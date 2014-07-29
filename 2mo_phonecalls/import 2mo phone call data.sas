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

****************************************************************************************;
* IMPORT REDCAP DATA and PREPARE DATASETS
****************************************************************************************;
  data phonecalls;
    retain test;
    set redcap;
    if (0 < input(substr(redcap_event_name,1,2),12.) < 99) or substr(redcap_event_name,1,2) = "of";
    drop essdate_completed--twpas_fabc_complete;
    test = redcap_event_name;
  run;

  data phonecalls_withrand;
    merge randset phonecalls;
    by elig_studyid;
  run;

  data unsched_phonecalls;
    set phonecalls_withrand;
    if phonechanges_datecompleted ne .;
    keep phonechanges_datecompleted--incoming_phone_call__v_5;
  run;

  proc sql;
    title "Phone Call Date More than 15-months after Baseline";
    select elig_studyid, rand_date, twomonth_month, twomonth_contactdate
    from phonecalls_withrand
    where (twomonth_contactdate - rand_date) > 455;
  quit;

  proc sql;
    title "2 Month Phone Call Date More than 4-months after Baseline";
    select elig_studyid, rand_date, twomonth_month, twomonth_contactdate
    from phonecalls_withrand
    where (twomonth_contactdate - rand_date) > 121 and twomonth_month = 1;

    title "4 Month Phone Call Date More than 6-months after Baseline";
    select elig_studyid, rand_date, twomonth_month, twomonth_contactdate
    from phonecalls_withrand
    where (twomonth_contactdate - rand_date) > 181 and twomonth_month = 2;

    title "6 Month Phone Call Date More than 8-months after Baseline";
    select elig_studyid, rand_date, twomonth_month, twomonth_contactdate
    from phonecalls_withrand
    where (twomonth_contactdate - rand_date) > 242 and twomonth_month = 3;

    title "8 Month Phone Call Date More than 10-months after Baseline";
    select elig_studyid, rand_date, twomonth_month, twomonth_contactdate
    from phonecalls_withrand
    where (twomonth_contactdate - rand_date) > 303 and twomonth_month = 4;

    title "10 Month Phone Call Date More than 12-months after Baseline";
    select elig_studyid, rand_date, twomonth_month, twomonth_contactdate
    from phonecalls_withrand
    where (twomonth_contactdate - rand_date) > 365 and twomonth_month = 5;

  quit;

  proc sql;
    title "Phone Call missing Date";
    select elig_studyid, redcap_event_name, twomonth_month, twomonth_contactdate
    from phonecalls_withrand
    where twomonth_contactdate = . and twomonth_studyid not in(.,-9) and (twomonth_namecode ne "" or twomonth_chestpain ne .);
  quit;
