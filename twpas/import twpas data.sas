

# Add two static libraries.
# --------------
# Please enter the commit message for your changes. Everything below
# this paragraph is ignored, and an empty message aborts the commit.
# Just close the window to accept your message.
diff --git a/twpas/import twpas data.sas b/twpas/import twpas data.sas
index 46f0361..6af375c 100644
--- a/twpas/import twpas data.sas 
+++ b/twpas/import twpas data.sas 
@@ -7,15 +7,21 @@
 ***************************************************************************************;
 * IMPORT BESTAIR TWPAS DATA FROM REDCAP
 ***************************************************************************************;
+/*
+  data redcap;
+    set bestair.baredcap;
+  run;
+*/
 
   data batwpas_in;
-    set bestair.baredcap;
+    set redcap;
 
-   if 60000 le elig_studyid le 99999 and twpas_studyid > .;
+   if 60000 le elig_studyid le 99999 and twpas_studyid > 0;
 
     keep elig_studyid twpas_studyid--twpas_fabc_complete;
   run;
 
+
 ***************************************************************************************;
 * RECODE TWPAS DATA TO MATCH STANDARDS
 ***************************************************************************************;
@@ -75,50 +81,50 @@
     by elig_studyid;
 
     do;
-      House_Light_Effort = (twpas_light_hrs * 60 + twpas_light_min) * twpas_light_days;
-      House_Moderate_Effort = (twpas_moderate_hrs * 60 + twpas_moderate_min) * twpas_moderate_days;
-      Lawn_Moderate_Effort = (twpas_lawnmod_hrs * 60 + twpas_lawnmod_min) * twpas_lawnmod_days;
-      Lawn_Heavy_Effort = (twpas_lawnheavy_hrs * 60 + twpas_lawnheavy_min) * twpas_lawnheavy_days;
-      Care_Light = (twpas_carelight_hrs * 60 + twpas_carelight_min) * twpas_carelight_days;
-      Care_Moderate = (twpas_caremod_hrs * 60 + twpas_caremod_min) * twpas_caremod_days;
-      Walk_Travel = (twpas_walkget_hrs * 60 + twpas_walkget_min) * twpas_walkget_days;
-      Walk_Exercise = (twpas_walkex_hrs * 60 + twpas_walkex_min) * twpas_walkex_days;
-      Dancing = (twpas_dancing_hrs * 60 + twpas_dancing_min) * twpas_dancing_days;
-      Sports_Team = (twpas_teamsports_hrs * 60 + twpas_teamsports_min) * twpas_teamsports_days;
-      Sports_Dual = (twpas_dualsports_hrs * 60 + twpas_dualsports_min) * twpas_dualsports_days;
-      Sports_Solo = (twpas_indivact_hrs * 60 + twpas_indivact_min) * twpas_indivact_days;
-      Condition_Moderate = (twpas_condmod_hrs * 60 + twpas_condmod_min) * twpas_condmod_days;
-      Condition_Heavy = (twpas_condheavy_hrs * 60 + twpas_condheavy_min) * twpas_condheavy_days;
-      Sit_Recline = (twpas_sitrecline_hrs * 60 + twpas_sitrecline_min) * twpas_sitrecline_days;
+      House_Light_Effort = (twpas_light_hrs + (twpas_light_min/60)) * twpas_light_days;
+      House_Moderate_Effort = (twpas_moderate_hrs + (twpas_moderate_min/60)) * twpas_moderate_days;
+      Lawn_Moderate_Effort = (twpas_lawnmod_hrs + (twpas_lawnmod_min/60)) * twpas_lawnmod_days;
+      Lawn_Heavy_Effort = (twpas_lawnheavy_hrs + (twpas_lawnheavy_min/60)) * twpas_lawnheavy_days;
+      Care_Light = (twpas_carelight_hrs + (twpas_carelight_min/60)) * twpas_carelight_days;
+      Care_Moderate = (twpas_caremod_hrs + (twpas_caremod_min/60)) * twpas_caremod_days;
+      Walk_Travel = (twpas_walkget_hrs + (twpas_walkget_min/60)) * twpas_walkget_days;
+      Walk_Exercise = (twpas_walkex_hrs + (twpas_walkex_min/60)) * twpas_walkex_days;
+      Dancing = (twpas_dancing_hrs + (twpas_dancing_min/60)) * twpas_dancing_days;
+      Sports_Team = (twpas_teamsports_hrs + (twpas_teamsports_min/60)) * twpas_teamsports_days;
+      Sports_Dual = (twpas_dualsports_hrs + (twpas_dualsports_min/60)) * twpas_dualsports_days;
+      Sports_Solo = (twpas_indivact_hrs + (twpas_indivact_min/60)) * twpas_indivact_days;
+      Condition_Moderate = (twpas_condmod_hrs + (twpas_condmod_min/60)) * twpas_condmod_days;
+      Condition_Heavy = (twpas_condheavy_hrs + (twpas_condheavy_min/60)) * twpas_condheavy_days;
+      Sit_Recline = (twpas_sitrecline_hrs + (twpas_sitrecline_min/60)) * twpas_sitrecline_days;
       end;
       do;
       if twpas_worklightsit_hrs = -99
         then do;
-          Work_Light_Sit = twpas_worklightsit_days * 60;
+          Work_Light_Sit = twpas_worklightsit_days;
           end;
         else do;
-          Work_Light_Sit = (twpas_worklightsit_days * 60) * twpas_worklightsit_hrs;
+          Work_Light_Sit = twpas_worklightsit_days * twpas_worklightsit_hrs;
           end;
       if twpas_worklightstand_hrs = -99
         then do;
-          Work_Light_Stand = twpas_worklightstand_days * 60;
+          Work_Light_Stand = twpas_worklightstand_days;
           end;
         else do;
-          Work_Light_Stand = (twpas_worklightstand_days * 60) * twpas_worklightstand_hrs;
+          Work_Light_Stand = twpas_worklightstand_days * twpas_worklightstand_hrs;
           end;
       if twpas_workmod_hrs = -99
         then do;
-          Work_Moderate = twpas_workmod_days * 60;
+          Work_Moderate = twpas_workmod_days;
           end;
         else do;
-          Work_Moderate = (twpas_workmod_days * 60) * twpas_workmod_hrs;
+          Work_Moderate = twpas_workmod_days * twpas_workmod_hrs;
           end;
       if twpas_workheavy_hrs = -99
         then do;
-          Work_Heavy = twpas_workheavy_days * 60;
+          Work_Heavy = twpas_workheavy_days;
           end;
         else do;
-          Work_Heavy = (twpas_workheavy_days * 60) * twpas_workheavy_hrs;
+          Work_Heavy = twpas_workheavy_days * twpas_workheavy_hrs;
           end;
         end;
     keep elig_studyid twpas_studyid twpas_namecode twpas_studyvisit House_Light_Effort--Work_Heavy;
@@ -133,40 +139,50 @@ run;
     do;
       House_Light_METS = house_light_effort * 2.5;
       House_Moderate_METS = house_moderate_effort * 4.0;
-      Household_Total_Minutes = house_light_effort + house_moderate_effort;
+      Household_Total_Minutes = (house_light_effort + house_moderate_effort) * 60;
       Household_Total_METS = house_light_mets + house_moderate_mets;
       Lawn_Moderate_METS = lawn_moderate_effort * 4.0;
       Lawn_Heavy_METS = lawn_heavy_effort * 6.5;
-      Lawn_Total_Minutes = lawn_moderate_effort + lawn_heavy_effort;
+      Lawn_Total_Minutes = (lawn_moderate_effort + lawn_heavy_effort) * 60;
       Lawn_Total_METS = lawn_moderate_mets + lawn_heavy_mets;
       Care_Light_METS = care_light * 2.5;
       Care_Moderate_METS = care_moderate * 4.0;
-      Care_Total_Minutes = care_light + care_moderate;
+      Care_Total_Minutes = (care_light + care_moderate) * 60;
       Care_Total_METS = care_light_mets + care_moderate_mets;
       Walk_Travel_METS = walk_travel * 3.0;
       Walk_Exercise_METS = walk_exercise * 3.5;
-      Walk_Total_Minutes = walk_travel + walk_exercise;
+      Walk_Total_Minutes = (walk_travel + walk_exercise) * 60;
       Walk_Total_METS = walk_travel_mets + walk_exercise_mets;
       Dancing_METS = dancing * 5.0;
       Team_Sports_METS = sports_team * 7.0;
       Dual_Sports_METS = sports_dual * 7.0;
       Individual_Activities_METS = sports_solo * 3.5;
-      Total_Sport_Minutes = dancing + sports_team + sports_dual + sports_solo;
+      Total_Sport_Minutes = (dancing + sports_team + sports_dual + sports_solo) * 60;
       Total_Sport_METS = dancing_mets + team_sports_mets + dual_sports_mets + individual_activities_mets;
       Moderate_Conditioning_METS = condition_moderate * 5.5;
       Heavy_Conditioning_METS = condition_heavy * 7.0;
-      Conditioning_Total_Minutes = condition_moderate + condition_heavy;
+      Conditioning_Total_Minutes = (condition_moderate + condition_heavy) * 60;
       Conditioning_Total_METS = moderate_conditioning_METS + heavy_conditioning_mets;
       Leisure_METS = sit_recline * 1.0;
-      Leisure_Minutes = sit_recline;
+      Leisure_Minutes = (sit_recline) * 60;
       Work_Light_Sitting_METS = work_light_sit * 1.5;
       Work_Light_Standing_METS = work_light_stand * 2.5;
       Work_Moderate_METS = work_moderate * 3.0;
       Work_Heavy_METS = work_heavy * 7.0;
-      Work_Total_Minutes = work_light_sit + work_light_stand + work_moderate + work_heavy;
+      Work_Total_Minutes = (work_light_sit + work_light_stand + work_moderate + work_heavy) * 60;
       Work_Total_METS = work_light_sitting_mets + work_light_standing_mets + work_moderate_mets + work_heavy_mets;
+    Moderate_Total_METS = House_Moderate_METS + House_Moderate_METS + Care_Moderate_METS + Walk_Exercise_METS + Dancing_METS +
+      Individual_Activities_METS + Moderate_Conditioning_METS + Walk_Travel_METS + Work_Moderate_METS;
+    Vigorous_Total_METS = Lawn_Heavy_METS + Team_Sports_METS + Dual_Sports_METS + Heavy_Conditioning_METS + Work_Heavy_METS;
+    Total_METS = Moderate_Total_METS + Vigorous_Total_METS;
+    Daily_Mod_METS = Moderate_Total_METS / 7;
+    Daily_Vig_METS = Vigorous_Total_METS / 7;
+    Daily_METS = Total_METS / 7;
+    Total_Activity_Minutes = (Household_Total_Minutes+Lawn_Total_Minutes+Care_Total_Minutes+Walk_Total_Minutes+Total_Sport_Minutes+
+                              Conditioning_Total_Minutes+Leisure_Minutes+Work_Total_Minutes);
+    Average_Hours_Activity = Total_Activity_Minutes / (60*7);
     end;
-    keep elig_studyid twpas_studyid twpas_studyvisit House_Light_METS--Work_Total_METS;
+    keep elig_studyid twpas_studyid twpas_studyvisit House_Light_METS--Average_Hours_Activity;
   run;
 
 *******************************************************************************************;
@@ -176,3 +192,6 @@ run;
   data bestair.batwpas;
     set BestAIRMETS;
   run;
+
+  proc export data=bestairmets outfile = "\\rfa01\bwh-sleepepi-bestair\data\sas\twpas\twpasdata.csv" dbms=csv replace;
+  run;
