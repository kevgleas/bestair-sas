****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\SAS\bestair options and libnames.sas";


*program set to be run after "redcap export.sas" (bestair\Data\SAS\redcap\_components\redcap export.sas)
  as part of "Run All.sas";
*specifically, program set to run during include steps of "update and check outcome data.sas";
*if running program independently, uncomment section labeled "IMPORT EXISTING DATASET";

/*
****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

  *create dataset by importing data from REDCap, where permanent data is stored;
  data redcap;
    set bestair.baredcap;
  run;
*/



*****************************************************************************************;
* READ IN DATA
*****************************************************************************************;

  data bestcal;
    set redcap;

    if cal_studyid > . and cal_studyid > 0;

    keep elig_studyid cal_namecode--calgary_complete;
  run;

  proc sort data=bestcal;
    by elig_studyid cal_studyvisit;
  run;


*****************************************************************************************;
* MANIPULATE DATA
*****************************************************************************************;

  * part 1;
  data  calgary1 (drop=variable value)
      missingcheck0 (keep=elig_studyid cal_studyvisit cal_datecompleted variable value);

    set bestcal;

    *********************************************************************************;
    * clean up missing values;
    *********************************************************************************;
    array rcd(*) _numeric_;
    do i=1 to dim(rcd);
      if rcd(i) < 0 then do;
        * output to missing check dataset;
        variable = vname(rcd(i));
        value = rcd(i);
        if rcd(i) in (.,-1,-10) then output missingcheck0;
        * recode to system missing;
        rcd(i) = .;
      end;
    end;
    drop i;

    array rcdc(*) _character_;
    do j=1 to dim(rcdc);
      if rcdc(j) in ("-10","-9","-8","-2","-1") then do;
        * output to missing check dataset;
        variable = vname(rcdc(j));
        value = rcdc(j);
        if rcdc(j) in ("-10") then output missingcheck0;
        * recode to system missing;
        rcdc(j) = "";
      end;
    end;
    drop j;

    * calculate daily functioning subscale;
    array cal_ai(11) cal_a01-cal_a11;

    do i=1 to 11;
      if cal_ai(i) < 1 or cal_ai(i) > 7 then cal_ai(i) = .;
    end;

    cal_anum = n(of cal_a01-cal_a11);
    cal_anmiss = nmiss(of cal_a01-cal_a11);

    if cal_anmiss le 2 then cal_araw = sum(of cal_a01-cal_a10);
    cal_amean = ((cal_araw)/(11-cal_anmiss));


    * calculate social interactions subscale;
    array cal_bi(13) cal_b01-cal_b13;

    do i=1 to 13;
      if cal_bi(i) < 1 or cal_bi(i) > 7 then cal_bi(i) = .;
    end;

    cal_bnum = n(of cal_b01-cal_b13);
    cal_bnmiss = nmiss(of cal_b01-cal_b13);

    if cal_bnmiss le 2 then cal_braw = sum(of cal_b01-cal_b13);
    cal_bmean = ((cal_braw)/(13-cal_bnmiss));


    * calculate emotional functioning subscale;
    array cal_ci(11) cal_c01-cal_c11;

    do i=1 to 11;
      if cal_ci(i) < 1 or cal_ci(i) > 7 then cal_ci(i) = .;
    end;

    cal_cnum = n(of cal_c01-cal_c11);
    cal_cnmiss = nmiss(of cal_c01-cal_c11);

    if cal_cnmiss le 2 then cal_craw = sum(of cal_c01-cal_c10);
    cal_cmean = ((cal_craw)/(11-cal_cnmiss));


    * calculate symptoms subscale;

    if cal_ds01p < 1 or cal_ds01p > 7 then cal_ds01p = .;
    if cal_ds02p < 1 or cal_ds02p > 7 then cal_ds02p = .;
    if cal_ds03p < 1 or cal_ds03p > 7 then cal_ds03p = .;
    if cal_ds04p < 1 or cal_ds04p > 7 then cal_ds04p = .;
    if cal_ds05p < 1 or cal_ds05p > 7 then cal_ds05p = .;

    cal_draw = sum(cal_ds01p, cal_ds02p, cal_ds03p, cal_ds04p, cal_ds05p);
    cal_dmean = ((cal_draw)/(5));

    drop cal_staffid cal_e01--cal_f02;

    output calgary1;
  run;

  proc sort data=missingcheck0;
    by elig_studyid;
  run;

  * part 2;
  data  calgary2 (drop=variable value)
      missingcheck (keep=elig_studyid cal_studyvisit cal_datecompleted variable value);

    set work.bestcal;

    *********************************************************************************;
    * clean up missing values;
    *********************************************************************************;
    array rcd(*) _numeric_;
    do i=1 to dim(rcd);
      if rcd(i) < 0 then do;
        * output to missing check dataset;
        variable = vname(rcd(i));
        value = rcd(i);
        if rcd(i) in (.,-1,-10) then output missingcheck;
        * recode to system missing;
        rcd(i) = .;
      end;
    end;
    drop i;

    array rcdc(*) _character_;
    do j=1 to dim(rcdc);
      if rcdc(j) in ("-10","-9","-8","-2","-1") then do;
        * output to missing check dataset;
        variable = vname(rcdc(j));
        value = rcdc(j);
        if rcdc(j) in ("-10") then output missingcheck;
        * recode to system missing;
        rcdc(j) = "";
      end;
    end;
    drop j;

    * calculate treatment-related symptoms subscale;
    if cal_es01p < 1 or cal_es01p > 7 then cal_es01p = .;
    if cal_es02p < 1 or cal_es02p > 7 then cal_es02p = .;
    if cal_es03p < 1 or cal_es03p > 7 then cal_es03p = .;
    if cal_es04p < 1 or cal_es04p > 7 then cal_es04p = .;
    if cal_es05p < 1 or cal_es05p > 7 then cal_es05p = .;

    cal_es01px = 7 - cal_es01p;
    cal_es02px = 7 - cal_es02p;
    cal_es03px = 7 - cal_es03p;
    cal_es04px = 7 - cal_es04p;
    cal_es05px = 7 - cal_es05p;

    cal_eraw = sum(cal_es01px, cal_es02px, cal_es03px, cal_es04px, cal_es05px);
    cal_emean = ((cal_eraw)/(5));

    * calculate impact subscale;
    if cal_f01 = . or cal_f02 = . then cal_fweight = .;
    else if cal_f01 > cal_f02 then cal_fweight = cal_f02 / cal_f01;
    else cal_fweight = 1;

    drop cal_staffid--cal_ds05p;

    output calgary2;
  run;

  proc sort data=missingcheck;
    by elig_studyid;
  run;

  * merge into single calgary dataset;
  data calgarymerge;
    merge calgary1 (in=a) calgary2 (in=b);
    by elig_studyid;

    cal_total = .;

    if nmiss(of cal_amean, cal_bmean, cal_cmean) = 0 and cal_studyvisit = 0 then do;
      cal_total = sum(of cal_amean, cal_bmean, cal_cmean, cal_dmean) / 4;
    end;
    else if nmiss(of cal_amean, cal_bmean, cal_cmean) = 0 and cal_studyvisit in (6,12) then do;
      if cal_emean = . then cal_emean = 0;
      if cal_fweight = . then cal_fweight = 0;
      cal_total = (sum(of cal_amean, cal_bmean, cal_cmean, cal_dmean) - (cal_emean * cal_fweight)) / 4;
    end;
  run;

/*
  *create frequency tables for calgary responses;

  proc freq data=calgarymerge;
    table cal_a01 -- cal_ds05p;
  run;

  proc freq data=calgarymerge;
    table cal_e01 -- cal_f02;
  run;
*/

*********************************************************************************;
* Update permanent datasets;
*********************************************************************************;

  data bestair.bestaircalgary bestair2.bestaircalgary_&sasfiledate;
    set calgarymerge;
  run;

