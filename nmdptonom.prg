// Programa   : DPDPTONOM
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Conceptos de Pago por Departamento
// Creado Por : Juan Navas
// Llamado por: DPDPTO
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTitle,cWhere,cCodDep)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,cConcepto:="",cFchNum
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nVar:=0,nMonto:=0,cTitle:=""
  LOCAL dDesde,dHasta,oBtn,oFont,cTipNom,cOtrNom,nAsigna:=0,nDeducc:=0

  DEFAULT cCodDep:="000001"

  cFchNum:=FCHGETDPTO(cCodDep,.T.)

  cSql   :="SELECT FCH_DESDE,FCH_HASTA,FCH_OTRNOM,FCH_TIPNOM FROM NMFECHAS WHERE FCH_NUMERO"+GetWhere("=",cFchNum)
  oTable :=OpenTable(cSql,.T.)
  dDesde :=oTable:FCH_DESDE
  dHasta :=oTable:FCH_HASTA
  cTipNom:=oTable:FCH_TIPNOM
  cOtrNom:=oTable:FCH_OTRNOM
  oTable:End()

  aData  :=FCHLOADDPTO(cFchNum,cCodDep,oBrw)

  AEVAL(aData,{|a,nAct|nAct   :=0,;
                       nAct   :=IIF(Left(a[1],1)$"AD", 1,nAct),;
                       nAsigna:=nAsigna+IIF(Left(a[1],1)="A",a[3]   ,0),;
                       nDeducc:=nDeducc+IIF(Left(a[1],1)="D",a[3]*-1,0),;
                       nMonto :=nMonto +(a[3]*nAct)})

  cPictureM:="999,999,999,999.99"

  IF EMPTY(aData)
     MensajeErr("Departamento "+cCodDep+" no Tiene Nóminas Procesadas "+cTitle)
     RETURN .F.
  ENDIF

  cTitle :="Nómina por "+GetFromVar("{oDp:xDPDPTO}")+" [ "+;
            cCodDep+" "+ALLTRIM(SQLGET("DPDPTO","DEP_DESCRI","DEP_CODIGO"+GetWhere("=",cCodDep)))+;
           " ]"

  DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

  oNmxDep:=DPEDIT():New(cTitle,"DPDPTONOM.edt","oNmxDep",.T.)

  oNmxDep:cCodDep  :=cCodDep
  oNmxDep:cFchNum  :=cFchNum
  oNmxDep:cPictureM:=cPictureM
  oNmxDep:dDesde   :=dDesde
  oNmxDep:dHasta   :=dHasta
  oNmxDep:cNombre  :=cNombre
  oNmxDep:cTipNom  :=cTipNom
  oNmxDep:cOtrNom  :=cOtrNom

  @ 2,1 GROUP oNmxDep:oGrupo1 TO 4, 21.5 PROMPT "Periodo  "

  @ 3,05 SAY oNmxDep:oDesde PROMPT oNmxDep:dDesde
  @ 3,15 SAY oNmxDep:oHasta PROMPT oNmxDep:dHasta

  @ 1.5,25 SAY oNmxDep:oTipNom PROMPT ;
              ALLTRIM(SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oNmxDep:cTipNom))+;
              IIF(Empty(oNmxDep:cOtrNom),"",": "+;
              ALLTRIM(SQLGET("NMOTRASNM","OTR_DESCRI","OTR_CODIGO"+GetWhere("=",oNmxDep:cOtrNom))))

  @02, 13  SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\CALENDAR.BMP" NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oNmxDep:ListFechas())

  oBtn:cToolTip:="Lista de Fechas"
  oBtn:cMsg:="Lista de Fechas"

  @02, 23  SBUTTON oBtn ;
           SIZE 17, 17 FONT oFont;
           FILENAME "BITMAPS\xTOP.BMP" NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oNmxDep:FCHGETDPTO(oNmxDep:cCodDep,.F.,NIL,oNmxDep))

  oBtn:cToolTip:="Primer Periodo"
  oBtn:cMsg:="Primer Periodo"

  @02,19  SBUTTON oBtn ;
          SIZE 45, 20 FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (oNmxDep:FCHGETDPTO(oNmxDep:cCodDep,.F.,oNmxDep:cFchNum,oNmxDep))

  oBtn:cToolTip:="Anterior"
  oBtn:cMsg    :="Anterior"

  @02,13  SBUTTON oBtn ;
          SIZE 45, 20 FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (oNmxDep:FCHGETDPTO(oNmxDep:cCodDep,.T.,oNmxDep:cFchNum,oNmxDep))

  oBtn:cToolTip:="Siguiente"
  oBtn:cMsg    :="Siguiente"

  @02, 23  SBUTTON oBtn ;
           SIZE 17, 17 FONT oFont;
           FILENAME "BITMAPS\xFIN.BMP" NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oNmxDep:FCHGETDPTO(oNmxDep:cCodDep,.T.,NIL,oNmxDep))

  oBtn:cToolTip:="Ultimo Periodo"
  oBtn:cMsg:="Ultimo Periodo"

  oDlg:=oNmxDep:oDlg

  oBrw:=TXBrowse():New( oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont
//oBrw:nHeaderLines        := 2
  oBrw:nFooterLines        := 2
 
  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:CreateFromCode()

  oBrw:aCols[1]:cHeader:="Cod."
  oBrw:aCols[1]:nWidth :=70

  oBrw:aCols[2]:cHeader:="Descripción del Concepto"
  oBrw:aCols[2]:nWidth :=340
  oBrw:aCols[2]:cFooter:= "A:"+TRAN(nAsigna,cPictureM)+CRLF+;
                          "D:"+TRAN(nDeducc,cPictureM)

  oBrw:aCols[3]:cHeader:="Monto"
  oBrw:aCols[3]:nWidth :=135
  oBrw:aCols[3]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[3]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[3]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[3]:cFooter       := TRAN(nMonto,cPictureM)
  oBrw:aCols[3]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],oNmxDep:cPictureM)}

  oBrw:bClrHeader:= {|| {0,14671839 }}
  oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oNmxDep:oBrw,cCod:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                               cCod:=Left(cCod,1),;
                               nClrText:=0,;
                               nClrText:=IIF(cCod="A",CLR_HBLUE,nClrText),;
                               nClrText:=IIF(cCod="D",CLR_HRED ,nClrText),;
                               {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }

//oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oNmxDep:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
//                   EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,1])}

  oBrw:SetFont(oFont)

  oNmxDep:oBrw:=oBrw
  oNmxDep:Activate({||oNmxDep:LeyBar(oNmxDep)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oNmxDep)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oNmxDep:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION EVAL(oNmxDep:oBrw:bLDblClick)

   oBtn:cToolTip:="Visualizar Cuerpo del Recibo"
*/
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oNmxDep:oBrw,oNmxDep:cTitle,;
                  "Periodo:"+DTOC(oNmxDep:dDesde)+" "+DTOC(oNmxDep:dHasta)+;
                  " Nómina: "+oNmxDep:oTipNom:VarGet()))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oNmxDep:RECIMPRIME(oNmxDep)

   oBtn:cToolTip:="Imprimir Recibo"
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNmxDep:oBrw:GoTop(),oNmxDep:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNmxDep:oBrw:PageDown(),oNmxDep:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNmxDep:oBrw:PageUp(),oNmxDep:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNmxDep:oBrw:GoBottom(),oNmxDep:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNmxDep:Close()

  oNmxDep:oBrw:SetColor(0,15790320)

// @ 0.5,32 SAY oNmxDep:cNombre OF oBar BORDER SIZE 300,18

  oBar:SetColor(CLR_BLACK,15724527)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

RETURN .T.

FUNCTION RECIMPRIME(oNmxDep)
  LOCAL aVar   :={}
  LOCAL oBrw   :=oNmxDep:oBrw
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[1]

  aVar:={oDp:cTipoNom  ,;
         oDp:cOtraNom  ,;
         oDp:dDesde    ,;
         oDp:dHasta    ,;
         oDp:cDepIni   ,;
         oDp:cDepFin    }

  oDP:cTipoNom  :=oNmxDep:cTipNom 
  oDp:cOtraNom  :=oNmxDep:cOtrNom 
  oDp:dDesde    :=oNmxDep:dDesde
  oDp:dHasta    :=oNmxDep:dHasta
  oDp:cDepIni   :=oNmxDep:cCodDep
  oDp:cDepFin   :=oNmxDep:cCodDep

  REPORTE(52)

  oDp:cTipoNom :=aVar[1]
  oDp:cOtraNom :=aVar[2]
  oDp:dDesde   :=aVar[3]
  oDp:dHasta   :=aVar[4]
  oDp:cDepIni  :=aVar[5]
  oDp:cDepFin  :=aVar[6]

RETURN .T.

/*
// Listar Fechas
*/
FUNCTION ListFechas()
   LOCAL cSql,aTitles:={"Desde","Hasta","Número","Tipo","Otra"}

   oDp:uValue:={}

   cSql:="SELECT FCH_DESDE,FCH_HASTA,FCH_NUMERO,FCH_TIPNOM,FCH_OTRNOM FROM NMHISTORICO "+;
         "INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
         "INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
         "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
         "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
         " WHERE REC_CODDEP"+GetWhere("=",oNmxDep:cCodDep)+;
         " GROUP BY FCH_DESDE,FCH_HASTA,FCH_NUMERO,FCH_TIPNOM,FCH_OTRNOM "

   EJECUTAR("SQLLIST",cSql,"Nóminas del Departamento "+oNmxDep:cCodDep,aTitles)

   IF !Empty(oDp:uValue)

      oNmxDep:cFchNum  :=oDp:uValue[3]
      oNmxDep:dDesde   :=oDp:uValue[1]
      oNmxDep:dHasta   :=oDp:uValue[2]
      oNmxDep:cTipNom  :=oDp:uValue[4]
      oNmxDep:cOtrNom  :=oDp:uValue[5]

      oNmxDep:oDesde:Refresh(.T.)
      oNmxDep:oHasta:Refresh(.T.)
      oNmxDep:oTipNom:Refresh(.T.)

      oNmxDep:FCHLOADDPTO(oNmxDep:cFchNum,oNmxDep:cCodDep,oNmxDep:oBrw)

   ENDIF

RETURN NIL

FUNCTION FCHLOADDPTO(cFchNum,cCodDep,oBrw)

  LOCAL cSql,aData,oTable
  LOCAL nAsigna:=0,nDeducc:=0,nMonto:=0

  cSql:=" SELECT HIS_CODCON,CON_DESCRI,SUM(HIS_MONTO) AS HIS_MONTO"+;
        " FROM NMHISTORICO "+;
        " INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
        " INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
        " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
        " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
        " WHERE FCH_NUMERO"+GetWhere("=",cFchNum)+;
        "   AND REC_CODDEP  "+GetWhere("=",cCodDep)+;
        " GROUP BY HIS_CODCON,CON_DESCRI "+;
        " ORDER BY HIS_CODCON "

  oTable:=OpenTable(cSql,.T.)

  aData:=ACLONE(oTable:aDataFill)

  oTable:End()

  IF ValType(oBrw)="O"

      AEVAL(aData,{|a,nAct|nAct   :=0,;
                           nAct   :=IIF(Left(a[1],1)$"AD", 1,nAct),;
                           nAsigna:=nAsigna+IIF(Left(a[1],1)="A",a[3]   ,0),;
                           nDeducc:=nDeducc+IIF(Left(a[1],1)="D",a[3]*-1,0),;
                           nMonto :=nMonto +(a[3]*nAct)})

      oBrw:aArrayData:=ACLONE(aData)

      oBrw:aCols[2]:cFooter:= "A:"+TRAN(nAsigna,oNmxDep:cPictureM)+CRLF+;
                              "D:"+TRAN(nDeducc,oNmxDep:cPictureM)

      oBrw:aCols[3]:cFooter       := TRAN(nMonto,oNmxDep:cPictureM)

      oBrw:Refresh(.T.)


  ENDIF

RETURN aData

/*
// Obtiene la Fecha Maxima
*/
FUNCTION FCHGETDPTO(cCodDep,lMax,cDesde,oFrm)
  LOCAL cSql,oTable,cFchNum,cWhere:=""

  DEFAULT lMax:=.T.

  IF cDesde!=NIL
     cWhere:=" AND FCH_NUMERO"+GetWhere(IIF(lMax,"<",">"),cDesde)
  ENDIF

  cSql:="SELECT "+IIF(lMax,"MAX","MIN")+"(FCH_NUMERO) FROM NMHISTORICO "+;
        "INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
        "INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
        "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
        "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
        " WHERE REC_CODDEP"+GetWhere("=",cCodDep)+cWhere

  oTable :=OpenTable(cSql,.T.)
  cFchNum:=oTable:FieldGet(1)
  oTable:End()

  IF ValType(oFrm)="O" .AND. !Empty(cFchNum)

      cSql   :="SELECT FCH_DESDE,FCH_HASTA,FCH_OTRNOM,FCH_TIPNOM FROM NMFECHAS WHERE FCH_NUMERO"+GetWhere("=",cFchNum)
      oTable :=OpenTable(cSql,.T.)

      oFrm:dDesde :=oTable:FCH_DESDE
      oFrm:dHasta :=oTable:FCH_HASTA
      oFrm:cTipNom:=oTable:FCH_TIPNOM
      oFrm:cOtrNom:=oTable:FCH_OTRNOM
      oFrm:cFchNum:=cFchNum
      oTable:End()

      oFrm:FCHLOADDPTO(cFchNum,oFrm:cCodDep,oFrm:oBrw)

      oFrm:oDesde:Refresh(.T.)
      oFrm:oHasta:Refresh(.T.)
      oFrm:oTipNom:Refresh(.T.)

  ENDIF

RETURN cFchNum

// EOF






