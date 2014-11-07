*Note: program designed to run as part of "Import BestAIR 24hr BP data when appropriate;

  proc sql;
    title "BP Journal Bedtime Recorded in REDCap between 8 AM and 5 PM";
    select studyid, timepoint, bpj_timebed, bpj_timewake
    from redcapbp
    where 28800 le bpj_timebed le 61200;
  quit;

  data ids_bedtime2fix;
    set redcapbp;
    keep studyid timepoint;
    if 28800 le bpj_timebed le 61200;
  run;

  *merge the datasets from raw data files and manually entered QC forms;
  data allreadings_plusredcap;
    merge bp2(in=a) redcapbp(in=b);
    by studyid timepoint;

    if a then inabp=1;
    if b then inredcap=1;

  run;

  data all_timework errorsin_sleepreporting errorsin_wakereporting longrecording;
    set allreadings_plusredcap;
    by studyid timepoint;
    retain first_monitor_datetime previous_timevalue monitor_datetime sleepstart_datetime sleepend_datetime;
    format first_monitor_datetime monitor_datetime sleepstart_datetime sleepend_datetime DATETIME.;


    *hard code participants with strange schedules;
    if (studyid = 70015 and timepoint = 12) then do;
      if first.timepoint then do;
        sleepstart_datetime = dhms(monitorqc_startdate, hour(bpj_timebed), minute(bpj_timebed), 0);
        sleepend_datetime = dhms(monitorqc_startdate, hour(bpj_timewake), minute(bpj_timewake), 0);
        first_monitor_datetime = dhms(monitorqc_startdate,hour(time),minute(time),0);
      end;
      monitor_datetime = dhms(monitorqc_startdate,hour(time),minute(time),0);
    end;


    else if first.timepoint then do;
      first_monitor_datetime = dhms(monitorqc_startdate,hour(time),minute(time),0);
      monitor_datetime = dhms(monitorqc_startdate,hour(time),minute(time),0);
      previous_timevalue = time;
      if bpj_timebed ge 43200 then do;
        sleepstart_datetime = dhms(monitorqc_startdate, hour(bpj_timebed), minute(bpj_timebed), 0);
        sleepend_datetime = dhms(monitorqc_startdate + 1, hour(bpj_timewake), minute(bpj_timewake), 0);
      end;
      else do;
        sleepstart_datetime = dhms(monitorqc_startdate + 1, hour(bpj_timebed), minute(bpj_timebed), 0);
        sleepend_datetime = dhms(monitorqc_startdate + 1, hour(bpj_timewake), minute(bpj_timewake), 0);
      end;
    end;
    else do;
      if previous_timevalue ge 43200 and time < 43200 then do;
        monitor_datetime = dhms(datepart(monitor_datetime+86400),hour(time),minute(time),0);
      end;
      else do;
        monitor_datetime = dhms(datepart(monitor_datetime),hour(time),minute(time),0);
      end;
      previous_timevalue = time;
    end;

    if (sleepstart_datetime le monitor_datetime < sleepend_datetime) and comment not in('"Sleeping"','"Reported Awake"') then output errorsin_sleepreporting;
    if sleepstart_datetime ne . and sleepend_datetime ne . then do;
      if (monitor_datetime < sleepstart_datetime or monitor_datetime ge sleepend_datetime) and comment = '"Sleeping"'  then output errorsin_wakereporting;
    end;
    if last.timepoint then do;
      if monitor_datetime - first_monitor_datetime > 108000 then output longrecording;
    end;
    output all_timework;
  run;

  proc sql;
    title "Longer than 30 hours in Recording";
    title2 "Consider Trimming";
    select studyid, timepoint from longrecording;
  run;

  data errorsin_wakereporting_check;
    merge Errorsin_wakereporting (in = a) ids_bedtime2fix (in = b);
    by studyid timepoint;

    *exclude participants where bedtimes need fixing in REDCap and case where daylight savings (DST) affected clock (73250 at timepoint 0);
    *exclude participants who have been confirmed to be correct;
    if not b and (
        not(studyid = 73250 and timepoint = 0) and /*DST*/
        not(studyid = 73113 and timepoint = 12) and /*Extends into Day 2*/
        not(studyid = 82523 and timepoint = 0) and /*DST*/
        not(studyid = 73123 and timepoint = 12) and /*Very close to extending into Day 2 (14:00 to 13:59)*/
				not(studyid = 73666 and timepoint = 12) and /*Two 12-mo recordings*/
				not(studyid = 82093 and timepoint = 0) and /*First two readings are from study visit; continuous recordings began later that day*/
				not(studyid = 85013 and timepoint = 6) /*Just night readings*/
				);
  run;

  *instances with many "wake errors" for same id and timepoint most likely caused by > 24 hours worth of data;
  *delete cases where there appears to be a flaw in date only;
  data errorsin_wakereporting_check2;
    set errorsin_wakereporting_check;

    if floor(timepart(sleepstart_datetime)/43200) = floor(timepart(monitor_datetime)/43200) then do;
      if datepart(sleepstart_datetime) ne datepart(monitor_datetime) then delete;
    end;
    else if floor(timepart(sleepstart_datetime)/43200) > floor(timepart(monitor_datetime)/43200) then do;
      if datepart(sleepstart_datetime) ne datepart(monitor_datetime)-1 then delete;
    end;
    else if floor(timepart(sleepstart_datetime)/43200) < floor(timepart(monitor_datetime)/43200) then do;
      if datepart(sleepstart_datetime) ne datepart(monitor_datetime)+1 then delete;
    end;

  run;

  data errorsin_sleepreporting_check;
    set errorsin_sleepreporting;

    if floor(timepart(sleepend_datetime)/43200) = floor(timepart(monitor_datetime)/43200) then do;
      if datepart(sleepend_datetime) ne datepart(monitor_datetime) then delete;
    end;
    else if floor(timepart(sleepend_datetime)/43200) > floor(timepart(monitor_datetime)/43200) then do;
      if datepart(sleepend_datetime) ne datepart(monitor_datetime)-1 then delete;
    end;
    else if floor(timepart(sleepend_datetime)/43200) < floor(timepart(monitor_datetime)/43200) then do;
      if datepart(sleepend_datetime) ne datepart(monitor_datetime)+1 then delete;
    end;

  run;

  proc sort data = errorsin_sleepreporting_check out = errorsin_sleepreporting_ids nodupkey;
    by studyid timepoint;
  run;

  proc sql;
    title "Check .abp raw file Sleep Times Against BP Journal";
    select studyid, timepoint
    from errorsin_sleepreporting_ids;
  quit;

  data errorsin_sleepreporting_output;
    set errorsin_sleepreporting_check;
    keep studyid--time bpj_timebed bpj_timewake;
  run;

  data errorsin_sleepreporting_output2;
    set errorsin_sleepreporting;
    by studyid timepoint;

    *exclude participant whose last reading on day 2 occurs at a time that would have been considered sleeping on the first day;
    if not(studyid = 73113 and timepoint = 12);

		*exclude participant whose recording appears to begin earlier than actual initiation due to readings taken at visit;
		if not(studyid = 82093 and timepoint = 0);

    retain order_number;
    if first.timepoint then order_number = sum(order_number,1);
    keep studyid--time bpj_timebed bpj_timewake order_number;
  run;

  * proc export data = errorsin_sleepreporting_output2 outfile = "&bestairpath/Kevin/24hrBP Errors in Sleep Reporting2 &sasfiledate..csv" dbms = csv replace;
  * run;


  data errorsin_sleepreporting_valid;
    set errorsin_sleepreporting;
    if error ne '"EE"';
  run;

  proc sort data= errorsin_sleepreporting_valid out = errorsin_sleepreporting_valid2 nodupkey;
    by studyid timepoint;
  run;

  data bestair.temp_errorsin_sleepreporting;
    set errorsin_sleepreporting_valid2;
  run;

  data noerrorsin_sleepreporting_valid;
    merge all_timework (in = a) errorsin_sleepreporting_valid2 (in = b keep = studyid timepoint);
    by studyid timepoint;
    if not b;
  run;

  data noerror_wakingup;
    set noerrorsin_sleepreporting_valid;
    if comment = '"Waking up"';
  run;

  data errorsin_sleepreporting_valid3;
    set errorsin_sleepreporting_valid;
    if comment = '"Waking up"';
  run;

  data wakingup_all;
    set all_timework;
    if comment = '"Waking up"';
  run;

  data wakingup_haderrors;
    merge wakingup_all errorsin_sleepreporting_valid2(in = b keep = studyid timepoint);
    by studyid timepoint;
    if b;
  run;

  data wakingup_wasawake;
    merge wakingup_haderrors errorsin_sleepreporting_valid2(in = b keep = studyid timepoint monitor_datetime);
    by studyid timepoint monitor_datetime;
    if not b and comment = '"Waking up"';
  run;

  proc sql;
    title '"Waking Up" noted in .abp file but BP Journal indicates person was "Sleeping"';
    select studyid, timepoint, time
    from errorsin_sleepreporting_valid3;
  quit;

  data bpreadings_withbouts multiple_sleepbouts;
    set allreadings_plusredcap;
    by studyid timepoint;
    retain sleepbouts prev_reading;
    format prev_reading $20.;

    if first.timepoint then do;
      sleepbouts = 0;
      prev_reading = '';
    end;

    if comment = '"Sleeping"' and prev_reading ne '"Sleeping"' then sleepbouts = sleepbouts + 1;

    prev_reading = comment;

    if sleepbouts > 1 then output multiple_sleepbouts;
    output bpreadings_withbouts;
  run;

  proc sort data = multiple_sleepbouts out = multiple_sleepbouts_ids nodupkey;
    by studyid timepoint;
  run;

  proc sql;
    title "Multiple Sleep Bouts in Recording";
    select studyid, timepoint from multiple_sleepbouts_ids where studyid not in(73123,73666);
  quit;

  proc sql noprint;
    select quote(cat(strip(put(studyid,5.)), strip(put(timepoint,2.)))) into :multibout_idtimepoints  separated by ', '
    from multiple_sleepbouts_ids;

  quit;

  %put &multibout_idtimepoints;

  data bpreadings_hasmultibouts;
    set bpreadings_withbouts;

    if cat(strip(put(studyid,5.)), strip(put(timepoint,2.))) in(&multibout_idtimepoints);
  run;

  data bpreadings_hasmultibouts_check;
    set bpreadings_hasmultibouts;

    if not (studyid = 70107 and timepoint = 0) and
        not (studyid = 70165 and timepoint = 0) and
				not (studyid = 74404 and timepoint = 6);
  run;
