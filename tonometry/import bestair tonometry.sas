****************************************************************************************;
* IMPORT BESTAIR OPTIONS AND LIBRARIES
****************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\bestair options and libnames.sas";

***************************************************************************************;
* IMPORT REDCAP DATASET OF RANDOMIZED PARTICIPANTS
***************************************************************************************;
*if not running as part of "update and check outcome variables.sas", uncomment import of REDCap data;
/*
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\redcap\_components\bestair create rand set.sas";

  *rename dataset of randomized participants to match syntax in later include steps;

  data redcap;
    set redcap_rand;
  run;
*/

***************************************************************************************;
* CALL PROGRAM TO IMPORT RAW TONOMETRY FILES
***************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\tonometry\import bestair tonometry for update and check outcome variables.sas";


***************************************************************************************;
* PERFORM ADDITIONAL PROCESSING ON DATA BY CALLING ANOTHER SAS PROGRAM
***************************************************************************************;
%include "\\rfa01\bwh-sleepepi-bestair\Data\SAS\tonometry\bestair tonometry data checking and stats.sas";
