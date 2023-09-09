// Programa   : NMTRABAJADORFIX
// Fecha/Hora : 22/02/2023 13:37:53
// Propósito  : Completar datos de los trabajadores importados desde excel
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)
  LOCAL cSql,oTable,cCedula,nAt,cData1,cData2,aLine

  SQLUPDATE("NMTRABAJADOR","CONDICION","A","CONDICION IS NULL OR CONDICION"+GetWhere("=",""))

  cSql:=[UPDATE NMTRABAJADOR SET RIF=CODIGO WHERE (RIF IS NULL OR RIF="") AND MID(CODIGO,2,1)="-" ]
  oDb:EXECUTE(cSql)

  cSql:=[UPDATE NMTRABAJADOR SET TIPO_CED=LEFT(CODIGO,1) WHERE (TIPO_CED IS NULL OR TIPO_CED="") AND MID(CODIGO,2,1)="-" ]
  oDb:EXECUTE(cSql)

  cSql:=[UPDATE NMTRABAJADOR SET TIPO_NOM="S" WHERE (TIPO_NOM=" " OR TIPO_NOM IS NULL ) ]
  oDb:EXECUTE(cSql)

  cSql:=[ SELECT CODIGO,RIF,CEDULA FROM NMTRABAJADOR WHERE CEDULA=" " OR CEDULA IS NULL]

  oTable:=OpenTable(cSql,.T.)
  WHILE !oTable:EOF()

     cCedula:=oTable:CODIGO
     nAt    :=RAT("-",cCedula)
     cCedula:=LEFT(cCedula,nAt-1)
     cCedula:=STRTRAN(cCedula,"-","")
     cCedula:=STRTRAN(cCedula,"V","")
     cCedula:=STRTRAN(cCedula,"E","")
     SQLUPDATE("NMTRABAJADOR","CEDULA",VAL(cCedula),"CODIGO"+GetWhere("=",oTable:CODIGO))

     oTable:DbSkip()

  ENDDO
  // oTable:Browse()
  oTable:End()

  cSql:=[ SELECT CODIGO,APELLIDO FROM nmtrabajador WHERE APELLIDO1="" OR APELLIDO1 IS NULL ]
  oTable:=OpenTable(cSql,.T.)
  WHILE !oTable:EOF()

     nAt  :=AT(" ",ALLTRIM(oTable:APELLIDO))

     IF nAt>0
        cData1:=LEFT(oTable:APELLIDO,nAt)
        cData2:=SUBS(oTable:APELLIDO,nAt+1,LEN(oTable:APELLIDO))
        SQLUPDATE("NMTRABAJADOR",{"APELLIDO","APELLIDO1","APELLIDO2"},{cData1,cData1,cData2},"CODIGO"+GetWhere("=",oTable:CODIGO))
     ENDIF

     oTable:DbSkip()

  ENDDO

  oTable:End()

  cSql:=[ SELECT CODIGO,NOMBRE FROM nmtrabajador WHERE NOMBRE1="" OR NOMBRE1 IS NULL ]
  oTable:=OpenTable(cSql,.T.)
  WHILE !oTable:EOF()

     nAt  :=AT(" ",ALLTRIM(oTable:NOMBRE))

     IF nAt>0
        cData1:=LEFT(oTable:NOMBRE,nAt)
        cData2:=SUBS(oTable:NOMBRE,nAt+1,LEN(oTable:NOMBRE))
        SQLUPDATE("NMTRABAJADOR",{"NOMBRE","NOMBRE1","NOMBRE2"},{cData1,cData1,cData2},"CODIGO"+GetWhere("=",oTable:CODIGO))
     ENDIF

     oTable:DbSkip()

  ENDDO

  oTable:End()

RETURN
// EOF
