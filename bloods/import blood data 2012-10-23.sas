****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";


*program set to be run after "redcap export.sas" (bestair\Data\SAS\redcap\_components\redcap export.sas)
  as part of "Run All.sas";
*specifically, program set to run during include steps of "update and check outcome data.sas";
*if running program independently, uncomment section labeled "IMPORT EXISTING DATASET";


****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

  *create dataset by importing data from REDCap, where permanent data is stored;
  data redcap;
    set bestair.baredcap;
  run;


****************************************************************************************;
*  REFORMAT BLOOD DATA AND EXPORT TO PERMANENT DATABASE
****************************************************************************************;

*import blood data from REDCap;
data blood_in;
  set redcap(keep=elig_studyid bloods_studyid--bloods_urinecreatin);
  if bloods_studyid ne . and bloods_studyid ne -9;
run;


*set missing values (denoted in REDCap as -8 or -9) to null;
data blood_in;
  set blood_in;
  array blood_fixer[*] bloods_totalchol--bloods_urinecreatin;

  do i = 1 to dim(blood_fixer);
    if blood_fixer[i] < 0 then blood_fixer[i] = .;
  end;

  drop i;
run;

*create dataset of eligibility information;
data elig_info;
    set redcap;
    if elig_datecompleted ne .;
    keep elig_studyid elig_datecompleted--eligibility_complete;
run;

data blood_in;
  merge blood_in (in = a) elig_info (in = b keep = elig_studyid elig_incl01dob elig_gender elig_raceblack);
  by elig_studyid;
  if a;
run;

/*
*calculate Glomerular Filtration Rate (GFR);
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair macros for multiple datasets.sas";
data blood_in;
  set blood_in;
  format age_atvisit 3.;
  %add_ageattimepoint(bloods_datetest, elig_incl01dob, age_atvisit);
  drop elig_incl01dob;

  *Need to determine how to adjust urine creatinine values to comparable serum creatinine values;
  adjusted_creatinine = bloods_urinecreatin;

  if elig_gender in(1,2) and elig_raceblack in(0,1) then do;
    if elig_gender = 1 then do;
      denom_constant = 0.9;
      exp_constant = -0.411;
      bloods_gfr = 141 * (min((adjusted_creatinine/denom_constant),1)**exp_constant) * (max((adjusted_creatinine/denom_constant),1)**(-1.209))  * (0.993**age_atvisit);
    end;
    else if elig_gender = 2 then do;
      denom_constant = 0.7;
      exp_constant = -0.329;
      bloods_gfr = (141*1.018) * (min((adjusted_creatinine/denom_constant),1)**exp_constant) * (max((adjusted_creatinine/denom_constant),1)**-1.209) * (0.993**age_atvisit);
    end;

    if elig_raceblack = 1 then bloods_gfr = bloods_gfr*1.159;

  end;

  drop elig_gender--elig_raceblack age_atvisit denom_constant exp_constant;

  label bloods_gfr = "Glomerular Filtration Rate (GFR) (mL/min per 1.73m^2)";
  label adjusted_creatinine = "Adjusted Creatinine Level";


run;
*/


*check extreme values;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bloods\check extreme bloods values.sas";

*export to pemanent dataset;
data bestair.bestairbloods bestair2.bestairbloods_&sasfiledate;
  set blood_in;
run;
