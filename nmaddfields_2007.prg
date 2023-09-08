// Programa   : NMADDFIELDS_2007    
// Fecha/Hora : 08/07/2020 11:03:42
// Propósito  : Agregar Campos en Release 20_01
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cId   :="NMADDFIELD2007_05",oData,cWhere,cSql,I
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL oFrm
  LOCAL aFields:={}

  oData:=DATASET(cId,"ALL")

  IF oData:Get(cId,"")<>cId 
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
     RETURN .T.
  ENDIF

  oFrm:=MSGRUNVIEW("Actualizando Base de Datos R:20.07")

  EJECUTAR("DPCAMPOSADD"   ,"NMCARGOS","CAR_ACTIVO","L",001,0,"Activo",NIL,.T.,.T.,".T.")    

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"NMRECIBOS","REC_CODSUC")
    EJECUTAR("DPSETLINKSUC")
  ENDIF

  DpMsgClose()  

  oData:=DATASET(cId,"ALL")
  oData:Set(cId,cId)
  oData:Save()
  oData:End()

RETURN .T.
// EOF




