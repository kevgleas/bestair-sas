****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

data redcap_bloods;
  set bestair.bestairbloods;
run;

ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\bloods\Bloods Extreme Values to Check &sasfiledate..PDF";

proc sql;

  title "Instances Where Total Cholesterol > 260 or < 115";
  select elig_studyid, bloods_studyvisit, bloods_totalchol
  from redcap_bloods
  where (bloods_totalchol > 260 or bloods_totalchol < 115) and bloods_totalchol ne .;
  title;

quit;


proc sql;

  title "Instances Where Triglycerides > 500";
  select elig_studyid, bloods_studyvisit, bloods_triglyc
  from redcap_bloods
  where bloods_triglyc > 500 and bloods_triglyc ne .;
  title;

quit;


proc sql;

  title "Instances Where HDL Cholesterol > 85 or < 25";
  select elig_studyid, bloods_studyvisit, bloods_hdlchol
  from redcap_bloods
  where (bloods_hdlchol > 85 or bloods_hdlchol < 25) and bloods_hdlchol ne .;
  title;

quit;

proc sql;

  title "Instances Where LDL Cholesterol Calc > 190";
  select elig_studyid, bloods_studyvisit, bloods_ldlcholcalc
  from redcap_bloods
  where bloods_ldlcholcalc > 190 and bloods_ldlcholcalc ne .;
  title;

quit;

proc sql;

  title "Instances Where Hemoglobin A1c > 15";
  select elig_studyid, bloods_studyvisit, bloods_hemoa1c
  from redcap_bloods
  where bloods_hemoa1c > 15 and bloods_hemoa1c ne .;
  title;

quit;

proc sql;

  title "Instances Where C-Reactive Protein > 50";
  select elig_studyid, bloods_studyvisit, bloods_creactivepro
  from redcap_bloods
  where bloods_creactivepro > 30 and bloods_creactivepro ne . and (
    (elig_studyid ne 70015 and bloods_studyvisit = 0) and /*kg693 checked 3/07/2014*/
    (elig_studyid ne 73068 and bloods_studyvisit = 0) and /*kg693 checked 3/07/2014*/
    (elig_studyid ne 73075 and bloods_studyvisit = 0) and /*kg693 checked 3/07/2014*/
    (elig_studyid ne 73075 and bloods_studyvisit = 6) and /*kg693 checked 3/07/2014*/
    (elig_studyid ne 73075 and bloods_studyvisit = 12) /*kg693 checked 3/07/2014*/
  );
  title;

quit;


proc sql;

  title "Instances Where Microalbumin, Urine > 250";
  select elig_studyid, bloods_studyvisit, bloods_urinemicro
  from redcap_bloods
  where bloods_urinemicro > 250 and bloods_urinemicro ne .;
  title;

quit;

proc sql;

  title "Instances Where Glucose, Serum > 300 or < 40";
  select elig_studyid, bloods_studyvisit, bloods_serumgluc
  from redcap_bloods
  where (bloods_serumgluc > 300 or bloods_serumgluc < 40) and bloods_serumgluc ne .;
  title;

quit;

*serum creatinine reference range 0.5-1.2 for men and 0.4 to 1.1 for women;

proc sql;

  title "Instances Where Serum Creatinine > 1.2 or < 0.4";
  select elig_studyid, bloods_studyvisit, bloods_serumcreatin
  from redcap_bloods
  where (bloods_serumcreatin > 1.2 or bloods_serumcreatin < 0.4) and bloods_serumcreatin ne .;
  title;

quit;

ods pdf close;
