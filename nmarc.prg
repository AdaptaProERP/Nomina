// Programa   : NMARC
// Fecha/Hora : 11/07/2005 12:37:32
// Propósito  : Calcular ARC del Trabajador
// Creado Por : Juan Navas
// Llamado por: NMTRABAJADOR
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,cNombre)
  LOCAL cSql,aData,cPictureM:="999,999,999,999.99",uValue
  LOCAL oFont,oFontB,oBrw,oDlg,cPictureM
  LOCAL nTot02:=0,nTot04:=0,nTot05:=0

  DEFAULT cCodTra:="1002",;
          cNombre:=SQLGET("NMTRABAJADOR","APELLIDO","CODIGO"+GetWhere("=",cCodTra))

  aData:=CALCARC(cCodTra,YEAR(oDp:dFecha))

  AEVAL(aData,{|a,n|nTot02:=nTot02+a[2],;
                    nTot04:=nTot04+a[4]})
 
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  oArc:=DPEDIT():New("Valores para la Planilla ARC [Cód:"+cCodTra+"]","NMARC.edt","oArc",.T.)

  oArc:cCodTra  :=cCodTra
  oArc:cTrabajad:=cNombre
  oArc:cPictureM:=cPictureM
  oArc:nAno     :=YEAR(oDp:dFecha)
  oArc:aData    :=ACLONE(aData)
  oDlg:=oArc:oDlg

  oBrw:=TXBrowse():New( oDlg )

//  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 2

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:CreateFromCode()

  oBrw:aCols[1]:cHeader:="Mes"
  oBrw:aCols[1]:nWidth :=080

  oBrw:aCols[2]:cHeader:="Remuneraciones"
  oBrw:aCols[2]:nWidth :=140
  oBrw:aCols[2]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[2]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[2]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[2]:cFooter       := TRAN(nTot02,cPictureM)
  oBrw:aCols[2]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,2],oArc:cPictureM)}

  oBrw:aCols[3]:cHeader:="%"
  oBrw:aCols[3]:nWidth :=40
  oBrw:aCols[3]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[3]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[3]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[3]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],"999.99")}

  oBrw:aCols[4]:cHeader:="Impuesto"+CRLF+"Retenido"
  oBrw:aCols[4]:nWidth :=140
  oBrw:aCols[4]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[4]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[4]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[4]:cFooter       := TRAN(nTot04,cPictureM)
  oBrw:aCols[4]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oArc:cPictureM)}

  oBrw:aCols[5]:cHeader:="Remuneraciones"+CRLF+"Acumualdas"
  oBrw:aCols[5]:nWidth :=160
  oBrw:aCols[5]:nWidth :=140
  oBrw:aCols[5]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[5]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[5]:nFootStrAlign := AL_RIGHT
//oBrw:aCols[5]:cFooter       := TRAN(nTot05,cPictureM)
  oBrw:aCols[5]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oArc:cPictureM)}


  oBrw:aCols[6]:cHeader:="Impuesto"+CRLF+"Acumulado"
  oBrw:aCols[6]:nWidth :=160
  oBrw:aCols[6]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[6]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[6]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[6]:cFooter       := TRAN(nTot06,cPictureM)
  oBrw:aCols[6]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oArc:cPictureM)}

  // oBrw:bClrHeader:= {|| {0,14671839 }}
  // oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}




  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oArc:oBrw,cCod:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                               nClrText:=0,;
                               {nClrText, iif( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2 ) } }


//  oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oArc:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
//                     EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,1])}

  oBrw:SetFont(oFont)

  oArc:oBrw:=oBrw
  oArc:Activate({||oArc:LeyBar(oArc)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oArc)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oArc:oDlg
   
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oArc:Imprimir()

   oBtn:cToolTip:="Emitir Planilla ARC"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oArc:oBrw,oArc:cTitle,oArc:cTrabajad+" Año:"+STRZERO(oARC:nAno,4)))

   oBtn:cToolTip:="Exportar hacia Excel"

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oArc:RECIMPRIME(oArc)

   oBtn:cToolTip:="Imprimir Recibo"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oArc:oBrw:GoTop(),oArc:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oArc:oBrw:PageDown(),oArc:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oArc:oBrw:PageUp(),oArc:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oArc:oBrw:GoBottom(),oArc:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oArc:Close()

  oArc:oBrw:SetColor(0,oDp:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,60 SAY " "+oArc:cCodTra   OF oBar BORDER SIZE 345,18;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont BORDER

  @ 1.4,60 SAY " "+oArc:cTrabajad OF oBar BORDER SIZE 345,18;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont BORDER



RETURN .T.

FUNCTION CALCARC(cCodTra,nAno)
  LOCAL cSql,aData:={},oTable,nRet:=0,nBase:=0,nAt,cMes

  FOR nAt=1 TO 12
     AADD(aData,{CMES(nAt),0,0,0,0,0})
  NEXT I

  cSql:="SELECT MONTH(FCH_SISTEM) AS MES,HIS_VARIAC AS TASA, "+;
        " SUM(IF(HIS_CODCON='H014',HIS_MONTO,0)) AS BASE,"+;
        " SUM(IF(HIS_CODCON='D014',HIS_MONTO,0)) AS RET "+;
        " FROM NMHISTORICO "+;
        " INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO "+CRLF+;
        " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+CRLF+;
        " WHERE (HIS_CODCON='H014' "+;
        "   OR HIS_CODCON='D014')  "+;
        "  AND REC_CODTRA"      +GetWhere("=",cCodTra)+;
        "  AND YEAR(FCH_SISTEM)"+GetWhere("=",nAno   )+;
        " GROUP BY MONTH(FCH_SISTEM) "+;
        " ORDER BY MONTH(FCH_SISTEM) "

   oTable:=OpenTable(cSql,.T.)

   IF oTable:RecCount()=0
      // No hay Retenciones, Realiza Calculo
      oTable:aDataFill:=EJECUTAR("ARCEXONERADO",cCodTra,nAno)
   ENDIF

   oTable:REPLACE("ACUMRET",0)
   oTable:Gotop()

   WHILE !oTable:Eof()

      oTable:REPLACE("RET",oTable:RET*-1)
      nRet :=nRet +oTable:RET
      nBase:=nBase+oTable:BASE
      oTable:Replace("TASA",RATA(oTable:RET,oTable:BASE))
      oTable:Replace("ACUMRET" ,nRet )
      oTable:Replace("ACUMBASE",nBase)
      nAt   :=CTOO(oTable:MES,"N")
      
      aData[nAt,2]:=oTable:BASE
      aData[nAt,3]:=oTable:TASA
      aData[nAt,4]:=oTable:RET
      aData[nAt,5]:=nBase      
      aData[nAt,6]:=nRet 
                  
    //? oTable:BASE
      oTable:DbSkip()

   ENDDO

   oTable:End()

//   oArc:aData:=ACLONE(aData)

RETURN aData

FUNCTION Imprimir()

  LOCAL oTable,cFileDbf,I,aData:=oARC:oBrw:aArrayData,cField,oDataAri,nSSO:=0,oData,aData
  LOCAL aFechas:={"31/03/","30/06/","30/09/","31/12/"}
  LOCAL cYear  :=STRZERO(oArc:nAno,4),dFecha
  LOCAL cFecha:=IIF(Left(oDp:cTipFecha,1)="D","FCH_DESDE","FCH_HASTA"),dDesde,dHasta,nInteres

  cFileDbf:=oDp:cPathCrp+"ARC.DBF"

  aData:=ACLONE(oArc:aData)

  oData:=DATASET("NOMINA","ALL",,,,"CRIF")

  dDesde:=CTOD("01/01/"+cYear)
  dHasta:=CTOD("31/12/"+cYear)

  nSSO:=SQLGET("NMHISTORICO","SUM(HIS_MONTO)"," INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO "+;
               " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
               " WHERE REC_CODTRA "+GetWhere("=",oArc:cCodTra)+;
               "   AND HIS_CODCON "+GetWhere("=","D004")+;
               "   AND "+GetWhereAnd(cFecha,dDesde,dHasta))*-1

  nInteres:=SQLGET("NMHISTORICO","SUM(HIS_MONTO)"," INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO "+;
               " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
               " WHERE REC_CODTRA "+GetWhere("=",oArc:cCodTra)+;
               "   AND HIS_CODCON "+GetWhere("=","A411")+;
               "   AND "+GetWhereAnd(cFecha,dDesde,dHasta))

  oTable:=OpenTable("SELECT APELLIDO,NOMBRE,CEDULA,FECHA_ING  FROM NMTRABAJADOR "+;
                    "WHERE CODIGO"+GetWhere("=",oArc:cCodTra),.T.)

  oTable:Replace("APELYNOM",ALLTRIM(oTable:APELLIDO)+", "+oTable:NOMBRE)
  oTable:Replace("FCHDESDE",dDesde)
  oTable:Replace("FCHHASTA",dHasta)
  oTable:Replace("FCHINIDD",DAY(dDesde))
  oTable:Replace("FCHINIMM",MONTH(dDesde))
  oTable:Replace("FCHINIAA",RIGHT(cYear,2))
  oTable:Replace("SSO"     ,nSSO)
  oTable:Replace("INTERES" ,nInteres)
  oTable:Replace("EMPRIF"     ,oData:cRIF)
  oTable:Replace("EMPRESA" ,oDp:cEmpresa)
  oTable:Replace("FCHFINDD",DAY(dHasta))
  oTable:Replace("FCHFINMM",MONTH(dHasta))
  oTable:Replace("FCHFINAA",RIGHT(cYear,2))

  FOR I=1 TO LEN(aData)
     cField:=STRZERO(I,2)
     oTable:Replace("REMUNE"+cField,aData[I,2])
     oTable:Replace("PORCEN"+cField,aData[I,3])
     oTable:Replace("IMPRET"+cField,aData[I,4])
     oTable:Replace("REMACU"+cField,aData[I,5])
     oTable:Replace("IMPACU"+cField,aData[I,6])
  NEXT I
 

  FOR I=1 TO LEN(aFechas)
      dFecha:=CTOD(aFechas[I]+cYear)
      oDataAri:=OpenTable(" SELECT ARI_INGANU,ARI_C,ARI_H2 FROM NMARI "+;
                          " WHERE ARI_CODTRA"+GetWhere("=",oArc:cCodTra)+;
                          "   AND ARI_FECHA "+GetWhere("=",dFecha      ),.T.)
     cField:=STRZERO(I,2)
     oTable:Replace("REMANU"+cField,oDataAri:ARI_INGANU)
     oTable:Replace("DESANU"+cField,oDataAri:ARI_C     )
     oTable:Replace("CARFAM"+cField,oDataAri:ARI_H2    )
     oDataAri:End()
  NEXT I

// oTable:Browse()
  oTable:CTODBF(cFileDbf)
  oTable:End()
  oData:End(.F.)

  RUNRPT(oDp:cPathCrp+"ARC.RPT",{cFileDbf},1,"ARC "+ALLTRIM(oTable:APELYNOM))

RETURN .T.
// EOF

