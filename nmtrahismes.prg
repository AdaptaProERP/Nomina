// Programa   : NMTRABHISMES
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Resumen Mensual de Pagos
// Creado Por : Juan Navas
// Llamado por: NMTRABJCON
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"
#Include "G_Graph.ch"

PROCE MAIN(cCodTra)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,nAno,nAt:=0,nDif:=0,nMtoAnt:=0,nAnoAnt:=0
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nMonto:=0,nRecibo:=0,nContar,nAnual:=0,nNumRec:=0,nMeses:=0
  LOCAL nAsigna:=0,nDeducc:=0
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )

  IF Type("oRecMes")="O" .AND. oRecMes:oWnd:hWnd>0
     RETURN EJECUTAR("BRRUNNEW",oRecMes,GetScript())
  ENDIF

  DEFAULT cCodTra:=SQLGET("NMRECIBOS","REC_CODTRA")

  cSql:="SELECT YEAR(FCH_SISTEM) AS ANO,MONTH(FCH_SISTEM) AS MES,"+;
        "SUM(IF(LEFT(HIS_CODCON,1)='A', HIS_MONTO     , IF(1=0,0,0)))     AS ASIGNA,"+;
        "SUM(IF(LEFT(HIS_CODCON,1)='D', ABS(HIS_MONTO), IF(1=0 , 0, 0 ))) AS DEDUCC, "+;
        "SUM(HIS_MONTO) AS REC_MONTO "+;
        "FROM NMRECIBOS "+;
        "INNER JOIN NMFECHAS    ON REC_NUMFCH=FCH_NUMERO "+;
        "INNER JOIN NMHISTORICO ON HIS_NUMREC=REC_NUMERO "+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+" AND HIS_CODCON<='DZZZ' "+;   
        "GROUP BY YEAR(FCH_SISTEM),MONTH(FCH_SISTEM) "+;
        "ORDER BY YEAR(FCH_SISTEM),MONTH(FCH_SISTEM) "

  oTable:=OpenTable(cSql,.T.)

  WHILE !oTable:Eof()
     oTable:Replace("ANO"      ,CTOO(oTable:ANO      ,"C"))
     oTable:Replace("MES"      ,CTOO(oTable:MES      ,"C"))
     oTable:Replace("ASIGNA"   ,CTOO(oTable:ASIGNA   ,"N"))
     oTable:Replace("DEDUCC"   ,CTOO(oTable:DEDUCC   ,"N"))
     oTable:Replace("REC_MONTO",CTOO(oTable:REC_MONTO,"N"))
     oTable:DbSkip()
  ENDDO

  aData :=ACLONE(oTable:aDataFill)

// AEVAL(aData,{|a,n|nMonto:=nMonto+a[4],nRecibo:=nRecibo+val(a[3])})

  nContar:=1

  WHILE nContar<=LEN(aData)

    nAno            :=aData[nContar,1]
    aData[nContar,1]:=ALLTRIM(CTOO(aData[nContar,1],"C"))
    aData[nContar,2]:=ALLTRIM(CTOO(aData[nContar,2],"C"))

    nAnual :=0
    nNumRec:=0
    nAsigna:=0
    nDeducc:=0

    WHILE nContar<=LEN(aData) .AND.  nAno=aData[nContar,1]

      IF LEN(aData[nContar,2])<>13

        nAnual :=nAnual +aData[nContar,4]
        nAsigna:=nAsigna+aData[nContar,3]
        nDeducc:=nDeducc+aData[nContar,4]
        nMeses++

      ENDIF

      nContar++

    ENDDO

    IF nAnual>0
        AADD(aData,{nAno,"13",nAsigna,nDeducc,nAsigna-nDeducc,0,"0",0})
        nContar++
    ENDIF

  ENDDO

  nAsigna:=0
  nDeducc:=0

  FOR I:=1 TO LEN(aData)

     AADD(aData[I],0)
     AADD(aData[I],aData[I,1])
     AADD(aData[I],aData[I,2])
     aData[I,1]:=aData[I,1]+" "+IIF(aData[I,2]="13","TOTAL"," "+CMES(VAL(aData[I,2])))
     aData[I,2]:=aData[I,3]
     aData[I,3]:=aData[I,4]
     aData[I,4]:=aData[I,5]
     aData[I,5]:=0

     IF !"TOTAL"$aData[I,1]
       nAsigna:=nAsigna+aData[I,2]
       nDeducc:=nDeducc+aData[I,3]
     ENDIF

  NEXT 

  nMtoAnt:=0

  FOR I=1 TO LEN(aData)

     nAt:=ASCAN(aData,{|a,n|a[6]==aData[I,6] .AND. a[7]=="13"})

//   nAt:=ASCAN(aData,{|a,n|a[6]==aData[I,6] })

     IF nAt>0 
       IF I<>nAt
          aData[I,5]:=RATA(aData[I,4],aData[nAt,4])
          nMeses    :=nMeses+1
          IF nMtoAnt>0
             aData[I,5]:=aData[I,4]-nMtoAnt
          ENDIF
          nMtoAnt:=aData[I,3]
       ELSE
          aData[I,5]:=RATA(aData[I,4],nMonto)

          IF nAnoAnt>0
             aData[I,5]:=aData[I,4]-nAnoAnt
          ENDIF

          nAnoAnt:=aData[I,4]

       ENDIF
     ENDIF

  NEXT I

  AEVAL(aData,{|a,n| aData[n,5]:=RATA(aData[n,4],nAsigna-nDeducc),;
                     aData[n,8]:=IIF(Empty(a[8]),"13",STRZERO(n,2))})

  aData:= ASORT(aData,,, { |x, y| (x[1]+x[8])<(y[1]+y[8]) }) // Ordena por Fecha

  ARREDUCE(aData,LEN(aData))

  cPictureM:=oTable:GetPicture("REC_MONTO",.T.)

  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Trabajador "+cCodTra+" No posee Registros en Recibos de Pago")
     RETURN .T.
  ENDIF

  oTable :=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
  cNombre:=cCodTra+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
  oTable:End()

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//  oRecMes:=DPEDIT():New("Resumen Mensual de Pagos","NMTRABHMES.edt","oRecMes",.T.)

  DpMdi("Resumen Mensual de Pagos","oRecMes","NMTRABHMES.edt")
  oRecMes:Windows(0,0,aCoors[3]-160,MIN(752,aCoors[4]-10),.T.) // Maximizado

  oRecMes:cCodTra  :=cCodTra
  oRecMes:cPictureM:=cPictureM
  oRecMes:cTrabajad:=" "+cNombre

  oRecMes:nClrPane1:=oDp:nClrPane1
  oRecMes:nClrPane2:=oDp:nClrPane2

  oDlg:=oRecMes:oDlg

  oBrw:=TXBrowse():New( oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

 

  oBrw:aCols[1]:cHeader:="Periodo [Año/Mes]"
  oBrw:aCols[1]:nWidth :=120
  oBrw:aCols[1]:cFooter:="Meses: "+ALLTRIM(STR(nMeses))

//  oBrw:aCols[2]:cHeader:="Recibos"
//  oBrw:aCols[2]:nWidth :=160
//  oBrw:aCols[2]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,;
//                                    IIF(oBrw:aArrayData[oBrw:nArrayAt,2]="13","TOTAL",;
//                                    (STRZERO(VAL(oBrw:aArrayData[oBrw:nArrayAt,2]),2)+"-"+;
//                                    CMES(VAL(oBrw:aArrayData[oBrw:nArrayAt,2]))))}

  oBrw:aCols[2]:cHeader:="Asignación"
  oBrw:aCols[2]:nWidth :=170
  oBrw:aCols[2]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[2]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[2]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[2]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,2],oRecMes:cPictureM)}
  oBrw:aCols[2]:cFooter       := TRAN(nAsigna,cPictureM)
  oBrw:aCols[2]:cEditPicture  := cPictureM

  oBrw:aCols[3]:cHeader:="Deducción"
  oBrw:aCols[3]:nWidth :=170
  oBrw:aCols[3]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[3]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[3]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[3]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],oRecMes:cPictureM)}
  oBrw:aCols[3]:cEditPicture  := cPictureM
  oBrw:aCols[3]:cFooter       :=TRAN(nDeducc,cPictureM)

  oBrw:aCols[4]:nWidth :=170
  oBrw:aCols[4]:cHeader:="Neto"
  oBrw:aCols[4]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[4]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[4]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[4]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oRecMes:cPictureM)}
  oBrw:aCols[4]:cFooter       := TRAN(nAsigna-nDeducc,cPictureM)
  oBrw:aCols[4]:cEditPicture  := cPictureM

  oBrw:aCols[5]:cHeader:="%Rata"
  oBrw:aCols[5]:nWidth :=60
  oBrw:aCols[5]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[5]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[5]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[5]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],"9999.99")}
  oBrw:aCols[5]:cEditPicture  := "999.99"

  oBrw:aCols[6]:cHeader:="Incremento"
  oBrw:aCols[6]:nWidth :=170
  oBrw:aCols[6]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[6]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[6]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[6]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oRecMes:cPictureM)}
  oBrw:aCols[6]:cEditPicture  := cPictureM

//  oBrw:bClrHeader:= {|| {0,14671839 }}
//  oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oRecMes:oBrw,;
                               nClrText:=IIF("TOTAL"$oBrw:aArrayData[oBrw:nArrayAt,1],CLR_HBLUE,CLR_BLACK),;
                              {nClrText, iif( oBrw:nArrayAt%2=0, oRecMes:nClrPane1, oRecMes:nClrPane2 ) } }


  oBrw:bLDblClick:={|oBrw,nAno,nMes|oBrw:=oRecMes:oBrw     ,;
                     nAno:=oBrw:aArrayData[oBrw:nArrayAt,7],;
                     nMes:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                     EJECUTAR("NMTRABREC",oRecMes:cCodTra,nAno,nMes)}

  oBrw:SetFont(oFont)

  oRecMes:oBrw:=oBrw

  oBrw:bClrHeader   := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter   := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:CreateFromCode()

  oRecMes:oWnd:oClient := oRecMes:oBrw

  oRecMes:Activate({||oRecMes:LeyBar(oRecMes)}) // ,oBrw:GoBottom()})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oRecMes)    //f
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oRecMes:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RECIBO.BMP";
          ACTION EVAL(oRecMes:oBrw:bLDblClick)

  oBtn:cToolTip:="Visualizar Recibos"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\EXCEL.BMP";
         ACTION (EJECUTAR("BRWTOEXCEL",oRecMes:oBrw,oRecMes:cTitle,oRecMes:cTrabajad))

  oBtn:cToolTip:="Exportar hacia Excel"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RESUMENXCONCEPTO.BMP"

  oBtn:bAction :={|oBrw,nAno,nMes|oBrw:=oRecMes:oBrw     ,;
                   nAno:=oBrw:aArrayData[oBrw:nArrayAt,7],;
                   nMes:=oBrw:aArrayData[oBrw:nArrayAt,8],;
                   EJECUTAR("NMTRABHISCON",oRecMes:cCodTra,nAno,nMes)}

  oBtn:cToolTip:="Visualizar Resumen por Concepto"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\GRAPH.BMP"

  oBtn:bAction :={|oBrw|oBrw:=oRecMes:oBrw     ,;
                   oRecMes:xGrafRes(oRecMes)}

  oBtn:cToolTip:="Graficar"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oRecMes:oBrw:GoTop(),oRecMes:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oRecMes:oBrw:PageDown(),oRecMes:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oRecMes:oBrw:PageUp(),oRecMes:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oRecMes:oBrw:GoBottom(),oRecMes:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRecMes:Close()

  oRecMes:oBrw:SetColor(0,oRecMes:nClrPane1)
  oRecMes:oBrw:GoTop(.T.)
  oRecMes:oBrw:nArrayAt:=LEN(oRecMes:oBrw:aArrayData)
  oRecMes:oBrw:nRowSel :=LEN(oRecMes:oBrw:aArrayData)


  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,60 SAY oRecMes:cTrabajad OF oBar BORDER SIZE 345,18;
           COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  
RETURN .T.

FUNCTION XGrafRes(oRecMes)
  Local aValues:={}, aTitCol,cTitle:=""
  LOCAL oFontT, oFontX, oFontY, oFont
  LOCAL oGraph, oColumn, ii,oGWnd
  LOCAL aData:={}
  LOCAL cSql,I
  LOCAL nDivide:=1,nTotal:=0,nIni
  LOCAL oTable,oIco

  aData:=ACLONE(oRecMes:oBrw:aArrayData)

  nIni :=MAX(LEN(aData)-10,1)
  FOR I:=nIni TO LEN(aData)
    IF aData[I,7]="13"
       nIni:=nIni-1
    ENDIF
  NEXT I
  nIni:=MAX(nIni,1)

  FOR I:=nIni TO LEN(aData)
    IF aData[I,7]<>"13"
       AADD(aValues,{ALLTRIM(LEFT(CMES(VAL(aData[I,7])),3))+"/"+RIGHT(aData[I,6],2),DIV(aData[I,3],1)})
       nTotal:=nTotal+aData[I,3]
    ENDIF
  NEXT
  
  DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0,-6
  DEFINE FONT oFontT NAME "Times New Roman" SIZE 0,-12 BOLD
  DEFINE FONT oFontX NAME "Times New Roman" SIZE 0,-10 
  DEFINE FONT oFontY NAME "Times New Roman" SIZE 0,-10 BOLD

//  cTitle:="["+ALLTRIM(STR(nTotal))+"]"

  aTitCol := { { "Recibos" , RGB(150,150,150) }, ;
             }

  aTitCol := { { "Recibos" , CLR_HBLUE }, ;
             }


  oGWnd := GraWnd():New( 1,1 , 30,90 , ;
           "Pagos:"+oRecMes:cTrabajad, GraServer():New(aValues), ;
           .F. )

  oGWnd:oWnd:oFont := oFont

  oGWnd:bToolBar := { || nil }
  oGraph := oGWnd:oGraph

  oGraph:lPopUp := .T.
  oGraph:oTitle:cText   := oRecMes:cTrabajad
  oGraph:GTypeLine()
  oGraph:oTitle:AliLeft()
  oGraph:oTitle:oFontT   :=oFontT
  oGraph:oAxisX:oFontL   :=oFontX
  oGraph:oAxisYL:oFontL  :=oFontY
  oGraph:oTitle:nClrT    :=CLR_BLUE // RGB( 55, 55, 55)
  oGraph:oAxisX:nClrL    :=CLR_HRED
  oGraph:oAxisYL:nClrL   :=CLR_HBLUE
  oGraph:oAxisYL:bToLabel:= { |nParam| TRANSFORM(nParam,"9,999,999") }
//  oGraph:cBitmap:= "bitmaps\datapro.bmp"

  //Sin linea punteada en Grid
  oGraph:oAxisX:lDottedGrid := .T.
  oGraph:oAxisYL:lDottedGrid:= .T.

  //Intervalo de AxisYL
  oGraph:oAxisYL:nStepOne := 6000*20

  //Color gris en oAxisYL:nAxisBase
  oGraph:oAxisYL:nClrZ := CLR_GRAY
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

  oGWnd:Activate()

  DEFINE ICON oIco RESNAME "ICON"

  oGWnd:oWnd:SetIcon(oIco)

//  oGWnd:oWnd:SetSize(700,500,.T.)

  oFontT:End()
  oFontX:End()
  oFontY:End()
  oFont:End()
  oIco:End()

RETURN (NIL)
// EOF
