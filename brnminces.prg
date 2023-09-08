// Programa   : BRNMINCES
// Fecha/Hora : 26/01/2022 10:41:55
// Propósito  : "Retencion y Aporte Patronal INCES"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMINCES.MEM",V_nPeriodo:=5,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oNMINCES")="O" .AND. oNMINCES:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oNMINCES,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Retencion y Aporte Patronal INCES" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oNMINCES

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oNMINCES","BRNMINCES.EDT")
// oNMINCES:CreateWindow(0,0,100,550)
   oNMINCES:Windows(0,0,aCoors[3]-160,MIN(1044,aCoors[4]-10),.T.) // Maximizado



   oNMINCES:cCodSuc  :=cCodSuc
   oNMINCES:lMsgBar  :=.F.
   oNMINCES:cPeriodo :=aPeriodos[nPeriodo]
   oNMINCES:cCodSuc  :=cCodSuc
   oNMINCES:nPeriodo :=nPeriodo
   oNMINCES:cNombre  :=""
   oNMINCES:dDesde   :=dDesde
   oNMINCES:cServer  :=cServer
   oNMINCES:dHasta   :=dHasta
   oNMINCES:cWhere   :=cWhere
   oNMINCES:cWhere_  :=cWhere_
   oNMINCES:cWhereQry:=""
   oNMINCES:cSql     :=oDp:cSql
   oNMINCES:oWhere   :=TWHERE():New(oNMINCES)
   oNMINCES:cCodPar  :=cCodPar // Código del Parámetro
   oNMINCES:lWhen    :=.T.
   oNMINCES:cTextTit :="" // Texto del Titulo Heredado
   oNMINCES:oDb      :=oDp:oDb
   oNMINCES:cBrwCod  :="NMINCES"
   oNMINCES:lTmdi    :=.T.
   oNMINCES:aHead    :={}
   oNMINCES:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oNMINCES:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMINCES)}

   oNMINCES:lBtnRun     :=.F.
   oNMINCES:lBtnMenuBrw :=.F.
   oNMINCES:lBtnSave    :=.F.
   oNMINCES:lBtnCrystal :=.F.
   oNMINCES:lBtnRefresh :=.F.
   oNMINCES:lBtnHtml    :=.T.
   oNMINCES:lBtnExcel   :=.T.
   oNMINCES:lBtnPreview :=.T.
   oNMINCES:lBtnQuery   :=.F.
   oNMINCES:lBtnOptions :=.T.
   oNMINCES:lBtnPageDown:=.T.
   oNMINCES:lBtnPageUp  :=.T.
   oNMINCES:lBtnFilters :=.T.
   oNMINCES:lBtnFind    :=.T.

   oNMINCES:nClrPane1:=16775408
   oNMINCES:nClrPane2:=16771797

   oNMINCES:nClrText :=0
   oNMINCES:nClrText1:=0
   oNMINCES:nClrText2:=0
   oNMINCES:nClrText3:=0




   oNMINCES:oBrw:=TXBrowse():New( IF(oNMINCES:lTmdi,oNMINCES:oWnd,oNMINCES:oDlg ))
   oNMINCES:oBrw:SetArray( aData, .F. )
   oNMINCES:oBrw:SetFont(oFont)

   oNMINCES:oBrw:lFooter     := .T.
   oNMINCES:oBrw:lHScroll    := .F.
   oNMINCES:oBrw:nHeaderLines:= 2
   oNMINCES:oBrw:nDataLines  := 1
   oNMINCES:oBrw:nFooterLines:= 1




   oNMINCES:aData            :=ACLONE(aData)

   AEVAL(oNMINCES:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: REC_CODTRA
  oCol:=oNMINCES:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMINCES:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: CONCAT(APELLIDO,',',NOMBRE)
  oCol:=oNMINCES:oBrw:aCols[2]
  oCol:cHeader      :='Apellido y Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMINCES:oBrw:aArrayData ) } 
  oCol:nWidth       := 350

  // Campo: D006
  oCol:=oNMINCES:oBrw:aCols[3]
  oCol:cHeader      :='Retención'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMINCES:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMINCES:oBrw:aArrayData[oNMINCES:oBrw:nArrayAt,3],;
                              oCol  := oNMINCES:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)


  // Campo: H002
  oCol:=oNMINCES:oBrw:aCols[4]
  oCol:cHeader      :='Aporte'+CRLF+'Patronal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMINCES:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMINCES:oBrw:aArrayData[oNMINCES:oBrw:nArrayAt,4],;
                              oCol  := oNMINCES:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)


  // Campo: MAX(FCH_DESDE)
  oCol:=oNMINCES:oBrw:aCols[5]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMINCES:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: MAX(FCH_HASTA)
  oCol:=oNMINCES:oBrw:aCols[6]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMINCES:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: CUANTOS
  oCol:=oNMINCES:oBrw:aCols[7]
  oCol:cHeader      :='Cant.'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMINCES:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMINCES:oBrw:aArrayData[oNMINCES:oBrw:nArrayAt,7],;
                              oCol  := oNMINCES:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


   oNMINCES:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMINCES:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oNMINCES:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oNMINCES:nClrText,;
                                                 nClrText:=IF(.F.,oNMINCES:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oNMINCES:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oNMINCES:nClrPane1, oNMINCES:nClrPane2 ) } }

//   oNMINCES:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oNMINCES:oBrw:bClrFooter            := {|| {0,14671839 }}

   oNMINCES:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMINCES:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oNMINCES:oBrw:bLDblClick:={|oBrw|oNMINCES:RUNCLICK() }

   oNMINCES:oBrw:bChange:={||oNMINCES:BRWCHANGE()}
   oNMINCES:oBrw:CreateFromCode()


   oNMINCES:oWnd:oClient := oNMINCES:oBrw



   oNMINCES:Activate({||oNMINCES:ViewDatBar()})

   oNMINCES:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMINCES:lTmdi,oNMINCES:oWnd,oNMINCES:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oNMINCES:oBrw:nWidth()

   oNMINCES:oBrw:GoBottom(.T.)
   oNMINCES:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMINCES.EDT")
     oNMINCES:oBrw:Move(44,0,1044+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oNMINCES:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMINCES:oBrw,oNMINCES:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oNMINCES:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMINCES")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMINCES"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMINCES:oBrw,"NMINCES",oNMINCES:cSql,oNMINCES:nPeriodo,oNMINCES:dDesde,oNMINCES:dHasta,oNMINCES)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMINCES:oBtnRun:=oBtn



       oNMINCES:oBrw:bLDblClick:={||EVAL(oNMINCES:oBtnRun:bAction) }


   ENDIF




IF oNMINCES:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oNMINCES");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oNMINCES:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oNMINCES:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oNMINCES:oBrw,oNMINCES:oFrm)
ENDIF

IF oNMINCES:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oNMINCES),;
                  EJECUTAR("DPBRWMENURUN",oNMINCES,oNMINCES:oBrw,oNMINCES:cBrwCod,oNMINCES:cTitle,oNMINCES:aHead));
          WHEN !Empty(oNMINCES:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oNMINCES:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMINCES:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oNMINCES:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oNMINCES:oBrw,oNMINCES);
          ACTION EJECUTAR("BRWSETFILTER",oNMINCES:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oNMINCES:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMINCES:oBrw);
          WHEN LEN(oNMINCES:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oNMINCES:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMINCES:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oNMINCES:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMINCES)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oNMINCES:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMINCES:oBrw,oNMINCES:cTitle,oNMINCES:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMINCES:oBtnXls:=oBtn

ENDIF

IF oNMINCES:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oNMINCES:HTMLHEAD(),EJECUTAR("BRWTOHTML",oNMINCES:oBrw,NIL,oNMINCES:cTitle,oNMINCES:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oNMINCES:oBtnHtml:=oBtn

ENDIF


IF oNMINCES:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMINCES:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMINCES:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMINCES")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMINCES:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMINCES:oBtnPrint:=oBtn

   ENDIF

IF oNMINCES:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMINCES:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMINCES:oBrw:GoTop(),oNMINCES:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oNMINCES:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oNMINCES:oBrw:PageDown(),oNMINCES:oBrw:Setfocus())
  ENDIF

  IF  oNMINCES:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oNMINCES:oBrw:PageUp(),oNMINCES:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMINCES:oBrw:GoBottom(),oNMINCES:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMINCES:Close()

  oNMINCES:oBrw:SetColor(0,oNMINCES:nClrPane1)

  oNMINCES:SETBTNBAR(40,40,oBar)


  EVAL(oNMINCES:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMINCES:oBar:=oBar

    nCol:=684
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oNMINCES:oPeriodo  VAR oNMINCES:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oNMINCES:LEEFECHAS();
                WHEN oNMINCES:lWhen


  ComboIni(oNMINCES:oPeriodo )

  @ nLin, nCol+103 BUTTON oNMINCES:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMINCES:oPeriodo:nAt,oNMINCES:oDesde,oNMINCES:oHasta,-1),;
                         EVAL(oNMINCES:oBtn:bAction));
                WHEN oNMINCES:lWhen


  @ nLin, nCol+130 BUTTON oNMINCES:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMINCES:oPeriodo:nAt,oNMINCES:oDesde,oNMINCES:oHasta,+1),;
                         EVAL(oNMINCES:oBtn:bAction));
                WHEN oNMINCES:lWhen


  @ nLin, nCol+160 BMPGET oNMINCES:oDesde  VAR oNMINCES:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMINCES:oDesde ,oNMINCES:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oNMINCES:oPeriodo:nAt=LEN(oNMINCES:oPeriodo:aItems) .AND. oNMINCES:lWhen ;
                FONT oFont

   oNMINCES:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oNMINCES:oHasta  VAR oNMINCES:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMINCES:oHasta,oNMINCES:dHasta);
                SIZE 76-2,24;
                WHEN oNMINCES:oPeriodo:nAt=LEN(oNMINCES:oPeriodo:aItems) .AND. oNMINCES:lWhen ;
                OF oBar;
                FONT oFont

   oNMINCES:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oNMINCES:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oNMINCES:oPeriodo:nAt=LEN(oNMINCES:oPeriodo:aItems);
               ACTION oNMINCES:HACERWHERE(oNMINCES:dDesde,oNMINCES:dHasta,oNMINCES:cWhere,.T.);
               WHEN oNMINCES:lWhen

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

  oRep:=REPORTE("BRNMINCES",cWhere)
  oRep:cSql  :=oNMINCES:cSql
  oRep:cTitle:=oNMINCES:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMINCES:oPeriodo:nAt,cWhere

  oNMINCES:nPeriodo:=nPeriodo


  IF oNMINCES:oPeriodo:nAt=LEN(oNMINCES:oPeriodo:aItems)

     oNMINCES:oDesde:ForWhen(.T.)
     oNMINCES:oHasta:ForWhen(.T.)
     oNMINCES:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMINCES:oDesde)

  ELSE

     oNMINCES:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMINCES:oDesde:VarPut(oNMINCES:aFechas[1] , .T. )
     oNMINCES:oHasta:VarPut(oNMINCES:aFechas[2] , .T. )

     oNMINCES:dDesde:=oNMINCES:aFechas[1]
     oNMINCES:dHasta:=oNMINCES:aFechas[2]

     cWhere:=oNMINCES:HACERWHERE(oNMINCES:dDesde,oNMINCES:dHasta,oNMINCES:cWhere,.T.)

     oNMINCES:LEERDATA(cWhere,oNMINCES:oBrw,oNMINCES:cServer,oNMINCES)

  ENDIF

  oNMINCES:SAVEPERIODO()

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

     IF !Empty(oNMINCES:cWhereQry)
       cWhere:=cWhere + oNMINCES:cWhereQry
     ENDIF

     oNMINCES:LEERDATA(cWhere,oNMINCES:oBrw,oNMINCES:cServer,oNMINCES)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oNMINCES)
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

   cSql:=" SELECT    "+;
          "    REC_CODTRA, "+;
          "    CONCAT(APELLIDO,',',NOMBRE),   "+;
          "    SUM(CASE WHEN HIS_CODCON='D006' THEN HIS_MONTO*-1  ELSE 0 END) AS D006, "+;
          "    SUM(CASE WHEN HIS_CODCON='H002' THEN HIS_MONTO  ELSE 0 END) AS H002, "+;
          "    MAX(FCH_DESDE),  "+;
          "    MAX(FCH_HASTA),  "+;
          "    COUNT(*) AS CUANTOS  "+;
          "    FROM NMHISTORICO   "+;
          "    INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO   "+;
          "    INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO   "+;
          "    INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO   "+;
          "    INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO  "+;
          "    WHERE REC_CODSUC='000001' AND (HIS_CODCON='D006' OR HIS_CODCON='H002') "+;
          "    GROUP BY REC_CODTRA"+;
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

   DPWRITE("TEMP\BRNMINCES.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0,CTOD(""),CTOD(""),0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oNMINCES:cSql   :=cSql
      oNMINCES:cWhere_:=cWhere

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
      AEVAL(oNMINCES:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMINCES:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMINCES.MEM",V_nPeriodo:=oNMINCES:nPeriodo
  LOCAL V_dDesde:=oNMINCES:dDesde
  LOCAL V_dHasta:=oNMINCES:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMINCES)
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


    IF Type("oNMINCES")="O" .AND. oNMINCES:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMINCES:cWhere_),oNMINCES:cWhere_,oNMINCES:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oNMINCES:LEERDATA(oNMINCES:cWhere_,oNMINCES:oBrw,oNMINCES:cServer)
      oNMINCES:oWnd:Show()
      oNMINCES:oWnd:Restore()

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

   oNMINCES:aHead:=EJECUTAR("HTMLHEAD",oNMINCES)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oNMINCES)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

