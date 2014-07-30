****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair macros for multiple datasets.sas";

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

***************************************************************************************;
* PROCESS BESTAIR MEDICATION DATA
***************************************************************************************;

  data medications2;
    set medications;

      med_nameother01 = med_name01other;
      med_nameother02 = med_name02other;
      med_nameother03 = med_name03other;
      med_nameother04 = med_name04other;
      med_nameother05 = med_name05other;
      med_nameother06 = med_name06other;
      med_nameother07 = med_name07other;
      med_nameother08 = med_name08other;
      med_nameother09 = med_name09other;
      med_nameother10 = med_name10other;
      med_nameother11 = med_name11other;
      med_nameother12 = med_name12other;
      med_nameother13 = med_name13other;
      med_nameother14 = med_name14other;
      med_nameother15 = med_name15other;
      med_nameother16 = med_name16other;
      med_nameother17 = med_name17other;
      med_nameother18 = med_name18other;
      med_nameother19 = med_name19other;
      med_nameother20 = med_name20other;
      med_nameother21 = med_name21other;
      med_nameother22 = med_name22other;
      med_nameother23 = med_name23other;
      med_nameother24 = med_name24other;
      med_nameother25 = med_name25other;
      med_nameother26 = med_name26other;
      med_nameother27 = med_name27other;
      med_nameother28 = med_name28other;
      med_nameother29 = med_name29other;
      med_nameother30 = med_name30other;
      med_nameother31 = med_name31other;
      med_nameother32 = med_name32other;
      med_nameother33 = med_name33other;
      med_nameother34 = med_name34other;
      med_nameother35 = med_name35other;
      med_nameother36 = med_name36other;
      med_nameother37 = med_name37other;
      med_nameother38 = med_name38other;
      med_nameother39 = med_name39other;
      med_nameother40 = med_name40other;
      med_nameother41 = med_name41other;
      med_nameother42 = med_name42other;
      med_nameother43 = med_name43other;
      med_nameother44 = med_name44other;
      med_nameother45 = med_name45other;
      med_nameother46 = med_name46other;
      med_nameother47 = med_name47other;
      med_nameother48 = med_name48other;
      med_nameother49 = med_name49other;
      med_nameother50 = med_name50other;
      med_nameother51 = med_name51other;
      med_nameother52 = med_name52other;
      med_nameother53 = med_name53other;
      med_nameother54 = med_name54other;
      med_nameother55 = med_name55other;
      med_nameother56 = med_name56other;
      med_nameother57 = med_name57other;
      med_nameother58 = med_name58other;
      med_nameother59 = med_name59other;
      med_nameother60 = med_name60other;
      med_startdate02 = med_startdate_02;
      med_startdate32 = med_startdate_32;
  run;

  proc contents data = medications2 out = medications2_contents noprint;
  run;

  proc sql noprint;
    select NAME into :rename_varlist separated by ' '
    from medications2_contents
    where substr(NAME,1,13) = "med_timetaken";

    select substr(NAME,14,2) into :rename_countlist separated by ' '
    from medications2_contents
    where substr(NAME,1,13) = "med_timetaken";

    select cat('med_timetaken',substr(NAME,16,1)) into :rename_letterlist separated by ' '
    from medications2_contents
    where substr(NAME,1,13) = "med_timetaken";
  quit;

  %let newlist = %parallel_join(words1=&rename_letterlist, words2=&rename_countlist, joinstr=_, delim1=%str( ), delim2=%str( ));

  data medications2;
    set medications2;

    rename %parallel_join(words1=&rename_varlist, words2=&newlist, joinstr=%str(=), delim1=%str( ), delim2=%str( ));
  run;

  data medications2;
    set medications2;
    array timetaken_vars[*] med_timetakena_01-med_timetakena_60 med_timetakenb_01-med_timetakenb_60 med_timetakenc_01-med_timetakenc_60;
    do i = 1 to dim(timetaken_vars);
      if timetaken_vars[i] < 0 then timetaken_vars[i] = .;
    end;
    drop i;
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

  proc transpose data=medications2 out=wide9;
      by elig_Studyid;
    var med_timetakena_01-med_timetakena_60;
  run;

  data wide9;
    set wide9(rename=COL1=med_timetakena);
  run;

  proc transpose data=medications2 out=wide10;
      by elig_Studyid;
    var med_timetakenb_01-med_timetakenb_60;
  run;

  data wide10;
    set wide10(rename=COL1=med_timetakenb);
  run;

  proc transpose data=medications2 out=wide11;
      by elig_Studyid;
    var med_timetakenc_01-med_timetakenc_60;
  run;

  data wide11;
    set wide11(rename=COL1=med_timetakenc);
  run;

  *merge above datasets to put each variable for given medication as same observation;
  data medmerge;
    merge wide1 wide2 wide3 wide4 wide5 wide6 wide7 wide8 wide9 wide10 wide11;
    by elig_studyid;
    drop _NAME_ _LABEL_;
  run;

  *delete empty observations;
  proc sql;
    delete from medmerge where med_name = .;
    delete from medmerge where med_name = 999 and med_nameother = "";
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
    if med_name = 117 then med_name2 = "Sodium Chloride ";
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

  *ods html close;

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
    title "BestAIR Participants Missing 'Start Date' on Medications Sheet"; select elig_studyid, medname from medmerge_reorder where med_startdate = .; title;
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

      if lowcase(medname) = lowcase(mednames) or
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

  *new calculation for visit_dates has been incorporated at beginning of program;

/*
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
    set date(where=(redcap_event_name = "00_bv_arm_1"));

    drop twelvemonth sixmonth;
  run;

  data date_six;
    set date(where=(redcap_event_name = "06_fu_arm_1"));

    drop baseline twelvemonth;
  run;

  data date_12;
    set date(where=(redcap_event_name = "12_fu_arm_1"));

    drop baseline sixmonth;
  run;

  *merge dates of each visit by studyid;
  data dates;
    merge date_base date_six date_12;
    by elig_studyid;
    drop redcap_event_name;
  run;
  */

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


  proc sql;
    title "Medication End Date is Earlier than Medication Start Date";
    select elig_studyid, medname, med_startdate, med_enddate
    from bamed_matched
    where med_enddate < med_startdate and med_enddate ne .;

    title "Medication End Date is Earlier than Baseline Date";
    select elig_studyid, medname, med_startdate, med_enddate, baseline label = "Baseline Date"
    from bamed_matched
    where med_enddate < baseline and med_enddate ne .;

  quit;


  *fix "unmatched" dataset to hold only variables that are truly unmatched;
  data bamed_unmatched;
    merge bamed_unmatched (in=a) bamed_matched (in=b);
    by elig_studyid medname med_strength med_startdate med_dose;

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



  data fixed_medtimes;
    set bamed_matched (where = (baseline le med_enddate or med_enddate = .));
    array medtimes[*] med_timetakena--med_timetakenc;

    do i = 1 to 3;
      if medtimes[i] = 0 then medtimes[i] = 2400;
      if medtimes[i] = 63 then medtimes[i] = 630;
      else if medtimes[i] = 7.5 then medtimes[i] = 730;
      else if medtimes[i] < 25 then medtimes[i] = medtimes[i]*100;
    end;

    do j = 1 to 3;
      if (medtimes[j] < 30 or medtimes[j] > 2400) and medtimes[j] ne . then timeerror = 1;
      else if 0 < medtimes[j] < 500 or medtimes[j] ge 2000 then taken_after8pm = 1;
      else if 500 le medtimes[j] < 1200 then taken_bt5am_Noon = 1;
      else if 1200 le medtimes[j] < 2000 then taken_btNoon_8pm = 1;
    end;

    drop i j;

  run;

  data fixed_medtimes;
    set fixed_medtimes;

    if  substr(atccode1,1,4) in ('C09A','C09B','C09C','C09D') or
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
        substr(atccode25,1,7) = 'C10BX04' then aceinhibitor = 1;
        else aceinhibitor = 0;

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
        substr(atccode25,1,5) = 'C02CA' then alphablocker = 1;
        else alphablocker = 0;

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
        substr(atccode25,1,5) = 'C03DA' then aldosteroneblocker = 1;
        else aldosteroneblocker = 0;

    if substr(atccode1,1,4) = 'N06A' or
        substr(atccode2,1,4) = 'N06A' or
        substr(atccode3,1,4) = 'N06A' or
        substr(atccode4,1,4) = 'N06A' or
        substr(atccode5,1,4) = 'N06A' or
        substr(atccode6,1,4) = 'N06A' or
        substr(atccode7,1,4) = 'N06A' or
        substr(atccode8,1,4) = 'N06A' or
        substr(atccode9,1,4) = 'N06A' or
        substr(atccode10,1,4) = 'N06A' or
        substr(atccode11,1,4) = 'N06A' or
        substr(atccode12,1,4) = 'N06A' or
        substr(atccode13,1,4) = 'N06A' or
        substr(atccode14,1,4) = 'N06A' or
        substr(atccode14,1,4) = 'N06A' or
        substr(atccode16,1,4) = 'N06A' or
        substr(atccode17,1,4) = 'N06A' or
        substr(atccode18,1,4) = 'N06A' or
        substr(atccode19,1,4) = 'N06A' or
        substr(atccode20,1,4) = 'N06A' or
        substr(atccode21,1,4) = 'N06A' or
        substr(atccode22,1,4) = 'N06A' or
        substr(atccode23,1,4) = 'N06A' or
        substr(atccode24,1,4) = 'N06A' or
        substr(atccode24,1,4) = 'N06A' then antidepressant = 1;
        else antidepressant = 0;

    if  substr(atccode1,1,3) = 'C07' or
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
        substr(atccode25,1,3) = 'C07' then betablocker = 1;
        else betablocker = 0;

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
        substr(atccode25,1,7) in ('C09DX03','C10BX03') then calciumblocker = 1;
        else calciumblocker = 0;

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
        substr(atccode25,1,7) in ('C09DX01','C09DX03') then diuretic = 1;
        else diuretic = 0;

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
        substr(atccode25,1,3) = 'A10' then diabetesmed = 1;
        else diabetesmed = 0;

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
        mednames ne 'Omega-3 Acid' then lipidlowering = 1;
        else lipidlowering = 0;

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
        substr(atccode25,1,7) = 'C05AE02' or
        substr(atccode1,1,4) = 'C02A' or
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
        substr(atccode25,1,4) = 'C02L' then antihypertensive = 1;
        else antihypertensive = 0;

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
        substr(atccode25,1,4) = 'C10B') then statin = 1;
        else statin = 0;

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
        substr(atccode25,1,7) in ('A02BX12','C05AE02')) then nitrate = 1;
        else nitrate = 0;

    if  substr(atccode1,1,3) = 'C04' or
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
        substr(atccode25,1,3) = 'C04' then peripheral_dilator = 1;
        else peripheral_dilator = 0;

    run;

*****************************************************************************************;
* ACE INHIBITOR OR ARB
*****************************************************************************************;

  proc sql;
    create table med_aceinhibitor_count as
    select elig_studyid, count(elig_studyid) as aceinhibitor_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having aceinhibitor = 1;
  quit;

*****************************************************************************************;
* ALPHA BLOCKER
*****************************************************************************************;

  proc sql;
    create table med_alphablocker_count as
    select elig_studyid, count(elig_studyid) as alphablocker_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having alphablocker = 1;
  quit;

*****************************************************************************************;
* ALDOSTERONE BLOCKER -- added 11/20/2012 for Walia/Mehra
*****************************************************************************************;

  proc sql;
    create table med_aldosteroneblocker_count as
    select elig_studyid, count(elig_studyid) as aldosteroneblocker_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having aldosteroneblocker = 1;
  quit;

*****************************************************************************************;
* ANTIDEPRESSANT -- added 01/28/2014
*****************************************************************************************;

  proc sql;
    create table med_antidepressant_count as
    select elig_studyid, count(elig_studyid) as antidepressant_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having antidepressant = 1;
  quit;

*****************************************************************************************;
* BETA BLOCKER
*****************************************************************************************;

  proc sql;
    create table med_betablocker_count as
    select elig_studyid, count(elig_studyid) as betablocker_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having betablocker = 1;
  quit;

*****************************************************************************************;
* CALCIUM CHANNEL BLOCKER
*****************************************************************************************;

  proc sql;
    create table med_calciumblocker_count as
    select elig_studyid, count(elig_studyid) as calciumblocker_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having calciumblocker = 1;
  quit;

*****************************************************************************************;
* DIURETICS
*****************************************************************************************;

  proc sql;
    create table med_diuretics_count as
    select elig_studyid, count(elig_studyid) as diuretics_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having diuretic = 1;
  quit;

*****************************************************************************************;
* DIABETES
*****************************************************************************************;
  proc sql;
    create table med_diabetes_count as
    select elig_studyid, count(elig_studyid) as diabetes_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having diabetesmed = 1;
  quit;

*****************************************************************************************;
* LIPID-LOWERING MEDS
*****************************************************************************************;
  proc sql;
    create table med_lipidlowering_count as
    select elig_studyid, count(elig_studyid) as lipidlowering_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having lipidlowering = 1;
  quit;

*****************************************************************************************;
* ANTI-HYPERTENSIVE
*****************************************************************************************;
  proc sql;
    create table med_antihypertensive_count as
    select elig_studyid, count(elig_studyid) as antihypertensive_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having antihypertensive = 1;
  quit;

*****************************************************************************************;
* STATINS
*****************************************************************************************;

  proc sql;
    create table med_statin_count as
    select elig_studyid, count(elig_studyid) as statin_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having statin = 1;
  quit;


*****************************************************************************************;
* NITRATES -- added for Walia/Mehra 11/20/2012
*****************************************************************************************;

  proc sql;
    create table med_nitrate_count as
    select elig_studyid, count(elig_studyid) as nitrate_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having nitrate = 1;
  quit;

*****************************************************************************************;
* PERIPHERAL VASODILATORS -- added for Walia/Mehra 12/06/2012
*****************************************************************************************;

  proc sql;
    create table med_perdilator_count as
    select elig_studyid, count(elig_studyid) as perdilator_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    having peripheral_dilator = 1;
  quit;

*****************************************************************************************;
* OTHER ANTIHYPERTENSIVES -- added for Walia/Mehra 12/06/2012
*****************************************************************************************;
/*
  proc sql;
    create table med_otherah_count as
    select elig_studyid, count(elig_studyid) as otherah_n, timepoint1, timepoint2, timepoint3
    from Fixed_medtimes
    group by elig_studyid
    where  = 1;
  quit;
*/
*compare to old dataset;
/*
  proc compare base=bestair.bamedication_match
      comp=Fixed_medtimes
      method = absolute
      criterion = 0.00500001
      transpose
      maxprint = 32767;

      id elig_studyid medname med_startdate med_strength med_freq;
  run;

  proc sort data = bestair.bamedication_match out = bamedication_match2;
  by elig_studyid medname med_startdate med_strength med_freq;
  run;

  proc sort data = Fixed_medtimes out = Fixed_medtimes2;
  by elig_studyid medname med_startdate med_strength med_freq;
  run;

  proc compare base=bamedication_match2
      comp=Fixed_medtimes2
      method = absolute
      criterion = 0.00500001
      transpose
      maxprint = 32767;

      id DESCENDING elig_studyid medname med_startdate med_strength med_freq;
  run;

data checkthisout;
  merge bamedication_match2 (in = a) Fixed_medtimes2 (in = b keep = elig_studyid medname med_strength med_startdate);
  by elig_studyid medname med_strength med_startdate;
  if a and not b;
run;
  */
*****************************************************************************************;
* SAVE PERMANENT DATASETS FOR MATCHED MEDICATIONS
*****************************************************************************************;

  *restrict to desired variables;
  data bamed_matched_final;
    set fixed_medtimes;

    drop timeerror--peripheral_dilator;
  run;

  data bestair.bamedication_match bestair2.bamedication_match_&sasfiledate;
    set bamed_matched_final;
  run;

  %include "&bestairpath\sas\medications\med frequency testing.sas";



*****************************;
* EXTRA CHECKS
*****************************;
/*  data fixed_medtimes_markclass;*/
/*    set fixed_medtimes;*/
/**/
/*    array class_array[*] aceinhibitor--peripheral_dilator;*/
/**/
/*    do i = 1 to dim(class_array);*/
/*      if class_array[i] = 1 then has_medclass = 1;*/
/*    end;*/
/**/
/*    drop i;*/
/*  run;*/
/**/
/*  data fixed_medtimes_noprn;*/
/*    set fixed_medtimes_markclass;*/
/*    if find(lowcase(med_freq),'prn') = 0 and find(lowcase(med_freq),'as needed') = 0 then output fixed_medtimes_noprn;*/
/*  run;*/
/**/
/**/
/*  proc freq data = fixed_medtimes_noprn;*/
/*    table med_timetakena;*/
/*/*    table med_timetakenb;*/*/
/*/*    table med_timetakenc;*/*/
/*/*    table timeerror;*/*/
/*/*    table taken_after8pm;*/*/
/*/*    table taken_bt5am_Noon;*/*/
/*/*    table taken_btNoon_8pm;*/*/
/*  run;*/
/**/
/*  data fixed_medtimes_noprn_hasclass;*/
/*    set fixed_medtimes_noprn;*/
/*    if has_medclass = 1;*/
/*  run;*/
/**/
/*  proc freq data = fixed_medtimes_noprn_hasclass;*/
/*    table med_timetakena;*/
/*/*    table med_timetakenb;*/*/
/*/*    table med_timetakenc;*/*/
/*/*    table timeerror;*/*/
/*/*    table taken_after8pm;*/*/
/*/*    table taken_bt5am_Noon;*/*/
/*/*    table taken_btNoon_8pm;*/*/
/*  run;*/

  *Stuff for Rui 1/29/14;
/*
  proc sql;
    create table med_antihypertensive2_count as
    select elig_studyid, count(elig_studyid) as antihypertensive_n
    from med_antihypertensive
    where timepoint1 = 1
    group by elig_studyid;

    create table baseline_cov as
    select elig_studyid, elig_incl01age as age, elig_gender as gender, elig_raceamerind as race_americanindian, elig_raceasian as race_asian, elig_racehawaiian as race_hawaiian,
      elig_raceblack as race_black, elig_racewhite as race_white, elig_raceotherspecify as race_other, bmi, elig_incl03osaahi as ahi, sysallmean as systolic_base,
      diaallmean as diastolic_base
    from bestair.badsmbtable4;

    create table treatment as
    select elig_studyid, rand_treatmentarm as treat_code
    from bestair.badsmbtable1;

    create table fu6_bp as
    select studyid as elig_studyid, sysallmean as systolic_6mo, diaallmean as diastolic_6mo
    from bestair.bestairbp24hr
    where timepoint = 6;

    create table fu12_bp as
    select studyid as elig_studyid, sysallmean as systolic_12mo, diaallmean as diastolic_12mo
    from bestair.bestairbp24hr
    where timepoint = 12;

    create table ess as
    select elig_studyid, ess_total
    from bestair.bestairess
    where ess_visit = 0;
  quit;

  data bestair_rui;
    merge baseline_cov treatment fu6_bp fu12_bp ess med_antihypertensive2_count;
    by elig_studyid;
  run;

  proc sort data=bestair_rui nodupkey;
    by elig_studyid;
  run;

  data bestair.bestair_rui;
    set bestair_rui;

    if treat_code ne .;
  run;
  */
