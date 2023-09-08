// Programa   : NMADDFIELDS_2107
// Fecha/Hora : 01/07/2021 11:03:42
// Propósito  : Agregar Campos en Release 21_03
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lRun)
  LOCAL cId   :="ADDNMFIELD2106_29"
  LOCAL oData,cWhere,cSql,I,cCodigo,cDescri,lRun
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL oFrm,cUrl,cWhere,oTable,oDataC
  LOCAL aFields:={}
  LOCAL cCodigo,cDescri,cSql,lRun,aFields,cNumEje
  LOCAL cFile :=cId+oDp:cDsnData+".ADD"

  DEFAULT lRun:=.F.

  IF FILE("DATADBF\DPTABLAS.DBF") .AND. FILE(cFile) .AND. !lRun
     RETURN .T.
  ENDIF

  // no tiene diccionario de datos
  IF !FILE("DATADBF\DPTABLAS.DBF") .AND. lRun
     RETURN .F.
  ENDIF
  
  RELEASEDATASET()

  oData:=DATASET(cId,"ALL")

  IF oData:Get(cId,"")<>cId .OR. lRun
     oData:End()
  ELSE
     oData:End()
     RETURN
  ENDIF

  IF oDp:lCrearTablas .OR. Empty(oDb:GetTables())
     oData:=DATASET(cId,"ALL")
     oData:Set(cId,cId)
     oData:Save()
     oData:End()
     DPWRITE(cFile,cFile)
     RETURN .T.
  ENDIF

  oFrm:=MSGRUNVIEW("Actualizando Base de Datos R:21.07")

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  //                                     1234567890
  EJECUTAR("DPCAMPOSADD" ,"NMTRABAJADOR","VEHICULOD" ,"C",250,0,"Datos del Vehículo",NIL,.T.,.F.)
  EJECUTAR("DPCAMPOSADD" ,"NMTRABAJADOR","SALARIOD"  ,"N",010,2,"Sueldo en Divisa") // ,NIL,.T.,.F.)

  EJECUTAR("DPCAMPOSADD" ,"NMCONCEPTOS" ,"CON_CATORC","L",001,0,"Catorcenal",NIL,.T.,.F.)
  EJECUTAR("SETFIELDLONG","NMCONCEPTOS" ,"CON_TIPNOM",5)

  oDp:nLenDep:=LEN(SQLGET("DPDPTO","DEP_CODIGO"))

  EJECUTAR("SETFIELDLONG","NMTRABAJADOR","COD_DPTO",oDp:nLenDep)

  EJECUTAR("DPLINKADD","DPDPTO","NMTRABAJADOR","DEP_CODIGO","COD_DPTO",.F.,.F.,.F.)

  EJECUTAR("SETFIELDLONG","NMTRABAJADOR","COD_DPTO",oDp:nLenDep)

  oDp:nLenDepTra:=LEN(SQLGET("NMTRABAJADOR","COD_DPTO"))

  SQLDELETE("DPLINK","LNK_TABLES"+GetWhere("=","DPDPTO")+" OR LNK_TABLED"+GetWhere("=","DPDPTO"))

  EJECUTAR("DPDROPALL_FK",oDp:cDsnData,{"DPDPTO","NMTRABAJADOR"} )
  EJECUTAR("DPDROP_FK","DPDPTO"      ,NIL,.F.,.T.)
  EJECUTAR("DPDROP_FK","NMTRABAJADOR",NIL,.F.,.T.)
    
  
  EJECUTAR("DPLINKADD","NMFECHAS" ,"NMRECIBOS"    ,"FCH_CODSUC,FCH_NUMERO","REC_CODSUC,REC_NUMFCH",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD","NMRECIBOS","NMGRABAR"     ,"REC_CODSUC,REC_NUMERO","GRA_CODSUC,GRA_NUMREC",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD","NMRECIBOS","NMHISTORICO"  ,"REC_CODSUC,REC_NUMERO","HIS_CODSUC,HIS_NUMREC",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD","NMRECIBOS","NMTABPRES"    ,"REC_CODSUC,REC_NUMERO","PRE_CODSUC,PRE_NUMREC",.T.,.T.,.T.)


  EJECUTAR("DPLINKADD","NMRECIBOS","NMFECHAS"     ,"REC_CODSUC,REC_NUMFCH","FCH_CODSUC,FCH_NUMERO",.F.,.F.,.F.)
  EJECUTAR("DPLINKADD","NMRECIBOS","NMUNDFUNC"    ,"REC_CODUND"           ,"CEN_CODIGO"           ,.F.,.F.,.F.)
  EJECUTAR("DPLINKADD","NMRECIBOS","DPDPTO"       ,"REC_CODDEP"           ,"DEP_CODIGO"           ,.F.,.F.,.F.)
  EJECUTAR("DPLINKADD","NMRECIBOS","NMCUOTASGUARD","REC_CODSUC,REC_NUMERO","CMG_CODSUC,CMG_RECNUM",.F.,.F.,.F.)
  EJECUTAR("DPLINKADD","NMRECIBOS","NMTRABAJADOR" ,"REC_CODTRA"           ,"CODIGO"               ,.F.,.F.,.F.)

//EJECUTAR("DPLINKADD","NMRECIBOS","NMFECHAS" ,"REC_CODSUC,REC_NUMFCH","FCH_CODSUC,FCH_NUMERO",.F.,.F.,.F.)
//EJECUTAR("DPLINKADD","NMRECIBOS","DPDPTO"   ,"REC_CODDEP"           ,"DEP_CODIGO"           ,.F.,.F.,.F.)
  
  EJECUTAR("DPLINKADD","DPDPTO","NMTRABAJADOR","DEP_CODIGO","COD_DPTO",.F.,.F.,.F.)

  EJECUTAR("DPDPTO_DPDPTO")

  EJECUTAR("DPCAMPOSADD","DPBRW","BRW_PERIOD","C",20,0,"Periodo")

  EJECUTAR("NMADDCAMPOSOP")

  EJECUTAR("NMJORNADAS_ADD")

  EJECUTAR("NMSETFECHA_EGR")
 

  SQLUPDATE("NMFECHAS" ,"FCH_CODSUC",oDp:cSucursal,"FCH_CODSUC"+GetWhere("=","")+" OR FCH_CODSUC IS NULL")
  SQLUPDATE("NMRECIBOS","REC_CODSUC",oDp:cSucursal,"REC_CODSUC"+GetWhere("=","")+" OR REC_CODSUC IS NULL")

  IF !EJECUTAR("DBISTABLE",NIL,"NMASISTENCIA")
     EJECUTAR("DPTABLEHIS","NMASISTENCIA",oDp:cDsnData,"_HIS",.F.)
  ENDIF

  EJECUTAR("NMTURNOSCREA")

  IF oDp:cType="NOM"

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"03F21"     ,"03"        ,"21"        ,"F"         ,[DPLBX("NMTURNOS.LBX")]       ,[.T.]               ,4         ,[{oDp:NMTURNOS}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","03F21"))
  ELSE

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"07F77"     ,"07"        ,"77"        ,"F"         ,[DPLBX("NMTURNOS.LBX")]       ,[.T.]               ,1         ,[{oDp:NMTURNOS}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","07F77"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"07F79"     ,"07"        ,"79"        ,"F"         ,[DPLBX("NMOTRASNM.LBX")]       ,[.T.]               ,1         ,[{oDp:NMOTRASNM}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","07F79"))



  ENDIF


  EJECUTAR("UNIQUETABLAS","NMFECHAS","FCH_CODSUC,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM")

  oData:=DATASET(cId,"ALL")
  oData:Set(cId,cId)
  oData:Save()
  oData:End()

  DPWRITE(cFile,cFile)

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

  DpMsgClose()

RETURN .T.
// EOF
