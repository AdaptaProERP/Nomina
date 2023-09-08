// Programa   : NMCONTBLD
// Fecha/Hora : 03/04/2005 17:47:20
// Propósito  : Genera Asientos Contables
// Creado Por : Juan Navas
// Llamado por: NMCONTABIL
// Aplicación : Nómina
// Tabla      : NMFECHAS
// Mejora en contabilizacion por transferencia agregada "   AND FCH_NUMERO"+GetWhere("=",cNumFch)+;
// para q contabilize solo en periodo a actualizar. (TJ)

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cClave)
  LOCAL cSql,oTable,cSqlT,cSqlE,oAsiento,cColName:="Dpto",cSqlC
  LOCAL cInner:="",cDescri:="",cSubTitle:="",nCheques,aData
  LOCAL aConTrabEx:="" // Conceptos Excluidos por Trabajador
  LOCAL aCodTra   :="" // Trabajadores que seran Contabilizados
  LOCAL cWhereTrab:=""
  LOCAL cSqlTrab  :="" // Sql por Trabajador
  LOCAL cKeyField :=""

  // Contabiliza por Departamento

  DEFAULT cWhere:="REC_CODDEP",cWhere:="FCH_NUMERO"+GetWhere("=",STRZERO(2,6))

  IF cWhere=NIL
     cWhere=""
  ENDIF

  cInner :="INNER JOIN DPDPTO ON <CLAVE>=DEP_CODIGO "
  cDescri:="DEP_DESCRI"
  cClave :=IIF(Empty(cClave),"REC_CODDEP",cClave)
 
//  ? cClave

  IF LEFT(UPPE(oDp:cContab),6)="UNIDAD"
     cClave  :="REC_CODUND"
     cInner  :="INNER JOIN NMUNDFUNC ON <CLAVE>=CEN_CODIGO "
     cDescri :="CEN_DESCRI"
     cColName:="Und."
  ENDIF

  IF UPPE(oDp:cContab)="GRUPO"
     cClave  :="REC_CODGRU"
     cInner  :="INNER JOIN NMGRUPO ON <CLAVE>=GTR_CODIGO "
     cDescri :="GTR_DESCRI"
     cColName:="Grupo"
  ENDIF

  IF UPPE(oDp:cContab)="CONCEPTO" 
     cClave  :="HIS_CODCON"
     cInner  :=""
     cDescri :="CON_DESCRI"
     cColName:="Concepto"
  ENDIF
//" (LEFT(HIS_CODCON,1)"+GetWhere("=","A")+"
  //         FCH_NUMERO"+GetWhere("=","00003")     =\'00003\'
//original cWhere:=" WHERE FCH_NUMERO=\'00003\' "
  IF Empty(cWhere)
     cWhere:=" WHERE FCH_NUMERO"+GetWhere("=","00003")
  ELSE
     cWhere:=" WHERE "+cWhere + " "
  ENDIF

/*
 nCheques:=COUNT("NMRECIBOS","INNER JOIN NMFECHAS ON FCH_NUMERO=REC_NUMFCH",cWhere+;
                  "AND REC_FORMAP=\'C\' AND REC_NUMCHQ=\'\'")

*/


  nCheques:=COUNT("NMRECIBOS","INNER JOIN NMFECHAS ON FCH_CODSUC=REC_CODSUC AND FCH_NUMERO=REC_NUMFCH "+cWhere+;
                  "AND REC_FORMAP"+GetWhere("=","A")+" AND REC_NUMCHQ"+GetWhere("="," ")+" ")

  // Solo Exige los Cheques cuando está Integrado con Administrativo
  IF !Empty(nCheques) .AND. !Empty(oDp:cPathBco)
     MensajeErr("Es necesario Indicar los numero de cheque para "+LSTR(nCheques)+" Recibo(s)")
     cWhere:=STRTRAN(cWhere,"FCH_NUMERO","REC_NUMFCH")
     cWhere:=STRTRAN(cWhere," WHERE ","")
     EJECUTAR("NMSETCHEQUE",cWhere)
     RETURN .F.
  ENDIF

  // Verifica Cuantas transferencias no tienen número de débito
  cSql:="SELECT FCH_NUMERO FROM NMFECHAS "+;
        "INNER JOIN NMRECIBOS   ON FCH_CODSUC=REC_CODSUC AND FCH_NUMERO=REC_NUMFCH "+;
        "INNER JOIN NMBANCOS    ON REC_CODBCO=BAN_CODIGO "+;
        "LEFT  JOIN NMDEBTRANF  ON DEB_NUMFCH=FCH_NUMERO AND DEB_CODBCO=BAN_CODIGO "+;
        cWhere+" "+;
        " AND FCH_CONTAB"+GetWhere("<>","S")+" "+;
        " AND (REC_FORMAP"+GetWhere("=","T")+" "+;
        " AND (DEB_NUMERO"+GetWhere("="," ")+" OR DEB_NUMERO IS NULL)) "+;
        " GROUP BY FCH_NUMERO "

// /* antes
// " AND FCH_CONTAB<>\'S\' "+;
//    " AND (REC_FORMAP=\'T\' "+;
//  " AND (DEB_NUMERO=\'\' OR DEB_NUMERO IS NULL)) "+;
// */


  oTable:=OpenTable(cSql,!Empty(oDp:cPathBco))
  aData :=oTable:aDataFill
  oTable:End() 

  IF !Empty(aData) .AND. !Empty(oDp:cPathBco)
     cWhere :=GetWhereOr("FCH_NUMERO",aData)
     MensajeErr("Es necesario Indicar los numero de Débito por Transferencia Bancaria")
     EJECUTAR("NMSETDEBITO",cWhere)
     RETURN .F.
  ENDIF

  // Busca los Trabajadores Con cuentas Contables Exclusivas
  cSql:="SELECT REC_CODTRA FROM NMHISTORICO "+;
        "INNER JOIN NMRECIBOS    ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
        "INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
        "INNER JOIN NMCTAXTRAB   ON REC_CODTRA=CXT_CODTRA "+;
         cWhere+" "+;
       " AND FCH_CONTAB"+GetWhere("<>","S")+" "+;
        "GROUP BY REC_CODTRA"

// ANTES " AND FCH_CONTAB<>\'S\' "+;

//? CLPCOPY(cSql)

  oTable    :=OpenTable(cSql,.T.)

  DPWRITE("TEMP\NMCONTBLD.SQL",oTable:cSql)

  cWhereTrab:=GetWhereOr("CXT_CODTRA",oTable:aDataFill)
  oTable:End()

  IF !Empty(cWhereTrab)

     cSql      :="SELECT CXT_CODCON,CXT_CODTRA FROM NMCTAXTRAB WHERE "+cWhereTrab
     oTable    :=OpenTable(cSql,.T.)
     cWhereTrab:=""

     WHILE !oTable:Eof()

       cWhereTrab:=cWhereTrab+IIF(Empty(cWhereTrab),""," OR ")+;
                              "(HIS_CODCON"+GetWhere("=",oTable:CXT_CODCON)+" AND "+;
                              "REC_CODTRA"+GetWhere("=",oTable:CXT_CODTRA)+")"
       oTable:DbSkip()

     ENDDO
     oTable:End()

     cSqlTrab:="SELECT REC_FECHAS,REC_CODTRA,FCH_DESDE,FCH_HASTA , " +;
               "       FCH_NUMERO,HIS_CODCON,CON_DESCRI,CON_CUENTA,CON_CTACON,"+;
               "       FCH_TIPNOM,APELLIDO,NOMBRE,CXT_CODCTA,CXT_CONTRA,<CLAVE>,SUM(HIS_MONTO) AS HIS_MONTO "+;
               "FROM NMHISTORICO "+;
               "INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
               "INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
               "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
               "INNER JOIN NMCTAXTRAB   ON REC_CODTRA=CXT_CODTRA AND HIS_CODCON=CXT_CODCON "+;
               "INNER JOIN NMFECHAS     ON REC_CODSUC=REC_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
               " "+cWhere+" AND ("+cWhereTrab+")"+;
               " GROUP BY REC_FECHAS,REC_CODTRA,FCH_DESDE ,FCH_HASTA,"+;
               "          FCH_NUMERO,CON_DESCRI,HIS_CODCON,CON_CUENTA,CON_CTACON,FCH_TIPNOM "+;
               " ORDER BY FCH_NUMERO,REC_CODTRA,FCH_NUMERO,HIS_CODCON,APELLIDO,NOMBRE,CXT_CODCTA,CXT_CONTRA,<CLAVE>"

     cSqlTrab:=STRTRAN(cSqlTrab,"<CLAVE>" ,cClave )
     cWhere  :=cWhere+" AND NOT ("+cWhereTrab+")"

    // ? CLPCOPY(cSqlTrab),"ESTE DEBE SER PROBADO"

  ENDIF

  cSql:="SELECT REC_FECHAS,<CLAVE>,FCH_DESDE,FCH_HASTA , " +;
        "       FCH_NUMERO,HIS_CODCON,CON_DESCRI,CON_CUENTA,CON_CTACON,"+;
        "       FCH_TIPNOM,<DESCRI>,SUM(HIS_MONTO) AS HIS_MONTO "+;
        "FROM NMHISTORICO "+;
        "INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
        "INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
        " "+cInner+;
        "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
        " "+cWhere+;
        " AND FCH_CONTAB"+GetWhere("<>","S")+" "+;
        " GROUP BY REC_FECHAS,<CLAVE>,FCH_DESDE ,FCH_HASTA,"+;
        "          FCH_NUMERO,CON_DESCRI,HIS_CODCON,CON_CUENTA,CON_CTACON,FCH_TIPNOM "+;
        " ORDER BY FCH_NUMERO,<CLAVE>,FCH_NUMERO,HIS_CODCON,<DESCRI>"


// ANTES " AND FCH_CONTAB<>\'S\' "+;

  // "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
  // UNA NOMINA PUEDE TENER VARIOS BANCOS
  cSql:=STRTRAN(cSql,"<CLAVE>" ,cClave )
  cSql:=STRTRAN(cSql,"<DESCRI>",cDescri)
  cSql:=STRTRAN(cSql,",,",",")
  cSql:=IIF(RIGHT(cSql,1)=",",LEFT(cSql,LEN(cSql)-1),cSql)

  cSqlT:="SELECT REC_FECHAS,FCH_DESDE ,FCH_HASTA ,"+;
         "       FCH_NUMERO,REC_CODBCO,"+;
         "       BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,DEB_NUMERO,SUM(HIS_MONTO) AS HIS_MONTO "+;
         "FROM NMHISTORICO "+;
         "INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
         "INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
         "INNER JOIN NMBANCOS     ON REC_CODBCO=BAN_CODIGO "+;
         "INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
         "LEFT  JOIN NMDEBTRANF   ON NMFECHAS.FCH_NUMERO = NMDEBTRANF.DEB_NUMFCH "+;
         "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
         " "+cWhere+;
         " AND FCH_CONTAB"+GetWhere("<>","S")+" "+;
         " AND REC_FORMAP"+GetWhere("=","T")+" "+;
         " AND (LEFT(HIS_CODCON,1)"+GetWhere("=","A")+" OR LEFT(HIS_CODCON,1)"+GetWhere("=","D")+" ) "+;
         " GROUP BY REC_FECHAS,FCH_DESDE,FCH_HASTA, "+;
         "       FCH_NUMERO,REC_CODBCO,BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,DEB_NUMERO"+;
         " ORDER BY COD_DPTO,FCH_NUMERO,HIS_CODCON"

//ANTES
//    " AND FCH_CONTAB<>\'S\' "+;
//       " AND REC_FORMAP=\'T\' "+;
//     " AND (LEFT(HIS_CODCON,1)=\'A\' OR LEFT(HIS_CODCON,1)=\'D\') "+;
// ? CLPCOPY(cSqlT)

  /*
  //Forma de pago Cheque
  */

  // Efectivo, Un Asiento por Dpto
  MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
                HacerAsiento( oMeter, oText, oDlg, @lEnd, cWhere , cClave, cDescri , cSql , cSqlT , cSqlTrab ) },;
                "Por favor Espere.... " )
  
  IF Empty(oAsiento:aDataFill)
     MensajeErr("No hay Histórico de pagos en la(s) Nómina(s) Seleccionada(s)")
  ELSE
     ViewData(oAsiento,cColName,cSubTitle,cClave,cWhere)
  ENDIF

  oAsiento:End()

  IF !Empty(oDp:cDsnCta)
    CLOSEODBC(oDp:cDsnCta)
  ENDIF

  IF !Empty(oDp:cDsnBco)
    CLOSEODBC(oDp:cDsnBco)
  ENDIF

RETURN .T.

FUNCTION HACERASIENTO(oMeter,oText,oDlg, lEnd, cWhere , cClave, cDescri , cSql , cSqlT, cSqlTrabj)
  LOCAL oTable,aCuentas:={},nAt:=0,cCodCta:="",aCtaXDep:={},I,dFecha,nSaldo:=0,cSqlC,nIDB,cNumDoc:=""
  LOCAL aFormas:={}
  LOCAL cCodDep:="",cNumFch:="",cNomCta:="",cCtaBco
  LOCAL oPagos,nContar:=1,cNombre:=""
  LOCAL cField:=SUBS(cClave,5,6)
  LOCAL cLnkTabla :="NMCTAXDEP"
  LOCAL cLnkClave :="CXD_CODDEP"
  LOCAL cLnkCodCon:="CXD_CODCON"
  LOCAL cLnkCta   :="CXD_CODCTA"
  LOCAL cLnkContra:="CXD_CONTRA" // Contra Partida
  LOCAL cLnkNombre:="DEP_DESCRI"
  LOCAL dDesde    :=CTOD("")
  LOCAL dHasta    :=CTOD("")
  LOCAL bWhile    :={||.T.}

  IF UPPE(cClave)="REC_CODGRU"
     cLnkTabla :="NMCTAXGRU"
     cLnkClave :="CXG_CODGRU"
     cLnkCodCon:="CXG_CODCON"
     cLnkCta   :="CXG_CODCTA"
     cLnkNombre:="GTR_DESCRI"
     cLnkContra:="CXG_CONTRA"
  ENDIF

  IF UPPE(cClave)="REC_CODUND"
     cLnkTabla :="NMCTAXUND"
     cLnkClave :="CXU_CODUND"
     cLnkCodCon:="CXU_CODCON"
     cLnkCta   :="CXU_CODCTA"
     cLnkNombre:="CEN_DESCRI"
     cLnkContra:="CXU_CONTRA"
  ENDIF

  IF UPPE(oDp:cContab)="CONCEPTO" 
     cLnkTabla :="NMCONCEPTOS"
     cLnkContra:="CON_CTACON" // Contra Partida
     cLnkClave :="CON_CODIGO"
     cLnkCodCon:="CON_CODIGO"
     cLnkCta   :="CON_CUENTA"
     cLnkNombre:="CON_DESCRI"
//     cLnkContra:="CON_CTACON"
  ENDIF

  cField     :=LEFT(cField,3)+"_"+RIGHT(cField,3)
  oDlg:cTitle:="Generando Asientos Contables"
  oDlg:SetColor(oDp:nGris,NIL)

  oAsiento:=OpenTable("SELECT COUNT(*) AS ASIENTO FROM "+cLnkTabla,.F.)


? oDp:cSql,"ASIENTO",oAsiento:RecCount()

//oAsiento:Browse()

  DPWRITE("TEMP\ASIENTO.SQL",oAsiento:cSql)
  oAsiento:aDataFill:={}

  oAsiento:AddFields("CUENTA" ,SPACE(40))
  oAsiento:AddFields("TIP_NOM"," " )
  oAsiento:AddFields("OTR_NOM","  ")
  oAsiento:AddFields(cField   ,SPACE(10))
  oAsiento:AddFields("FECHA"  ,CTOD(""))
  oAsiento:AddFields("DESDE"  ,CTOD(""))
  oAsiento:AddFields("HASTA"  ,CTOD(""))
  oAsiento:AddFields("NOMCTA" ,SPACE(20)) // Descripción de la Cuenta
  oAsiento:AddFields("NOMLNK" ,SPACE(40)) // Nombre del Enlace, o Departamento
  oAsiento:AddFields("nSaldo" ,0.11)
  oAsiento:AddFields("CHEQUE" ,0   )
  oAsiento:AddFields("TIPDOC" ,SPACE(10))   //  oAsiento:TIPDOC :="DD"
  oAsiento:AddFields("NUMDOC" ,SPACE(10))

  cKeyField:=cField

// ?  oAsiento:RecCount(),"oAsiento:RecCount() inicio"
  /*
 // Asiento Contable por Trabajador
 */

  IF !Empty(cSqlTrab)

   oTable:=OpenTable(cSqlTrab , .T.)

// CLPCOPY(cSqlTrab)

   WHILE !oTable:Eof()

      cCodCta:=oTable:CXT_CODCTA

      cNomCta:=SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta))

// ? oAsiento:RecCount(),"oAsiento:RecCount() 1",nContar

      // oAsiento:AppendBlank()
      oAsiento:AddRecord(.T.)
      oAsiento:Replace("ASIENTO",nContar++       )
      oAsiento:Replace("CUENTA" ,cCodCta          )
      oAsiento:Replace("NOMCTA" ,cNomCta          )
      oAsiento:Replace("FECHA"  ,oTable:REC_FECHAS)
      oAsiento:Replace("DESDE"  ,oTable:FCH_DESDE )
      oAsiento:Replace("HASTA"  ,oTable:FCH_HASTA )
      oAsiento:Replace("DESCRI" ,ALLTRIM(oTable:CON_DESCRI)+" "+ALLTRIM(oTable:APELLIDO)+","+ALLTRIM(oTable:NOMBRE))
      oAsiento:Replace("COD_CON",oTable:HIS_CODCON)
      oAsiento:Replace("TIP_NOM",oTable:FCH_TIPNOM)
      oAsiento:Replace(cField   ,oTable:FieldGet(cClave))
      oAsiento:Replace("MONTO"  ,oTable:HIS_MONTO,18,2 )
      oAsiento:Replace("NOMLNK" ,ALLTRIM(oTable:APELLIDO)+","+oTable:NOMBRE)
      oAsiento:Replace("TIPDOC" ,SPACE(10))
      oAsiento:Replace("NUMDOC" ,SPACE(12))

      // oAsiento:AddRecord()

      IF !Empty(oTable:CXT_CONTRA) // ContraPartida

         oAsiento:AddRecord(.T.)

? oAsiento:RecCount(),"oAsiento:RecCount() 1 CONTRAPARTIDA"


         cCodCta:=oTable:CXT_CONTRA
         cNomCta:=SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta))

//       oAsiento:Replace("ASIENTO" ,nContar++         )
         oAsiento:Replace("CUENTA" ,cCodCta             )
         oAsiento:Replace("NOMCTA" ,cNomCta             )
         oAsiento:Replace("MONTO"  ,oTable:HIS_MONTO*-1 )
//       oAsiento:AddRecord()

      ENDIF

      oTable:DbSkip()

   ENDDO

   oTable:End()
 
 ENDIF 

? "AQUI ABRE ",cSql

 oTable:=OpenTable(cSql,.T.)
 oMeter:SetTotal(oTable:RecCount())

 WHILE !oTable:Eof() 

   cCodDep:=oTable:FieldGet(cClave)
   dFecha :=oTable:REC_FECHAS
   cNumFch:=oTable:FCH_NUMERO
   aFormas:={}
   dDesde :=IIF(Empty(dDesde),dFecha,dDesde)
   dHasta :=IIF(Empty(dHasta),dFecha,dHasta)
   dDesde :=MIN(dDesde,dFecha)
   dHasta :=MAX(dHasta,dFecha)
   bWhile :={||cCodDep=oTable:FieldGet(cClave) .AND. cNumFch=oTable:FCH_NUMERO}

   SysRefresh(.T.)

   /*
   // Cuentas Contables por Dpto,Grupo,Unidad Funcional
   */
   WHILE !oTable:Eof() .AND. EVAL(bWhile) 
      // cCodDep=oTable:FieldGet(cClave) .AND. cNumFch=oTable:FCH_NUMERO

      oMeter:Set(oTable:Recno())

      nAt    :=ASCAN(aCtaXDep,{|a,n|a[1]=oTable:FieldGet(cClave) .AND. a[2]=oTable:HIS_CODCON})

      IF nAt=0

        cCodCta:=SQLGET(cLnkTabla,cLnkCta,cLnkClave+GetWhere("=",oTable:FieldGet(cClave))+" AND "+;
                                                   cLnkCodCon+GetWhere("=",oTable:HIS_CODCON))
 

        cNomCta:=IIF(Empty(cCodCta),"",;
                                   SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta)))

        AADD(aCtaXDep,{oTable:FieldGet(cClave),oTable:HIS_CODCON,cCodCta,cNomCta})

      ELSE

        cCodCta:=aCtaXDep[nAt,3]
        cNomCta:=aCtaXDep[nAt,4]

      ENDIF

      // Busca la Cuenta en los Conceptos

     IF EMPTY(cCodCta)

       cCodCta:=oTable:CON_CUENTA

       // SQLGET("NMCTAXDEP","CXD_CODCTA","CXD_CODDEP"+GetWhere("=",oTable:REC_CODDEP  )+" AND "+;
       //                                          "CXD_CODCON"+GetWhere("=",oTable:HIS_CODCON))
 
     ENDIF

     IF !Empty(cCodCta)
        cNomCta:=SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta))
     ENDIF

     IF LEFT(oTable:HIS_CODCON,1)$"AD" .OR.  !Empty(cCodCta)

//      ? oAsiento:RecCount(),"oAsiento:RecCount() 2, Solo asiento de AD o HN con cuenta contable",nContar,cCodCta

      oAsiento:AddRecord(.t.)
 //   oAsiento:AppendBlank()
      oAsiento:Replace("ASIENTO" ,nContar++       )
      oAsiento:Replace("CUENTA" ,cCodCta          )
      oAsiento:Replace("NOMCTA" ,cNomCta          )
      oAsiento:Replace("FECHA"  ,oTable:REC_FECHAS)
      oAsiento:Replace("DESDE"  ,oTable:FCH_DESDE )
      oAsiento:Replace("HASTA"  ,oTable:FCH_HASTA )
      oAsiento:Replace("DESCRI" ,oTable:CON_DESCRI)
      oAsiento:Replace("COD_CON",oTable:HIS_CODCON)
      oAsiento:Replace(cField   ,oTable:FieldGet(cClave))
      oAsiento:Replace("TIP_NOM",oTable:FCH_TIPNOM)
      oAsiento:Replace("MONTO"  ,oTable:HIS_MONTO )
      oAsiento:Replace("NOMLNK" ,oTable:FieldGet(cDescri))
      oAsiento:Replace("TIPDOC" ,"")
      oAsiento:Replace("NUMDOC" ,"")

      cNombre:=oAsiento:NOMLNK

     ENDIF     

     // Busca la Contrapartida en Otros Conceptos
     IF !LEFT(oTable:HIS_CODCON,1)$"AD" .AND. !Empty(cCodCta)

        nSaldo :=nSaldo + oTable:HIS_MONTO
        oAsiento:Replace("SALDO " ,nSaldo )

        // oAsiento:AddRecord()

        // Busca Contrapartida
        cCodCta:=SQLGET(cLnkTabla,cLnkContra,cLnkClave +GetWhere("=",oTable:FieldGet(cClave))+" AND "+;
                                             cLnkCodCon+GetWhere("=",oTable:HIS_CODCON))

        IF Empty(cCodCta)
           cCodCta:=oTable:CON_CTACON
        ENDIF

        nSaldo :=nSaldo - oTable:HIS_MONTO

 ? oAsiento:RecCount(),"oAsiento:RecCount() 3, Contrapartida",nContar

        oAsiento:AddRecord(.T.)
//      oAsiento:AppendBlank()
        oAsiento:Replace("CUENTA" ,cCodCta )
        oAsiento:Replace("FECHA"  ,oTable:REC_FECHAS)
        oAsiento:Replace("DESDE"  ,oTable:FCH_DESDE )
        oAsiento:Replace("HASTA"  ,oTable:FCH_HASTA )
        oAsiento:Replace("DESCRI" ,oTable:CON_DESCRI)
        oAsiento:Replace("COD_CON",oTable:HIS_CODCON)
        oAsiento:Replace(cField   ,oTable:FieldGet(cClave))
        oAsiento:Replace("TIP_NOM",oTable:FCH_TIPNOM )
        oAsiento:Replace("MONTO"  ,oTable:HIS_MONTO*-1 )
        oAsiento:Replace("ASIENTO",nContar++)
        oAsiento:Replace("SALDO"  ,nSaldo)
        oAsiento:Replace("TIPDOC" ,"")
        oAsiento:Replace("NUMDOC" ,"")

//      oAsiento:AddRecord()

     ENDIF

     // JN 24/10/2017 Duplica Registro
     IF LEFT(oTable:HIS_CODCON,1)$"AD" .AND. .F.
        oAsiento:AddRecord(.T.)
        nSaldo :=nSaldo + oTable:HIS_MONTO
        oAsiento:Replace("SALDO XXXX DUPLICA" ,nSaldo )
//      oAsiento:AddRecord()
        ? "AQUI DUPLICA"
     ENDIF
 
     oTable:DbSkip()
   
   ENDDO

// RETURN // QUITAR 


   nAt   :=oAsiento:FieldPos("MONTO")
   nSaldo:=0
   IF nAt>0
      AEVAL(oAsiento:aDataFill,{|a,n|nSaldo:=nSaldo+a[nAt]})
   ENDIF


   // Al finalizar Cada Dpto, Debe hacer el Asiento de Caja

   cSqlE:="SELECT REC_FECHAS,FCH_DESDE,FCH_HASTA ,"+;
          "       FCH_NUMERO,FCH_TIPNOM, <CLAVE>,"+;
          "       SUM(HIS_MONTO) AS HIS_MONTO "+;
          " FROM  NMHISTORICO "+;
          " INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
          " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
          " WHERE REC_FORMAP"+GetWhere("=","E")+" "+;
          "   AND FCH_CONTAB"+GetWhere("<>","S")+" "+;
          "   AND FCH_NUMERO"+GetWhere("=",cNumFch)+;
          IIF(cClave="HIS_CODCON",""," AND <CLAVE>   "+GetWhere("=",cCodDep))+;
          "   AND (LEFT(HIS_CODCON,1)"+GetWhere("=","A")+" OR LEFT(HIS_CODCON,1)"+GetWhere("=","D")+") "+;
          " GROUP BY REC_FECHAS,FCH_DESDE,FCH_HASTA, "+;
          "       FCH_NUMERO,FCH_TIPNOM, <CLAVE> "+;
          " ORDER BY <CLAVE>,FCH_NUMERO"

  cSqlE:=STRTRAN(cSqlE,"<CLAVE>",cClave)

 // ANTES  " WHERE REC_FORMAP=\'E\'  "+;
   //       "   AND FCH_CONTAB<>\'S\' "+;

// "   AND (LEFT(HIS_CODCON,1)=\'A\' OR LEFT(HIS_CODCON,1)=\'D\') "+;


  IF cClave<>"HIS_CODCON"

      ASIENTOEFE(cSqlE,cNombre)

  ENDIF

  /*
  // Pagos con Cheque hace un Registro por Trabajador
  */
  cSqlC:="SELECT REC_NUMERO,REC_CODTRA,REC_NUMCHQ,REC_FECHAS,FCH_DESDE ,FCH_HASTA ,"+;
         "       FCH_NUMERO,REC_CODBCO,"+;
         "       BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,APELLIDO,NOMBRE,SUM(HIS_MONTO) AS HIS_MONTO "+;
         "FROM NMHISTORICO "+;
         "INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
         "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO     "+;
         "LEFT  JOIN NMBANCOS     ON REC_CODBCO=BAN_CODIGO "+;
         "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
         " WHERE REC_FORMAP"+GetWhere("=","C") +;
         "   AND FCH_NUMERO"+GetWhere("=",cNumFch)+;
         "   AND FCH_CONTAB"+GetWhere("<>","S")+;
         IIF(cClave="HIS_CODCON","","   AND <CLAVE>   "+GetWhere("=",cCodDep))+;
         "   AND HIS_CODCON"+GetWhere("<=","DZZZ")+;
         " GROUP BY REC_NUMERO,REC_CODTRA,REC_NUMCHQ,REC_FECHAS,FCH_DESDE ,FCH_HASTA ,"+;
         "          FCH_NUMERO,REC_CODBCO,"+;
         "          BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,APELLIDO,NOMBRE "

   cSqlC:=STRTRAN(cSqlC,"<CLAVE>",cClave)


//ANTES " WHERE REC_FORMAP=\'C\' "+;
//"   AND FCH_CONTAB<>\'S\' "+;
//"   AND HIS_CODCON<=\'DZZZ\' "+;

   IF cClave<>"HIS_CODCON"
      ASIENTOCHQ(cSqlC)
   ENDIF

  ENDDO

  IF cClave="HIS_CODCON"

    cSqlE:="SELECT REC_FECHAS,FCH_DESDE,FCH_HASTA ,"+;
            "       FCH_NUMERO,FCH_TIPNOM,"+;
            "       SUM(HIS_MONTO) AS HIS_MONTO "+;
            " FROM  NMHISTORICO "+;
            " INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
            " INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
            " WHERE REC_FORMAP"+GetWhere("=","E")+;
            "   AND FCH_NUMERO"+GetWhere("=",cNumFch)+;
            "   AND FCH_CONTAB"+GetWhere("<>","S")+;
            "   AND HIS_CODCON"+GetWhere("<=","DZZZ")+;
            " GROUP BY REC_FECHAS,FCH_DESDE,FCH_HASTA, "+;
            "       FCH_NUMERO,FCH_TIPNOM"

     ASIENTOEFE(cSqlE)
     ASIENTOCHQ(cSqlC)

  ENDIF

  oMeter:Set(oTable:RecCount())

 // Genera las Transferencias Bancarias por cada Periodo

 cSqlT:=" SELECT FCH_NUMERO,FCH_SISTEM,FCH_DESDE,FCH_HASTA,REC_CODBCO, "+;
        " BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA,  "+;
        " SUM(HIS_MONTO) AS HIS_MONTO FROM NMRECIBOS  "+;
        " INNER JOIN NMFECHAS      ON FCH_CODSUC=REC_CODSUC AND FCH_NUMERO=REC_NUMFCH "+;
        " INNER JOIN NMHISTORICO   ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
        " LEFT  JOIN NMBANCOS ON REC_CODBCO=BAN_CODIGO "+;
        " WHERE HIS_CODCON"+GetWhere("<","DZZZ")+;
        "   AND FCH_NUMERO"+GetWhere("=",cNumFch)+;      // (TJ)
        "   AND REC_FORMAP"+GetWhere("=","T")+;
        "   AND FCH_CONTAB"+GetWhere("<>","S")+;
        " GROUP BY FCH_NUMERO,FCH_SISTEM,FCH_DESDE,FCH_HASTA,REC_CODBCO, "+;
        " BAN_CODCTA,BAN_NOMBRE,BAN_CUENTA "+;
        " ORDER BY FCH_NUMERO "

 oPagos:=OpenTable(cSqlT,.T.)

// oPagos:Browse()

 oPagos:GoTop()

 DO WHILE !oPagos:Eof() .and. .f.

     cNumDoc:=SQLGET("NMDEBTRANF","DEB_NUMERO,DEB_CTABCO","DEB_NUMFCH"+GetWhere("=",oPagos:FCH_NUMERO)+" AND "+;
                                               "DEB_CODBCO"+GetWhere("=",oPagos:REC_CODBCO))

     cCtaBco:=IIF( Empty(oDp:aRow) , "" , oDp:aRow[2])
     cCodCta:=oPagos:BAN_CODCTA

// ? cNumDoc,"NUMDOCUMENTO"

     IF "SGE"$oDp:cPathCta

       cCodCta:=SQLGET("DPCTABANCO","BCO_CUENTA","BCO_CODIGO"+GetWhere("=",oPagos:REC_CODBCO)+" AND "+;
                                                 "BCO_CTABAN"+GetWhere("=",oPagos:BAN_CUENTA))

     ENDIF

     IF !Empty(oDp:cDsnBco) .AND. !"SGE"$oDp:cPathCta
        cCodCta:=SQLGET("DPBCO","BCO_CUENTA","BCO_CTABAN"+GetWhere("=",oPagos:BAN_CUENTA))
     ENDIF


     cCodCta:= IIF(Empty(cCodCta) , oDp:cCtaNXP , cCodCta )

     cNomCta:=IIF(Empty(cCodCta),"",;
              SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta)))

     nSaldo:=nSaldo-oPagos:HIS_MONTO

// ? oAsiento:RecCount(),"oAsiento:RecCount() 4",nContar

     oAsiento:AddRecord(.T.)
//   oAsiento:AppendBlank()
     oAsiento:Replace("NOMCTA"  ,cNomCta          )
     oAsiento:Replace("ASIENTO" ,nContar++)
     oAsiento:Replace("CUENTA"  ,cCodCta )
     oAsiento:Replace("FECHA"   ,oPagos:FCH_SISTEM)
     oAsiento:Replace("DESCRI"  ,"TransXXferencia: "+oPagos:BAN_NOMBRE)
     oAsiento:Replace("MONTO"   ,oPagos:HIS_MONTO*-1)
     oAsiento:Replace("SALDO"   ,nSaldo)
     oAsiento:Replace("COD_CON" ,"")
     oAsiento:Replace("TIPDOC"  ,"DEB")
     oAsiento:Replace("NUMDOC"  ,cNumDoc)
     oAsiento:Replace(cField    ,"")
//   oAsiento:AddRecord()

     // Débito %
     // JN 17/10/2017 Debito Bancario se Aplica cuando se Concilia
     IF !Empty(oDp:nDebBanc) .AND. .F.

         nIDB    :=PORCEN(oPagos:HIS_MONTO,oDp:nDebBanc)*-1
         nSaldo  :=nSaldo-oPagos:HIS_MONTO

         oAsiento:AppendBlank()
         oAsiento:Replace("NOMCTA" ,cNomCta  )
         oAsiento:Replace("ASIENTO",nContar++)
         oAsiento:Replace("CUENTA" ,cCodCta  )
         oAsiento:Replace("FECHA"  ,oPagos:FCH_SISTEM)
         oAsiento:Replace("DESCRI" ,"IDB Transferencia: "+oPagos:BAN_NOMBRE)
         oAsiento:Replace("MONTO"  ,nIDB  )
         oAsiento:Replace("SALDO"  ,nSaldo)
         oAsiento:Replace("COD_CON",""    )
         oAsiento:Replace("TIPDOC" ,"DB"  )
         oAsiento:Replace("NUMDOC" ,"IDB"+cNumDoc)

         oAsiento:AddRecord()

         nSaldo  :=nSaldo-oPagos:HIS_MONTO
         cCodCta :=oDp:cCtaIDB

         cNomCta:=IIF(Empty(cCodCta),"",;
              SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta)))

         oAsiento:AppendBlank()
         oAsiento:Replace("NOMCTA" ,cNomCta  )
         oAsiento:Replace("ASIENTO",nContar++)
         oAsiento:Replace("CUENTA" ,cCodCta )
         oAsiento:Replace("FECHA"  ,oPagos:FCH_SISTEM)
         oAsiento:Replace("DESCRI" ,"IDB Transferencia: "+oPagos:BAN_NOMBRE)
         oAsiento:Replace("MONTO"  ,nIDB*-1)
         oAsiento:Replace("SALDO"  ,nSaldo)
         oAsiento:Replace("COD_CON","")
         oAsiento:Replace("TIPDOC" ,"IDB")
         oAsiento:Replace("NUMDOC" ,"IDB"+cNumDoc)

//       oAsiento:AddRecord()

     ENDIF

     oPagos:DbSkip()

 ENDDO

 IF cClave="HIS_CODCON"
    nAt:=oAsiento:FieldPos("NOMLNK")
    FOR I=1 TO LEN(oAsiento:aDataFill)
       // oAsiento:DbGoto(I)
       oAsiento:aDataFill[I,nAt]:=SPACE(20)
//       oAsiento:aDataFill[I,nAt]:=SQLGET("NMCONCEPTOS","CON_DESCRI","CON_CODIGO"+GetWhere("=",oAsiento:aDataFill[I,2]))
    NEXT I
 ENDIF


 // oPagos:Browse()
 oPagos:End()
 oTable:End()

 cSubTitle:="Periodo: "+DTOC(dDesde)+" "+DTOC(dHasta)

 oAsiento:Browse()

RETURN oAsiento

/*
// Crea los Asientos de Caja 
*/
FUNCTION CREA_CAJA(cFchNum,cCodDep,nMonto,oAsiento)
RETURN .T.

/*
// Crea los Asientos de Caja o Bancos
*/
FUNCTION CREA_BCO(cFchNum,cCodDep,nMonto,oAsiento)
RETURN .T.

/*
// Coloca la Barra de Botones
*/
FUNCTION ViewData(oAsiento,cColName,cSubTitle,cClave,cWhere)
   LOCAL oBrw:="",cTitle,nDebe:=0,nHaber:=0,nSaldo:=0,I
   LOCAL oFont,oFontB,aView:={},aLine:={},U,aData,nCol:=oAsiento:FieldPos("MONTO")
   LOCAL cField:=SUBS(cClave,5,6)
   LOCAL nField:=oAsiento:FieldPos(cField),nCta:=oAsiento:FieldPos("NOMCTA")

   aData:=ACLONE(oAsiento:aDataFill)

   IF ValType(oAsiento:NOMLNK)="U"
      oAsiento:REPLACE("NOMLNK","")
   ENDIF

   cTitle:="Asientos Contables"
   nSaldo:=0
 
   FOR I=1 TO LEN(aData)
       oAsiento:Goto(I)
       nSaldo:=nSaldo+oAsiento:MONTO
       aLine:={}
       FOR U=1 TO 8
          AADD(aLine,aData[I,U])
          // AADD(aLine,oAsiento:FieldGet(i))
       NEXT U
       aLine[1]:=STRZERO(oASiento:ASIENTO,4)  
       aLine[2]:=oAsiento:FieldGet(cKeyField)
       aLine[3]:=oAsiento:CUENTA
       aLine[4]:=ALLTRIM(oAsiento:COD_CON+" "+oAsiento:DESCRI)
       aLine[5]:=oAsiento:FECHA
       aLine[6]:=oAsiento:DESDE
       aLine[7]:=oAsiento:HASTA  // TIPDOC           
       aLine[8]:=oAsiento:TIP_NOM           
       AADD(aLine , oAsiento:TIPDOC)
       AADD(aLine , oAsiento:NUMDOC)
       AADD(aLine , IIF(oAsiento:MONTO<0 , 0 , oAsiento:MONTO   ))  // 9
       AADD(aLine , IIF(oAsiento:MONTO>0 , 0 , oAsiento:MONTO*-1))  // 10
       AADD(aLine , nSaldo)                                         // 11
       AADD(aView , aLine)
       aData[I,13]:=nSaldo
   NEXT
   
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oDatCont:=DPEDIT():New("Asientos Contables ["+ALLTRIM(oDp:cContab)+"]","NMDATCONTAB.edt","oDatCont",.T.)
   oDatCont:cPicture :="9,999,999,999.99"
   oDatCont:SetScript() 
   oDatCont:cSubTitle:=cSubTitle
   oDatCont:cColName :=cColName
   oDatCont:cClave   :=cClave
   oDatCont:oAsiento :=oAsiento
   oDatCont:cWhere   :=cWhere
   oDatCont:nCta     :=nCta
   oDatCont:cFileChm :="CAPITULO2.CHM"



   oDatCont:oBrw:=TXBrowse():New( oDatCont:oDlg )
   oDatCont:oBrw:SetArray( aView, .F. )
   oDatCont:aData:=ACLONE(aData)
   oDatCont:oBrw:SetFont(oFont)
   oDatCont:oBrw:lFooter := .T.
   oDatCont:oBrw:lHScroll:= .T.
   oDatCont:oBrw:nFreeze :=3

   oDatCont:oBrw:aCols[1]:cHeader:="Num"
   oDatCont:oBrw:aCols[1]:nWidth :=035

   oDatCont:oBrw:aCols[2]:cHeader:=cColName
   oDatCont:oBrw:aCols[2]:nWidth :=48

   oDatCont:oBrw:aCols[3]:cHeader:="Cuenta"
   oDatCont:oBrw:aCols[3]:nWidth :=160

   oDatCont:oBrw:aCols[4]:cHeader:="Concepto"
   oDatCont:oBrw:aCols[4]:nWidth :=300

   oDatCont:oBrw:aCols[5]:cHeader:="Fecha"
   oDatCont:oBrw:aCols[5]:nWidth :=82

   oDatCont:oBrw:aCols[6]:cHeader:="Desde"
   oDatCont:oBrw:aCols[6]:nWidth :=82

   oDatCont:oBrw:aCols[7]:cHeader:="Hasta"
   oDatCont:oBrw:aCols[7]:nWidth :=82

   oDatCont:oBrw:aCols[8]:cHeader:="Nm"
   oDatCont:oBrw:aCols[8]:nWidth :=25

   oDatCont:oBrw:aCols[09]:cHeader:="Tp"
   oDatCont:oBrw:aCols[09]:nWidth :=60

   oDatCont:oBrw:aCols[10]:cHeader:="Documento"
   oDatCont:oBrw:aCols[10]:nWidth :=90

   oDatCont:oBrw:aCols[11]:cHeader:="Debe"
   oDatCont:oBrw:aCols[11]:nWidth :=110
   oDatCont:oBrw:aCols[11]:nDataStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[11]:nHeadStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[11]:nFootStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[11]:cPicture     :=oDatCont:cPicture
   oDatCont:oBrw:aCols[11]:bStrData     :={|oBrw|oBrw:=oDatCont:oBrw,;
                                                 IIF(oBrw:aArrayData[oBrw:nArrayAt,11]=0,"",;
                                                 TRAN(oBrw:aArrayData[oBrw:nArrayAt,11],oDatCont:cPicture))}

   oDatCont:oBrw:aCols[12]:cHeader:="Haber"
   oDatCont:oBrw:aCols[12]:nWidth :=110
   oDatCont:oBrw:aCols[12]:nDataStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[12]:nHeadStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[12]:nFootStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[12]:cPicture     :=oDatCont:cPicture
   oDatCont:oBrw:aCols[12]:bStrData     :={|oBrw|oBrw:=oDatCont:oBrw,;
                                                 IIF(oBrw:aArrayData[oBrw:nArrayAt,12]=0,"",;
                                                 TRAN(oBrw:aArrayData[oBrw:nArrayAt,12],oDatCont:cPicture))}


   oDatCont:oBrw:aCols[13]:cHeader:="Saldo"
   oDatCont:oBrw:aCols[13]:nWidth :=110
   oDatCont:oBrw:aCols[13]:nDataStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[13]:nHeadStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[13]:nFootStrAlign:= AL_RIGHT
   oDatCont:oBrw:aCols[13]:cPicture     :=oDatCont:cPicture
   oDatCont:oBrw:aCols[13]:bStrData     :={|oBrw|oBrw:=oDatCont:oBrw,;
                                                 TRAN(oBrw:aArrayData[oBrw:nArrayAt,13],oDatCont:cPicture)}


   oDatCont:oBrw:bClrStd := {|oBrw,nClrText|oBrw:=oDatCont:oBrw,;
                                             nClrText:=IIF(oBrw:aArrayData[oBrw:nArrayAt,12]=0,CLR_HBLUE,CLR_HRED),;
                                            {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }

//                                          nClrText:=IIF(oBrw:aArrayData[oBrw:nArrayAt,11]>0,CLR_HBLUE,CLR_HRED),;

   oDatCont:oBrw:aCols[ 11 ]:bClrStd := {|oBrw,nClrText,nClrPane| oBrw    :=oDatCont:oBrw,;
                                                                  nClrPane:=iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ),;
                                                                  nClrText:=CLR_HBLUE,;
                                                                  { nClrText, nClrPane } }

   oDatCont:oBrw:aCols[ 12 ]:bClrStd := {|oBrw,nClrText,nClrPane| oBrw    :=oDatCont:oBrw,;
                                                                  nClrPane:=iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ),;
                                                                  nClrText:=CLR_HRED,;
                                                                  { nClrText, nClrPane } }


   oDatCont:oBrw:aCols[ 13 ]:bClrStd := {|oBrw,nClrText,nClrPane| oBrw    :=oDatCont:oBrw,;
                                                                  nClrPane:=iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ),;
                                                                  nClrText:=0,;
                                                                  { nClrText, nClrPane } }


   oDatCont:oBrw:bClrHeader:= {|| {0,14671839 }}
   oDatCont:oBrw:bClrFooter:= {|| {0,14671839 }}

   AEVAL(oDatCont:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})


   AEVAL(aData,{|a,n|nDebe :=nDebe +IIF(a[nCol]>0,a[nCol],0),;
                     nHaber:=nHaber+IIF(a[nCol]<0,a[nCol],0),;
                     nSaldo:=nDebe+nHaber})

   oDatCont:oBrw:aCols[11]:cFooter      :=TRAN(nDebe    ,oDatCont:cPicture)
   oDatCont:oBrw:aCols[12]:cFooter      :=TRAN(nHaber*-1,oDatCont:cPicture)
   oDatCont:oBrw:aCols[13]:cFooter      :=TRAN(nSaldo   ,oDatCont:cPicture)

   oDatCont:oBrw:CreateFromCode()

   oDatCont:oBrw:bChange:={|oBrw|oBrw:=oDatCont:oBrw,oDatCont:oSay1:SetText("Cuenta : "+oDatCont:aData[oBrw:nArrayAt,oDatCont:nCta]),;
                                                     oDatCont:oSay2:SetText(oDatCont:cColName+" : "+oDatCont:aData[oBrw:nArrayAt,10])}

   oDatCont:Activate({||oDatCont:ViewDatBar(oDatCont)})

   EVAL(oDatCont:oBrw:bChange,oDatCont:oBrw)


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oDatCont)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oDatCont:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   IF !EMPTY(oDp:cPathCta)

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\\RUN.BMP";
             ACTION oDatCont:RunAsiento(oDatCont)

      oBtn:cToolTip:="Expotar hacientos Contables hacia "+oDp:cPathCta

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oDatCont:oBrw,oDatCont:cTitle,oDatCont:cSubTitle))

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\TXT.BMP";
          ACTION (EJECUTAR("NMCONTABTXT",oDatCont:oBrw:aArrayData,oDatCont:cTitle,oDatCont:cSubTitle))

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\XPRINT.BMP";
          ACTION oDatCont:AntImprime(oDatCont)

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xTOP.BMP";
          ACTION (oDatCont:oBrw:GoTop(),oDatCont:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xSIG.BMP";
          ACTION (oDatCont:oBrw:PageDown(),oDatCont:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xANT.BMP";
          ACTION (oDatCont:oBrw:PageUp(),oDatCont:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xFIN.BMP";
          ACTION (oDatCont:oBrw:GoBottom(),oDatCont:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\XSALIR.BMP";
          ACTION oDatCont:Close()

    @ 0.1,58 SAY oDatCont:oSay1 PROMPT "Cuenta : "    OF oBar BORDER SIZE 395,18
    @ 1.4,58 SAY oDatCont:oSay2 PROMPT oDatCont:cColName+" : " OF oBar BORDER SIZE 395,18


  oDatCont:oBrw:SetColor(0,oDp:nGris)

  // 15790320, 16382457
  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

RETURN .T.

#Include "G_Graph.ch"
/*
// Grafica
*/
FUNCTION ViewDatGraf(oDatCont)
RETURN .T.

/*
// Imprimir Antiguedad
*/
FUNCTION ANTIMPRIME(oDatCont)
  ALERT("IMPRIMIR")
RETURN .T.

/*
// Exporta los Asientos Contables
*/
FUNCTION RunAsiento(oDatCont)
  LOCAL aFields:={}
  LOCAL aData:=oDatCont:oBrw:aArrayData,I,U
  LOCAL ctempo:="CRYSTAL\\TEMPO.DBF",cClave:=oDatCont:cClave
  LOCAL oAsiento:=oDatCont:oAsiento 
  LOCAL nField  :=oAsiento:FieldPos("MONTO")

  IF nField>0 // Colocar DOS Decimales
     oAsiento:aFields[nField,4]:=2
  ENDIF

  oDatCont:oAsiento:CTODBF(cTempo)

/*
  IF "DP20"$oDp:cPathCta  .OR. "DP19"$oDp:cPathCta
     oDatCont:Close()
     EJECUTAR("NMCONTADM",cTempo,oDatCont:cWhere)
  ENDIF

  IF "DPCONT"$oDp:cPathCta
     oDatCont:Close()
     EJECUTAR("NMCONTDPC",cTempo,oDatCont:cWhere)
  ENDIF

  IF "PSPLA"$oDp:cPathCta
     oDatCont:Close()
     EJECUTAR("NMCONTSGT",cTempo,oDatCont:cWhere)
  ENDIF
*/


  IF "SGE"$oDp:cPathCta
     oDatCont:Close()
     EJECUTAR("NMCONTSGE",cTempo,oDatCont:cWhere)
  ENDIF



RETURN .T.

FUNCTION ASIENTOEFE(cSqlE,cNombre)


? "por ahora asientoEFE"

RETURN


  DEFAULT cNombre:="EFECTIVO"

  oPagos:=OpenTable(cSqlE,.T.)
  oPagos:GoTop()

  WHILE !oPagos:Eof() 

     cCodCta:=oDp:cCtaEfe
//??  cCodCta
     IF Empty(cCodCta) .AND. !Empty(oDp:cDsnBco)
        // Debe leer los Códigos de Integración
        cCodCta:=SQLGET("DPCTAC","CTA_CODIGO","CTA_NUMERO"+GetWhere("=","A07"))
     ENDIF

 // ? oDp:cCtaEfe,"oDp:cCtaEfe"

     cNomCta:=IIF(Empty(cCodCta),"",;
              SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta)))

     nSaldo :=nSaldo - oPagos:HIS_MONTO

     oAsiento:AppendBlank()
     oAsiento:Replace("CUENTA" ,cCodCta )
     oAsiento:Replace("FECHA"  ,oPagos:REC_FECHAS)
     oAsiento:Replace("DESDE"  ,oPagos:FCH_DESDE )
     oAsiento:Replace("HASTA"  ,oPagos:FCH_HASTA )
     oAsiento:Replace("DESCRI" ,ALLTRIM(cNombre)+" "+DTOC(oPagos:FCH_DESDE)+"-"+DTOC(oPagos:FCH_HASTA))
     oAsiento:Replace("NOMCTA" ,cNomCta          )
     oAsiento:Replace("COD_CON","")
     oAsiento:Replace(cField   ,IIF(cClave="HIS_CODCON","",oPagos:FieldGet(cClave)))
     oAsiento:Replace("TIP_NOM",oPagos:FCH_TIPNOM )
     oAsiento:Replace("NUMDOC" ,"EF"+oPagos:FCH_NUMERO )
     oAsiento:Replace("MONTO"  ,oPagos:HIS_MONTO*-1 )
     oAsiento:Replace("ASIENTO",nContar++)
     oAsiento:Replace("COD_CON","")
     oAsiento:Replace("SALDO " ,nSaldo)
     oAsiento:Replace("TIPDOC" ,"CAJA")
     oAsiento:AddRecord()

     oPagos:DbSkip()

  ENDDO

  oPagos:End()

RETURN NIL

FUNCTION ASIENTOCHQ()

 ? "por ahora asientochq"

RETURN

  oPagos:=OpenTable(cSqlC,.T.)

  oPagos:GoTop()

  WHILE !oPagos:Eof() 

      cCodCta:=oPagos:BAN_CODCTA

   
      IF !Empty(oDp:cDsnBco)
         cCodCta:=SQLGET("DPBCO","BCO_CUENTA","BCO_CTABAN"+GetWhere("=",oPagos:BAN_CUENTA))
      ENDIF
 
      cCodCta:=IIF(Empty(cCodCta),oDp:cCtaNXP)
//? cCodCta
      cNomCta:=IIF(Empty(cCodCta),"",;
               SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta)))

      nSaldo:=nSaldo-oPagos:HIS_MONTO
      oAsiento:AppendBlank()
      oAsiento:Replace("ASIENTO" ,nContar++)
      oAsiento:Replace("NOMCTA" ,cNomCta          )
      oAsiento:Replace("CUENTA",cCodCta )
      oAsiento:Replace("FECHA" ,oPagos:REC_FECHAS)
//    oAsiento:Replace("DESCRI","Cheque "+oPagos:REC_CODTRA+" "+oPagos:BAN_NOMBRE)
      oAsiento:Replace("DESCRI",ALLTRIM(oPagos:APELLIDO)+","+ALLTRIM(oPagos:NOMBRE)+" BCO:"+oPagos:BAN_NOMBRE)
      oAsiento:Replace("MONTO" ,oPagos:HIS_MONTO*-1)
      oAsiento:Replace("SALDO ",nSaldo)
      oAsiento:Replace("COD_CON","")
      oAsiento:Replace("TIPDOC" ,"CHEQUE")
      oAsiento:Replace("NUMDOC" ,oPagos:REC_NUMCHQ)
      oAsiento:AddRecord()
      oPagos:DbSkip()

   ENDDO

   oPagos:End()

RETURN NIL

// EOF
