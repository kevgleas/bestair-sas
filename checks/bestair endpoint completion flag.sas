****************************************************************************************;
* Establish BestAIR libraries and options
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

  *import data for research visits;
  data baredcap;
    set bestair.baredcap;
    if redcap_event_name = "00_bv_arm_1" or redcap_event_name = "06_fu_arm_1" or redcap_event_name = "12_fu_arm_1";
  run;

  *create baseline visit dataset;
  data baseline;
    set baredcap(where=(redcap_event_name = "00_bv_arm_1"));

    keep elig_studyid redcap_event_name bloods_studyid--blood_results_labcor_v_1 cal_studyid--cal_ds05p phq8_studyid--phq8_complete sf36_studyid--sf36_bdfa_complete
      shq_sitread--shq_driving;
  run;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\checks\bestair_checks_macros.sas";

  *code variables for missing and not applicable data;
  data codes1;
    set baseline;

    array relabeler[*] bloods_totalchol--bloods_urinecreatin cal_a01--cal_d21 phq8_interest--phq8_total sf36_gh01--sf36_gh05 shq_sitread--shq_stoppedcar;

    do i = 1 to dim(relabeler);
      if relabeler[i] = -8 then relabeler[i] = .n;
      else if relabeler[i] = -9 then relabeler[i] = .m;
      else if relabeler[i] = -10 then relabeler[i] = .c;
    end;

    *blood data;
    array bloods_checker[*] bloods_totalchol--bloods_urinecreatin;
    format base_bloods 8.;
    %endpointcheck_macro(endpoint_array=bloods_checker, result_var=base_bloods);
    if base_bloods = 0 then base_bloods_nmiss = nmiss(of bloods_totalchol--bloods_urinecreatin); else base_bloods_nmiss = 0;

    *calgary (saqli) data;
    array saqli_checker[*] cal_a01--cal_d21;
    format base_saqli 8.;
    %endpointcheck_macro(endpoint_array=saqli_checker, result_var=base_saqli);
    if base_saqli = 0 then base_saqli_nmiss = nmiss(of cal_a01--cal_d21);
    else base_saqli_nmiss = 0;

    *phq8 data;
    array phq8_checker[*] phq8_interest--phq8_total;
    format base_phq8 8.;
    %endpointcheck_macro(endpoint_array=phq8_checker, result_var=base_phq8);
    if base_phq8 = 0 then base_phq8_nmiss = nmiss(of phq8_interest--phq8_total);
    else base_phq8_nmiss = 0;

    *sf36 data;
    array sf36_checker[*] sf36_gh01--sf36_gh05;
    format base_sf36 8.;
    %endpointcheck_macro(endpoint_array=sf36_checker, result_var=base_sf36);
    if base_sf36 = 0 then base_sf36_nmiss = nmiss(of sf36_gh01--sf36_gh05);
    else base_sf36_nmiss = 0;

    *ess data (from shq) - excludes "shq_driving" because variable is not scored as part of ess;
    array ess_checker[*] shq_sitread--shq_stoppedcar;
    format base_ess 8.;
    %endpointcheck_macro(endpoint_array=ess_checker, result_var=base_ess);
    if base_ess = 0 then base_ess_nmiss = nmiss(of shq_sitread--shq_stoppedcar);
    else base_ess_nmiss = 0;

    drop i;

  run;

  *create 6-month and 12-month follow-up visit dataset;
  data m6or12;
    set baredcap(where=(redcap_event_name = "06_fu_arm_1" or redcap_event_name = "12_fu_arm_1"));

    keep elig_studyid redcap_event_name bloods_studyid--blood_results_labcor_v_1 cal_studyid--cal_e26 cal_f01 cal_f02 phq8_studyid--phq8_complete sf36_studyid--sf36_bdfa_complete
      shq_sitread6--shq_driving6;
  run;

  *code variables for missing and not applicable data;
  *rename variables at output for 6- and 12-month visits to differentiate between visits at later merge step;
  data  codes2 (rename=(visit_bloods=m6_bloods visit_bloods_nmiss=m6_bloods_nmiss visit_saqli=m6_saqli visit_saqli_nmiss=m6_saqli_nmiss
                visit_phq8=m6_phq8 visit_phq8_nmiss=m6_phq8_nmiss visit_sf36=m6_sf36 visit_sf36_nmiss=m6_sf36_nmiss visit_ess=m6_ess visit_ess_nmiss=m6_ess_nmiss ))
        codes3 (rename=(visit_bloods=m12_bloods visit_bloods_nmiss=m12_bloods_nmiss visit_saqli=m12_saqli visit_saqli_nmiss=m12_saqli_nmiss
                visit_phq8=m12_phq8 visit_phq8_nmiss=m12_phq8_nmiss visit_sf36=m12_sf36 visit_sf36_nmiss=m12_sf36_nmiss visit_ess=m12_ess visit_ess_nmiss=m12_ess_nmiss ));
    set m6or12;

    array relabeler2[*] bloods_totalchol--bloods_urinecreatin cal_a01--cal_d21 cal_e01--cal_e26 cal_f01 cal_f02 phq8_interest--phq8_total sf36_gh01--sf36_gh05
                        shq_sitread6--shq_stoppedcar6;

    do i = 1 to dim(relabeler2);
      if relabeler2[i] = -8 then relabeler2[i] = .n;
      else if relabeler2[i] = -9 then relabeler2[i] = .m;
      else if relabeler2[i] = -10 then relabeler2[i] = .c;
    end;

    *blood data;
    array bloods_checker2[*] bloods_totalchol--bloods_urinecreatin;
    format visit_bloods 8.;
    %endpointcheck_macro(endpoint_array=bloods_checker2, result_var=visit_bloods);
    if visit_bloods = 0 then visit_bloods_nmiss = nmiss(of bloods_totalchol--bloods_urinecreatin); else visit_bloods_nmiss = 0;

    *calgary (saqli) data;
    array saqli_checker2[*] cal_a01--cal_d21 cal_e01--cal_e26 cal_f01 cal_f02;
    format visit_saqli 8.;
    %endpointcheck_macro(endpoint_array=saqli_checker2, result_var=visit_saqli);
    if visit_saqli = 0 then visit_saqli_nmiss = nmiss(of cal_a01--cal_d21 cal_e01--cal_e26 cal_f01 cal_f02);
    else visit_saqli_nmiss = 0;

    *phq8 data;
    array phq8_checker2[*] phq8_interest--phq8_total;
    format visit_phq8 8.;
    %endpointcheck_macro(endpoint_array=phq8_checker2, result_var=visit_phq8);
    if visit_phq8 = 0 then visit_phq8_nmiss = nmiss(of phq8_interest--phq8_total);
    else visit_phq8_nmiss = 0;

    *sf36 data;
    array sf36_checker2[*] sf36_gh01--sf36_gh05;
    format visit_sf36 8.;
    %endpointcheck_macro(endpoint_array=sf36_checker2, result_var=visit_sf36);
    if visit_sf36 = 0 then visit_sf36_nmiss = nmiss(of sf36_gh01--sf36_gh05);
    else visit_sf36_nmiss = 0;

    *ess data (from shq) - excludes "shq_driving" because variable is not scored as part of ess;
    array ess_checker2[*] shq_sitread6--shq_stoppedcar6;
    format visit_ess 8.;
    %endpointcheck_macro(endpoint_array=ess_checker2, result_var=visit_ess);
    if visit_ess = 0 then visit_ess_nmiss = nmiss(of shq_sitread6--shq_stoppedcar6);
    else visit_ess_nmiss = 0;

    drop i;

    if redcap_event_name = "06_fu_arm_1"
      then output codes2;
    else output codes3;

  run;

  data recode1;
    set codes1;

    keep elig_studyid base_bloods--base_ess_nmiss;
  run;

  data recode2;
    set codes2;

    keep elig_studyid m6_bloods--m6_ess_nmiss;
  run;

  data recode3;
    set codes3;

    keep elig_studyid m12_bloods--m12_ess_nmiss;
  run;

  data flag;
    merge recode1 recode2 recode3;
    by elig_studyid;
  run;

  data bestair.bacompletionflag bestair2.bacompletionflag_&sasfiledate;
    set flag;
  run;

  proc export data=flag dbms=csv outfile="\\rfa01\bwh-sleepepi-bestair\data\sas\checks\BestAIR Endpoint Checks &sasfiledate..csv" replace; run;
