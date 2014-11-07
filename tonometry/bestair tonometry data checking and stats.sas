****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";

****************************************************************************************;
* FILE TO RUN AS PART OF "IMPORT BESTAIR TONOMETRY.SAS"; * IF NOT, UNCOMMENT THIS SECTION;
****************************************************************************************;
/*%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\redcap\_components\create rand set.sas";*/
/**/
/*data redcap;*/
/*  set redcap_rand;*/
/*run;*/
/**/
/*%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\tonometry\import bestair tonometry for update and check outcome variables.sas";*/

***************************************************************************************;
* DATA CHECKING - CHECK DATA IN SPHYGMACOR FILES ON RFA AGAINST QC FORMS IN REDCAP
***************************************************************************************;

  data tonom_fixed;
    set tonom_in;

    rename elig_studyid = studyid;

    array qctonom_numeric[*] _numeric_;
    array qctonom_character[*] _character_;

    do i = 1 to dim(qctonom_numeric);
      if qctonom_numeric[i] < 0 then qctonom_numeric[i] = .;
    end;

    do j = 1 to dim(qctonom_character);
      if qctonom_character[j] in ("-8", "-9") then qctonom_character[j] = "";
    end;

    drop redcap_event_name i j tonometry_qc_complete;
  run;

******;
* PWV
******;

  *create dataset of desired variables from sphygmacor observations to use for data checking;
  data pwv_sphyg_var;
    set batonometry;

    if find(lowcase(folder),'pwv.txt') > 0;

    *create variable to check against dates of measurements;
    day = scan (datetime,1,'/ ');
    month = scan (datetime,2,'/ ');
    year = scan (datetime,3,'/ ');
    format sphyg_date YYMMDD10.;

    sphyg_date = mdy(input(month,5.),input(day,5.),input(year,5.));

    keep studyid timepoint sphyg_date px_dist dt_dist pwv pwverr ptt_sd;

  run;

  proc sort data = pwv_sphyg_var;
    by studyid timepoint;
  run;

  *create dataset where each visit is its own observation with multiple pwv measurements;
  proc transpose data=pwv_sphyg_var out=pwv_sphyg_pwv prefix=sphyg_pwv;
    var pwv;
    by studyid timepoint;
  run;

  *create dataset where each visit is its own observation with multiple standard deviation measurements;
  proc transpose data=pwv_sphyg_var out=pwv_sphyg_std prefix=sphyg_stdpct;
    var ptt_sd;
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
    drop sphyg_date2--sphyg_date5 _NAME_ _LABEL_;
  run;

  *merge sphygmacor data with redcap data, keeping key variables;
  data pwv_check;
    merge pwv_sphyg_byvisit (in = a) tonom_fixed (in = b);
    by studyid timepoint;

    if a;

    keep studyid timepoint qctonom_visitdate sphyg_date sphyg_pwv1--sphyg_stdpct4 qctonom_pwv1-qctonom_pwv4 qctonom_standarddeviation1-qctonom_standarddeviation4;

  run;

  *ods pdf file = "J:\Data\SAS\tonometry\Tonometry Values with Discrepancy &sasfiledate.pdf";
  proc sql;
    title 'PWV Sphygmacor Date does not match REDCap Date - Re-export';
      select studyid, timepoint from pwv_check where qctonom_visitdate ne sphyg_date;
    title;
  quit;

  *create 2 datasets, one where sphygmacor pwv and redcap pwv match, one where they do not match;
  data pwv_match pwv_nomatch;
    set pwv_check;

    if (sphyg_pwv1 = qctonom_pwv1 and sphyg_pwv2 = qctonom_pwv2 and sphyg_pwv3 = qctonom_pwv3 and sphyg_pwv4 = qctonom_pwv4)
      then output pwv_match;

    *allow for rounding of 0.1 - QC display on Sphygmacor and raw data exports appear to use different rounding algorithms;
    else if (abs(sphyg_pwv1 - qctonom_pwv1) le 0.1 and abs(sphyg_pwv2 - qctonom_pwv2) le 0.1 and abs(sphyg_pwv3 - qctonom_pwv3) le 0.1 and abs(sphyg_pwv4 - qctonom_pwv4) le 0.1)
      then output pwv_match;

    else output pwv_nomatch;

  run;

  *create dataset that flags which pwv variables do not match;
  data prep_pwv_nomatch;
    set pwv_nomatch;

    array sphyg_pwv [4] sphyg_pwv1 sphyg_pwv2 sphyg_pwv3 sphyg_pwv4;
    array form_pwv [4] qctonom_pwv1 qctonom_pwv2 qctonom_pwv3 qctonom_pwv4;
    array pwv_mismatch [4] pwv_mismatch1 pwv_mismatch2 pwv_mismatch3 pwv_mismatch4;

    do i = 1 to 4;
      if sphyg_pwv[i] ne form_pwv[i] then pwv_mismatch[i] = i;
      else if sphyg_pwv[i] = form_pwv[i] then pwv_mismatch[i] = .;
    end;
    drop i;
  run;

  *print files where PWV observations do not match. include indication of which variables misalign;
  proc sql;
    title 'Specific PWV Observations that do not Match between Sphygmacor and RedCap';
    select studyid, timepoint, sphyg_pwv1, sphyg_pwv2, sphyg_pwv3, sphyg_pwv4, qctonom_pwv1, qctonom_pwv2, qctonom_pwv3, qctonom_pwv4, pwv_mismatch1, pwv_mismatch2, pwv_mismatch3, pwv_mismatch4
      from prep_pwv_nomatch;
    title;
  quit;

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

  *create dataset that flags which std deviation variables do not match;
  data prep_stdpct_nomatch;
    set stdpct_nomatch;

    array sphyg_pct [4] sphyg_stdpct1 sphyg_stdpct2 sphyg_stdpct3 sphyg_stdpct4;
    array form_pct [4] qctonom_standarddeviation1 qctonom_standarddeviation2 qctonom_standarddeviation3 qctonom_standarddeviation4;
    array pct_mismatch [4] pct_mismatch1 pct_mismatch2 pct_mismatch3 pct_mismatch4;

    do i = 1 to 4;
      if sphyg_pct[i] ne form_pct[i] then pct_mismatch[i] = i;
      else if sphyg_pct[i] = form_pct[i] then pct_mismatch[i] = .;
    end;
    drop i;
  run;

  *print files where std deviations were never entered from the tonometry form;
  proc sql;
    title 'Standard Deviations Never Entered from Tonometry Form';
    select studyid, timepoint, sphyg_stdpct1, sphyg_stdpct2, sphyg_stdpct3, sphyg_stdpct4, qctonom_standarddeviation1, qctonom_standarddeviation2, qctonom_standarddeviation3, qctonom_standarddeviation4
      from stdpct_neverentered;
    title;
  quit;

  *print files where std dev observations do not match. include indication of which variables misalign;
  proc sql;
    title 'Specific Standard Deviation (%) Observations that do not Match between Sphygmacor and RedCap';
    select studyid, timepoint, sphyg_stdpct1, sphyg_stdpct2, sphyg_stdpct3, sphyg_stdpct4, qctonom_standarddeviation1, qctonom_standarddeviation2, qctonom_standarddeviation3,
      qctonom_standarddeviation4, pct_mismatch1, pct_mismatch2, pct_mismatch3, pct_mismatch4
      from prep_stdpct_nomatch;
    title;
  quit;

******;
* PWA
******;

  *create dataset of desired variables from sphygmacor observations to use for data checking;
  data pwa_sphyg_var;
    set batonometry;

    if find(lowcase(folder),'pwa.txt') > 0;

    *create variable to check against dates of measurements;
    day = scan (datetime,1,'/ ');
    month = scan (datetime,2,'/ ');
    year = scan (datetime,3,'/ ');
    format sphyg_date YYMMDD10.;

    sphyg_date = mdy(input(month,5.),input(day,5.),input(year,5.));
    keep studyid timepoint sphyg_date operator_index c_ap c_agph;

  run;

  proc sort data = pwa_sphyg_var;
    by studyid timepoint;
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

  *merge datasets for above sphygmacor measurements for data checking;
  data pwa_sphyg_byvisit;
    merge pwa_sphyg_operix pwa_sphyg_augix pwa_sphyg_augpress pwa_sphyg_dates;
    by studyid timepoint;

    rename sphyg_date1=sphyg_date;
    drop sphyg_date2--sphyg_date5 _NAME_;
  run;

  *merge sphygmacor data with redcap data, keeping key variables;
  data pwa_check (rename = (qctonom_augpressa1=qctonom_augpress1 qctonom_augpressa2=qctonom_augpress2 qctonom_augpressa3=qctonom_augpress3 qctonom_augpressa4=qctonom_augpress4));
    merge pwa_sphyg_byvisit (in = a) tonom_fixed (in = b);
    by studyid timepoint;
    if a;

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

  *create dataset that flags which operator index variables do not match;
  data prep_operix_nomatch;
    set operix_nomatch;

    array sphyg_operix [4] sphyg_operix1 sphyg_operix2 sphyg_operix3 sphyg_operix4;
    array form_operix [4] qctonom_specifyoi1 qctonom_specifyoi2 qctonom_specifyoi3 qctonom_specifyoi4;
    array operix_mismatch [4] operix_mismatch1 operix_mismatch2 operix_mismatch3 operix_mismatch4;

    do i = 1 to 4;
      if sphyg_operix[i] ne form_operix[i] then operix_mismatch[i] = i;
      else if sphyg_operix[i] = form_operix[i] then operix_mismatch[i] = .;
    end;
    drop i;
  run;

  *print files where operator index values do not match. include indication of which variables misalign;
  proc sql;
    title 'Specific Operator Index Variables that do not Match between Sphygmacor and RedCap';
    select studyid, timepoint, sphyg_operix1, sphyg_operix2, sphyg_operix3, sphyg_operix4, qctonom_specifyoi1, qctonom_specifyoi2, qctonom_specifyoi3,
      qctonom_specifyoi4, operix_mismatch1, operix_mismatch2, operix_mismatch3, operix_mismatch4
      from prep_operix_nomatch;
    title;
  quit;

  *create 2 datasets, one where sphygmacor augmentation index and redcap augmentation index match, one where they do not match;
  data augix_match augix_nomatch;
    set pwa_check;

    if (sphyg_augix1 = qctonom_augix1 and sphyg_augix2 = qctonom_augix2 and
        sphyg_augix3 = qctonom_augix3 and sphyg_augix4 = qctonom_augix4)
      then output augix_match;
    else output augix_nomatch;

  run;

  *create dataset that flags which augmentation index variables do not match;
  data prep_augix_nomatch;
    set augix_nomatch;

    array sphyg_augix [4] sphyg_augix1 sphyg_augix2 sphyg_augix3 sphyg_augix4;
    array form_augix [4] qctonom_augix1 qctonom_augix2 qctonom_augix3 qctonom_augix4;
    array augix_mismatch [4] augix_mismatch1 augix_mismatch2 augix_mismatch3 augix_mismatch4;

    do i = 1 to 4;
      if sphyg_augix[i] ne form_augix[i] then augix_mismatch[i] = i;
      else if sphyg_augix[i] = form_augix[i] then augix_mismatch[i] = .;
    end;
    drop i;
  run;

  *print files where augmentation index values do not match. include indication of which variables misalign;
  proc sql;
    title 'Specific Augmentation Index Variables that do not Match between Sphygmacor and RedCap';
    select studyid, timepoint, sphyg_augix1, sphyg_augix2, sphyg_augix3, sphyg_augix4, qctonom_augix1, qctonom_augix2, qctonom_augix3, qctonom_augix4, augix_mismatch1,
            augix_mismatch2, augix_mismatch3, augix_mismatch4
      from prep_augix_nomatch;
    title;
  quit;

  *create 2 datasets, one where sphygmacor augmentation pressure and redcap augmentation pressure match, one where they do not match;
  data augpress_match augpress_nomatch;
    set pwa_check;

    if (sphyg_augpress1 = qctonom_augpress1 and sphyg_augpress2 = qctonom_augpress2 and
        sphyg_augpress3 = qctonom_augpress3 and sphyg_augpress4 = qctonom_augpress4)
      then output augpress_match;
    else output augpress_nomatch;

  run;

  *create dataset that flags which augmentation index variables do not match;
  data prep_augpress_nomatch;
    set augpress_nomatch;

    array sphyg_augpre [4] sphyg_augpress1 sphyg_augpress2 sphyg_augpress3 sphyg_augpress4;
    array form_augpre [4] qctonom_augpress1 qctonom_augpress2 qctonom_augpress3 qctonom_augpress4;
    array augpre_mismatch [4] augpress_mismatch1 augpress_mismatch2 augpress_mismatch3 augpress_mismatch4;

    do i = 1 to 4;
      if sphyg_augpre[i] ne form_augpre[i] then augpre_mismatch[i] = i;
      else if sphyg_augpre[i] = form_augpre[i] then augpre_mismatch[i] = .;
    end;
    drop i;
  run;

  *print files where augmentation pressure values do not match. include indication of which variables misalign;
  proc sql;
    title 'Specific Augmentation Pressure Variables that do not Match between Sphygmacor and RedCap';
    select studyid, timepoint, sphyg_augpress1 label = "Sphyg AugPress1", sphyg_augpress2 label = "Sphyg AugPress2", sphyg_augpress3 label = "Sphyg AugPress3",
            sphyg_augpress4 label = "Sphyg AugPress4", qctonom_augpress1 label = "Form AugPress1", qctonom_augpress2 label = "Form AugPress2",
            qctonom_augpress3 label = "Form AugPress3", qctonom_augpress4 label = "Form AugPress4", augpress_mismatch1, augpress_mismatch2, augpress_mismatch3, augpress_mismatch4
      from prep_augpress_nomatch;
    title;
  quit;


  proc sql;
    title 'PWA Sphygmacor Date does not match REDCap Date - Re-export';
      select studyid, timepoint from pwa_check where qctonom_visitdate ne sphyg_date;
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

  *ods pdf close;

***************************************************************************************;
* EXPORT PERMANENT DATASETS
***************************************************************************************;
  data Pwv_sphyg_byvisit2;
    retain studyid timepoint sphyg_date;
    format avgpwv_qcadjusted avgpwv_allmeasures best12.;
    set Pwv_sphyg_byvisit;
    avgpwv_allmeasures = MEAN(of sphyg_pwv1-sphyg_pwv5);

    array pwv_values[*] sphyg_pwv1-sphyg_pwv5;
    array stdpct_values[*] sphyg_stdpct1-sphyg_stdpct5;

    do i = 1 to 5;
      if stdpct_values[i] le 15 and stdpct_values[i] ne . then do;
        totalpwv = sum(totalpwv, pwv_values[i]);
        pwvcount = sum(pwvcount, 1);
      end;
    end;

    avgpwv_qcadjusted = totalpwv/pwvcount;

    drop i totalpwv pwvcount;
  run;

  data Pwa_sphyg_byvisit2;
    retain studyid timepoint sphyg_date;
    format avgaugix_qcadjusted avgaugix_allmeasures avgaugpress_qcadjusted avgaugpress_allmeasures best12.;
    set Pwa_sphyg_byvisit;
    avgaugix_allmeasures = MEAN(of sphyg_augix1-sphyg_augix5);
    avgaugpress_allmeasures = MEAN(of sphyg_augpress1-sphyg_augpress5);

    array augix_values[*] sphyg_augix1-sphyg_augix5;
    array augpress_values[*] sphyg_augpress1-sphyg_augpress5;
    array operix_values[*] sphyg_operix1-sphyg_operix5;

    do i = 1 to 5;
      if operix_values[i] ge 80 and operix_values[i] ne . then do;
        totalaugix = sum(totalaugix, augix_values[i]);
        totalaugpress = sum(totalaugpress, augpress_values[i]);
        pwacount = sum(pwacount, 1);
      end;
    end;

    avgaugix_qcadjusted = totalaugix/pwacount;
    avgaugpress_qcadjusted = totalaugpress/pwacount;


    drop i totalaugix totalaugpress pwacount;
  run;

  data tonom_final (drop = sphyg_datepwa _LABEL_);
    merge Tonom_fixed Pwv_sphyg_byvisit2 Pwa_sphyg_byvisit2 (rename = (sphyg_date = sphyg_datepwa));
    by studyid timepoint;
    if sphyg_date = . then sphyg_date = sphyg_datepwa;
  run;

  data tonom_final;
    set tonom_final;

    label
    sphyg_date = "Sphygmacor Date"
    avgpwv_qcadjusted = "PWV: Average Pulse Wave Velocity (SD < 10%)"
    avgpwv_allmeasures = "PWV: Average Pulse Wave Velocity (All Measures)"
    sphyg_pwv1 = "PWV: Sphygmacor Pulse Wave Velocity #1"
    sphyg_pwv2 = "PWV: Sphygmacor Pulse Wave Velocity #2"
    sphyg_pwv3 = "PWV: Sphygmacor Pulse Wave Velocity #3"
    sphyg_pwv4 = "PWV: Sphygmacor Pulse Wave Velocity #4"
    sphyg_pwv5 = "PWV: Sphygmacor Pulse Wave Velocity #5"
    sphyg_stdpct1 = "PWV: Sphygmacor Standard Deviation of PWV (%) #1"
    sphyg_stdpct2 = "PWV: Sphygmacor Standard Deviation of PWV (%) #2"
    sphyg_stdpct3 = "PWV: Sphygmacor Standard Deviation of PWV (%) #3"
    sphyg_stdpct4 = "PWV: Sphygmacor Standard Deviation of PWV (%) #4"
    sphyg_stdpct5 = "PWV: Sphygmacor Standard Deviation of PWV (%) #5"
    avgaugix_qcadjusted = "PWA: Average Augmentation Index (Operator Index >= 80)"
    avgaugix_allmeasures = "PWA: Average Augmentation Index (All Measures)"
    avgaugpress_qcadjusted = "PWA: Average Augmentation Pressure (Operator Index >= 80)"
    avgaugpress_allmeasures = "PWA: Average Augmentation Pressure (All Measures)"
    sphyg_operix1 = "PWA: Sphygmacor Operator Index #1"
    sphyg_operix2 = "PWA: Sphygmacor Operator Index #2"
    sphyg_operix3 = "PWA: Sphygmacor Operator Index #3"
    sphyg_operix4 = "PWA: Sphygmacor Operator Index #4"
    sphyg_operix5 = "PWA: Sphygmacor Operator Index #5"
    sphyg_augix1 = "PWA: Sphygmacor Augmentation Index #1"
    sphyg_augix2 = "PWA: Sphygmacor Augmentation Index #2"
    sphyg_augix3 = "PWA: Sphygmacor Augmentation Index #3"
    sphyg_augix4 = "PWA: Sphygmacor Augmentation Index #4"
    sphyg_augix5 = "PWA: Sphygmacor Augmentation Index #5"
    sphyg_augpress1 = "PWA: Sphygmacor Augmentation Pressure #1"
    sphyg_augpress2 = "PWA: Sphygmacor Augmentation Pressure #2"
    sphyg_augpress3 = "PWA: Sphygmacor Augmentation Pressure #3"
    sphyg_augpress4 = "PWA: Sphygmacor Augmentation Pressure #4"
    sphyg_augpress5 = "PWA: Sphygmacor Augmentation Pressure #5"
    ;

    drop timepoint;
  run;

/*  proc freq data = tonom_final;*/
/*    table avgpwv_qcadjusted;*/
/*    table avgpwv_allmeasures;*/
/*    table avgaugix_qcadjusted;*/
/*    table avgaugix_allmeasures;*/
/*  run;*/

  data bestair.bestairtonometry_all bestair2.bestairtonometry_all_&sasfiledate;
    set tonom_final;
  run;
/*
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
  proc means data = pwa noprint;
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
  proc means data = pwv noprint;
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

  proc univariate data = Pwv_sphyg_var noprint;
    var pwv;
    histogram pwv;
    inset mean max min;
  run;

  proc univariate data = Pwa_sphyg_var noprint;
    var c_ap;
    histogram c_ap;
    inset mean max min / position = n;
  run;

  *REDCap histograms;

  *PWA Augmentation Pressure;
  data  qctonomaugpress1 (rename = (qctonom_augpress1=qctonom_augpress))
        qctonomaugpress2 (rename = (qctonom_augpress2=qctonom_augpress))
        qctonomaugpress3 (rename = (qctonom_augpress3=qctonom_augpress))
        qctonomaugpress4 (rename = (qctonom_augpress4=qctonom_augpress));
    set pwa_check;
  run;

  data qctonomaugpress_all;
    set qctonomaugpress1 qctonomaugpress2 qctonomaugpress3 qctonomaugpress4;
    if qctonom_augpress ne .;
    keep studyid timepoint qctonom_augpress;
  run;

  proc sort data = qctonomaugpress_all;
    by studyid timepoint;
  run;

  *PWA Augmentation Index;
  data  qctonomaugix1 (rename = (qctonom_augix1=qctonom_augix))
        qctonomaugix2 (rename = (qctonom_augix2=qctonom_augix))
        qctonomaugix3 (rename = (qctonom_augix3=qctonom_augix))
        qctonomaugix4 (rename = (qctonom_augix4=qctonom_augix));
    set pwa_check;
  run;

  data qctonomaugix_all;
    set qctonomaugix1 qctonomaugix2 qctonomaugix3 qctonomaugix4;
    if qctonom_augix ne .;
    keep studyid timepoint qctonom_augix;
  run;

  proc sort data = qctonomaugix_all;
    by studyid timepoint;
  run;

  *Pulse Wave Velocity;
  data  qctonompwv1 (rename = (qctonom_pwv1=qctonom_pwv))
        qctonompwv2 (rename = (qctonom_pwv2=qctonom_pwv))
        qctonompwv3 (rename = (qctonom_pwv3=qctonom_pwv))
        qctonompwv4 (rename = (qctonom_pwv4=qctonom_pwv));
    set pwv_check;
  run;

  data qctonompwv_all;
    set qctonompwv1 qctonompwv2 qctonompwv3 qctonompwv4;
    if qctonom_pwv ne .;
    keep studyid timepoint qctonom_pwv;
  run;

  proc sort data = qctonompwv_all;
    by studyid timepoint;
  run;


  proc univariate data = qctonomaugpress_all noprint;
    var qctonom_augpress;
    histogram qctonom_augpress;
    inset mean max min / position =  ne;
  run;

  proc univariate data = qctonomaugix_all noprint;
    var qctonom_augix;
    histogram qctonom_augix;
    inset mean max min;
  run;

  proc univariate data = qctonompwv_all noprint;
    var qctonom_pwv;
    histogram qctonom_pwv;
    inset mean max min / position =  ne;
  run;
