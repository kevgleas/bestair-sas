****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

***************************************************************************************;
* IMPORT ALL BESTAIR REDCAP DATA FOR RANDOMIZED PARTICIPANTS
***************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\redcap\_components\bestair create rand set.sas";

  data redcap;
    set redcap_rand;
  run;

***************************************************************************************;
* IMPORT BESTAIR MEDICATION DATA FROM REDCAP
***************************************************************************************;

*Create Dataset that Stores Observations with Medications and Observations where we Expect Medications (a.k.a. Baseline);
  data pre_medications;
    set redcap (where = (med_studyid ne . or redcap_event_name = "00_bv_arm_1"));
  run;

  proc sort data = pre_medications;
  by elig_studyid;
  run;

*Create Datasets of Participants that Need Medication Status Checked;
  data multi_medtimepoints nomedsentered_anytimepoint missing_medsstudyid;
    set pre_medications;
    by elig_studyid;
    if first.elig_studyid and not last.elig_studyid then output multi_medtimepoints;
    if first.elig_studyid and last.elig_studyid and med_studyid = . then output nomedsentered_anytimepoint;
    if med_studyid = . and med_count ne . then output missing_medsstudyid;
  run;

  proc sql;
    title "Medications Entered at Multiple Timepoints";
    title2 "Previous Merge did not Work";
    select elig_studyid from multi_medtimepoints;
  quit;

  proc sql;
    title "No Medications Entered at Any Timepoint";
    title2 "Check that Participant Truly was Never taking Meds during Study";
    select elig_studyid from nomedsentered_anytimepoint;
  quit;

  proc sql;
    title "Participant Missing Meds_Studyid but has Data";
    title2 "Participant Will be Mistakenly Excluded from Meds Analysis";
    select elig_studyid from missing_medsstudyid;
  quit;

  data medications;
    set pre_medications;
    if med_studyid ne .;
    keep elig_studyid med_studyid--medications_complete;
  run;

  /*
  data medications;
    set bestair.baredcap;
    keep elig_studyid med_studyid--medications_complete;
  run;

  proc sql;
    delete from medications where med_studyid = .;
  quit;
  */
 
***************************************************************************************;
* DETERMINE VISIT DATES (TO BE USED IN CALCULATING WHETHER MEDS WERE TAKEN AT TIMEPOINT)
***************************************************************************************;

  *determine best date to use for "visitdate" for each timepoint;
  data store_visitdates;
    set redcap_rand (where = (redcap_event_name in("00_bv_arm_1", "06_fu_arm_1", "12_fu_arm_1")));

    if redcap_event_name = "00_bv_arm_1" then timepoint = 0;
    else if redcap_event_name = "06_fu_arm_1" then timepoint = 6;
    else if redcap_event_name = "12_fu_arm_1" then timepoint = 12;

    format timepoint_date YYMMDD10.;

    *create array of several visitdate variables in ascending order of likely accuracy of actual visitdate;
    array decide_visitdate[*] bplog_visitdate sf36_visitdate prom_visitdate phq8_visitdate
                              cal_datecompleted qctonom_visitdate bprp_visitdate anth_date;

    *set timepoint_date equal to value of visitdate variable most likely to be accurate;
    do i = 1 to dim(decide_visitdate);
      if decide_visitdate[i] ne . then timepoint_date = decide_visitdate[i];
    end;


    keep elig_studyid redcap_event_name bplog_visitdate sf36_visitdate prom_visitdate phq8_visitdate
          cal_datecompleted qctonom_visitdate bprp_visitdate anth_date timepoint timepoint_date;
  run;

  data baselinedates mo6dates mo12dates;
    set store_visitdates;
    if timepoint = 0 then output baselinedates;
    else if timepoint = 6 then output mo6dates;
    else if timepoint = 12 then output mo12dates;
  run;

  data baselinedates;
    set baselinedates (keep = elig_studyid timepoint_date);
    rename timepoint_date = baseline_date;
  run;

  data mo6dates;
    set mo6dates (keep = elig_studyid timepoint_date);
    rename timepoint_date = sixmonth_date;
  run;

  data mo12dates;
    set mo12dates (keep = elig_studyid timepoint_date);
    rename timepoint_date = twelvemonth_date;
  run;

  *this should be the dataset used instead of "dates" later in program;
  data all_visitdates;
    merge baselinedates mo6dates mo12dates;
    by elig_studyid;
    *if participant skipped 6-month but had 12-month data, then set 6-month "date" to 6-months from baseline;
    if sixmonth_date = . and twelvemonth_date ne . then sixmonth_date = baseline_date + ceil(365.25/2);
  run;

  data medications_withvisitdates;
    merge randset all_visitdates medications (in = meds_reported);
    by elig_studyid;
    if meds_reported;
  run;

  data meds_denotechanges_postrand;
    set medications_withvisitdates;

    medchange_noted = 0;

    array medstartdates[60] med_startdate01-med_startdate60;
    array medenddates[60] med_enddate01-med_enddate60;

    do i = 1 to 60;
      if baselinedate < medstartdates[i] le mo6date then medchange_after00_before06 = 1;
      else if mo6date < medstartdates[i] le mo12date then medchange_after06_before12 = 1;
    end;

    do j = 1 to 60;
      if baselinedate < medenddates[j] le mo6date then medchange_after00_before06 = 1;
      else if mo6date < medenddates[j] le mo12date then medchange_after06_before12 = 1;
    end;

    drop i j;

    if medchange_after00_before06 ne 1 and medchange_after06_before12 ne 1 then nomedchange_since00 = 1;

  run;

  proc sql noprint;
    select elig_studyid into :studyids_nomedchanges
    separated by ' , '
    from meds_denotechanges_postrand
    where nomedchange_since00 = 1;

    select elig_studyid into :studyids_withmedchanges
    separated by ' , '
    from meds_denotechanges_postrand
    where nomedchange_since00 ne 1;
  quit;


  data dates;
    set all_visitdates;
    rename baseline_date = baseline;
    rename sixmonth_date = sixmonth;
    rename twelvemonth_date = twelvemonth;
  run;


	data medications2;
		set medications;

			med_nameother01 = med_name01other;
			med_nameother02 = med_name02other;
			med_nameother03	= med_name03other;
			med_nameother04	= med_name04other;
			med_nameother05	= med_name05other;
			med_nameother06	= med_name06other;
			med_nameother07	= med_name07other;
			med_nameother08	= med_name08other;
			med_nameother09	= med_name09other;
			med_nameother10	= med_name10other;
			med_nameother11	= med_name11other;
			med_nameother12	= med_name12other;
			med_nameother13	= med_name13other;
			med_nameother14	= med_name14other;
			med_nameother15	= med_name15other;
			med_nameother16	= med_name16other;
			med_nameother17	= med_name17other;
			med_nameother18	= med_name18other;
			med_nameother19	= med_name19other;
			med_nameother20	= med_name20other;
			med_nameother21	= med_name21other;
			med_nameother22	= med_name22other;
			med_nameother23	= med_name23other;
			med_nameother24	= med_name24other;
			med_nameother25	= med_name25other;
			med_nameother26	= med_name26other;
			med_nameother27	= med_name27other;
			med_nameother28	= med_name28other;
			med_nameother29	= med_name29other;
			med_nameother30	= med_name30other;
			med_nameother31	= med_name31other;
			med_nameother32	= med_name32other;
			med_nameother33	= med_name33other;
			med_nameother34	= med_name34other;
			med_nameother35	= med_name35other;
			med_nameother36	= med_name36other;
			med_nameother37	= med_name37other;
			med_nameother38	= med_name38other;
			med_nameother39	= med_name39other;
			med_nameother40	= med_name40other;
			med_nameother41	= med_name41other;
			med_nameother42	= med_name42other;
			med_nameother43	= med_name43other;
			med_nameother44	= med_name44other;
			med_nameother45	= med_name45other;
			med_nameother46	= med_name46other;
			med_nameother47	= med_name47other;
			med_nameother48	= med_name48other;
			med_nameother49	= med_name49other;
			med_nameother50	= med_name50other;
			med_nameother51	= med_name51other;
			med_nameother52	= med_name52other;
			med_nameother53	= med_name53other;
			med_nameother54	= med_name54other;
			med_nameother55	= med_name55other;
			med_nameother56	= med_name56other;
			med_nameother57	= med_name57other;
			med_nameother58	= med_name58other;
			med_nameother59	= med_name59other;
			med_nameother60	= med_name60other;
			med_startdate02 = med_startdate_02;
			med_startdate32 = med_startdate_32;
	run;

	*list each medication as a separate observation by elig_studyid;
	proc transpose data=medications2 out=wide1;
	    by elig_Studyid;
		var med_name01-med_name60;
	run;

	*rename variable and drop second column auto-generated by transpose step;
	data wide1;
		set wide1(rename=COL1=med_name);
		drop COL2;
	run;

***************************;
* repeat two steps above for
* each relevant variable;
***************************;
	proc transpose data=medications2 out=wide2;
	    by elig_Studyid;
		var med_nameother01-med_nameother60;
	run;

	data wide2;
		set wide2(rename=COL1=med_nameother);
		drop COL2;
	run;

	proc transpose data=medications2 out=wide3;
	    by elig_Studyid;
		var med_strength01-med_strength60;
	run;

	data wide3;
		set wide3(rename=COL1=med_strength);
		drop COL2;
	run;

	proc transpose data=medications2 out=wide4;
	    by elig_Studyid;
		var med_doseamount01-med_doseamount60;
	run;

	data wide4;
		set wide4(rename=COL1=med_dose);
		drop COL2;
	run;

	proc transpose data=medications2 out=wide5;
	    by elig_Studyid;
		var med_dosetype01-med_dosetype60;
	run;

	data wide5;
		set wide5(rename=COL1=med_type);
		drop COL2;
	run;

	proc transpose data=medications2 out=wide6;
	    by elig_Studyid;
		var med_freq01-med_freq60;
	run;

	data wide6;
		set wide6(rename=COL1=med_freq);
		drop COL2;
	run;

	proc transpose data=medications2 out=wide7;
	    by elig_Studyid;
		var med_startdate01-med_startdate60;
	run;

	data wide7;
		set wide7(rename=COL1=med_startdate);
		drop COL2;
	run;

	proc transpose data=medications2 out=wide8;
	    by elig_Studyid;
		var med_enddate01-med_enddate60;
	run;

	data wide8;
		set wide8(rename=COL1=med_enddate);
		drop COL2;
	run;

	*merge above datasets to put each variable for given medication as same observation;
	data medmerge;
		merge wide1 wide2 wide3 wide4 wide5 wide6 wide7 wide8;
		by elig_studyid;
		drop _NAME_ _LABEL_;
	run;

	*delete empty observations;
	proc sql;
		delete from medmerge where med_name = .;
	quit;

	*add variable with medication name based on REDCap's number coding for medications;
	data medmerge_rename;
		set medmerge;

		format med_name2 $100.;
		if med_name = 1 then med_name2 = "Acetaminophen";
		if med_name = 2 then med_name2 = "Acyclovir";
		if med_name = 3 then med_name2 = "Albuterol";
		if med_name = 4 then med_name2 = "Allopurinol";
		if med_name = 5 then med_name2 = "Alprostadil";
		if med_name = 6 then med_name2 = "Amiodarone";
		if med_name = 7 then med_name2 = "Amitriptyline";
		if med_name = 8 then med_name2 = "Amlodipine";
		if med_name = 9 then med_name2 = "Aspirin";
		if med_name = 10 then med_name2 = "Atenolol";
		if med_name = 11 then med_name2 = "Atorvastatin";
		if med_name = 12 then med_name2 = "Azithromycin";
		if med_name = 13 then med_name2 = "Beclomethasone";
		if med_name = 14 then med_name2 = "Benazepril";
		if med_name = 15 then med_name2 = "Biotin";
		if med_name = 16 then med_name2 = "Bisoprolol";
		if med_name = 17 then med_name2 = "Bupropion";
		if med_name = 18 then med_name2 = "Calcium";
		if med_name = 19 then med_name2 = "Candesartan";
		if med_name = 20 then med_name2 = "Carvedilol";
		if med_name = 21 then med_name2 = "Celecoxib";
		if med_name = 22 then med_name2 = "Cetirizine";
		if med_name = 23 then med_name2 = "Cholecalciferol";
		if med_name = 24 then med_name2 = "Cilostazol";
		if med_name = 25 then med_name2 = "Citalopram";
		if med_name = 26 then med_name2 = "Clonazepam";
		if med_name = 27 then med_name2 = "Clopidogrel";
		if med_name = 28 then med_name2 = "Codeine";
		if med_name = 29 then med_name2 = "Coenzyme Q10";
		if med_name = 30 then med_name2 = "Colace";
		if med_name = 31 then med_name2 = "Colchicine";
		if med_name = 32 then med_name2 = "Colesevelam";
		if med_name = 33 then med_name2 = "Cyanocobalamin";
		if med_name = 34 then med_name2 = "Cyclobenzaprine";
		if med_name = 35 then med_name2 = "Desonide";
		if med_name = 36 then med_name2 = "Diazepam";
		if med_name = 37 then med_name2 = "Digoxin";
		if med_name = 38 then med_name2 = "Diltiazem";
		if med_name = 39 then med_name2 = "Docusate";
		if med_name = 40 then med_name2 = "Dorzolamide";
		if med_name = 41 then med_name2 = "Doxazosin";
		if med_name = 42 then med_name2 = "Duloxetine";
		if med_name = 43 then med_name2 = "Enalapril";
		if med_name = 44 then med_name2 = "Escitalopram";
		if med_name = 45 then med_name2 = "Esomeprazole";
		if med_name = 46 then med_name2 = "Ezetimibe";
		if med_name = 47 then med_name2 = "Felodipine";
		if med_name = 48 then med_name2 = "Fenofibrate";
		if med_name = 49 then med_name2 = "Ferrous Sulfate";
		if med_name = 50 then med_name2 = "Fexofenadine";
		if med_name = 51 then med_name2 = "Fish Oil";
		if med_name = 52 then med_name2 = "Flunisolide";
		if med_name = 53 then med_name2 = "Fluoxetine";
		if med_name = 54 then med_name2 = "Fluticasone";
		if med_name = 55 then med_name2 = "Folic Acid";
		if med_name = 56 then med_name2 = "Furosemide";
		if med_name = 57 then med_name2 = "Gabapentin";
		if med_name = 58 then med_name2 = "Garlic";
		if med_name = 59 then med_name2 = "Gemfibrozil";
		if med_name = 60 then med_name2 = "Glimepiride";
		if med_name = 61 then med_name2 = "Glipizide";
		if med_name = 62 then med_name2 = "Glyburide";
		if med_name = 63 then med_name2 = "Hydrochlorothiazide";
		if med_name = 64 then med_name2 = "Hydroxyzine";
		if med_name = 65 then med_name2 = "Ibuprofen";
		if med_name = 66 then med_name2 = "Insulin";
		if med_name = 67 then med_name2 = "Ipratropium";
		if med_name = 68 then med_name2 = "Isosorbide";
		if med_name = 69 then med_name2 = "Latanoprost";
		if med_name = 70 then med_name2 = "Levothyroxine";
		if med_name = 71 then med_name2 = "Levoxyl";
		if med_name = 72 then med_name2 = "Liraglutide";
		if med_name = 73 then med_name2 = "Lisinopril";
		if med_name = 74 then med_name2 = "Loratadine";
		if med_name = 75 then med_name2 = "Lorazepam";
		if med_name = 76 then med_name2 = "Losartan";
		if med_name = 77 then med_name2 = "Lovastatin";
		if med_name = 78 then med_name2 = "Meloxicam";
		if med_name = 79 then med_name2 = "Metformin";
		if med_name = 80 then med_name2 = "Methylphenidate";
		if med_name = 81 then med_name2 = "Metoprolol";
		if med_name = 82 then med_name2 = "Mirtazapine";
		if med_name = 83 then med_name2 = "Mometasone";
		if med_name = 84 then med_name2 = "Montelukast";
		if med_name = 85 then med_name2 = "Multivitamin";
		if med_name = 86 then med_name2 = "Nabumetone";
		if med_name = 87 then med_name2 = "Naproxen";
		if med_name = 88 then med_name2 = "Niacin";
		if med_name = 89 then med_name2 = "Nifedipine";
		if med_name = 90 then med_name2 = "Nitroglycerin";
		if med_name = 91 then med_name2 = "Nortriptyline";
		if med_name = 92 then med_name2 = "Olmesartan";
		if med_name = 93 then med_name2 = "Omega-3 Acid";
		if med_name = 94 then med_name2 = "Omeprazole";
		if med_name = 95 then med_name2 = "Oxycodone";
		if med_name = 96 then med_name2 = "Pantoprazole";
		if med_name = 97 then med_name2 = "Paroxetine";
		if med_name = 98 then med_name2 = "Pioglitazone";
		if med_name = 99 then med_name2 = "Potassium chloride";
		if med_name = 100 then med_name2 = "Pravastatin";
		if med_name = 101 then med_name2 = "Prazosin";
		if med_name = 102 then med_name2 = "Prednisone";
		if med_name = 103 then med_name2 = "Pregabalin";
		if med_name = 104 then med_name2 = "Probenecid";
		if med_name = 105 then med_name2 = "Propionate";
		if med_name = 106 then med_name2 = "Quetiapine";
		if med_name = 107 then med_name2 = "Ramipril";
		if med_name = 108 then med_name2 = "Ranitidine";
		if med_name = 109 then med_name2 = "Rosiglitazone";
		if med_name = 110 then med_name2 = "Rosuvastatin";
		if med_name = 111 then med_name2 = "Salmeterol";
		if med_name = 112 then med_name2 = "Sennosides";
		if med_name = 113 then med_name2 = "Sertraline";
		if med_name = 114 then med_name2 = "Sildenafil";
		if med_name = 115 then med_name2 = "Simvastatin";
		if med_name = 116 then med_name2 = "Sitagliptin";
		if med_name = 117 then med_name2 = "Sodium Chloride	";
		if med_name = 118 then med_name2 = "Solifenacin";
		if med_name = 119 then med_name2 = "Spironolactone";
		if med_name = 120 then med_name2 = "Sulfasalazine";
		if med_name = 121 then med_name2 = "Terazosin";
		if med_name = 122 then med_name2 = "Tiotropium";
		if med_name = 123 then med_name2 = "Topiramate";
		if med_name = 124 then med_name2 = "Tramadol";
		if med_name = 125 then med_name2 = "Travoprost";
		if med_name = 126 then med_name2 = "Trazodone";
		if med_name = 127 then med_name2 = "Valsartan";
		if med_name = 128 then med_name2 = "Vardenafil";
		if med_name = 129 then med_name2 = "Venlafaxine";
		if med_name = 130 then med_name2 = "Vitamin C";
		if med_name = 131 then med_name2 = "Vitamin D";
		if med_name = 132 then med_name2 = "Vitamin E";
		if med_name = 133 then med_name2 = "Warfarin";
		if med_name = 134 then med_name2 = "Zolpidem";
		if med_name = 999 then med_name2 = "Other";

		drop med_name;
	run;

	data medmerge_reorder;
		retain elig_studyid medname med_nameother med_strength med_dose med_type med_freq med_startdate med_enddate;
		set medmerge_rename (rename=med_name2=medname);
	run;

	*import .csv file that lists alternative names for medications;
	PROC IMPORT OUT= atc_in
	            DATAFILE= "\\rfa01\BWH-SleepEpi-bestair\data\SAS\medications\atc_mergelist.csv"
	            DBMS=csv REPLACE;
							GUESSINGROWS = 30000;
	RUN;


	proc sort data=medmerge_reorder;
		by elig_studyid medname;
	run;

	*print participants missing start date as list to collect missing data;
	proc sql;
		title "BestAIR Participants Missing 'Start Date' on Medications Sheet"; select elig_studyid from medmerge_reorder where med_startdate = .; title;
	quit;

	proc sql;
		create table medmergesql as

		select * from medmerge_reorder full join atc_in
		on medname;
	quit;

	proc sort data=medmergesql out=medmergesql2;
		by elig_studyid medname mednames;
	run;

	data premerge;
		set medmergesql2;

		if medname = "Other" then medname = med_nameother;
		drop med_nameother;
	run;

	*create datasets for matched and unmatched mednames;
	data bamed_matched bamed_unmatched;
		set premerge;

			if	lowcase(medname) = lowcase(mednames) or
				lowcase(medname) = lowcase(brandname1) or
				lowcase(medname) = lowcase(brandname2) or
				lowcase(medname) = lowcase(brandname3) or
				lowcase(medname) = lowcase(altnames) or
				lowcase(medname) = lowcase(altname1) or
				lowcase(medname) = lowcase(altname2) or
				lowcase(medname) = lowcase(altname3) or
				lowcase(medname) = lowcase(altname4) or
				lowcase(medname) = lowcase(altname5) or
				lowcase(medname) = lowcase(altname6) or
				lowcase(medname) = lowcase(altname7) or
				lowcase(medname) = lowcase(altname8) or
				lowcase(medname) = lowcase(altname9) or
				lowcase(medname) = lowcase(altname10) or
				lowcase(medname) = lowcase(altname11) or
				lowcase(medname) = lowcase(altname12) or
				lowcase(medname) = lowcase(altname13) or
				lowcase(medname) = lowcase(altname14) or
				lowcase(medname) = lowcase(altname15) or
				lowcase(medname) = lowcase(altname16) or
				lowcase(medname) = lowcase(altname17) or
				lowcase(medname) = lowcase(altname18) or
				lowcase(medname) = lowcase(altname19) or
				lowcase(medname) = lowcase(altname20) or
				lowcase(medname) = lowcase(altname21) or
				lowcase(medname) = lowcase(altname22) or
				lowcase(medname) = lowcase(altname23) or
				lowcase(medname) = lowcase(altname24) or
				lowcase(medname) = lowcase(altname25) or
				lowcase(medname) = lowcase(altname26) or
				lowcase(medname) = lowcase(altname27) or
				lowcase(medname) = lowcase(altname28) or
				lowcase(medname) = lowcase(altname29) or
				lowcase(medname) = lowcase(altname30) or
				lowcase(medname) = lowcase(altname31) or
				lowcase(medname) = lowcase(altname32) or
				lowcase(medname) = lowcase(altname33) or
				lowcase(medname) = lowcase(altname34) or
				lowcase(medname) = lowcase(altname35) or
				lowcase(medname) = lowcase(altname36) or
				lowcase(medname) = lowcase(altname37) or
				lowcase(medname) = lowcase(altname38) or
				lowcase(medname) = lowcase(altname39) or
				lowcase(medname) = lowcase(altname40) or
				lowcase(medname) = lowcase(altname41) or
				lowcase(medname) = lowcase(altname42) or
				lowcase(medname) = lowcase(altname43) or
				lowcase(medname) = lowcase(altname44) or
				lowcase(medname) = lowcase(altname45) or
				lowcase(medname) = lowcase(altname46) or
				lowcase(medname) = lowcase(altname47) or
				lowcase(medname) = lowcase(altname48) or
				lowcase(medname) = lowcase(altname49) or
				lowcase(medname) = lowcase(altname50) or
				lowcase(medname) = lowcase(altname51) or
				lowcase(medname) = lowcase(altname52) or
				lowcase(medname) = lowcase(altname53) or
				lowcase(medname) = lowcase(altname54) or
				lowcase(medname) = lowcase(altname55) or
				lowcase(medname) = lowcase(altname56) or
				lowcase(medname) = lowcase(altname57) or
				lowcase(medname) = lowcase(altname58) or
				lowcase(medname) = lowcase(altname59) or
				lowcase(medname) = lowcase(altname60) or
				lowcase(medname) = lowcase(altname61) or
				lowcase(medname) = lowcase(altname62) or
				lowcase(medname) = lowcase(altname63) or
				lowcase(medname) = lowcase(altname64) or
				lowcase(medname) = lowcase(altname65) or
				lowcase(medname) = lowcase(altname66) or
				lowcase(medname) = lowcase(altname67) or
				lowcase(medname) = lowcase(altname68) or
				lowcase(medname) = lowcase(altname69) or
				lowcase(medname) = lowcase(altname70) or
				lowcase(medname) = lowcase(altname71) or
				lowcase(medname) = lowcase(altname72) or
				lowcase(medname) = lowcase(altname73)
				then output bamed_matched;
		else output bamed_unmatched;
	run;

	proc sort data=bamed_unmatched nodupkey;
		by elig_studyid medname med_strength med_startdate med_dose;
	run;

	proc sort data=bamed_matched nodupkey;
		by elig_studyid medname med_strength med_startdate med_dose;
	run;

	*obtain visit_dates from redcap;
	data visit_dates;
		set bestair.baredcap;
		keep elig_studyid redcap_event_name anth_studyid anth_date;
	run;

	proc sql;
		delete
		from visit_dates
		where anth_studyid = . or anth_studyid = -9;
	quit;

	data date;
		set visit_dates;

		if redcap_event_name = "00_bv_arm_1" then baseline = anth_date;
		else if redcap_event_name = "06_fu_arm_1" then sixmonth = anth_date;
		else if redcap_event_name = "12_fu_arm_1" then twelvemonth = anth_date;

		drop anth_date anth_studyid;

	run;

	data date_base;
		set	date(where=(redcap_event_name = "00_bv_arm_1"));

		drop twelvemonth sixmonth;
	run;

	data date_six;
		set	date(where=(redcap_event_name = "06_fu_arm_1"));

		drop baseline twelvemonth;
	run;

	data date_12;
		set	date(where=(redcap_event_name = "12_fu_arm_1"));

		drop baseline sixmonth;
	run;

	*merge dates of each visit by studyid;
	data dates;
		merge date_base date_six date_12;
		by elig_studyid;
		drop redcap_event_name;
	run;

	data med_dates;
		merge bamed_matched (in=a) dates (in=b);
		by elig_studyid;

		format baseline sixmonth twelvemonth med_startdate YYMMDD10.;
		if a and b;
	run;

	*set flags for whether a particular medication was being taken at each visit;
	*save over bamed_matched dataset to keep consistent and logical naming;
	data bamed_matched med_fail;
		set med_dates;

		if med_startdate le baseline then timepoint1 = 1;
		if med_startdate > baseline then timepoint1 = 0;
		if med_startdate le sixmonth and sixmonth ne . then timepoint2 = 1;
		if med_enddate le sixmonth and sixmonth ne . and med_enddate ne . then timepoint2 = 0;
		if med_startdate > sixmonth and sixmonth ne . then timepoint2 = 0;
		if med_startdate le twelvemonth and twelvemonth ne . then timepoint3 = 1;
		if med_enddate le twelvemonth and twelvemonth ne . and med_enddate ne . then timepoint3 = 0;

		if med_startdate = . then timepoint1 = 99;

		if med_startdate > today() then output med_FAIL;
		else output bamed_matched;

	run;

	*fix "unmatched" dataset to hold only variables that are truly unmatched;
	data bamed_unmatched;
		merge bamed_unmatched (in=a) bamed_matched (in=b);
		by elig_studyid medname;

		if a and NOT b;
	run;

	data unmatched;
		set bamed_unmatched;
		medname = lowcase(medname);
	run;

	proc sql;
		create table unmatched_count as
		select elig_studyid, medname, count(medname) as medcount
		from unmatched
		group by medname;

		select elig_studyid, medname, medcount
		from unmatched_count
		order by medname asc;

	quit;

*****************************************************************************************;
* ACE INHIBITOR OR ARB
*****************************************************************************************;
	data med_aceinhibitor;
		set bamed_matched;

		if 	substr(atccode1,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode2,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode3,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode4,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode5,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode6,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode7,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode8,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode9,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode10,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode11,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode12,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode13,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode14,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode15,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode16,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode17,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode18,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode19,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode20,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode21,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode22,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode23,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode24,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode25,1,4) in ('C09A','C09B','C09C','C09D') or
				substr(atccode1,1,7) = 'C10BX04' or
				substr(atccode2,1,7) = 'C10BX04' or
				substr(atccode3,1,7) = 'C10BX04' or
				substr(atccode4,1,7) = 'C10BX04' or
				substr(atccode5,1,7) = 'C10BX04' or
				substr(atccode6,1,7) = 'C10BX04' or
				substr(atccode7,1,7) = 'C10BX04' or
				substr(atccode8,1,7) = 'C10BX04' or
				substr(atccode9,1,7) = 'C10BX04' or
				substr(atccode10,1,7) = 'C10BX04' or
				substr(atccode11,1,7) = 'C10BX04' or
				substr(atccode12,1,7) = 'C10BX04' or
				substr(atccode13,1,7) = 'C10BX04' or
				substr(atccode14,1,7) = 'C10BX04' or
				substr(atccode15,1,7) = 'C10BX04' or
				substr(atccode16,1,7) = 'C10BX04' or
				substr(atccode17,1,7) = 'C10BX04' or
				substr(atccode18,1,7) = 'C10BX04' or
				substr(atccode19,1,7) = 'C10BX04' or
				substr(atccode20,1,7) = 'C10BX04' or
				substr(atccode21,1,7) = 'C10BX04' or
				substr(atccode22,1,7) = 'C10BX04' or
				substr(atccode23,1,7) = 'C10BX04' or
				substr(atccode24,1,7) = 'C10BX04' or
				substr(atccode25,1,7) = 'C10BX04';
	run;

	proc sql;
		create table med_aceinhibitor_count as
		select elig_studyid, count(elig_studyid) as aceinhibitor_n, timepoint1, timepoint2, timepoint3
		from med_aceinhibitor
		group by elig_studyid;
	quit;

	proc sort data=med_aceinhibitor nodupkey;
		by elig_studyid;
	run;


*****************************************************************************************;
* ALPHA BLOCKER
*****************************************************************************************;
	data med_alphablocker;
		set bamed_matched;
		if substr(atccode1,1,5) = 'C02CA' or
				substr(atccode2,1,5) = 'C02CA' or
				substr(atccode3,1,5) = 'C02CA' or
				substr(atccode4,1,5) = 'C02CA' or
				substr(atccode5,1,5) = 'C02CA' or
				substr(atccode6,1,5) = 'C02CA' or
				substr(atccode7,1,5) = 'C02CA' or
				substr(atccode8,1,5) = 'C02CA' or
				substr(atccode9,1,5) = 'C02CA' or
				substr(atccode10,1,5) = 'C02CA' or
				substr(atccode11,1,5) = 'C02CA' or
				substr(atccode12,1,5) = 'C02CA' or
				substr(atccode13,1,5) = 'C02CA' or
				substr(atccode14,1,5) = 'C02CA' or
				substr(atccode15,1,5) = 'C02CA' or
				substr(atccode16,1,5) = 'C02CA' or
				substr(atccode17,1,5) = 'C02CA' or
				substr(atccode18,1,5) = 'C02CA' or
				substr(atccode19,1,5) = 'C02CA' or
				substr(atccode20,1,5) = 'C02CA' or
				substr(atccode21,1,5) = 'C02CA' or
				substr(atccode22,1,5) = 'C02CA' or
				substr(atccode23,1,5) = 'C02CA' or
				substr(atccode24,1,5) = 'C02CA' or
				substr(atccode25,1,5) = 'C02CA';
	run;

	proc sql;
		create table med_alphablocker_count as
		select elig_studyid, count(elig_studyid) as alphablocker_n, timepoint1, timepoint2, timepoint3
		from med_alphablocker
		group by elig_studyid;
	quit;

	proc sort data=med_alphablocker nodupkey;
		by elig_studyid;
	run;


*****************************************************************************************;
* ALDOSTERONE BLOCKER -- added 11/20/2012 for Walia/Mehra
*****************************************************************************************;
	data med_aldosteroneblocker;
		set bamed_matched;
		if substr(atccode1,1,5) = 'C03DA' or
				substr(atccode2,1,5) = 'C03DA' or
				substr(atccode3,1,5) = 'C03DA' or
				substr(atccode4,1,5) = 'C03DA' or
				substr(atccode5,1,5) = 'C03DA' or
				substr(atccode6,1,5) = 'C03DA' or
				substr(atccode7,1,5) = 'C03DA' or
				substr(atccode8,1,5) = 'C03DA' or
				substr(atccode9,1,5) = 'C03DA' or
				substr(atccode10,1,5) = 'C03DA' or
				substr(atccode11,1,5) = 'C03DA' or
				substr(atccode12,1,5) = 'C03DA' or
				substr(atccode13,1,5) = 'C03DA' or
				substr(atccode14,1,5) = 'C03DA' or
				substr(atccode15,1,5) = 'C03DA' or
				substr(atccode16,1,5) = 'C03DA' or
				substr(atccode17,1,5) = 'C03DA' or
				substr(atccode18,1,5) = 'C03DA' or
				substr(atccode19,1,5) = 'C03DA' or
				substr(atccode20,1,5) = 'C03DA' or
				substr(atccode21,1,5) = 'C03DA' or
				substr(atccode22,1,5) = 'C03DA' or
				substr(atccode23,1,5) = 'C03DA' or
				substr(atccode24,1,5) = 'C03DA' or
				substr(atccode25,1,5) = 'C03DA';
	run;

	proc sql;
		create table med_aldosteroneblocker_count as
		select elig_studyid, count(elig_studyid) as aldosteroneblocker_n, timepoint1, timepoint2, timepoint3
		from med_aldosteroneblocker
		group by elig_studyid;
	quit;

	proc sort data=med_aldosteroneblocker nodupkey;
		by elig_studyid;
	run;



*****************************************************************************************;
* BETA BLOCKER
*****************************************************************************************;
	data med_betablocker;
		set bamed_matched;

		if 	substr(atccode1,1,3) = 'C07' or
				substr(atccode2,1,3) = 'C07' or
				substr(atccode3,1,3) = 'C07' or
				substr(atccode4,1,3) = 'C07' or
				substr(atccode5,1,3) = 'C07' or
				substr(atccode6,1,3) = 'C07' or
				substr(atccode7,1,3) = 'C07' or
				substr(atccode8,1,3) = 'C07' or
				substr(atccode9,1,3) = 'C07' or
				substr(atccode10,1,3) = 'C07' or
				substr(atccode11,1,3) = 'C07' or
				substr(atccode12,1,3) = 'C07' or
				substr(atccode13,1,3) = 'C07' or
				substr(atccode14,1,3) = 'C07' or
				substr(atccode15,1,3) = 'C07' or
				substr(atccode16,1,3) = 'C07' or
				substr(atccode17,1,3) = 'C07' or
				substr(atccode18,1,3) = 'C07' or
				substr(atccode19,1,3) = 'C07' or
				substr(atccode20,1,3) = 'C07' or
				substr(atccode21,1,3) = 'C07' or
				substr(atccode22,1,3) = 'C07' or
				substr(atccode23,1,3) = 'C07' or
				substr(atccode24,1,3) = 'C07' or
				substr(atccode25,1,3) = 'C07';
	run;

	proc sql;
		create table med_betablocker_count as
		select elig_studyid, count(elig_studyid) as betablocker_n, timepoint1, timepoint2, timepoint3
		from med_betablocker
		group by elig_studyid;
	quit;

	proc sort data=med_betablocker nodupkey;
		by elig_studyid;
	run;


*****************************************************************************************;
* CALCIUM CHANNEL BLOCKER
*****************************************************************************************;
	data med_calciumblocker;
		set bamed_matched;

		if substr(atccode1,1,3) = 'C08' or
				substr(atccode2,1,3) = 'C08' or
				substr(atccode3,1,3) = 'C08' or
				substr(atccode4,1,3) = 'C08' or
				substr(atccode5,1,3) = 'C08' or
				substr(atccode6,1,3) = 'C08' or
				substr(atccode7,1,3) = 'C08' or
				substr(atccode8,1,3) = 'C08' or
				substr(atccode9,1,3) = 'C08' or
				substr(atccode10,1,3) = 'C08' or
				substr(atccode11,1,3) = 'C08' or
				substr(atccode12,1,3) = 'C08' or
				substr(atccode13,1,3) = 'C08' or
				substr(atccode14,1,3) = 'C08' or
				substr(atccode15,1,3) = 'C08' or
				substr(atccode16,1,3) = 'C08' or
				substr(atccode17,1,3) = 'C08' or
				substr(atccode18,1,3) = 'C08' or
				substr(atccode19,1,3) = 'C08' or
				substr(atccode20,1,3) = 'C08' or
				substr(atccode21,1,3) = 'C08' or
				substr(atccode22,1,3) = 'C08' or
				substr(atccode23,1,3) = 'C08' or
				substr(atccode24,1,3) = 'C08' or
				substr(atccode25,1,3) = 'C08' or
				substr(atccode1,1,5) = 'C09BB' or
				substr(atccode2,1,5) = 'C09BB' or
				substr(atccode3,1,5) = 'C09BB' or
				substr(atccode4,1,5) = 'C09BB' or
				substr(atccode5,1,5) = 'C09BB' or
				substr(atccode6,1,5) = 'C09BB' or
				substr(atccode7,1,5) = 'C09BB' or
				substr(atccode8,1,5) = 'C09BB' or
				substr(atccode9,1,5) = 'C09BB' or
				substr(atccode10,1,5) = 'C09BB' or
				substr(atccode11,1,5) = 'C09BB' or
				substr(atccode12,1,5) = 'C09BB' or
				substr(atccode13,1,5) = 'C09BB' or
				substr(atccode14,1,5) = 'C09BB' or
				substr(atccode15,1,5) = 'C09BB' or
				substr(atccode16,1,5) = 'C09BB' or
				substr(atccode17,1,5) = 'C09BB' or
				substr(atccode18,1,5) = 'C09BB' or
				substr(atccode19,1,5) = 'C09BB' or
				substr(atccode20,1,5) = 'C09BB' or
				substr(atccode21,1,5) = 'C09BB' or
				substr(atccode22,1,5) = 'C09BB' or
				substr(atccode23,1,5) = 'C09BB' or
				substr(atccode24,1,5) = 'C09BB' or
				substr(atccode25,1,5) = 'C09BB' or
				substr(atccode1,1,5) = 'C09DB' or
				substr(atccode2,1,5) = 'C09DB' or
				substr(atccode3,1,5) = 'C09DB' or
				substr(atccode4,1,5) = 'C09DB' or
				substr(atccode5,1,5) = 'C09DB' or
				substr(atccode6,1,5) = 'C09DB' or
				substr(atccode7,1,5) = 'C09DB' or
				substr(atccode8,1,5) = 'C09DB' or
				substr(atccode9,1,5) = 'C09DB' or
				substr(atccode10,1,5) = 'C09DB' or
				substr(atccode11,1,5) = 'C09DB' or
				substr(atccode12,1,5) = 'C09DB' or
				substr(atccode13,1,5) = 'C09DB' or
				substr(atccode14,1,5) = 'C09DB' or
				substr(atccode15,1,5) = 'C09DB' or
				substr(atccode16,1,5) = 'C09DB' or
				substr(atccode17,1,5) = 'C09DB' or
				substr(atccode18,1,5) = 'C09DB' or
				substr(atccode19,1,5) = 'C09DB' or
				substr(atccode20,1,5) = 'C09DB' or
				substr(atccode21,1,5) = 'C09DB' or
				substr(atccode22,1,5) = 'C09DB' or
				substr(atccode23,1,5) = 'C09DB' or
				substr(atccode24,1,5) = 'C09DB' or
				substr(atccode25,1,5) = 'C09DB' or
				substr(atccode1,1,7) in ('C09DX03','C10BX03') or
				substr(atccode2,1,7) in ('C09DX03','C10BX03') or
				substr(atccode3,1,7) in ('C09DX03','C10BX03') or
				substr(atccode4,1,7) in ('C09DX03','C10BX03') or
				substr(atccode5,1,7) in ('C09DX03','C10BX03') or
				substr(atccode6,1,7) in ('C09DX03','C10BX03') or
				substr(atccode7,1,7) in ('C09DX03','C10BX03') or
				substr(atccode8,1,7) in ('C09DX03','C10BX03') or
				substr(atccode9,1,7) in ('C09DX03','C10BX03') or
				substr(atccode10,1,7) in ('C09DX03','C10BX03') or
				substr(atccode11,1,7) in ('C09DX03','C10BX03') or
				substr(atccode12,1,7) in ('C09DX03','C10BX03') or
				substr(atccode13,1,7) in ('C09DX03','C10BX03') or
				substr(atccode14,1,7) in ('C09DX03','C10BX03') or
				substr(atccode15,1,7) in ('C09DX03','C10BX03') or
				substr(atccode16,1,7) in ('C09DX03','C10BX03') or
				substr(atccode17,1,7) in ('C09DX03','C10BX03') or
				substr(atccode18,1,7) in ('C09DX03','C10BX03') or
				substr(atccode19,1,7) in ('C09DX03','C10BX03') or
				substr(atccode20,1,7) in ('C09DX03','C10BX03') or
				substr(atccode21,1,7) in ('C09DX03','C10BX03') or
				substr(atccode22,1,7) in ('C09DX03','C10BX03') or
				substr(atccode23,1,7) in ('C09DX03','C10BX03') or
				substr(atccode24,1,7) in ('C09DX03','C10BX03') or
				substr(atccode25,1,7) in ('C09DX03','C10BX03');
	run;

	proc sql;
		create table med_calciumblocker_count as
		select elig_studyid, count(elig_studyid) as calciumblocker_n, timepoint1, timepoint2, timepoint3
		from med_calciumblocker
		group by elig_studyid;
	quit;

	proc sort data=med_calciumblocker nodupkey;
		by elig_studyid;
	run;


*****************************************************************************************;
* DIURETICS
*****************************************************************************************;

	data med_diuretics;
		set bamed_matched;

		if substr(atccode1,1,3) = 'C03' or
				substr(atccode1,1,3) = 'C03' or
				substr(atccode2,1,3) = 'C03' or
				substr(atccode3,1,3) = 'C03' or
				substr(atccode4,1,3) = 'C03' or
				substr(atccode5,1,3) = 'C03' or
				substr(atccode6,1,3) = 'C03' or
				substr(atccode7,1,3) = 'C03' or
				substr(atccode8,1,3) = 'C03' or
				substr(atccode9,1,3) = 'C03' or
				substr(atccode10,1,3) = 'C03' or
				substr(atccode11,1,3) = 'C03' or
				substr(atccode12,1,3) = 'C03' or
				substr(atccode13,1,3) = 'C03' or
				substr(atccode14,1,3) = 'C03' or
				substr(atccode15,1,3) = 'C03' or
				substr(atccode16,1,3) = 'C03' or
				substr(atccode17,1,3) = 'C03' or
				substr(atccode18,1,3) = 'C03' or
				substr(atccode19,1,3) = 'C03' or
				substr(atccode20,1,3) = 'C03' or
				substr(atccode21,1,3) = 'C03' or
				substr(atccode22,1,3) = 'C03' or
				substr(atccode23,1,3) = 'C03' or
				substr(atccode24,1,3) = 'C03' or
				substr(atccode25,1,3) = 'C03' or
				substr(atccode1,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode2,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode3,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode4,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode5,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode6,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode7,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode8,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode9,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode10,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode11,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode12,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode13,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode14,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode15,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode16,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode17,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode18,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode19,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode20,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode21,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode22,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode23,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode24,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode25,1,4) in ('C02L','C07B','C07C','C07D','C08G') or
				substr(atccode1,1,5) in ('C09BA','C09DA') or
				substr(atccode2,1,5) in ('C09BA','C09DA') or
				substr(atccode3,1,5) in ('C09BA','C09DA') or
				substr(atccode4,1,5) in ('C09BA','C09DA') or
				substr(atccode5,1,5) in ('C09BA','C09DA') or
				substr(atccode6,1,5) in ('C09BA','C09DA') or
				substr(atccode7,1,5) in ('C09BA','C09DA') or
				substr(atccode8,1,5) in ('C09BA','C09DA') or
				substr(atccode9,1,5) in ('C09BA','C09DA') or
				substr(atccode10,1,5) in ('C09BA','C09DA') or
				substr(atccode11,1,5) in ('C09BA','C09DA') or
				substr(atccode12,1,5) in ('C09BA','C09DA') or
				substr(atccode13,1,5) in ('C09BA','C09DA') or
				substr(atccode14,1,5) in ('C09BA','C09DA') or
				substr(atccode15,1,5) in ('C09BA','C09DA') or
				substr(atccode16,1,5) in ('C09BA','C09DA') or
				substr(atccode17,1,5) in ('C09BA','C09DA') or
				substr(atccode18,1,5) in ('C09BA','C09DA') or
				substr(atccode19,1,5) in ('C09BA','C09DA') or
				substr(atccode20,1,5) in ('C09BA','C09DA') or
				substr(atccode21,1,5) in ('C09BA','C09DA') or
				substr(atccode22,1,5) in ('C09BA','C09DA') or
				substr(atccode23,1,5) in ('C09BA','C09DA') or
				substr(atccode24,1,5) in ('C09BA','C09DA') or
				substr(atccode25,1,5) in ('C09BA','C09DA') or
				substr(atccode1,1,7) in ('C09DX01','C09DX03') or
				substr(atccode2,1,7) in ('C09DX01','C09DX03') or
				substr(atccode3,1,7) in ('C09DX01','C09DX03') or
				substr(atccode4,1,7) in ('C09DX01','C09DX03') or
				substr(atccode5,1,7) in ('C09DX01','C09DX03') or
				substr(atccode6,1,7) in ('C09DX01','C09DX03') or
				substr(atccode7,1,7) in ('C09DX01','C09DX03') or
				substr(atccode8,1,7) in ('C09DX01','C09DX03') or
				substr(atccode9,1,7) in ('C09DX01','C09DX03') or
				substr(atccode10,1,7) in ('C09DX01','C09DX03') or
				substr(atccode11,1,7) in ('C09DX01','C09DX03') or
				substr(atccode12,1,7) in ('C09DX01','C09DX03') or
				substr(atccode13,1,7) in ('C09DX01','C09DX03') or
				substr(atccode14,1,7) in ('C09DX01','C09DX03') or
				substr(atccode15,1,7) in ('C09DX01','C09DX03') or
				substr(atccode16,1,7) in ('C09DX01','C09DX03') or
				substr(atccode17,1,7) in ('C09DX01','C09DX03') or
				substr(atccode18,1,7) in ('C09DX01','C09DX03') or
				substr(atccode19,1,7) in ('C09DX01','C09DX03') or
				substr(atccode20,1,7) in ('C09DX01','C09DX03') or
				substr(atccode21,1,7) in ('C09DX01','C09DX03') or
				substr(atccode22,1,7) in ('C09DX01','C09DX03') or
				substr(atccode23,1,7) in ('C09DX01','C09DX03') or
				substr(atccode24,1,7) in ('C09DX01','C09DX03') or
				substr(atccode25,1,7) in ('C09DX01','C09DX03');
	run;

	proc sql;
		create table med_diuretics_count as
		select elig_studyid, count(elig_studyid) as diuretics_n, timepoint1, timepoint2, timepoint3
		from med_diuretics
		group by elig_studyid;
	quit;

	proc sort data=med_diuretics nodupkey;
		by elig_studyid;
	run;


*****************************************************************************************;
* DIABETES MEDICATIONS
*****************************************************************************************;
	data med_diabetes;
		set bamed_matched;

		if substr(atccode1,1,3) = 'A10' or
				substr(atccode1,1,3) = 'A10' or
				substr(atccode2,1,3) = 'A10' or
				substr(atccode3,1,3) = 'A10' or
				substr(atccode4,1,3) = 'A10' or
				substr(atccode5,1,3) = 'A10' or
				substr(atccode6,1,3) = 'A10' or
				substr(atccode7,1,3) = 'A10' or
				substr(atccode8,1,3) = 'A10' or
				substr(atccode9,1,3) = 'A10' or
				substr(atccode10,1,3) = 'A10' or
				substr(atccode11,1,3) = 'A10' or
				substr(atccode12,1,3) = 'A10' or
				substr(atccode13,1,3) = 'A10' or
				substr(atccode14,1,3) = 'A10' or
				substr(atccode15,1,3) = 'A10' or
				substr(atccode16,1,3) = 'A10' or
				substr(atccode17,1,3) = 'A10' or
				substr(atccode18,1,3) = 'A10' or
				substr(atccode19,1,3) = 'A10' or
				substr(atccode20,1,3) = 'A10' or
				substr(atccode21,1,3) = 'A10' or
				substr(atccode22,1,3) = 'A10' or
				substr(atccode23,1,3) = 'A10' or
				substr(atccode24,1,3) = 'A10' or
				substr(atccode25,1,3) = 'A10';
	run;

	proc sql;
		create table med_diabetes_count as
		select elig_studyid, count(elig_studyid) as diabetes_n, timepoint1, timepoint2, timepoint3
		from med_diabetes
		group by elig_studyid;
	quit;

	proc sort data=med_diabetes nodupkey;
		by elig_studyid;
	run;

	/*
	PROC EXPORT DATA= med_diabetes
	            OUTFILE= "\\rfa01\BWH-SleepEpi-heartbeat\SAS\Medications\_datasets\med_diabetes_&sasfiledate..csv"
	            DBMS=CSV REPLACE;
	     PUTNAMES=YES;
	RUN;
	*/


*****************************************************************************************;
* LIPID LOWERING MEDICATIONS
*****************************************************************************************;
	data med_lipidlowering;
		set bamed_matched;

		if (substr(atccode1,1,3) = 'C10' or
				substr(atccode2,1,3) = 'C10' or
				substr(atccode3,1,3) = 'C10' or
				substr(atccode4,1,3) = 'C10' or
				substr(atccode5,1,3) = 'C10' or
				substr(atccode6,1,3) = 'C10' or
				substr(atccode7,1,3) = 'C10' or
				substr(atccode8,1,3) = 'C10' or
				substr(atccode9,1,3) = 'C10' or
				substr(atccode10,1,3) = 'C10' or
				substr(atccode11,1,3) = 'C10' or
				substr(atccode12,1,3) = 'C10' or
				substr(atccode13,1,3) = 'C10' or
				substr(atccode14,1,3) = 'C10' or
				substr(atccode15,1,3) = 'C10' or
				substr(atccode16,1,3) = 'C10' or
				substr(atccode17,1,3) = 'C10' or
				substr(atccode18,1,3) = 'C10' or
				substr(atccode19,1,3) = 'C10' or
				substr(atccode20,1,3) = 'C10' or
				substr(atccode21,1,3) = 'C10' or
				substr(atccode22,1,3) = 'C10' or
				substr(atccode23,1,3) = 'C10' or
				substr(atccode24,1,3) = 'C10' or
				substr(atccode25,1,3) = 'C10') and
				mednames ne 'Omega-3 Acid'; /* NO FISH OIL, per Dan/Susan 05/15/2012 */
	run;

	proc sql;
		create table med_lipidlowering_count as
		select elig_studyid, count(elig_studyid) as lipidlowering_n, timepoint1, timepoint2, timepoint3
		from med_lipidlowering
		group by elig_studyid;
quit;

	proc sort data=med_lipidlowering nodupkey;
		by elig_studyid;
	run;

	/*
	PROC EXPORT DATA= med_lipidlowering
	            OUTFILE= "\\rfa01\BWH-SleepEpi-heartbeat\SAS\Medications\_datasets\med_lipidlowering_&sasfiledate..csv"
	            DBMS=CSV REPLACE;
	     PUTNAMES=YES;
	RUN;
	*/


*****************************************************************************************;
* ANTI-HYPERTENSIVE MEDICATIONS
*****************************************************************************************;
	data med_antihypertensive;
		set bamed_matched;

		if substr(atccode1,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode2,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode3,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode4,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode5,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode6,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode7,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode8,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode9,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode10,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode11,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode12,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode13,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode14,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode15,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode16,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode17,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode18,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode19,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode20,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode21,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode22,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode23,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode24,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode25,1,3) in ('C02','C03','C04','C07','C08','C09') or
				substr(atccode1,1,4) = 'C01D' or
				substr(atccode2,1,4) = 'C01D' or
				substr(atccode3,1,4) = 'C01D' or
				substr(atccode4,1,4) = 'C01D' or
				substr(atccode5,1,4) = 'C01D' or
				substr(atccode6,1,4) = 'C01D' or
				substr(atccode7,1,4) = 'C01D' or
				substr(atccode8,1,4) = 'C01D' or
				substr(atccode9,1,4) = 'C01D' or
				substr(atccode10,1,4) = 'C01D' or
				substr(atccode11,1,4) = 'C01D' or
				substr(atccode12,1,4) = 'C01D' or
				substr(atccode13,1,4) = 'C01D' or
				substr(atccode14,1,4) = 'C01D' or
				substr(atccode15,1,4) = 'C01D' or
				substr(atccode16,1,4) = 'C01D' or
				substr(atccode17,1,4) = 'C01D' or
				substr(atccode18,1,4) = 'C01D' or
				substr(atccode19,1,4) = 'C01D' or
				substr(atccode20,1,4) = 'C01D' or
				substr(atccode21,1,4) = 'C01D' or
				substr(atccode22,1,4) = 'C01D' or
				substr(atccode23,1,4) = 'C01D' or
				substr(atccode24,1,4) = 'C01D' or
				substr(atccode25,1,4) = 'C01D' or
				substr(atccode1,1,7) = 'C05AE02' or
				substr(atccode2,1,7) = 'C05AE02' or
				substr(atccode3,1,7) = 'C05AE02' or
				substr(atccode4,1,7) = 'C05AE02' or
				substr(atccode5,1,7) = 'C05AE02' or
				substr(atccode6,1,7) = 'C05AE02' or
				substr(atccode7,1,7) = 'C05AE02' or
				substr(atccode8,1,7) = 'C05AE02' or
				substr(atccode9,1,7) = 'C05AE02' or
				substr(atccode10,1,7) = 'C05AE02' or
				substr(atccode11,1,7) = 'C05AE02' or
				substr(atccode12,1,7) = 'C05AE02' or
				substr(atccode13,1,7) = 'C05AE02' or
				substr(atccode14,1,7) = 'C05AE02' or
				substr(atccode15,1,7) = 'C05AE02' or
				substr(atccode16,1,7) = 'C05AE02' or
				substr(atccode17,1,7) = 'C05AE02' or
				substr(atccode18,1,7) = 'C05AE02' or
				substr(atccode19,1,7) = 'C05AE02' or
				substr(atccode20,1,7) = 'C05AE02' or
				substr(atccode21,1,7) = 'C05AE02' or
				substr(atccode22,1,7) = 'C05AE02' or
				substr(atccode23,1,7) = 'C05AE02' or
				substr(atccode24,1,7) = 'C05AE02' or
				substr(atccode25,1,7) = 'C05AE02';
	run;

	proc sql;
		create table med_antihypertensive_count as
		select elig_studyid, count(elig_studyid) as antihypertensive_n, timepoint1, timepoint2, timepoint3
		from med_antihypertensive
		group by elig_studyid;
	quit;

	proc sort data=med_antihypertensive nodupkey;
		by elig_studyid;
	run;

	/*
	PROC EXPORT DATA= med_diabetes
	            OUTFILE= "\\rfa01\BWH-SleepEpi-heartbeat\SAS\Medications\_datasets\med_diabetes_&sasfiledate..csv"
	            DBMS=CSV REPLACE;
	     PUTNAMES=YES;
	RUN;
	*/


*****************************************************************************************;
* STATINS
*****************************************************************************************;
	data med_statin;
		set bamed_matched;

		if (substr(atccode1,1,5) = 'C10AA' or
				substr(atccode2,1,5) = 'C10AA' or
				substr(atccode3,1,5) = 'C10AA' or
				substr(atccode4,1,5) = 'C10AA' or
				substr(atccode5,1,5) = 'C10AA' or
				substr(atccode6,1,5) = 'C10AA' or
				substr(atccode7,1,5) = 'C10AA' or
				substr(atccode8,1,5) = 'C10AA' or
				substr(atccode9,1,5) = 'C10AA' or
				substr(atccode10,1,5) = 'C10AA' or
				substr(atccode11,1,5) = 'C10AA' or
				substr(atccode12,1,5) = 'C10AA' or
				substr(atccode13,1,5) = 'C10AA' or
				substr(atccode14,1,5) = 'C10AA' or
				substr(atccode15,1,5) = 'C10AA' or
				substr(atccode16,1,5) = 'C10AA' or
				substr(atccode17,1,5) = 'C10AA' or
				substr(atccode18,1,5) = 'C10AA' or
				substr(atccode19,1,5) = 'C10AA' or
				substr(atccode20,1,5) = 'C10AA' or
				substr(atccode21,1,5) = 'C10AA' or
				substr(atccode22,1,5) = 'C10AA' or
				substr(atccode23,1,5) = 'C10AA' or
				substr(atccode24,1,5) = 'C10AA' or
				substr(atccode25,1,5) = 'C10AA' or
				substr(atccode1,1,4) = 'C10B' or
				substr(atccode2,1,4) = 'C10B' or
				substr(atccode3,1,4) = 'C10B' or
				substr(atccode4,1,4) = 'C10B' or
				substr(atccode5,1,4) = 'C10B' or
				substr(atccode6,1,4) = 'C10B' or
				substr(atccode7,1,4) = 'C10B' or
				substr(atccode8,1,4) = 'C10B' or
				substr(atccode9,1,4) = 'C10B' or
				substr(atccode10,1,4) = 'C10B' or
				substr(atccode11,1,4) = 'C10B' or
				substr(atccode12,1,4) = 'C10B' or
				substr(atccode13,1,4) = 'C10B' or
				substr(atccode14,1,4) = 'C10B' or
				substr(atccode15,1,4) = 'C10B' or
				substr(atccode16,1,4) = 'C10B' or
				substr(atccode17,1,4) = 'C10B' or
				substr(atccode18,1,4) = 'C10B' or
				substr(atccode19,1,4) = 'C10B' or
				substr(atccode20,1,4) = 'C10B' or
				substr(atccode21,1,4) = 'C10B' or
				substr(atccode22,1,4) = 'C10B' or
				substr(atccode23,1,4) = 'C10B' or
				substr(atccode24,1,4) = 'C10B' or
				substr(atccode25,1,4) = 'C10B');
	run;

	proc sql;
		create table med_statin_count as
		select elig_studyid, count(elig_studyid) as statin_n, timepoint1, timepoint2, timepoint3
		from med_statin
		group by elig_studyid;
	quit;

	proc sort data=med_statin nodupkey;
		by elig_studyid;
	run;


	/*
	PROC EXPORT DATA= med_statin
	            OUTFILE= "\\rfa01\BWH-SleepEpi-heartbeat\SAS\Medications\_datasets\med_statin_&sasfiledate..csv"
	            DBMS=CSV REPLACE;
	     PUTNAMES=YES;
	RUN;
	*/


*****************************************************************************************;
* NITRATES -- added for Walia/Mehra 11/20/2012
*****************************************************************************************;
	data med_nitrate;
		set bamed_matched;

		if (substr(atccode1,1,5) = 'C01DA' or
				substr(atccode2,1,5) = 'C01DA' or
				substr(atccode3,1,5) = 'C01DA' or
				substr(atccode4,1,5) = 'C01DA' or
				substr(atccode5,1,5) = 'C01DA' or
				substr(atccode6,1,5) = 'C01DA' or
				substr(atccode7,1,5) = 'C01DA' or
				substr(atccode8,1,5) = 'C01DA' or
				substr(atccode9,1,5) = 'C01DA' or
				substr(atccode10,1,5) = 'C01DA' or
				substr(atccode11,1,5) = 'C01DA' or
				substr(atccode12,1,5) = 'C01DA' or
				substr(atccode13,1,5) = 'C01DA' or
				substr(atccode14,1,5) = 'C01DA' or
				substr(atccode15,1,5) = 'C01DA' or
				substr(atccode16,1,5) = 'C01DA' or
				substr(atccode17,1,5) = 'C01DA' or
				substr(atccode18,1,5) = 'C01DA' or
				substr(atccode19,1,5) = 'C01DA' or
				substr(atccode20,1,5) = 'C01DA' or
				substr(atccode21,1,5) = 'C01DA' or
				substr(atccode22,1,5) = 'C01DA' or
				substr(atccode23,1,5) = 'C01DA' or
				substr(atccode24,1,5) = 'C01DA' or
				substr(atccode25,1,5) = 'C01DA' or
				substr(atccode1,1,7) in ('A02BX12','C05AE02') or
				substr(atccode2,1,7) in ('A02BX12','C05AE02') or
				substr(atccode3,1,7) in ('A02BX12','C05AE02') or
				substr(atccode4,1,7) in ('A02BX12','C05AE02') or
				substr(atccode5,1,7) in ('A02BX12','C05AE02') or
				substr(atccode6,1,7) in ('A02BX12','C05AE02') or
				substr(atccode7,1,7) in ('A02BX12','C05AE02') or
				substr(atccode8,1,7) in ('A02BX12','C05AE02') or
				substr(atccode9,1,7) in ('A02BX12','C05AE02') or
				substr(atccode10,1,7) in ('A02BX12','C05AE02') or
				substr(atccode11,1,7) in ('A02BX12','C05AE02') or
				substr(atccode12,1,7) in ('A02BX12','C05AE02') or
				substr(atccode13,1,7) in ('A02BX12','C05AE02') or
				substr(atccode14,1,7) in ('A02BX12','C05AE02') or
				substr(atccode15,1,7) in ('A02BX12','C05AE02') or
				substr(atccode16,1,7) in ('A02BX12','C05AE02') or
				substr(atccode17,1,7) in ('A02BX12','C05AE02') or
				substr(atccode18,1,7) in ('A02BX12','C05AE02') or
				substr(atccode19,1,7) in ('A02BX12','C05AE02') or
				substr(atccode20,1,7) in ('A02BX12','C05AE02') or
				substr(atccode21,1,7) in ('A02BX12','C05AE02') or
				substr(atccode22,1,7) in ('A02BX12','C05AE02') or
				substr(atccode23,1,7) in ('A02BX12','C05AE02') or
				substr(atccode24,1,7) in ('A02BX12','C05AE02') or
				substr(atccode25,1,7) in ('A02BX12','C05AE02'));
	run;

	proc sql;
		create table med_nitrate_count as
		select elig_studyid, count(elig_studyid) as nitrate_n, timepoint1, timepoint2, timepoint3
		from med_nitrate
		group by elig_studyid;
	quit;

	proc sort data=med_nitrate nodupkey;
		by elig_studyid;
	run;


*****************************************************************************************;
* PERIPHERAL VASODILATORS -- added for Walia/Mehra 12/06/2012
*****************************************************************************************;
	data med_perdilator;
		set bamed_matched;

		if 	substr(atccode1,1,3) = 'C04' or
				substr(atccode2,1,3) = 'C04' or
				substr(atccode3,1,3) = 'C04' or
				substr(atccode4,1,3) = 'C04' or
				substr(atccode5,1,3) = 'C04' or
				substr(atccode6,1,3) = 'C04' or
				substr(atccode7,1,3) = 'C04' or
				substr(atccode8,1,3) = 'C04' or
				substr(atccode9,1,3) = 'C04' or
				substr(atccode10,1,3) = 'C04' or
				substr(atccode11,1,3) = 'C04' or
				substr(atccode12,1,3) = 'C04' or
				substr(atccode13,1,3) = 'C04' or
				substr(atccode14,1,3) = 'C04' or
				substr(atccode15,1,3) = 'C04' or
				substr(atccode16,1,3) = 'C04' or
				substr(atccode17,1,3) = 'C04' or
				substr(atccode18,1,3) = 'C04' or
				substr(atccode19,1,3) = 'C04' or
				substr(atccode20,1,3) = 'C04' or
				substr(atccode21,1,3) = 'C04' or
				substr(atccode22,1,3) = 'C04' or
				substr(atccode23,1,3) = 'C04' or
				substr(atccode24,1,3) = 'C04' or
				substr(atccode25,1,3) = 'C04';
	run;

	proc sql;
		create table med_perdilator_count as
		select elig_studyid, count(elig_studyid) as perdilator_n, timepoint1, timepoint2, timepoint3
		from med_perdilator
		group by elig_studyid;
	quit;

	proc sort data=med_perdilator nodupkey;
		by elig_studyid;
	run;



*****************************************************************************************;
* OTHER ANTIHYPERTENSIVES -- added for Walia/Mehra 12/06/2012
*****************************************************************************************;
	data med_otherah;
		set bamed_matched;

		if (substr(atccode1,1,4) = 'C02A' or
				substr(atccode2,1,4) = 'C02A' or
				substr(atccode3,1,4) = 'C02A' or
				substr(atccode4,1,4) = 'C02A' or
				substr(atccode5,1,4) = 'C02A' or
				substr(atccode6,1,4) = 'C02A' or
				substr(atccode7,1,4) = 'C02A' or
				substr(atccode8,1,4) = 'C02A' or
				substr(atccode9,1,4) = 'C02A' or
				substr(atccode10,1,4) = 'C02A' or
				substr(atccode11,1,4) = 'C02A' or
				substr(atccode12,1,4) = 'C02A' or
				substr(atccode13,1,4) = 'C02A' or
				substr(atccode14,1,4) = 'C02A' or
				substr(atccode15,1,4) = 'C02A' or
				substr(atccode16,1,4) = 'C02A' or
				substr(atccode17,1,4) = 'C02A' or
				substr(atccode18,1,4) = 'C02A' or
				substr(atccode19,1,4) = 'C02A' or
				substr(atccode20,1,4) = 'C02A' or
				substr(atccode21,1,4) = 'C02A' or
				substr(atccode22,1,4) = 'C02A' or
				substr(atccode23,1,4) = 'C02A' or
				substr(atccode24,1,4) = 'C02A' or
				substr(atccode25,1,4) = 'C02A' or
				substr(atccode1,1,4) = 'C02B' or
				substr(atccode2,1,4) = 'C02B' or
				substr(atccode3,1,4) = 'C02B' or
				substr(atccode4,1,4) = 'C02B' or
				substr(atccode5,1,4) = 'C02B' or
				substr(atccode6,1,4) = 'C02B' or
				substr(atccode7,1,4) = 'C02B' or
				substr(atccode8,1,4) = 'C02B' or
				substr(atccode9,1,4) = 'C02B' or
				substr(atccode10,1,4) = 'C02B' or
				substr(atccode11,1,4) = 'C02B' or
				substr(atccode12,1,4) = 'C02B' or
				substr(atccode13,1,4) = 'C02B' or
				substr(atccode14,1,4) = 'C02B' or
				substr(atccode15,1,4) = 'C02B' or
				substr(atccode16,1,4) = 'C02B' or
				substr(atccode17,1,4) = 'C02B' or
				substr(atccode18,1,4) = 'C02B' or
				substr(atccode19,1,4) = 'C02B' or
				substr(atccode20,1,4) = 'C02B' or
				substr(atccode21,1,4) = 'C02B' or
				substr(atccode22,1,4) = 'C02B' or
				substr(atccode23,1,4) = 'C02B' or
				substr(atccode24,1,4) = 'C02B' or
				substr(atccode25,1,4) = 'C02B' or
				substr(atccode1,1,5) = 'C02CC' or
				substr(atccode2,1,5) = 'C02CC' or
				substr(atccode3,1,5) = 'C02CC' or
				substr(atccode4,1,5) = 'C02CC' or
				substr(atccode5,1,5) = 'C02CC' or
				substr(atccode6,1,5) = 'C02CC' or
				substr(atccode7,1,5) = 'C02CC' or
				substr(atccode8,1,5) = 'C02CC' or
				substr(atccode9,1,5) = 'C02CC' or
				substr(atccode10,1,5) = 'C02CC' or
				substr(atccode11,1,5) = 'C02CC' or
				substr(atccode12,1,5) = 'C02CC' or
				substr(atccode13,1,5) = 'C02CC' or
				substr(atccode14,1,5) = 'C02CC' or
				substr(atccode15,1,5) = 'C02CC' or
				substr(atccode16,1,5) = 'C02CC' or
				substr(atccode17,1,5) = 'C02CC' or
				substr(atccode18,1,5) = 'C02CC' or
				substr(atccode19,1,5) = 'C02CC' or
				substr(atccode20,1,5) = 'C02CC' or
				substr(atccode21,1,5) = 'C02CC' or
				substr(atccode22,1,5) = 'C02CC' or
				substr(atccode23,1,5) = 'C02CC' or
				substr(atccode24,1,5) = 'C02CC' or
				substr(atccode25,1,5) = 'C02CC' or
				substr(atccode1,1,4) = 'C02D' or
				substr(atccode2,1,4) = 'C02D' or
				substr(atccode3,1,4) = 'C02D' or
				substr(atccode4,1,4) = 'C02D' or
				substr(atccode5,1,4) = 'C02D' or
				substr(atccode6,1,4) = 'C02D' or
				substr(atccode7,1,4) = 'C02D' or
				substr(atccode8,1,4) = 'C02D' or
				substr(atccode9,1,4) = 'C02D' or
				substr(atccode10,1,4) = 'C02D' or
				substr(atccode11,1,4) = 'C02D' or
				substr(atccode12,1,4) = 'C02D' or
				substr(atccode13,1,4) = 'C02D' or
				substr(atccode14,1,4) = 'C02D' or
				substr(atccode15,1,4) = 'C02D' or
				substr(atccode16,1,4) = 'C02D' or
				substr(atccode17,1,4) = 'C02D' or
				substr(atccode18,1,4) = 'C02D' or
				substr(atccode19,1,4) = 'C02D' or
				substr(atccode20,1,4) = 'C02D' or
				substr(atccode21,1,4) = 'C02D' or
				substr(atccode22,1,4) = 'C02D' or
				substr(atccode23,1,4) = 'C02D' or
				substr(atccode24,1,4) = 'C02D' or
				substr(atccode25,1,4) = 'C02D' or
				substr(atccode1,1,4) = 'C02K' or
				substr(atccode2,1,4) = 'C02K' or
				substr(atccode3,1,4) = 'C02K' or
				substr(atccode4,1,4) = 'C02K' or
				substr(atccode5,1,4) = 'C02K' or
				substr(atccode6,1,4) = 'C02K' or
				substr(atccode7,1,4) = 'C02K' or
				substr(atccode8,1,4) = 'C02K' or
				substr(atccode9,1,4) = 'C02K' or
				substr(atccode10,1,4) = 'C02K' or
				substr(atccode11,1,4) = 'C02K' or
				substr(atccode12,1,4) = 'C02K' or
				substr(atccode13,1,4) = 'C02K' or
				substr(atccode14,1,4) = 'C02K' or
				substr(atccode15,1,4) = 'C02K' or
				substr(atccode16,1,4) = 'C02K' or
				substr(atccode17,1,4) = 'C02K' or
				substr(atccode18,1,4) = 'C02K' or
				substr(atccode19,1,4) = 'C02K' or
				substr(atccode20,1,4) = 'C02K' or
				substr(atccode21,1,4) = 'C02K' or
				substr(atccode22,1,4) = 'C02K' or
				substr(atccode23,1,4) = 'C02K' or
				substr(atccode24,1,4) = 'C02K' or
				substr(atccode25,1,4) = 'C02K' or
				substr(atccode1,1,4) = 'C02L' or
				substr(atccode2,1,4) = 'C02L' or
				substr(atccode3,1,4) = 'C02L' or
				substr(atccode4,1,4) = 'C02L' or
				substr(atccode5,1,4) = 'C02L' or
				substr(atccode6,1,4) = 'C02L' or
				substr(atccode7,1,4) = 'C02L' or
				substr(atccode8,1,4) = 'C02L' or
				substr(atccode9,1,4) = 'C02L' or
				substr(atccode10,1,4) = 'C02L' or
				substr(atccode11,1,4) = 'C02L' or
				substr(atccode12,1,4) = 'C02L' or
				substr(atccode13,1,4) = 'C02L' or
				substr(atccode14,1,4) = 'C02L' or
				substr(atccode15,1,4) = 'C02L' or
				substr(atccode16,1,4) = 'C02L' or
				substr(atccode17,1,4) = 'C02L' or
				substr(atccode18,1,4) = 'C02L' or
				substr(atccode19,1,4) = 'C02L' or
				substr(atccode20,1,4) = 'C02L' or
				substr(atccode21,1,4) = 'C02L' or
				substr(atccode22,1,4) = 'C02L' or
				substr(atccode23,1,4) = 'C02L' or
				substr(atccode24,1,4) = 'C02L' or
				substr(atccode25,1,4) = 'C02L')
;
	run;

	proc sql;
		create table med_otherah_count as
		select elig_studyid, count(elig_studyid) as otherah_n, timepoint1, timepoint2, timepoint3
		from med_otherah
		group by elig_studyid;
	quit;

	proc sort data=med_otherah nodupkey;
		by elig_studyid;
	run;

	data bestair.bamedication_match bestair2.bamedication_match_&sasfiledate;
		set bamed_matched;
	run;

************************************;
*
* Debug next section to determine
* why some elig_studyids don't merge
* perfectly into medicationscat
*
************************************;


	*merge all medications by studyid;
	*include count of medication classifications by studyid and visit;
	data medicationscat;
		merge med_aceinhibitor (in=bacei where=(timepoint1=1))
						med_aceinhibitor (in=sacei where=(timepoint2=1))
						med_aceinhibitor (in=facei where=(timepoint3=1))
						med_betablocker (in=bbeta where=(timepoint1=1))
						med_betablocker (in=sbeta where=(timepoint2=1))
						med_betablocker (in=fbeta where=(timepoint3=1))
						med_aldosteroneblocker (in=baldosterone where=(timepoint1=1))
						med_aldosteroneblocker (in=saldosterone where=(timepoint2=1))
						med_aldosteroneblocker (in=faldosterone where=(timepoint3=1))
						med_alphablocker (in=balpha where=(timepoint1=1))
						med_alphablocker (in=salpha where=(timepoint2=1))
						med_alphablocker (in=falpha where=(timepoint3=1))
						med_calciumblocker (in=bcalcium where=(timepoint1=1))
						med_calciumblocker (in=scalcium where=(timepoint2=1))
						med_calciumblocker (in=fcalcium where=(timepoint3=1))
						med_diabetes (in=bdiab where=(timepoint1=1))
						med_diabetes (in=sdiab where=(timepoint2=1))
						med_diabetes (in=fdiab where=(timepoint3=1))
						med_diuretics (in=bdiur where=(timepoint1=1))
						med_diuretics (in=sdiur where=(timepoint2=1))
						med_diuretics (in=fdiur where=(timepoint3=1))
						med_lipidlowering (in=blipid where=(timepoint1=1))
						med_lipidlowering (in=slipid where=(timepoint2=1))
						med_lipidlowering (in=flipid where=(timepoint3=1))
						med_antihypertensive (in=bhyper where=(timepoint1=1))
						med_antihypertensive (in=shyper where=(timepoint2=1))
						med_antihypertensive (in=fhyper where=(timepoint3=1))
						med_statin (in=bstat where=(timepoint1=1))
						med_statin (in=sstat where=(timepoint2=1))
						med_statin (in=fstat where=(timepoint3=1))
						med_nitrate (in=bnitr where=(timepoint1=1))
						med_nitrate (in=snitr where=(timepoint2=1))
						med_nitrate (in=fnitr where=(timepoint3=1))
						med_perdilator (in=bpdil where=(timepoint1=1))
						med_perdilator (in=spdil where=(timepoint2=1))
						med_perdilator (in=fpdil where=(timepoint3=1))
						med_otherah (in=boah where=(timepoint1=1))
						med_otherah (in=soah where=(timepoint2=1))
						med_otherah (in=foah where=(timepoint3=1))
						/* counts below */
						med_aceinhibitor_count (in=bacein where=(timepoint1=1) rename=(aceinhibitor_n=baseaceinhibitor_n))
						med_aceinhibitor_count (in=sacein where=(timepoint2=1) rename=(aceinhibitor_n=sixaceinhibitor_n))
						med_aceinhibitor_count (in=facein where=(timepoint3=1) rename=(aceinhibitor_n=finaceinhibitor_n))
						med_betablocker_count (in=bbetan where=(timepoint1=1) rename=(betablocker_n=basebetablocker_n))
						med_betablocker_count (in=sbetan where=(timepoint2=1) rename=(betablocker_n=sixbetablocker_n))
						med_betablocker_count (in=fbetan where=(timepoint3=1) rename=(betablocker_n=finbetablocker_n))
						med_aldosteroneblocker_count (in=baldosteronen where=(timepoint1=1) rename=(aldosteroneblocker_n=basealdosteroneblocker_n))
						med_aldosteroneblocker_count (in=saldosteronen where=(timepoint2=1) rename=(aldosteroneblocker_n=sixaldosteroneblocker_n))
						med_aldosteroneblocker_count (in=faldosteronen where=(timepoint3=1) rename=(aldosteroneblocker_n=finaldosteroneblocker_n))
						med_alphablocker_count (in=balphan where=(timepoint1=1) rename=(alphablocker_n=basealphablocker_n))
						med_alphablocker_count (in=salphan where=(timepoint2=1) rename=(alphablocker_n=sixalphablocker_n))
						med_alphablocker_count (in=falphan where=(timepoint3=1) rename=(alphablocker_n=finalphablocker_n))
						med_calciumblocker_count (in=bcalciumn where=(timepoint1=1) rename=(calciumblocker_n=basecalciumblocker_n))
						med_calciumblocker_count (in=scalciumn where=(timepoint2=1) rename=(calciumblocker_n=sixcalciumblocker_n))
						med_calciumblocker_count (in=fcalciumn where=(timepoint3=1) rename=(calciumblocker_n=fincalciumblocker_n))
						med_diabetes_count (in=bdiabn where=(timepoint1=1) rename=(diabetes_n=basediabetes_n))
						med_diabetes_count (in=sdiabn where=(timepoint2=1) rename=(diabetes_n=sixdiabetes_n))
						med_diabetes_count (in=fdiabn where=(timepoint3=1) rename=(diabetes_n=findiabetes_n))
						med_diuretics_count (in=bdiurn where=(timepoint1=1) rename=(diuretics_n=basediuretics_n))
						med_diuretics_count (in=sdiurn where=(timepoint2=1) rename=(diuretics_n=sixdiuretics_n))
						med_diuretics_count (in=fdiurn where=(timepoint3=1) rename=(diuretics_n=findiuretics_n))
						med_lipidlowering_count (in=blipidn where=(timepoint1=1) rename=(lipidlowering_n=baselipidlowering_n))
						med_lipidlowering_count (in=slipidn where=(timepoint2=1) rename=(lipidlowering_n=sixlipidlowering_n))
						med_lipidlowering_count (in=flipidn where=(timepoint3=1) rename=(lipidlowering_n=finlipidlowering_n))
						med_antihypertensive_count (in=bhypern where=(timepoint1=1) rename=(antihypertensive_n=baseantihypertensive_n))
						med_antihypertensive_count (in=shypern where=(timepoint2=1) rename=(antihypertensive_n=sixantihypertensive_n))
						med_antihypertensive_count (in=fhypern where=(timepoint3=1) rename=(antihypertensive_n=finantihypertensive_n))
						med_statin_count (in=bstatn where=(timepoint1=1) rename=(statin_n=basestatin_n))
						med_statin_count (in=sstatn where=(timepoint2=1) rename=(statin_n=sixstatin_n))
						med_statin_count (in=fstatn where=(timepoint3=1) rename=(statin_n=finstatin_n))
						med_nitrate_count (in=bnitrn where=(timepoint1=1) rename=(nitrate_n=basenitrate_n))
						med_nitrate_count (in=snitrn where=(timepoint2=1) rename=(nitrate_n=sixnitrate_n))
						med_nitrate_count (in=fnitrn where=(timepoint3=1) rename=(nitrate_n=finnitrate_n))
						med_perdilator_count (in=bpdiln where=(timepoint1=1) rename=(perdilator_n=baseperdilator_n))
						med_perdilator_count (in=spdiln where=(timepoint2=1) rename=(perdilator_n=sixperdilator_n))
						med_perdilator_count (in=fpdiln where=(timepoint3=1) rename=(perdilator_n=finperdilator_n))
						med_otherah_count (in=boahn where=(timepoint1=1) rename=(otherah_n=baseotherah_n))
						med_otherah_count (in=soahn where=(timepoint2=1) rename=(otherah_n=sixotherah_n))
						med_otherah_count (in=foahn where=(timepoint3=1) rename=(otherah_n=finotherah_n));
			by elig_studyid;

			/* dichotomous */

			if bacei then baceinhibitor = 1; else baceinhibitor = 0;
			if sacei then saceinhibitor = 1; else saceinhibitor = 0;
			if facei then faceinhibitor = 1; else faceinhibitor = 0;

			if bbeta then bbetablocker = 1; else bbetablocker = 0;
			if sbeta then sbetablocker = 1; else sbetablocker = 0;
			if fbeta then fbetablocker = 1; else fbetablocker = 0;

			if baldosterone then baldosteroneblocker = 1; else baldosteroneblocker = 0;
			if saldosterone then saldosteroneblocker = 1; else saldosteroneblocker = 0;
			if faldosterone then faldosteroneblocker = 1; else faldosteroneblocker = 0;

			if balpha then balphablocker = 1; else balphablocker = 0;
			if salpha then salphablocker = 1; else salphablocker = 0;
			if falpha then falphablocker = 1; else falphablocker = 0;

			if bcalcium then bcalciumblocker = 1; else bcalciumblocker = 0;
			if scalcium then scalciumblocker = 1; else scalciumblocker = 0;
			if fcalcium then fcalciumblocker = 1; else fcalciumblocker = 0;

			if bdiab then bdiabetes = 1; else bdiabetes = 0;
			if sdiab then sdiabetes = 1; else sdiabetes = 0;
			if fdiab then fdiabetes = 1; else fdiabetes = 0;

			if bdiur then bdiuretic = 1; else bdiuretic = 0;
			if sdiur then sdiuretic = 1; else saceinhibitor = 0;
			if fdiur then fdiuretic = 1; else fdiuretic = 0;

			if blipid then blipidlowering = 1; else blipidlowering = 0;
			if slipid then slipidlowering = 1; else slipidlowering = 0;
			if flipid then flipidlowering = 1; else flipidlowering = 0;

			if bhyper then bantihypertensive = 1; else bantihypertensive = 0;
			if shyper then santihypertensive = 1; else santihypertensive = 0;
			if fhyper then fantihypertensive = 1; else fantihypertensive = 0;

			if bstat then bstatin = 1; else bstatin = 0;
			if sstat then sstatin = 1; else sstatin = 0;
			if fstat then fstatin = 1; else fstatin = 0;

			if bnitr then bnitrate = 1; else bnitrate = 0;
			if snitr then snitrate = 1; else snitrate = 0;
			if fnitr then fnitrate = 1; else fnitrate = 0;

			if bpdil then bperdilator = 1; else bperdilator = 0;
			if spdil then sperdilator = 1; else sperdilator = 0;
			if fpdil then fperdilator = 1; else fperdilator = 0;

			if boah then botherah = 1; else botherah = 0;
			if soah then sotherah = 1; else sotherah = 0;
			if foah then fotherah = 1; else fotherah = 0;

			/* counts */

			if bacein then baceinhibitor_n = baseaceinhibitor_n; else baceinhibitor_n = 0;
			if sacein then saceinhibitor_n = sixaceinhibitor_n; else saceinhibitor_n = 0;
			if facein then faceinhibitor_n = finaceinhibitor_n; else faceinhibitor_n = 0;

			if bbetan then bbetablocker_n = basebetablocker_n; else bbetablocker_n = 0;
			if sbetan then sbetablocker_n = sixbetablocker_n; else sbetablocker_n = 0;
			if fbetan then fbetablocker_n = finbetablocker_n; else fbetablocker_n = 0;

			if baldosteronen then baldosteroneblocker_n = basealdosteroneblocker_n; else baldosteroneblocker_n = 0;
			if saldosteronen then saldosteroneblocker_n = sixaldosteroneblocker_n; else saldosteroneblocker_n = 0;
			if faldosteronen then faldosteroneblocker_n = finaldosteroneblocker_n; else faldosteroneblocker_n = 0;

			if balphan then balphablocker_n = basealphablocker_n; else balphablocker_n = 0;
			if salphan then salphablocker_n = sixalphablocker_n; else salphablocker_n = 0;
			if falphan then falphablocker_n = finalphablocker_n; else falphablocker_n = 0;

			if bcalciumn then bcalciumblocker_n = basecalciumblocker_n; else bcalciumblocker_n = 0;
			if scalciumn then scalciumblocker_n = sixcalciumblocker_n; else scalciumblocker_n = 0;
			if fcalciumn then fcalciumblocker_n = fincalciumblocker_n; else fcalciumblocker_n = 0;

			if bdiabn then bdiabetes_n = basediabetes_n; else bdiabetes_n = 0;
			if sdiabn then sdiabetes_n = sixdiabetes_n; else sdiabetes_n = 0;
			if fdiabn then fdiabetes_n = findiabetes_n; else fdiabetes_n = 0;

			if bdiurn then bdiuretic_n = basediuretics_n; else bdiuretic_n = 0;
			if sdiurn then sdiuretic_n = sixdiuretics_n; else sdiuretic_n = 0;
			if fdiurn then fdiuretic_n = findiuretics_n; else fdiuretic_n = 0;

			if blipidn then blipidlowering_n = baselipidlowering_n; else blipidlowering_n = 0;
			if slipidn then slipidlowering_n = sixlipidlowering_n; else slipidlowering_n = 0;
			if flipidn then flipidlowering_n = finlipidlowering_n; else flipidlowering_n = 0;

			if bhypern then bantihypertensive_n = baseantihypertensive_n; else bantihypertensive_n = 0;
			if shypern then santihypertensive_n = sixantihypertensive_n; else santihypertensive_n = 0;
			if fhypern then fantihypertensive_n = finantihypertensive_n; else fantihypertensive_n = 0;

			if bstatn then bstatin_n = basestatin_n; else bstatin_n = 0;
			if sstatn then sstatin_n = sixstatin_n; else sstatin_n = 0;
			if fstatn then fstatin_n = finstatin_n; else fstatin_n = 0;

			if bnitrn then bnitrate_n = basenitrate_n; else bnitrate_n = 0;
			if snitrn then snitrate_n = sixnitrate_n; else snitrate_n = 0;
			if fnitrn then fnitrate_n = finnitrate_n; else fnitrate_n = 0;

			if bpdiln then bperdilator_n = baseperdilator_n; else bperdilator_n = 0;
			if spdiln then sperdilator_n = sixperdilator_n; else sperdilator_n = 0;
			if fpdiln then fperdilator_n = finperdilator_n; else fperdilator_n = 0;

			if boahn then botherah_n = baseotherah_n; else botherah_n = 0;
			if soahn then sotherah_n = sixotherah_n; else sotherah_n = 0;
			if foahn then fotherah_n = finotherah_n; else fotherah_n = 0;

			/* only keep the good stuff */

			keep elig_studyid baceinhibitor saceinhibitor faceinhibitor bbetablocker sbetablocker fbetablocker baldosteroneblocker saldosteroneblocker faldosteroneblocker
						balphablocker salphablocker falphablocker
						bcalciumblocker scalciumblocker fcalciumblocker bdiabetes sdiabetes fdiabetes bdiuretic sdiuretic fdiuretic
						blipidlowering slipidlowering flipidlowering bantihypertensive santihypertensive fantihypertensive bstatin sstatin fstatin bnitrate snitrate fnitrate
						bperdilator sperdilator fperdilator botherah sotherah fotherah
						baceinhibitor_n saceinhibitor_n faceinhibitor_n bbetablocker_n sbetablocker_n fbetablocker_n baldosteroneblocker_n saldosteroneblocker_n faldosteroneblocker_n
						balphablocker_n salphablocker_n falphablocker_n
						bcalciumblocker_n scalciumblocker_n fcalciumblocker_n bdiabetes_n sdiabetes_n fdiabetes_n bdiuretic_n sdiuretic_n fdiuretic_n
						blipidlowering_n slipidlowering_n flipidlowering_n bantihypertensive_n santihypertensive_n fantihypertensive_n bstatin_n sstatin_n fstatin_n
						bnitrate_n snitrate_n fnitrate
						bperdilator_n sperdilator_n fperdilator_n botherah_n sotherah_n fotherah_n;
		run;

	*create frequency tables where 1 = "Yes", 0 = "No" regarding the number of participants taking a class of medication at each timepoint (Boolean frequency);
	proc freq data=medicationscat;
		table bbetablocker sbetablocker fbetablocker;
		table baceinhibitor saceinhibitor faceinhibitor;
		table baldosteroneblocker saldosteroneblocker faldosteroneblocker;
		table balphablocker salphablocker falphablocker;
		table bcalciumblocker scalciumblocker fcalciumblocker;
		table bdiabetes sdiabetes fdiabetes;
		table bdiuretic sdiuretic fdiuretic;
		table blipidlowering slipidlowering flipidlowering;
		table bantihypertensive santihypertensive fantihypertensive;
		table bstatin sstatin fstatin;
		table bnitrate snitrate fnitrate;
		table bperdilator sperdilator fperdilator;
		table botherah sotherah fotherah;
	run;

	*print instances where a particular individual is not prescribed one of main classification of medications for cardiovascular disease (CVD);
	*purpose of list is to quality check medication data given the unlikelihood of no CVD medications given patient demographics of study;
	data nomedclass_baseorfinal;
		set medicationscat;

		if (
		bbetablocker = 0 and fbetablocker = 0 and
		baceinhibitor = 0 and faceinhibitor = 0 and
		balphablocker = 0 and falphablocker = 0 and
		bcalciumblocker = 0 and fcalciumblocker = 0 and
		bdiabetes = 0 and fdiabetes = 0 and
		bdiuretic = 0 and fdiuretic = 0 and
		blipidlowering = 0 and flipidlowering = 0 and
		bantihypertensive = 0 and fantihypertensive = 0 and
		bstatin = 0 and fstatin = 0
		);


	run;

	proc sort data = nomedclass_baseorfinal nodupkey;
		by elig_studyid;
	run;

	proc sql;
		select elig_studyid
		from nomedclass_baseorfinal;
	quit;

	data bestair.bamedicationcat bestair2.bamedicationcat;
		set medicationscat;
	run;
