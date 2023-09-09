// Programa   : NMTRABHISCON
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Visualizar Trabajador Histórico
// Creado Por : Juan Navas
// Llamado por: NMTRABJCON
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,cCodCon)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,cConcepto:=""
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nVar:=0,nMonto:=0

  DEFAULT cCodTra:="1002",cCodCon:="A002"

  cSql:=" SELECT HIS_NUMREC,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OBS_OBSERV,HIS_VARIAC,HIS_MONTO,HIS_NUMOBS FROM NMHISTORICO "+;
        " INNER JOIN NMRECIBOS ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
        " INNER JOIN NMFECHAS  ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
        " LEFT JOIN NMOBSERV ON HIS_NUMOBS=OBS_NUMERO "+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
        " AND HIS_CODCON"+GetWhere("=",cCodCon)

  oTable:=OpenTable(cSql,.T.)
  
  aData:=ACLONE(oTable:aDataFill)

  AEVAL(aData,{|a,n|nVar:=nVar+a[7],nMonto:=nMonto+a[8]})

  cPictureV:=oTable:GetPicture("HIS_VARIAC",.T.)
  cPictureM:=oTable:GetPicture("HIS_MONTO",.T.)

  oTable:End()

  oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
  cNombre:=cCodTra+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
  oTable:End()

  oTable   :=OpenTable("SELECT CON_DESCRI FROM NMCONCEPTOS WHERE CON_CODIGO"+GetWhere("=",cCodCon),.T.)
  cConcepto:=" "+cCodCon+" "+ALLTRIM(oTable:CON_DESCRI)
  oTable:End()

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//oHisRes:=DPEDIT():New("Detalle por Concepto","NMTRABHCON.edt","oHisRes",.T.)

  DpMdi("Detalle por Concepto","oHisRes","NMTRABHCON.edt")
  oHisRes:Windows(0,0,oDp:aCoors[3]-160,MIN(650+155,oDp:aCoors[4]-10),.T.) // Maximizado

  oHisRes:cCodTra  :=cCodTra
  oHisRes:cTrabajad:=" "+cNombre
  oHisRes:cPictureV:=cPictureV
  oHisRes:cPictureM:=cPictureM
  oHisRes:cConcepto:=cConcepto

  oDlg:=oHisRes:oDlg

  oBrw:=TXBrowse():New( oDlg )

  // oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLROW // MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .T. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

 

  oBrw:aCols[1]:cHeader:="Recibo"
  oBrw:aCols[1]:nWidth :=60

  oBrw:aCols[2]:cHeader:="Desde"
  oBrw:aCols[2]:nWidth :=70

  oBrw:aCols[3]:cHeader:="Hasta"
  oBrw:aCols[3]:nWidth :=70

  oBrw:aCols[4]:cHeader:="T"
  oBrw:aCols[4]:nWidth :=20

  oBrw:aCols[5]:cHeader:="O/N"
  oBrw:aCols[5]:nWidth :=30

  oBrw:aCols[6]:cHeader:="Observación"
  oBrw:aCols[6]:nWidth :=180

  oBrw:aCols[7]:cHeader:="Variación"
  oBrw:aCols[7]:nWidth :=140
  oBrw:aCols[7]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[7]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[7]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[7]:cFooter       := TRAN(nVar,cPictureV)
  oBrw:aCols[7]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],oHisRes:cPictureV)}

  oBrw:aCols[8]:cHeader:="Monto"
  oBrw:aCols[8]:nWidth :=135
  oBrw:aCols[8]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[8]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[8]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[8]:cFooter       := TRAN(nMonto,cPictureV)
  oBrw:aCols[8]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,8],oHisRes:cPictureM)}


  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oHisRes:oBrw,cCod:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                               cCod:=Left(cCod,1),;
                               nClrText:=0,;
                               nClrText:=IIF(cCod="A",CLR_HBLUE,nClrText),;
                               nClrText:=IIF(cCod="D",CLR_HRED ,nClrText),;
                               {nClrText, iif( oBrw:nArrayAt%2=0, oHisRes:nClrPane1,oHisRes:nClrPane2 ) } }
  oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oHisRes:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                     EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,1])}

  oBrw:SetFont(oFont)

  oBrw:CreateFromCode()
  oHisRes:bValid   :={|| EJECUTAR("BRWSAVEPAR",oHisRes)}
  oHisRes:BRWRESTOREPAR()

  oHisRes:oBrw:=oBrw
  oHisRes:oWnd:oClient := oBrw

  oHisRes:Activate({||oHisRes:VIEWHISTBAR(oHisRes)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION VIEWHISTBAR(oHisRes)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oHisRes:oDlg

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RECIBO.BMP";
          ACTION EVAL(oHisRes:oBrw:bLDblClick)

  oBtn:cToolTip:="Visualizar Recibo Recibo"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oHisRes:RECIMPRIME(oHisRes)

  oBtn:cToolTip:="Imprimir Recibo de Pago"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XMEMO2.BMP";
          ACTION oHisRes:VIEWMEMO(oHisRes)

  oBtn:cToolTip:="Visualizar Memo del Concepto"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oHisRes:oBrw:GoTop(),oHisRes:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oHisRes:oBrw:PageDown(),oHisRes:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oHisRes:oBrw:PageUp(),oHisRes:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oHisRes:oBrw:GoBottom(),oHisRes:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oHisRes:Close()

  oHisRes:oBrw:SetColor(0,oHisRes:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,70 SAY oHisRes:cTrabajad OF oBar BORDER SIZE 345,18 FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow
  @ 1.4,70 SAY oHisRes:cConcepto OF oBar BORDER SIZE 345,18 FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow

RETURN .T.

/*
// Visualizar Campo Memo
*/
FUNCTION VIEWMEMO(oHisRes)
   LOCAL oBrw :=oHisRes:oBrw,oTable
   LOCAL aData:=oBrw:aArrayData[oBrw:nArrayAt]
   LOCAL cMemo:=""

   oTable:=OpenTable("SELECT MEM_MEMO FROM NMMEMO WHERE MEM_NUMERO"+GetWhere("=",aData[9]),.T.)
   cMemo:=ALLTRIM(oTable:MEM_MEMO)
   oTable:End()

   oHisResM:=DPEDIT():New("Memo del Concepto ","NMHISDETM.edt","oHisResM",.T.)

   oHisResM:cMemo    :=cMemo
   oHisResM:cRecibo  :=aData[1]
   oHisResM:cTrabajad:=oHisRes:cTrabajad
   oHisResM:cConcepto:=oHisRes:cConcepto

   @ 0,0 SAY "Recibo:"     RIGHT
   @ 1,0 SAY "Trabajador:" RIGHT
   @ 2,0 SAY "Concepto:"   RIGHT

   @ 0,20 SAY oHisResM:cRecibo   BORDER
   @ 1,20 SAY oHisResM:cTrabajad BORDER
   @ 2,20 SAY oHisResM:cConcepto BORDER

   @ 4,0 GET oHisResM:cMemo MULTILINE READONLY OF oHisResM:oDlg SIZE 100,100

   @6, 16 SBUTTON oHisResM:oBtn ;
          SIZE 50, 50 ;
          FILE "BITMAPS\XSALIR.BMP" ;
          LEFT PROMPT "Cerrar" NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 3 };
          ACTION (oHisResM:Close())

   oHisResM:Activate()

RETURN .T.

FUNCTION RECIMPRIME(oTrabRec)
  LOCAL aVar   :={}
  LOCAL oBrw   :=oTrabRec:oBrw
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[1]

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
  oDp:cRecIni   :=cNumRec
  oDp:cRecFin   :=cNumRec

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







 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oHisRes)
// EOF
