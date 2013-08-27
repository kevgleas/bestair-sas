****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";


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

***************************************************************************************;
* PROCESS SHQ ESS DATA FROM REDCAP
***************************************************************************************;

	data ess_in;
		set redcap;

		if 60000 le elig_studyid le 99999;

		keep elig_studyid shq_namecode shq_namecode6 shq_study_visit shq_sitread--shq_stoppedcar
				sleephealth_question_v_2 shq_studyvisit6 shq_sitread6--shq_driving6 sleephealth_question_v_3;
	run;

***************************************************************************************;
* CREATE BASELINE DATASET AND FILTER OUT MISSING/INVALID RESPONSES
***************************************************************************************;
	data ess_b missingcheck_b;
		set ess_in(keep=elig_studyid shq_namecode shq_study_visit shq_sitread--shq_stoppedcar where=(shq_study_visit=1));
			array ess_base(8) shq_sitread--shq_stoppedcar;
				do i=1 to 8;
					if ess_base(i) < 0 or ess_base(i) = . then output missingcheck_b;
					else output ess_b;
				end;
			drop i;
	run;

	proc sort data=ess_b nodupkey;
		by elig_studyid;
	run;

	proc sort data=missingcheck_b nodupkey;
		by elig_studyid;
	run;

	proc sql;
		delete
		from work.ess_b
		where shq_sitread < 0 or shq_watchingtv < 0 or shq_sitinactive < 0 or shq_ridingforhour < 0 or shq_lyingdown < 0 or shq_sittalk < 0 or shq_afterlunch < 0 or shq_stoppedcar < 0;
	quit;

	data ess_b;
		set ess_b;
			shq_esstotal = shq_sitread + shq_watchingtv + shq_sitinactive + shq_ridingforhour + shq_lyingdown + shq_sittalk + shq_afterlunch + shq_stoppedcar;
			ess_visit = shq_study_visit;
			ess_namecode = shq_namecode;
			ess1 = shq_sitread;
			ess2 = shq_watchingtv;
			ess3 = shq_sitinactive;
			ess4 = shq_ridingforhour;
			ess5 = shq_lyingdown;
			ess6 = shq_sittalk;
			ess7 = shq_afterlunch;
			ess8 = shq_stoppedcar;
			ess_total = shq_esstotal;
			drop shq_sitread--shq_stoppedcar shq_esstotal shq_study_visit;
	run;

***************************************************************************************;
* CREATE 6-MONTH FOLLOW-UP DATASET AND FILTER OUT MISSING/INVALID RESPONSES
***************************************************************************************;

	data ess_6 missingcheck_6;
		set ess_in(keep=elig_studyid shq_namecode6 shq_studyvisit6 shq_sitread6--shq_stoppedcar6 where=(shq_studyvisit6=2));
			array ess_6(8) shq_sitread6--shq_stoppedcar6;
				do i=1 to 8;
					if ess_6(i) < 0 or ess_6(i) = . then output missingcheck_6;
					else output ess_6;
				end;
			drop i;
	run;

	proc sort data=ess_6 nodupkey;
		by elig_studyid;
	run;

	proc sort data=missingcheck_6 nodupkey;
		by elig_studyid;
	run;

	proc sql;
		delete
		from work.ess_6
		where shq_sitread6 < 0 or shq_watchingtv6 < 0 or shq_sitinactive6 < 0 or shq_ridingforhour6 < 0 or shq_lyingdown6 < 0 or shq_sittalk6 < 0 or shq_afterlunch6 < 0 or shq_stoppedcar6 < 0;
	quit;

	data ess_6;
		set ess_6;
			shq_esstotal6 = shq_sitread6 + shq_watchingtv6 + shq_sitinactive6 + shq_ridingforhour6 + shq_lyingdown6 + shq_sittalk6 + shq_afterlunch6 + shq_stoppedcar6;
			ess_visit = shq_studyvisit6;
			ess_namecode = shq_namecode6;
			ess1 = shq_sitread6;
			ess2 = shq_watchingtv6;
			ess3 = shq_sitinactive6;
			ess4 = shq_ridingforhour6;
			ess5 = shq_lyingdown6;
			ess6 = shq_sittalk6;
			ess7 = shq_afterlunch6;
			ess8 = shq_stoppedcar6;
			ess_total = shq_esstotal6;
			drop shq_sitread6--shq_stoppedcar6 shq_esstotal6 shq_studyvisit6;
	run;

***************************************************************************************;
* CREATE 12-MONTH FOLLOW-UP DATASET AND FILTER OUT MISSING/INVALID RESPONSES
***************************************************************************************;

	data ess_12 missingcheck_12;
		set ess_in(keep=elig_studyid shq_namecode6 shq_studyvisit6 shq_sitread6--shq_stoppedcar6 where=(shq_studyvisit6=3));
			array ess_12(8) shq_sitread6--shq_stoppedcar6;
				do i=1 to 8;
					if ess_12(i) < 0 or ess_12(i) = . then output missingcheck_12;
					else output ess_12;
				end;
			drop i;
	run;

	proc sort data=ess_12 nodupkey;
		by elig_studyid;
	run;

	proc sort data=missingcheck_12 nodupkey;
		by elig_studyid;
	run;

	proc sql;
		delete
		from work.ess_12
		where shq_sitread6 < 0 or shq_watchingtv6 < 0 or shq_sitinactive6 < 0 or shq_ridingforhour6 < 0 or shq_lyingdown6 < 0 or shq_sittalk6 < 0 or shq_afterlunch6 < 0 or shq_stoppedcar6 < 0;
	quit;

	data ess_12;
		set ess_12;
			shq_esstotal12 = shq_sitread6 + shq_watchingtv6 + shq_sitinactive6 + shq_ridingforhour6 + shq_lyingdown6 + shq_sittalk6 + shq_afterlunch6 + shq_stoppedcar6;
			ess_visit = shq_studyvisit6;
			ess_namecode = shq_namecode6;
			ess1 = shq_sitread6;
			ess2 = shq_watchingtv6;
			ess3 = shq_sitinactive6;
			ess4 = shq_ridingforhour6;
			ess5 = shq_lyingdown6;
			ess6 = shq_sittalk6;
			ess7 = shq_afterlunch6;
			ess8 = shq_stoppedcar6;
			ess_total = shq_esstotal12;
			drop shq_sitread6--shq_stoppedcar6 shq_esstotal12 shq_studyvisit6;
	run;

***************************************************************************************;
* RECOMBINE INTO SINGLE DATASET
***************************************************************************************;

	data ess;
		set ess_b ess_6 ess_12;
		if ess_visit = 1 then ess_visit = 0;
		if ess_visit = 2 then ess_visit = 6;
		if ess_visit = 3 then ess_visit = 12;
	run;

	proc sort data=ess;
		by elig_studyid ess_visit;
	run;

***************************************************************************************;
* UPDATE PERMANENT DATASETS
***************************************************************************************;
	data bestair.bestairess bestair2.bestairess_&sasfiledate;
		set ess;
	run;
