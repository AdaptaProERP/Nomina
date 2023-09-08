// Programa   : BCOCARIBE
// Fecha/Hora : 26/02/2007 16:50:24
// Propósito  : Generar Archivo TXT Banco Caribe
// Creado Por : Juan Navas // Modificado por Carlos y Gabriel Ovalles//Cristian Abreu 01/10/2007
// Llamado por: NMNOMTXT
// Aplicación : NOMINA
// Tabla      :

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cCuenta,cMonto,nCant2

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

  IF EMPTY(oTable)

   cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,BANCO_CTA,CEDULA,TIPO_CED,REC_MONTO FROM NMRECIBOS "+;
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
/*
  IF FILE(cFile)
     MensajeErr("Fichero "+cFile+CRLF+"Posiblemente Protegido","No es posible Grabar")
     RETURN .F.
  ENDIF
*/
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
  ENDDO

  //cMonto:=LSTR(nMonto*100,12,2)
  cMonto:=LSTR(nMonto,11,2)
  cMonto:=STRTRAN(cMonto,".","")
  cMonto:=STRZERO(Val(cMonto),13)

  nHandler:=fcreate(cFile,FC_NORMAL)
//  nCant++
//? nCant
  oTable:Gotop()
  WHILE !oTable:Eof()
    nCant++
 	cLine:=""+;        
         STRZERO(DAY(oDp:dFecha),2)+;
	    STRZERO(MONTH(oDp:dFecha),2)+;
         STRZERO(YEAR(oDp:dFecha),4)+;
         "/"+;
         FILLZERO(nCant,2)+;   //cantidad de registros
	    "/"+;
	    "0000000"+;
	    cMonto+;    //total debitos
         CHR(13)+CHR(10)

  //  ? LEN(cLine), // Si tiene 80 No cuenta CRLF


  
  //cLine:=""+CRLF


  oTable:Skip()

  ENDDO
  fwrite(nHandler,cLine)
  nMonto:=0
  nCant:=0
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
      
  
     cLine:="C/"+;
		FILLZERO(STRTRAN(oTable:BANCO_CTA,"-",""),10)+;          
          "/"+;
		FILLZERO(nCant,2)+;
		"/"+;
		"0000000"+;
		FILLZERO(STR(oTable:REC_MONTO*100,12,0),13)+;		
	     CHR(13)+CHR(10)
//? nCant          

		
		
                  
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
// EOF

