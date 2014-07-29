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
* PROCESS BESTAIR PHQ-8 DATA FROM REDCAP
***************************************************************************************;

  data baphq_in;
    set redcap;

    if 60000 le elig_studyid le 99999 and phq8_studyid > .;

    keep elig_studyid redcap_event_name phq8_studyid--phq8_complete;
  run;

  *create two datasets: one of observations missing PHQ-8 data, one of complete PHQ-8 data to be further edited;

  data baphq missingcheck1;
    set baphq_in;
        array phq(8) phq8_interest--phq8_movingslowly;
        do i=1 to 8;
          if phq(i) < 0 or phq8_studyid = -9 then output missingcheck1;
          else output baphq;
        drop i;

      end;
    keep elig_studyid phq8_namecode phq8_studyvisit phq8_interest--phq8_total;

  run;

  *eliminate duplicates from dataset of missing PHQ-8 data;

  proc sort data = missingcheck1 nodupkey;
    by elig_studyid phq8_studyvisit;
  run;

  *eliminate duplicates from complete PHQ-8 dataset;

  proc sort data=baphq nodupkey;
    by elig_studyid phq8_studyvisit;
  run;

  *eliminate observations with missing PHQ-8 data from dataset that will be additionally processed;
/*
  proc sql;
  delete
  from baphq
  where phq8_interest < 0 or phq8_down_hopeless < 0 or phq8_sleep < 0 or phq8_tired < 0 or phq8_appetite < 0
      or phq8_bad_failure < 0 or phq8_troubleconcentrating < 0 or phq8_movingslowly < 0;
  quit;
*/


***************************************************************************************;
* EXPORT AND QUALITY CHECK OBSERVATIONS WITH COMPLETE PHQ-8 DATA
***************************************************************************************;

  data baphq_final;
    set baphq;

    phq8_calc_total = sum(of phq8_interest--phq8_movingslowly);

    array phq8array(8) phq8_interest--phq8_movingslowly;

    do i=1 to 8;
      if phq8array(i) < 0 then do;
        phq8array[i] = .;
        phq8_total = .;
        phq8_calc_total = .;
      end;
    end;
    drop i;
  run;

  data bestair.bestairphq8 bestair2.bestairphq8_&sasfiledate;
    set baphq_final;
  run;

  *validate overall score of PHQ-8 by comparing reported score to calculated sum of individual questions;

  proc sql;
    options linesize=70;
    title "BestAIR PHQ-8 Calculated Total Does Not Match Reported Total";
    select elig_studyid as StudyID, phq8_namecode as Namecode, phq8_studyvisit as Visit, phq8_calc_total as Calculated, phq8_total as REDCap
    from bestair.bestairphq8
    where elig_studyid > . and(
        (phq8_calc_total ne phq8_total)
        );
    title;

  quit;
