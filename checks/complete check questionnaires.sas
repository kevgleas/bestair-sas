****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";


*designed to run as part of "complete check all.sas";
*if running independently, uncomment "IMPORT REDCAP DATA" step;

/*
****************************************************************************************;
* IMPORT REDCAP DATA
****************************************************************************************;

  data redcap;
    set bestair.baredcap;
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

  data questionnaires_baseall questionnaires_6all questionnaires_12all;
    set questionnaires1;

    if timepoint = 00 then output questionnaires_baseall; else
    if timepoint = 06 then output questionnaires_6all; else
    if timepoint = 12 then output questionnaires_12all;

    drop cal_studyid phq8_studyid prom_studyid sarp_studyid semsa_studyid sf36_studyid twpas_studyid;
  run;

  data questionnaires_basepending questionnaires_baseresolved;
    set questionnaires1;

    if (cal_studyid = . or phq8_studyid = . or prom_studyid = . or sarp_studyid = . or semsa_studyid = . or sf36_studyid = . or twpas_studyid = .) and timepoint = 00
      then output questionnaires_basepending;
    else if timepoint = 00 then output questionnaires_baseresolved;

  run;

  data questionnaires_6pending questionnaires_6resolved;
    set questionnaires1;

    if (cal_studyid = . or phq8_studyid = . or prom_studyid = . or sarp_studyid = . or semsa_studyid = . or sf36_studyid = . or twpas_studyid = .) and timepoint = 06
      then output questionnaires_6pending;
    else if timepoint = 06 then output questionnaires_6resolved;

  run;

  data questionnaires_12pending questionnaires_12resolved;
    set questionnaires1;

    if (cal_studyid = . or phq8_studyid = . or prom_studyid = . or sarp_studyid = . or semsa_studyid = . or sf36_studyid = . or twpas_studyid = .) and timepoint = 12
      then output questionnaires_12pending;
    else if timepoint = 12 then output questionnaires_12resolved;

  run;

  *print study ids for participants REDCap denotes as pending;
  proc sql;
    title 'Pending Questionnaire Data';
      select elig_studyid, timepoint from questionnaires_basepending;
      select elig_studyid, timepoint from questionnaires_6pending;
      select elig_studyid, timepoint from questionnaires_12pending;
    title;
  quit;

  data questionnaires_baseresolved;
    set questionnaires_baseresolved;
    drop cal_studyid phq8_studyid prom_studyid sarp_studyid semsa_studyid sf36_studyid twpas_studyid cal_d22--cal_f02;
  run;

  data questionnaires_6resolved;
    set questionnaires_6resolved;
    drop cal_studyid phq8_studyid prom_studyid sarp_studyid semsa_studyid sf36_studyid twpas_studyid cal_d22--cal_ds05p cal_e27--cal_es05p;
  run;

  data questionnaires_12resolved;
    set questionnaires_12resolved;
    drop cal_studyid phq8_studyid prom_studyid sarp_studyid semsa_studyid sf36_studyid twpas_studyid cal_d22--cal_ds05p cal_e27--cal_es05p;
  run;





/*

TWPAS not yet added to All Data Completeness

****************************************************************************************;
* CREATE COMPLETENESS TABLE FOR ALL DATA
****************************************************************************************;

  data questionnaires_b2;
    set questionnaires_baseall;

    array questionnaires {97} phq8_interest--sf36_gh05;
    array questionnaires_fix {97} q1-q97;
    do i = 1 to 97;
    if questionnaires{i} = -9 then questionnaires_fix{i} = .; else
    if questionnaires{i} = -10 then questionnaires_fix{i} = .; else
    questionnaires_fix{i} = questionnaires{i};
    end;
    keep elig_studyid timepoint q1--q97;
  run;

  data questionnaires_s2;
    set questionnaires_6all;

    array questionnaires {97} phq8_interest--sf36_gh05;
    array questionnaires_fix {97} q1-q97;
    do i = 1 to 97;
    if questionnaires{i} = -9 then questionnaires_fix{i} = .; else
    if questionnaires{i} = -10 then questionnaires_fix{i} = .; else
    questionnaires_fix{i} = questionnaires{i};
    end;
    keep elig_studyid timepoint q1--q97;
  run;

  data questionnaires_t2;
    set questionnaires_12all;

    array questionnaires {97} phq8_interest--sf36_gh05;
    array questionnaires_fix {97} q1-q97;
    do i = 1 to 97;
    if questionnaires{i} = -9 then questionnaires_fix{i} = .; else
    if questionnaires{i} = -10 then questionnaires_fix{i} = .; else
    questionnaires_fix{i} = questionnaires{i};
    end;
    keep elig_studyid timepoint q1--q97;
  run;

  proc contents data=questionnaires varnum;
  run;

  proc sql;
    delete
    from questionnaires_s2
    where q1 = . and (elig_studyid ne 73192 and elig_studyid ne 73207 and elig_studyid ne 91396);
    delete
    from questionnaires_t2
    where q1 = . and (elig_studyid ne 70016 and elig_studyid ne 70250 and elig_studyid ne 73097 and elig_studyid ne 73107);
  quit;

  proc sort data=questionnaires_s2 nodupkey;
    by elig_studyid;
  run;

  proc sort data=questionnaires_t2 nodupkey;
    by elig_studyid;
  run;

  data questionnaires_b3;
    set questionnaires_b2;

    phq_missb = nmiss(of q1--q10);
    prom_missb = nmiss(of q11--q26);
    sarp_missb = nmiss(of q27--q34);
    semsa_missb = nmiss(of q35--q61);
    sf36_missb = nmiss(of q62--q97);
    var_missb = nmiss(of q1-q97);
    phq_percentb = (phq_missb/10)*100;
    prom_percentb = (prom_missb/16)*100;
    sarp_percentb = (sarp_missb/8)*100;
    semsa_percentb = (semsa_missb/27)*100;
    sf36_percentb = (sf36_missb/36)*100;
    var_percentb = (var_missb/97)*100;
    keep elig_studyid phq_missb--var_percentb;
  run;

  data questionnaires_s3;
    set questionnaires_s2;

    phq_miss6 = nmiss(of q1--q10);
    prom_miss6 = nmiss(of q11--q26);
    sarp_miss6 = nmiss(of q27--q34);
    semsa_miss6 = nmiss(of q35--q61);
    sf36_miss6 = nmiss(of q62--q97);
    var_miss6 = nmiss(of q1-q97);
    phq_percent6 = (phq_miss6/10)*100;
    prom_percent6 = (prom_miss6/16)*100;
    sarp_percent6 = (sarp_miss6/8)*100;
    semsa_percent6 = (semsa_miss6/27)*100;
    sf36_percent6 = (sf36_miss6/36)*100;
    var_percent6 = (var_miss6/97)*100;
    keep elig_studyid phq_miss6--var_percent6;
  run;

  data questionnaires_t3;
    set questionnaires_t2;

    phq_miss12 = nmiss(of q1--q10);
    prom_miss12 = nmiss(of q11--q26);
    sarp_miss12 = nmiss(of q27--q34);
    semsa_miss12 = nmiss(of q35--q61);
    sf36_miss12 = nmiss(of q62--q97);
    var_miss12 = nmiss(of q1-q97);
    phq_percent12 = (phq_miss12/10)*100;
    prom_percent12 = (prom_miss12/16)*100;
    sarp_percent12 = (sarp_miss12/8)*100;
    semsa_percent12 = (semsa_miss12/27)*100;
    sf36_percent12 = (sf36_miss12/36)*100;
    var_percent12 = (var_miss12/97)*100;
    keep elig_studyid phq_miss12--var_percent12;
  run;

  data questionnaires_allcomp;
    merge questionnaires_b3 questionnaires_s3 questionnaires_t3;
    by elig_studyid;
  run;
*/
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

  proc sort data=questionnaires_br2 nodupkey;
    by elig_studyid;
  run;

  proc sort data=questionnaires_sr2 nodupkey;
    by elig_studyid;
  run;

  proc sort data=questionnaires_tr2 nodupkey;
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


  data quest_compstatsfinal;
    merge basequest_comppct mo6quest_comppct mo12quest_comppct;
    by timepoint;
  run;


/*
****************************************************************************************;
* EXPORT COMPLETENESS TABLES AS CSVs
****************************************************************************************;
  proc export data=questionnaires_allcomp dbms=csv outfile="c:\users\kg693\desktop\complete questionnaire averages.csv"; run;
  proc export data=questionnaires_resolvedcomp dbms=csv outfile="c:\users\kg693\desktop\nonpending questionnaire averages.csv"; run; */

