****************************************************************************************;
* Program title: complete check all.sas
*
* Created:		5/20/13
* Last updated: 5/20/2013 * see notes
* Author:		Kevin Gleason
*
****************************************************************************************;
* Purpose:
*			Import relevant data from REDCap and the rfa server.
*				Run statistics regarding completeness percentages.
*
****************************************************************************************;
****************************************************************************************;
* NOTES:
*
*
****************************************************************************************;


****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";


****************************************************************************************;
* DATA CHECKING
****************************************************************************************;

*limit dataset to randomized participants only;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\redcap\_components\bestair create rand set.sas";

	*rename dataset of randomized participants to match syntax in later include steps;

	data redcap;
		set redcap_rand;
	run;


%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\complete check questionnaires.sas";
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\complete check crfs.sas";



proc sql;
ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\BestAIR Completeness &sasfiledate..PDF";

title "BestAIR 24-Hour Ambulatory Blood Pressure Completeness Percentages";
select visit_type as visit, pctpart_bpresolved as Including_Partial, pctcomp_bpresolved as Excluding_Partial
from work.bp_compstatsfinal;
title;

title "BestAIR Lab Results Completeness Percentages";
select visit_type as Visit, pctcomp_bloodresolved as Blood, pctcomp_urineresolved as Urine
from work.blood_compstatsfinal;
title;


title "BestAIR Ultrasound Completeness Percentages";
select visit_type as Visit, pctcomp_pwaresolved as Pulse_Wave_Analysis, pctcomp_pwvresolved as Pulse_Wave_Velocity, pctcomp_echoresolved as Echo
from work.ultrasound_compstatsfinal;
title;


title "BestAIR Questionnaire Completeness as Percentage of Completed Variables";
select visit_type as Visit, cal_comp as Calgary, phq_comp as PHQ_8, prom_comp as PROMIS, sarp_comp as SARP, semsa_comp as SEMSA, sf36_comp as SF_36, twpas_comp as TWPAS,
		allquestionnaire_comp as All_Questionnaires
from work.quest_compstatsfinal;
title;


ods pdf close;
quit;
