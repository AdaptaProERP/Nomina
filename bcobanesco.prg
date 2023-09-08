// Programa   : BCOBANESCO
// Fecha/Hora : 10/03/2005 14:32:22
// Propósito  : Generar Archivo TXT Banco Banesco
// Creado Por : Leonardo Palleschi
// Llamado por: NMNOMTXT
// Aplicación : Nómina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"

PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cCuenta,cMonto:=0, nCta:=0,CED,CEDU,cNomina
  LOCAL dHasta,dHasta2,cMonto,cConteo,cRif,nRif
  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

  IF EMPTY(oTable)
    cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,BANCO_CTA,CEDULA,TIPCTABCO,REC_MONTO FROM NMRECIBOS "+;
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

  cCuenta:=SQLGET("NMBANCOS","BAN_BCOTXT"+GetWhere("=",cBanco))

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

  cMonto:=LSTR(nMonto,13,2)
  cMonto:=STRTRAN(cMonto,".","")
  cMonto:=STRZERO(Val(cMonto),15)

  cRif:=STRTRAN(oDp:cRif,"-","")
  nRif:=STRTRAN(cRif,LEFT(cRif,1),"")

  nHandler:=fcreate(cFile,FC_NORMAL)
 
  cNomina :=""
  dHasta:=DTOC(oFrmTxt:dHasta)
  dHasta:=LEFT(dHasta,2)           //+RIGTH(dHasta,2)        //+RIGHT(dHasta,2)
  dHasta2:=RIGHT(dHasta,4)

  cLine:="HRD"+;
         "BANESCO        "+;
         "I"+;
         "D 95B "+;
         "PAYMUL"+;
         "P"+;
         CRLF+;
         "01"+;
         "SAL                               "+;
         "9  "+;
         "01                                "+;
         STRZERO(DAY(oDp:dFecha),2)+;
         STRZERO(MONTH(oDp:dFecha),2)+;
         STRZERO(YEAR(oDp:dFecha),4)+;
         CRLF+;
         "02" +;                      
         "05                            "+;
         PADR(nRif,17)+;
         PADR(oDp:cEmpresa,35)+; 
         cMonto+;
         "VEF" +;
         SPACE(1)+;
         "BANESCO    " +;
         STRZERO(YEAR(oDp:dFecha),4)+;
         STRZERO(MONTH(oDp:dFecha),2)+;
         dHasta  +;
         CRLF
 
  cConteo:=oTable:Recno() 

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
      
    cLine:="03"+;
           FILLZERO(nCant,8)+;
           SPACE(22)+;
           FILLZERO(STR(oTable:REC_MONTO*100,13,2),15)+;
           "VEF" +;
           PADR(oTable:BANCO_CTA,20)+;
           SPACE(10)+;
           "0134       "+;
           SPACE(3)+;
           oTable:TIPO_CED +;
           FILLZERO(STR(oTable:CEDULA),9)+;
           SPACE(17)+;  
           PADR(ALLTRIM(oTable:APELLIDO)+" "+oTable:NOMBRE,70)+;
           SPACE(201)+;
           "42"+;
           CRLF
     
    fwrite(nHandler,cLine)

    oTable:Skip()
  ENDDO

  IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
  IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)

  cLine :=""
  nCant:=FILLZERO(nCant,15)-1
  
  cLine:="06" +;
         REPLI("0",14)+; 
         "1" +;
         FILLZERO(nCant,15)+;   
         cMonto
   
  fwrite(nHandler,cLine)

  oTable:Skip()
    
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

// EOF
