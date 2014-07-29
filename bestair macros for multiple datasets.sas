***********************************************;
* Macros that apply to wide variety of datasets
***********************************************;

***********************************************;
* Calculate age at particular timepoint;
***********************************************;
%macro add_ageattimepoint(dateoftimepoint, dateofbirth, ageattimepoint);

if &dateoftimepoint ne . and &dateofbirth ne .
  then do;
    unadj_age = year(&dateoftimepoint) - year(&dateofbirth)-1;
    monthdob = month(elig_incl01dob);
    monthtimepoint = month(&dateoftimepoint);
    daydob = day(elig_incl01dob);
    daytimepoint = day(&dateoftimepoint);

    if monthtimepoint > monthdob then &ageattimepoint = unadj_age + 1;
    else if monthtimepoint < monthdob then &ageattimepoint = unadj_age;
    else if daytimepoint ge daydob then &ageattimepoint = unadj_age + 1;
    else &ageattimepoint = unadj_age;

    drop unadj_age monthdob monthtimepoint daydob daytimepoint;

  end;

%mend add_ageattimepoint;

***********************************************;
* Create dummy dataset;
***********************************************;
*check if dataset exists and, if missing, create empty dataset with:
  variable &id_varname, format of &macrostore_idformat, with missing values in that format represented by &macrostore_idmisval;
*Code adapted from that written by Spencer Childress and Brandon Welch of SAS Institute: http://analytics.ncsu.edu/sesug/2011/CC19.Childress.pdf;

%macro create_emptydataset_ifmissing(dataset2check, id_varname, macrostore_idformat=best12., macrostore_idmisval=.);

 %local Exist NumObs;
 %let Exist = No;
 %let NumObs = 0;

 %if %sysfunc(exist(&dataset2check)) %then %let Exist = Yes;

 %if &Exist = Yes %then %do;
 %let DSNId = %sysfunc(open(&dataset2check));
 %let DSObs = %sysfunc(attrn(&DSNId.,nobs));
 %let rc = %sysfunc(close(&DSNId.));
 %let NumObs = &DSObs.;
 %end;

 %put;
 %put **************** Check for Existence of &dataset2check *******************;
 %put EXIST: &Exist;
 %put NUMBER OF OBS: &NumObs;
 %put **************************************************************************;

  %if &Exist = No or &NumObs = 0 %then %do;
    DATA &dataset2check;
      format &id_varname &macrostore_idformat;
      &id_varname = &macrostore_idmisval;
    RUN;
  %end;

%mend create_emptydataset_ifmissing;

***********************************************;
* Macros Check Values of Variables
***********************************************;

  ***** Print Lists of Variables that are either "NULL" or "non-NULL". Variable names have been storedin array-style variables (e.g. var1-var27)*****;
  *change prefix based on array; *null_value changed based on variable type; *options for null test are '=' or 'ne';
  %macro printlists_ofvars_basedonnull(datasetname=, id_var=elig_studyid, timepoint_var=redcap_event_name, prefix=var, num_ofvars=, null_value=., null_test=%str(=));
    %do i = 1 %to &num_ofvars;
      proc sql;
        select &id_var, &timepoint_var, &prefix&i
        from &datasetname
        where &prefix&i &null_test &null_value;
      quit;
    %end;
  %mend printlists_ofvars_basedonnull;

  ***** Create Table of Variables that are either "NULL" or "non-NULL". Variable names have been storedin array-style variables (e.g. var1-var27)*****;
  *change prefix based on array; *null_value changed based on variable type; *options for null test are '=' or 'ne';
  %macro createtable_ofvars_basedonnull(datasetname=, tablename=, id_var=elig_studyid, timepoint_var=redcap_event_name, prefix=var, num_ofvars=, null_value=., null_test=%str(=));

    *%create_emptydataset_ifmissing(&tablename, &id_var);
    proc sql noprint;
      create table &tablename
      (&id_var NUM, &timepoint_var CHAR(32), Variable_Name CHAR(32));
    quit;

    %do i = 1 %to &num_ofvars;
      proc sql noprint;
        insert into work.&tablename
        select &id_var, &timepoint_var, &prefix&i as Variable_Name
        from &datasetname
        where &prefix&i &null_test &null_value;
      quit;
    %end;
  %mend createtable_ofvars_basedonnull;
