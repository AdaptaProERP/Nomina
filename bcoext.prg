// Programa   : BCOEXT
// Fecha/Hora : 10/03/2005 14:32:22
// Propósito  : Generar Archivo TXT Banco Exterior
// Creado Por : Juan Navas // Modificado por Carlos Ovalles
// Llamado por: NMNOMTXT
// Aplicación : Nómina    //  ADAPTADO A UNA EMPRESA EN ESPECIAL
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cCuenta,cMonto:=0, nCta:=0,nDia:=0,cDescri

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

  //cMonto:=LSTR(nMonto*100,12,2)
 // cMonto:=LSTR(nMonto*100,11,2)
  cMonto:=STRTRAN(nMonto,".","")
//  cMonto:=STRZERO(Val(cMonto),13)
//cMonto:=nMonto*100
  nHandler:=fcreate(cFile,FC_NORMAL)

     //nMonto:=nMonto+oTable:REC_MONTO
//     nCant++

///oDp:dFechaIni:=CTOD("01/01/"+STRZERO(YEAR(DATE()),4))  /// DTOS(oDp:dFecha)+;

  nDia:=DAY(oDp:dFecha)
  
  IF nDia<=15
     cDescri:="NOMINA DE 1RA QNA"
  ELSE 
     cDescri:="NOMINA DE 2DA QNA"
  ENDIF   
   
  cLine:="J030200445"+;
         "00000000000000000001"+;
          STRZERO(oTable:RecCount(),4)+;
         STRZERO(INT(nMonto*100),13)+;
         STRZERO(DAY(oDp:dFecha),2)+;
	   STRZERO(MONTH(oDp:dFecha),2)+;
         STRZERO(YEAR(oDp:dFecha),4)+;
         "02"+;
         CHR(13)+CHR(10)
//       REPLI(" ",14)+;
//       CHR(13)+CHR(10)
//PADR(cMonto,15)+;

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
      
    
     cLine:=""+;
            PADR(ALLTRIM(oTable:NOMBRE)+" "+oTable:APELLIDO,60)+;
            FILLZERO(STR(oTable:REC_MONTO*100,12),12)+; 
            oTable:TIPO_CED+;
            FILLZERO(oTable:CEDULA   , 60)+; 
            PADR(cDescri,60)+;
            "115"+;
            FILLZERO(STRTRAN(RIGHT(ALLTRIM(oTable:BANCO_CTA),20),"-",""),20)+;
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
