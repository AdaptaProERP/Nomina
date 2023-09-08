// Programa   : NMADDFIELDS_2108
// Fecha/Hora : 01/07/2021 11:03:42
// Propósito  : Agregar Campos en Release 21_03
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lRun)
  LOCAL cId   :="ADDNMFIELD2109_31" 
  LOCAL oData,cWhere,cSql,I,cCodigo,cDescri
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL oFrm,cUrl,cWhere,oTable,oDataC
  LOCAL aFields:={}
  LOCAL cCodigo,cDescri,cSql,aFields,cNumEje
  LOCAL cFile :=cId+oDp:cDsnData+".ADD"
  LOCAL cUrl,cFileU

  DEFAULT lRun:=.F.

  IF lRun
     FERASE(cFile)
     cId   :=cId+"1"
     cFile :=cId+oDp:cDsnData+".ADD"
  ENDIF

  IF FILE("DATADBF\DPTABLAS.DBF") .AND. FILE(cFile) .AND. !lRun
     RETURN .T.
  ENDIF

  // no tiene diccionario de datos
//  IF !FILE("DATADBF\DPTABLAS.DBF") .AND. !lRun
//     RETURN .F.
//  ENDIF

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

  oFrm:=MSGRUNVIEW("Actualizando Base de Datos R:21.08")

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  EJECUTAR("DPCAMPOSADD","DPTABMON","MON_CODEQI","C",003,0,"Moneda Equivalente","",.T.,"BsD",[&oDp:cMoneda]) 
  EJECUTAR("DPCAMPOSADD","DPTABMON","MON_FILURL","C",250,0,"Sitio Descarga del Archivo")

  cUrl  :="https://www.bcv.org.ve/"
  cFileU:="https://www.bcv.org.ve/sites/default/files/indicadores_sector_externo/2_1_1_tdc.xlsx"

  EJECUTAR("CREATERECORD","DPTABMON",{"MON_CODIGO"  ,"MON_DESCRI"   ,"MON_APLICA"     ,"MON_FILURL","MON_URL","MON_CODPRC","MON_ACTIVO"},;
                                     {"DBC"         ,"Dolar BCV http://www.bcv.org.ve/ ","*"       ,cFileU   ,cUrl      ,"DPHISTABMOBBCV", .T.  },;
                                       NIL,.T.,"MON_CODIGO"+GetWhere("=","DBC"))


  SQLUPDATE("DPCAJAINST","ICJ_CODMON","BSD",GetWhereOr("ICJ_CODMON",{"BS","Bs","BSF","BSS","BsS"}))
  SQLUPDATE("DPCAJAINST","ICJ_CODMON","DBC",GetWhereOr("ICJ_CODIGO",{"ZEL","PAY","DOL"}))
  SQLUPDATE("DPCAJAINST","ICJ_CODMON","EBC",GetWhereOr("ICJ_CODIGO",{"EUR"}))
	
  //                                     1234567890
  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_CODMON"  ,"C",003,0,"Moneda",NIL,.T.,NIL,"&oDp:cMoneda") 

  SQLUPDATE("NMOTRASNM","OTR_CODMON",oDp:cMoneda,"OTR_CODMON IS NULL OR OTR_CODMON"+GetWhere("=",""))


  EJECUTAR("DPCAMPOSADD" ,"NMFECHAS","FCH_CODMON"  ,"C",003,0,"Moneda",NIL,.T.,NIL,"&oDp:cMoneda") 

  SQLUPDATE("NMFECHAS","FCH_CODMON",oDp:cMoneda,"FCH_CODMON IS NULL OR FCH_CODMON"+GetWhere("=",""))

  IF COUNT("NMOTRASNM")>0 .AND. FILE("EJEMPLO\NMOTRASNM.DBF")
    IMPORTDBF32("NMOTRASNM","EJEMPLO\NMOTRASNM.DBF",oDp:cDsnData)
  ENDIF

  IF COUNT("NMOTRASNM")>0

    EJECUTAR("CREATERECORD","NMOTRASNM",{"OTR_CODIGO","OTR_DESCRI"          ,"OTR_CODMON","OTR_PERIOD","OTR_TIPTRA" },;
                                        {"ES"        ,"Extra Nómina Semanal","DBC"        ,"Semanal"  ,"Activos"},;
                                        NIL,.T.,"OTR_CODIGO"+GetWhere("=","ES"))

    EJECUTAR("CREATERECORD","NMOTRASNM",{"OTR_CODIGO","OTR_DESCRI"          ,"OTR_CODMON" ,"OTR_PERIOD","OTR_TIPTRA" },;
                                        {"EQ"        ,"Extra Nómina Quincenal","DBC"      ,"Quincenal"   ,"Activos"    },;
                                         NIL,.T.,"OTR_CODIGO"+GetWhere("=","EQ"))

    EJECUTAR("CREATERECORD","NMOTRASNM",{"OTR_CODIGO","OTR_DESCRI"          ,"OTR_CODMON" ,"OTR_PERIOD","OTR_TIPTRA" },;
                                        {"EM"        ,"Extra Nómina Mensual","DBC"        ,"Mensual"    ,"Activos"    },;
                                         NIL,.T.,"OTR_CODIGO"+GetWhere("=","EM"))

  ENDIF

  EJECUTAR("DPCAMPOSADD","NMFECHAS","FCH_NUMDOC" ,"C",20,0,"Documento CxP"       ,"",NIL,NIL)


  IF oDp:cType="NOM"

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"01O58"     ,"01"        ,"58"        ,"O"         ,[EJECUTAR("NMTRABAJADOREDIT")],[.T.]               ,4         ,[{oDP:DPEXPTAREASDEF}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","01O58"))
   
    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"07O97"     ,"07"        ,"97"        ,"O"         ,[EJECUTAR("NMTRABAJADOREDIT")],[.T.]               ,4         ,[Edición Vertical de Trabajadores]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","07O97"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"             ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"03F40"     ,"03"        ,"40"        ,"F"         ,[EJECUTAR("DPEXPTEMAS")],[]                   ,1         ,[Temas y Actividades del Expediente]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","03F40"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"03F41"     ,"03"        ,"41"        ,"F"         ,[DPLBX("DPEXPTAREASDEF.LBX")],[]              ,1    ,[{oDP:DPEXPTAREASDEF}]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","03F41"))

    EJECUTAR("SETFIELDLONG","DPEXPTAREASDEF" ,"TDF_APLICA",15)

  ELSE


    SQLDELETE("DPMENU","MNU_TITULO"+GetWhere("=","Edición Vertical de Trabajadores")+" AND MNU_CODIGO"+GetWhere("=","01O58"))

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                  ,"MNU_CONDIC"        ,"MNU_TIPO","MNU_TITULO" },;
                                     {"07O97"     ,"07"        ,"97"        ,"O"         ,[EJECUTAR("NMTRABAJADOREDIT")],[.T.]               ,4         ,[{oDP:DPEXPTAREASDEF}]},;
                                      NIL,.T.,"MNU_CODIGO"+GetWhere("=","07O97"))
  ENDIF


  EJECUTAR("DPCAMPOSADD" ,"DPTABMON"      ,"MON_CODPRC","C",20 ,2,"Código de Proceso Automático")
  EJECUTAR("DPCAMPOSADD" ,"DPTABMON"      ,"MON_URL"   ,"C",250,2,"Dirección URL")

  SQLUPDATE("DPTABMON","MON_CODPRC","DPHISTABMOBBCV","MON_CODIGO"+GetWhere("=","DBC"))
  SQLUPDATE("DPTABMON","MON_URL"   ,"http://www.bcv.org.ve/","MON_CODIGO"+GetWhere("=","DBC"))

  SQLUPDATE("DPTABMON","MON_CODPRC","DPHISTABMOBDMON","MON_CODIGO"+GetWhere("=","DMN"))
  SQLUPDATE("DPTABMON","MON_URL"   ,"https://twitter.com/monitordolarvla?lang=es","MON_CODIGO"+GetWhere("=","DMN"))

  EJECUTAR("DPCAMPOSADD","DPTABMON","MON_CODEQI","C",003,0,"Moneda Equivalente","",.T.,"BsS",[&oDp:cMoneda]) 
  EJECUTAR("DPCAMPOSADD","DPTABMON","MON_FILURL","C",250,0,"Sitio Descarga del Archivo")

//  EJECUTAR("DPCAMPOSADD","NMRECIBOS","REC_CODMON","C",003,0,"Moneda","",.T.,"BsS",[&oDp:cMoneda]) 
//  EJECUTAR("DPCAMPOSADD","NMFECHAS" ,"FCH_VALCAM","N",019,2,"Valor Cambiario")

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"NMVARIAC","VAR_CODSUC")
     EJECUTAR("NMSETSUCURSAL")
  ENDIF

  SQLUPDATE("NMVARIAC"   ,"VAR_CODSUC",oDp:cSucursal,"VAR_CODSUC IS NULL")
  SQLUPDATE("NMHISTORICO","HIS_CODSUC",oDp:cSucursal,"HIS_CODSUC IS NULL")
  SQLUPDATE("NMFECHAS"   ,"FCH_CODSUC",oDp:cSucursal,[FCH_CODSUC IS NULL OR FCH_CODSUC=""])
  SQLUPDATE("NMRECIBOS"  ,"REC_CODSUC",oDp:cSucursal,[REC_CODSUC IS NULL OR REC_CODSUC=""])

  EJECUTAR("NMJORNADAS_ADD")

  EJECUTAR("SETNOMINADOLARIZA")

  EJECUTAR("DPLINKADD"  ,"DPTABMON"   ,"NMRECIBOS" ,"MON_CODIGO","REC_CODMON",.T.,.T.,.T.)

  EJECUTAR("CREATERECORD","DPTABMON",{"MON_CODIGO"  ,"MON_DESCRI"   ,"MON_APLICA"     ,"MON_FILURL","MON_URL","MON_CODPRC","MON_ACTIVO"},;
                                     {"BSD"         ,"Bolivar Digital","*"             ,""         ,""       ,""          , .T.  },;
                                      NIL,.T.,"MON_CODIGO"+GetWhere("=","BSD"))

  DEFAULT oDp:dFchFinRec:=CTOD("30/09/2021")

  SQLUPDATE("DPCAJAINST","ICJ_CODMON","BSD",GetWhereOr("ICJ_CODMON",{"BS","Bs","BSF","BSS","BsS"}))
  SQLUPDATE("DPCAJAINST","ICJ_CODMON","DBC",GetWhereOr("ICJ_CODIGO",{"ZEL","PAY","DOL"}))
  SQLUPDATE("DPCAJAINST","ICJ_CODMON","EBC",GetWhereOr("ICJ_CODIGO",{"EUR"}))

  EJECUTAR("ADDONADD","RECMON","Reconversión Monetaria")
  EJECUTAR("DPMODCTATABLNK","NMOTRASNM")

  EJECUTAR("NMOTRASNM_CTA")

  IF oDp:cType="NOM"

    cCodigo:="TABMONXCLI"
    cDescri:="Divisa por Otras Nóminas"
    cSql   :=[ SELECT OTR_CODMON AS CLI_CODMON,COUNT(*) FROM nmotrasnm GROUP BY OTR_CODMON ORDER BY OTR_CODMON ]
    lRun   :=.T.
    EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

    cCodigo:="NMHISMONMAXFCH"
    cDescri:="Fecha Final por Divisa                                      "
    cSql:=[ SELECT  HMN_CODIGO      AS MAX_CODIGO, ]+;
          [ MIN(HMN_FECHA)  AS MAX_DESDE, ]+;
          [ MAX(HMN_FECHA)  AS MAX_FECHA, ]+;
          [ MAX(MID(CONCAT(HMN_FECHA,HMN_HORA),11,8)) AS MAX_HORA, ]+;
          [ COUNT(*) AS MAX_CANTID ]+;
          [ FROM DPHISMON ]+;
          [ GROUP BY HMN_CODIGO ]+;
          [ ORDER BY CONCAT(HMN_FECHA,HMN_HORA) ]
    lRun   :=.T.
    EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

    cSql:=[ SELECT  ]+;
          [ HMN_CODIGO AS MAX_CODIGO,]+CRLF+;                
          [ HMN_VALOR  AS MAX_VALOR, ]+CRLF+;               
          [ MAX_FECHA,MAX_HORA       ]+CRLF+;       
          [ FROM VIEW_NMHISMONMAXFCH ]+CRLF+;                 
          [ INNER JOIN DPHISMON ON MAX_CODIGO=HMN_CODIGO AND MAX_FECHA=HMN_FECHA ]+CRLF+;
          [ GROUP BY HMN_CODIGO ]

    lRun   :=.T.
    cCodigo:="HISMONMAXVALOR"
    cDescri:="Valor Maximo Historico Divisa"    
    EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

/*
    cCodigo:="DPPROVEEDORBCO"
    cDescri:="Proveedores Cuentas Bancarias"
    lRun   :=.T.
    cSql   :=[ SELECT "" AS CBP_CODIGO,0 AS CBP_CUANTOS FROM nmrecibos LIMIT 0]
    EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)
*/

    EJECUTAR("DPCAMPOSOPCADD","DPEXPTAREASDEF","TDF_APLICA","Cliente"   ,.T.,CLR_HBLUE,.T.)
    EJECUTAR("DPCAMPOSOPCADD","DPEXPTAREASDEF","TDF_APLICA","Proveedor" ,.T.,CLR_HRED ,.T.)
    EJECUTAR("DPCAMPOSOPCADD","DPEXPTAREASDEF","TDF_APLICA","Trabajador",.T.,4227072  ,.T.)
    EJECUTAR("DPCAMPOSOPCADD","DPEXPTAREASDEF","TDF_APLICA","Todos"     ,.T.,0        ,.T.)

  ENDIF

  cCodigo:="DPCTABANCO"
  cDescri:="Cuentas Bancarias por Banco"
  lRun   :=.T.
  cSql   :=[ SELECT BCO_CODIGO AS CBC_CODIGO, COUNT(*)   AS CBC_CUANTOS FROM  dpctabanco GROUP BY BCO_CODIGO ]
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  EJECUTAR("DPCAMPOSADD","DPBANCOS"   ,"BAN_DEFNOM","M",10,0,"Definición de TXT para Generar Pagos Nómina")

  EJECUTAR("FIXCHARSETREPLACE","NMCONCEPTOS")
  EJECUTAR("FIXCHARSETREPLACE","NMCONSTANTES")

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

