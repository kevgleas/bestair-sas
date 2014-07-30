proc datasets library=work nolist;
modify BESTAIRBP24HR;
label
studyid = '24BP: Study ID'
timepoint = '24BP: Timepoint'
bp24date = '24BP: Test Date'
starttime = '24BP: Start Time'
endtime = '24BP: End Time'
startsleep = '24BP: Sleep Start Time'
endsleep = '24BP: Sleep End Time'
nreadings = '24BP: Number of Readings'
nvalid = '24BP: Number of Valid Readings'
pctvalid = '24BP: Percent Valid Readings'
nsleep = '24BP: Number of Sleep Readings'
nwake = '24BP: Number of Awake Readings'
sysallmean = '24BP: Average Systolic Pressure (all readings)'
sysallsd = '24BP: Standard Deviation of Systolic Pressure (all readings)'
sysallmin = '24BP: Minimum Systolic Pressure (all readings)'
sysallmax = '24BP: Maximum Systolic Pressure (all readings)'
diaallmean = '24BP: Average Diastolic Pressure (all readings)'
diaallsd = '24BP: Standard Deviation of Diastolic Pressure (all readings)'
diaallmin = '24BP: Minimum Diastolic Pressure (all readings)'
diaallmax = '24BP: Maximum Diastolic Pressure (all readings)'
mapallmean = '24BP: Average Mean Arterial Pressure (all readings)'
mapallsd = '24BP: Standard Deviation of Mean Arterial Pressure (all readings)'
mapallmin = '24BP: Minimum Mean Arterial Pressure (all readings)'
mapallmax = '24BP: Maximum Mean Arterial Pressure (all readings)'
map2allmean = 'map2allmean'
map2allsd = 'map2allsd'
map2allmin = 'map2allmin'
map2allmax = 'map2allmax'
ppallmean = '24BP: Average Pulse Pressure (all readings)'
ppallsd = '24BP: Standard Deviation of Pulse Pressure (all readings)'
ppallmin = '24BP: Minimum Pulse Pressure (all readings)'
ppallmax = '24BP: Maximum Pulse Pressure (all readings)'
heartallmean = '24BP: Average Heart Rate(all readings)'
heartallsd = '24BP: Standard Deviation of Heart Rate (all readings)'
heartallmin = '24BP: Minimum Heart Rate (all readings)'
heartallmax = '24BP: Maximum Heart Rate (all readings)'
syssleepmean = '24BP: Average Systolic Pressure (asleep)'
syssleepsd = '24BP: Standard Deviation of Systolic Pressure (asleep)'
syssleepmin = '24BP: Minimum Systolic Pressure (asleep)'
syssleepmax = '24BP: Maximum Systolic Pressure (asleep)'
diasleepmean = '24BP: Average Diastolic Pressure (asleep)'
diasleepsd = '24BP: Standard Deviation of Diastolic Pressure (asleep)'
diasleepmin = '24BP: Minimum Diastolic Pressure (asleep)'
diasleepmax = '24BP: Maximum Diastolic Pressure (asleep)'
mapsleepmean = '24BP: Average Mean Arterial Pressure (asleep)'
mapsleepsd = '24BP: Standard Deviation of Mean Arterial Pressure (asleep)'
mapsleepmin = '24BP: Minimum Mean Arterial Pressure (asleep)'
mapsleepmax = '24BP: Maximum Mean Arterial Pressure (asleep)'
map2sleepmean = 'map2sleepmean'
map2sleepsd = 'map2sleepsd'
map2sleepmin = 'map2sleepmin'
map2sleepmax = 'map2sleepmax'
ppsleepmean = '24BP: Average Pulse Pressure (asleep)'
ppsleepsd = '24BP: Standard Deviation of Pulse Pressure (asleep)'
ppsleepmin = '24BP: Minimum Pulse Pressure (asleep)'
ppsleepmax = '24BP: Maximum Pulse Pressure (asleep)'
heartsleepmean = '24BP: Average Heart Rate (asleep)'
heartsleepsd = '24BP: Standard Deviation of Heart Rate (asleep)'
heartsleepmin = '24BP: Minimum Heart Rate (asleep)'
heartsleepmax = '24BP: Maximum Heart Rate (asleep)'
syswakemean = '24BP: Average Systolic Pressure (awake)'
syswakesd = '24BP: Standard Deviation of Systolic Pressure (awake)'
syswakemin = '24BP: Minimum Systolic Pressure (awake)'
syswakemax = '24BP: Maximum Systolic Pressure (awake)'
diawakemean = '24BP: Average Diastolic Pressure (awake)'
diawakesd = '24BP: Standard Deviation of Diastolic Pressure (awake)'
diawakemin = '24BP: Minimum Diastolic Pressure (awake)'
diawakemax = '24BP: Maximum Diastolic Pressure (awake)'
mapwakemean = '24BP: Average Mean Arterial Pressure (awake)'
mapwakesd = '24BP: Standard Deviation of Mean Arterial Pressure (awake)'
mapwakemin = '24BP: Minimum Mean Arterial Pressure (awake)'
mapwakemax = '24BP: Maximum Mean Arterial Pressure (awake)'
map2wakemean = 'map2wakemean'
map2wakesd = 'map2wakesd'
map2wakemin = 'map2wakemin'
map2wakemax = 'map2wakemax'
ppwakemean = '24BP: Average Pulse Pressure (awake)'
ppwakesd = '24BP: Standard Deviation of Pulse Pressure (awake)'
ppwakemin = '24BP: Minimum Pulse Pressure (awake)'
ppwakemax = '24BP: Maximum Pulse Pressure (awake)'
heartwakemean = '24BP: Average Heart Rate(awake)'
heartwakesd = '24BP: Standard Deviation of Heart Rate (awake)'
heartwakemin = '24BP: Minimum Heart Rate (awake)'
heartwakemax = '24BP: Maximum Heart Rate (awake)'
timetotal = '24BP: Total Study Time'
sleeptotal = '24BP: Total Study Time Asleep'
totalmin = '24BP: Total Study Time  (Minutes)'
sleepmin = '24BP: Total Study Time Asleep (Minutes)'
validsleep = '24BP: At Least 4 Valid Sleep Readings'
validwake = '24BP: At Least 10 Valid Wake Readings'
validall = '24BP: At Least 10 Valid Wake Readings and  At Least 4 Valid Sleep Readings'
mapsleepvalid = 'mapsleepvalid'
syssleepvalid = '24BP: Average Valid Systolic Pressure (asleep)'
diasleepvalid = '24BP: Average Valid Diastolic Pressure (asleep)'
mapwakevalid = 'mapwakevalid'
syswakevalid = '24BP: Average Valid Systolic Pressure (awake)'
diawakevalid = '24BP: Average Valid Diastolic Pressure (awake)'
mapratiovalid = 'mapratiovalid'
sysratiovalid = '24B:'
diaratiovalid = 'diaratiovalid'
mapnondip = 'mapnondip'
sysnondip = 'sysnondip'
dianondip = 'dianondip'
sysswratio = 'sysswratio'
diaswratio = 'diaswratio'
mapswratio = 'mapswratio'
heartswratio = 'heartswratio'
sysnondipping = 'sysnondipping'
dianondipping = 'dianondipping'
mapnondipping = 'mapnondipping'
heartnondipping = 'heartnondipping'
bp24mapweight = 'bp24mapweight'
bp24sbpweight = 'bp24sbpweight'
bp24dbpweight = 'bp24dbpweight'
monitorqc_namecode = 'Namecode:'
monitorqc_datecom = 'Date Completed:'
monitorqc_staffid = 'Staff ID:'
monitorqc_startdate = 'Start Date:'
monitorqc_starttime = 'Start Time:'
monitorqc_enddate = 'End Date:'
monitorqc_endtime = 'End Time:'
monitorqc_serialnumber = 'Monitor Serial Number:'
monitorqc_wearandcollect = '1. Able to wear and collect data for 24 hours?'
monitorqc_wearandcollreas = '1a. If no, state reason:'
monitorqc_dataupload = '2. Data uploaded successfully?'
monitorqc_datauploaddate = '2a. Date'
monitorqc_datauploadreas = '2b. If no, state reason:'
monitorqc_20hrs = '3. Received at least 20 hrs of recorded data?'
monitorqc_10readingsday = '4. Received at least 10 readings from day BP?'
monitorqc_4readingsnight = '5. Received at least 4 readings from night BP?'
monitorqc_percentsuccess = '6. More than 75% successful readings?'
monitorqc_comments = 'Comments:'
monitor_24_hr_qc_complete = 'Complete?'
inabp = 'inabp'
inredcap = 'inredcap'
;

format
bp24date MMDDYY8.
starttime TIME6.
endtime TIME6.
startsleep TIME6.
endsleep TIME6.
pctvalid 5.1
sysallmean 5.1
sysallsd 5.1
sysallmin 5.1
sysallmax 5.1
diaallmean 5.1
diaallsd 5.1
diaallmin 5.1
diaallmax 5.1
mapallmean 5.1
mapallsd 5.1
mapallmin 5.1
mapallmax 5.1
map2allmean 5.1
map2allsd 5.1
map2allmin 5.1
map2allmax 5.1
ppallmean 5.1
ppallsd 5.1
ppallmin 5.1
ppallmax 5.1
heartallmean 5.1
heartallsd 5.1
heartallmin 5.1
heartallmax 5.1
syssleepmean 5.1
syssleepsd 5.1
syssleepmin 5.1
syssleepmax 5.1
diasleepmean 5.1
diasleepsd 5.1
diasleepmin 5.1
diasleepmax 5.1
mapsleepmean 5.1
mapsleepsd 5.1
mapsleepmin 5.1
mapsleepmax 5.1
map2sleepmean 5.1
map2sleepsd 5.1
map2sleepmin 5.1
map2sleepmax 5.1
ppsleepmean 5.1
ppsleepsd 5.1
ppsleepmin 5.1
ppsleepmax 5.1
heartsleepmean 5.1
heartsleepsd 5.1
heartsleepmin 5.1
heartsleepmax 5.1
syswakemean 5.1
syswakesd 5.1
syswakemin 5.1
syswakemax 5.1
diawakemean 5.1
diawakesd 5.1
diawakemin 5.1
diawakemax 5.1
mapwakemean 5.1
mapwakesd 5.1
mapwakemin 5.1
mapwakemax 5.1
map2wakemean 5.1
map2wakesd 5.1
map2wakemin 5.1
map2wakemax 5.1
ppwakemean 5.1
ppwakesd 5.1
ppwakemin 5.1
ppwakemax 5.1
heartwakemean 5.1
heartwakesd 5.1
heartwakemin 5.1
heartwakemax 5.1
timetotal TIME6.
sleeptotal TIME6.
totalmin 8.
sleepmin 8.
monitorqc_namecode $500.
monitorqc_datecom YYMMDD10.
monitorqc_staffid $500.
monitorqc_startdate YYMMDD10.
monitorqc_starttime TIME5.
monitorqc_enddate YYMMDD10.
monitorqc_endtime TIME5.
monitorqc_serialnumber $500.
monitorqc_wearandcollect MONITORQC_WEARANDCOLLECT_.
monitorqc_wearandcollreas $500.
monitorqc_dataupload MONITORQC_DATAUPLOAD_.
monitorqc_datauploaddate YYMMDD10.
monitorqc_datauploadreas $500.
monitorqc_20hrs MONITORQC_20HRS_.
monitorqc_10readingsday MONITORQC_10READINGSDAY_.
monitorqc_4readingsnight MONITORQC_4READINGSNIGHT_.
monitorqc_percentsuccess MONITORQC_PERCENTSUCCESS_.
monitorqc_comments $500.
monitor_24_hr_qc_complete MONITOR_24_HR_QC_COMPLETE_.
;
run;
quit;
