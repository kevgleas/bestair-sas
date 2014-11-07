%include "\\rfa01\bwh-sleepepi-bestair\data\SAS\bestair options and libnames.sas";
%include "&bestairpath\SAS\bestair macros for multiple datasets.sas";
*%include "&bestairpath\SAS\redcap\_components\create bestair rand set.sas";

  data redcap_all_timepoints;
    retain elig_studyid study_visit;
    set bestair.baredcap_nomiss;
    if redcap_event_name = "screening_arm_0" then study_visit = -1;
    else if redcap_event_name = "unscheduled_arm_0" then study_visit = -2;
    else if redcap_event_name = "00_bv_arm_1" then study_visit = 0;
    else if redcap_event_name = "02_pc_arm_1" then study_visit = 2;
    else if redcap_event_name = "04_pc_arm_1" then study_visit = 4;
    else if redcap_event_name = "06_fu_arm_1" then study_visit = 6;
    else if redcap_event_name = "08_pc_arm_1" then study_visit = 8;
    else if redcap_event_name = "10_pc_arm_1" then study_visit = 10;
    else if redcap_event_name = "12_fu_arm_1" then study_visit = 12;
    else if redcap_event_name = "99_us_arm_1" then study_visit = 99;
    else if redcap_event_name = "of_01_arm_99" then study_visit = 97;
    else if redcap_event_name = "of_02_arm_99" then study_visit = 98;
  run;

  proc sort data = redcap_all_timepoints;
    by elig_studyid study_visit;
  run;

  data baanthro;
    retain elig_studyid study_visit;
    set bestair.baanthro;

    study_visit = anth_studyvisit;

    drop anth_studyvisit;
  run;

  data babprp;
    retain elig_studyid study_visit;
    set bestair.babprp;

    study_visit = bprp_studyvisit;

    drop bprp_studyvisit;
  run;

  data bapromis;
    retain elig_studyid study_visit;
    set bestair.bapromis;

    study_visit = prom_studyvisit;

    drop prom_studyvisit;
  run;

  data basarp;
    retain elig_studyid study_visit;
    set bestair.basarp;

    study_visit = sarp_studyvisit;

    drop sarp_studyvisit;
  run;

  data basemsa;
    retain elig_studyid study_visit;
    set bestair.basemsa;

    study_visit = semsa_studyvisit;

    drop semsa_studyvisit;
  run;

  data batwpas;
    retain elig_studyid study_visit;
    set bestair.batwpas;


    study_visit = twpas_studyvisit;

    drop twpas_studyvisit;
  run;

  data bestairbloods;
    retain elig_studyid study_visit;
    set bestair.bestairbloods;

    study_visit = bloods_studyvisit;

    drop bloods_studyvisit;
  run;

  data bestairbp24hr;
    retain elig_studyid study_visit;
    set bestair.bestairbp24hr;

    elig_studyid = studyid;
    study_visit = timepoint;

    drop studyid timepoint;
  run;

  data bestaircalgary;
    retain elig_studyid study_visit;
    set bestair.bestaircalgary;

    study_visit = cal_studyvisit;

    drop cal_studyvisit;
  run;

  data bestairecho;
    retain elig_studyid study_visit;
    set bestair.bestairecho;

    study_visit = visit;

    drop visit;
  run;

  data bestaireligibility;
    retain elig_studyid redcap_event_name study_visit;
    set bestair.bestaireligibility;

    study_visit = -1;

    drop randomized;
  run;

  data bestairess;
    retain elig_studyid study_visit;
    set bestair.bestairess;

    study_visit = ess_visit;

    drop ess_visit;
  run;

  data bestairphq8;
    retain elig_studyid study_visit;
    set bestair.bestairphq8;

    study_visit = phq8_studyvisit;

    drop phq8_studyvisit;
  run;

  data bestairpsg;
    retain elig_studyid study_visit;
    set bestair.bestairpsg;

    if psgpurpose = 0 then study_visit = -1;
    else if final_visit = 6 then study_visit = 6;
    else study_visit = 12;

    elig_studyid = studyid;
    keep elig_studyid study_visit recording_date--embqs_ahi embletta waso--ahi_primary_ge30;*ahiu3 pctlt90 avgsat minsat ahi_primary ahi_primary_source ahi_primary_ge30;
    drop studyid;
  run;

  data bestairsf36;
    retain elig_studyid study_visit;
    set bestair.bestairsf36;

    study_visit = sf36_studyvisit;

    drop sf36_studyvisit;
  run;

/*  data bestairtonometry;*/
/*    retain elig_studyid study_visit;*/
/*    set bestair.bestairtonometry;*/
/**/
/*    study_visit = qctonom_studyvisit;*/
/**/
/*    drop qctonom_studyvisit;*/
/*  run;*/

  data bestairtonometry;
    retain elig_studyid study_visit;
    set bestair.bestairtonometry_all;

    elig_studyid = studyid;
    study_visit = qctonom_studyvisit;

    drop studyid qctonom_studyvisit;
  run;

  data bestairwhiirs;
    retain elig_studyid study_visit;
    set bestair.bestairwhiirs;

    study_visit = shq_studyvisit;

    drop shq_studyvisit;
  run;

  ********************************** WORK ON ORDER OF VARIABLES - CONSIDER ;
/*
  proc contents data = baanthro out = contents1 noprint;
  run;

  proc contents data = babprp out = contents2 noprint;
  run;

  proc contents data = bapromis out = contents3 noprint;
  run;

  proc contents data = basarp out = contents4 noprint;
  run;

  proc contents data = basemsa out = contents5 noprint;
  run;

  proc contents data = batwpas out = contents6 noprint;
  run;

  proc contents data = bestairbloods out = contents7 noprint;
  run;

  proc contents data = bestairbp24hr out = contents8 noprint;
  run;

  proc contents data = bestaircalgary out = contents9 noprint;
  run;

  proc sort data = contents9;
  by NAME;
  run;

  proc contents data = bestairecho out = contents10 noprint;
  run;

  proc contents data = bestaireligibility out = contents11 noprint;
  run;

  proc sort data = contents11;
  by NAME;
  run;
  proc contents data = bestairess out = contents12 noprint;
  run;

  proc contents data = bestairphq8 out = contents13 noprint;
  run;

  proc contents data = bestairsf36 out = contents15 noprint;
  run;

  proc contents data = bestairtonometry out = contents16 noprint;
  run;

  proc contents data = bestairwhiirs out = contents17 noprint;
  run;

  data allsubset_contents;
    merge contents1 contents2 contents3 contents4 contents5 contents6 contents7 contents8 contents9 contents10 contents11 contents12 contents13 contents14 contents15 contents16 contents17;
    by NAME;
  run;

  data allsubset_contents;
    set allsubset_contents;
    name = lowcase(name);
  run;

  proc sort data = allsubset_contents nodupkey;
  by name;
  run;

  proc sql noprint;
    select name into :var_droplist separated by ' '
    from allsubset_contents
    where name not in ("elig_studyid", "study_visit");
  quit;

  %let additional_droplist = cardiology_berlin_ess_complete embletta_qs_complete eligibility_complete sleep_journal_runin_complete bp_journal_complete fasting_qc_checklist_complete
        ;

  data redcap_all_timepoints_lessvars;
    set redcap_all_timepoints;
    drop &var_droplist;
    drop &additional_droplist;
  run;

  proc sort data = redcap_all_timepoints_lessvars;
    by elig_studyid study_visit;
  run;
  */

  proc contents data = bestaireligibility out = elig_contents noprint;
  run;

  proc sql noprint;
    select name into :var_droplist separated by ' '
    from elig_contents
    where name not in ("elig_studyid", "study_visit");
  quit;

/*  data redcap_all_timepoints_lessvars;*/
/*    set redcap_all_timepoints;*/
/*    drop &var_droplist;*/
/*  run;*/

  data all_data_bytimepoint;
    retain elig_studyid study_visit;
    merge redcap_all_timepoints bestaireligibility baanthro(where = (study_visit ne .)) babprp(where = (study_visit ne .)) bapromis(where = (study_visit ne .)) 
          basarp(where = (study_visit ne .)) basemsa(where = (study_visit ne .)) batwpas(where = (study_visit ne .)) bestairbloods(where = (study_visit ne .)) 
          bestairbp24hr(where = (study_visit ne .)) bestaircalgary(where = (study_visit ne .)) bestairecho(where = (study_visit ne .)) bestairess(where = (study_visit ne .)) 
          bestairphq8(where = (study_visit ne .)) bestairsf36(where = (study_visit ne .)) bestairtonometry(where = (study_visit ne .)) bestairwhiirs (where = (study_visit ne .))
          bestairpsg(where = (study_visit ne .));
    by elig_studyid study_visit;
  run;

  data all_data_bytimepoint;
    set all_data_bytimepoint;
    rename cardiology_berlin_ess_complete = cardiology_berlin_ess_comp;
    drop i essdo_you_snore_--cbt_followup_phone_c_v_9_;
  run;

  proc contents data = all_data_bytimepoint out = all_data_contents noprint;
  run;

  data timepointneg2 timepointneg1 timepoint00 timepoint02 timepoint04 timepoint06 timepoint08 timepoint10 timepoint12 timepoint99 timepointof1 timepointof2;
    set all_data_bytimepoint;
    if study_visit = -1 then output timepointneg1;
    else if study_visit = -2 then output timepointneg2;
    else if study_visit = 0 then output timepoint00;
    else if study_visit = 2 then output timepoint02;
    else if study_visit = 4 then output timepoint04;
    else if study_visit = 6 then output timepoint06;
    else if study_visit = 8 then output timepoint08;
    else if study_visit = 10 then output timepoint10;
    else if study_visit = 12 then output timepoint12;
    else if study_visit = 99 then output timepoint99;
    else if study_visit = 97 then output timepointof1;
    else if study_visit = 98 then output timepointof2;
  run;

  proc sql noprint;

    select NAME into :toolong_varnames separated by ' '
    from all_data_contents
    where length(NAME) > 29;    

    select NAME into :rename_list1 separated by ' '
    from all_data_contents
    where NAME not in("elig_studyid", "study_visit") and upcase(substr(NAME,1,1)) le byte(71);

    select NAME into :rename_list2 separated by ' '
    from all_data_contents
    where NAME not in("elig_studyid", "study_visit") and byte(72) le upcase(substr(NAME,1,1)) le byte(78);

    select NAME into :rename_list3 separated by ' '
    from all_data_contents
    where NAME not in("elig_studyid", "study_visit") and byte(79) le upcase(substr(NAME,1,1)) le byte(85);

    select NAME into :rename_list4 separated by ' '
    from all_data_contents
    where NAME not in("elig_studyid", "study_visit") and upcase(substr(NAME,1,1)) ge byte(86);

  quit;

  %put &toolong_varnames;

  %macro renamevars_bytimepoint(dataset, timepoint_string);
  data &dataset;
    set &dataset;
    rename %rename_string(&rename_list1, &timepoint_string, location = suffix);
    rename %rename_string(&rename_list2, &timepoint_string, location = suffix);
    rename %rename_string(&rename_list3, &timepoint_string, location = suffix);
    rename %rename_string(&rename_list4, &timepoint_string, location = suffix);

  run;
  %mend renamevars_bytimepoint;

  %renamevars_bytimepoint(timepointneg1,_s1);
  %renamevars_bytimepoint(timepointneg2, _s2);
  %renamevars_bytimepoint(timepoint00, _00);
  %renamevars_bytimepoint(timepoint02, _02);
  %renamevars_bytimepoint(timepoint04, _04);
  %renamevars_bytimepoint(timepoint06, _06);
  %renamevars_bytimepoint(timepoint08, _08);
  %renamevars_bytimepoint(timepoint10, _10);
  %renamevars_bytimepoint(timepoint12, _12);
  %renamevars_bytimepoint(timepoint99, _99);
  %renamevars_bytimepoint(timepointof1, _o1);
  %renamevars_bytimepoint(timepointof2, _o2);

  proc freq data = timepoint00;
    table whiirs_total_00;
  run;

  data timepointneg1;
    set timepointneg1;
    keep elig_studyid redcap_event_name_s1--sleep_journal_runin_complete_s1 ae_studyid_s1--protocol_deviation_complete_s1
        randomized_education_s1 age_atbaseline_s1 race_whitenothispanic_s1 CVDstatus_primary_s1 runin_daysmask_ge13_s1 recording_date_s1--ahi_primary_ge30_s1;
  run;

  data timepointneg2;
    set timepointneg2;
    keep elig_studyid redcap_event_name_s2 embqs_study_id_s2--embletta_qs_complete_s2 ae_studyid_s2--protocol_deviation_complete_s2
        sc_studyid_s2--study_completion_complete_s2;
  run;

  data timepoint00;
    retain elig_studyid randomized;
    set timepoint00;
    if elig_studyid ne 81259 then randomized = 1;
    keep elig_studyid randomized redcap_event_name_00 rand_studyid_00--whiirs_total_00;
    drop twomonth_studyid_00--incoming_phone_call__v_6_00 cbtp2_studyid_00--cbt_followup_phone_c_v_10_00 
        treatdisc_studyid_00--study_completion_complete_00 randomized_education_00 age_atbaseline_00;
  run;

  data timepoint02;
    set timepoint02;
    keep elig_studyid redcap_event_name_02 twomonth_studyid_02--cbt_followup_phone_c_v_10_02; 
    drop sc_studyid_02--study_completion_complete_02;
  run;
  
  data timepoint04;
    set timepoint04;
    keep elig_studyid redcap_event_name_04 twomonth_studyid_04--cbt_followup_phone_c_v_10_04;
    drop sc_studyid_04--study_completion_complete_04;
  run;

  data timepoint06;
    set timepoint06;
    keep elig_studyid redcap_event_name_06 anth_studyid_06--whiirs_total_06;
    drop sc_studyid_06--study_completion_complete_06 randomized_education_06 age_atbaseline_06;
  run;
  
  data timepoint08;
    set timepoint08;
    keep elig_studyid redcap_event_name_08 twomonth_studyid_08--cbt_followup_phone_c_v_10_08;
    drop sc_studyid_08--study_completion_complete_08;
  run;
  
  data timepoint10;
    set timepoint10;
    keep elig_studyid redcap_event_name_10 twomonth_studyid_10--cbt_followup_phone_c_v_10_10;
    drop sc_studyid_10--study_completion_complete_10;
  run;

  data timepoint12;
    set timepoint12;
    keep elig_studyid redcap_event_name_12 anth_studyid_12--whiirs_total_12;
    drop sc_studyid_12--study_completion_complete_12 randomized_education_12--age_atbaseline_12;
  run;

  data timepoint99;
    set timepoint99;
    keep elig_studyid redcap_event_name_99 embqs_study_id_99--embletta_qs_complete_99 treatdisc_studyid_99--study_completion_complete_99;
  run;

  data timepointof1;
    set timepointof1;
    keep elig_studyid redcap_event_name_o1 ae_studyid_o1--serious_adverse_even_v_7_o1;
  run;

  data timepointof2;
    set timepointof2;
    keep elig_studyid redcap_event_name_o2 ae_studyid_o2--serious_adverse_even_v_7_o2;
  run;

  proc format;
    value randomizedf
    0 = "0: No"
    1 = "1: Yes"
    ;
  run;

  data alldata_alltimepoints;
    retain elig_studyid randomized;
    merge timepointneg1 timepointneg2 timepoint00 timepoint02 timepoint04 timepoint06 timepoint08 timepoint10 timepoint12 timepoint99 timepointof1 timepointof2;
    by elig_studyid;
    if randomized ne 1 then randomized = 0;
    format randomized randomizedf.;
  run;

  data alldata_alltimepoints;
    retain elig_studyid randomized final_visit;
    format rand_treatmentarm Rand_treatmentarm_. pooled_treatmentarm Controlorpapf.;
    merge alldata_alltimepoints bestair.bamedicationcat 
          bestair.bamedicationcat_bpmeds (keep = elig_studyid total_antihypertensive_ddd00--total_antihypertensive_ddd12 change_antihypertensive_ddd00_06--change_antihypertensive_ddd00_12);
    by elig_studyid;
    rand_treatmentarm = rand_treatmentarm_00;
    if rand_treatmentarm_00 in (1,2) then pooled_treatmentarm = 0;
    else if rand_treatmentarm_00 in (3,4) then pooled_treatmentarm = 1;
    
    if ess_total_00 ne . then ess_baseline = ess_total_00;
    else if elig_excl09epworthscore_s1 ge 0 then ess_baseline = elig_excl09epworthscore_s1;
  run;

  data allscreeningdata;
    set alldata_alltimepoints;
    drop redcap_event_name_00--change_antihypertensive_ddd00_12;
  run;

  data bestair.bestair_alldata_randomizedpts bestair2.bestair_alldata_random_&sasfiledate;
    set alldata_alltimepoints;
    if randomized = 1;
  run;

  data bestair.bestair_allscreeningdata bestair2.bestair_allscreening_&sasfiledate;
    set allscreeningdata;
  run;
