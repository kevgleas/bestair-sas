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
* PROCESS SEMSA DATA FROM REDCAP
***************************************************************************************;

  data semsa_in;
    set redcap;

    if 60000 le elig_studyid le 99999 and semsa_studyid > 0;

    keep elig_studyid redcap_event_name semsa_studyid--semsa_complete;
  run;


  *create dataset of observations missing variables;
  data missingcheck_semsa;
    set semsa_in;

    if redcap_event_name = '00_bv_arm_1' then timepoint = 0;
    if redcap_event_name = '06_fu_arm_1' then timepoint = 6;
    if redcap_event_name = '12_fu_arm_1' then timepoint = 12;

    array check_semsa[*] semsa_highbp--semsa_paysomecost;

    do i = 1 to dim(check_semsa);
      if check_semsa[i] = . or check_semsa[i] < 0 then output missingcheck_semsa;
    end;

    drop i redcap_event_name;

  run;

  *change missing values to sas standard '.';
  data semsa_fix;
    set semsa_in;

    array semsa_array (27) semsa_highbp--semsa_paysomecost;
      do i = 1 to 27;
        if semsa_array(i) in (-9,-10) then do;
          semsa_array(i) = .;
        end;
      end;


  drop i redcap_event_name;
    *drop sarp_fallasleepdriving--sarp_sexperformance sarp_visitdate sarp_staffid i sarp_complete;

  run;

  *create subscales for the 3 different sections of the semsa;
  data semsa_subscales;
    set semsa_fix;

    semsa_pr = sum(of semsa_highbp--semsa_sexdesire);
    semsa_oe = sum(of semsa_decaccdriving--semsa_desire);
    semsa_tse = sum(of semsa_claustro--semsa_paysomecost);

    semsa_pr_nmiss = nmiss(of semsa_highbp--semsa_sexdesire);
    semsa_oe_nmiss = nmiss(of semsa_decaccdriving--semsa_desire);
    semsa_tse_nmiss = nmiss(of semsa_claustro--semsa_paysomecost);

    if semsa_pr_nmiss > 0
      then semsa_pr = .;
    if semsa_oe_nmiss > 0
      then semsa_oe = .;
    if semsa_tse_nmiss > 0
      then semsa_tse = .;

  run;

***************************************************************************************;
* PERFORM QUALITY CHECK
***************************************************************************************;

  *print observations with partial and missing data;
/*  proc sql;*/
/*    title "SEMSA00 NO MISS";select semsa_studyid from bestair.basemsa where semsa_pr_nmiss = 0 and semsa_oe_nmiss = 0 and semsa_tse_nmiss = 0 and semsa_studyvisit = 0;*/
/*    title "SEMSA00 PART";select semsa_studyid from bestair.basemsa where (semsa_pr_nmiss ne 0 or semsa_oe_nmiss ne 0 or semsa_tse_nmiss ne 0) and semsa_studyvisit = 0;*/
/*    TITLE "SEMSA06 NO MISS";select semsa_studyid from bestair.basemsa where semsa_pr_nmiss = 0 and semsa_oe_nmiss = 0 and semsa_tse_nmiss = 0 and semsa_studyvisit = 6;*/
/*    TITLE "SEMSA06 PART";select semsa_studyid from bestair.basemsa where (semsa_pr_nmiss ne 0 or semsa_oe_nmiss ne 0 or semsa_tse_nmiss ne 0) and semsa_studyvisit = 6;*/
/*    TITLE "SEMSA12 NO MISS";select semsa_studyid from bestair.basemsa where semsa_pr_nmiss = 0 and semsa_oe_nmiss = 0 and semsa_tse_nmiss = 0 and semsa_studyvisit = 12;*/
/*    TITLE "SEMSA12 PART";select semsa_studyid from bestair.basemsa where (semsa_pr_nmiss ne 0 or semsa_oe_nmiss ne 0 or semsa_tse_nmiss ne 0) and semsa_studyvisit = 12;*/
/*    TITLE "SEMSA MISS";select semsa_studyid, semsa_studyvisit from bestair.basemsa where semsa_studyid = . or semsa_studyid < 0;*/
/*  quit;*/


***************************************************************************************;
* EXPORT SEMSA DATA TO PERMANENT DATASET
***************************************************************************************;
  data bestair.basemsa bestair2.basemsa_&sasfiledate;
    set semsa_subscales;
  run;


