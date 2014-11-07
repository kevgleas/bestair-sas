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

*run SAS programs that create completeness datasets;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\complete check questionnaires (adjusted).sas";
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\complete check crfs (adjusted).sas";



  proc sql;
  ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\_adjusted\BestAIR Completeness (adjusted) &sasfiledate..PDF";

  title "BestAIR 24-Hour Ambulatory Blood Pressure Completeness Percentages";
  select visit_type as Visit, pctpart_bpresolved label = "Including Partial", pctcomp_bpresolved label = "Excluding Partial"
  from work.bp_compstatsfinal;
  title;

  title "BestAIR Lab Results Completeness Percentages";
  select visit_type as Visit, pctcomp_bloodresolved as Blood, pctcomp_urineresolved as Urine
  from work.blood_compstatsfinal;
  title;


  title "BestAIR Ultrasound Completeness Percentages";
  select visit_type as Visit, pctcomp_pwaresolved label = "Pulse Wave Analysis", pctcomp_pwvresolved label = "Pulse Wave Velocity", pctcomp_echoresolved as Echo
  from work.ultrasound_compstatsfinal;
  title;


  title "BestAIR Questionnaire Completeness as Percentage of Completed Variables";
  select visit_type as Visit, cal_comp as Calgary, phq_comp as PHQ_8, prom_comp as PROMIS, sarp_comp as SARP, semsa_comp as SEMSA, sf36_comp label = "SF-36", twpas_comp as TWPAS,
      allquestionnaire_comp as All_Questionnaires
  from work.quest_compstatsfinal;
  title;


  ods pdf close;
  quit;
