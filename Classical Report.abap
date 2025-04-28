REPORT ZPRG1_ALV.  "Report/Program Name.

TYPES: BEGIN OF lty_vbak,   "Structure 1 Declaration.
  VBELN TYPE VBELN_VA,
  ERDAT TYPE ERDAT,
  ERZET TYPE ERZET,
  ERNAM TYPE ERNAM,
  VBTYP TYPE VBTYP,
  end of lty_vbak.      "End of Structure Declaration.

DATA int_table type TABLE OF lty_vbak.    "Declaration of Internal Table 1.
DATA warea TYPE lty_vbak.               "Declaration of Work Area 1.

TYPES: BEGIN OF lty_vbap,     "Declaring a Structure 2.
  VBELN TYPE VBELN_VA,
  POSNR TYPE POSNR_VA,
  MATNR TYPE MATNR,
  end of lty_vbap.        "End of Structure Declaration..

DATA int_table1 type  TABLE OF lty_vbap.      "Declaration of Internal Table 2.
data warea1 type lty_vbap.                "Declaration of Work Area 1.
DATA LV_FIELDCATALOG TYPE SLIS_T_FIELDCAT_ALV.    "Declaraing a field catalog.
DATA: LT_FINAL TYPE TABLE OF ZSTR_ALV.      "Declaring a finnal internal table to display data.
DATA : WA_FINAL TYPE ZSTR_ALV.              "Declaring a final work area to display data.


data lv_vbeln TYPE VBELN_VA.    "Declaring a variable to get the Order Number.

SELECT-OPTIONS : s_vbeln for lv_vbeln.    "Declaring a select option.

SELECT VBELN ERDAT ERZET ERNAM VBTYP    "Select statement to get data from the vbak table into internl table 1.
from vbak
into table int_table
where VBELN in s_vbeln.

if int_table is not initial.
select  VBELN POSNR  MATNR            "Select staatement to get data from vbap table into internal table 2.
from VBAP
INTO TABLE int_table1
for all ENTRIES IN int_table
where VBELN = int_table-VBELN.
ENDIF.

LOOP AT INT_TABLE INTO WAREA.                                 "Get data from internal table 1 into work area 1.
LOOP AT INT_TABLE1 INTO WAREA1 WHERE VBELN = WAREA-VBELN.     "Get data from internal table 2 into work area 2.
WA_FINAL-VBELN = WAREA-VBELN.
WA_FINAL-ERDAT = WAREA-ERDAT.
WA_FINAL-ERZET = WAREA-ERZET.
WA_FINAL-ERNAM = WAREA-ERNAM.
WA_FINAL-VBTYP = WAREA-VBTYP.
WA_FINAL-POSNR = WAREA1-POSNR.
WA_FINAL-MATNR = WAREA1-MATNR.
APPEND WA_FINAL TO LT_FINAL.                                  "Append the data from final work area into final internal table.
CLEAR WA_FINAL.
ENDLOOP.
ENDLOOP.



CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'        "call function module to  create field catalog.
 EXPORTING
*   I_PROGRAM_NAME               =
*   I_INTERNAL_TABNAME           =
   I_STRUCTURE_NAME             =   'ZSTR_ALV'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
*   I_INCLNAME                   =
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
  CHANGING
    CT_FIELDCAT                  =  LV_FIELDCATALOG
 EXCEPTIONS                                           "Enabling the exceptions.
   INCONSISTENT_INTERFACE       = 1
   PROGRAM_ERROR                = 2
   OTHERS                       = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'                "call function module to diplay the data in list format.
 EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
*   I_CALLBACK_PROGRAM             = ' '
*   I_CALLBACK_PF_STATUS_SET       = ' '
*   I_CALLBACK_USER_COMMAND        = ' '
*   I_STRUCTURE_NAME               =
*   IS_LAYOUT                      =
   IT_FIELDCAT                    =  LV_FIELDCATALOG
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
*   IT_SORT                        =
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
*   I_DEFAULT                      = 'X'
*   I_SAVE                         = ' '
*   IS_VARIANT                     =
*   IT_EVENTS                      =
*   IT_EVENT_EXIT                  =
*   IS_PRINT                       =
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
*   IR_SALV_LIST_ADAPTER           =
*   IT_EXCEPT_QINFO                =
*   I_SUPPRESS_EMPTY_DATA          = ABAP_FALSE
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
  TABLES
    T_OUTTAB                       = LT_FINAL           "data will be  stored in this final internal table.
 EXCEPTIONS                                             "Enabling the exceptions.
   PROGRAM_ERROR                  = 1
   OTHERS                         = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.