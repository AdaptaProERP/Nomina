// Programa   : BCOMERC
// Fecha/Hora : 29/04/2004 14:32:22
// Prop®sito  : Generar Archivo TXT Banco Mercantil
// Creado Por : TJ
// Llamado por: NMNOMTXT	
// Aplicaci®n : N®mina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,cMonto,nMonto:=0,oFont,cFecha,nTotal:=0,ceros,servicio,cDescri,cRecha,ceros1,fJueves,nDia
  LOCAL cFileTmp:=cTempFile()

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.,cBanco:="Ninguno"

  IF EMPTY(oTable)

   cSql:= " SELECT CODIGO,APELLIDO,TIPO_CED,NOMBRE,BANCO_CTA,CEDULA,REC_MONTO FROM NMRECIBOS"+;
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

  // nHandler:=fcreate(cFilTmp,FC_NORMAL)

  IIF(ValType(oMeter)="O",oMeter:SetTotal(oTable:RecCount()),NIL)
	
  						//  ESTE ES EL ENCABEZADO
  nHandler:=fcreate(cFileTmp,FC_NORMAL)
  ceros:="0"
  ceros:=FILLZERO(ceros,60)
  nDia :=DOW(DATE())

  DO CASE
	CASE nDia<5; fJueves:=DATE()+(5-nDia)
	CASE nDIA>5; fJueves:=DATE()-(nDia-5)
	CASE nDia==5; fJueves:=DATE()
  ENDCASE
	
  nMonto:=oTable:TOTAL("REC_MONTO")
  cMonto:=LSTR(nMonto*100,13)
  cMonto:=STRTRAN(cMonto,".","")
  cMonto:=STRZERO(Val(cMonto),13)

  cLine:="640NOMI"+;
      FILLZERO(PADR(SQLGET("NMBANCOS","BAN_CUENTA","BAN_BCOTXT"+GetWhere("=",cBanco)),12),12)+;  
	"785"+; 
	REPLI("0",8)+;
	cMonto+;
	REPLI("0",13)+;
	"001050"+;	
	Dtos(oDp:dfecha)+;
	REPLI("0",14)+;
	"0D"+;
	"0A"+CRLF
      
  fwrite(nHandler,cLine)
  oTable:Gotop()
  WHILE !oTable:Eof()
	cLine:=""

     IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
     IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)
     
     nMonto:=nMonto+oTable:REC_MONTO
     nCant++
     cFecha:=SUBS(DTOS(oTable:FCH_HASTA),3,6)
  
	 			//  ESTE ES EL DETALLE
	//?oTable:Codigo
	cDescri:="Abono de N®mina"
	cRecha:=""
	cLine:=FILLZERO(nCant,6)+; //Detalle por trabajador 
		"770"+;
		FILLZERO(oTable:BANCO_CTA,12)+;
		"222"+;
		FILLZERO(oTable:CEDULA,8)+;
		STRZERO(INT(oTable:REC_MONTO*100),13)+;
		REPLI("0",13)+;
		"001050"+; //Tipo de Servicio
		REPLI("0",22)+; // referencia
		"0D"+;
		"0A"+CRLF	
			
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
 
  // calculo del total de la nomina
  cMonto:=LSTR(nMonto*100,13)
  cMonto:=STRTRAN(cMonto,".","")
  cMonto:=STRZERO(Val(cMonto),13)

  cLine:="00"+;   // valor fijo consecutivo
	"5555"+;    //
	"99"+;
	"J"+;
	PADR(oDp:cRIF,10)+;
      REPLI(" ",20)+;
	"IDENTIFICACION "+;
	"105"+;
	"VEB"+;
	FILLZERO(PADR(SQLGET("NMBANCOS","BAN_CUENTA","BAN_BCOTXT"+GetWhere("=",cBanco)),12),12)+;
	 cMonto+;       //PADR(oDp:cEmpresa,40)+;   // nombre de la empresa
	FILLZERO(nCant,5)+;   //cantidad de registros
	Dtos(oDp:dfecha) 

  fwrite(nHandler,cLine)
  fclose(nHandler)

  COPY FILE (cFileTmp) TO (cFile)

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
							
         //relleno de ceros
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
