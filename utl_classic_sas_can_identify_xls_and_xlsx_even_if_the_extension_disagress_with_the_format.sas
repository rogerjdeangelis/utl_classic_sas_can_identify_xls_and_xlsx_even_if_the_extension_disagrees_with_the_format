Classic SAS can identify xls and xlsx even if the extension disagress with the format

github
https://goo.gl/GxiyU8
https://github.com/rogerjdeangelis/utl_classic_sas_can_identify_xls_and_xlsx_even_if_the_extension_disagress_with_the_format

   I don't use 'proc import/export', wish SAS would deprecate.

   Two solutions

       1. These crossed formats work in classic SAS
         libname xel "d:/xls/xlsx_formatted.xls";     * xls extension on xlsx formatted workbook;
         libname xel "d:/xls/xls_formatted.xlsx";     * xlsx extension on xls formatted workbook;

       2. Examine bytes 47-49 of workbook header for string 'xml'
          Fix incorrect extension copy d:/xls/xlsx_formatted.xls  to d:/xls/xlsx_formatted.xls

see
https://goo.gl/BC7Xrr
https://communities.sas.com/t5/Base-SAS-Programming/import-excels-whose-format-and-extension-don-t-match/m-p/435907

INPUT
=====

  Create the two workbooks below then change to wrong extensions

   %utlfkil(d:/xls/xlsx_formatted.xlsx);
   libname xel "d:/xls/xlsx_formatted.xlsx";
   data xel.xlsx_formatted;
    set sashelp.class;
   run;quit;
   libname xel clear;

   %utlfkil(d:/xls/xls_formatted.xls);
   libname xel "d:/xls/xls_formatted.xls";
   data xel.xls_formatted;
     set sashelp.class;
   run;quit;
   libname xel clear;

  Rename first workbook to
      d:/xls/xls_formatted.xls  -> d:/xls/xls_formatted.xlsx
      d:/xls/xlsx_formatted.xlsx  -> d:/xls/xlsx_formatted.xls


   How to determine the format when the extension may be wrong
   NOTE bytes 47-49 have 'xml' this is an xlsx workbook


   d:/xls/xlsx_formatted.xlsx
    --- Record Number ---  1   ---  Record Length ---- 100

                                              NOTE XML
                                                 vvv
                                                 vvv
   PK..........!.....^...<.......[Content_Types].xml ...(..............................................
   1...5....10...15...20...25...30...35...40...45...50...55...60...65...70...75...80...85...90...95...1
   540010000000209DFA5000300010C054667667557767527662AC02A000000000000000000000000000000000000000000000
   0B344060800010C7C8E100C40030F1B3FE45E4F49053DE8DC02B180020000000000000000000000000000000000000000000


   d:/xls/xls_formatted.xls
    --- Record Number ---  1   ---  Record Length ---- 100

   .......................>...........................................................................
   1...5....10...15...20...25...30...35...40...45...50...55...60...65...70...75...80...85...90...95...1
   DC1EAB1E00000000000000003000FF00000000000000000000000000010010000000FFFF00000000FFFFFFFFFFFFFFFFFFFF
   0F1011A10000000000000000E030EF90600000000000100000000000000050001000EFFF00001000FFFFFFFFFFFFFFFFFFFF



PROCESS
=======

  1. These crossed formats work automatically in classic SAS

    * reading xlsx formatted with wron xls extension;
    libname xel "d:/xls/xlsx_formatted.xls";
    data class;
       set xel.xlsx_formatted;
    run;quit;
    libname xel clear;

    There were 19 observations read from the data set XEL.xls_formatted.
    The data set WORK.CLASS has 19 observations and 5 variables.

    * reading xlsx formatted with wron xls extension;
    libname xel "d:/xls/xls_formatted.xlsx";
    data class;
       set xel.xls_formatted;
    run;quit;
    libname xel clear;

    NOTE: There were 19 observations read from the data set XEL.xls_formatted.
    NOTE: The data set WORK.CLASS has 19 observations and 5 variables.


 2. Examine bytes 47-49 of workbook header for string 'xml';

    %let fyl=d:/xls/xlsx_formatted.xls; * wrong extension;
    data _null_;
      if _n_=0 then do;
         %let rc=%sysfunc(dosubl('
           %symdel ext / nowarn;
           filename fix "&fyl" lrecl=100 recfm=f;
           data _null_;
             infile fix;
             input;
             if substr(_infile_,47,3)="xml" then call symputx("ext","xlsx");
             else call symputx("ext","xls");
             stop;
           run;quit;
         '));
         retain ext "&ext";
      end;
      rc=dosubl('
        %let fylout=%scan(&fyl.,1,%str(.))..&ext.z;
        %put &=fylout;
        data _null_;
           infile "&fyl" lrecl=256 recfm=F length=length eof=eof unbuf;
           file "&fylout" lrecl=256 recfm=N;
           input;
           put _infile_ $varying256. length;
           return;
         eof:
           stop;
        run;
      ');

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;


  Create the two workbooks below athen change to the wrong extensions

   %utlfkil(d:/xls/xlsx_formatted.xlsx);
   libname xel "d:/xls/xlsx_formatted.xlsx";
   data xel.xlsx_formatted;
    set sashelp.class;
   run;quit;
   libname xel clear;

   %utlfkil(d:/xls/xls_formatted.xls);
   libname xel "d:/xls/xls_formatted.xls";
   data xel.xls_formatted;
     set sashelp.class;
   run;quit;
   libname xel clear;

  Rename first workbook to
      d:/xls/xls_formatted.xls  -> d:/xls/xls_formatted.xlsx
      d:/xls/xlsx_formatted.xlsx  -> d:/xls/xlsx_formatted.xls


   How to determine the format when the extension may be wrong
   NOTE bytes 47-49 have 'xml' this is an xlsx workbook


   d:/xls/xlsx_formatted.xlsx
    --- Record Number ---  1   ---  Record Length ---- 100

                                              NOTE XML
                                                 vvv
                                                 vvv
   PK..........!.....^...<.......[Content_Types].xml ...(..............................................
   1...5....10...15...20...25...30...35...40...45...50...55...60...65...70...75...80...85...90...95...1
   540010000000209DFA5000300010C054667667557767527662AC02A000000000000000000000000000000000000000000000
   0B344060800010C7C8E100C40030F1B3FE45E4F49053DE8DC02B180020000000000000000000000000000000000000000000


   d:/xls/xls_formatted.xls
    --- Record Number ---  1   ---  Record Length ---- 100

   .......................>...........................................................................
   1...5....10...15...20...25...30...35...40...45...50...55...60...65...70...75...80...85...90...95...1
   DC1EAB1E00000000000000003000FF00000000000000000000000000010010000000FFFF00000000FFFFFFFFFFFFFFFFFFFF
   0F1011A10000000000000000E030EF90600000000000100000000000000050001000EFFF00001000FFFFFFFFFFFFFFFFFFFF


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;

same as above


  1. These crossed formats work automatically in classic SAS

    * reading xlsx formatted with wron xls extension;
    libname xel "d:/xls/xlsx_formatted.xls";
    data class;
       set xel.xlsx_formatted;
    run;quit;
    libname xel clear;

    There were 19 observations read from the data set XEL.xls_formatted.
    The data set WORK.CLASS has 19 observations and 5 variables.

    * reading xlsx formatted with wron xls extension;
    libname xel "d:/xls/xls_formatted.xlsx";
    data class;
       set xel.xls_formatted;
    run;quit;
    libname xel clear;

    NOTE: There were 19 observations read from the data set XEL.xls_formatted.
    NOTE: The data set WORK.CLASS has 19 observations and 5 variables.


 2. Examine bytes 47-49 of workbook header for string 'xml';

    %let fyl=d:/xls/xlsx_formatted.xls; * wrong extension;
    data _null_;
      if _n_=0 then do;
         %let rc=%sysfunc(dosubl('
           %symdel ext / nowarn;
           filename fix "&fyl" lrecl=100 recfm=f;
           data _null_;
             infile fix;
             input;
             if substr(_infile_,47,3)="xml" then call symputx("ext","xlsx");
             else call symputx("ext","xls");
             stop;
           run;quit;
         '));
         retain ext "&ext";
      end;
      rc=dosubl('
        %let fylout=%scan(&fyl.,1,%str(.))..&ext.z;
        %put &=fylout;
        data _null_;
           infile "&fyl" lrecl=256 recfm=F length=length eof=eof unbuf;
           file "&fylout" lrecl=256 recfm=N;
           input;
           put _infile_ $varying256. length;
           return;
         eof:
           stop;
        run;
      ');


