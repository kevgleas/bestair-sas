***************************************************************************************;
* bestair endpoint completion flag.sas
*
* Created:		11/8/12
* Last updated:	8/07/13 * see notes
* Author:		Michael Cailler
*
***************************************************************************************;
* Purpose:
*	This program checks the completedness of endpoint measures for the BestAIR Trial
***************************************************************************************;
***************************************************************************************;
* NOTES:
*
*		08/07/2013 - Fixed minor compilation errors. Changed "-9" to null in flag variable
*					to match SAS standard for missing data. Updated by: Kevin Gleason
*
***************************************************************************************;

****************************************************************************************;
* Establish BestAIR libraries and options
****************************************************************************************;

%include "\\rfa01\bwh-sleepepi-bestair\data\sas\bestair options and libnames.sas";

data baredcap;
	set bestair.baredcap;
run;

*restrict observations to research visits;
proc sql;
	delete
	from baredcap
	where redcap_event_name = "screening_arm_0" or redcap_event_name = "02_pc_arm_1" or redcap_event_name = "04_pc_arm_1"
		or redcap_event_name = "08_pc_arm_1" or redcap_event_name = "10_pc_arm_1" or redcap_event_name = "99_us_arm_1";
quit;

*create baseline visit dataset;
data baseline;
	set baredcap(where=(redcap_event_name = "00_bv_arm_1"));

	keep elig_studyid redcap_event_name bloods_studyid--blood_results_labcor_v_1 cal_studyid--cal_ds05p phq8_studyid--phq8_complete sf36_studyid--sf36_bdfa_complete
		shq_sitread--shq_driving;
run;

*code variables for missing and not applicable data;
data codes1;
	set baseline;

	array calgary_array {56} cal_a01--cal_d21;
		do i = 1 to 56;
		if calgary_array{i} = -8 then calgary_array{i} = .n;
		else if calgary_array{i} = -9 then calgary_array{i} = .m;
		else if calgary_array{i} = -10 then calgary_array{i} = .c;
		end;
	array bloods_array {11} bloods_totalchol--bloods_urinecreatin;
		do k = 1 to 11;
		if bloods_array{k} = -8 then bloods_array{k} = .n;
		else if bloods_array{k} = -9 then bloods_array{k} = .m;
		else if bloods_array{k} = -10 then bloods_array{k} = .c;
		end;
	array phq_array {9} phq8_interest--phq8_total;
		do j = 1 to 9;
		if phq_array{j} = -8 then phq_array{j} = .n;
		else if phq_array{j} = -9 then phq_array{j} = .m;
		else if phq_array{j} = -10 then phq_array{j} = .c;
		end;
	array sf36_array {36} sf36_gh01--sf36_gh05;
		do l = 1 to 36;
		if sf36_array{l} = -8 then sf36_array{l} = .n;
		else if sf36_array{l} = -9 then sf36_array{l} = .m;
		else if sf36_array{l} = -10 then sf36_array{l} = .c;
		end;
	array ess_array {8} shq_sitread--shq_stoppedcar;
		do h = 1 to 8;
		if ess_array{h} = -8 then ess_array{h} = .n;
		else if ess_array{h} = -9 then ess_array{h} = .m;
		else if ess_array{h} = -10 then ess_array{h} = .c;
		if shq_driving = -9 then shq_driving = .m;
		else if shq_driving = -10 then shq_driving = .c;
		end;
	if bloods_totalchol > 0 and bloods_totalchol ne . and bloods_triglyc > 0 and bloods_triglyc ne . and bloods_hdlchol > 0 and bloods_hdlchol ne . and
		bloods_vldlcholcal > 0 and bloods_vldlcholcal ne . and bloods_ldlcholcalc > 0 and bloods_ldlcholcalc ne . and bloods_hemoa1c > 0 and bloods_hemoa1c ne . and
		bloods_creactivepro > 0 and bloods_creactivepro ne . and bloods_urinemicro > 0 and bloods_urinemicro ne . and bloods_serumgluc > 0 and bloods_serumgluc ne . and
		bloods_fibrinactivity > 0 and bloods_fibrinactivity ne . and bloods_urinecreatin > 0 and bloods_urinecreatin ne .
		then base_bloods = 1;
	else if  (bloods_totalchol < 0 or bloods_totalchol = .) and (bloods_triglyc < 0 or bloods_triglyc = .) and (bloods_hdlchol < 0 or bloods_hdlchol = .) and
		(bloods_vldlcholcal < 0 or bloods_vldlcholcal = .) and (bloods_ldlcholcalc < 0 or bloods_ldlcholcalc = .) and (bloods_hemoa1c < 0 or bloods_hemoa1c = .) and
		(bloods_creactivepro < 0 or bloods_creactivepro = .) and (bloods_urinemicro < 0 or bloods_urinemicro = .) and (bloods_serumgluc < 0 or bloods_serumgluc = .) and
		(bloods_fibrinactivity < 0 or bloods_fibrinactivity = .) and (bloods_urinecreatin < 0 or bloods_urinecreatin = .)
		then base_bloods = .;
	else if (bloods_totalchol < 0 or bloods_totalchol = . or bloods_triglyc < 0 or bloods_triglyc = . or bloods_hdlchol < 0 or bloods_hdlchol = . or
		bloods_vldlcholcal < 0 or bloods_vldlcholcal = . or bloods_ldlcholcalc < 0 or bloods_ldlcholcalc = . or bloods_hemoa1c < 0 or bloods_hemoa1c = . or
		bloods_creactivepro < 0 or bloods_creactivepro = . or bloods_urinemicro < 0 or bloods_urinemicro = . or bloods_serumgluc < 0 or bloods_serumgluc = . or
		bloods_fibrinactivity < 0 or bloods_fibrinactivity = . or bloods_urinecreatin < 0 or bloods_urinecreatin = .)
		then base_bloods = 0;
	if base_bloods = 0 then base_bloods_nmiss = nmiss(of bloods_totalchol--bloods_urinecreatin); else base_bloods_nmiss = 0;
	if cal_a01 > 0 and cal_a01 ne . and cal_a02 > 0 and cal_a02 ne . and cal_a03 > 0 and cal_a03 ne . and cal_a04 > 0 and cal_a04 ne . and cal_a05 > 0 and cal_a05 ne . and
		cal_a06 > 0 and cal_a06 ne . and cal_a07 > 0 and cal_a07 ne . and cal_a08 > 0 and cal_a08 ne . and cal_a09 > 0 and cal_a09 ne . and cal_a10 > 0 and cal_a10 ne . and
		cal_a11 > 0 and cal_a11 ne . and cal_b01 > 0 and cal_b01 ne . and cal_b02 > 0 and cal_b02 ne . and cal_b03 > 0 and cal_b03 ne . and cal_b04 > 0 and cal_b04 ne . and
		cal_b05 > 0 and cal_b05 ne . and cal_b06 > 0 and cal_b06 ne . and cal_b07 > 0 and cal_b07 ne . and cal_b08 > 0 and cal_b08 ne . and cal_b09 > 0 and cal_b09 ne . and
		cal_b10 > 0 and cal_b10 ne . and cal_b11 > 0 and cal_b11 ne . and cal_b12 > 0 and cal_b12 ne . and cal_b13 > 0 and cal_b13 ne . and cal_c01 > 0 and cal_c01 ne . and
		cal_c02 > 0 and cal_c02 ne . and cal_c03 > 0 and cal_c03 ne . and cal_c04 > 0 and cal_c04 ne . and cal_c05 > 0 and cal_c05 ne . and cal_c06 > 0 and cal_c06 ne . and
		cal_c07 > 0 and cal_c07 ne . and cal_c08 > 0 and cal_c08 ne . and cal_c09 > 0 and cal_c09 ne . and cal_c10 > 0 and cal_c10 ne . and cal_c11 > 0 and cal_c11 ne . and
		cal_d01 ge 0 and cal_d01 ne . and cal_d02 ge 0 and cal_d02 ne . and cal_d03 ge 0 and cal_d03 ne . and cal_d04 ge 0 and cal_d04 ne . and cal_d05 ge 0 and cal_d05 ne . and
		cal_d06 ge 0 and cal_d06 ne . and cal_d07 ge 0 and cal_d07 ne . and cal_d08 ge 0 and cal_d08 ne . and cal_d09 ge 0 and cal_d09 ne . and cal_d10 ge 0 and cal_d10 ne . and
		cal_d11 ge 0 and cal_d11 ne . and cal_d12 ge 0 and cal_d12 ne . and cal_d13 ge 0 and cal_d13 ne . and cal_d14 ge 0 and cal_d14 ne . and cal_d15 ge 0 and cal_d15 ne . and
		cal_d16 ge 0 and cal_d16 ne . and cal_d17 ge 0 and cal_d17 ne . and cal_d18 ge 0 and cal_d18 ne . and cal_d19 ge 0 and cal_d19 ne . and cal_d20 ge 0 and cal_d20 ne . and
		cal_d21 ge 0 and cal_d21 ne .
		then base_saqli = 1;
	else if (cal_a01 < 0 or cal_a01 = .) and (cal_a02 < 0 or cal_a02 = .) and (cal_a03 < 0 or cal_a03 = .) and (cal_a04 < 0 or cal_a04 = .) and (cal_a05 < 0 or cal_a05 = .) and
		(cal_a06 < 0 or cal_a06 = .) and (cal_a07 < 0 or cal_a07 = .) and (cal_a08 < 0 or cal_a08 = .) and (cal_a09 < 0 or cal_a09 = .) and (cal_a10 < 0 or cal_a10 = .) and
		(cal_a11 < 0 or cal_a11 = .) and (cal_b01 < 0 or cal_b01 = .) and (cal_b02 < 0 or cal_b02 = .) and (cal_b03 < 0 or cal_b03 = .) and (cal_b04 < 0 or cal_b04 = .) and
		(cal_b05 < 0 or cal_b05 = .) and (cal_b06 < 0 or cal_b06 = .) and (cal_b07 < 0 or cal_b07 = .) and (cal_b08 < 0 or cal_b08 = .) and (cal_b09 < 0 or cal_b09 = .) and
		(cal_b10 < 0 or cal_b10 = .) and (cal_b11 < 0 or cal_b11 = .) and (cal_b12 < 0 or cal_b12 = .) and (cal_b13 < 0 or cal_b13 = .) and (cal_c01 < 0 or cal_c01 = .) and
		(cal_c02 < 0 or cal_c02 = .) and (cal_c03 < 0 or cal_c03 = .) and (cal_c04 < 0 or cal_c04 = .) and (cal_c05 < 0 or cal_c05 = .) and (cal_c06 < 0 or cal_c06 = .) and
		(cal_c07 < 0 or cal_c07 = .) and (cal_c08 < 0 or cal_c08 = .) and (cal_c09 < 0 or cal_c09 = .) and (cal_c10 < 0 or cal_c10 = .) and (cal_c11 < 0 or cal_c11 = .) and
		(cal_d01 < 0 or cal_d01 = .) and (cal_d02 < 0 or cal_d02 = .) and (cal_d03 < 0 or cal_d03 = .) and (cal_d04 < 0 or cal_d04 = .) and (cal_d05 < 0 or cal_d05 = .) and
		(cal_d06 < 0 or cal_d06 = .) and (cal_d07 < 0 or cal_d07 = .) and (cal_d08 < 0 or cal_d08 = .) and (cal_d09 < 0 or cal_d09 = .) and (cal_d10 < 0 or cal_d10 = .) and
		(cal_d11 < 0 or cal_d11 = .) and (cal_d12 < 0 or cal_d12 = .) and (cal_d13 < 0 or cal_d13 = .) and (cal_d14 < 0 or cal_d14 = .) and (cal_d15 < 0 or cal_d15 = .) and
		(cal_d16 < 0 or cal_d16 = .) and (cal_d17 < 0 or cal_d17 = .) and (cal_d18 < 0 or cal_d18 = .) and (cal_d19 < 0 or cal_d19 = .) and (cal_d20 < 0 or cal_d20 = .) and
		(cal_d21 < 0 or cal_d21 = .)
		then base_saqli = .;
	else if (cal_a01 < 0 or cal_a01 = . or cal_a02 < 0 or cal_a02 = . or cal_a03 < 0 or cal_a03 = . or cal_a04 < 0 or cal_a04 = . or cal_a05 < 0 or cal_a05 = . or
		cal_a06 < 0 or cal_a06 = . or cal_a07 < 0 or cal_a07 = . or cal_a08 < 0 or cal_a08 = . or cal_a09 < 0 or cal_a09 = . or cal_a10 < 0 or cal_a10 = . or
		cal_a11 < 0 or cal_a11 = . or cal_b01 < 0 or cal_b01 = . or cal_b02 < 0 or cal_b02 = . or cal_b03 < 0 or cal_b03 = . or cal_b04 < 0 or cal_b04 = . or
		cal_b05 < 0 or cal_b05 = . or cal_b06 < 0 or cal_b06 = . or cal_b07 < 0 or cal_b07 = . or cal_b08 < 0 or cal_b08 = . or cal_b09 < 0 or cal_b09 = . or
		cal_b10 < 0 or cal_b10 = . or cal_b11 < 0 or cal_b11 = . or cal_b12 < 0 or cal_b12 = . or cal_b13 < 0 or cal_b13 = . or cal_c01 < 0 or cal_c01 = . or
		cal_c02 < 0 or cal_c02 = . or cal_c03 < 0 or cal_c03 = . or cal_c04 < 0 or cal_c04 = . or cal_c05 < 0 or cal_c05 = . or cal_c06 < 0 or cal_c06 = . or
		cal_c07 < 0 or cal_c07 = . or cal_c08 < 0 or cal_c08 = . or cal_c09 < 0 or cal_c09 = . or cal_c10 < 0 or cal_c10 = . or cal_c11 < 0 or cal_c11 = . or
		cal_d01 < 0 or cal_d01 = . or cal_d02 < 0 or cal_d02 = . or cal_d03 < 0 or cal_d03 = . or cal_d04 < 0 or cal_d04 = . or cal_d05 < 0 or cal_d05 = . or
		cal_d06 < 0 or cal_d06 = . or cal_d07 < 0 or cal_d07 = . or cal_d08 < 0 or cal_d08 = . or cal_d09 < 0 or cal_d09 = . or cal_d10 < 0 or cal_d10 = . or
		cal_d11 < 0 or cal_d11 = . or cal_d12 < 0 or cal_d12 = . or cal_d13 < 0 or cal_d13 = . or cal_d14 < 0 or cal_d14 = . or cal_d15 < 0 or cal_d15 = . or
		cal_d16 < 0 or cal_d16 = . or cal_d17 < 0 or cal_d17 = . or cal_d18 < 0 or cal_d18 = . or cal_d19 < 0 or cal_d19 = . or cal_d20 < 0 or cal_d20 = . or
		cal_d21 < 0 or cal_d21 = .)
		then base_saqli = 0;
	if base_saqli = 0 then base_saqli_nmiss = nmiss(of cal_a01--cal_d21); else base_saqli_nmiss = 0;
	if phq8_interest ge 0 and phq8_interest ne . and phq8_down_hopeless ge 0 and phq8_down_hopeless ne . and phq8_sleep ge 0 and phq8_sleep ne . and
		phq8_tired ge 0 and phq8_tired ne . and phq8_appetite ge 0 and phq8_appetite ne . and phq8_bad_failure ge 0 and phq8_bad_failure ne . and
		phq8_troubleconcentrating ge 0 and phq8_troubleconcentrating ne . and phq8_movingslowly ge 0 and phq8_movingslowly ne . and phq8_total ne .
		then base_phq = 1;
	else if (phq8_interest le 0 or phq8_interest = .) and (phq8_down_hopeless le 0 or phq8_down_hopeless = .) and (phq8_sleep le 0 or phq8_sleep = .) and
		(phq8_tired le 0 or phq8_tired = .) and (phq8_appetite le 0 or phq8_appetite = .) and (phq8_bad_failure le 0 or phq8_bad_failure = .) and
		(phq8_troubleconcentrating le 0 or phq8_troubleconcentrating = .) and (phq8_movingslowly le 0 or phq8_movingslowly = .) and (phq8_total le 0 or phq8_total = .)
		then base_phq = .;
	else if (phq8_interest le 0 or phq8_interest = . or phq8_down_hopeless le 0 or phq8_down_hopeless = . or phq8_sleep le 0 or phq8_sleep = . or
		phq8_tired le 0 or phq8_tired = . or phq8_appetite le 0 or phq8_appetite = . or phq8_bad_failure le 0 or phq8_bad_failure = . or
		phq8_troubleconcentrating le 0 or phq8_troubleconcentrating = . or phq8_movingslowly le 0 or phq8_movingslowly = . or phq8_total le 0 or phq8_total = .)
		then base_phq = 0;
	if base_phq = 0 then base_phq_nmiss = nmiss(of phq8_interest--phq8_total); else base_phq_nmiss = 0;
	if sf36_gh01 > 0 and sf36_gh01 ne . and sf36_gh02 > 0 and sf36_gh02 ne . and sf36_gh03 > 0 and sf36_gh03 ne . and sf36_gh04 > 0 and sf36_gh04 ne . and
		sf36_gh05 > 0 and sf36_gh05 ne . and sf36_pf01 > 0 and sf36_pf01 ne . and sf36_pf02 > 0 and sf36_pf02 ne . and sf36_pf03 > 0 and sf36_pf03 ne . and
		sf36_pf04 > 0 and sf36_pf04 ne . and sf36_pf05 > 0 and sf36_pf05 ne . and sf36_pf06 > 0 and sf36_pf06 ne . and sf36_pf07 > 0 and sf36_pf07 ne . and
		sf36_pf08 > 0 and sf36_pf08 ne . and sf36_pf09 > 0 and sf36_pf09 ne . and sf36_pf10 > 0 and sf36_pf10 ne . and sf36_rp01 > 0 and sf36_rp01 ne . and
		sf36_rp02 > 0 and sf36_rp02 ne . and sf36_rp03 > 0 and sf36_rp03 ne . and sf36_rp04 > 0 and sf36_rp04 ne . and sf36_re01 > 0 and sf36_re01 ne . and
		sf36_re02 > 0 and sf36_re02 ne . and sf36_re03 > 0 and sf36_re03 ne . and sf36_bp01 > 0 and sf36_bp01 ne . and sf36_bp02 > 0 and sf36_bp02 ne . and
		sf36_sf01 > 0 and sf36_sf01 ne . and sf36_sf02 > 0 and sf36_sf02 ne . and sf36_mh01 > 0 and sf36_mh01 ne . and sf36_mh02 > 0 and sf36_mh02 ne . and
		sf36_mh03 > 0 and sf36_mh03 ne . and sf36_mh04 > 0 and sf36_mh04 ne . and sf36_mh05 > 0 and sf36_mh05 ne . and sf36_sfht > 0 and sf36_sfht ne .
		then base_sf36 = 1;
	else if (sf36_gh01 < 0 or sf36_gh01 = .) and (sf36_gh02 < 0 or sf36_gh02 = .) and (sf36_gh03 < 0 or sf36_gh03 = .) and (sf36_gh04 < 0 or sf36_gh04 = .) and
		(sf36_gh05 < 0 or sf36_gh05 = .) and (sf36_pf01 < 0 or sf36_pf01 = .) and (sf36_pf02 < 0 or sf36_pf02 = .) and (sf36_pf03 < 0 or sf36_pf03 = .) and
		(sf36_pf04 < 0 or sf36_pf04 = .) and (sf36_pf05 < 0 or sf36_pf05 = .) and (sf36_pf06 < 0 or sf36_pf06 = .) and (sf36_pf07 < 0 or sf36_pf07 = .) and
		(sf36_pf08 < 0 or sf36_pf08 = .) and (sf36_pf09 < 0 or sf36_pf09 = .) and (sf36_pf10 < 0 or sf36_pf10 = .) and (sf36_rp01 < 0 or sf36_rp01 = .) and
		(sf36_rp02 < 0 or sf36_rp02 = .) and (sf36_rp03 < 0 or sf36_rp03 = .) and (sf36_rp04 < 0 or sf36_rp04 = .) and (sf36_re01 < 0 or sf36_re01 = .) and
		(sf36_re02 < 0 or sf36_re02 = .) and (sf36_re03 < 0 or sf36_re03 = .) and (sf36_bp01 < 0 or sf36_bp01 = .) and (sf36_bp02 < 0 or sf36_bp02 = .) and
		(sf36_sf01 < 0 or sf36_sf01 = .) and (sf36_sf02 < 0 or sf36_sf02 = .) and (sf36_mh01 < 0 or sf36_mh01 = .) and (sf36_mh02 < 0 or sf36_mh02 = .) and
		(sf36_mh03 < 0 or sf36_mh03 = .) and (sf36_mh04 < 0 or sf36_mh04 = .) and (sf36_mh05 < 0 or sf36_mh05 = .) and (sf36_sfht < 0 or sf36_sfht = .)
		then base_sf36 = .;
	else if (sf36_gh01 < 0 or sf36_gh01 = . or sf36_gh02 < 0 or sf36_gh02 = . or sf36_gh03 < 0 or sf36_gh03 = . or sf36_gh04 < 0 or sf36_gh04 = . or
		sf36_gh05 < 0 or sf36_gh05 = . or sf36_pf01 < 0 or sf36_pf01 = . or sf36_pf02 < 0 or sf36_pf02 = . or sf36_pf03 < 0 or sf36_pf03 = . or
		sf36_pf04 < 0 or sf36_pf04 = . or sf36_pf05 < 0 or sf36_pf05 = . or sf36_pf06 < 0 or sf36_pf06 = . or sf36_pf07 < 0 or sf36_pf07 = . or
		sf36_pf08 < 0 or sf36_pf08 = . or sf36_pf09 < 0 or sf36_pf09 = . or sf36_pf10 < 0 or sf36_pf10 = . or sf36_rp01 < 0 or sf36_rp01 = . or
		sf36_rp02 < 0 or sf36_rp02 = . or sf36_rp03 < 0 or sf36_rp03 = . or sf36_rp04 < 0 or sf36_rp04 = . or sf36_re01 < 0 or sf36_re01 = . or
		sf36_re02 < 0 or sf36_re02 = . or sf36_re03 < 0 or sf36_re03 = . or sf36_bp01 < 0 or sf36_bp01 = . or sf36_bp02 < 0 or sf36_bp02 = . or
		sf36_sf01 < 0 or sf36_sf01 = . or sf36_sf02 < 0 or sf36_sf02 = . or sf36_mh01 < 0 or sf36_mh01 = . or sf36_mh02 < 0 or sf36_mh02 = . or
		sf36_mh03 < 0 or sf36_mh03 = . or sf36_mh04 < 0 or sf36_mh04 = . or sf36_mh05 < 0 or sf36_mh05 = . or sf36_sfht < 0 or sf36_sfht = .)
		then base_sf36 = 0;
	if base_sf36 = 0 then base_sf36_nmiss = nmiss(of sf36_gh01--sf36_gh05); else base_sf36_nmiss = 0;
	if shq_sitread ge 0 and shq_sitread ne . and shq_watchingtv ge 0 and shq_watchingtv ne . and shq_sitinactive ge 0 and shq_sitinactive ne . and
		shq_ridingforhour ge 0 and shq_ridingforhour ne . and shq_lyingdown ge 0 and shq_lyingdown ne . and shq_sittalk ge 0 and shq_sittalk ne . and
		shq_afterlunch ge 0 and shq_afterlunch ne . and shq_stoppedcar ge 0 and shq_stoppedcar ne . and (shq_driving ge 0 or shq_driving = -8) and shq_driving ne .
		then base_ess = 1;
	else if (shq_sitread < 0 or shq_sitread = .) and (shq_watchingtv < 0 or shq_watchingtv = .) and (shq_sitinactive < 0 or shq_sitinactive = .) and
		(shq_ridingforhour < 0 or shq_ridingforhour = .) and (shq_lyingdown < 0 or shq_lyingdown = .) and (shq_sittalk < 0 or shq_sittalk = .) and
		(shq_afterlunch < 0 or shq_afterlunch = .) and (shq_stoppedcar < 0 or shq_stoppedcar = .) and shq_driving = .
		then base_ess = .;
	else if (shq_sitread < 0 or shq_sitread = . or shq_watchingtv < 0 or shq_watchingtv = . or shq_sitinactive < 0 or shq_sitinactive = . or
		shq_ridingforhour < 0 or shq_ridingforhour = . or shq_lyingdown < 0 or shq_lyingdown = . or shq_sittalk < 0 or shq_sittalk = . or
		shq_afterlunch < 0 or shq_afterlunch = . or shq_stoppedcar < 0 or shq_stoppedcar = . or shq_driving = .)
		then base_ess = 0;
	if base_ess = 0 then base_ess_nmiss = nmiss(of shq_sitread--shq_driving); else base_ess_nmiss = 0;
run;

*create 6-month follow-up visit dataset;
data m6;
	set baredcap(where=(redcap_event_name = "06_fu_arm_1"));

	keep elig_studyid redcap_event_name bloods_studyid--blood_results_labcor_v_1 cal_studyid--cal_e26 cal_f01 cal_f02 phq8_studyid--phq8_complete sf36_studyid--sf36_bdfa_complete
		shq_sitread6--shq_driving6;
run;

*code variables for missing and not applicable data;
data codes2;
	set m6;

	array calgary_array {84} cal_a01--cal_d21 cal_e01--cal_e26 cal_f01 cal_f02;
		do i = 1 to 84;
		if calgary_array{i} = -8 then calgary_array{i} = .n;
		else if calgary_array{i} = -9 then calgary_array{i} = .m;
		else if calgary_array{i} = -10 then calgary_array{i} = .c;
		end;
	array bloods_array {11} bloods_totalchol--bloods_urinecreatin;
		do k = 1 to 11;
		if bloods_array{k} = -8 then bloods_array{k} = .n;
		else if bloods_array{k} = -9 then bloods_array{k} = .m;
		else if bloods_array{k} = -10 then bloods_array{k} = .c;
		end;
	array phq_array {9} phq8_interest--phq8_total;
		do j = 1 to 9;
		if phq_array{j} = -8 then phq_array{j} = .n;
		else if phq_array{j} = -9 then phq_array{j} = .m;
		else if phq_array{j} = -10 then phq_array{j} = .c;
		end;
	array sf36_array {36} sf36_gh01--sf36_gh05;
		do l = 1 to 36;
		if sf36_array{l} = -8 then sf36_array{l} = .n;
		else if sf36_array{l} = -9 then sf36_array{l} = .m;
		else if sf36_array{l} = -10 then sf36_array{l} = .c;
		end;
	array ess_array {8} shq_sitread6--shq_stoppedcar6;
		do h = 1 to 8;
		if ess_array{h} = -8 then ess_array{h} = .n;
		else if ess_array{h} = -9 then ess_array{h} = .m;
		else if ess_array{h} = -10 then ess_array{h} = .c;
		if shq_driving6 = -9 then shq_driving6 = .m;
		else if shq_driving6 = -10 then shq_driving6 = .c;
		end;
	if bloods_totalchol > 0 and bloods_totalchol ne . and bloods_triglyc > 0 and bloods_triglyc ne . and bloods_hdlchol > 0 and bloods_hdlchol ne . and
		bloods_vldlcholcal > 0 and bloods_vldlcholcal ne . and bloods_ldlcholcalc > 0 and bloods_ldlcholcalc ne . and bloods_hemoa1c > 0 and bloods_hemoa1c ne . and
		bloods_creactivepro > 0 and bloods_creactivepro ne . and bloods_urinemicro > 0 and bloods_urinemicro ne . and bloods_serumgluc > 0 and bloods_serumgluc ne . and
		bloods_fibrinactivity > 0 and bloods_fibrinactivity ne . and bloods_urinecreatin > 0 and bloods_urinecreatin ne .
		then m6_bloods = 1;
	else if  (bloods_totalchol < 0 or bloods_totalchol = .) and (bloods_triglyc < 0 or bloods_triglyc = .) and (bloods_hdlchol < 0 or bloods_hdlchol = .) and
		(bloods_vldlcholcal < 0 or bloods_vldlcholcal = .) and (bloods_ldlcholcalc < 0 or bloods_ldlcholcalc = .) and (bloods_hemoa1c < 0 or bloods_hemoa1c = .) and
		(bloods_creactivepro < 0 or bloods_creactivepro = .) and (bloods_urinemicro < 0 or bloods_urinemicro = .) and (bloods_serumgluc < 0 or bloods_serumgluc = .) and
		(bloods_fibrinactivity < 0 or bloods_fibrinactivity = .) and (bloods_urinecreatin < 0 or bloods_urinecreatin = .)
		then m6_bloods = .;
	else if (bloods_totalchol < 0 or bloods_totalchol = . or bloods_triglyc < 0 or bloods_triglyc = . or bloods_hdlchol < 0 or bloods_hdlchol = . or
		bloods_vldlcholcal < 0 or bloods_vldlcholcal = . or bloods_ldlcholcalc < 0 or bloods_ldlcholcalc = . or bloods_hemoa1c < 0 or bloods_hemoa1c = . or
		bloods_creactivepro < 0 or bloods_creactivepro = . or bloods_urinemicro < 0 or bloods_urinemicro = . or bloods_serumgluc < 0 or bloods_serumgluc = . or
		bloods_fibrinactivity < 0 or bloods_fibrinactivity = . or bloods_urinecreatin < 0 or bloods_urinecreatin = .)
		then m6_bloods = 0;
	if m6_bloods = 0 then m6_bloods_nmiss = nmiss(of bloods_totalchol--bloods_urinecreatin); else m6_bloods_nmiss = 0;
	if cal_a01 > 0 and cal_a01 ne . and cal_a02 > 0 and cal_a02 ne . and cal_a03 > 0 and cal_a03 ne . and cal_a04 > 0 and cal_a04 ne . and cal_a05 > 0 and cal_a05 ne . and
		cal_a06 > 0 and cal_a06 ne . and cal_a07 > 0 and cal_a07 ne . and cal_a08 > 0 and cal_a08 ne . and cal_a09 > 0 and cal_a09 ne . and cal_a10 > 0 and cal_a10 ne . and
		cal_a11 > 0 and cal_a11 ne . and cal_b01 > 0 and cal_b01 ne . and cal_b02 > 0 and cal_b02 ne . and cal_b03 > 0 and cal_b03 ne . and cal_b04 > 0 and cal_b04 ne . and
		cal_b05 > 0 and cal_b05 ne . and cal_b06 > 0 and cal_b06 ne . and cal_b07 > 0 and cal_b07 ne . and cal_b08 > 0 and cal_b08 ne . and cal_b09 > 0 and cal_b09 ne . and
		cal_b10 > 0 and cal_b10 ne . and cal_b11 > 0 and cal_b11 ne . and cal_b12 > 0 and cal_b12 ne . and cal_b13 > 0 and cal_b13 ne . and cal_c01 > 0 and cal_c01 ne . and
		cal_c02 > 0 and cal_c02 ne . and cal_c03 > 0 and cal_c03 ne . and cal_c04 > 0 and cal_c04 ne . and cal_c05 > 0 and cal_c05 ne . and cal_c06 > 0 and cal_c06 ne . and
		cal_c07 > 0 and cal_c07 ne . and cal_c08 > 0 and cal_c08 ne . and cal_c09 > 0 and cal_c09 ne . and cal_c10 > 0 and cal_c10 ne . and cal_c11 > 0 and cal_c11 ne . and
		cal_d01 ge 0 and cal_d01 ne . and cal_d02 ge 0 and cal_d02 ne . and cal_d03 ge 0 and cal_d03 ne . and cal_d04 ge 0 and cal_d04 ne . and cal_d05 ge 0 and cal_d05 ne . and
		cal_d06 ge 0 and cal_d06 ne . and cal_d07 ge 0 and cal_d07 ne . and cal_d08 ge 0 and cal_d08 ne . and cal_d09 ge 0 and cal_d09 ne . and cal_d10 ge 0 and cal_d10 ne . and
		cal_d11 ge 0 and cal_d11 ne . and cal_d12 ge 0 and cal_d12 ne . and cal_d13 ge 0 and cal_d13 ne . and cal_d14 ge 0 and cal_d14 ne . and cal_d15 ge 0 and cal_d15 ne . and
		cal_d16 ge 0 and cal_d16 ne . and cal_d17 ge 0 and cal_d17 ne . and cal_d18 ge 0 and cal_d18 ne . and cal_d19 ge 0 and cal_d19 ne . and cal_d20 ge 0 and cal_d20 ne . and
		cal_d21 ge 0 and cal_d21 ne . and cal_e01 ge 0 and cal_e01 ne . and cal_e02 ge 0 and cal_e02 ne . and cal_e03 ge 0 and cal_e03 ne . and cal_e04 ge 0 and cal_e04 ne . and
		cal_e05 ge 0 and cal_e05 ne . and cal_e06 ge 0 and cal_e06 ne . and cal_e07 ge 0 and cal_e07 ne . and cal_e08 ge 0 and cal_e08 ne . and cal_e09 ge 0 and cal_e09 ne . and
		cal_e10 ge 0 and cal_e10 ne . and cal_e11 ge 0 and cal_e11 ne . and cal_e12 ge 0 and cal_e12 ne . and cal_e13 ge 0 and cal_e13 ne . and cal_e14 ge 0 and cal_e14 ne . and
		cal_e15 ge 0 and cal_e15 ne . and cal_e16 ge 0 and cal_e16 ne . and cal_e17 ge 0 and cal_e17 ne . and cal_e18 ge 0 and cal_e18 ne . and cal_e19 ge 0 and cal_e19 ne . and
		cal_e20 ge 0 and cal_e20 ne . and cal_e21 ge 0 and cal_e21 ne . and cal_e22 ge 0 and cal_e22 ne . and cal_e23 ge 0 and cal_e23 ne . and cal_e24 ge 0 and cal_e24 ne . and
		cal_e25 ge 0 and cal_e25 ne . and cal_e26 ge 0 and cal_e26 ne . and cal_f01 ge 0 and cal_f01 ne . and cal_f02 ge 0 and cal_f02 ne .
		then m6_saqli = 1;
	else if (cal_a01 < 0 or cal_a01 = .) and (cal_a02 < 0 or cal_a02 = .) and (cal_a03 < 0 or cal_a03 = .) and (cal_a04 < 0 or cal_a04 = .) and (cal_a05 < 0 or cal_a05 = .) and
		(cal_a06 < 0 or cal_a06 = .) and (cal_a07 < 0 or cal_a07 = .) and (cal_a08 < 0 or cal_a08 = .) and (cal_a09 < 0 or cal_a09 = .) and (cal_a10 < 0 or cal_a10 = .) and
		(cal_a11 < 0 or cal_a11 = .) and (cal_b01 < 0 or cal_b01 = .) and (cal_b02 < 0 or cal_b02 = .) and (cal_b03 < 0 or cal_b03 = .) and (cal_b04 < 0 or cal_b04 = .) and
		(cal_b05 < 0 or cal_b05 = .) and (cal_b06 < 0 or cal_b06 = .) and (cal_b07 < 0 or cal_b07 = .) and (cal_b08 < 0 or cal_b08 = .) and (cal_b09 < 0 or cal_b09 = .) and
		(cal_b10 < 0 or cal_b10 = .) and (cal_b11 < 0 or cal_b11 = .) and (cal_b12 < 0 or cal_b12 = .) and (cal_b13 < 0 or cal_b13 = .) and (cal_c01 < 0 or cal_c01 = .) and
		(cal_c02 < 0 or cal_c02 = .) and (cal_c03 < 0 or cal_c03 = .) and (cal_c04 < 0 or cal_c04 = .) and (cal_c05 < 0 or cal_c05 = .) and (cal_c06 < 0 or cal_c06 = .) and
		(cal_c07 < 0 or cal_c07 = .) and (cal_c08 < 0 or cal_c08 = .) and (cal_c09 < 0 or cal_c09 = .) and (cal_c10 < 0 or cal_c10 = .) and (cal_c11 < 0 or cal_c11 = .) and
		(cal_d01 < 0 or cal_d01 = .) and (cal_d02 < 0 or cal_d02 = .) and (cal_d03 < 0 or cal_d03 = .) and (cal_d04 < 0 or cal_d04 = .) and (cal_d05 < 0 or cal_d05 = .) and
		(cal_d06 < 0 or cal_d06 = .) and (cal_d07 < 0 or cal_d07 = .) and (cal_d08 < 0 or cal_d08 = .) and (cal_d09 < 0 or cal_d09 = .) and (cal_d10 < 0 or cal_d10 = .) and
		(cal_d11 < 0 or cal_d11 = .) and (cal_d12 < 0 or cal_d12 = .) and (cal_d13 < 0 or cal_d13 = .) and (cal_d14 < 0 or cal_d14 = .) and (cal_d15 < 0 or cal_d15 = .) and
		(cal_d16 < 0 or cal_d16 = .) and (cal_d17 < 0 or cal_d17 = .) and (cal_d18 < 0 or cal_d18 = .) and (cal_d19 < 0 or cal_d19 = .) and (cal_d20 < 0 or cal_d20 = .) and
		(cal_d21 < 0 or cal_d21 = .) and (cal_e01 < 0 or cal_e01 = .) and (cal_e02 < 0 or cal_e02 = .) and (cal_e03 < 0 or cal_e03 = .) and (cal_e04 < 0 or cal_e04 = .) and
		(cal_e05 < 0 or cal_e05 = .) and (cal_e06 < 0 or cal_e06 = .) and (cal_e07 < 0 or cal_e07 = .) and (cal_e08 < 0 or cal_e08 = .) and (cal_e09 < 0 or cal_e09 = .) and
		(cal_e10 < 0 or cal_e10 = .) and (cal_e11 < 0 or cal_e11 = .) and (cal_e12 < 0 or cal_e12 = .) and (cal_e13 < 0 or cal_e13 = .) and (cal_e14 < 0 or cal_e14 = .) and
		(cal_e15 < 0 or cal_e15 = .) and (cal_e16 < 0 or cal_e16 = .) and (cal_e17 < 0 or cal_e17 = .) and (cal_e18 < 0 or cal_e18 = .) and (cal_e19 < 0 or cal_e19 = .) and
		(cal_e20 < 0 or cal_e20 = .) and (cal_e21 < 0 or cal_e21 = .) and (cal_e22 < 0 or cal_e22 = .) and (cal_e23 < 0 or cal_e23 = .) and (cal_e24 < 0 or cal_e24 = .) and
		(cal_e25 < 0 or cal_e25 = .) and (cal_e26 < 0 or cal_e26 = .) and (cal_f01 < 0 or cal_f01 = .) and (cal_f02 < 0 or cal_f02 = .)
		then m6_saqli = .;
	else if (cal_a01 < 0 or cal_a01 = . or cal_a02 < 0 or cal_a02 = . or cal_a03 < 0 or cal_a03 = . or cal_a04 < 0 or cal_a04 = . or cal_a05 < 0 or cal_a05 = . or
		cal_a06 < 0 or cal_a06 = . or cal_a07 < 0 or cal_a07 = . or cal_a08 < 0 or cal_a08 = . or cal_a09 < 0 or cal_a09 = . or cal_a10 < 0 or cal_a10 = . or
		cal_a11 < 0 or cal_a11 = . or cal_b01 < 0 or cal_b01 = . or cal_b02 < 0 or cal_b02 = . or cal_b03 < 0 or cal_b03 = . or cal_b04 < 0 or cal_b04 = . or
		cal_b05 < 0 or cal_b05 = . or cal_b06 < 0 or cal_b06 = . or cal_b07 < 0 or cal_b07 = . or cal_b08 < 0 or cal_b08 = . or cal_b09 < 0 or cal_b09 = . or
		cal_b10 < 0 or cal_b10 = . or cal_b11 < 0 or cal_b11 = . or cal_b12 < 0 or cal_b12 = . or cal_b13 < 0 or cal_b13 = . or cal_c01 < 0 or cal_c01 = . or
		cal_c02 < 0 or cal_c02 = . or cal_c03 < 0 or cal_c03 = . or cal_c04 < 0 or cal_c04 = . or cal_c05 < 0 or cal_c05 = . or cal_c06 < 0 or cal_c06 = . or
		cal_c07 < 0 or cal_c07 = . or cal_c08 < 0 or cal_c08 = . or cal_c09 < 0 or cal_c09 = . or cal_c10 < 0 or cal_c10 = . or cal_c11 < 0 or cal_c11 = . or
		cal_d01 < 0 or cal_d01 = . or cal_d02 < 0 or cal_d02 = . or cal_d03 < 0 or cal_d03 = . or cal_d04 < 0 or cal_d04 = . or cal_d05 < 0 or cal_d05 = . or
		cal_d06 < 0 or cal_d06 = . or cal_d07 < 0 or cal_d07 = . or cal_d08 < 0 or cal_d08 = . or cal_d09 < 0 or cal_d09 = . or cal_d10 < 0 or cal_d10 = . or
		cal_d11 < 0 or cal_d11 = . or cal_d12 < 0 or cal_d12 = . or cal_d13 < 0 or cal_d13 = . or cal_d14 < 0 or cal_d14 = . or cal_d15 < 0 or cal_d15 = . or
		cal_d16 < 0 or cal_d16 = . or cal_d17 < 0 or cal_d17 = . or cal_d18 < 0 or cal_d18 = . or cal_d19 < 0 or cal_d19 = . or cal_d20 < 0 or cal_d20 = . or
		cal_d21 < 0 or cal_d21 = . or cal_e01 < 0 or cal_e01 = . or cal_e02 < 0 or cal_e02 = . or cal_e03 < 0 or cal_e03 = . or cal_e04 < 0 or cal_e04 = . or
		cal_e05 < 0 or cal_e05 = . or cal_e06 < 0 or cal_e06 = . or cal_e07 < 0 or cal_e07 = . or cal_e08 < 0 or cal_e08 = . or cal_e09 < 0 or cal_e09 = . or
		cal_e10 < 0 or cal_e10 = . or cal_e11 < 0 or cal_e11 = . or cal_e12 < 0 or cal_e12 = . or cal_e13 < 0 or cal_e13 = . or cal_e14 < 0 or cal_e14 = . or
		cal_e15 < 0 or cal_e15 = . or cal_e16 < 0 or cal_e16 = . or cal_e17 < 0 or cal_e17 = . or cal_e18 < 0 or cal_e18 = . or cal_e19 < 0 or cal_e19 = . or
		cal_e20 < 0 or cal_e20 = . or cal_e21 < 0 or cal_e21 = . or cal_e22 < 0 or cal_e22 = . or cal_e23 < 0 or cal_e23 = . or cal_e24 < 0 or cal_e24 = . or
		cal_e25 < 0 or cal_e25 = . or cal_e26 < 0 or cal_e26 = . or cal_f01 < 0 or cal_f01 = . or cal_f02 < 0 or cal_f02 = .)
		then m6_saqli = 0;
	if m6_saqli = 0 then m6_saqli_nmiss = nmiss(of cal_a01--cal_d21 cal_e01--cal_e25 cal_f01--cal_f02); else m6_saqli_nmiss = 0;
	if phq8_interest ge 0 and phq8_interest ne . and phq8_down_hopeless ge 0 and phq8_down_hopeless ne . and phq8_sleep ge 0 and phq8_sleep ne . and
		phq8_tired ge 0 and phq8_tired ne . and phq8_appetite ge 0 and phq8_appetite ne . and phq8_bad_failure ge 0 and phq8_bad_failure ne . and
		phq8_troubleconcentrating ge 0 and phq8_troubleconcentrating ne . and phq8_movingslowly ge 0 and phq8_movingslowly ne . and phq8_total ne .
		then m6_phq = 1;
	else if (phq8_interest le 0 or phq8_interest = .) and (phq8_down_hopeless le 0 or phq8_down_hopeless = .) and (phq8_sleep le 0 or phq8_sleep = .) and
		(phq8_tired le 0 or phq8_tired = .) and (phq8_appetite le 0 or phq8_appetite = .) and (phq8_bad_failure le 0 or phq8_bad_failure = .) and
		(phq8_troubleconcentrating le 0 or phq8_troubleconcentrating = .) and (phq8_movingslowly le 0 or phq8_movingslowly = .) and (phq8_total le 0 or phq8_total = .)
		then m6_phq = .;
	else if (phq8_interest le 0 or phq8_interest = . or phq8_down_hopeless le 0 or phq8_down_hopeless = . or phq8_sleep le 0 or phq8_sleep = . or
		phq8_tired le 0 or phq8_tired = . or phq8_appetite le 0 or phq8_appetite = . or phq8_bad_failure le 0 or phq8_bad_failure = . or
		phq8_troubleconcentrating le 0 or phq8_troubleconcentrating = . or phq8_movingslowly le 0 or phq8_movingslowly = . or phq8_total le 0 or phq8_total = .)
		then m6_phq = 0;
	if m6_phq = 0 then m6_phq_nmiss = nmiss(of phq8_interest--phq8_total); else m6_phq_nmiss = 0;
	if sf36_gh01 > 0 and sf36_gh01 ne . and sf36_gh02 > 0 and sf36_gh02 ne . and sf36_gh03 > 0 and sf36_gh03 ne . and sf36_gh04 > 0 and sf36_gh04 ne . and
		sf36_gh05 > 0 and sf36_gh05 ne . and sf36_pf01 > 0 and sf36_pf01 ne . and sf36_pf02 > 0 and sf36_pf02 ne . and sf36_pf03 > 0 and sf36_pf03 ne . and
		sf36_pf04 > 0 and sf36_pf04 ne . and sf36_pf05 > 0 and sf36_pf05 ne . and sf36_pf06 > 0 and sf36_pf06 ne . and sf36_pf07 > 0 and sf36_pf07 ne . and
		sf36_pf08 > 0 and sf36_pf08 ne . and sf36_pf09 > 0 and sf36_pf09 ne . and sf36_pf10 > 0 and sf36_pf10 ne . and sf36_rp01 > 0 and sf36_rp01 ne . and
		sf36_rp02 > 0 and sf36_rp02 ne . and sf36_rp03 > 0 and sf36_rp03 ne . and sf36_rp04 > 0 and sf36_rp04 ne . and sf36_re01 > 0 and sf36_re01 ne . and
		sf36_re02 > 0 and sf36_re02 ne . and sf36_re03 > 0 and sf36_re03 ne . and sf36_bp01 > 0 and sf36_bp01 ne . and sf36_bp02 > 0 and sf36_bp02 ne . and
		sf36_sf01 > 0 and sf36_sf01 ne . and sf36_sf02 > 0 and sf36_sf02 ne . and sf36_mh01 > 0 and sf36_mh01 ne . and sf36_mh02 > 0 and sf36_mh02 ne . and
		sf36_mh03 > 0 and sf36_mh03 ne . and sf36_mh04 > 0 and sf36_mh04 ne . and sf36_mh05 > 0 and sf36_mh05 ne . and sf36_sfht > 0 and sf36_sfht ne .
		then m6_sf36 = 1;
	else if (sf36_gh01 < 0 or sf36_gh01 = .) and (sf36_gh02 < 0 or sf36_gh02 = .) and (sf36_gh03 < 0 or sf36_gh03 = .) and (sf36_gh04 < 0 or sf36_gh04 = .) and
		(sf36_gh05 < 0 or sf36_gh05 = .) and (sf36_pf01 < 0 or sf36_pf01 = .) and (sf36_pf02 < 0 or sf36_pf02 = .) and (sf36_pf03 < 0 or sf36_pf03 = .) and
		(sf36_pf04 < 0 or sf36_pf04 = .) and (sf36_pf05 < 0 or sf36_pf05 = .) and (sf36_pf06 < 0 or sf36_pf06 = .) and (sf36_pf07 < 0 or sf36_pf07 = .) and
		(sf36_pf08 < 0 or sf36_pf08 = .) and (sf36_pf09 < 0 or sf36_pf09 = .) and (sf36_pf10 < 0 or sf36_pf10 = .) and (sf36_rp01 < 0 or sf36_rp01 = .) and
		(sf36_rp02 < 0 or sf36_rp02 = .) and (sf36_rp03 < 0 or sf36_rp03 = .) and (sf36_rp04 < 0 or sf36_rp04 = .) and (sf36_re01 < 0 or sf36_re01 = .) and
		(sf36_re02 < 0 or sf36_re02 = .) and (sf36_re03 < 0 or sf36_re03 = .) and (sf36_bp01 < 0 or sf36_bp01 = .) and (sf36_bp02 < 0 or sf36_bp02 = .) and
		(sf36_sf01 < 0 or sf36_sf01 = .) and (sf36_sf02 < 0 or sf36_sf02 = .) and (sf36_mh01 < 0 or sf36_mh01 = .) and (sf36_mh02 < 0 or sf36_mh02 = .) and
		(sf36_mh03 < 0 or sf36_mh03 = .) and (sf36_mh04 < 0 or sf36_mh04 = .) and (sf36_mh05 < 0 or sf36_mh05 = .) and (sf36_sfht < 0 or sf36_sfht = .)
		then m6_sf36 = .;
	else if (sf36_gh01 < 0 or sf36_gh01 = . or sf36_gh02 < 0 or sf36_gh02 = . or sf36_gh03 < 0 or sf36_gh03 = . or sf36_gh04 < 0 or sf36_gh04 = . or
		sf36_gh05 < 0 or sf36_gh05 = . or sf36_pf01 < 0 or sf36_pf01 = . or sf36_pf02 < 0 or sf36_pf02 = . or sf36_pf03 < 0 or sf36_pf03 = . or
		sf36_pf04 < 0 or sf36_pf04 = . or sf36_pf05 < 0 or sf36_pf05 = . or sf36_pf06 < 0 or sf36_pf06 = . or sf36_pf07 < 0 or sf36_pf07 = . or
		sf36_pf08 < 0 or sf36_pf08 = . or sf36_pf09 < 0 or sf36_pf09 = . or sf36_pf10 < 0 or sf36_pf10 = . or sf36_rp01 < 0 or sf36_rp01 = . or
		sf36_rp02 < 0 or sf36_rp02 = . or sf36_rp03 < 0 or sf36_rp03 = . or sf36_rp04 < 0 or sf36_rp04 = . or sf36_re01 < 0 or sf36_re01 = . or
		sf36_re02 < 0 or sf36_re02 = . or sf36_re03 < 0 or sf36_re03 = . or sf36_bp01 < 0 or sf36_bp01 = . or sf36_bp02 < 0 or sf36_bp02 = . or
		sf36_sf01 < 0 or sf36_sf01 = . or sf36_sf02 < 0 or sf36_sf02 = . or sf36_mh01 < 0 or sf36_mh01 = . or sf36_mh02 < 0 or sf36_mh02 = . or
		sf36_mh03 < 0 or sf36_mh03 = . or sf36_mh04 < 0 or sf36_mh04 = . or sf36_mh05 < 0 or sf36_mh05 = . or sf36_sfht < 0 or sf36_sfht = .)
		then m6_sf36 = 0;
	if m6_sf36 = 0 then m6_sf36_nmiss = nmiss(of sf36_gh01--sf36_gh05); else m6_sf36_nmiss = 0;
	if shq_sitread6 ge 0 and shq_sitread6 ne . and shq_watchingtv6 ge 0 and shq_watchingtv6 ne . and shq_sitinactive6 ge 0 and shq_sitinactive6 ne . and
		shq_ridingforhour6 ge 0 and shq_ridingforhour6 ne . and shq_lyingdown6 ge 0 and shq_lyingdown6 ne . and shq_sittalk6 ge 0 and shq_sittalk6 ne . and
		shq_afterlunch6 ge 0 and shq_afterlunch6 ne . and shq_stoppedcar6 ge 0 and shq_stoppedcar6 ne . and (shq_driving6 ge 0 or shq_driving6 = -8) and shq_driving6 ne .
		then m6_ess = 1;
	else if (shq_sitread6 < 0 or shq_sitread6 = .) and (shq_watchingtv6 < 0 or shq_watchingtv6 = .) and (shq_sitinactive6 < 0 or shq_sitinactive6 = .) and
		(shq_ridingforhour6 < 0 or shq_ridingforhour6 = .) and (shq_lyingdown6 < 0 or shq_lyingdown6 = .) and (shq_sittalk6 < 0 or shq_sittalk6 = .) and
		(shq_afterlunch6 < 0 or shq_afterlunch6 = .) and (shq_stoppedcar6 < 0 or shq_stoppedcar6 = .) and shq_driving6 = .
		then m6_ess = .;
	else if (shq_sitread6 < 0 or shq_sitread6 = . or shq_watchingtv6 < 0 or shq_watchingtv6 = . or shq_sitinactive6 < 0 or shq_sitinactive6 = . or
		shq_ridingforhour6 < 0 or shq_ridingforhour6 = . or shq_lyingdown6 < 0 or shq_lyingdown6 = . or shq_sittalk6 < 0 or shq_sittalk6 = . or
		shq_afterlunch6 < 0 or shq_afterlunch6 = . or shq_stoppedcar6 < 0 or shq_stoppedcar6 = . or shq_driving6 = .)
		then m6_ess = 0;
	if m6_ess = 0 then m6_ess_nmiss = nmiss(of shq_sitread6--shq_driving6); else m6_ess_nmiss = 0;
run;

*create 12-month follow-up visit dataset;
data m12;
	set baredcap(where=(redcap_event_name = "12_fu_arm_1"));

	keep elig_studyid redcap_event_name bloods_studyid--blood_results_labcor_v_1 cal_studyid--cal_e26 cal_f01 cal_f02 phq8_studyid--phq8_complete sf36_studyid--sf36_bdfa_complete
		shq_sitread6--shq_driving6;
run;

*code variables for missing and not applicable data;
data codes3;
	set m12;

	array calgary_array {84} cal_a01--cal_d21 cal_e01--cal_e26 cal_f01 cal_f02;
		do i = 1 to 84;
		if calgary_array{i} = -8 then calgary_array{i} = .n;
		else if calgary_array{i} = -9 then calgary_array{i} = .m;
		else if calgary_array{i} = -10 then calgary_array{i} = .c;
		end;
	array bloods_array {11} bloods_totalchol--bloods_urinecreatin;
		do k = 1 to 11;
		if bloods_array{k} = -8 then bloods_array{k} = .n;
		else if bloods_array{k} = -9 then bloods_array{k} = .m;
		else if bloods_array{k} = -10 then bloods_array{k} = .c;
		end;
	array phq_array {9} phq8_interest--phq8_total;
		do j = 1 to 9;
		if phq_array{j} = -8 then phq_array{j} = .n;
		else if phq_array{j} = -9 then phq_array{j} = .m;
		else if phq_array{j} = -10 then phq_array{j} = .c;
		end;
	array sf36_array {36} sf36_gh01--sf36_gh05;
		do l = 1 to 36;
		if sf36_array{l} = -8 then sf36_array{l} = .n;
		else if sf36_array{l} = -9 then sf36_array{l} = .m;
		else if sf36_array{l} = -10 then sf36_array{l} = .c;
		end;
	array ess_array {8} shq_sitread6--shq_stoppedcar6;
		do h = 1 to 8;
		if ess_array{h} = -8 then ess_array{h} = .n;
		else if ess_array{h} = -9 then ess_array{h} = .m;
		else if ess_array{h} = -10 then ess_array{h} = .c;
		if shq_driving6 = -9 then shq_driving6 = .m;
		else if shq_driving6 = -10 then shq_driving6 = .c;
		end;

	if bloods_totalchol > 0 and bloods_totalchol ne . and bloods_triglyc > 0 and bloods_triglyc ne . and bloods_hdlchol > 0 and bloods_hdlchol ne . and
		bloods_vldlcholcal > 0 and bloods_vldlcholcal ne . and bloods_ldlcholcalc > 0 and bloods_ldlcholcalc ne . and bloods_hemoa1c > 0 and bloods_hemoa1c ne . and
		bloods_creactivepro > 0 and bloods_creactivepro ne . and bloods_urinemicro > 0 and bloods_urinemicro ne . and bloods_serumgluc > 0 and bloods_serumgluc ne . and
		bloods_fibrinactivity > 0 and bloods_fibrinactivity ne . and bloods_urinecreatin > 0 and bloods_urinecreatin ne .
		then m12_bloods = 1;
	else if  (bloods_totalchol < 0 or bloods_totalchol = .) and (bloods_triglyc < 0 or bloods_triglyc = .) and (bloods_hdlchol < 0 or bloods_hdlchol = .) and
		(bloods_vldlcholcal < 0 or bloods_vldlcholcal = .) and (bloods_ldlcholcalc < 0 or bloods_ldlcholcalc = .) and (bloods_hemoa1c < 0 or bloods_hemoa1c = .) and
		(bloods_creactivepro < 0 or bloods_creactivepro = .) and (bloods_urinemicro < 0 or bloods_urinemicro = .) and (bloods_serumgluc < 0 or bloods_serumgluc = .) and
		(bloods_fibrinactivity < 0 or bloods_fibrinactivity = .) and (bloods_urinecreatin < 0 or bloods_urinecreatin = .)
		then m12_bloods = .;
	else if (bloods_totalchol < 0 or bloods_totalchol = . or bloods_triglyc < 0 or bloods_triglyc = . or bloods_hdlchol < 0 or bloods_hdlchol = . or
		bloods_vldlcholcal < 0 or bloods_vldlcholcal = . or bloods_ldlcholcalc < 0 or bloods_ldlcholcalc = . or bloods_hemoa1c < 0 or bloods_hemoa1c = . or
		bloods_creactivepro < 0 or bloods_creactivepro = . or bloods_urinemicro < 0 or bloods_urinemicro = . or bloods_serumgluc < 0 or bloods_serumgluc = . or
		bloods_fibrinactivity < 0 or bloods_fibrinactivity = . or bloods_urinecreatin < 0 or bloods_urinecreatin = .)
		then m12_bloods = 0;
	if m12_bloods = 0 then m12_bloods_nmiss = nmiss(of bloods_totalchol--bloods_urinecreatin); else m12_bloods_nmiss = 0;
	if cal_a01 > 0 and cal_a01 ne . and cal_a02 > 0 and cal_a02 ne . and cal_a03 > 0 and cal_a03 ne . and cal_a04 > 0 and cal_a04 ne . and cal_a05 > 0 and cal_a05 ne . and
		cal_a06 > 0 and cal_a06 ne . and cal_a07 > 0 and cal_a07 ne . and cal_a08 > 0 and cal_a08 ne . and cal_a09 > 0 and cal_a09 ne . and cal_a10 > 0 and cal_a10 ne . and
		cal_a11 > 0 and cal_a11 ne . and cal_b01 > 0 and cal_b01 ne . and cal_b02 > 0 and cal_b02 ne . and cal_b03 > 0 and cal_b03 ne . and cal_b04 > 0 and cal_b04 ne . and
		cal_b05 > 0 and cal_b05 ne . and cal_b06 > 0 and cal_b06 ne . and cal_b07 > 0 and cal_b07 ne . and cal_b08 > 0 and cal_b08 ne . and cal_b09 > 0 and cal_b09 ne . and
		cal_b10 > 0 and cal_b10 ne . and cal_b11 > 0 and cal_b11 ne . and cal_b12 > 0 and cal_b12 ne . and cal_b13 > 0 and cal_b13 ne . and cal_c01 > 0 and cal_c01 ne . and
		cal_c02 > 0 and cal_c02 ne . and cal_c03 > 0 and cal_c03 ne . and cal_c04 > 0 and cal_c04 ne . and cal_c05 > 0 and cal_c05 ne . and cal_c06 > 0 and cal_c06 ne . and
		cal_c07 > 0 and cal_c07 ne . and cal_c08 > 0 and cal_c08 ne . and cal_c09 > 0 and cal_c09 ne . and cal_c10 > 0 and cal_c10 ne . and cal_c11 > 0 and cal_c11 ne . and
		cal_d01 ge 0 and cal_d01 ne . and cal_d02 ge 0 and cal_d02 ne . and cal_d03 ge 0 and cal_d03 ne . and cal_d04 ge 0 and cal_d04 ne . and cal_d05 ge 0 and cal_d05 ne . and
		cal_d06 ge 0 and cal_d06 ne . and cal_d07 ge 0 and cal_d07 ne . and cal_d08 ge 0 and cal_d08 ne . and cal_d09 ge 0 and cal_d09 ne . and cal_d10 ge 0 and cal_d10 ne . and
		cal_d11 ge 0 and cal_d11 ne . and cal_d12 ge 0 and cal_d12 ne . and cal_d13 ge 0 and cal_d13 ne . and cal_d14 ge 0 and cal_d14 ne . and cal_d15 ge 0 and cal_d15 ne . and
		cal_d16 ge 0 and cal_d16 ne . and cal_d17 ge 0 and cal_d17 ne . and cal_d18 ge 0 and cal_d18 ne . and cal_d19 ge 0 and cal_d19 ne . and cal_d20 ge 0 and cal_d20 ne . and
		cal_d21 ge 0 and cal_d21 ne . and cal_e01 ge 0 and cal_e01 ne . and cal_e02 ge 0 and cal_e02 ne . and cal_e03 ge 0 and cal_e03 ne . and cal_e04 ge 0 and cal_e04 ne . and
		cal_e05 ge 0 and cal_e05 ne . and cal_e06 ge 0 and cal_e06 ne . and cal_e07 ge 0 and cal_e07 ne . and cal_e08 ge 0 and cal_e08 ne . and cal_e09 ge 0 and cal_e09 ne . and
		cal_e10 ge 0 and cal_e10 ne . and cal_e11 ge 0 and cal_e11 ne . and cal_e12 ge 0 and cal_e12 ne . and cal_e13 ge 0 and cal_e13 ne . and cal_e14 ge 0 and cal_e14 ne . and
		cal_e15 ge 0 and cal_e15 ne . and cal_e16 ge 0 and cal_e16 ne . and cal_e17 ge 0 and cal_e17 ne . and cal_e18 ge 0 and cal_e18 ne . and cal_e19 ge 0 and cal_e19 ne . and
		cal_e20 ge 0 and cal_e20 ne . and cal_e21 ge 0 and cal_e21 ne . and cal_e22 ge 0 and cal_e22 ne . and cal_e23 ge 0 and cal_e23 ne . and cal_e24 ge 0 and cal_e24 ne . and
		cal_e25 ge 0 and cal_e25 ne . and cal_e26 ge 0 and cal_e26 ne . and cal_f01 ge 0 and cal_f01 ne . and cal_f02 ge 0 and cal_f02 ne .
		then m12_saqli = 1;
	else if (cal_a01 < 0 or cal_a01 = .) and (cal_a02 < 0 or cal_a02 = .) and (cal_a03 < 0 or cal_a03 = .) and (cal_a04 < 0 or cal_a04 = .) and (cal_a05 < 0 or cal_a05 = .) and
		(cal_a06 < 0 or cal_a06 = .) and (cal_a07 < 0 or cal_a07 = .) and (cal_a08 < 0 or cal_a08 = .) and (cal_a09 < 0 or cal_a09 = .) and (cal_a10 < 0 or cal_a10 = .) and
		(cal_a11 < 0 or cal_a11 = .) and (cal_b01 < 0 or cal_b01 = .) and (cal_b02 < 0 or cal_b02 = .) and (cal_b03 < 0 or cal_b03 = .) and (cal_b04 < 0 or cal_b04 = .) and
		(cal_b05 < 0 or cal_b05 = .) and (cal_b06 < 0 or cal_b06 = .) and (cal_b07 < 0 or cal_b07 = .) and (cal_b08 < 0 or cal_b08 = .) and (cal_b09 < 0 or cal_b09 = .) and
		(cal_b10 < 0 or cal_b10 = .) and (cal_b11 < 0 or cal_b11 = .) and (cal_b12 < 0 or cal_b12 = .) and (cal_b13 < 0 or cal_b13 = .) and (cal_c01 < 0 or cal_c01 = .) and
		(cal_c02 < 0 or cal_c02 = .) and (cal_c03 < 0 or cal_c03 = .) and (cal_c04 < 0 or cal_c04 = .) and (cal_c05 < 0 or cal_c05 = .) and (cal_c06 < 0 or cal_c06 = .) and
		(cal_c07 < 0 or cal_c07 = .) and (cal_c08 < 0 or cal_c08 = .) and (cal_c09 < 0 or cal_c09 = .) and (cal_c10 < 0 or cal_c10 = .) and (cal_c11 < 0 or cal_c11 = .) and
		(cal_d01 < 0 or cal_d01 = .) and (cal_d02 < 0 or cal_d02 = .) and (cal_d03 < 0 or cal_d03 = .) and (cal_d04 < 0 or cal_d04 = .) and (cal_d05 < 0 or cal_d05 = .) and
		(cal_d06 < 0 or cal_d06 = .) and (cal_d07 < 0 or cal_d07 = .) and (cal_d08 < 0 or cal_d08 = .) and (cal_d09 < 0 or cal_d09 = .) and (cal_d10 < 0 or cal_d10 = .) and
		(cal_d11 < 0 or cal_d11 = .) and (cal_d12 < 0 or cal_d12 = .) and (cal_d13 < 0 or cal_d13 = .) and (cal_d14 < 0 or cal_d14 = .) and (cal_d15 < 0 or cal_d15 = .) and
		(cal_d16 < 0 or cal_d16 = .) and (cal_d17 < 0 or cal_d17 = .) and (cal_d18 < 0 or cal_d18 = .) and (cal_d19 < 0 or cal_d19 = .) and (cal_d20 < 0 or cal_d20 = .) and
		(cal_d21 < 0 or cal_d21 = .) and (cal_e01 < 0 or cal_e01 = .) and (cal_e02 < 0 or cal_e02 = .) and (cal_e03 < 0 or cal_e03 = .) and (cal_e04 < 0 or cal_e04 = .) and
		(cal_e05 < 0 or cal_e05 = .) and (cal_e06 < 0 or cal_e06 = .) and (cal_e07 < 0 or cal_e07 = .) and (cal_e08 < 0 or cal_e08 = .) and (cal_e09 < 0 or cal_e09 = .) and
		(cal_e10 < 0 or cal_e10 = .) and (cal_e11 < 0 or cal_e11 = .) and (cal_e12 < 0 or cal_e12 = .) and (cal_e13 < 0 or cal_e13 = .) and (cal_e14 < 0 or cal_e14 = .) and
		(cal_e15 < 0 or cal_e15 = .) and (cal_e16 < 0 or cal_e16 = .) and (cal_e17 < 0 or cal_e17 = .) and (cal_e18 < 0 or cal_e18 = .) and (cal_e19 < 0 or cal_e19 = .) and
		(cal_e20 < 0 or cal_e20 = .) and (cal_e21 < 0 or cal_e21 = .) and (cal_e22 < 0 or cal_e22 = .) and (cal_e23 < 0 or cal_e23 = .) and (cal_e24 < 0 or cal_e24 = .) and
		(cal_e25 < 0 or cal_e25 = .) and (cal_e26 < 0 or cal_e26 = .) and (cal_f01 < 0 or cal_f01 = .) and (cal_f02 < 0 or cal_f02 = .)
		then m12_saqli = .;
	else if (cal_a01 < 0 or cal_a01 = . or cal_a02 < 0 or cal_a02 = . or cal_a03 < 0 or cal_a03 = . or cal_a04 < 0 or cal_a04 = . or cal_a05 < 0 or cal_a05 = . or
		cal_a06 < 0 or cal_a06 = . or cal_a07 < 0 or cal_a07 = . or cal_a08 < 0 or cal_a08 = . or cal_a09 < 0 or cal_a09 = . or cal_a10 < 0 or cal_a10 = . or
		cal_a11 < 0 or cal_a11 = . or cal_b01 < 0 or cal_b01 = . or cal_b02 < 0 or cal_b02 = . or cal_b03 < 0 or cal_b03 = . or cal_b04 < 0 or cal_b04 = . or
		cal_b05 < 0 or cal_b05 = . or cal_b06 < 0 or cal_b06 = . or cal_b07 < 0 or cal_b07 = . or cal_b08 < 0 or cal_b08 = . or cal_b09 < 0 or cal_b09 = . or
		cal_b10 < 0 or cal_b10 = . or cal_b11 < 0 or cal_b11 = . or cal_b12 < 0 or cal_b12 = . or cal_b13 < 0 or cal_b13 = . or cal_c01 < 0 or cal_c01 = . or
		cal_c02 < 0 or cal_c02 = . or cal_c03 < 0 or cal_c03 = . or cal_c04 < 0 or cal_c04 = . or cal_c05 < 0 or cal_c05 = . or cal_c06 < 0 or cal_c06 = . or
		cal_c07 < 0 or cal_c07 = . or cal_c08 < 0 or cal_c08 = . or cal_c09 < 0 or cal_c09 = . or cal_c10 < 0 or cal_c10 = . or cal_c11 < 0 or cal_c11 = . or
		cal_d01 < 0 or cal_d01 = . or cal_d02 < 0 or cal_d02 = . or cal_d03 < 0 or cal_d03 = . or cal_d04 < 0 or cal_d04 = . or cal_d05 < 0 or cal_d05 = . or
		cal_d06 < 0 or cal_d06 = . or cal_d07 < 0 or cal_d07 = . or cal_d08 < 0 or cal_d08 = . or cal_d09 < 0 or cal_d09 = . or cal_d10 < 0 or cal_d10 = . or
		cal_d11 < 0 or cal_d11 = . or cal_d12 < 0 or cal_d12 = . or cal_d13 < 0 or cal_d13 = . or cal_d14 < 0 or cal_d14 = . or cal_d15 < 0 or cal_d15 = . or
		cal_d16 < 0 or cal_d16 = . or cal_d17 < 0 or cal_d17 = . or cal_d18 < 0 or cal_d18 = . or cal_d19 < 0 or cal_d19 = . or cal_d20 < 0 or cal_d20 = . or
		cal_d21 < 0 or cal_d21 = . or cal_e01 < 0 or cal_e01 = . or cal_e02 < 0 or cal_e02 = . or cal_e03 < 0 or cal_e03 = . or cal_e04 < 0 or cal_e04 = . or
		cal_e05 < 0 or cal_e05 = . or cal_e06 < 0 or cal_e06 = . or cal_e07 < 0 or cal_e07 = . or cal_e08 < 0 or cal_e08 = . or cal_e09 < 0 or cal_e09 = . or
		cal_e10 < 0 or cal_e10 = . or cal_e11 < 0 or cal_e11 = . or cal_e12 < 0 or cal_e12 = . or cal_e13 < 0 or cal_e13 = . or cal_e14 < 0 or cal_e14 = . or
		cal_e15 < 0 or cal_e15 = . or cal_e16 < 0 or cal_e16 = . or cal_e17 < 0 or cal_e17 = . or cal_e18 < 0 or cal_e18 = . or cal_e19 < 0 or cal_e19 = . or
		cal_e20 < 0 or cal_e20 = . or cal_e21 < 0 or cal_e21 = . or cal_e22 < 0 or cal_e22 = . or cal_e23 < 0 or cal_e23 = . or cal_e24 < 0 or cal_e24 = . or
		cal_e25 < 0 or cal_e25 = . or cal_e26 < 0 or cal_e26 = . or cal_f01 < 0 or cal_f01 = . or cal_f02 < 0 or cal_f02 = .)
		then m12_saqli = 0;
	if m12_saqli = 0 then m12_saqli_nmiss = nmiss(of cal_a01--cal_d21 cal_e01--cal_e25 cal_f01--cal_f02); else m12_saqli_nmiss = 0;
	if phq8_interest ge 0 and phq8_interest ne . and phq8_down_hopeless ge 0 and phq8_down_hopeless ne . and phq8_sleep ge 0 and phq8_sleep ne . and
		phq8_tired ge 0 and phq8_tired ne . and phq8_appetite ge 0 and phq8_appetite ne . and phq8_bad_failure ge 0 and phq8_bad_failure ne . and
		phq8_troubleconcentrating ge 0 and phq8_troubleconcentrating ne . and phq8_movingslowly ge 0 and phq8_movingslowly ne . and phq8_total ne .
		then m12_phq = 1;
	else if (phq8_interest le 0 or phq8_interest = .) and (phq8_down_hopeless le 0 or phq8_down_hopeless = .) and (phq8_sleep le 0 or phq8_sleep = .) and
		(phq8_tired le 0 or phq8_tired = .) and (phq8_appetite le 0 or phq8_appetite = .) and (phq8_bad_failure le 0 or phq8_bad_failure = .) and
		(phq8_troubleconcentrating le 0 or phq8_troubleconcentrating = .) and (phq8_movingslowly le 0 or phq8_movingslowly = .) and (phq8_total le 0 or phq8_total = .)
		then m12_phq = .;
	else if (phq8_interest le 0 or phq8_interest = . or phq8_down_hopeless le 0 or phq8_down_hopeless = . or phq8_sleep le 0 or phq8_sleep = . or
		phq8_tired le 0 or phq8_tired = . or phq8_appetite le 0 or phq8_appetite = . or phq8_bad_failure le 0 or phq8_bad_failure = . or
		phq8_troubleconcentrating le 0 or phq8_troubleconcentrating = . or phq8_movingslowly le 0 or phq8_movingslowly = . or phq8_total le 0 or phq8_total = .)
		then m12_phq = 0;
	if m12_phq = 0 then m12_phq_nmiss = nmiss(of phq8_interest--phq8_total); else m12_phq_nmiss = 0;
	if sf36_gh01 > 0 and sf36_gh01 ne . and sf36_gh02 > 0 and sf36_gh02 ne . and sf36_gh03 > 0 and sf36_gh03 ne . and sf36_gh04 > 0 and sf36_gh04 ne . and
		sf36_gh05 > 0 and sf36_gh05 ne . and sf36_pf01 > 0 and sf36_pf01 ne . and sf36_pf02 > 0 and sf36_pf02 ne . and sf36_pf03 > 0 and sf36_pf03 ne . and
		sf36_pf04 > 0 and sf36_pf04 ne . and sf36_pf05 > 0 and sf36_pf05 ne . and sf36_pf06 > 0 and sf36_pf06 ne . and sf36_pf07 > 0 and sf36_pf07 ne . and
		sf36_pf08 > 0 and sf36_pf08 ne . and sf36_pf09 > 0 and sf36_pf09 ne . and sf36_pf10 > 0 and sf36_pf10 ne . and sf36_rp01 > 0 and sf36_rp01 ne . and
		sf36_rp02 > 0 and sf36_rp02 ne . and sf36_rp03 > 0 and sf36_rp03 ne . and sf36_rp04 > 0 and sf36_rp04 ne . and sf36_re01 > 0 and sf36_re01 ne . and
		sf36_re02 > 0 and sf36_re02 ne . and sf36_re03 > 0 and sf36_re03 ne . and sf36_bp01 > 0 and sf36_bp01 ne . and sf36_bp02 > 0 and sf36_bp02 ne . and
		sf36_sf01 > 0 and sf36_sf01 ne . and sf36_sf02 > 0 and sf36_sf02 ne . and sf36_mh01 > 0 and sf36_mh01 ne . and sf36_mh02 > 0 and sf36_mh02 ne . and
		sf36_mh03 > 0 and sf36_mh03 ne . and sf36_mh04 > 0 and sf36_mh04 ne . and sf36_mh05 > 0 and sf36_mh05 ne . and sf36_sfht > 0 and sf36_sfht ne .
		then m12_sf36 = 1;
	else if (sf36_gh01 < 0 or sf36_gh01 = .) and (sf36_gh02 < 0 or sf36_gh02 = .) and (sf36_gh03 < 0 or sf36_gh03 = .) and (sf36_gh04 < 0 or sf36_gh04 = .) and
		(sf36_gh05 < 0 or sf36_gh05 = .) and (sf36_pf01 < 0 or sf36_pf01 = .) and (sf36_pf02 < 0 or sf36_pf02 = .) and (sf36_pf03 < 0 or sf36_pf03 = .) and
		(sf36_pf04 < 0 or sf36_pf04 = .) and (sf36_pf05 < 0 or sf36_pf05 = .) and (sf36_pf06 < 0 or sf36_pf06 = .) and (sf36_pf07 < 0 or sf36_pf07 = .) and
		(sf36_pf08 < 0 or sf36_pf08 = .) and (sf36_pf09 < 0 or sf36_pf09 = .) and (sf36_pf10 < 0 or sf36_pf10 = .) and (sf36_rp01 < 0 or sf36_rp01 = .) and
		(sf36_rp02 < 0 or sf36_rp02 = .) and (sf36_rp03 < 0 or sf36_rp03 = .) and (sf36_rp04 < 0 or sf36_rp04 = .) and (sf36_re01 < 0 or sf36_re01 = .) and
		(sf36_re02 < 0 or sf36_re02 = .) and (sf36_re03 < 0 or sf36_re03 = .) and (sf36_bp01 < 0 or sf36_bp01 = .) and (sf36_bp02 < 0 or sf36_bp02 = .) and
		(sf36_sf01 < 0 or sf36_sf01 = .) and (sf36_sf02 < 0 or sf36_sf02 = .) and (sf36_mh01 < 0 or sf36_mh01 = .) and (sf36_mh02 < 0 or sf36_mh02 = .) and
		(sf36_mh03 < 0 or sf36_mh03 = .) and (sf36_mh04 < 0 or sf36_mh04 = .) and (sf36_mh05 < 0 or sf36_mh05 = .) and (sf36_sfht < 0 or sf36_sfht = .)
		then m12_sf36 = .;
	else if (sf36_gh01 < 0 or sf36_gh01 = . or sf36_gh02 < 0 or sf36_gh02 = . or sf36_gh03 < 0 or sf36_gh03 = . or sf36_gh04 < 0 or sf36_gh04 = . or
		sf36_gh05 < 0 or sf36_gh05 = . or sf36_pf01 < 0 or sf36_pf01 = . or sf36_pf02 < 0 or sf36_pf02 = . or sf36_pf03 < 0 or sf36_pf03 = . or
		sf36_pf04 < 0 or sf36_pf04 = . or sf36_pf05 < 0 or sf36_pf05 = . or sf36_pf06 < 0 or sf36_pf06 = . or sf36_pf07 < 0 or sf36_pf07 = . or
		sf36_pf08 < 0 or sf36_pf08 = . or sf36_pf09 < 0 or sf36_pf09 = . or sf36_pf10 < 0 or sf36_pf10 = . or sf36_rp01 < 0 or sf36_rp01 = . or
		sf36_rp02 < 0 or sf36_rp02 = . or sf36_rp03 < 0 or sf36_rp03 = . or sf36_rp04 < 0 or sf36_rp04 = . or sf36_re01 < 0 or sf36_re01 = . or
		sf36_re02 < 0 or sf36_re02 = . or sf36_re03 < 0 or sf36_re03 = . or sf36_bp01 < 0 or sf36_bp01 = . or sf36_bp02 < 0 or sf36_bp02 = . or
		sf36_sf01 < 0 or sf36_sf01 = . or sf36_sf02 < 0 or sf36_sf02 = . or sf36_mh01 < 0 or sf36_mh01 = . or sf36_mh02 < 0 or sf36_mh02 = . or
		sf36_mh03 < 0 or sf36_mh03 = . or sf36_mh04 < 0 or sf36_mh04 = . or sf36_mh05 < 0 or sf36_mh05 = . or sf36_sfht < 0 or sf36_sfht = .)
		then m12_sf36 = 0;
	if m12_sf36 = 0 then m12_sf36_nmiss = nmiss(of sf36_gh01--sf36_gh05); else m12_sf36_nmiss = 0;
	if shq_sitread6 ge 0 and shq_sitread6 ne . and shq_watchingtv6 ge 0 and shq_watchingtv6 ne . and shq_sitinactive6 ge 0 and shq_sitinactive6 ne . and
		shq_ridingforhour6 ge 0 and shq_ridingforhour6 ne . and shq_lyingdown6 ge 0 and shq_lyingdown6 ne . and shq_sittalk6 ge 0 and shq_sittalk6 ne . and
		shq_afterlunch6 ge 0 and shq_afterlunch6 ne . and shq_stoppedcar6 ge 0 and shq_stoppedcar6 ne . and (shq_driving6 ge 0 or shq_driving6 = -8) and shq_driving6 ne .
		then m12_ess = 1;
	else if (shq_sitread6 < 0 or shq_sitread6 = .) and (shq_watchingtv6 < 0 or shq_watchingtv6 = .) and (shq_sitinactive6 < 0 or shq_sitinactive6 = .) and
		(shq_ridingforhour6 < 0 or shq_ridingforhour6 = .) and (shq_lyingdown6 < 0 or shq_lyingdown6 = .) and (shq_sittalk6 < 0 or shq_sittalk6 = .) and
		(shq_afterlunch6 < 0 or shq_afterlunch6 = .) and (shq_stoppedcar6 < 0 or shq_stoppedcar6 = .) and shq_driving6 = .
		then m12_ess = .;
	else if (shq_sitread6 < 0 or shq_sitread6 = . or shq_watchingtv6 < 0 or shq_watchingtv6 = . or shq_sitinactive6 < 0 or shq_sitinactive6 = . or
		shq_ridingforhour6 < 0 or shq_ridingforhour6 = . or shq_lyingdown6 < 0 or shq_lyingdown6 = . or shq_sittalk6 < 0 or shq_sittalk6 = . or
		shq_afterlunch6 < 0 or shq_afterlunch6 = . or shq_stoppedcar6 < 0 or shq_stoppedcar6 = . or shq_driving6 = .)
		then m12_ess = 0;
	if m12_ess = 0 then m12_ess_nmiss = nmiss(of shq_sitread6--shq_driving6); else m12_ess_nmiss = 0;
run;

data recode1;
	set codes1;

	keep elig_studyid base_bloods--base_ess_nmiss;
run;

data recode2;
	set codes2;

	keep elig_studyid m6_bloods--m6_ess_nmiss;
run;

data recode3;
	set codes3;

	keep elig_studyid m12_bloods--m12_ess_nmiss;
run;

data flag;
	merge recode1 recode2 recode3;
	by elig_studyid;
run;

data bestair.bacompletionflag bestair2.bacompletionflag_&sasfiledate;
	set flag;
run;

proc export data=flag dbms=csv outfile="\\rfa01\bwh-sleepepi-bestair\data\sas\checks\BestAIR Endpoint Checks &sasfiledate..csv" replace; run;
