****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
* IMPORT TONOMETRY DATA FROM SPHYGMACOR AND QC FORMS FROM REDCAP
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\tonometry\import bestair tonometry.sas";

***************************************************************************************;
* DATA CHECKING - CHECK DATA IN SPHYGMACOR FILES ON RFA AGAINST QC FORMS IN REDCAP
***************************************************************************************;

  data tonom_in;
    set work.tonom_in;

    rename elig_studyid = studyid;

  run;

******;
* PWV
******;

  *create dataset of desired variables from sphygmacor observations to use for data checking;
  data pwv_sphyg_var;
    set pwv;

    pwv_stdpct = ptt_sd;
    pwverrptt_sd = pwverr;

    *create variable to check against dates of measurements;
    format sphyg_date $10.;
    sphyg_date=datetime;

    keep studyid timepoint sphyg_date px_dist dt_dist pwv pwverrptt_sd pwv_stdpct;

  run;

  *create dataset where each visit is its own observation with multiple pwv measurements;
  proc transpose data=pwv_sphyg_var out=pwv_sphyg_pwv prefix=sphyg_pwv;
    var pwv;
    by studyid timepoint;
  run;

  *create dataset where each visit is its own observation with multiple standard deviation measurements;
  proc transpose data=pwv_sphyg_var out=pwv_sphyg_std prefix=sphyg_stdpct;
    var pwv_stdpct;
    by studyid timepoint;
  run;

  *include date of sphygmacor measurement in dataset;
  proc transpose data = pwv_sphyg_var out=pwv_sphyg_dates prefix = sphyg_date;
    var sphyg_date;
    by studyid timepoint;
  run;

  *merge datasets for above sphymacor measurements for data checking;
  data pwv_sphyg_byvisit;
    merge pwv_sphyg_pwv pwv_sphyg_std pwv_sphyg_dates;
    by studyid timepoint;

    rename sphyg_date1=sphyg_date;
    drop sphyg_date2--sphyg_date5 _NAME_;
  run;

  *merge sphygmacor data with redcap data, keeping key variables;
  data pwv_check;
    merge pwv_sphyg_byvisit tonom_in;
    by studyid timepoint;

    *set unobserved values of pwv equal to null for data checking;
    
    array pwv_fixer[*] qctonom_pwv1-qctonom_pwv4 qctonom_standarddeviation1-qctonom_standarddeviation4;
    do i = 1 to dim(pwv_fixer);
      if pwv_fixer[i] < 0
        then pwv_fixer[i] = .;
    end;

    keep studyid timepoint qctonom_visitdate sphyg_date sphyg_pwv1--sphyg_stdpct4 qctonom_pwv1-qctonom_pwv4 qctonom_standarddeviation1-qctonom_standarddeviation4;

  run;

  *print files possibly imported from wrong visit;
  data proper_import_check;
    set pwv_check;

    sphyg_datecheck = input(sphyg_date, ddmmyy10.);
    redcap_datecheck = qctonom_visitdate;
  run;

  proc sql;
    title 'PWV Sphygmacor Date does not match REDCap Date - Re-export';
      select studyid, timepoint from proper_import_check where redcap_datecheck ne sphyg_datecheck and
          (sphyg_datecheck ne . and redcap_datecheck ne .);
    title;
  quit;

  *create 2 datasets, one where sphygmacor pwv and redcap pwv match, one where they do not match;
  data pwv_match pwv_nomatch;
    set pwv_check;

    if (sphyg_pwv1 = qctonom_pwv1 and sphyg_pwv2 = qctonom_pwv2 and sphyg_pwv3 = qctonom_pwv3 and sphyg_pwv4 = qctonom_pwv4)
      then output pwv_match;
    else output pwv_nomatch;

  run;

  *create 3 datasets, one where sphymacor stdpct and redcap stdpct match, one where they do not match, one where redcap is missing data;
  data stdpct_match stdpct_nomatch stdpct_neverentered;
    set pwv_check;

    if (qctonom_pwv1 ne . and qctonom_standarddeviation1 = .)
      then output stdpct_neverentered;
    else if (abs(sphyg_stdpct1-qctonom_standarddeviation1) < .1 and abs(sphyg_stdpct2-qctonom_standarddeviation2) < .1 and
        abs(sphyg_stdpct3-qctonom_standarddeviation3) < .1 and abs(sphyg_stdpct4-qctonom_standarddeviation4) < .1)
      then output stdpct_match;
    else output stdpct_nomatch;

  run;

******;
* PWA
******;

  *create dataset of desired variables from sphygmacor observations to use for data checking;
  data pwa_sphyg_var;
    set pwa;

    *create variable to check against dates of measurements;
    format sphyg_date $10.;
    sphyg_date=datetime;

    keep studyid timepoint sphyg_date operator_index c_ap c_agph;

  run;

  *create dataset where each visit is its own observation with multiple operator indices;
  proc transpose data=pwa_sphyg_var out=pwa_sphyg_operix prefix=sphyg_operix;
    var operator_index;
    by studyid timepoint;
  run;

  *create dataset where each visit is its own observation with multiple augmentation index measurements;
  proc transpose data=pwa_sphyg_var out=pwa_sphyg_augix prefix=sphyg_augix;
    var c_agph;
    by studyid timepoint;
  run;

  *create dataset where each visit is its own observation with multiple augmentation pressure measurements;
  proc transpose data=pwa_sphyg_var out=pwa_sphyg_augpress prefix=sphyg_augpress;
    var c_ap;
    by studyid timepoint;
  run;

  *include date of sphygmacor measurement in dataset;
  proc transpose data = pwa_sphyg_var out=pwa_sphyg_dates prefix = sphyg_date;
    var sphyg_date;
    by studyid timepoint;
  run;

  *merge datasets for above sphymacor measurements for data checking;
  data pwa_sphyg_byvisit;
    merge pwa_sphyg_operix pwa_sphyg_augix pwa_sphyg_augpress pwa_sphyg_dates;
    by studyid timepoint;

    rename sphyg_date1=sphyg_date;
    drop sphyg_date2--sphyg_date5 _NAME_;
  run;

  *merge sphygmacor data with redcap data, keeping key variables;
  data pwa_check (rename = (qctonom_augpressa1=qctonom_augpress1 qctonom_augpressa2=qctonom_augpress2 qctonom_augpressa3=qctonom_augpress3 qctonom_augpressa4=qctonom_augpress4));
    merge pwa_sphyg_byvisit tonom_in;
    by studyid timepoint;

    *change augmentation pressure to numeric variable for data checking;
    qctonom_augpressa1 = input(qctonom_augpress1, BEST12.);
    qctonom_augpressa2 = input(qctonom_augpress2, BEST12.);
    qctonom_augpressa3 = input(qctonom_augpress3, BEST12.);
    qctonom_augpressa4 = input(qctonom_augpress4, BEST12.);

    *set unobserved values of operator index equal to null for data checking;
    array pwa_fixer[*] qctonom_specifyoi1-qctonom_specifyoi4 qctonom_augix1-qctonom_augix4 qctonom_augpressa1-qctonom_augpressa4;
    do i = 1 to dim(pwa_fixer);
      if pwa_fixer[i] < 0
        then pwa_fixer[i] = .;
    end;


    keep studyid timepoint qctonom_visitdate sphyg_date sphyg_operix1--sphyg_augpress4 qctonom_specifyoi1-qctonom_specifyoi4 qctonom_augix1-qctonom_augix4
        qctonom_augpressa1-qctonom_augpressa4;

  run;

  *create 2 datasets, one where sphygmacor operator index and redcap operator index match, one where they do not match;
  data operix_match operix_nomatch;
    set pwa_check;

    if (sphyg_operix1 = qctonom_specifyoi1 and sphyg_operix2 = qctonom_specifyoi2 and
        sphyg_operix3 = qctonom_specifyoi3 and sphyg_operix4 = qctonom_specifyoi4)
      then output operix_match;
    else output operix_nomatch;

  run;

  *create 2 datasets, one where sphygmacor augmentation index and redcap augmentation index match, one where they do not match;
  data augix_match augix_nomatch;
    set pwa_check;

    if (sphyg_augix1 = qctonom_augix1 and sphyg_augix2 = qctonom_augix2 and
        sphyg_augix3 = qctonom_augix3 and sphyg_augix4 = qctonom_augix4)
      then output augix_match;
    else output augix_nomatch;

  run;

  *create 2 datasets, one where sphygmacor augmentation pressure and redcap augmentation pressure match, one where they do not match;
  data augpress_match augpress_nomatch;
    set pwa_check;

    if (sphyg_augpress1 = qctonom_augpress1 and sphyg_augpress2 = qctonom_augpress2 and
        sphyg_augpress3 = qctonom_augpress3 and sphyg_augpress4 = qctonom_augpress4)
      then output augpress_match;
    else output augpress_nomatch;

  run;

  *print files possibly imported from wrong visit;
  data proper_import_check2;
    set pwa_check;

    sphyg_datecheck = input(sphyg_date, ddmmyy10.);
    redcap_datecheck = qctonom_visitdate;
  run;

  proc sql;
    title 'PWA Sphygmacor Date does not match REDCap Date - Re-export';
      select studyid, timepoint from proper_import_check2 where redcap_datecheck ne sphyg_datecheck and
          (sphyg_datecheck ne . and redcap_datecheck ne .);
    title;
  quit;

  *recombine pwa and pwv;
  data all_tonom;
    merge pwv_check pwa_check;
    by studyid timepoint;
  run;

  *print studyids where raw data is missing from server;
  proc sql;
    title 'Missing All Tonometry Raw Files from Visit';
      select studyid, timepoint from all_tonom where (qctonom_pwv1 > 0 and sphyg_pwv1 = .) and
          (qctonom_augix1 > 0 and sphyg_augix1 = .);
    title;

    title 'Missing PWV Raw Files from Visit';
      select studyid, timepoint from all_tonom where (qctonom_pwv1 > 0 and sphyg_pwv1 = .) and
          (sphyg_augix1 > 0 or (qctonom_augix1 = sphyg_augix1));
    title;

    title 'Missing PWA Raw Files from Visit';
      select studyid, timepoint from all_tonom where (qctonom_augix1 > 0 and sphyg_augix1 = .) and
          (sphyg_pwv1 > 0 or (qctonom_pwv1 = sphyg_pwv1));
    title;
  quit;


***************************************************************************************;
* RUN BASIC STATISTICAL ANALYSIS
***************************************************************************************;
  *create data set for statistics of augmentation pressure for each subject and visit;
  proc means data = pwa;
    var c_ap;
    by studyid surname timepoint;
    output out=pwa_ap_stats mean = mean_aug_press std=std_aug_press min = min_aug_press max = max_aug_press;
  run;

  data pwa_ap_stats;
    set pwa_ap_stats;
    rename surname = namecode;
    rename _FREQ_ = n_measurements;
    drop _TYPE_;
  run;

  *create data set for statistics of augmentation index for each subject and visit;
  proc means data = pwa;
    var c_agph;
    by studyid surname timepoint;
    output out=pwa_aix_stats mean = mean_aug_ix std=std_aug_ix min = min_aug_ix max = max_aug_ix;
  run;

  data pwa_aix_stats;
    set pwa_aix_stats;
    rename surname = namecode;
    rename _FREQ_ = n_measurements;
    drop _TYPE_;
  run;

  *create data set for statistics of pulse pressure for each subject and visit;
  proc means data = pwa;
    var c_ap;
    by studyid surname timepoint;
    output out=pwa_pp_stats mean = mean_pulse_press std=std_pulse_press min = min_pulse_press max = max_pulse_press;
  run;

  data pwa_pp_stats;
    set pwa_pp_stats;
    rename surname = namecode;
    rename _FREQ_ = n_measurements;
    drop _TYPE_;
  run;

  *create data set for statistics of pulse wave velocity for each subject and visit;
  proc means data = pwv;
    var pwv;
    by studyid surname timepoint;
    output out=pwv_stats mean = mean_pwv std=std_pwv min = min_pwv max = max_pwv;
  run;

  data pwv_stats;
    set pwv_stats;
    rename surname = namecode;
    rename _FREQ_ = n_measurements;
    drop _TYPE_;
  run;


*;
*;
*Edited through here;
* Check labels for gender with Cailler
*;
*;
/*
******************************************************************************;
* Create Formats for the SASS Data Sets;
******************************************************************************;
* These formats will be stored in the permanent format library in sass_titration folder;
proc format library=sass;
  value genderf   0="0: Female" 1="1: Male";
  value arteryf   0="0: Radial"
          1="1: Carotid"
          2="2: Femoral";
  value yesnof  1="1: Yes"  0="0: No";
  value ejdurf  0="0: Very Strong"
          1="1: Strong"
          2="2: Weak"
          3="3: Very Weak";
run;


******************************************************************************;
* Add Labels and Formats to the SAS Data Sets;
******************************************************************************;
data sass_pwa;
  set sass_pwa1;

  label
  Patient_Number  = "PWA: Patient's Machine Assigned Number"
  Date_Of_Birth = "PWA: Patient's Date of Birth"
  studyid     = "PWA: Entered StudyID Number (optional)"
  SP        = "PWA: Entered Brachial Systolic Pressure (mmHg)"
  DP        = "PWA: Entered Brachial Diastolic Pressure (mmHg)"
  OPERATOR    = "PWA: Entered Operator ID (optional)"
  PPAmpRatio    = "PWA: Pulse Pressure Amplification Ratio (%)"
  P_MAX_DPDT    = "PWA: Peripheral Pulse Maximum dP/dT (max rise in slope of radial upstroke) (mmHg/ms)"
  ED1       = "PWA: Ejection Duration 1 (ms)"
  QUALITY_ED    = "PWA: Confidence Level of Ejection Duration (0-3 (0=very strong, 3= very weak))"
  P_QC_PH     = "PWA: Peripheral Pulse Quality Control- Average Pulse Height (signal strenth (arbitrary units))"
  P_QC_PHV    = "PWA: Peripheral Pulse Quality Control- Pulse Height Variation (degree of variability (unitless))"
  P_QC_PLV    = "PWA: Peripheral Pulse Quality Control- Pulse Length Variation degree of variability (unitless))"
  P_QC_DV     = "PWA: Peripheral Pulse Quality Control- Diastolic Variation degree of variability (unitless))"
  P_QC_SDEV   = "PWA: Peripheral Pulse Quality Control- Shape Deviation degree of variability (unitless))"
  Operator_Index  = "PWA: Calculated Operator Index (0-100)"
  P_SP      = "PWA: Peripheral Systolic Pressure (mmHg)"
  P_DP      = "PWA: Peripheral Diastolic Pressure (mmHg)"
  P_MEANP     = "PWA: Peripheral Mean Pressure (mmHg)"
  P_T1      = "PWA: Peripheral T1 (ms)"
  P_T2      = "PWA: Peripheral T2 (ms)"
  P_AI      = "PWA: Peripheral Augmentation Index (%)"
  ED2       = "PWA: Ejection Duration 2 (different from 'CalcED' only if operator manually adjusts end of systole) (ms)"
  CalcED1     = "PWA: Calculated Ejection Duration 1 (ms)"
  P_ESP     = "PWA: Peripheral End Systolic Pressure (mmHg)"
  P_P1      = "PWA: Peripheral P1 mmHg)"
  P_P2      = "PWA: Peripheral P2 (mmHg)"
  P_T1ED      = "PWA: Peripheral T1/ED (%)"
  P_T2ED      = "PWA: Peripheral T2/Ed (%)"
  P_QUALITY_T1  = "PWA: Peripheral Confidence Level of T1 (0-3 (0=very strong, 3= very weak))"
  P_QUALITY_T2  = "PWA: Peripheral Confidence Level of T2 (0-3 (0=very strong, 3= very weak))"
  C_AP      = "PWA: Central Augmentation Pressure (mmHg)"
  C_AP_HR75   = "PWA: Central Augmentation Pressure @ HR 75 (mmHg)"
  C_MPS     = "PWA: Central Mean Pressure of Systole (mmHg)"
  C_MPD     = "PWA: Central Mean Pressure of Diastole (mmHg)"
  C_TTI     = "PWA: Central Tension Time Index (area under curve during systole) (mmHg*ms)"
  C_DTI     = "PWA: Central Diastolic Time Index (area under curve during diastole) (mmHg*ms)"
  C_SVI     = "PWA: Central Subendocardial Viability Ratio (CDTI/CTTI) (%)"
  C_AL      = "PWA: Central Augmentation Load (when augmentation >0)- extra work by heart because of wave reflection (%)"
  C_ATI     = "PWA: Central Area of Augmentation (when augmentation >0)- area under the curve of augmentation (mmHg*ms)"
  HR        = "PWA: Heart Rate (Beats/minute)"
  C_PERIOD    = "PWA: Heart Rate Period (ms)"
  C_DD      = "PWA: Central Diastolic Duration (ms)"
  C_ED_PERIOD   = "PWA: Central ED/Period (%)"
  C_DD_PERIOD   = "PWA: Diastolic Duration/Period (%)"
  C_PH      = "PWA: Central Pulse Pressure (mmHg)"
  C_AGPH      = "PWA: Central Augmentation Index (as percentage of Pulse Pressure) (%)"
  C_AGPH_HR75   = "PWA: Central Augmentation Index @ HR 75bmp (as percentage of pulse pressure) (%)"
  C_P1_HEIGHT   = "PWA: Central Pressure at T1-Dp (mmHg)"
  C_T1R     = "PWA: Time of Start of the Reflected Wave (ms)"
  C_SP      = "PWA: Central Systolic Pressure (mmHg)"
  C_DP      = "PWA: Central Diastolic Pressure (mmHg)"
  C_MEANP     = "PWA: Central Mean Pressure (mmHg)"
  pwadate     = "PWA: Date and Time of Measure ((day/month/year) time)"
  pwanamecode   = "PWA: Patient's Namecode"
  pwagender     = "PWA: Patient's Gender (Male=1)"
  artery      = "PWA: Artery Used for Measure"
  conclusive    = "PWA: Inconclusive Study"
  ;

  format
  pwagender genderf.
  artery  arteryf.
  conclusive yesnof.
  quality_ed P_QUALITY_T1 P_QUALITY_T2 ejdurf.
  ;
run;

*** Drop step unneccessary? ;

****************************************************************************************;
* Drop Data Check Variables;
****************************************************************************************;
  data pwa_merge1;
    set pwa_merge;

    drop pwaq_date techid pwanurse gender -- Patient_Number pwanamecode pwagender inqc indata;
  run;

*******************************************************************************************;
* SAVE PERMANENT DATASETS
*******************************************************************************************;
  data sass.PWAMerge sass2.PWAMerge_&date6;
    set pwa_merge1;
  run;

  data sass.PWAMergeAbbr sass2.PWAMergeAbbr_&date6;
    set pwa_abbrmeans;
  run;
*/
