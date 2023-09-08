// Programa   : BRHISCONXTRAB
// Fecha/Hora : 14/01/2022 10:14:14
// Propósito  : "Histórico de Conceptos de Pago"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRHISCONXTRAB.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oHISCONXTRAB")="O" .AND. oHISCONXTRAB:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oHISCONXTRAB,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Histórico de Conceptos de Pago" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oHISCONXTRAB

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oHISCONXTRAB","BRHISCONXTRAB.EDT")
// oHISCONXTRAB:CreateWindow(0,0,100,550)
   oHISCONXTRAB:Windows(0,0,aCoors[3]-160,MIN(740,aCoors[4]-10),.T.) // Maximizado



   oHISCONXTRAB:cCodSuc  :=cCodSuc
   oHISCONXTRAB:lMsgBar  :=.F.
   oHISCONXTRAB:cPeriodo :=aPeriodos[nPeriodo]
   oHISCONXTRAB:cCodSuc  :=cCodSuc
   oHISCONXTRAB:nPeriodo :=nPeriodo
   oHISCONXTRAB:cNombre  :=""
   oHISCONXTRAB:dDesde   :=dDesde
   oHISCONXTRAB:cServer  :=cServer
   oHISCONXTRAB:dHasta   :=dHasta
   oHISCONXTRAB:cWhere   :=cWhere
   oHISCONXTRAB:cWhere_  :=cWhere_
   oHISCONXTRAB:cWhereQry:=""
   oHISCONXTRAB:cSql     :=oDp:cSql
   oHISCONXTRAB:oWhere   :=TWHERE():New(oHISCONXTRAB)
   oHISCONXTRAB:cCodPar  :=cCodPar // Código del Parámetro
   oHISCONXTRAB:lWhen    :=.T.
   oHISCONXTRAB:cTextTit :="" // Texto del Titulo Heredado
   oHISCONXTRAB:oDb      :=oDp:oDb
   oHISCONXTRAB:cBrwCod  :="HISCONXTRAB"
   oHISCONXTRAB:lTmdi    :=.T.
   oHISCONXTRAB:aHead    :={}
   oHISCONXTRAB:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oHISCONXTRAB:bValid   :={|| EJECUTAR("BRWSAVEPAR",oHISCONXTRAB)}

   oHISCONXTRAB:lBtnRun     :=.F.
   oHISCONXTRAB:lBtnMenuBrw :=.F.
   oHISCONXTRAB:lBtnSave    :=.F.
   oHISCONXTRAB:lBtnCrystal :=.F.
   oHISCONXTRAB:lBtnRefresh :=.F.
   oHISCONXTRAB:lBtnHtml    :=.T.
   oHISCONXTRAB:lBtnExcel   :=.T.
   oHISCONXTRAB:lBtnPreview :=.T.
   oHISCONXTRAB:lBtnQuery   :=.F.
   oHISCONXTRAB:lBtnOptions :=.T.
   oHISCONXTRAB:lBtnPageDown:=.T.
   oHISCONXTRAB:lBtnPageUp  :=.T.
   oHISCONXTRAB:lBtnFilters :=.T.
   oHISCONXTRAB:lBtnFind    :=.T.

   oHISCONXTRAB:nClrPane1:=16775408
   oHISCONXTRAB:nClrPane2:=16771797

   oHISCONXTRAB:nClrText :=0
   oHISCONXTRAB:nClrText1:=0
   oHISCONXTRAB:nClrText2:=0
   oHISCONXTRAB:nClrText3:=0




   oHISCONXTRAB:oBrw:=TXBrowse():New( IF(oHISCONXTRAB:lTmdi,oHISCONXTRAB:oWnd,oHISCONXTRAB:oDlg ))
   oHISCONXTRAB:oBrw:SetArray( aData, .F. )
   oHISCONXTRAB:oBrw:SetFont(oFont)

   oHISCONXTRAB:oBrw:lFooter     := .T.
   oHISCONXTRAB:oBrw:lHScroll    := .F.
   oHISCONXTRAB:oBrw:nHeaderLines:= 2
   oHISCONXTRAB:oBrw:nDataLines  := 1
   oHISCONXTRAB:oBrw:nFooterLines:= 1




   oHISCONXTRAB:aData            :=ACLONE(aData)

   AEVAL(oHISCONXTRAB:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: FCH_NUMERO
  oCol:=oHISCONXTRAB:oBrw:aCols[1]
  oCol:cHeader      :='Número'+CRLF+'Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISCONXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: FCH_DESDE
  oCol:=oHISCONXTRAB:oBrw:aCols[2]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISCONXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: FCH_HASTA
  oCol:=oHISCONXTRAB:oBrw:aCols[3]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISCONXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: REC_NUMERO
  oCol:=oHISCONXTRAB:oBrw:aCols[4]
  oCol:cHeader      :='Número'+CRLF+'Recibo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISCONXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 56

  // Campo: NOMBRE
  oCol:=oHISCONXTRAB:oBrw:aCols[5]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISCONXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 408

  // Campo: HIS_MONTO
  oCol:=oHISCONXTRAB:oBrw:aCols[6]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISCONXTRAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 96
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oHISCONXTRAB:oBrw:aArrayData[oHISCONXTRAB:oBrw:nArrayAt,6],;
                              oCol  := oHISCONXTRAB:oBrw:aCols[6],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[6],oCol:cEditPicture)


   oHISCONXTRAB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oHISCONXTRAB:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oHISCONXTRAB:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oHISCONXTRAB:nClrText,;
                                                 nClrText:=IF(.F.,oHISCONXTRAB:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oHISCONXTRAB:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oHISCONXTRAB:nClrPane1, oHISCONXTRAB:nClrPane2 ) } }

//   oHISCONXTRAB:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oHISCONXTRAB:oBrw:bClrFooter            := {|| {0,14671839 }}

   oHISCONXTRAB:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oHISCONXTRAB:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oHISCONXTRAB:oBrw:bLDblClick:={|oBrw|oHISCONXTRAB:RUNCLICK() }

   oHISCONXTRAB:oBrw:bChange:={||oHISCONXTRAB:BRWCHANGE()}
   oHISCONXTRAB:oBrw:CreateFromCode()


   oHISCONXTRAB:oWnd:oClient := oHISCONXTRAB:oBrw



   oHISCONXTRAB:Activate({||oHISCONXTRAB:ViewDatBar()})

   oHISCONXTRAB:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oHISCONXTRAB:lTmdi,oHISCONXTRAB:oWnd,oHISCONXTRAB:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oHISCONXTRAB:oBrw:nWidth()

   oHISCONXTRAB:oBrw:GoBottom(.T.)
   oHISCONXTRAB:oBrw:Refresh(.T.)

   IF !File("FORMS\BRHISCONXTRAB.EDT")
     oHISCONXTRAB:oBrw:Move(44,0,740+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oHISCONXTRAB:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oHISCONXTRAB:oBrw,oHISCONXTRAB:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oHISCONXTRAB:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","HISCONXTRAB")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","HISCONXTRAB"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oHISCONXTRAB:oBrw,"HISCONXTRAB",oHISCONXTRAB:cSql,oHISCONXTRAB:nPeriodo,oHISCONXTRAB:dDesde,oHISCONXTRAB:dHasta,oHISCONXTRAB)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oHISCONXTRAB:oBtnRun:=oBtn



       oHISCONXTRAB:oBrw:bLDblClick:={||EVAL(oHISCONXTRAB:oBtnRun:bAction) }


   ENDIF




IF oHISCONXTRAB:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oHISCONXTRAB");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oHISCONXTRAB:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oHISCONXTRAB:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oHISCONXTRAB:oBrw,oHISCONXTRAB:oFrm)
ENDIF

IF oHISCONXTRAB:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oHISCONXTRAB),;
                  EJECUTAR("DPBRWMENURUN",oHISCONXTRAB,oHISCONXTRAB:oBrw,oHISCONXTRAB:cBrwCod,oHISCONXTRAB:cTitle,oHISCONXTRAB:aHead));
          WHEN !Empty(oHISCONXTRAB:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oHISCONXTRAB:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oHISCONXTRAB:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oHISCONXTRAB:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oHISCONXTRAB:oBrw,oHISCONXTRAB);
          ACTION EJECUTAR("BRWSETFILTER",oHISCONXTRAB:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oHISCONXTRAB:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oHISCONXTRAB:oBrw);
          WHEN LEN(oHISCONXTRAB:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oHISCONXTRAB:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oHISCONXTRAB:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oHISCONXTRAB:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oHISCONXTRAB)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oHISCONXTRAB:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oHISCONXTRAB:oBrw,oHISCONXTRAB:cTitle,oHISCONXTRAB:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oHISCONXTRAB:oBtnXls:=oBtn

ENDIF

IF oHISCONXTRAB:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oHISCONXTRAB:HTMLHEAD(),EJECUTAR("BRWTOHTML",oHISCONXTRAB:oBrw,NIL,oHISCONXTRAB:cTitle,oHISCONXTRAB:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oHISCONXTRAB:oBtnHtml:=oBtn

ENDIF


IF oHISCONXTRAB:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oHISCONXTRAB:oBrw))

   oBtn:cToolTip:="Previsualización"

   oHISCONXTRAB:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRHISCONXTRAB")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oHISCONXTRAB:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oHISCONXTRAB:oBtnPrint:=oBtn

   ENDIF

IF oHISCONXTRAB:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oHISCONXTRAB:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oHISCONXTRAB:oBrw:GoTop(),oHISCONXTRAB:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oHISCONXTRAB:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oHISCONXTRAB:oBrw:PageDown(),oHISCONXTRAB:oBrw:Setfocus())
  ENDIF

  IF  oHISCONXTRAB:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oHISCONXTRAB:oBrw:PageUp(),oHISCONXTRAB:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oHISCONXTRAB:oBrw:GoBottom(),oHISCONXTRAB:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oHISCONXTRAB:Close()

  oHISCONXTRAB:oBrw:SetColor(0,oHISCONXTRAB:nClrPane1)

  oHISCONXTRAB:SETBTNBAR(40,40,oBar)


  EVAL(oHISCONXTRAB:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oHISCONXTRAB:oBar:=oBar

    nCol:=380
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oHISCONXTRAB:oPeriodo  VAR oHISCONXTRAB:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oHISCONXTRAB:LEEFECHAS();
                WHEN oHISCONXTRAB:lWhen


  ComboIni(oHISCONXTRAB:oPeriodo )

  @ nLin, nCol+103 BUTTON oHISCONXTRAB:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oHISCONXTRAB:oPeriodo:nAt,oHISCONXTRAB:oDesde,oHISCONXTRAB:oHasta,-1),;
                         EVAL(oHISCONXTRAB:oBtn:bAction));
                WHEN oHISCONXTRAB:lWhen


  @ nLin, nCol+130 BUTTON oHISCONXTRAB:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oHISCONXTRAB:oPeriodo:nAt,oHISCONXTRAB:oDesde,oHISCONXTRAB:oHasta,+1),;
                         EVAL(oHISCONXTRAB:oBtn:bAction));
                WHEN oHISCONXTRAB:lWhen


  @ nLin, nCol+160 BMPGET oHISCONXTRAB:oDesde  VAR oHISCONXTRAB:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oHISCONXTRAB:oDesde ,oHISCONXTRAB:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oHISCONXTRAB:oPeriodo:nAt=LEN(oHISCONXTRAB:oPeriodo:aItems) .AND. oHISCONXTRAB:lWhen ;
                FONT oFont

   oHISCONXTRAB:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oHISCONXTRAB:oHasta  VAR oHISCONXTRAB:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oHISCONXTRAB:oHasta,oHISCONXTRAB:dHasta);
                SIZE 76-2,24;
                WHEN oHISCONXTRAB:oPeriodo:nAt=LEN(oHISCONXTRAB:oPeriodo:aItems) .AND. oHISCONXTRAB:lWhen ;
                OF oBar;
                FONT oFont

   oHISCONXTRAB:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oHISCONXTRAB:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oHISCONXTRAB:oPeriodo:nAt=LEN(oHISCONXTRAB:oPeriodo:aItems);
               ACTION oHISCONXTRAB:HACERWHERE(oHISCONXTRAB:dDesde,oHISCONXTRAB:dHasta,oHISCONXTRAB:cWhere,.T.);
               WHEN oHISCONXTRAB:lWhen

  BMPGETBTN(oBar,oFont,13)

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})



RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRHISCONXTRAB",cWhere)
  oRep:cSql  :=oHISCONXTRAB:cSql
  oRep:cTitle:=oHISCONXTRAB:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oHISCONXTRAB:oPeriodo:nAt,cWhere

  oHISCONXTRAB:nPeriodo:=nPeriodo


  IF oHISCONXTRAB:oPeriodo:nAt=LEN(oHISCONXTRAB:oPeriodo:aItems)

     oHISCONXTRAB:oDesde:ForWhen(.T.)
     oHISCONXTRAB:oHasta:ForWhen(.T.)
     oHISCONXTRAB:oBtn  :ForWhen(.T.)

     DPFOCUS(oHISCONXTRAB:oDesde)

  ELSE

     oHISCONXTRAB:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oHISCONXTRAB:oDesde:VarPut(oHISCONXTRAB:aFechas[1] , .T. )
     oHISCONXTRAB:oHasta:VarPut(oHISCONXTRAB:aFechas[2] , .T. )

     oHISCONXTRAB:dDesde:=oHISCONXTRAB:aFechas[1]
     oHISCONXTRAB:dHasta:=oHISCONXTRAB:aFechas[2]

     cWhere:=oHISCONXTRAB:HACERWHERE(oHISCONXTRAB:dDesde,oHISCONXTRAB:dHasta,oHISCONXTRAB:cWhere,.T.)

     oHISCONXTRAB:LEERDATA(cWhere,oHISCONXTRAB:oBrw,oHISCONXTRAB:cServer,oHISCONXTRAB)

  ENDIF

  oHISCONXTRAB:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "NMFECHAS.FCH_HASTA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('NMFECHAS.FCH_HASTA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('NMFECHAS.FCH_HASTA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oHISCONXTRAB:cWhereQry)
       cWhere:=cWhere + oHISCONXTRAB:cWhereQry
     ENDIF

     oHISCONXTRAB:LEERDATA(cWhere,oHISCONXTRAB:oBrw,oHISCONXTRAB:cServer,oHISCONXTRAB)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oHISCONXTRAB)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT  "+;
          "   FCH_NUMERO, "+;
          "   FCH_DESDE, "+;
          "   FCH_HASTA,  "+;
          "   REC_NUMERO, "+;
          "   CONCAT(NOMBRE,',',APELLIDO) AS NOMBRE, "+;
          "   HIS_MONTO "+;
          "   FROM NMRECIBOS   "+;
          "   INNER JOIN NMTRABAJADOR    ON REC_CODTRA=CODIGO   "+;
          "   INNER JOIN NMHISTORICO     ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC   "+;
          "   INNER JOIN NMFECHAS        ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO   "+;
          "   INNER JOIN NMCONCEPTOS     ON HIS_CODCON=CON_CODIGO"+;
""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRHISCONXTRAB.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'',CTOD(""),CTOD(""),'','',0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oHISCONXTRAB:cSql   :=cSql
      oHISCONXTRAB:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oHISCONXTRAB:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oHISCONXTRAB:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRHISCONXTRAB.MEM",V_nPeriodo:=oHISCONXTRAB:nPeriodo
  LOCAL V_dDesde:=oHISCONXTRAB:dDesde
  LOCAL V_dHasta:=oHISCONXTRAB:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oHISCONXTRAB)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oHISCONXTRAB")="O" .AND. oHISCONXTRAB:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oHISCONXTRAB:cWhere_),oHISCONXTRAB:cWhere_,oHISCONXTRAB:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oHISCONXTRAB:LEERDATA(oHISCONXTRAB:cWhere_,oHISCONXTRAB:oBrw,oHISCONXTRAB:cServer)
      oHISCONXTRAB:oWnd:Show()
      oHISCONXTRAB:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oHISCONXTRAB:aHead:=EJECUTAR("HTMLHEAD",oHISCONXTRAB)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oHISCONXTRAB)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

