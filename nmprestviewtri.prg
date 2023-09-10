// Programa   : NMPRESTVIEW
// Fecha/Hora : 14/06/2004 19:10:32
// Propósito  : Visualizar Prestaciones Sociales 
// Creado Por : Juan Navas
// Llamado por: NMCALANT
// Aplicación : Nómina
// Tabla      : DPHISTO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,lData)
   LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oSintax,oMemo,oEjemplo,oTable
   LOCAL aInteres:={},dDesde,nInteres:=0,aVacio:={0,0,0,CTOD(""),0}
   LOCAL cPagos:=oDp:cConAdel+","+oDp:cConInter,nAt,aData
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFAULT lData:=.F.

   CursorWait()

   DEFAULT cCodTra:=SQLGET("NMRECIBOS","REC_CODTRA")

   publico("oTrabajador","nil")
   
   CursorWait()

//? lData,lData

   aData:=ViewData(cCodTra,lData)

//viewarray(adata)
   IF lData 
      RETURN aData
   ENDIF

//? "2"

RETURN aData

/*
// Coloca la Barra de Botones
*/
FUNCTION ViewData(cCodTra,lData)
   LOCAL oBrw,aHisto,cAntigue:=""
   LOCAL I,nMonto:=0,nDias,nAt,nAnticipo:=0,nInteres:=0,aInteres:={},nPagoInt:=0,nAntigue:=0,aTotal:={}
   LOCAL nIntAcum:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL cPagos:=oDp:cConAdel+","+oDp:cConInter,dDesde
   LOCAL cTipNom:=SQLGET("NMTRABAJADOR","TIPO_NOM","CODIGO"+GetWhere("=",cCodTra))
   LOCAL cFecha :=HISFECHA(NIL,cTipNom)
   LOCAL aLine  :={},aH400:={}
   LOCAL nBaseAnual:=oDp:nBaseAnual,nDias,dFecha,nSalario,nMeses:=0
   LOCAL nIntxPag:=0,nSaldo:=0
//   LOCAL cNombre :=SQLGET("NMTRABAJADOR","NOMBRE,APELLIDO,FECHA_ING","CODIGO"+GetWhere("=",cCodTra))

   DEFAULT nBaseAnual:=360


//? "22"

   IF oDp:lIndexaInt
      cPagos:=oDp:cConAdel+","+oDp:cConInter
   ENDIF

//   DEFAULT aData:=oFrmView:oBrw:aArrayData[oFrmView:oBrw:nArrayAt]

   publico("oTrabajador","nil")


   oTrabajador:=OPENTABLE(" SELECT * FROM NMTRABAJADOR "+;
                          " WHERE CODIGO"+GetWhere("=",cCodTra),.T.)

   cAntigue:=ANTIGUEDAD(oTrabajador:FECHA_ING)

   dDesde:=oTrabajador:FECHA_ING

//   IF oTrabajador:DESTINO_PR<>"B"
//   nInteres:=INTERES(NIL,oDp:cConPres,cPagos,dDesde,oDp:dFecha,@aInteres,,,,,,,oDp:lIndexaInt,0,oDp:dFchIniInt)

    nInteres:=EJECUTAR("INTERESES",NIL,oDp:cConPresTr,cPagos,dDesde,oDp:dFecha,@aInteres,,,,,,cCodTra,oDp:lIndexaInt,0,oDp:dFchIniInt)

    aInteres:=ACLONE( oDp:aIntereses)

   // Debe Borrar los Intereses
   IF oTrabajador:DESTINO_PR<>"B"
   ENDIF

   oTrabajador:End()

   cSql:="SELECT "+cFecha+",HIS_VARIAC,0,HIS_MONTO,HIS_CODCON FROM NMHISTORICO "+;
         " INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
         " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
         " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
         " AND HIS_CODCON"+GetWhere("=",oDp:cConPresTr)+;
         " ORDER BY "+cFecha

   aH400   :=ASQL(cSql)

//? aH400,"aH400"
   dFechaA :=aH400[1,1]

   FOR I=1 TO LEN(aH400)

      dFecha:=aH400[I,1]
      nDias :=DAY(dFecha)

      IF nBaseAnual=360 .AND. (nDias=31 .OR. (nDias>=28 .AND. MONTH(aH400[I,1])=2))

          // 20/10/2010
          // JN Aqui es interpretativo, si febrero tiene 28 o 29 Dias, y la base es 30
          // Si la base no es 30 entonces sera 28 ??? Cada cliente debe indicar su interpretacion

          dFecha:=FCHFINMES(dFecha)

          IF DAY(dFecha)>30
             dFecha--
          ENDIF

          nDias:=30

      ENDIF

      aH400[I,3]:=nDias
      aH400[I,1]:=dFecha

   NEXT I

   aHisto:={}

   FOR I=1 TO LEN(aInteres)

      aLine:=ARRAY(12)

      aLine[01]:=aInteres[I,1]
      aLine[02]:=aInteres[I,2]
      aLine[05]:=0 // Antiguedad
      aLine[07]:=0 // Anticipos
      aLine[09]:=0 // Interes Pagado 

      
      // Busca los 5 dias de Antiguedad
      nDias   :=0
      nSalario:=0
      nMeses  :=0
      nMeses  :=MESES(aLine[02],dDesde)

      nAt  :=ASCAN(aH400,{|a,n|a[5]=aLine[01] .AND. aLine[02]=a[1]})

      IF nAt>0

         nDias    :=aH400[nAt,2]
         nSalario :=DIV(aH400[nAt,4],nDias)
         aLine[05]:=aH400[nAt,4] // Antiguedad
      
      ENDIF

      // Anticipos
      IF aInteres[I,01]==oDp:cConAdel
         aLine[07]:=aInteres[I,4]*-1 // Antiguedad
      ELSE
         aLine[07]:=0
      ENDIF

      // Anticipos, Hay que buscarlo en H400
      IF aLine[01]==oDp:cConInter 
         aLine[09]:=aInteres[I,4]*-1 // Interes Pagado 
      ELSE
         aLine[09]:=0
      ENDIF

      nIntxPag:=nIntxPag+aInteres[I,7]-aLine[09]

      aLine[03]:=nDias         // nDias   
      aLine[04]:=nSalario      // Salario  
      aLine[06]:=nMeses        // Meses    
      aLine[08]:=aInteres[I,7] // Interes Ganado
      aLine[10]:=nIntxPag      // Interes x Pagar
      aLine[11]:=0 // Del Mes  
      aLine[12]:=aInteres[I,8] // Saldo   

      AADD(aHisto,ACLONE(aLine))

   NEXT I

   IF lData
     RETURN aHisto
   ENDIF

   // Calcular Total
   nMonto:=0

// ViewArray(aHisto)
// ViewArray(aInteres)
 //ViewArray(aH400)

   FOR I=1 TO LEN(aHisto)
     aHisto[I,11]:=aHisto[I,5]-aHisto[I,7]+aHisto[I,8]-aHisto[I,9]
   NEXT I

   IF Empty(aHisto)
      MensajeErr("No hay Información")
      RETURN .F.
   ENDIF

   aTotal:=ATOTALES(aHisto)
   aTotal[12]:=aHisto[LEN(aHisto),12]

   oTrabajador:End()

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi("Estado de Cuenta [Prestaciones] ","oFrmPres","NMPRESTVIEW.edt")
   oFrmPres:Windows(0,0,aCoors[3]-160,MIN(900,aCoors[4]-10),.T.) // Maximizado

//   oFrmPres:=DPEDIT():New("Estado de Cuenta [Prestaciones] ","NMPRESTVIEW.edt","oFrmPres",.T.)

   oFrmPres:lMsgBar:=.F.
   oFrmPres:cCodTrab :=cCodTra
   oFrmPres:cTrabajad:=" "+ALLTRIM(cCodTra)+" "+ALLTRIM(oTrabajador:APELLIDO)+","+ALLTRIM(oTrabajador:NOMBRE)
   oFrmPres:cConcepto:=" Ingreso :"+DTOC(oTrabajador:FECHA_ING)+"["+cAntigue+"] C: "+oDp:cConPresTr+","+;
                       oDp:cConAdel+","+oDp:cConInter
   oFrmPres:cPicture :="9,999,999,999.99"

   oFrmPres:nClrPane1:=16775408
   oFrmPres:nClrPane2:=16771797

   oFrmPres:nClrText :=0
   oFrmPres:nClrText1:=CLR_HBLUE
   oFrmPres:nClrText2:=4887808
   oFrmPres:nClrText3:=0

   oFrmPres:oBrw:=TXBrowse():New( oFrmPres:oDlg )
   oFrmPres:oBrw:SetArray( aHisto, .F. )
   oFrmPres:oBrw:SetFont(oFont)
   oFrmPres:oBrw:lFooter := .T.
   oFrmPres:oBrw:lHScroll:= .T.
   oFrmPres:oBrw:nFreeze      :=2
   oFrmPres:oBrw:nHeaderLines := 2


   AEVAL(oFrmPres:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oFrmPres:oBrw:aCols[1]:cHeader:="Cod"
   oFrmPres:oBrw:aCols[1]:nWidth :=070

   oFrmPres:oBrw:aCols[2]:cHeader:="Fecha"
   oFrmPres:oBrw:aCols[2]:nWidth :=069

   oFrmPres:oBrw:aCols[3]:cHeader:="Días"
   oFrmPres:oBrw:aCols[3]:nWidth :=45
   oFrmPres:oBrw:aCols[3]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[3]:cEditPicture := "999.99"
   oFrmPres:oBrw:aCols[3]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[3]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[3]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],"999.99")}
   oFrmPres:oBrw:aCols[3]:cFooter      :=TRAN(aTotal[3],"999.99")

   oFrmPres:oBrw:aCols[4]:cHeader:="Salario"
   oFrmPres:oBrw:aCols[4]:nWidth :=110
   oFrmPres:oBrw:aCols[4]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[4]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[4]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[4]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oFrmPres:cPicture)}

   oFrmPres:oBrw:aCols[5]:cHeader:="Antiguedad"
   oFrmPres:oBrw:aCols[5]:nWidth :=110
   oFrmPres:oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[5]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[5]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oFrmPres:cPicture)}
   oFrmPres:oBrw:aCols[5]:cFooter      :=TRAN(aTotal[5],oFrmPres:cPicture)

   oFrmPres:oBrw:aCols[6]:cHeader:="Meses"
   oFrmPres:oBrw:aCols[6]:nWidth :=45
   oFrmPres:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[6]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],"999")}
   oFrmPres:oBrw:aCols[6]:cFooter      :=TRAN(I-1,"999")

   oFrmPres:oBrw:aCols[7]:cHeader:="Anticipos"
   oFrmPres:oBrw:aCols[7]:nWidth :=110
   oFrmPres:oBrw:aCols[7]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[7]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[7]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[7]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],oFrmPres:cPicture)}
   oFrmPres:oBrw:aCols[7]:cFooter      :=TRAN(aTotal[7],oFrmPres:cPicture)

   oFrmPres:oBrw:aCols[8]:cHeader:="Interés"+CRLF+"Ganado"
   oFrmPres:oBrw:aCols[8]:nWidth :=110
   oFrmPres:oBrw:aCols[8]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[8]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[8]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[8]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,8],oFrmPres:cPicture)}
   oFrmPres:oBrw:aCols[8]:cFooter      :=TRAN(aTotal[8],oFrmPres:cPicture)

   oFrmPres:oBrw:aCols[9]:cHeader:="Interés"+CRLF+"Pagado"
   oFrmPres:oBrw:aCols[9]:nWidth :=110
   oFrmPres:oBrw:aCols[9]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[9]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[9]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[9]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,9],"999,999,999.99")}
   oFrmPres:oBrw:aCols[9]:cFooter      :=TRAN(aTotal[9],oFrmPres:cPicture)

   oFrmPres:oBrw:aCols[10]:cHeader:="Interés por Pagar"
   oFrmPres:oBrw:aCols[10]:nWidth :=110
   oFrmPres:oBrw:aCols[10]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[10]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[10]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[10]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,10],"999,999,999.99")}
   oFrmPres:oBrw:aCols[10]:cFooter      :=TRAN(aTotal[8]-aTotal[9],oFrmPres:cPicture)

   oFrmPres:oBrw:aCols[11]:cHeader:="Del Mes"
   oFrmPres:oBrw:aCols[11]:nWidth :=110
   oFrmPres:oBrw:aCols[11]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[11]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[11]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[11]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,11],"999,999,999.99")}
   oFrmPres:oBrw:aCols[11]:cFooter      :=TRAN(0,oFrmPres:cPicture)

   oFrmPres:oBrw:aCols[12]:cHeader:="Saldo"
   oFrmPres:oBrw:aCols[12]:nWidth :=110
   oFrmPres:oBrw:aCols[12]:nDataStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[12]:nHeadStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[12]:nFootStrAlign:= AL_RIGHT
   oFrmPres:oBrw:aCols[12]:bStrData     :={|oBrw|oBrw:=oFrmPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,12],"999,999,999.99")}
   oFrmPres:oBrw:aCols[12]:cFooter      :=TRAN(aTotal[12],oFrmPres:cPicture)


// oFrmPres:oBrw:bClrStd := {|oBrw|oBrw:=oFrmPres:oBrw,{0, iif( oBrw:nArrayAt%2=0, oFrmPres:nClrPane1, 11790521 ) } }
   oFrmPres:oBrw:bClrStd := {|oBrw|oBrw:=oFrmPres:oBrw,{0, iif( oBrw:nArrayAt%2=0, oFrmPres:nClrPane1, oFrmPres:nClrPane2 ) } }

//   oFrmPres:oBrw:bClrHeader:= {|| {0,14671839 }}
//   oFrmPres:oBrw:bClrFooter:= {|| {0,14671839 }}

   oFrmPres:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oFrmPres:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}



   oFrmPres:oBrw:CreateFromCode()

   oFrmPres:oWnd:oClient := oFrmPres:oBrw


   oFrmPres:Activate({||oFrmPres:ViewDatBar(oFrmPres)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oFrmPres)
   LOCAL oCursor,oBar,oBtn,oFont,oFontB,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmPres:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oFrmPres:oBrw,oFrmPres:cTitle,oFrmPres:cTrabajad))

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\interespago.BMP";
          ACTION (EJECUTAR("NMPAGOINT",oFrmPres:cCodTrab))

   oBtn:cToolTip:="Intereses Pagados"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\antiguedadanticipada.BMP";
          ACTION (EJECUTAR("NMANTPRES",oFrmPres:cCodTrab))

   oBtn:cToolTip:="Pagos Anticipados de Antiguedad"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oFrmPres:AntImprime(oFrmPres)

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oFrmPres:oBrw:GoTop(),oFrmPres:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oFrmPres:oBrw:PageDown(),oFrmPres:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oFrmPres:oBrw:PageUp(),oFrmPres:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oFrmPres:oBrw:GoBottom(),oFrmPres:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFrmPres:Close()

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,58 SAY oFrmPres:cTrabajad OF oBar BORDER SIZE 395,18 COLOR oDp:nClrYellowText,oDp:nClrYellow
  @ 1.4,58 SAY oFrmPres:cConcepto OF oBar BORDER SIZE 395,18 COLOR oDp:nClrYellowText,oDp:nClrYellow

  oFrmPres:oBrw:SetColor(0,oFrmPres:nClrPane1)

  // 15790320, 16382457
RETURN .T.

#Include "G_Graph.ch"
/*
// Grafica
*/
FUNCTION ViewDatGraf(oFrmPres)
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
  aData:=oFrmPres:oBrw:aArrayData
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
 oGraph:oTitle:cText   := oFrmPres:cTitle // "Trabajadores por Grupo"
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
FUNCTION ANTIMPRIME(oFrmPres)
  LOCAL aVar   :={}

  aVar:={oDp:cCodTraIni,;
         oDp:cCodTraFin}

  oDp:cCodTraIni:=oFrmPres:cCodTrab
  oDp:cCodTraFin:=oFrmPres:cCodTrab

  REPORTE("NMEDOCTAPRTRIM")

  oDp:cCodTraIni:=aVar[1]
  oDp:cCodTraFin:=aVar[2]

RETURN .T.

// EOF

