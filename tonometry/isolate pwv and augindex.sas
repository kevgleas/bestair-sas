****************************************************************************************;
* ESTABLISH BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;

%include "\\Rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";

****************************************************************************************;
* IMPORT AND PROCESS TONOMETRY DATA FROM REDCAP
****************************************************************************************;

  data tonometry_in;
    set bestair.baredcap;

    keep elig_studyid rand_siteid rand_treatmentarm qctonom_studyvisit qctonom_pwv1 qctonom_pwv2 qctonom_pwv3 qctonom_pwv4 qctonom_augix1 qctonom_augix2 qctonom_aix3 qctonom_aix4;
  run;


  proc sql;

    delete
      from work.tonometry_in
      where qctonom_studyvisit not in (0,6,12);

  quit;


  data tonometry_scrub;
    set tonometry_in;

    array tonom_fixer[*] qctonom_pwv1--qctonom_aix4;
    do i =1 to dim(tonom_fixer);
      if tonom_fixer[i] < 0
        then tonom_fixer[i] = .;
    end;

  run;


  data tonometry2;
    set tonometry_scrub;

    avgpwv = MEAN(of qctonom_pwv1-qctonom_pwv4);
    avgaugix = MEAN(of qctonom_augix1-qctonom_augix2 qctonom_aix3-qctonom_aix4);

  run;

****************************************************************************************;
* EXPORT TO PERMANENT DATASETS
****************************************************************************************;

  data bestair.bestairtonometry bestair2.bestairtonometry_&sasfiledate;
    set tonometry;
  run;
