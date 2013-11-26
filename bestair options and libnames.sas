****************************************************************************************;
* bestair options and libnames.sas
*
* Author: Michael Rueschman
* Date:   07/09/2010
* Updated:  (see notes)
*
* Purpose:  This program contains code that is run at the beginning of each program for
*     the BestAIR study to establish common libraries and system options, include
*     commonly used macros.
****************************************************************************************;
* Notes
* 07/09/2010 - converting program to work on BWH DFA space
*
* 08/21/2013 - converting program to work on BWH RFA space dedicated to bestair
****************************************************************************************;
options source nodate nonumber nofmterr formdlim = ' ' /*fmtsearch = (bestair)*/ nomprint noxwait;

***************************************************************************************;
* Set PACT Libraries
***************************************************************************************;
%let bestairpath = \\rfa01\bwh-sleepepi-bestair\Data;
libname bestair "&bestairpath.\SAS\_datasets";
libname bestair2 "&bestairpath.\SAS\_archive";
  

*Create format dataset;
*Only perform one time from operating environment that created formats unless formats are modified;
/*
proc format library = bestair cntlout=bestair.cntlfmt;
run;
*/


*Used to import formats in any operating environment (32-bit or 64-bit) / makes fmtsearch irrelevant but cntlfmt.sas7bdat will not automatically update with bestair.formats;
proc format library = work cntlin=bestair.cntlfmt;
run;


***************************************************************************************;
* Store current date
***************************************************************************************;
data _null_;
  call symput("datetoday",put("&sysdate"d,mmddyy8.));
  call symput("date6",put("&sysdate"d,mmddyy6.));
  call symput("date10",put("&sysdate"d,mmddyy10.));
  call symput("filedate",put("&sysdate"d,yymmdd10.));
  call symput("sasfiledate",put(year("&sysdate"d),4.)||put(month("&sysdate"d),z2.)||put(day("&sysdate"d),z2.));
run;

***************************************************************************************;
* Include commonly used macros
***************************************************************************************;
*%include "&heartbeatpath.\SAS\Macro Catalog\load dce macros.sas";
*%include "&heartbeatpath.\SAS\mike\createformatcatalog cci macro (create sas format catalog from data dictionary) 2010-01-21.sas";


****************************************************************************************;
* Macro to assign variable labels and formats based on data dictionary
****************************************************************************************;
  %macro ddlabel(ds,dir,prefix=none);
    %let file = \\rfa01\BWH-SleepEpi-bestair\Data\SAS\&dir\&ds._labels.sas;
    %let dd = dd;

    * import data dictionary spreadsheet;
    proc import out=&dd
        datafile = "\\rfa01\BWH-SleepEpi-bestair\Data\SAS\bestair data dictionary.xls"
        dbms = excel2000 replace;
      mixed=yes;
      getnames = yes;
      range = "dd$";
    run;


      ************************************************************************************;
    * begin writing labeling program;
      ************************************************************************************;
    data _null_;
      file "&file";
      put "proc datasets library=work nolist;";
      put "modify &ds.;";
      put "label";
    run;

    * labels;
    data _null_;
      file "&file" MOD;
      set &dd (where=(lowcase(table) = lowcase("&ds")));
      length myput $3200.;
      if label = "" then label = name;
      %if &prefix = none %then %do;
        myput = trim(left(name)) || " = '" || trim(left(label)) || "'";
      %end;
      %else %do;
        myput = trim(left(name)) || " = '" || &prefix || trim(left(label)) || "'";
      %end;
      put myput;

      call symput('nvars',trim(left(put(_n_,best32.))));
    run;
    data _null_;
      file "&file" MOD;
      put ";";
      put "  ";
      put "format";
    run;

    * formats;
    data _null_;
      file "&file" MOD;
      set &dd (where=(lowcase(table) = lowcase("&ds")));
      length myput formatlx formatx $3200.;
      formatlx = trim(left(translate(put(formatl,4.)," ","."))) || ".";
      formatx = trim(left(format)) || trim(left(formatlx)) || trim(left(translate(put(formatd,4.)," ",".")));
      if formatx not in ("", ".", " .") then do;
        myput = trim(left(name)) || " " || trim(left(formatx));
        put myput;
      end;
    run;

    data _null_;
      file "&file" MOD;
      put ";";
      put "run;";
      put "quit;";
    run;
      ************************************************************************************;
    * end writing labeling program
    ************************************************************************************;


    * drop data dictionary dataset;
    proc datasets library=work nolist;
      delete &dd;
    quit;

    * run labeling program;
    options nosource2;
    %include "&file";
    options source2;

    options nosource nonotes;
    %put *************************************************************;
    %put * ddlabel macro completed for table &ds..;
    %put * There were &nvars variables in the data dictionary.;
    %put *************************************************************;
    options source notes;
  %mend;






****************************************************************************************;
* Macro to log size of table and when and by whom updated in SQL Server table
****************************************************************************************;
  %macro sasupdate(tbl);
    data temp_;
      tableid = open("&tbl",'i');
      num = attrn(tableid,'nobs');
      numv = attrn(tableid,'nvars');
      mydate = datetime();
      format mydate datetime16.;
    run;

    proc sql;
      insert into hbsql.sasupdate (sasupdatedt, sasupdatetable, sasupdatenvars, sasupdatenrec, sasupdateuser)
        select mydate,"&tbl",numv, num, "&sqllogin" from temp_;

      drop table temp_;
    quit;
  %mend;


