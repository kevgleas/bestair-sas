****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

*import dataset of randomized participants;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\redcap\_components\bestair create rand set.sas";

  *create dataset by importing data from REDCap, where permanent data is stored;
  data redcap;
    set Redcap_rand;
  run;


****************************************************************************************;
*  DATA PROCESSING FOR ANTHROPOMETRY DATA
****************************************************************************************;

  *RESTRICT DATASET TO VISIT DATA ONLY;
  data redcap_visitsonly;
    set redcap;
    if redcap_event_name in("00_bv_arm_1", "06_fu_arm_1", "12_fu_arm_1");

    if redcap_event_name = "00_bv_arm_1" then timepoint = 0;
    else if redcap_event_name = "06_fu_arm_1" then timepoint = 6;
    else if redcap_event_name = "12_fu_arm_1" then timepoint = 12;
  run;

  *GET POTENTIALLY RELEVANT ELIGIBILITY DATA;
  data redcap_eligibility;
    set redcap;
    if redcap_event_name = "screening_arm_0";

    keep elig_studyid elig_incl04fbmi elig_gender;
  run;

  *RESTRICT TO RELEVANT VARIABLES;
  data anthrodata;
    retain elig_studyid timepoint;
    merge redcap_visitsonly (drop = elig_incl04fbmi elig_gender) redcap_eligibility;
    by elig_studyid;
    keep elig_studyid timepoint anth_studyid--anthropometry_complete elig_incl04fbmi elig_gender;
    if anth_studyid > 0 and anth_studyid ne .;
  run;

  *RECODE MISSING VARIABLES;
  data anthrofix;
    set anthrodata;
    array missing2null[*] anth_heightcm1--anth_hipcm3;
    do i = 1 to dim(missing2null);
      if missing2null[i] < 0 then missing2null[i] = .;
    end;
    drop i;
  run;

  *check for significant differences in height measurements;
  data anthheights00 anthheights12;
    set anthrofix;
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

  *IDENTIFY EXTREME VALUES;
  *ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\anthropometry\Anthropometry Extreme Values &sasfiledate..PDF";

  proc sql;
    title 'Instances Where Anthro. Heights Differ by Greater than 5 cm';
    select elig_studyid from anthheights1 where big_htdiff = 1;
    title;

    title 'Instances Where Reported Anthro. Height is Less than 150 cm';
    select elig_studyid, timepoint from anthrofix where (0 < anth_heightcm1 < 150) or (0 < anth_heightcm2 < 150) or (0 < anth_heightcm3 < 150);
    title;

    title 'Instances Where Reported Anthro. Weight is Less than 45 kg or Greater than 130 kg';
    select elig_studyid, timepoint from anthrofix where ((0 < anth_weightkg < 45) or anth_weightkg > 130) and (
                  elig_studyid ne 70179 and /*confirmed 6/19/2013 JL*/
                  elig_studyid ne 74404 and /*confirmed 8/28/2013 KG*/
                  elig_studyid ne 80024 and /*confirmed 6/19/2013 JL*/
                  elig_studyid ne 82545     /*confirmed 6/19/2013 JL*/
                  );
    title;

    title 'Instances Where Reported Neck Circumference is Less than 35 cm (Male) or 30 cm (Female)';
    select elig_studyid, timepoint, elig_gender from anthrofix where (0 < anth_neckcm1 < 35 and elig_gender = 1) 
            or (0 < anth_neckcm2 < 35 and elig_gender = 1) or (0 < anth_neckcm3 < 35 and elig_gender = 1)
            or (0 < anth_neckcm1 < 30 and elig_gender = 2) 
            or (0 < anth_neckcm2 < 30 and elig_gender = 2) or (0 < anth_neckcm3 < 30 and elig_gender = 2);
    title;

    title 'Instances Where Reported Waist Circumference is Less than 70 cm';
    select elig_studyid, timepoint from anthrofix where (0 < anth_waistcm1 < 70) or (0 < anth_waistcm2 < 70) or (0 < anth_waistcm3 < 70);
    title;

    title 'Instances Where Reported Hip Circumference is Less than 70 cm';
    select elig_studyid, timepoint from anthrofix where (0 < anth_hipcm1 < 70) or (0 < anth_hipcm2 < 70) or (0 < anth_hipcm3 < 70);
    title;
  quit;
  *ods pdf close;

  *Univariate to assess data values;
/*  proc univariate data=anthrofix;*/
/*    var anth_heightcm1-3 anth_weightkg anth_neckcm1-3 anth_waistcm1-3 anth_hipcm1-3;*/
/*  run;*/

  *drop unnecessary variables;
  *null impossible values known to have problem with data collection;
  *create summary variables;
  data anthrofinal;
    set anthrofix;
    by elig_studyid;
    retain avgheightcm_atbaseline;
    array allheights[*] anth_heightcm1-anth_heightcm3;

    do i = 1 to dim(allheights);
      if elig_studyid = 80045 and timepoint = 12 then allheights[i] = .;
    end;
    drop i;

    if first.elig_studyid then avgheightcm_atbaseline = .;
    if timepoint = 0 then avgheightcm_atbaseline = mean(of anth_heightcm1-anth_heightcm3);
    avgheightcm = mean(of anth_heightcm1-anth_heightcm3);
    avgneckcm = mean(of anth_neckcm1-anth_neckcm3);
    avgwaistcm = mean(of anth_waistcm1-anth_waistcm3);
    avghipcm = mean(of anth_hipcm1-anth_hipcm3);
/*
    if avgheightcm = . then bmi = anth_weightkg/((avgheightcm_atbaseline/100)*(avgheightcm_atbaseline/100));
    else bmi = anth_weightkg/((avgheightcm/100)*(avgheightcm/100));
*/
    bmi = anth_weightkg/((avgheightcm_atbaseline/100)*(avgheightcm_atbaseline/100));

    drop timepoint anthropometry_complete elig_incl04fbmi elig_gender;
  run;

  data anthrofinal;
    set anthrofinal;
    label avgheightcm_atbaseline = "Average Height at Baseline (cm)"
          avgheightcm = "Average Height at Visit (cm)"
          avgneckcm = "Average Neck Circumference (cm)"
          avgwaistcm = "Average Waist Circumference (cm)"
          avghipcm = "Average Hip Circumference (cm)"
          bmi = "Body Mass Index"
          ;
  run;
  
  *need to comment out "drop" section above before running next proc sql;
  /*
  proc sql;
    select elig_studyid, timepoint, bmi_atvisit, elig_incl04fbmi
    from anthrofinal 
    where bmi_atvisit < 30 and elig_incl04fbmi = 1;
  quit;
  */

  *proc export data = anthrofinal outfile = "\\rfa01\bwh-sleepepi-bestair\data\kevin\anthro 2-26-14.csv" dbms = csv replace;
  *run;

  data bestair.baanthro bestair2.baanthro_&sasfiledate;
    set anthrofinal;
  run;
