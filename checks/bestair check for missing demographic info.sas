****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\bestair options and libnames.sas";


****************************************************************************************;
*  IMPORT BESTAIR DATASET OF RANDOMIZED PARTICIPANTS FROM REDCAP
****************************************************************************************;

%include "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\redcap\_components\bestair create rand set.sas";

  data elig_info;
    set redcap_rand;

    if redcap_event_name = "screening_arm_0";
    keep elig_studyid elig_datecompleted--eligibility_complete rand_date;

  run;

****************************************************************************************;
*  PRINT PARTICIPANTS MISSING DEMOGRAPHIC INFORMATION
****************************************************************************************;
  proc sql;
    title "Unverified Eligibility Information, Randomized Subjects";
    select elig_studyid from elig_info where eligibility_complete < 2;
  quit;
  
  ods pdf file="\\rfa01\bwh-sleepepi-bestair\data\sas\checks\Missing Eligibility Info &sasfiledate..PDF";
  proc sql;
  *create table of randomized participants missing demographic info;

    title "Randomized, Missing Eligibility Form";
      select elig_studyid from elig_info where rand_date > . and (eligibility_complete = . or eligibility_complete = 0);
      title;

    title "Randomized, Missing Gender";
      select elig_studyid from elig_info where rand_date > . and (eligibility_complete ne . and eligibility_complete ne 0) and (elig_gender < 1 or elig_gender = .);
      title;

    title "Randomized, Missing Race";
      select elig_studyid from elig_info
      where rand_date > . and (eligibility_complete ne . and eligibility_complete ne 0) and
                    ((elig_raceamerind < 0 or elig_raceamerind = .) or (elig_raceasian < 0 or elig_raceasian = .) or (elig_racehawaiian < 0 or elig_racehawaiian = .)
                  or (elig_raceblack < 0 or elig_raceblack = .) or (elig_racewhite < 0 or elig_racewhite = .) or (elig_raceother < 0 or elig_raceother = .));
      title;

    title "Randomized, Marked 'Other Race', No Race listed";
      select elig_studyid from elig_info
      where rand_date > . and (eligibility_complete ne . and eligibility_complete ne 0) and
                  (elig_raceother = 1 and (elig_raceotherspecify = '-8' or elig_raceotherspecify = '-9' or elig_raceotherspecify = '-10'));
      title;

    title "Randomized, Missing Ethnicity";
      select elig_studyid from elig_info where rand_date > . and (eligibility_complete ne . and eligibility_complete ne 0) and (elig_ethnicity < 1 or elig_ethnicity = .);
      title;

    title "Randomized, Missing Education";
      select elig_studyid from elig_info where rand_date > . and (eligibility_complete ne . and eligibility_complete ne 0) and (elig_education < 1 or elig_education = .);
      title;
  /*
  *create table of non-randomized participants missing demographic info;
    title "Non-randomized, Missing Gender";
      select elig_studyid from elig_info where rand_date = . and (elig_gender < 1 or elig_gender = .);
      title;

    title "Non-randomized, Missing Race";
      select elig_studyid
      from elig_info
      where rand_date = . and ((elig_raceamerind < 0 or elig_raceamerind = .) or (elig_raceasian < 0 or elig_raceasian = .) or (elig_racehawaiian < 0 or elig_racehawaiian = .)
                    or (elig_raceblack < 0 or elig_raceblack = .) or (elig_racewhite < 0 or elig_racewhite = .) or (elig_raceother < 0 or elig_raceother = .));
      title;

    title "Non-randomized, Marked 'Other Race', No Race listed";
      select elig_studyid from elig_info where rand_date = . and (elig_raceother = 1 and (elig_raceotherspecify = '-8' or elig_raceotherspecify = '-9'
        or elig_raceotherspecify = '-10'));
      title;

    title "Non-randomized, Missing Ethnicity";
      select elig_studyid from elig_info where rand_date = . and (elig_ethnicity < 1 or elig_ethnicity = .);
      title;

    title "Non-randomized, Missing Education";
      select elig_studyid from elig_info where rand_date = . and (elig_education < 1 or elig_education = .);
      title;
  */



****************************************************************************************;
*  PRINT PARTICIPANTS MISSING DEMOGRAPHIC INFORMATION RANDOMIZED BEFORE CERTAIN DATE
****************************************************************************************;
  /*

  data elig_info;
      set elig_info;
      calc_days = today() - 30;
  run;

  *print randomized participants missing demographic info;

    title "Randomized > 1 months ago, Missing Gender";
      select elig_studyid from elig_info where rand_date < calc_days and (elig_gender < 1 or elig_gender = .);
      title;

    title "Randomized > 1 months ago, Missing Race";
      select elig_studyid
      from elig_info
      where rand_date < calc_days and ((elig_raceamerind < 0 or elig_raceamerind = .) or (elig_raceasian < 0 or elig_raceasian = .)
                              or (elig_racehawaiian < 0 or elig_racehawaiian = .) or (elig_raceblack < 0 or elig_raceblack = .)
                              or (elig_racewhite < 0 or elig_racewhite = .) or (elig_raceother < 0 or elig_raceother = .));
      title;

    title "Randomized > 1 month ago, Marked 'Other Race', No Race listed";
      select elig_studyid from elig_info where rand_date < calc_days and (elig_raceother = 1 and (elig_raceotherspecify = '-8' or elig_raceotherspecify = '-9'
        or elig_raceotherspecify = '-10'));
      title;

    title "Randomized > 1 month ago, Missing Ethnicity";
      select elig_studyid from elig_info where rand_date < calc_days and (elig_ethnicity < 1 or elig_ethnicity = .);
      title;

    title "Randomized > 1 month ago, Missing Education";
      select elig_studyid from elig_info where rand_date < calc_days and (elig_education < 1 or elig_education = .);
      title;

  */

  
  quit;
  ods pdf close;
