## September 9, 2013

### Changes
  - complete check questionnaires.sas
    - Eliminate unneccessary datasteps by utlizing drop= dataset option in earlier steps.


## September 4, 2013

### Changes
  - bestair endpoint completion flag.sas
    - Refactor datasteps "codes2" and "codes3" using "endpointcheck_macro".
    - Combine datasteps "codes2" and "codes3" (6- and 12-month follow-up visit data) and differentiate visits at output.
  - entry error check.sas
    - Improve efficiency by using array and calling scan() function to screen only variable names ending in "studyid" and "namecode" in respective sections, rather than series of proc transpose steps.


## September 3, 2013

### Changes
  - bestair endpoint completion flag.sas
    - Restrict original import to observations for research visits to delete proc sql step.
    - Replace 5 relabeling arrays with 1 for efficiency in "data codes1" datastep.
    - Replace long, compound if-then statements with simple code blocks that pass array and storage variable to a macro ("endpointcheck_macro") in datastep "codes1"
  -bestair_checks_macros.sas
    - Add macro for checking completion of endpoint by passing all variables of endpoint as array.
  - README.md
    - Reformat to boldface categories.


## August 28, 2013

### Changes
  - entry error check.sas
    - Add exception to check on extreme values for weight.


## August 23, 2013

### Changes
  - bestair check for missing demographic info.sas
    - Move header to README.md.
  - bestair endpoint completion flag.sas
    - Move header to README.md.
  - complete check all.sas
    - Move header to README.md.
  - complete check crfs.sas
    - Move header to README.md.
  - complete check questionnaires.sas
    - Move header to README.md.
  - entry error check.sas
    - Move header to README.md.

## July 29, 2014

### Changes
  - complete check all.sas
    - Update to reflect more up-to-date data.
  - complete check crfs.sas
    - Update to reflect more up-to-date data.
  - complete check questionnaires.sas
    - Update to reflect more up-to-date data.
