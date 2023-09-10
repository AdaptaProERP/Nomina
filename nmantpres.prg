// Programa   : NMANTPRES
// Fecha/Hora : 24/05/2004 01:19:07
// Propósito  : Visualiza Anticipo de Prestaciones
// Creado Por : Juan Navas
// Llamado por: Trabajador,Consultar,Intereses,Pago de Intereses
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
   LOCAL aData:={},dDesde,nMonto:=0,nContar:=0
   LOCAL cPagos:=oDp:cConAdel
   LOCAL oTable,oTrabaj
   
   DEFAULT cCodTra:=SQLGET("NMRECIBOS","REC_CODTRA")

   CursorWait()

   oTrabaj:=OPENTABLE(" SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR "+;
                          " WHERE CODIGO"+GetWhere("=",cCodTra),.T.)

   oTable:=OPENTABLE(" SELECT HIS_NUMOBS,HIS_NUMREC,FCH_DESDE,FCH_HASTA,HIS_MONTO,HIS_VARIAC FROM NMHISTORICO "+;
                     " INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
                     " INNER  JOIN NMFECHAS ON NMFECHAS.FCH_NUMERO = NMRECIBOS.REC_NUMFCH "+;
                     " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
                     " AND HIS_CODCON"+GetWhere("=",oDp:cConAdel),.T.)

   oTable:Gotop()

   WHILE !oTable:Eof()
     nContar++
     nMonto:=nMonto+oTable:HIS_MONTO
     oTable:Replace("HIS_NUMOBS",STRZERO(nContar,3))
     oTable:Replace("HIS_VARIAC",nMonto)
     oTable:DbSkip()
   ENDDO

   IF !EMPTY(oTable:RecCount())
       
      VIEWDATA(oTable:aDataFill,cCodTra,oTrabaj:APELLIDO,oTrabaj:NOMBRE)
   
   ELSE

      MensajeErr("Trabajador:"+cCodTra+" no tiene Registros de:"+oDp:cConAdel)

   ENDIF

   oTrabaj:End()

   oTable:End()

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION ViewData(aData,cCodTra,cApellido,cNombre)
   LOCAL oBrw,aHisto
   LOCAL I,nMonto:=0,nDias
   LOCAL cSql,oTable,cTipo:="Pago de Intereses : "+oDp:cConInter
   LOCAL oFont,oFontB
   LOCAL nDias:=0,nInteres:=0,nMontoAnt:=0
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   cApellido:=ALLTRIM(cApellido)+","+ALLTRIM(cNombre)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//   oAntPres:=DPEDIT():New("Pagos sobre Antiguedad Laboral ","NMANTPRES.edt","oAntPres",.T.)

   DpMdi("Pagos sobre Antiguedad Laboral ","oAntPres","NMANTPRES.edt")

   oAntPres:Windows(0,0,aCoors[3]-160,MIN(620,aCoors[4]-10),.T.) // Maximizado

   oAntPres:oBrw:=TXBrowse():New( oAntPres:oDlg )
   oAntPres:oBrw:SetArray( aData, .F. )
   oAntPres:oBrw:SetFont(oFont)
   oAntPres:oBrw:lFooter             := .F.
   oAntPres:oBrw:lHScroll:= .F.
   oAntPres:cCodTra  :=cCodTra
   oAntPres:cTrabajad:=" "+ALLTRIM(cCodTra)+" "+cApellido
   oAntPres:cConcepto:=" Concepto: ["+oDp:cConAdel+"]"


   oAntPres:nClrPane1:=16775408
   oAntPres:nClrPane2:=16771797

   oAntPres:nClrText :=0
   oAntPres:nClrText1:=CLR_HBLUE
   oAntPres:nClrText2:=4887808
   oAntPres:nClrText3:=0


   AEVAL(oAntPres:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oAntPres:oBrw:aCols[1]:cHeader:="Num."
   oAntPres:oBrw:aCols[1]:nWidth :=060

   oAntPres:oBrw:aCols[2]:cHeader:="Recibo"
   oAntPres:oBrw:aCols[2]:nWidth :=080

   oAntPres:oBrw:aCols[3]:cHeader:="Desde"
   oAntPres:oBrw:aCols[3]:nWidth :=70

   oAntPres:oBrw:aCols[4]:cHeader:="Hasta"
   oAntPres:oBrw:aCols[4]:nWidth :=70

   oAntPres:oBrw:aCols[5]:cHeader:="Monto"
   oAntPres:oBrw:aCols[5]:nWidth :=120
   oAntPres:oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT
   oAntPres:oBrw:aCols[5]:cEditPicture := "99,999,999.99"
   oAntPres:oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT
   oAntPres:oBrw:aCols[5]:bStrData     :={||oBrw:=oAntPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],"99,999,999.99")}

   oAntPres:oBrw:aCols[6]:cHeader:="Acumulado"
   oAntPres:oBrw:aCols[6]:nWidth :=150
   oAntPres:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oAntPres:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oAntPres:oBrw:aCols[6]:cEditPicture := "999,999,999.99"
   oAntPres:oBrw:aCols[6]:bStrData     :={||oBrw:=oAntPres:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],"999,999,999.99")}

   oAntPres:oBrw:bClrStd := {|oBrw,nClrText,aData|oBrw:=oAntPres:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                             nClrText:=0,;
                             {nClrText,iif( oBrw:nArrayAt%2=0, oAntPres:nClrPane1, oAntPres:nClrPane2) } }

   oAntPres:oBrw:bLDblClick:={|oBrw|oBrw:=oAntPres:oBrw,;
                               EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,2])}

//   oAntPres:oBrw:bClrHeader:= {|| {0,14671839 }}
//   oAntPres:oBrw:bClrFooter:= {|| {0,14671839 }

   oAntPres:oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oAntPres:oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oAntPres:oBrw:CreateFromCode()

   oAntPres:oWnd:oClient := oAntPres:oBrw


   oAntPres:Activate({||oAntPres:ViewDatBar(oAntPres)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oAntPres)
   LOCAL oCursor,oBar,oBtn,oFont,oFontB,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oAntPres:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RECIBO.BMP";
          ACTION EVAL(oAntPres:oBrw:bLDblClick)

   oBtn:cToolTip:="Visualizar Cuerpo del Recibo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oAntPres:oBrw:GoTop(),oAntPres:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oAntPres:oBrw:PageDown(),oAntPres:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oAntPres:oBrw:PageUp(),oAntPres:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oAntPres:oBrw:GoBottom(),oAntPres:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oAntPres:Close()

  oAntPres:oBrw:SetColor(0,oAntPres:nClrPane1 )

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,40 SAY oAntPres:cTrabajad OF oBar BORDER SIZE 345,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontB
  @ 1.4,40 SAY oAntPres:cConcepto OF oBar BORDER SIZE 345,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontB

  

RETURN .T.

// EOF




