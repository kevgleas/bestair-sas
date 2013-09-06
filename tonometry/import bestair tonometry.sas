****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";

***************************************************************************************;
* IMPORT REDCAP DATASET OF RANDOMIZED PARTICIPANTS
***************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\redcap\_components\bestair create rand set.sas";

  *rename dataset of randomized participants to match syntax in later include steps;

  data redcap;
    set redcap_rand;
  run;

***************************************************************************************;
* CALL PROGRAM TO IMPORT RAW TONOMETRY FILES
***************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\tonometry\import bestair tonometry for update and check outcome variables.sas";


***************************************************************************************;
* PERFORM ADDITIONAL PROCESSING ON DATA BY CALLING ANOTHER SAS PROGRAM
***************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\tonometry\bestair tonometry data checking and stats.sas";

/*
*;
*Edited through here;
* Check labels for gender with Cailler
*;
*/

/*
******************************************************************************;
* Create Formats for the SASS Data Sets;
******************************************************************************;
* These formats will be stored in the permanent format library in sass_titration folder;
proc format library=sass;
	value genderf 	0="0: Female" 1="1: Male";
	value arteryf 	0="0: Radial"
					1="1: Carotid"
					2="2: Femoral";
	value yesnof 	1="1: Yes"	0="0: No";
	value ejdurf	0="0: Very Strong"
					1="1: Strong"
					2="2: Weak"
					3="3: Very Weak";
run;


******************************************************************************;
* Add Labels and Formats to the SAS Data Sets;
******************************************************************************;
data sass_pwa;
	set sass_pwa1;

	label
	Patient_Number	=	"PWA: Patient's Machine Assigned Number"
	Date_Of_Birth	=	"PWA: Patient's Date of Birth"
	studyid			=	"PWA: Entered StudyID Number (optional)"
	SP				=	"PWA: Entered Brachial Systolic Pressure (mmHg)"
	DP				=	"PWA: Entered Brachial Diastolic Pressure (mmHg)"
	OPERATOR		=	"PWA: Entered Operator ID (optional)"
	PPAmpRatio		=	"PWA: Pulse Pressure Amplification Ratio (%)"
	P_MAX_DPDT		=	"PWA: Peripheral Pulse Maximum dP/dT (max rise in slope of radial upstroke) (mmHg/ms)"
	ED1				=	"PWA: Ejection Duration 1 (ms)"
	QUALITY_ED		=	"PWA: Confidence Level of Ejection Duration (0-3 (0=very strong, 3= very weak))"
	P_QC_PH			=	"PWA: Peripheral Pulse Quality Control- Average Pulse Height (signal strenth (arbitrary units))"
	P_QC_PHV		=	"PWA: Peripheral Pulse Quality Control- Pulse Height Variation (degree of variability (unitless))"
	P_QC_PLV		=	"PWA: Peripheral Pulse Quality Control- Pulse Length Variation degree of variability (unitless))"
	P_QC_DV			=	"PWA: Peripheral Pulse Quality Control- Diastolic Variation degree of variability (unitless))"
	P_QC_SDEV		=	"PWA: Peripheral Pulse Quality Control- Shape Deviation degree of variability (unitless))"
	Operator_Index	=	"PWA: Calculated Operator Index (0-100)"
	P_SP			=	"PWA: Peripheral Systolic Pressure (mmHg)"
	P_DP			=	"PWA: Peripheral Diastolic Pressure (mmHg)"
	P_MEANP			=	"PWA: Peripheral Mean Pressure (mmHg)"
	P_T1			=	"PWA: Peripheral T1 (ms)"
	P_T2			=	"PWA: Peripheral T2 (ms)"
	P_AI			=	"PWA: Peripheral Augmentation Index (%)"
	ED2				=	"PWA: Ejection Duration 2 (different from 'CalcED' only if operator manually adjusts end of systole) (ms)"
	CalcED1			=	"PWA: Calculated Ejection Duration 1 (ms)"
	P_ESP			=	"PWA: Peripheral End Systolic Pressure (mmHg)"
	P_P1			=	"PWA: Peripheral P1 mmHg)"
	P_P2			=	"PWA: Peripheral P2 (mmHg)"
	P_T1ED			=	"PWA: Peripheral T1/ED (%)"
	P_T2ED			=	"PWA: Peripheral T2/Ed (%)"
	P_QUALITY_T1	=	"PWA: Peripheral Confidence Level of T1 (0-3 (0=very strong, 3= very weak))"
	P_QUALITY_T2	=	"PWA: Peripheral Confidence Level of T2 (0-3 (0=very strong, 3= very weak))"
	C_AP			=	"PWA: Central Augmentation Pressure (mmHg)"
	C_AP_HR75		=	"PWA: Central Augmentation Pressure @ HR 75 (mmHg)"
	C_MPS			=	"PWA: Central Mean Pressure of Systole (mmHg)"
	C_MPD			=	"PWA: Central Mean Pressure of Diastole (mmHg)"
	C_TTI			=	"PWA: Central Tension Time Index (area under curve during systole) (mmHg*ms)"
	C_DTI			=	"PWA: Central Diastolic Time Index (area under curve during diastole) (mmHg*ms)"
	C_SVI			=	"PWA: Central Subendocardial Viability Ratio (CDTI/CTTI) (%)"
	C_AL			=	"PWA: Central Augmentation Load (when augmentation >0)- extra work by heart because of wave reflection (%)"
	C_ATI			=	"PWA: Central Area of Augmentation (when augmentation >0)- area under the curve of augmentation (mmHg*ms)"
	HR				=	"PWA: Heart Rate (Beats/minute)"
	C_PERIOD		=	"PWA: Heart Rate Period (ms)"
	C_DD			=	"PWA: Central Diastolic Duration (ms)"
	C_ED_PERIOD		=	"PWA: Central ED/Period (%)"
	C_DD_PERIOD		=	"PWA: Diastolic Duration/Period (%)"
	C_PH			=	"PWA: Central Pulse Pressure (mmHg)"
	C_AGPH			=	"PWA: Central Augmentation Index (as percentage of Pulse Pressure) (%)"
	C_AGPH_HR75		=	"PWA: Central Augmentation Index @ HR 75bmp (as percentage of pulse pressure) (%)"
	C_P1_HEIGHT		=	"PWA: Central Pressure at T1-Dp (mmHg)"
	C_T1R			=	"PWA: Time of Start of the Reflected Wave (ms)"
	C_SP			=	"PWA: Central Systolic Pressure (mmHg)"
	C_DP			=	"PWA: Central Diastolic Pressure (mmHg)"
	C_MEANP			=	"PWA: Central Mean Pressure (mmHg)"
	pwadate  		=	"PWA: Date and Time of Measure ((day/month/year) time)"
	pwanamecode  	=	"PWA: Patient's Namecode"
	pwagender  		=	"PWA: Patient's Gender (Male=1)"
	artery 			=	"PWA: Artery Used for Measure"
	conclusive 		=	"PWA: Inconclusive Study"
	;

	format
	pwagender genderf.
	artery	arteryf.
	conclusive yesnof.
	quality_ed P_QUALITY_T1 P_QUALITY_T2 ejdurf.
	;
run;

*** Drop step unneccessary? ;

****************************************************************************************;
* Drop Data Check Variables;
****************************************************************************************;

	*there is not dataset pwa_merge - check what is supposed to be in pwa_merge;
	data pwa_merge1;
		set pwa_merge;

		drop pwaq_date techid pwanurse gender -- Patient_Number pwanamecode pwagender inqc indata;
	run;

*******************************************************************************************;
* SAVE PERMANENT DATASETS
*******************************************************************************************;
	data sass.PWAMerge sass2.PWAMerge_&date6;
		set pwa_merge1;
	run;

	*there is no dataset "pwa_abbrmeans" - check what this is supposed to do;
	data sass.PWAMergeAbbr sass2.PWAMergeAbbr_&date6;
		set pwa_abbrmeans;
	run;


*/

