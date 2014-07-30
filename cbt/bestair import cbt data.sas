***************************************************************************************;
* bestair import cbt data.sas
*
* Created:    6/26/2014
* Last updated: 6/26/2014 * see notes
* Author:   Kevin Gleason
*
***************************************************************************************;
* Purpose:
* This program imports and cleans CBT data from the REDCap dataset for BestAIR.
*
***************************************************************************************;
****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\SAS\bestair options and libnames.sas";
%include "&bestairpath\SAS\bestair macros for multiple datasets.sas";

****************************************************************************************;
* IMPORT REDCAP DATA
****************************************************************************************;
%include "&bestairpath\SAS\redcap\_components\bestair create rand set.sas";

data cbt_data_in;
  set redcap_rand;
  if cbt1_studyid ne . or cbt2_studyid ne . or cbtp1_studyid ne . or cbtp2_studyid ne .;
  keep elig_studyid redcap_event_name cbt1_studyid--cbt_followup_phone_c_v_9;
run;

data cbt_data_nulldates_nocall;
  set cbt_data_in;
  if cbtp1_occur = 0 then cbtp1_date = .;
  if cbtp2_occur = 0 then cbtp2_date = .;
  if cbt2_thoughts in("Did not show", "-9") then cbt2_date = .;
run;

proc sql noprint;
  create table cbt_early_dates as
  select elig_studyid, cbt1_date, cbt2_date, cbtp1_date
  from cbt_data_nulldates_nocall
  where cbt1_studyid ne "";
quit;

proc transpose data = cbt_data_nulldates_nocall prefix = cbtp2_date out = cbt_late_dates;
  var cbtp2_date;
  by elig_studyid;
  where redcap_event_name ne "00_bv_arm_1";
run;

data cbt_dates;
  merge cbt_early_dates cbt_late_dates (drop = _NAME_ _LABEL_);
  by elig_studyid;
run;

data cbt_dates_idprobs;
  set cbt_dates;

  array check4problems[*] cbt1_date--cbtp2_date5;

  do i = 2 to dim(check4problems);
    if (check4problems[i] < check4problems[i-1]) and check4problems[i] ne . then lastproblem_atindex = i;
    if (check4problems[i] < check4problems[1]) and check4problems[i] ne . then lastproblem_atindex = i;
    if check4problems[i] = . and i ne 8 then null_before_end = 1;
  end;
  drop i;
run;

data check4problems;
  set cbt_dates_idprobs;
  if lastproblem_atindex ne . or null_before_end ne .;
run;

proc export data = check4problems outfile = "&bestairpath\SAS\cbt\check cbt dates.csv" dbms = csv replace;
run;

proc import file = "&bestairpath\SAS\_compliance\RT_Visit_Schedules-kg.xlsx" out = Active_CPAP_RTdates dbms = xlsx replace;
  sheet = "Active CPAP";
  getnames = yes;
  guessingrows = 100;
run;

proc import file = "&bestairpath\SAS\_compliance\RT_Visit_Schedules-kg.xlsx" out = Sham_CPAP_RTdates dbms = xlsx replace;
  sheet = "Sham CPAP";
  getnames = yes;
  guessingrows = 100;
run;

proc import file = "&bestairpath\SAS\_compliance\RT_Visit_Schedules-kg.xlsx" out = CBTdates_spreadsheet dbms = xlsx replace;
  sheet = "Behavioral Intervention";
  getnames = yes;
  guessingrows = 100;
run;

data Active_CPAP_RTdates_idprobs;
  set Active_CPAP_RTdates;

  if elig_studyid = 84175 then VAR8 = mdy(11,20,2012);

  array check4problems1[*] Var5--Var10;

  do i = 2 to dim(check4problems1);
    if (check4problems1[i] < check4problems1[i-1]) and check4problems1[i] ne . then lastproblem_atindex = i;
    if (check4problems1[i] < check4problems1[1]) and check4problems1[i] ne . then lastproblem_atindex = i;
    if (check4problems1[i] - check4problems1[1]) > biggest_range then biggest_range = (check4problems1[i] - check4problems1[1]);
    *if check4problems1[i] = . and i ne 8 then null_before_end = 1;
  end;
  drop i;

run;

proc univariate;
  var biggest_range;
run;

data Sham_CPAP_RTdates_idprobs;
  set Sham_CPAP_RTdates;

  array check4problems2[*] Var4--Var9;

  do i = 2 to dim(check4problems2);
    if (check4problems2[i] < check4problems2[i-1]) and check4problems2[i] ne . then lastproblem_atindex = i;
    if (check4problems2[i] < check4problems2[1]) and check4problems2[i] ne . then lastproblem_atindex = i;
    if (check4problems2[i] - check4problems2[1]) > biggest_range then biggest_range = (check4problems2[i] - check4problems2[1]);
    *if check4problems2[i] = . and i ne 8 then null_before_end = 1;
  end;
  drop i;
run;

proc univariate;
  var biggest_range;
run;
/*
data CBTdates_spreadsheet_idprobs;
  merge CBTdates_spreadsheet (in = a) bestair.Bestair_alldata_randomizedpts (keep = elig_studyid final_visit);
  by elig_studyid;

  if a;

  array check4problems3[*] VAR5--VAR12;

  do i = 2 to dim(check4problems3);
    if (check4problems3[i] < check4problems3[i-1]) and check4problems3[i] ne . then lastproblem_atindex = i;
    if (check4problems3[i] < check4problems3[1]) and check4problems3[i] ne . then lastproblem_atindex = i;
    if (check4problems3[i] - check4problems3[1]) > biggest_range then biggest_range = (check4problems3[i] - check4problems3[1]);
    *if check4problems[i] = . and i ne 8 then null_before_end = 1;
  end;
  drop i;
run;
*/
data cbtdates_merged;
  merge cbt_dates CBTdates_spreadsheet;
  by elig_studyid;

  array redcap_vars[*] cbt1_date--cbtp2_date5;
  array spreadsheet_vars[*] VAR5--VAR12;

  do i = 1 to dim(redcap_vars);
    if redcap_vars[i] ne spreadsheet_vars[i] then last_disagreement = i;
  end;

  drop i;
run;

*check for disagreements between spreadsheet and REDCap;
data cbtdates_merged_disagree (drop = namecode);
  set cbtdates_merged;
  *find disagreements but exclude instances that have already been corrected in REDCap);
  if last_disagreement ne .;
run;

options orientation = landscape;

proc sql;
  select * from cbtdates_merged_disagree;
quit;


proc univariate data = CBTdates_spreadsheet_idprobs;
  var biggest_range;
run;

proc freq data =  bestair.Bestair_alldata_randomizedpts ;
table rand_treatmentarm;
run;

proc sql;
  select elig_studyid, rand_treatmentarm
  from bestair.Bestair_alldata_randomizedpts
  where elig_studyid in (70015,70116,70149,72154);
quit;

***** write check for 12-month participants who have Week 20 phone call but no Week 32 phone call (already found one error, could be more) *****;
