proc datasets library=work nolist;
modify numompsgreceipt;
label
pptid = 'Participant ID'
siteid = 'Site ID'
stdydt = '1. Date Study Recorded'
rcvddt = '2. Date Study Received by SRC'
staendt = '3. Week Ending Date (Receipt)'
reviewdt = '4. Date Study Reviewed'
stdytype = '4a. Type'
stdyvis = '4b. Visit'
unitid = '5. Unit ID'
techid = '6. Staff/Tech ID'
status = '7. Study Passed Status (Pass/Fail)'
rsnco = '7a. Failure Reason'
pfcomm = '8. Pass/Fail Comments'
anyalerts = 'Any urgent alerts?'
highprio = 'High priority scoring?'
scordt = '1. Date Scored'
scordtwkend = '2. Week Ending Date (Scoring)'
ahiq = '3. AHI (QS)'
reviewerid = 'Reviewer ID'
scorerid = 'Scorer ID'
anlysstart = '4. Analysis Start (0-1159)'
anlysstartap = '4a. AM/PM'
anlysstop = '5. Analysis Stop (0-1159)'
anlysstopap = '5a. AM/PM'
totalhrs = '6. Total Recording Time (hours)'
totalmin = '6. Total Recording Time (minutes)'
ekghrs = '7a. EKG (hours usable)'
ekgqual = '7b. EKG (quality code)'
cannhrs = '8a. Cannula Flow (hours usable)'
cannqual = '8b. Cannula Flow (quality code)'
thorhrs = '9a. Thoracic (hours usable)'
thorqual = '9b. Thoracic (quality code)'
abdohrs = '10a. Abdomen (hours usable)'
abdoqual = '10b. Abdomen (quality code)'
oxihrs = '11a. Oximetry (hours usable)'
oxiqual = '11b. Oximetry (quality code)'
flowlimit = '12. Flow Limitation Code'
snoring = '13. Snoring Code'
overall = '12. Overall Study Quality'
overall_comments = '13. Comments'
urgalertyn = '1. Did review result in urgent alerts?'
urgalert_notifydt = 'a. If Yes, Date site was notified'
urgalert_replydt = 'a. If Yes, Date site reply received'
alertahi50 = 'b1. Apnea-hypopnea index (AHI) > 50 (No/Yes)'
alerthypoyn = 'b2. Severe hypoxemia (No/Yes)'
alerthyporest = 'b2a. Baseline O2 sat < 88%'
alerthyposleep = 'b2b. O2 sat during sleep <90% for >10% of sleep time'
alertecgyn = 'b3. Specific heart rate and/or ECG finding (No/Yes)'
alertecghr40 = 'b3a. HR for >2 continuous minutes is <40 bpm'
alertecghr150 = 'b3b. HR for >2 continuous minutes is >150 bpm'
alertecgwide = 'b3c. Sustained wide complex rhythm'
alertecgsecond = 'b3d. Type 2 second degree AV block'
alertecgthird = 'b3e. Third degree AV block'
alertecgafib = 'b3f. Atrial fibrillation and/or flutter'
;

format
pptid $19.
siteid VD02352F.
stdydt mmddyy10.
rcvddt mmddyy10.
staendt mmddyy10.
reviewdt mmddyy10.
stdytype VD02365F.
stdyvis VD02366F.
unitid VD02350F.
techid VD02357F.
status VD01258F.
rsnco VD02228F.
pfcomm $2500.
anyalerts YESNOF.
highprio YESNOF.
scordt mmddyy10.
scordtwkend mmddyy10.
ahiq 6.1
reviewerid scoridf.
scorerid scoridf.
anlysstart 6.
anlysstartap VD00949F.
anlysstop 6.
anlysstopap VD00949F.
totalhrs 6.
totalmin 6.
ekghrs 6.
ekgqual VD01334F.
cannhrs 6.
cannqual VD01334F.
thorhrs 6.
thorqual VD01334F.
abdohrs 6.
abdoqual VD01334F.
oxihrs 6.
oxiqual VD01334F.
flowlimit FLOWSNORF.
snoring FLOWSNORF.
overall VD02355F.
overall_comments $2500.
urgalertyn YESNOF.
urgalert_notifydt mmddyy10.
urgalert_replydt mmddyy10.
alertahi50 YESNOF.
alerthypoyn YESNOF.
alerthyporest CHECKF.
alerthyposleep CHECKF.
alertecgyn YESNOF.
alertecghr40 CHECKF.
alertecghr150 CHECKF.
alertecgwide CHECKF.
alertecgsecond CHECKF.
alertecgthird CHECKF.
alertecgafib CHECKF.
;
run;
quit;
