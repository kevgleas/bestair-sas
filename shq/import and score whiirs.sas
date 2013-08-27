***************************************************************************************;
*	ESTABLISH BESTAIR OPTIONS AND LIBRARIES
***************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

***************************************************************************************;
*	IMPORT DATA FROM REDCAP
***************************************************************************************;

	data shq_all;
		set bestair.baredcap;

		if (60000 le shq_studyid le 99999 or 60000 le shq_studyid6 le 99999);

		keep elig_studyid shq_studyid--sleephealth_question_v_3;
	run;

*create separate dataset for each visit;
	data redcapwhiirs_b;
		set shq_all (where=(shq_studyid ne .));
		shq_studyvisit = 0;
		whiirs_total = shq_trasleep + shq_wokeupsev + shq_wokeupearly + shq_trbacktosleep + shq_typnightsleep;
		keep elig_studyid shq_namecode shq_studyvisit shq_trasleep--shq_typnightsleep whiirs_total;
	run;
	data redcapwhiirs_6;
		set shq_all(where=(shq_studyvisit6=2));
		shq_studyvisit = 6;
		whiirs_total = shq_trasleep6 + shq_wokeupsev6 + shq_wokeupearly6 + shq_trbacktosleep6 + shq_typnightsleep6;
		keep elig_studyid shq_namecode6 shq_studyvisit shq_trasleep6--shq_typnightsleep6 whiirs_total;
	run;
	data redcapwhiirs_12;
		set shq_all(where=(shq_studyvisit6=3));
		shq_studyvisit = 12;
		whiirs_total = shq_trasleep6 + shq_wokeupsev6 + shq_wokeupearly6 + shq_trbacktosleep6 + shq_typnightsleep6;
		keep elig_studyid shq_namecode6 shq_studyvisit shq_trasleep6--shq_typnightsleep6 whiirs_total;
	run;

***************************************************************************************;
*	RECODE TO PROPER OPTIONS VALUES
***************************************************************************************;


	data redcapwhiirs_6a;
		set redcapwhiirs_6;
		array redcapwhiirs6 {6} shq_trasleep6--shq_typnightsleep6;
		array whiirs_6fix {6} shq_trasleep shq_wokeupsev shq_wokeupearly shq_trbacktosleep shq_trpills shq_typnightsleep;
		do i = 1 to 6;
			whiirs_6fix{i} = redcapwhiirs6{i};
			shq_namecode = shq_namecode6;
		end;
		drop shq_trasleep6--shq_typnightsleep6 shq_namecode6 i;
		retain elig_studyid shq_namecode shq_studyvisit shq_trasleep--shq_typnightsleep whiirs_total;
	run;


	data redcapwhiirs_12a;
		set redcapwhiirs_12;
		array redcapwhiirs6 {6} shq_trasleep6--shq_typnightsleep6;
		array whiirs_6fix {6} shq_trasleep shq_wokeupsev shq_wokeupearly shq_trbacktosleep shq_trpills shq_typnightsleep;
		do i = 1 to 6;
			whiirs_6fix{i} = redcapwhiirs6{i};
			shq_namecode = shq_namecode6;
		end;
		drop shq_trasleep6--shq_typnightsleep6 shq_namecode6 i;
		retain elig_studyid shq_namecode shq_studyvisit shq_trasleep--shq_typnightsleep whiirs_total;
	run;

***************************************************************************************;
*	MERGE DATASETS FROM STUDY VISITS
***************************************************************************************;

	data whiirs;
		merge redcapwhiirs_b(in=a) redcapwhiirs_6a(in=b) redcapwhiirs_12a(in=a);
		by elig_studyid shq_studyvisit;
		retain elig_studyid shq_namecode shq_studyvisit shq_trasleep--shq_typnightsleep whiirs_total;
	run;

************************************************;
*	UPDATE PERMANENT DATASETS
************************************************;

	data bestair.bestairwhiirs bestair2.bestairwhiirs_&sasfiledate;
		set whiirs;
	run;
