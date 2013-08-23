****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\bestair options and libnames.sas";


***************************************************************************************;
* READ IN ECHO EXPORT FROM RFA
***************************************************************************************;
	proc import out = echo_in
	            datafile = "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\echo\BESTAIR_Echo_LATEST.csv"
	            dbms =csv replace;
	run;

	*change timepoints to match BestAIR Standard;
	data echo;
		length elig_studyid 8.;
		set echo_in;

		if visit = 1 then visit = 0;
		else if visit = 2 then visit = 12;

		elig_studyid = site_id;

	run;

	proc sort data=echo;
		by elig_studyid;
	run;

	*merge rfa data with data stored on redcap;
	data echo_rand;
		merge echo (in=a) bestair.badsmbtable4 (keep=elig_studyid elig_gender rand_treatmentarm rand_siteid);
		by elig_studyid;

		if a;
	run;


***************************************************************************************;
* RUN STATISTIC FUNCTIONS
***************************************************************************************;

	proc means data=echo_rand n mean std median min max;
		var lvef lvm lvmi;
	run;

	proc means data=echo_rand n mean std median min max;
		var lvef lvm lvmi;
		class rand_treatmentarm;
	run;

	proc means data=echo_rand n mean std median min max;
		var lvef lvm lvmi;
		class rand_siteid;
	run;


*****************************************************************************************;
* PERFORM DATA QC BY CHECKING FOR VALUES OF KEY VARIABLES CONSIDERED SEVERELY ABNORMAL
*****************************************************************************************;
	proc sql;
		title "Left Ventricle End-Diastolic Diameter (LVEDD) Outside Normal Range:";
			select elig_studyid, VISIT, LVEDD from echo_rand
			where (LVEDD ne . and (((LVEDD ge 6.2 or LVEDD < 3.9) and elig_gender = 2) or ((LVEDD ge 6.9 or LVEDD < 4.2) and elig_gender=1)));

		title "Interventricular Septum Thickness (IVS) Outside Normal Range:";
			select elig_studyid, VISIT, IVS from echo_rand
			where (LVEDD ne . and (LVEDD le .6 or (IVS ge 1.6 and gender = 2) or (IVS ge 1.7 and gender = 1)));

		title "End-Diastolic Volume (LVEDV) Outside Normal Range:";
			select elig_studyid, VISIT, LVEDV from echo_rand
			where (LVEDV ne . and (((LVEDV ge 118 or LVEDV < 56) and elig_gender = 2) or ((LVEDV ge 179 or LVEDV < 67) and elig_gender = 1)));

		title "End-Systolic Volume (LVESV) Outside Normal Range:";
			select elig_studyid, VISIT, LVESV from echo_rand
			where (LVESV ne . and (((LVESV ge 70 or LVESV < 19) and elig_gender = 2) or ((LVESV ge 83 or LVESV < 22) and elig_gender = 1)));

		title "Ejection Fraction (LVEF) Outside Normal Range:";
			select elig_studyid, VISIT, LVEF from echo_rand
			where (LVEF ne . and LVEF le 30);

		title "Left Ventricle Mass (LVM) Outside Normal Range:";
			select elig_studyid, VISIT, LVM from echo_rand
			where (LVM ne . and (((LVM ge 193 or LVM < 66) and elig_gender=2) or ((LVM ge 255 or LVM < 96) and elig_gender=1)));

	quit;
	title;


***************************************************************************************;
* CLEAN UP DATASETS
***************************************************************************************;
	* drop variables only used for data checking;
	data bestairecho;
		set echo;
	run;

	proc sort data=bestairecho;
		by elig_studyid visit;
	run;


*****************************************************************************************;
* APPLY LABELS
*****************************************************************************************;
	%ddlabel(bestairecho,echo);

/*Labels as yet undefined*/

*******************************************************************************************;
* COMPARE TO PREVIOUS DATASET
*******************************************************************************************;
	proc compare base=bestair.bestairecho compare=bestairecho nomissbase transpose nosummary;
		title "Echo: Comparison of dataset to previous import";
		id elig_studyid visit;
	run;
	title;


*****************************************************************************************;
* CREATE PERMANENT DATASETS
*****************************************************************************************;

	data bestair.bestairecho bestair2.bestairecho_&sasfiledate;
		set bestairecho;
	run;

