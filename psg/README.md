psg
====
A collection of SAS programs used to import and manipulate data from the Polysomnography (PSG) reports for the BestAIR study.

Title: bestair psg input statement.sas
Purpose: Move input statement for psg variables to its own file for improved legibility in main program - ("import bestair psg data.sas").

Title: bestair psg labels.sas
Purpose: Stores labels and formats for the ~1400 psg variables.

Title: bestair psg variable recodes.sas
Purpose: Renames psg variables after input statement.

Title: bestairpsgreceipt_labels.sas
Purpose: Stores labels and formats for the QC data received with psg reports.

Title: import bestair psg data.sas
Purpose: This program reads in BestAIR (PSG) sleep study data based on the standard report variables and manipulates PSG data.
