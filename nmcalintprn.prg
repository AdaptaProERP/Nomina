// Programa   : NMCALINTPRN
// Fecha/Hora : 12/09/2004 17:16:34
// Propósito  : Calcula Intereses para ser Impresos
// Creado Por : Juan Navas
// Llamado por: 
// Aplicación : NOMINA
// Tabla      : NMRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cSql)
  LOCAL aData:={},dDesde,nInteres:=0,I,lCursor:=.T.
  LOCAL cCodTra,oCursor,cSqlTra,cWhere,cSelect,aSelect
  LOCAL aCodigo:={},oTable
   
  DEFAULT cCodTra:="1003"

  CursorWait()

  IF cSql=NIL

      cSql:="SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING,HIS_CODCON,HIS_DESDE,HIS_VARIAC,"+;
            "HIS_MONTO,HIS_NUMMEM,HIS_NUMOBS FROM NMHISTORICO "+;
            "INNER JOIN NMTRABAJADOR ON HIS_CODTRA=CODIGO "+;
            "WHERE CODIGO"+GetWhere(">=",cCodTra)+" AND CODIGO"+GetWhere("<=",cCodTra)

  ENDIF

  cWhere :=GetSqlWhere(cSql)

  IF EMPTY(cWhere) 

     cSqlTra:="SELECT HIS_CODTRA FROM NMHISTORICO WHERE HIS_CODCON"+GetWhere("=",oDp:cConPres)+;
              " OR HIS_CODCON"+GetWhere("=",oDp:cConAdel)

     IF oDp:lIndexaInt .OR. .T.

        cSqlTra:=cSqlTra+" OR HIS_CODCON"+GetWhere("=",oDp:cConAdel )+;
                         " OR HIS_CODCON"+GetWhere("=",oDp:cConInter)

     ENDIF

     cSqlTra:=cSqlTra+" GROUP BY HIS_CODTRA"

     oTable:=OpenTable(cSqlTra,.T.)
     cWhere:=" WHERE "+GetWhereOr("CODIGO",oTable:aDataFill)
     oTable:End()

   ENDIF

   cSqlTra:="SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING FROM NMTRABAJADOR "+;
            " "+cWhere

   oCursor:=OpenTable(cSql,.F.) // Cursor para el Reporte

  
   oCursor:AppendBlank()

   MsgMeter( { | oMeter, oText, oDlg, lEnd | ;
              INTERESCAL(oDlg,oText,oMeter,@lEnd,@oCursor,cSqlTra)  },;
            "Leyendo Trabajadores", "Calculando Intereses"  )

RETURN oCursor

/*
// Realizar Calculo de Interes
*/
FUNCTION INTERESCAL(oDlg , oText , oMeter , lEnd , oCursor , cSqlTra)  
   LOCAL I,aData
   LOCAL cPagos:=oDp:cConAdel
   LOCAL cSql,cWhere,oBtn:=oDlg:aControls[3]

   oBtn:bAction:={||oTrabajador:DbGoBottom()}

   oText:SetText("Leyendo Trabajadores")
   oText:SetSize(300,17)

   IF TYPE("oTrabajador")="U"
      PUBLICO("oTrabajador","NIL")
   ENDIF

   cSqlTra:=ALLTRIM(cSqlTra)
                        
   IF RIGHT(cSqlTra,6)=" WHERE"
      cSqlTra:=LEFT(cSqlTra,LEN(cSqlTra)-6)
   ENDIF

   oTrabajador:=OPENTABLE(cSqlTra,.F.)
   oTrabajador:End()

   cSql:=" SELECT REC_CODTRA FROM NMRECIBOS "+;
         " INNER JOIN NMHISTORICO  ON HIS_NUMREC=REC_NUMERO "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
         "  "+oTrabajador:cWhere+;
         " AND HIS_CODCON='H400' "+;
         " GROUP BY REC_CODTRA "  

   oTrabajador:=OpenTable(cSql,.T.)
// oTrabajador:Browse()

   cWhere:=GetWhereOr("CODIGO",oTrabajador:aDataFill)
   oTrabajador:End()

   IF (" WHERE "$cSqlTra) .AND. !Empty(cWhere)
      cSqlTra:=STRTRAN(cSqlTra," WHERE ", " WHERE "+cWhere+" AND ")
   ENDIF

   IF !(" WHERE "$cSqlTra) .AND. !Empty(cWhere)
      cSqlTra:=cSqlTra+" WHERE "+cWhere
   ENDIF

   oTrabajador:=OPENTABLE(cSqlTra,.T.)

   oMeter:SetTotal(oTrabajador:RecCount())

   oDlg:SetColor(CLR_BLACK,15724527)
   oText:SetColor(CLR_BLACK,15724527)
   oDlg:Refresh(.T.)

   IF oDp:lIndexaInt
      cPagos:=oDp:cConAdel+","+oDp:cConInter
   ENDIF

   oCursor:TASA   :=0
   oCursor:DIAS   :=0
   oCursor:INTERES:=0
   oCursor:CAPITAL:=0

   WHILE !oTrabajador:Eof() 

      oMeter:Set(oTrabajador:RecNo())

      SysRefresh()

      oText:SetText("Trabajadores:"+ALLTRIM(oTrabajador:CODIGO)+" "+;
                     ALLTRIM(oTrabajador:APELLIDO)+" "+ALLTRIM(oTrabajador:NOMBRE))

      dDesde:=oTrabajador:FECHA_ING
      aData :={}
  
//    nInteres:=EJECUTAR("INTERESES",NIL  ,oDp:cConPres,cPagos ,dDesde,oDp:dFecha,{},    ,        ,        ,     ,        ,       ,oDp:lIndexaInt,0,oDp:dFchIniInt)
//    nInteres:=INTERES(NIL,oDp:cConPres,cPagos,dDesde,oDp:dFecha,@aData,,,,,,,oDp:lIndexaInt,0,oDp:dFchIniInt)

      nInteres:=EJECUTAR("INTERESES",NIL,oDp:cConPres,cPagos,dDesde,oDp:dFecha,{},,,,,,oTrabajador:CODIGO,oDp:lIndexaInt,0,oDp:dFchIniInt)
//   INTERES(   cField,cDeuda      ,cAbonos,dDesde,dHasta    ,aVector,NEGATIVO,ANIODIAS,nTasa,_CFINMES,_CAPCOR,cCodTra,lIndexa,nBase,dFchIni,cConIni)

      aData    :=ACLONE(oDp:aIntereses)

// ViewArray(aData)

      aData:= ASORT(aData,,, { |x, y| x[2] < y[2] })

      FOR I=1 TO LEN(aData)
          oCursor:Replace("CODIGO"    ,oTrabajador:CODIGO)
          oCursor:Replace("APELLIDO"  ,oTrabajador:APELLIDO)
          oCursor:Replace("NOMBRE"    ,oTrabajador:NOMBRE)
          oCursor:Replace("FECHA_ING" ,oTrabajador:FECHA_ING)
          oCursor:Replace("HIS_CODCON",aData[I,1])
          oCursor:Replace("HIS_DESDE" ,aData[I,2])
          oCursor:Replace("HIS_VARIAC",aData[I,3])
          oCursor:Replace("HIS_MONTO" ,aData[I,4])
          oCursor:Replace("TASA"      ,aData[I,6]) // %
          oCursor:Replace("DIAS"      ,aData[I,3]) // Días
          oCursor:Replace("INTERES"   ,aData[I,7]) // Interes
          oCursor:Replace("CAPITAL"   ,aData[I,8]) // Capital
          AADD(oCursor:aDataFill,ACLONE(oCursor:aRecord))
      NEXT I       

      oTrabajador:DbSkip()

   ENDDO

   oTrabajador:End()

   RELEASE oTrabajador

// Reporte
// oCursor:=EJECUTAR("NMCALINTPRN",cSql) 

RETURN NIL

// EOF
