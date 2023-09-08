// Programa   : NMCHKCHQ
// Fecha/Hora : 30/06/2005 14:55:49
// Propósito  : Revision de Cheques que seran Exportados
// Creado Por : Juan Navas
// Llamado por: NMCONTAADM
// Aplicación : Nómina
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cTipDoc,lExport,cCompro,oSay,oMeter,lCaja)
  LOCAL cSql,cMemo:="",cLine:="",nAt:=0
  LOCAL oTable,aBancos:={}
  LOCAL cForma:="",cIndex:="",cNumDoc:="",cCodBco:="",cDescri:=""

  DEFAULT lExport    :=.F.,;
          cWhere     :=" WHERE FCH_NUMERO"+GetWhere("=",STRZERO(1,5)),;
          cTipDoc    :="DB",;
          cCompro    :="",;
          lCaja      :=.T.,;
          oDp:aCajBco:={}

  cForma:="REC_FORMAP"+GetWhere("=",IIF(cTipDoc="CH","C","T"))
  cWhere:=IIF(" WHERE "$cWhere,""," WHERE ")+cWhere+;
          " AND FCH_INTEGR<>'S'"
           

  IF Empty(oDp:cPathBco)
     RETURN .T.
  ENDIF

//  IF oDp:cPathBco="SGE"
//     RETURN EJECUTAR("NMCHKCHQSGE")
//  ENDIF
//  ErrorSys(.T.)
//  ? cWhere,cTipDoc,lExport,cCompro,oSay,oMeter,lCaja
//  ? lCaja,"lCaja"
//  MensajeErr("NMCHKCHQ")

  IF EMPTY(oDp:cFileBco)
     EJECUTAR("NMDBFADM")
  ENDIF

  // Los asientos de Caja se hacen cuando se Contabiliza
  IF lCaja .AND. cTipDoc="DB" // .AND. !(ALLTRIM(oDp:cPathCta)==ALLTRIM(oDp:cPathBco))
     ASIENTOEFE(cWhere,cCompro,oSay,oMeter,lExport)
  ENDIF

  IIF(ValType(oSay)="O",oSay:SETTEXT("Revisando Cuentas Bancarias "),NIL)

  // Bancos sin Cuenta Bancaria
  cSql:=" SELECT REC_CODBCO,BAN_NOMBRE FROM NMRECIBOS "+;
        " INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
        " LEFT  JOIN NMBANCOS ON BAN_CODIGO=REC_CODBCO "+;
        cWhere+;
        "   AND "+cForma+;
        "   AND FCH_INTEGR<>'S' "+;
        "   AND (BAN_CUENTA='' OR BAN_CUENTA IS NULL) "+;
        " GROUP BY REC_CODBCO,BAN_NOMBRE "

  oTable:=OpenTable(cSql,.T.)

/*
  ? ChkSql(oTable:cSql),CLPCOPY(oTable:cSql)
  oTable:End()
  RETURN .F.
*/

  WHILE !oTable:Eof()
     cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+oTable:REC_CODBCO+" "+oTable:BAN_NOMBRE
     oTable:DbSkip()
  ENDDO

  oTable:End()

  IF !EMPTY(cMemo) 

     cMemo:=PADR("Código",LEN(oTable:REC_CODBCO))+" "+PADR("Banco",LEN(oTable:BAN_NOMBRE))+CRLF+;
            REPLI("-",LEN(oTable:REC_CODBCO))+" "+REPLI("-",LEN(oTable:BAN_NOMBRE))+CRLF+;
            cMemo +CRLF+CRLF+;
            "La Cuenta Bancaria es Necesaria para la Integración Administrativa."+CRLF+;
            "Indique la Cuentas Bancaria en los Bancos indicados en esta lista y"+CRLF+;
            "Ejecute nuevamente este proceso."

      MensajeErr(cMemo,"Bancos sin Cuenta Bancaria")

      IF cTipDoc="DB"
         EJECUTAR("NMSETDEBITO",cWhere)
      ENDIF

      RETURN .F.

  ENDIF

  cSql:=" SELECT BAN_CODIGO,BAN_CUENTA,BAN_NOMBRE FROM NMRECIBOS "+;
        " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+; 
        " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
        " LEFT  JOIN NMBANCOS     ON BAN_CODIGO=REC_CODBCO "+;
        cWhere+;
        "   AND "+cForma+;
        " GROUP BY BAN_CODIGO,BAN_CUENTA,BAN_NOMBRE "

  CLOSE ALL

  SELE A
  USE (oDp:cFileBco) SHARED VIA "DBFCDX" ALIAS "BCO"
  oTable:=OpenTable(cSql,.t.)
//  ? CLPCOPY(cSql),CHKSQL(cSql)
//  oTable:Browse()

  WHILE !oTable:Eof()

    SELE A
    GOTO TOP
    LOCATE FOR ALLTRIM(BCO_CTABAN)==ALLTRIM(oTable:BAN_CUENTA)

    IF !FOUND()
       cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+oTable:BAN_CODIGO+" "+oTable:BAN_NOMBRE+;
              " "+oTable:BAN_CUENTA
    ELSE
       AADD(aBancos,{oTable:BAN_CODIGO,BCO->BCO_CODIGO})
    ENDIF

    oTable:DbSkip()

  ENDDO

  oTable:End()

  SELE A 
  USE

  IF !EMPTY(cMemo)

     cMemo:=PADR("Código",LEN(oTable:BAN_CODIGO))+" "+PADR("Banco",LEN(oTable:BAN_NOMBRE))+" "+PADR("Cuenta",LEN(oTable:BAN_CUENTA))+CRLF+;
            REPLI("-",LEN(oTable:BAN_CODIGO))+" "+REPLI("-",LEN(oTable:BAN_NOMBRE))+" "+REPLI("-",LEN(oTable:BAN_CUENTA))+CRLF+;
            cMemo +CRLF+CRLF+;
            "La Cuenta Bancaria es Necesaria para la Integración Administrativa."+CRLF+;
            "Indique la Cuentas Bancaria en los Bancos indicados en esta lista y"+CRLF+;
            "Ejecute nuevamente este proceso."

      MensajeErr(cMemo,"Cuentas Bancarias no encontradas en el Sistema Administrativo")
//
      RETURN .F.

  ENDIF

  cSql:=" SELECT REC_NUMERO,REC_CODBCO,REC_NUMCHQ,REC_FECHAS,REC_CODTRA,BAN_CUENTA,"+;
        " APELLIDO,NOMBRE,"+;
        "SUM(HIS_MONTO) AS HIS_MONTO FROM NMRECIBOS "+;
        " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+; 
        " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
        " LEFT  JOIN NMBANCOS     ON BAN_CODIGO=REC_CODBCO "+;
        " INNER JOIN NMHISTORICO  ON REC_NUMERO=HIS_NUMREC "+;
        cWhere+;
        "   AND "+cForma+;
        "   AND FCH_INTEGR<>'S' "+;
        "   AND HIS_CODCON<='DZZZ' "+;
        " GROUP BY REC_NUMERO,REC_CODBCO,REC_NUMCHQ,REC_FECHAS,REC_CODTRA,BAN_CUENTA,APELLIDO,NOMBRE"

  IF cTipDoc="DB"
/*
       cSql:="SELECT REC_FECHAS,FCH_DESDE ,FCH_HASTA , FCH_TIPNOM,"+;
             "       FCH_NUMERO,REC_CODBCO,"+;
             "       BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,DEB_NUMERO,SUM(HIS_MONTO) AS HIS_MONTO "+;
             "FROM NMHISTORICO "+;
             "INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
             "INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
             "INNER JOIN NMBANCOS     ON REC_CODBCO=BAN_CODIGO "+;
             "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
             "LEFT  JOIN NMDEBTRANF   ON NMFECHAS.FCH_NUMERO = NMDEBTRANF.DEB_NUMFCH "+;
             "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
             " "+cWhere+;
             " AND REC_FORMAP='T' "+;
             " AND HIS_CODCON<='DZZZ' "+;
             "   AND FCH_INTEGR<>'S' "+;
             " GROUP BY REC_FECHAS,FCH_DESDE,FCH_HASTA, FCH_TIPNOM, "+;
             "       FCH_NUMERO,REC_CODBCO,BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,DEB_NUMERO"
*/

       cSql:=" SELECT FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO,FCH_SISTEM AS REC_FECHAS,FCH_DESDE,FCH_HASTA,REC_CODBCO, "+;
             " BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,  "+;
             " SUM(HIS_MONTO) AS HIS_MONTO FROM NMRECIBOS  "+;
             " INNER JOIN NMFECHAS    ON FCH_NUMERO=REC_NUMFCH "+;
             " INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC "+;
             " INNER JOIN NMBANCOS    ON REC_CODBCO=BAN_CODIGO "+;
             " "+cWhere+;
             "   AND HIS_CODCON<='DZZZ' "+;
             "   AND REC_FORMAP='T' "+;
             " GROUP BY FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO,FCH_SISTEM,FCH_DESDE,FCH_HASTA,REC_CODBCO, "+;
             " BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA "+;
            " ORDER BY FCH_NUMERO "


  ENDIF

//? ChkSql(cSql),CLPCOPY(cSql)
// RETURN .F.
//  ViewArray(aBancos)

  CLOSE ALL

  SELE A
  cIndex:=STRTRAN(oDp:cFileBco,".DBF",".CDX")
  USE (oDp:cFileBco) SHARED VIA "DBFCDX" ALIAS "BCO"
  SET INDEX TO (cIndex)

  SELE B
  cIndex:=STRTRAN(oDp:cFileMovB,".DBF",".CDX")
  USE (oDp:cFileMovB) SHARED VIA "DBFCDX" ALIAS "MOVB"
  SET INDEX TO (cIndex)
  SET ORDE TO 2

  oTable:=OpenTable(cSql,.t.)
  oTable:REPLACE("BCO_CODIGO",SPACE(20))
  // Virtualmente Agregamos el codigo del Banco
  cMemo:=""

  // oTable:Browse()

  IIF(ValType(oMeter)="O",oMeter:SETTOTAL(oTable:RecCount()),NIL)

  WHILE !oTable:Eof()

    cCodBco:=""
    nAt    :=ASCAN(aBancos,{|a,n|ALLTRIM(a[1])==ALLTRIM(oTable:REC_CODBCO)})

    IF nAt>0
       cCodBco:=aBancos[nAt,2]
       oTable:Replace("BCO_CODIGO",aBancos[nAt,2])
//  ELSE
//       cCodBco:=SQLGET("NMBANCOS","BAN_CUENTA","BCO_CODIGO"+GetWhere("=",oTable:REC_CODBCO))
//       ? cCodBco,oTable:REC_CODBCO
    ENDIF

    A->(DBSEEK(cCodBco)) // Nombre del Banco

    IIF(ValType(oSay)="O",oSay:SETTEXT("Revisando: "+oTable:BCO_CODIGO+cTipDoc+cNumDoc),NIL)

    IF cTipDoc="DB"

       cNumDoc:=SQLGET("NMDEBTRANF","DEB_NUMERO","DEB_NUMFCH"+GetWhere("=",oTable:FCH_NUMERO)+" AND "+;
                                               "DEB_CODBCO"+GetWhere("=",oTable:REC_CODBCO))

       // cDescri:=oTable:FCH_TIPNOM+": "+DTOC(oTable:FCH_DESDE)+" - "+DTOC(oTable:FCH_HASTA)

       cDescri:=oTable:FCH_TIPNOM+":"+ALLTRIM(oTable:FCH_OTRNOM)+" "+DTOC(oTable:FCH_DESDE)+" "+DTOC(oTable:FCH_HASTA)




    ELSE

       cNumDoc:=oTable:REC_NUMCHQ
       cDescri:=oTable:REC_NUMERO+" "+ALLTRIM(oTable:APELLIDO)+", "+ALLTRIM(oTable:NOMBRE)

    ENDIF

    cNumDoc:=PADR(cNumDoc,10)
    // Buscamos el Cheque
    // cNumDoc:=PADR(IIF(cTipDoc="CH",oTable:REC_NUMCHQ,oTable:DEB_NUMERO),10)

    IIF(ValType(oMeter)="O",oMeter:SET(oTable:Recno()),NIL)

    IF EMPTY(cNumDoc)

       cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+;
              "Falta Número"+;
              " "+IIF(cTipDoc="CH",oTable:REC_NUMERO,"")+" "+oTable:REC_CODBCO+" "+;
              cTipDoc+" <Falta Num> "+MOVB->MOV_DESCRI

       oTable:DbSkip()

       LOOP

    ENDIF

    IF MOVB->(DBSEEK(oTable:BCO_CODIGO+cTipDoc+cNumDoc))

       cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+;
              "Ya Existe   "+;
              " "+IIF(cTipDoc="CH",oTable:REC_NUMERO,"")+" "+oTable:REC_CODBCO+" "+;
              cTipDoc+" "+cNumDoc+" "+MOVB->MOV_DESCRI

       oTable:DbSkip()

       LOOP

    ENDIF

    AADD(oDp:aCajBco,{cCodBco,;
                      A->BCO_DESCRI,;
                      cTipDoc,;
                      cNumDoc,;
                      cDescri,;
                      oTable:HIS_MONTO,;
                      PORCEN(MOV_MONTO,oDp:nDebBanc),;
                      oTable:REC_FECHAS})


    IF lExport

      IIF(ValType(oSay)="O",oSay:SETTEXT("Grabando: "+oTable:BCO_CODIGO+cTipDoc+cNumDoc),NIL)


//      ? "AQUI GRABA",cCodBco,cTipDoc,cNumDoc
//      IF cTipDoc="CH"
//         cDescri:=ALLTRIM(oTable:APELLIDO)+","+ALLTRIM(oTable:NOMBRE)
//      ELSE
//       cDescri:="Nóm:["+ALLTRIM(SayOptions("NMTRABAJADOR","TIPO_NOM",oTable:FCH_TIPNOM))+"] "+DTOC(oTable:FCH_DESDE)+" - "+DTOC(oTable:FCH_HASTA)
//         cDescri:=oTable:FCH_TIPNOM
//))+"] "+DTOC(oTable:FCH_DESDE)+" - "+DTOC(oTable:FCH_HASTA)
//      ENDIF

      SELE MOVB

      // MOV_CODIGO WITH cCodBco,;

      NUEVO()
      BLOC()
      REPLACE MOV_CUENTA WITH cCodBco,;
              MOV_FECHA  WITH oTable:REC_FECHAS,;
              MOV_TIPO   WITH cTipDoc,;
              MOV_DOCUME WITH cNumDoc,;
              MOV_DESCRI WITH cDescri,;
              MOV_MONTO  WITH oTable:HIS_MONTO,;
              MOV_MONNAC WITH oTable:HIS_MONTO,;
              MOV_CAMBIO WITH 1,;
              MOV_DH     WITH .F.,;
              MOV_CONCIL WITH "N",;
              MOV_OK     WITH !EMPTY(cCompro),;
              MOV_FCHCON WITH CTOD(""),;
              MOV_ORIGEN WITH "NMW",;
              MOV_COMPRO WITH cCompro,;
              MOV_IDB    WITH PORCEN(MOV_MONTO,oDp:nDebBanc),;
              MOV_EXENTO WITH IIF(MOV_IDB=0,"S","N")

              ACTSLDBCO([4],MOV_CUENTA,1,[H],MOV_FECHA,MOV_MONTO+MOV_IDB,.T.)

              SELECT BCO
              DBSEEK(cCodBco)
              BLOC()
              IF cTipDoc="CH"
                 REPLACE BCO_CHEQUE WITH VAL(cNumDoc)
              ELSE
                 REPLACE BCO_NOTADB WITH VAL(cNumDoc)
              ENDIF
              UNLOCK

    ENDIF

    oTable:DbSkip()

  ENDDO

  CLOSE ALL
//  otable:Browse()
  oTable:End()

  IF !Empty(cMemo)

     cMemo:=PADR("Motivo",12)+" "+PADR("Recibo",7)+" "+PADR("Cod. Banco",10)+" TP Número "+CRLF+;
            REPL("-"     ,12)+" "+REPL("-"     ,7)+" "+REPL("-"         ,10)+" -- -------"+CRLF+;
            cMemo +CRLF+CRLF+;
            "El proceso de Integración requiere disponibilidad de los números de documentos"+CRLF+;
            "que indentifican las transacciones."

      MensajeErr(cMemo,"Registros Bancarios Existentes")

      IF cTipDoc="DB"
         EJECUTAR("NMSETDEBITO",cWhere)
      ENDIF

      IF cTipDoc="CH"
         EJECUTAR("NMSETCHEQUE",cWhere)
      ENDIF

  ENDIF

RETURN Empty(cMemo)


/*
// Agrega Nuevo Registro
*/
FUNCTION NUEVO()

    DO WHILE .T.
       APPE BLANK
       IF !NETERR()
          EXIT
       ENDIF
    ENDDO

RETURN .T.

/*
// Bloque Registro
*/
FUNCTION Rlock(nTime,nVeces) 
      LOCAL nContar:=0

      DEFAULT nTime:=5,nVeces:=500

      DO WHILE !REC_LOCK(nTime)
         IF nVeces<nCONTAR++ .AND. nVeces>0
            ALERT("Area : "+ALIAS()+" Bloqueado ")
         ENDIF
      ENDDO

RETURN .T.

FUNCTION Rec_Lock(WAIT)
     LOCAL FOREVER

     FOREVER=.F.

     IF RLOCK()
        RETURN .t.
     ENDIF

     forEver=(wait=0)

     DO WHILE (forEver .or. wait=0)
        IF RLOCK()
           RETURN .T.
        ENDIF
        // INKEY(.5)
        WAIT=WAIT -.5
     ENDDO

RETURN .f.

PROCE ACTSLDBCO(cTipSld,cCodCta,nModo,cCampo,dFchAct,nMonto)

      **** ACTUALIZA LOS SALDOS ****
      LOCAL cMes , nPosCam , cOldAre := ALIAS(),cIndex

      IF !DPSELECT("SLD")
         SELE H
         cIndex:=STRTRAN(oDp:cFileSld,".DBF",".CDX")
         USE (oDp:cFileSld) SHARED VIA "DBFCDX" ALIAS "SLD"
         SET INDEX TO (cIndex)
      ENDIF

      dFchAct = EVAL(oDp:bFecha,dFchAct)
     
      IF nMonto = 0 
         RETURN
      ENDIF

      IF ! DBSEEK( cTipSld + cCodCta ) 
         NUEVO()
         BLOC()
         FIELDPUT( 1 , cTipSld + cCodCta )
      ENDIF

      cMes    := MONTH( dFchAct )
      cMes    := StrZero( cMes , 2 )
      nPosCam := FieldPos( "SLD_" + cCampo + cMes )

      BLOC()
      cMes := VAL(cMes) + 1
      IF cCampo = "D"
         FieldPut( nPosCam , FieldGet( nPosCam ) + ( nMonto*nModo) )
      ELSE
         FieldPut( nPosCam , FieldGet( nPosCam ) + ( nMonto*nModo) )
      ENDIF
      DbUnLock()
      DpSelect( cOldAre )

RETURN .T.
/*
// Hace los Asientos de Caja
*/
FUNCTION ASIENTOEFE(cWhere,cCompro,oSay,oMeter,lExport)
   LOCAL cSql,oTable,cIndex,cDescri:=""

   CLOSE ALL

   SELE A
   cIndex:=STRTRAN(oDp:cFileCaja,".DBF",".CDX")
   USE (oDp:cFileCaja) SHARED VIA "DBFCDX" ALIAS "CAJM"
   SET INDEX TO (cIndex)

   cSql:=" SELECT FCH_DESDE,FCH_HASTA,FCH_SISTEM,FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO,"+;
         " SUM(HIS_MONTO) AS HIS_MONTO FROM NMRECIBOS "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+; 
         " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
         " LEFT  JOIN NMBANCOS     ON BAN_CODIGO=REC_CODBCO "+;
         " INNER JOIN NMHISTORICO  ON REC_NUMERO=HIS_NUMREC "+;
         cWhere+;
         " AND REC_FORMAP='E' "+;
         " GROUP BY FCH_DESDE,FCH_HASTA,FCH_SISTEM,FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO"


    oTable:=OpenTable(cSql,.T.)
//    oTable:Browse()
// ? oTable:cSql

    WHILE !oTable:Eof()

       cDescri:=oTable:FCH_TIPNOM+":"+ALLTRIM(oTable:FCH_OTRNOM)+" "+DTOC(oTable:FCH_DESDE)+" "+DTOC(oTable:FCH_HASTA)

       AADD(oDp:aCajBco,{"CAJA",;
                         "EFECTIVO",;
                         "EF",;
                         "NM" +oTable:FCH_NUMERO,;
                         cDescri,;
                         oTable:HIS_MONTO,;
                         0,;
                         oTable:FCH_SISTEM})

      IF lExport
         oTable:DbSkip()
         LOOP
      ENDIF


      NUEVO()
      BLOC()
      REPLACE CAJ_FECHA  WITH oTable:FCH_SISTEM,;
              CAJ_TIPO   WITH "EF",;
              CAJ_OPERAC WITH "E",;
              CAJ_NUMERO WITH "NM" +oTable:FCH_NUMERO,;
              CAJ_ORIGEN WITH "NMW",;
              CAJ_USUARI WITH oDp:cUsuario,;
              CAJ_MONTO  WITH oTable:HIS_MONTO,;
              CAJ_COMPRO WITH cCompro,;
              CAJ_CONTAB WITH IIF(Empty(cCompro),"N","S"),;
              CAJ_HORA   WITH TIME(),;
              CAJ_NUMCAJ WITH NETNAME()

      ACTSLDBCO([E],"EFECTIVO",1,[H],CAJ_FECHA,CAJ_MONTO,.T.)

      oTable:DbSkip()

    ENDDO

//    oTable:Browse()
//    oTable:End()
//   ? cWhere,cCompro,CHKSQL(cSql),cSql

  CLOSE ALL

RETURN .T.
// EOF
