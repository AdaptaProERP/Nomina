// Programa   : BCOFEDERAL
// Fecha/Hora : 23/05/2005 14:32:22
// Propósito  : Generar Archivo TXT Banco Federal
// Creado Por : Juan Navas
// Llamado por: NMNOMTXT
// Aplicación : Nómina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,cCuenta,cMonto
  LOCAL cWhereGru:="",cNomina,cCodEmp:="",a,cTipNom,cCodEmpr:=""

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

  IF EMPTY(oTable)

   cBanco:="Federal"

   cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,BANCO_CTA,TIPO_NOM,TIPO_CED,CEDULA,SUM(HIS_MONTO) AS REC_MONTO, "+;
          " FCH_DESDE,FCH_HASTA "+;
          " FROM NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO   =NMRECIBOS.REC_CODTRA "+;
          " INNER JOIN NMHISTORICO  ON NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "+;
          " INNER JOIN NMBANCOS     ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
          " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
          " WHERE HIS_CODCON<='DZZZ' AND "+;
          " BANCO_CTA<>'' AND REC_FORMAP='T' "+;
            cWhereGru  +" AND "+;
          " NMBANCOS.BAN_BCOTXT"+GetWhere("=","Federal")+;
          " GROUP BY CODIGO,APELLIDO,NOMBRE,BANCO_CTA,TIPO_CED,CEDULA"




   oTable:=OpenTable(cSql,.T.)
a:=TIPO_NOM
//? a
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

  IF EMPTY(cCodEmp)
    cCodEmp:=SQLGET("NMBANCOS","BAN_CODBAN","BAN_BCOTXT"+GetWhere("=",cBanco))
  ENDIF

  IF Empty(cCodEmp)
    cCodEmp:="999"
  ENDIF

  // Calculamos el Total de la Nómina

  nMonto:=0
  oTable:Gotop()
  WHILE !oTable:Eof()
     nMonto:=nMonto+oTable:REC_MONTO
     oTable:Skip(1)
  ENDDO

  cMonto:=LSTR(nMonto*100,11,2)
  cMonto:=STRTRAN(cMonto,".","")
  cMonto:=STRZERO(Val(cMonto),11)

  nHandler:=fcreate(cFile,FC_NORMAL)
/*
  cNomina :=""
  IF oTable:FCH_HASTA-oTable:FCH_DESDE<15
     cNomina:="03"
  ELSE
     cNomina:=IIF(oTable:FCH_DESDE=01,"01","02")
  ENDIF
*/ 
 
  // valida el codigo de empresa segun banco semanal, quincenal
  
  IF TIPO_NOM="S"
     cCodEmpr:="03"
  ELSE
     cCodEmpr:="02"
  ENDIF

  // valida el codigo segun nomina de trabajador semanal, quincenal
  cTipNom :=""
  IF TIPO_NOM="S"
     cTipNom:="329"
  ELSE
     cTipNom:="236"
  ENDIF
 // ? cTipNom


   cLine:="001"+;
         REPLI("0",5)+;
         STRZERO(oTable:RecCount(),7)+;
         REPLI("0",4)+;
         STRZERO(MONTH(oDp:dFecha),2)+;
         cCodEmpr+;
         cTipNom+;
         FILLZERO(STR(nMonto*100,13,0),13)+;
         FILLZERO(STR(nMonto*100,13,0),13)+;
         STRTRAN(DTOC(oDp:dFecha),"/","")+;
         "N"+;
         REPLICATE("0",19)+;
         CHR(13)+CHR(10)

/*
  cLine:="001"+;
         REPLI("0",5)+;
         STRZERO(oTable:RecCount(),7)+;
         REPLI("0",4)+;
         STRZERO(MONTH(oDp:dFecha),2)+;
         cNomina+;
         Left(cCodEmp,3)+;
         FILLZERO(STR(nMonto*100,13,0),13)+;
         FILLZERO(STR(nMonto*100,13,0),13)+;
         STRTRAN(DTOC(oDp:dFecha),"/","")+;
         "N"+;
         REPLICATE("0",19)+;
         CHR(13)+CHR(10)
 // ? LEN(cLine) 
 // Si tiene 80 No cuenta CRLF
*/


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

                   //  DETALLE
                  cLine:=cLine+"770"+;
                  FILLZERO(STRTRAN(oTable:BANCO_CTA,"-",""),20)+;
                  "0000"+;
                  STRZERO(MONTH(oDp:dFecha),2)+;
                  cCodEmpr+;
                  cTipNom+;
                  FILLZERO(STR(oTable:REC_MONTO*100,10,0),13)+;
                  REPLICATE("0",33)+;
                  CHR(13)+CHR(10)


/*
                  cLine:=cLine+"770"+;
                  FILLZERO(STRTRAN(oTable:BANCO_CTA,"-",""),20)+;
                  "0000"+;
                  STRZERO(MONTH(oDp:dFecha),2)+;
                  cNomina+;
                  Left(cCodEmp,3)+;
                  FILLZERO(STR(oTable:REC_MONTO*100,10,0),13)+;
                  REPLICATE("0",33)+;
                  CHR(13)+CHR(10)
*/
//  ? LEN(cLine) //, Comprobado 80

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

