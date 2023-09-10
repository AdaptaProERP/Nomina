// Programa   : NMTRABTABVAC
// Fecha/Hora : 06/09/2004 21:03:39
// Prop�sito  : Consultar tabla de Vacaciones
// Creado Por : Juan Navas
// Llamado por: Consulta Ficha del Trabajador
// Aplicaci�n : N�mina
// Tabla      : NMTRABAJADOR y NMTABVAC

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,cConcepto:="",oCol
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nVar:=0,nMonto:=0,cTitle:=""
  LOCAL aTotal

  DEFAULT SQLGET("NMTRABAJADOR","CODIGO")

  cSql:="SELECT TAB_NUMERO,TAB_DESDE,TAB_HASTA,TAB_FCHREI,TAB_DIAS,TAB_DIAHAB,"+;
        "TAB_DIAFER,TAB_DIADES,TAB_NUMREC,TAB_PROCES FROM NMTABVAC "+;
        "WHERE TAB_CODTRA"+GetWhere("=",cCodTra)

  oTable:=OpenTable(cSql,.T.)
  aData :=ACLONE(oTable:aDataFill)
  aTotal:=ATOTALES(aData)

  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Trabajador "+cCodTra+" no Tiene Recibos "+cTitle)
     RETURN .F.
  ENDIF

  oTable :=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
  cNombre:=cCodTra+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
  oTable:End()

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//  oTrabVac:=DPEDIT():New("Registro de Vacaciones"+cTitle,"NMTRABVAC.edt","oTrabVac",.T.)

  DpMdi("Registro de Vacaciones"+cTitle,"oTrabVac","NMTRABVAC.edt")
  oTrabVac:Windows(0,0,oDp:aCoors[3]-160,MIN(650+155,oDp:aCoors[4]-10),.T.) // Maximizado

  oTrabVac:nClrPane1:=oDp:nClrPane1 // 15790320
  oTrabVac:nClrPane2:=oDp:nClrPane2 // 16382457

  oTrabVac:lMsgBar:=.F.

  oTrabVac:cCodTra  :=cCodTra
  oTrabVac:cTrabajad:=cNombre
  oTrabVac:cPictureM:="999"

  oDlg:=oTrabVac:oDlg

  oBrw:=TXBrowse():New( oTrabVac:oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 2

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  

  oBrw:aCols[1]:cHeader:="N�mero"+CRLF+"Reg."
  oBrw:aCols[1]:nWidth :=65

  oBrw:aCols[2]:cHeader:="Fecha"+CRLF+"Desde"
  oBrw:aCols[2]:nWidth :=70

  oBrw:aCols[3]:cHeader:="Fecha"+CRLF+"Hasta"
  oBrw:aCols[3]:nWidth :=70

  oBrw:aCols[4]:cHeader:="Fecha"+CRLF+"Reintegro"
  oBrw:aCols[4]:nWidth :=70

  oBrw:aCols[5]:cHeader:="D�as"+CRLF+"Vac."
  oBrw:aCols[5]:nWidth :=60
  oBrw:aCols[5]:cEditPicture:="9999"
  oBrw:aCols[5]:cFooter     :=FDP(aTotal[5],"9999")

  oBrw:aCols[6]:cHeader:="D�as"+CRLF+"H�biles"
  oBrw:aCols[6]:nWidth :=60
  oBrw:aCols[6]:cEditPicture:="9999"
  oBrw:aCols[6]:cFooter     :=FDP(aTotal[6],"9999")
  oBrw:aCols[6]:bStrData    :={|oBrw|oBrw:=oTrabVac:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],"9999")}


  oBrw:aCols[7]:cHeader  :="D�as"+CRLF+"Feriados"
  oBrw:aCols[7]:nWidth   :=60
  oBrw:aCols[7]:cEditPicture:="9999"
  oBrw:aCols[7]:cFooter     :=FDP(aTotal[7],"9999")


  oBrw:aCols[8]:cHeader:="D�as"+CRLF+"Descanso"
  oBrw:aCols[8]:nWidth :=65
  oBrw:aCols[8]:cEditPicture:="9999"
  oBrw:aCols[8]:cFooter     :=FDP(aTotal[8],"9999")


  oBrw:aCols[9]:cHeader :="N�mero"+CRLF+"Recibo"
  oBrw:aCols[9]:nWidth  :=60

  oCol:=oBrw:aCols[10]
  oCol:cHeader      := "Procesado"
  oCol:nWidth       := 70
//oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
//  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")

  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bBmpData    := {|oObj,oBrw|oBrw:=oTrabVac:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,10],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bStrData    := { ||""}

//oBrw:bClrHeader:= {|| {0,14671839 }}
//oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oTrabVac:oBrw,cCod:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                               cCod:=Left(cCod,1),;
                               nClrText:=0,;
                               nClrText:=IIF(cCod="A",CLR_HBLUE,nClrText),;
                               nClrText:=IIF(cCod="D",CLR_HRED ,nClrText),;
                               {nClrText, iif( oBrw:nArrayAt%2=0, oTrabVac:nClrPane1, oTrabVac:nClrPane2 ) } }
  oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oTrabVac:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                     EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,09])}

  oBrw:SetFont(oFont)

  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oTrabVac:oBrw:=oBrw

  oBrw:CreateFromCode()

  oTrabVac:oWnd:oClient := oBrw

  oTrabVac:Activate({||oTrabVac:LeyBar(oTrabVac)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oTrabVac)
   LOCAL oCursor,oBar,oBtn,oFont,oFontB,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg�n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTrabVac:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RECIBO.BMP";
          ACTION EVAL(oTrabVac:oBrw:bLDblClick)

   oBtn:cToolTip:="Visualizar Cuerpo del Recibo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTrabVac:oBrw,oTrabVac:cTitle,oTrabVac:cTrabajad))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oTrabVac:RECIMPRIME(oTrabVac)

   oBtn:cToolTip:="Imprimir Recibo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTrabVac:oBrw:GoTop(),oTrabVac:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oTrabVac:oBrw:PageDown(),oTrabVac:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oTrabVac:oBrw:PageUp(),oTrabVac:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTrabVac:oBrw:GoBottom(),oTrabVac:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTrabVac:Close()

  oTrabVac:oBrw:SetColor(0,oTrabVac:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,60 SAY oTrabVac:cTrabajad OF oBar BORDER SIZE 345,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontB

RETURN .T.

FUNCTION RECIMPRIME(oTrabVac)
  LOCAL aVar   :={}
  LOCAL oBrw   :=oTrabVac:oBrw
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[1]

  aVar:={oDp:cCodTraIni,;
         oDp:cCodTraFin}

  oDp:cCodTraIni:=oTrabVac:cCodTra 
  oDp:cCodTraFin:=oTrabVac:cCodTra 

  REPORTE("NMTABVACH")

  oDp:cCodTraIni:=aVar[1]
  oDp:cCodTraFin:=aVar[2]

RETURN .T.

// EOF






