****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";

***************************************************************************************;
* ESTABLISH TEMPORARY NETWORK DRIVE
***************************************************************************************;
x net use y: /d;
x net use y: "\\rfa01\BWH-SleepEpi-bestair\Data\Tonometry\Scored" /P:No;


***************************************************************************************;
* READ IN SCORED REPORTS FROM DCESLEEPSVR
***************************************************************************************;
  * get list of directories in scored folder;
  filename scored pipe 'dir y:\ /b';
  * within each directory, read in report file named s + foldername + .txt;
  data reportlist_pwv reportlist_pwa reportlist_error;
    length studyid timepoint 8.;
    infile scored truncover;
    input folder $30. ;

    studyid = input(substr(folder,1,5),5.);
    timepoint = input(substr(folder,10,2),5.);

    if timepoint > . and substr(folder,12,3) = 'PWV' then output reportlist_pwv;
    else if timepoint > . and substr(folder,12,3) = 'PWA' then output reportlist_pwa;
    else output reportlist_error;

  run;

  *format pwv data;
  data pwv;
    set reportlist_pwv;

    file2read = "y:\"||trim(left(folder))||"";
    infile pwvfile filevar=file2read end=done truncover firstobs=2 dlm='09'x dsd lrecl=512;
    do while(not done);

    informat date_of_birth $10. datetime $19. surname $upcase4.;

    input   system_id $ database_id $ patient_number $ surname $ first_name $
            sex $ date_of_birth $ patient_id $ patient_code $ patient_notes $
            sp $ dp $ mp $ data_rev $ datetime age medication $ notes $
            operator $ interpretation height weight body_mass_index $
            sample_rate $ simulation_mode $ px_dist dt_dist pwv_dist
            pwv_disterr algorithm pheight_pc pp_mdt pp_deviation
            pwv pwverr ptt_sd serialnum a_subtype $ a_nof_10_sets
            a_hr a_mdt a_deviation_dt a_ton_qc_ph a_ton_qc_phv
            a_ton_qc_plv a_ton_qc_blv a_ecg_qc_ph a_ecg_qc_phv
            a_ecg_qc_plv a_ecg_qc_blv b_subtype $ b_nof_10_sets
            b_hr b_mdt b_deviation_dt b_ton_qc_ph b_ton_qc_phv
            b_ton_qc_plv b_ton_qc_blv b_ecg_qc_ph b_ecg_qc_phv
            b_ecg_qc_plv b_ecg_qc_blv
        ;
      output;
    end;
  run;

  *format pwa data;
  data pwa;
    set reportlist_pwa;

    file2read = "y:\"||trim(left(folder))||"";
    infile pwafile filevar=file2read end=done truncover firstobs=2 dlm='09'x dsd lrecl=512;
    do while(not done);

    informat date_of_birth $10. datetime $19. surname $upcase4.;

    input   system_id $ database_id $ patient_number $ surname $ first_name $
            sex $ date_of_birth $ patient_id $ patient_code $ patient_notes $
            sp $ dp $ mp $ data_rev $ datetime $ age medication $ notes $
            operator $ interpretation height weight body_mass_index $
            sample_rate $ simulation_mode $ serialnum sub_type $
            inconclusive $ reference_age ppampratio p_max_dpdt ed
            calc_ed quality_ed p_qc_ph p_qc_phv p_qc_plv p_qc_dv
            p_qc_sdev operator_index p_sp p_dp p_meanp p_t1
            p_t2 p_ai p_calct1 p_calct2 p_esp p_p1 p_p2
            p_t1ed p_t2ed p_quality_t1 p_quality_t2 c_ap c_ap_hr75
            c_mps c_mpd c_tti c_dti c_svi c_al c_ati hr
            c_period c_dd c_ed_period c_dd_period c_ph c_agph
            c_agph_hr75 c_p1_height c_t1r c_sp c_dp c_meanp c_t1
            c_t2 c_ai c_calct1 c_calct2 c_esp c_p1 c_p2 c_t1ed
            c_t2ed c_quality_t1 c_quality_t2
        ;
      output;
    end;
  run;

  *merge pwa and pwv files;
  data batonometry;
    merge pwa (in=a) pwv (in=b);
    by studyid timepoint folder;
  run;

  *print low quality files;
  proc print data=batonometry noobs;
    var studyid timepoint operator_index;
    where . < operator_index < 80;
    title1 'Low Quality PWA Measurements';
    title2 '(Operator Index < 80)';
  run;

  *check for extreme values of ap or aix within pwa files;
  data batonometry_checkpwa batonometry_pwa_ap_err batonometry_pwa_aix_err;
    set batonometry;

    if substr(folder,12,3) = 'PWV' then delete;

    if operator_index < 80 then delete;

    if age < 20 then category = 1;
    else if age > 79 then category = 8;
    else category = floor(age/10);

    if sex = "MALE" then gender = 1; else if sex = "FEMALE" then gender = 2;

    if gender = 1
      then do;
        if category = 1 then do; if (c_ap > 5 or c_ap < -7) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 2 then do; if (c_ap > 9 or c_ap < -7) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 3 then do; if (c_ap > 14 or c_ap < -6) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 4 then do; if (c_ap > 15 or c_ap < -1) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 5 then do; if (c_ap > 19 or c_ap < -1) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 6 then do; if (c_ap > 21 or c_ap < 1) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 7 then do; if (c_ap > 23 or c_ap < 3) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 8 then do; if (c_ap > 24 or c_ap < 4) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        if category = 1 then do; if (c_agph > 14 or c_agph < -14) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 2 then do; if (c_agph > 24 or c_agph < -20) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 3 then do; if (c_agph > 38 or c_agph < -24) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 4 then do; if (c_agph > 39 or c_agph < -1) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 5 then do; if (c_agph > 44 or c_agph < 4) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 6 then do; if (c_agph > 46 or c_agph < 10) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 7 then do; if (c_agph > 48 or c_agph < 12) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 8 then do; if (c_agph > 50 or c_agph < 20) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
      end;
    else if gender = 2
      then do;
        if category = 1 then do; if (c_ap > 7 or c_ap < -5) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 2 then do; if (c_ap > 11 or c_ap < -5) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 3 then do; if (c_ap > 16 or c_ap < -4) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 4 then do; if (c_ap > 20 or c_ap < 0) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 5 then do; if (c_ap > 23 or c_ap < 3) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 6 then do; if (c_ap > 25 or c_ap < 5) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 7 then do; if (c_ap > 26 or c_ap < 6) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        else if category = 8 then do; if (c_ap > 32 or c_ap < 4) then output batonometry_pwa_ap_err; else output batonometry_checkpwa; end;
        if category = 1 then do; if (c_agph > 25 or c_agph < -15) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 2 then do; if (c_agph > 37 or c_agph < -19) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 3 then do; if (c_agph > 44 or c_agph < -4) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 4 then do; if (c_agph > 48 or c_agph < 8) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 5 then do; if (c_agph > 51 or c_agph < 15) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 6 then do; if (c_agph > 52 or c_agph < 16) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 7 then do; if (c_agph > 53 or c_agph < 17) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
        else if category = 8 then do; if (c_agph > 55 or c_agph < 19) then output batonometry_pwa_aix_err; else output batonometry_checkpwa; end;
      end;

  drop px_dist--b_ecg_qc_blv;

  run;
  *eliminate duplicates for pwa;
  proc sort data = batonometry_checkpwa nodupkey;
    by studyid timepoint datetime;
  run;

  *check for extreme values of pwv;
  data batonometry_checkpwv;
    set batonometry;

    if sex = "MALE" then gender = 1; else if sex = "FEMALE" then gender = 2;

    if substr(folder,12,3) = 'PWA' then delete;

    if gender = 1 then pwv_calc = (-0.017 * age) + (0.001 * (age * age)) + 5.490; else if gender = 2 then pwv_calc = (-0.086 * age) + (0.002 * (age * age)) + 6.363;

    drop sub_type--c_quality_t2;
  run;

  *eliminate duplicates for pwv;
  proc sort data = batonometry_checkpwv nodupkey;
    by studyid timepoint datetime;
  run;

***************************************************************************************;
* disconnect network drive;
***************************************************************************************;
  x cd "c:\";
  x net use y: /delete ;


***************************************************************************************;
* IMPORT DATA OF MANUALLY ENTERED QC FORMS FROM REDCAP
***************************************************************************************;

  *if not running as part of "update and check outcome variables.sas", uncomment next datastep;
/* 
  data redcap;
    set bestair.baredcap;
  run;
 */ 


  data redcap_tonom;
    set redcap;

    if 60000 le elig_studyid le 99999 and qctonom_studyid > .;

  run;


  *delete unnecessary variables from bestair dataset and rename key variables to match BestAIR standard verbage;
  data alltonom_in;
    length elig_studyid timepoint 8.;
    set redcap_tonom (keep=elig_studyid redcap_event_name qctonom_studyid--tonometry_qc_complete);
    by elig_studyid;

    if redcap_event_name in ('00_bv_arm_1', '06_fu_arm_1', '12_fu_arm_1');

    if redcap_event_name = '00_bv_arm_1' then timepoint = 0;
    else if redcap_event_name = '06_fu_arm_1' then timepoint = 6;
    else if redcap_event_name = '12_fu_arm_1' then timepoint = 12;


    *rename unclear or confusing variables names from redcap to match variable names in later coding;
    rename qctonom_proximaldista2_50e = qctonom_proximaldistance4;
    rename qctonom_distaldistanc2_f1a = qctonom_distaldistance4;
    rename qctonom_qcnumbersred32_d69 = qctonom_qcnumbersred4;

    rename qctonom_aix3 = qctonom_augix3;
    rename qctonom_aix4 = qctonom_augix4;

    rename qctonom_comments7 = qctonom_comments8;
    rename qctonom_comments6 = qctonom_comments7;
    rename qctonom_comments5 = qctonom_comments6;
    rename qctonom_comments4 = qctonom_comments5;
    rename qctonom_comments3a = qctonom_comments4;


  run;

  *delete observations where no tonometry data was obtained;
  data tonom_in missingcheck_tonom;
    set alltonom_in;

    if qctonom_studyid = -9 then output missingcheck_tonom;
    if qctonom_studyid > 0 then output tonom_in;
    if qctonom_studyid > 0 and (qctonom_pwv1 < 0 or qctonom_pwv1 = . or qctonom_augix1 < 0 or qctonom_augix1 = .) then output missingcheck_tonom;

  run;

  data bestair.bestairtonometry_raw bestair2.bestairtonometry_raw_&sasfiledate;
    set batonometry;
  run;
