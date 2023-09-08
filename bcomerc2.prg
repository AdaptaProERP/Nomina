// Programa   : BCOMERC2
// Fecha/Hora : 10/03/2005 14:32:22
// Propósito  : Generar Archivo TXT Banco Mercantil
// Creado Por : Juan Navas 
// Llamado por: BCOMERC
// Aplicación : Nómina 
// Tabla      : Adaptapro segun usuarios para codigo de banco/Leonardo PALLESCHI

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

  cRif:=STRTRAN(oDp:cRif,"-","")
  nRif:=STRTRAN(cRif,LEFT(cRif,1),"")

  IF oDp:cUsuario='03'
    cCodBco:='818045'
  ELSE
    IF oDp:cUsuario='04'
      cCodBco:='800150'
    ELSE
      cCodBco:='000000'
    ENDIF
  ENDIF

  cLine:="00"+;
         cCodBco+;
         LEFT(cRif,1)+;
         STRZERO(VAL(nRif),10)+;
         "PAGO DE NOMINA      "+;
         STRZERO(VAL(nNumero),15)+;
         "105"+;
         "VEF"+;
         RIGHT(ALLTRIM(cCuenta),10)+;
         STRZERO(INT(nMonto*100),15)+;
         STRZERO(nCta,5)+;
         DTOS(oDp:dFchPago)+;
         CHR(13)+CHR(10)

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

    cCtaBco:=ALLTRIM(oTable:BANCO_CTA)
    cCtaBco:=STRTRAN(cCtaBco,"-","") // Quita los guiones

    cLine:="01"+;
           oTable:TIPO_CED+;
           FILLZERO(oTable:CEDULA   ,10)+;
           PADR(ALLTRIM(oTable:APELLIDO)+" "+oTable:NOMBRE,60)+;
           "1"+;
           "105"+;
           FILLZERO(RIGHT(cCtaBco,10),10)+;
           FILLZERO(STR(oTable:REC_MONTO*100,12,0),15)+;
           FILLZERO(STR(oTable:REC_MONTO*100,12,0),15)+;
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

// EOF
