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
  set redcap(keep=elig_studyid bloods_studyid--bloods_urinecreatin bloods2_studyid--bloods_pai1);
  if (bloods_studyid ne . and bloods_studyid ne -9) or (bloods2_studyid ne . and bloods2_studyid ne -9);
run;

data blood_fastingdata;
  set redcap(keep=elig_studyid bloods_studyid bloods2_studyid bloods_studyvisit fastqc_urineperformed--fastqc_venicomments dev_datediscovered--dev_codeother);
  if (bloods_studyid ne . and bloods_studyid ne -9) or (bloods2_studyid ne . and bloods2_studyid ne -9);
run;

data blood_compacted (drop = bloods2_studyid--bloods2_studyvisit) blood1_blood2_conflict;
  set blood_in;

  if (bloods_studyid ne bloods2_studyid and bloods2_studyid ne .) or (bloods_datetest ne bloods2_datetest and bloods2_datetest ne .) 
      or (bloods_studyvisit ne bloods2_studyvisit and bloods2_studyvisit ne .) then output blood1_blood2_conflict;

  if bloods_studyid in (.,-9) and bloods2_studyid not in (.,-9) then bloods_studyid = bloods2_studyid;
  if bloods_namecode in (""," ","-9") and bloods2_namecode not in (""," ","-9") then bloods_namecode = bloods2_namecode;
  if bloods_datetest in (.,-9) and bloods2_datetest not in (.,-9) then bloods_datetest = bloods2_datetest;
  if bloods_studyvisit in (.,-9) and bloods2_studyvisit not in (.,-9) then bloods_studyvisit = bloods2_studyvisit;

  output blood_compacted;

run;

*set missing values (denoted in REDCap as -8 or -9) to null;
data blood_fixed;
  set blood_compacted;
  array blood_fixer[*] bloods_totalchol--bloods_pai1;

  do i = 1 to dim(blood_fixer);
    if blood_fixer[i] < 0 then blood_fixer[i] = .;
  end;

  drop i;

  *calculate albumin-creatinine ratio;
  *convert albumin units from ug/mL to ug/dL by multiplying times 100;
  bloods_albumin_creatin_ratio = (bloods_urinemicro*100)/bloods_urinecreatin;
  label bloods_albumin_creatin_ratio = "Urine Albumin/Creatinine Ratio, ACR (ug/mg)";

  bloods_gfr = .;


run;

data blood_fastingdata2;
  set blood_fastingdata;
  format fastqc_venifast yesnof.;
run;

data blood_fastingdata_processed (drop = bloods2_studyid dev_datediscovered--dev_codeother);
  set blood_fastingdata;
  if bloods_studyid in (.,-9) and bloods2_studyid not in (.,-9) then bloods_studyid = bloods2_studyid;

  if fastqc_urinefast = . and fastqc_venifast = . then do;
    if dev_code = 21 and find(lowcase(dev_descripdev), 'fast') > 0 then do;
      if find(lowcase(dev_descripdev), 'urine') > 0 then do;
        fastqc_urinefast = 0;
        fastqc_urinecomments = "Not fasting for Urine Collection per Proctocol Deviation";
      end;
      if find(lowcase(dev_descripdev), 'blood') > 0 or find(lowcase(dev_descripdev), 'venipuncture') > 0 then do;
        fastqc_venifast = 0;
        fastqc_venicomments = "Not fasting for Venipuncture per Proctocol Deviation";
      end;
    end;
  end;
run;

proc freq data = blood_fastingdata_processed;
  table fastqc_urinefast;
  table fastqc_venifast;
run;

*create dataset of eligibility information;
data elig_info;
    set bestair.Bestair_alldata_randomizedpts;
    keep elig_studyid elig_incl01dob_s1 elig_gender_s1 elig_raceblack_s1;
run;

proc import file = "&bestairpath\Participant Assay Results\Participant Assay Results 2014-07-09.xlsx" out = new_assay_results_in dbms = xlsx replace;
  guessingrows = 1500;
  getnames = yes;
  sheet = "Sheet1";
run;

data new_assay_results (rename = (subject_ID = elig_studyid Sample_Date = bloods_datetest));
  set new_assay_results_in;
  *delete non-randomized subject;
  if Subject_ID ne 81259 and not (Subject_ID = 73474 and Sample_Date = mdy(12,3,2013));

  quantitative_result_num = input(quantitative_result,best32.);
  rename quantitative_result = quantitative_result_char;
run;

proc sort data = new_assay_results;
  by elig_studyid bloods_datetest TestName;
run;
/*
proc import file = "&bestairpath\Participant Assay Results\Pending Assays 2014-06-19.xlsx" out = pending_assay_results_in dbms = xlsx replace;
  guessingrows = 50;
  getnames = yes;
  sheet = "Sheet1";
run;

proc sort data = pending_assay_results_in;
  by elig_studyid bloods_datetest testname;
run;

data new_assay_results2;
  merge pending_assay_results_in new_assay_results;
  by elig_studyid bloods_datetest testname;
run;
*/

proc sort data = blood_fixed out = blood_sorted;
  by elig_studyid bloods_datetest;
run;

data new_assay_results_withtimepoint;
  merge blood_sorted (keep = elig_studyid bloods_datetest bloods_studyvisit) new_assay_results;
  by elig_studyid bloods_datetest;

  *change dates for 2 subjects who came in for blood draw at later date than visit - merging won't work otherwise;
  if elig_studyid = 71176 and bloods_datetest = mdy(8,27,2012) then bloods_studyvisit = 12;
  else if elig_studyid = 82019 and bloods_datetest = mdy(8,24,2012) then bloods_studyvisit = 0;
run;

data new_assay_results_withtimepoint;
  set new_assay_results_withtimepoint;
  if quantitative_result_char ne "";
  if elig_studyid = 70016 and bloods_studyvisit = . then bloods_studyvisit = study_visit;
  if elig_studyid = 73113 and bloods_studyvisit = . then bloods_studyvisit = study_visit;
run;

proc sql;
  title "Spreadsheet Blood Study Visit does not equal REDCap Blood Study Visit";
  select elig_studyid, bloods_studyvisit, study_visit
  from new_assay_results_withtimepoint
  where bloods_studyvisit ne study_visit;
  title;
quit;

proc sort data = new_assay_results_withtimepoint nodupkey;
  by elig_studyid bloods_studyvisit TestName quantitative_result_num;
run;


*Ignore units. Units are equivalent for each test but were sometimes recorded wrong in tracking system;

data IL_6_results (rename = (quantitative_result_num = bloods_IL6_spreadsheet)) 
      insulin_results (rename = (quantitative_result_num = bloods_insulinfast_spreadsheet)) 
      PAI_1_results (rename = (quantitative_result_num = bloods_PAI1_spreadsheet));
  set new_assay_results_withtimepoint;
  if TestName= "IL-6" then output IL_6_results;
  else if TestName= "Insulin" then output insulin_results;
  else if TestName= "PAI-1" then output PAI_1_results;
run;

data blood_fasting_plus_elig_data;
  merge Blood_fastingdata_processed (in = a drop = bloods_studyid) elig_info (in = b);
  by elig_studyid;
  if a;
run;

data blood_allmerged;
  merge blood_fixed blood_fasting_plus_elig_data IL_6_results (keep = elig_studyid bloods_studyvisit bloods_IL6_spreadsheet) 
        insulin_results (keep = elig_studyid bloods_studyvisit bloods_insulinfast_spreadsheet) PAI_1_results (keep = elig_studyid bloods_studyvisit bloods_PAI1_spreadsheet);
  by elig_studyid bloods_studyvisit;
  label bloods_IL6 = "Interleukin 6, IL-6 (pg/mL)"
        bloods_insulinfast = "Insulin, Fasting (uIU/mL)"
        bloods_PAI1 = "Plasminogen Activator Inhibitor-1, PAI-1 (ng/mL)";
run;


*calculate Glomerular Filtration Rate (GFR);
*using MDRD study method;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair macros for multiple datasets.sas";

data blood_out;
  set blood_allmerged;
  format age_atvisit 3.;
  %add_ageattimepoint(bloods_datetest, elig_incl01dob_s1, age_atvisit);

  if bloods_IL6 =. then bloods_IL6 = bloods_IL6_spreadsheet;
  if bloods_insulinfast =. then bloods_insulinfast = bloods_insulinfast_spreadsheet;
  if bloods_PAI1 =. then bloods_PAI1 = bloods_PAI1_spreadsheet;


  if elig_gender_s1 = 1 then gender_constant = 1;
  else if elig_gender_s1 = 2 then gender_constant = 0.742;

  if elig_raceblack_s1 = 1 then race_constant = 1.212;
  else if elig_raceblack_s1 = 0 then race_constant = 1;

  bloods_gfr = 175 * (bloods_serumcreatin**(-1.154)) * (age_atvisit**(-0.203)) * race_constant * gender_constant;

  *drop elig_gender--elig_raceblack age_atvisit race_constant*gender_constant;

  label bloods_gfr = "Glomerular Filtration Rate (GFR) (mL/min per 1.73m^2)";
  *label bloods2_serumcreatin = "Serum Creatinine";


run;


/*

*calculate Glomerular Filtration Rate (GFR);
*using The CKD-EPI Equation for Estimating GFR on the Natural Scale (Levey AS, 2009 from Annals of Internal Medicine);
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair macros for multiple datasets.sas";
data blood_out;
  set blood_out;
  format age_atvisit 3.;
  %add_ageattimepoint(bloods_datetest, elig_incl01dob_s1, age_atvisit);
  drop elig_incl01dob;


  if elig_gender_s1 in(1,2) and elig_raceblack_s1 in(0,1) then do;
    if elig_gender_s1 = 1 then do;
      denom_constant = 0.9;
      exp_constant = -0.411;
      bloods_gfr = 141 * (min((bloods_urinecreatin/denom_constant),1)**exp_constant) * (max((bloods_urinecreatin/denom_constant),1)**(-1.209))  * (0.993**age_atvisit);
    end;
    else if elig_gender_s1 = 2 then do;
      denom_constant = 0.7;
      exp_constant = -0.329;
      bloods_gfr = (141*1.018) * (min((bloods_urinecreatin/denom_constant),1)**exp_constant) * (max((bloods_urinecreatin/denom_constant),1)**-1.209) * (0.993**age_atvisit);
    end;

    if elig_raceblack_s1 = 1 then bloods_gfr = bloods_gfr*1.159;

  end;

  *drop elig_gender--elig_raceblack age_atvisit denom_constant exp_constant;

  label bloods_gfr = "Glomerular Filtration Rate (GFR) (mL/min per 1.73m^2)";
  label serum_creatinine = "Serum Creatinine";


run;
*/


data blood_out;
  set blood_out (drop = elig_incl01dob_s1--race_constant);
  if bloods_studyvisit ne .;
run;

*export to pemanent dataset;
data bestair.bestairbloods bestair2.bestairbloods_&sasfiledate;
  set blood_out;
run;

*check extreme values;
*%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bloods\check extreme bloods values.sas";
