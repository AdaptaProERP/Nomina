// Programa   : BCOCORPBANCA
// Fecha/Hora : 10/03/2005 14:32:22
// Propósito  : Generar Archivo TXT Banco CorpBanca
// Creado Por : Leonardo Palleschi
// Llamado por: NMNOMTXT
// Aplicación : Nómina 
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"

PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cCodBco,cCuenta,cCtaBco,cRif,nRif,cMonto:=0,nCta:=0
  LOCAL nNumero:=SQLGET("NMFECHAS","FCH_NUMERO","FCH_SISTEM"+GetWhere("=",oDp:dFecha))

  DEFAULT cFile:="NOMINA.TXT",lEdit:=.T.

  IF EMPTY(oTable)
    cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,BANCO_CTA,CEDULA,REC_MONTO FROM NMRECIBOS "+;
           " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
           " INNER JOIN NMBANCOS     ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
           " LIMIT 10 "

    oTable:=OpenTable(cSql,.T.)

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

  cCuenta:=SQLGET("NMBANCOS","BAN_CUENTA","BAN_BCOTXT"+GetWhere("=",cBanco))

  IF Empty(cCuenta)
    MensajeErr("Banco: "+Alltrim(cBanco)+" no posee Cuenta Bancaria","Advertencia")
  ENDIF

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

  cRif:=STRTRAN(oDp:cRif,"-","")
  nRif:=STRTRAN(cRif,LEFT(cRif,1),"")

  nMonto:=0
  cLine :=""
  oTable:Gotop()

  WHILE !oTable:Eof()
    IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
    IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)

    cLine :=""
    nMonto:=nMonto+oTable:REC_MONTO
    nCant++

    cCtaBco:=ALLTRIM(oTable:BANCO_CTA)
    cCtaBco:=STRTRAN(cCtaBco,"-","") // Quita los guiones

    cLine:=FILLSPACE(oTable:CEDULA,15)+;
           FILLZERO(RIGHT(cCtaBco,10),12)+;
           FILLZERO(STR(oTable:REC_MONTO*100,12,0),15)+;
           "PAGO DE NOMINA      "+;        
           CHR(13)+CHR(10)
                  
    fwrite(nHandler,cLine)

    oTable:Skip()
  ENDDO

  fclose(nHandler)

  IF lEdit
    DEFINE FONT oFont     NAME "Courier"   SIZE 0, -10

    VIEWRTF(cFile,"Archivo "+cFile+" Monto:"+ALLTRIM(TRAN(nMonto,"999,999,999,999.99"))+;
            " Cant.:" +ALLTRIM(TRAN(nCant ,"99,999")),oFont)
  ELSE
    MsgInfo("Monto Total...: "+ALLTRIM(TRAN(nMonto,"999,999,999,999.99"))+CRLF+;
            "Trabajadores.: " +ALLTRIM(TRAN(nCant ,"99,999"))+CRLF+;
            "Fichero Texto: "+cFile,"Resultado")
  ENDIF
RETURN .T.

// Relleno de ZERO
FUNCTION FILLZERO(cExp,nLen)
  IF ValType(cExp)="N"
    cExp:=ALLTRIM(STR(cExp))
  ENDIF

  cExp:=LEFT(ALLTRIM(cExp),nLen)
  cExp:=REPLI("0",nLen-LEN(cExp))+cExp
RETURN cExp

// Relleno de Espacios
FUNCTION FILLSPACE(cExp,nLen)
  IF ValType(cExp)="N"
    cExp:=ALLTRIM(STR(cExp))
  ENDIF

  cExp:=LEFT(ALLTRIM(cExp),nLen)
  cExp:=cExp+REPLI(" ",nLen-LEN(cExp))
RETURN cExp

// EOF
