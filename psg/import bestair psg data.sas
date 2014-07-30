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

  ************************************************************************************;
  * #1 WAKE TIME AFTER SLEEP ONSET
  ************************************************************************************;
    waso = timebedm - slpprdp - slplatm;

    *account for rounding and fix negative waso;
    if -1 <= waso < 0 then waso = 0;

  ************************************************************************************;
  * #2 TOTAL SLEEP PERIOD VARIABLES
  ************************************************************************************;
    time_bed = timebedp;

  ************************************************************************************;
  * #4 SLEEP EFFICIENCY
  ************************************************************************************;
    if timebedp ne 0 then do;
        slp_eff = 100*(slpprdp)/timebedp;
    end;

  ************************************************************************************;
  * #9 RDI
  * RDI at specified desat  
      [ (Total number of central apneas at specified desat)
      + (Total number of obstructive apneas at specified desat)
      + (hypopneas at specified desat)] 
      / (hours of sleep)
  * For all, exclude if total sleep time is zero;
  * For Profusion2 studies, include AASM hypopneas ('unsure events');
  ************************************************************************************;
    if slpprdp gt 0 then do;
      ahi_a0h0 = 60*(hrembp + hrop + hnrbp + hnrop + 
            carbp + carop + canbp + canop +
            oarbp + oarop + oanbp +oanop +
            urbp + urop + unrbp + unrop) / slpprdp;
        ahi_a2h2 = 60*(hrembp2 + hrop2 + hnrbp2 + hnrop2 + 
            carbp2 + carop2 + canbp2 + canop2 +
            oarbp2 + oarop2 + oanbp2 +oanop2 +
            urbp2 + urop2 + unrbp2 + unrop2) / slpprdp;
        ahi_a3h3 = 60*(hrembp3 + hrop3 + hnrbp3 + hnrop3 + 
            carbp3 + carop3 + canbp3 + canop3 +
            oarbp3 + oarop3 + oanbp3 + oanop3 +
            urbp3 + urop3 + unrbp3 + unrop3) / slpprdp;
        ahi_a4h4 = 60*(hrembp4 + hrop4 + hnrbp4 + hnrop4 + 
            carbp4 + carop4 + canbp4 + canop4 +
            oarbp4 + oarop4 + oanbp4 +oanop4 +
            urbp4 + urop4 + unrbp4 + unrop4) / slpprdp;
      ahi_a5h5 = 60*(hrembp5 + hrop5 + hnrbp5 + hnrop5 + 
            carbp5 + carop5 + canbp5 + canop5 +
            oarbp5 + oarop5 + oanbp5 +oanop5 +
            urbp5 + urop5 + unrbp5 + unrop5) / slpprdp;
    end;

  ************************************************************************************;
  * #13 OAHI - all obstructive apneas and hypopneas with specified desat;
  * exclude studies where total sleep time is zero;
  ************************************************************************************;
    if slpprdp gt 0 then do;
      oahi_o0h3 = 60*(hrembp3 + hrop3 + hnrbp3 + hnrop3 + oarbp +oarop + oanbp +oanop + urbp3 + urop3 + unrbp3 + unrop3) / slpprdp;
      oahi_o0h4 = 60*(hrembp4 +hrop4 + hnrbp4 + hnrop4 + oarbp +oarop + oanbp +oanop + urbp4 + urop4 + unrbp4 + unrop4 ) / slpprdp;
    end;

  ************************************************************************************;
  * #14 OBSTRUCTIVE APNEA INDEX
  * exclude studies with total sleep time = 0 or with poor airflow;
  * for OAI with arousals, exclude studies scored sleep/wake
  ************************************************************************************;
    if slpprdp gt 0 then do;
      oai_o0  = 60*(oarbp +  oarop  + oanbp  + oanop) / slpprdp;
      oai_o4  = 60*(oarbp4 + oarop4 + oanbp4 + oanop4) / slpprdp;
    end;

  ************************************************************************************;
  * #15 Central apnea index;
  * exclude studies with total sleep time = 0 or
  * for CAI with arousals, exclude studies scored sleep/wake
  ************************************************************************************;
    if slpprdp gt 0 then do;
      cai_c0 = 60*(carbp +  carop  + canbp  + canop ) / slpprdp;
      cai_c4 = 60*(carbp4 + carop4 + canbp4 + canop4 ) / slpprdp;
    end;

  ************************************************************************************;
  * #16 PERCENT TIME WITH SAO2 < 90,85,80,75
  ************************************************************************************;
      pctlt90 = pctsa90h;
      pctlt85 = pctsa85h;
      pctlt80 = pctsa80h;
      pctlt75 = pctsa75h;

  ************************************************************************************;
  * #18 MINIMUM SA02 IN REM, NREM
  * exclude studies scored as sleep/wake.
  ************************************************************************************;
      if mnsao2rh ne 0 then losao2r = mnsao2rh;
        else losao2r = .;

      if mnsao2nh ne 0 then losao2nr = mnsao2nh;
        else losao2nr = .;

  ************************************************************************************;
  * #19 AVERAGE SA02 DURING SLEEP
  ************************************************************************************;
      *create holder variable for average saO2 in rem which = 0 if there is no rem
        (avoids avgsat being missing due to missing value in calculation);
      if avsao2rh = . then avsao2rh_holder = 0;
        else avsao2rh_holder = avsao2rh;

      avgsat = ((avsao2nh) * (tmstg1p+tmstg2p+tmstg34p) + (avsao2rh_holder)*(tmremp))/100;
      drop avsao2rh_holder;

  ************************************************************************************;
  * #19 MINIMUM SA02 DURING SLEEP
  ************************************************************************************;
      if losao2r = . then minsat = losao2nr;
      else if losao2nr = . then minsat = losao2r;
      else minsat = min(losao2r,losao2nr);

  ************************************************************************************;
  * #20 AVERAGE HYPOPNEA LENGTH
  ************************************************************************************;
      hypopnea_denominator = sum(hrembp, hrop, hnrbp, hnrop);
      hypremback_numerator = max(hrembp, 0);
      hypremother_numerator = max(hrop, 0);
      hypnremback_numerator = max(hnrbp, 0);
      hypnremother_numerator = max(hnrop, 0);

      avghypdur = ((hypremback_numerator/hypopnea_denominator) * max(avhrbp,0)) +
                      ((hypremother_numerator/hypopnea_denominator) * max(avhrop,0)) +
                      ((hypnremback_numerator/hypopnea_denominator) * max(avhnbp,0)) +
                      ((hypnremother_numerator/hypopnea_denominator) * max(avhnop,0));

      drop hypopnea_denominator--hypnremother_numerator;



    *BestAIR AHI;
    *all obstructives/centrals, hypopneas with >=3% desat;
    if slpprdp gt 0 then do;
      ahi_a0h3 = 60*(hnrbp3 + hnrop3 + canbp + canop + oanbp + oanop + unrbp3 + unrop3) / slpprdp;
    end;

    drop filename;
  run;

*****************************************************************************************;
* quick checking for Mike Morrical;
*****************************************************************************************;
  proc sql;
    title "BestAIR PSG: Sleep latency missing from SAS report?";
    select pptid, stdatep, stloutp, stonsetp, slplatm, waso
    from pro2
    where slplatm < 0; title;
  quit;

  proc sql;
    title "BestAIR PSG: WASO missing or negative -- generated from SAS report variables";
    select pptid, stdatep, stloutp, stonsetp, timebedm, slplatm, slpprdm, slpprdp, waso
    from pro2
    where waso < 0; title;
  quit;

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

  data bestair_in (drop = pptid);
    format studyid best12.;
    set bestair_in;
    studyid = input(pptid,5.);
  run;

  proc sort data=bestair_in;
    by studyid stdydt;
  run;
