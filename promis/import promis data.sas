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
* PROCESS PROMIS DATA FROM REDCAP
***************************************************************************************;

	data promis_in;
		set redcap;

		if 60000 le elig_studyid le 99999 and prom_studyid > .;

		keep elig_studyid redcap_event_name prom_studyid--promis_dcfc_complete;
	run;

	*create dataset of observations missing variables;
	data missingcheck_promis;
		set promis_in;

		if redcap_event_name = '00_bv_arm_1' then timepoint = 0;
		if redcap_event_name = '06_fu_arm_1' then timepoint = 6;
		if redcap_event_name = '12_fu_arm_1' then timepoint = 12;

		array check_promis[*] prom_restless--prom_stayawake;

		do i = 1 to dim(check_promis);
			if check_promis[i] = . or check_promis[i] < 0 then output missingcheck_promis;
		end;

		drop i redcap_event_name;

	run;

	proc sort data = missingcheck_promis nodupkey;
		by elig_studyid;
	run;

	*change missing values to sas standard '.';
	data promis_fix;
		set promis_in;

		array check_promis[*] prom_restless--prom_stayawake;

			do i = 1 to dim(check_promis);
				if check_promis[i] < 0 then do;
					check_promis[i] = .;
				end;
			end;

		drop redcap_event_name i;
		*drop sarp_fallasleepdriving--sarp_sexperformance sarp_visitdate sarp_staffid i sarp_complete;

	run;

***************************************************************************************;
* EXPORT TO PERMANENT DATASET
***************************************************************************************;
	data bestair.bapromis bestair2.bapromis_&sasfiledate;
		set promis_fix;
	run;
