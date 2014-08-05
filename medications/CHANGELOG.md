## August 5, 2014

### Changes

  - import bestair medications.sas
    - Refactor step that rectifies variable names to med standard.
    - Refactor step merging REDCap medications with ATC codes.
    - Delete med category count section (moved to "med frequency testing.sas).
  - med frequency testing.sas
    - Refactor medication classification section.
    - Refactor medication count by class using macro.
    - Remove rarely used (and internal testing) steps for bp and diabetes meds.



## July 30, 2014

### Changes

  - import bestair medications.sas
    - Create dataset of randomized pts to improve speed.
    - Check for meds entered in wrong place/never entered.
    - Update source for main medications dataset.
    - Add timepoint date calculations.
    - Include macros stored in another program.
    - Create main dataset from premedications.
    - Efficiently rename med time variables using macro.
    - Add time taken variables to transpose steps.
    - Improve efficiency by reducing to 1 step med class.
    - Move medication category section to new program.

## August 27, 2013

### Changes

  - import bestair medications.sas
    - Move header to README.md.
