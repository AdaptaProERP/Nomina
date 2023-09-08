// Programa   : BCOVCRE
// Fecha/Hora : 29/04/2004 14:32:22
// Prop¢sito  : Generar Archivo TXT Banco Venezolano de Credito
// Creado Por : Juan Navas
// Llamado por: NMNOMTXT	
// Aplicaci¢n : N¢mina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,cFecha,oFont,nTotal:=0,cMonto:=""


  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

  IF EMPTY(oTable)
/*
   cSql:= " SELECT CODIGO,APELLIDO,TIPO_CED,NOMBRE,BANCO_CTA,CEDULA,REC_MONTO FROM NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
          " INNER JOIN NMBANCOS     ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
          " LIMIT 10 "

  oFrmTxt:cTipoNom     :=oDp:cTipoNom
  oFrmTxt:cOtraNom     :=oDp:cOtraNom
  oFrmTxt:cBanco       :=oDp:cBanco  
  oFrmTxt:dDesde       :=oDp:dDesde 
  oFrmTxt:dHasta       :=oDp:dHasta
*/
   cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,BANCO_CTA,TIPO_CED,TIPCTABCO,CEDULA,SUM(HIS_MONTO) AS REC_MONTO, "+;
          " FCH_DESDE,FCH_HASTA "+;
          " FROM NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO   =NMRECIBOS.REC_CODTRA "+;
          " INNER JOIN NMHISTORICO  ON NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "+;
          " INNER JOIN NMBANCOS     ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
          " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
          " WHERE HIS_CODCON<='DZZZ' AND "+;
          " FCH_DESDE "+GetWhere("=",oDp:dDesde  )+" AND "+;
          " FCH_HASTA "+GetWhere("=",oDp:dHasta  )+" AND "+;
          " FCH_TIPNOM"+GetWhere("=",oDp:cTipoNom)+" AND "+;
          " FCH_OTRNOM"+GetWhere("=",oDp:cOtraNom)+;
          " AND BANCO_CTA<>'' AND REC_FORMAP='T' "+;
          " GROUP BY CODIGO,APELLIDO,NOMBRE,BANCO_CTA,TIPO_CED,TIPCTABCO,CEDULA"

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

  cLine:=SQLGET("NMFECHAS","COUNT(*)")
//? cLine

  cLine:=DTOC(oDp:dFecha)
  cLine:=STRTRAN(cLine,"/","")
  cLine:=LEFT(cLine,4)+RIGHT(cLine,2)

  nHandler:=fcreate(cFile,FC_NORMAL)
  cLine:=SPACE(20)+"BVC"+cLine+CRLF
  fwrite(nHandler,cLine)

  IIF(ValType(oMeter)="O",oMeter:SetTotal(oTable:RecCount()),NIL)
  WHILE !oTable:Eof()

     IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
     IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)

// ESTE ES EL DETALLE
    
     cLine :=""
     nMonto:=nMonto+oTable:REC_MONTO
     nCant++

     IF oTable:Recno()>1
        cLine:=CRLF
     ENDIF
      
         
       cFecha:=SUBS(DTOS(oTable:FCH_HASTA),3,6)
//     ? cFecha

     // ENV{LOTE}01{RIGHT(R+ALLTRIM(SUBS(F(PAGO,P11),1,11)),13)}{SUBS(F(PAGO,P11),13,2)}{RIGHT(R+ALLTRIM(F(CEDULA,P28)),15)}{RIGHT(R+ALLTRIM(F(A->CTA_VENCRE,P24)),12)}
     cLine:=cLine+"COJ"+;
                  cFecha+;
                  "01"+;
                  FILLZERO(STR(oTable:REC_MONTO*100,10,0)  ,13)+;
                  FILLZERO(ALLTRIM(STR(oTable:CEDULA,10))  ,15)+;
                  FILLZERO(STRTRAN(oTable:BANCO_CTA,"-",""),12)+;
                  REPLI(" ",14)
//+;        		CHR(13)+CHR(10)

     fwrite(nHandler,cLine)
     IF oTable:Recno()>1
        cLine:=CRLF
     ENDIF

     nTotal:=nTotal+oTable:REC_MONTO
     oTable:Skip()

  ENDDO
  nMonto:=0
  oTable:Gotop()
  WHILE !oTable:Eof()
     nMonto:=nMonto+oTable:REC_MONTO
     oTable:Skip(1)
  ENDDO

// nHandler:=fcreate(cFile,FC_NORMAL)

     				
// calculo del total de la nomina
  cMonto:=LSTR(nMonto*100,15)
  cMonto:=STRTRAN(cMonto,".","")
  cMonto:=STRZERO(Val(cMonto),15)

  cLine:=CHR(13)+CHR(10)+;
         "COJ"+;      // codigo de la ocmpa¤ia
         cfecha+; 
         "09"+;
         cMonto+;    //total debitos 
         FILLZERO(nCant,10)+;   //cantidad de registros
	   Dtos(oDp:dfecha)+;
         REPLI(" ",14)
	

  fwrite(nHandler,cLine)
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
