****************************************************************************************;
* Establish BestAIR libraries and options
****************************************************************************************;
%include "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\bestair options and libnames.sas";

***************************************************************************************;
* ESTABLISH TEMPORARY NETWORK DRIVE
***************************************************************************************;
  x net use y: /d;
  x net use y: "\\rfa01\BWH-SleepEpi-bestair\Data" /P:No;

***************************************************************************************;
* CREATE INPUT STATEMENT FILE BASED ON PSG REPORT VARIABLES
***************************************************************************************;
  proc import out=reportvars
      datafile = "&bestairpath.\SAS\psg\bestair psg report variables.csv"
      dbms = csv
      replace;
    getnames = yes;
    guessingrows = 10000;
  run;

  * output statements to new file;
  data _null_;
    file "&bestairpath.\SAS\psg\bestair psg input statement.sas";
    put "input";
  run;

  data wtf;
    file "&bestairpath.\SAS\psg\bestair psg input statement.sas" MOD;
    set reportvars;
    length out $32000.;
    out = strip(input_code) || " " || strip(input_code_2);
    put out;
  run;
  data _null_;
    file "&bestairpath.\SAS\psg\bestair psg input statement.sas" MOD;
    put ";";
  run;

  * create recode file;
  data _null_;
    file "&bestairpath.\SAS\psg\bestair psg variable recodes.sas";
    set reportvars;
    length out $32000.;
    out = strip(conversion_code) || "  " || strip(formatting_code) || " " || strip(drop_input_variable);
    put out;
  run;



***************************************************************************************;
* READ IN SCORED REPORTS FROM RAW DATA -- EMBLETTA
***************************************************************************************;
  * get list of directories in scored folder;
  filename f1 pipe 'dir "y:\Embletta\SAS Reports" /b';

  * within each directory, read in report file named s + foldername + .txt;
  data bestairfiles;
    infile f1 truncover;
    input filename $30.;
    length foldername $150.;
    foldername = "y:\Embletta\SAS Reports\" || strip(filename);
    foldername = lowcase(foldername);
    filename = lowcase(filename);
    if strip(filename) in ("","_CMPStudyList.mdb") then delete;
  run;

  proc sort data=bestairfiles;
    by filename;
  run;

  data bestairreports;
    set bestairfiles;
    by filename;
  run;

  data pro2_embletta_in;
    set bestairreports;

    infile dummy filevar=foldername end=done truncover lrecl=256 N=78;
    do while(not done);
      * include input statement;
      %include "&bestairpath.\SAS\psg\bestair psg input statement.sas";

      * recode mising value codes to system missing;
      array char{*} _character_;
      do i=1 to dim(char);
        if char{i} = "N/A" then char{i}= "";
        if char{i} = "-" then char{i} = "";
        * round 30sec to nearest minute;
        if char{i} = "30sec" then char{i} = '00:01';
      end;

    end;
    call symput('nread',_n_);
  run;


***************************************************************************************;
* READ IN SCORED REPORTS FROM RAW DATA -- SLEEP HEALTH CENTERS STUDIES
***************************************************************************************;
  * get list of directories in scored folder;
  filename f2 pipe 'dir "y:\PSG\SAS Reports" /b';

  * within each directory, read in report file named s + foldername + .txt;
  data bestairfiles;
    infile f2 truncover;
    input filename $30.;
    length foldername $150.;
    foldername = "y:\PSG\SAS Reports\" || strip(filename);
    foldername = lowcase(foldername);
    filename = lowcase(filename);
    if strip(filename) in ("","_CMPStudyList.mdb") then delete;
  run;

  proc sort data=bestairfiles;
    by filename;
  run;

  data bestairreports;
    set bestairfiles;
    by filename;
  run;

  data pro2_shc_in;
    set bestairreports;

    infile dummy filevar=foldername end=done truncover lrecl=256 N=78;
    do while(not done);
      * include input statement;
      %include "&bestairpath.\SAS\psg\bestair psg input statement.sas";

      * recode mising value codes to system missing;
      array char{*} _character_;
      do i=1 to dim(char);
        if char{i} = "N/A" then char{i}= "";
        if char{i} = "-" then char{i} = "";
        * round 30sec to nearest minute;
        if char{i} = "30sec" then char{i} = '00:01';
      end;

    end;
    call symput('nread',_n_);
  run;


***************************************************************************************;
* COMBINE TWO RAW DATA SOURCES
***************************************************************************************;

  data pro2_in;
    set pro2_embletta_in (in=a) pro2_shc_in (in=b);

    if a then embletta = 1;
    if b then shc = 1;
  run;

  proc sort data=pro2_in;
    by filename;
  run;


*******************************************************************************;
* RUN THIS PART OF THE PROGRAM FIRST ^
*******************************************************************************;


*******************************************************************************;
* IF THAT WORKS AND THERE ARE NO ERRORS IN THE LOG THEN RUN THE REST v
*******************************************************************************;

  *******************************************************************************;
  * disconnect network drive;
  *******************************************************************************;
  x net use y: /delete ;


  *******************************************************************************;
  * ASSIGN VARIABLE FORMATS AND RECODE CHARACTER TO NUMERIC
  *******************************************************************************;
/*
  data check1;
    set pro2_in;
    pptid = upcase(pptid_in);
    stdydt = input(substr(filename,13,8),mmddyy8.);
  run;

  proc sort data=check1;
    by pptid stdydt;
  run;

* get all files in receipt;
  proc sql;
    create table qs_check as
    select pptid, datepart(stdydt) as stdydt, scorerid as scorid
    from psgsql.prc_numom_psgreceipt
    order by pptid, stdydt;
  quit;

  data check1;
    merge check1 (in=a) qs_check;
    by pptid stdydt;
    if a and index(scorerid_in,"/")>0;
  run;

  *print from check1;
  proc sql;
    title "nuMoM PSG: Possibly incorrect/improper Scorer ID, will be excluded from dataset";
    select filename, scorid, scorerid_in
    from check1; title;
  quit;
*/

  data check2;
    set pro2_in;
    if index(stdatep_in,":")>0
      or index(scoredt_in,":")>0
      or index(stloutp_in,":")=0
      or index(stonsetp_in,":")=0
      or index(slplatp_in,":")=0
      or index(remlaip_in,":")=0
      or index(remlaiip_in,":")=0
      or index(timebedp_in,":")=0
      or index(slpprdp_in,":")=0
      or index(slpeffp_in,":")>0
      or index(minstg1p_in,":")=0
      or index(minstg2p_in,":")=0
      or index(mnstg34p_in,":")=0
      or index(minremp_in,":")=0
      ;
  run;

  *print from check2;
  proc sql;
    title "BestAIR: PSG: Possibly improperly formatted report, will be excluded from dataset";
    select filename, scorerid_in, STDATEP_in, SCOREDT_in, embletta, shc
    from check2; title;
  quit;

  proc sql;
    create table pro2_valid as
    select * from pro2_in
    where /* filename not in (select filename from check1)
      and */ filename not in (select filename from check2);
  quit;

  data pro2;
    set pro2_valid;
    drop i;
    * include code to recode and format variables;
    %include "\\rfa01\BWH-SleepEpi-bestair\data\SAS\psg\bestair psg variable recodes.sas";

    * store the number of records read in from the network to report later for easy checking;
    call symput('filecount2',_n_);

    drop filename;
  run;



*****************************************************************************************;
* Format PPTID and clean up dataset
*****************************************************************************************;
  data bestair_in bestair_error;
    length pptid $5. stdydt 8.;
    set pro2;

    stdydt = stdatep;
    format stdydt mmddyy10.;

    if pptid = . then output bestair_error;
    else output bestair_in;

  run;

  proc sort data=bestair_in;
    by pptid stdydt;
  run;
