***************************************************************************************;
* import blood data 2012-10-23.sas
*
* Created:		10/23/2012
* Last updated: 08/07/2013 * see notes
* Author:		Michael Cailler
*
***************************************************************************************;
* Purpose:
*	This program imports data from Ambulatory 24HR Blood Pressure reports for the
*		BestAIR study.
***************************************************************************************;
***************************************************************************************;
* NOTES:
*				08/07/2013 - Added comments. Updated by: Kevin Gleason
*
***************************************************************************************;

****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

****************************************************************************************;
*  REFORMAT BLOOD DATA AND EXPORT TO PERMANENT DATABASE
****************************************************************************************;

*import blood data from REDCap;
data blood_in;
	set bestair.baredcap(keep=elig_studyid bloods_studyid--bloods_urinecreatin);
run;

*delete missing observations;
proc sql;
	delete
	from work.blood_in
	where bloods_studyid = . or bloods_studyid = -9;
quit;

*set missing values (denoted in REDCap as -8 or -9) to null;
data blood_in;
	set blood_in;
	array blood_fixer[*] bloods_totalchol--bloods_urinecreatin;

	do i = 1 to dim(blood_fixer);
		if blood_fixer[i] < 0 then blood_fixer[i] = .;
	end;

	drop i;
run;

*export to pemanent dataset;
data bestair.bestairbloods bestair2.bestairbloods_&sasfiledate;
	set blood_in;
run;
