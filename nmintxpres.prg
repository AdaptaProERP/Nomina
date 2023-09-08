// Programa   : NMINTXPRES
// Fecha/Hora : 24/09/2004 08:08:07
// Propósito  : Calcula los Intereses por Prestamo
// Creado Por : Juan Navas
// Llamado por: Formulas de Nómina
// Aplicación : Nomina
// Tabla      : NMTABINT

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,cNumPres)
   LOCAL cSql,nInteres:=0,dHasta,nBase:=0,dFchIni,nPagos:=0
   LOCAL oPagos,oCursor,cWhere:="",aData:={},lIndexa:=.F.

   DEFAULT cCodTra:="1002"

   IF !EMPTY(cNumPres)
      cWhere:="PRE_NUMERO"+GetWhere("=",cNumPres)+" AND "
   ENDIF
   
   CursorWait()

   cSql:="SELECT PRE_NUMERO,PRE_NUMREC,REC_FECHAS,PRE_MONTO,PRE_CUOTA,PRE_TIPO,REC_CODTRA,APELLIDO,NOMBRE FROM NMTABPRES "+;
         "INNER JOIN NMRECIBOS ON NMTABPRES.PRE_NUMREC=NMRECIBOS.REC_NUMERO INNER JOIN NMTRABAJADOR ON NMRECIBOS.REC_CODTRA=NMTRABAJADOR.CODIGO "+;
         "WHERE "+cWhere+" REC_CODTRA"+GetWhere("=",cCodTra)+" AND PRE_TIPO"+GetWhere("=","P") + " " +;
         "ORDER BY  NMRECIBOS.REC_CODTRA,NMRECIBOS.REC_CODTRA,NMTABPRES.PRE_NUMERO"

   oCursor:=OpenTable(cSql,.T.) // Cursor para el Reporte

   
   /*
   // Calcula los Pagos
   */
   WHILE !oCursor:Eof() 

     aData:={}

     AADD(aData,{"PRESTAMO",oCursor:PRE_MONTO,oCursor:REC_FECHAS,1})
     dHasta:=oCursor:REC_FECHAS

     cSql:="SELECT PRE_MONTO,REC_FECHAS FROM NMTABPRES "+;
           "INNER JOIN NMRECIBOS ON NMTABPRES.PRE_NUMREC=NMRECIBOS.REC_NUMERO "+;
           "WHERE REC_CODTRA"+GetWhere("=",oCursor:REC_CODTRA)+;
           " AND PRE_NUMERO"+GetWhere("=",oCursor:PRE_NUMERO)+;
           " AND PRE_TIPO"+GetWhere("=","A")

      oPagos:=OpenTable(cSql,.T.)
      nPagos:=0

      WHILE !oPagos:Eof()
        nPagos:=nPagos+oPagos:PRE_MONTO
        AADD(aData,{"ABONO",oPagos:PRE_MONTO,oPagos:REC_FECHAS,1})
        oPagos:DbSkip(1)
      ENDDO

      oPagos:End()

      nInteres:=INTERES("002",NIL,NIL,NIL,dHasta,aData,.F.,,,,,"xx",lIndexa,@nBase,dFchIni)

      ? nInteres,nPagos,oCursor:PRE_MONTO,oCursor:REC_FECHAS


      oCursor:DbSkip()

   ENDDO

   ? ValType(aData),LEN(aData)

RETURN nInteres
// EOF

