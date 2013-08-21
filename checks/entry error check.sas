****************************************************************************************;
* Program title: entry error check.sas
*
* Created:		5/01/2013
* Last updated: 8/08/2013 * see notes
* Author:		Kevin Gleason
*
****************************************************************************************;
* Purpose:
*			Import data from REDCap and check for obvious data entry/collection errors.
*
****************************************************************************************;
****************************************************************************************;
* NOTES:
*
*			6/17/2013 - Added coding to check extreme values of anthropometry. - KG
*
*			8/08/2013 - Added checks for studyids, visitdates & timepoints. - KG
*
****************************************************************************************;


****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT REDCAP DATA and PREPARE DATASETS
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\redcap\_components\bestair create rand set.sas";

	*rename dataset of randomized participants to match syntax in later include steps;
	data redcap;
		set redcap_rand;
	run;

	data var_4checking;
		set redcap;

		keep elig_studyid redcap_event_name anth_studyid--anthropometry_complete bprp_studyid--blood_pressure_and_r_v_0
				bloods_studyid--blood_results_labcor_v_1 bpj_studyid--bp_journal_complete bplog_studyid--bp_log_complete cal_studyid--calgary_complete
				phq8_studyid--phq8_complete prom_studyid--promis_dcfc_complete sarp_studyid--sarp_complete semsa_studyid--semsa_complete sf36_studyid--sf36_bdfa_complete
				shq_studyid--shq_date qctonom_studyid--tonometry_qc_complete twpas_studyid--twpas_fabc_complete;

	run;

	*restrict dataset to research visits;
	data visits_only (drop = redcap_event_name);
		retain elig_studyid timepoint;
		set var_4checking;

		if redcap_event_name = "00_bv_arm_1" or redcap_event_name = "06_fu_arm_1" or redcap_event_name = "12_fu_arm_1";

		if redcap_event_name = "00_bv_arm_1" then timepoint = 00; else
		if redcap_event_name = "06_fu_arm_1" then timepoint = 06; else
		if redcap_event_name = "12_fu_arm_1" then timepoint = 12;


	run;

****************************************************************************************;
* CHECK FOR INSTANCES WHERE THERE MIGHT BE A DATA ENTRY ERROR
****************************************************************************************;

*********************************;
* check for misentered studyids;
*********************************;

	*transpose all studyids and merge into one dataset;

	proc transpose data = visits_only out = anthstudyids (drop = _NAME_ _LABEL_) prefix = anth_studyid;
		var anth_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bprpstudyids (drop = _NAME_ _LABEL_) prefix = bprp_studyid;
		var bprp_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bloodsstudyids (drop = _NAME_ _LABEL_) prefix = bloods_studyid;
		var bloods_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bpjstudyids (drop = _NAME_ _LABEL_) prefix = bpj_studyid;
		var bpj_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bplogstudyids (drop = _NAME_ _LABEL_) prefix = bplog_studyid;
		var bplog_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = calstudyids (drop = _NAME_ _LABEL_) prefix = cal_studyid;
		var cal_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = phq8studyids (drop = _NAME_ _LABEL_) prefix = phq8_studyid;
		var phq8_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = promstudyids (drop = _NAME_ _LABEL_) prefix = prom_studyid;
		var prom_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = sarpstudyids (drop = _NAME_ _LABEL_) prefix = sarp_studyid;
		var sarp_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = semsastudyids (drop = _NAME_ _LABEL_) prefix = semsa_studyid;
		var semsa_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = sf36studyids (drop = _NAME_ _LABEL_) prefix = sf36_studyid;
		var sf36_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = shqstudyids (drop = _NAME_ _LABEL_) prefix = shq_studyid;
		var shq_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = qctonomstudyids (drop = _NAME_ _LABEL_)prefix = qctonom_studyid;
		var qctonom_studyid;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = twpasstudyids (drop = _NAME_ _LABEL_) prefix = twpas_studyid;
		var twpas_studyid;
		by elig_studyid;
	quit;

	*merge studyid datasets and check for errors;
	data allstudyids studyid_errors;
		merge anthstudyids bprpstudyids bloodsstudyids bpjstudyids bplogstudyids calstudyids phq8studyids promstudyids sarpstudyids semsastudyids
					sf36studyids shqstudyids qctonomstudyids twpasstudyids;
		by elig_studyid;

		array si_checker[*] elig_studyid--twpas_studyid3;

		format var_error $32.;

		do i = 1 to dim(si_checker);
			if (si_checker[i] ne si_checker[1]) and si_checker[i] ne . and si_checker[i] ne -9
				then do;
						var_error = vname(si_checker[i]);
						output studyid_errors;
					end;
			else output allstudyids;
		end;

		drop i;

	run;



	proc sort data = allstudyids nodupkey;
		by elig_studyid;
	run;



*********************************;
* check for misentered namecodes;
*********************************;

	*transpose all namecodes and merge into one dataset;

	proc transpose data = visits_only out = anthnamecodes (drop = _NAME_ _LABEL_) prefix = anth_namecode;
		var anth_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bprpnamecodes (drop = _NAME_ _LABEL_) prefix = bprp_namecode;
		var bprp_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bloodsnamecodes (drop = _NAME_ _LABEL_) prefix = bloods_namecode;
		var bloods_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bpjnamecodes (drop = _NAME_ _LABEL_) prefix = bpj_namecode;
		var bpj_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = bplognamecodes (drop = _NAME_ _LABEL_) prefix = bplog_namecode;
		var bplog_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = calnamecodes (drop = _NAME_ _LABEL_) prefix = cal_namecode;
		var cal_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = phq8namecodes (drop = _NAME_ _LABEL_) prefix = phq8_namecode;
		var phq8_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = promnamecodes (drop = _NAME_ _LABEL_) prefix = prom_namecode;
		var prom_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = sarpnamecodes (drop = _NAME_ _LABEL_) prefix = sarp_namecode;
		var sarp_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = semsanamecodes (drop = _NAME_ _LABEL_) prefix = semsa_namecode;
		var semsa_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = sf36namecodes (drop = _NAME_ _LABEL_) prefix = sf36_namecode;
		var sf36_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = shqnamecodes (drop = _NAME_ _LABEL_) prefix = shq_namecode;
		var shq_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = qctonomnamecodes (drop = _NAME_ _LABEL_)prefix = qctonom_namecode;
		var qctonom_namecode;
		by elig_studyid;
	quit;

	proc transpose data = visits_only out = twpasnamecodes (drop = _NAME_ _LABEL_) prefix = twpas_namecode;
		var twpas_namecode;
		by elig_studyid;
	quit;

	*merge namecode datasets and check for errors;
	data allnamecodes namecode_errors;
		merge anthnamecodes bprpnamecodes bloodsnamecodes bpjnamecodes bplognamecodes calnamecodes phq8namecodes promnamecodes sarpnamecodes semsanamecodes
					sf36namecodes shqnamecodes qctonomnamecodes twpasnamecodes;
		by elig_studyid;

		array nc_checker[*] anth_namecode1--twpas_namecode3;

		format var_error $32.;

		if nc_checker[2] ne "" and ((nc_checker[2] = nc_checker[3]) or (nc_checker[2] = nc_checker[4])) and nc_checker[2] ne nc_checker[1]
			then do;
					var_error = vname(nc_checker[1]);
					output namecode_errors;
				end;
		else do i = 1 to dim(nc_checker);
			if upcase(nc_checker[i]) ne upcase(nc_checker[1]) and nc_checker[i] ne ""
				then do;
						var_error = vname(nc_checker[i]);
						output namecode_errors;
					end;
			else output allnamecodes;
		end;

		drop i;

	run;


	proc sort data = allnamecodes nodupkey;
		by elig_studyid;
	run;



**********************************;
* check for misentered visitdates;
**********************************;

	*sort visitdates into datasets sorted by visit;

	data baseline_dates;
		set visits_only;
		if timepoint = 0;
		keep elig_studyid timepoint anth_namecode anth_date bprp_visitdate bloods_datetest bplog_visitdate cal_datecompleted phq8_visitdate prom_visitdate sarp_visitdate semsa_visitdate
			sf36_visitdate shq_date qctonom_visitdate twpas_visitdate;
	run;

	data mo6_dates;
		set visits_only;
		if timepoint = 6;
		keep elig_studyid timepoint anth_namecode anth_date bprp_visitdate bloods_datetest bplog_visitdate cal_datecompleted phq8_visitdate prom_visitdate sarp_visitdate semsa_visitdate
			sf36_visitdate shq_date qctonom_visitdate twpas_visitdate;
	run;

	data mo12_dates;
		set visits_only;
		if timepoint = 12;
		keep elig_studyid timepoint anth_namecode anth_date bprp_visitdate bloods_datetest bplog_visitdate cal_datecompleted phq8_visitdate prom_visitdate sarp_visitdate semsa_visitdate
			sf36_visitdate shq_date qctonom_visitdate twpas_visitdate;
	run;


	*merge visitdate datasets and check for errors;
	data allvisitdates visitdate_errors;
		merge baseline_dates mo6_dates mo12_dates;
		by elig_studyid;

		array vd_checker[*] anth_date--twpas_visitdate;

		format var_error $32.;

		if vd_checker[2] ne . and ((vd_checker[2] = vd_checker[3]) or (vd_checker[2] = vd_checker[4])) and vd_checker[2] ne vd_checker[1]
			then do;
					var_error = vname(vd_checker[1]);
					output visitdate_errors;
				end;
		else do i = 1 to dim(vd_checker);
			if (vd_checker[i] ne vd_checker[1]) and vd_checker[i] ne .
				then do;
						var_error = vname(vd_checker[i]);
						output visitdate_errors;
					end;
			else output allvisitdates;
		end;

		drop i;

	run;

	proc sort data = allvisitdates nodupkey;
		by elig_studyid;
	run;

**********************************;
* check for misentered timepoints;
**********************************;

	*sort timepoints into datasets sorted by visit;

	data baseline_timepoints;
		set visits_only;
		if timepoint = 0;
		keep elig_studyid timepoint anth_namecode anth_studyvisit bprp_studyvisit bloods_studyvisit bplog_studyvisit cal_studyvisit phq8_studyvisit prom_studyvisit sarp_studyvisit
			semsa_studyvisit sf36_studyvisit qctonom_studyvisit twpas_studyvisit;
	run;

	data mo6_timepoints;
		set visits_only;
		if timepoint = 6;
		keep elig_studyid timepoint anth_namecode anth_studyvisit bprp_studyvisit bloods_studyvisit bplog_studyvisit cal_studyvisit phq8_studyvisit prom_studyvisit sarp_studyvisit
			semsa_studyvisit sf36_studyvisit qctonom_studyvisit twpas_studyvisit;
	run;

	data mo12_timepoints;
		set visits_only;
		if timepoint = 12;
		keep elig_studyid timepoint anth_namecode anth_studyvisit bprp_studyvisit bloods_studyvisit bplog_studyvisit cal_studyvisit phq8_studyvisit prom_studyvisit sarp_studyvisit
			semsa_studyvisit sf36_studyvisit qctonom_studyvisit twpas_studyvisit;
	run;


	*merge timepoint datasets and check for errors;
	data alltimepoints timepoint_errors;
		merge baseline_timepoints mo6_timepoints mo12_timepoints;
		by elig_studyid;

		array tp_checker[*] timepoint anth_studyvisit--twpas_studyvisit;

		format var_error $32.;

		do i = 1 to dim(tp_checker);
			if (tp_checker[i] ne tp_checker[1]) and tp_checker[i] ne .
				then do;
						var_error = vname(tp_checker[i]);
						output timepoint_errors;
					end;
			else output alltimepoints;
		end;

		drop i;

	run;

	proc sort data = alltimepoints nodupkey;
		by elig_studyid;
	run;

****************************************************************************************;
* CHECK FOR INSTANCES WHERE THERE MIGHT BE A DATA ENTRY OR COLLECTION ERROR
****************************************************************************************;

*ANTHROPOMETRY;

	*check for significant differences in height measurements;
	data anthheights00 anthheights12;
		set visits_only;
		if timepoint = 00 then output anthheights00; else
		if timepoint = 12 then output anthheights12;

		keep elig_studyid anth_heightcm1--anth_heightcm3;

	run;

	data anthheights12;
		set anthheights12;
		array htstore[3] anth_heightcm1--anth_heightcm3;
		array htwrite[3] anth_heightcm4-anth_heightcm6;

		do i = 1 to 3;
			htwrite[i] = htstore[i];
		end;

		keep elig_studyid anth_heightcm4--anth_heightcm6;

	run;

	data anthheights;
		merge anthheights00 anthheights12;
		by elig_studyid;
	run;

	data anthheights1;
		set anthheights;

		tallest_ht = max(anth_heightcm1, anth_heightcm2, anth_heightcm3, anth_heightcm4, anth_heightcm5, anth_heightcm6);
		big_htdiff = .;

		array allhts[6] anth_heightcm1--anth_heightcm6;

		do i = 1 to 6;
			if (allhts[i] ne . and allhts[i] ge 0) then do;
				if (tallest_ht - allhts[i]) ge 5 then big_htdiff = 1;
			end;
		end;

	run;



	proc sql;
	ods pdf file="\\rfa01\bwh-sleepepi-bestair\Data\SAS\checks\BestAIR Possible Entry or Collection Errors &sasfiledate..PDF";

	*DATA ENTRY;
		title 'Instances Where Study ID was Entered Incorrectly';
		select elig_studyid as StudyID, var_error as Mistake_Variable from studyid_errors;
		title;

		title 'Instances Where NameCode was Entered Incorrectly';
		select elig_studyid as StudyID, anth_namecode1 as Namecode, var_error as Mistake_Variable from namecode_errors;
		title;

		title 'Instances Where Visit Date was Possibly Entered Incorrectly';
		select elig_studyid as StudyID, anth_namecode as Namecode, timepoint, var_error as Mistake_Variable from visitdate_errors;
		title;

		title 'Instances Where Study Visit (Timepoint) was Entered Incorrectly';
		select elig_studyid as StudyID, anth_namecode as Namecode, timepoint, var_error as Mistake_Variable from timepoint_errors;
		title;


	*ANTHROPOMETRY;
		title 'Instances Where Anthro. Heights Differ by Greater than 5 cm';
		select elig_studyid from anthheights1 where big_htdiff = 1;
		title;

		title 'Instances Where Reported Anthro. Height is Less than 150 cm';
		select elig_studyid, timepoint from visits_only where (0 < anth_heightcm1 < 150) or (0 < anth_heightcm2 < 150) or (0 < anth_heightcm3 < 150);
		title;

		title 'Instances Where Reported Anthro. Weight is Less than 45 kg or Greater than 130 kg';
		select elig_studyid, timepoint from visits_only where ((0 < anth_weightkg < 45) or anth_weightkg > 130) and (
									elig_studyid ne 70179 and 	/*confirmed 6/19/2013 JL*/
									elig_studyid ne 80024 and 	/*confirmed 6/19/2013 JL*/
									elig_studyid ne 82545 		/*confirmed 6/19/2013 JL*/
									);
		title;

		title 'Instances Where Reported Neck Circumference is Less than 35 cm';
		select elig_studyid, timepoint from visits_only where (0 < anth_waistcm1 < 35) or (0 < anth_waistcm2 < 35) or (0 < anth_waistcm3 < 35);
		title;

		title 'Instances Where Reported Waist Circumference is Less than 70 cm';
		select elig_studyid, timepoint from visits_only where (0 < anth_waistcm1 < 70) or (0 < anth_waistcm2 < 70) or (0 < anth_waistcm3 < 70);
		title;

		title 'Instances Where Reported Hip Circumference is Less than 70 cm';
		select elig_studyid, timepoint from visits_only where (0 < anth_hipcm1 < 70) or (0 < anth_hipcm2 < 70) or (0 < anth_hipcm3 < 70);
		title;

	*BP AND RADIAL PULSE;
		title 'Instances Where Reported Resting BP Systolic is Less than 90 mm/hg or Greater than 180 mm/hg';
		select elig_studyid, timepoint from visits_only where (0 < bprp_bpsys1 < 90 or bprp_bpsys1 > 180 or 0 < bprp_bpsys2 < 90 or bprp_bpsys2 > 180
																or 0 < bprp_bpsys3 < 90 or bprp_bpsys3 > 180) and (
																(elig_studyid ne 70140 and timepoint = 12) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 70197 and timepoint = 6) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 71176 and timepoint = 12) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73068 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73101 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73122 and timepoint = 6) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73134 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73143 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73220 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73220 and timepoint = 6)	 	/* confirmed 08/16/2013 BO*/
																)
																;
		title;

		title 'Instances Where Reported Resting BP Diastolic is Less than 50 mm/hg or Greater than 110 mm/hg';
		select elig_studyid, timepoint from visits_only where (0 < bprp_bpdia1 < 50 or bprp_bpdia1 > 110 or 0 < bprp_bpdia2 < 50 or bprp_bpdia2 > 110
																or 0 < bprp_bpdia3 < 50 or bprp_bpdia3 > 110) and (
																(elig_studyid ne 71176 and timepoint = 12) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 72154 and timepoint = 6) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 72154 and timepoint = 12) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73101 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73143 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 73143 and timepoint = 6) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 80510 and timepoint = 6) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 80510 and timepoint = 12) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 82444 and timepoint = 6)	 	/* confirmed 08/16/2013 BO*/
																);
		title;


		title 'Instances Where Reported Resting BP Radial Pulse is Less than 40 BPM or Greater than 100 BPM';
		select elig_studyid, timepoint from visits_only where (0 < bprp_rp1 < 40 or bprp_rp1 > 100 or 0 < bprp_rp2 < 40 or bprp_rp2 > 100
																or 0 < bprp_rp3 < 40 or bprp_rp3 > 100) and (
																(elig_studyid ne 82286 and timepoint = 0) and 	/* confirmed 08/16/2013 BO*/
																(elig_studyid ne 90731 and timepoint = 0)		/* confirmed 08/16/2013 BO*/
																);
		title;



	ods pdf close;
	quit;
