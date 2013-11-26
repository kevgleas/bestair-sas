****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";


****************************************************************************************;
* IMPORT 24-HOUR BP DATA FROM REDCAP AND SERVER
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\24hrbp\import BestAIR 24hr BP and compare to REDCap.sas";

  *restrict bp dataset to variables to be used in program;
  data bptracking;
    set mergebp;
    by studyid;
    keep studyid--nwake monitorqc_20hrs--monitorqc_percentsuccess;
  run;

  *combine relevant bp data across all visits by subject;
  proc transpose data=bptracking out = bptrackingwake prefix = nwake;
    var nwake;
    by studyid;
  run;

  proc transpose data=bptracking out = bptrackingsleep prefix = nsleep;
    var nsleep;
    by studyid;
  run;

  data long_bp;
    merge bptrackingwake bptrackingsleep;
    by studyid;
    drop _name_;
    rename nwake1 = nwake00;
    rename nwake2 = nwake06;
    rename nwake3 = nwake12;
    rename nsleep1 = nsleep00;
    rename nsleep2 = nsleep06;
    rename nsleep3 = nsleep12;

  run;

  data long_bp;
    retain studyid nwake00 nsleep00 nwake06 nsleep06 nwake12 nsleep12;
    set long_bp;
  run;

*create dataset with randomizations dates - will be used to determine windows for visits to know when BP is expected;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\redcap\_components\bestair create rand set.sas";

  *rename variable in dataset listing randomization dates to match;
  data randset2;
    set randset;
    rename elig_studyid = studyid;
  run;

  *combine bp data with randomization date;
  data longbp_withrand;
    merge randset2 long_bp;
    by studyid;
  run;


****************************************************************************************;
* CALCULATE COMPLETED VERSUS MISSING LONGITUDINAL DATA
****************************************************************************************;
  data longitudinal_bp;
    set longbp_withrand;

    all_data = .;
    atleast1_complong = .;
    atleast1_partlong = .;
    alllong_missing = .;

    if rand_date < (date() - 456) then do;
      if nwake06 = . and nsleep06 = . and nwake12 = . and nsleep12 = . then do;
        all_data = 0;
        atleast1_complong = 0;
        atleast1_partlong = 0;
        alllong_missing = 1;
        end;
      else if (nwake06 > 10 and nsleep06 > 4) and (nwake12 > 10 and nsleep12 > 4) then do;
        all_data = 1;
        atleast1_complong = 1;
        atleast1_partlong = 1;
        alllong_missing = 0;
        end;
      else if (nwake06 > 10 and nsleep06 > 4) or (nwake12 > 10 and nsleep12 > 4) then do;
        all_data = 0;
        atleast1_complong = 1;
        atleast1_partlong = 1;
        alllong_missing = 0;
        end;
      else do;
        all_data = 0;
        atleast1_complong = 0;
        atleast1_partlong = 1;
        alllong_missing = 0;
        end;
      end;

    else if rand_date < (date() - 274) then do;
      if (nwake06 > 10 and nsleep06 > 4) then do;
        atleast1_complong = 1;
        atleast1_partlong = 1;
        end;
      else if (nwake06 > 10 or nsleep06 > 4) then do;
        atleast1_partlong = 1;
        end;
      end;


    else do;
      if (nwake06 > 10 and nsleep06 > 4) then do;
        atleast1_complong = 1;
        atleast1_partlong = 1;
        end;
      else if (nwake06 > 10 or nsleep06 > 4) then do;
        atleast1_partlong = 1;
        end;
      end;


  run;

  *calculate total participants for complete and partial longitudinal data;
  proc means noprint data=longitudinal_bp;
    output out=longitudinal_bpstats sum(atleast1_complong) = comp_longitudinalbp sum(atleast1_partlong) = part_longitudinalbp;
  run;

  data longitudinal_bpstatsfinal;
    set longitudinal_bpstats;

    format pct_with_compmeasurement pct_with_partmeasurement percent8.1;

    pct_with_compmeasurement = comp_longitudinalbp/_FREQ_;
    pct_with_partmeasurement = part_longitudinalbp/_FREQ_;
  run;

****************************************************************************************;
* PERFORM ADDITIONAL TESTING FOR PTS. WITH AT LEAST 1 COMPLETE LONGITUDINAL BP
****************************************************************************************;

  data longitudinal_bp_1comp;
    set longitudinal_bp;
    if atleast1_complong = 1;
  run;

  data longitudinal_bp_1part;
    set longitudinal_bp;
    if atleast1_partlong = 1;
  run;

  *include treatment arm for further data query;
  data randarm (keep = studyid rand_treatmentarm);
    set redcap_all;
    if rand_treatmentarm ne .;
    rename elig_studyid = studyid;
  run;

  proc sort data = longitudinal_bp_1comp;
    by studyid;
  run;

  proc sort data = longitudinal_bp_1part;
    by studyid;
  run;

  data complongbp_randarm (keep = rand_treatmentarm);
    merge randarm(in=a) longitudinal_bp_1comp(in=b);
    if b;
    by studyid;
  run;

  data partlongbp_randarm (keep = rand_treatmentarm);
    merge randarm(in=a) longitudinal_bp_1part(in=b);
    if b;
    by studyid;
  run;

  proc sort data = complongbp_randarm;
    by rand_treatmentarm;
  run;

  proc sort data = partlongbp_randarm;
    by rand_treatmentarm;
  run;

  *calculate statistics for number of complete longitudinal bp measurements by treatment arm;
  proc means noprint data=complongbp_randarm n;
    output out=complong_byarm;
    by rand_treatmentarm;
  run;

  *calculate statistics for number of partial longitudinal bp measurements by treatment arm;
  proc means noprint data=partlongbp_randarm n;
    output out=partlong_byarm;
    by rand_treatmentarm;
  run;

  *calculate number of expected longitudinal bp measurements by treatment arm;
  data expected_randarm (keep = rand_treatmentarm);
    set redcap_all;
    testdate = today() - 274;
    if rand_treatmentarm ne . and rand_date < testdate;
  run;

  proc sort data = expected_randarm;
    by rand_treatmentarm;
  run;

  proc means noprint data=expected_randarm n;
    output out=expected_byarm;
    by rand_treatmentarm;
  run;

  data expected_byarm;
    set expected_byarm;
    drop _type_;
    rename _freq_ = expected;
  run;

  data complong_byarm;
    set complong_byarm;
    drop _type_;
    rename _freq_ = comp_obtained;
  run;

  data partlong_byarm;
    set partlong_byarm;
    drop _type_;
    rename _freq_ = part_obtained;
  run;

  *merge values for obtained and expected measurements by treatment arm;
  data longbp_byarmfinal;
    merge complong_byarm partlong_byarm expected_byarm;
    by rand_treatmentarm;
    format pct_with_compmeasurement pct_with_partmeasurement percent8.1;
    pct_with_compmeasurement = comp_obtained/expected;
    pct_with_partmeasurement = part_obtained/expected;
  run;

****************************************************************************************;
* EXPORT PDF OF LONGITUDINAL BP MEASUREMENT STATS
****************************************************************************************;
  proc sql;
  ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\Longitudinal BP Completeness by Treatment Arm &sasfiledate..PDF";

  title "Longitudinal BP Completeness Numbers";
  select comp_longitudinalbp label = "Number with at Least 1 Complete Longitudinal Measure",
          part_longitudinalbp label = "Number with at Least 1 Partial Longitudinal Measure"
  from work.longitudinal_bpstatsfinal;
  title;


  title "Longitudinal BP Completeness by Treatment arm";
  select rand_treatmentarm, comp_obtained as Obtained, expected as Expected, pct_with_compmeasurement as Completion_Percentage
  from work.longbp_byarmfinal;
  title;

  title "Longitudinal BP Partial Completeness by Treatment arm";
  select rand_treatmentarm, part_obtained as Obtained, expected as Expected, pct_with_partmeasurement as PartialCompletion_Percentage
  from work.longbp_byarmfinal;
  title;

/*
  title "Longitudinal BP Completeness Numbers";
  select rand_treatmentarm, comp_obtained as Obtained, expected as Expected
  from work.longbp_byarmfinal;
  title;

  title "Longitudinal BP Partial Completeness Numbers";
  select rand_treatmentarm, part_obtained as Obtained, expected as Expected
  from work.longbp_byarmfinal;
  title;

  title "Longitudinal BP Completeness % by Treatment arm";
  select rand_treatmentarm, pct_with_compmeasurement as Completion_Percentage
  from work.longbp_byarmfinal;
  title;

  title "Longitudinal BP Partial Completeness % by Treatment arm";
  select rand_treatmentarm, pct_with_partmeasurement as PartialCompletion_Percentage
  from work.longbp_byarmfinal;
  title;
*/

  ods pdf close;
  quit;
