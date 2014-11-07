proc datasets library=work nolist;
modify &bestairpsg_datasetname;
label
pptid = 'Participant ID'
acrostic = 'Acrostic'
stdydt = 'Date of Study'
rcvddt = 'Date received at Reading Center'
staendt = 'Week ending date received at Reading Center'
unitid = 'Unit ID - unit on which data were collected'
techid = 'Tech ID - Tech performing hookup'
siteid = 'Site ID'
status = 'Pass Fail Status'
rsnco = 'Reason for study failure'
EnvrmtOu = 'Environmental outlier'
pfcomm = 'Pass Fail comments'
prio = 'Flagged for priority scoring'
rcrdtime = 'QS - Recording time (minutes)'
scordt = 'QS - Date Scored'
scorid = 'QS - Scorer ID'
slptime = 'QS - Sleep Time (minutes)'
sclout = 'QS - Lights out set by scorer (hhmm)'
scslpon = 'QS - Sleep onset time (hhmm)'
sclon = 'QS - Lights on time'
lighoff = 'QS - Reported time to bed'
rdiqs = 'QS - RDI per scorer'
cpapuse = 'QS - CPAP / BiPAP use during study'
o2use = 'QS - Oxygen in use during study'
e1dur = 'Duration of signal: E1'
e2dur = 'Duration of signal: E2'
chindur = 'Duration of signal: Chin'
c3dur = 'Duration of signal: C3'
c4dur = 'Duration of signal: C4'
ecgdur = 'Duration of signal: ECG'
LegLdur = 'Duration of signal: Left Leg'
LegRdur = 'Duration of signal: Right Leg'
Airdur = 'Duration of signal: Airflow'
xflowdur = 'Duration of signal: Cannula Flow'
Chestdur = 'Duration of signal: Thoracic Effort'
Abdodur = 'Duration of signal: Abdominal Effort'
Oximdur = 'Duration of signal: Oximetry'
SUMdur = 'Duration of signal: SUM'
que1 = 'Quality of signal: E1'
que2 = 'Quality of signal: E2'
quchin = 'Quality of signal: Chin'
quc3 = 'Quality of signal: C3'
quc4 = 'Quality of signal: C4'
quecg = 'Quality of signal: ECG'
quLegL = 'Quality of signal: Left Leg'
quLegR = 'Quality of signal: Right Leg'
quAir = 'Quality of signal: Airflow'
quxflow = 'Quality of signal: Cannula Flow'
quChest = 'Quality of signal: Thoracic Effort'
quAbdo = 'Quality of signal: Abdominal Effort'
quOxim = 'Quality of signal: Oximetry'
quSUM = 'Quality of signal: SUM'
m1 = 'Signal quality issues found on M1 signal'
m2 = 'Signal quality issues found on M2 signal'
ref = 'Signal quality issues found on Reference / Ground signal'
posn = 'Signal quality issues found on Position signal'
overall = 'Overall Study Quality Grade'
slewake = 'Study scored sleep / wake only'
AHIov50 = 'Medical Alert - RDI > 50'
sao2lt85 = 'Medical Alert - SaO2 < 85%'
unuhrou = 'Medical Alert - unusual heart rate'
unuhrou3a = 'Medical Alert - unusual HR: new Afib'
unuhrou3b = 'Medical Alert - unusual HR: HR > 120 or < 50'
unuhrou4a = 'Medical Alert - unusual HR: 2nd or 3rd degree block'
unuhrou4b = 'Medical Alert - unusual HR: Acute ST Segment'
unuhrou4c = 'Medical Alert - unusual HR: NSVT 3-beat run'
unuhrou4d = 'Medical Alert - unusual HR: HR above 150 bpm for = 2 min'
unuhrou4e = 'Medical Alert - unusual HR: HR < 30 bpm for = 2 min'
unuhrou4f = 'Medical Alert - unusual HR: Other'
unuhrou4g = 'Medical Alert - unusual HR (removed from form on 11/16/09)'
unuhrou4h = 'Medical Alert - unusual HR (removed from form on 11/16/09)'
unuhrou4i = 'Medical Alert - unusual HR (removed from form on 11/16/09)'
unuhrou4j = 'Medical Alert - unusual HR (removed from form on 11/16/09)'
RecBeAw = 'Data Lost - Recording ended before wake'
LosBeg = 'Data Lost at beginning of study'
LosEnd = 'Data Lost at end of study'
LosOth = 'Data Lost during study'
WakSlePr = 'Wake/Sleep Scoring unreliable'
Stg1Stg2Pr = 'Stage1/Stage2 Scoring unreliable'
Stg2Stg3Pr = 'Stage2/Stage3-4 Scoring unreliable'
RemNRemPr = 'REM/NREM Scoring unreliable'
ArUnrel = 'Arousals unreliable'
RemArUnrel = 'Arousals unreliable (REM)'
RespEvPr = 'Respiratory scoring problems'
ApnHypPr = 'Apnea/Hypopnea scoring problems'
AbnorEEG = 'Abnormal EEG'
AlpDEL = 'Alpha Intrusion'
Period = 'Periodic breathing (5 min)'
LagBreath = 'Periodic large breahts'
NPFLOW = 'Flow limitation'
PLMWAKE = 'Leg movements in wake'
UnuStgOu = 'Unusual Staging'
RDI0Ou = 'RDI = 0 verified'
ARSL3OU = 'Arousal Index < 3 verified'
MaxResOu = 'Long respiratory events verified'
PLMOU = 'PLM > 25 verified'
OtherOu = 'Other outlier'
dhrinvalid = 'DHR data invalid (N/A on report)'
Comm = 'Signal Quality comments'
Notes = 'Scoring Notes'
inqs_form = 'inqs_form'
SCORERID = 'Scorer ID'
STDATEP = 'PSG Start Date'
SCOREDT = 'Date study scored'
STLOUTP = 'Lights out time (hh:mm:ss)'
STONSETP = 'Sleep onset time (hh:mm:ss)'
SLPLATP = 'Sleep Latency (minutes)'
REMLAIP = 'REM Latency I - including wake time (minutes)'
REMLAIIP = 'REM Latency II - excluding wake (minutes)'
TIMEBEDP = 'Time in bed (minutes)'
SLPPRDP = 'Total Sleep Time (minutes)'
SLPEFFP = 'Sleep Efficiency (%)'
TMSTG1P = 'Pct. sleep time in stage 1 sleep (%)'
MINSTG1P = 'Time in stage 1 sleep (minutes)'
TMSTG2P = 'Pct. sleep time in stage 2 sleep (%)'
MINSTG2P = 'Time in stage 2 sleep (minutes)'
TMSTG34P = 'Pct. sleep time in stage 3-4 sleep (%)'
MNSTG34P = 'Time in stage 3-4 sleep (minutes)'
TMREMP = 'Pct. sleep time in REM sleep (%)'
MINREMP = 'Time in REM sleep (minutes)'
ARREMBP = '# of Arousals (REM, Back, all desats)'
ARREMOP = '# of Arousals (REM, Other, all desats)'
ARNREMBP = '# of Arousals (NREM, Back, all desats)'
ARNREMOP = '# of Arousals (NREM, Other, all desats)'
AHREMBP = 'Arousals per hour (REM, Back, all desats)'
AHREMOP = 'Arousals per hour (REM, Other, all desats)'
AHNREMBP = 'Arousals per hour (NREM, Back, all desats)'
AHNREMOP = 'Arousals per hour (NREM, Other, all desats)'
AI = 'Arousal Index'
OAI = 'Obstructive Apnea Index'
CAI = 'Central Apnea Index'
STSTARTP = 'Study start time (hh:mm:ss)'
STENDP = 'Study end time (hh:mm:ss)'
STDURM = 'Study length (epoch 1 to last epoch- minutes)'
SCLOUTP = 'Lights out set by scorer (hh:mm:ss)'
STLONP = 'Lights on set by scorer (hh:mm:ss)'
STONSET1 = 'Sleep onset (start of sleep- hh:mm:ss) - scorer'
TIMEBEDM = 'Time in bed (minutes .5)'
SLPLATM = 'Sleep Latency (minutes .5)'
REMLATM = 'REM Latency I (minutes .5)'
WASOM = 'Wake time during sleep period (minutes .5)'
SLPTIMEM = 'Sleep Time (minutes .5)'
SLPPRDM = 'Sleep Period (minutes)'
STG2T1P = '# of stage 2 to stage 1 shifts during sleep'
STG34T2P = '# of stage 3/4 to stage 1/2 shifts during sleep'
REMT1P = '# of REM to stage 1 shifts during sleep'
REMT2P = '# of REM to stage 2 shifts during sleep'
REMT34P = '# of REM to stage 3/4 shifts during sleep'
SLPTAWP = '# of sleep to awake shifts'
HSTG2T1P = '# of stage 2 to stage 1 shifts per hour of sleep'
HSTG342P = '# of stage 3/4 to stage 1/2 shifts per hour of sleep'
HREMT1P = '# of REM to stage 1 shifts per hour of sleep'
HREMT2P = '# of REM to stage 2 shifts per hour of sleep'
HREMT34P = '# of REM to stage 3/4 shifts per hour of sleep'
HSLPTAWP = '# of sleep to awake shifts per hour'
BPMAVG = 'Average Heart rate (bpm)'
BPMMIN = 'Lowest Heart rate (bpm)'
BPMMAX = 'Highest Heart rate (bpm)'
APNEA3 = '# of Apnea events with >= 3% desat'
AHI3 = 'Apnea / Hypopnea events with >= 3% percent desat per hour of sleep'
AHIU3 = 'RDI – Apnea/Hypopnea/AASM Hypopneas with >= 3% desat'
HREMBP = '# of Hypopnea (REM, Back, all desats)'
RDIRBP = 'Hypopnea per hour (REM, Back, all desats)'
AVHRBP = 'Avg. Hypopnea length (REM, Back, all desats) (seconds)'
MNHRBP = 'Min. Hypopnea length (REM, Back, all desats) (seconds)'
MXHRBP = 'Max. Hypopnea length (REM, Back, all desats) (seconds)'
HROP = '# of Hypopnea (REM, Other, all desats)'
RDIROP = 'Hypopnea per hour (REM, Other, all desats)'
AVHROP = 'Avg. Hypopnea length (REM, Other, all desats) (seconds)'
MNHROP = 'Min. Hypopnea length (REM, Other, all desats) (seconds)'
MXHROP = 'Max. Hypopnea length (REM, Other, all desats) (seconds)'
HNRBP = '# of Hypopnea (NREM, Back, all desats)'
RDINBP = 'Hypopnea per hour (NREM, Back, all desats)'
AVHNBP = 'Avg. Hypopnea length (NREM, Back, all desats) (seconds)'
MNHNBP = 'Min. Hypopnea length (NREM, Back, all desats) (seconds)'
MXHNBP = 'Max. Hypopnea length (NREM, Back, all desats) (seconds)'
HNROP = '# of Hypopnea (NREM, Other, all desats)'
RDINOP = 'Hypopnea per hour (NREM, Other, all desats)'
AVHNOP = 'Avg. Hypopnea length (NREM, Other, all desats) (seconds)'
MNHNOP = 'Min. Hypopnea length (NREM, Other, all desats) (seconds)'
MXHNOP = 'Max. Hypopnea length (NREM, Other all desats) (seconds)'
CARBP = '# of Cent. Apnea (REM, Back, all desats)'
CARDRBP = 'Cent. Apnea per hour (REM, Back, all desats)'
AVCARBP = 'Avg. Cent. Apnea length (REM, Back, all desats) (seconds)'
MNCARBP = 'Min. Cent. Apnea length (REM, Back, all desats) (seconds)'
MXCARBP = 'Max. Cent. Apnea length (REM, Back, all desats) (seconds)'
CAROP = '# of Cent. Apnea (REM, Other, all desats)'
CARDROP = 'Cent. Apnea per hour (REM, Other, all desats)'
AVCAROP = 'Avg. Cent. Apnea length (REM, Other, all desats) (seconds)'
MNCAROP = 'Min. Cent. Apnea length (REM, Other, all desats) (seconds)'
MXCAROP = 'Max. Cent. Apnea length (REM, Other, all desats) (seconds)'
CANBP = '# of Cent. Apnea (NREM, Back, all desats)'
CARDNBP = 'Cent. Apnea per hour (NREM, Back, all desats)'
AVCANBP = 'Avg. Cent. Apnea length (NREM, Back, all desats) (seconds)'
MNCANBP = 'Min. Cent. Apnea length (NREM, Back, all desats) (seconds)'
MXCANBP = 'Max. Cent. Apnea length (NREM, Back, all desats) (seconds)'
CANOP = '# of Cent. Apnea (NREM, Other, all desats)'
CARDNOP = 'Cent. Apnea per hour (NREM, Other, all desats)'
AVCANOP = 'Avg. Cent. Apnea length (NREM, Other, all desats) (seconds)'
MNCANOP = 'Min. Cent. Apnea length (NREM, Other, all desats) (seconds)'
MXCANOP = 'Max. Cent. Apnea length (NREM, Other all desats) (seconds)'
OARBP = '# of Obs. Apnea (REM, Back, all desats)'
OARDRBP = 'Obs. Apnea per hour (REM, Back, all desats)'
AVOARBP = 'Avg. Obs. Apnea length (REM, Back, all desats) (seconds)'
MNOARBP = 'Min. Obs. Apnea length (REM, Back, all desats) (seconds)'
MXOARBP = 'Max. Obs. Apnea length (REM, Back, all desats) (seconds)'
OAROP = '# of Obs. Apnea (REM, Other, all desats)'
OARDROP = 'Obs. Apnea per hour (REM, Other, all desats)'
AVOAROP = 'Avg. Obs. Apnea length (REM, Other, all desats) (seconds)'
MNOAROP = 'Min. Obs. Apnea length (REM, Other, all desats) (seconds)'
MXOAROP = 'Max. Obs. Apnea length (REM, Other, all desats) (seconds)'
OANBP = '# of Obs. Apnea (NREM, Back, all desats)'
OARDNBP = 'Obs. Apnea per hour (NREM, Back, all desats)'
AVOANBP = 'Avg. Obs. Apnea length (NREM, Back, all desats) (seconds)'
MNOANBP = 'Min. Obs. Apnea length (NREM, Back, all desats) (seconds)'
MXOANBP = 'Max. Obs. Apnea length (NREM, Back, all desats) (seconds)'
OANOP = '# of Obs. Apnea (NREM, Other, all desats)'
OARDNOP = 'Obs. Apnea per hour (NREM, Other, all desats)'
AVOANOP = 'Avg. Obs. Apnea length (NREM, Other, all desats) (seconds)'
MNOANOP = 'Min. Obs. Apnea length (NREM, Other, all desats) (seconds)'
MXOANOP = 'Max. Obs. Apnea length (NREM, Other all desats) (seconds)'
MXDRBP = 'Max. Desat (REM, Back, all desats)'
MXDROP = 'Max. Desat (REM, Other, all desats)'
MXDNBP = 'Max. Desat (NREM, Back, all desats)'
MXDNOP = 'Max. Desat (NREM, Other, all desats)'
AVDRBP = 'Avg. Desat (REM, Back, all desats)'
AVDROP = 'Avg. Desat (REM, Other, all desats)'
AVDNBP = 'Avg. Desat (NREM, Back, all desats)'
AVDNOP = 'Avg. Desat (NREM, Other, all desats)'
MNDRBP = 'Min. SaO2 (REM, Back, all desats) (%)'
MNDROP = 'Min. SaO2 (REM, Other, all desats) (%)'
MNDNBP = 'Min. SaO2 (NREM, Back, all desats) (%)'
MNDNOP = 'Min. SaO2 (NREM, Other, all desats) (%)'
HREMBA = '# of Hypopnea w/ arousals (REM, Back, all desats)'
RDIRBA = 'Hypopnea per hour w/ arousals (REM, Back, all desats)'
AVHRBA = 'Avg. Hypopnea length w/ arousals (REM, Back, all desats) (seconds)'
MNHRBA = 'Min. Hypopnea length w/ arousals (REM, Back, all desats) (seconds)'
MXHRBA = 'Max. Hypopnea length w/ arousals (REM, Back, all desats) (seconds)'
HROA = '# of Hypopnea w/ arousals (REM, Other, all desats)'
RDIROA = 'Hypopnea per hour w/ arousals (REM, Other, all desats)'
AVHROA = 'Avg. Hypopnea length w/ arousals (REM, Other, all desats) (seconds)'
MNHROA = 'Min. Hypopnea length w/ arousals (REM, Other, all desats) (seconds)'
MXHROA = 'Max. Hypopnea length w/ arousals (REM, Other, all desats) (seconds)'
HNRBA = '# of Hypopnea w/ arousals (NREM, Back, all desats)'
RDINBA = 'Hypopnea per hour w/ arousals (NREM, Back, all desats)'
AVHNBA = 'Avg. Hypopnea length w/ arousals (NREM, Back, all desats) (seconds)'
MNHNBA = 'Min. Hypopnea length w/ arousals (NREM, Back, all desats) (seconds)'
MXHNBA = 'Max. Hypopnea length w/ arousals (NREM, Back, all desats) (seconds)'
HNROA = '# of Hypopnea w/ arousals (NREM, Other, all desats)'
RDINOA = 'Hypopnea per hour w/ arousals (NREM, Other, all desats)'
AVHNOA = 'Avg. Hypopnea length w/ arousals (NREM, Other, all desats) (seconds)'
MNHNOA = 'Min. Hypopnea length w/ arousals (NREM, Other, all desats) (seconds)'
MXHNOA = 'Max. Hypopnea length w/ arousals (NREM, Other all desats) (seconds)'
CARBA = '# of Cent. Apnea w/ arousals (REM, Back, all desats)'
CARDRBA = 'Cent. Apnea per hour w/ arousals (REM, Back, all desats)'
AVCARBA = 'Avg. Cent. Apnea length w/ arousals (REM, Back, all desats) (seconds)'
MNCARBA = 'Min. Cent. Apnea length w/ arousals (REM, Back, all desats) (seconds)'
MXCARBA = 'Max. Cent. Apnea length w/ arousals (REM, Back, all desats) (seconds)'
CAROA = '# of Cent. Apnea w/ arousals (REM, Other, all desats)'
CARDROA = 'Cent. Apnea per hour w/ arousals (REM, Other, all desats)'
AVCAROA = 'Avg. Cent. Apnea length w/ arousals (REM, Other, all desats) (seconds)'
MNCAROA = 'Min. Cent. Apnea length w/ arousals (REM, Other, all desats) (seconds)'
MXCAROA = 'Max. Cent. Apnea length w/ arousals (REM, Other, all desats) (seconds)'
CANBA = '# of Cent. Apnea w/ arousals (NREM, Back, all desats)'
CARDNBA = 'Cent. Apnea per hour w/ arousals (NREM, Back, all desats)'
AVCANBA = 'Avg. Cent. Apnea length w/ arousals (NREM, Back, all desats) (seconds)'
MNCANBA = 'Min. Cent. Apnea length w/ arousals (NREM, Back, all desats) (seconds)'
MXCANBA = 'Max. Cent. Apnea length w/ arousals (NREM, Back, all desats) (seconds)'
CANOA = '# of Cent. Apnea w/ arousals (NREM, Other, all desats)'
CARDNOA = 'Cent. Apnea per hour w/ arousals (NREM, Other, all desats)'
AVCANOA = 'Avg. Cent. Apnea length w/ arousals (NREM, Other, all desats) (seconds)'
MNCANOA = 'Min. Cent. Apnea length w/ arousals (NREM, Other, all desats) (seconds)'
MXCANOA = 'Max. Cent. Apnea length w/ arousals (NREM, Other all desats) (seconds)'
OARBA = '# of Obs. Apnea w/ arousals (REM, Back, all desats)'
OARDRBA = 'Obs. Apnea per hour w/ arousals (REM, Back, all desats)'
AVOARBA = 'Avg. Obs. Apnea length w/ arousals (REM, Back, all desats) (seconds)'
MNOARBA = 'Min. Obs. Apnea length w/ arousals (REM, Back, all desats) (seconds)'
MXOARBA = 'Max. Obs. Apnea length w/ arousals (REM, Back, all desats) (seconds)'
OAROA = '# of Obs. Apnea w/ arousals (REM, Other, all desats)'
OARDROA = 'Obs. Apnea per hour w/ arousals (REM, Other, all desats)'
AVOAROA = 'Avg. Obs. Apnea length w/ arousals (REM, Other, all desats) (seconds)'
MNOAROA = 'Min. Obs. Apnea length w/ arousals (REM, Other, all desats) (seconds)'
MXOAROA = 'Max. Obs. Apnea length w/ arousals (REM, Other, all desats) (seconds)'
OANBA = '# of Obs. Apnea w/ arousals (NREM, Back, all desats)'
OARDNBA = 'Obs. Apnea per hour w/ arousals (NREM, Back, all desats)'
AVOANBA = 'Avg. Obs. Apnea length w/ arousals (NREM, Back, all desats) (seconds)'
MNOANBA = 'Min. Obs. Apnea length w/ arousals (NREM, Back, all desats) (seconds)'
MXOANBA = 'Max. Obs. Apnea length w/ arousals (NREM, Back, all desats) (seconds)'
OANOA = '# of Obs. Apnea w/ arousals (NREM, Other, all desats)'
OARDNOA = 'Obs. Apnea per hour w/ arousals (NREM, Other, all desats)'
AVOANOA = 'Avg. Obs. Apnea length w/ arousals (NREM, Other, all desats) (seconds)'
MNOANOA = 'Min. Obs. Apnea length w/ arousals (NREM, Other, all desats) (seconds)'
MXOANOA = 'Max. Obs. Apnea length w/ arousals (NREM, Other all desats) (seconds)'
MXDRBA = 'Max. Desat w/ arousals (REM, Back, all desats)'
MXDROA = 'Max. Desat w/ arousals (REM, Other, all desats)'
MXDNBA = 'Max. Desat w/ arousals (NREM, Back, all desats)'
MXDNOA = 'Max. Desat w/ arousals (NREM, Other, all desats)'
AVDRBA = 'Avg. Desat w/ arousals (REM, Back, all desats)'
AVDROA = 'Avg. Desat w/ arousals (REM, Other, all desats)'
AVDNBA = 'Avg. Desat w/ arousals (NREM, Back, all desats)'
AVDNOA = 'Avg. Desat w/ arousals (NREM, Other, all desats)'
MNDRBA = 'Min. SaO2 w/ arousals (REM, Back, all desats) (%)'
MNDROA = 'Min. SaO2 w/ arousals (REM, Other, all desats) (%)'
MNDNBA = 'Min. SaO2 w/ arousals (NREM, Back, all desats) (%)'
MNDNOA = 'Min. SaO2 w/ arousals (NREM, Other, all desats) (%)'
HREMBP2 = '# of Hypopnea (REM, Back, 2% desat)'
RDIRBP2 = 'Hypopnea per hour (REM, Back, 2% desat)'
AVHRBP2 = 'Avg. Hypopnea length (REM, Back, 2% desat) (seconds)'
MNHRBP2 = 'Min. Hypopnea length (REM, Back, 2% desat) (seconds)'
MXHRBP2 = 'Max. Hypopnea length (REM, Back, 2% desat) (seconds)'
HROP2 = '# of Hypopnea (REM, Other, 2% desat)'
RDIROP2 = 'Hypopnea per hour (REM, Other, 2% desat)'
AVHROP2 = 'Avg. Hypopnea length (REM, Other, 2% desat) (seconds)'
MNHROP2 = 'Min. Hypopnea length (REM, Other, 2% desat) (seconds)'
MXHROP2 = 'Max. Hypopnea length (REM, Other, 2% desat) (seconds)'
HNRBP2 = '# of Hypopnea (NREM, Back, 2% desat)'
RDINBP2 = 'Hypopnea per hour (NREM, Back, 2% desat)'
AVHNBP2 = 'Avg. Hypopnea length (NREM, Back, 2% desat) (seconds)'
MNHNBP2 = 'Min. Hypopnea length (NREM, Back, 2% desat) (seconds)'
MXHNBP2 = 'Max. Hypopnea length (NREM, Back, 2% desat) (seconds)'
HNROP2 = '# of Hypopnea (NREM, Other, 2% desat)'
RDINOP2 = 'Hypopnea per hour (NREM, Other, 2% desat)'
AVHNOP2 = 'Avg. Hypopnea length (NREM, Other, 2% desat) (seconds)'
MNHNOP2 = 'Min. Hypopnea length (NREM, Other, 2% desat) (seconds)'
MXHNOP2 = 'Max. Hypopnea length (NREM, Other 2% desat) (seconds)'
CARBP2 = '# of Cent. Apnea (REM, Back, 2% desat)'
CARDRBP2 = 'Cent. Apnea per hour (REM, Back, 2% desat)'
AVCARBP2 = 'Avg. Cent. Apnea length (REM, Back, 2% desat) (seconds)'
MNCARBP2 = 'Min. Cent. Apnea length (REM, Back, 2% desat) (seconds)'
MXCARBP2 = 'Max. Cent. Apnea length (REM, Back, 2% desat) (seconds)'
CAROP2 = '# of Cent. Apnea (REM, Other, 2% desat)'
CARDROP2 = 'Cent. Apnea per hour (REM, Other, 2% desat)'
AVCAROP2 = 'Avg. Cent. Apnea length (REM, Other, 2% desat) (seconds)'
MNCAROP2 = 'Min. Cent. Apnea length (REM, Other, 2% desat) (seconds)'
MXCAROP2 = 'Max. Cent. Apnea length (REM, Other, 2% desat) (seconds)'
CANBP2 = '# of Cent. Apnea (NREM, Back, 2% desat)'
CARDNBP2 = 'Cent. Apnea per hour (NREM, Back, 2% desat)'
AVCANBP2 = 'Avg. Cent. Apnea length (NREM, Back, 2% desat) (seconds)'
MNCANBP2 = 'Min. Cent. Apnea length (NREM, Back, 2% desat) (seconds)'
MXCANBP2 = 'Max. Cent. Apnea length (NREM, Back, 2% desat) (seconds)'
CANOP2 = '# of Cent. Apnea (NREM, Other, 2% desat)'
CARDNOP2 = 'Cent. Apnea per hour (NREM, Other, 2% desat)'
AVCANOP2 = 'Avg. Cent. Apnea length (NREM, Other, 2% desat) (seconds)'
MNCANOP2 = 'Min. Cent. Apnea length (NREM, Other, 2% desat) (seconds)'
MXCANOP2 = 'Max. Cent. Apnea length (NREM, Other 2% desat) (seconds)'
OARBP2 = '# of Obs. Apnea (REM, Back, 2% desat)'
OARDRBP2 = 'Obs. Apnea per hour (REM, Back, 2% desat)'
AVOARBP2 = 'Avg. Obs. Apnea length (REM, Back, 2% desat) (seconds)'
MNOARBP2 = 'Min. Obs. Apnea length (REM, Back, 2% desat) (seconds)'
MXOARBP2 = 'Max. Obs. Apnea length (REM, Back, 2% desat) (seconds)'
OAROP2 = '# of Obs. Apnea (REM, Other, 2% desat)'
OARDROP2 = 'Obs. Apnea per hour (REM, Other, 2% desat)'
AVOAROP2 = 'Avg. Obs. Apnea length (REM, Other, 2% desat) (seconds)'
MNOAROP2 = 'Min. Obs. Apnea length (REM, Other, 2% desat) (seconds)'
MXOAROP2 = 'Max. Obs. Apnea length (REM, Other, 2% desat) (seconds)'
OANBP2 = '# of Obs. Apnea (NREM, Back, 2% desat)'
OARDNBP2 = 'Obs. Apnea per hour (NREM, Back, 2% desat)'
AVOANBP2 = 'Avg. Obs. Apnea length (NREM, Back, 2% desat) (seconds)'
MNOANBP2 = 'Min. Obs. Apnea length (NREM, Back, 2% desat) (seconds)'
MXOANBP2 = 'Max. Obs. Apnea length (NREM, Back, 2% desat) (seconds)'
OANOP2 = '# of Obs. Apnea (NREM, Other, 2% desat)'
OARDNOP2 = 'Obs. Apnea per hour (NREM, Other, 2% desat)'
AVOANOP2 = 'Avg. Obs. Apnea length (NREM, Other, 2% desat) (seconds)'
MNOANOP2 = 'Min. Obs. Apnea length (NREM, Other, 2% desat) (seconds)'
MXOANOP2 = 'Max. Obs. Apnea length (NREM, Other 2% desat) (seconds)'
MXDRBP2 = 'Max. Desat (REM, Back, 2% desat)'
MXDROP2 = 'Max. Desat (REM, Other, 2% desat)'
MXDNBP2 = 'Max. Desat (NREM, Back, 2% desat)'
MXDNOP2 = 'Max. Desat (NREM, Other, 2% desat)'
AVDRBP2 = 'Avg. Desat (REM, Back, 2% desat)'
AVDROP2 = 'Avg. Desat (REM, Other, 2% desat)'
AVDNBP2 = 'Avg. Desat (NREM, Back, 2% desat)'
AVDNOP2 = 'Avg. Desat (NREM, Other, 2% desat)'
MNDRBP2 = 'Min. SaO2 (REM, Back, 2% desat) (%)'
MNDROP2 = 'Min. SaO2 (REM, Other, 2% desat) (%)'
MNDNBP2 = 'Min. SaO2 (NREM, Back, 2% desat) (%)'
MNDNOP2 = 'Min. SaO2 (NREM, Other, 2% desat) (%)'
HREMBA2 = '# of Hypopnea w/ arousals (REM, Back, 2% desat)'
RDIRBA2 = 'Hypopnea per hour w/ arousals (REM, Back, 2% desat)'
AVHRBA2 = 'Avg. Hypopnea length w/ arousals (REM, Back, 2% desat) (seconds)'
MNHRBA2 = 'Min. Hypopnea length w/ arousals (REM, Back, 2% desat) (seconds)'
MXHRBA2 = 'Max. Hypopnea length w/ arousals (REM, Back, 2% desat) (seconds)'
HROA2 = '# of Hypopnea w/ arousals (REM, Other, 2% desat)'
RDIROA2 = 'Hypopnea per hour w/ arousals (REM, Other, 2% desat)'
AVHROA2 = 'Avg. Hypopnea length w/ arousals (REM, Other, 2% desat) (seconds)'
MNHROA2 = 'Min. Hypopnea length w/ arousals (REM, Other, 2% desat) (seconds)'
MXHROA2 = 'Max. Hypopnea length w/ arousals (REM, Other, 2% desat) (seconds)'
HNRBA2 = '# of Hypopnea w/ arousals (NREM, Back, 2% desat)'
RDINBA2 = 'Hypopnea per hour w/ arousals (NREM, Back, 2% desat)'
AVHNBA2 = 'Avg. Hypopnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
MNHNBA2 = 'Min. Hypopnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
MXHNBA2 = 'Max. Hypopnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
HNROA2 = '# of Hypopnea w/ arousals (NREM, Other, 2% desat)'
RDINOA2 = 'Hypopnea per hour w/ arousals (NREM, Other, 2% desat)'
AVHNOA2 = 'Avg. Hypopnea length w/ arousals (NREM, Other, 2% desat) (seconds)'
MNHNOA2 = 'Min. Hypopnea length w/ arousals (NREM, Other, 2% desat) (seconds)'
MXHNOA2 = 'Max. Hypopnea length w/ arousals (NREM, Other 2% desat) (seconds)'
CARBA2 = '# of Cent. Apnea w/ arousals (REM, Back, 2% desat)'
CARDRBA2 = 'Cent. Apnea per hour w/ arousals (REM, Back, 2% desat)'
AVCARBA2 = 'Avg. Cent. Apnea length w/ arousals (REM, Back, 2% desat) (seconds)'
MNCARBA2 = 'Min. Cent. Apnea length w/ arousals (REM, Back, 2% desat) (seconds)'
MXCARBA2 = 'Max. Cent. Apnea length w/ arousals (REM, Back, 2% desat) (seconds)'
CAROA2 = '# of Cent. Apnea w/ arousals (REM, Other, 2% desat)'
CARDROA2 = 'Cent. Apnea per hour w/ arousals (REM, Other, 2% desat)'
AVCAROA2 = 'Avg. Cent. Apnea length w/ arousals (REM, Other, 2% desat) (seconds)'
MNCAROA2 = 'Min. Cent. Apnea length w/ arousals (REM, Other, 2% desat) (seconds)'
MXCAROA2 = 'Max. Cent. Apnea length w/ arousals (REM, Other, 2% desat) (seconds)'
CANBA2 = '# of Cent. Apnea w/ arousals (NREM, Back, 2% desat)'
CARDNBA2 = 'Cent. Apnea per hour w/ arousals (NREM, Back, 2% desat)'
AVCANBA2 = 'Avg. Cent. Apnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
MNCANBA2 = 'Min. Cent. Apnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
MXCANBA2 = 'Max. Cent. Apnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
CANOA2 = '# of Cent. Apnea w/ arousals (NREM, Other, 2% desat)'
CARDNOA2 = 'Cent. Apnea per hour w/ arousals (NREM, Other, 2% desat)'
AVCANOA2 = 'Avg. Cent. Apnea length w/ arousals (NREM, Other, 2% desat) (seconds)'
MNCANOA2 = 'Min. Cent. Apnea length w/ arousals (NREM, Other, 2% desat) (seconds)'
MXCANOA2 = 'Max. Cent. Apnea length w/ arousals (NREM, Other 2% desat) (seconds)'
OARBA2 = '# of Obs. Apnea w/ arousals (REM, Back, 2% desat)'
OARDRBA2 = 'Obs. Apnea per hour w/ arousals (REM, Back, 2% desat)'
AVOARBA2 = 'Avg. Obs. Apnea length w/ arousals (REM, Back, 2% desat) (seconds)'
MNOARBA2 = 'Min. Obs. Apnea length w/ arousals (REM, Back, 2% desat) (seconds)'
MXOARBA2 = 'Max. Obs. Apnea length w/ arousals (REM, Back, 2% desat) (seconds)'
OAROA2 = '# of Obs. Apnea w/ arousals (REM, Other, 2% desat)'
OARDROA2 = 'Obs. Apnea per hour w/ arousals (REM, Other, 2% desat)'
AVOAROA2 = 'Avg. Obs. Apnea length w/ arousals (REM, Other, 2% desat) (seconds)'
MNOAROA2 = 'Min. Obs. Apnea length w/ arousals (REM, Other, 2% desat) (seconds)'
MXOAROA2 = 'Max. Obs. Apnea length w/ arousals (REM, Other, 2% desat) (seconds)'
OANBA2 = '# of Obs. Apnea w/ arousals (NREM, Back, 2% desat)'
OARDNBA2 = 'Obs. Apnea per hour w/ arousals (NREM, Back, 2% desat)'
AVOANBA2 = 'Avg. Obs. Apnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
MNOANBA2 = 'Min. Obs. Apnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
MXOANBA2 = 'Max. Obs. Apnea length w/ arousals (NREM, Back, 2% desat) (seconds)'
OANOA2 = '# of Obs. Apnea w/ arousals (NREM, Other, 2% desat)'
OARDNOA2 = 'Obs. Apnea per hour w/ arousals (NREM, Other, 2% desat)'
AVOANOA2 = 'Avg. Obs. Apnea length w/ arousals (NREM, Other, 2% desat) (seconds)'
MNOANOA2 = 'Min. Obs. Apnea length w/ arousals (NREM, Other, 2% desat) (seconds)'
MXOANOA2 = 'Max. Obs. Apnea length w/ arousals (NREM, Other 2% desat) (seconds)'
MXDRBA2 = 'Max. Desat w/ arousals (REM, Back, 2% desat)'
MXDROA2 = 'Max. Desat w/ arousals (REM, Other, 2% desat)'
MXDNBA2 = 'Max. Desat w/ arousals (NREM, Back, 2% desat)'
MXDNOA2 = 'Max. Desat w/ arousals (NREM, Other, 2% desat)'
AVDRBA2 = 'Avg. Desat w/ arousals (REM, Back, 2% desat)'
AVDROA2 = 'Avg. Desat w/ arousals (REM, Other, 2% desat)'
AVDNBA2 = 'Avg. Desat w/ arousals (NREM, Back, 2% desat)'
AVDNOA2 = 'Avg. Desat w/ arousals (NREM, Other, 2% desat)'
MNDRBA2 = 'Min. SaO2 w/ arousals (REM, Back, 2% desat) (%)'
MNDROA2 = 'Min. SaO2 w/ arousals (REM, Other, 2% desat) (%)'
MNDNBA2 = 'Min. SaO2 w/ arousals (NREM, Back, 2% desat) (%)'
MNDNOA2 = 'Min. SaO2 w/ arousals (NREM, Other, 2% desat) (%)'
HREMBP3 = '# of Hypopnea (REM, Back, 3% desat)'
RDIRBP3 = 'Hypopnea per hour (REM, Back, 3% desat)'
AVHRBP3 = 'Avg. Hypopnea length (REM, Back, 3% desat) (seconds)'
MNHRBP3 = 'Min. Hypopnea length (REM, Back, 3% desat) (seconds)'
MXHRBP3 = 'Max. Hypopnea length (REM, Back, 3% desat) (seconds)'
HROP3 = '# of Hypopnea (REM, Other, 3% desat)'
RDIROP3 = 'Hypopnea per hour (REM, Other, 3% desat)'
AVHROP3 = 'Avg. Hypopnea length (REM, Other, 3% desat) (seconds)'
MNHROP3 = 'Min. Hypopnea length (REM, Other, 3% desat) (seconds)'
MXHROP3 = 'Max. Hypopnea length (REM, Other, 3% desat) (seconds)'
HNRBP3 = '# of Hypopnea (NREM, Back, 3% desat)'
RDINBP3 = 'Hypopnea per hour (NREM, Back, 3% desat)'
AVHNBP3 = 'Avg. Hypopnea length (NREM, Back, 3% desat) (seconds)'
MNHNBP3 = 'Min. Hypopnea length (NREM, Back, 3% desat) (seconds)'
MXHNBP3 = 'Max. Hypopnea length (NREM, Back, 3% desat) (seconds)'
HNROP3 = '# of Hypopnea (NREM, Other, 3% desat)'
RDINOP3 = 'Hypopnea per hour (NREM, Other, 3% desat)'
AVHNOP3 = 'Avg. Hypopnea length (NREM, Other, 3% desat) (seconds)'
MNHNOP3 = 'Min. Hypopnea length (NREM, Other, 3% desat) (seconds)'
MXHNOP3 = 'Max. Hypopnea length (NREM, Other 3% desat) (seconds)'
CARBP3 = '# of Cent. Apnea (REM, Back, 3% desat)'
CARDRBP3 = 'Cent. Apnea per hour (REM, Back, 3% desat)'
AVCARBP3 = 'Avg. Cent. Apnea length (REM, Back, 3% desat) (seconds)'
MNCARBP3 = 'Min. Cent. Apnea length (REM, Back, 3% desat) (seconds)'
MXCARBP3 = 'Max. Cent. Apnea length (REM, Back, 3% desat) (seconds)'
CAROP3 = '# of Cent. Apnea (REM, Other, 3% desat)'
CARDROP3 = 'Cent. Apnea per hour (REM, Other, 3% desat)'
AVCAROP3 = 'Avg. Cent. Apnea length (REM, Other, 3% desat) (seconds)'
MNCAROP3 = 'Min. Cent. Apnea length (REM, Other, 3% desat) (seconds)'
MXCAROP3 = 'Max. Cent. Apnea length (REM, Other, 3% desat) (seconds)'
CANBP3 = '# of Cent. Apnea (NREM, Back, 3% desat)'
CARDNBP3 = 'Cent. Apnea per hour (NREM, Back, 3% desat)'
AVCANBP3 = 'Avg. Cent. Apnea length (NREM, Back, 3% desat) (seconds)'
MNCANBP3 = 'Min. Cent. Apnea length (NREM, Back, 3% desat) (seconds)'
MXCANBP3 = 'Max. Cent. Apnea length (NREM, Back, 3% desat) (seconds)'
CANOP3 = '# of Cent. Apnea (NREM, Other, 3% desat)'
CARDNOP3 = 'Cent. Apnea per hour (NREM, Other, 3% desat)'
AVCANOP3 = 'Avg. Cent. Apnea length (NREM, Other, 3% desat) (seconds)'
MNCANOP3 = 'Min. Cent. Apnea length (NREM, Other, 3% desat) (seconds)'
MXCANOP3 = 'Max. Cent. Apnea length (NREM, Other 3% desat) (seconds)'
OARBP3 = '# of Obs. Apnea (REM, Back, 3% desat)'
OARDRBP3 = 'Obs. Apnea per hour (REM, Back, 3% desat)'
AVOARBP3 = 'Avg. Obs. Apnea length (REM, Back, 3% desat) (seconds)'
MNOARBP3 = 'Min. Obs. Apnea length (REM, Back, 3% desat) (seconds)'
MXOARBP3 = 'Max. Obs. Apnea length (REM, Back, 3% desat) (seconds)'
OAROP3 = '# of Obs. Apnea (REM, Other, 3% desat)'
OARDROP3 = 'Obs. Apnea per hour (REM, Other, 3% desat)'
AVOAROP3 = 'Avg. Obs. Apnea length (REM, Other, 3% desat) (seconds)'
MNOAROP3 = 'Min. Obs. Apnea length (REM, Other, 3% desat) (seconds)'
MXOAROP3 = 'Max. Obs. Apnea length (REM, Other, 3% desat) (seconds)'
OANBP3 = '# of Obs. Apnea (NREM, Back, 3% desat)'
OARDNBP3 = 'Obs. Apnea per hour (NREM, Back, 3% desat)'
AVOANBP3 = 'Avg. Obs. Apnea length (NREM, Back, 3% desat) (seconds)'
MNOANBP3 = 'Min. Obs. Apnea length (NREM, Back, 3% desat) (seconds)'
MXOANBP3 = 'Max. Obs. Apnea length (NREM, Back, 3% desat) (seconds)'
OANOP3 = '# of Obs. Apnea (NREM, Other, 3% desat)'
OARDNOP3 = 'Obs. Apnea per hour (NREM, Other, 3% desat)'
AVOANOP3 = 'Avg. Obs. Apnea length (NREM, Other, 3% desat) (seconds)'
MNOANOP3 = 'Min. Obs. Apnea length (NREM, Other, 3% desat) (seconds)'
MXOANOP3 = 'Max. Obs. Apnea length (NREM, Other 3% desat) (seconds)'
MXDRBP3 = 'Max. Desat (REM, Back, 3% desat)'
MXDROP3 = 'Max. Desat (REM, Other, 3% desat)'
MXDNBP3 = 'Max. Desat (NREM, Back, 3% desat)'
MXDNOP3 = 'Max. Desat (NREM, Other, 3% desat)'
AVDRBP3 = 'Avg. Desat (REM, Back, 3% desat)'
AVDROP3 = 'Avg. Desat (REM, Other, 3% desat)'
AVDNBP3 = 'Avg. Desat (NREM, Back, 3% desat)'
AVDNOP3 = 'Avg. Desat (NREM, Other, 3% desat)'
MNDRBP3 = 'Min. SaO2 (REM, Back, 3% desat) (%)'
MNDROP3 = 'Min. SaO2 (REM, Other, 3% desat) (%)'
MNDNBP3 = 'Min. SaO2 (NREM, Back, 3% desat) (%)'
MNDNOP3 = 'Min. SaO2 (NREM, Other, 3% desat) (%)'
HREMBA3 = '# of Hypopnea w/ arousals (REM, Back, 3% desat)'
RDIRBA3 = 'Hypopnea per hour w/ arousals (REM, Back, 3% desat)'
AVHRBA3 = 'Avg. Hypopnea length w/ arousals (REM, Back, 3% desat) (seconds)'
MNHRBA3 = 'Min. Hypopnea length w/ arousals (REM, Back, 3% desat) (seconds)'
MXHRBA3 = 'Max. Hypopnea length w/ arousals (REM, Back, 3% desat) (seconds)'
HROA3 = '# of Hypopnea w/ arousals (REM, Other, 3% desat)'
RDIROA3 = 'Hypopnea per hour w/ arousals (REM, Other, 3% desat)'
AVHROA3 = 'Avg. Hypopnea length w/ arousals (REM, Other, 3% desat) (seconds)'
MNHROA3 = 'Min. Hypopnea length w/ arousals (REM, Other, 3% desat) (seconds)'
MXHROA3 = 'Max. Hypopnea length w/ arousals (REM, Other, 3% desat) (seconds)'
HNRBA3 = '# of Hypopnea w/ arousals (NREM, Back, 3% desat)'
RDINBA3 = 'Hypopnea per hour w/ arousals (NREM, Back, 3% desat)'
AVHNBA3 = 'Avg. Hypopnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
MNHNBA3 = 'Min. Hypopnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
MXHNBA3 = 'Max. Hypopnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
HNROA3 = '# of Hypopnea w/ arousals (NREM, Other, 3% desat)'
RDINOA3 = 'Hypopnea per hour w/ arousals (NREM, Other, 3% desat)'
AVHNOA3 = 'Avg. Hypopnea length w/ arousals (NREM, Other, 3% desat) (seconds)'
MNHNOA3 = 'Min. Hypopnea length w/ arousals (NREM, Other, 3% desat) (seconds)'
MXHNOA3 = 'Max. Hypopnea length w/ arousals (NREM, Other 3% desat) (seconds)'
CARBA3 = '# of Cent. Apnea w/ arousals (REM, Back, 3% desat)'
CARDRBA3 = 'Cent. Apnea per hour w/ arousals (REM, Back, 3% desat)'
AVCARBA3 = 'Avg. Cent. Apnea length w/ arousals (REM, Back, 3% desat) (seconds)'
MNCARBA3 = 'Min. Cent. Apnea length w/ arousals (REM, Back, 3% desat) (seconds)'
MXCARBA3 = 'Max. Cent. Apnea length w/ arousals (REM, Back, 3% desat) (seconds)'
CAROA3 = '# of Cent. Apnea w/ arousals (REM, Other, 3% desat)'
CARDROA3 = 'Cent. Apnea per hour w/ arousals (REM, Other, 3% desat)'
AVCAROA3 = 'Avg. Cent. Apnea length w/ arousals (REM, Other, 3% desat) (seconds)'
MNCAROA3 = 'Min. Cent. Apnea length w/ arousals (REM, Other, 3% desat) (seconds)'
MXCAROA3 = 'Max. Cent. Apnea length w/ arousals (REM, Other, 3% desat) (seconds)'
CANBA3 = '# of Cent. Apnea w/ arousals (NREM, Back, 3% desat)'
CARDNBA3 = 'Cent. Apnea per hour w/ arousals (NREM, Back, 3% desat)'
AVCANBA3 = 'Avg. Cent. Apnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
MNCANBA3 = 'Min. Cent. Apnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
MXCANBA3 = 'Max. Cent. Apnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
CANOA3 = '# of Cent. Apnea w/ arousals (NREM, Other, 3% desat)'
CARDNOA3 = 'Cent. Apnea per hour w/ arousals (NREM, Other, 3% desat)'
AVCANOA3 = 'Avg. Cent. Apnea length w/ arousals (NREM, Other, 3% desat) (seconds)'
MNCANOA3 = 'Min. Cent. Apnea length w/ arousals (NREM, Other, 3% desat) (seconds)'
MXCANOA3 = 'Max. Cent. Apnea length w/ arousals (NREM, Other 3% desat) (seconds)'
OARBA3 = '# of Obs. Apnea w/ arousals (REM, Back, 3% desat)'
OARDRBA3 = 'Obs. Apnea per hour w/ arousals (REM, Back, 3% desat)'
AVOARBA3 = 'Avg. Obs. Apnea length w/ arousals (REM, Back, 3% desat) (seconds)'
MNOARBA3 = 'Min. Obs. Apnea length w/ arousals (REM, Back, 3% desat) (seconds)'
MXOARBA3 = 'Max. Obs. Apnea length w/ arousals (REM, Back, 3% desat) (seconds)'
OAROA3 = '# of Obs. Apnea w/ arousals (REM, Other, 3% desat)'
OARDROA3 = 'Obs. Apnea per hour w/ arousals (REM, Other, 3% desat)'
AVOAROA3 = 'Avg. Obs. Apnea length w/ arousals (REM, Other, 3% desat) (seconds)'
MNOAROA3 = 'Min. Obs. Apnea length w/ arousals (REM, Other, 3% desat) (seconds)'
MXOAROA3 = 'Max. Obs. Apnea length w/ arousals (REM, Other, 3% desat) (seconds)'
OANBA3 = '# of Obs. Apnea w/ arousals (NREM, Back, 3% desat)'
OARDNBA3 = 'Obs. Apnea per hour w/ arousals (NREM, Back, 3% desat)'
AVOANBA3 = 'Avg. Obs. Apnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
MNOANBA3 = 'Min. Obs. Apnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
MXOANBA3 = 'Max. Obs. Apnea length w/ arousals (NREM, Back, 3% desat) (seconds)'
OANOA3 = '# of Obs. Apnea w/ arousals (NREM, Other, 3% desat)'
OARDNOA3 = 'Obs. Apnea per hour w/ arousals (NREM, Other, 3% desat)'
AVOANOA3 = 'Avg. Obs. Apnea length w/ arousals (NREM, Other, 3% desat) (seconds)'
MNOANOA3 = 'Min. Obs. Apnea length w/ arousals (NREM, Other, 3% desat) (seconds)'
MXOANOA3 = 'Max. Obs. Apnea length w/ arousals (NREM, Other 3% desat) (seconds)'
MXDRBA3 = 'Max. Desat w/ arousals (REM, Back, 3% desat)'
MXDROA3 = 'Max. Desat w/ arousals (REM, Other, 3% desat)'
MXDNBA3 = 'Max. Desat w/ arousals (NREM, Back, 3% desat)'
MXDNOA3 = 'Max. Desat w/ arousals (NREM, Other, 3% desat)'
AVDRBA3 = 'Avg. Desat w/ arousals (REM, Back, 3% desat)'
AVDROA3 = 'Avg. Desat w/ arousals (REM, Other, 3% desat)'
AVDNBA3 = 'Avg. Desat w/ arousals (NREM, Back, 3% desat)'
AVDNOA3 = 'Avg. Desat w/ arousals (NREM, Other, 3% desat)'
MNDRBA3 = 'Min. SaO2 w/ arousals (REM, Back, 3% desat) (%)'
MNDROA3 = 'Min. SaO2 w/ arousals (REM, Other, 3% desat) (%)'
MNDNBA3 = 'Min. SaO2 w/ arousals (NREM, Back, 3% desat) (%)'
MNDNOA3 = 'Min. SaO2 w/ arousals (NREM, Other, 3% desat) (%)'
HREMBP4 = '# of Hypopnea (REM, Back, 4% desat)'
RDIRBP4 = 'Hypopnea per hour (REM, Back, 4% desat)'
AVHRBP4 = 'Avg. Hypopnea length (REM, Back, 4% desat) (seconds)'
MNHRBP4 = 'Min. Hypopnea length (REM, Back, 4% desat) (seconds)'
MXHRBP4 = 'Max. Hypopnea length (REM, Back, 4% desat) (seconds)'
HROP4 = '# of Hypopnea (REM, Other, 4% desat)'
RDIROP4 = 'Hypopnea per hour (REM, Other, 4% desat)'
AVHROP4 = 'Avg. Hypopnea length (REM, Other, 4% desat) (seconds)'
MNHROP4 = 'Min. Hypopnea length (REM, Other, 4% desat) (seconds)'
MXHROP4 = 'Max. Hypopnea length (REM, Other, 4% desat) (seconds)'
HNRBP4 = '# of Hypopnea (NREM, Back, 4% desat)'
RDINBP4 = 'Hypopnea per hour (NREM, Back, 4% desat)'
AVHNBP4 = 'Avg. Hypopnea length (NREM, Back, 4% desat) (seconds)'
MNHNBP4 = 'Min. Hypopnea length (NREM, Back, 4% desat) (seconds)'
MXHNBP4 = 'Max. Hypopnea length (NREM, Back, 4% desat) (seconds)'
HNROP4 = '# of Hypopnea (NREM, Other, 4% desat)'
RDINOP4 = 'Hypopnea per hour (NREM, Other, 4% desat)'
AVHNOP4 = 'Avg. Hypopnea length (NREM, Other, 4% desat) (seconds)'
MNHNOP4 = 'Min. Hypopnea length (NREM, Other, 4% desat) (seconds)'
MXHNOP4 = 'Max. Hypopnea length (NREM, Other 4% desat) (seconds)'
CARBP4 = '# of Cent. Apnea (REM, Back, 4% desat)'
CARDRBP4 = 'Cent. Apnea per hour (REM, Back, 4% desat)'
AVCARBP4 = 'Avg. Cent. Apnea length (REM, Back, 4% desat) (seconds)'
MNCARBP4 = 'Min. Cent. Apnea length (REM, Back, 4% desat) (seconds)'
MXCARBP4 = 'Max. Cent. Apnea length (REM, Back, 4% desat) (seconds)'
CAROP4 = '# of Cent. Apnea (REM, Other, 4% desat)'
CARDROP4 = 'Cent. Apnea per hour (REM, Other, 4% desat)'
AVCAROP4 = 'Avg. Cent. Apnea length (REM, Other, 4% desat) (seconds)'
MNCAROP4 = 'Min. Cent. Apnea length (REM, Other, 4% desat) (seconds)'
MXCAROP4 = 'Max. Cent. Apnea length (REM, Other, 4% desat) (seconds)'
CANBP4 = '# of Cent. Apnea (NREM, Back, 4% desat)'
CARDNBP4 = 'Cent. Apnea per hour (NREM, Back, 4% desat)'
AVCANBP4 = 'Avg. Cent. Apnea length (NREM, Back, 4% desat) (seconds)'
MNCANBP4 = 'Min. Cent. Apnea length (NREM, Back, 4% desat) (seconds)'
MXCANBP4 = 'Max. Cent. Apnea length (NREM, Back, 4% desat) (seconds)'
CANOP4 = '# of Cent. Apnea (NREM, Other, 4% desat)'
CARDNOP4 = 'Cent. Apnea per hour (NREM, Other, 4% desat)'
AVCANOP4 = 'Avg. Cent. Apnea length (NREM, Other, 4% desat) (seconds)'
MNCANOP4 = 'Min. Cent. Apnea length (NREM, Other, 4% desat) (seconds)'
MXCANOP4 = 'Max. Cent. Apnea length (NREM, Other 4% desat) (seconds)'
OARBP4 = '# of Obs. Apnea (REM, Back, 4% desat)'
OARDRBP4 = 'Obs. Apnea per hour (REM, Back, 4% desat)'
AVOARBP4 = 'Avg. Obs. Apnea length (REM, Back, 4% desat) (seconds)'
MNOARBP4 = 'Min. Obs. Apnea length (REM, Back, 4% desat) (seconds)'
MXOARBP4 = 'Max. Obs. Apnea length (REM, Back, 4% desat) (seconds)'
OAROP4 = '# of Obs. Apnea (REM, Other, 4% desat)'
OARDROP4 = 'Obs. Apnea per hour (REM, Other, 4% desat)'
AVOAROP4 = 'Avg. Obs. Apnea length (REM, Other, 4% desat) (seconds)'
MNOAROP4 = 'Min. Obs. Apnea length (REM, Other, 4% desat) (seconds)'
MXOAROP4 = 'Max. Obs. Apnea length (REM, Other, 4% desat) (seconds)'
OANBP4 = '# of Obs. Apnea (NREM, Back, 4% desat)'
OARDNBP4 = 'Obs. Apnea per hour (NREM, Back, 4% desat)'
AVOANBP4 = 'Avg. Obs. Apnea length (NREM, Back, 4% desat) (seconds)'
MNOANBP4 = 'Min. Obs. Apnea length (NREM, Back, 4% desat) (seconds)'
MXOANBP4 = 'Max. Obs. Apnea length (NREM, Back, 4% desat) (seconds)'
OANOP4 = '# of Obs. Apnea (NREM, Other, 4% desat)'
OARDNOP4 = 'Obs. Apnea per hour (NREM, Other, 4% desat)'
AVOANOP4 = 'Avg. Obs. Apnea length (NREM, Other, 4% desat) (seconds)'
MNOANOP4 = 'Min. Obs. Apnea length (NREM, Other, 4% desat) (seconds)'
MXOANOP4 = 'Max. Obs. Apnea length (NREM, Other 4% desat) (seconds)'
MXDRBP4 = 'Max. Desat (REM, Back, 4% desat)'
MXDROP4 = 'Max. Desat (REM, Other, 4% desat)'
MXDNBP4 = 'Max. Desat (NREM, Back, 4% desat)'
MXDNOP4 = 'Max. Desat (NREM, Other, 4% desat)'
AVDRBP4 = 'Avg. Desat (REM, Back, 4% desat)'
AVDROP4 = 'Avg. Desat (REM, Other, 4% desat)'
AVDNBP4 = 'Avg. Desat (NREM, Back, 4% desat)'
AVDNOP4 = 'Avg. Desat (NREM, Other, 4% desat)'
MNDRBP4 = 'Min. SaO2 (REM, Back, 4% desat) (%)'
MNDROP4 = 'Min. SaO2 (REM, Other, 4% desat) (%)'
MNDNBP4 = 'Min. SaO2 (NREM, Back, 4% desat) (%)'
MNDNOP4 = 'Min. SaO2 (NREM, Other, 4% desat) (%)'
HREMBA4 = '# of Hypopnea w/ arousals (REM, Back, 4% desat)'
RDIRBA4 = 'Hypopnea per hour w/ arousals (REM, Back, 4% desat)'
AVHRBA4 = 'Avg. Hypopnea length w/ arousals (REM, Back, 4% desat) (seconds)'
MNHRBA4 = 'Min. Hypopnea length w/ arousals (REM, Back, 4% desat) (seconds)'
MXHRBA4 = 'Max. Hypopnea length w/ arousals (REM, Back, 4% desat) (seconds)'
HROA4 = '# of Hypopnea w/ arousals (REM, Other, 4% desat)'
RDIROA4 = 'Hypopnea per hour w/ arousals (REM, Other, 4% desat)'
AVHROA4 = 'Avg. Hypopnea length w/ arousals (REM, Other, 4% desat) (seconds)'
MNHROA4 = 'Min. Hypopnea length w/ arousals (REM, Other, 4% desat) (seconds)'
MXHROA4 = 'Max. Hypopnea length w/ arousals (REM, Other, 4% desat) (seconds)'
HNRBA4 = '# of Hypopnea w/ arousals (NREM, Back, 4% desat)'
RDINBA4 = 'Hypopnea per hour w/ arousals (NREM, Back, 4% desat)'
AVHNBA4 = 'Avg. Hypopnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
MNHNBA4 = 'Min. Hypopnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
MXHNBA4 = 'Max. Hypopnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
HNROA4 = '# of Hypopnea w/ arousals (NREM, Other, 4% desat)'
RDINOA4 = 'Hypopnea per hour w/ arousals (NREM, Other, 4% desat)'
AVHNOA4 = 'Avg. Hypopnea length w/ arousals (NREM, Other, 4% desat) (seconds)'
MNHNOA4 = 'Min. Hypopnea length w/ arousals (NREM, Other, 4% desat) (seconds)'
MXHNOA4 = 'Max. Hypopnea length w/ arousals (NREM, Other 4% desat) (seconds)'
CARBA4 = '# of Cent. Apnea w/ arousals (REM, Back, 4% desat)'
CARDRBA4 = 'Cent. Apnea per hour w/ arousals (REM, Back, 4% desat)'
AVCARBA4 = 'Avg. Cent. Apnea length w/ arousals (REM, Back, 4% desat) (seconds)'
MNCARBA4 = 'Min. Cent. Apnea length w/ arousals (REM, Back, 4% desat) (seconds)'
MXCARBA4 = 'Max. Cent. Apnea length w/ arousals (REM, Back, 4% desat) (seconds)'
CAROA4 = '# of Cent. Apnea w/ arousals (REM, Other, 4% desat)'
CARDROA4 = 'Cent. Apnea per hour w/ arousals (REM, Other, 4% desat)'
AVCAROA4 = 'Avg. Cent. Apnea length w/ arousals (REM, Other, 4% desat) (seconds)'
MNCAROA4 = 'Min. Cent. Apnea length w/ arousals (REM, Other, 4% desat) (seconds)'
MXCAROA4 = 'Max. Cent. Apnea length w/ arousals (REM, Other, 4% desat) (seconds)'
CANBA4 = '# of Cent. Apnea w/ arousals (NREM, Back, 4% desat)'
CARDNBA4 = 'Cent. Apnea per hour w/ arousals (NREM, Back, 4% desat)'
AVCANBA4 = 'Avg. Cent. Apnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
MNCANBA4 = 'Min. Cent. Apnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
MXCANBA4 = 'Max. Cent. Apnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
CANOA4 = '# of Cent. Apnea w/ arousals (NREM, Other, 4% desat)'
CARDNOA4 = 'Cent. Apnea per hour w/ arousals (NREM, Other, 4% desat)'
AVCANOA4 = 'Avg. Cent. Apnea length w/ arousals (NREM, Other, 4% desat) (seconds)'
MNCANOA4 = 'Min. Cent. Apnea length w/ arousals (NREM, Other, 4% desat) (seconds)'
MXCANOA4 = 'Max. Cent. Apnea length w/ arousals (NREM, Other 4% desat) (seconds)'
OARBA4 = '# of Obs. Apnea w/ arousals (REM, Back, 4% desat)'
OARDRBA4 = 'Obs. Apnea per hour w/ arousals (REM, Back, 4% desat)'
AVOARBA4 = 'Avg. Obs. Apnea length w/ arousals (REM, Back, 4% desat) (seconds)'
MNOARBA4 = 'Min. Obs. Apnea length w/ arousals (REM, Back, 4% desat) (seconds)'
MXOARBA4 = 'Max. Obs. Apnea length w/ arousals (REM, Back, 4% desat) (seconds)'
OAROA4 = '# of Obs. Apnea w/ arousals (REM, Other, 4% desat)'
OARDROA4 = 'Obs. Apnea per hour w/ arousals (REM, Other, 4% desat)'
AVOAROA4 = 'Avg. Obs. Apnea length w/ arousals (REM, Other, 4% desat) (seconds)'
MNOAROA4 = 'Min. Obs. Apnea length w/ arousals (REM, Other, 4% desat) (seconds)'
MXOAROA4 = 'Max. Obs. Apnea length w/ arousals (REM, Other, 4% desat) (seconds)'
OANBA4 = '# of Obs. Apnea w/ arousals (NREM, Back, 4% desat)'
OARDNBA4 = 'Obs. Apnea per hour w/ arousals (NREM, Back, 4% desat)'
AVOANBA4 = 'Avg. Obs. Apnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
MNOANBA4 = 'Min. Obs. Apnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
MXOANBA4 = 'Max. Obs. Apnea length w/ arousals (NREM, Back, 4% desat) (seconds)'
OANOA4 = '# of Obs. Apnea w/ arousals (NREM, Other, 4% desat)'
OARDNOA4 = 'Obs. Apnea per hour w/ arousals (NREM, Other, 4% desat)'
AVOANOA4 = 'Avg. Obs. Apnea length w/ arousals (NREM, Other, 4% desat) (seconds)'
MNOANOA4 = 'Min. Obs. Apnea length w/ arousals (NREM, Other, 4% desat) (seconds)'
MXOANOA4 = 'Max. Obs. Apnea length w/ arousals (NREM, Other 4% desat) (seconds)'
MXDRBA4 = 'Max. Desat w/ arousals (REM, Back, 4% desat)'
MXDROA4 = 'Max. Desat w/ arousals (REM, Other, 4% desat)'
MXDNBA4 = 'Max. Desat w/ arousals (NREM, Back, 4% desat)'
MXDNOA4 = 'Max. Desat w/ arousals (NREM, Other, 4% desat)'
AVDRBA4 = 'Avg. Desat w/ arousals (REM, Back, 4% desat)'
AVDROA4 = 'Avg. Desat w/ arousals (REM, Other, 4% desat)'
AVDNBA4 = 'Avg. Desat w/ arousals (NREM, Back, 4% desat)'
AVDNOA4 = 'Avg. Desat w/ arousals (NREM, Other, 4% desat)'
MNDRBA4 = 'Min. SaO2 w/ arousals (REM, Back, 4% desat) (%)'
MNDROA4 = 'Min. SaO2 w/ arousals (REM, Other, 4% desat) (%)'
MNDNBA4 = 'Min. SaO2 w/ arousals (NREM, Back, 4% desat) (%)'
MNDNOA4 = 'Min. SaO2 w/ arousals (NREM, Other, 4% desat) (%)'
HREMBP5 = '# of Hypopnea (REM, Back, 5% desat)'
RDIRBP5 = 'Hypopnea per hour (REM, Back, 5% desat)'
AVHRBP5 = 'Avg. Hypopnea length (REM, Back, 5% desat) (seconds)'
MNHRBP5 = 'Min. Hypopnea length (REM, Back, 5% desat) (seconds)'
MXHRBP5 = 'Max. Hypopnea length (REM, Back, 5% desat) (seconds)'
HROP5 = '# of Hypopnea (REM, Other, 5% desat)'
RDIROP5 = 'Hypopnea per hour (REM, Other, 5% desat)'
AVHROP5 = 'Avg. Hypopnea length (REM, Other, 5% desat) (seconds)'
MNHROP5 = 'Min. Hypopnea length (REM, Other, 5% desat) (seconds)'
MXHROP5 = 'Max. Hypopnea length (REM, Other, 5% desat) (seconds)'
HNRBP5 = '# of Hypopnea (NREM, Back, 5% desat)'
RDINBP5 = 'Hypopnea per hour (NREM, Back, 5% desat)'
AVHNBP5 = 'Avg. Hypopnea length (NREM, Back, 5% desat) (seconds)'
MNHNBP5 = 'Min. Hypopnea length (NREM, Back, 5% desat) (seconds)'
MXHNBP5 = 'Max. Hypopnea length (NREM, Back, 5% desat) (seconds)'
HNROP5 = '# of Hypopnea (NREM, Other, 5% desat)'
RDINOP5 = 'Hypopnea per hour (NREM, Other, 5% desat)'
AVHNOP5 = 'Avg. Hypopnea length (NREM, Other, 5% desat) (seconds)'
MNHNOP5 = 'Min. Hypopnea length (NREM, Other, 5% desat) (seconds)'
MXHNOP5 = 'Max. Hypopnea length (NREM, Other 5% desat) (seconds)'
CARBP5 = '# of Cent. Apnea (REM, Back, 5% desat)'
CARDRBP5 = 'Cent. Apnea per hour (REM, Back, 5% desat)'
AVCARBP5 = 'Avg. Cent. Apnea length (REM, Back, 5% desat) (seconds)'
MNCARBP5 = 'Min. Cent. Apnea length (REM, Back, 5% desat) (seconds)'
MXCARBP5 = 'Max. Cent. Apnea length (REM, Back, 5% desat) (seconds)'
CAROP5 = '# of Cent. Apnea (REM, Other, 5% desat)'
CARDROP5 = 'Cent. Apnea per hour (REM, Other, 5% desat)'
AVCAROP5 = 'Avg. Cent. Apnea length (REM, Other, 5% desat) (seconds)'
MNCAROP5 = 'Min. Cent. Apnea length (REM, Other, 5% desat) (seconds)'
MXCAROP5 = 'Max. Cent. Apnea length (REM, Other, 5% desat) (seconds)'
CANBP5 = '# of Cent. Apnea (NREM, Back, 5% desat)'
CARDNBP5 = 'Cent. Apnea per hour (NREM, Back, 5% desat)'
AVCANBP5 = 'Avg. Cent. Apnea length (NREM, Back, 5% desat) (seconds)'
MNCANBP5 = 'Min. Cent. Apnea length (NREM, Back, 5% desat) (seconds)'
MXCANBP5 = 'Max. Cent. Apnea length (NREM, Back, 5% desat) (seconds)'
CANOP5 = '# of Cent. Apnea (NREM, Other, 5% desat)'
CARDNOP5 = 'Cent. Apnea per hour (NREM, Other, 5% desat)'
AVCANOP5 = 'Avg. Cent. Apnea length (NREM, Other, 5% desat) (seconds)'
MNCANOP5 = 'Min. Cent. Apnea length (NREM, Other, 5% desat) (seconds)'
MXCANOP5 = 'Max. Cent. Apnea length (NREM, Other 5% desat) (seconds)'
OARBP5 = '# of Obs. Apnea (REM, Back, 5% desat)'
OARDRBP5 = 'Obs. Apnea per hour (REM, Back, 5% desat)'
AVOARBP5 = 'Avg. Obs. Apnea length (REM, Back, 5% desat) (seconds)'
MNOARBP5 = 'Min. Obs. Apnea length (REM, Back, 5% desat) (seconds)'
MXOARBP5 = 'Max. Obs. Apnea length (REM, Back, 5% desat) (seconds)'
OAROP5 = '# of Obs. Apnea (REM, Other, 5% desat)'
OARDROP5 = 'Obs. Apnea per hour (REM, Other, 5% desat)'
AVOAROP5 = 'Avg. Obs. Apnea length (REM, Other, 5% desat) (seconds)'
MNOAROP5 = 'Min. Obs. Apnea length (REM, Other, 5% desat) (seconds)'
MXOAROP5 = 'Max. Obs. Apnea length (REM, Other, 5% desat) (seconds)'
OANBP5 = '# of Obs. Apnea (NREM, Back, 5% desat)'
OARDNBP5 = 'Obs. Apnea per hour (NREM, Back, 5% desat)'
AVOANBP5 = 'Avg. Obs. Apnea length (NREM, Back, 5% desat) (seconds)'
MNOANBP5 = 'Min. Obs. Apnea length (NREM, Back, 5% desat) (seconds)'
MXOANBP5 = 'Max. Obs. Apnea length (NREM, Back, 5% desat) (seconds)'
OANOP5 = '# of Obs. Apnea (NREM, Other, 5% desat)'
OARDNOP5 = 'Obs. Apnea per hour (NREM, Other, 5% desat)'
AVOANOP5 = 'Avg. Obs. Apnea length (NREM, Other, 5% desat) (seconds)'
MNOANOP5 = 'Min. Obs. Apnea length (NREM, Other, 5% desat) (seconds)'
MXOANOP5 = 'Max. Obs. Apnea length (NREM, Other 5% desat) (seconds)'
MXDRBP5 = 'Max. Desat (REM, Back, 5% desat)'
MXDROP5 = 'Max. Desat (REM, Other, 5% desat)'
MXDNBP5 = 'Max. Desat (NREM, Back, 5% desat)'
MXDNOP5 = 'Max. Desat (NREM, Other, 5% desat)'
AVDRBP5 = 'Avg. Desat (REM, Back, 5% desat)'
AVDROP5 = 'Avg. Desat (REM, Other, 5% desat)'
AVDNBP5 = 'Avg. Desat (NREM, Back, 5% desat)'
AVDNOP5 = 'Avg. Desat (NREM, Other, 5% desat)'
MNDRBP5 = 'Min. SaO2 (REM, Back, 5% desat) (%)'
MNDROP5 = 'Min. SaO2 (REM, Other, 5% desat) (%)'
MNDNBP5 = 'Min. SaO2 (NREM, Back, 5% desat) (%)'
MNDNOP5 = 'Min. SaO2 (NREM, Other, 5% desat) (%)'
HREMBA5 = '# of Hypopnea w/ arousals (REM, Back, 5% desat)'
RDIRBA5 = 'Hypopnea per hour w/ arousals (REM, Back, 5% desat)'
AVHRBA5 = 'Avg. Hypopnea length w/ arousals (REM, Back, 5% desat) (seconds)'
MNHRBA5 = 'Min. Hypopnea length w/ arousals (REM, Back, 5% desat) (seconds)'
MXHRBA5 = 'Max. Hypopnea length w/ arousals (REM, Back, 5% desat) (seconds)'
HROA5 = '# of Hypopnea w/ arousals (REM, Other, 5% desat)'
RDIROA5 = 'Hypopnea per hour w/ arousals (REM, Other, 5% desat)'
AVHROA5 = 'Avg. Hypopnea length w/ arousals (REM, Other, 5% desat) (seconds)'
MNHROA5 = 'Min. Hypopnea length w/ arousals (REM, Other, 5% desat) (seconds)'
MXHROA5 = 'Max. Hypopnea length w/ arousals (REM, Other, 5% desat) (seconds)'
HNRBA5 = '# of Hypopnea w/ arousals (NREM, Back, 5% desat)'
RDINBA5 = 'Hypopnea per hour w/ arousals (NREM, Back, 5% desat)'
AVHNBA5 = 'Avg. Hypopnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
MNHNBA5 = 'Min. Hypopnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
MXHNBA5 = 'Max. Hypopnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
HNROA5 = '# of Hypopnea w/ arousals (NREM, Other, 5% desat)'
RDINOA5 = 'Hypopnea per hour w/ arousals (NREM, Other, 5% desat)'
AVHNOA5 = 'Avg. Hypopnea length w/ arousals (NREM, Other, 5% desat) (seconds)'
MNHNOA5 = 'Min. Hypopnea length w/ arousals (NREM, Other, 5% desat) (seconds)'
MXHNOA5 = 'Max. Hypopnea length w/ arousals (NREM, Other 5% desat) (seconds)'
CARBA5 = '# of Cent. Apnea w/ arousals (REM, Back, 5% desat)'
CARDRBA5 = 'Cent. Apnea per hour w/ arousals (REM, Back, 5% desat)'
AVCARBA5 = 'Avg. Cent. Apnea length w/ arousals (REM, Back, 5% desat) (seconds)'
MNCARBA5 = 'Min. Cent. Apnea length w/ arousals (REM, Back, 5% desat) (seconds)'
MXCARBA5 = 'Max. Cent. Apnea length w/ arousals (REM, Back, 5% desat) (seconds)'
CAROA5 = '# of Cent. Apnea w/ arousals (REM, Other, 5% desat)'
CARDROA5 = 'Cent. Apnea per hour w/ arousals (REM, Other, 5% desat)'
AVCAROA5 = 'Avg. Cent. Apnea length w/ arousals (REM, Other, 5% desat) (seconds)'
MNCAROA5 = 'Min. Cent. Apnea length w/ arousals (REM, Other, 5% desat) (seconds)'
MXCAROA5 = 'Max. Cent. Apnea length w/ arousals (REM, Other, 5% desat) (seconds)'
CANBA5 = '# of Cent. Apnea w/ arousals (NREM, Back, 5% desat)'
CARDNBA5 = 'Cent. Apnea per hour w/ arousals (NREM, Back, 5% desat)'
AVCANBA5 = 'Avg. Cent. Apnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
MNCANBA5 = 'Min. Cent. Apnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
MXCANBA5 = 'Max. Cent. Apnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
CANOA5 = '# of Cent. Apnea w/ arousals (NREM, Other, 5% desat)'
CARDNOA5 = 'Cent. Apnea per hour w/ arousals (NREM, Other, 5% desat)'
AVCANOA5 = 'Avg. Cent. Apnea length w/ arousals (NREM, Other, 5% desat) (seconds)'
MNCANOA5 = 'Min. Cent. Apnea length w/ arousals (NREM, Other, 5% desat) (seconds)'
MXCANOA5 = 'Max. Cent. Apnea length w/ arousals (NREM, Other 5% desat) (seconds)'
OARBA5 = '# of Obs. Apnea w/ arousals (REM, Back, 5% desat)'
OARDRBA5 = 'Obs. Apnea per hour w/ arousals (REM, Back, 5% desat)'
AVOARBA5 = 'Avg. Obs. Apnea length w/ arousals (REM, Back, 5% desat) (seconds)'
MNOARBA5 = 'Min. Obs. Apnea length w/ arousals (REM, Back, 5% desat) (seconds)'
MXOARBA5 = 'Max. Obs. Apnea length w/ arousals (REM, Back, 5% desat) (seconds)'
OAROA5 = '# of Obs. Apnea w/ arousals (REM, Other, 5% desat)'
OARDROA5 = 'Obs. Apnea per hour w/ arousals (REM, Other, 5% desat)'
AVOAROA5 = 'Avg. Obs. Apnea length w/ arousals (REM, Other, 5% desat) (seconds)'
MNOAROA5 = 'Min. Obs. Apnea length w/ arousals (REM, Other, 5% desat) (seconds)'
MXOAROA5 = 'Max. Obs. Apnea length w/ arousals (REM, Other, 5% desat) (seconds)'
OANBA5 = '# of Obs. Apnea w/ arousals (NREM, Back, 5% desat)'
OARDNBA5 = 'Obs. Apnea per hour w/ arousals (NREM, Back, 5% desat)'
AVOANBA5 = 'Avg. Obs. Apnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
MNOANBA5 = 'Min. Obs. Apnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
MXOANBA5 = 'Max. Obs. Apnea length w/ arousals (NREM, Back, 5% desat) (seconds)'
OANOA5 = '# of Obs. Apnea w/ arousals (NREM, Other, 5% desat)'
OARDNOA5 = 'Obs. Apnea per hour w/ arousals (NREM, Other, 5% desat)'
AVOANOA5 = 'Avg. Obs. Apnea length w/ arousals (NREM, Other, 5% desat) (seconds)'
MNOANOA5 = 'Min. Obs. Apnea length w/ arousals (NREM, Other, 5% desat) (seconds)'
MXOANOA5 = 'Max. Obs. Apnea length w/ arousals (NREM, Other 5% desat) (seconds)'
MXDRBA5 = 'Max. Desat w/ arousals (REM, Back, 5% desat)'
MXDROA5 = 'Max. Desat w/ arousals (REM, Other, 5% desat)'
MXDNBA5 = 'Max. Desat w/ arousals (NREM, Back, 5% desat)'
MXDNOA5 = 'Max. Desat w/ arousals (NREM, Other, 5% desat)'
AVDRBA5 = 'Avg. Desat w/ arousals (REM, Back, 5% desat)'
AVDROA5 = 'Avg. Desat w/ arousals (REM, Other, 5% desat)'
AVDNBA5 = 'Avg. Desat w/ arousals (NREM, Back, 5% desat)'
AVDNOA5 = 'Avg. Desat w/ arousals (NREM, Other, 5% desat)'
MNDRBA5 = 'Min. SaO2 w/ arousals (REM, Back, 5% desat) (%)'
MNDROA5 = 'Min. SaO2 w/ arousals (REM, Other, 5% desat) (%)'
MNDNBA5 = 'Min. SaO2 w/ arousals (NREM, Back, 5% desat) (%)'
MNDNOA5 = 'Min. SaO2 w/ arousals (NREM, Other, 5% desat) (%)'
PCTSTAPN = '% Sleep time in Apnea'
PCTSTHYP = '% Sleep time in Hypopnea'
PCSTAHAR = '% Sleep time in Apnea+Hypopnea with arousal'
PCSTAH3D = '% Sleep time in Apnea+Hypopnea with >3% desat'
PCSTAHDA = '% Sleep time in Apnea+Hypopnea with > 3% desat or arousal'
SAVBRBH = 'Avg. Heart Rate (REM, Back, all desats) (bpm)'
SMNBRBH = 'Min. Heart Rate (REM, Back, all desats) (bpm)'
SMXBRBH = 'Max. Heart Rate (REM, Back, all desats) (bpm)'
SAVBROH = 'Avg. Heart Rate (REM, Other, all desats) (bpm)'
SMNBROH = 'Min. Heart Rate (REM, Other, all desats) (bpm)'
SMXBROH = 'Max. Heart Rate (REM, Other, all desats) (bpm)'
SAVBNBH = 'Avg. Heart Rate (NREM, Back, all desats) (bpm)'
SMNBNBH = 'Min. Heart Rate (NREM, Back, all desats) (bpm)'
SMXBNBH = 'Max. Heart Rate (NREM, Back, all desats) (bpm)'
SAVBNOH = 'Avg. Heart Rate (NREM, Other, all desats) (bpm)'
SMNBNOH = 'Min. Heart Rate (NREM, Other, all desats) (bpm)'
SMXBNOH = 'Max. Heart Rate (NREM, Other, all desats) (bpm)'
AAVBRBH = 'Avg. Heart Rate with arousal (REM, Back, all desats) (bpm)'
AMNBRBH = 'Min. Heart Rate with arousal (REM, Back, all desats) (bpm)'
AMXBRBH = 'Max. Heart Rate with arousal (REM, Back, all desats) (bpm)'
AAVBROH = 'Avg. Heart Rate with arousal (REM, Other, all desats) (bpm)'
AMNBROH = 'Min. Heart Rate with arousal (REM, Other, all desats) (bpm)'
AMXBROH = 'Max. Heart Rate with arousal (REM, Other, all desats) (bpm)'
AAVBNBH = 'Avg. Heart Rate with arousal (NREM, Back, all desats) (bpm)'
AMNBNBH = 'Min. Heart Rate with arousal (NREM, Back, all desats) (bpm)'
AMXBNBH = 'Max. Heart Rate with arousal (NREM, Back, all desats) (bpm)'
AAVBNOH = 'Avg. Heart Rate with arousal (NREM, Other, all desats) (bpm)'
AMNBNOH = 'Min. Heart Rate with arousal (NREM, Other, all desats) (bpm)'
AMXBNOH = 'Max. Heart Rate with arousal (NREM, Other, all desats) (bpm)'
HAVBRBH = 'Avg. Heart Rate (REM, Back, 3% desat) (bpm)'
HMNBRBH = 'Min. Heart Rate (REM, Back, 3% desat) (bpm)'
HMXBRBH = 'Max. Heart Rate (REM, Back, 3% desat) (bpm)'
HAVBROH = 'Avg. Heart Rate (REM, Other, 3% desat) (bpm)'
HMNBROH = 'Min. Heart Rate (REM, Other, 3% desat) (bpm)'
HMXBROH = 'Max. Heart Rate (REM, Other, 3% desat) (bpm)'
HAVBNBH = 'Avg. Heart Rate (NREM, Back, 3% desat) (bpm)'
HMNBNBH = 'Min. Heart Rate (NREM, Back, 3% desat) (bpm)'
HMXBNBH = 'Max. Heart Rate (NREM, Back, 3% desat) (bpm)'
HAVBNOH = 'Avg. Heart Rate (NREM, Other, 3% desat) (bpm)'
HMNBNOH = 'Min. Heart Rate (NREM, Other, 3% desat) (bpm)'
HMXBNOH = 'Max. Heart Rate (NREM, Other, 3% desat) (bpm)'
DAVBRBH = 'Avg. Heart Rate with arousal (REM, Back, 3% desat) (bpm)'
DMNBRBH = 'Min. Heart Rate with arousal (REM, Back, 3% desat) (bpm)'
DMXBRBH = 'Max. Heart Rate with arousal (REM, Back, 3% desat) (bpm)'
DAVBROH = 'Avg. Heart Rate with arousal (REM, Other, 3% desat) (bpm)'
DMNBROH = 'Min. Heart Rate with arousal (REM, Other, 3% desat) (bpm)'
DMXBROH = 'Max. Heart Rate with arousal (REM, Other, 3% desat) (bpm)'
DAVBNBH = 'Avg. Heart Rate with arousal (NREM, Back, 3% desat) (bpm)'
DMNBNBH = 'Min. Heart Rate with arousal (NREM, Back, 3% desat) (bpm)'
DMXBNBH = 'Max. Heart Rate with arousal (NREM, Back, 3% desat) (bpm)'
DAVBNOH = 'Avg. Heart Rate with arousal (NREM, Other, 3% desat) (bpm)'
DMNBNOH = 'Min. Heart Rate with arousal (NREM, Other, 3% desat) (bpm)'
DMXBNOH = 'Max. Heart Rate with arousal (NREM, Other, 3% desat) (bpm)'
NDES2PH = '# of desat with >= 2% desat'
NDES3PH = '# of desat with >= 3% desat'
NDES4PH = '# of desat with >= 4% desat'
NDES5PH = '# of desat with >= 5% desat'
PCTSA95H = '% sleep time SaO2 is < 95%'
PCTSA90H = '% sleep time SaO2 is < 90%'
PCTSA85H = '% sleep time SaO2 is < 85%'
PCTSA80H = '% sleep time SaO2 is < 80%'
PCTSA75H = '% sleep time SaO2 is < 75%'
PCTSA70H = '% sleep time SaO2 is < 70%'
AVSAO2RH = 'Avg. SaO2 % during REM sleep'
AVSAO2NH = 'Avg. SaO2 % during NREM sleep'
MNSAO2RH = 'Min. SaO2 % during REM sleep'
MNSAO2NH = 'Min. SaO2 % during NREM sleep'
MXSAO2RH = 'Max. SaO2 % during REM sleep'
MXSAO2NH = 'Max. SaO2 % during NREM sleep'
REMEPBP = 'Sleep Time (REM, Back) (minutes)'
REMEPOP = 'Sleep Time (REM, Other) (minutes)'
NREMEPBP = 'Sleep Time (NREM, Back) (minutes)'
NREMEPOP = 'Sleep Time (NREM, Other) (minutes)'
ARTIFACT = 'Total Artifact Time (Unscorable) (minutes)'
LONGAP = 'Longest Apnea (seconds)'
LONGHYP = 'Longest Hypopnea (seconds)'
CAVGDUR = 'Avg. Cent. Apnea Length (seconds)'
OAVGDUR = 'Avg. Obs. Apnea Length (seconds)'
APAVGDUR = 'Avg. Apnea Length (seconds)'
HAVGDUR = 'Avg. Hypopnea Length (seconds)'
CTDUR = 'Total Cent. Apnea Length (minutes)'
OTDUR = 'Total Obs. Apnea Length (minutes)'
APTDUR = 'Total Mixed Apnea Length (minutes)'
HTDUR = 'Total Hypopnea Length (minutes)'
HRTDUR = 'Total Apnea and Hypopnea Length (REM) (minutes)'
CRTDURBP = 'Total Cent. Apnea Length (REM, Back) (minutes)'
AHRTDURBP = 'Total Apnea and Hypopnea Length (REM, Back) (minutes)'
CRTDUROP = 'Total Cent. Apnea Length (REM, Other) (minutes)'
ORTDUROP = 'Total Obs. Apnea Length (REM, Other) (minutes)'
APRTDUROP = 'Total Apnea Length (REM, Other) (minutes)'
HRTDUROP = 'Total Hypopnea Length (REM, Other) (minutes)'
AHTDUROP = 'Total Apnea and Hypopnea Length (REM, Other) (minutes)'
CNTDUR = 'Total Cent. Apnea Length (NREM) (minutes)'
ONTDUR = 'Total Obs. Apnea Length (NREM) (minutes)'
APNTDUR = 'Total Apnea Length (NREM) (minutes)'
HNTDUR = 'Total Hypopnea Length (NREM) (minutes)'
AHNTDUR = 'Total Apnea and Hypopnea Length (NREM) (minutes)'
CNTDURBP = 'Total Cent. Apnea Length (NREM, Back) (minutes)'
ONTDURBP = 'Total Obs. Apnea Length (NREM, Back) (minutes)'
APNTDURBP = 'Total Apnea Length (NREM, Back) (minutes)'
HNTDURBP = 'Total Hypopnea Length (NREM, Back) (minutes)'
AHNTDURBP = 'Total Apnea and Hypopnea Length (NREM, Back) (minutes)'
CNTDUROP = 'Total Cent. Apnea Length (NREM, Other) (minutes)'
ONTDUROP = 'Total Obs. Apnea Length (NREM, Other) (minutes)'
HNTDUROP = 'Total Hypopnea Length (NREM, Other) (minutes)'
AHNTDUROP = 'Total Apnea and Hypopnea Length (NREM, Other) (minutes)'
AVGSAOMINRPT = 'Avg. SaO2% minimum (Report time) (%)'
AVGSAOMINSLP = 'Avg. SaO2% minimum (Sleep time) (%)'
LOWSAOSLP = 'Min. SaO2 % (Sleep time) (%)'
AVGSAOMINR = 'Avg. SaO2 % (REM) (%)'
LOWSAOR = 'Min. SaO2 % (REM) (%)'
AVGDSSLP = 'Avg. Desaturation (Report Time)'
AVGDSEVENT = 'Avg. Desaturation (assoc. w/ manually scored resp. events)'
PDB5SLP = '% Snore time in sleep (dB level 5)'
PRDB5SLP = '% Snore time in REM sleep (dB level 5)'
NORDB2 = '# of Snore in REM (dB level 2)'
NORDB3 = '# of Snore in REM (dB level 3)'
NODB4SLP = '# of Snore during sleep (dB level 4)'
NORDB4 = '# of Snore in REM (dB level 4)'
NODB5SLP = '# of Snore during sleep (dB level 5)'
NORDB5 = '# of Snore in REM (dB level 5)'
NORDBALL = '# of Snore in REM (dB level 1 - 5)'
MAXDBSLP = 'Max. Snore level during sleep (dB)'
AVGDBSLP = 'Min. Snore level during sleep (dB)'
MXHRAHSLP = 'Max. Heart Rate assoc. w/ Apnea and Hypopnea (Sleep time onset)'
MNHRAHSLP = 'Min. Heart Rate assoc. w/ Apnea and Hypopnea (Sleep time onset)'
AVGHRAHSLP = 'Avg. Heart Rate assoc. w/ Apnea and Hypopnea (Sleep time onset)'
AVGPLM = '# of PLM per hour of sleep'
AVGNPLM = '# of PLM per hour of NREM sleep'
AVGRPLM = '# of PLM per hour of REM sleep'
NOPLM = '# of PLM during sleep'
AVGPLMWK = '# of PLM per hour of awake'
NOLLMSLP = '# of left limb movements per hour of sleep'
NORLMSLP = '# of right limb movements per hour of sleep'
NOBRSLP = '# of Bradycardia (Sleep time)'
NOBRAP = '# of Bradycardia related to Apnea (Sleep time onset)'
NOBRC = '# of Bradycardia related to Cent. Apnea (Sleep time onset)'
NOBRO = '# of Bradycardia related to Obs. Apnea (Sleep time onset)'
NOBRH = '# of Bradycardia related to Hypopnea (Sleep time onset)'
NOTCA = '# of Tachycardia (Sleep time)'
NOTCC = '# of Tachycardia  related to Cent. Apnea (Sleep time)'
NOTCO = '# of Tachycardia  related to Obs. Apnea (Sleep time)'
NOTCH = '# of Tachycardia  related to Hypopnea  (Sleep time)'
dsrem2 = '# of desats per hour (REM, >= 2%)'
dsrem3 = '# of desats per hour (REM, >= 3%)'
dsrem4 = '# of desats per hour (REM, >= 4%)'
dsrem5 = '# of desats per hour (REM, >= 5%)'
dsnr2 = '# of desats per hour (NREM, >= 2%)'
dsnr3 = '# of desats per hour (NREM, >= 3%)'
dsnr4 = '# of desats per hour (NREM, >= 4%)'
dsnr5 = '# of desats per hour (NREM, >= 5%)'
dssao90 = '# of desats with SaO2 drops below 90% in sleep'
avgsaominnr = 'Avg. SaO2% minimum (NREM) (%)'
lowsaonr = 'Min. SaO2% (NREM) (%)'
avgdsresp = 'Avg. desat assoc. w/ resp. events in sleep'
sao92slp = 'Total time SaO2 > 92 in sleep (minutes)'
sao92awk = 'Total time SaO2 > 92 in awake (minutes)'
sao90awk = 'Total time SaO2 < 90 in awake (minutes)'
saoslp = 'Avg. SaO2% (Sleep)'
saorem = 'Avg. SaO2% (REM)'
saonrem = 'Avg. SaO2% (NREM)'
saondoaslp = 'Avg. SaO2% Nadir assoc. w/ Obs. Apnea (Sleep)'
saondcaslp = 'Avg. SaO2% Nadir assoc. w/ Cent. Apnea (Sleep)'
saondrem = 'Avg. SaO2% Nadir  (REM)'
saondnrem = 'Avg. SaO2% Nadir (NREM)'
minsaondoaslp = 'Min. SaO2% Nadir assoc. w/ Obs. Apnea (Sleep)'
minsaondcaslp = 'Min. SaO2% Nadir assoc. w/ Cent. Apnea (Sleep)'
minsaondrem = 'Min. SaO2% Nadir  (REM)'
minsaondnrem = 'Min. SaO2% Nadir (NREM)'
lmslp = '# Limb Movements (Sleep)'
lmnrem = '# Limb Movements (NREM)'
Lmstg1 = '# Limb Movements (Stage 1 Sleep)'
Lmstg2 = '# Limb Movements (Stage 2 Sleep)'
Lmdelta = '# Limb Movements (Delta Sleep)'
Lmrem = '# Limb Movements (REM)'
lmtot = '# Limb Movements'
Lmaslp = '# Limb Movements with arousal (Sleep)'
Lmanrem = '# Limb Movements with arousal (NREM)'
Lmastg1 = '# Limb Movements with arousal (Stage 1 Sleep)'
Lmastg2 = '# Limb Movements with arousal (Stage 2 Sleep)'
Lmadelta = '# Limb Movements with arousal (Delta Sleep)'
Lmarem = '# Limb Movements with arousal (REM)'
Lma = '# Limb Movements with arousal'
Lmrslp = '# Limb Movements with resp. events (Sleep)'
Lmrnrem = '# Limb Movements with resp. events (NREM)'
Lmrstg1 = '# Limb Movements with resp. events (Stage 1 Sleep)'
Lmrstg2 = '# Limb Movements with resp. events (Stage 2 Sleep)'
Lmrdelta = '# Limb Movements with resp. events (Delta Sleep)'
Lmrrem = '# Limb Movements with resp. events (REM)'
lmr = '# Limb Movements with resp. events'
lmarslp = '# Limb Movements with arousal and resp. event (Sleep)'
Lmarnrem = '# Limb Movements with arousal and resp. event (NREM)'
Lmarstg1 = '# Limb Movements with arousal and resp. event (Stage 1 Sleep)'
Lmarstg2 = '# Limb Movements with arousal and resp. event (Stage 2 Sleep)'
Lmardelta = '# Limb Movements with arousal and resp. event (Delta Sleep)'
Lmarrem = '# Limb Movements with arousal and resp. event (REM)'
Lmar = '# Limb Movements with arousal and resp. event'
plmslp = '# PLMs (Sleep)'
plmnrem = '# PLMs (NREM)'
pLmstg1 = '# PLMs (Stage 1 Sleep)'
pLmstg2 = '# PLMs (Stage 2 Sleep)'
pLmdelta = '# PLMs (Delta Sleep)'
pLmrem = '# PLMs (REM)'
plmtot = '# PLMs'
pLmaslp = '# PLMs with arousal (Sleep)'
pLmanrem = '# PLMs with arousal (NREM)'
pLmastg1 = '# PLMs with arousal (Stage 1 Sleep)'
pLmastg2 = '# PLMs with arousal (Stage 2 Sleep)'
pLmadelta = '# PLMs with arousal (Delta Sleep)'
pLmarem = '# PLMs with arousal (REM)'
pLma = '# PLMs with arousal'
pLmrslp = '# PLMs with resp. events (Sleep)'
pLmrnrem = '# PLMs with resp. events (NREM)'
pLmrstg1 = '# PLMs with resp. events (Stage 1 Sleep)'
pLmrstg2 = '# PLMs with resp. events (Stage 2 Sleep)'
pLmrdelta = '# PLMs with resp. events (Delta Sleep)'
pLmrrem = '# PLMs with resp. events (REM)'
plmr = '# PLMs with resp. events'
plmarslp = '# PLMs with arousal and resp. event (Sleep)'
pLmarnrem = '# PLMs with arousal and resp. event (NREM)'
pLmarstg1 = '# PLMs with arousal and resp. event (Stage 1 Sleep)'
pLmarstg2 = '# PLMs with arousal and resp. event (Stage 2 Sleep)'
pLmardelta = '# PLMs with arousal and resp. event (Delta Sleep)'
pLmarrem = '# PLMs with arousal and resp. event (REM)'
pLmar = '# PLMs with arousal and resp. event'
PLMCslp = '# PLM clusters (Sleep)'
PLMCnrem = '# PLM clusters (NREM)'
PLMCstg1 = '# PLM clusters (Stage 1 Sleep)'
PLMCstg2 = '# PLM clusters (Stage 2 Sleep)'
PLMCdelta = '# PLM clusters (Delta Sleep)'
PLMCrem = '# PLM clusters (REM)'
PLMCtot = '# PLM clusters'
pLmCaslp = '# PLM clusters with arousal (Sleep)'
pLmCanrem = '# PLM clusters with arousal (NREM)'
pLmCastg1 = '# PLM clusters with arousal (Stage 1 Sleep)'
pLmCastg2 = '# PLM clusters with arousal (Stage 2 Sleep)'
pLmCadelta = '# PLM clusters with arousal (Delta Sleep)'
pLmCarem = '# PLM clusters with arousal (REM)'
pLmCa = '# PLM clusters with arousal'
pLmCrslp = '# PLM clusters with resp. events (Sleep)'
pLmCrnrem = '# PLM clusters with resp. events (NREM)'
pLmCrstg1 = '# PLM clusters with resp. events (Stage 1 Sleep)'
pLmCrstg2 = '# PLM clusters with resp. events (Stage 2 Sleep)'
pLmCrdelta = '# PLM clusters with resp. events (Delta Sleep)'
pLmCrrem = '# PLM clusters with resp. events (REM)'
plmCr = '# PLM clusters with resp. events'
plmCarslp = '# PLM clusters with arousal and resp. event (Sleep)'
pLmCarnrem = '# PLM clusters with arousal and resp. event (NREM)'
pLmCarstg1 = '# PLM clusters with arousal and resp. event (Stage 1 Sleep)'
pLmCarstg2 = '# PLM clusters with arousal and resp. event (Stage 2 Sleep)'
pLmCardelta = '# PLM clusters with arousal and resp. event (Delta Sleep)'
pLmCarrem = '# PLM clusters with arousal and resp. event (REM)'
pLmCar = '# PLM clusters with arousal and resp. event'
Urbp = '# AASM Hypopnea (REM, Back, all desats)'
Hurbp = '# AASM Hypopnea per hour (REM, Back, all desats)'
Avurbp = 'Avg. AASM Hypopnea length (REM, Back, all desats) (seconds)'
Surbp = 'Min. AASM Hypopnea length (REM, Back, all desats) (seconds)'
Lurbp = 'Max. AASM Hypopnea length (REM, Back, all desats) (seconds)'
Urop = '# AASM Hypopnea (REM, Other, all desats)'
Hurop = '# AASM Hypopnea per hour (REM, Other, all desats)'
Avurop = 'Avg. AASM Hypopnea length (REM, Other, all desats) (seconds)'
Surop = 'Min. AASM Hypopnea length (REM, Other, all desats) (seconds)'
Lurop = 'Max. AASM Hypopnea length (REM, Other, all desats) (seconds)'
Unrbp = '# AASM Hypopnea (NREM, Back, all desats)'
Hunrbp = '# AASM Hypopnea per hour (NREM, Back, all desats)'
Avunrbp = 'Avg. AASM Hypopnea length (NREM, Back, all desats) (seconds)'
Sunrbp = 'Min. AASM Hypopnea length (NREM, Back, all desats) (seconds)'
Lunrbp = 'Max. AASM Hypopnea length (NREM, Back, all desats) (seconds)'
unrop = '# AASM Hypopnea (NREM, Other, all desats)'
Hunrop = '# AASM Hypopnea per hour (NREM, Other, all desats)'
Avunrop = 'Avg. AASM Hypopnea length (NREM, Other, all desats) (seconds)'
Sunrop = 'Min. AASM Hypopnea length (NREM, Other, all desats) (seconds)'
lunrop = 'Max. AASM Hypopnea length (NREM, Other, all desats) (seconds)'
Urbpa = '# AASM Hypopnea with arousal (REM, Back, all desats)'
Hurbpa = '# AASM Hypopnea with arousal per hour (REM, Back, all desats)'
Avurbpa = 'Avg. AASM Hypopnea with arousal length (REM, Back, all desats) (seconds)'
Surbpa = 'Min. AASM Hypopnea with arousal length (REM, Back, all desats) (seconds)'
Lurbpa = 'Max. AASM Hypopnea with arousal length (REM, Back, all desats) (seconds)'
Uropa = '# AASM Hypopnea with arousal (REM, Other, all desats)'
Huropa = '# AASM Hypopnea with arousal per hour (REM, Other, all desats)'
Avuropa = 'Avg. AASM Hypopnea with arousal length (REM, Other, all desats) (seconds)'
Suropa = 'Min. AASM Hypopnea with arousal length (REM, Other, all desats) (seconds)'
Luropa = 'Max. AASM Hypopnea with arousal length (REM, Other, all desats) (seconds)'
Unrbpa = '# AASM Hypopnea with arousal (NREM, Back, all desats)'
Hunrbpa = '# AASM Hypopnea with arousal per hour (NREM, Back, all desats)'
Avunrbpa = 'Avg. AASM Hypopnea with arousal length (NREM, Back, all desats) (seconds)'
Sunrbpa = 'Min. AASM Hypopnea with arousal length (NREM, Back, all desats) (seconds)'
Lunrbpa = 'Max. AASM Hypopnea with arousal length (NREM, Back, all desats) (seconds)'
unropa = '# AASM Hypopnea with arousal (NREM, Other, all desats)'
Hunropa = '# AASM Hypopnea with arousal per hour (NREM, Other, all desats)'
Avunropa = 'Avg. AASM Hypopnea with arousal length (NREM, Other, all desats) (seconds)'
Sunropa = 'Min. AASM Hypopnea with arousal length (NREM, Other, all desats) (seconds)'
lunropa = 'Max. AASM Hypopnea with arousal length (NREM, Other, all desats) (seconds)'
Urbp2 = '# AASM Hypopnea (REM, Back, 2% desat)'
Hurbp2 = '# AASM Hypopnea per hour (REM, Back, 2% desat)'
Avurbp2 = 'Avg. AASM Hypopnea length (REM, Back, 2% desat) (seconds)'
Surbp2 = 'Min. AASM Hypopnea length (REM, Back, 2% desat) (seconds)'
Lurbp2 = 'Max. AASM Hypopnea length (REM, Back, 2% desat) (seconds)'
Urop2 = '# AASM Hypopnea (REM, Other, 2% desat)'
Hurop2 = '# AASM Hypopnea per hour (REM, Other, 2% desat)'
Avurop2 = 'Avg. AASM Hypopnea length (REM, Other, 2% desat) (seconds)'
Surop2 = 'Min. AASM Hypopnea length (REM, Other, 2% desat) (seconds)'
Lurop2 = 'Max. AASM Hypopnea length (REM, Other, 2% desat) (seconds)'
Unrbp2 = '# AASM Hypopnea (NREM, Back, 2% desat)'
Hunrbp2 = '# AASM Hypopnea per hour (NREM, Back, 2% desat)'
Avunrbp2 = 'Avg. AASM Hypopnea length (NREM, Back, 2% desat) (seconds)'
Sunrbp2 = 'Min. AASM Hypopnea length (NREM, Back, 2% desat) (seconds)'
Lunrbp2 = 'Max. AASM Hypopnea length (NREM, Back, 2% desat) (seconds)'
unrop2 = '# AASM Hypopnea (NREM, Other, 2% desat)'
Hunrop2 = '# AASM Hypopnea per hour (NREM, Other, 2% desat)'
Avunrop2 = 'Avg. AASM Hypopnea length (NREM, Other, 2% desat) (seconds)'
Sunrop2 = 'Min. AASM Hypopnea length (NREM, Other, 2% desat) (seconds)'
lunrop2 = 'Max. AASM Hypopnea length (NREM, Other, 2% desat) (seconds)'
Urbpa2 = '# AASM Hypopnea with arousal (REM, Back, 2% desat)'
Hurbpa2 = '# AASM Hypopnea with arousal per hour (REM, Back, 2% desat)'
Avurbpa2 = 'Avg. AASM Hypopnea with arousal length (REM, Back, 2% desat) (seconds)'
Surbpa2 = 'Min. AASM Hypopnea with arousal length (REM, Back, 2% desat) (seconds)'
Lurbpa2 = 'Max. AASM Hypopnea with arousal length (REM, Back, 2% desat) (seconds)'
Uropa2 = '# AASM Hypopnea with arousal (REM, Other, 2% desat)'
Huropa2 = '# AASM Hypopnea with arousal per hour (REM, Other, 2% desat)'
Avuropa2 = 'Avg. AASM Hypopnea with arousal length (REM, Other, 2% desat) (seconds)'
Suropa2 = 'Min. AASM Hypopnea with arousal length (REM, Other, 2% desat) (seconds)'
Luropa2 = 'Max. AASM Hypopnea with arousal length (REM, Other, 2% desat) (seconds)'
Unrbpa2 = '# AASM Hypopnea with arousal (NREM, Back, 2% desat)'
Hunrbpa2 = '# AASM Hypopnea with arousal per hour (NREM, Back, 2% desat)'
Avunrbpa2 = 'Avg. AASM Hypopnea with arousal length (NREM, Back, 2% desat) (seconds)'
Sunrbpa2 = 'Min. AASM Hypopnea with arousal length (NREM, Back, 2% desat) (seconds)'
Lunrbpa2 = 'Max. AASM Hypopnea with arousal length (NREM, Back, 2% desat) (seconds)'
unropa2 = '# AASM Hypopnea with arousal (NREM, Other, 2% desat)'
Hunropa2 = '# AASM Hypopnea with arousal per hour (NREM, Other, 2% desat)'
Avunropa2 = 'Avg. AASM Hypopnea with arousal length (NREM, Other, 2% desat) (seconds)'
Sunropa2 = 'Min. AASM Hypopnea with arousal length (NREM, Other, 2% desat) (seconds)'
lunropa2 = 'Max. AASM Hypopnea with arousal length (NREM, Other, 2% desat) (seconds)'
Urbp3 = '# AASM Hypopnea (REM, Back, 3% desat)'
Hurbp3 = '# AASM Hypopnea per hour (REM, Back, 3% desat)'
Avurbp3 = 'Avg. AASM Hypopnea length (REM, Back, 3% desat) (seconds)'
Surbp3 = 'Min. AASM Hypopnea length (REM, Back, 3% desat) (seconds)'
Lurbp3 = 'Max. AASM Hypopnea length (REM, Back, 3% desat) (seconds)'
Urop3 = '# AASM Hypopnea (REM, Other, 3% desat)'
Hurop3 = '# AASM Hypopnea per hour (REM, Other, 3% desat)'
Avurop3 = 'Avg. AASM Hypopnea length (REM, Other, 3% desat) (seconds) (seconds) (seconds)'
Surop3 = 'Min. AASM Hypopnea length (REM, Other, 3% desat) (seconds) (seconds) (seconds)'
Lurop3 = 'Max. AASM Hypopnea length (REM, Other, 3% desat) (seconds)'
Unrbp3 = '# AASM Hypopnea (NREM, Back, 3% desat)'
Hunrbp3 = '# AASM Hypopnea per hour (NREM, Back, 3% desat)'
Avunrbp3 = 'Avg. AASM Hypopnea length (NREM, Back, 3% desat) (seconds)'
Sunrbp3 = 'Min. AASM Hypopnea length (NREM, Back, 3% desat) (seconds)'
Lunrbp3 = 'Max. AASM Hypopnea length (NREM, Back, 3% desat) (seconds)'
unrop3 = '# AASM Hypopnea (NREM, Other, 3% desat)'
Hunrop3 = '# AASM Hypopnea per hour (NREM, Other, 3% desat)'
Avunrop3 = 'Avg. AASM Hypopnea length (NREM, Other, 3% desat) (seconds)'
Sunrop3 = 'Min. AASM Hypopnea length (NREM, Other, 3% desat) (seconds)'
lunrop3 = 'Max. AASM Hypopnea length (NREM, Other, 3% desat) (seconds)'
Urbpa3 = '# AASM Hypopnea with arousal (REM, Back, 3% desat)'
Hurbpa3 = '# AASM Hypopnea with arousal per hour (REM, Back, 3% desat)'
Avurbpa3 = 'Avg. AASM Hypopnea with arousal length (REM, Back, 3% desat) (seconds)'
Surbpa3 = 'Min. AASM Hypopnea with arousal length (REM, Back, 3% desat) (seconds)'
Lurbpa3 = 'Max. AASM Hypopnea with arousal length (REM, Back, 3% desat) (seconds)'
Uropa3 = '# AASM Hypopnea with arousal (REM, Other, 3% desat)'
Huropa3 = '# AASM Hypopnea with arousal per hour (REM, Other, 3% desat)'
Avuropa3 = 'Avg. AASM Hypopnea with arousal length (REM, Other, 3% desat) (seconds)'
Suropa3 = 'Min. AASM Hypopnea with arousal length (REM, Other, 3% desat) (seconds)'
Luropa3 = 'Max. AASM Hypopnea with arousal length (REM, Other, 3% desat) (seconds)'
Unrbpa3 = '# AASM Hypopnea with arousal (NREM, Back, 3% desat)'
Hunrbpa3 = '# AASM Hypopnea with arousal per hour (NREM, Back, 3% desat)'
Avunrbpa3 = 'Avg. AASM Hypopnea with arousal length (NREM, Back, 3% desat) (seconds)'
Sunrbpa3 = 'Min. AASM Hypopnea with arousal length (NREM, Back, 3% desat) (seconds)'
Lunrbpa3 = 'Max. AASM Hypopnea with arousal length (NREM, Back, 3% desat) (seconds)'
unropa3 = '# AASM Hypopnea with arousal (NREM, Other, 3% desat)'
Hunropa3 = '# AASM Hypopnea with arousal per hour (NREM, Other, 3% desat)'
Avunropa3 = 'Avg. AASM Hypopnea with arousal length (NREM, Other, 3% desat) (seconds)'
Sunropa3 = 'Min. AASM Hypopnea with arousal length (NREM, Other, 3% desat) (seconds)'
lunropa3 = 'Max. AASM Hypopnea with arousal length (NREM, Other, 3% desat) (seconds)'
Urbp4 = '# AASM Hypopnea (REM, Back, 4% desat)'
Hurbp4 = '# AASM Hypopnea per hour (REM, Back, 4% desat)'
Avurbp4 = 'Avg. AASM Hypopnea length (REM, Back, 4% desat) (seconds)'
Surbp4 = 'Min. AASM Hypopnea length (REM, Back, 4% desat) (seconds)'
Lurbp4 = 'Max. AASM Hypopnea length (REM, Back, 4% desat) (seconds)'
Urop4 = '# AASM Hypopnea (REM, Other, 4% desat)'
Hurop4 = '# AASM Hypopnea per hour (REM, Other, 4% desat)'
Avurop4 = 'Avg. AASM Hypopnea length (REM, Other, 4% desat) (seconds)'
Surop4 = 'Min. AASM Hypopnea length (REM, Other, 4% desat) (seconds)'
Lurop4 = 'Max. AASM Hypopnea length (REM, Other, 4% desat) (seconds)'
Unrbp4 = '# AASM Hypopnea (NREM, Back, 4% desat)'
Hunrbp4 = '# AASM Hypopnea per hour (NREM, Back, 4% desat)'
Avunrbp4 = 'Avg. AASM Hypopnea length (NREM, Back, 4% desat) (seconds)'
Sunrbp4 = 'Min. AASM Hypopnea length (NREM, Back, 4% desat) (seconds)'
Lunrbp4 = 'Max. AASM Hypopnea length (NREM, Back, 4% desat) (seconds)'
unrop4 = '# AASM Hypopnea (NREM, Other, 4% desat)'
Hunrop4 = '# AASM Hypopnea per hour (NREM, Other, 4% desat)'
Avunrop4 = 'Avg. AASM Hypopnea length (NREM, Other, 4% desat) (seconds)'
Sunrop4 = 'Min. AASM Hypopnea length (NREM, Other, 4% desat) (seconds)'
lunrop4 = 'Max. AASM Hypopnea length (NREM, Other, 4% desat) (seconds)'
Urbpa4 = '# AASM Hypopnea with arousal (REM, Back, 4% desat)'
Hurbpa4 = '# AASM Hypopnea with arousal per hour (REM, Back, 4% desat)'
Avurbpa4 = 'Avg. AASM Hypopnea with arousal length (REM, Back, 4% desat) (seconds)'
Surbpa4 = 'Min. AASM Hypopnea with arousal length (REM, Back, 4% desat) (seconds)'
Lurbpa4 = 'Max. AASM Hypopnea with arousal length (REM, Back, 4% desat) (seconds)'
Uropa4 = '# AASM Hypopnea with arousal (REM, Other, 4% desat)'
Huropa4 = '# AASM Hypopnea with arousal per hour (REM, Other, 4% desat)'
Avuropa4 = 'Avg. AASM Hypopnea with arousal length (REM, Other, 4% desat) (seconds)'
Suropa4 = 'Min. AASM Hypopnea with arousal length (REM, Other, 4% desat) (seconds)'
Luropa4 = 'Max. AASM Hypopnea with arousal length (REM, Other, 4% desat) (seconds)'
Unrbpa4 = '# AASM Hypopnea with arousal (NREM, Back, 4% desat)'
Hunrbpa4 = '# AASM Hypopnea with arousal per hour (NREM, Back, 4% desat)'
Avunrbpa4 = 'Avg. AASM Hypopnea with arousal length (NREM, Back, 4% desat) (seconds)'
Sunrbpa4 = 'Min. AASM Hypopnea with arousal length (NREM, Back, 4% desat) (seconds)'
Lunrbpa4 = 'Max. AASM Hypopnea with arousal length (NREM, Back, 4% desat) (seconds)'
unropa4 = '# AASM Hypopnea with arousal (NREM, Other, 4% desat)'
Hunropa4 = '# AASM Hypopnea with arousal per hour (NREM, Other, 4% desat)'
Avunropa4 = 'Avg. AASM Hypopnea with arousal length (NREM, Other, 4% desat) (seconds)'
Sunropa4 = 'Min. AASM Hypopnea with arousal length (NREM, Other, 4% desat) (seconds)'
lunropa4 = 'Max. AASM Hypopnea with arousal length (NREM, Other, 4% desat) (seconds)'
Urbp5 = '# AASM Hypopnea (REM, Back, 5% desat)'
Hurbp5 = '# AASM Hypopnea per hour (REM, Back, 5% desat)'
Avurbp5 = 'Avg. AASM Hypopnea length (REM, Back, 5% desat) (seconds)'
Surbp5 = 'Min. AASM Hypopnea length (REM, Back, 5% desat) (seconds)'
Lurbp5 = 'Max. AASM Hypopnea length (REM, Back, 5% desat) (seconds)'
Urop5 = '# AASM Hypopnea (REM, Other, 5% desat)'
Hurop5 = '# AASM Hypopnea per hour (REM, Other, 5% desat)'
Avurop5 = 'Avg. AASM Hypopnea length (REM, Other, 5% desat) (seconds)'
Surop5 = 'Min. AASM Hypopnea length (REM, Other, 5% desat) (seconds)'
Lurop5 = 'Max. AASM Hypopnea length (REM, Other, 5% desat) (seconds)'
Unrbp5 = '# AASM Hypopnea (NREM, Back, 5% desat)'
Hunrbp5 = '# AASM Hypopnea per hour (NREM, Back, 5% desat)'
Avunrbp5 = 'Avg. AASM Hypopnea length (NREM, Back, 5% desat) (seconds)'
Sunrbp5 = 'Min. AASM Hypopnea length (NREM, Back, 5% desat) (seconds)'
Lunrbp5 = 'Max. AASM Hypopnea length (NREM, Back, 5% desat) (seconds)'
unrop5 = '# AASM Hypopnea (NREM, Other, 5% desat)'
Hunrop5 = '# AASM Hypopnea per hour (NREM, Other, 5% desat)'
Avunrop5 = 'Avg. AASM Hypopnea length (NREM, Other, 5% desat) (seconds)'
Sunrop5 = 'Min. AASM Hypopnea length (NREM, Other, 5% desat) (seconds)'
lunrop5 = 'Max. AASM Hypopnea length (NREM, Other, 5% desat) (seconds)'
Urbpa5 = '# AASM Hypopnea with arousal (REM, Back, 5% desat)'
Hurbpa5 = '# AASM Hypopnea with arousal per hour (REM, Back, 5% desat)'
Avurbpa5 = 'Avg. AASM Hypopnea with arousal length (REM, Back, 5% desat) (seconds)'
Surbpa5 = 'Min. AASM Hypopnea with arousal length (REM, Back, 5% desat) (seconds)'
Lurbpa5 = 'Max. AASM Hypopnea with arousal length (REM, Back, 5% desat) (seconds)'
Uropa5 = '# AASM Hypopnea with arousal (REM, Other, 5% desat)'
Huropa5 = '# AASM Hypopnea with arousal per hour (REM, Other, 5% desat)'
Avuropa5 = 'Avg. AASM Hypopnea with arousal length (REM, Other, 5% desat)'
Suropa5 = 'Min. AASM Hypopnea with arousal length (REM, Other, 5% desat) (seconds)'
Luropa5 = 'Max. AASM Hypopnea with arousal length (REM, Other, 5% desat) (seconds)'
Unrbpa5 = '# AASM Hypopnea with arousal (NREM, Back, 5% desat)'
Hunrbpa5 = '# AASM Hypopnea with arousal per hour (NREM, Back, 5% desat)'
Avunrbpa5 = 'Avg. AASM Hypopnea with arousal length (NREM, Back, 5% desat) (seconds)'
Sunrbpa5 = 'Min. AASM Hypopnea with arousal length (NREM, Back, 5% desat) (seconds)'
Lunrbpa5 = 'Max. AASM Hypopnea with arousal length (NREM, Back, 5% desat) (seconds)'
unropa5 = '# AASM Hypopnea with arousal (NREM, Other, 5% desat)'
Hunropa5 = '# AASM Hypopnea with arousal per hour (NREM, Other, 5% desat)'
Avunropa5 = 'Avg. AASM Hypopnea with arousal length (NREM, Other, 5% desat) (seconds)'
Sunropa5 = 'Min. AASM Hypopnea with arousal length (NREM, Other, 5% desat) (seconds)'
lunropa5 = 'Max. AASM Hypopnea with arousal length (NREM, Other, 5% desat) (seconds)'
rpt = 'Compumedics Report Version'
havestudy = 'Has Scored PSG Study'
inqs = 'Has PSG QS Form Entered'
waso = 'Calculated - Wake after sleep onset (minutes)'
time_bed = 'Calculated - time in bed (minutes)'
slp_eff = 'Calculated - sleep efficiency %'
timest1p = 'Calculated - pct time stage 1'
timest1 = 'Calculated - time stage 1 minutes'
timest2p = 'Calculated - pct time stage 2'
timest2 = 'Calculated - time stage 2 minutes'
times34p = 'Calculated - pct time stage 3-4'
timest34 = 'Calculated - time stage 3-4 minutes'
timeremp = 'Calculated - pct time REM'
timerem = 'Calculated - time rem minutes'
rem_lat1 = 'Calculated - rem latency I in minutes slp onset to first rem'
supinep = 'Calculated - pct time supine'
nsupinep = 'Calculated - pct time non-supine'
ai_all = 'Calculated - Overall arousal index'
ai_rem = 'Calculated - arousal index rem sleep'
ai_nrem = 'Calculated - arousal index non-rem'
rdi0p = 'Calculated - Overall RDI at 0% desat'
rdi2p = 'Calculated - Overall RDI at 2% desat'
rdi3p = 'Calculated - Overall RDI at 3% desat'
rdi4p = 'Calculated - Overall RDI at 4% desat'
rdi5p = 'Calculated - Overall RDI at 5% desat'
rdi0pa = 'Calculated - Overall RDI at 0% desat or arousal'
rdi2pa = 'Calculated - Overall RDI at 2% desat or arousal'
rdi3pa = 'Calculated - Overall RDI at 3% desat or arousal'
rdi4pa = 'Calculated - Overall RDI at 4% desat or arousal'
rdi5pa = 'Calculated - Overall RDI at 5% desat or arousal'
rdi0ps = 'Calculated - Overall Supine RDI at 0% desat'
rdi2ps = 'Calculated - Overall Supine RDI at 2% desat'
rdi3ps = 'Calculated - Overall Supine RDI at 3% desat'
rdi4ps = 'Calculated - Overall Supine RDI at 4% desat'
rdi5ps = 'Calculated - Overall Supine RDI at 5% desat'
rdi0pns = 'Calculated - Overall Non-Supine RDI at 0% desat'
rdi2pns = 'Calculated - Overall Non-Supine RDI at 2% desat'
rdi3pns = 'Calculated - Overall Non-Supine RDI at 3% desat'
rdi4pns = 'Calculated - Overall Non-Supine RDI at 4% desat'
rdi5pns = 'Calculated - Overall Non-Supine RDI at 5% desat'
rdirem0p = 'Calculated - Overall rem RDI at 0% desat'
rdirem2p = 'Calculated - Overall rem RDI at 2% desat'
rdirem3p = 'Calculated - Overall rem RDI at 3% desat'
rdirem4p = 'Calculated - Overall Rem RDI at 4% desat'
rdirem5p = 'Calculated - Overall rem RDI at 5% desat'
rdinr0p = 'Calculated - Overall Non-rem RDI at 0% desat'
rdinr2p = 'Calculated - Overall Non-rem RDI at 2% desat'
rdinr3p = 'Calculated - Overall Non-rem RDI at 3% desat'
rdinr4p = 'Calculated - Overall Non-rem RDI at 4% desat'
rdinr5p = 'Calculated - Overall Non-rem RDI at 5% desat'
oahi4 = 'Calculated - Obstructive apnea (all desats) Hypopnea (4% desat) Index'
oahi3 = 'Calculated - Obstructive apnea (all desats) Hypopnea (3% desat) Index'
oai0p = 'Calculated - Obstructive Apnea Index all desats'
oai4p = 'Calculated - Obstructive Apnea Index 4% desats'
oai4pa = 'Calculated - Obstructive Apnea Index 4% or arousal'
cai0p = 'Calculated - Central Apnea Index all desats'
cai4p = 'Calculated - Central Apnea Index 4% desats'
cai4pa = 'Calculated - Central Apnea Index 4% or arousal'
pctlt90 = 'Calculated - pct time < 90% desat'
pctlt85 = 'Calculated - pct time < 85% desat'
pctlt80 = 'Calculated - pct time < 80% desat'
pctlt75 = 'Calculated - pct time < 75% desat'
sao2rem = 'Calculated - avg sao2 rem'
sao2nrem = 'Calculated - avg sao2 nrem'
losao2r = 'Calculated - min sao2 rem'
losao2nr = 'Calculated - min sao2 nrem'
avgsat = 'Calculated - avg SaO2 in sleep'
minsat = 'Calculated - min SaO2 in sleep'
= ' '
= ' '
= ' '
= ' '
= ' '
;

format
pptid $12.
acrostic $4.
stdydt MMDDYY8.
rcvddt MMDDYY8.
staendt MMDDYY8.
unitid VD02226F.
techid VD02225F.
siteid VD02227F.
status VD01258F.
rsnco VD02228F.
EnvrmtOu CHECKF.
pfcomm $5000.
prio YESNOF.
rcrdtime 6.
scordt MMDDYY8.
scorid SCORIDF.
slptime 6.
sclout TIME5.
scslpon TIME5.
sclon TIME5.
lighoff TIME5.
rdiqs 10.2
cpapuse YESNOF.
o2use YESNOF.
e1dur 6.
e2dur 6.
chindur 6.
c3dur 6.
c4dur 6.
ecgdur 6.
LegLdur 6.
LegRdur 6.
Airdur 6.
xflowdur 6.
Chestdur 6.
Abdodur 6.
Oximdur 6.
SUMdur 6.
que1 VD01334F.
que2 VD01334F.
quchin VD01334F.
quc3 VD01334F.
quc4 VD01334F.
quecg VD01334F.
quLegL VD01334F.
quLegR VD01334F.
quAir VD01334F.
quxflow VD01334F.
quChest VD01334F.
quAbdo VD01334F.
quOxim VD01334F.
quSUM VD01334F.
m1 YESNOF.
m2 YESNOF.
ref YESNOF.
posn YESNOF.
overall VD01243F.
slewake YESNOF.
AHIov50 YESNOF.
sao2lt85 YESNOF.
unuhrou VD02229F.
unuhrou3a CHECKF.
unuhrou3b CHECKF.
unuhrou4a CHECKF.
unuhrou4b CHECKF.
unuhrou4c CHECKF.
unuhrou4d CHECKF.
unuhrou4e CHECKF.
unuhrou4f CHECKF.
unuhrou4g CHECKF.
unuhrou4h CHECKF.
unuhrou4i CHECKF.
unuhrou4j CHECKF.
RecBeAw YESNOF.
LosBeg YESNOF.
LosEnd YESNOF.
LosOth YESNOF.
WakSlePr YESNOF.
Stg1Stg2Pr YESNOF.
Stg2Stg3Pr YESNOF.
RemNRemPr YESNOF.
ArUnrel YESNOF.
RemArUnrel YESNOF.
RespEvPr YESNOF.
ApnHypPr YESNOF.
AbnorEEG YESNOF.
AlpDEL YESNOF.
Period YESNOF.
LagBreath YESNOF.
NPFLOW YESNOF.
PLMWAKE YESNOF.
UnuStgOu YESNOF.
RDI0Ou YESNOF.
ARSL3OU YESNOF.
MaxResOu YESNOF.
PLMOU YESNOF.
OtherOu YESNOF.
dhrinvalid YESNOF.
Comm $300.
Notes $300.
inqs_form YESNOF.
SCORERID 3.0
STDATEP MMDDYY10.0
SCOREDT MMDDYY10.0
STLOUTP TIME8.
STONSETP TIME8.
SLPLATP 8.2
REMLAIP 8.2
REMLAIIP 8.2
TIMEBEDP 8.2
SLPPRDP 8.2
SLPEFFP 8.2
TMSTG1P 8.2
MINSTG1P 8.2
TMSTG2P 8.2
MINSTG2P 8.2
TMSTG34P 8.2
MNSTG34P 8.2
TMREMP 8.2
MINREMP 8.2
ARREMBP 3.0
ARREMOP 3.0
ARNREMBP 3.0
ARNREMOP 3.0
AHREMBP 8.2
AHREMOP 8.2
AHNREMBP 8.2
AHNREMOP 8.2
AI 8.2
OAI 8.2
CAI 8.2
STSTARTP TIME8.
STENDP TIME8.
STDURM 8.2
SCLOUTP TIME8.
STLONP TIME8.
STONSET1 TIME8.
TIMEBEDM 8.2
SLPLATM 8.2
REMLATM 8.2
WASOM 8.2
SLPTIMEM 8.2
SLPPRDM 8.2
STG2T1P 3.0
STG34T2P 3.0
REMT1P 3.0
REMT2P 3.0
REMT34P 3.0
SLPTAWP 3.0
HSTG2T1P 8.2
HSTG342P 8.2
HREMT1P 8.2
HREMT2P 8.2
HREMT34P 8.2
HSLPTAWP 8.2
BPMAVG 3.0
BPMMIN 3.0
BPMMAX 3.0
APNEA3 8.2
AHI3 8.2
AHIU3 8.2
HREMBP 3.0
RDIRBP 8.2
AVHRBP 3.0
MNHRBP 3.0
MXHRBP 3.0
HROP 3.0
RDIROP 8.2
AVHROP 3.0
MNHROP 3.0
MXHROP 3.0
HNRBP 3.0
RDINBP 8.2
AVHNBP 3.0
MNHNBP 3.0
MXHNBP 3.0
HNROP 3.0
RDINOP 8.2
AVHNOP 3.0
MNHNOP 3.0
MXHNOP 3.0
CARBP 3.0
CARDRBP 8.2
AVCARBP 3.0
MNCARBP 3.0
MXCARBP 3.0
CAROP 3.0
CARDROP 8.2
AVCAROP 3.0
MNCAROP 3.0
MXCAROP 3.0
CANBP 3.0
CARDNBP 8.2
AVCANBP 3.0
MNCANBP 3.0
MXCANBP 3.0
CANOP 3.0
CARDNOP 8.2
AVCANOP 3.0
MNCANOP 3.0
MXCANOP 3.0
OARBP 3.0
OARDRBP 8.2
AVOARBP 3.0
MNOARBP 3.0
MXOARBP 3.0
OAROP 3.0
OARDROP 8.2
AVOAROP 3.0
MNOAROP 3.0
MXOAROP 3.0
OANBP 3.0
OARDNBP 8.2
AVOANBP 3.0
MNOANBP 3.0
MXOANBP 3.0
OANOP 3.0
OARDNOP 8.2
AVOANOP 3.0
MNOANOP 3.0
MXOANOP 3.0
MXDRBP 3.0
MXDROP 3.0
MXDNBP 3.0
MXDNOP 3.0
AVDRBP 3.0
AVDROP 3.0
AVDNBP 3.0
AVDNOP 3.0
MNDRBP 3.0
MNDROP 3.0
MNDNBP 3.0
MNDNOP 3.0
HREMBA 3.0
RDIRBA 8.2
AVHRBA 8.2
MNHRBA 3.0
MXHRBA 3.0
HROA 3.0
RDIROA 8.2
AVHROA 3.0
MNHROA 3.0
MXHROA 3.0
HNRBA 3.0
RDINBA 8.2
AVHNBA 3.0
MNHNBA 3.0
MXHNBA 3.0
HNROA 3.0
RDINOA 8.2
AVHNOA 3.0
MNHNOA 3.0
MXHNOA 3.0
CARBA 3.0
CARDRBA 8.2
AVCARBA 3.0
MNCARBA 3.0
MXCARBA 3.0
CAROA 3.0
CARDROA 8.2
AVCAROA 3.0
MNCAROA 3.0
MXCAROA 3.0
CANBA 3.0
CARDNBA 8.2
AVCANBA 3.0
MNCANBA 3.0
MXCANBA 3.0
CANOA 3.0
CARDNOA 8.2
AVCANOA 3.0
MNCANOA 3.0
MXCANOA 3.0
OARBA 3.0
OARDRBA 8.2
AVOARBA 3.0
MNOARBA 3.0
MXOARBA 3.0
OAROA 3.0
OARDROA 8.2
AVOAROA 3.0
MNOAROA 3.0
MXOAROA 3.0
OANBA 3.0
OARDNBA 8.2
AVOANBA 3.0
MNOANBA 3.0
MXOANBA 3.0
OANOA 3.0
OARDNOA 8.2
AVOANOA 3.0
MNOANOA 3.0
MXOANOA 3.0
MXDRBA 3.0
MXDROA 3.0
MXDNBA 3.0
MXDNOA 3.0
AVDRBA 3.0
AVDROA 3.0
AVDNBA 3.0
AVDNOA 3.0
MNDRBA 3.0
MNDROA 3.0
MNDNBA 3.0
MNDNOA 3.0
HREMBP2 3.0
RDIRBP2 8.2
AVHRBP2 3.0
MNHRBP2 3.0
MXHRBP2 3.0
HROP2 3.0
RDIROP2 8.2
AVHROP2 3.0
MNHROP2 3.0
MXHROP2 3.0
HNRBP2 3.0
RDINBP2 8.2
AVHNBP2 3.0
MNHNBP2 3.0
MXHNBP2 3.0
HNROP2 3.0
RDINOP2 8.2
AVHNOP2 3.0
MNHNOP2 3.0
MXHNOP2 3.0
CARBP2 3.0
CARDRBP2 8.2
AVCARBP2 3.0
MNCARBP2 3.0
MXCARBP2 3.0
CAROP2 3.0
CARDROP2 8.2
AVCAROP2 3.0
MNCAROP2 3.0
MXCAROP2 3.0
CANBP2 3.0
CARDNBP2 8.2
AVCANBP2 3.0
MNCANBP2 3.0
MXCANBP2 3.0
CANOP2 3.0
CARDNOP2 8.2
AVCANOP2 3.0
MNCANOP2 3.0
MXCANOP2 3.0
OARBP2 3.0
OARDRBP2 8.2
AVOARBP2 3.0
MNOARBP2 3.0
MXOARBP2 3.0
OAROP2 3.0
OARDROP2 8.2
AVOAROP2 3.0
MNOAROP2 3.0
MXOAROP2 3.0
OANBP2 3.0
OARDNBP2 8.2
AVOANBP2 3.0
MNOANBP2 3.0
MXOANBP2 3.0
OANOP2 3.0
OARDNOP2 8.2
AVOANOP2 3.0
MNOANOP2 3.0
MXOANOP2 3.0
MXDRBP2 3.0
MXDROP2 3.0
MXDNBP2 3.0
MXDNOP2 3.0
AVDRBP2 3.0
AVDROP2 3.0
AVDNBP2 3.0
AVDNOP2 3.0
MNDRBP2 3.0
MNDROP2 3.0
MNDNBP2 3.0
MNDNOP2 3.0
HREMBA2 3.0
RDIRBA2 8.2
AVHRBA2 3.0
MNHRBA2 3.0
MXHRBA2 3.0
HROA2 3.0
RDIROA2 8.2
AVHROA2 3.0
MNHROA2 3.0
MXHROA2 3.0
HNRBA2 3.0
RDINBA2 8.2
AVHNBA2 3.0
MNHNBA2 3.0
MXHNBA2 3.0
HNROA2 3.0
RDINOA2 8.2
AVHNOA2 3.0
MNHNOA2 3.0
MXHNOA2 3.0
CARBA2 3.0
CARDRBA2 8.2
AVCARBA2 3.0
MNCARBA2 3.0
MXCARBA2 3.0
CAROA2 3.0
CARDROA2 8.2
AVCAROA2 3.0
MNCAROA2 3.0
MXCAROA2 3.0
CANBA2 3.0
CARDNBA2 8.2
AVCANBA2 3.0
MNCANBA2 3.0
MXCANBA2 3.0
CANOA2 3.0
CARDNOA2 8.2
AVCANOA2 3.0
MNCANOA2 3.0
MXCANOA2 3.0
OARBA2 3.0
OARDRBA2 8.2
AVOARBA2 3.0
MNOARBA2 3.0
MXOARBA2 3.0
OAROA2 3.0
OARDROA2 8.2
AVOAROA2 3.0
MNOAROA2 3.0
MXOAROA2 3.0
OANBA2 3.0
OARDNBA2 8.2
AVOANBA2 3.0
MNOANBA2 3.0
MXOANBA2 3.0
OANOA2 3.0
OARDNOA2 8.2
AVOANOA2 3.0
MNOANOA2 3.0
MXOANOA2 3.0
MXDRBA2 3.0
MXDROA2 3.0
MXDNBA2 3.0
MXDNOA2 3.0
AVDRBA2 3.0
AVDROA2 3.0
AVDNBA2 3.0
AVDNOA2 3.0
MNDRBA2 3.0
MNDROA2 3.0
MNDNBA2 3.0
MNDNOA2 3.0
HREMBP3 3.0
RDIRBP3 8.2
AVHRBP3 3.0
MNHRBP3 3.0
MXHRBP3 3.0
HROP3 3.0
RDIROP3 8.2
AVHROP3 3.0
MNHROP3 3.0
MXHROP3 3.0
HNRBP3 3.0
RDINBP3 8.2
AVHNBP3 3.0
MNHNBP3 3.0
MXHNBP3 3.0
HNROP3 3.0
RDINOP3 8.2
AVHNOP3 3.0
MNHNOP3 3.0
MXHNOP3 3.0
CARBP3 3.0
CARDRBP3 8.2
AVCARBP3 3.0
MNCARBP3 3.0
MXCARBP3 3.0
CAROP3 3.0
CARDROP3 8.2
AVCAROP3 3.0
MNCAROP3 3.0
MXCAROP3 3.0
CANBP3 3.0
CARDNBP3 8.2
AVCANBP3 3.0
MNCANBP3 3.0
MXCANBP3 3.0
CANOP3 3.0
CARDNOP3 8.2
AVCANOP3 3.0
MNCANOP3 3.0
MXCANOP3 3.0
OARBP3 3.0
OARDRBP3 8.2
AVOARBP3 3.0
MNOARBP3 3.0
MXOARBP3 3.0
OAROP3 3.0
OARDROP3 8.2
AVOAROP3 3.0
MNOAROP3 3.0
MXOAROP3 3.0
OANBP3 3.0
OARDNBP3 8.2
AVOANBP3 3.0
MNOANBP3 3.0
MXOANBP3 3.0
OANOP3 3.0
OARDNOP3 8.2
AVOANOP3 3.0
MNOANOP3 3.0
MXOANOP3 3.0
MXDRBP3 3.0
MXDROP3 3.0
MXDNBP3 3.0
MXDNOP3 3.0
AVDRBP3 3.0
AVDROP3 3.0
AVDNBP3 3.0
AVDNOP3 3.0
MNDRBP3 3.0
MNDROP3 3.0
MNDNBP3 3.0
MNDNOP3 3.0
HREMBA3 3.0
RDIRBA3 8.2
AVHRBA3 3.0
MNHRBA3 3.0
MXHRBA3 3.0
HROA3 3.0
RDIROA3 8.2
AVHROA3 3.0
MNHROA3 3.0
MXHROA3 3.0
HNRBA3 3.0
RDINBA3 8.2
AVHNBA3 3.0
MNHNBA3 3.0
MXHNBA3 3.0
HNROA3 3.0
RDINOA3 8.2
AVHNOA3 3.0
MNHNOA3 3.0
MXHNOA3 3.0
CARBA3 3.0
CARDRBA3 8.2
AVCARBA3 3.0
MNCARBA3 3.0
MXCARBA3 3.0
CAROA3 3.0
CARDROA3 8.2
AVCAROA3 3.0
MNCAROA3 3.0
MXCAROA3 3.0
CANBA3 3.0
CARDNBA3 8.2
AVCANBA3 3.0
MNCANBA3 3.0
MXCANBA3 3.0
CANOA3 3.0
CARDNOA3 8.2
AVCANOA3 3.0
MNCANOA3 3.0
MXCANOA3 3.0
OARBA3 3.0
OARDRBA3 8.2
AVOARBA3 3.0
MNOARBA3 3.0
MXOARBA3 3.0
OAROA3 3.0
OARDROA3 8.2
AVOAROA3 3.0
MNOAROA3 3.0
MXOAROA3 3.0
OANBA3 3.0
OARDNBA3 8.2
AVOANBA3 3.0
MNOANBA3 3.0
MXOANBA3 3.0
OANOA3 3.0
OARDNOA3 8.2
AVOANOA3 3.0
MNOANOA3 3.0
MXOANOA3 3.0
MXDRBA3 3.0
MXDROA3 3.0
MXDNBA3 3.0
MXDNOA3 3.0
AVDRBA3 3.0
AVDROA3 3.0
AVDNBA3 3.0
AVDNOA3 3.0
MNDRBA3 3.0
MNDROA3 3.0
MNDNBA3 3.0
MNDNOA3 3.0
HREMBP4 3.0
RDIRBP4 8.2
AVHRBP4 3.0
MNHRBP4 3.0
MXHRBP4 3.0
HROP4 3.0
RDIROP4 8.2
AVHROP4 3.0
MNHROP4 3.0
MXHROP4 3.0
HNRBP4 3.0
RDINBP4 8.2
AVHNBP4 3.0
MNHNBP4 3.0
MXHNBP4 3.0
HNROP4 3.0
RDINOP4 8.2
AVHNOP4 3.0
MNHNOP4 3.0
MXHNOP4 3.0
CARBP4 3.0
CARDRBP4 8.2
AVCARBP4 3.0
MNCARBP4 3.0
MXCARBP4 3.0
CAROP4 3.0
CARDROP4 8.2
AVCAROP4 3.0
MNCAROP4 3.0
MXCAROP4 3.0
CANBP4 3.0
CARDNBP4 8.2
AVCANBP4 3.0
MNCANBP4 3.0
MXCANBP4 3.0
CANOP4 3.0
CARDNOP4 8.2
AVCANOP4 3.0
MNCANOP4 3.0
MXCANOP4 3.0
OARBP4 3.0
OARDRBP4 8.2
AVOARBP4 3.0
MNOARBP4 3.0
MXOARBP4 3.0
OAROP4 3.0
OARDROP4 8.2
AVOAROP4 3.0
MNOAROP4 3.0
MXOAROP4 3.0
OANBP4 3.0
OARDNBP4 8.2
AVOANBP4 3.0
MNOANBP4 3.0
MXOANBP4 3.0
OANOP4 3.0
OARDNOP4 8.2
AVOANOP4 3.0
MNOANOP4 3.0
MXOANOP4 3.0
MXDRBP4 3.0
MXDROP4 3.0
MXDNBP4 3.0
MXDNOP4 3.0
AVDRBP4 3.0
AVDROP4 3.0
AVDNBP4 3.0
AVDNOP4 3.0
MNDRBP4 3.0
MNDROP4 3.0
MNDNBP4 3.0
MNDNOP4 3.0
HREMBA4 3.0
RDIRBA4 8.2
AVHRBA4 3.0
MNHRBA4 3.0
MXHRBA4 3.0
HROA4 3.0
RDIROA4 8.2
AVHROA4 3.0
MNHROA4 3.0
MXHROA4 3.0
HNRBA4 3.0
RDINBA4 8.2
AVHNBA4 3.0
MNHNBA4 3.0
MXHNBA4 3.0
HNROA4 3.0
RDINOA4 8.2
AVHNOA4 3.0
MNHNOA4 3.0
MXHNOA4 3.0
CARBA4 3.0
CARDRBA4 8.2
AVCARBA4 3.0
MNCARBA4 3.0
MXCARBA4 3.0
CAROA4 3.0
CARDROA4 8.2
AVCAROA4 3.0
MNCAROA4 3.0
MXCAROA4 3.0
CANBA4 3.0
CARDNBA4 8.2
AVCANBA4 3.0
MNCANBA4 3.0
MXCANBA4 3.0
CANOA4 3.0
CARDNOA4 8.2
AVCANOA4 3.0
MNCANOA4 3.0
MXCANOA4 3.0
OARBA4 3.0
OARDRBA4 8.2
AVOARBA4 3.0
MNOARBA4 3.0
MXOARBA4 3.0
OAROA4 3.0
OARDROA4 8.2
AVOAROA4 3.0
MNOAROA4 3.0
MXOAROA4 3.0
OANBA4 3.0
OARDNBA4 8.2
AVOANBA4 3.0
MNOANBA4 3.0
MXOANBA4 3.0
OANOA4 3.0
OARDNOA4 8.2
AVOANOA4 3.0
MNOANOA4 3.0
MXOANOA4 3.0
MXDRBA4 3.0
MXDROA4 3.0
MXDNBA4 3.0
MXDNOA4 3.0
AVDRBA4 3.0
AVDROA4 3.0
AVDNBA4 3.0
AVDNOA4 3.0
MNDRBA4 3.0
MNDROA4 3.0
MNDNBA4 3.0
MNDNOA4 3.0
HREMBP5 3.0
RDIRBP5 8.2
AVHRBP5 3.0
MNHRBP5 3.0
MXHRBP5 3.0
HROP5 3.0
RDIROP5 8.2
AVHROP5 3.0
MNHROP5 3.0
MXHROP5 3.0
HNRBP5 3.0
RDINBP5 8.2
AVHNBP5 3.0
MNHNBP5 3.0
MXHNBP5 3.0
HNROP5 3.0
RDINOP5 8.2
AVHNOP5 3.0
MNHNOP5 3.0
MXHNOP5 3.0
CARBP5 3.0
CARDRBP5 8.2
AVCARBP5 3.0
MNCARBP5 3.0
MXCARBP5 3.0
CAROP5 3.0
CARDROP5 8.2
AVCAROP5 3.0
MNCAROP5 3.0
MXCAROP5 3.0
CANBP5 3.0
CARDNBP5 8.2
AVCANBP5 3.0
MNCANBP5 3.0
MXCANBP5 3.0
CANOP5 3.0
CARDNOP5 8.2
AVCANOP5 3.0
MNCANOP5 3.0
MXCANOP5 3.0
OARBP5 3.0
OARDRBP5 8.2
AVOARBP5 3.0
MNOARBP5 3.0
MXOARBP5 3.0
OAROP5 3.0
OARDROP5 8.2
AVOAROP5 3.0
MNOAROP5 3.0
MXOAROP5 3.0
OANBP5 3.0
OARDNBP5 8.2
AVOANBP5 3.0
MNOANBP5 3.0
MXOANBP5 3.0
OANOP5 3.0
OARDNOP5 8.2
AVOANOP5 3.0
MNOANOP5 3.0
MXOANOP5 3.0
MXDRBP5 3.0
MXDROP5 3.0
MXDNBP5 3.0
MXDNOP5 3.0
AVDRBP5 3.0
AVDROP5 3.0
AVDNBP5 3.0
AVDNOP5 3.0
MNDRBP5 3.0
MNDROP5 3.0
MNDNBP5 3.0
MNDNOP5 3.0
HREMBA5 3.0
RDIRBA5 8.2
AVHRBA5 3.0
MNHRBA5 3.0
MXHRBA5 3.0
HROA5 3.0
RDIROA5 8.2
AVHROA5 3.0
MNHROA5 3.0
MXHROA5 3.0
HNRBA5 3.0
RDINBA5 8.2
AVHNBA5 3.0
MNHNBA5 3.0
MXHNBA5 3.0
HNROA5 3.0
RDINOA5 8.2
AVHNOA5 3.0
MNHNOA5 3.0
MXHNOA5 3.0
CARBA5 3.0
CARDRBA5 8.2
AVCARBA5 3.0
MNCARBA5 3.0
MXCARBA5 3.0
CAROA5 3.0
CARDROA5 8.2
AVCAROA5 3.0
MNCAROA5 3.0
MXCAROA5 3.0
CANBA5 3.0
CARDNBA5 8.2
AVCANBA5 3.0
MNCANBA5 3.0
MXCANBA5 3.0
CANOA5 3.0
CARDNOA5 8.2
AVCANOA5 3.0
MNCANOA5 3.0
MXCANOA5 3.0
OARBA5 3.0
OARDRBA5 8.2
AVOARBA5 3.0
MNOARBA5 3.0
MXOARBA5 3.0
OAROA5 3.0
OARDROA5 8.2
AVOAROA5 3.0
MNOAROA5 3.0
MXOAROA5 3.0
OANBA5 3.0
OARDNBA5 8.2
AVOANBA5 3.0
MNOANBA5 3.0
MXOANBA5 3.0
OANOA5 3.0
OARDNOA5 8.2
AVOANOA5 3.0
MNOANOA5 3.0
MXOANOA5 3.0
MXDRBA5 3.0
MXDROA5 3.0
MXDNBA5 3.0
MXDNOA5 3.0
AVDRBA5 3.0
AVDROA5 3.0
AVDNBA5 3.0
AVDNOA5 3.0
MNDRBA5 3.0
MNDROA5 3.0
MNDNBA5 3.0
MNDNOA5 3.0
PCTSTAPN 8.2
PCTSTHYP 8.2
PCSTAHAR 8.2
PCSTAH3D 8.2
PCSTAHDA 8.2
SAVBRBH 3.0
SMNBRBH 3.0
SMXBRBH 3.0
SAVBROH 3.0
SMNBROH 3.0
SMXBROH 3.0
SAVBNBH 3.0
SMNBNBH 3.0
SMXBNBH 3.0
SAVBNOH 3.0
SMNBNOH 3.0
SMXBNOH 3.0
AAVBRBH 3.0
AMNBRBH 3.0
AMXBRBH 3.0
AAVBROH 3.0
AMNBROH 3.0
AMXBROH 3.0
AAVBNBH 3.0
AMNBNBH 3.0
AMXBNBH 3.0
AAVBNOH 3.0
AMNBNOH 3.0
AMXBNOH 3.0
HAVBRBH 3.0
HMNBRBH 3.0
HMXBRBH 3.0
HAVBROH 3.0
HMNBROH 3.0
HMXBROH 3.0
HAVBNBH 3.0
HMNBNBH 3.0
HMXBNBH 3.0
HAVBNOH 3.0
HMNBNOH 3.0
HMXBNOH 3.0
DAVBRBH 3.0
DMNBRBH 3.0
DMXBRBH 3.0
DAVBROH 3.0
DMNBROH 3.0
DMXBROH 3.0
DAVBNBH 3.0
DMNBNBH 3.0
DMXBNBH 3.0
DAVBNOH 3.0
DMNBNOH 3.0
DMXBNOH 3.0
NDES2PH 3.0
NDES3PH 3.0
NDES4PH 3.0
NDES5PH 3.0
PCTSA95H 8.2
PCTSA90H 8.2
PCTSA85H 8.2
PCTSA80H 8.2
PCTSA75H 8.2
PCTSA70H 8.2
AVSAO2RH 3.0
AVSAO2NH 3.0
MNSAO2RH 3.0
MNSAO2NH 3.0
MXSAO2RH 3.0
MXSAO2NH 3.0
REMEPBP 8.2
REMEPOP 8.2
NREMEPBP 8.2
NREMEPOP 8.2
ARTIFACT 8.2
LONGAP 8.2
LONGHYP 8.2
CAVGDUR 8.2
OAVGDUR 8.2
APAVGDUR 8.2
HAVGDUR 8.2
CTDUR 8.2
OTDUR 8.2
APTDUR 8.2
HTDUR 8.2
HRTDUR 8.2
CRTDURBP 8.2
AHRTDURBP 8.2
CRTDUROP 8.2
ORTDUROP 8.2
APRTDUROP 8.2
HRTDUROP 8.2
AHTDUROP 8.2
CNTDUR 8.2
ONTDUR 8.2
APNTDUR 8.2
HNTDUR 8.2
AHNTDUR 8.2
CNTDURBP 8.2
ONTDURBP 8.2
APNTDURBP 8.2
HNTDURBP 8.2
AHNTDURBP 8.2
CNTDUROP 8.2
ONTDUROP 8.2
HNTDUROP 8.2
AHNTDUROP 8.2
AVGSAOMINRPT 3.0
AVGSAOMINSLP 3.0
LOWSAOSLP 3.0
AVGSAOMINR 3.0
LOWSAOR 3.0
AVGDSSLP 3.0
AVGDSEVENT 3.0
PDB5SLP 8.2
PRDB5SLP 8.2
NORDB2 3.0
NORDB3 3.0
NODB4SLP 3.0
NORDB4 3.0
NODB5SLP 3.0
NORDB5 3.0
NORDBALL 3.0
MAXDBSLP 8.2
AVGDBSLP 8.2
MXHRAHSLP 3.0
MNHRAHSLP 3.0
AVGHRAHSLP 3.0
AVGPLM 8.2
AVGNPLM 8.2
AVGRPLM 8.2
NOPLM 8.2
AVGPLMWK 8.2
NOLLMSLP 8.2
NORLMSLP 8.2
NOBRSLP 3.0
NOBRAP 3.0
NOBRC 3.0
NOBRO 3.0
NOBRH 3.0
NOTCA 3.0
NOTCC 3.0
NOTCO 3.0
NOTCH 3.0
dsrem2 3.0
dsrem3 3.0
dsrem4 3.0
dsrem5 3.0
dsnr2 3.0
dsnr3 3.0
dsnr4 3.0
dsnr5 3.0
dssao90 3.0
avgsaominnr 3.0
lowsaonr 3.0
avgdsresp 3.0
sao92slp 8.2
sao92awk 8.2
sao90awk 8.2
saoslp 3.0
saorem 3.0
saonrem 3.0
saondoaslp 3.0
saondcaslp 3.0
saondrem 3.0
saondnrem 3.0
minsaondoaslp 3.0
minsaondcaslp 3.0
minsaondrem 3.0
minsaondnrem 3.0
lmslp 3.0
lmnrem 3.0
Lmstg1 3.0
Lmstg2 3.0
Lmdelta 3.0
Lmrem 3.0
lmtot 3.0
Lmaslp 3.0
Lmanrem 3.0
Lmastg1 3.0
Lmastg2 3.0
Lmadelta 3.0
Lmarem 3.0
Lma 3.0
Lmrslp 3.0
Lmrnrem 3.0
Lmrstg1 3.0
Lmrstg2 3.0
Lmrdelta 3.0
Lmrrem 3.0
lmr 3.0
lmarslp 3.0
Lmarnrem 3.0
Lmarstg1 3.0
Lmarstg2 3.0
Lmardelta 3.0
Lmarrem 3.0
Lmar 3.0
plmslp 3.0
plmnrem 3.0
pLmstg1 3.0
pLmstg2 3.0
pLmdelta 3.0
pLmrem 3.0
plmtot 3.0
pLmaslp 3.0
pLmanrem 3.0
pLmastg1 3.0
pLmastg2 3.0
pLmadelta 3.0
pLmarem 3.0
pLma 3.0
pLmrslp 3.0
pLmrnrem 3.0
pLmrstg1 3.0
pLmrstg2 3.0
pLmrdelta 3.0
pLmrrem 3.0
plmr 3.0
plmarslp 3.0
pLmarnrem 3.0
pLmarstg1 3.0
pLmarstg2 3.0
pLmardelta 3.0
pLmarrem 3.0
pLmar 3.0
PLMCslp 3.0
PLMCnrem 3.0
PLMCstg1 3.0
PLMCstg2 3.0
PLMCdelta 3.0
PLMCrem 3.0
PLMCtot 3.0
pLmCaslp 3.0
pLmCanrem 3.0
pLmCastg1 3.0
pLmCastg2 3.0
pLmCadelta 3.0
pLmCarem 3.0
pLmCa 3.0
pLmCrslp 3.0
pLmCrnrem 3.0
pLmCrstg1 3.0
pLmCrstg2 3.0
pLmCrdelta 3.0
pLmCrrem 3.0
plmCr 3.0
plmCarslp 3.0
pLmCarnrem 3.0
pLmCarstg1 3.0
pLmCarstg2 3.0
pLmCardelta 3.0
pLmCarrem 3.0
pLmCar 3.0
Urbp 3.0
Hurbp 8.2
Avurbp 3.0
Surbp 3.0
Lurbp 3.0
Urop 3.0
Hurop 8.2
Avurop 3.0
Surop 3.0
Lurop 3.0
Unrbp 3.0
Hunrbp 8.2
Avunrbp 3.0
Sunrbp 3.0
Lunrbp 3.0
unrop 3.0
Hunrop 8.2
Avunrop 3.0
Sunrop 3.0
lunrop 3.0
Urbpa 3.0
Hurbpa 8.2
Avurbpa 3.0
Surbpa 3.0
Lurbpa 3.0
Uropa 3.0
Huropa 8.2
Avuropa 3.0
Suropa 3.0
Luropa 3.0
Unrbpa 3.0
Hunrbpa 8.2
Avunrbpa 3.0
Sunrbpa 3.0
Lunrbpa 3.0
unropa 3.0
Hunropa 8.2
Avunropa 3.0
Sunropa 3.0
lunropa 3.0
Urbp2 3.0
Hurbp2 8.2
Avurbp2 3.0
Surbp2 3.0
Lurbp2 3.0
Urop2 3.0
Hurop2 8.2
Avurop2 3.0
Surop2 3.0
Lurop2 3.0
Unrbp2 3.0
Hunrbp2 8.2
Avunrbp2 3.0
Sunrbp2 3.0
Lunrbp2 3.0
unrop2 3.0
Hunrop2 8.2
Avunrop2 3.0
Sunrop2 3.0
lunrop2 3.0
Urbpa2 3.0
Hurbpa2 8.2
Avurbpa2 3.0
Surbpa2 3.0
Lurbpa2 3.0
Uropa2 3.0
Huropa2 8.2
Avuropa2 3.0
Suropa2 3.0
Luropa2 3.0
Unrbpa2 3.0
Hunrbpa2 8.2
Avunrbpa2 3.0
Sunrbpa2 3.0
Lunrbpa2 3.0
unropa2 3.0
Hunropa2 8.2
Avunropa2 3.0
Sunropa2 3.0
lunropa2 3.0
Urbp3 3.0
Hurbp3 8.2
Avurbp3 3.0
Surbp3 3.0
Lurbp3 3.0
Urop3 3.0
Hurop3 8.2
Avurop3 3.0
Surop3 3.0
Lurop3 3.0
Unrbp3 3.0
Hunrbp3 8.2
Avunrbp3 3.0
Sunrbp3 3.0
Lunrbp3 3.0
unrop3 3.0
Hunrop3 8.2
Avunrop3 3.0
Sunrop3 3.0
lunrop3 3.0
Urbpa3 3.0
Hurbpa3 8.2
Avurbpa3 3.0
Surbpa3 3.0
Lurbpa3 3.0
Uropa3 3.0
Huropa3 8.2
Avuropa3 3.0
Suropa3 3.0
Luropa3 3.0
Unrbpa3 3.0
Hunrbpa3 8.2
Avunrbpa3 3.0
Sunrbpa3 3.0
Lunrbpa3 3.0
unropa3 3.0
Hunropa3 8.2
Avunropa3 3.0
Sunropa3 3.0
lunropa3 3.0
Urbp4 3.0
Hurbp4 8.2
Avurbp4 3.0
Surbp4 3.0
Lurbp4 3.0
Urop4 3.0
Hurop4 8.2
Avurop4 3.0
Surop4 3.0
Lurop4 3.0
Unrbp4 3.0
Hunrbp4 8.2
Avunrbp4 3.0
Sunrbp4 3.0
Lunrbp4 3.0
unrop4 3.0
Hunrop4 8.2
Avunrop4 3.0
Sunrop4 3.0
lunrop4 3.0
Urbpa4 3.0
Hurbpa4 8.2
Avurbpa4 3.0
Surbpa4 3.0
Lurbpa4 3.0
Uropa4 3.0
Huropa4 8.2
Avuropa4 3.0
Suropa4 3.0
Luropa4 3.0
Unrbpa4 3.0
Hunrbpa4 8.2
Avunrbpa4 3.0
Sunrbpa4 3.0
Lunrbpa4 3.0
unropa4 3.0
Hunropa4 8.2
Avunropa4 3.0
Sunropa4 3.0
lunropa4 3.0
Urbp5 3.0
Hurbp5 8.2
Avurbp5 3.0
Surbp5 3.0
Lurbp5 3.0
Urop5 3.0
Hurop5 8.2
Avurop5 3.0
Surop5 3.0
Lurop5 3.0
Unrbp5 3.0
Hunrbp5 8.2
Avunrbp5 3.0
Sunrbp5 3.0
Lunrbp5 3.0
unrop5 3.0
Hunrop5 8.2
Avunrop5 3.0
Sunrop5 3.0
lunrop5 3.0
Urbpa5 3.0
Hurbpa5 8.2
Avurbpa5 3.0
Surbpa5 3.0
Lurbpa5 3.0
Uropa5 3.0
Huropa5 8.2
Avuropa5 3.0
Suropa5 3.0
Luropa5 3.0
Unrbpa5 3.0
Hunrbpa5 8.2
Avunrbpa5 3.0
Sunrbpa5 3.0
Lunrbpa5 3.0
unropa5 3.0
Hunropa5 8.2
Avunropa5 3.0
Sunropa5 3.0
lunropa5 3.0
rpt $20.
havestudy YESNOF.
inqs YESNOF.
waso 8.0
time_bed 8.0
slp_eff 8.2
timest1p 8.2
timest1 8.0
timest2p 8.2
timest2 8.0
times34p 8.2
timest34 8.0
timeremp 8.2
timerem 8.0
rem_lat1 8.0
supinep 8.2
nsupinep 8.2
ai_all 8.2
ai_rem 8.2
ai_nrem 8.2
rdi0p 8.2
rdi2p 8.2
rdi3p 8.2
rdi4p 8.2
rdi5p 8.2
rdi0pa 8.2
rdi2pa 8.2
rdi3pa 8.2
rdi4pa 8.2
rdi5pa 8.2
rdi0ps 8.2
rdi2ps 8.2
rdi3ps 8.2
rdi4ps 8.2
rdi5ps 8.2
rdi0pns 8.2
rdi2pns 8.2
rdi3pns 8.2
rdi4pns 8.2
rdi5pns 8.2
rdirem0p 8.2
rdirem2p 8.2
rdirem3p 8.2
rdirem4p 8.2
rdirem5p 8.2
rdinr0p 8.2
rdinr2p 8.2
rdinr3p 8.2
rdinr4p 8.2
rdinr5p 8.2
oahi4 8.2
oahi3 8.2
oai0p 8.2
oai4p 8.2
oai4pa 8.2
cai0p 8.2
cai4p 8.2
cai4pa 8.2
pctlt90 8.2
pctlt85 8.2
pctlt80 8.2
pctlt75 8.2
sao2rem 8.2
sao2nrem 8.2
losao2r 8.0
losao2nr 8.0
avgsat 8.2
minsat 8.0
;
run;
quit;
