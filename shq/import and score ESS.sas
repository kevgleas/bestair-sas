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
      ess_namecode = shq_namecode;
      ess_visit = shq_study_visit;
      

      array base_ess[8] ess1-ess8;
			array base_shq[8] shq_sitread--shq_stoppedcar;
			do i = 1 to 8;
				base_ess[i] = base_shq[i];
			end;

      ess_total = sum(of shq_sitread--shq_stoppedcar);

      drop shq_namecode shq_sitread--shq_stoppedcar shq_study_visit i;
  run;

***************************************************************************************;
* CREATE 6-MONTH FOLLOW-UP DATASET AND FILTER OUT MISSING/INVALID RESPONSES
***************************************************************************************;

  data ess_6or12 missingcheck_6or12;
    set ess_in(keep=elig_studyid shq_namecode6 shq_studyvisit6 shq_sitread6--shq_stoppedcar6 where=(shq_studyvisit6=2 or shq_studyvisit6=3));
      array ess_6(8) shq_sitread6--shq_stoppedcar6;
        do i=1 to 8;
          if ess_6(i) < 0 or ess_6(i) = . then output missingcheck_6or12;
          else output ess_6or12;
        end;
      drop i;
  run;

  proc sort data=ess_6or12 nodupkey;
    by elig_studyid shq_studyvisit6;
  run;

  proc sort data=missingcheck_6or12 nodupkey;
    by elig_studyid shq_studyvisit6;
  run;

  data missingcheck_6 missingcheck_12;
    if shq_studyvisit6 = 2 then output missingcheck_6;
    else output missingcheck_12;
  run;

  proc sql;
    delete
    from work.ess_6or12
    where shq_sitread6 < 0 or shq_watchingtv6 < 0 or shq_sitinactive6 < 0 or shq_ridingforhour6 < 0 or shq_lyingdown6 < 0 or shq_sittalk6 < 0 or shq_afterlunch6 < 0 or shq_stoppedcar6 < 0;
  quit;

  data ess_6or12;
    set ess_6or12;
      ess_namecode = shq_namecode6;
      ess_visit = shq_studyvisit6;

      array mo6or12_ess[8] ess1-ess8;
			array mo6or12_shq[8] shq_sitread6--shq_stoppedcar6;
			do i = 1 to 8;
				mo6or12_ess[i] = mo6or12_shq[i];
			end;

      ess_total = sum(of shq_sitread6--shq_stoppedcar6);

      drop shq_namecode6 shq_sitread6--shq_stoppedcar6 shq_studyvisit6 i;
  run;

***************************************************************************************;
* RECOMBINE INTO SINGLE DATASET
***************************************************************************************;

  data ess;
    set ess_b ess_6or12;
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
