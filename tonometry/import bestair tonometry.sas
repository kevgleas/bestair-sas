****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";

***************************************************************************************;
* ESTABLISH TEMPORARY NETWORK DRIVE
***************************************************************************************;
x net use y: /d;
x net use y: "\\rfa01\BWH-SleepEpi-bestair\Data\Tonometry\Scored" /P:No;


***************************************************************************************;
* READ IN SCORED REPORTS FROM DCESLEEPSVR
***************************************************************************************;
	* get list of directories in scored folder;
	filename scored pipe 'dir y:\ /b';
	* within each directory, read in report file named s + foldername + .txt;
	data reportlist_pwv reportlist_pwa reportlist_error;
		length studyid timepoint 8.;
		infile scored truncover;
		input folder $30. ;

		studyid = input(substr(folder,1,5),5.);
		timepoint = input(substr(folder,10,2),5.);

		if timepoint > . and substr(folder,12,3) = 'PWV' then output reportlist_pwv;
		else if timepoint > . and substr(folder,12,3) = 'PWA' then output reportlist_pwa;
		else output reportlist_error;

	run;

	*format pwv data;
	data pwv;
		set reportlist_pwv;

		file2read = "y:\"||trim(left(folder))||"";
		infile pwvfile filevar=file2read end=done truncover firstobs=2 dlm='09'x dsd lrecl=512;
		do while(not done);

		informat date_of_birth $10. datetime $19. surname $upcase4.;

		input 	system_id $ database_id $ patient_number $ surname $ first_name $
						sex $ date_of_birth $ patient_id $ patient_code $ patient_notes $
						sp $ dp $ mp $ data_rev $ datetime age medication $ notes $
						operator $ interpretation height weight body_mass_index $
						sample_rate $ simulation_mode $ px_dist dt_dist pwv_dist
						pwv_disterr algorithm pheight_pc pp_mdt pp_deviation
						pwv pwverr ptt_sd serialnum a_subtype $ a_nof_10_sets
						a_hr a_mdt a_deviation_dt a_ton_qc_ph a_ton_qc_phv
						a_ton_qc_plv a_ton_qc_blv a_ecg_qc_ph a_ecg_qc_phv
						a_ecg_qc_plv a_ecg_qc_blv b_subtype $ b_nof_10_sets
						b_hr b_mdt b_deviation_dt b_ton_qc_ph b_ton_qc_phv
						b_ton_qc_plv b_ton_qc_blv b_ecg_qc_ph b_ecg_qc_phv
						b_ecg_qc_plv b_ecg_qc_blv
				;
			output;
		end;
	run;

	*format pwa data;
	data pwa;
		set reportlist_pwa;

		file2read = "y:\"||trim(left(folder))||"";
		infile pwafile filevar=file2read end=done truncover firstobs=2 dlm='09'x dsd lrecl=512;
		do while(not done);

		informat date_of_birth $10. datetime $19. surname $upcase4.;

		input 	system_id $ database_id $ patient_number $ surname $ first_name $
						sex $ date_of_birth $ patient_id $ patient_code $ patient_notes $
						sp $ dp $ mp $ data_rev $ datetime $ age medication $ notes $
						operator $ interpretation height weight body_mass_index $
						sample_rate $ simulation_mode $ serialnum sub_type $
						inconclusive $ reference_age ppampratio p_max_dpdt ed
						calc_ed quality_ed p_qc_ph p_qc_phv p_qc_plv p_qc_dv
						p_qc_sdev operator_index p_sp p_dp p_meanp p_t1
						p_t2 p_ai p_calct1 p_calct2 p_esp p_p1 p_p2
						p_t1ed p_t2ed p_quality_t1 p_quality_t2 c_ap c_ap_hr75
						c_mps c_mpd c_tti c_dti c_svi c_al c_ati hr
						c_period c_dd c_ed_period c_dd_period c_ph c_agph
						c_agph_hr75 c_p1_height c_t1r c_sp c_dp c_meanp c_t1
						c_t2 c_ai c_calct1 c_calct2 c_esp c_p1 c_p2 c_t1ed
						c_t2ed c_quality_t1 c_quality_t2
				;
			output;
		end;
	run;

	*merge pwa and pwv files;
	data batonometry;
		merge pwa (in=a) pwv (in=b);
		by studyid timepoint folder;
	run;

	*print low quality files;
	proc print data=batonometry noobs;
		var studyid timepoint operator_index;
		where . < operator_index < 80;
		title1 'Low Quality PWA Measurements';
		title2 '(Operator Index < 80)';
	run;

	*check for extreme values of ap or aix within pwa files;
	data batonometry_checkpwa batonometry_pwa_ap_err batonometry_pwa_aix_err;
		set batonometry;

		if age < 20 then category = 1; else if 29 >= age >= 20 then category = 2; else if 39 >= age >= 30 then category = 3; else if 49 >= age >= 40 then category = 4;
			else if 59 >= age >= 50 then category = 5; else if 69 >= age >= 60 then category = 6; else if 79 >= age >= 70 then category = 7; else if age > 79 then category = 8;

		if sex = "MALE" then gender = 1; else if sex = "FEMALE" then gender = 2;

		if substr(folder,12,3) = 'PWV' then delete;

		if operator_index < 80 then delete;

		if category = 1 and gender = 1 and (c_ap > 5 or c_ap < -7) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 2 and gender = 1 and (c_ap > 9 or c_ap < -7) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 3 and gender = 1 and (c_ap > 14 or c_ap < -6) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 4 and gender = 1 and (c_ap > 15 or c_ap < -1) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 5 and gender = 1 and (c_ap > 19 or c_ap < -1) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 6 and gender = 1 and (c_ap > 21 or c_ap < 1) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 7 and gender = 1 and (c_ap > 23 or c_ap < 3) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 8 and gender = 1 and (c_ap > 24 or c_ap < 4) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 1 and gender = 2 and (c_ap > 7 or c_ap < -5) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 2 and gender = 2 and (c_ap > 11 or c_ap < -5) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 3 and gender = 2 and (c_ap > 16 or c_ap < -4) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 4 and gender = 2 and (c_ap > 20 or c_ap < 0) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 5 and gender = 2 and (c_ap > 23 or c_ap < 3) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 6 and gender = 2 and (c_ap > 25 or c_ap < 5) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 7 and gender = 2 and (c_ap > 26 or c_ap < 6) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 8 and gender = 2 and (c_ap > 32 or c_ap < 4) then output batonometry_pwa_ap_err; else output batonometry_checkpwa;
		if category = 1 and gender = 1 and (c_agph > 14 or c_agph < -14) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 2 and gender = 1 and (c_agph > 24 or c_agph < -20) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 3 and gender = 1 and (c_agph > 38 or c_agph < -24) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 4 and gender = 1 and (c_agph > 39 or c_agph < -1) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 5 and gender = 1 and (c_agph > 44 or c_agph < 4) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 6 and gender = 1 and (c_agph > 46 or c_agph < 10) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 7 and gender = 1 and (c_agph > 48 or c_agph < 12) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 8 and gender = 1 and (c_agph > 50 or c_agph < 20) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 1 and gender = 2 and (c_agph > 25 or c_agph < -15) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 2 and gender = 2 and (c_agph > 37 or c_agph < -19) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 3 and gender = 2 and (c_agph > 44 or c_agph < -4) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 4 and gender = 2 and (c_agph > 48 or c_agph < 8) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 5 and gender = 2 and (c_agph > 51 or c_agph < 15) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 6 and gender = 2 and (c_agph > 52 or c_agph < 16) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 7 and gender = 2 and (c_agph > 53 or c_agph < 17) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		if category = 8 and gender = 2 and (c_agph > 55 or c_agph < 19) then output batonometry_pwa_aix_err; else output batonometry_checkpwa;
		drop px_dist--b_ecg_qc_blv;
	run;

	*eliminate duplicates for pwa;
	proc sort data = batonometry_checkpwa nodupkey;
		by studyid timepoint datetime;
	run;

	*check for extreme values of pwv;
	data batonometry_checkpwv;
		set batonometry;

		if sex = "MALE" then gender = 1; else if sex = "FEMALE" then gender = 2;

		if substr(folder,12,3) = 'PWA' then delete;

		if gender = 1 then pwv_calc = (-0.017 * age) + (0.001 * (age * age)) + 5.490; else if gender = 2 then pwv_calc = (-0.086 * age) + (0.002 * (age * age)) + 6.363;

		drop sub_type--c_quality_t2;
	run;

	*eliminate duplicates for pwv;
	proc sort data = batonometry_checkpwv nodupkey;
		by studyid timepoint datetime;
	run;

***************************************************************************************;
* disconnect network drive;
***************************************************************************************;
	x cd "c:\";
	x net use y: /delete ;


***************************************************************************************;
* IMPORT DATA OF MANUALLY ENTERED QC FORMS FROM REDCAP
***************************************************************************************;

	data redcap_tonom;
		set bestair.baredcap;

		if 60000 le elig_studyid le 99999 and qctonom_studyid > .;

	run;


	*delete unnecessary variables from bestair dataset and rename key variables to match BestAIR standard verbage;
	data alltonom_in;
		length elig_studyid timepoint 8.;
		set redcap_tonom (keep=elig_studyid redcap_event_name qctonom_studyid--tonometry_qc_complete);
		by elig_studyid;

		if redcap_event_name in ('00_bv_arm_1', '06_fu_arm_1', '12_fu_arm_1');

		if redcap_event_name = '00_bv_arm_1' then timepoint = 0;
		else if redcap_event_name = '06_fu_arm_1' then timepoint = 6;
		else if redcap_event_name = '12_fu_arm_1' then timepoint = 12;


		*rename unclear or confusing variables names from redcap to match variable names in later coding;
		rename qctonom_proximaldista2_50e = qctonom_proximaldistance4;
		rename qctonom_distaldistanc2_f1a = qctonom_distaldistance4;
		rename qctonom_qcnumbersred32_d69 = qctonom_qcnumbersred4;

		rename qctonom_aix3 = qctonom_augix3;
		rename qctonom_aix4 = qctonom_augix4;

		rename qctonom_comments7 = qctonom_comments8;
		rename qctonom_comments6 = qctonom_comments7;
		rename qctonom_comments5 = qctonom_comments6;
		rename qctonom_comments4 = qctonom_comments5;
		rename qctonom_comments3a = qctonom_comments4;


	run;

	*delete observations where no tonometry data was obtained;
	data tonom_in missingcheck_tonom;
		set alltonom_in;

		if qctonom_studyid = -9 then output missingcheck_tonom;
		if qctonom_studyid > 0 then output tonom_in;
		if qctonom_studyid > 0 and (qctonom_pwv1 < 0 or qctonom_pwv1 = . or qctonom_augix1 < 0 or qctonom_augix1 = .) then output missingcheck_tonom;

	run;


	data tonom_in;
		set tonom_in;
		rename elig_studyid = studyid;
	run;
/*
	*print tables listing study ids for observations missing PWA, PWV, both;
	proc sql;

		title 'Missing All Tonometry (REDCap) for Visit';
			select studyid, timepoint
			from tonom_in where qctonom_studyid < 0 or
								((qctonom_pwv1 = . or qctonom_pwv1<0) and (qctonom_augix1 = . or qctonom_augix1<0));
		title;

		title 'Missing PWV Only (REDCap) for Visit';
			select studyid, timepoint
			from tonom_in where	((qctonom_pwv1 = . or qctonom_pwv1<0) and (qctonom_augix1 ne . and qctonom_augix1>0))
								and qctonom_studyid > 0;
		title;

		title 'Missing PWA Only (REDCap) for Visit';
			select studyid, timepoint
			from tonom_in where ((qctonom_pwv1 ne . and qctonom_pwv1>0) and (qctonom_augix1 = . or qctonom_augix1<0))
								and qctonom_studyid > 0;
		title;


		title 'Unexpectedly Missing All Tonometry (REDCap) for Visit';
			select studyid, timepoint
			from tonom_in where qctonom_studyid > 0 and
								((qctonom_pwv1 = .) and (qctonom_augix1 = .));
		title;

		title 'Unexpectedly Missing PWV Only (REDCap) for Visit';
			select studyid, timepoint
			from tonom_in where qctonom_studyid > 0 and
								((qctonom_pwv1 = .) and (qctonom_augix1 ne .));
		title;

		title 'Unexpectedly Missing PWA Only (REDCap) for Visit';
			select studyid, timepoint
			from tonom_in where qctonom_studyid > 0 and
								((qctonom_pwv1 ne .) and (qctonom_augix1 = .));
		title;


	quit;

*/

***************************************************************************************;
* DATA CHECKING - CHECK DATA IN SPHYGMACOR FILES ON RFA AGAINST QC FORMS IN REDCAP
***************************************************************************************;


******;
* PWV
******;

	*create dataset of desired variables from sphygmacor observations to use for data checking;
	data pwv_sphyg_var;
		set pwv;


		*create variable to check against dates of measurements;
		format sphyg_date $10.;
		sphyg_date=datetime;

		keep studyid timepoint sphyg_date px_dist dt_dist pwv ptt_sd;

	run;

	*create dataset where each visit is its own observation with multiple pwv measurements;
	proc transpose data=pwv_sphyg_var out=pwv_sphyg_pwv prefix=sphyg_pwv;
		var pwv;
		by studyid timepoint;
	run;

	*create dataset where each visit is its own observation with multiple standard deviation measurements;
	proc transpose data=pwv_sphyg_var out=pwv_sphyg_std prefix=sphyg_stdpct;
		var ptt_sd;
		by studyid timepoint;
	run;

	*include date of sphygmacor measurement in dataset;
	proc transpose data = pwv_sphyg_var out=pwv_sphyg_dates prefix = sphyg_date;
		var sphyg_date;
		by studyid timepoint;
	run;

	*merge datasets for above sphymacor measurements for data checking;
	data pwv_sphyg_byvisit;
		merge  pwv_sphyg_dates pwv_sphyg_pwv pwv_sphyg_std;
		by studyid timepoint;

		rename sphyg_date1=sphyg_date;
		drop sphyg_date2--sphyg_date5 _NAME_;
	run;

	*merge sphygmacor data with redcap data, keeping key variables;
	data pwv_check;
		merge pwv_sphyg_byvisit tonom_in;
		by studyid timepoint;

		*set unobserved values of pwv equal to null for data checking;
		if (qctonom_pwv1 < 0)
			then qctonom_pwv1 = .;
		if (qctonom_pwv2 < 0)
			then qctonom_pwv2 = .;
		if (qctonom_pwv3 < 0)
			then qctonom_pwv3 = .;
		if (qctonom_pwv4 < 0)
			then qctonom_pwv4 = .;

		keep studyid timepoint qctonom_visitdate sphyg_date sphyg_pwv1--sphyg_stdpct4 qctonom_pwv1 qctonom_pwv2 qctonom_pwv3 qctonom_pwv4
				qctonom_standarddeviation1 qctonom_standarddeviation2 qctonom_standarddeviation3 qctonom_standarddeviation4;

	run;

	*print files possibly imported from wrong visit;
	data proper_import_check;
		set pwv_check;

		sphyg_datecheck = input(sphyg_date, ddmmyy10.);
		redcap_datecheck = qctonom_visitdate;
	run;

	proc sql;
		title 'PWV Sphygmacor Date does not match REDCap Date - Re-export';
			select studyid, timepoint from proper_import_check where redcap_datecheck ne sphyg_datecheck and
					(sphyg_datecheck ne . and redcap_datecheck ne .);
		title;
	quit;

	*create 2 datasets, one where sphygmacor pwv and redcap pwv match, one where they do not match;
	data pwv_match pwv_nomatch;
		set pwv_check;

		if (sphyg_pwv1 = qctonom_pwv1 and sphyg_pwv2 = qctonom_pwv2 and sphyg_pwv3 = qctonom_pwv3 and sphyg_pwv4 = qctonom_pwv4)
			then output pwv_match;
		else output pwv_nomatch;

	run;

	*create 3 datasets, one where sphymacor stdpct and redcap stdpct match, one where they do not match, one where redcap is missing data;
	data stdpct_match stdpct_nomatch stdpct_neverentered;
		set pwv_check;

		if (qctonom_pwv1 ne . and qctonom_standarddeviation1 = .)
			then output stdpct_neverentered;
		else if (abs(sphyg_stdpct1-qctonom_standarddeviation1) < .1 and abs(sphyg_stdpct2-qctonom_standarddeviation2) < .1 and
				abs(sphyg_stdpct3-qctonom_standarddeviation3) < .1 and abs(sphyg_stdpct4-qctonom_standarddeviation4) < .1)
			then output stdpct_match;
		else output stdpct_nomatch;

	run;

******;
* PWA
******;

	*create dataset of desired variables from sphygmacor observations to use for data checking;
	data pwa_sphyg_var;
		set pwa;

		*create variable to check against dates of measurements;
		format sphyg_date $10.;
		sphyg_date=datetime;

		keep studyid timepoint sphyg_date operator_index c_ap c_agph;

	run;

	*create dataset where each visit is its own observation with multiple operator indices;
	proc transpose data=pwa_sphyg_var out=pwa_sphyg_operix prefix=sphyg_operix;
		var operator_index;
		by studyid timepoint;
	run;

	*create dataset where each visit is its own observation with multiple augmentation index measurements;
	proc transpose data=pwa_sphyg_var out=pwa_sphyg_augix prefix=sphyg_augix;
		var c_agph;
		by studyid timepoint;
	run;

	*create dataset where each visit is its own observation with multiple augmentation pressure measurements;
	proc transpose data=pwa_sphyg_var out=pwa_sphyg_augpress prefix=sphyg_augpress;
		var c_ap;
		by studyid timepoint;
	run;

	*include date of sphygmacor measurement in dataset;
	proc transpose data = pwa_sphyg_var out=pwa_sphyg_dates prefix = sphyg_date;
		var sphyg_date;
		by studyid timepoint;
	run;

	*merge datasets for above sphymacor measurements for data checking;
	data pwa_sphyg_byvisit;
		merge pwa_sphyg_operix pwa_sphyg_augix pwa_sphyg_augpress pwa_sphyg_dates;
		by studyid timepoint;

		rename sphyg_date1=sphyg_date;
		drop sphyg_date2--sphyg_date5 _NAME_;
	run;

	*merge sphygmacor data with redcap data, keeping key variables;
	data pwa_check;
		merge pwa_sphyg_byvisit tonom_in;
		by studyid timepoint;

		*set unobserved values of operator index equal to null for data checking;
		if (qctonom_specifyoi1 < 0)
			then qctonom_specifyoi1 = .;
		if (qctonom_specifyoi2 < 0)
			then qctonom_specifyoi2 = .;
		if (qctonom_specifyoi3 < 0)
			then qctonom_specifyoi3 = .;
		if (qctonom_specifyoi4 < 0)
			then qctonom_specifyoi4 = .;

		*set unobserved values of augmentation index equal to null for data checking;
		if (qctonom_augix1 < 0)
			then qctonom_augix1 = .;
		if (qctonom_augix2 < 0)
			then qctonom_augix2 = .;
		if (qctonom_augix3 < 0)
			then qctonom_augix3 = .;
		if (qctonom_augix4 < 0)
			then qctonom_augix4 = .;

		*set unobserved values of augmentation pressure equal to null for data checking;
		if (qctonom_augpress1 < 0)
			then qctonom_augpress1 = .;
		if (qctonom_augpress2 < 0)
			then qctonom_augpress2 = .;
		if (qctonom_augpress3 < 0)
			then qctonom_augpress3 = .;
		if (qctonom_augpress4 < 0)
			then qctonom_augpress4 = .;


		keep studyid timepoint qctonom_visitdate sphyg_date sphyg_operix1--sphyg_augpress4 qctonom_specifyoi1 qctonom_specifyoi2
				qctonom_specifyoi3 qctonom_specifyoi4 qctonom_augix1 qctonom_augix2 qctonom_augix3 qctonom_augix4
				qctonom_augpress1 qctonom_augpress2 qctonom_augpress3 qctonom_augpress4;

	run;

	*create 2 datasets, one where sphygmacor operator index and redcap operator index match, one where they do not match;
	data operix_match operix_nomatch;
		set pwa_check;

		if (sphyg_operix1 = qctonom_specifyoi1 and sphyg_operix2 = qctonom_specifyoi2 and
				sphyg_operix3 = qctonom_specifyoi3 and sphyg_operix4 = qctonom_specifyoi4)
			then output operix_match;
		else output operix_nomatch;

	run;

	*create 2 datasets, one where sphygmacor augmentation index and redcap augmentation index match, one where they do not match;
	data augix_match augix_nomatch;
		set pwa_check;

		if (sphyg_augix1 = qctonom_augix1 and sphyg_augix2 = qctonom_augix2 and
				sphyg_augix3 = qctonom_augix3 and sphyg_augix4 = qctonom_augix4)
			then output augix_match;
		else output augix_nomatch;

	run;

	*create 2 datasets, one where sphygmacor augmentation pressure and redcap augmentation pressure match, one where they do not match;
	data augpress_match augpress_nomatch;
		set pwa_check;

		if (sphyg_augpress1 = qctonom_augpress1 and sphyg_augpress2 = qctonom_augpress2 and
				sphyg_augpress3 = qctonom_augpress3 and sphyg_augpress4 = qctonom_augpress4)
			then output augpress_match;
		else output augpress_nomatch;

	run;

	*print files possibly imported from wrong visit;
	data proper_import_check2;
		set pwa_check;

		sphyg_datecheck = input(sphyg_date, ddmmyy10.);
		redcap_datecheck = qctonom_visitdate;
	run;

	proc sql;
		title 'PWA Sphygmacor Date does not match REDCap Date - Re-export';
			select studyid, timepoint from proper_import_check2 where redcap_datecheck ne sphyg_datecheck and
					(sphyg_datecheck ne . and redcap_datecheck ne .);
		title;
	quit;

	*recombine pwa and pwv;
	data all_tonom;
		merge pwv_check pwa_check;
		by studyid timepoint;
	run;

	*print studyids where raw data is missing from server;
	proc sql;
		title 'Missing All Tonometry Raw Files from Visit';
			select studyid, timepoint from all_tonom where (qctonom_pwv1 > 0 and sphyg_pwv1 = .) and
					(qctonom_augix1 > 0 and sphyg_augix1 = .);
		title;

		title 'Missing PWV Raw Files from Visit';
			select studyid, timepoint from all_tonom where (qctonom_pwv1 > 0 and sphyg_pwv1 = .) and
					(sphyg_augix1 > 0 or (qctonom_augix1 = sphyg_augix1));
		title;

		title 'Missing PWA Raw Files from Visit';
			select studyid, timepoint from all_tonom where (qctonom_augix1 > 0 and sphyg_augix1 = .) and
					(sphyg_pwv1 > 0 or (qctonom_pwv1 = sphyg_pwv1));
		title;
	quit;


/*

***************************************************************************************;
* RUN BASIC STATISTICAL ANALYSIS
***************************************************************************************;
	*create data set for statistics of augmentation pressure for each subject and visit;
	proc means data = pwa;
		var c_ap;
		by studyid surname timepoint;
		output out=pwa_ap_stats mean = mean_aug_press std=std_aug_press min = min_aug_press max = max_aug_press;
	run;

	data pwa_ap_stats;
		set pwa_ap_stats;
		rename surname = namecode;
		rename _FREQ_ = n_measurements;
		drop _TYPE_;
	run;

	*create data set for statistics of augmentation index for each subject and visit;
	proc means data = pwa;
		var c_agph;
		by studyid surname timepoint;
		output out=pwa_aix_stats mean = mean_aug_ix std=std_aug_ix min = min_aug_ix max = max_aug_ix;
	run;

	data pwa_aix_stats;
		set pwa_aix_stats;
		rename surname = namecode;
		rename _FREQ_ = n_measurements;
		drop _TYPE_;
	run;

	*create data set for statistics of pulse pressure for each subject and visit;
	proc means data = pwa;
		var c_ph;
		by studyid surname timepoint;
		output out=pwa_pp_stats mean = mean_pulse_press std=std_pulse_press min = min_pulse_press max = max_pulse_press;
	run;

	data pwa_pp_stats;
		set pwa_pp_stats;
		rename surname = namecode;
		rename _FREQ_ = n_measurements;
		drop _TYPE_;
	run;

	*create data set for statistics of pulse wave velocity for each subject and visit;
	proc means data = pwv;
		var pwv;
		by studyid surname timepoint;
		output out=pwv_stats mean = mean_pwv std=std_pwv min = min_pwv max = max_pwv;
	run;

	data pwv_stats;
		set pwv_stats;
		rename surname = namecode;
		rename _FREQ_ = n_measurements;
		drop _TYPE_;
	run;


*;
*;
*Edited through here;
* Check labels for gender with Cailler
*;
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

