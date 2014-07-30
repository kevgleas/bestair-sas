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

	* import spreadsheet with variable formats for echo variables;
  proc import out=formats datafile = "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\bestair data dictionary.xls" dbms = xls replace;
    mixed=yes;
    getnames = yes;
    sheet = "dd";
    datarow = 2;
  run;

	data echo_formats;
		set formats;
		where table = "BESTAIRECHO";
	run;

*****************************************************************************************;
* APPLY LABELS -- code was taken from bestair options and libnames
*****************************************************************************************;
  %macro ddlabel(ds,dir,prefix=none);
    %let file = \\rfa01\BWH-SleepEpi-bestair\Data\SAS\&dir\&ds._labels.sas;
    %let dd = echo_formats;

      ************************************************************************************;
   		* begin writing labeling program;
      ************************************************************************************;
    data _null_;
      file "&file";
      put "proc datasets library=work nolist;";
      put "modify &ds.;";
      put "label";
    run;

    * labels;
    data _null_;
      file "&file" MOD;
      set &dd; *(where=(lowcase(table) = lowcase("&ds")));
      length myput $3200.;
      if label = "" then label = name;
      %if &prefix = none %then %do;
        myput = trim(left(name)) || " = '" || trim(left(label)) || "'";
      %end;
      %else %do;
        myput = trim(left(name)) || " = '" || &prefix || trim(left(label)) || "'";
      %end;
      put myput;

      call symput('nvars',trim(left(put(_n_,best32.))));
    run;
    data _null_;
      file "&file" MOD;
      put ";";
      put "  ";
      put "format";
    run;

    * formats;
    data _null_;
      file "&file" MOD;
      set &dd; *(where=(lowcase(table) = lowcase("&ds")));
      length myput formatlx formatx $3200.;
      formatlx = trim(left(translate(put(formatl,4.)," ","."))) || ".";
      formatx = trim(left(format)) || trim(left(formatlx)) || trim(left(translate(put(formatd,4.)," ",".")));
      if formatx not in ("", ".", " .") then do;
        myput = trim(left(name)) || " " || trim(left(formatx));
        put myput;
      end;
    run;

    data _null_;
      file "&file" MOD;
      put ";";
      put "run;";
      put "quit;";
    run;
    ************************************************************************************;
    * end writing labeling program
    ************************************************************************************;

    * drop data dictionary dataset;
    proc datasets library=work nolist;
      delete &dd;
    quit;

    * run labeling program;
    options nosource2;
    %include "&file";
    options source2;

    options nosource nonotes;
    %put *************************************************************;
    %put * ddlabel macro completed for table &ds..;
    %put * There were &nvars variables in the data dictionary.;
    %put *************************************************************;
    options source notes;
  %mend;

	%ddlabel(echo,echo,prefix=none);

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
/*	%ddlabel(bestairecho,echo);*/

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

*****************************************************************************************;
* CREATE HISTOGRAMS OF RELEVANT VARIABLES
*****************************************************************************************;
	ods pdf file = "\\rfa01\bwh-sleepepi-bestair\Data\SAS\echo\Histograms of Echo Variables &sasfiledate..PDF";
	ods select histogram;
	proc univariate data=echo_rand;
		title "Frequency Distributions for Echo Variables";
		var LVEDD--RVOTVTI;
		histogram;
	run;title;
	ods pdf close;
