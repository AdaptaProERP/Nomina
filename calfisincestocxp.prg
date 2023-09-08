// Programa   : CALFISINCESTOCXP
// Fecha/Hora : 21/07/2020 17:23:55
// Propósito  : Crear Documento de CxP desde Conceptos de Pago
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dFecha,cRegPla,cTipDoc,aCodCon,cRif,nPeriodo,lSave)
  LOCAL aPeriodo:={NIL,NIL}
  LOCAL dDesde,dHasta,dFchIni
  LOCAL aFechas:={},cSql,cField,oTable,cWhere,cTitle,cSql

  DEFAULT dFecha:=CTOD("05/01/2022"),;
          oDp:cTipFecha:=NIL,;
          cTipDoc :="INC",;
          aCodCon :={"D006","P204"},;
          nPeriodo:=6,;
          cRif    :=oDp:cRifInces,;
          lSave   :=.T.

  cCodPro :=SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_RIF"+GetWhere("=",cRif))

  IF Empty(oDp:cTipFecha) .OR. oDp:cTipFecha=NIL
     EJECUTAR("NMRESTDATA")
  ENDIF

  dFchIni:=FCHINIMES(dFecha)-1
  aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,dFchIni)
  dDesde :=aFechas[1]
  dHasta :=aFechas[2]
  cField:=HISFECHA(oDp:cTipFecha)

  IF Empty(cRegPla)

    cWhere:="  PLP_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
            "  PLP_TIPDOC"+GetWhere("=",cTipDoc      )+" AND "+;
            "  "+GetWhereAnd("PLP_FECHA",dDesde,dHasta)

    cRegPla:=SQLGET("DPDOCPROPROG","PLP_NUMREG,PLP_FECHA",cWhere)
    dFecha :=DPSQLROW(2,CTOD(""))

  ENDIF

  IF lSave

    cWhere:=" INNER JOIN NMTRABAJADOR    ON REC_CODTRA=CODIGO "+;
            " INNER JOIN NMHISTORICO     ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
            " INNER JOIN NMFECHAS        ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
            " WHERE "+GetWhereAnd(cField,dDesde,dHasta)+" AND "+GetWhereOr("HIS_CODCON",aCodCon)+;
            " GROUP BY FCH_NUMERO "

    oTable:=OpenTable("SELECT FCH_NUMERO FROM NMRECIBOS "+cWhere,.T.)
    oTable:End()

    IF oTable:RecCount()=0
      RETURN .F.
    ENDIF

  ENDIF

//  IF COUNT("NMRECIBOS",cWhere)=0
//     RETURN .T.
//  ENDIF

  cWhere:=GetWhereAnd(cField,dDesde,dHasta)+" AND "+GetWhereOr("HIS_CODCON",aCodCon)


  IF lSave

     EJECUTAR("BRNMHISTOCXP",cWhere,NIL,NIL,NIL,NIL,cTitle,cTipDoc,cRegPla,cRif)

  ELSE

    cSql:=" SELECT "+;
          " SUM(HIS_MONTO*IF(HIS_MONTO<0,-1,1)) AS HIS_MONTO "+;
          " FROM NMRECIBOS  "+;
          " INNER JOIN NMHISTORICO     ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC  "+;
          " INNER JOIN NMFECHAS        ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO  "+;
          " WHERE "+cWhere+;
          " GROUP BY FCH_NUMERO,HIS_CODCON"+;
          ""

     oTable:=OpenTable(cSql,.T.)

// ? oDp:cSql,oTable:Browse()
     oDp:nMonto:=oTable:HIS_MONTO
     oTable:End()
   
  ENDIF

RETURN .T.
// EOF
