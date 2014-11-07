****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";


****************************************************************************************;
* DATA CHECKING
****************************************************************************************;

*limit dataset to randomized participants only;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\redcap\_components\bestair create rand set.sas";

  *rename dataset of randomized participants to match syntax in later include steps;

  data redcap;
    set redcap_rand;
  run;

  data allpts_whichvisits_expected;
    set randset;
    if rand_date < 19359 then do;
      expect_6mo_fu = 1;
      expect_6mo_final = .;
      expect_12mo_final = 1;
    end;
    else if rand_date ge 19359 then do;
      expect_6mo_fu = .;
      expect_6mo_final = 1;
      expect_12mo_final = .;
    end;
  run;

  *import list of all expected visits with final visits denoted;
  proc import datafile = "&bestairpath\Kevin\List of All Expected Visits.csv"
    out = all_expected_visits
    dbms = csv
    replace;
    getnames = yes;
  run;

  *import pending visit list to exclude pending visits from expected data;
  proc import datafile = "&bestairpath\Kevin\Pending Visits.csv"
    out = pending_visits
    dbms = csv
    replace;
    getnames = yes;
    guessingrows = 50;
  run;

/*
  *dropouts can be accounted for using all_expected_visits;

  *import dropout list to add dropouts to redcap timepoints;
  proc import datafile = "&bestairpath\Kevin\Dropout CSV.csv"
    out = dropoutlist
    dbms = csv
    replace;
    getnames = yes;
  run;

  data mo6dropouts (keep = elig_studyid timepoint);
    set dropoutlist;
    if exclude_from6 = 1;
    timepoint = 6;
  run;

  data mo12dropouts (keep = elig_studyid timepoint);
    set dropoutlist;
    if exclude_from12 = 1;
    timepoint = 12;
  run;

  data dropoutvisits;
    merge mo6dropouts mo12dropouts;
    by elig_studyid timepoint;
  run;
*/

*run SAS programs that create completeness datasets;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\complete check questionnaires.sas";
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\complete check crfs.sas";

data bp_compstatsfinal;
  set bp_compstatsfinal;
  if visit_type = '6 Month' then do;
    
  end;
run;

  proc sql;
  ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\BestAIR Predicted Completeness &sasfiledate..PDF";

  title "BestAIR 24-Hour Ambulatory Blood Pressure Completeness Percentages";
  title2 "Percentage of All Randomized Participants Expected to Reach Timepoint (Excluding Pending)";
  select visit_type as Visit, pctpart_bpresolved label = "Including Partial", pctcomp_bpresolved label = "Excluding Partial"
  from work.bp_compstatsfinal;
  title;

  title "BestAIR Lab Results Completeness Percentages";
  title2 "Percentage of All Randomized Participants Expected to Reach Timepoint (Excluding Pending)";
  select visit_type as Visit, pctcomp_bloodresolved as Blood, pctcomp_urineresolved as Urine
  from work.blood_compstatsfinal;
  title;


  title "BestAIR Ultrasound Completeness Percentages";
  title2 "Percentage of All Randomized Participants Expected to Reach Timepoint (Excluding Pending)";
  select visit_type as Visit, pctcomp_pwaresolved label = "Pulse Wave Analysis", pctcomp_pwvresolved label = "Pulse Wave Velocity", pctcomp_echoresolved as Echo
  from work.ultrasound_compstatsfinal;
  title;


  title "BestAIR Questionnaire Completeness as Percentage of Completed Variables";
  title2 "Percentage of All Randomized Participants Expected to Reach Timepoint (Excluding Pending)";
  select visit_type as Visit, cal_comp as Calgary, phq_comp as PHQ_8, prom_comp as PROMIS, sarp_comp as SARP, semsa_comp as SEMSA, sf36_comp label = "SF-36", twpas_comp as TWPAS,
      allquestionnaire_comp as All_Questionnaires
  from work.quest_compstatsfinal;
  title;


  ods pdf close;
  quit;
