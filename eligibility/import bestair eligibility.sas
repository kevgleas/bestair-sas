****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";


***************************************************************************************;
* IMPORT BESTAIR ELIGIBILITY DATA FROM REDCAP
***************************************************************************************;

*import data from two different arms simultaneously to conserve computation time;
	data bestair_elig_info rand_set;
		set bestair.baredcap;

		if 60000 le elig_studyid le 99999 and redcap_event_name = "screening_arm_0"
			then output bestair_elig_info;

		if 60000 le elig_studyid le 99999 and rand_date > .
			then output rand_set;

		keep elig_studyid--eligibility_complete rand_date anth_namecode;
	run;

*prepare rand_set and bestaireligibility for merging by eliminating common variables to reduce likelihood of merge error;
	data rand_set;
		set rand_set;

		keep elig_studyid rand_date anth_namecode;
	run;

	data bestair_elig_info;
		set bestair_elig_info;

		drop rand_date anth_namecode;
	run;

*merge randomization information into eligibility dataset;
	data bestaireligibility;
		merge bestair_elig_info rand_set;

		by elig_studyid;

	run;


*****************************************************************************************;
* DATA CHECKING
*****************************************************************************************;

*create tables of randomized participants missing demographic info;

	proc sql;

		title "Randomized, Missing Age";
			select elig_studyid, anth_namecode from bestaireligibility where rand_date > . and (elig_incl01age < 1 or elig_incl01age = .);
			title;

		title "Randomized, Missing DOB";
			select elig_studyid, anth_namecode from bestaireligibility where (rand_date > . and elig_incl01dob = .);
			title;

		title "Randomized, Missing Gender";
			select elig_studyid, anth_namecode from bestaireligibility where rand_date > . and (elig_gender < 1 or elig_gender = .);
			title;

		title "Randomized, Missing Race";
			select elig_studyid, anth_namecode
			from bestaireligibility
			where rand_date > . and ((elig_raceamerind < 0 or elig_raceamerind = .) or (elig_raceasian < 0 or elig_raceasian = .) or (elig_racehawaiian < 0 or elig_racehawaiian = .)
										or (elig_raceblack < 0 or elig_raceblack = .) or (elig_racewhite < 0 or elig_racewhite = .) or (elig_raceother < 0 or elig_raceother = .));
			title;

		title "Randomized, Marked 'Other Race', No Race listed";
			select elig_studyid, anth_namecode from bestaireligibility where rand_date > . and (elig_raceother = 1 and (elig_raceotherspecify = '-8' or elig_raceotherspecify = '-9'
				or elig_raceotherspecify = '-10'));
			title;

		title "Randomized, Missing Ethnicity";
			select elig_studyid, anth_namecode from bestaireligibility where rand_date > . and (elig_ethnicity < 1 or elig_ethnicity = .);
			title;

		title "Randomized, Missing Education";
			select elig_studyid, anth_namecode from bestaireligibility where rand_date > . and (elig_education < 1 or elig_education = .);
			title;

	quit;

	data bestairreport;
		set bestaireligibility;

		if 70000 le elig_studyid le 79999 then site = 1;
		else if 80000 le elig_studyid le 89999 then site = 2;
		else site = 3;

		if elig_incl01agerange = 2 then elig_incl01agerange = 2;
		else elig_incl01agerange = .;

		if elig_incl02infconsent = 2 then elig_incl02infconsent = 2;
		else elig_incl02infconsent = .;

		if elig_incl03osa = 2 then elig_incl03osa = 2;
		else elig_incl03osa = .;

		if elig_incl04cvd = 2 then elig_incl04cvd = 2;
		else elig_incl04cvd = .;

		if elig_excl01ejec = 1 then elig_excl01ejec = 1;
		else elig_excl01ejec = .;

		if elig_excl02miproc = 1 then elig_excl02miproc = 1;
		else elig_excl02miproc = .;

		if elig_excl03poorhyper = 1 then elig_excl03poorhyper = 1;
		else elig_excl03poorhyper = .;

		if elig_excl04strokeimp = 1 then elig_excl04strokeimp = 1;
		else elig_excl04strokeimp = .;

		if elig_excl05medprob = 1 then elig_excl05medprob = 1;
		else elig_excl05medprob = .;

		if elig_excl06oxsat = 1 then elig_excl06oxsat = 1;
		else elig_excl06oxsat = .;

		if elig_excl07pap = 1 then elig_excl07pap = 1;
		else elig_excl07pap = .;

		if elig_excl08sixhrsbed = 1 then elig_excl08sixhrsbed = 1;
		else elig_excl08sixhrsbed = .;

		if elig_excl09epworth = 1 then elig_excl09epworth = 1;
		else elig_excl09epworth = .;

		if elig_excl10driver = 1 then elig_excl10driver = 1;
		else elig_excl10driver = .;

		if elig_excl11csa = 1 then elig_excl11csa = 1;
		else elig_excl11csa = .;

		if elig_excl12refusal = 1 then elig_excl12refusal = 1;
		else elig_excl12refusal = .;

		if elig_meetstatus = 1 then elig_meetstatus = 1;
		else elig_meetstatus = .;

		if elig_partstatus = 1 then elig_partstatusagree = 1;
		else elig_partstatusagree = .;

		if elig_partstatus = 2 then elig_partstatusdnagr = 1;
		else elig_partstatusdnagr = .;

		if elig_notinterested = 1 then elig_notinterested = 1;
		else elig_notinterested = .;

		if elig_toobusy = 1 then elig_toobusy = 1;
		else elig_toobusy = .;

		if elig_misswork = 1 then elig_misswork = 1;
		else elig_misswork = .;

		if elig_transportation = 1 then elig_transportation = 1;
		else elig_transportation = .;

		if elig_distance = 1 then elig_distance = 1;
		else elig_distance = .;

		if elig_extratests = 1 then elig_extratests = 1;
		else elig_extratests = .;

		if elig_passive = 1 then elig_passive = 1;
		else elig_passive = .;

		if elig_onlycpap = 1 then elig_onlycpap = 1;
		else elig_onlycpap = .;

		if elig_otherreason = 1 then elig_otherreason = 1;
		else elig_otherreason = .;

		if elig_physiciandoesnotgrant = 1 then elig_physiciandoesnotgrant = 1;
		else elig_physiciandoesnotgrant = .;

	run;

	*create table that sorts eligibility data by source and other criteria;
	proc sql;
		create table bestairreport_out (total smallint, inc01 smallint, inc02 smallint, inc03 smallint,
									inc04 smallint,
									exc01 smallint, exc02 smallint, exc03 smallint, exc04 smallint,
									exc05 smallint, exc06 smallint, exc07 smallint, exc08 smallint,
									exc09 smallint, exc10 smallint, exc11 smallint, exc12 smallint,
									meets smallint, agree smallint, dnagr smallint, dnres smallint, dnbus smallint,
									dnwrk smallint, dntra smallint, dndis smallint, dntst smallint,
									dnpas smallint, dnpap smallint, dnoth smallint, dnphy smallint);

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where 45 le elig_incl01age le 54;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where 55 le elig_incl01age le 75;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where site = 1;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where site = 2;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where elig_source = 1 and elig_meetstatus = 1;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where elig_source = 2 and elig_meetstatus = 1;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where elig_source = 3 and elig_meetstatus = 1;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where elig_source = 4 and elig_meetstatus = 1;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where elig_source = 5 and elig_meetstatus = 1;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where elig_source = 6 and elig_meetstatus = 1;

		insert into bestairreport_out (total, inc01, inc02, inc03, inc04, exc01,
									exc02, exc03, exc04, exc05, exc06, exc07, exc08, exc09, exc10,
									exc11, exc12, meets, agree, dnagr, dnres, dnbus, dnwrk, dntra, dndis,
									dntst, dnpas, dnpap, dnoth, dnphy)
		select 	count(elig_studyid) as total,
				count(elig_incl01agerange) as inc01,
				count(elig_incl02infconsent) as inc02,
				count(elig_incl03osa) as inc03,
				count(elig_incl04cvd) as inc04,
				count(elig_excl01ejec) as exc01,
				count(elig_excl02miproc) as exc02,
				count(elig_excl03poorhyper) as exc03,
				count(elig_excl04strokeimp) as exc04,
				count(elig_excl05medprob) as exc05,
				count(elig_excl06oxsat) as exc06,
				count(elig_excl07pap) as exc07,
				count(elig_excl08sixhrsbed) as exc08,
				count(elig_excl09epworth) as exc09,
				count(elig_excl10driver) as exc10,
				count(elig_excl11csa) as exc11,
				count(elig_excl12refusal) as exc12,
				count(elig_meetstatus) as meets,
				count(elig_partstatusagree) as agree,
				count(elig_partstatusdnagr) as dnagr,
				count(elig_notinterested) as dnres,
				count(elig_toobusy) as dnbus,
				count(elig_misswork) as dnwrk,
				count(elig_transportation) as dntra,
				count(elig_distance) as dndis,
				count(elig_extratests) as dntst,
				count(elig_passive) as dnpas,
				count(elig_onlycpap) as dnpap,
				count(elig_otherreason) as dnoth,
				count(elig_physiciandoesnotgrant) as dnphy
		from bestairreport
		where elig_meetstatus = 1;
	quit;


	* output table data into csv;
	PROC EXPORT DATA= bestairreport_out
	            OUTFILE= "\\rfa01\bwh-sleepepi-bestair\Data\SAS\eligibility\bestairreport_out_&sasfiledate..csv"
	            DBMS=CSV LABEL REPLACE;
	     PUTNAMES=YES;
	RUN;
