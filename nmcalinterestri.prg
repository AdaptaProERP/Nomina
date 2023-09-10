// Programa   : NMCALINTERESTRI
// Fecha/Hora : 24/05/2004 01:19:07
// Propósito  : Calcular los Acumulados mensuales por Trabajador
// Creado Por : Juan Navas
// Llamado por: Actualizar, Reversar Nómina, Clase TNomina
// Aplicación : Nómina
// Tabla      : NMACUMCON

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
   LOCAL aData:={},dDesde,nInteres:=0
   LOCAL cPagos:=oDp:cConAdel+","+oDp:cConInter
   
   publico("oTrabajador","nil")

   DEFAULT cCodTra:=SQLGET("NMRECIBOS","REC_CODTRA")

   CursorWait()

   oTrabajador:=OPENTABLE(" SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING FROM NMTRABAJADOR "+;
                          " WHERE CODIGO"+GetWhere("=",cCodTra),.T.)

   dDesde:=oTrabajador:FECHA_ING

   IF oDp:lIndexaInt
      cPagos:=oDp:cConAdel+","+oDp:cConInter
   ENDIF

//nInteres:=INTERES(NIL,oDp:cConPres,cPagos,dDesde,oDp:dFecha,@aData,,,,,,cCodTra,oDp:lIndexaInt,0,oDp:dFchIniInt)
  
  nInteres:=EJECUTAR("INTERESES",NIL,oDp:cConPresTr,cPagos,dDesde,oDp:dFecha,@aData,,,,,,cCodTra,oDp:lIndexaInt,0,oDp:dFchIniInt)
  aData   :=ACLONE(oDp:aIntereses)

// nInteres:=EJECUTAR("INT",NIL,oDp:cConPres,cPagos,dDesde,oDp:dFecha,@aData,,,,,,cCodTra,oDp:lIndexaInt,0,oDp:dFchIniInt)
// nInteres

   IF !EMPTY(aData)
       
      VIEWDATA(aData,cCodTra,oTrabajador:APELLIDO,oTrabajador:NOMBRE)
   
   ELSE

      MensajeErr("Intereses no Calculados para el Trabajador "+cCodTra)

   ENDIF

   oTrabajador:End()

   RELEASE oTrabajador

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION ViewData(aData,cCodTra,cApellido,cNombre)
   LOCAL oBrw,aHisto
   LOCAL I,nMonto:=0,nDias
   LOCAL cSql,oTable,cTipo:=""
   LOCAL oFont,oFontB
   LOCAL nDias:=0,nInteres:=0,nMontoAnt:=0
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   cApellido:=ALLTRIM(cApellido)+","+ALLTRIM(cNombre)

   AEVAL(aData,{|a|nDias:=nDias+a[6],nMontoAnt:=nMontoAnt+a[3],nInteres:=nInteres+a[7]})

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   cTipo:=" [ Base "+LSTR(oDp:nBaseAnual)+" "+IF( oDp:lIndexaInt,"Indexado","Simple ")+" ]"

//   oFrmIntTrim:=DPEDIT():New("Intereses sobre Antiguedad Laboral. "+cTipo,"NMVIEWINT.edt","oFrmIntTrimTrim",.T.)

   DpMdi("Intereses sobre Antiguedad Laboral. "+cTipo,"oFrmIntTrim","NMVIEWINTRIM.edt")
   oFrmIntTrim:Windows(0,0,aCoors[3]-160,MIN(900,aCoors[4]-10),.T.) // Maximizado

   oFrmIntTrim:lMsgBar:=.F.

 
   oFrmIntTrim:nClrPane1:=16775408
   oFrmIntTrim:nClrPane2:=16771797

   oFrmIntTrim:nClrText :=0
   oFrmIntTrim:nClrText1:=CLR_HBLUE
   oFrmIntTrim:nClrText2:=4887808
   oFrmIntTrim:nClrText3:=0



   oFrmIntTrim:oBrw:=TXBrowse():New( oFrmIntTrim:oDlg )
   oFrmIntTrim:oBrw:SetArray( aData, .F. )
   oFrmIntTrim:oBrw:SetFont(oFont)
   oFrmIntTrim:oBrw:lFooter       := .T.
   oFrmIntTrim:oBrw:lHScroll      := .T.
   oFrmIntTrim:oBrw:nHeaderLines:= 2

   oFrmIntTrim:cCodTra  :=cCodTra
   oFrmIntTrim:cTrabajad:=" "+ALLTRIM(cCodTra)+" "+cApellido
   oFrmIntTrim:cConcepto:=" Conceptos: ["+oDp:cConPresTr+","+oDp:cConAdel+;
                        IIF(oDp:lIndexaInt,","+oDp:cConInter,"")+"]"

   AEVAL(oFrmIntTrim:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oFrmIntTrim:oBrw:aCols[1]:cHeader:="Concepto"
   oFrmIntTrim:oBrw:aCols[1]:nWidth :=080

   oFrmIntTrim:oBrw:aCols[2]:cHeader:="Fecha"
   oFrmIntTrim:oBrw:aCols[2]:nWidth :=70

   oFrmIntTrim:oBrw:aCols[3]:cHeader:="Días"
   oFrmIntTrim:oBrw:aCols[3]:nWidth :=50
   oFrmIntTrim:oBrw:aCols[3]:nDataStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[3]:nHeadStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[3]:nFootStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[3]:cEditPicture := "9999"
   oFrmIntTrim:oBrw:aCols[3]:bStrData     :={||oBrw:=oFrmIntTrim:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],"9999")}
   oFrmIntTrim:oBrw:aCols[3]:cFooter      :=TRAN(nDias,"9999")


   oFrmIntTrim:oBrw:aCols[4]:cHeader:="Cuota"+CRLF+"Mensual"
   oFrmIntTrim:oBrw:aCols[4]:nWidth :=120
   oFrmIntTrim:oBrw:aCols[4]:nDataStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[4]:cEditPicture := "999,999,999.99"
   oFrmIntTrim:oBrw:aCols[4]:nHeadStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[4]:nFootStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[4]:bStrData     :={||oBrw:=oFrmIntTrim:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],"999,999,999.99")}

   oFrmIntTrim:oBrw:aCols[5]:cHeader:="Acumulado"+CRLF+"Cuota"
   oFrmIntTrim:oBrw:aCols[5]:nWidth :=150
   oFrmIntTrim:oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[5]:nFootStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[5]:cEditPicture := "999,999,999.99"
   oFrmIntTrim:oBrw:aCols[5]:bStrData     :={||oBrw:=oFrmIntTrim:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],"999,999,999.99")}
//   oFrmIntTrim:oBrw:aCols[5]:cFooter      :=TRAN(nMontoAnt,"999,999,999.99")

   oFrmIntTrim:oBrw:aCols[6]:cHeader:="Tasa"
   oFrmIntTrim:oBrw:aCols[6]:nWidth :=50
   oFrmIntTrim:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[6]:cEditPicture := "999.99"
   oFrmIntTrim:oBrw:aCols[6]:bStrData     :={||oBrw:=oFrmIntTrim:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],"999.99")}

   oFrmIntTrim:oBrw:aCols[7]:cHeader:="Interés"
   oFrmIntTrim:oBrw:aCols[7]:nWidth :=100
   oFrmIntTrim:oBrw:aCols[7]:nDataStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[7]:nHeadStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[7]:nFootStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[7]:cEditPicture := "999,999,999.99"
   oFrmIntTrim:oBrw:aCols[7]:bStrData     :={||oBrw:=oFrmIntTrim:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],"999,999,999.99")}
   oFrmIntTrim:oBrw:aCols[7]:cFooter      :=TRAN(nInteres,"999,999,999.99")

   oFrmIntTrim:oBrw:aCols[8]:cHeader:="Capital"
   oFrmIntTrim:oBrw:aCols[8]:nWidth :=120
   oFrmIntTrim:oBrw:aCols[8]:nDataStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[8]:nHeadStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[8]:nFootStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[8]:cEditPicture := "999,999,999.99"
   oFrmIntTrim:oBrw:aCols[8]:bStrData     :={||oBrw:=oFrmIntTrim:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,8],"999,999,999.99")}
   oFrmIntTrim:oBrw:aCols[8]:cFooter      :=TRAN(aData[Len(aData),8],"999,999,999.99")


   oFrmIntTrim:oBrw:aCols[9]:cHeader:="Interés"+CRLF+"Acumulado"
   oFrmIntTrim:oBrw:aCols[9]:nWidth :=110
   oFrmIntTrim:oBrw:aCols[9]:nDataStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[9]:nHeadStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[9]:nFootStrAlign:= AL_RIGHT
   oFrmIntTrim:oBrw:aCols[9]:cEditPicture := "999,999,999.99"
   oFrmIntTrim:oBrw:aCols[9]:bStrData     :={||oBrw:=oFrmIntTrim:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,9],"999,999,999.99")}


   oFrmIntTrim:oBrw:bClrStd := {|oBrw,nClrText,aData|oBrw:=oFrmIntTrim:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                             nClrText:=0,;
                             nClrText:=IIF(aData[3]>0,CLR_BLACK,nClrText),;
                             nClrText:=IIF(aData[3]<0,CLR_HRED ,nClrText),;
                             {nClrText,iif( oBrw:nArrayAt%2=0, oFrmIntTrim:nClrPane1, oFrmIntTrim:nClrPane2 ) } }
/*
  oBrw:bClrStd   :={|oBrw,nSaldo,nClrText|oBrw:=oTrabPres:oBrw,nSaldo:=oBrw:aArrayData[oBrw:nArrayAt,6],;
                               nClrText:=0,;
                               nClrText:=IIF(nSaldo=0,CLR_HBLUE,nClrText),;
                               nClrText:=IIF(nSaldo>0,CLR_HRED ,nClrText),;
                               {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }
*/


   oFrmIntTrim:oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oFrmIntTrim:oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oFrmIntTrim:oBrw:CreateFromCode()
   oFrmIntTrim:bValid   :={|| EJECUTAR("BRWSAVEPAR",oFrmIntTrim)}
   oFrmIntTrim:BRWRESTOREPAR()

   oFrmIntTrim:oWnd:oClient := oFrmIntTrim:oBrw

   oFrmIntTrim:Activate({||oFrmIntTrim:ViewDatBar(oFrmIntTrim)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oFrmIntTrim)
   LOCAL oCursor,oBar,oBtn,oFont,oFontB,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmIntTrim:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oFrmIntTrim:IMPRIMIR(oFrmIntTrim:cCodTra))

   oBtn:cToolTip:="Imprimir Intereses"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oFrmIntTrim:oBrw,oFrmIntTrim:cTitle,oFrmIntTrim:cTrabajad))

   oBtn:cToolTip:="Exportar hacia Excel"

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oFrmIntTrim:HTMLHEAD(),EJECUTAR("BRWTOHTML",oFrmIntTrim:oBrw,NIL,oFrmIntTrim:cTitle,oFrmIntTrim:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oFrmIntTrim:oBtnHtml:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\INTERESPAGO.BMP";
          ACTION (EJECUTAR("NMPAGOINT",oFrmIntTrim:cCodTra))

   oBtn:cToolTip:="Intereses Pagados"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\antiguedadanticipada.BMP";
          ACTION (EJECUTAR("NMANTPRES",oFrmIntTrim:cCodTra))

   oBtn:cToolTip:="Pagos Anticipados de Antiguedad"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oFrmIntTrim:oBrw:GoTop(),oFrmIntTrim:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oFrmIntTrim:oBrw:PageDown(),oFrmIntTrim:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oFrmIntTrim:oBrw:PageUp(),oFrmIntTrim:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oFrmIntTrim:oBrw:GoBottom(),oFrmIntTrim:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFrmIntTrim:Close()

  oFrmIntTrim:oBrw:SetColor(0,oFrmIntTrim:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,60+5 SAY oFrmIntTrim:cTrabajad OF oBar BORDER SIZE 335,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontB
  @ 1.4,60+5 SAY oFrmIntTrim:cConcepto OF oBar BORDER SIZE 335,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontB


//@ 1.4,90 SAY "Base "+LSTR(oDp:nBaseAnual)+" "+IF( oDp:lIndexaInt,"Indexado","Simple ");
//         OF oBar BORDER SIZE 40,18

 

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodTra)
  LOCAL aData:={oDp:cCodTraIni,oDp:cCodTraFin}
  oDp:cCodTraIni:=cCodTra
  oDp:cCodTraFin:=cCodTra
  REPORTE("NMINTERESE")
  oDp:cCodTraIni:=aData[1]
  oDp:cCodTraFin:=aData[2]
RETURN .T.

FUNCTION HTMLHEAD()

   oFrmIntTrim:aHead:=EJECUTAR("HTMLHEAD",oFrmIntTrim)

RETURN


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oFrmIntTrim)
// EOF
