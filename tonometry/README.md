tonometry
=========
A collection of SAS programs used to import and manipulate data from the sphygmacor tonometry - Pulse Wave Velocity (PWV) and Pulse Wave Analysis (PWA) - for the BestAIR study.

Title: bestair tonometry data checking and stats.sas
Purpose: This program calls "import bestair tonometry.sas" to import manipulated tonometry data, performs quality checks and calculates simple statistics.

Title: import bestair tonometry for update and check outcome variables.sas
Purpose: This program imports and manipulates tonometry data (PWA and PWV) from the BestAIR study's server using small dataset reduced to randomized participants to reduce computation time when running "update and check outcome variables.sas".

Title: import bestair tonometry.sas
Purpose: This program imports and manipulates tonometry data (PWA and PWV) from the BestAIR study's server.

Title: isolate pwv and augindex.sas
Purpose: This program imports data from the QC Tonometry forms on REDCap and calculates means for pulse wave velocity and augmentation index based on data in these forms.
