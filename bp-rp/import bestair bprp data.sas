****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

*import dataset of randomized participants;
*%include "\\rfa01\bwh-sleepepi-bestair\data\sas\redcap\_components\bestair create rand set.sas";

  *create dataset by importing data from REDCap, where permanent data is stored;
  data redcap;
    set Redcap_rand;
  run;


****************************************************************************************;
*  DATA PROCESSING FOR BPRP DATA
****************************************************************************************;

  *RESTRICT DATASET TO VISIT DATA ONLY;
  data redcap_visitsonly;
    set redcap;
    if redcap_event_name in("00_bv_arm_1", "06_fu_arm_1", "12_fu_arm_1");

    if redcap_event_name = "00_bv_arm_1" then timepoint = 0;
    else if redcap_event_name = "06_fu_arm_1" then timepoint = 6;
    else if redcap_event_name = "12_fu_arm_1" then timepoint = 12;
  run;

  *SELECT RELEVANT VARIABLES;
  data bprpdata;
    retain elig_studyid timepoint;
    set redcap_visitsonly;
    keep elig_studyid timepoint bprp_studyid--blood_pressure_and_r_v_0;
    if bprp_studyid > 0 and bprp_studyid ne .;
  run;

  *RECODE MISSING VARIABLES;
  data bprpmiss;
    set bprpdata;
    array miss[*] bprp_bpsys1--blood_pressure_and_r_v_0;
    do i = 1 to dim(miss);
      if miss[i] < 0 then miss[i] = .;
    end;
    drop i;
  run;

  *IDENTIFY EXTREME VALUES;
  *ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\BP-RP\Blood Pressure and Radial Pulse Extreme Values &sasfiledate..PDF";

  *SYSTOLIC BLOOD PRESSURE;
  proc sql;
    title "Instances Where Systolic Blood Pressure was < 90 or > = 180";
    title2 "Values That Have Not Been Checked";
    select elig_studyid, timepoint, bprp_bpsys1, bprp_bpsys2, bprp_bpsys3
    from bprpmiss
    where ((bprp_bpsys1 >= 180 or bprp_bpsys2 >= 180 or bprp_bpsys3 >= 180) or (bprp_bpsys1 < 90 or bprp_bpsys2 < 90 or bprp_bpsys3 < 90)) and (bprp_bpsys1 ne . or bprp_bpsys2 ne . or bprp_bpsys3 ne .) and (
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
                                );
    title;
  quit;

  *DIASTOLIC BLOOD PRESSURE;
  proc sql;
    title "Instances Where Diastolic Blood Pressure was < 50 or > = 110";
    title2 "Values That Have Not Been Checked";
    select elig_studyid, timepoint, bprp_bpdia1, bprp_bpdia2, bprp_bpdia3
    from bprpmiss
    where ((bprp_bpdia1 >= 110 or bprp_bpdia2 >= 110 or bprp_bpdia3 >= 110) or (bprp_bpdia1 < 50 or bprp_bpdia2 < 50 or bprp_bpdia3 < 50)) and (bprp_bpdia1 ne . or bprp_bpdia2 ne . or bprp_bpdia3 ne .) and (
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
  title;title2;
  quit;

  *RADIAL PULSE;
  proc sql;
    title "Instances Where Radial Pulse < 40 or > 100";
    select elig_studyid, timepoint, bprp_rp1, bprp_rp2, bprp_rp3
    from bprpmiss
    where ((bprp_rp1 > 140 or bprp_rp2 > 140 or bprp_rp3 > 140) or (bprp_rp1 < 40 or bprp_rp2 < 40 or bprp_rp3 < 40)) and (bprp_rp1 ne . and bprp_rp2 ne . and bprp_rp3 ne .) and (
                                 (elig_studyid ne 82286 and timepoint = 0) and   /* confirmed 08/16/2013 BO*/
                                  (elig_studyid ne 90731 and timepoint = 0)   /* confirmed 08/16/2013 BO*/
                                );
    title;
  quit;

  *COMPLETENESS;
  proc sql;
    title "Incomplete/Unverified Data Points";
    select elig_studyid, timepoint, blood_pressure_and_r_v_0
    from bprpmiss
    where blood_pressure_and_r_v_0 NE 2;
    title;
  quit;

  *ods pdf close;

  *Univariate to assess data values;
/*  proc univariate data=bprpdata;*/
/*    var bprp_bpsys1-3 bprp_bpdia1-3;*/
/*  run;*/

  data bprpfinal;
    set bprpmiss;

    avgseatedsystolic = mean(of bprp_bpsys1-bprp_bpsys3);
    avgseateddiastolic = mean(of bprp_bpdia1-bprp_bpdia3);
    avgseatedpulse = mean(of bprp_rp1-bprp_rp3);

    drop timepoint blood_pressure_and_r_v_0;

  run;

  data bprpfinal;
    set bprpfinal;
    label avgseatedsystolic = "Average Seated Systolic BP"
          avgseateddiastolic = "Average Seated Diastolic BP"
          avgseatedpulse = "Average Seated Radial Pressure (bpm)"
    ;
  run;

  data bestair.babprp bestair2.babprp_&sasfiledate;
    set bprpfinal;
  run;
