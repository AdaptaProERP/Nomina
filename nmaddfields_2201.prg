// Programa   : NMADDFIELDS_2201
// Fecha/Hora : 01/07/2021 11:03:42
// Propósito  : Agregar Campos en Release 21_11
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lRun)
  LOCAL x     :=EJECUTAR("NMLOADCNFCHKFCH")
  LOCAL cId   :=oDp:cBdRelease
  LOCAL oData,cWhere,cSql,I,cCodigo,cDescri,lRun
  LOCAL oDb   :=OpenOdbc(oDp:cDsnData)
  LOCAL oFrm,cUrl,cWhere,oTable,oDataC
  LOCAL aFields:={}
  LOCAL aFields,cNumEje
  LOCAL cFile :="ADD\"+cId+oDp:cDsnData+".ADD"
  LOCAL cUrl,cFileU,oLink,cSql
  LOCAL aOtrNom:={"VC","VI","IN","EQ","ES","EM","UT","CT"}
  LOCAL aTipNom:={"S","C","Q","M"}
  LOCAL aNombre:={"Semanal","Catorcenal","Quincenal","Mensual"}

  DEFAULT lRun:=.T.

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

  oFrm:=MSGRUNVIEW("Actualizando Base de Datos R:22.01")

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  EJECUTAR("NMDATACREADEFAULT",.T.)

  EJECUTAR("SETFIELDEFAULT","NMTRABAJADOR","CONDICION",["A"])

  EJECUTAR("SETFIELDLONG","NMTRABAJADOR","CODIGO",12)
  EJECUTAR("SETFIELDLONG","NMPRENOMINA" ,"HIS_CODTRA",12)
  EJECUTAR("SETFIELDLONG","NMRECIBOS"   ,"REC_CODTRA",12)
  EJECUTAR("SETFIELDLONG","NMGRABAR"    ,"GRA_CODTRA",12)

  cWhere:="LNK_FIELDD"+GetWhere("=","CODIGO")+" AND LNK_TABLED"+GetWhere("=","NMTRABAJADOR")
  oLink :=OpenTable("SELECT LNK_TABLES,LNK_FIELDS FROM DPLINK WHERE "+cWhere,.T.)

  WHILE !oLink:Eof()
    EJECUTAR("SETFIELDLONG",ALLTRIM(oLink:LNK_TABLES),ALLTRIM(oLink:LNK_FIELDS),12)
    oLink:DbSkip()
  ENDDO

//  oLink:Browse()
  oLink:End()

  IF COUNT("nmjornadas")=0 .AND. FILE("datadbf\nmjornadas.dbf")
    IMPORTDBF32("NMJORNADAS","datadbf\nmjornadas.dbf",oDp:cDsnData,oDp:oSay,.T.,.T.)
  ENDIF

  EJECUTAR("NMFERIADOSLEE",.T.)
  EJECUTAR("DPCAMPOSADD" ,"NMASISTENCIA","RAS_TIPASI","C",2,0,"Tipo de Asistencia")
  EJECUTAR("DPCAMPOSADD" ,"NMTRABAJADOR","TRA_ACTIVO","L",1,0,"Registro Activo")

  SQLUPDATE("NMTRABAJADOR","TRA_ACTIVO",.T.,[LEFT(CONDICION,1)="A" OR LEFT(CONDICION,1)="V"])

  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_ACTIVO","L",1,0,"Registro Activo")
  cSql:="UPDATE NMOTRASNM SET OTR_ACTIVO=1 WHERE OTR_ACTIVO IS NULL "
  oDb:EXECUTE(cSql)

  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_PLAFIN","L",1,0,"Planificación Financiera")

  IF LEN(aOtrNom)>0
    cSql:="UPDATE NMOTRASNM SET OTR_PLAFIN=1 WHERE OTR_PLAFIN IS NULL AND "+GetWhereOr("OTR_CODIGO",aOtrNom)
    oDb:EXECUTE(cSql)
  ENDIF

  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_FCHPLF","C",05,0,"Registro Referencia Planificación Financiera")
  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_FINPLF","D",08,0,"Fecha Culminación Planificación Financiera")
  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_MTOPLF","N",19,2,"Monto Planfinicación")
  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_DIVPLF","N",19,2,"Monto Divisa Planfinicación")
  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_TIPO"  ,"C",1 ,2,"Tipo de Nómina")

  EJECUTAR("DPCAMPOSADD" ,"NMFECHAS","FCH_REGPLA"  ,"C",10,0,"Registro de Planificación")

  //                                      1234567890
  EJECUTAR("DPCAMPOSADD" ,"NMCURRICULUM","CUR_LINKED"  ,"C",250,0,"Registro en Linked-In")
  EJECUTAR("DPCAMPOSADD" ,"NMCURRICULUM","CUR_ORGCAP"  ,"C",250,0,"Origen de Captación")
  EJECUTAR("DPCAMPOSADD" ,"NMCURRICULUM","CUR_RIF"     ,"C",012,0,"RIF")
  EJECUTAR("DPCAMPOSADD" ,"NMCURRICULUM","CUR_FECHA"   ,"D",008,0,"Fecha de Registro")

  EJECUTAR("DPCAMPOSADD" ,"NMCONCEPTOS","CON_VARVER" ,"L",01,0,"Variación en Vertical")
  SQLUPDATE("NMCONCEPTOS","CON_VARVER",.T.,"CON_MENSAJ"+GetWhere("<>","")+" AND CON_VARVER IS NULL")

  EJECUTAR("DPCAMPOSADD" ,"NMCONCEPTOS","CON_PICTURE","C",40,0,"Formato Input")

  cSql:=[UPDATE NMCONCEPTOS SET CON_PICTURE="" WHERE CON_PICTURE IS NULL]
  oDb:EXECUTE(cSql)

  EJECUTAR("DPDROP_FK","NMOTRASNM")
  EJECUTAR("SETPRIMARYKEY","NMOTRASNM","OTR_TIPO,OTR_CODIGO",.T.)

  cSql:=[UPDATE NMOTRASNM SET OTR_TIPO="O" WHERE OTR_TIPO]+GetWhere("=","")+[ OR OTR_TIPO  IS NULL]
  oDb:EXECUTE(cSql)

  EJECUTAR("DPCAMPOSADD" ,"NMOTRASNM","OTR_OTRANM","L",1,0,"Otra Nómina")

  cSql:="UPDATE NMOTRASNM SET OTR_OTRANM=1 WHERE NOT "+GetWhereOr("OTR_CODIGO",{"S","M","Q","C"})
  oDb:EXECUTE(cSql)

  FOR I=1 TO LEN(aTipNom)
  
    EJECUTAR("CREATERECORD","NMOTRASNM",{"OTR_TIPO","OTR_CODIGO","OTR_DESCRI","OTR_CODMON" ,"OTR_PERIOD","OTR_TIPTRA","OTR_ACTIVO","OTR_PLAFIN"},;
                                       {aTipNom[I],SPACE(02)   ,aNombre[I]  ,oDp:cMoneda  ,aNombre[I]  ,"Activos"   ,.T.         ,.T.         },;
                                        NIL,.T.,"OTR_TIPO"+GetWhere("=",aTipNom[I]))

  NEXT I

  oDb:EXECUTE(cSql)

//SQLUPDATE("NMTRABAJADOR","TRA_ACTIVO",.T.,[LEFT(CONDICION,1)="A" OR LEFT(CONDICION,1)="V"])

  cSql:="UPDATE NMTRABAJADOR SET TRA_ACTIVO=1 WHERE TRA_ACTIVO IS NULL "
  oDb:EXECUTE(cSql)

  SQLUPDATE("NMOTRASNM","OTR_PERIOD","Ejercicio"    ,"OTR_PERIOD"+GetWhere("=","E"))
  SQLUPDATE("NMOTRASNM","OTR_PERIOD","Mensual"      ,"OTR_PERIOD"+GetWhere("=","M"))
  SQLUPDATE("NMOTRASNM","OTR_PERIOD","Fecha Sistema","OTR_PERIOD"+GetWhere("=","F"))
  SQLUPDATE("NMOTRASNM","OTR_PERIOD","Catorcenal"   ,"OTR_PERIOD"+GetWhere("=","CATORCENAL"))

  EJECUTAR("DPCAMPOSADD","NMUNDFUNC","CEN_ACTIVO","L",01,0,"Registro Activo",NIL,.T.,.T.,[.T.])

  EJECUTAR("DPCAMPOSADD","NMNIVELESTUD","NES_ACTIVO","L",01,0,"Activo",NIL,.T.,.T.,[.T.])

  EJECUTAR("DPCAMPOSADD","NMCOMPHCM","CHC_RIF","C",12,0,"RIF") //,NIL,.T.,.T.,[.T.])


  IF COUNT("NMNIVELESTUD")=0 .AND. FILE("EJEMPLO\NMNIVELESTUD.DBF")
     IMPORTDBF32("NMNIVELESTUD","EJEMPLO\NMNIVELESTUD.DBF",oDp:cDsnData,oDp:oSay,.T.,.T.)
     SQLUPDATE("NMNIVELESTUD","NES_ACTIVO",.T.)
  ENDIF

  EJECUTAR("NMASISTENCIATIPCREA")
  EJECUTAR("NMTRABAJADORFIX")

//EJECUTAR("DPLINKADD","NMGRUCONOCI","NMCLACONOCI","CNC_GRUCON","CDC_GRUPO",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD","NMGRUCONOCI","NMCLACONOCI","GRC_CODIGO","CDC_GRUPO",.T.,.T.,.T.)
  SQLDELETE("DPLINK","LNK_TABLES"+GetWhere("=","NMTRABAJADOR")+" AND LNK_TABLED"+GetWhere("=","NMTRABCONOCI"))            

  EJECUTAR("DPCAMPOSADD" ,"NMTRABCONOCI","CXT_RIF","C",12,0,"RIF")
  EJECUTAR("DPDROP_FK","NMTRABAJADOR",.T.,.T.)
  EJECUTAR("DPLINKADD","DPRIF","NMTRABCONOCI","RIF_ID","CXT_RIF",.T.,.T.,.T.)

  EJECUTAR("NMTIPAUSCREAR")

  // EJECUTAR("ADDONADD","NMPTRS","Implementar Nómina en Petros")
  EJECUTAR("ADDONADD","EXTRAN","Implementar Extra Nómina en Dólares")

  oDp:cFileEjm:=oDp:cBin+"ejemplo\1_3_18.XLS"

  IF FILE(oDp:cFileEjm) .AND. COUNT("NMTASASINT")=0              
     EJECUTAR("BCVTASASINT",NIL,NIL,NIL,NIL,NIL,oDp:cFileEjm)
  ENDIF

  EJECUTAR("NMTABLIQSETNUM")

  EJECUTAR("NMTIPNOMXCONCEPTO") // crear tipo  de nómina por conceptos de Pago
  EJECUTAR("DPTABLAACENTOS","NMPROFESION","PRF_NOMBRE","PRF_CODIGO")

  oData:=DATASET(cId,"ALL")
  oData:Set(cId,cId)
  oData:Save()
  oData:End()

  DPWRITE(cFile,cFile)

  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
  oDb:Execute(cSql)

RETURN .T.
// EOF



