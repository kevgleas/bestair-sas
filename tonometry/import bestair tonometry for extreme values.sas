****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

*import dataset of randomized participants;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\redcap\_components\bestair create rand set.sas";

  *create dataset by importing data from REDCap, where permanent data is stored;
  data redcap;
    set Redcap_rand;
  run;


****************************************************************************************;
*  DATA PROCESSING FOR TONOMETRY DATA
****************************************************************************************;

  *RESTRICT DATASET TO VISIT DATA ONLY;
	data redcap_visitsonly;
		set redcap;
		if redcap_event_name in("00_bv_arm_1", "06_fu_arm_1", "12_fu_arm_1");

		if redcap_event_name = "00_bv_arm_1" then timepoint = 0;
    else if redcap_event_name = "06_fu_arm_1" then timepoint = 6;
    else if redcap_event_name = "12_fu_arm_1" then timepoint = 12;
	run;

	*SELECT RELEVANT VARIABLES;
	data tonmdata;
		retain elig_studyid timepoint;
		set redcap_visitsonly; 
		keep elig_studyid timepoint qctonom_pwv1 qctonom_pwv2 qctonom_pwv3 qctonom_augix1 qctonom_augix2 qctonom_augpress1 qctonom_augpress2 qctonom_augpress3;
		if bprp_studyid > 0 and bprp_studyid ne .;
	run;
	
	*RECODE MISSING VARIABLES & CONVERT CHARACTER TO NUMERIC;
	data tonmmiss;
		set tonmdata;
		array old[3] qctonom_augpress1 qctonom_augpress2 qctonom_augpress3;
		array new[3] press1 press2 press3;
		do i = 1 to 3;
			new[i] = input(old[i],3.0);
		end;
		array miss[8] qctonom_pwv1--qctonom_pwv3 qctonom_augix1 qctonom_augix2 press1 press2 press3;
		do i = 1 to 8;
			if miss[i] < 0 then miss[i] = .;
		end;
		drop i;
	run;

  proc univariate data=tonmmiss noprint;
    var qctonom_pwv1 qctonom_pwv2 qctonom_pwv3 qctonom_augix1 qctonom_augix2 press1 press2 press3;
	  output out=extremes pctlpre=pwv1 pwv2 pwv3 ai1 ai2 ap1 ap2 ap3 pctlpts=1 99;
	run;


	*IDENTIFY EXTREME VALUES;
	ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\tonometry\Tonometry Extreme Values &sasfiledate..PDF";

	*PULSE WAVE VELOCITY;
	data pwv;
		set tonmmiss;
		array pwv[3] qctonom_pwv1 qctonom_pwv2 qctonom_pwv3;
		do i = 1 to 3;
			if pwv[i] NE . and pwv[i] < 2.0 OR pwv[i] > 16.9 then output;
		end;
		drop i;
	run;
	proc sort data=pwv nodup;
		by _all_;
	run;

	proc sql;
	  title "Instances Where Pulse Wave Velocity was in the 1st or 99th Percentile (<2.0 or >16.9)";
		title2 "Values That Have Not Been Checked";
	  select elig_studyid, timepoint, qctonom_pwv1, qctonom_pwv2, qctonom_pwv3
	  from pwv;
	quit;

	*AUGMENTATION INDEX;
	data ai;
		set tonmmiss;
		array ai[2] qctonom_augix1 qctonom_augix2;
		do i = 1 to 2;
			if ai[i] NE . and ai[i] < 6 OR ai[i] > 57 then output;
		end;
		drop i;
	run;
	proc sort data=ai nodup;
		by _all_;
	run;

	proc sql;
		title "Instances Where Augmentation Index was in the 1st or 99th Percentile (<6 or >57)";
		title2 "Values That Have Not Been Checked";
		select elig_studyid, timepoint, qctonom_augix1, qctonom_augix2
		from ai;
	quit;

	*AUGMENTATION PRESSURE;
	data ap;
		set tonmmiss;
		array ap[3] press1 press2 press3;
		do i = 1 to 3;
			if ap[i] NE . and ap[i] < 2 OR ap[i] > 100 then output;
		end;
		drop i;
	run;
	proc sort data=ap nodup;
		by _all_;
	run;

	proc sql;
		title "Instances Where Augmentation Pressure was in the 1st or 99th Percentile (<2 or >100)";
		title2 "Values That Have Not Been Checked";
		select elig_studyid, timepoint, press1, press2, press3
		from ap;
	quit;

	*PWV, AI, and AP;
	data combo;
		set tonmmiss;
		array pwv[3] qctonom_pwv1 qctonom_pwv2 qctonom_pwv3;
		do i = 1 to 3;
			if pwv[i] NE . and pwv[i] < 2.0 OR pwv[i] > 16.9 then output;
		end;
		array ai[2] qctonom_augix1 qctonom_augix2;
		do i = 1 to 2;
			if ai[i] NE . and ai[i] < 6 OR ai[i] > 57 then output;
		end;
		array ap[3] press1 press2 press3;
		do i = 1 to 3;
			if ap[i] NE . and ap[i] < 2 OR ap[i] > 100 then output;
		end;
		drop i;
	run;
	proc sort data=combo nodup;
		by _all_;
	run;

	proc sql;
		title "All Tonometry Extreme Values";
		title2 "Values That Have Not Been Checked";
		select elig_studyid, timepoint, qctonom_pwv1, qctonom_pwv2, qctonom_pwv3, qctonom_augix1, qctonom_augix2, press1, press2, press3
		from combo;
	quit;

	ods pdf close;
