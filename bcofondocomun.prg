// Programa   : BCOFONDOCOMUN
// Fecha/Hora : 29/04/2004 14:32:22
// Prop«sito  : Generar Archivo TXT Banco Fondo Comun
// Creado Por : TJ
// Llamado por: NMNOMTXT	
// Aplicaci«n : N«mina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit,cBanco)
  LOCAL nHandler,cLine,cSql,nCant:=0,cMonto,nMonto:=0,oFont,cFecha,nTotal:=0,ceros,servicio,cDescri,cRecha,ceros1,fJueves,nDia
  LOCAL fechapag

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.,cBanco:="FONDO COMUN"

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

  nHandler:=fcreate(cFile,FC_NORMAL)


  IIF(ValType(oMeter)="O",oMeter:SetTotal(oTable:RecCount()),NIL)
	
  						//  ESTE ES EL ENCABEZADO
  nHandler:=fcreate(cFile,FC_NORMAL)
  ceros:="0"
  ceros:=FILLZERO(ceros,60)
	nDia:=DATE() //si es quincenal 
	if Day(nDia)<=15
		fechapag:=CTOD("15/MONTH(DATE())/YEAR(DATE())")
	else
		fechapag:=CTOD("30/MONTH(DATE())/YEAR(DATE())")
	endif

	
 
  cLine:="000000"+;
                  Dtos(oDp:dfecha)+;
                  STRTRAN(TIME(),":","")+;  
                  Dtos(fechapag)+; // fecha en la cual la empresa quiere pagar
                  "150000"+; //hora en la cual quiere pagar la empresa
                  "000000"+; //codigo de la empresa asignado por el banco
                  "000000"+; //codigo de servicio asignado por el banco
			" CC"+; //codigo de cuenta
			FILLZERO(PADR(SQLGET("NMBANCOS","BAN_CUENTA","BAN_BCOTXT"+GetWhere("=",cBanco)),22),22)+;  
			" CC"+; 
                  ceros+CRLF
  fwrite(nHandler,cLine)
  
  WHILE !oTable:Eof()
	cLine:=""

     IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)
     IIF(ValType(oSay)  ="O",oSay:SetText(oTable:CODIGO+" "+ALLTRIM(oTable:APELLIDO)),NIL)
     
     nMonto:=nMonto+oTable:REC_MONTO
     nCant++
     cFecha:=SUBS(DTOS(oTable:FCH_HASTA),3,6)
  
	 			//  ESTE ES EL DETALLE
	//?oTable:Codigo
	cDescri:="Abono de N«mina"
	cRecha:=""
	cLine:=FILLZERO(nCant,6)+; //Detalle por trabajador 
		" CC"+;
		FILLZERO(oTable:BANCO_CTA,20)+;
		oTable:TIPO_CED+;
		FILLZERO(oTable:CEDULA,10)+;
		"00001"+; //Tipo de Servicio
		"00000"+; // cuotas
            REPLI(" ",10)+; // referencia
		STRZERO(INT(oTable:REC_MONTO*100),15)+;
		"C0"+;
		PADR(cDescri,40)+;
		REPLI("0",4)+;
		PADR(cRecha,49)+CRLF
	
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
  cMonto:=LSTR(nMonto*100,15)
  cMonto:=STRTRAN(cMonto,".","")
  cMonto:=STRZERO(Val(cMonto),15)

  cLine:="999999"+;   // valor fijo consecutivo
	PADR(oDp:cEmpresa,40)+;   // nombre de la empresa
	FILLZERO(nCant,6)+;   //cantidad de registros
	 cMonto+;    //total debitos 
	 cMonto+;    //total creditos
	"REGDEB"+;
	FILLZERO(nCant,6)+;        
      REPLI("0",76)     //ceros1

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
