// Programa   : BCOTOTXT_0108
// Fecha/Hora : 04/11/2020 20:15:47
// Propósito  : Generar TXT Bancario para Banco Provincial
// Creado Por : Juan Navas
// Llamado por: Orden de Pago
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cCuenta)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cCuenta,cMonto:=0, nCta:=0,CED,CEDU

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

  IF EMPTY(oTable)

   cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,BANCO_CTA,CEDULA,TIPCTABCO,REC_MONTO FROM NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
          " INNER JOIN DPBANCOS     ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
          " LIMIT 10 "

? CLPCOPY(cSql)

   oTable:=OpenTable(cSql,.T.)

oTable:Browse()

   IF oTable:RecCount()=0
      oTable:End()
      MensajeErr("Recibos no Encontrados")
      RETURN .F.
    ENDIF

  ENDIF

  FERASE(cFile)

  IF FILE(cFile)
     MensajeErr("Fichero "+cFile+CRLF+"Posiblemente Protegido","No es posible Grabar")
     RETURN .F.
  ENDIF

  IIF(ValType(oMeter)="O",oMeter:SetTotal(oTable:RecCount()),NIL)

  IF Empty(cCuenta)
     MsgMemo("Requiere Cuenta Bancaria")
     RETURN .F.
  ENDIF

  cCuenta:=STRTRAN(cCuenta,"-","") // Quita los guiones

  // Calculamos el Total de la Nómina

  nMonto:=0
  oTable:Gotop()
  WHILE !oTable:Eof()
     nMonto:=nMonto+oTable:REC_MONTO
     oTable:Skip(1)
     nCta:=nCta+1
  ENDDO

  cMonto:=STRTRAN(nMonto,".","")
  nHandler:=fcreate(cFile,FC_NORMAL)
  
  fwrite(nHandler,cLine)

  nMonto:=0
  cLine :=""
  oTable:Gotop()
  WHILE !oTable:Eof()

     IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
     IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)

     cLine :=""
     nMonto:=nMonto+oTable:REC_MONTO
     nCant++

     cLine:=ALLTRIM(oTable:BANCO_CTA)+" "+;
            oTable:TIPO_CED+;
            FILLZERO(oTable:CEDULA,10)+" "+;
            FILLZERO(STR(oTable:REC_MONTO*100,15,0),15)+" "+;
            "00000000"+" "+;
            PADR(ALLTRIM(oTable:APELLIDO)+" "+oTable:NOMBRE,35)+;
            CHR(13)+CHR(10)
                 
     fwrite(nHandler,cLine)

     oTable:Skip()

  ENDDO

  fclose(nHandler)

/*
  IF lEdit

    DEFINE FONT oFont     NAME "Courier"   SIZE 0, -10

    VIEWRTF(cFile,"Archivo "+cFile+" Monto:"+ALLTRIM(TRAN(nMonto,"999,999,999,999.99"))+;
            " Cant.:" +ALLTRIM(TRAN(nCant ,"99,999")),oFont)

  ELSE

    MsgInfo("Monto Total...: "+ALLTRIM(TRAN(nMonto,"999,999,999,999.99"))+CRLF+;
            "Trabajadores.: " +ALLTRIM(TRAN(nCant ,"99,999"))+CRLF+;
            "Fichero Texto: "+cFile,"Resultado")

  ENDIF
*/   
RETURN .T.
/*
// Relleno de ZERO
*/
FUNCTION FILLZERO(cExp,nLen)
   IF ValType(cExp)="N"
     cExp:=ALLTRIM(STR(cExp))
   ENDIF
   cExp:=LEFT(ALLTRIM(cExp),nLen)
   cExp:=REPLI("0",nLen-LEN(cExp))+cExp
RETURN cExp
