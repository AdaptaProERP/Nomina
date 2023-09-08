// Programa   : NMCALANTVIEW
// Fecha/Hora : 14/06/2004 19:10:32
// Propósito  : Visualizar los Cálculos de Antiguedad
// Creado Por : Juan Navas
// Llamado por: NMCALANT
// Aplicación : Nómina
// Tabla      : DPHISTO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(aData)

   LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oSintax,oMemo,oEjemplo

   CursorWait()

   IF aData=NIL
      aData:={}
      AADD(aData,{"1002","UNO","DOS",oDp:dFecha,0})
   ENDIF

   IF LEN(aData)=1
      ViewData(NIL,aData[1])
      RETURN .T.
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 

   oFrmView:=DPEDIT():New("Procesados","NMCALANTVIEW.edt","oFrmView",.T.)

   oBrw:=TXBrowse():New( oFrmView:oDlg )

   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
   oBrw:SetArray( aData, .T. )
   oBrw:lHScroll            := .F.
   oBrw:oFont               :=oFont

   AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oBrw:CreateFromCode()
//   oBrw:aCols[1]:cHeader:="Código"
//   oBrw:aCols[1]:nWidth :=100

   // Apellido
//   oBrw:aCols[2]:cHeader:="Apellido"
//   oBrw:aCols[2]:nWidth :=220

   // Nombre
//   oBrw:aCols[3]:cHeader:="Nombre"
//   oBrw:aCols[3]:nWidth :=220

   // Ingreso
//   oBrw:aCols[4]:cHeader:="Ingreso"
//   oBrw:aCols[4]:nWidth :=70

   // Meses
//   oBrw:aCols[5]:cHeader:="Meses"
//   oBrw:aCols[5]:nWidth :=50

   oBrw:bClrHeader:= {|| {0,14671839 }}
   oBrw:bClrFooter:= {|| {0,14671839 }}

   oBrw:bClrStd := {|oBrw|oBrw:=oFrmView:oBrw,{0, iif( oBrw:nArrayAt%2=0, 16770764, 16566954 ) } }
   oBrw:SetFont(oFont)

   oFrmView:oBrw:=oBrw
   oFrmView:oBrw:bLDblClick:={||oFrmView:ViewData(oFrmView)}

   oFrmView:Activate({||oFrmView:ViewBar(oFrmView)})

   STORE NIL TO oBrw,aData
   Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION Viewbar(oFrmView)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmView:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\INTERESPAGO.BMP";
          ACTION EVAL(oFrmView:oBrw:bLDblClick)

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oFrmView:oBrw:GoTop(),oFrmView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oFrmView:oBrw:PageDown(),oFrmView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oFrmView:oBrw:PageUp(),oFrmView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oFrmView:oBrw:GoBottom(),oFrmView:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFrmView:Close()

  oFrmView:oBrw:SetColor(0,16770764)

  oBar:SetColor(CLR_BLACK,15724527)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

RETURN .T.

/*
// Coloca la Barra de Botones
*/
FUNCTION ViewData(oFrmView,aData)
   LOCAL oBrw,aHisto,dFchIng:=CTOD("")
   LOCAL I,nMonto:=0,nDias
   LOCAL cSql,oTable
   LOCAL oFont,oFontB

   DEFAULT aData:=oFrmView:oBrw:aArrayData[oFrmView:oBrw:nArrayAt]

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

//   oDp:cConPres  :=oData:Get("cConPres" ,"H400")          // Concepto Acumulado Prestaciones
//   oDp:cConAdel  :=oData:Get("cConAdel" ,"A410")          // Adelanto de Prestaciones

/*
   cSql:="SELECT HIS_HASTA,HIS_VARIAC,0,HIS_MONTO FROM NMHISTORICO WHERE HIS_CODTRA"+GetWhere("=",aData[1])+;
         " AND (HIS_CODCON"+GetWhere("=",oDp:cConPres)+" OR HIS_CODCON"+GetWhere("=",oDp:cConAdel)+")"+;
         " ORDER BY HIS_HASTA"

   cSql:="SELECT HIS_HASTA,HIS_VARIAC,0,HIS_MONTO FROM NMHISTORICO WHERE HIS_CODTRA"+GetWhere("=",aData[1])+;
         " AND HIS_CODCON"+GetWhere("=",oDp:cConPres)+;
         " ORDER BY HIS_HASTA"
*/
   cSql:="SELECT FCH_HASTA,HIS_VARIAC,0,HIS_MONTO FROM NMHISTORICO "+;
         "INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
         "INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
         "WHERE REC_CODTRA"+GetWhere("=",aData[1])+;
         " AND HIS_CODCON"+GetWhere("=",oDp:cConPres)+;
         " ORDER BY FCH_HASTA"

   oTable:=OpenTable(cSql,.T.)
   aHisto:=oTable:aDataFill
   oTable:End()

   IF Empty(aHisto)
      MensajeErr("Concepto: "+oDp:cConPres+" no tiene Registro Histórico para el Trabajador: "+aData[1])
      RETURN .F.
   ENDIF

   FOR I=1 TO LEN(aHisto)
      nMonto:=nMonto+aHisto[I,4]
      nDias :=nDias +aHisto[I,2]
      ahisto[I,3]:=DIV(aHisto[I,4],aHisto[I,2])
      AADD(ahisto[I],I     )
      AADD(aHisto[I],nMonto)
   NEXT I
   
   oFrmDat:=DPEDIT():New("Antiguedad Laboral","NMDETANT.edt","oFrmDat",.T.)

   oFrmDat:cCodTrab :=aData[1]
   oFrmDat:cTrabajad:=" "+ALLTRIM(aData[1])+" "+ALLTRIM(aData[2])+","+ALLTRIM(aData[3])
   oFrmDat:cConcepto:=" Ingreso :"+DTOC(aData[4])+" Concepto: "+oDp:cConPres  

   oFrmDat:oBrw:=TXBrowse():New( oFrmDat:oDlg )
   oFrmDat:oBrw:SetArray( aHisto, .T. )
   oFrmDat:oBrw:SetFont(oFont)
   oFrmDat:oBrw:lFooter             := .T.
   oFrmDat:oBrw:lHScroll:= .F.

   AEVAL(oFrmDat:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
   oFrmDat:oBrw:aCols[1]:cHeader:="Fecha"
   oFrmDat:oBrw:aCols[1]:nWidth :=080

   oFrmDat:oBrw:aCols[2]:cHeader:="Días"
   oFrmDat:oBrw:aCols[2]:nWidth :=70
   oFrmDat:oBrw:aCols[2]:nDataStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[2]:cEditPicture := "9,999.99"
   oFrmDat:oBrw:aCols[2]:nHeadStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[2]:nFootStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[2]:bStrData     :={||oBrw:=oFrmDat:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,2],"999.99")}
   oFrmDat:oBrw:aCols[2]:cFooter      :=TRAN(nDias,"9,999.99")

   oFrmDat:oBrw:aCols[3]:cHeader:="Salario"
   oFrmDat:oBrw:aCols[3]:nWidth :=150
   oFrmDat:oBrw:aCols[3]:nDataStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[3]:cEditPicture := "999,999,999.99"
   oFrmDat:oBrw:aCols[3]:nHeadStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[3]:nFootStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[3]:bStrData     :={||oBrw:=oFrmDat:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],"999,999,999.99")}

   oFrmDat:oBrw:aCols[4]:cHeader:="Monto"
   oFrmDat:oBrw:aCols[4]:nWidth :=150
   oFrmDat:oBrw:aCols[4]:nDataStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[4]:nHeadStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[4]:nFootStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[4]:cEditPicture := "9,999,999,999.99"
   oFrmDat:oBrw:aCols[4]:bStrData     :={||oBrw:=oFrmDat:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],"9,999,999,999.99")}

   oFrmDat:oBrw:aCols[5]:cHeader:="Meses"
   oFrmDat:oBrw:aCols[5]:nWidth :=50
   oFrmDat:oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[5]:nFootStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[5]:cEditPicture := "9999"
   oFrmDat:oBrw:aCols[5]:bStrData     :={||oBrw:=oFrmDat:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],"999")}
   oFrmDat:oBrw:aCols[5]:cFooter      :=TRAN(I-1,"9999")

   oFrmDat:oBrw:aCols[6]:cHeader:="Acumulado"
   oFrmDat:oBrw:aCols[6]:nWidth :=150
   oFrmDat:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oFrmDat:oBrw:aCols[6]:cEditPicture := "999,999,999.99"
   oFrmDat:oBrw:aCols[6]:bStrData     :={||oBrw:=oFrmDat:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],"999,999,999.99")}
   oFrmDat:oBrw:aCols[6]:cFooter      :=TRAN(nMonto,"999,999,999.99")

   oFrmDat:oBrw:bClrStd := {|oBrw|oBrw:=oFrmDat:oBrw,{0, iif( oBrw:nArrayAt%2=0, 14087148, 11790521 ) } }

   oFrmDat:oBrw:bClrHeader:= {|| {0,14671839 }}
   oFrmDat:oBrw:bClrFooter:= {|| {0,14671839 }}

   oFrmDat:oBrw:CreateFromCode()
   oFrmDat:Activate({||oFrmDat:ViewDatBar(oFrmDat)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oFrmDat)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmDat:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\INTERESPAGO.BMP";
          ACTION (EJECUTAR("NMANTPRES",oFrmDat:cCodTrab))

   oBtn:cToolTip:="Pagos Anticipados de Antiguedad"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oFrmDat:oBrw,oFrmDat:cTitle,oFrmDat:cTrabajad))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\GRAPH.BMP";
          ACTION oFrmDat:ViewDatGraf(oFrmDat)

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oFrmDat:AntImprime(oFrmDat)

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oFrmDat:oBrw:GoTop(),oFrmDat:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oFrmDat:oBrw:PageDown(),oFrmDat:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oFrmDat:oBrw:PageUp(),oFrmDat:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oFrmDat:oBrw:GoBottom(),oFrmDat:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFrmDat:Close()

  @ 0.1,60 SAY oFrmDat:cTrabajad OF oBar BORDER SIZE 345,18
  @ 1.4,60 SAY oFrmDat:cConcepto OF oBar BORDER SIZE 345,18

  oFrmDat:oBrw:SetColor(0,14087148)

  oBar:SetColor(CLR_BLACK,15724527)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

RETURN .T.

#Include "G_Graph.ch"
/*
// Grafica
*/
FUNCTION ViewDatGraf(oFrmDat)
  Local aValues, aTitCol,cTitle:=""
  LOCAL oFontT, oFontX, oFontY, oFont
  LOCAL oGraph, oColumn, ii,oGWnd
  LOCAL aData:={}
  LOCAL cSql,I
  LOCAL nDivide:=1,nTotal:=0
  LOCAL cMes

  DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0,-10
  DEFINE FONT oFontT NAME "Times New Roman" SIZE 0,-18 BOLD ITALIC
  DEFINE FONT oFontX NAME "Times New Roman" SIZE 0,-10
  DEFINE FONT oFontY NAME "Times New Roman" SIZE 0,-10

  aValues:={}
  aData:=oFrmDat:oBrw:aArrayData
  uValues:={}
  FOR I=1 TO LEN(aData)
     cMes:=LEFT(CMES(aData[I,1]),2)+"/"+RIGHT(STRZERO(YEAR(aData[I,1]),4),2)
     AADD(aValues,{cMes,DIV(aData[I,6],1000)})
     nTotal:=100
  NEXT I

  nDivide:=LEN(aData)
  cTitle :="["+ALLTRIM(STR(nTotal))+"]"

  aTitCol := { { "Escala 1:1000" , RGB(150,150,150) }, ;
               { "Grupo 2" , RGB(  0,200,100) }  ;
            }

 oGWnd := GraWnd():New( 2, 0,32 ,098 , ;
          "Antiguedad ", GraServer():New(aValues), ;
          .F. )

 oGWnd:oWnd:oFont := oFont

//Sin ToolBar
 oGWnd:bToolBar := { || nil }
//Tomar grafica
 oGraph := oGWnd:oGraph
 oGraph:lPopUp := .T.
 oGraph:oTitle:cText   := oFrmDat:cTitle // "Trabajadores por Grupo"
 oGraph:GTypeLine()
 //Titulo a la izquierda
 oGraph:oTitle:AliLeft()
 //Asignar Fonts
 oGraph:oTitle:oFontT:=oFontT
 oGraph:oAxisX:oFontL:=oFontX
 oGraph:oAxisYL:oFontL:=oFontY
 //Asignar colores
 oGraph:oTitle:nClrT   :=RGB( 55, 55, 55)
 oGraph:oAxisX:nClrL   :=CLR_RED
 oGraph:oAxisYL:nClrL   :=CLR_BLUE
 //Presentacion de etiquetas AxisYL
 oGraph:oAxisYL:bToLabel := { |nParam| TRANSFORM(nParam,"9,999,999") }
 oGraph:cBitmap:= "beige2.bmp"
 oGraph:nRowView := MIN(len(aData),24)

 //Sin linea punteada en Grid
 oGraph:oAxisX:lDottedGrid := .F.
 oGraph:oAxisYL:lDottedGrid := .F.
 //Intervalo de AxisYL
 oGraph:oAxisYL:nStepOne := 6000
 //Color gris en oAxisYL:nAxisBase
 oGraph:oAxisYL:nClrZ := CLR_BLUE
 //Anular escalamiento automatico en AxisYL
 oGraph:oAxisYL:bToScale := { | nVal | nVal }

 //Asignar automaticamente las Columnas del servidor de datos
 oGraph:AutoData()

 //Asignar titulos y colores a Columnas (la primer columna son valores de X)
 FOR ii = 1 TO oGraph:nColGraph()
   oColumn:= oGraph:GetColGraph(ii)
   oColumn:cTitle   := aTitCol[ii,1]
   oColumn:nClrFill := aTitCol[ii,2]
 NEXT ii

//Usar tipo de grafica: Barras
oGraph:GTypeBar()

//Aplicar escala de fechas
oGraph:oAxisX:lAxisScale := .T.  //Es necesario que sea eje escalable
oGraph:oAxisX:lAxisDate := .T.   //Considerar la escala como fechas

 oGWnd:Activate()

 oFontT:End()
 oFontX:End()
 oFontY:End()
 oFont:End()

RETURN .T.

/*
// Imprimir Antiguedad
*/
FUNCTION ANTIMPRIME(oFrmDat)
  LOCAL aVar   :={}

  aVar:={oDp:cCodTraIni,;
         oDp:cCodTraFin}

  oDp:cCodTraIni:=oFrmDat:cCodTrab
  oDp:cCodTraFin:=oFrmDat:cCodTrab

  REPORTE("REPH400")

  oDp:cCodTraIni:=aVar[1]
  oDp:cCodTraFin:=aVar[2]

RETURN .T.

// EOF
