// Programa   : NMCAMBIAFP
// Fecha/Hora : 12/04/2005 21:58:57
// Propósito  : Cambiar Forma de Pago
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Nómina
// Tabla      : NMRECIBOS

// FALTA VALIDAD EL CHEQUE

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cNumFch:="",oBtn,oFontB,cRecibo
  LOCAL aFormaP:=GETOPTIONS("NMTRABAJADOR","FORMA_PAG"),nAt

  nAt:=ASCAN(aFormaP,{|a|a="Otra"})

  IF nAt>0
    ADEL(aFormaP,nAt)
    ASIZE(aFormaP,LEN(aFormaP)-1)
  ENDIF

  cNumFch:=SQLGET("NMFECHAS","FCH_NUMERO","FCH_TIPNOM"+GetWhere("=",oDp:cTipoNom)+" AND "+;
                                          "FCH_OTRNOM"+GetWhere("=",oDp:cOtraNom)+" AND "+;
                                          "FCH_DESDE "+GetWhere("=",oDp:dDesde  )+" AND "+;
                                          "FCH_HASTA "+GetWhere("=",oDp:dHasta  ))

  IF COUNT("NMRECIBOS","REC_NUMFCH"+GetWhere("=",cNumFch))=0
     cNumFch:=""
  ENDIF

  WHILE Empty(cNumFch) // Si no hay Búsca la Ultima
    cNumFch:=SQLGETMAX("NMFECHAS","FCH_NUMERO","FCH_NUMERO"+GetWhere(">",cNumFch))
    IF COUNT("NMRECIBOS","REC_NUMFCH"+GetWhere("=",cNumFch))>0
      EXIT
    ENDIF
    IF Empty(cNumFch)
       EXIT
    ENDIF
  ENDDO

  IF Empty(cNumFch) 
    MensajeErr("No existen periodos de Nómina Procesado")
    RETURN .F.
  ENDIF
 
  DPEDIT():New("Cambiar forma de pago del Recibo ","NMCAMBIAFP.EDT","oCamFp",.T.)
  oCamFp:cFileChm:="CAPITULO2.CHM"

  LeerFechas(cNumFch,.T.)
 
  @ 1,1  SAY "Nómina:"
  @ 2,1  SAY "Otra:"

  @ 1,20 SAY "Desde:" RIGHT
  @ 2,20 SAY "Hasta:" RIGHT

  @ 1,10 SAY oCamFp:oTipoNom PROMPT SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oCamFp:FCH_TIPNOM) UPDATE
  @ 2,10 SAY oCamFp:oOtraNom PROMPT SQLGET("NMOTRASNM","OTR_DESCRI","OTR_CODIGO='"+oCamFp:FCH_OTRNOM+"'")
  @ 1,25 SAY oCamFp:oDesde   PROMPT oCamFp:FCH_DESDE  UPDATE 
  @ 2,25 SAY oCamFp:oHasta   PROMPT oCamFp:FCH_HASTA  UPDATE

  // Datos del Recibo
  @ 5,1 SAY "Recibo:" RIGHT
  @ 6,1 SAY "Código:" RIGHT
  @ 7,1 SAY "Trabajador:" RIGHT
  @ 8,1 SAY "Forma:"  RIGHT
  @ 7,1 SAY "Banco:"  RIGHT
  @ 8,1 SAY "Cheque:" RIGHT

  @ 5,25 SAY oCamFp:oNombre  PROMPT ALLTRIM(oCamFp:APELLIDO)+","+ALLTRIM(oCamFp:NOMBRE)
  @ 6,25 SAY oCamFp:oBanco   PROMPT oCamFp:BAN_NOMBRE 

  @ 5,05 BMPGET oCamFp:oREC_NUMERO VAR oCamFp:REC_NUMERO;
         NAME "BITMAPS\find.bmp";
         ACTION oCamFp:ValRecibo("");
         VALID  CERO(oCamFp:REC_NUMERO) .AND. oCamFp:ValRecibo(oCamFp:REC_NUMERO)

  @ 6,05 BMPGET oCamFp:oREC_CODTRA VAR oCamFp:REC_CODTRA;
         NAME "BITMAPS\find.bmp";
         ACTION oCamFp:ValCodTra("");
         VALID  oCamFp:ValCodTra(oCamFp:REC_CODTRA)

  @ 7,05 COMBOBOX oCamFp:oFormaP  VAR oCamFp:REC_FORMAP ITEMS aFormaP

  COMBOINI(oCamFp:oFormaP)

  @ 8,05 BMPGET oCamFp:oREC_CODBCO VAR oCamFp:REC_CODBCO;
         NAME "BITMAPS\find.bmp";
         ACTION oCamFp:ValCodBco("");
         VALID  oCamFp:ValCodBco(oCamFp:REC_CODBCO);
         WHEN   !Left(oCamFp:REC_FORMAP,1)="E"

  @ 8,05 GET oCamFp:oREC_NUMCHQ VAR oCamFp:REC_NUMCHQ;
         VALID .T.; // oCamFp:ValNumChq(oCamFp:REC_NUMCHQ);
         WHEN  LEFT(oCamFp:REC_FORMAP,1)="C"

  @09,33  SBUTTON oBtn;
          SIZE 42, 23;
          FILE "BITMAPS\XSave.BMP" ;
          LEFT PROMPT "&Grabar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (oCamFp:SaveForma())

  @09,33  SBUTTON oBtn ;
          SIZE 42, 23 ;
          FILE "BITMAPS\XSIG.BMP" ;
          LEFT PROMPT "&Siguiente";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (CursorWait(),;
                  oCamFp:GotoSkip(1))

  @09,33  SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\XANT.BMP" ;
          LEFT PROMPT "&Anterior";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (CursorWait(),;
                  oCamFp:GotoSkip(-1))

  @09,33  SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\XBrowse.BMP" ;
          LEFT PROMPT "&Fechas";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (CursorWait(),;
                  oCamFp:ListFechas())

  @09,33  SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\XPRINT.BMP" ;
          LEFT PROMPT "&Imprimir";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (CursorWait(),;
                  oCamFp:RecImprime())

  @09,33  SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\XSALIR.BMP" ;
          LEFT PROMPT "sa&lir";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (CursorWait(),;
                  oCamFp:Close())

  oCamFp:Activate()

RETURN .T.

/*
// Grabar Forma de Pago
*/
FUNCTION SaveForma()
  LOCAL oTable,cDescri:="",cRecibo:=oCamFp:REC_NUMERO

  IF LEFT(oCamFp:REC_FORMAP,1)="C" .AND. !oCamFp:ValNumChq(oCamFp:REC_NUMCHQ)
     RETURN .F.
  ENDIF

  oTable:=OpenTable("SELECT REC_FORMAP,REC_CODBCO,REC_NUMCHQ FROM NMRECIBOS WHERE REC_NUMERO"+GetWhere("=",oCamFp:REC_NUMERO),.T.)

  IF oTable:REC_FORMAP<>oCamFp:REC_FORMAP
     cDescri:="Forma "+oTable:REC_FORMAP+" Cambiado por  "+oCamFp:REC_FORMAP
  ENDIF

  oTable:Replace("REC_FORMAP",oCamFp:REC_FORMAP)
  oTable:Replace("REC_CODBCO",oCamFp:REC_CODBCO)
  oTable:Replace("REC_NUMCHQ",oCamFp:REC_NUMCHQ)

  IF Left(oCamFp:REC_FORMAP,1)="E"
    oTable:Replace("REC_CODBCO","")
    oTable:Replace("REC_NUMCHQ","")
  ENDIF

  IF Left(oCamFp:REC_FORMAP,1)="T"
    oTable:Replace("REC_NUMCHQ","")
  ENDIF

  oTable:Commit(oTable:cWhere)
  oTable:End()

  oCamFp:GotoSkip(1)

  AUDITAR("DMOD" , NIL ,"NMRECIBOS" , oCamFp:REC_NUMERO+" Cambia "+cDescri)

  oCamFp:REC_NUMERO:=""
  oCamFp:LEERRECIBO(cRecibo)

  DpFocus(oCamFp:oREC_NUMERO)

RETURN .T.

/*
// Lectura del Recibo
*/
FUNCTION LEERRECIBO(cRecibo)
  LOCAL oTable,nAt

  oTable:=OpenTable("SELECT REC_NUMERO,REC_CODTRA,REC_CODBCO,REC_FORMAP,APELLIDO,NOMBRE,BAN_NOMBRE, "+;
                    "REC_NUMCHQ "+; 
                    " FROM NMRECIBOS "+;
                    "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
                    "LEFT  JOIN NMBANCOS     ON REC_CODBCO=BAN_CODIGO "+;
                    "WHERE REC_NUMERO"+GetWhere("=",cRecibo),.T.)
  oTable:End()

  oCamFp:REC_NUMERO:=oTable:REC_NUMERO
  oCamFp:REC_CODTRA:=oTable:REC_CODTRA
  oCamFp:REC_FORMAP:=oTable:REC_FORMAP
  oCamFp:REC_CODBCO:=oTable:REC_CODBCO
  oCamFp:APELLIDO  :=oTable:APELLIDO
  oCamFp:NOMBRE    :=oTable:NOMBRE
  oCamFp:BAN_NOMBRE:=oTable:BAN_NOMBRE
  oCamFp:REC_NUMCHQ:=oTable:REC_NUMCHQ

  IF oCamFp:lActivated

     oCamFp:oREC_NUMERO:VarPut(oTable:REC_NUMERO,.T.)
     oCamFp:oNombre:VarPut(ALLTRIM(oCamFp:APELLIDO)+","+ALLTRIM(oCamFp:NOMBRE))
     oCamFp:oBanco:VarPut(SQLGET("NMBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oCamFp:REC_CODBCO)))

     AEVAL(oCamFp:oDlg:aControls,{|o|IIF("GET"$o:ClassName(),o:Refresh(.T.))})
     oCamFp:oFormaP:VarPut(oCamFp:REC_FORMAP)
     oCamFp:oFormaP:Refresh(.T.)

  ENDIF

RETURN NIL

/*
// Lectura de la Fecha
*/
FUNCTION LEERFECHAS(cNumFch,lRecibo)
  LOCAL oTable

  oTable:=OpenTable("SELECT * FROM NMFECHAS WHERE FCH_NUMERO"+GetWhere("=",cNumFch),.T.)
  oTable:End()

  oCamFp:cNumFch   :=cNumFch
  oCamFp:FCH_TIPNOM:=oTable:FCH_TIPNOM
  oCamFp:FCH_OTRNOM:=oTable:FCH_OTRNOM
  oCamFp:FCH_DESDE :=oTable:FCH_DESDE
  oCamFp:FCH_HASTA :=oTable:FCH_HASTA


  // Lee el Primer Recibo
  IF lRecibo
     oCamFp:cRecibo :=SQLGETMIN("NMRECIBOS","REC_NUMERO","REC_NUMFCH"+GetWhere("=",cNumFch))
     oCamFp:LeerRecibo(oCamFp:cRecibo)
  ENDIF

  IF oCamFp:lActivated
     AEVAL(oCamFp:oDlg:aControls,{|o|IIF("GET"$o:ClassName(),o:Refresh(.T.))})
//     AEVAL(oCamFp:oDlg:aControls,{|o|o:Refresh(.T.)})
  ENDIF

RETURN .T.

/*
// Listar Fechas
*/
FUNCTION ListFechas()
  LOCAL uValue,cSql,aTitles

  aTitles:={"Numero","Desde","Hasta","Tipo","Otra Nómina"}
  cSql   :="SELECT FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM FROM NMFECHAS"
  uValue :=EJECUTAR("SQLLIST",cSql,NIL,aTitles)

  IF uValue<>oCamFp:cNumFch
     oCamFp:LeerFechas(uValue,.T.)
  ENDIF

RETURN NIL

/*
// Valida Recibo
*/
FUNCTION ValRecibo(cNumero)
  LOCAL cFchNum,aTitles,uValue,cSql,cCodTra,cNombre

  cFchNum:=SQLGET("NMRECIBOS","REC_NUMFCH","REC_NUMERO"+GetWhere("=",cNumero))

  IF Empty(cFchNum)

     aTitles:={"Número","Código","Apellido","Nombre","Monto"}
     cSql   :="SELECT REC_NUMERO,REC_CODTRA,APELLIDO,NOMBRE,SUM(HIS_MONTO) FROM NMRECIBOS "+;
              "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
              "INNER JOIN NMHISTORICO  ON REC_NUMERO=HIS_NUMREC "+;
              "WHERE REC_NUMFCH "+GetWhere("=",oCamFp:cNumFch)+;
              "  AND (LEFT(HIS_CODCON,1)='A' OR LEFT(HIS_CODCON,1)='D') "+;
              " GROUP BY REC_NUMERO,REC_CODTRA,APELLIDO,NOMBRE "

     uValue :=EJECUTAR("SQLLIST",cSql,NIL,aTitles)

     IF !Empty(uValue)
        oCamFp:oREC_NUMERO:VarPut(uValue,.T.)
        oCamFp:oREC_NUMERO:KeyBoard(13)
     ENDIF

     RETURN .F.

  ENDIF

  IF !cFchNum==oCamFp:cNumFch // Recibo de Otro Periodo
     oCamFp:LeerFechas(cFchNum,.F.)
  ENDIF

  oCamFp:LEERRECIBO(cNumero)

  cCodTra:=SQLGET("NMRECIBOS","REC_CODTRA","REC_NUMERO"+GetWhere("=",cNumero))
  oCamFp:oREC_CODTRA:VarPut(cCodTra,.T.)
  oCamFp:REC_CODTRA:=cCodTra

  cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))
  oCamFp:oNombre:VarPut(cNombre)
  oCamFp:oNombre:Refresh(.T.)

  oCamFp:oBanco:VarPut(SQLGET("NMBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oCamFp:REC_CODBCO)))
  oCamFp:oBanco:Refresh(.T.)

  oCamFp:oREC_NUMERO:Refresh(.T.)

RETURN .T.

/*
// Valida Código del Trabajador
*/
FUNCTION ValCodTra(cCodTra)
  LOCAL aTitles,uValue,cSql,cNombre

  cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))

  oCamFp:oNombre:VarPut(cNombre)
  oCamFp:oNombre:Refresh(.T.)

  IF cCodTra=SQLGET("NMTRABAJADOR","CODIGO","CODIGO"+GetWhere("=",cCodTra))
     RETURN .T.
  ENDIF

  aTitles:={"Código","Apellido","Nombre"}

  cSql   :="SELECT CODIGO,APELLIDO,NOMBRE,REC_NUMERO AS RECIBO FROM NMRECIBOS "+;
           "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
           "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
           " WHERE FCH_TIPNOM"+GetWhere("=",oCamFp:FCH_TIPNOM)+; 
           "   AND FCH_OTRNOM"+GetWhere("=",oCamFp:FCH_OTRNOM)+;
           "   AND FCH_DESDE "+GetWhere("=",oCamFp:FCH_DESDE )+;
           "   AND FCH_HASTA "+GetWhere("=",oCamFp:FCH_HASTA )+;  
           " GROUP BY CODIGO,APELLIDO,NOMBRE "

//  ? cSql,"CSQL",CHKSQL(cSql)

  uValue :=EJECUTAR("SQLLIST",cSql,NIL,aTitles)

  IF !Empty(uValue)

     oCamFp:oREC_CODTRA:VarPut(uValue,.T.)

     aTitles:={"Recibo","Desde","Hasta","Nómina","Otra Nómina","Monto"}

     cSql   :="SELECT REC_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,SUM(HIS_MONTO) FROM NMRECIBOS "+;
              "INNER JOIN NMHISTORICO  ON REC_NUMERO=HIS_NUMREC "+;
              "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
              "WHERE REC_CODTRA "+GetWhere("=",uValue)+;
              "  AND (LEFT(HIS_CODCON,1)='A' OR LEFT(HIS_CODCON,1)='D') "+;
              " GROUP BY REC_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM "

     cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",uValue))
     oCamFp:oNombre:VarPut(cNombre)
     oCamFp:oNombre:Refresh(.T.)

     uValue :=EJECUTAR("SQLLIST",cSql,"Recibos de :"+ALLTRIM(uValue)+" ["+ALLTRIM(cNombre)+"]",aTitles)

     IF !Empty(uValue)
        oCamFp:oREC_NUMERO:VarPut(uValue,.T.)
        DPFOCUS(oCamFp:oREC_CODTRA)
        RETURN .F.
     ENDIF

  ENDIF

RETURN .T.

/*
// Valida Número del Cheque
*/
FUNCTION ValNumChq(cNumChq)
  LOCAL cRecibo:=oCamFp:REC_NUMERO 
   
  cRecibo:=SQLGET("NMRECIBOS","REC_NUMERO","REC_NUMCHQ"+GetWhere("=",cNumChq)+;
                  " AND REC_CODBCO"+GetWhere("=",oCamFp:REC_CODBCO)+;
                  " AND REC_NUMERO"+GetWhere("<>",cRecibo))

  IF !Empty(cRecibo)
     MensajeErr("Cheque ["+cNumChq+"] ya está Asignado al Recibo: "+cRecibo)
     RETURN .F.
  ENDIF

RETURN .T.

/*
// Valida Número del Cheque
*/
FUNCTION ValCodBco(cCodBco)
  LOCAL aTitles,cSql,uValue

  IF !Empty(cCodBco) .AND. SQLGET("NMBANCOS","BAN_CODIGO","BAN_CODIGO"+GetWhere("=",cCodBco))=cCodBco
     oCamFp:oBanco:VarPut(SQLGET("NMBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",cCodBco)))
     oCamFp:oBanco:Refresh(.T.)
     RETURN .T.
  ENDIF

  aTitles:={"Código","Nombre"}
  cSql   :="SELECT BAN_CODIGO,BAN_NOMBRE FROM NMBANCOS "
  uValue :=EJECUTAR("SQLLIST",cSql,NIL,aTitles)

  IF !Empty(uValue)
     oCamFp:oREC_CODBCO:VarPut(uValue,.T.)
     oCamFp:oREC_CODBCO:KeyBoard(13)
     RETURN .F.
  ENDIF

RETURN .T.

/*
// Avanza el Registro
*/
FUNCTION GotoSkip(nSkip)
  LOCAL cRecibo

  IF nSkip=1 // Siguiente

    cRecibo:=SQLGETMIN("NMRECIBOS","REC_NUMERO","REC_NUMERO"+GetWhere(">",oCamFp:REC_NUMERO)+" AND "+;
                       "REC_NUMFCH "+GetWhere("=",oCamFp:cNumFch))
  ELSE

    cRecibo:=SQLGETMAX("NMRECIBOS","REC_NUMERO","REC_NUMERO"+GetWhere("<",oCamFp:REC_NUMERO)+" AND "+;
                       "REC_NUMFCH "+GetWhere("=",oCamFp:cNumFch))

  ENDIF

  IF !Empty(cRecibo)
     oCamFp:LEERRECIBO(cRecibo)
  ENDIF

RETURN .T.

FUNCTION RECIMPRIME(oTrabRec)
  LOCAL aVar   :={}
 
  aVar:={oDp:cTipoNom  ,;
         oDp:cOtraNom  ,;
         oDp:cCodTraIni,;
         oDp:cCodTraFin,;
         oDp:cCodGru   ,;
         oDp:dDesde    ,;
         oDp:dHasta    ,;
         oDp:cRecIni   ,;
         oDp:cRecFin    }

  oDP:cTipoNom  :=""
  oDp:cOtraNom  :=""
  oDp:cCodTraIni:=""
  oDp:cCodTraFin:=""
  oDp:cCodGru   :=""
  oDp:dDesde    :=CTOD("")
  oDp:dHasta    :=CTOD("")
  oDp:cRecIni   :=oCamFp:REC_NUMERO
  oDp:cRecFin   :=oCamFp:REC_NUMERO

  REPORTE("RECIBOS")

  oDp:cTipoNom  :=aVar[1]
  oDp:cOtraNom  :=aVar[2]
  oDp:cCodTraIni:=aVar[3]
  oDp:cCodTraFin:=aVar[4]
  oDp:cCodGru   :=aVar[5]
  oDp:dDesde    :=aVar[6]
  oDp:dHasta    :=aVar[7]
  oDp:cRecIni   :=aVar[8]
  oDp:cRecFin   :=aVar[9]

RETURN .T.

// EOF
