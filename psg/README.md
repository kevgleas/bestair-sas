psg
====
A collection of SAS programs used to import and manipulate data from the Polysomnography (PSG) reports for the BestAIR study.

##### [bestair psg input statement.sas](https://github.com/sleepepi/bestair-sas/blob/master/psg/bestair%20psg%20input%20statement.sas)  
Move input statement for psg variables to its own file for improved legibility in main program - ("import bestair psg data.sas").  

##### [bestair psg labels.sas](https://github.com/sleepepi/bestair-sas/blob/master/psg/bestair%20psg%20labels.sas)  
Stores labels and formats for the ~1400 psg variables.  

##### [bestair psg variable recodes.sas](https://github.com/sleepepi/bestair-sas/blob/master/psg/bestair%20psg%20variable%20recodes.sas)  
Renames psg variables after input statement.  

##### [bestairpsgreceipt_labels.sas](https://github.com/sleepepi/bestair-sas/blob/master/psg/bestairpsgreceipt_labels.sas)  
Stores labels and formats for the QC data received with psg reports.

##### [import bestair psg data.sas](https://github.com/sleepepi/bestair-sas/blob/master/psg/import%20bestair%20psg%20data.sas)  
This program reads in BestAIR (PSG) sleep study data based on the standard report variables and manipulates PSG data.  
