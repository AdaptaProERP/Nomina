// Programa   : NMEDOCTAPRN
// Fecha/Hora : 19/09/2004 10:14:14
// Propósito  : Calcular Estados de Cuenta por Prestaciones
// Creado Por : Juan Navas
// Llamado por: REPORTE("NMEDOCTAP")
// Aplicación : Nómina
// Tabla      : HISTORICO
// Modificacion .AND. dDesde>=oDp:dFchIniInt, para que tome la fecha de inicio para el 
// calculo de intereses mejorado por Leonardo P. revisado (TJ)

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cSql)
  LOCAL aData:={},dDesde,nInteres:=0,I,lCursor:=.T.
  LOCAL cCodTra,oCursor,cSqlTra,cWhere,cSelect,aSelect
  LOCAL aCodigo:={},oTable
   
  DEFAULT cCodTra:="1002"

  CursorWait()

  IF cSql=NIL 
    cSql:="SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING,CEDULA,HIS_CODCON"+;
          " FROM NMRECIBOS "+;
          " INNER  JOIN NMHISTORICO ON NMRECIBOS.REC_NUMERO = NMHISTORICO.HIS_NUMREC"+;
          " INNER  JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
          " WHERE CODIGO"+GetWhere(">=",cCodTra)+" AND CODIGO"+GetWhere("<=",cCodTra)
  ENDIF

  cWhere :=GetSqlWhere(cSql)

  IF EMPTY(cWhere) 
    cSqlTra:=" SELECT REC_CODTRA FROM NMRECIBOS "+;
             " INNER  JOIN NMHISTORICO ON NMRECIBOS.REC_NUMERO = NMHISTORICO.HIS_NUMREC"+;
             " WHERE HIS_CODCON"+GetWhere("=",oDp:cConPres)+;
             " OR HIS_CODCON"+GetWhere("=",oDp:cConAdel)

    IF oDp:lIndexaInt
      cSqlTra:=cSqlTra+" OR HIS_CODCON"+GetWhere("=",oDp:cConAdel )+;
                       " OR HIS_CODCON"+GetWhere("=",oDp:cConInter)
    ENDIF

    cSqlTra:=cSqlTra+" GROUP BY REC_CODTRA"

    oTable:=OpenTable(cSqlTra,.T.)
    cWhere:=" WHERE "+GetWhereOr("CODIGO",oTable:aDataFill)
    oTable:End()
  ENDIF

  IF !"CODIGO>="$cWhere
    cWhere:=" INNER  JOIN NMRECIBOS    ON NMRECIBOS.REC_CODTRA = NMTRABAJADOR.CODIGO "+;
            " INNER  JOIN NMHISTORICO  ON NMRECIBOS.REC_NUMERO = NMHISTORICO.HIS_NUMREC "+;
            cWhere + ;
            " AND (HIS_CODCON"+GetWhere("=",oDp:cConPres)+;
            " OR HIS_CODCON"+GetWhere("=",oDp:cConAdel)+")"+;
            " GROUP BY CODIGO,APELLIDO,NOMBRE,FECHA_ING"
  ENDIF

  cSqlTra:="SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING,CEDULA FROM NMTRABAJADOR "+;
           " "+cWhere

// AQUI CAMBIO HOY 03-12-09 RD
//   ? cWhere,cSqlTra,CHKSQL(cSqlTra)

  oCursor:=OpenTable(cSql,.F.) // Cursor para el Reporte
  
  oCursor:AppendBlank()

  MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
            INTERESCAL(oDlg,oText,oMeter,@lEnd,@oCursor , cSqlTra )  },;
            "Leyendo Trabajadores", "Calculando Estado de Cuenta"  )

RETURN oCursor

/*
// Realizar Calculo de Interes
*/
FUNCTION INTERESCAL(oDlg , oText , oMeter , lEnd , oCursor , cSqlTra )  
  LOCAL I,aData
  LOCAL cPagos:=oDp:cConAdel

  oText:SetText("Leyendo Trabajadores")
  oText:SetSize(300,17)

  PUBLICO("oTrabajador","NIL")

  oTrabajador:=OpenTable(cSqlTra , .T.)
  oMeter:SetTotal(oTrabajador:RecCount())

  oDlg:SetColor(CLR_BLACK,15724527)
  oText:SetColor(CLR_BLACK,15724527)
  oDlg:Refresh(.T.)

  IF oDp:lIndexaInt
    cPagos:=oDp:cConAdel+","+oDp:cConInter
  ENDIF

  WHILE !oTrabajador:Eof() 
    oMeter:Set(oTrabajador:RecNo())

    oText:SetText("Trabajadores:"+ALLTRIM(oTrabajador:CODIGO)+" "+;
                   ALLTRIM(oTrabajador:APELLIDO)+" "+ALLTRIM(oTrabajador:NOMBRE))

//    aData:=CALEDOCTA(oTrabajador:CODIGO,oTrabajador)
//     aData:={}
//     AADD(aData,{oTrabajador:CODIGO,"","",oTrabajador:FECHA_ING,0})
  
     aData:=EJECUTAR("NMPRESTVIEW",oTrabajador:CODIGO,.T.)

//{oFrmCon:CODIGO,oFrmCon:cNombre,;
//                                            "NOMBRE",oFrmCon:FECHA_ING,0}});
//viewarray(adata)

    FOR I:=1 TO LEN(aData)

      oCursor:Replace("CODIGO"     ,oTrabajador:CODIGO)
      oCursor:Replace("APELLIDO"   ,oTrabajador:APELLIDO)
      oCursor:Replace("NOMBRE"     ,oTrabajador:NOMBRE)
      oCursor:Replace("FECHA_ING"  ,oTrabajador:FECHA_ING)
      oCursor:Replace("CEDULA"     ,oTrabajador:CEDULA) //CAMPO NUEVO
      oCursor:Replace("ANTIGUEDA"  ,ANTIGUEDAD(oTrabajador:FECHA_ING,oDp:dFecha))
      oCursor:Replace("HIS_CODCON" ,aData[I,01])
      oCursor:Replace("HIS_FECHA"  ,aData[I,02])
      oCursor:Replace("HIS_DIAS"   ,aData[I,03])
      oCursor:Replace("HIS_SALARI" ,aData[I,04])
      oCursor:Replace("HIS_ANTIGU" ,aData[I,05])
      oCursor:Replace("HIS_MESES"  ,aData[I,06])
      oCursor:Replace("HIS_ANTICI" ,aData[I,07])
      oCursor:Replace("HIS_INTGAN" ,aData[I,08])
      oCursor:Replace("HIS_INTPAG" ,aData[I,09]) // PAGADO
      oCursor:Replace("HIS_INTCXP" ,aData[I,10]) // X PAGAR
      oCursor:Replace("HIS_DELMES" ,aData[I,11]) // DEL MES
      oCursor:Replace("HIS_MONTO"  ,aData[I,12]) // SALDOS 

      AADD(oCursor:aDataFill,ACLONE(oCursor:aRecord))

    NEXT I       

    oTrabajador:DbSkip()
  ENDDO

  oTrabajador:End()

  RELEASE oTrabajador

RETURN oCursor

/*
// Realización del Cálculo
*/
PROCE CALEDOCTA(cCodTra,oTrabajador)
  LOCAL oBrw,aHisto,cAntigue:=""
  LOCAL I,nMonto:=0,nDias,nAt,nAnticipo:=0,nInteres,aInteres:={},nPagoInt:=0,nAntigue:=0
  LOCAL nIntAcum:=0
  LOCAL cSql,oTable
  LOCAL oFont,oFontB
  LOCAL cPagos:=oDp:cConAdel,dDesde

  IF oDp:lIndexaInt
    cPagos:=oDp:cConAdel+","+oDp:cConInter
  ENDIF
	
  cSql:=" SELECT FCH_HASTA AS HIS_HASTA,HIS_VARIAC,0,HIS_MONTO FROM NMHISTORICO"+;
        " INNER  JOIN NMRECIBOS  ON NMRECIBOS.REC_NUMERO = NMHISTORICO.HIS_NUMREC"+;
        " INNER  JOIN NMFECHAS   ON NMFECHAS.FCH_NUMERO  = NMRECIBOS.REC_NUMFCH "+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
        " AND HIS_CODCON"+GetWhere("=",oDp:cConPres)+;
        " ORDER BY FCH_HASTA"

  oTable:=OpenTable(cSql,.T.)
  aHisto:=oTable:aDataFill
  oTable:End()

  IF Empty(aHisto) // No tiene Datos
    RETURN {}
  ENDIF

  FOR I=1 TO LEN(aHisto)
    nMonto:=nMonto+aHisto[I,4]
    nDias :=nDias +aHisto[I,2]
    ahisto[I,3]:=DIV(aHisto[I,4],aHisto[I,2])
    AADD(ahisto[I],I     )
    AADD(aHisto[I],0     ) // 6 Anticipos
    AADD(aHisto[I],0     ) // 7 Intereses Ganados
    AADD(aHisto[I],0     ) // 8 Intereses Pagados
    AADD(aHisto[I],0     ) // 9 Intereses Por Pagar
    AADD(aHisto[I],nMonto) // 10 Del Mes
    AADD(aHisto[I],nMonto) // 11 Acumulado
  NEXT I

  // Anticipos 
  oTable:=OPENTABLE(" SELECT HIS_CODCON,FCH_DESDE AS HIS_DESDE,FCH_HASTA AS HIS_HASTA,HIS_MONTO FROM NMHISTORICO "+;
                    " INNER  JOIN NMRECIBOS  ON NMRECIBOS.REC_NUMERO = NMHISTORICO.HIS_NUMREC"+;
                    " INNER  JOIN NMFECHAS   ON NMFECHAS.FCH_NUMERO  = NMRECIBOS.REC_NUMFCH "+;
                    " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
                    " AND (HIS_CODCON" +GetWhere("=",oDp:cConAdel  )+;
                     "   OR HIS_CODCON" +GetWhere("=",oDp:cConInter )+;
                     "   OR HIS_CODCON" +GetWhere("=",oDp:cPagInter )+")" ,.T.)


  oTable:GoTop()

  WHILE !oTable:Eof()
    nAt:=ASCAN(aHisto,{|a,i,dFinMes|dFinMes:=FCHFINMES(a[1]),;
                                   (dFinMes=FchFinMes(oTable:HIS_DESDE) .OR.; 
                                    dFinMes=FchFinMes(oTable:HIS_HASTA))})

    // Adelantos
    IF nAt>0 .AND. oTable:HIS_CODCON=oDp:cConAdel
      nAnticipo:=nAnticipo+oTable:HIS_MONTO
      aHisto[nAt,6]:=oTable:HIS_MONTO
    ENDIF

    // Pagos Calculados
      IF nAt>0 .AND. oTable:HIS_CODCON=oDp:cPagInter
         aHisto[nAt,7]:=oTable:HIS_MONTO
         nInteres     :=nInteres+aHisto[nAt,7]
      ENDIF

    // Intereses
    IF nAt>0 .AND. oTable:HIS_CODCON=oDp:cConInter
      nPagoInt:=nPagoInt+oTable:HIS_MONTO
      aHisto[nAt,8]:=oTable:HIS_MONTO
    ENDIF

    oTable:DbSkip()
  ENDDO

  oTable:End()

  dDesde:=oTrabajador:FECHA_ING

  nInteres:=INTERES(NIL,oDp:cConPres,cPagos,dDesde,oDp:dFecha,@aInteres,,,,,,,oDp:lIndexaInt)

  FOR I=1 TO LEN(aInteres)
    dDesde:=FCHFINMES(aInteres[I,2])
    nAt   :=ASCAN(aHisto,{|a,n|FCHFINMES(a[1])=dDesde})

********************** LEONARDO *******************************
    IF nAt>0 .AND. dDesde>=oDp:dFchIniInt 
***************************************************************
      aHisto[nAt,7]:=aHisto[nAt,7]+aInteres[I,7]
    ENDIF
  NEXT I

  // Calcular Total
  nMonto:=0
  FOR I=1 TO LEN(aHisto)
    aHisto[I,10]:=aHisto[I,4]-aHisto[I,6]+aHisto[I,7]-aHisto[I,8]
    nIntAcum    :=nIntAcum+aHisto[I,7]-aHisto[I,8]
//? nIntAcum
    aHisto[I,09]:=nIntAcum
    nAntigue    :=nAntigue+aHisto[I,04]
    nMonto      :=nMonto  +aHisto[I,10] 
    aHisto[I,11]:=nMonto
  NEXT I
 
  aTotal:=ATOTALES(aHisto)  

RETURN aHisto

// EOF
