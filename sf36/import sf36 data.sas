****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\data\SAS\bestair options and libnames.sas";


*program set to be run after "redcap export.sas" (bestair\Data\SAS\redcap\_components\redcap export.sas)
	as part of "Run All.sas";
*specifically, program set to run during include steps of "update and check outcome data.sas";
*if running program independently, uncomment section labeled "IMPORT EXISTING DATASET";

/*
****************************************************************************************;
* IMPORT EXISTING DATASET
****************************************************************************************;

	*create dataset by importing data from REDCap, where permanent data is stored;
	data redcap;
		set bestair.baredcap;
	run;
*/

****************************************************************************************;
* PROCESS BESTAIR SF-36 DATA FROM REDCAP
****************************************************************************************;
	*import bestair dataset from redcap and keep variables related to sf36;
	data sf36;
		set redcap;

		if 60000 le elig_studyid le 99999 and sf36_studyid > .;

		keep elig_studyid sf36_studyid--sf36_bdfa_complete;
	run;

	*delete observations missing data;
	proc sql;
		delete
		from work.sf36
		where sf36_studyid = .;

		delete
		from work.sf36
		where sf36_studyid = -9;
	quit;

	data sf36;
		set sf36;
		drop sf36_studyid;
	run;

	*create dataset of sf36 observations missing one or more data;
	data sf36_out missingcheck2;
		set sf36;
		array sf36_array (36) sf36_gh01--sf36_gh05;
			do i = 1 to 36;
			if sf36_array(i) in (-8,-9,-10) then output missingcheck2; else output sf36_out;
			end;
		drop i;
	run;

	proc sort data=sf36_out nodupkey;
		by elig_studyid sf36_studyvisit;
	run;

	proc sort data=missingcheck2 nodupkey;
		by elig_studyid sf36_studyvisit;
	run;

****************************************************************************************;
* PROCESS DATA
****************************************************************************************;

	data sf36_fix;
		set sf36_out;

		************************************************************************************************;
		*create series of indices for different categories on the sf36 needed for additional processing
		************************************************************************************************;

		*physical functioning index;

		array sf36_phys (10) sf36_pf01--sf36_pf10;
		do i=1 to 10;
			if sf36_phys(i) < 1 or sf36_phys(i) > 3 then sf36_phys(i) = .;
		end;

		pfnum = n(of sf36_pf01-sf36_pf10);
		pfmean = mean(of sf36_pf01-sf36_pf10);

		do i=1 to 10;
			if sf36_phys(i) = . then sf36_phys(i) = pfmean;
		end;

		if pfnum ge 5 then sf36_rawpf = sum(of sf36_pf01-sf36_pf10);
		sf36_pf = ((sf36_rawpf-10)/(30-10))*100;
		****************************************

		*role-physical index;

		array sf36_rolephys(4) sf36_rp01--sf36_rp04;
		do i=1 to 4;
		if sf36_rolephys(i) < 1 OR sf36_rolephys(i) > 5 then sf36_rolephys(i) = .;
		end;

		rolpnum = n(of sf36_rp01-sf36_rp04);
		rolpmean = mean(of sf36_rp01-sf36_rp04);

		do i = 1 to 4;
			if sf36_rolephys(I) = . then sf36_rolephys(I) = rolpmean;
		end;

		if rolpnum ge 2 then sf36_rawrp = sum(of sf36_rp01-sf36_rp04);
		sf36_rp = ((sf36_rawrp - 4)/(20-4)) * 100;
		******************************************

		*role-emotional index;

		array sf36_rolemo(3) sf36_re01--sf36_re03;
		do i=1 to 3;
		if sf36_rolemo(i) < 1 or sf36_rolemo(i) > 5 then sf36_rolemo(i) = .;
		end;

		rolmnum = n(of sf36_re01--sf36_re03);
		rolmmean = mean(of sf36_re01--sf36_re03);

		do i = 1 to 3;
			if sf36_rolemo(i) = . then sf36_rolemo(i) = rolmmean;
		end;

		if rolmnum ge 2 then sf36_rawre = sum(of sf36_re01--sf36_re03);
		sf36_re = ((sf36_rawre - 3)/(15-3)) * 100;
		******************************************

		*vitality index;

		array sf36_vitality(4) sf36_vt01-sf36_vt04;
		do i = 1 to 4;
			if sf36_vitality(i) < 1 or sf36_vitality(i) > 5 then sf36_vitality(i) = .;
		end;

		rvt01 = 6 - sf36_vt01;
		rvt02 = 6 - sf36_vt02;

		vitnum = n(sf36_vt01,sf36_vt02,sf36_vt03,sf36_vt04);
		vitmean = mean(rvt01,rvt02,sf36_vt03,sf36_vt04);

		array rvi(4) rvt01 rvt02 sf36_vt03 sf36_vt04;

		do i = 1 to 4;
			if rvi(i) = . then rvi(i) = vitmean;
		end;

		if vitnum ge 2 then sf36_rawvt = sum(rvt01,rvt02,sf36_vt03,sf36_vt04);
		sf36_vt = ((sf36_rawvt - 4)/(20-4)) * 100;
		******************************************

		*mental health index;

		array mhi(5) sf36_mh01-sf36_mh05;

		do i = 1 to 5;
			if mhi(i) < 1 or mhi(i) > 5 then mhi(i) = .;
		end;

		rmh03 = 6 - sf36_mh03;
		rmh05 = 6 - sf36_mh05;

		mhnum = n(sf36_mh01,sf36_mh02,sf36_mh03,sf36_mh04,sf36_mh05);
		mhmean = mean(sf36_mh01,sf36_mh02,rmh03,sf36_mh04,rmh05);

		array rmh(5) sf36_mh01 sf36_mh02 rmh03 sf36_mh04 rmh05;

		do i = 1 to 5;
			if rmh(i) = . then rmh(i) = mhmean;
		end;

		if mhnum ge 3 then sf36_rawmh = sum(sf36_mh01,sf36_mh02,rmh03,sf36_mh04,rmh05);
		sf36_mh = ((sf36_rawmh - 5)/(25-5)) * 100;
		******************************************

		*general health index;

		array ghp(5) sf36_gh01-sf36_gh05;
		do i = 1 to 5;
			if ghp(i) < 1 or ghp(i) > 5 then ghp(i) = .;
		end;

		if sf36_gh01 = 1 then rgh01 = 5;
		if sf36_gh02 = 2 then rgh01 = 4.4;
		if sf36_gh03 = 3 then rgh01 = 3.4;
		if sf36_gh04 = 4 then rgh01 = 2;
		if sf36_gh05 = 5 then rgh01 = 1;

		rgh03 = 6 - sf36_gh03;
		rgh05 = 6 - sf36_gh05;

		ghnum = n(sf36_gh01,sf36_gh02,sf36_gh03,sf36_gh04,sf36_gh05);
		ghmean = mean(rgh01,sf36_gh02,rgh03,sf36_gh04,rgh05);

		array rgh(5) rgh01 sf36_gh02 rgh03 sf36_gh04 rgh05;

		do i = 1 to 5;
			if rgh(i) = . then rgh(i) = ghmean;
		end;

		if ghnum ge 3 then sf36_rawgh = sum(rgh01,sf36_gh02,rgh03,sf36_gh04,rgh05);
		sf36_gh = ((sf36_rawgh - 5)/(25-5)) * 100;
		******************************************

		*pain index;

		if sf36_bp01 < 1 or sf36_bp01 > 6 then sf36_bp01 = .;
		if sf36_bp02 < 1 or sf36_bp02 > 5 then sf36_bp02 = .;


		* RECODES IF NEITHER bp01 OR bp02 HAS A MISSING VALUE;

		if sf36_bp01 ne . and sf36_bp02 ne . then do;

			if sf36_bp01 = 1 then rbp01 = 6;
			if sf36_bp01 = 2 then rbp01 = 5.4;
			if sf36_bp01 = 3 then rbp01 = 4.2;
			if sf36_bp01 = 4 then rbp01 = 3.1;
			if sf36_bp01 = 5 then rbp01 = 2.2;
			if sf36_bp01 = 6 then rbp01 = 1;

			if sf36_bp02 = 1 and sf36_bp01 = 1 then rbp02 = 6;
			if sf36_bp02 = 1 and 2 le sf36_bp01 le 6 then rbp02 = 5;
			if sf36_bp02 = 2 and 1 le sf36_bp01 le 6 then rbp02 = 4;
			if sf36_bp02 = 3 and 1 le sf36_bp01 le 6 then rbp02 = 3;
			if sf36_bp02 = 4 and 1 le sf36_bp01 le 6 then rbp02 = 2;
			if sf36_bp02 = 5 and 1 le sf36_bp01 le 6 then rbp02 = 1;

		end;


		* RECODES IF bp01 IS NOT MISSING AND bp02 IS MISSING;

		if sf36_bp01 ne . and sf36_bp02 = . then do;
			if sf36_bp01 = 1 then rbp01 = 6;
			if sf36_bp01 = 2 then rbp01 = 5.4;
			if sf36_bp01 = 3 then rbp01 = 4.2;
			if sf36_bp01 = 4 then rbp01 = 3.1;
			if sf36_bp01 = 5 then rbp01 = 2.2;
			if sf36_bp01 = 6 then rbp01 = 1;
			rbp02 = rbp01;

		end;


		* RECODES IF bp01 IS MISSING AND bp02 IS NOT MISSING;

		if sf36_bp01 = . and sf36_bp02 ne . then do;
			if sf36_bp02 = 1 then rbp02 = 6;
			if sf36_bp02 = 2 then rbp02 = 4.75;
			if sf36_bp02 = 3 then rbp02 = 3.5;
			if sf36_bp02 = 4 then rbp02 = 2.25;
			if sf36_bp02 = 5 then rbp02 = 1;
			rbp01 = rbp02;

		end;


		bpnum = n(sf36_bp01,sf36_bp02);

		*calculate weighted bp values;
		if bpnum ge 1 then sf36_rawbp = sum(rbp01,rbp02);
		sf36_bp = ((sf36_rawbp - 2)/(12-2)) * 100;
		******************************************

		social functioning index;

		array soc(2) sf36_sf01-sf36_sf02;

		do i = 1 to 2;
			if soc(i) < 1 or soc(i) > 5 then soc(i) = .;
		end;

		rsf01 = 6 - sf36_sf01;

		sfnum = n(sf36_sf01,sf36_sf02);
		sfmean = mean(rsf01,sf36_sf02);

		array rsf(2) rsf01 sf36_sf02;

		do i = 1 to 2;
			if rsf(i) = . then rsf(i) = sfmean;
		end;

		if sfnum ge 1 then sf36_rawsf = sum(rsf01,sf36_sf02);
		sf36_sf = ((sf36_rawsf - 2)/(10-2)) * 100;
		******************************************

		*Health Transition Item - Scored Categorically;

		if sf36_sfht < 1 or sf36_sfht > 5 then sf36_sfht = .;

	*****************************************************************;
	***               SF-36 SCALE CONSTRUCTION    			      ***;
	*****************************************************************;


	*******************************************************************;
	*  purpose: create physical and mental health index scores
	*           standardized but not normalized
	*           and standard deviations calculated with vardef=wdf
	*******************************************************************;



		**********************************************************;
		*      COMPUTE Z SCORES -- OBSERVED VALUES ARE SAMPLE DATA
		*
		*      MEAN AND SD IS U.S GENERAL POPULATION
		*      FACTOR ANALYTIC SAMPLE
		*      ALL EIGHT SCALES
		**********************************************************;

	    PF_Z=(sf36_pf -83.29094)/23.75883;
	    RP_Z=(sf36_rp -82.50964)/25.52028;
	    BP_Z=(sf36_bp -71.32527)/23.66224;
	    GH_Z=(sf36_gh -70.84570)/20.97821;
	    VT_Z=(sf36_vt -58.31411)/20.01923;
	    SF_Z=(sf36_sf -84.30250)/22.91921;
	    RE_Z=(sf36_re -87.39733)/21.43778;
	    MH_Z=(sf36_mh -74.98685)/17.75604;


		***********************************************************;
		*          COMPUTE NORM SCORES
		*          Z SCORES ARE FROM ABOVE
		**********************************************************;

		PF_norm=50+(PF_Z*10);
	    RP_norm=50+(RP_Z*10);
	    BP_norm=50+(BP_Z*10);
	    GH_norm=50+(GH_Z*10);
	    VT_norm=50+(VT_Z*10);
	    SF_norm=50+(SF_Z*10);
	    RE_norm=50+(RE_Z*10);
	    MH_norm=50+(MH_Z*10);


		***********************************************************;
		*          COMPUTE SAMPLE RAW FACTOR SCORES
		*          Z SCORES ARE FROM ABOVE
		*          SCORING COEFFICIENTS ARE FROM U.S. GENERAL POPULATION
		*          FACTOR ANALYTIC SAMPLE N=2393: HAVE ALL EIGHT SCALES
		**********************************************************;

	    agg_phys	=	(PF_Z * 0.42402)+(RP_Z * 0.35119)+(BP_Z * 0.31754)+(SF_Z * -0.00753)+
	         			(MH_Z * -0.22069)+(RE_Z * -0.19206)+(VT_Z * 0.02877)+(GH_Z * 0.24954);

	    agg_ment	=	(PF_Z * -0.22999)+(RP_Z * -0.12329)+(BP_Z * -0.09731)+(SF_Z * 0.26876)+
	         			(MH_Z * 0.48581)+(RE_Z * 0.43407)+(VT_Z * 0.23534)+(GH_Z * -0.01571);


		*****************************************;
		*          COMPUTE STANDARDIZED SCORES
		*****************************************;

	    sf36_PCS = (agg_phys*10) + 50;
	    sf36_MCS = (agg_ment*10) + 50;


		*drop unnecessary variables;
		drop rbp01 rbp02 rgh01 -- rgh05 rvt01 rvt02 rsf01
			rmh03 rmh05;

	run;

	*update permanent dataset;
	data bestair.bestairsf36 bestair2.bestairsf36;
		set sf36_fix;
	run;
