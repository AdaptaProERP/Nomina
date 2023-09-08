// Programa   : Banco Federal
// Fecha/Hora : 10/03/2005 14:32:22
// Propósito  : Generar Archivo TXT Banco Federal
// Creado Por : Juan Navas // Modificado por Vicente Camesella
// Llamado por: BCOFED
// Aplicación : Nómina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cCuenta,cMonto:=0, nCta:=0,CED,CEDU,cNomina

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

//cMonto:=RSTR(nMonto*100,15,2)
cMonto:=STRTRAN(nMonto,".","")
//cMonto:=STRZERO(Val(cMonto),15)
//cMonto:=nMonto*100
  nHandler:=fcreate(cFile,FC_NORMAL)
 
  
//nMonto:=nMonto+oTable:REC_MONTO
//     nCant++

 cNomina :=""
  IF oTable:FCH_HASTA-oTable:FCH_DESDE<15
     cNomina:="03"
  ELSE
     cNomina:=IIF(oTable:FCH_DESDE=01,"01","02")
  ENDIF

  cLine:="001"+;
	   "00000"+;
	   STRZERO(nCta,7)+;
	   "0000"+;
         STRZERO(MONTH(oDp:dFecha),2)+;
         cNomina+;
         "067"+;
         STRZERO(INT(nMonto*100),13)+;
         STRZERO(INT(nMonto*100),13)+;
	   DTOS(oDp:dFecha)+;
         "N"+;
         "0000000000000000000"+;
         CHR(13)+CHR(10)

  //  ? LEN(cLine), // Si tiene 80 No cuenta CRLF


  
  //cLine:=""+CRLF

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

//     IF oTable:Recno()>1
//        cLine:=CRLF
//     ENDIF
      
     cLine:="770"+;
            "0133"+;
            FILLZERO(STRTRAN(RIGHT(ALLTRIM(oTable:BANCO_CTA),16),"-",""),16)+;
            "0000"+;
            STRZERO(MONTH(oDp:dFecha),2)+;
            cNomina+;
            "670"+;
            FILLZERO(STR(oTable:REC_MONTO*100,13,0),13)+;
            "0000000000000000000"+;
            CHR(13)+CHR(10)
     
     
     fwrite(nHandler,cLine)

     oTable:Skip()

    


  ENDDO

     IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
     IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)

     cLine :=""
     nMonto:=nMonto+oTable:REC_MONTO
     nCant++

//     IF oTable:Recno()>1
//        cLine:=CRLF
//     ENDIF
      
      cLine:="670"+;
            "01330036401000000493"+;    
            "0000"+;
            STRZERO(MONTH(oDp:dFecha),2)+;
            cNomina+;
            "067"+;
            STRZERO(INT(nMonto*100),13)+;
            "0000000000000000000"+;
            CHR(13)+CHR(10)
     
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
