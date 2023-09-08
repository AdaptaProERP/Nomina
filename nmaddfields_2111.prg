// Programa   : NMADDFIELDS_2111
// Fecha/Hora : 01/07/2021 11:03:42
// Propósito  : Agregar Campos en Release 21_11
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lRun)
  LOCAL cId   :="ADDNMFIELD2111_07" // Ultimo Release en Construcción para Evita Solicitar Revisión de las Tablas
  LOCAL oData,cWhere,cSql,I,cCodigo,cDescri,lRun
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL oFrm,cUrl,cWhere,oTable,oDataC
  LOCAL aFields:={}
  LOCAL aFields,cNumEje
  LOCAL cFile :="ADD\"+cId+oDp:cDsnData+".ADD"
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
  IF !FILE("DATADBF\DPTABLAS.DBF") .AND. !lRun
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

  oFrm:=MSGRUNVIEW("Actualizando Base de Datos R:21.11")

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  EJECUTAR("FIXCHARSETREPLACE","NMCONCEPTOS")
  EJECUTAR("FIXCHARSETREPLACE","NMCONSTANTES")

  EJECUTAR("CREATERECORD","NMCONSTANTES",{"CNS_CODIGO","CNS_DESCRI"                    ,"CNS_TIPO","CNS_VALOR"},;
                                         {"201"      ,"Meses Antiguedad de Utilidades" ,"N"       ,"12"       },;
                                          NIL,.T.,"CNS_CODIGO"+GetWhere("=","201"))


  EJECUTAR("SETFIELDLONG","NMRESTRA","RMT_PROM_D",19,2)

  SQLUPDATE("DPCAMPOSOP","OPC_TITULO","Capacitación",[OPC_TABLE="NMTRABAJADOR" AND OPC_CAMPO="CONDICION" AND OPC_TITULO="Entrenamiento"])

  EJECUTAR("DPCAMPOSADD","NMCARGOS","CAR_ACTIVO" ,"L",01,0,"Activo","",NIL,NIL)

  SQLUPDATE("NMCARGOS","CAR_ACTIVO",.T.,"CAR_ACTIVO IS NULL")

  IF oDp:cType="SGE"

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                   ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"07C05"     ,"07"        ,"05"        ,"C	"         ,[EJECUTAR("BRNMRESTRAANUAL")],[.T.]        ,1         ,[Anual de Salarios Promedios]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","07C05"))
  ELSE

    EJECUTAR("CREATERECORD","DPMENU",{"MNU_CODIGO","MNU_MODULO","MNU_HORIZO","MNU_VERTIC","MNU_ACCION"                   ,"MNU_CONDIC" ,"MNU_TIPO","MNU_TITULO"   },;
                                     {"01C05"     ,"01"        ,"05"        ,"C	"         ,[EJECUTAR("BRNMRESTRAANUAL")],[.T.]        ,1         ,[Anual de Salarios Promedios]},;
                                     NIL,.T.,"MNU_CODIGO"+GetWhere("=","01C05"))

  ENDIF

  EJECUTAR("CREATERECORD","DPBRW",{"BRW_CODIGO"  ,"BRW_TITULO"                      ,"BRW_CODCLA"   ,"BRW_MENU","BRW_EMANAG" },;
                                  {"NMVARIAC_RES","Resumen de Variaciones por Fecha","Variaciones",.T.       ,.F.          },;
            NIL,.T.,"BRW_CODIGO"+GetWhere("=","NMVARIAC_RES"))

  EJECUTAR("DBISTABLE",oDp:cDsnData,"VIEW_NMRECIBOS",.T.)

/*
  cSql:=[ SELECT ]+CRLF+;
        [ FCH_CODSUC AS CRF_CODSUC, ]+CRLF+;               
        [ FCH_NUMERO AS CRF_NUMERO, ]+CRLF+;              
        [ SUM(IF(NMRECIBOS.REC_FORMAP="C",1,0))        AS CRF_CANCHQ,]+CRLF+;              
        [ SUM(IF(NMRECIBOS.REC_FORMAP="E",1,0))        AS CRF_CANEFE,]+CRLF+;              
        [ SUM(IF(NMRECIBOS.REC_FORMAP="T",1,0))        AS CRF_CANTRA,]+CRLF+;           
        [ SUM(REC_MTOASG)                    AS CRF_MTOASG,]+CRLF+;                    
        [ SUM(REC_MTODED)                    AS CRF_MTODED,]+CRLF+;                    
        [ SUM(REC_NETO  )                    AS CRF_NETO  ,]+CRLF+;  
        [ SUM(REC_NETO/REC_VALCAM)           AS CRF_MTODIV,]+CRLF+;   
        [ AVG(REC_VALCAM)                    AS CRF_VALCAM,]+CRLF+;           
        [ SUM(IF(NMRECIBOS.REC_FORMAP="C",REC_NETO,0)) AS CRF_MTOCHQ,]+CRLF+;              
        [ SUM(IF(NMRECIBOS.REC_FORMAP="E",REC_NETO,0)) AS CRF_MTOEFE,]+CRLF+;              
        [ SUM(IF(NMRECIBOS.REC_FORMAP="T",REC_NETO,0)) AS CRF_MTOTRA,]+CRLF+;           
        [ COUNT(*)                                     AS CRF_CANTID ]+CRLF+;               
        [ FROM NMFECHAS ]+CRLF+;                
        [ INNER JOIN NMRECIBOS       ON FCH_CODSUC=REC_CODSUC AND FCH_NUMERO=REC_NUMFCH ]+CRLF+;             
        [ INNER JOIN VIEW_NMRECIBOS  ON VIEW_NMRECIBOS.REC_CODSUC=NMRECIBOS.REC_CODSUC AND VIEW_NMRECIBOS.REC_NUMERO=NMRECIBOS.REC_NUMERO ]+CRLF+;          
        [ GROUP BY FCH_CODSUC,FCH_NUMERO ]+CRLF+;               
        [ ORDER BY FCH_CODSUC,FCH_NUMERO ]


// ? CLPCOPY(cSql)

  cCodigo:="NMFCHCANTREC"
  cDescri:="Resumen de Nóminas Actualizadas"
  lRun   :=.T.
  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  cCodigo:="NMCONCEPTOSCTA_DEB"
  cDescri:="Cuentas Contables por Conceptos de Nómina Debe"
  lRun   :=.T.
  cSql   :=[ SELECT ]+;
              [ CIC_CUENTA AS CDB_CUENTA, ]+;
              [ CIC_CTAMOD AS CDB_CTAMOD, ]+;
              [ CTA_DESCRI AS CDB_DESCRI  ]+;
              [ FROM NMCONCEPTOS_CTA ]+;
              [ INNER JOIN dpcta ON CIC_CUENTA=CTA_CODIGO AND CTA_CODMOD=CIC_CTAMOD ]+;
              [ WHERE CIC_CODINT="CUENTA"] 

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)

  cCodigo:="NMCONCEPTOSCTA_HAB"
  cDescri:="Cuentas Contables por Conceptos de Nómina Haber"
  lRun   :=.T.
  cSql   :=[ SELECT ]+;
           [ CIC_CUENTA AS CCR_CUENTA, ]+;
           [ CIC_CTAMOD AS CCR_CTAMOD, ]+;
           [ CTA_DESCRI AS CCR_DESCRI  ]+;
           [ FROM NMCONCEPTOS_CTA ]+;
           [ INNER JOIN dpcta ON CIC_CUENTA=CTA_CODIGO AND CTA_CODMOD=CIC_CTAMOD ]+;
           [ WHERE CIC_CODINT="CTACON"] 

  EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql)
*/

  EJECUTAR("SETVISTASINLIMIT0")

  EJECUTAR("SETFIELDLONG","NMPROFESION","PRF_NOMBRE" ,250)
  EJECUTAR("DPCAMPOSADD","NMPROFESION","PRF_ACTIVO" ,"L",1,0,"Activo","",NIL,NIL)
  EJECUTAR("DPCAMPOSADD","NMCARGOS"   ,"CAR_ACTIVO" ,"L",1,0,"Activo","",NIL,NIL)

  EJECUTAR("NMADDVIEW")

  oData:=DATASET(cId,"ALL")
  oData:Set(cId,cId)
  oData:Save()
  oData:End()

  DPWRITE(cFile,cFile)

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

RETURN .T.
// EOF


