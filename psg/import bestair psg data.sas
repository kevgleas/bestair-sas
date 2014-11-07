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

  *********************** IMPORT REDCAP Data *******************************;
  **************************************************************************;
  %include "&bestairpath\SAS\redcap\_components\bestair create rand set.sas";
  proc sql noprint;
    select elig_studyid into :randomized_list separated by ', '
    from randset;
  quit;

  data redcap_embletta;
    set redcap_all (keep = elig_studyid embqs_study_id--embletta_qs_complete);

    if embqs_study_id ne "";

    embqs_ahi = input(embqs_first_pass_ahi, 8.);

    array numeric_array[*] _numeric_;
    do i = 1 to dim(numeric_array);
      if numeric_array[i] in (-8,-9,-10) then numeric_array[i] = .;
    end;
    drop i;

    if embqs_unit_id in ("-8","-9","-10") then embqs_unit_id = "";
    if embqs_staff_id in ("-8","-9","-10") then embqs_staff_id = "";

  run;

  proc format;
    value psgpurposef
      0 = "0: Screening PSG"
      1 = "1: Final Visit PSG"
    ;
    value yesnof
      0 = "0: No"
      1 = "1: Yes"
    ;
    value ahisourcef
      1 = "1: Scored by BestAIR Staff"
      3 = "3: AHI3p recorded on Eligibility Form"
      4 = "4: (AHI4p reported on Eligibility Form)*1.25"
      9 = "9: 'First Pass' AHI3p recorded on Embletta QS"
    ;
  run;

  data redcap_embletta_withrand;
    merge randset redcap_embletta (in = b);
    by elig_studyid;
    if b;
    format redcap_psgpurpose psgpurposef.;
    if embqs_date_study_recorded < rand_date or rand_date = . then redcap_psgpurpose = 0;
    else redcap_psgpurpose = 1;
  run;

  data bestair_in_withrand;
    retain studyid rand_date stdydt import_psgpurpose;
    merge randset (rename = (elig_studyid = studyid)) bestair_in (in = b);
    by studyid;
    if b;
    format import_psgpurpose psgpurposef.;
    if stdydt < rand_date or rand_date = . then do
      import_psgpurpose = 0;
      screening = 1;
    end;
    else import_psgpurpose = 1;
  run;

  proc sql noprint;

    select distinct studyid into :toomanypsgs separated by ', '
    from bestair_in_withrand
    group by studyid
    having (count(*) ge 3 and rand_date ne .) OR (count(*) ge 2 and rand_date = .) OR (sum(screening) > 1);

  quit;

  data check4bestpsgs;
    set bestair_in_withrand;
    if studyid in (&toomanypsgs);
  run;

/*  proc sql;*/
/*    title 'Manually Select Proper PSG';*/
/*    select distinct studyid from check4bestpsgs;*/
/*  quit;*/


  *73141 first screening embletta had 1.5 hours unreliable oximetry and was retested on 8/08/2012 - pt data. from 7/24/2012 should be excluded;
  *82205 was reconsented and retested on 5/24/2013 - pt. data from 2/28/2012 should be excluded;
  *84319 - first "final" psg (10/22/2013) should be excluded for poor oximetry - use final psg from 1/08/2014 instead);

  data bestairpsg_max1pertimepoint;
    set bestair_in_withrand;
    by studyid;
    if studyid in (73143, 82205) then do;
      if not first.studyid then output bestairpsg_max1pertimepoint;
    end;
    else if studyid = 84319 then do;
      if first.studyid or last.studyid then output bestairpsg_max1pertimepoint;
    end;
    else output bestairpsg_max1pertimepoint;
  run;

  * import spreadsheet with list of variables not collected by Embletta as part of HSS;
  proc import out=null_for_embletta datafile = "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\bestair psg dd.xls" dbms = xls replace;
    mixed=yes;
    getnames = yes;
    sheet = "NULL_for_embletta";
    datarow = 2;
  run;

  proc sql noprint;
    select NAME into :vars_notin_hss separated by ' '
    from null_for_embletta;
  run;

  data bestair_cleanemblettavars;
    set bestairpsg_max1pertimepoint;

    array fullpsgvars[*] &vars_notin_hss;

    if embletta = 1 then do;
      do i = 1 to dim(fullpsgvars);
        fullpsgvars[i] = .;
      end;
    end;

    drop i;
  run;

  proc sql noprint;
    create table bestair_cleanemblettavars2 as
    select stdydt as recording_date, *
    from bestair_cleanemblettavars
    order by studyid, recording_date;
  quit;

  proc sql noprint;
    create table Redcap_embletta_withrand2 as
    select elig_studyid as studyid, embqs_date_study_recorded as recording_date, *
    from Redcap_embletta_withrand
    order by studyid, recording_date;
  quit;

  data psg_redcapmatch_orshc psg_missredcap redcap_nopsgmatch;
    retain studyid;
    format psgpurpose psgpurposef.;
    label psgpurpose = "PSG Purpose (0 = Screening; 1 = Final Visit)";
    retain recording_date;
    merge Redcap_embletta_withrand2 (in = a drop = elig_studyid) bestair_cleanemblettavars2 (in = b drop = screening);
    by studyid recording_date;

    psgpurpose = max(of import_psgpurpose redcap_psgpurpose);

    if shc = 1 then output psg_redcapmatch_orshc;
    else if a and b then output psg_redcapmatch_orshc;
    else if b then output psg_missredcap;
    else if a then output redcap_nopsgmatch;
  run;

  proc sql noprint;
    select studyid into :missing_redcapqs separated by ', '
    from psg_missredcap;
  quit;

  data checkfor_wrongimport;
    set psg_missredcap redcap_nopsgmatch;
    if studyid in (&missing_redcapqs);
  run;

  proc sort data = checkfor_wrongimport;
    by studyid psgpurpose;
  run;

  data checkfor_wrongimport;
    set checkfor_wrongimport;
    by studyid psgpurpose;
    if (first.psgpurpose and not last.psgpurpose) or (last.psgpurpose and not first.psgpurpose) or (not last.psgpurpose and not first.psgpurpose);
  run;

  proc sql;
    title 'Check for PSG being exported to SAS Reports';
    select distinct studyid,  psgpurpose, max(stdydt) format = mmddyy. label = "PSG Import Recording Date", max(AHIU3),
                              max(embqs_date_study_recorded) format = mmddyy. label = "REDCap Recording Date", max(embqs_ahi) label = "REDCap AHI"
    from checkfor_wrongimport
    group by studyid
    ;
  quit;


  data bestair_psgall;
    merge psg_redcapmatch_orshc psg_missredcap;
    by studyid recording_date;
  run;

  proc sql noprint;

    select distinct studyid into :missingqs_fordate separated by ', '
    from bestair_psgall
    group by studyid
    having (stdydt = . and embletta = 1 and embqs_date_study_recorded ne .) OR (stdydt ne . and embqs_date_study_recorded = . and embletta = 1);

    select distinct studyid into :nomatchingpsg_forqs separated by ', '
    from bestair_psgall
    group by studyid
    having (embqs_date_study_recorded ne . and stdydt = .);

  quit;

  data checkqs_forid;
    set bestair_psgall;
    if studyid in (&missingqs_fordate);
  run;

  data checkpsg_forid;
    set bestair_psgall;
    if studyid in (&nomatchingpsg_forqs);
  run;

  proc sql ;

    title 'Embletta: No Embletta QS entered in REDCap for PSG imported into Dataset';
    select studyid, stdydt, embqs_date_study_recorded
    from bestair_psgall
    where (stdydt = . and embletta = 1 and embqs_date_study_recorded ne .) OR (stdydt ne . and embqs_date_study_recorded = . and embletta = 1);

    title 'No matching PSG for REDCap form';
    select studyid, stdydt, embqs_date_study_recorded
    from bestair_psgall
    where (embqs_date_study_recorded ne . and stdydt = . and studyid not in(&toomanypsgs));

  quit;

  data rand_eligahi;
    set bestair.bestaireligibility;
    if randomized = 1;
    psgpurpose = 0;
    keep elig_studyid psgpurpose elig_incl03osaahi--elig_incl03osa4 randomized;
  run;

  data bestair_psg_addedvars;
    merge bestair_psgall rand_eligahi (rename = (elig_studyid = studyid));
    by studyid psgpurpose;


    if ahiu3 ne . then do;
      ahi_primary = ahiu3;
      ahi_primary_source = 1;
    end;
    else if elig_incl03osa4 = 1 and elig_incl03osa3 = 0 then do;
      ahi_primary = elig_incl03osaahi*1.25;
      ahi_primary_source = 4;
    end;
    else do;
      ahi_primary = elig_incl03osaahi;
      ahi_primary_source = 3;
    end;

    if ahi_primary = . then do;
      ahi_primary = embqs_ahi;
      ahi_primary_source = 9;
    end;

    if ahi_primary ge 30 then ahi_primary_ge30 = 1;
    else if ahi_primary ne . then ahi_primary_ge30 = 0;


    if studyid in(&randomized_list) then randomized = 1;

    format ahi_primary_source ahisourcef. ahi_primary_ge30 yesnof.;

    drop rand_date embletta_qs_complete redcap_psgpurpose import_psgpurpose;
  run;
/*
  proc sql;
    title "";
    select studyid, psgpurpose, elig_incl03osaahi, embqs_ahi, AHIU3, ahi_a0h3
    from bestair_psg_addedvars
    where abs(elig_incl03osaahi - embqs_ahi) ge 1;
  quit;

  proc sql;
    select studyid, psgpurpose, elig_incl03osaahi, elig_incl03osa3, elig_incl03osa4, ahi_primary
    from bestair_psg_addedvars
    where embletta = . and ahiu3 = .;
  quit;

  proc sql;
    select studyid, psgpurpose, embletta, ahiu3,elig_incl03osaahi, elig_incl03osa3, elig_incl03osa4, ahi_primary
    from bestair_psg_addedvars
    where abs(ahiu3-elig_incl03osaahi) ge 1;
  quit;
*/
/**/
/*  data random_baselinepsg;*/
/*    set bestair_psg_addedvars;*/
/*    if randomized = 1 and psgpurpose = 0;*/
/*  run;*/

  data bestair_psgfinal;
    format studyid best12. randomized yesnof. final_visit best12.;
    label randomized = "Was Pt. Randomized?";
    label final_visit = "Expected Final Visit";
    merge bestair_psg_addedvars (in = a) bestair.bamedicationcat(keep = elig_studyid final_visit rename = (elig_studyid=studyid));
    by studyid;
    if a;

    drop elig_incl03osaahi--elig_incl03osa4;
  run;

  %let bestairpsg_datasetname = bestair_psgfinal;
  %include "&bestairpath\sas\psg\bestair psg labels.sas";

  data bestair.bestairpsg bestair2.bestairpsg_&sasfiledate;
    set bestair_psgfinal;
  run;

/*
  proc contents data = bestair_psgfinal out = bestairpsg_contents;
  run;

  data bestairpsg_contents;
    set bestairpsg_contents;
    keep NAME--NOBS;
  run;

  proc export data = bestairpsg_contents outfile = "\\rfa01\bwh-sleepepi-home\users\public\bestair_psgdata_contents_2014-03-12.csv" dbms = csv replace;
  run;
