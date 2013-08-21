***************************************************************************************;
* import and score calgary 2012-10-23.sas
*
* Created:		7/8/09
* Last updated:	10/30/09 * see notes
* Author:		Michael Rueschman
*
***************************************************************************************;
* Purpose:
*	This program imports data from the Calgary SAQLI for the BestAIR study. It is
*		adapted from a program written by Michael Rueschman for the HomePAP Study
*		[Import HomePAP Calgary (Parts 1 and 2).sas].
*
***************************************************************************************;
***************************************************************************************;
* NOTES:
*	07/08/09 mnr
*		Sought to merge both parts of the Calgary.  Add calculations for Total (SAQLI),
*		which is dependent on timepoint (pre2, post5, post6).  Post-intervention
*		calculations include additional factor in Total (SAQLI) based on QOL improvement and
*		treatment-related symptoms.
*	07/09/09 mnr
*		Simple update to remove additional variables from final merge dataset.
*	07/24/09 mnr
*		Added timepoint listing to data checks.
*	07/27/09 mnr
*		Minor fixes to missingcheck.
*	10/30/09 mnr
*		Added proc compare to import.
*	08/07/2013 kjg
*		Commented code. Improved efficiency for when program runs as part of "update
*		and check outcome variables.sas"
***************************************************************************************;

****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\SAS\bestair options and libnames.sas";


*program set to be run after "redcap export.sas" (bestair\Data\SAS\redcap\_components\redcap export.sas)
	as part of "Run All.sas";
*specifically, program set to run during include steps of "update and check outcome data.sas";
*if running program independently, uncomment section labeled "IMPORT EXISTING DATASET";

/*
****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

	*create dataset by importing data from REDCap, where permanent data is stored;
	data redcap;
		set bestair.baredcap;
	run;
*/



*****************************************************************************************;
* READ IN DATA
*****************************************************************************************;

	data bestcal;
		set redcap;

		if cal_studyid > . and cal_studyid > 0;

		keep elig_studyid cal_namecode--calgary_complete;
	run;

	proc sort data=bestcal;
		by elig_studyid cal_studyvisit;
	run;


*****************************************************************************************;
* MANIPULATE DATA
*****************************************************************************************;

	* part 1;
	data 	calgary1 (drop=variable value)
			missingcheck0 (keep=elig_studyid cal_studyvisit cal_datecompleted variable value);

		set bestcal;

		*********************************************************************************;
		* clean up missing values;
        *********************************************************************************;
		array rcd(*) _numeric_;
		do i=1 to dim(rcd);
			if rcd(i) < 0 then do;
				* output to missing check dataset;
				variable = vname(rcd(i));
				value = rcd(i);
				if rcd(i) in (.,-1,-10) then output missingcheck0;
				* recode to system missing;
				rcd(i) = .;
			end;
		end;
		drop i;

		array rcdc(*) _character_;
		do j=1 to dim(rcdc);
			if rcdc(j) in ("-10","-9","-8","-2","-1") then do;
				* output to missing check dataset;
				variable = vname(rcdc(j));
				value = rcdc(j);
				if rcdc(j) in ("-10") then output missingcheck0;
				* recode to system missing;
				rcdc(j) = "";
			end;
		end;
		drop j;

		* calculate daily functioning subscale;
		array cal_ai(11) cal_a01-cal_a11;

		do i=1 to 11;
			if cal_ai(i) < 1 or cal_ai(i) > 7 then cal_ai(i) = .;
		end;

		cal_anum = n(of cal_a01-cal_a11);
		cal_anmiss = nmiss(of cal_a01-cal_a11);

		if cal_anmiss le 2 then cal_araw = sum(of cal_a01-cal_a10);
		cal_amean = ((cal_araw)/(11-cal_anmiss));


		* calculate social interactions subscale;
		array cal_bi(13) cal_b01-cal_b13;

		do i=1 to 13;
			if cal_bi(i) < 1 or cal_bi(i) > 7 then cal_bi(i) = .;
		end;

		cal_bnum = n(of cal_b01-cal_b13);
		cal_bnmiss = nmiss(of cal_b01-cal_b13);

		if cal_bnmiss le 2 then cal_braw = sum(of cal_b01-cal_b13);
		cal_bmean = ((cal_braw)/(13-cal_bnmiss));


		* calculate emotional functioning subscale;
		array cal_ci(11) cal_c01-cal_c11;

		do i=1 to 11;
			if cal_ci(i) < 1 or cal_ci(i) > 7 then cal_ci(i) = .;
		end;

		cal_cnum = n(of cal_c01-cal_c11);
		cal_cnmiss = nmiss(of cal_c01-cal_c11);

		if cal_cnmiss le 2 then cal_craw = sum(of cal_c01-cal_c10);
		cal_cmean = ((cal_craw)/(11-cal_cnmiss));


		* calculate symptoms subscale;

		if cal_ds01p < 1 or cal_ds01p > 7 then cal_ds01p = .;
		if cal_ds02p < 1 or cal_ds02p > 7 then cal_ds02p = .;
		if cal_ds03p < 1 or cal_ds03p > 7 then cal_ds03p = .;
		if cal_ds04p < 1 or cal_ds04p > 7 then cal_ds04p = .;
		if cal_ds05p < 1 or cal_ds05p > 7 then cal_ds05p = .;

		cal_draw = sum(cal_ds01p, cal_ds02p, cal_ds03p, cal_ds04p, cal_ds05p);
		cal_dmean = ((cal_draw)/(5));

		drop cal_staffid cal_e01--cal_f02;

		output calgary1;
	run;

	proc sort data=missingcheck0;
		by elig_studyid;
	run;

	* part 2;
	data 	calgary2 (drop=variable value)
			missingcheck (keep=elig_studyid cal_studyvisit cal_datecompleted variable value);

		set work.bestcal;

		*********************************************************************************;
		* clean up missing values;
        *********************************************************************************;
		array rcd(*) _numeric_;
		do i=1 to dim(rcd);
			if rcd(i) < 0 then do;
				* output to missing check dataset;
				variable = vname(rcd(i));
				value = rcd(i);
				if rcd(i) in (.,-1,-10) then output missingcheck;
				* recode to system missing;
				rcd(i) = .;
			end;
		end;
		drop i;

		array rcdc(*) _character_;
		do j=1 to dim(rcdc);
			if rcdc(j) in ("-10","-9","-8","-2","-1") then do;
				* output to missing check dataset;
				variable = vname(rcdc(j));
				value = rcdc(j);
				if rcdc(j) in ("-10") then output missingcheck;
				* recode to system missing;
				rcdc(j) = "";
			end;
		end;
		drop j;

		* calculate treatment-related symptoms subscale;
		if cal_es01p < 1 or cal_es01p > 7 then cal_es01p = .;
		if cal_es02p < 1 or cal_es02p > 7 then cal_es02p = .;
		if cal_es03p < 1 or cal_es03p > 7 then cal_es03p = .;
		if cal_es04p < 1 or cal_es04p > 7 then cal_es04p = .;
		if cal_es05p < 1 or cal_es05p > 7 then cal_es05p = .;

		cal_es01px = 7 - cal_es01p;
		cal_es02px = 7 - cal_es02p;
		cal_es03px = 7 - cal_es03p;
		cal_es04px = 7 - cal_es04p;
		cal_es05px = 7 - cal_es05p;

		cal_eraw = sum(cal_es01px, cal_es02px, cal_es03px, cal_es04px, cal_es05px);
		cal_emean = ((cal_eraw)/(5));

		* calculate impact subscale;
		if cal_f01 = . or cal_f02 = . then cal_fweight = .;
		else if cal_f01 > cal_f02 then cal_fweight = cal_f02 / cal_f01;
		else cal_fweight = 1;

		drop cal_staffid--cal_ds05p;

		output calgary2;
	run;

	proc sort data=missingcheck;
		by elig_studyid;
	run;

	* merge into single calgary dataset;
	data calgarymerge;
		merge calgary1 (in=a) calgary2 (in=b);
		by elig_studyid;

		cal_total = .;

		if nmiss(of cal_amean, cal_bmean, cal_cmean) = 0 and cal_studyvisit = 0 then do;
			cal_total = sum(of cal_amean, cal_bmean, cal_cmean, cal_dmean) / 4;
		end;
		else if nmiss(of cal_amean, cal_bmean, cal_cmean) = 0 and cal_studyvisit in (6,12) then do;
			if cal_emean = . then cal_emean = 0;
			if cal_fweight = . then cal_fweight = 0;
			cal_total = (sum(of cal_amean, cal_bmean, cal_cmean, cal_dmean) - (cal_emean * cal_fweight)) / 4;
		end;
	run;

/*
	*create frequency tables for calgary responses;

	proc freq data=calgarymerge;
		table cal_a01 -- cal_ds05p;
	run;

	proc freq data=calgarymerge;
		table cal_e01 -- cal_f02;
	run;
*/


*data checking section remaining from HomePAP study;
*BestAIR data checking occurs as part of "update and check outcome variables.sas" program;

*****************************************************************************************;
* DATA CHECKING
*****************************************************************************************;
	* run macro to create and print title for data checking;
/*	%datechecktitle(calgary1,HomePAP Calgary SAQLI Part 1 Import);

	* create check dataset by merging from multiple data sources;
	data check;
		merge 	calgary1 (in=a)
				hsql.homepap_covenrl (in=b keep=studyid timepoint namecode cal1_2 cal1_5
					cal1_6 rename=(namecode=namecode_cov));
		by studyid timepoint;

		namecode = lowcase(namecode);
		namecode_cov = lowcase(namecode_cov);

		if a then incal1 = 1;
		if b then incov = 1;

		if timepoint in (2,5,6);

	run;

	* print missing values from missingcheck1 dataset;
	title "Calgary 1: Missing values";
	proc print data=missingcheck1 noobs;
		var studyid timepoint cal1_date variable value;
		where variable not in ('cal_d22','cal_d23','cal_ds01','cal_ds02','cal_ds03',
			'cal_ds04','cal_ds05','cal_ds01p','cal_ds02p','cal_ds03p','cal_ds04p',
			'cal_ds05p','CAL1_FORMID','CAL1_BATCHNO');
	run; title;

	* run remainder of data checks using proc sql;
	options nolabel;
	proc sql;
		title "Calgary 1: Namecode mismatches between form and cover sheet";
		select studyid, timepoint, namecode, namecode_cov from check
		where namecode ne namecode_cov and namecode ne '' and namecode_cov ne '';

		title "Calgary 1: Data is present, but no cover sheet entered";
		select studyid, incal1, incov from check
		where incal1 = 1 and incov ne 1;

		title "Calgary 1: Cover sheet indicates form is present, but no data entered";
		select studyid, timepoint, incal1, cal1_2, cal1_5, cal1_6 from check
		where incal1 ne 1 and (cal1_2 = 1 or cal1_5 = 1 or cal1_6 = 1);

		title "Calgary 1: Data is present, but cover sheet indicates form not present";
		select studyid, timepoint, incal1, cal1_2, cal1_5, cal1_6 from check
		where incal1 = 1 and ((cal1_2 ne 1 and timepoint = 2) or (cal1_5 ne 1
			and timepoint = 5) or (cal1_6 ne 1 and timepoint = 6));

		title "Calgary 1: Date Form Completed is Missing or Out of Range";
		select studyid, timepoint, cal1_date from calgary1
		where cal1_date = . or cal1_date lt 02/13/2008 or cal1_date ge input("&sysdate",date9.);

		title "Calgary 1: Important symptom number is out of range (1-23)";
		select studyid, timepoint, cal_ds01, cal_ds02, cal_ds03, cal_ds04, cal_ds05 from calgary1
		where cal_ds01 > 23 or cal_ds02 > 23 or cal_ds03 > 23 or cal_ds04 > 23 or cal_ds05 > 23;
	quit;
	title; options label;


	* run macro to create and print title for data checking;
	%datechecktitle(calgary2,HomePAP Calgary SAQLI Part 2 Import);

	* create check dataset by merging from multiple data sources;
	data check;
		merge 	calgary2 (in=a)
				hsql.homepap_covenrl (in=b keep=studyid timepoint namecode cal2_5
					cal2_6 rename=(namecode=namecode_cov));
		by studyid timepoint;

		namecode = lowcase(namecode);
		namecode_cov = lowcase(namecode_cov);

		if a then incal2 = 1;
		if b then incov = 1;

		if timepoint in (5,6);

	run;

	* print missing values from missingcheck2 dataset;
	title "Calgary 2: Missing values";
	proc print data=missingcheck2 noobs;
		var studyid timepoint cal2_date variable value;
		where variable not in ('cal_e27','cal_e27s','cal_e28','cal_e28s','cal_es01','cal_es02',
			'cal_es03','cal_es04','cal_es05','cal_es01p','cal_es02p','cal_es03p','cal_es04p',
			'cal_es05p','CAL2_BATCHNO','CAL2_FORMID');
	run; title;

	* run remainder of data checks using proc sql;
	options nolabel;
	proc sql;
		title "Calgary 2: Date Form Completed is Missing or Out of Range";
		select studyid, cal2_date from calgary2
		where cal2_date = . or cal2_date LT 02/13/2008 or cal2_date GE input("&sysdate",date9.);
	quit;
	title; options label;


***************************************************************************************;
* CLEAN UP DATASETS
***************************************************************************************;
	* drop variables only used for data checking;
	data homepapcalgary1;
		set calgary1;

		*drop variables unnecessary in final dataset;
		drop cal1_formid--cal1_entrynotes;
	run;

	data homepapcalgary2;
		set calgary2;

		*drop variables unnecessary in final dataset;
		drop cal2_formid--cal2_entrynotes cal_es01px--cal_es05px;
	run;

	data homepapcalgarymerge;
		set calgarymerge;

		*drop variables unnecessary in final dataset;
		drop cal1_formid--cal1_entrynotes cal2_formid--cal2_entrynotes cal_es01px--cal_es05px;
	run;

	proc datasets library=work nolist;
		delete missingcheck1 missingcheck2 calgarymerge calgary1 calgary2;
	quit; run;


*****************************************************************************************;
* APPLY LABELS
*****************************************************************************************;
	%ddlabel(homepapcalgary1,calgary saqli);
	%ddlabel(homepapcalgary2,calgary saqli);
	%ddlabel(homepapcalgarymerge,calgary saqli);


*******************************************************************************************;
* COMPARE TO PREVIOUS DATASET
*******************************************************************************************;
	proc compare base=homepap.homepapcalgarymerge compare=homepapcalgarymerge nomissbase transpose nosummary;
		title "Calgary Merge: Comparison of dataset to previous import";
		id studyid timepoint;
	run;
	title;


*****************************************************************************************;
* CREATE PERMANENT DATASETS
*****************************************************************************************;
	data bestair.bacalgary1 homepap2.homepapcalgary1_&sasfiledate;
		set homepapcalgary1;
	run;

	data homepap.homepapcalgary2 homepap2.homepapcalgary2_&sasfiledate;
		set homepapcalgary2;
	run;
*/
	data bestair.bestaircalgary bestair2.bestaircalgary_&sasfiledate;
		set calgarymerge;
	run;

