****************************************************************************************;
* Program title: complete check crfs.sas
*
* Created:		5/20/2013
* Last updated: 5/20/2013 * see notes
* Author:		Kevin Gleason
*
****************************************************************************************;
* Purpose:
*			Import crf data from REDCap and raw files from rfa server.
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


*designed to run as part of "complete check all.sas";
*if running independently, uncomment "IMPORT REDCAP DATA" step;

/*
****************************************************************************************;
* IMPORT REDCAP DATA
****************************************************************************************;

	data redcap;
		set bestair.baredcap;
	run;
*/



****************************************************************************************;
* PROCESS REDCAP DATA
****************************************************************************************;

	data crfs;
		set redcap;

		if redcap_event_name = "00_bv_arm_1" or redcap_event_name = "06_fu_arm_1" or redcap_event_name = "12_fu_arm_1";

		keep elig_studyid redcap_event_name anth_studyid--bloods_urinecreatin qctonom_studyid--monitorqc_percentsuccess;

		drop anth_namecode--anth_staffid anthropometry_complete bprp_namecode--bprp_staffid blood_pressure_and_r_v_0 bloods_namecode--bloods_studyvisit
				qctonom_namecode--qctonom_staffid tonometry_qc_complete monitorqc_namecode--monitorqc_datauploadreas;
		run;

	data crfs2;
		retain elig_studyid timepoint;
		set crfs;

		if redcap_event_name = "00_bv_arm_1" then timepoint = 00; else
		if redcap_event_name = "06_fu_arm_1" then timepoint = 06; else
		if redcap_event_name = "12_fu_arm_1" then timepoint = 12;
		else timepoint = .;

		drop redcap_event_name;

	run;


****************************************************************************************;
* IMPORT AND PROCESS RAW FILES FROM RFA SERVER
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\24hrbp\import BestAIR 24hr BP and compare to REDCap.sas";
%include "\\rfa01\bwh-sleepepi-bestair\data\sas\tonometry\import bestair tonometry.sas";

****************************************************************************************;
* CALCULATE NUMBER OF VISITS BY TYPE TO BE USED AS DENOMINATOR IN COMPLETENESS % CHECKS
****************************************************************************************;

	data bp4check (keep = elig_studyid timepoint nvalid pctvalid nreadings nwake nsleep);
		set mergebp;

		rename studyid = elig_studyid;
	run;

	data tonom4check (keep = elig_studyid timepoint sphyg_pwv1 sphyg_augix1);
		set all_tonom;
		rename studyid = elig_studyid;
	run;

	proc sort data = bp4check nodupkey;
		by elig_studyid timepoint;
	run;

	proc sort data = tonom4check nodupkey;
		by elig_studyid timepoint;
	run;

	proc sort data = crfs2 nodupkey;
		by elig_studyid timepoint;
	run;

	data crfs_withbptonom;
		merge crfs2 bp4check tonom4check;
		by elig_studyid timepoint;
	run;


	data visit_counts;
		set crfs_withbptonom;

		if (anth_studyid ne . or bprp_studyid ne . or bloods_studyid ne . or nreadings ne . or sphyg_pwv1 ne . or sphyg_augix1 ne .)
			then do;
				if timepoint = 00 then bl_allcount = 1;
				if timepoint = 06 then mo6_allcount = 1;
				if timepoint = 12 then mo12_allcount = 1;
			end;


		if (anth_studyid ne . and bprp_studyid ne .)
			then do;
				if timepoint = 00 then bl_crfcount = 1;
				if timepoint = 06 then mo6_crfcount = 1;
				if timepoint = 12 then mo12_crfcount = 1;
			end;

		if (bloods_studyid ne .)
			then do;
				if timepoint = 00 then bl_bloodcount = 1;
				if timepoint = 06 then mo6_bloodcount = 1;
				if timepoint = 12 then mo12_bloodcount = 1;
			end;

		if (nreadings ne . or monitorqc_studyid = -9)
			then do;
				if timepoint = 00 then bl_bpcount = 1;
				if timepoint = 06 then mo6_bpcount = 1;
				if timepoint = 12 then mo12_bpcount = 1;
			end;

		if (sphyg_pwv1 ne . or sphyg_augix1 ne . or qctonom_studyid = -9)
			then do;
				if timepoint = 00 then bl_tonomcount = 1;
				if timepoint = 06 then mo6_tonomcount = 1;
				if timepoint = 12 then mo12_tonomcount = 1;
			end;

		keep elig_studyid timepoint bl_allcount--mo12_tonomcount;

	run;


	proc means noprint data = visit_counts;
		output out = visit_countsums sum(bl_allcount) = bl_allcount sum(mo6_allcount) = mo6_allcount sum(mo12_allcount) = mo12_allcount
										sum(bl_crfcount) = bl_crfcount sum(mo6_crfcount) = mo6_crfcount sum(mo12_crfcount) = mo12_crfcount
										sum(bl_bloodcount) = bl_bloodcount sum(mo6_bloodcount) = mo6_bloodcount sum(mo12_bloodcount) = mo12_bloodcount
										sum(bl_bpcount) = bl_bpcount sum(mo6_bpcount) = mo6_bpcount sum(mo12_bpcount) = mo12_bpcount
										sum(bl_tonomcount) = bl_tonomcount sum(mo6_tonomcount) = mo6_tonomcount sum(mo12_tonomcount) = mo12_tonomcount;

	run;


	data bl_countsums (keep = timepoint visit_type allcount crfcount bloodcount bpcount tonomcount);
		retain visit_type timepoint;
		set visit_countsums;

		rename bl_allcount = allcount;
		rename bl_crfcount = crfcount;
		rename bl_bloodcount = bloodcount;
		rename bl_bpcount = bpcount;
		rename bl_tonomcount = tonomcount;

		timepoint = 00;
		visit_type = "Baseline";

	run;

	data mo6_countsums (keep = timepoint visit_type allcount crfcount bloodcount bpcount tonomcount);
		retain visit_type timepoint;
		set visit_countsums;

		rename mo6_allcount = allcount;
		rename mo6_crfcount = crfcount;
		rename mo6_bloodcount = bloodcount;
		rename mo6_bpcount = bpcount;
		rename mo6_tonomcount = tonomcount;

		timepoint = 06;
		visit_type = "6 Month";

	run;

	data mo12_countsums (keep = timepoint visit_type allcount crfcount bloodcount bpcount tonomcount);
		retain visit_type timepoint;
		set visit_countsums;

		rename mo12_allcount = allcount;
		rename mo12_crfcount = crfcount;
		rename mo12_bloodcount = bloodcount;
		rename mo12_bpcount = bpcount;
		rename mo12_tonomcount = tonomcount;

		timepoint = 12;
		visit_type = "12 Month";

	run;

	data countsums_byvisit;
		merge bl_countsums mo6_countsums mo12_countsums;
		by timepoint;
	run;



/*
	data crfs_baseall crfs_6all crfs_12all;
		set crfs2;

		if timepoint = 00 then output crfs_baseall; else
		if timepoint = 06 then output crfs_6all; else
		if timepoint = 12 then output crfs_12all;

	run;

	data crfs_basepending crfs_baseresolved;
		set crfs2;

		if (anth_studyid = . and bprp_studyid= .) and timepoint = 00
			then output crfs_basepending;
		else if timepoint = 00 then output crfs_baseresolved;

	run;

	data crfs_6pending crfs_6resolved;
		set crfs2;

		if (anth_studyid = . and bprp_studyid= .) and timepoint = 06
			then output crfs_6pending;
		else if timepoint = 06 then output crfs_6resolved;

	run;

	data crfs_12pending crfs_12resolved;
		set crfs2;

		if (anth_studyid = . and bprp_studyid= .) and timepoint = 12
			then output crfs_12pending;
		else if timepoint = 12 then output crfs_12resolved;

	run;
	*/

	data crfs_pending crfs_resolved bp_pending bp_resolved blood_pending blood_resolved tonom_pending tonom_resolved;
		set crfs_withbptonom;

		if (anth_studyid = . and bprp_studyid = .)
			then output crfs_pending;
		else if timepoint ne . then output crfs_resolved;

		if (bloods_studyid = .)
			then output blood_pending;
		else if timepoint ne . then output blood_resolved;

		if (nreadings ne . or monitorqc_studyid = -9)
			then output bp_resolved;
		else if timepoint ne . then output bp_pending;

		if (sphyg_pwv1 ne . or sphyg_augix1 ne . or qctonom_studyid = -9)
			then output tonom_resolved;
		else if timepoint ne . then output tonom_pending;

	run;

	*print study ids for participants REDCap denotes as pending;
	proc sql;
		title 'Visit Data Pending Entry';
			select elig_studyid, timepoint from crfs_pending;
		title;
	quit;



****************************************************************************************;
* CREATE DATASETS OF COMPLETENESS TABLES
****************************************************************************************;

*Calculate Completeness of 24-hour Ambulatory Blood Pressure;

	data bp_completeness;
		set bp_resolved;

		comp_bp = .;
		part_bp = .;
		miss_bp = .;

		if nsleep ge 4 and nwake ge 10 then
						do
						comp_bp = 1;
						part_bp = 1;
						miss_bp = 0;
						end;

		else if nsleep ge 1 or nwake ge 1 then
						do
						comp_bp = 0;
						part_bp = 1;
						miss_bp = 0;
						end;

		else
						do
						comp_bp = 0;
						part_bp = 0;
						miss_bp = 1;
						end;

	run;
*new section;
	data bp_completenesspartial (keep = elig_studyid timepoint monitorqc_20hrs--monitorqc_percentsuccess nreadings nvalid pctvalid nwake nsleep both_sleepwake);
		set bp_completeness;

		if comp_bp = 0 and part_bp = 1;

		if (nsleep ge 1 and nwake ge 1) then both_sleepwake = 1;
		else both_sleepwake = 0;

	run;

	proc sort data = bp_completenesspartial;
		by timepoint nsleep nwake;
	run;

	data bp_howcomplete (keep = elig_studyid timepoint monitorqc_20hrs--monitorqc_percentsuccess nreadings nvalid pctvalid nwake nsleep);
		set bp_completeness;
	run;


	data bp_comp00 bp_comp06 bp_comp12;
		set bp_completeness;
		if timepoint = 0 then output bp_comp00;
		if timepoint = 6 then output bp_comp06;
		if timepoint = 12 then output bp_comp12;
	run;


	proc means noprint data = bp_comp00;
		output out = bp_compstats00 sum(comp_bp) = comp_bp sum(part_bp) = part_bp sum(miss_bp) = miss_bp;
	run;

	data bp_compstats00 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set bp_compstats00;

		timepoint = 00;
		visit_type = "Baseline";

	run;


	proc means noprint data = bp_comp06;
		output out = bp_compstats06 sum(comp_bp) = comp_bp sum(part_bp) = part_bp sum(miss_bp) = miss_bp;
	run;

	data bp_compstats06 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set bp_compstats06;

		timepoint = 06;
		visit_type = "6 Month";

	run;

	proc means noprint data = bp_comp12;
		output out = bp_compstats12 sum(comp_bp) = comp_bp sum(part_bp) = part_bp sum(miss_bp) = miss_bp;
	run;

	data bp_compstats12 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set bp_compstats12;

		timepoint = 12;
		visit_type = "12 Month";

	run;


	data bp_compstats;
		merge bp_compstats00 bp_compstats06 bp_compstats12;
		by timepoint;

	run;

	data bp_compstatsall (drop = bloodcount crfcount tonomcount);
		merge bp_compstats countsums_byvisit;
		by timepoint;
	run;


	data bp_compstatsfinal;
		set bp_compstatsall;

		format pctcomp_bpall pctpart_bpall pctmiss_bpall pctcomp_bpresolved pctpart_bpresolved pctmiss_bpresolved percent10.1;


		pctcomp_bpall = comp_bp/allcount;
		pctpart_bpall = part_bp/allcount;
		pctmiss_bpall = miss_bp/allcount;

		pctcomp_bpresolved = comp_bp/bpcount;
		pctpart_bpresolved = part_bp/bpcount;
		pctmiss_bpresolved = miss_bp/bpcount;

	run;


*Calculate Completeness of Lab Data;

	data bloodurine_allresolved;
		set crfs_resolved;

		nmiss_blood = 0;
		nmiss_urine = 0;

		array checkblood[*] bloods_totalchol--bloods_serumgluc;

		do i=1 to dim(checkblood);
			if checkblood[i] < 0 or checkblood[i] = . then nmiss_blood = nmiss_blood + 1;
		end;

		array checkurine[*] bloods_fibrinactivity--bloods_urinecreatin;

		do i=1 to dim(checkurine);
			if checkurine[i] < 0 or checkurine[i] = . then nmiss_urine = nmiss_urine + 1;
		end;

		drop anth_studyid--bprp_rp3 qctonom_studyid--monitorqc_4readingsnight i;

	run;

	data blood_comp00 blood_comp06 blood_comp12;
		set bloodurine_allresolved;
		keep elig_studyid--bloods_urinecreatin nmiss_blood--pctmiss_urine;

		ncomp_blood = 9 - nmiss_blood;
		ncomp_urine = 2 - nmiss_urine;

		format pctcomp_blood pctcomp_urine pctmiss_blood pctmiss_urine percent10.1;

		pctcomp_blood = ((9-nmiss_blood)/9);
		pctcomp_urine = ((2-nmiss_urine)/2);
		pctmiss_blood = (nmiss_blood/9);
		pctmiss_urine = (nmiss_urine/2);


		if timepoint = 00 then output blood_comp00;
		if timepoint = 06 then output blood_comp06;
		if timepoint = 12 then output blood_comp12;

	run;


	proc means noprint data = blood_comp00;
		output out = blood_compstats00 sum(ncomp_blood) = ncomp_blood sum(ncomp_urine) = ncomp_urine sum(nmiss_blood) = nmiss_blood sum(nmiss_urine) = nmiss_urine;
	run;

	data blood_compstats00 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set blood_compstats00;

		visit_type = "Baseline";
		timepoint= 00;

	run;

	proc means noprint data = blood_comp06;
		output out = blood_compstats06 sum(ncomp_blood) = ncomp_blood sum(ncomp_urine) = ncomp_urine sum(nmiss_blood) = nmiss_blood sum(nmiss_urine) = nmiss_urine;
	run;

	data blood_compstats06 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set blood_compstats06;

		visit_type = "6 Month";
		timepoint= 06;

	run;

	proc means noprint data = blood_comp12;
		output out = blood_compstats12 sum(ncomp_blood) = ncomp_blood sum(ncomp_urine) = ncomp_urine sum(nmiss_blood) = nmiss_blood sum(nmiss_urine) = nmiss_urine;
	run;

	data blood_compstats12 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set blood_compstats12;

		visit_type = "12 Month";
		timepoint= 12;

	run;



	data blood_compstats;
		merge blood_compstats00 blood_compstats06 blood_compstats12;
		by timepoint;

	run;

	data blood_compstatsall (drop = bpcount crfcount tonomcount);
		merge blood_compstats countsums_byvisit;
		by timepoint;
	run;


	data blood_compstatsfinal;
		set blood_compstatsall;

		format pctcomp_bloodall pctcomp_urineall pctmiss_bloodall pctmiss_urineall pctcomp_bloodresolved pctcomp_urineresolved pctmiss_bloodresolved pctmiss_urineresolved percent10.1;


		pctcomp_bloodall = ncomp_blood/(9*allcount);
		pctcomp_urineall = ncomp_urine/(2*allcount);
		pctmiss_bloodall = nmiss_blood/(9*allcount);
		pctmiss_urineall = nmiss_urine/(2*allcount);

 *fix "crf count" so that it's only blood;
		pctcomp_bloodresolved = ncomp_blood/(9*bloodcount);
		pctcomp_urineresolved = ncomp_urine/(2*bloodcount);
		pctmiss_bloodresolved = nmiss_blood/(9*bloodcount);
		pctmiss_urineresolved = nmiss_urine/(2*bloodcount);

	run;



	proc sql;
		title "Missing Blood";
			select elig_studyid, timepoint from bloodurine_allresolved where nmiss_blood > 8;
		title;

		title "Missing Urine";
			select elig_studyid, timepoint from bloodurine_allresolved where nmiss_urine > 1;
		title;

	quit;

	data tonom_completeness;
		set tonom_resolved;

		pwa_comp = .;
		pwv_comp = .;

		if sphyg_pwv1 ne . and sphyg_augix1 ne . then
						do
						pwa_comp = 1;
						pwv_comp = 1;
						end;

		else if sphyg_pwv1 ne . then
						do
						pwa_comp = 0;
						pwv_comp = 1;
						end;

		else if sphyg_augix1 ne . then
						do
						pwa_comp = 1;
						pwv_comp = 0;
						end;

		else
						do
						pwa_comp = 0;
						pwv_comp = 0;
						end;

		drop anth_studyid--bloods_urinecreatin monitorqc_studyid--nwake;

	run;

	data tonom_comp00 tonom_comp06 tonom_comp12;
		set tonom_completeness;
		if timepoint = 0 then output tonom_comp00;
		if timepoint = 6 then output tonom_comp06;
		if timepoint = 12 then output tonom_comp12;
	run;

	proc means noprint data = tonom_comp00;
		output out = tonom_compstats00 sum(pwa_comp) = pwa_comp sum(pwv_comp) = pwv_comp;
	run;

	data tonom_compstats00 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set tonom_compstats00;

		timepoint = 00;
		visit_type = "Baseline";

	run;


	proc means noprint data = tonom_comp06;
		output out = tonom_compstats06 sum(pwa_comp) = pwa_comp sum(pwv_comp) = pwv_comp;
	run;

	data tonom_compstats06 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set tonom_compstats06;

		timepoint = 06;
		visit_type = "6 Month";

	run;

	proc means noprint data = tonom_comp12;
		output out = tonom_compstats12 sum(pwa_comp) = pwa_comp sum(pwv_comp) = pwv_comp;
	run;

	data tonom_compstats12 (drop = _type_ _freq_);
		retain visit_type timepoint;
		set tonom_compstats12;

		timepoint = 12;
		visit_type = "12 Month";

	run;


	data tonom_compstats;
		merge tonom_compstats00 tonom_compstats06 tonom_compstats12;
		by timepoint;

	run;

	data tonom_compstatsall (drop = bloodcount bpcount crfcount);
		merge tonom_compstats countsums_byvisit;
		by timepoint;
	run;


	data tonom_compstatsfinal;
		set tonom_compstatsall;

		format pctcomp_pwaall pctcomp_pwvall pctcomp_pwaresolved pctcomp_pwvresolved percent10.1;


		pctcomp_pwaall = pwa_comp/allcount;
		pctcomp_pwvall = pwv_comp/allcount;

		pctcomp_pwaresolved = pwa_comp/tonomcount;
		pctcomp_pwvresolved = pwv_comp/tonomcount;

	run;


	*echo count manually calculated because of delay in processing;
	*last counted 8/06/2013;

	data ultrasound_compstatsfinal;
		set tonom_compstatsfinal;

		format pctcomp_echoresolved percent10.1;

		if timepoint = 0 then do;
			echocount = 169;
			echo_comp = 155;	/*missing: 60678, 70245, 70335, 70337, 73088, 74068, 74404, 74567, 74721, 74756, 74772, 75063, 84319, 89191, 89565*/
			pctcomp_echoresolved = echo_comp / echocount;
			end;
		else if timepoint = 12 then do;
			echocount = 63;
			echo_comp = 58;		/*missing: 73068, 73119, 80024, 82444, 84175*/
			pctcomp_echoresolved = echo_comp / echocount;
			end;

	run;
