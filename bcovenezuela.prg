// Programa   : BCOVENEZUELA
// Fecha/Hora : 10/08/2004 14:32:22
// Propósito  : Generar Archivo TXT Banco Venezuela
// Creado Por : Juan Navas
// Llamado por: NMNOMTXT	
// Aplicación : Nómina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cNumCon:="01"
  LOCAL dHasta:="",nTotal:=0

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

  IF EMPTY(oTable)

   cSql:= " SELECT CODIGO,APELLIDO,TIPO_CED,NOMBRE,BANCO_CTA,CEDULA,REC_MONTO FROM NMRECIBOS "+;
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

  oTable:DbEVal({||nTotal:=nTotal+oTable:REC_MONTO})

  IIF(ValType(oMeter)="O",oMeter:SetTotal(oTable:RecCount()),NIL)

  nHandler:=fcreate(cFile,FC_NORMAL)

  dHasta:=DTOC(oFrmTxt:dHasta)
  dHasta:=LEFT(dHasta,6)+RIGHT(dHasta,2)


  cLine:="H"+;
         PADR(oDp:cEmpresa,40)+;
         PADR(SQLGET("NMBANCOS","BAN_CUENTA","BAN_CUENTA='Venezuela'"),10)+;
         PADR(cNumCon,2)+;
         dHasta+;
         STRZERO(INT(nTotal*100),13)+;
         "03291"+;
         " "+CRLF

  fwrite(nHandler,cLine)

  oTable:Gotop()

  WHILE !oTable:Eof()

     IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
     IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)

     cLine :=""
//   nMonto:=nMonto+oTable:REC_MONTO
     nCant++

     IF oTable:Recno()>1
        cLine:=CRLF
     ENDIF

     cLine:=IIF(oTable:TIPCTABCO="A","1","0")+;
            PADR(oTable:BANCO_CTA,10)+;
            STRZERO(INT(oTable:REC_MONTO*100),11)+;            
            IIF(oTable:TIPCTABCO="A","1770","0770")+;
            PADR(ALLTRIM(oTable:APELLIDO)+" "+oTable:NOMBRE,40)+;
            PADL(LSTR(oTable:CEDULA),10)+;
            "003291"+;
            "  "+CRLF
 
     fwrite(nHandler,cLine)

     oTable:Skip()

  ENDDO

  fclose(nHandler)

  IF lEdit

    DEFINE FONT oFont     NAME "Courier"   SIZE 0, -10

    VIEWRTF(cFile,"Archivo "+cFile+" Monto:"+ALLTRIM(TRAN(nMonto,"999,999,999,999.99"))+;
            " Cant.:" +ALLTRIM(TRAN(nCant ,"99,999")),oFont)

    oFont:End()

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
/*
// Relleno de ZERO
*/
FUNCTION FILLSPACE(cExp,nLen)
   IF ValType(cExp)="N"
     cExp:=ALLTRIM(STR(cExp))
   ENDIF
   cExp:=LEFT(ALLTRIM(cExp),nLen)
   cExp:=REPLI(" ",nLen-LEN(cExp))+cExp
RETURN cExp

// EOF
