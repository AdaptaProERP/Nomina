// Programa   : BRNMHISTOCXP
// Fecha/Hora : 31/12/2021 06:21:16
// Propósito  : "Histórico hacia Cuentas por Pagar"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cTipDoc,cRegPla,cRif,dFecha)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMHISTOCXP.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oNMHISTOCXP")="O" .AND. oNMHISTOCXP:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oNMHISTOCXP,GetScript())
   ENDIF

   DEFAULT cTipDoc:="INC",cRegPla:=STRZERO(8,10),cRif:=oDp:cRifInces,dFecha:=oDp:dFecha

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Crear Cuentas por Pagar desde Recibos de Nómina" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oNMHISTOCXP

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )
   LOCAL lView :=!ISTABMOD("DPCTA")

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oNMHISTOCXP","BRNMHISTOCXP.EDT")
// oNMHISTOCXP:CreateWindow(0,0,100,550)
   oNMHISTOCXP:Windows(0,0,aCoors[3]-160,MIN(1092,aCoors[4]-10),.T.) // Maximizado


   oNMHISTOCXP:cCodSuc  :=cCodSuc
   oNMHISTOCXP:lMsgBar  :=.F.
   oNMHISTOCXP:cPeriodo :=aPeriodos[nPeriodo]
   oNMHISTOCXP:cCodSuc  :=cCodSuc
   oNMHISTOCXP:nPeriodo :=nPeriodo
   oNMHISTOCXP:cNombre  :=""
   oNMHISTOCXP:dDesde   :=dDesde
   oNMHISTOCXP:cServer  :=cServer
   oNMHISTOCXP:dHasta   :=dHasta
   oNMHISTOCXP:cWhere   :=cWhere
   oNMHISTOCXP:cWhere_  :=cWhere_
   oNMHISTOCXP:cWhereQry:=""
   oNMHISTOCXP:cSql     :=oDp:cSql
   oNMHISTOCXP:oWhere   :=TWHERE():New(oNMHISTOCXP)
   oNMHISTOCXP:cCodPar  :=cCodPar // Código del Parámetro
   oNMHISTOCXP:lWhen    :=.T.
   oNMHISTOCXP:cTextTit :="" // Texto del Titulo Heredado
   oNMHISTOCXP:oDb      :=oDp:oDb
   oNMHISTOCXP:cBrwCod  :="NMHISTOCXP"
   oNMHISTOCXP:lTmdi    :=.T.
   oNMHISTOCXP:aHead    :={}
   oNMHISTOCXP:lBarDef  :=.T. // Activar Modo Diseño.
   oNMHISTOCXP:dHasta   :=dFecha
   oNMHISTOCXP:cTableD  :="NMCONCEPTOS_CTA"


   oNMHISTOCXP:cTipDoc:=cTipDoc
   oNMHISTOCXP:cRegPla:=cRegPla
   oNMHISTOCXP:cRif   :=cRif

   // Guarda los parámetros del Browse cuando cierra la ventana
   oNMHISTOCXP:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMHISTOCXP)}

   oNMHISTOCXP:lBtnRun     :=.F.
   oNMHISTOCXP:lBtnMenuBrw :=.F.
   oNMHISTOCXP:lBtnSave    :=.F.
   oNMHISTOCXP:lBtnCrystal :=.F.
   oNMHISTOCXP:lBtnRefresh :=.F.
   oNMHISTOCXP:lBtnHtml    :=.T.
   oNMHISTOCXP:lBtnExcel   :=.T.
   oNMHISTOCXP:lBtnPreview :=.T.
   oNMHISTOCXP:lBtnQuery   :=.F.
   oNMHISTOCXP:lBtnOptions :=.T.
   oNMHISTOCXP:lBtnPageDown:=.T.
   oNMHISTOCXP:lBtnPageUp  :=.T.
   oNMHISTOCXP:lBtnFilters :=.T.
   oNMHISTOCXP:lBtnFind    :=.T.

   oNMHISTOCXP:nClrPane1:=16775408
   oNMHISTOCXP:nClrPane2:=16771797

   oNMHISTOCXP:nClrText :=0
   oNMHISTOCXP:nClrText1:=0
   oNMHISTOCXP:nClrText2:=0
   oNMHISTOCXP:nClrText3:=0

   oNMHISTOCXP:oBrw:=TXBrowse():New( IF(oNMHISTOCXP:lTmdi,oNMHISTOCXP:oWnd,oNMHISTOCXP:oDlg ))
   oNMHISTOCXP:oBrw:SetArray( aData, .F. )
   oNMHISTOCXP:oBrw:SetFont(oFont)

   oNMHISTOCXP:oBrw:lFooter     := .T.
   oNMHISTOCXP:oBrw:lHScroll    := .T.
   oNMHISTOCXP:oBrw:nHeaderLines:= 2
   oNMHISTOCXP:oBrw:nDataLines  := 1
   oNMHISTOCXP:oBrw:nFooterLines:= 1

   oNMHISTOCXP:aData            :=ACLONE(aData)

   AEVAL(oNMHISTOCXP:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  

  // Campo: FCH_NUMERO
  oCol:=oNMHISTOCXP:oBrw:aCols[1]
  oCol:cHeader      :='Número'+CRLF+'Proceso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: FCH_TIPNOM
  oCol:=oNMHISTOCXP:oBrw:aCols[2]
  oCol:cHeader      :='Tipo'+CRLF+'Nómina'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 64
oCol:bClrStd  := {|nClrText,uValue|uValue:=oNMHISTOCXP:oBrw:aArrayData[oNMHISTOCXP:oBrw:nArrayAt,2],;
                     nClrText:=COLOR_OPTIONS("NMFECHAS            ","FCH_TIPNOM",uValue),;
                     {nClrText,iif( oNMHISTOCXP:oBrw:nArrayAt%2=0, oNMHISTOCXP:nClrPane1, oNMHISTOCXP:nClrPane2 ) } } 

  // Campo: FCH_OTRNOM
  oCol:=oNMHISTOCXP:oBrw:aCols[3]
  oCol:cHeader      :='Otra'+CRLF+'Nómina'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: OTR_DESCRI
  oCol:=oNMHISTOCXP:oBrw:aCols[4]
  oCol:cHeader      :='Descripción'+CRLF+'Otra Nómina'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: FCH_DESDE
  oCol:=oNMHISTOCXP:oBrw:aCols[5]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: FCH_HASTA
  oCol:=oNMHISTOCXP:oBrw:aCols[6]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: HIS_CODCON
  oCol:=oNMHISTOCXP:oBrw:aCols[7]
  oCol:cHeader      :='Código'+CRLF+'Concepto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  // Campo: CON_DESCRI
  oCol:=oNMHISTOCXP:oBrw:aCols[8]
  oCol:cHeader      :='Descripción'+CRLF+'Concepto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 480

  // Campo: CIC_CUENTA
  oCol:=oNMHISTOCXP:oBrw:aCols[9]
  oCol:cHeader      :='Cuenta'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock:={||oNMHISTOCXP:EditCta(9,.F.)}
  oCol:bOnPostEdit:={|oCol,uValue,nKey|oNMHISTOCXP:ValCta(oCol,uValue,9,nKey)}
  oCol:lButton   :=.F.
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 

  // Campo: HIS_MONTO
  oCol:=oNMHISTOCXP:oBrw:aCols[10]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMHISTOCXP:oBrw:aArrayData[oNMHISTOCXP:oBrw:nArrayAt,10],;
                              oCol  := oNMHISTOCXP:oBrw:aCols[10],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[10],oCol:cEditPicture)


  // Campo: CON_DESCRI
   oCol:=oNMHISTOCXP:oBrw:aCols[11]
   oCol:cHeader      :='Descripción'+CRLF+'Cuenta Contable'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oNMHISTOCXP:oBrw:aArrayData ) } 
   oCol:nWidth       := 380

   oNMHISTOCXP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMHISTOCXP:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oNMHISTOCXP:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oNMHISTOCXP:nClrText,;
                                                 nClrText:=IF(.F.,oNMHISTOCXP:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oNMHISTOCXP:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oNMHISTOCXP:nClrPane1, oNMHISTOCXP:nClrPane2 ) } }

//   oNMHISTOCXP:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oNMHISTOCXP:oBrw:bClrFooter            := {|| {0,14671839 }}

   oNMHISTOCXP:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMHISTOCXP:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oNMHISTOCXP:oBrw:bLDblClick:={|oBrw|oNMHISTOCXP:RUNCLICK() }

   oNMHISTOCXP:oBrw:bChange:={||oNMHISTOCXP:BRWCHANGE()}
   oNMHISTOCXP:oBrw:CreateFromCode()


   oNMHISTOCXP:oWnd:oClient := oNMHISTOCXP:oBrw



   oNMHISTOCXP:Activate({||oNMHISTOCXP:ViewDatBar()})

   oNMHISTOCXP:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMHISTOCXP:lTmdi,oNMHISTOCXP:oWnd,oNMHISTOCXP:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oNMHISTOCXP:oBrw:nWidth()

   oNMHISTOCXP:oBrw:GoBottom(.T.)
   oNMHISTOCXP:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMHISTOCXP.EDT")
     oNMHISTOCXP:oBrw:Move(44,0,1092+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            ACTION oNMHISTOCXP:CXPGRABAR()

   oBtn:cToolTip:="Guardar en Cuentas por Pagar"


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XBROWSE.BMP";
            ACTION oNMHISTOCXP:VERDETALLES()

   oBtn:cToolTip:="Ver Detalles"

   IF .F. .AND. Empty(oNMHISTOCXP:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMHISTOCXP:oBrw,oNMHISTOCXP:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oNMHISTOCXP:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMHISTOCXP")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMHISTOCXP"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMHISTOCXP:oBrw,"NMHISTOCXP",oNMHISTOCXP:cSql,oNMHISTOCXP:nPeriodo,oNMHISTOCXP:dDesde,oNMHISTOCXP:dHasta,oNMHISTOCXP)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMHISTOCXP:oBtnRun:=oBtn



       oNMHISTOCXP:oBrw:bLDblClick:={||EVAL(oNMHISTOCXP:oBtnRun:bAction) }


   ENDIF




IF oNMHISTOCXP:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oNMHISTOCXP");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oNMHISTOCXP:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oNMHISTOCXP:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oNMHISTOCXP:oBrw,oNMHISTOCXP:oFrm)
ENDIF

IF oNMHISTOCXP:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oNMHISTOCXP),;
                  EJECUTAR("DPBRWMENURUN",oNMHISTOCXP,oNMHISTOCXP:oBrw,oNMHISTOCXP:cBrwCod,oNMHISTOCXP:cTitle,oNMHISTOCXP:aHead));
          WHEN !Empty(oNMHISTOCXP:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oNMHISTOCXP:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMHISTOCXP:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oNMHISTOCXP:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oNMHISTOCXP:oBrw,oNMHISTOCXP);
          ACTION EJECUTAR("BRWSETFILTER",oNMHISTOCXP:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oNMHISTOCXP:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMHISTOCXP:oBrw);
          WHEN LEN(oNMHISTOCXP:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oNMHISTOCXP:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMHISTOCXP:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oNMHISTOCXP:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMHISTOCXP)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oNMHISTOCXP:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMHISTOCXP:oBrw,oNMHISTOCXP:cTitle,oNMHISTOCXP:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMHISTOCXP:oBtnXls:=oBtn

ENDIF

IF oNMHISTOCXP:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oNMHISTOCXP:HTMLHEAD(),EJECUTAR("BRWTOHTML",oNMHISTOCXP:oBrw,NIL,oNMHISTOCXP:cTitle,oNMHISTOCXP:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oNMHISTOCXP:oBtnHtml:=oBtn

ENDIF


IF oNMHISTOCXP:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMHISTOCXP:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMHISTOCXP:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMHISTOCXP")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMHISTOCXP:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMHISTOCXP:oBtnPrint:=oBtn

   ENDIF

IF oNMHISTOCXP:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMHISTOCXP:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMHISTOCXP:oBrw:GoTop(),oNMHISTOCXP:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oNMHISTOCXP:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oNMHISTOCXP:oBrw:PageDown(),oNMHISTOCXP:oBrw:Setfocus())
  ENDIF

  IF  oNMHISTOCXP:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oNMHISTOCXP:oBrw:PageUp(),oNMHISTOCXP:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMHISTOCXP:oBrw:GoBottom(),oNMHISTOCXP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMHISTOCXP:Close()

  oNMHISTOCXP:oBrw:SetColor(0,oNMHISTOCXP:nClrPane1)

  oNMHISTOCXP:SETBTNBAR(40,40,oBar)


  EVAL(oNMHISTOCXP:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMHISTOCXP:oBar:=oBar

  oBar:SetSize(NIL,75,.T.)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 45,015+10 SAY oNMHISTOCXP:cRif                                                            OF oBar SIZE 090,20;
           BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ 45,115+10 SAY SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_RIF"+GetWhere("=",oNMHISTOCXP:cRif)) OF oBar SIZE 450,20;
           BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont


  @ 02,450+10 SAY "Tipo 	" OF oBar SIZE 85,20 RIGHT;
           BORDER PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  @ 02,535+10 SAY " "+oNMHISTOCXP:cTipDoc+" "+SQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oNMHISTOCXP:cTipDoc)) OF oBar SIZE 450,20;
           BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont


  @ 23,450+10 SAY "Planificación " OF oBar SIZE 85,20 RIGHT;
           BORDER PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  @ 23,535+10 SAY " "+oNMHISTOCXP:cRegPla OF oBar SIZE 110,20;
           BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont


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

  oRep:=REPORTE("BRNMHISTOCXP",cWhere)
  oRep:cSql  :=oNMHISTOCXP:cSql
  oRep:cTitle:=oNMHISTOCXP:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMHISTOCXP:oPeriodo:nAt,cWhere

  oNMHISTOCXP:nPeriodo:=nPeriodo


  IF oNMHISTOCXP:oPeriodo:nAt=LEN(oNMHISTOCXP:oPeriodo:aItems)

     oNMHISTOCXP:oDesde:ForWhen(.T.)
     oNMHISTOCXP:oHasta:ForWhen(.T.)
     oNMHISTOCXP:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMHISTOCXP:oDesde)

  ELSE

     oNMHISTOCXP:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMHISTOCXP:oDesde:VarPut(oNMHISTOCXP:aFechas[1] , .T. )
     oNMHISTOCXP:oHasta:VarPut(oNMHISTOCXP:aFechas[2] , .T. )

     oNMHISTOCXP:dDesde:=oNMHISTOCXP:aFechas[1]
     oNMHISTOCXP:dHasta:=oNMHISTOCXP:aFechas[2]

     cWhere:=oNMHISTOCXP:HACERWHERE(oNMHISTOCXP:dDesde,oNMHISTOCXP:dHasta,oNMHISTOCXP:cWhere,.T.)

     oNMHISTOCXP:LEERDATA(cWhere,oNMHISTOCXP:oBrw,oNMHISTOCXP:cServer,oNMHISTOCXP)

  ENDIF

  oNMHISTOCXP:SAVEPERIODO()

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

     IF !Empty(oNMHISTOCXP:cWhereQry)
       cWhere:=cWhere + oNMHISTOCXP:cWhereQry
     ENDIF

     oNMHISTOCXP:LEERDATA(cWhere,oNMHISTOCXP:oBrw,oNMHISTOCXP:cServer,oNMHISTOCXP)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oNMHISTOCXP)
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

   cSql:=" SELECT "+;
          " FCH_NUMERO,"+;
          " FCH_TIPNOM,"+;
          " FCH_OTRNOM,"+;
          " OTR_DESCRI,"+;
          " FCH_DESDE,"+;
          " FCH_HASTA,"+;
          " HIS_CODCON,"+;
          " CON_DESCRI,"+;
          " CIC_CUENTA,"+;
          " SUM(HIS_MONTO*IF(HIS_MONTO<0,-1,1)) AS HIS_MONTO,CTA_DESCRI  "+;
          " FROM NMRECIBOS  "+;
          " INNER JOIN NMTRABAJADOR    ON REC_CODTRA=CODIGO  "+;
          " INNER JOIN NMHISTORICO     ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC  "+;
          " INNER JOIN NMFECHAS        ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO  "+;
          " LEFT  JOIN NMOTRASNM       ON FCH_OTRNOM=OTR_CODIGO"+;
          " INNER JOIN NMCONCEPTOS     ON HIS_CODCON=CON_CODIGO  "+;
          " LEFT  JOIN NMCONCEPTOS_CTA ON CIC_CODIGO=HIS_CODCON AND CIC_CODINT='CUENTA' AND CIC_CTAMOD"+GetWhere("=",oDp:cCtaMod)+;
          " LEFT  JOIN DPCTA           ON CIC_CUENTA=CTA_CODIGO AND CIC_CTAMOD=CTA_CODMOD"+;
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

   DPWRITE("TEMP\BRNMHISTOCXP.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','',CTOD(""),CTOD(""),'','','',0})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,2]:=SAYOPTIONS("NMFECHAS","FCH_TIPNOM",a[2])})

   IF ValType(oBrw)="O"

      oNMHISTOCXP:cSql   :=cSql
      oNMHISTOCXP:cWhere_:=cWhere

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
      AEVAL(oNMHISTOCXP:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMHISTOCXP:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMHISTOCXP.MEM",V_nPeriodo:=oNMHISTOCXP:nPeriodo
  LOCAL V_dDesde:=oNMHISTOCXP:dDesde
  LOCAL V_dHasta:=oNMHISTOCXP:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMHISTOCXP)
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


    IF Type("oNMHISTOCXP")="O" .AND. oNMHISTOCXP:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMHISTOCXP:cWhere_),oNMHISTOCXP:cWhere_,oNMHISTOCXP:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oNMHISTOCXP:LEERDATA(oNMHISTOCXP:cWhere_,oNMHISTOCXP:oBrw,oNMHISTOCXP:cServer)
      oNMHISTOCXP:oWnd:Show()
      oNMHISTOCXP:oWnd:Restore()

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

   oNMHISTOCXP:aHead:=EJECUTAR("HTMLHEAD",oNMHISTOCXP)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oNMHISTOCXP)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/

FUNCTION CXPGRABAR()
  LOCAL aData  :=oNMHISTOCXP:oBrw:aArrayData
  LOCAL aTotal :=ATOTALES(oNMHISTOCXP:oBrw:aArrayData)
  LOCAL nMonto :=aTotal[10]
  LOCAL cCodigo:=SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_RIF"+GetWhere("=",oNMHISTOCXP:cRif))
  LOCAL nPlazo :=0,lItem:=.F.,nValCam:=0,I,oItem
  LOCAL cDescri:="",cCodCta,cCtaEgr,cRefere,nMonto,dFchDec,cWhere

  oDp:cNumero:=""

  EJECUTAR("DPDOCPROPROGUP",oNMHISTOCXP:cCodSuc,cCodigo,oNMHISTOCXP:cTipDoc,oNMHISTOCXP:cRegPla,nMonto,oNMHISTOCXP:dHasta,nPlazo,oDp:cNumero,lItem,nValCam) // Fecha Correspondiente será la Fecha hasta


  cWhere :="PLP_CODSUC"+GetWhere("=",oDp:cSucMain)+" AND PLP_TIPDOC"+GetWhere("=",oNMHISTOCXP:cTipDoc)
  dFchDec:=SQLGET("DPDOCPROPROG","PLP_FECHA,PLP_REFERE",cWhere+" AND PLP_NUMREG"+GetWhere("=",oNMHISTOCXP:cRegPla))
  cRefere:=DPSQLROW(2,CTOD(""))

  IF !Empty(oDp:cNumero)

    SQLDELETE("DPDOCPROCTA","CCD_CODSUC" + GetWhere("=" , oNMHISTOCXP:cCodSuc)+" AND "+;
                            "CCD_TIPDOC" + GetWhere("=" , oNMHISTOCXP:cTipDoc)+" AND "+;
                            "CCD_CODIGO" + GetWhere("=" , cCodigo            )+" AND "+;
                            "CCD_NUMERO" + GetWhere("=" , oDp:cNumero       ))
 
    oItem:=OpenTable("SELECT * FROM DPDOCPROCTA",.F.)

    FOR I=1 TO LEN(aData)

      cDescri:=ALLTRIM(aData[I,08])+" ["+aData[I,07]+"] "+F8(aData[I,5])+"-"+F8(aData[I,6])
      cCodCta:=aData[I,09]

      IF Empty(cCodCta)

         cCodCta:=oDp:cCtaIndef
         cCtaEgr:=oDp:cCtaIndef

      ELSE

         EJECUTAR("DPCTAEGRESOCREA",cCodCta)

         cCtaEgr:=SQLGET("DPCTAEGRESO_CTA","CIC_CODIGO","CIC_CUENTA"+GetWhere("=",cCodCta)+" AND CIC_CTAMOD"+GetWhere("=",oDp:cCtaMod))
         cCtaEgr:=IF(Empty(cCtaEgr),oDp:cCtaIndef,cCtaEgr)

      ENDIF

// ? cCtaEgr,"cCtaEgr",cCodCta,"cCodCta"

      oItem:AppendBlank()
      oItem:Replace("CCD_CODSUC" , oNMHISTOCXP:cCodSuc)
      oItem:Replace("CCD_TIPDOC" , oNMHISTOCXP:cTipDoc)
      oItem:Replace("CCD_DESCRI" , cDescri)
      oItem:Replace("CCD_CODIGO" , cCodigo)
      oItem:Replace("CCD_NUMERO" , oDp:cNumero)
      oItem:Replace("CCD_TIPTRA" , "D"    )
      oItem:Replace("CCD_CODCTA" , cCodCta)
      oItem:Replace("CCD_CTAEGR" , cCtaEgr)
      oItem:Replace("CCD_ITEM"   , STRZERO(I,5))
      oItem:Replace("CCD_CENCOS" , oDp:cCenCos)
      oItem:Replace("CCD_ACT"    , 1      )
      oItem:Replace("CCD_REFERE" , cRefere)
      oItem:Replace("CCD_TIPIVA" , "EX"   )
      oItem:Replace("CCD_MONTO"  , aData[I,10] )
      oItem:Replace("CCD_TOTAL"  , aData[I,10] )
      oItem:Replace("CCD_PORIVA" , 0      )
      oItem:Replace("CCD_CTAMOD" , oDp:cCtaMod )
      oItem:Replace("CCD_CODCON" , aData[I,07] )
      oItem:Replace("CCD_FCHNUM" , aData[I,01] )
      oItem:Commit()

    NEXT I

    oItem:End()

  ENDIF

  EJECUTAR("DPPROVEEDORDOC",cCodigo,NIL,oNMHISTOCXP:cTipDoc)

RETURN .T.

FUNCTION ValCta(oCol,uValue,nCol,nKey)
 LOCAL cTipDoc,oTable,cWhere:="",cCtaOld:="",cDescri,aLine:={},cWhere

 DEFAULT nKey:=0

 DEFAULT oCol:lButton:=.F.

 IF oCol:lButton=.T.
    oCol:lButton:=.F.
    RETURN .T.
 ENDIF

 IF !SQLGET("DPCTA","CTA_CODIGO,CTA_DESCRI","CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+" AND CTA_CODIGO"+GetWhere("=",uValue))==uValue
    MensajeErr("Cuenta Contable no Existe")
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF

 cDescri:=oDp:aRow[2]

 IF !EJECUTAR("ISCTADET",uValue,.T.)
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF

 oNMHISTOCXP:lAcction  :=.F.

 aLine:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt]

 cWhere:="CIC_CODIGO"+GetWhere("=",aLine[7])+" AND "+;
         "CIC_COD2"  +GetWhere("=",""      )+" AND "+;
         "CIC_CODINT"+GetWhere("=","CUENTA")

 oTable:=OpenTable("SELECT * FROM "+oNMHISTOCXP:cTableD+" WHERE "+cWhere,.T.)

 IF oTable:RecCount()=0
    oTable:Append()
    cWhere:=""
 ELSE
    cWhere:=oTable:cWhere
 ENDIF

 oTable:cPrimary:="CIC_CTAMOD,CIC_CODIGO,CIC_COD2,CIC_CODINT"
 oTable:SetAuditar()
 oTable:Replace("CIC_COD2"  ,"")
 oTable:Replace("CIC_CODIGO",aLine[7]    )
 oTable:Replace("CIC_CODINT","CUENTA"    )
 oTable:Replace("CIC_CUENTA",uValue      )
 oTable:Replace("CIC_FECHA" ,oDp:dFecha  )
 oTable:Replace("CIC_HORA"  ,oDp:cHora   )
 oTable:Replace("CIC_USUARI",oDp:cUsuario)
 otable:Replace("CIC_CTAMOD",oDp:cCtaMod )
  
 oTable:Commit(cWhere)
 oTable:End()

// ? oDp:cSql

 SysRefresh(.t.)

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,9+2]:=SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",uValue)+" AND CTA_CODMOD"+GetWhere("=",oDp:cCtaMod))

 oCol:oBrw:DrawLine(.T.)

RETURN .T.

FUNCTION EditCta(nCol,lSave)
   LOCAL oBrw  :=oNMHISTOCXP:oBrw,oLbx
   LOCAL nAt   :=oBrw:nArrayAt
   LOCAL uValue:=oBrw:aArrayData[oBrw:nArrayAt,nCol]

   oLbx:=DpLbx("DPCTAUTILIZACION.LBX")
   oLbx:GetValue("CTA_CODIGO",oBrw:aCols[nCol],,,uValue)
   oNMHISTOCXP:lAcction  :=.T.
   oBrw:nArrayAt:=nAt

   SysRefresh(.t.)


RETURN uValue


FUNCTION VERDETALLES()
  LOCAL aLine  :=oNMHISTOCXP:oBrw:aArrayData[oNMHISTOCXP:oBrw:nArrayAt]
  LOCAL cCodCon:=aLine[7],dDesde:=aLine[5],dHasta:=aLine[6]

  IF oNMHISTOCXP:cTipDoc="INC"
    RETURN EJECUTAR("BRNMINCES",NIL,oNMHISTOCXP:cCodSuc,12,dDesde,dHasta)
  ENDIF
//  LOCAL cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCon
RETURN EJECUTAR("BRNMHISTRAREC","HIS_CODCON"+GetWhere("=",cCodCon),oNMHISTOCXP:cCodSuc,12,dDesde,dHasta,NIL,cCodCon)
// EOF

