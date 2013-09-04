****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT REDCAP DATA and PREPARE DATASETS
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\redcap\_components\bestair create rand set.sas";

  *rename dataset of randomized participants to match syntax in later include steps;
  data redcap;
    set redcap_rand;
  run;

  data var_4checking;
    set redcap;

    keep elig_studyid redcap_event_name anth_studyid--anthropometry_complete bprp_studyid--blood_pressure_and_r_v_0
        bloods_studyid--blood_results_labcor_v_1 bpj_studyid--bp_journal_complete bplog_studyid--bp_log_complete cal_studyid--calgary_complete
        phq8_studyid--phq8_complete prom_studyid--promis_dcfc_complete sarp_studyid--sarp_complete semsa_studyid--semsa_complete sf36_studyid--sf36_bdfa_complete
        shq_studyid--shq_date qctonom_studyid--tonometry_qc_complete twpas_studyid--twpas_fabc_complete;

  run;

  *restrict dataset to research visits;
  data visits_only (drop = redcap_event_name);
    retain elig_studyid timepoint;
    set var_4checking;

    if redcap_event_name = "00_bv_arm_1" or redcap_event_name = "06_fu_arm_1" or redcap_event_name = "12_fu_arm_1";

    if redcap_event_name = "00_bv_arm_1" then timepoint = 00; else
    if redcap_event_name = "06_fu_arm_1" then timepoint = 06; else
    if redcap_event_name = "12_fu_arm_1" then timepoint = 12;


  run;

****************************************************************************************;
* CHECK FOR INSTANCES WHERE THERE MIGHT BE A DATA ENTRY ERROR
****************************************************************************************;

*********************************;
* check for misentered studyids;
*********************************;

  *create dataset of studyid variables where they differ from elig_studyid;
  data studyid_errors (keep = elig_studyid timepoint var_error ent_error);
    set visits_only;
    array si_checker[*] _numeric_;

    format var_error $32.;

    do i = 1 to dim(si_checker);
      if scan(vname(si_checker[i]), -1, '_') = "studyid"
        then do;
          if (si_checker[i] ne si_checker[1]) and si_checker[i] ne . and si_checker[i] ne -9
          then do;
                var_error = vname(si_checker[i]);
                ent_error = si_checker[i];
                output studyid_errors;
              end;
        end;

    end;

  run;



*********************************;
* check for misentered namecodes;
*********************************;

  data namecode_errors (keep = elig_studyid anth_namecode timepoint var_error ent_error);
    set visits_only;
    array nc_checker[*] _character_;

    format var_error $32.;

    *check namecodes for errors based on anthropometry namecode;
    if nc_checker[1] ne "" then
      do i = 1 to dim(nc_checker);
        if scan(vname(nc_checker[i]), -1, '_') = "namecode"
          then do;
            if (nc_checker[i] ne nc_checker[1]) and nc_checker[i] ne ""
            then do;
                  var_error = vname(nc_checker[i]);
                  ent_error = nc_checker[i];
                  output namecode_errors;
                end;
          end;

      end;

    *run check for situation where person never had anthropometry data collected but did have other data such as questionnaires;
    else
      do;
        nc_store = nc_checker[1];
        do i= 1 to dim(nc_checker);
        if (scan(vname(nc_checker[i]), -1, '_') = "namecode") and nc_checker[i] ne ""
          then nc_store = nc_checker[i];
        end;
        if nc_store ne "" then
          do i = 1 to dim(nc_checker);
          if (scan(vname(nc_checker[i]), -1, '_') = "namecode") and (nc_checker[i] ne nc_store) and nc_checker[i] ne ""
          then do;
            var_error = vname(nc_checker[i]);
            ent_error = nc_checker[i];
            output namecode_errors;
            end;
          end;
      end;

  run;



**********************************;
* check for misentered visitdates;
**********************************;

  *sort visitdates into datasets sorted by visit;

  data baseline_dates;
    set visits_only;
    if timepoint = 0;
    keep elig_studyid timepoint anth_namecode anth_date bprp_visitdate bloods_datetest bplog_visitdate cal_datecompleted phq8_visitdate prom_visitdate sarp_visitdate semsa_visitdate
      sf36_visitdate shq_date qctonom_visitdate twpas_visitdate;
  run;

  data mo6_dates;
    set visits_only;
    if timepoint = 6;
    keep elig_studyid timepoint anth_namecode anth_date bprp_visitdate bloods_datetest bplog_visitdate cal_datecompleted phq8_visitdate prom_visitdate sarp_visitdate semsa_visitdate
      sf36_visitdate shq_date qctonom_visitdate twpas_visitdate;
  run;

  data mo12_dates;
    set visits_only;
    if timepoint = 12;
    keep elig_studyid timepoint anth_namecode anth_date bprp_visitdate bloods_datetest bplog_visitdate cal_datecompleted phq8_visitdate prom_visitdate sarp_visitdate semsa_visitdate
      sf36_visitdate shq_date qctonom_visitdate twpas_visitdate;
  run;


  *merge visitdate datasets and check for errors;
  data allvisitdates visitdate_errors;
    merge baseline_dates mo6_dates mo12_dates;
    by elig_studyid;

    array vd_checker[*] anth_date--twpas_visitdate;

    format var_error $32.;

    if vd_checker[2] ne . and ((vd_checker[2] = vd_checker[3]) or (vd_checker[2] = vd_checker[4])) and vd_checker[2] ne vd_checker[1]
      then do;
          var_error = vname(vd_checker[1]);
          output visitdate_errors;
        end;
    else do i = 1 to dim(vd_checker);
      if (vd_checker[i] ne vd_checker[1]) and vd_checker[i] ne .
        then do;
            var_error = vname(vd_checker[i]);
            output visitdate_errors;
          end;
      else output allvisitdates;
    end;

    drop i;

  run;

  proc sort data = allvisitdates nodupkey;
    by elig_studyid;
  run;

**********************************;
* check for misentered timepoints;
**********************************;

  *sort timepoints into datasets sorted by visit;

  data baseline_timepoints;
    set visits_only;
    if timepoint = 0;
    keep elig_studyid timepoint anth_namecode anth_studyvisit bprp_studyvisit bloods_studyvisit bplog_studyvisit cal_studyvisit phq8_studyvisit prom_studyvisit sarp_studyvisit
      semsa_studyvisit sf36_studyvisit qctonom_studyvisit twpas_studyvisit;
  run;

  data mo6_timepoints;
    set visits_only;
    if timepoint = 6;
    keep elig_studyid timepoint anth_namecode anth_studyvisit bprp_studyvisit bloods_studyvisit bplog_studyvisit cal_studyvisit phq8_studyvisit prom_studyvisit sarp_studyvisit
      semsa_studyvisit sf36_studyvisit qctonom_studyvisit twpas_studyvisit;
  run;

  data mo12_timepoints;
    set visits_only;
    if timepoint = 12;
    keep elig_studyid timepoint anth_namecode anth_studyvisit bprp_studyvisit bloods_studyvisit bplog_studyvisit cal_studyvisit phq8_studyvisit prom_studyvisit sarp_studyvisit
      semsa_studyvisit sf36_studyvisit qctonom_studyvisit twpas_studyvisit;
  run;


  *merge timepoint datasets and check for errors;
  data alltimepoints timepoint_errors;
    merge baseline_timepoints mo6_timepoints mo12_timepoints;
    by elig_studyid;

    array tp_checker[*] timepoint anth_studyvisit--twpas_studyvisit;

    format var_error $32.;

    do i = 1 to dim(tp_checker);
      if (tp_checker[i] ne tp_checker[1]) and tp_checker[i] ne .
        then do;
            var_error = vname(tp_checker[i]);
            output timepoint_errors;
          end;
      else output alltimepoints;
    end;

    drop i;

  run;

  proc sort data = alltimepoints nodupkey;
    by elig_studyid;
  run;

****************************************************************************************;
* CHECK FOR INSTANCES WHERE THERE MIGHT BE A DATA ENTRY OR COLLECTION ERROR
****************************************************************************************;

*ANTHROPOMETRY;

  *check for significant differences in height measurements;
  data anthheights00 anthheights12;
    set visits_only;
    if timepoint = 00 then output anthheights00; else
    if timepoint = 12 then output anthheights12;

    keep elig_studyid anth_heightcm1--anth_heightcm3;

  run;

  data anthheights12;
    set anthheights12;
    array htstore[3] anth_heightcm1--anth_heightcm3;
    array htwrite[3] anth_heightcm4-anth_heightcm6;

    do i = 1 to 3;
      htwrite[i] = htstore[i];
    end;

    keep elig_studyid anth_heightcm4--anth_heightcm6;

  run;

  data anthheights;
    merge anthheights00 anthheights12;
    by elig_studyid;
  run;

  data anthheights1;
    set anthheights;

    tallest_ht = max(anth_heightcm1, anth_heightcm2, anth_heightcm3, anth_heightcm4, anth_heightcm5, anth_heightcm6);
    big_htdiff = .;

    array allhts[6] anth_heightcm1--anth_heightcm6;

    do i = 1 to 6;
      if (allhts[i] ne . and allhts[i] ge 0) then do;
        if (tallest_ht - allhts[i]) ge 5 then big_htdiff = 1;
      end;
    end;

  run;



  proc sql;
  ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\BestAIR Possible Entry or Collection Errors &sasfiledate..PDF";

  *DATA ENTRY;
    title 'Instances Where Study ID was Entered Incorrectly';
    select elig_studyid as StudyID, timepoint, var_error as Mistake_Variable, ent_error as Entered_As from studyid_errors;
    title;

    title 'Instances Where NameCode was Entered Incorrectly';
    select elig_studyid as StudyID, timepoint, anth_namecode as Intended_Namecode, var_error as Mistake_Variable, ent_error as Entered_As from namecode_errors;
    title;

    title 'Instances Where Visit Date was Possibly Entered Incorrectly';
    select elig_studyid as StudyID, anth_namecode as Namecode, timepoint, var_error as Mistake_Variable from visitdate_errors;
    title;

    title 'Instances Where Study Visit (Timepoint) was Entered Incorrectly';
    select elig_studyid as StudyID, anth_namecode as Namecode, timepoint, var_error as Mistake_Variable from timepoint_errors;
    title;


  *ANTHROPOMETRY;
    title 'Instances Where Anthro. Heights Differ by Greater than 5 cm';
    select elig_studyid from anthheights1 where big_htdiff = 1;
    title;

    title 'Instances Where Reported Anthro. Height is Less than 150 cm';
    select elig_studyid, timepoint from visits_only where (0 < anth_heightcm1 < 150) or (0 < anth_heightcm2 < 150) or (0 < anth_heightcm3 < 150);
    title;

    title 'Instances Where Reported Anthro. Weight is Less than 45 kg or Greater than 130 kg';
    select elig_studyid, timepoint from visits_only where ((0 < anth_weightkg < 45) or anth_weightkg > 130) and (
                  elig_studyid ne 70179 and /*confirmed 6/19/2013 JL*/
                  elig_studyid ne 74404 and /*confirmed 8/28/2013 KG*/
                  elig_studyid ne 80024 and /*confirmed 6/19/2013 JL*/
                  elig_studyid ne 82545     /*confirmed 6/19/2013 JL*/
                  );
    title;

    title 'Instances Where Reported Neck Circumference is Less than 35 cm';
    select elig_studyid, timepoint from visits_only where (0 < anth_waistcm1 < 35) or (0 < anth_waistcm2 < 35) or (0 < anth_waistcm3 < 35);
    title;

    title 'Instances Where Reported Waist Circumference is Less than 70 cm';
    select elig_studyid, timepoint from visits_only where (0 < anth_waistcm1 < 70) or (0 < anth_waistcm2 < 70) or (0 < anth_waistcm3 < 70);
    title;

    title 'Instances Where Reported Hip Circumference is Less than 70 cm';
    select elig_studyid, timepoint from visits_only where (0 < anth_hipcm1 < 70) or (0 < anth_hipcm2 < 70) or (0 < anth_hipcm3 < 70);
    title;

  *BP AND RADIAL PULSE;
    title 'Instances Where Reported Resting BP Systolic is Less than 90 mm/hg or Greater than 180 mm/hg';
    select elig_studyid, timepoint from visits_only where (0 < bprp_bpsys1 < 90 or bprp_bpsys1 > 180 or 0 < bprp_bpsys2 < 90 or bprp_bpsys2 > 180
                                or 0 < bprp_bpsys3 < 90 or bprp_bpsys3 > 180) and (
                                (elig_studyid ne 70140 and timepoint = 12) and  /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 70197 and timepoint = 6) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 71176 and timepoint = 12) and  /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73068 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73101 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73122 and timepoint = 6) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73134 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73143 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73220 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73220 and timepoint = 6)   /* confirmed 08/16/2013 BO*/
                                )
                                ;
    title;

    title 'Instances Where Reported Resting BP Diastolic is Less than 50 mm/hg or Greater than 110 mm/hg';
    select elig_studyid, timepoint from visits_only where (0 < bprp_bpdia1 < 50 or bprp_bpdia1 > 110 or 0 < bprp_bpdia2 < 50 or bprp_bpdia2 > 110
                                or 0 < bprp_bpdia3 < 50 or bprp_bpdia3 > 110) and (
                                (elig_studyid ne 71176 and timepoint = 12) and  /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 72154 and timepoint = 6) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 72154 and timepoint = 12) and  /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73101 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73143 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 73143 and timepoint = 6) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 80510 and timepoint = 6) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 80510 and timepoint = 12) and  /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 82444 and timepoint = 6)   /* confirmed 08/16/2013 BO*/
                                );
    title;


    title 'Instances Where Reported Resting BP Radial Pulse is Less than 40 BPM or Greater than 100 BPM';
    select elig_studyid, timepoint from visits_only where (0 < bprp_rp1 < 40 or bprp_rp1 > 100 or 0 < bprp_rp2 < 40 or bprp_rp2 > 100
                                or 0 < bprp_rp3 < 40 or bprp_rp3 > 100) and (
                                (elig_studyid ne 82286 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                (elig_studyid ne 90731 and timepoint = 0)   /* confirmed 08/16/2013 BO*/
                                );
    title;



  ods pdf close;
  quit;
