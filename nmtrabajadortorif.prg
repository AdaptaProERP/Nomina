// Programa   : NMTRABAJADORTORIF
// Fecha/Hora : 23/04/2017 20:06:49
// Propósito  : Crear registros de DPRIF que no esten en la tabla de DPPROVEEDOR
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo)
   LOCAL oTable,oRif,cRif,nRif:=0,cMemo:="",cFileTxt:=oDp:cEmpCod+"NMTRABAJADOR.TXT",cRif_:="",cLine:="",cMemo:="",nNumMem:=0,cWhere
   LOCAL oDb:=OpenOdbc(oDp:cDsnData),cRif2

   /*
   // Ubicamos al Proveedor
   */

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"NMTRABAJADOR")
       RETURN .F.
   ENDIF

   IF Empty(cCodigo)
     oDb:Execute([UPDATE NMTRABAJADOR SET TRA_NOMAPL=CONCAT(RTRIM(APELLIDO)," ",RTRIM(NOMBRE))])
   ENDIF

   // UPDATE NMTRABAJADOR SET TRA_NOMAPL=CONCAT(RTRIM(APELLIDO)," ",RTRIM(NOMBRE)) WHERE TRA_NOMAPL IS NULL OR TRA_NOMAPL=""
  
   CursorWait()

   /*
   // Ubicamos al Proveedor con RIF Repetidos
   */

   cWhere:=IIF(Empty(cCodigo),"","CODIGO"+GetWhere("=",cCodigo))

   // cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+"RIF"+GetWhere("<>","")
  
   oTable:=OpenTable("SELECT CODIGO,RIF,NOMBRE,APELLIDO,TRA_NOMAPL FROM NMTRABAJADOR LEFT JOIN DPRIF ON RIF=RIF_ID "+;
                     " WHERE "+IF(Empty(cWhere),"RIF"+GetWhere("<>","")+" AND RIF_ID IS NULL",cWhere)+" ORDER BY CODIGO ",.T.)

// ? oDp:cSql
// oTable:Browse()
   oTable:GoTop()
// oTable:End()

   oRif  :=OpenTable("SELECT * FROM DPRIF",.F.)

   WHILE !oTable:Eof()

        cRif:=STRTRAN(oTable:RIF,"-","")
        cRif:=STRTRAN(cRif          ," ","")
        cRif:=STRTRAN(cRif          ,".","")
        cRif:=ALLTRIM(cRif)

        SQLUPDATE("NMTRABAJADOR","RIF",cRif,"CODIGO"+GetWhere("=",oTable:CODIGO))

        oTable:Replace("RIF",cRif)

        IF oTable:Recno()%10=0
           SysRefresh(.T.)
        ENDIF

        IF !ISSQLFIND("DPRIF","RIF_ID"+GetWhere("=",cRif))

//.AND. COUNT("DPRIF","RIF_ID"+GetWhere("=",cRif))=0

          oRif:AppendBlank()
          oRif:Replace("RIF_ID"    ,cRif)
          oRif:Replace("RIF_TRABAJ",.T.)
          oRif:Replace("RIF_TIPPER","N")
          oRif:Replace("RIF_RESIDE",.T.)
          oRif:Replace("RIF_NOMBRE",ALLTRIM(oTable:TRA_NOMAPL))
          oRif:Commit("")

        ELSE

//       SQLUPDATE("DPRIF",{"RIF_TRABAJ","RIF_TIPPER","RIF_RESIDE","RIF_NOMBRE"},{.T.,oTable:PRO_TIPPER,oTable:PRO_RESIDE="S" .OR. Empty(oTable:PRO_RESIDE),oTable:PRO_NOMBRE},"RIF_ID"+GetWhere("=",cRif))

         SQLUPDATE("DPRIF",{"RIF_TRABAJ","RIF_TIPPER","RIF_RESIDE","RIF_NOMBRE"},{.T.,"N",.T.,oTable:TRA_NOMAPL},"RIF_ID"+GetWhere("=",cRif))

        ENDIF

        oTable:DbSkip()

    ENDDO

    oRif:End()
    oTable:End()

RETURN NIL
// EOF



