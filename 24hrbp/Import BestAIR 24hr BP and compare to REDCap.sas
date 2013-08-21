***************************************************************************************;
* Import BestAIR 24hr BP.sas
*
* Created:		09/01/2011
* Last updated: 04/01/2013 * see notes
* Author:		Michael Rueschman
*
***************************************************************************************;
* Purpose:
*	This program imports data from Ambulatory 24HR Blood Pressure reports for the
*		BestAIR study.
***************************************************************************************;
***************************************************************************************;
* NOTES:
*				04/01/2013 - Added comments.
*								Updated by: Kevin Gleason
*
***************************************************************************************;

****************************************************************************************;
*  ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\bestair options and libnames.sas";


***************************************************************************************;
* ESTABLISH TEMPORARY NETWORK DRIVE
***************************************************************************************;
x net use y: /d;
x net use y: "\\rfa01\BWH-SleepEpi-bestair\Data\24BP\Scored" /P:No;


***************************************************************************************;
* READ IN SCORED REPORTS FROM DCESLEEPSVR
***************************************************************************************;
	* get list of directories in scored folder;
	filename scored pipe 'dir y:\ /b';

	* within each directory, read in report file named foldername + .abp;
	data reportlist;
		length studyid 8. timepoint 3.;
		infile scored truncover;
		input folder $30. ;

		studyid = input(substr(folder,3,5),5.);
		timepoint = input(substr(folder,12,2),3.);

	run;

	* import dates for 24-hr bp using dummy file;
	data bpdates;
		set reportlist;

		file2read = "y:\" || trim(left(folder));
		infile dummy filevar=file2read end=done truncover firstobs=18 obs=18 /*lrecl=256*/;

		format bpdate $20.;

		do while(not done);
			input bpdate $20.;
			output;
		end;
	run;

	*drop file name;
	data bpdates2;
		set bpdates;

		format bp24date mmddyy8.;

		bp24date = input(bpdate,mmddyy8.);

		drop folder bpdate;
	run;


	* import all data for 24-hr bp;
	data bpdata;
		set reportlist;

		file2read = "y:\" || trim(left(folder));
		infile dummy filevar=file2read end=done truncover delimiter=',' firstobs=52 /*lrecl=256*/;

		format hr min sys map dia pulse error comment $20.;

		do while(not done);
			input hr min sys map dia pulse error comment;
			if dia > . then output;
		end;
	run;

	*prepare and format bp data into table;
	data bp2;
		set bpdata;

		*combine hours and minutes and express as one variable time-formatted;
		hour = input(hr,8.);
		minute = input(min,8.);
		time = hms(hour,min,0);
		format time time6.;

		sysall = input(sys,8.);
		diaall = input(dia,8.);
		mapall = input(map,8.);
		heartall = input(pulse,8.);

		*use SAS standard "." for invalid bp readings;
		if sysall > 0 and diaall > 0 then valid = 1;

		if valid ne 1 then do;
			sysall = .;
			diaall = .;
			mapall = .;
			heartall = .;
		end;

		*create pulse pressure variable as difference between systolic and diastolic measurements;
		ppall = sysall - diaall;

		*differentiate between Sleep and Wake readings;
		if comment = '"Sleeping"' and valid = 1 then sleep = 1;
		else if valid = 1 then wake = 1;

		if sleep = 1 then do;
			syssleep = sysall;
			diasleep = diaall;
			mapsleep = mapall;
			ppsleep = ppall;
			heartsleep = heartall;
			sleeptime = time;
		end;

		if wake = 1 then do;
			syswake = sysall;
			diawake = diaall;
			mapwake = mapall;
			ppwake = ppall;
			heartwake = heartall;
		end;

		*drop unwanted variables;
		drop hr min hour minute sys map dia pulse folder;
	run;

	*sort to ensure bp readings are organized by studyid and timepoint;
	proc sort data=bp2;
		by studyid timepoint;
	run;

	*use 3 temporary tables to create start and endtimes for each 24-hr bp period;
	data bp3;
		set bp2;
		by studyid timepoint;

		format sorter 8.2;
		sorter = (studyid + timepoint/120);
	run;

	data bp4 (keep=studyid timepoint starttime);
		set bp3;
		by sorter;

		rename time = starttime;
		if first.sorter then output;
	run;

	data bp5 (keep=studyid timepoint endtime);
		set bp3;
		by sorter;

		rename time = endtime;
		if last.sorter then output;
	run;

	*group sleep measurements together;
	proc sort data=bp3;
		by studyid timepoint sleep;
	run;

	*use two temporary tables to gather sleep start and end times;
	data bp6 (keep=studyid timepoint startsleep);
		set bp3;
		by studyid timepoint sleep;

		rename time = startsleep;
		if sleep = 1 and first.sleep then output;

	run;

	data bp7 (keep=studyid timepoint endsleep);
		set bp3;
		by studyid timepoint sleep;

		rename time = endsleep;
		if sleep = 1 and last.sleep then output;
	run;

	*merge temporary tables created in previous steps;
	data bp8;
		merge bp4 bp5 bp6 bp7;
		by studyid timepoint;
	run;

	*create formated table with some additional variables of statistical calculations such as mean, standard deviation, etc.;
	proc sql;
		create table bp9 as

		(
		select 	studyid,
				timepoint,
				count(studyid) as nreadings,
				sum(valid) as nvalid,
				count(valid)/count(studyid)*100 as pctvalid format 5.1,
				sum(sleep) as nsleep,
				sum(wake) as nwake,

				/*all time*/
				avg(sysall) as sysallmean format 5.1,
				std(sysall) as sysallsd format 5.1,
				min(sysall) as sysallmin format 5.1,
				max(sysall) as sysallmax format 5.1,
				avg(diaall) as diaallmean format 5.1,
				std(diaall) as diaallsd format 5.1,
				min(diaall) as diaallmin format 5.1,
				max(diaall) as diaallmax format 5.1,
				avg(mapall) as mapallmean format 5.1,
				std(mapall) as mapallsd format 5.1,
				min(mapall) as mapallmin format 5.1,
				max(mapall) as mapallmax format 5.1,
				avg((1/3)*sysall + (2/3)*diaall) as map2allmean format 5.1,
				std((1/3)*sysall + (2/3)*diaall) as map2allsd format 5.1,
				min((1/3)*sysall + (2/3)*diaall) as map2allmin format 5.1,
				max((1/3)*sysall + (2/3)*diaall) as map2allmax format 5.1,
				avg(ppall) as ppallmean format 5.1,
				std(ppall) as ppallsd format 5.1,
				min(ppall) as ppallmin format 5.1,
				max(ppall) as ppallmax format 5.1,
				avg(heartall) as heartallmean format 5.1,
				std(heartall) as heartallsd format 5.1,
				min(heartall) as heartallmin format 5.1,
				max(heartall) as heartallmax format 5.1,

				/*sleep time*/
				avg(syssleep) as syssleepmean format 5.1,
				std(syssleep) as syssleepsd format 5.1,
				min(syssleep) as syssleepmin format 5.1,
				max(syssleep) as syssleepmax format 5.1,
				avg(diasleep) as diasleepmean format 5.1,
				std(diasleep) as diasleepsd format 5.1,
				min(diasleep) as diasleepmin format 5.1,
				max(diasleep) as diasleepmax format 5.1,
				avg(mapsleep) as mapsleepmean format 5.1,
				std(mapsleep) as mapsleepsd format 5.1,
				min(mapsleep) as mapsleepmin format 5.1,
				max(mapsleep) as mapsleepmax format 5.1,
				avg((1/3)*syssleep + (2/3)*diasleep) as map2sleepmean format 5.1,
				std((1/3)*syssleep + (2/3)*diasleep) as map2sleepsd format 5.1,
				min((1/3)*syssleep + (2/3)*diasleep) as map2sleepmin format 5.1,
				max((1/3)*syssleep + (2/3)*diasleep) as map2sleepmax format 5.1,
				avg(ppsleep) as ppsleepmean format 5.1,
				std(ppsleep) as ppsleepsd format 5.1,
				min(ppsleep) as ppsleepmin format 5.1,
				max(ppsleep) as ppsleepmax format 5.1,
				avg(heartsleep) as heartsleepmean format 5.1,
				std(heartsleep) as heartsleepsd format 5.1,
				min(heartsleep) as heartsleepmin format 5.1,
				max(heartsleep) as heartsleepmax format 5.1,

				/*wake time*/
				avg(syswake) as syswakemean format 5.1,
				std(syswake) as syswakesd format 5.1,
				min(syswake) as syswakemin format 5.1,
				max(syswake) as syswakemax format 5.1,
				avg(diawake) as diawakemean format 5.1,
				std(diawake) as diawakesd format 5.1,
				min(diawake) as diawakemin format 5.1,
				max(diawake) as diawakemax format 5.1,
				avg(mapwake) as mapwakemean format 5.1,
				std(mapwake) as mapwakesd format 5.1,
				min(mapwake) as mapwakemin format 5.1,
				max(mapwake) as mapwakemax format 5.1,
				avg((1/3)*syswake + (2/3)*diawake) as map2wakemean format 5.1,
				std((1/3)*syswake + (2/3)*diawake) as map2wakesd format 5.1,
				min((1/3)*syswake + (2/3)*diawake) as map2wakemin format 5.1,
				max((1/3)*syswake + (2/3)*diawake) as map2wakemax format 5.1,
				avg(ppwake) as ppwakemean format 5.1,
				std(ppwake) as ppwakesd format 5.1,
				min(ppwake) as ppwakemin format 5.1,
				max(ppwake) as ppwakemax format 5.1,
				avg(heartwake) as heartwakemean format 5.1,
				std(heartwake) as heartwakesd format 5.1,
				min(heartwake) as heartwakemin format 5.1,
				max(heartwake) as heartwakemax format 5.1

		from bp2
		group by studyid, timepoint
		);

	quit;

	*merge pristine data and functions calculated in previous data steps;
	data bp24hr;
		merge bpdates2 bp8 bp9;
		by studyid timepoint;

		*calculate total times and compensate for start or end times after midnight;
		if starttime > endtime then timetotal = ((86400-starttime) + endtime);
		else timetotal = endtime - starttime;

		*calculate sleep times and compensate for start or end times after midnight;
		if startsleep > endsleep then sleeptotal = ((86400-startsleep) + endsleep);
		else sleeptotal = endsleep - startsleep;

		format sleeptotal timetotal time6.;

		*express times as minutes;
		totalmin = timetotal/60;
		sleepmin = sleeptotal/60;
		format totalmin sleepmin 8.;

		*calculate number of sleep and wake measurements for QC purposes, testing for 4 or more sleep, and 10 or more wake measurements;
		if nsleep ge 4 then validsleep = 1;
		else validsleep = 0;

		if nwake ge 10 then validwake = 1;
		else validwake = 0;

		if nwake ge 10 and nsleep ge 4 then validall = 1;
		else validall = 0;

		*prepare observations of 24-hr bp that pass QC testing for calculation;
		if validsleep then do;
			mapsleepvalid = map2sleepmean;
			syssleepvalid = syssleepmean;
			diasleepvalid = diasleepmean;
		end;

		if validwake then do;
			mapwakevalid = map2wakemean;
			syswakevalid = syswakemean;
			diawakevalid = diawakemean;
		end;

		*for previously validated observations of 24-hr bp (passed QC testing)
		test for non-dipping, where average sleep bp reading < 10% decrease from average wake bp reading;
		if validall then do;
			mapratiovalid = map2sleepmean / map2wakemean;
			sysratiovalid = syssleepmean / syswakemean;
			diaratiovalid = diasleepmean / diawakemean;

			if mapratiovalid > .9 then mapnondip = 1;
			else mapnondip = 0;

			if sysratiovalid > .9 then sysnondip = 1;
			else sysnondip = 0;

			if diaratiovalid > .9 then dianondip = 1;
			else dianondip = 0;
		end;

		*for all observations of 24-hr bp
		test for non-dipping, where average bp readings are less than 10% decreased during sleep from wake measurements;
		sysswratio = syssleepmean / syswakemean;
		diaswratio = diasleepmean / diawakemean;
		mapswratio = map2sleepmean / map2wakemean;
		heartswratio = heartsleepmean / heartwakemean;

		if sysswratio > .9 then sysnondipping = 1;
		else sysnondipping = 0;

		if diaswratio > .9 then dianondipping = 1;
		else dianondipping = 0;

		if mapswratio > .9 then mapnondipping = 1;
		else mapnondipping = 0;

		if heartswratio > .9 then heartnondipping = 1;
		else heartnondipping = 0;

		*calculate weighted averages for exactly 24-hours;
		if validall then do;
			bp24mapweight = (sleepmin/1440)*map2sleepmean + ((1440-sleepmin)/1440)*map2wakemean;
			bp24sbpweight = (sleepmin/1440)*syssleepmean + ((1440-sleepmin)/1440)*syswakemean;
			bp24dbpweight = (sleepmin/1440)*diasleepmean + ((1440-sleepmin)/1440)*diawakemean;
		end;

		/*format sysdip diadip mapdip percent10.1;*/

		*add dipping calculations;
		sysdip = 1-syssleepmean/syswakemean;
		diadip = 1-diasleepmean/diawakemean;
		mapdip = 1-mapsleepmean/mapwakemean;

	run;


***************************************************************************************;
* DISCONNECT NETWORK DRIVE
***************************************************************************************;
	x cd "c:\";
	x net use y: /delete ;


*****************************************************************************************;
* DATA CHECKING
*****************************************************************************************;
	proc sql;

		title "24BP: Total sleep time longer than 10 hours (confirm diary)";
		select studyid, timepoint, sleepmin from bp24hr
		where sleepmin > 600 and(
			(studyid ne 73097 and timepoint ne 6) and
			(studyid ne 82432 and timepoint ne 0) and
			(studyid ne 82570 and timepoint ne 0) and
			(studyid ne 90431 and timepoint ne 0)
			);

		title "24BP: No sleep readings? Short/bad recording or perhaps no Sleeping indicated on diary";
		select studyid, timepoint, nreadings, nsleep from bp24hr
		where nreadings > 20 and nsleep = . and(
			(studyid ne 91792 and timepoint ne 0) and/*confirmed kg 07/03/13*/
			(studyid ne 70204 and timepoint ne 6) and/*confirmed my888 12/19/12*/
			(studyid ne 82093 and timepoint ne 12)/*confirmed my888 12/19/12*/
			);

	quit;
	title;


***************************************************************************************;
* CLEAN UP DATASETS
***************************************************************************************;
	* drop variables only used for data checking;
	data bestairbp24hr;
		set bp24hr;
	run;

	proc datasets library=work nolist;
		delete bpdata bpdates bpdates2 bp9 bp2 bp3 bp4 bp5 bp6 bp7 bp8 reportlist bp24hr;
	run; quit;


*****************************************************************************************;
* APPLY LABELS
*****************************************************************************************;
	%ddlabel(BESTAIRBP24HR,24hrbp);


*******************************************************************************************;
* COMPARE TO PREVIOUS DATASET
*******************************************************************************************;
	proc compare base=bestair.bestairbp24hr compare=bestairbp24hr nomissbase transpose nosummary;
		title "24HR BP: Comparison of dataset to previous import";
		id studyid timepoint;
		title;
	run;

	*rename variables from previous dataset to match variables from current dataset;
	data redcapbp;
		set bestair.baredcap;

			timepoint  = monitorqc_studyvisit;
			studyid = elig_studyid;

		keep monitorqc_studyid--monitor_24_hr_qc_complete timepoint studyid;
		drop monitorqc_studyvisit monitorqc_studyid;

	run;

	proc sort data=redcapbp;
		by studyid timepoint;
	run;

	*delete observations of non-randomized participants from dataset;
	proc sql;
		delete
		from work.redcapbp
		where studyid = .;

		delete
		from work.redcapbp
		where timepoint = .;
	quit;

	*merge the datasets from raw data files and manually entered QC forms;
	data mergebp;
		merge bestairbp24hr(in=a) redcapbp(in=b);
		by studyid timepoint;

		if a then inabp=1;
		if b then inredcap=1;

	run;

	*delete observations where patient did not complete 24-hr bp;
	proc sql;

	delete
	from work.mergebp
	where studyid = -9;

	quit;

*****************************************************************************************;
* CREATE PERMANENT DATASETS
*****************************************************************************************;

	data bestair.bestairbp24hr bestair2.bestairbp24hr_&sasfiledate;
		set mergebp;
	run;

