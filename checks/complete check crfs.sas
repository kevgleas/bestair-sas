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
  run;


  *import pending visit list to exclude pending visits from expected data;
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

  data crfs;
    set redcap;

    if redcap_event_name = "00_bv_arm_1" or redcap_event_name = "06_fu_arm_1" or redcap_event_name = "12_fu_arm_1";

    keep elig_studyid redcap_event_name anth_studyid--bloods_urinecreatin qctonom_studyid--monitorqc_percentsuccess;

    drop anth_namecode anth_studyvisit--anth_staffid anthropometry_complete bprp_namecode--bprp_staffid blood_pressure_and_r_v_0 bloods_namecode--bloods_studyvisit
        qctonom_namecode--qctonom_staffid tonometry_qc_complete monitorqc_namecode--monitorqc_datauploadreas;
    run;

  data crfs2;
    retain elig_studyid timepoint;
    set crfs;

    if redcap_event_name = "00_bv_arm_1" then timepoint = 00; else
    if redcap_event_name = "06_fu_arm_1" then timepoint = 06; else
    if redcap_event_name = "12_fu_arm_1" then timepoint = 12;
    else timepoint = .;

    drop redcap_event_name;

  run;

  *exclude participants who have 12-month timepoint erroneously listed in REDCap and add visits for dropouts;
  *(because study completion form was originalyy created to be completed after 12-month timepoint,
  12-month timepoint is auto-created in REDCap when participant completes study, even if only intended to be enrolled for 6-months);

  data crfs2;
    merge all_expected_visits (in = a) crfs2 (in = b);
    by elig_studyid timepoint;
    if a;
  run;

  *exclude pending visits from calculation (6-month visit timepoint is created in REDCap at time of 6-month phone call);
/*  data crfs2;*/
/*    merge crfs2 (in = a) pending_visits (in = b keep = elig_studyid timepoint);*/
/*    by elig_studyid timepoint;*/
/*    if not b;*/
/*  run;*/

****************************************************************************************;
* IMPORT AND PROCESS RAW FILES FROM RFA SERVER
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\24hrbp\import BestAIR 24hr BP and compare to REDCap.sas";
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\tonometry\import bestair tonometry.sas";

****************************************************************************************;
* CALCULATE NUMBER OF VISITS BY TYPE TO BE USED AS DENOMINATOR IN COMPLETENESS % CHECKS
****************************************************************************************;

  data bp4check (keep = elig_studyid timepoint nvalid pctvalid nreadings nwake nsleep);
    set mergebp;

    rename studyid = elig_studyid;
  run;

  data tonom4check (keep = elig_studyid timepoint sphyg_pwv1 sphyg_augix1);
    set all_tonom;
    rename studyid = elig_studyid;
  run;

  proc sort data = bp4check nodupkey;
    by elig_studyid timepoint;
  run;

  proc sort data = tonom4check nodupkey;
    by elig_studyid timepoint;
  run;

  proc sort data = crfs2 nodupkey;
    by elig_studyid timepoint;
  run;

  data crfs_withbptonom;
    merge crfs2 bp4check tonom4check;
    by elig_studyid timepoint;
  run;

  data visit_counts;
    set crfs_withbptonom;

    format  bl_allcount bl_crfcount bl_bloodcount bl_bpcount bl_tonomcount
            mo6_allcount mo6_crfcount mo6_bloodcount mo6_bpcount mo6_tonomcount
            mo12_allcount mo12_crfcount mo12_bloodcount mo12_bpcount mo12_tonomcount
            final_allcount final_crfcount final_bloodcount final_bpcount final_tonomcount 3.;

    if timepoint = 00 then do;
        bl_allcount = 1;
        bl_bpcount = 1;
        bl_crfcount = 1;
        bl_bloodcount = 1;
        bl_tonomcount = 1;
    end;

    if timepoint = 06 then do;
        mo6_allcount = 1;
        mo6_bpcount = 1;
        mo6_crfcount = 1;
        if bloods_totalchol ne . or bloods_triglyc ne . or bloods_serumgluc ne . or (anth_date = . or (today() - anth_date) > 14) then mo6_bloodcount = 1;
        mo6_tonomcount = 1;
    end;

    if timepoint = 12 then do;
        mo12_allcount = 1;
        mo12_crfcount = 1;
        mo12_bpcount = 1;
        if bloods_totalchol ne . or bloods_triglyc ne . or bloods_serumgluc ne . or (anth_date = . or (today() - anth_date) > 14) then mo12_bloodcount = 1;
        mo12_tonomcount = 1;
    end;

    if is_final = 1 then do;
        final_allcount = 1;
        final_bpcount = 1;
        final_crfcount = 1;
        if bloods_totalchol ne . or bloods_triglyc ne . or bloods_serumgluc ne . or (anth_date = . or (today() - anth_date) > 14) then final_bloodcount = 1;
        final_tonomcount = 1;
    end;


*calculates bpcount based on non-pending data: hasbp + knownmissing + neverhadvisit + visitdate_earlier_than_oldestpending;
* as of 11/21/13, oldest pending is 12-month data for 73250 whose visit date was 09/09/13 (SAS_DATE = 19610);
    *as of 3/07/14, only 74404 6-month data is pending - assume it's collected;

/*    if nreadings ne . or monitorqc_studyid = -9 or*/
/*        (anth_studyid in(.,-9) and bprp_studyid in(.,-9) and bloods_studyid in(.,-9) and sphyg_pwv1 in(.,-9) and sphyg_augix1 in(.,-9)) or*/
/*        anth_date < 19610*/
/*      then do;*/
/*        if timepoint = 00 then bl_bpcount = 1;*/
/*        if timepoint = 06 then mo6_bpcount = 1;*/
/*        if timepoint = 12 then mo12_bpcount = 1;*/
/*        if is_final = 1 then final_bpcount = 1;*/
/*      end;*/


    keep elig_studyid timepoint bl_allcount--final_tonomcount;

  run;


  proc means noprint data = visit_counts;
    output out = visit_countsums sum(bl_allcount) = bl_allcount sum(mo6_allcount) = mo6_allcount sum(mo12_allcount) = mo12_allcount sum(final_allcount) = final_allcount
                    sum(bl_crfcount) = bl_crfcount sum(mo6_crfcount) = mo6_crfcount sum(mo12_crfcount) = mo12_crfcount sum(final_crfcount) = final_crfcount
                    sum(bl_bloodcount) = bl_bloodcount sum(mo6_bloodcount) = mo6_bloodcount sum(mo12_bloodcount) = mo12_bloodcount sum(final_bloodcount) = final_bloodcount
                    sum(bl_bpcount) = bl_bpcount sum(mo6_bpcount) = mo6_bpcount sum(mo12_bpcount) = mo12_bpcount sum(final_bpcount) = final_bpcount
                    sum(bl_tonomcount) = bl_tonomcount sum(mo6_tonomcount) = mo6_tonomcount sum(mo12_tonomcount) = mo12_tonomcount sum(final_tonomcount) = final_tonomcount;

  run;


  data bl_countsums (keep = timepoint visit_type allcount crfcount bloodcount bpcount tonomcount);
    retain visit_type timepoint;
    set visit_countsums;

    rename bl_allcount = allcount;
    rename bl_crfcount = crfcount;
    rename bl_bloodcount = bloodcount;
    rename bl_bpcount = bpcount;
    rename bl_tonomcount = tonomcount;

    timepoint = 00;
    visit_type = "Baseline";

  run;

  data mo6_countsums (keep = timepoint visit_type allcount crfcount bloodcount bpcount tonomcount);
    retain visit_type timepoint;
    set visit_countsums;

    rename mo6_allcount = allcount;
    rename mo6_crfcount = crfcount;
    rename mo6_bloodcount = bloodcount;
    rename mo6_bpcount = bpcount;
    rename mo6_tonomcount = tonomcount;

    timepoint = 06;
    visit_type = "6 Month";

  run;

  data mo12_countsums (keep = timepoint visit_type allcount crfcount bloodcount bpcount tonomcount);
    retain visit_type timepoint;
    set visit_countsums;

    rename mo12_allcount = allcount;
    rename mo12_crfcount = crfcount;
    rename mo12_bloodcount = bloodcount;
    rename mo12_bpcount = bpcount;
    rename mo12_tonomcount = tonomcount;

    timepoint = 12;
    visit_type = "12 Month";

  run;

  data final_countsums (keep = timepoint visit_type allcount crfcount bloodcount bpcount tonomcount);
    retain visit_type timepoint;
    set visit_countsums;

    rename final_allcount = allcount;
    rename final_crfcount = crfcount;
    rename final_bloodcount = bloodcount;
    rename final_bpcount = bpcount;
    rename final_tonomcount = tonomcount;

    timepoint = 99;
    visit_type = "Combined Final";

  run;

  data countsums_byvisit;
    format visit_type $20.;
    merge bl_countsums mo6_countsums mo12_countsums final_countsums;
    by timepoint;
  run;

  data crfs_resolved bp_resolved blood_resolved tonom_resolved;
    set crfs_withbptonom (drop = anth_date);
  run;

****************************************************************************************;
* CREATE DATASETS OF COMPLETENESS TABLES
****************************************************************************************;

*Calculate Completeness of 24-hour Ambulatory Blood Pressure;

  data bp_completeness;
    set bp_resolved;

    comp_bp = .;
    part_bp = .;
    miss_bp = .;

    *assuming pending participants completes BP;
    if elig_studyid = 74404 and timepoint = 6 then do;
            comp_bp = 1;
            part_bp = 1;
            miss_bp = 0;
    end;

    else if nsleep ge 4 and nwake ge 10 then
            do
            comp_bp = 1;
            part_bp = 1;
            miss_bp = 0;
            end;

    else if nsleep ge 1 or nwake ge 1 then
            do
            comp_bp = 0;
            part_bp = 1;
            miss_bp = 0;
            end;

    else
            do
            comp_bp = 0;
            part_bp = 0;
            miss_bp = 1;
            end;

  run;
*new section;
  data bp_completenesspartial (keep = elig_studyid timepoint monitorqc_20hrs--monitorqc_percentsuccess nreadings nvalid pctvalid nwake nsleep both_sleepwake);
    set bp_completeness;

    if comp_bp = 0 and part_bp = 1;

    if (nsleep ge 1 and nwake ge 1) then both_sleepwake = 1;
    else both_sleepwake = 0;

  run;

  proc sort data = bp_completenesspartial;
    by timepoint nsleep nwake;
  run;

  data bp_howcomplete (keep = elig_studyid timepoint monitorqc_20hrs--monitorqc_percentsuccess nreadings nvalid pctvalid nwake nsleep);
    set bp_completeness;
  run;


  data bp_comp00 bp_comp06 bp_comp12 bp_compfinalv;
    set bp_completeness;
    if timepoint = 0 then output bp_comp00;
    if timepoint = 6 then output bp_comp06;
    if timepoint = 12 then output bp_comp12;
    if is_final = 1 then output bp_compfinalv;
  run;


  proc means noprint data = bp_comp00;
    output out = bp_compstats00 sum(comp_bp) = comp_bp sum(part_bp) = part_bp sum(miss_bp) = miss_bp;
  run;

  data bp_compstats00 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set bp_compstats00;

    timepoint = 00;
    visit_type = "Baseline";

  run;


  proc means noprint data = bp_comp06;
    output out = bp_compstats06 sum(comp_bp) = comp_bp sum(part_bp) = part_bp sum(miss_bp) = miss_bp;
  run;

  data bp_compstats06 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set bp_compstats06;

    timepoint = 06;
    visit_type = "6 Month";

  run;

  proc means noprint data = bp_comp12;
    output out = bp_compstats12 sum(comp_bp) = comp_bp sum(part_bp) = part_bp sum(miss_bp) = miss_bp;
  run;

  data bp_compstats12 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set bp_compstats12;

    timepoint = 12;
    visit_type = "12 Month";

  run;



  proc means noprint data = bp_compfinalv;
    output out = bp_compstatsfinalv sum(comp_bp) = comp_bp sum(part_bp) = part_bp sum(miss_bp) = miss_bp;
  run;

  data bp_compstatsfinalv (drop = _type_ _freq_);
    retain visit_type timepoint;
    set bp_compstatsfinalv;

    timepoint = 99;
    visit_type = "Combined Final";

  run;


  data bp_compstats;
    format visit_type $20.;
    merge bp_compstats00 bp_compstats06 bp_compstats12 bp_compstatsfinalv;
    by timepoint;
  run;

  data bp_compstatsall (drop = bloodcount crfcount tonomcount);
    merge bp_compstats countsums_byvisit;
    by timepoint;
  run;


  data bp_compstatsfinal;
    set bp_compstatsall;

    format pctcomp_bpall pctpart_bpall pctmiss_bpall pctcomp_bpresolved pctpart_bpresolved pctmiss_bpresolved percent10.1;


    pctcomp_bpall = comp_bp/allcount;
    pctpart_bpall = part_bp/allcount;
    pctmiss_bpall = miss_bp/allcount;

    pctcomp_bpresolved = comp_bp/bpcount;
    pctpart_bpresolved = part_bp/bpcount;
    pctmiss_bpresolved = miss_bp/bpcount;

  run;


*Calculate Completeness of Lab Data;

  data bloodurine_allresolved;
    set crfs_resolved;

    nmiss_blood = 0;
    nmiss_urine = 0;

    array checkblood[*] bloods_totalchol--bloods_serumgluc;

    do i=1 to dim(checkblood);
      if checkblood[i] < 0 or checkblood[i] = . then nmiss_blood = nmiss_blood + 1;
    end;

    array checkurine[*] bloods_fibrinactivity--bloods_urinecreatin;

    do i=1 to dim(checkurine);
      if checkurine[i] < 0 or checkurine[i] = . then nmiss_urine = nmiss_urine + 1;
    end;

    drop anth_studyid--bprp_rp3 qctonom_studyid--monitorqc_4readingsnight i;

  run;

  data blood_comp00 blood_comp06 blood_comp12 blood_compfinalv;
    set bloodurine_allresolved;
    keep elig_studyid--bloods_urinecreatin nmiss_blood--pctmiss_urine;

    ncomp_blood = 9 - nmiss_blood;
    ncomp_urine = 2 - nmiss_urine;

    format pctcomp_blood pctcomp_urine pctmiss_blood pctmiss_urine percent10.1;

    pctcomp_blood = ((9-nmiss_blood)/9);
    pctcomp_urine = ((2-nmiss_urine)/2);
    pctmiss_blood = (nmiss_blood/9);
    pctmiss_urine = (nmiss_urine/2);


    if timepoint = 00 then output blood_comp00;
    if timepoint = 06 then output blood_comp06;
    if timepoint = 12 then output blood_comp12;
    if is_final = 1 then output blood_compfinalv;


  run;


  proc means noprint data = blood_comp00;
    output out = blood_compstats00 sum(ncomp_blood) = ncomp_blood sum(ncomp_urine) = ncomp_urine sum(nmiss_blood) = nmiss_blood sum(nmiss_urine) = nmiss_urine;
  run;

  data blood_compstats00 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set blood_compstats00;

    visit_type = "Baseline";
    timepoint= 00;

  run;

  proc means noprint data = blood_comp06;
    output out = blood_compstats06 sum(ncomp_blood) = ncomp_blood sum(ncomp_urine) = ncomp_urine sum(nmiss_blood) = nmiss_blood sum(nmiss_urine) = nmiss_urine;
  run;

  data blood_compstats06 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set blood_compstats06;

    visit_type = "6 Month";
    timepoint= 06;

  run;

  proc means noprint data = blood_comp12;
    output out = blood_compstats12 sum(ncomp_blood) = ncomp_blood sum(ncomp_urine) = ncomp_urine sum(nmiss_blood) = nmiss_blood sum(nmiss_urine) = nmiss_urine;
  run;

  data blood_compstats12 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set blood_compstats12;

    visit_type = "12 Month";
    timepoint= 12;

  run;

  proc means noprint data = blood_compfinalv;
    output out = blood_compstatsfinalv sum(ncomp_blood) = ncomp_blood sum(ncomp_urine) = ncomp_urine sum(nmiss_blood) = nmiss_blood sum(nmiss_urine) = nmiss_urine;
  run;

  data blood_compstatsfinalv (drop = _type_ _freq_);
    retain visit_type timepoint;
    set blood_compstatsfinalv;

    visit_type = "Combined Final";
    timepoint= 99;

  run;

  data blood_compstats;
    format visit_type $20.;
    merge blood_compstats00 blood_compstats06 blood_compstats12 blood_compstatsfinalv;
    by timepoint;

  run;

  data blood_compstatsall (drop = bpcount crfcount tonomcount);
    merge blood_compstats countsums_byvisit;
    by timepoint;
  run;


  data blood_compstatsfinal;
    set blood_compstatsall;

    format pctcomp_bloodall pctcomp_urineall pctmiss_bloodall pctmiss_urineall pctcomp_bloodresolved pctcomp_urineresolved pctmiss_bloodresolved pctmiss_urineresolved percent10.1;


    pctcomp_bloodall = ncomp_blood/(9*allcount);
    pctcomp_urineall = ncomp_urine/(2*allcount);
    pctmiss_bloodall = nmiss_blood/(9*allcount);
    pctmiss_urineall = nmiss_urine/(2*allcount);

 *fix "crf count" so that it's only blood;
    pctcomp_bloodresolved = ncomp_blood/(9*bloodcount);
    pctcomp_urineresolved = ncomp_urine/(2*bloodcount);
    pctmiss_bloodresolved = nmiss_blood/(9*bloodcount);
    pctmiss_urineresolved = nmiss_urine/(2*bloodcount);

  run;


  proc sql;
    title "Missing Blood";
      select elig_studyid, timepoint from bloodurine_allresolved where nmiss_blood > 8;
    title;

    title "Missing Urine";
      select elig_studyid, timepoint from bloodurine_allresolved where nmiss_urine > 1;
    title;

  quit;

  data tonom_completeness;
    set tonom_resolved;

    pwa_comp = .;
    pwv_comp = .;

    if sphyg_pwv1 ne . and sphyg_augix1 ne . then
            do
            pwa_comp = 1;
            pwv_comp = 1;
            end;

    else if sphyg_pwv1 ne . then
            do
            pwa_comp = 0;
            pwv_comp = 1;
            end;

    else if sphyg_augix1 ne . then
            do
            pwa_comp = 1;
            pwv_comp = 0;
            end;

    else
            do
            pwa_comp = 0;
            pwv_comp = 0;
            end;

    drop anth_studyid--bloods_urinecreatin monitorqc_studyid--nwake;

  run;

  data tonom_comp00 tonom_comp06 tonom_comp12 tonom_compfinalv;
    set tonom_completeness;
    if timepoint = 0 then output tonom_comp00;
    if timepoint = 6 then output tonom_comp06;
    if timepoint = 12 then output tonom_comp12;
    if is_final = 1 then output tonom_compfinalv;
  run;

  proc means noprint data = tonom_comp00;
    output out = tonom_compstats00 sum(pwa_comp) = pwa_comp sum(pwv_comp) = pwv_comp;
  run;

  data tonom_compstats00 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set tonom_compstats00;

    timepoint = 00;
    visit_type = "Baseline";

  run;


  proc means noprint data = tonom_comp06;
    output out = tonom_compstats06 sum(pwa_comp) = pwa_comp sum(pwv_comp) = pwv_comp;
  run;

  data tonom_compstats06 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set tonom_compstats06;

    timepoint = 06;
    visit_type = "6 Month";

  run;

  proc means noprint data = tonom_comp12;
    output out = tonom_compstats12 sum(pwa_comp) = pwa_comp sum(pwv_comp) = pwv_comp;
  run;

  data tonom_compstats12 (drop = _type_ _freq_);
    retain visit_type timepoint;
    set tonom_compstats12;

    timepoint = 12;
    visit_type = "12 Month";

  run;

    proc means noprint data = tonom_compfinalv;
    output out = tonom_compstatsfinalv sum(pwa_comp) = pwa_comp sum(pwv_comp) = pwv_comp;
  run;

  data tonom_compfinalv (drop = _type_ _freq_);
    retain visit_type timepoint;
    set tonom_compstatsfinalv;

    timepoint = 99;
    visit_type = "Combined Final";

  run;


  data tonom_compstats;
    format visit_type $20.;
    merge tonom_compstats00 tonom_compstats06 tonom_compstats12 tonom_compfinalv;
    by timepoint;

  run;

  data tonom_compstatsall (drop = bloodcount bpcount crfcount);
    merge tonom_compstats countsums_byvisit;
    by timepoint;
  run;


  data tonom_compstatsfinal;
    set tonom_compstatsall;

    format pctcomp_pwaall pctcomp_pwvall pctcomp_pwaresolved pctcomp_pwvresolved percent10.1;


    pctcomp_pwaall = pwa_comp/allcount;
    pctcomp_pwvall = pwv_comp/allcount;

    pctcomp_pwaresolved = pwa_comp/tonomcount;
    pctcomp_pwvresolved = pwv_comp/tonomcount;

  run;


  *echo count manually calculated because of delay in processing;
  *last counted 3/07/2014;

  data ultrasound_compstatsfinal;
    set tonom_compstatsfinal;

    format pctcomp_echoresolved percent10.1;

    if timepoint = 0 then do;
      echo_comp = 155;  /*missing: 60678, 70245, 70335, 70337, 73088, 74068, 74404, 74567, 74721, 74756, 74772, 75063, 84319, 89191, 89565*/
      pctcomp_echoresolved = echo_comp / tonomcount;
      end;
    else if timepoint = 12 then do;
      echo_comp = 73;   /*missing: 73068, 73093, 73119, 80024, 82444, 84175, 91396*/ /*addtional follow-up echoes not counted for 73474 (9-month) and 87145 (6-month)*/
      pctcomp_echoresolved = echo_comp / tonomcount;
      end;

  run;
