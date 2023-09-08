// Programa   : NMCHKCHQSGE
// Fecha/Hora : 30/06/2005 14:55:49
// Propósito  : Revision de Cheques que seran Exportados
// Creado Por : Juan Navas
// Llamado por: NMCONTAADM
// Aplicación : Nómina
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cTipDoc,lExport,cCompro,oSay,oMeter,lCaja)
  LOCAL cSql,cMemo:="",cLine:="",nAt:=0
  LOCAL oTable,aBancos:={},oBcoMov,cNumTra,cWhereMovB
  LOCAL cForma:="",cIndex:="",cNumDoc:="",cCodBco:="",cDescri:="",cNomBco:="",cCtaBco

  DEFAULT lExport    :=.T.,;
          cWhere     :=" WHERE FCH_NUMERO"+GetWhere("=",STRZERO(1,5)),;
          cTipDoc    :="DEB",;
          cCompro    :="",;
          lCaja      :=.T.,;
          oDp:aCajBco:={}

  DEFAULT oDp:nDebBanc:=0

//? oDp:nDebBanc,"oDp:nDebBanc"

  cForma:="REC_FORMAP"+GetWhere("=",IIF(cTipDoc="CH","C","T"))
  cWhere:=IIF(" WHERE "$cWhere,""," WHERE ")+cWhere+;
          " AND FCH_INTEGR<>'S'"
        

  // Los asientos de Caja se hacen cuando se Contabiliza
  IF lCaja .AND. cTipDoc="DEB"
     ASIENTOEFE(cWhere,cCompro,oSay,oMeter,lExport)
  ENDIF

  IIF(ValType(oSay)="O",oSay:SETTEXT("Revisando Cuentas Bancarias "),NIL)

  // Bancos sin Cuenta Bancaria
  cSql:=" SELECT REC_CODBCO,REC_CTABCO,BAN_NOMBRE FROM NMRECIBOS "+;
        " INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
        " LEFT  JOIN NMBANCOS ON BAN_CODIGO=REC_CODBCO "+;
        cWhere+;
        "   AND "+cForma+;
        "   AND FCH_INTEGR<>'S' "+;
        "   AND (BAN_CUENTA='' OR BAN_CUENTA IS NULL) "+;
        " GROUP BY REC_CODBCO,REC_CTABCO,BAN_NOMBRE "

// ? CLPCOPY(cSql)

  oTable:=OpenTable(cSql,.T.)

// oTable:Browse()
// RETURN .T.

/*
//  ? ChkSql(oTable:cSql),CLPCOPY(oTable:cSql)
  oTable:End()
  RETURN .F.
*/

  WHILE !oTable:Eof() .AND. cTipDoc="DEB"
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

      IF cTipDoc="DEB"
         EJECUTAR("NMSETDEBITO",cWhere)
      ENDIF

      RETURN .F.

  ENDIF

/*

  cSql:=" SELECT BAN_CODIGO,BAN_CUENTA,BAN_NOMBRE FROM NMRECIBOS "+;
        " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+; 
        " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
        " LEFT  JOIN NMBANCOS     ON BAN_CODIGO=REC_CODBCO "+;
        cWhere+;
        "   AND "+cForma+;
        " GROUP BY BAN_CODIGO,BAN_CUENTA,BAN_NOMBRE "

  CLOSE ALL

//  SELE A
//  USE (oDp:cFileBco) SHARED VIA "DBFCDX" ALIAS "BCO"

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

*/


  cSql:=" SELECT REC_NUMERO,REC_CODBCO,REC_CTABCO,REC_NUMCHQ,REC_FECHAS,REC_CODTRA,BAN_CUENTA,"+;
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
        " GROUP BY REC_NUMERO,REC_CODBCO,REC_CTABCO,REC_NUMCHQ,REC_FECHAS,REC_CODTRA,BAN_CUENTA,APELLIDO,NOMBRE"

  IF cTipDoc="DEB"

       cSql:=" SELECT FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO,FCH_SISTEM AS REC_FECHAS,FCH_DESDE,FCH_HASTA,REC_CODBCO, "+;
             " BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,REC_CTABCO,  "+;
             " SUM(HIS_MONTO) AS HIS_MONTO FROM NMRECIBOS  "+;
             " INNER JOIN NMFECHAS    ON FCH_NUMERO=REC_NUMFCH "+;
             " INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC "+;
             " INNER JOIN NMBANCOS    ON REC_CODBCO=BAN_CODIGO "+;
             " "+cWhere+;
             "   AND HIS_CODCON<='DZZZ' "+;
             "   AND REC_FORMAP='T' "+;
             " GROUP BY FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO,FCH_SISTEM,FCH_DESDE,FCH_HASTA,REC_CODBCO, "+;
             " BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,REC_CTABCO "+;
            " ORDER BY FCH_NUMERO "


  ENDIF

// ? ChkSql(cSql),
//? CLPCOPY(cSql)
// RETURN .F.
//  ViewArray(aBancos)

  oTable:=OpenTable(cSql,.t.)

//  oTable:Browse()
  oTable:REPLACE("BCO_CODIGO",SPACE(20))
  // Virtualmente Agregamos el codigo del Banco
  cMemo:=""

//  oTable:Browse()

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

//  A->(DBSEEK(cCodBco)) // Nombre del Banco
    cCodBco:=oTable:REC_CODBCO
    cCtaBco:=oTable:REC_CTABCO

    cNomBco:=SQLGET("DPBANCOS","BAN_NOMBRE,BAN_CODIGO","BAN_CODIGO"+GetWhere("=",cCodBco))

    IF Empty(cNomBco) .OR. Empty(oDp:aRow)

       cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+;
              "Falta Banco : "+cCodBco+;
              " "+IIF(cTipDoc="CHQ",oTable:REC_NUMERO,"Nómina:"+oTable:FCH_NUMERO)+" CodBco:"+oTable:REC_CODBCO

       oTable:DbSkip()

       LOOP

    ENDIF

    IIF(ValType(oSay)="O",oSay:SETTEXT("Revisando: "+oTable:BCO_CODIGO+cTipDoc+cNumDoc),NIL)

    IF cTipDoc="DEB"

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
              " "+IIF(cTipDoc="CHQ",oTable:REC_NUMERO,"")+" "+oTable:REC_CODBCO+" "
//              cTipDoc+" <Falta Num> "+MOVB->MOV_DESCRI

       oTable:DbSkip()

       LOOP

    ENDIF

    cWhereMovB:="MOB_CODSUC"+GetWhere("=",oDp:cSucSge      )+" AND "+;
                "MOB_CODBCO"+GetWhere("=",oTable:REC_CODBCO)+" AND "+;
                "MOB_CUENTA"+GetWhere("=",oTable:REC_CTABCO)+" AND "+;
                "MOB_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
                "MOB_DOCUME"+GetWhere("=",cNumDoc          )


//? cWhereMovB
//? SQLGET("DPCTABANCOMOV","MOB_DESCRI",cWhereMovB), cWhereMovB

    IF !Empty(SQLGET("DPCTABANCOMOV","MOB_DESCRI",cWhereMovB))

//  IF MOVB->(DBSEEK(oTable:BCO_CODIGO+cTipDoc+cNumDoc))

       cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+;
              "Ya Existe   "+;
              " "+IIF(cTipDoc="CHQ",oTable:REC_NUMERO,"")+" "+oTable:REC_CODBCO+" "+;
              oTable:REC_CTABCO+" "+cTipDoc+" "+cNumDoc+" "+oDp:aRow[1]

       oTable:DbSkip()

       LOOP

    ENDIF

    AADD(oDp:aCajBco,{cCodBco,;
                      ALLTRIM(cNomBco)+" "+cCtaBco,;
                      cTipDoc,;
                      cNumDoc,;
                      cDescri,;
                      oTable:HIS_MONTO,;
                      PORCEN(oTable:HIS_MONTO,oDp:nDebBanc),;
                      oTable:REC_FECHAS})


    IF lExport 

      IIF(ValType(oSay)="O",oSay:SETTEXT("Grabando: "+oTable:BCO_CODIGO+cTipDoc+cNumDoc),NIL)

      cWhereMovB:="MOB_CODSUC"+GetWhere("=",oDp:cSucSge      )+" AND "+;
                  "MOB_CODBCO"+GetWhere("=",oTable:REC_CODBCO)+" AND "+;
                  "MOB_CUENTA"+GetWhere("=",oTable:REC_CTABCO)+" AND "+;
                  "MOB_TIPO  "+GetWhere("=",cTipDoc     )


      cNumTra:=SQLINCREMENTAL("DPCTABANCOMOV","MOB_NUMTRA",cWhereMovB)

      oBcoMov:=OpenTable("SELECT * FROM DPCTABANCOMOV",.F.)
      oBcoMov:Append()

//  ? cTipDoc,oTable:REC_CODBCO,oTable:REC_CTABCO
	
      oBcoMov:Replace("MOB_CODBCO", oTable:REC_CODBCO)
      oBcoMov:Replace("MOB_CUENTA", oTable:REC_CTABCO)
      oBcoMov:Replace("MOB_CODSUC", oDp:cSucSge      )
      oBcoMov:Replace("MOB_TIPO  ", cTipDoc          )
      oBcoMov:Replace("MOB_ACT  " , 1                )
      oBcoMov:Replace("MOB_DEBCRE", -1               )
      oBcoMov:Replace("MOB_MONTO ", oTable:HIS_MONTO )
      oBcoMov:Replace("MOB_MONNAC", oTable:HIS_MONTO )
      oBcoMov:Replace("MOB_ORIGEN", "NOM"            )
      oBcoMov:Replace("MOB_COMPRO", cCompro          )
      oBcoMov:Replace("MOB_IDB"   , PORCEN(oTable:HIS_MONTO,oDp:nDebBanc))

      IF cTipDoc="DEB"
         oBcoMov:Replace("MOB_DOCASO", oTable:FCH_NUMERO)

         oBcoMov:Replace("MOB_DESCRI", "Nómina:"+oTable:FCH_TIPNOM+" "+;
                                       DTOC(oTable:FCH_DESDE)+"-"+DTOC(oTable:FCH_HASTA))
      ELSE
         oBcoMov:Replace("MOB_DESCRI", ALLTRIM(oTable:APELLIDO)+","+oTable:NOMBRE)
         oBcoMov:Replace("MOB_DOCASO", oTable:REC_NUMERO)
      ENDIF

      oBcoMov:Replace("MOB_DOCUME", cNumDoc          )
      oBcoMov:Replace("MOB_FECHA" , oTable:REC_FECHAS)
      oBcoMov:Replace("MOB_HORA"  , TIME()           )
      oBcoMov:Replace("MOB_NUMTRA", cNumTra          )

      oBcoMov:Commit()

    ENDIF

    oTable:DbSkip()

  ENDDO

  CLOSE ALL

  oTable:End()

  IF !Empty(cMemo)

     cMemo:=PADR("Motivo",12)+" "+PADR("Recibo",7)+" "+PADR("Cod. Banco",10)+" TP Número "+CRLF+;
            REPL("-"     ,12)+" "+REPL("-"     ,7)+" "+REPL("-"         ,10)+" -- -------"+CRLF+;
            cMemo +CRLF+CRLF+;
            "El proceso de Integración requiere disponibilidad de los números de documentos"+CRLF+;
            "que indentifican las transacciones."

      MensajeErr(cMemo,"Registros Bancarios Existentes")

      IF cTipDoc="DEB"
         EJECUTAR("NMSETDEBITO",cWhere)
      ENDIF

      IF cTipDoc="CHQ"
         EJECUTAR("NMSETCHEQUE",cWhere)
      ENDIF

  ENDIF

RETURN Empty(cMemo)

/*
// Hace los Asientos de Caja
*/
FUNCTION ASIENTOEFE(cWhere,cCompro,oSay,oMeter,lExport)
   LOCAL cSql,oTable,cIndex,cDescri:="",oCajaMov

   cSql:=" SELECT FCH_DESDE,FCH_HASTA,FCH_SISTEM,FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO,"+;
         " SUM(HIS_MONTO) AS HIS_MONTO FROM NMRECIBOS "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+; 
         " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
         " LEFT  JOIN NMBANCOS     ON BAN_CODIGO=REC_CODBCO "+;
         " INNER JOIN NMHISTORICO  ON REC_NUMERO=HIS_NUMREC "+;
         cWhere+;
         " AND REC_FORMAP='E' "+;
         " GROUP BY FCH_DESDE,FCH_HASTA,FCH_SISTEM,FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO"


    oCajaMov:=OpenTable("SELECT * FROM DPCAJAMOV",.F.)

    oTable:=OpenTable(cSql,.T.)

    WHILE !oTable:Eof()

       cDescri:=oTable:FCH_TIPNOM+":"+ALLTRIM(oTable:FCH_OTRNOM)+" "+DTOC(oTable:FCH_DESDE)+" "+DTOC(oTable:FCH_HASTA)

       AADD(oDp:aCajBco,{"CAJA",;
                         "EFECTIVO",;
                         "EFE",;
                         "NOM" +oTable:FCH_NUMERO,;
                         cDescri,;
                         oTable:HIS_MONTO,;
                         0,;
                         oTable:FCH_SISTEM})

      IF lExport
         oTable:DbSkip()
         LOOP
      ENDIF


      oCajaMov:Append()

      oCajaMov:Replace("CAJ_FECHA" , oTable:FCH_SISTEM)
      oCajaMov:Replace("CAJ_TIPO " , "EFE")
      oCajaMov:Replace("CAJ_DEBCRE", -1)
      oCajaMov:Replace("CAJ_NUMERO", oTable:FCH_NUMERO)
      oCajaMov:Replace("CAJ_DESCRI", "Nómina"+oTable:FCH_NUMERO+" "+DTOC(oTable:FCH_DESDE)+"-"+DTOC(oTable:FCH_HASTA))
      oCajaMov:Replace("CAJ_ORIGEN", "NOM"            )
      oCajaMov:Replace("CAJ_USUARI", oDp:cUsuario     )
      oCajaMov:Replace("CAJ_MONTO ", oTable:HIS_MONTO )
      oCajaMov:Replace("CAJ_CONTAB", "S"              )
      oCajaMov:Replace("CAJ_HORA"  , TIME()           )
      oCajaMov:Replace("CAJ_NUMCAJ", NETNAME()        )
      oCajaMov:Replace("CAJ_CODSUC", oDp:cSucSge      )
      oCajaMov:Replace("CAJ_CODCAJ", oDp:cCajaSge     )
      oCajaMov:Replace("CAJ_ACT   ", 1                )
      oCajaMov:Commit()

      oTable:DbSkip()

    ENDDO

    oCajaMov:End()

    CLOSE ALL

RETURN .T.
// EOF

