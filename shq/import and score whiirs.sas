

# Add two static libraries.
# --------------
# Please enter the commit message for your changes. Everything below
# this paragraph is ignored, and an empty message aborts the commit.
# Just close the window to accept your message.
diff --git a/shq/import and score whiirs.sas b/shq/import and score whiirs.sas
index 0f13126..f97c25b 100644
--- a/shq/import and score whiirs.sas 
+++ b/shq/import and score whiirs.sas 
@@ -6,26 +6,54 @@
 ***************************************************************************************;
 * IMPORT DATA FROM REDCAP
 ***************************************************************************************;
+  /*
+  data redcap;
+    set bestair.baredcap;
+  run;
+  */
 
   data shq_all;
-    set bestair.baredcap;
+    set redcap;
 
     if (60000 le shq_studyid le 99999 or 60000 le shq_studyid6 le 99999);
 
-    keep elig_studyid shq_studyid--sleephealth_question_v_3;
+    keep elig_studyid shq_studyid--sleephealth_question_v_4;
+  run;
+
+  proc format;
+    value shq_typnightsleep_recodef
+      0 = "0: Very Sound or Restful"
+      1 = "1: Sound or Restful"
+      2 = "2: Average Quality"
+      3 = "3: Restless"
+      4 = "4: Very Restless"
+    ;
   run;
 
 *create separate dataset for each visit;
   data redcapwhiirs_b;
     set shq_all (where=(shq_study_visit = 1));
     shq_studyvisit = 0;
+
+    *recode last question to match WHI IRS standard;
+    shq_typnightsleep = shq_typnightsleep - 1;
+    format shq_typnightsleep shq_typnightsleep_recodef.;
+
+    *exclude 7e ("sleeping pills") from calculation;
     whiirs_total = sum(of shq_trasleep--shq_trbacktosleep shq_typnightsleep);
     keep elig_studyid shq_namecode shq_studyvisit shq_trasleep--shq_typnightsleep whiirs_total;
   run;
+
   data redcapwhiirs_6or12;
     set shq_all(where=(shq_studyvisit6=2 or shq_studyvisit6=3));
     if shq_studyvisit6 = 2 then shq_studyvisit = 6;
     else shq_studyvisit = 12;
+
+    *recode last question to match WHI IRS standard;
+    shq_typnightsleep6 = shq_typnightsleep6 - 1;
+    format shq_typnightsleep6 shq_typnightsleep_recodef.;
+
+    *exclude 7e ("sleeping pills") from calculation;
     whiirs_total = sum(of shq_trasleep6--shq_trbacktosleep6 shq_typnightsleep6);
     keep elig_studyid shq_namecode6 shq_studyvisit shq_trasleep6--shq_typnightsleep6 whiirs_total;
   run;
@@ -41,8 +69,8 @@
     array whiirs_6fix {6} shq_trasleep shq_wokeupsev shq_wokeupearly shq_trbacktosleep shq_trpills shq_typnightsleep;
     do i = 1 to 6;
       whiirs_6fix{i} = redcapwhiirs6{i};
-      shq_namecode = shq_namecode6;
     end;
+    shq_namecode = shq_namecode6;
     drop shq_trasleep6--shq_typnightsleep6 shq_namecode6 i;
   run;
 
@@ -57,6 +85,22 @@
     by elig_studyid shq_studyvisit;
   run;
 
+  data whiirs;
+    set whiirs;
+    array nullifier[*] shq_trasleep--shq_trbacktosleep shq_typnightsleep;
+    
+    do i = 1 to dim(nullifier);
+      if nullifier[i] < 0 then do;
+        nullifier[i] = .;
+        whiirs_total = .;
+      end;
+    end;
+
+    drop i;
+    if shq_trpills < 0 then shq_trpills = .;
+  run;
+
+
 
 ************************************************;
 * UPDATE PERMANENT DATASETS
