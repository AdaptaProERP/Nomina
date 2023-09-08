// Programa   : NMINTPRESTM
// Fecha/Hora : 19/09/2004 10:14:14
// Propósito  : Calcular Intereses por Prestamos
// Creado Por : Juan Navas
// Llamado por: Desde Cualquier Programa
// Aplicación : Nómina
// Tabla      : NMTABPRES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,cNumPres,nDeuda,nTasa,dFecha,dHasta)
   LOCAL aData:={},dDesde,nTInteres:=0,nInteres:=0,I,lCursor:=.T.,dFecha,nSaldo:=0,nBase:=0,nDias:=0
   LOCAL cSqlTra,cWhere,cSelect,aSelect,nTasaP:=0,nCuantos:=0
   LOCAL aCodigo:={},oTable,cSql,cLinea:=""
   LOCAL oPagos,oCursor,nPagos
   LOCAL lIndexaInt:=.F.  // No indexa Prestaciones

   DEFAULT cCodTra:="1002",dHasta:=oDp:dFecha

   CursorWait()

   cWhere:="REC_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
           "PRE_TIPO"+GetWhere("=","P")+;
           IIF(!EMPTY(cNumPres)," AND PRE_NUMERO"+GetWhere("=",cNumPres),"")

   cSql:="SELECT PRE_NUMERO,PRE_NUMREC,FCH_SISTEM,REC_CODTRA,FCH_HASTA,PRE_MONTO,PRE_CUOTA,PRE_TIPO,PRE_TASA FROM NMTABPRES "+;
         "INNER JOIN NMRECIBOS ON NMTABPRES.PRE_NUMREC=NMRECIBOS.REC_NUMERO " +;
         "INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
         "WHERE "+cWhere+" AND PRE_ACTIVO=1 "+;
         "ORDER BY NMTABPRES.PRE_NUMERO"

   oDp:cMemo:=""
   oCursor  :=OpenTable(cSql,.T.) // Cursor para el Reporte
   nTasaP   :=0
   nCuantos :=0

   WHILE !oCursor:Eof()

     cSql:="SELECT MAX(FCH_HASTA) AS FCH_HASTA FROM NMTABPRES "+;
           "INNER JOIN NMRECIBOS ON NMTABPRES.PRE_NUMREC=NMRECIBOS.REC_NUMERO "+;
           "INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
           "WHERE PRE_NUMERO"+GetWhere("=",oCursor:PRE_NUMERO)+;
           " AND PRE_CODTRA"+GetWhere("=",cCodtra)+;
           " AND PRE_TIPO"+GetWhere("=","A")

     oPagos:=OpenTable(cSql,.T.)
     dFecha:=oPagos:FCH_HASTA
     oPagos:End()

     cSql:="SELECT PRE_MONTO,FCH_HASTA FROM NMTABPRES "+;
           "INNER JOIN NMRECIBOS ON NMTABPRES.PRE_NUMREC=NMRECIBOS.REC_NUMERO "+;
           "INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
           "WHERE REC_CODTRA"+GetWhere("=",oCursor:REC_CODTRA)+;
           " AND PRE_NUMERO"+GetWhere("=",oCursor:PRE_NUMERO)+;
           " AND PRE_TIPO"+GetWhere("=","A")+" ORDER BY FCH_HASTA"

      oPagos:=OpenTable(cSql,.T.)
      aData :={}
      nPagos:=0
      nSaldo:=oCursor:PRE_MONTO

      AADD(aData,{"PRES",oCursor:PRE_MONTO,oCursor:FCH_HASTA,1}) // Saldo del prestamo

      WHILE !oPagos:Eof()
         nPagos:=nPagos+oPagos:PRE_MONTO
         nSaldo:=oCursor:PRE_MONTO-nPagos
         AADD(aData,{"ABO",oPagos:PRE_MONTO*-1,oPagos:FCH_HASTA,-1}) // Saldo del prestamo
         oPagos:DbSkip()
      ENDDO

      oPagos:End()

      IF nSaldo=0
         oCursor:DbSkip(1)
         LOOP
      ENDIF

      nInteres:=INTERES("INT_TASA",NIL,NIL,NIL,dHasta,@aData,.F.,NIL,oCursor:PRE_TASA,,,,lIndexaInt,@nBase,NIL)

      cLinea  :="Prestamo: #"+oCursor:PRE_NUMERO+" "+F8(oCursor:FCH_HASTA)+" Interés:"+;
                ALLTRIM(TRANS(nInteres,"999,999,999.99"))+CRLF

      FOR I=1 TO LEN(aData)
         IF !EMPTY(aData[I,7]) .OR. I=1
            IF aData[I,5]<>0
               nCuantos:=nCuantos+1
               nTasaP  :=nTasaP  +aData[I,5]
            ENDIF
            cLinea:=cLinea+F8(aData[I,2])+" Sld:"+ALLTRIM(STR(aData[I,4],12,2))+;
                   " %"+ALLTRIM(STR(aData[I,5],6,2))+" Días:"+ALLTRIM(STR(aData[I,6],3))+;
                   " R="+ALLTRIM(TRANS(aData[I,7],"999,999,999.99"))+CRLF
         ENDIF
      NEXT I

      oDp:cMemo:=oDp:cMemo+IIF(EMPTY(oDp:cMemo),"",CRLF)+cLinea

      nTInteres:=nTinteres+nInteres

      oCursor:DbSkip()

   ENDDO

   oDp:nTasa:=DIV(nTasaP,nCuantos)

   oCursor:End()

RETURN nTInteres
// EOF

