// Programa   : NMEDOPRES
// Fecha/Hora : 23/09/2004 17:07:51
// Propósito  : Calcular Estado de Cuenta de Prestamos
// Creado Por : Juan Navas
// Llamado por: 
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,cConcepto:="",oPagos
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nVar:=0,nMonto:=0,cTitle:=""
  LOCAL nSaldo:=0,nPago:=0

  DEFAULT cCodTra:="1002"

  cSql:=" SELECT PRE_NUMERO,REC_FECHAS,PRE_NUMREC,PRE_MONTO,0 AS PRE_PAGADO,0 AS PRE_SALDO,PRE_CUOTA,REC_USUARI FROM NMTABPRES "+;
        " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO "+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
        " AND PRE_TIPO='P'"

//? cSql

  oTable:=OpenTable(cSql,.T.)

  WHILE !oTable:Eof()

     oPagos:=OpenTable("SELECT SUM(PRE_MONTO) AS PRE_MONTO,COUNT(*) AS CUANTOS FROM NMTABPRES "+;
                       " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO    "   +;
                       " WHERE REC_CODTRA"+GetWhere("=",cCodTra)              +;
                       "       AND PRE_NUMERO"+GetWhere("=",oTable:PRE_NUMERO)+;
                       "       AND PRE_TIPO='A'",.T.)

     oTable:Replace("PRE_PAGADO",oPagos:PRE_MONTO)
     oTable:Replace("PRE_SALDO" ,oTable:PRE_MONTO-oPagos:PRE_MONTO)

     nMonto:=nMonto+oTable:PRE_MONTO
     nPago :=nPago +oTable:PRE_SALDO

     oPagos:End()
     oTable:Skip(1)

  ENDDO

  nSaldo:=nMonto-nPago
  aData :=ACLONE(oTable:aDataFill)

  cPictureM:=oTable:GetPicture("PRE_MONTO",.T.)

  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Trabajador "+cCodTra+" no Tiene Préstamos "+cTitle)
     RETURN .F.
  ENDIF

  oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
  cNombre:=cCodTra+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
  oTable:End()

RETURN .T.
