*******************************************
*
*   BestAIR Medication Frequency Analysis
*
*******************************************;

  %include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";
  %include "&bestairpath\sas\bestair macros for multiple datasets.sas";

  data meds_in;
    set bestair.bamedication_match;
  run;

  *import list of all expected visits with final visits denoted;
  proc import datafile = "&bestairpath\Kevin\List of All Expected Visits.csv"
    out = all_expected_visits
    dbms = csv
    replace;
    getnames = yes;
  run;

  data final_expected_visit (keep = elig_studyid final_visit);
    set all_expected_visits;
    by elig_studyid;

    if last.elig_studyid then do;
      final_visit = timepoint;
      output final_expected_visit;
    end;

  run;

  *import daily defined dose (DDD) information;
  proc import datafile = "&bestairpath\sas\medications\ATC2011_ddd.csv"
    out = atc_ddd_codes
    dbms = csv
    replace;
    getnames = yes;
    guessingrows = 2500;
  run;


  /*
  proc sql noprint;
    create table atccode1_ddd as
    select elig_studyid, medname, atccode1, atc_ddd_codes.DDD as dddcode1, atc_ddd_codes.UnitType as unittype1
    from meds_in as a, atc_ddd_codes as b
      where a.atccode1 = b.ATCCode
    order by elig_studyid, atccode1;
  quit;

  proc sort data = atccode1_ddd nodupkey;
    by elig_studyid medname atccode1 dddcode1 unittype1;
  run;

  proc sql noprint;
    create table atccode2_ddd as
    select elig_studyid, medname, atccode2, atc_ddd_codes.DDD as dddcode2, atc_ddd_codes.UnitType as unittype2
    from meds_in as a, atc_ddd_codes as b
      where a.atccode2 = b.ATCCode
    order by elig_studyid, atccode2;
  quit;

  proc sort data = atccode2_ddd nodupkey;
    by elig_studyid medname atccode2 dddcode2 unittype2;
  run;

    proc sql noprint;
    create table atccode3_ddd as
    select elig_studyid, medname, atccode3, atc_ddd_codes.DDD as dddcode3, atc_ddd_codes.UnitType as unittype3
    from meds_in as a, atc_ddd_codes as b
      where a.atccode3 = b.ATCCode
    order by elig_studyid, atccode3;
  quit;

  proc sort data = atccode3_ddd nodupkey;
    by elig_studyid medname atccode3 dddcode3 unittype3;
  run;

  data check4dosingdiffs;
    merge atccode1_ddd atccode2_ddd atccode3_ddd;
    by elig_studyid medname;
  run;


  data atc_ddd_codes_oral;
    set atc_ddd_codes;
    if AdmCode = "O";
  run;


  proc sql noprint;
    create table atccode1_ddd as
    select elig_studyid, medname, atccode1, atc_ddd_codes_oral.DDD as dddcode1, atc_ddd_codes_oral.UnitType as unittype1
    from meds_in as a, atc_ddd_codes_oral as b
      where a.atccode1 = b.ATCCode
    order by elig_studyid, atccode1;
  quit;

  proc sort data = atccode1_ddd nodupkey;
    by elig_studyid medname atccode1 dddcode1 unittype1;
  run;

  proc sql noprint;
    create table atccode2_ddd as
    select elig_studyid, medname, atccode2, atc_ddd_codes_oral.DDD as dddcode2, atc_ddd_codes_oral.UnitType as unittype2
    from meds_in as a, atc_ddd_codes_oral as b
      where a.atccode2 = b.ATCCode
    order by elig_studyid, atccode2;
  quit;

  proc sort data = atccode2_ddd nodupkey;
    by elig_studyid medname atccode2 dddcode2 unittype2;
  run;

  proc sql noprint;
    create table atccode3_ddd as
    select elig_studyid, medname, atccode3, atc_ddd_codes_oral.DDD as dddcode3, atc_ddd_codes_oral.UnitType as unittype3
    from meds_in as a, atc_ddd_codes_oral as b
      where a.atccode3 = b.ATCCode
    order by elig_studyid, atccode3;
  quit;

  proc sort data = atccode3_ddd nodupkey;
    by elig_studyid medname atccode3 dddcode3 unittype3;
  run;

  proc sql noprint;
    create table atccode4_ddd as
    select elig_studyid, medname, atccode4, atc_ddd_codes_oral.DDD as dddcode4, atc_ddd_codes_oral.UnitType as unittype4
    from meds_in as a, atc_ddd_codes_oral as b
      where a.atccode4 = b.ATCCode
    order by elig_studyid, atccode4;
  quit;

  proc sort data = atccode4_ddd nodupkey;
    by elig_studyid medname atccode4 dddcode4 unittype4;
  run;

  proc sql noprint;
    create table atccode5_ddd as
    select elig_studyid, medname, atccode5, atc_ddd_codes_oral.DDD as dddcode5, atc_ddd_codes_oral.UnitType as unittype5
    from meds_in as a, atc_ddd_codes_oral as b
      where a.atccode5 = b.ATCCode
    order by elig_studyid, atccode5;
  quit;

  proc sort data = atccode5_ddd nodupkey;
    by elig_studyid medname atccode5 dddcode5 unittype5;
  run;

  data check4dosingdiffs;
    merge atccode1_ddd atccode2_ddd atccode3_ddd atccode4_ddd atccode5_ddd;
    by elig_studyid medname;

    array ddd_array[*] dddcode1-dddcode5;

    do i = 1 to (dim(ddd_array)-1);
      if ddd_array[i] ne ddd_array[i+1] and ddd_array[i] ne . and ddd_array[i+1] ne . then discrepancy = 1;
    end;
    drop i;

    if discrepancy = 1 then output check4dosingdiffs;
  run;
*/


****************************************;
*  PROCESS AND CHECK MEDICATIONS;
****************************************;

  *divide data into 3 sets:
    1. med_freq (medications are not prn and have frequency recorded)
    2. prn_list (PRN medications only)
    3. med_freq_error (frequency or dosage of medication is missing or not conformed to accepted standard)
  ;
  data med_frequency med_freq_error prn_list;
    set meds_in;

    if lowcase(med_freq) in("daily", "day", "once/day", "qd", "qpm", "1/day", "1","daily/day") then dailydose = 1;
    else if lowcase(med_freq) in("2", "2 times/day", "2/daily", "2/day", "2x/day", "bid", "twice a day", "twice/daily", "twice/day", "twice", "twice daily", "twice/day for course of tx") then dailydose = 2;
    else if lowcase(med_freq) in("3 times/day", "3/day", "three times / day", "three times/daily", "three times/day", "3 times a day", "3x/day") then dailydose = 3;
    else if lowcase(med_freq) in("4", "4 times/day", "4/day", "four times / day", "four times/daily", "qid", "4x/day", "4 times per day") then dailydose = 4;
    else if lowcase(med_freq) in("1-2 times/day", "1.5", "once-twice daily", "once-twice/daily") then dailydose = 1.5;
    else if lowcase(med_freq) in("once ever other day", "every other day", "alternate days", "once every other day") then dailydose = 0.5;
    else if lowcase(med_freq) in("1/week", "qw", "weekly", "once a week") then dailydose = 1/7;
    else if lowcase(med_freq) in("2/week", "twice a week", "1 a day on mon & wed") then dailydose = 2/7;
    else if lowcase(med_freq) in("3 times a week", "3/week") then dailydose = 3/7;
    else if lowcase(med_freq) in("4/week", "4x/week") then dailydose = 4/7;
    else if lowcase(med_freq) in("5/week") then dailydose = 5/7;
    else if lowcase(med_freq) in("6/day") then dailydose = 6;
    else if lowcase(med_freq) in("3-4x/day") then dailydose = 3.5;
    else if lowcase(med_freq) in("4-6 hours") then dailydose = 5;
    else if lowcase(med_freq) in("1/month", "once/monthly", "once/month") then dailydose = (1/7)/4;

    if med_dose < 0 then med_dose = .;

    dosage = med_dose * dailydose;

    if find(med_freq, "prn", 'i') > 0 or find(med_freq, "as needed", 'i') > 0 then med_prn = 1;

    if dosage = . and med_prn ne 1 then output med_freq_error;
    else if med_prn = 1 then output prn_list;
    else output med_frequency;

  run;

  data med_freq_error2fix;
    set med_freq_error;

    if find(lowcase(mednames),"uncategorizable") = 0 and find(lowcase(mednames),"omega") = 0 and find(lowcase(mednames),"vitamin") = 0 and find(lowcase(medname),"vitamin") = 0
        and find(lowcase(medname),"insulin") = 0 and find(lowcase(med_strength),"%") = 0 and lowcase(med_type) not in("cream","gel", "sliding scale");

    keep elig_studyid--med_freq;

  run;

  proc sql;
    title "Problem with Medication Dose or Frequency";
    select elig_studyid, medname, med_strength, med_dose, med_type, med_freq
    from med_freq_error2fix;
    title;
  quit;
/*
  proc sort data = med_freq_error;
  by medname;
  run;

  proc sql;
    create table prn_meds as
    select elig_studyid, medname, med_freq
    from med_freq
    where dailydose = .;
  quit;


  data strength_test;
    set meds_in;

    var2=input(compress(med_strength,,"kd"),best.);
  run;
*/

  data no_strengthlisted nontypical_strength typical_strength;
    set med_frequency;

    if med_strength in ("","-8", "-9", "-10") then output no_strengthlisted;
    else if anypunct(med_strength) = 0 then output typical_strength;
    else do;
      if find(med_strength,".") = 0 then output nontypical_strength;
      else if find(med_strength,".") > 0 and ((anypunct(med_strength) < find(med_strength,".")) or anypunct(med_strength, find(med_strength,".")+1)) then output nontypical_strength;
      else output typical_strength;
    end;
  run;
/*
  data other_than_typical;
    set no_strengthlisted nontypical_strength med_freq_error prn_list;
  run;

  proc sort data = other_than_typical;
    by elig_studyid medname;
  run;

  data ruhroh;
    merge typical_strength (in = a) other_than_typical (in = b);
    by elig_studyid medname;
    if a and b;
  run;
*/


  data no_strengthlisted2fix;
    set no_strengthlisted;

    if find(lowcase(mednames),"uncategorizable") = 0 and find(lowcase(mednames),"omega") = 0 and find(lowcase(mednames),"vitamin") = 0 and find(lowcase(medname),"vitamin") = 0
        and find(lowcase(medname),"insulin") = 0 and find(lowcase(med_strength),"%") = 0 and lowcase(med_type) not in("cream","gel", "sliding scale");

    keep elig_studyid--med_freq;

  run;

  proc sql;
    title "Medication Missing Strength";
    select elig_studyid, medname, med_strength, med_dose, med_type, med_freq
    from no_strengthlisted2fix;
    title;
  quit;

  data probable_combomeds probablenot_combomeds;
    set nontypical_strength;

    if find(medname, "+") > 0 or (find(med_strength, "unit", 'i') = 0 and find(med_strength, "puff", 'i') = 0 and find(med_strength, "drop", 'i') = 0) then do;
      if lowcase(substr(medname, 1, 7)) not in ("insulin", "warfari", "fish oi")
        and (find(med_strength,"/") > 0 or find(med_strength,"-") > 0 or find(med_strength,"(") > 0 or find(med_strength,",") > 0) then output probable_combomeds;
      else output probablenot_combomeds;
    end;
    else output probablenot_combomeds;

  run;

  data combination_bpmeds;
    set probable_combomeds;
    if find(lowcase(medname), "lisinopril") > 0 or find(lowcase(medname), "olmesartan") > 0 or find(lowcase(medname), "valsartan") > 0
        or find(lowcase(medname), "triamterene") > 0 or find(lowcase(medname), "quinapril") > 0;
  run;

  proc sort data = no_strengthlisted;
  by medname;
  run;

  data dailyamount unable2identify_units;
    set typical_strength (where = (med_prn ne 1));

    format origstrength_numvalue 12.5 origstrength_units $12. adjstrength_numvalue 12.5 adjstrength_units $12.;

    *as of 1/30/14, any non-vitamins that are missing units have standard unit measurement of "mg";
    if find(mednames,"vitamin",'i') = 0 and find(medname,"vitamin",'i') = 0 then do;
      if anyalpha(med_strength) = 0 then med_strength = cat(trim(put(med_strength,12.)), " mg");
    end;

    origstrength_numvalue = input(compress(med_strength,".","kd"),best.);

    if find(lowcase(med_strength), "unit/ml") or find(lowcase(med_strength), "units/ml") then do;
      origstrength_units = "units/mL";
      adjstrength_numvalue = origstrength_numvalue;
      adjstrength_units = "units/mL";
    end;

    else if find(lowcase(med_strength), "unit") or find(lowcase(med_strength), "iu") or find(lowcase(med_strength), "i.u") or find(lowcase(med_strength), " u") then do;
      origstrength_units = "units";
      adjstrength_numvalue = origstrength_numvalue;
      adjstrength_units = "units";
    end;

    else if find(lowcase(med_strength), "ml") then do;
      origstrength_units = "mL";
      adjstrength_numvalue = origstrength_numvalue;
      adjstrength_units = "mL";
    end;

    else if find(lowcase(med_strength), "cc") then do;
      origstrength_units = "cc";
      adjstrength_numvalue = origstrength_numvalue;
      adjstrength_units = "mL";
    end;

    else if find(lowcase(med_strength), "mg") then do;
      origstrength_units = "mg";
      adjstrength_numvalue = origstrength_numvalue;
      adjstrength_units = "mg";
    end;

    else if find(lowcase(med_strength), "mcg") then do;
      origstrength_units = "mcg";
      adjstrength_numvalue = origstrength_numvalue/1000;
      adjstrength_units = "mg";
    end;


    else if find(lowcase(med_strength), "g") then do;
      origstrength_units = "g";
      adjstrength_numvalue = origstrength_numvalue*1000;
      adjstrength_units = "mg";
    end;

    *1 mEq of Potassium Chloride = 75 mg;
    else if find(lowcase(med_strength), "meq") and lowcase(medname) = "potassium chloride" then do;
      origstrength_units = "mEq";
      adjstrength_numvalue = origstrength_numvalue*75;
      adjstrength_units = "mg";
    end;

    dailyamount_taken = dosage*adjstrength_numvalue;
    dailyamount_taken_units = adjstrength_units;


    if origstrength_units = "" then output unable2identify_units;
    else output dailyamount;
  run;

  data dailyamount_combination_bpmeds;
    set combination_bpmeds;

    adjstrength_numvalue_med1  = input(compress((scan(med_strength,1," -/")),".","kd"),best.);
    adjstrength_numvalue_med2  = input(compress((scan(med_strength,2," -/")),".","kd"),best.);

    dailyamount_taken_med1 = dosage*adjstrength_numvalue_med1;
    dailyamount_taken_med2 = dosage*adjstrength_numvalue_med2;
    dailyamount_taken_units_med1 = "mg";
    dailyamount_taken_units_med2 = "mg";

  run;

  proc sql;
    title "Medication Strength Missing Units";
    select elig_studyid, medname, med_strength
    from unable2identify_units
    where anyalpha(med_strength) = 0;

    title "Medication Strength Unable to be Converted to Standard Measure";
    select elig_studyid, medname, med_strength
    from unable2identify_units
    where anyalpha(med_strength) > 0;
  quit;

  proc freq data = dailyamount (where = (anyalpha(med_strength) = 0));
    tables med_strength;
  run;

  proc sql;
    create table total_dailyamount_1 as
    select elig_studyid, medname, dailyamount_taken, dailyamount_taken_units, sum(dailyamount_taken) as totalamount_taken1, timepoint1, timepoint2, timepoint3
    from work.dailyamount
    where timepoint1 = 1
    group by elig_studyid, medname;

    create table total_dailyamount_2 as
    select elig_studyid, medname, dailyamount_taken, dailyamount_taken_units, sum(dailyamount_taken) as totalamount_taken2, timepoint1, timepoint2, timepoint3
    from work.dailyamount
    where timepoint2 = 1
    group by elig_studyid, medname;

    create table total_dailyamount_3 as
    select elig_studyid, medname, dailyamount_taken, dailyamount_taken_units, sum(dailyamount_taken) as totalamount_taken3, timepoint1, timepoint2, timepoint3
    from work.dailyamount
    where timepoint3 = 1
    group by elig_studyid, medname;

    title "Total amount taken differs from daily amount - indicates program success";
    select elig_studyid, medname
    from total_dailyamount_1
    where dailyamount_taken ne totalamount_taken1;
  quit;

  proc sort data=total_dailyamount_1 nodupkey;
    by elig_studyid medname totalamount_taken1;
  run;

    proc sort data=total_dailyamount_2 nodupkey;
    by elig_studyid medname totalamount_taken2;
  run;

    proc sort data=total_dailyamount_3 nodupkey;
    by elig_studyid medname totalamount_taken3;
  run;

  *counts will be messed up for PRNs or medications missing strength/dose medications;
  *input -9 for these cases;
  data total_dailyamount (drop = timepoint1 timepoint2 timepoint3);
    merge total_dailyamount_1 total_dailyamount_2 total_dailyamount_3;
    by elig_studyid medname;

    if timepoint1 = 1 and totalamount_taken1 = . then totalamount_taken1 = -9;
    if timepoint2 = 1 and totalamount_taken2 = . then totalamount_taken2 = -9;
    if timepoint3 = 1 and totalamount_taken3 = . then totalamount_taken3 = -9;

  run;

  proc sql;
    title "Daily medication intake amounts differ between timepoints";
    select elig_studyid, medname, totalamount_taken1, totalamount_taken2, totalamount_taken3
    from total_dailyamount
    where totalamount_taken1 ne totalamount_taken2 or ((totalamount_taken2 ne totalamount_taken3) and totalamount_taken3 ne .) or ((totalamount_taken1 ne totalamount_taken3) and totalamount_taken3 ne .);
  quit;

  proc sql;
    title "Daily medication intake amounts differ by more than 300%";
    title2 "Might indicate error recorded in strength, units or frequency at dosage change";
    select elig_studyid, medname, totalamount_taken1, totalamount_taken2, totalamount_taken3
    from total_dailyamount
    where ((max(totalamount_taken1, totalamount_taken2) - min(totalamount_taken1, totalamount_taken2)) > 3*min(totalamount_taken1, totalamount_taken2)
            and totalamount_taken1 ne . and totalamount_taken2 ne .) or
          ((max(totalamount_taken1, totalamount_taken3) - min(totalamount_taken1, totalamount_taken3)) > 3*min(totalamount_taken1, totalamount_taken3)
            and totalamount_taken1 ne . and totalamount_taken3 ne .) or
          ((max(totalamount_taken2, totalamount_taken3) - min(totalamount_taken2, totalamount_taken3)) > 3*min(totalamount_taken2, totalamount_taken3)
            and totalamount_taken2 ne . and totalamount_taken3 ne .);
    title;
    title2;
  quit;

****************************************;
*  REMERGE ATC CODES TO DELINEATE BY CLASS;
****************************************;

  data remerge_atccodes;
    merge total_dailyamount meds_in;
    by elig_studyid medname;
    drop dailyamount_taken /*dailyamount_taken_units*/ med_strength--med_dose med_freq--med_enddate brandname1--altname73 comments--twelvemonth;
  run;

  proc sort data=remerge_atccodes nodupkey;
    by elig_studyid medname;
  run;


****************************************;
*  WORK IN DEFINED DAILY DOSE (DDD)
*   FOR PARTICULAR CLASSES
****************************************;
  proc format;
    value $medroutef
      'Implant' = 'Implant: Implant'
      'Inhal' = 'Inhal: Inhalation'
      'N' = 'N: nasal'
      'Instill' = 'Instill: Instillation'
      'O' = 'O: oral'
      'P' = 'P: parenteral'
      'R' = 'R: rectal'
      'SL' = 'S: sublingual/buccal'
      'TD' = 'TD: transdermal'
      'V' = 'V: vaginal'
    ;
  run;

  data remerge_atccodes_route (drop = med_type);
    retain elig_studyid medname totalamount_taken1 totalamount_taken2 totalamount_taken3 dailyamount_taken_units;
    format med_route $medroutef.;
    set remerge_atccodes;

    if lowcase(substr(med_type,1,3)) in ('cap', 'pil', 'tab', 'tsp') then med_route = 'O';

    else if find(lowcase(med_type),'cream') > 0 or find(lowcase(med_type),'ointment') > 0 or find(lowcase(med_type),'gel') > 0 or find(lowcase(med_type),'patch') > 0
      or find(lowcase(med_type),'app') > 0 or find(lowcase(med_type),'wash') > 0 or find(lowcase(medname), 'cleocin') > 0 or find(lowcase(medname), 'androgel') > 0
      or find(lowcase(medname), 'cordran') > 0 or find(lowcase(medname), 'imiquimod') > 0 then med_route = 'TD';

    else if find(lowcase(med_type),'inhal') > 0 or find(lowcase(med_type),'puff') > 0 or medname = 'Albuterol' then med_route = 'Inhal';

    else if (find(lowcase(med_type),'spray') > 0 and lowcase(medname) ne 'Phenol') then med_route = 'N';


    else if find(lowcase(med_type),'unit') > 0 or find(lowcase(med_type),'inject') > 0 or find(lowcase(med_type),'sub') > 0 or find(lowcase(med_type),'pen') > 0
      or find(lowcase(med_type),'sliding') > 0 or lowcase(med_type) = 'sc' or find(lowcase(med_type),'vial') > 0 or find(lowcase(med_type),'infusion') > 0 then med_route = 'P';

    else if find(lowcase(med_type),'lozen') > 0 or find(lowcase(med_type),'powder') > 0 or find(lowcase(med_type),'packet') > 0 or lowcase(med_type) = 'scoop' then med_route = 'O';

  run;

****************************** ASSUMPTION ******************************;
* assuming that hypertensive medications that have no med_route listed
* are ORAL. Note that Furosemide, Hydralazine, Labetalol have IV option  ;

  data remerge_atccodes_route;
    set remerge_atccodes_route;

    if med_route = '' then do;
      if scan(lowcase(medname),1,' -') in ('amiloride', 'amlodipine', 'diazide', 'lisniopril','losartan', 'metoprolol','triamterene') then med_route = 'O';
      if scan(lowcase(medname),1,' -') in ('furosemide', 'hydralazine', 'labetalol') then med_route = 'O';
    end;
  run;


/*
  proc freq data = Atc_ddd_codes;
    table AdmCode;
  run;
*/
  proc freq data = Atc_ddd_codes;
    table unittype;
  run;

  *Inhaled products are unresolved - aerosol and solution based routes often have differing DDD;
  data Atc_ddd_codes_edit;
    set Atc_ddd_codes;
    if substr(lowcase(admcode),1,2) in ('td','oi') then AdmCode = 'TD';
    format adj_DDD best12. adj_DDDunits $12.;

    if unittype in ('mg','g','mcg') then do;
      if unittype = 'mg' then adj_DDD = DDD;
      else if unittype = 'g' then adj_DDD = 1000*DDD;
      else if unittype = 'mcg' then adj_DDD = DDD/1000;
      adj_DDDunits = 'mg';
    end;

    else if unittype in ('U', 'TU', 'MU') then do;
      if unittype = 'U' then adj_DDD = DDD;
      else if unittype = 'TU' then adj_DDD = 1000*DDD;
      else if unittype = 'MU' then adj_DDD = 1000000*DDD;
      adj_DDDunits = 'units';
    end;

    else do;
      adj_DDD = DDD;
      if unittype = 'ml' then adj_DDDunits = 'mL';
    end;

  run;

  proc sql noprint;
    create table antihypertensive_ddd_codes as
    select *
    from Atc_ddd_codes_edit
    where substr(ATCCode,1,3) in ('C02','C03','C04','C07','C08','C09') or
        substr(ATCCode,1,4) = 'C01D' or
        substr(ATCCode,1,7) = 'C05AE02'
    order by ATCCode, AdmCode;
  quit;

***** ANTIHYPERTENSIVE ATCCODES ARE ONLY EVER STORED IN atccode1 or atccode2 *****;
***** only stored in atccode 2 when "Isosorbide" - special coding below *****;
  data remerge_atccodes_route;
    set remerge_atccodes_route;

    *if dosage is divisible by 15, it is likely isosorbide mononitrate (C01DA14) because typical doses are 30, 60, 90, 120 / sometimes 1/2 pill so 15;
    if atccode1 = 'C01DA14' then do;
      if mod(max(of totalamount_taken1-totalamount_taken3),15) ne 0 then do;
        atccode1 = 'C01DA08';
        atccode2 = 'C05AE02';
        atccode3 = 'C01DA58';
      end;
    end;

  run;

  proc sort data = remerge_atccodes_route out = remerge_atccodes_resort;
    by atccode1 med_route;
  run;
/*
  data remerge_atccodes1;
    merge remerge_atccodes_resort (in = a) antihypertensive_ddd_codes (in = b drop = DDDComment rename = (ATCCode=atccode1 DDD=DDD1 UnitType=UnitType1 AdmCode = med_route));
    by atccode1 med_route;
    if a;
  run;

  proc sort data = remerge_atccodes1;
    by atccode2 med_route;
  run;

  data remerge_atccodes2;
    merge remerge_atccodes1 (in = a) antihypertensive_ddd_codes (in = b drop = DDDComment rename = (ATCCode=atccode2 DDD=DDD2 UnitType=UnitType2 AdmCode = med_route));
    by atccode2 med_route;
    if a;
  run;

  proc sql;
    select elig_studyid, medname, totalamount_taken1, totalamount_taken2, totalamount_taken3, atccode1, atccode2
    from remerge_atccodes2
    where ddd2 ne .;
  quit;
*/

  data remerge_atccodes_ddd (drop = med_route);
    merge remerge_atccodes_resort (in = a) antihypertensive_ddd_codes (in = b drop = DDDComment DDD UnitType
                                                                  rename = (ATCCode=atccode1 adj_DDD=antihypertensive_DDD adj_DDDunits=antihypertensive_DDD_units AdmCode = med_route));
    by atccode1 med_route;
    if a;
  run;

  proc sort data = remerge_atccodes_ddd;
    by elig_studyid medname;
  run;

  *should we add angiotensin II receptor antagonists as category?;
  data huge_medclass;
    retain elig_studyid medname totalamount_taken1 totalamount_taken2 totalamount_taken3 dailyamount_taken_units;
    set remerge_atccodes_ddd;

    array atccode_vars[*] $ atccode1-atccode25;

    aceinhibitor = 0;
    alphablocker = 0;
    aldosteroneblocker = 0;
    angiotensinblocker = 0;
    antidepressant = 0;
    betablocker = 0;
    calciumblocker = 0;
    diuretic = 0;
    diabetesmed = 0;
    lipidlowering = 0;
    antihypertensive = 0;
    statin = 0;
    nitrate = 0;
    peripheral_dilator = 0;
    otherah = 0;

    do i = 1 to dim(atccode_vars);
      if  substr(atccode_vars[i],1,4) in ('C09A','C09B') or substr(atccode_vars[i],1,7) = 'C10BX04' then aceinhibitor = 1;
      if substr(atccode_vars[i],1,5) = 'C02CA' then alphablocker = 1;
      if substr(atccode_vars[i],1,5) = 'C03DA' then aldosteroneblocker = 1;
      if substr(atccode_vars[i],1,4) = 'C09C' then angiotensinblocker = 1;
      if substr(atccode_vars[i],1,4) = 'N06A' then antidepressant = 1;
      if  substr(atccode_vars[i],1,3) = 'C07' then betablocker = 1;
      if substr(atccode_vars[i],1,3) = 'C08' or substr(atccode_vars[i],1,5) = 'C09BB' or substr(atccode_vars[i],1,5) = 'C09DB' or substr(atccode_vars[i],1,7) in ('C09DX03','C10BX03')
          then calciumblocker = 1;
      if substr(atccode_vars[i],1,3) = 'C03' or substr(atccode_vars[i],1,4) in ('C02L','C07B','C07C','C07D','C08G') or substr(atccode_vars[i],1,5) in ('C09BA','C09DA') or
          substr(atccode_vars[i],1,7) in ('C09DX01','C09DX03') then diuretic = 1;
      if substr(atccode_vars[i],1,3) = 'A10' or
          substr(atccode_vars[i],1,3) = 'A10' then diabetesmed = 1;
      if substr(atccode_vars[i],1,3) = 'C10' and mednames ne 'Omega-3 Acid' then lipidlowering = 1;
      if substr(atccode_vars[i],1,3) in ('C02','C03','C04','C07','C08','C09') or substr(atccode_vars[i],1,4) = 'C01D' or substr(atccode_vars[i],1,7) = 'C05AE02' or
          substr(atccode_vars[i],1,4) = 'C02A' or substr(atccode_vars[i],1,4) = 'C02B' or substr(atccode_vars[i],1,5) = 'C02CC' or substr(atccode_vars[i],1,4) = 'C02D' or
          substr(atccode_vars[i],1,4) = 'C02K' or substr(atccode_vars[i],1,4) = 'C02L' then antihypertensive = 1;
      if substr(atccode_vars[i],1,5) = 'C10AA' or substr(atccode_vars[i],1,4) = 'C10B' then statin = 1;
      if substr(atccode_vars[i],1,5) = 'C01DA' or substr(atccode_vars[i],1,7) in ('A02BX12','C05AE02') then nitrate = 1;
      if  substr(atccode_vars[i],1,3) = 'C04' then peripheral_dilator = 1;
      if substr(atccode_vars[i],1,4) in ('C02A', 'C02B', 'C02D', 'C02K', 'C02L') or substr(atccode_vars[i],1,5) = 'C02CC' then otherah = 1;

    end;

    anymed_dose_change = 0;
    anymed_dose_decr = 0;
    anymed_dose_incr = 0;

    if totalamount_taken1 ne totalamount_taken2 and totalamount_taken1 ne . and totalamount_taken2 ne . then do;
      anymed_dose_change = 1;
      med_dose_change06 = 1;
      if totalamount_taken1 > totalamount_taken2 then do;
        anymed_dose_decr = 1;
        med_dose_decr06 = 1;
        med_dose_incr06 = 0;
      end;
      else do;
        anymed_dose_incr = 1;
        med_dose_incr06 = 1;
        med_dose_decr06 = 0;
      end;
    end;
    else do;
      med_dose_change06 = 0;
      med_dose_decr06 = 0;
      med_dose_incr06 = 0;
    end;

    if (totalamount_taken2 ne totalamount_taken3 and totalamount_taken2 ne . and totalamount_taken3 ne .) or
        (totalamount_taken1 ne totalamount_taken3 and totalamount_taken1 ne . and totalamount_taken3 ne . and totalamount_taken2 = .) then do;
      anymed_dose_change = 1;
      med_dose_change12 = 1;
      if (totalamount_taken3 > totalamount_taken2 or (totalamount_taken3 > totalamount_taken1 and totalamount_taken2 = .)) then do;
        anymed_dose_decr = 1;
        med_dose_decr12 = 1;
        med_dose_incr12 = 0;
      end;
      else if (totalamount_taken2 = .) then do;
        anymed_dose_incr = 1;
        med_dose_incr12 = 1;
        med_dose_decr12 = 0;
      end;
      else
    end;
    else do;
      med_dose_change12 = 0;
      med_dose_decr12 = 0;
      med_dose_incr12 = 0;
    end;

    drop mednames atccode1--atccode25 i;
run;

    data huge_medclass;
      set huge_medclass;
      if max(of timepoint1-timepoint3) not in (.,0);
      label totalamount_taken1 = "Total Daily Amount Taken at Baseline"
            totalamount_taken2 = "Total Daily Amount Taken at 6-Month"
            totalamount_taken3 = "Total Daily Amount Taken at 12-Month";
    run;

  proc freq data= huge_medclass;
    tables aceinhibitor alphablocker aldosteroneblocker angiotensinblocker antidepressant betablocker calciumblocker diuretic diabetesmed lipidlowering antihypertensive
            statin nitrate peripheral_dilator otherah
            med_dose_change06 med_dose_change12;
  run;


****************************************;
*  MEDICATION COUNTS BY CLASS;
****************************************;

%macro medclass_counter(outputset, classification, baselinevarname, mo6varname, mo12varname);
  proc sql;
    create table &outputset as
    select elig_studyid, sum(timepoint1) as &baselinevarname, sum(timepoint2) as &mo6varname, sum(timepoint3) as &mo12varname
    from huge_medclass
    where &classification = 1
    group by elig_studyid;
  quit;
%mend;

  proc sql;
    create table med_allmeds_recount as
    select elig_studyid, sum(timepoint1) as allmeds_n00, sum(timepoint2) as allmeds_n06, sum(timepoint3) as allmeds_n12
    from huge_medclass
    group by elig_studyid;
  quit;

  %medclass_counter(med_aceinhibitor_recount, aceinhibitor, aceinhibitor_n00, aceinhibitor_n06, aceinhibitor_n12);
  %medclass_counter(med_alphablocker_recount, alphablocker, alphablocker_n00, alphablocker_n06, alphablocker_n12);
  %medclass_counter(med_aldosteroneblocker_recount, aldosteroneblocker, aldosteroneblocker_n00, aldosteroneblocker_n06, aldosteroneblocker_n12);
  %medclass_counter(med_angiotensinblocker_recount, angiotensinblocker, angiotensinblocker_n00, angiotensinblocker_n06, angiotensinblocker_n12);
  %medclass_counter(med_antidepressant_recount, antidepressant, antidepressant_n00, antidepressant_n06, antidepressant_n12);
  %medclass_counter(med_betablocker_recount, betablocker, betablocker_n00, betablocker_n06, betablocker_n12);
  %medclass_counter(med_calciumblocker_recount, calciumblocker, calciumblocker_n00, calciumblocker_n06, calciumblocker_n12);
  %medclass_counter(med_diabetesmed_recount, diabetesmed, diabetesmed_n00, diabetesmed_n06, diabetesmed_n12);
  %medclass_counter(med_diuretic_recount, diuretic, diuretic_n00, diuretic_n06, diuretic_n12);
  %medclass_counter(med_lipidlowering_recount, lipidlowering, lipidlowering_n00, lipidlowering_n06, lipidlowering_n12);
  %medclass_counter(med_antihypertensive_recount, antihypertensive, antihypertensive_n00, antihypertensive_n06, antihypertensive_n12);
  %medclass_counter(med_statin_recount, statin, statin_n00, statin_n06, statin_n12);
  %medclass_counter(med_nitrate_recount, nitrate, nitrate_n00, nitrate_n06, nitrate_n12);
  %medclass_counter(med_perdilator_recount, peripheral_dilator, peripheraldilator_n00, peripheraldilator_n06, peripheraldilator_n12);
  %medclass_counter(med_otherah_recount, otherah, otherah_n00, otherah_n06, otherah_n12);

  data newmedcount;
    merge Final_expected_visit med_allmeds_recount med_aceinhibitor_recount med_alphablocker_recount med_aldosteroneblocker_recount med_angiotensinblocker_recount med_antidepressant_recount
          med_betablocker_recount med_calciumblocker_recount med_diabetesmed_recount med_diuretic_recount med_lipidlowering_recount med_antihypertensive_recount
          med_statin_recount med_nitrate_recount med_perdilator_recount med_otherah_recount;
    by elig_studyid;
/*
    array medcountarray[*] allmeds_n00--peripheraldilator_n12;

    do i = 1 to dim(medcountarray);
      if medcountarray[i] = . then medcountarray[i] = 0;
      *reset non-expected 12-month visits to null;
      if mod(i, 3) = 0 and final_visit < 12 then medcountarray[i] = .;
    end;

    drop i;
*/
  run;

  data huge_medclass;
    set huge_medclass;
    drop timepoint1-timepoint3;
  run;

****************************************;
*  DOSAGE CHANGES BY CLASS;
****************************************;

  proc sql;
    create table med_allmeds_dosechange as
    select elig_studyid, sum(anymed_dose_change) as allmeds_dosechangeany, sum(med_dose_change06) as allmeds_dosechange06, sum(med_dose_change12) as allmeds_dosechange12,
    sum(anymed_dose_decr) as allmeds_dosedecrany, sum(med_dose_decr06) as allmeds_dosedecr06, sum(med_dose_decr12) as allmeds_dosedecr12,
    sum(anymed_dose_incr) as allmeds_doseincrany, sum(med_dose_incr06) as allmeds_doseincr06, sum(med_dose_incr12) as allmeds_doseincr12
    from huge_medclass
    group by elig_studyid;
  quit;

  proc sql;
    create table med_aceinhibitor_dosechange as
    select elig_studyid, sum(anymed_dose_change) as aceinhibitor_dosechangeany, sum(med_dose_change06) as aceinhibitor_dosechange06, sum(med_dose_change12) as aceinhibitor_dosechange12,
    sum(anymed_dose_decr) as aceinhibitor_dosedecrany, sum(med_dose_decr06) as aceinhibitor_dosedecr06, sum(med_dose_decr12) as aceinhibitor_dosedecr12,
    sum(anymed_dose_incr) as aceinhibitor_doseincrany, sum(med_dose_incr06) as aceinhibitor_doseincr06, sum(med_dose_incr12) as aceinhibitor_doseincr12
    from huge_medclass
    where aceinhibitor = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_alphablocker_dosechange as
    select elig_studyid, sum(anymed_dose_change) as alphablocker_dosechangeany, sum(med_dose_change06) as alphablocker_dosechange06, sum(med_dose_change12) as alphablocker_dosechange12,
    sum(anymed_dose_decr) as alphablocker_dosedecrany, sum(med_dose_decr06) as alphablocker_dosedecr06, sum(med_dose_decr12) as alphablocker_dosedecr12,
    sum(anymed_dose_incr) as alphablocker_doseincrany, sum(med_dose_incr06) as alphablocker_doseincr06, sum(med_dose_incr12) as alphablocker_doseincr12
    from huge_medclass
    where alphablocker = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_aldoblocker_dosechange as
    select elig_studyid, sum(anymed_dose_change) as aldoblocker_dosechangeany, sum(med_dose_change06) as aldoblocker_dosechange06, sum(med_dose_change12) as aldoblocker_dosechange12,
    sum(anymed_dose_decr) as aldoblocker_dosedecrany, sum(med_dose_decr06) as aldoblocker_dosedecr06, sum(med_dose_decr12) as aldoblocker_dosedecr12,
    sum(anymed_dose_incr) as aldoblocker_doseincrany, sum(med_dose_incr06) as aldoblocker_doseincr06, sum(med_dose_incr12) as aldoblocker_doseincr12
    from huge_medclass
    where aldosteroneblocker = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_angiotenblocker_dosechange as
    select elig_studyid, sum(anymed_dose_change) as angiotenblocker_dosechangeany, sum(med_dose_change06) as angiotenblocker_dosechange06, sum(med_dose_change12) as angiotenblocker_dosechange12,
    sum(anymed_dose_decr) as angiotenblocker_dosedecrany, sum(med_dose_decr06) as angiotenblocker_dosedecr06, sum(med_dose_decr12) as angiotenblocker_dosedecr12,
    sum(anymed_dose_incr) as angiotenblocker_doseincrany, sum(med_dose_incr06) as angiotenblocker_doseincr06, sum(med_dose_incr12) as angiotenblocker_doseincr12
    from huge_medclass
    where angiotensinblocker = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_antidepressant_dosechange as
    select elig_studyid, sum(anymed_dose_change) as antidepressant_dosechangeany, sum(med_dose_change06) as antidepressant_dosechange06, sum(med_dose_change12) as antidepressant_dosechange12,
    sum(anymed_dose_decr) as antidepressant_dosedecrany, sum(med_dose_decr06) as antidepressant_dosedecr06, sum(med_dose_decr12) as antidepressant_dosedecr12,
    sum(anymed_dose_incr) as antidepressant_doseincrany, sum(med_dose_incr06) as antidepressant_doseincr06, sum(med_dose_incr12) as antidepressant_doseincr12
    from huge_medclass
    where antidepressant = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_betablocker_dosechange as
    select elig_studyid, sum(anymed_dose_change) as betablocker_dosechangeany, sum(med_dose_change06) as betablocker_dosechange06, sum(med_dose_change12) as betablocker_dosechange12,
    sum(anymed_dose_decr) as betablocker_dosedecrany, sum(med_dose_decr06) as betablocker_dosedecr06, sum(med_dose_decr12) as betablocker_dosedecr12,
    sum(anymed_dose_incr) as betablocker_doseincrany, sum(med_dose_incr06) as betablocker_doseincr06, sum(med_dose_incr12) as betablocker_doseincr12
    from huge_medclass
    where betablocker = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_calciumblocker_dosechange as
    select elig_studyid, sum(anymed_dose_change) as calciumblocker_dosechangeany, sum(med_dose_change06) as calciumblocker_dosechange06, sum(med_dose_change12) as calciumblocker_dosechange12,
    sum(anymed_dose_decr) as calciumblocker_dosedecrany, sum(med_dose_decr06) as calciumblocker_dosedecr06, sum(med_dose_decr12) as calciumblocker_dosedecr12,
    sum(anymed_dose_incr) as calciumblocker_doseincrany, sum(med_dose_incr06) as calciumblocker_doseincr06, sum(med_dose_incr12) as calciumblocker_doseincr12
    from huge_medclass
    where calciumblocker = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_diabetesmed_dosechange as
    select elig_studyid, sum(anymed_dose_change) as diabetesmed_dosechangeany, sum(med_dose_change06) as diabetesmed_dosechange06, sum(med_dose_change12) as diabetesmed_dosechange12,
    sum(anymed_dose_decr) as diabetesmed_dosedecrany, sum(med_dose_decr06) as diabetesmed_dosedecr06, sum(med_dose_decr12) as diabetesmed_dosedecr12,
    sum(anymed_dose_incr) as diabetesmed_doseincrany, sum(med_dose_incr06) as diabetesmed_doseincr06, sum(med_dose_incr12) as diabetesmed_doseincr12
    from huge_medclass
    where diabetesmed = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_diuretic_dosechange as
    select elig_studyid, sum(anymed_dose_change) as diuretic_dosechangeany, sum(med_dose_change06) as diuretic_dosechange06, sum(med_dose_change12) as diuretic_dosechange12,
    sum(anymed_dose_decr) as diuretic_dosedecrany, sum(med_dose_decr06) as diuretic_dosedecr06, sum(med_dose_decr12) as diuretic_dosedecr12,
    sum(anymed_dose_incr) as diuretic_doseincrany, sum(med_dose_incr06) as diuretic_doseincr06, sum(med_dose_incr12) as diuretic_doseincr12
    from huge_medclass
    where diuretic = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_lipidlowering_dosechange as
    select elig_studyid, sum(anymed_dose_change) as lipidlowering_dosechangeany, sum(med_dose_change06) as lipidlowering_dosechange06, sum(med_dose_change12) as lipidlowering_dosechange12,
    sum(anymed_dose_decr) as lipidlowering_dosedecrany, sum(med_dose_decr06) as lipidlowering_dosedecr06, sum(med_dose_decr12) as lipidlowering_dosedecr12,
    sum(anymed_dose_incr) as lipidlowering_doseincrany, sum(med_dose_incr06) as lipidlowering_doseincr06, sum(med_dose_incr12) as lipidlowering_doseincr12
    from huge_medclass
    where lipidlowering = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_antihypertensive_dosechange as
    select elig_studyid, sum(anymed_dose_change) as antihypertensive_dosechangeany, sum(med_dose_change06) as antihypertensive_dosechange06, sum(med_dose_change12) as antihypertensive_dosechange12,
    sum(anymed_dose_decr) as antihypertensive_dosedecrany, sum(med_dose_decr06) as antihypertensive_dosedecr06, sum(med_dose_decr12) as antihypertensive_dosedecr12,
    sum(anymed_dose_incr) as antihypertensive_doseincrany, sum(med_dose_incr06) as antihypertensive_doseincr06, sum(med_dose_incr12) as antihypertensive_doseincr12
    from huge_medclass
    where antihypertensive = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_statin_dosechange as
    select elig_studyid, sum(anymed_dose_change) as statin_dosechangeany, sum(med_dose_change06) as statin_dosechange06, sum(med_dose_change12) as statin_dosechange12,
    sum(anymed_dose_decr) as statin_dosedecrany, sum(med_dose_decr06) as statin_dosedecr06, sum(med_dose_decr12) as statin_dosedecr12,
    sum(anymed_dose_incr) as statin_doseincrany, sum(med_dose_incr06) as statin_doseincr06, sum(med_dose_incr12) as statin_doseincr12
    from huge_medclass
    where statin = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_nitrate_dosechange as
    select elig_studyid, sum(anymed_dose_change) as nitrate_dosechangeany, sum(med_dose_change06) as nitrate_dosechange06, sum(med_dose_change12) as nitrate_dosechange12,
    sum(anymed_dose_decr) as nitrate_dosedecrany, sum(med_dose_decr06) as nitrate_dosedecr06, sum(med_dose_decr12) as nitrate_dosedecr12,
    sum(anymed_dose_incr) as nitrate_doseincrany, sum(med_dose_incr06) as nitrate_doseincr06, sum(med_dose_incr12) as nitrate_doseincr12
    from huge_medclass
    where nitrate = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_perdilator_dosechange as
    select elig_studyid, sum(anymed_dose_change) as perdilator_dosechangeany, sum(med_dose_change06) as perdilator_dosechange06, sum(med_dose_change12) as perdilator_dosechange12,
    sum(anymed_dose_decr) as perdilator_dosedecrany, sum(med_dose_decr06) as perdilator_dosedecr06, sum(med_dose_decr12) as perdilator_dosedecr12,
    sum(anymed_dose_incr) as perdilator_doseincrany, sum(med_dose_incr06) as perdilator_doseincr06, sum(med_dose_incr12) as perdilator_doseincr12
    from huge_medclass
    where peripheral_dilator = 1
    group by elig_studyid;
  quit;

  proc sql;
    create table med_otherah_dosechange as
    select elig_studyid, sum(anymed_dose_change) as otherah_dosechangeany, sum(med_dose_change06) as otherah_dosechange06, sum(med_dose_change12) as otherah_dosechange12,
    sum(anymed_dose_decr) as otherah_dosedecrany, sum(med_dose_decr06) as otherah_dosedecr06, sum(med_dose_decr12) as otherah_dosedecr12,
    sum(anymed_dose_incr) as otherah_doseincrany, sum(med_dose_incr06) as otherah_doseincr06, sum(med_dose_incr12) as otherah_doseincr12
    from huge_medclass
    where otherah = 1
    group by elig_studyid;
  quit;

  data dosechange_byclass;
    merge Final_expected_visit med_allmeds_dosechange med_aceinhibitor_dosechange med_alphablocker_dosechange med_aldoblocker_dosechange med_antidepressant_dosechange
          med_betablocker_dosechange med_calciumblocker_dosechange med_diabetesmed_dosechange med_diuretic_dosechange med_lipidlowering_dosechange med_antihypertensive_dosechange
          med_statin_dosechange med_nitrate_dosechange med_perdilator_dosechange med_otherah_dosechange;
    by elig_studyid;
/*
    array medcountarray[*] allmeds_n00--peripheraldilator_n12;

    do i = 1 to dim(medcountarray);
      if medcountarray[i] = . then medcountarray[i] = 0;
      *reset non-expected 12-month visits to null;
      if mod(i, 3) = 0 and final_visit < 12 then medcountarray[i] = .;
    end;

    drop i;
*/
  run;

****************************************;
*  DOSAGE CHANGES BY CLASS;
****************************************;

  data visit_dates;
    set meds_in;
    keep elig_studyid baseline sixmonth twelvemonth;
  run;

  proc sort data = visit_dates nodupkey;
    by elig_studyid;
  run;

  data newmedcat (drop = baseline sixmonth twelvemonth);
    format  elig_studyid final_visit best12.
            allmeds00 allmeds06 allmeds12 best12.
            allmeds_n00 allmeds_n06 allmeds_n12 best12.
            aceinhibitor00  aceinhibitor06  aceinhibitor12
            alphablocker00  alphablocker06  alphablocker12
            aldosteroneblocker00  aldosteroneblocker06  aldosteroneblocker12
            angiotensinblocker00 angiotensinblocker06 angiotensinblocker12
            antidepressant00  antidepressant06  antidepressant12
            betablocker00 betablocker06 betablocker12
            calciumblocker00  calciumblocker06  calciumblocker12
            diabetesmed00 diabetesmed06 diabetesmed12
            diuretic00  diuretic06  diuretic12
            lipidlowering00 lipidlowering06 lipidlowering12
            antihypertensive00  antihypertensive06  antihypertensive12
            statin00  statin06  statin12
            nitrate00 nitrate06 nitrate12
            peripheraldilator00 peripheraldilator06 peripheraldilator12
            otherah00 otherah06 otherah12
            best12.;
    merge newmedcount visit_dates;
    by elig_studyid;

    array medstatus_array[*] allmeds00--allmeds12 aceinhibitor00--otherah12;
    array mednumber_array[*] allmeds_n00--allmeds_n12 aceinhibitor_n00--otherah_n12;
    array allmedvars_array[*] allmeds00--otherah_n12;

    do i = 1 to dim(medstatus_array);
      if mednumber_array[i] > 0 then medstatus_array[i] = 1;
      else medstatus_array[i] = 0;
    end;

    do j = 1 to dim(allmedvars_array);
      if allmedvars_array[j] = . then allmedvars_array[j] = 0;
      *reset non-expected 12-month visits to null;
      if mod(j, 3) = 0 and final_visit < 12 then allmedvars_array[j] = .;
    end;

    if sixmonth = . then do;
      do k = 1 to dim(allmedvars_array);
        if mod((k+1),3) = 0 then allmedvars_array[k] = .;
      end;
    end;

    if twelvemonth = . then do;
      do m = 1 to dim(allmedvars_array);
        if mod(m,3) = 0 then allmedvars_array[m] = .;
      end;
    end;

    drop i j k m;

  run;

  %macro record_medclass_nchange06(temp_medname);
    if temp_medname = "allmeds" then allmeds_changein_n06 = 1;
    else if temp_medname = "aceinhibitor" then aceinhibitor_changein_n06 = 1;
    else if temp_medname = "alphablocker" then alphablocker_changein_n06 = 1;
    else if temp_medname = "aldosteroneblocker" then aldosteroneblocker_changein_n06 = 1;
    else if temp_medname = "angiotensinblocker" then angiotensinblocker_changein_n06 = 1;
    else if temp_medname = "antidepressant" then antidepressant_changein_n06 = 1;
    else if temp_medname = "betablocker" then betablocker_changein_n06 = 1;
    else if temp_medname = "calciumblocker" then calciumblocker_changein_n06 = 1;
    else if temp_medname = "diabetesmed" then diabetesmed_changein_n06 = 1;
    else if temp_medname = "diuretic" then diuretic_changein_n06 = 1;
    else if temp_medname = "lipidlowering" then lipidlowering_changein_n06 = 1;
    else if temp_medname = "antihypertensive" then antihypertensive_changein_n06 = 1;
    else if temp_medname = "statin" then statin_changein_n06 = 1;
    else if temp_medname = "peripheraldilator" then peripheraldilator_changein_n06 = 1;
    else if temp_medname = "otherah" then otherah_changein_n06 = 1;
  %mend;

  %macro record_newmedclass06(temp_medname);
    if temp_medname = "allmeds" then allmeds_newmedclass06 = 1;
    else if temp_medname = "aceinhibitor" then aceinhibitor_newmedclass06 = 1;
    else if temp_medname = "alphablocker" then alphablocker_newmedclass06 = 1;
    else if temp_medname = "aldosteroneblocker" then aldosteroneblocker_newmedclass06 = 1;
    else if temp_medname = "angiotensinblocker" then angiotensinblocker_newmedclass06 = 1;
    else if temp_medname = "antidepressant" then antidepressant_newmedclass06 = 1;
    else if temp_medname = "betablocker" then betablocker_newmedclass06 = 1;
    else if temp_medname = "calciumblocker" then calciumblocker_newmedclass06 = 1;
    else if temp_medname = "diabetesmed" then diabetesmed_newmedclass06 = 1;
    else if temp_medname = "diuretic" then diuretic_newmedclass06 = 1;
    else if temp_medname = "lipidlowering" then lipidlowering_newmedclass06 = 1;
    else if temp_medname = "antihypertensive" then antihypertensive_newmedclass06 = 1;
    else if temp_medname = "statin" then statin_newmedclass06 = 1;
    else if temp_medname = "peripheraldilator" then peripheraldilator_newmedclass06 = 1;
    else if temp_medname = "otherah" then otherah_newmedclass06 = 1;
  %mend;

  %macro record_medclass_nchange12(temp_medname);
    if temp_medname = "allmeds" then allmeds_changein_n12 = 1;
    else if temp_medname = "aceinhibitor" then aceinhibitor_changein_n12 = 1;
    else if temp_medname = "alphablocker" then alphablocker_changein_n12 = 1;
    else if temp_medname = "aldosteroneblocker" then aldosteroneblocker_changein_n12 = 1;
    else if temp_medname = "angiotensinblocker" then angiotensinblocker_changein_n12 = 1;
    else if temp_medname = "antidepressant" then antidepressant_changein_n12 = 1;
    else if temp_medname = "betablocker" then betablocker_changein_n12 = 1;
    else if temp_medname = "calciumblocker" then calciumblocker_changein_n12 = 1;
    else if temp_medname = "diabetesmed" then diabetesmed_changein_n12 = 1;
    else if temp_medname = "diuretic" then diuretic_changein_n12 = 1;
    else if temp_medname = "lipidlowering" then lipidlowering_changein_n12 = 1;
    else if temp_medname = "antihypertensive" then antihypertensive_changein_n12 = 1;
    else if temp_medname = "statin" then statin_changein_n12 = 1;
    else if temp_medname = "peripheraldilator" then peripheraldilator_changein_n12 = 1;
    else if temp_medname = "otherah" then otherah_changein_n12 = 1;
  %mend;

  %macro record_newmedclass12(temp_medname);
    if temp_medname = "allmeds" then allmeds_newmedclass12 = 1;
    else if temp_medname = "aceinhibitor" then aceinhibitor_newmedclass12 = 1;
    else if temp_medname = "alphablocker" then alphablocker_newmedclass12 = 1;
    else if temp_medname = "aldosteroneblocker" then aldosteroneblocker_newmedclass12 = 1;
    else if temp_medname = "angiotensinblocker" then angiotensinblocker_newmedclass12 = 1;
    else if temp_medname = "antidepressant" then antidepressant_newmedclass12 = 1;
    else if temp_medname = "betablocker" then betablocker_newmedclass12 = 1;
    else if temp_medname = "calciumblocker" then calciumblocker_newmedclass12 = 1;
    else if temp_medname = "diabetesmed" then diabetesmed_newmedclass12 = 1;
    else if temp_medname = "diuretic" then diuretic_newmedclass12 = 1;
    else if temp_medname = "lipidlowering" then lipidlowering_newmedclass12 = 1;
    else if temp_medname = "antihypertensive" then antihypertensive_newmedclass12 = 1;
    else if temp_medname = "statin" then statin_newmedclass12 = 1;
    else if temp_medname = "peripheraldilator" then peripheraldilator_newmedclass12 = 1;
    else if temp_medname = "otherah" then otherah_newmedclass12 = 1;
  %mend;

  %macro record_medclass_nchange_any(temp_medname);
    if allmeds_changein_n06 = 1 or allmeds_changein_n12 = 1 then allmeds_changein_nany = 1;
    else if aceinhibitor_changein_n06 = 1 or aceinhibitor_changein_n12 = 1 then aceinhibitor_changein_nany = 1;
    else if alphablocker_changein_n06 = 1 or alphablocker_changein_n12 = 1 then alphablocker_changein_nany = 1;
    else if aldosteroneblocker_changein_n06 = 1 or aldosteroneblocker_changein_n12 = 1 then aldosteroneblocker_changein_nany = 1;
    else if angiotensinblocker_changein_n06 = 1 or angiotensinblocker_changein_n12 = 1 then angiotensinblocker_changein_nany = 1;
    else if antidepressant_changein_n06 = 1 or antidepressant_changein_n12 = 1 then antidepressant_changein_nany = 1;
    else if betablocker_changein_n06 = 1 or betablocker_changein_n12 = 1 then betablocker_changein_nany = 1;
    else if calciumblocker_changein_n06 = 1 or calciumblocker_changein_n12 = 1 then calciumblocker_changein_nany = 1;
    else if diabetesmed_changein_n06 = 1 or diabetesmed_changein_n12 = 1 then diabetesmed_changein_nany = 1;
    else if diuretic_changein_n06 = 1 or diuretic_changein_n12 = 1 then diuretic_changein_nany = 1;
    else if lipidlowering_changein_n06 = 1 or lipidlowering_changein_n12 = 1 then lipidlowering_changein_nany = 1;
    else if antihypertensive_changein_n06 = 1 or antihypertensive_changein_n12 = 1 then antihypertensive_changein_nany = 1;
    else if statin_changein_n06 = 1 or statin_changein_n12 = 1 then statin_changein_nany = 1;
    else if peripheraldilator_changein_n06 = 1 or peripheraldilator_changein_n12 = 1 then peripheraldilator_changein_nany = 1;
    else if otherah_changein_n06 = 1 or otherah_changein_n12 = 1 then otherah_changein_nany = 1;
  %mend;

  %macro record_newmedclass_any(temp_medname);
    if allmeds_newmedclass06 = 1 or allmeds_newmedclass12 = 1 then allmeds_newmedclassany = 1;
    else if aceinhibitor_newmedclass06 = 1 or aceinhibitor_newmedclass12 = 1 then aceinhibitor_newmedclassany = 1;
    else if alphablocker_newmedclass06 = 1 or alphablocker_newmedclass12 = 1 then alphablocker_newmedclassany = 1;
    else if aldosteroneblocker_newmedclass06 = 1 or aldosteroneblocker_newmedclass12 = 1 then aldosteroneblocker_newclassany = 1;
    else if angiotensinblocker_newmedclass06 = 1 or angiotensinblocker_newmedclass12 = 1 then angiotensinblocker_newclassany = 1;
    else if antidepressant_newmedclass06 = 1 or antidepressant_newmedclass12 = 1 then antidepressant_newmedclassany = 1;
    else if betablocker_newmedclass06 = 1 or betablocker_newmedclass12 = 1 then betablocker_newmedclassany = 1;
    else if calciumblocker_newmedclass06 = 1 or calciumblocker_newmedclass12 = 1 then calciumblocker_newmedclassany = 1;
    else if diabetesmed_newmedclass06 = 1 or diabetesmed_newmedclass12 = 1 then diabetesmed_newmedclassany = 1;
    else if diuretic_newmedclass06 = 1 or diuretic_newmedclass12 = 1 then diuretic_newmedclassany = 1;
    else if lipidlowering_newmedclass06 = 1 or lipidlowering_newmedclass12 = 1 then lipidlowering_newmedclassany = 1;
    else if antihypertensive_newmedclass06 = 1 or antihypertensive_newmedclass12 = 1 then antihypertensive_newmedclassany = 1;
    else if statin_newmedclass06 = 1 or statin_newmedclass12 = 1 then statin_newmedclassany = 1;
    else if peripheraldilator_newmedclass06 = 1 or peripheraldilator_newmedclass12 = 1 then peripheraldilator_newmedclassany = 1;
    else if otherah_newmedclass06 = 1 or otherah_newmedclass12 = 1 then otherah_newmedclassany = 1;
  %mend;

  data newmedicationscat;
    set newmedcat;

    array medcountarray[*] allmeds_n00--allmeds_n12 aceinhibitor_n00--otherah_n12;

    do i = 1 to dim(medcountarray);

      *6-month visit coding;
      if mod(i, 3) = 2 then do;
        if medcountarray[i] ne . then do;
          if medcountarray[i] - medcountarray[i-1] ne 0 then do;
            temp_medname = scan(vname(medcountarray[i]),1,'_');
            %record_medclass_nchange06(temp_medname);
            if medcountarray[i-1] = 0 then do;
              %record_newmedclass06(temp_medname);
            end;
          end;
        end;
      end;

      *12-month visit coding;
      else if mod(i, 3) = 0 then do;
        if medcountarray[i] ne . then do;
          if medcountarray[i] - medcountarray[i-1] ne 0 then do;
            temp_medname = scan(vname(medcountarray[i]),1,'_');
            %record_medclass_nchange12(temp_medname);
            if medcountarray[i-1] = 0 and medcountarray[i-2] = 0 then do;
              %record_newmedclass12(temp_medname);
            end;
          end;
        end;
      end;

      if mod(i, 3) = 0 then do;
        temp_medname = scan(vname(medcountarray[i]),1,'_');
        %record_medclass_nchange_any(temp_medname);
        %record_newmedclass_any(temp_medname);
      end;

    end;

    drop i temp_medname;

  run;

  data newmedicationscat;
    set newmedicationscat;

    allmeds_newmedclass06 = .;
    allmeds_newmedclass12 = .;
    allmeds_newmedclassany = .;

    array mo6array[*] aceinhibitor_newmedclass06--otherah_newmedclass06;
    array mo12array[*] aceinhibitor_newmedclass12--otherah_newmedclass12;

    do i = 1 to dim(mo6array);
      if mo6array[i] = 1 then allmeds_newmedclass06 = 1;
    end;


    do j = 1 to dim(mo12array);
      if mo12array[j] = 1 then allmeds_newmedclass12 = 1;
    end;

    if allmeds_newmedclass06 = 1 or allmeds_newmedclass12 = 1 then allmeds_newmedclassany = 1;

    drop i j;

  run;

  data finalmedicationscat;
    retain elig_studyid final_visit allmeds00 allmeds06 allmeds12 allmeds_n00 allmeds_n06 allmeds_n12 allmeds_dosechangeany allmeds_dosechange06 allmeds_dosechange12
    allmeds_dosedecrany allmeds_dosedecr06 allmeds_dosedecr12 allmeds_doseincrany allmeds_doseincr06 allmeds_doseincr12;
    merge newmedicationscat Dosechange_byclass;
    by elig_studyid;

    array alldosagevars[*] allmeds_dosechangeany--allmeds_doseincr12 aceinhibitor_dosechangeany--otherah_doseincr12;
    do i = 1 to dim(alldosagevars);
      *reset non-expected 12-month visits to null;
      if mod(i, 3) = 0 and final_visit < 12 then alldosagevars[i] = .;
      if alldosagevars[i] > 0 then alldosagevars[i] = 1;
    end;
    drop i;

  run;

  proc sql;
    select elig_studyid, allmeds_n00, allmeds_n06, allmeds_n12
    from finalmedicationscat
    where allmeds_n06 = . and allmeds_n12 ne .;
  run;

  *NULL change flags when participant dropped out before visit;
  data finalmedicationscat;
    set finalmedicationscat;
    by elig_studyid;

    array allmedchangeflags[*] allmeds_dosechangeany--allmeds_doseincr12 allmeds_changein_n06--otherah_doseincr12;

    if allmeds_n06 = . then do;
      do i = 1 to dim(allmedchangeflags);
        allmedchangeflags[i] = .;
      end;
    end;

    if allmeds_n12 = . then do;
      do j = 1 to dim(allmedchangeflags);
        if find(vname(allmedchangeflags[j]),'12') > 0 then allmedchangeflags[j] = .;
      end;
    end;

    drop i j;

  run;

  data bestair.bamedicationcat bestair2.bamedicationcat;
    set finalmedicationscat;
  run;


  *print instances where a particular individual is not prescribed one of main classification of medications for cardiovascular disease (CVD);
  *purpose of list is to quality check medication data given the unlikelihood of no CVD medications given patient demographics of study;
  data nomedclass_baseorfinal;
    set finalmedicationscat;

    if (
    betablocker00 = 0 and betablocker06 = 0 and betablocker12 = 0 and
    aceinhibitor00 = 0 and aceinhibitor06 = 0 and aceinhibitor12 = 0 and
    alphablocker00 = 0 and alphablocker06 = 0 and alphablocker12 = 0 and
    calciumblocker00 = 0 and calciumblocker06 = 0 and calciumblocker12 = 0 and
    diabetesmed00 = 0 and diabetesmed06 = 0 and diabetesmed12 = 0 and
    diuretic00 = 0 and diuretic06 = 0 and diuretic12 = 0 and
    lipidlowering00 = 0 and lipidlowering06 = 0 and lipidlowering12 = 0 and
    antihypertensive00 = 0 and antihypertensive06 = 0 and antihypertensive12 = 0 and
    statin00 = 0 and statin06 = 0 and statin12 = 0
    );


  run;

  proc sort data = nomedclass_baseorfinal nodupkey;
    by elig_studyid;
  run;

  proc sql;
    title "Patient Recorded as Not Taking a Medication of Classification of Interest at Baseline or Final Visit";
    select elig_studyid
    from nomedclass_baseorfinal;
  quit;


********************************************************************************;
* Anti-Hypertensive Medications - Additional work;
********************************************************************************;

  data antihypertensive_medsall;
    set huge_medclass;
    if antihypertensive = 1;
    rename totalamount_taken1 = totalamount_taken00
            totalamount_taken2 = totalamount_taken06
            totalamount_taken3 = totalamount_taken12;
  run;

/*  proc sql;*/
/*    title "Missing Defined Daily Dose (DDD)";*/
/*    select unique(medname)*/
/*    from antihypertensive_medsall*/
/*    where antihypertensive_DDD = .;*/
/*  quit;*/

  proc format;
    value ddd_statusf
      0 = "0: Below DDD"
      1 = "1: At or Above DDD"
    ;
  run;

  data antihypertensive_meds_ddd;
    retain elig_studyid medname totalamount_taken00 totalamount_taken06 totalamount_taken12 dailyamount_taken_units antihypertensive_DDD antihypertensive_DDD_units;
    format ddd_status00 ddd_status06 ddd_status12 ddd_statusf.;
    format ddd_value00 ddd_value06 ddd_value12 best12.;
    set antihypertensive_medsall;
    if totalamount_taken00 ne . and antihypertensive_DDD ne . then do;
      if totalamount_taken00 ge antihypertensive_DDD then ddd_status00 = 1;
      else ddd_status00 = 0;
    end;
    if totalamount_taken06 ne . and antihypertensive_DDD ne . then do;
      if totalamount_taken06 ge antihypertensive_DDD then ddd_status06 = 1;
      else ddd_status06 = 0;
    end;
    if totalamount_taken12 ne . and antihypertensive_DDD ne . then do;
      if totalamount_taken12 ge antihypertensive_DDD then ddd_status12 = 1;
      else ddd_status12 = 0;
    end;

    ddd_value00 = totalamount_taken00/antihypertensive_DDD;
    ddd_value06 = totalamount_taken06/antihypertensive_DDD;
    ddd_value12 = totalamount_taken12/antihypertensive_DDD;


    label ddd_status00 = "Defined Daily Dose (DDD) Status at Baseline"
          ddd_status06 = "Defined Daily Dose (DDD) Status at 6-Month"
          ddd_status12 = "Defined Daily Dose (DDD) Status at 12-Month"
          ddd_value00 = "Defined Daily Dose (DDD) Ratio (taken/DDD) at Baseline"
          ddd_value06 = "Defined Daily Dose (DDD) Ratio (taken/DDD) at 6-Month"
          ddd_value12 = "Defined Daily Dose (DDD) Ratio (taken/DDD) at 12-Month";

    drop aceinhibitor--peripheral_dilator;
  run;

  data combomeds_forddd antihypertensive_meds_ddd_nocomb (drop = atccode1--dailyamount_taken_units_med2);
    merge antihypertensive_meds_ddd Dailyamount_combination_bpmeds (in = b keep = elig_studyid medname atccode1-atccode3
                                                                          timepoint1-timepoint3 adjstrength_numvalue_med1--dailyamount_taken_units_med2);
    by elig_studyid medname;
    if b then output combomeds_forddd;
    else output antihypertensive_meds_ddd_nocomb;
  run;

  proc sort data = combomeds_forddd;
    by atccode2;
  run;

  data combomeds_forddd;
    merge combomeds_forddd (in = a) antihypertensive_ddd_codes (in = b where = (AdmCode = 'O') drop = DDDComment DDD UnitType
                                                                  rename = (ATCCode=atccode2 adj_DDD=antihypertensive_DDD_med1 adj_DDDunits=antihypertensive_DDD_units1));
    by atccode2;
    if a;
  run;

  proc sort data = combomeds_forddd;
    by atccode3;
  run;

  data combomeds_forddd;
    merge combomeds_forddd (in = a) antihypertensive_ddd_codes (in = b where = (AdmCode = 'O') drop = DDDComment DDD UnitType
                                                                  rename = (ATCCode=atccode3 adj_DDD=antihypertensive_DDD_med2 adj_DDDunits=antihypertensive_DDD_units2));
    by atccode3;
    if a;
  run;

  data combomeds_forddd_final (drop = atccode1--antihypertensive_DDD_units2);
    set combomeds_forddd;
    if (dailyamount_taken_med1 ge antihypertensive_DDD_med1 or dailyamount_taken_med2 ge antihypertensive_DDD_med2) then do;
      if timepoint1 = 1 then do;
        ddd_status00 = 1;
        ddd_value00 = 1;
      end;
      if timepoint2 = 1 then do;
        ddd_status06 = 1;
        ddd_value06 = 1;
      end;
      if timepoint3 = 1 then do;
        ddd_status12 = 1;
        ddd_value12 = 1;
      end;
    end;
    else do;
      if timepoint1 = 1 then do;
        ddd_status00 = 0;
        ddd_value00 = max((dailyamount_taken_med1/antihypertensive_DDD_med1), (dailyamount_taken_med1/antihypertensive_DDD_med2));
      end;
      if timepoint2 = 1 then do;
        ddd_status06 = 0;
        ddd_value06 = max((dailyamount_taken_med1/antihypertensive_DDD_med1), (dailyamount_taken_med1/antihypertensive_DDD_med2));
      end;
      if timepoint3 = 1 then do;
        ddd_status12 = 0;
        ddd_value12 = max((dailyamount_taken_med1/antihypertensive_DDD_med1), (dailyamount_taken_med1/antihypertensive_DDD_med2));
      end;
    end;
  run;

  proc sort data = combomeds_forddd_final;
    by elig_studyid medname;
  run;

  data antihypertensive_meds_final;
    merge combomeds_forddd_final antihypertensive_meds_ddd_nocomb;
    by elig_studyid medname;
  run;

  data antihypertensive_meds_out;
    retain elig_studyid medname totalamount_taken00 totalamount_taken06 totalamount_taken12 dailyamount_taken_units antihypertensive_DDD antihypertensive_DDD_units;
    format ddd_status00 ddd_status06 ddd_status12 ddd_statusf.;
    format ddd_value00 ddd_value06 ddd_value12 change_ddd00_06 change_ddd00_12 best12.;
    merge antihypertensive_meds_final (in = a) visit_dates (in = b);
    by elig_studyid;
    if a;

    label change_ddd00_06 = "Change in Defined Daily Dose (DDD) from Baseline to 6-month"
          change_ddd00_12 = "Change in Defined Daily Dose (DDD) from Baseline to 12-month";
  run;

  data antihypertensive_meds_out (drop = baseline--medminute3);
    set antihypertensive_meds_out;
    array medhours[*] medhour1-medhour3;
    array medminutes[*] medminute1-medminute3;
    array medtimes[*] med_timetakena med_timetakenb med_timetakenc;

    do i = 1 to 3;
      if medtimes[i] ne . then do;
        medhours[i] = floor(medtimes[i]/100);
        medminutes[i] = medtimes[i] - (medhours[i]*100);
      end;
    end;
    drop i;

    do j = 1 to 3;
      medtimes[j] = hms(medhours[j],medminutes[j],0);
    end;
    drop j;

    *PRN and Combo meds will have NULL for all totalamount_taken variables;
    *for non-PRN, non_combo meds, change NULL values to 0 if participant completed given timepoint;
    if (totalamount_taken00 ne . or totalamount_taken06 ne . or totalamount_taken12 ne .) then do;
      if baseline ne . then do;
        if totalamount_taken00 = . then totalamount_taken00 = 0;
        if ddd_value00 = . then ddd_value00 = 0;
      end;

      if sixmonth ne . then do;
        if totalamount_taken06 = . then totalamount_taken06 = 0;
        if ddd_value06 = . then ddd_value06 = 0;
      end;

      if twelvemonth ne . then do;
        if totalamount_taken12 = . then totalamount_taken12 = 0;
        if ddd_value12 = . then ddd_value12 = 0;
      end;
    end;

    change_ddd00_06 = ddd_value06 - ddd_value00;
    change_ddd00_12 = ddd_value12 - ddd_value00;

    format med_timetakena med_timetakenb med_timetakenc HHMM5.;
  run;

  proc sql noprint;
    create table antihypertensive_ddd_summ as
    select elig_studyid, sum(ddd_value00) as total_antihypertensive_ddd00, sum(ddd_value06) as total_antihypertensive_ddd06, sum(ddd_value12) as total_antihypertensive_ddd12,
            sum(change_ddd00_06) as change_antihypertensive_ddd00_06, sum(change_ddd00_12) as change_antihypertensive_ddd00_12
    from antihypertensive_meds_out
    group by elig_studyid;
  quit;

  data antihypertensive_ddd_summ2;
    merge bestair.Bestair_alldata_randomizedpts (keep = elig_studyid rand_treatmentarm pooled_treatmentarm) antihypertensive_ddd_summ;
    by elig_studyid;
  run;

  data antihypertensive_catcount (keep = elig_studyid antihypertensive00--antihypertensive12 diuretic00--diuretic12 antihypertensive_n00--antihypertensive_n12
          antihypertensive_changein_n06 antihypertensive_newmedclass06 antihypertensive_changein_n12 antihypertensive_newmedclass12
          antihypertensive_dosechangeany--antihypertensive_doseincr12 total_antihyp_classes00 total_antihyp_classes06 total_antihyp_classes12);
    set finalmedicationscat;
    array baseline_cats[*] aceinhibitor00 alphablocker00 angiotensinblocker00 betablocker00 calciumblocker00 diuretic00 nitrate00 peripheraldilator00 otherah00;
    array mo6_cats[*] aceinhibitor06 alphablocker06 angiotensinblocker06 betablocker06 calciumblocker06 diuretic06 nitrate06 peripheraldilator06 otherah06;
    array mo12_cats[*] aceinhibitor12 alphablocker12 angiotensinblocker12 betablocker12 calciumblocker12 diuretic12 nitrate12 peripheraldilator12 otherah12;

    do i = 1 to dim(baseline_cats);
      if baseline_cats[i] > 0 then total_antihyp_classes00 = sum(total_antihyp_classes00,1);
      if mo6_cats[i] > 0 then total_antihyp_classes06 = sum(total_antihyp_classes06,1);
      if mo12_cats[i] > 0 then total_antihyp_classes12 = sum(total_antihyp_classes12,1);
    end;

  run;

  data antihypertensive_cat;
    retain elig_studyid rand_treatmentarm pooled_treatmentarm antihypertensive00 antihypertensive06 antihypertensive12 antihypertensive_n00 antihypertensive_n06 antihypertensive_n12;
    merge  antihypertensive_ddd_summ2 antihypertensive_catcount;
    by elig_studyid;

    array num_array[*] antihypertensive_n00--antihypertensive_n12;
    array ddd_array[*] total_antihypertensive_ddd00--total_antihypertensive_ddd12;

    do i = 1 to dim(num_array);
      if num_array[i] = 0 and ddd_array[i] = . then ddd_array[i]= 0;
    end;
    drop i;
  run;

  data antihypertensive_meds_out2;
    set antihypertensive_meds_out;
    by elig_studyid;

    retain participant_number;
    if first.elig_studyid then participant_number = sum(participant_number, 1);
  run;

  data check_against;
    merge meds_in antihypertensive_meds_out (in = b keep = elig_studyid medname);
    by elig_studyid medname;
    if b;
  run;
/*
  proc sql;
    select elig_studyid, medname
    from antihypertensive_meds_out
    where totalamount_taken00 = . and totalamount_taken06 = . and totalamount_taken12 = . and medname ne "Nitroglycerin";
  quit;
*/

  data bestair.bamedicationcat_bpmeds;
    set antihypertensive_cat;
  run;

  data bestair.bamedication_bpmeds_ddd;
    set antihypertensive_meds_out;
  run;

*additional steps for bp meds and diabetes rarely run and not public;
*%include "&bestairpath\_additional bp med and diabetes med work.sas";
