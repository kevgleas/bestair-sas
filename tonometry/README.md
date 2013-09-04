tonometry
=========
A collection of SAS programs used to import and manipulate data from the sphygmacor tonometry - Pulse Wave Velocity (PWV) and Pulse Wave Analysis (PWA) - for the BestAIR study.

##### [bestair tonometry data checking and stats.sas](https://github.com/sleepepi/bestair-sas/blob/master/tonometry/bestair%20tonometry%20data%20checking%20and%20stats.sas)  
This program calls "import bestair tonometry.sas" to import manipulated tonometry data, performs quality checks and calculates simple statistics.  

##### [import bestair tonometry for update and check outcome variables.sas](https://github.com/sleepepi/bestair-sas/blob/master/tonometry/import%20bestair%20tonometry%20for%20update%20and%20check%20outcome%20variables.sas)  
This program imports and manipulates tonometry data (PWA and PWV) from the BestAIR study's server using small dataset reduced to randomized participants to reduce computation time when running "update and check outcome variables.sas".  

##### [import bestair tonometry.sas](https://github.com/sleepepi/bestair-sas/blob/master/tonometry/import%20bestair%20tonometry.sas)  
This program imports and manipulates tonometry data (PWA and PWV) from the BestAIR study's server.  

##### [isolate pwv and augindex.sas](https://github.com/sleepepi/bestair-sas/blob/master/tonometry/isolate%20pwv%20and%20augindex.sas)  
This program imports data from the QC Tonometry forms on REDCap and calculates means for pulse wave velocity and augmentation index based on data in these forms.  
