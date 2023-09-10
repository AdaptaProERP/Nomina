// Programa   : NMRECVIEW
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Visualizar Recibo
// Creado Por : Juan Navas
// Llamado por: NMTRABJCON
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cNumRec,cCodSuc)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nMonto:=0,cCodTra,cPeriodo
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )
  
  DEFAULT cNumRec:=SQLGET("NMRECIBOS","REC_CODTRA"),;
          cCodSuc:=oDp:cSucursal

  IF Type("oRecView")="O" .AND. oRecView:oWnd:hWnd>0
     RETURN EJECUTAR("BRRUNNEW",oRecView,GetScript())
  ENDIF

  cSql:="SELECT HIS_CODCON,CON_DESCRI,CON_REPRES,HIS_VARIAC,HIS_MONTO,HIS_NUMMEM,HIS_NUMOBS FROM NMHISTORICO "+;
        "INNER JOIN NMCONCEPTOS ON HIS_CODCON=CON_CODIGO WHERE HIS_CODSUC"+GetWhere("=",cCodSuc)+" AND HIS_NUMREC"+GetWhere("=",cNumRec)
        
  oTable:=OpenTable(cSql,.T.)
//oTable:Browse()

  aData:=ACLONE(oTable:aDataFill)

  AEVAL(aData,{|a,n,n1|n1:=0,;
                    n1:=IIF(Left(a[1],1)="A", 1,n1),;
                    n1:=IIF(Left(a[1],1)="D", 1,n1),;
                    nMonto:=nMonto+(a[5]*n1)})

  cPictureV:=oTable:GetPicture("HIS_VARIAC",.T.)
  cPictureM:=oTable:GetPicture("HIS_MONTO",.T.)

  oTable:End()

  oTable  :=OpenTable("SELECT FCH_TIPNOM,FCH_OTRNOM,REC_CODTRA,FCH_DESDE,FCH_HASTA FROM NMRECIBOS "+;
                      "LEFT JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
                      "WHERE REC_NUMERO"+GetWhere("=",cNumRec),.T.)

  cCodTra :=oTable:REC_CODTRA

// ? CLPCOPY(oDp:cSql)

  cPeriodo:="Nómina : ["+oTable:FCH_TIPNOM+"/"+oTable:FCH_OTRNOM+"]  "+DTOC(oTable:FCH_DESDE)+"-"+DTOC(oTable:FCH_HASTA)
  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Recibo "+cNumRec+" No posee Registros en el Histórico de Pagos")
     RETURN .T.
  ENDIF

  cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))

//  oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
//  cNombre:=ALLTRIM(cCodTra)+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
//  oTable:End()

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//  oRecView:=DPEDIT():New("Recibo de Pago : "+cNumRec,"NMRECVIEW.edt","oRecView",.T.)

  DpMdi("Recibo de Pago : "+cNumRec,"oRecView","NMRECVIEW.edt")
  oRecView:Windows(0,0,oDp:aCoors[3]-160,MIN(1030,oDp:aCoors[4]-10),.T.) // Maximizado

  oRecView:cCodTra  :=cCodTra
  oRecView:cPictureV:=cPictureV
  oRecView:cPictureM:=cPictureM
  oRecView:cPeriodo :=cPeriodo
  oRecView:cRecibo  :=cNumRec
  oRecView:cTrabajad:=cNombre

  oRecView:nClrPane1:=oDp:nClrPane1
  oRecView:nClrPane2:=oDp:nClrPane2

  oRecView:nClrText1:=CLR_HBLUE
  oRecView:nClrText2:=CLR_HRED

  oDlg:=oRecView:oDlg

  oBrw:=TXBrowse():New( oRecView:oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .T. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  

  oBrw:aCols[1]:cHeader:="Código"
  oBrw:aCols[1]:nWidth :=70

  oBrw:aCols[2]:cHeader:="Descripción"
  oBrw:aCols[2]:nWidth :=280

  oBrw:aCols[3]:cHeader:="Repres."
  oBrw:aCols[3]:nWidth :=90

  oBrw:aCols[4]:cHeader:="Variación"
  oBrw:aCols[4]:nWidth :=125
  oBrw:aCols[4]:cPicture:=cPictureV   
  oBrw:aCols[4]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[4]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[4]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oRecView:cPictureV)}

  oBrw:aCols[5]:cHeader :="Monto"
  oBrw:aCols[5]:nWidth  :=150
  oBrw:aCols[5]:cPicture:=cPictureM
  oBrw:aCols[5]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[5]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[5]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[5]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oRecView:cPictureM)}
  oBrw:aCols[5]:cFooter       := TRAN(nMonto,cPictureM)

//  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oRecView:oBrw,cCod:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                               cCod:=Left(cCod,1),;
                               nClrText:=0,;
                               nClrText:=IIF(cCod="A",oRecView:nClrText1,nClrText),;
                               nClrText:=IIF(cCod="D",oRecView:nClrText2,nClrText),;
                               {nClrText, iif( oBrw:nArrayAt%2=0, oRecView:nClrPane1, oRecView:nClrPane2 ) } }

  oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oRecView:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                     oRecView:RECIMPRIME(oRecView)}

  oBrw:SetFont(oFont)

  oBrw:aCols[6]:Hide()
  oBrw:aCols[7]:Hide()

  oRecView:oBrw:=oBrw

  oRecView:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oRecView:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oRecView:oBrw:CreateFromCode()
    oRecView:bValid   :={|| EJECUTAR("BRWSAVEPAR",oRecView)}
    oRecView:BRWRESTOREPAR()

  oRecView:oWnd:oClient := oRecView:oBrw

  oRecView:Activate({||oRecView:LeyBar(oRecView)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oRecView)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oRecView:oDlg

   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION EVAL(oRecView:oBrw:bLDblClick)

  oBtn:cToolTip:="Imprimir Recibo"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\EXCEL.BMP";
         ACTION (EJECUTAR("BRWTOEXCEL",oRecView:oBrw,oRecView:cTitle,oRecView:cTrabajad))

  oBtn:cToolTip:="Exportar Hacia Excel"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XMEMO2.BMP";
          ACTION oRecView:VIEWMEMO(oRecView)

  oBtn:cToolTip:="Visualizar Memo del Concepto"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EMAIL.BMP",NIL,"BITMAPS\EMAILG.BMP";
          ACTION oRecView:ENVIARMAIL();
          WHEN ISRELEASE("18.04")

  oBtn:cToolTip:="Enviar Recibo por Correo"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\HTML.BMP",NIL,"BITMAPS\HTMLG.BMP";
          ACTION EJECUTAR("HTMNMRECIBO",oRecView:cRecibo);
          WHEN ISRELEASE("18.04")

  oBtn:cToolTip:="Generar Recibo en Formato HTML"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oRecView:oBrw:GoTop(),oRecView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oRecView:oBrw:PageDown(),oRecView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oRecView:oBrw:PageUp(),oRecView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oRecView:oBrw:GoBottom(),oRecView:oBrw:Setfocus())


   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRecView:Close()

  oRecView:oBrw:SetColor(0,oDp:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


  
  @ 0.1,70 SAY " "+ALLTRIM(oRecView:cCodTra)+" "+oRecView:cTrabajad OF oBar;
           BORDER SIZE 345,18;
           FONT oFontB COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  @ 1.4,70 SAY " "+oRecView:cPeriodo  OF oBar BORDER SIZE 345,18;
           FONT oFontB COLOR oDp:nClrLabelText,oDp:nClrLabelPane

RETURN .T.

FUNCTION RECIMPRIME(oRecView)
  LOCAL aVar:={}
  LOCAL oBrw :=oRecView:oBrw
  LOCAL aData:=oBrw:aArrayData[oBrw:nArrayAt]

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
  oDp:cRecIni   :=oRecView:cRecibo
  oDp:cRecFin   :=oRecView:cRecibo

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


/*
// Visualizar Campo Memo
*/
FUNCTION VIEWMEMO(oRecView)
   LOCAL oBrw :=oRecView:oBrw,oTable
   LOCAL aData:=oBrw:aArrayData[oBrw:nArrayAt]
   LOCAL cMemo:="",cObserv:=""

   IF aData[6]>0
     cMemo:=ALLTRIM(SQLGET("NMMEMO","MEM_MEMO","MEM_NUMERO"+GetWhere("=",aData[6])))
   ENDIF

   IF aData[7]>0
     cObserv:=ALLTRIM(SQLGET("NMOBSERV","OBS_OBSERV","OBS_NUMERO"+GetWhere("=",aData[7])))
   ENDIF

//   ? cMemo,aData[6],aData[7]
//   oTable:=OpenTable("SELECT MEM_MEMO FROM NMMEMO WHERE MEM_NUMERO"+GetWhere("=",aData[6]),.T.)
//   cMemo:=ALLTRIM(oTable:MEM_MEMO)
//   oTable:End()

   oRecViewM:=DPEDIT():New("Memo del Concepto","NMHISDETM.edt","oRecViewM",.T.)

   oRecViewM:cMemo    :=cMemo
   oRecViewM:cRecibo  :=oRecView:cRecibo
   oRecViewM:cTrabajad:=oRecView:cTrabajad
   oRecViewM:cConcepto:=aData[1]+" "+aData[2]
   oRecViewM:cObserv  :=cObserv

   @ 0,0 SAY "Recibo:"     RIGHT
   @ 1,0 SAY "Trabajador:" RIGHT
   @ 2,0 SAY "Concepto:"   RIGHT

   @ 0,20 SAY oRecViewM:cRecibo   BORDER
   @ 1,20 SAY oRecViewM:cTrabajad BORDER
   @ 2,20 SAY oRecViewM:cConcepto BORDER

   @ 3,0 SAY "Observación:"     RIGHT
   @ 3,20 SAY oRecViewM:cObserv BORDER

   @ 4,0 GET oRecViewM:cMemo MULTILINE READONLY OF oRecViewM:oDlg SIZE 100,100

   @6, 16 SBUTTON oRecViewM:oBtn ;
          SIZE 50, 50 ;
          FILE "BITMAPS\XSALIR.BMP" ;
          LEFT PROMPT "Cerrar" NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 3 };
          ACTION (oRecViewM:Close())

   oRecViewM:Activate()

RETURN .T.

FUNCTION ENVIARMAIL()
  LOCAL cMemo:=""
  LOCAL cFile:="TEMP\"+LSTR(SECONDS())+".HTML"

  EJECUTAR("HTMNMRECIBO",oRecView:cRecibo,cFile,.F.)
  cMemo:=MemoRead(cFile)

//? cMemo,"cMemo"

  EJECUTAR("NMBLAT",oRecView:cCodTra,"Recibo de Pago "+oRecView:cRecibo ,cMemo)

  oBlat:oText:VarPut(cMemo,.T.)

  AEVAL(oBlat:oBar:aControls,{|o,n|o:ForWhen(.T.)})

RETURN NIL
//
FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oRecView)
// EOF
