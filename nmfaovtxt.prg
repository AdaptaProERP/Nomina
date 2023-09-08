// Programa   : NMFAOVTXT
// Fecha/Hora : 26/11/2008 14:32:22
// Prop½sito  : Generar Archivo TXT FAOV (Aporte)
// Creado Por : JS mejorado TJ
// Llamado por: NMLPHTXT	
// Aplicaci½n : Nomina
// Tabla      : 

#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"


PROCE MAIN(oTable,cFile,oMeter,oSay,lEdit)
  LOCAL nHandler,cLine,cSql,nCant:=0,nMonto:=0,oFont,Apellnom,Fechan1,Fechan2
  LOCAL fechain,Fechaeg,valida,validaeg,emision,anoemis,nTipoce,nSexo
  LOCAL SalIntgD:=0, SalIntgG:=0,nSi:=0,nSi1:=0

  DEFAULT cFile:="FILE.TXT",lEdit:=.T.

  IF EMPTY(oTable)

   cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,BANCO_CTA,CEDULA,REC_MONTO FROM NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
          " LEFT  JOIN NMBANCOS     ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
          " LIMIT 10000000 "

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
//? nMonto,"nMonto"

  //? oTable:REC_MONTO ,"oTable:REC_MONTO"

   nSi:=oTable:REC_MONTO  
   nSi1:=nSi/0.03

//? nSi,"nSi"
//? nSi1,"nSi1"
     apellnom:=RTRIM(oTable:NOMBRE)+" "+RTRIM(oTable:APELLIDO)
     Fechan1:=STRTRAN(DTOC(oTable:FECHA_NAC),"/","")
     Fechan2:=SUBST(FECHAN1,1,2)+SUBST(FECHAN1,3,2)+RIGHT(FECHAN1,4)
     // Fecha Ingreso 
     Fechain:=STRTRAN(DTOC(oTable:FECHA_ING),"/","")
     Valida :=SUBST(FECHAIN,1,2)+SUBST(FECHAIN,3,2)+RIGHT(FECHAIN,4)
     // Fecha Egreso
     FechaEg:=STRTRAN(DTOC(oTable:FECHA_EGR),"/","")
     Validaeg :=SUBST(FECHAEG,1,2)+SUBST(FECHAEG,3,2)+RIGHT(FECHAEG,4)

     Anoemis:=STRTRAN(DTOC(oDp:dFecha),"/","")
     nTipoce:=IIF(oTable:TIPO_CED="V","1","2")
     nSexo  :=IIF(oTable:SEXO="F","1","2")
   
     // CALCULO DEL SALARIO INTEGRAL
       // SalIntgD:=STRZERO(INT(oTable:REC_MONTO*100),11)
        SalIntgD:=STRZERO((INT(oTable:REC_MONTO*100,10,0),11)*30)
       // ? SalIntgD,"SalIntgD"

        //SalIntgG:=FILLZERO((STR(SalIntgD*100,10,0),11)*30)
        //? SalIntgG,"SalIntgG" 

//FILLZERO((STR(SalIntgD*100,10,0),11)*30)


//   STRZERO(MONTH(oDp:dFecha),2)+;J30381544800


     cLine:=cLine+FILLZERO(oTable:TIPO_CED,1)+","+;
                        FILLZERO(oTable:CEDULA,8)+","+;
                        SEPARA(oTable:NOMBRE)+","+;
                        SEPARA(oTable:APELLIDO)+","+;
                        STRZERO(INT((oTable:REC_MONTO*100)*100),11)+","+;
                        PADR(Valida,8)+","+;
                        ALLTRIM(PADR(Validaeg,8))


/*
cLine:=cLine+FILLZERO(oTable:TIPO_CED,1)+","+;
                        FILLZERO(oTable:CEDULA,10)+","+;
                        SEPARA(oTable:NOMBRE)+","+;
                        SEPARA(oTable:APELLIDO)+","+;
                        STRZERO(INT(oTable:REC_MONTO*100),11)+","+;
                        PADR(Valida,8)+","+;
                        ALLTRIM(PADR(Validaeg,8))
*/

                 //       "0134"  STRZERO(INT(oTable:REC_MONTO*100),15)

/* FILLZERO((STR(oTable:REC_MONTO*100,10,0),11)*30)
     cLine:=cLine+PADR(FECHAN2,8)+","+FILLZERO(nTipoce,1)+","+;
                        FILLZERO(oTable:CEDULA,10)+","+;
                        SEPARA(oTable:NOMBRE)+","+;
                        SEPARA(oTable:APELLIDO)+","+;
                        PADR(nSexo,1)+","+;
                        PADR(Anoemis,8)+","+"1"+","+;
                        FILLZERO((STR(oTable:REC_MONTO*100,10,0),11)*30)+","+;
                        "0134"
*/

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
// Separa el Primer Nombre del Segundo al Igual que el Apellido
*/
FUNCTION SEPARA(cCampo)
  LOCAL cCamp,cAux,I,nRat
  cCamp:=ALLTRIM(cCampo)
  I   := AT (" ",cCamp)
  nRat:= RAT(" ",cCamp)

  // Corrige Apellidos Separados, Ejemplo: "Da Costa" CR

  IF I<>nRat
    I:=nRat
  ENDIF

  // Limpia las comas, suele suceder CR
  cCamp:=STRTRAN(cCamp,","," ")
  cCamp:=STRTRAN(cCamp,"."," ")


  IF I > 0
    cAux:=ALLTRIM(LEFT(cCamp,I-1))+","+ALLTRIM(SUBSTR(cCamp,I+1))
  ELSE
    cAux:=cCamp+","
  ENDIF

  cAux:=STRTRAN(cAux," ","")


RETURN cAux

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


