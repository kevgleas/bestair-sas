****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\Rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT AND PROCESS TONOMETRY DATA FROM REDCAP
****************************************************************************************;

	data tonometry_in;
		set bestair.baredcap;

		keep elig_studyid rand_siteid rand_treatmentarm qctonom_studyvisit qctonom_pwv1 qctonom_pwv2 qctonom_pwv3 qctonom_pwv4 qctonom_augix1 qctonom_augix2 qctonom_aix3 qctonom_aix4;
	run;


	proc sql;

		delete
			from work.tonometry_in
			where qctonom_studyvisit not in (0,6,12);

	quit;


	data tonometry_scrub;
		set tonometry_in;
		do;
		if qctonom_pwv1 = -9 or qctonom_pwv1 = -8 then qctonom_pwv1 = .;
		if qctonom_pwv2 = -9 or qctonom_pwv2 = -8 then qctonom_pwv2 = .;
		if qctonom_pwv3 = -9 or qctonom_pwv3 = -8 then qctonom_pwv3 = .;
		if qctonom_pwv4 = -9 or qctonom_pwv4 = -8 then qctonom_pwv4 = .;
		if qctonom_augix1 = -9 or qctonom_augix1 = -8 then qctonom_augix1 = .;
		if qctonom_augix2 = -9 or qctonom_augix2 = -8 then qctonom_augix2 = .;
		if qctonom_aix3 = -9 or qctonom_aix3 = -8 then qctonom_aix3 = .;
		if qctonom_aix4 = -9 or qctonom_aix4 = -8 then qctonom_aix4 = .;
		end;
	run;

	data tonometry;
		set tonometry_scrub;

		avgpwv = MEAN(qctonom_pwv1, qctonom_pwv2, qctonom_pwv3, qctonom_pwv4);
		avgaugix = MEAN(qctonom_augix1, qctonom_augix2, qctonom_aix3, qctonom_aix4);

	run;

****************************************************************************************;
* EXPORT TO PERMANENT DATASETS
****************************************************************************************;

	data bestair.bestairtonometry bestair2.bestairtonometry_&sasfiledate;
		set tonometry;
	run;
