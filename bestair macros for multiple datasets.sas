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
