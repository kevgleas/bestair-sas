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
