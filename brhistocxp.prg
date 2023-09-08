// Programa   : BRHISTOCXP
// Fecha/Hora : 31/12/2021 05:36:58
// Propósito  : "Histórico hacia Cuentas por Pagar"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRHISTOCXP.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oHISTOCXP")="O" .AND. oHISTOCXP:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oHISTOCXP,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Histórico hacia Cuentas por Pagar" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oHISTOCXP

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oHISTOCXP","BRHISTOCXP.EDT")
// oHISTOCXP:CreateWindow(0,0,100,550)
   oHISTOCXP:Windows(0,0,aCoors[3]-160,MIN(1092,aCoors[4]-10),.T.) // Maximizado



   oHISTOCXP:cCodSuc  :=cCodSuc
   oHISTOCXP:lMsgBar  :=.F.
   oHISTOCXP:cPeriodo :=aPeriodos[nPeriodo]
   oHISTOCXP:cCodSuc  :=cCodSuc
   oHISTOCXP:nPeriodo :=nPeriodo
   oHISTOCXP:cNombre  :=""
   oHISTOCXP:dDesde   :=dDesde
   oHISTOCXP:cServer  :=cServer
   oHISTOCXP:dHasta   :=dHasta
   oHISTOCXP:cWhere   :=cWhere
   oHISTOCXP:cWhere_  :=cWhere_
   oHISTOCXP:cWhereQry:=""
   oHISTOCXP:cSql     :=oDp:cSql
   oHISTOCXP:oWhere   :=TWHERE():New(oHISTOCXP)
   oHISTOCXP:cCodPar  :=cCodPar // Código del Parámetro
   oHISTOCXP:lWhen    :=.T.
   oHISTOCXP:cTextTit :="" // Texto del Titulo Heredado
   oHISTOCXP:oDb      :=oDp:oDb
   oHISTOCXP:cBrwCod  :="HISTOCXP"
   oHISTOCXP:lTmdi    :=.T.
   oHISTOCXP:aHead    :={}
   oHISTOCXP:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oHISTOCXP:bValid   :={|| EJECUTAR("BRWSAVEPAR",oHISTOCXP)}

   oHISTOCXP:lBtnRun     :=.F.
   oHISTOCXP:lBtnMenuBrw :=.F.
   oHISTOCXP:lBtnSave    :=.F.
   oHISTOCXP:lBtnCrystal :=.F.
   oHISTOCXP:lBtnRefresh :=.F.
   oHISTOCXP:lBtnHtml    :=.T.
   oHISTOCXP:lBtnExcel   :=.T.
   oHISTOCXP:lBtnPreview :=.T.
   oHISTOCXP:lBtnQuery   :=.F.
   oHISTOCXP:lBtnOptions :=.T.
   oHISTOCXP:lBtnPageDown:=.T.
   oHISTOCXP:lBtnPageUp  :=.T.
   oHISTOCXP:lBtnFilters :=.T.
   oHISTOCXP:lBtnFind    :=.T.

   oHISTOCXP:nClrPane1:=16775408
   oHISTOCXP:nClrPane2:=16771797

   oHISTOCXP:nClrText :=0
   oHISTOCXP:nClrText1:=0
   oHISTOCXP:nClrText2:=0
   oHISTOCXP:nClrText3:=0




   oHISTOCXP:oBrw:=TXBrowse():New( IF(oHISTOCXP:lTmdi,oHISTOCXP:oWnd,oHISTOCXP:oDlg ))
   oHISTOCXP:oBrw:SetArray( aData, .F. )
   oHISTOCXP:oBrw:SetFont(oFont)

   oHISTOCXP:oBrw:lFooter     := .T.
   oHISTOCXP:oBrw:lHScroll    := .F.
   oHISTOCXP:oBrw:nHeaderLines:= 2
   oHISTOCXP:oBrw:nDataLines  := 1
   oHISTOCXP:oBrw:nFooterLines:= 1




   oHISTOCXP:aData            :=ACLONE(aData)

   AEVAL(oHISTOCXP:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: FCH_NUMERO
  oCol:=oHISTOCXP:oBrw:aCols[1]
  oCol:cHeader      :='Número'+CRLF+'Proceso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: FCH_TIPNOM
  oCol:=oHISTOCXP:oBrw:aCols[2]
  oCol:cHeader      :='Tipo'+CRLF+'Nómina'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 64
oCol:bClrStd  := {|nClrText,uValue|uValue:=oHISTOCXP:oBrw:aArrayData[oHISTOCXP:oBrw:nArrayAt,2],;
                     nClrText:=COLOR_OPTIONS("NMFECHAS            ","FCH_TIPNOM",uValue),;
                     {nClrText,iif( oHISTOCXP:oBrw:nArrayAt%2=0, oHISTOCXP:nClrPane1, oHISTOCXP:nClrPane2 ) } } 

  // Campo: FCH_OTRNOM
  oCol:=oHISTOCXP:oBrw:aCols[3]
  oCol:cHeader      :='Otra'+CRLF+'Nómina'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: FCH_DESDE
  oCol:=oHISTOCXP:oBrw:aCols[4]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: FCH_HASTA
  oCol:=oHISTOCXP:oBrw:aCols[5]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: HIS_CODCON
  oCol:=oHISTOCXP:oBrw:aCols[6]
  oCol:cHeader      :='Código'+CRLF+'Concepto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  // Campo: CON_DESCRI
  oCol:=oHISTOCXP:oBrw:aCols[7]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 480

  // Campo: CIC_CUENTA
  oCol:=oHISTOCXP:oBrw:aCols[8]
  oCol:cHeader      :='Cuenta'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: HIS_MONTO
  oCol:=oHISTOCXP:oBrw:aCols[9]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oHISTOCXP:oBrw:aArrayData[oHISTOCXP:oBrw:nArrayAt,9],;
                              oCol  := oHISTOCXP:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[9],oCol:cEditPicture)


   oHISTOCXP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oHISTOCXP:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oHISTOCXP:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oHISTOCXP:nClrText,;
                                                 nClrText:=IF(.F.,oHISTOCXP:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oHISTOCXP:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oHISTOCXP:nClrPane1, oHISTOCXP:nClrPane2 ) } }

//   oHISTOCXP:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oHISTOCXP:oBrw:bClrFooter            := {|| {0,14671839 }}

   oHISTOCXP:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oHISTOCXP:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oHISTOCXP:oBrw:bLDblClick:={|oBrw|oHISTOCXP:RUNCLICK() }

   oHISTOCXP:oBrw:bChange:={||oHISTOCXP:BRWCHANGE()}
   oHISTOCXP:oBrw:CreateFromCode()


   oHISTOCXP:oWnd:oClient := oHISTOCXP:oBrw



   oHISTOCXP:Activate({||oHISTOCXP:ViewDatBar()})

   oHISTOCXP:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oHISTOCXP:lTmdi,oHISTOCXP:oWnd,oHISTOCXP:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oHISTOCXP:oBrw:nWidth()

   oHISTOCXP:oBrw:GoBottom(.T.)
   oHISTOCXP:oBrw:Refresh(.T.)

   IF !File("FORMS\BRHISTOCXP.EDT")
     oHISTOCXP:oBrw:Move(44,0,1092+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oHISTOCXP:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oHISTOCXP:oBrw,oHISTOCXP:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oHISTOCXP:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","HISTOCXP")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","HISTOCXP"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oHISTOCXP:oBrw,"HISTOCXP",oHISTOCXP:cSql,oHISTOCXP:nPeriodo,oHISTOCXP:dDesde,oHISTOCXP:dHasta,oHISTOCXP)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oHISTOCXP:oBtnRun:=oBtn



       oHISTOCXP:oBrw:bLDblClick:={||EVAL(oHISTOCXP:oBtnRun:bAction) }


   ENDIF




IF oHISTOCXP:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oHISTOCXP");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oHISTOCXP:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oHISTOCXP:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oHISTOCXP:oBrw,oHISTOCXP:oFrm)
ENDIF

IF oHISTOCXP:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oHISTOCXP),;
                  EJECUTAR("DPBRWMENURUN",oHISTOCXP,oHISTOCXP:oBrw,oHISTOCXP:cBrwCod,oHISTOCXP:cTitle,oHISTOCXP:aHead));
          WHEN !Empty(oHISTOCXP:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oHISTOCXP:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oHISTOCXP:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oHISTOCXP:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oHISTOCXP:oBrw,oHISTOCXP);
          ACTION EJECUTAR("BRWSETFILTER",oHISTOCXP:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oHISTOCXP:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oHISTOCXP:oBrw);
          WHEN LEN(oHISTOCXP:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oHISTOCXP:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oHISTOCXP:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oHISTOCXP:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oHISTOCXP)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oHISTOCXP:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oHISTOCXP:oBrw,oHISTOCXP:cTitle,oHISTOCXP:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oHISTOCXP:oBtnXls:=oBtn

ENDIF

IF oHISTOCXP:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oHISTOCXP:HTMLHEAD(),EJECUTAR("BRWTOHTML",oHISTOCXP:oBrw,NIL,oHISTOCXP:cTitle,oHISTOCXP:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oHISTOCXP:oBtnHtml:=oBtn

ENDIF


IF oHISTOCXP:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oHISTOCXP:oBrw))

   oBtn:cToolTip:="Previsualización"

   oHISTOCXP:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRHISTOCXP")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oHISTOCXP:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oHISTOCXP:oBtnPrint:=oBtn

   ENDIF

IF oHISTOCXP:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oHISTOCXP:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oHISTOCXP:oBrw:GoTop(),oHISTOCXP:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oHISTOCXP:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oHISTOCXP:oBrw:PageDown(),oHISTOCXP:oBrw:Setfocus())
  ENDIF

  IF  oHISTOCXP:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oHISTOCXP:oBrw:PageUp(),oHISTOCXP:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oHISTOCXP:oBrw:GoBottom(),oHISTOCXP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oHISTOCXP:Close()

  oHISTOCXP:oBrw:SetColor(0,oHISTOCXP:nClrPane1)

  oHISTOCXP:SETBTNBAR(40,40,oBar)


  EVAL(oHISTOCXP:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oHISTOCXP:oBar:=oBar

  

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

  oRep:=REPORTE("BRHISTOCXP",cWhere)
  oRep:cSql  :=oHISTOCXP:cSql
  oRep:cTitle:=oHISTOCXP:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oHISTOCXP:oPeriodo:nAt,cWhere

  oHISTOCXP:nPeriodo:=nPeriodo


  IF oHISTOCXP:oPeriodo:nAt=LEN(oHISTOCXP:oPeriodo:aItems)

     oHISTOCXP:oDesde:ForWhen(.T.)
     oHISTOCXP:oHasta:ForWhen(.T.)
     oHISTOCXP:oBtn  :ForWhen(.T.)

     DPFOCUS(oHISTOCXP:oDesde)

  ELSE

     oHISTOCXP:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oHISTOCXP:oDesde:VarPut(oHISTOCXP:aFechas[1] , .T. )
     oHISTOCXP:oHasta:VarPut(oHISTOCXP:aFechas[2] , .T. )

     oHISTOCXP:dDesde:=oHISTOCXP:aFechas[1]
     oHISTOCXP:dHasta:=oHISTOCXP:aFechas[2]

     cWhere:=oHISTOCXP:HACERWHERE(oHISTOCXP:dDesde,oHISTOCXP:dHasta,oHISTOCXP:cWhere,.T.)

     oHISTOCXP:LEERDATA(cWhere,oHISTOCXP:oBrw,oHISTOCXP:cServer,oHISTOCXP)

  ENDIF

  oHISTOCXP:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oHISTOCXP:cWhereQry)
       cWhere:=cWhere + oHISTOCXP:cWhereQry
     ENDIF

     oHISTOCXP:LEERDATA(cWhere,oHISTOCXP:oBrw,oHISTOCXP:cServer,oHISTOCXP)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oHISTOCXP)
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

   cSql:=" SELECT FCH_NUMERO,FCH_TIPNOM,FCH_OTRNOM,FCH_DESDE,FCH_HASTA, HIS_CODCON,CON_DESCRI,CIC_CUENTA, SUM(HIS_MONTO*IF(HIS_MONTO<0,-1,1)) AS HIS_MONTO  "+;
          " FROM NMRECIBOS  "+;
          " INNER JOIN NMTRABAJADOR    ON REC_CODTRA=CODIGO  "+;
          " INNER JOIN NMHISTORICO     ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC  "+;
          " INNER JOIN NMFECHAS        ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO  "+;
          " INNER JOIN NMCONCEPTOS     ON HIS_CODCON=CON_CODIGO  "+;
          " LEFT  JOIN NMCONCEPTOS_CTA ON CIC_CODIGO=HIS_CODCON AND CIC_CODINT='CUENTA' AND CIC_CTAMOD='000000' "+;
          " WHERE 1=1"+;
          " GROUP BY FCH_NUMERO,HIS_CODCON"+;
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

   DPWRITE("TEMP\BRHISTOCXP.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',CTOD(""),CTOD(""),'','','',0})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,2]:=SAYOPTIONS("NMFECHAS","FCH_TIPNOM",a[2])})

   IF ValType(oBrw)="O"

      oHISTOCXP:cSql   :=cSql
      oHISTOCXP:cWhere_:=cWhere

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
      AEVAL(oHISTOCXP:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oHISTOCXP:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRHISTOCXP.MEM",V_nPeriodo:=oHISTOCXP:nPeriodo
  LOCAL V_dDesde:=oHISTOCXP:dDesde
  LOCAL V_dHasta:=oHISTOCXP:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oHISTOCXP)
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


    IF Type("oHISTOCXP")="O" .AND. oHISTOCXP:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oHISTOCXP:cWhere_),oHISTOCXP:cWhere_,oHISTOCXP:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oHISTOCXP:LEERDATA(oHISTOCXP:cWhere_,oHISTOCXP:oBrw,oHISTOCXP:cServer)
      oHISTOCXP:oWnd:Show()
      oHISTOCXP:oWnd:Restore()

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

   oHISTOCXP:aHead:=EJECUTAR("HTMLHEAD",oHISTOCXP)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oHISTOCXP)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

