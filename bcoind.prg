// Programa   : BCOIND
// Fecha/Hora : 29/04/2004 14:32:22
// Propósito  : Generar Archivo TXT Banco Industrial
// Creado Por : Juan Navas
// Llamado por: NMNOMTXT	
// Aplicación : Nómina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

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

  nHandler:=fcreate(cFile,FC_NORMAL)

  WHILE !oTable:Eof()

     IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
     IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)

     cLine :=""
     nMonto:=nMonto+oTable:REC_MONTO
     nCant++

     IF oTable:Recno()>1
        cLine:=CRLF
     ENDIF

     cLine:=cLine+"770"+FILLZERO(oTable:BANCO_CTA,20)+;
                        FILLZERO(oTable:CEDULA,11)+;
                        FILLZERO(STR(oTable:REC_MONTO*100,10,0),13)+;
                        REPLI("0",13)
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
