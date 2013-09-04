## September 4, 2013

### Changes
  - bestair endpoint completion flag.sas
    - Refactor datasteps "codes2" and "codes3" using "endpointcheck_macro".
    - Combine datasteps "codes2" and "codes3" (6- and 12-month follow-up visit data) and differentiate visits at output.


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
