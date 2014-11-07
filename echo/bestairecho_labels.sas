proc datasets library=work nolist;
modify bestairecho;
label
ECHO_ID = 'Echo: BestAIR Patient Identifier'
SITE_ID = 'Site ID'
PATIENT_ID = 'Patient ID'
VISIT = 'Echo Visit'
OCCURRED_ON = 'Date of echo'
LVEDD = 'Parasternal long axis view: End-diastolic left ventricular diameter'
LVESD = 'Parasternal long axis view: End-systolic left ventricular diameter'
IVS = 'Parasternal long axis view: Interventricular septum thickness'
PW = 'Parasternal long axis view: Posterior wall thickness'
LVEDV = 'End-diastolic volume'
LVESV = 'End-systolic volume'
LVEF = 'Ejection fraction'
LVM = 'LV mass'
LVMI = 'LV mass index'
LAV = 'Left atrial volume'
LAVI = 'LA volume index'
EWAVE = 'Peak E wave velocity'
EEPRIMELAT = 'E/Em lateral ratio'
A4CRVEDA = 'Apical 4 chamber view: RV end diastolic area'
A4CRVESA = 'Apical 4 chamber view: RV end systolic area'
RVFAC = 'RV fractional area change'
TVSA = 'Tricuspid annular peak systolic myocardial velocity'
TRVEL = 'Peak tricuspid regurgitation velocity'
PVR = 'Pulmonary Vascular Resistance'
RVOTVTI = 'RVOT VTI'
PFO = 'Interatrial shunt: 1: Yes, 2: No, 99'
IASEP = 'Interatrial septum: 0: normal, 1: Hypermobile, 2: Aneurysmal,'
;

format
ECHO_ID $9.
SITE_ID BEST12.
PATIENT_ID $4.
VISIT BEST12.
OCCURRED_ON MMDDYY10.
LVEDD BEST12.
LVESD BEST12.
IVS BEST12.
PW BEST12.
LVEDV BEST12.
LVESV BEST12.
LVEF BEST12.
LVM BEST12.
LVMI BEST12.
LAV BEST12.
LAVI BEST12.
EWAVE BEST12.
EEPRIMELAT BEST12.
A4CRVEDA BEST12.
A4CRVESA BEST12.
RVFAC BEST12.
TVSA BEST12.
TRVEL BEST12.
PVR BEST12.
RVOTVTI BEST12.
PFO BEST12.
IASEP BEST12.
;
run;
quit;
