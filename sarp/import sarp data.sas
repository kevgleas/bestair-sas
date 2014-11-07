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
* PROCESS SARP DATA FROM REDCAP
***************************************************************************************;

data sarp_in;
  set redcap;

  if 60000 le elig_studyid le 99999 and sarp_studyid > 0;

  keep elig_studyid redcap_event_name sarp_studyid--sarp_complete;
run;

*create dataset of observations missing variables;
data missingcheck_sarp;
  set sarp_in;

  if redcap_event_name = '00_bv_arm_1' then timepoint = 0;
  if redcap_event_name = '06_fu_arm_1' then timepoint = 6;
  if redcap_event_name = '12_fu_arm_1' then timepoint = 12;

  array check_sarp[8] sarp_fallasleepdriving--sarp_sexperformance;

  do i = 1 to 8;
    if check_sarp[i] = . or check_sarp[i] < 0 then output missingcheck_sarp;
  end;

run;

proc sort data = missingcheck_sarp nodupkey;
  by elig_studyid;
run;

data missingcheck_sarp;
  retain elig_studyid timepoint sarp_studyid sarp_namecode sarp_visitdate sarp_studyvisit sarp_staffid sarp_fallasleepdriving sarp_accident sarp_heartattack sarp_fallasleepday
      sarp_highbp sarp_diffconc sarp_depressed sarp_sexperformance sarp_complete;
  set missingcheck_sarp;
run;




*change missing values to sas standard '.';
data sarp_fix;
  set sarp_in;

  array sarp_array (8) sarp_fallasleepdriving--sarp_sexperformance;
    do i = 1 to 8;
      if sarp_array(i) < 0 then do;
        sarp_array(i) = .;
      end;
    end;

  drop redcap_event_name i sarp_studyid;
  *drop sarp_fallasleepdriving--sarp_sexperformance sarp_visitdate sarp_staffid i sarp_complete;

run;

***************************************************************************************;
* EXPORT TO PERMANENT DATASET
***************************************************************************************;
data bestair.basarp bestair2.basarp_&sasfiledate;
  set sarp_fix;
run;
