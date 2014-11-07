****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";


*designed to run as part of "complete check all.sas";
*if running independently, uncomment "IMPORT REDCAP (and other) DATA" step;

/*
****************************************************************************************;
* IMPORT REDCAP DATA
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
    guessingrows = 500;
  run;

  *import pending visit list to exclude dropouts from expected data;
  proc import datafile = "&bestairpath\Kevin\Pending Visits.csv"
    out = pending_visits
    dbms = csv
    replace;
    getnames = yes;
    guessingrows = 50;
  run;


*/

****************************************************************************************;
* PROCESS REDCAP DATA
****************************************************************************************;

  data questionnaires;
    set redcap;

    if redcap_event_name = "00_bv_arm_1" or redcap_event_name = "06_fu_arm_1" or redcap_event_name = "12_fu_arm_1";

    keep elig_studyid redcap_event_name cal_studyid--cal_f02 phq8_studyid--twpas_usualpace;

    drop cal_namecode--cal_staffid phq8_namecode--phq8_staffid phq8_complete prom_namecode--prom_staffid promis_dcfc_complete sarp_namecode--sarp_staffid sarp_complete
        semsa_namecode--semsa_staffid semsa_complete sf36_namecode--sf36_staffid sf36_bdfa_complete shq_namecode--shq_staffid sleephealth_question_v_2
        shq_namecode6--shq_staffid6 sleephealth_question_v_3 qctonom_studyid--monitor_24_hr_qc_complete twpas_namecode--twpas_staffid;
  run;

  data questionnaires1;
    retain elig_studyid timepoint;
    set questionnaires;

    if redcap_event_name = "00_bv_arm_1" then timepoint = 00; else
    if redcap_event_name = "06_fu_arm_1" then timepoint = 06; else
    if redcap_event_name = "12_fu_arm_1" then timepoint = 12;
    else timepoint = .;

    drop redcap_event_name;

    *drop shq because number of variables to be completed is dependent on answers to certain questions within questionnaires;
    drop shq_studyid--shq_pressurechestdoctsay6;

  run;

  *exclude participants who have 12-month timepoint erroneously listed in REDCap and add visits for dropouts;
  *(because study completion form was originalyy created to be completed after 12-month timepoint,
  12-month timepoint is auto-created in REDCap when participant completes study, even if only intended to be enrolled for 6-months);

  data questionnaires1;
    merge all_expected_visits (in = a) questionnaires1 (in = b);
    by elig_studyid timepoint;
    if a;
  run;
/*
  *exclude pending visits from calculation (6-month visit timepoint is created in REDCap at time of 6-month phone call);
  data questionnaires1;
    merge questionnaires1 (in = a) pending_visits (in = b keep = elig_studyid timepoint);
    by elig_studyid timepoint;
    *for pending visits, assume all quest data except for calgary;
    if b then do;
      array assume_allquestdata[*] _numeric_;
      do i = 103 to dim(assume_allquestdata);
        assume_allquestdata[i] = 1;
      end;
      drop i;
    end;
  run;
*/

  data questionnaires1;
    set questionnaires1;

    drop cal_studyid phq8_studyid prom_studyid sarp_studyid semsa_studyid sf36_studyid twpas_studyid;

  run;

  /*
  data twpas;
    retain elig_studyid timepoint;
    set questionnaires;

    if redcap_event_name = "00_bv_arm_1" then timepoint = 00; else
    if redcap_event_name = "06_fu_arm_1" then timepoint = 06; else
    if redcap_event_name = "12_fu_arm_1" then timepoint = 12;
    else timepoint = .;

    drop redcap_event_name;

    *narrow to twpas variables;
    drop cal_studyid--shq_pressurechestdoctsay6;

  run;
  */

*all baselines should be resolved - last baseline 8/02/2013;

  data  questionnaires_baseresolved (drop = cal_d22--cal_f02)
        questionnaires_6resolved (drop = cal_d22--cal_ds05p cal_e27--cal_es05p)
        questionnaires_12resolved (drop = cal_d22--cal_ds05p cal_e27--cal_es05p)
        questionnaires_finalresolved (drop = cal_d22--cal_ds05p cal_e27--cal_es05p);

    set questionnaires1;

    if timepoint = 00 then output questionnaires_baseresolved;
    else if timepoint = 06 then output questionnaires_6resolved;
    else if timepoint = 12 then output questionnaires_12resolved;

    if is_final = 1 then output questionnaires_finalresolved;

  run;


****************************************************************************************;
* CREATE COMPLETENESS TABLE FOR NON-PENDING DATA
****************************************************************************************;

  data questionnaires_br2;
    set questionnaires_baseresolved;

    array questionnaires_fix[*] cal_a01--twpas_usualpace;
    do i = 1 to dim(questionnaires_fix);
      if (questionnaires_fix[i] = -9 or questionnaires_fix[i] = -10) then questionnaires_fix[i] = .;
    end;

    keep elig_studyid timepoint cal_a01--twpas_usualpace i;
  run;

  data questionnaires_sr2;
    set questionnaires_6resolved;

    array questionnaires_fix[*] cal_a01--twpas_usualpace;
    do i = 1 to dim(questionnaires_fix);
      if (questionnaires_fix[i] = -9 or questionnaires_fix[i] = -10) then questionnaires_fix[i] = .;
    end;

    keep elig_studyid timepoint cal_a01--twpas_usualpace i;
  run;

  data questionnaires_tr2;
    set questionnaires_12resolved;

    array questionnaires_fix[*] cal_a01--twpas_usualpace;
    do i = 1 to dim(questionnaires_fix);
      if (questionnaires_fix[i] = -9 or questionnaires_fix[i] = -10) then questionnaires_fix[i] = .;
    end;

    keep elig_studyid timepoint cal_a01--twpas_usualpace i;
  run;

  data questionnaires_fr2;
    set questionnaires_finalresolved;

    array questionnaires_fix[*] cal_a01--twpas_usualpace;
    do i = 1 to dim(questionnaires_fix);
      if (questionnaires_fix[i] = -9 or questionnaires_fix[i] = -10) then questionnaires_fix[i] = .;
    end;

    keep elig_studyid timepoint cal_a01--twpas_usualpace i;
  run;

  proc sort data=questionnaires_br2 nodupkey;
    by elig_studyid;
  run;

  proc sort data=questionnaires_sr2 nodupkey;
    by elig_studyid;
  run;

  proc sort data=questionnaires_tr2 nodupkey;
    by elig_studyid;
  run;

  proc sort data=questionnaires_fr2 nodupkey;
    by elig_studyid;
  run;

  data questionnaires_br3;
    set questionnaires_br2;

    cal_miss = nmiss(of cal_a01--cal_d21);
    phq_miss = nmiss(of phq8_interest--phq8_difficulty);
    prom_miss = nmiss(of prom_restless--prom_stayawake);
    sarp_miss = nmiss(of sarp_fallasleepdriving--sarp_sexperformance);
    semsa_miss = nmiss(of semsa_highbp--semsa_paysomecost);
    sf36_miss = nmiss(of sf36_gh01--sf36_gh05);
    twpas_miss = nmiss(of twpas_light_yn--twpas_usualpace);
    var_miss = nmiss(of cal_a01--twpas_usualpace);
    cal_percent = (cal_miss/56);
    phq_percent = (phq_miss/10);
    prom_percent = (prom_miss/16);
    sarp_percent = (sarp_miss/8);
    semsa_percent = (semsa_miss/27);
    sf36_percent = (sf36_miss/36);
    twpas_percent = (twpas_miss/73);
    var_percent = (var_miss/(i-1));

    keep elig_studyid cal_miss--var_percent;

  run;


  data questionnaires_sr3;
    set questionnaires_sr2;

    cal_miss = nmiss(of cal_a01--cal_f02);
    phq_miss = nmiss(of phq8_interest--phq8_difficulty);
    prom_miss = nmiss(of prom_restless--prom_stayawake);
    sarp_miss = nmiss(of sarp_fallasleepdriving--sarp_sexperformance);
    semsa_miss = nmiss(of semsa_highbp--semsa_paysomecost);
    sf36_miss = nmiss(of sf36_gh01--sf36_gh05);
    twpas_miss = nmiss(of twpas_light_yn--twpas_usualpace);
    var_miss = nmiss(of cal_a01--twpas_usualpace);
    cal_percent = (cal_miss/84);
    phq_percent = (phq_miss/10);
    prom_percent = (prom_miss/16);
    sarp_percent = (sarp_miss/8);
    semsa_percent = (semsa_miss/27);
    sf36_percent = (sf36_miss/36);
    twpas_percent = (twpas_miss/73);
    var_percent = (var_miss/(i-1));

    keep elig_studyid cal_miss--var_percent;

  run;

  data questionnaires_tr3;
    set questionnaires_tr2;

    cal_miss = nmiss(of cal_a01--cal_f02);
    phq_miss = nmiss(of phq8_interest--phq8_difficulty);
    prom_miss = nmiss(of prom_restless--prom_stayawake);
    sarp_miss = nmiss(of sarp_fallasleepdriving--sarp_sexperformance);
    semsa_miss = nmiss(of semsa_highbp--semsa_paysomecost);
    sf36_miss = nmiss(of sf36_gh01--sf36_gh05);
    twpas_miss = nmiss(of twpas_light_yn--twpas_usualpace);
    var_miss = nmiss(of cal_a01--twpas_usualpace);
    cal_percent = (cal_miss/84);
    phq_percent = (phq_miss/10);
    prom_percent = (prom_miss/16);
    sarp_percent = (sarp_miss/8);
    semsa_percent = (semsa_miss/27);
    sf36_percent = (sf36_miss/36);
    twpas_percent = (twpas_miss/73);
    var_percent = (var_miss/(i-1));

    keep elig_studyid cal_miss--var_percent;

  run;

  data questionnaires_fr3;
    set questionnaires_fr2;

    cal_miss = nmiss(of cal_a01--cal_f02);
    phq_miss = nmiss(of phq8_interest--phq8_difficulty);
    prom_miss = nmiss(of prom_restless--prom_stayawake);
    sarp_miss = nmiss(of sarp_fallasleepdriving--sarp_sexperformance);
    semsa_miss = nmiss(of semsa_highbp--semsa_paysomecost);
    sf36_miss = nmiss(of sf36_gh01--sf36_gh05);
    twpas_miss = nmiss(of twpas_light_yn--twpas_usualpace);
    var_miss = nmiss(of cal_a01--twpas_usualpace);
    cal_percent = (cal_miss/84);
    phq_percent = (phq_miss/10);
    prom_percent = (prom_miss/16);
    sarp_percent = (sarp_miss/8);
    semsa_percent = (semsa_miss/27);
    sf36_percent = (sf36_miss/36);
    twpas_percent = (twpas_miss/73);
    var_percent = (var_miss/(i-1));

    keep elig_studyid cal_miss--var_percent;

  run;


  proc means noprint data = questionnaires_br3;
    output out = basequest_misspct mean(cal_percent) = cal_missing mean(phq_percent) = phq_missing mean(prom_percent) = prom_missing mean(sarp_percent) = sarp_missing
        mean(semsa_percent)=semsa_missing mean(sf36_percent)=sf36_missing mean(twpas_percent) = twpas_missing mean(var_percent) = allquestionnaire_missing;
  run;

  proc means noprint data = questionnaires_sr3;
    output out = mo6quest_misspct mean(cal_percent) = cal_missing mean(phq_percent) = phq_missing mean(prom_percent) = prom_missing mean(sarp_percent) = sarp_missing
        mean(semsa_percent)=semsa_missing mean(sf36_percent)=sf36_missing mean(twpas_percent) = twpas_missing mean(var_percent) = allquestionnaire_missing;
  run;

  proc means noprint data = questionnaires_tr3;
    output out = mo12quest_misspct mean(cal_percent) = cal_missing mean(phq_percent) = phq_missing mean(prom_percent) = prom_missing mean(sarp_percent) = sarp_missing
        mean(semsa_percent)=semsa_missing mean(sf36_percent)=sf36_missing mean(twpas_percent) = twpas_missing mean(var_percent) = allquestionnaire_missing;
  run;

  proc means noprint data = questionnaires_fr3;
    output out = finalquest_misspct mean(cal_percent) = cal_missing mean(phq_percent) = phq_missing mean(prom_percent) = prom_missing mean(sarp_percent) = sarp_missing
        mean(semsa_percent)=semsa_missing mean(sf36_percent)=sf36_missing mean(twpas_percent) = twpas_missing mean(var_percent) = allquestionnaire_missing;
  run;



  data basequest_comppct (keep = visit_type timepoint cal_comp--allquestionnaire_comp);
    retain visit_type timepoint;
    set basequest_misspct;

    visit_type = "Baseline";
    timepoint = 00;

    format cal_comp phq_comp prom_comp sarp_comp semsa_comp sf36_comp twpas_comp allquestionnaire_comp percent10.1;

    cal_comp = 1 - cal_missing;
    phq_comp = 1 - phq_missing;
    prom_comp = 1 - prom_missing;
    sarp_comp = 1 - sarp_missing;
    semsa_comp = 1 - semsa_missing;
    sf36_comp = 1 - sf36_missing;
    twpas_comp = 1 - twpas_missing;
    allquestionnaire_comp = 1 - allquestionnaire_missing;

  run;

  data mo6quest_comppct (keep = visit_type timepoint cal_comp--allquestionnaire_comp);
    retain visit_type timepoint;
    set mo6quest_misspct;

    visit_type = "6 Month";
    timepoint = 06;

    format cal_comp phq_comp prom_comp sarp_comp semsa_comp sf36_comp twpas_comp allquestionnaire_comp percent10.1;

    cal_comp = 1 - cal_missing;
    phq_comp = 1 - phq_missing;
    prom_comp = 1 - prom_missing;
    sarp_comp = 1 - sarp_missing;
    semsa_comp = 1 - semsa_missing;
    sf36_comp = 1 - sf36_missing;
    twpas_comp = 1 - twpas_missing;
    allquestionnaire_comp = 1 - allquestionnaire_missing;


  run;

  data mo12quest_comppct (keep = visit_type timepoint cal_comp--allquestionnaire_comp);
    retain visit_type timepoint;
    set mo12quest_misspct;

    visit_type = "12 Month";
    timepoint = 12;

    format cal_comp phq_comp prom_comp sarp_comp semsa_comp sf36_comp twpas_comp allquestionnaire_comp percent10.1;

    cal_comp = 1 - cal_missing;
    phq_comp = 1 - phq_missing;
    prom_comp = 1 - prom_missing;
    sarp_comp = 1 - sarp_missing;
    semsa_comp = 1 - semsa_missing;
    sf36_comp = 1 - sf36_missing;
    twpas_comp = 1 - twpas_missing;
    allquestionnaire_comp = 1 - allquestionnaire_missing;

  run;

  data finalquest_comppct (keep = visit_type timepoint cal_comp--allquestionnaire_comp);
    retain visit_type timepoint;
    set finalquest_misspct;

    visit_type = "Combined Final";
    timepoint = 99;

    format cal_comp phq_comp prom_comp sarp_comp semsa_comp sf36_comp twpas_comp allquestionnaire_comp percent10.1;

    cal_comp = 1 - cal_missing;
    phq_comp = 1 - phq_missing;
    prom_comp = 1 - prom_missing;
    sarp_comp = 1 - sarp_missing;
    semsa_comp = 1 - semsa_missing;
    sf36_comp = 1 - sf36_missing;
    twpas_comp = 1 - twpas_missing;
    allquestionnaire_comp = 1 - allquestionnaire_missing;

  run;

  data quest_compstatsfinal;
    format visit_type $20.;
    merge basequest_comppct mo6quest_comppct mo12quest_comppct finalquest_comppct;
    by timepoint;
  run;


/*
****************************************************************************************;
* EXPORT COMPLETENESS TABLES AS CSVs
****************************************************************************************;
  proc export data=quest_compstatsfinal dbms=csv outfile="c:\users\kg693\desktop\complete questionnaire averages.csv"; run;
  proc export data=questionnaires_resolvedcomp dbms=csv outfile="c:\users\kg693\desktop\nonpending questionnaire averages.csv"; run; */

