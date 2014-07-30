****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";


*program set to be run after "redcap export.sas" (bestair\Data\SAS\redcap\_components\redcap export.sas)
  as part of "Run All.sas";
*specifically, program set to run during include steps of "update and check outcome data.sas";
*if running program independently, uncomment section labeled "IMPORT EXISTING DATASET";


****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;
/*
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
  run;


  *score promis subscales - one missing value makes subscale null;
  *all variables but prom_quality are wrongfully based on 0-4 scale, instead of the proper 1 - 5;
  data promis_scored;
    set promis_fix (where = (prom_studyid ne -9));
    format prom_restless_recode prom_satisfied_recode prom_refreshing_recode prom_difficulty_recode prom_staying_recode prom_sleeping_recode prom_enough_recode prom_quality_recode
            prom_thingsdone_recode prom_alert_recode prom_tired_recode prom_problems_recode prom_concentrating_recode prom_irritable_recode prom_daytime_recode 
            prom_stayawake_recode best12.;

    array redcap_scores[16] prom_restless--prom_stayawake;
    array recodes[16] prom_restless_recode--prom_stayawake_recode;

    do i = 1 to 16;
      if i = 8 then recodes[i] = redcap_scores[i];
      else recodes[i] = redcap_scores[i] + 1;
    end;
    drop i;

    *recode to reverse order for 5 variables = satisfied, refreshing, enough, quality, alert;
    prom_satisfied_recode = abs(prom_satisfied_recode - 5) + 1;
    prom_refreshing_recode = abs(prom_refreshing_recode - 5) + 1;
    prom_enough_recode = abs(prom_enough_recode - 5) + 1;
    prom_quality_recode = abs(prom_quality_recode - 5) + 1;
    prom_alert_recode = abs(prom_alert_recode - 5) + 1;

    prom_sdscale = prom_restless_recode + prom_satisfied_recode + prom_refreshing_recode + prom_difficulty_recode + prom_staying + prom_sleeping + prom_enough_recode + prom_quality_recode;
    prom_sriscale = prom_thingsdone_recode + prom_alert_recode + prom_tired_recode + prom_problems_recode + prom_concentrating_recode + prom_irritable_recode + prom_daytime_recode 
                    + prom_stayawake_recode;

  run;

  data promis_scored;
    set promis_scored;
    label prom_sdscale = "Sleep Disturbance (short form)"
          prom_sriscale = "Sleep Related-Impairment (short form)";
    drop promis_dcfc_complete prom_restless_recode--prom_stayawake_recode;
  run;

  *proc export data = promis_scored outfile = "\\rfa01\bwh-sleepepi-bestair\Data\Kevin\promis 02-25-14.csv" dbms = csv replace;
  *run;


***************************************************************************************;
* EXPORT TO PERMANENT DATASET
***************************************************************************************;
  data bestair.bapromis bestair2.bapromis_&sasfiledate;
    set promis_scored;
  run;
