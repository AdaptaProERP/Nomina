// Programa   : BRNMTRABJDEPURA
// Fecha/Hora : 01/09/2021 09:22:32
// Propósito  : "Depurar y Migrar hacia Histórico Trabajadores Inactivos y Liquidados"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMTRABJDEPURA.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oNMTRABJDEPURA")="O" .AND. oNMTRABJDEPURA:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oNMTRABJDEPURA,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Depurar y Migrar hacia Histórico Trabajadores Inactivos y Liquidados" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oNMTRABJDEPURA

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oNMTRABJDEPURA","BRNMTRABJDEPURA.EDT")
// oNMTRABJDEPURA:CreateWindow(0,0,100,550)
   oNMTRABJDEPURA:Windows(0,0,aCoors[3]-160,MIN(1466,aCoors[4]-10),.T.) // Maximizado



   oNMTRABJDEPURA:cCodSuc  :=cCodSuc
   oNMTRABJDEPURA:lMsgBar  :=.F.
   oNMTRABJDEPURA:cPeriodo :=aPeriodos[nPeriodo]
   oNMTRABJDEPURA:cCodSuc  :=cCodSuc
   oNMTRABJDEPURA:nPeriodo :=nPeriodo
   oNMTRABJDEPURA:cNombre  :=""
   oNMTRABJDEPURA:dDesde   :=dDesde
   oNMTRABJDEPURA:cServer  :=cServer
   oNMTRABJDEPURA:dHasta   :=dHasta
   oNMTRABJDEPURA:cWhere   :=cWhere
   oNMTRABJDEPURA:cWhere_  :=cWhere_
   oNMTRABJDEPURA:cWhereQry:=""
   oNMTRABJDEPURA:cSql     :=oDp:cSql
   oNMTRABJDEPURA:oWhere   :=TWHERE():New(oNMTRABJDEPURA)
   oNMTRABJDEPURA:cCodPar  :=cCodPar // Código del Parámetro
   oNMTRABJDEPURA:lWhen    :=.T.
   oNMTRABJDEPURA:cTextTit :="" // Texto del Titulo Heredado
   oNMTRABJDEPURA:oDb      :=oDp:oDb
   oNMTRABJDEPURA:cBrwCod  :="NMTRABJDEPURA"
   oNMTRABJDEPURA:lTmdi    :=.T.
   oNMTRABJDEPURA:aHead    :={}
   oNMTRABJDEPURA:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oNMTRABJDEPURA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMTRABJDEPURA)}

   oNMTRABJDEPURA:lBtnRun     :=.F.
   oNMTRABJDEPURA:lBtnMenuBrw :=.F.
   oNMTRABJDEPURA:lBtnSave    :=.F.
   oNMTRABJDEPURA:lBtnCrystal :=.F.
   oNMTRABJDEPURA:lBtnRefresh :=.F.
   oNMTRABJDEPURA:lBtnHtml    :=.T.
   oNMTRABJDEPURA:lBtnExcel   :=.T.
   oNMTRABJDEPURA:lBtnPreview :=.T.
   oNMTRABJDEPURA:lBtnQuery   :=.F.
   oNMTRABJDEPURA:lBtnOptions :=.T.
   oNMTRABJDEPURA:lBtnPageDown:=.T.
   oNMTRABJDEPURA:lBtnPageUp  :=.T.
   oNMTRABJDEPURA:lBtnFilters :=.T.
   oNMTRABJDEPURA:lBtnFind    :=.T.

   oNMTRABJDEPURA:nClrPane1:=16775408
   oNMTRABJDEPURA:nClrPane2:=16771797

   oNMTRABJDEPURA:nClrText :=0
   oNMTRABJDEPURA:nClrText1:=0
   oNMTRABJDEPURA:nClrText2:=0
   oNMTRABJDEPURA:nClrText3:=0




   oNMTRABJDEPURA:oBrw:=TXBrowse():New( IF(oNMTRABJDEPURA:lTmdi,oNMTRABJDEPURA:oWnd,oNMTRABJDEPURA:oDlg ))
   oNMTRABJDEPURA:oBrw:SetArray( aData, .F. )
   oNMTRABJDEPURA:oBrw:SetFont(oFont)

   oNMTRABJDEPURA:oBrw:lFooter     := .T.
   oNMTRABJDEPURA:oBrw:lHScroll    := .F.
   oNMTRABJDEPURA:oBrw:nHeaderLines:= 2
   oNMTRABJDEPURA:oBrw:nDataLines  := 1
   oNMTRABJDEPURA:oBrw:nFooterLines:= 1




   oNMTRABJDEPURA:aData            :=ACLONE(aData)

   AEVAL(oNMTRABJDEPURA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: CODIGO
  oCol:=oNMTRABJDEPURA:oBrw:aCols[1]
  oCol:cHeader      :='Codigo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJDEPURA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: TRA_NOMAPL
  oCol:=oNMTRABJDEPURA:oBrw:aCols[2]
  oCol:cHeader      :='Apellidos y Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJDEPURA:oBrw:aArrayData ) } 
  oCol:nWidth       := 960

  // Campo: FECHA_ING
  oCol:=oNMTRABJDEPURA:oBrw:aCols[3]
  oCol:cHeader      :='Fecha'+CRLF+'Ingreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJDEPURA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: FECHA_EGR
  oCol:=oNMTRABJDEPURA:oBrw:aCols[4]
  oCol:cHeader      :='Fecha'+CRLF+'Egreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJDEPURA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: CONDICION
  oCol:=oNMTRABJDEPURA:oBrw:aCols[5]
  oCol:cHeader      :='Condición'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJDEPURA:oBrw:aArrayData ) } 
  oCol:nWidth       := 72
oCol:bClrStd  := {|nClrText,uValue|uValue:=oNMTRABJDEPURA:oBrw:aArrayData[oNMTRABJDEPURA:oBrw:nArrayAt,5],;
                     nClrText:=COLOR_OPTIONS("nmtrabajador ","CONDICION",uValue),;
                     {nClrText,iif( oNMTRABJDEPURA:oBrw:nArrayAt%2=0, oNMTRABJDEPURA:nClrPane1, oNMTRABJDEPURA:nClrPane2 ) } } 

  // Campo: REC_ULTFCH
  oCol:=oNMTRABJDEPURA:oBrw:aCols[6]
  oCol:cHeader      :='Ultimo'+CRLF+'Recibo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJDEPURA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: COUNT(*)
  oCol:=oNMTRABJDEPURA:oBrw:aCols[7]
  oCol:cHeader      :='Cant.'+CRLF+'Recibos'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJDEPURA:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMTRABJDEPURA:oBrw:aArrayData[oNMTRABJDEPURA:oBrw:nArrayAt,7],;
                              oCol  := oNMTRABJDEPURA:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


   oNMTRABJDEPURA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMTRABJDEPURA:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oNMTRABJDEPURA:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oNMTRABJDEPURA:nClrText,;
                                                 nClrText:=IF(.F.,oNMTRABJDEPURA:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oNMTRABJDEPURA:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oNMTRABJDEPURA:nClrPane1, oNMTRABJDEPURA:nClrPane2 ) } }

//   oNMTRABJDEPURA:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oNMTRABJDEPURA:oBrw:bClrFooter            := {|| {0,14671839 }}

   oNMTRABJDEPURA:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMTRABJDEPURA:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oNMTRABJDEPURA:oBrw:bLDblClick:={|oBrw|oNMTRABJDEPURA:RUNCLICK() }

   oNMTRABJDEPURA:oBrw:bChange:={||oNMTRABJDEPURA:BRWCHANGE()}
   oNMTRABJDEPURA:oBrw:CreateFromCode()


   oNMTRABJDEPURA:oWnd:oClient := oNMTRABJDEPURA:oBrw



   oNMTRABJDEPURA:Activate({||oNMTRABJDEPURA:ViewDatBar()})

   oNMTRABJDEPURA:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMTRABJDEPURA:lTmdi,oNMTRABJDEPURA:oWnd,oNMTRABJDEPURA:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oNMTRABJDEPURA:oBrw:nWidth()

   oNMTRABJDEPURA:oBrw:GoBottom(.T.)
   oNMTRABJDEPURA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMTRABJDEPURA.EDT")
     oNMTRABJDEPURA:oBrw:Move(44,0,1466+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oNMTRABJDEPURA:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oNMTRABJDEPURA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMTRABJDEPURA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMTRABJDEPURA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMTRABJDEPURA:oBrw,"NMTRABJDEPURA",oNMTRABJDEPURA:cSql,oNMTRABJDEPURA:nPeriodo,oNMTRABJDEPURA:dDesde,oNMTRABJDEPURA:dHasta,oNMTRABJDEPURA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMTRABJDEPURA:oBtnRun:=oBtn



       oNMTRABJDEPURA:oBrw:bLDblClick:={||EVAL(oNMTRABJDEPURA:oBtnRun:bAction) }


   ENDIF




IF oNMTRABJDEPURA:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oNMTRABJDEPURA");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oNMTRABJDEPURA:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oNMTRABJDEPURA:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA:oFrm)
ENDIF

IF oNMTRABJDEPURA:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oNMTRABJDEPURA),;
                  EJECUTAR("DPBRWMENURUN",oNMTRABJDEPURA,oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA:cBrwCod,oNMTRABJDEPURA:cTitle,oNMTRABJDEPURA:aHead));
          WHEN !Empty(oNMTRABJDEPURA:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oNMTRABJDEPURA:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMTRABJDEPURA:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oNMTRABJDEPURA:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA);
          ACTION EJECUTAR("BRWSETFILTER",oNMTRABJDEPURA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oNMTRABJDEPURA:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMTRABJDEPURA:oBrw);
          WHEN LEN(oNMTRABJDEPURA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oNMTRABJDEPURA:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMTRABJDEPURA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oNMTRABJDEPURA:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMTRABJDEPURA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oNMTRABJDEPURA:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA:cTitle,oNMTRABJDEPURA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMTRABJDEPURA:oBtnXls:=oBtn

ENDIF

IF oNMTRABJDEPURA:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oNMTRABJDEPURA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oNMTRABJDEPURA:oBrw,NIL,oNMTRABJDEPURA:cTitle,oNMTRABJDEPURA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oNMTRABJDEPURA:oBtnHtml:=oBtn

ENDIF


IF oNMTRABJDEPURA:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMTRABJDEPURA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMTRABJDEPURA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMTRABJDEPURA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMTRABJDEPURA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMTRABJDEPURA:oBtnPrint:=oBtn

   ENDIF

IF oNMTRABJDEPURA:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMTRABJDEPURA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMTRABJDEPURA:oBrw:GoTop(),oNMTRABJDEPURA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oNMTRABJDEPURA:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oNMTRABJDEPURA:oBrw:PageDown(),oNMTRABJDEPURA:oBrw:Setfocus())
  ENDIF

  IF  oNMTRABJDEPURA:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oNMTRABJDEPURA:oBrw:PageUp(),oNMTRABJDEPURA:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMTRABJDEPURA:oBrw:GoBottom(),oNMTRABJDEPURA:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMTRABJDEPURA:Close()

  oNMTRABJDEPURA:oBrw:SetColor(0,oNMTRABJDEPURA:nClrPane1)

  oNMTRABJDEPURA:SETBTNBAR(40,40,oBar)


  EVAL(oNMTRABJDEPURA:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMTRABJDEPURA:oBar:=oBar

    nCol:=1106
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oNMTRABJDEPURA:oPeriodo  VAR oNMTRABJDEPURA:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oNMTRABJDEPURA:LEEFECHAS();
                WHEN oNMTRABJDEPURA:lWhen


  ComboIni(oNMTRABJDEPURA:oPeriodo )

  @ nLin, nCol+103 BUTTON oNMTRABJDEPURA:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMTRABJDEPURA:oPeriodo:nAt,oNMTRABJDEPURA:oDesde,oNMTRABJDEPURA:oHasta,-1),;
                         EVAL(oNMTRABJDEPURA:oBtn:bAction));
                WHEN oNMTRABJDEPURA:lWhen


  @ nLin, nCol+130 BUTTON oNMTRABJDEPURA:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMTRABJDEPURA:oPeriodo:nAt,oNMTRABJDEPURA:oDesde,oNMTRABJDEPURA:oHasta,+1),;
                         EVAL(oNMTRABJDEPURA:oBtn:bAction));
                WHEN oNMTRABJDEPURA:lWhen


  @ nLin, nCol+160 BMPGET oNMTRABJDEPURA:oDesde  VAR oNMTRABJDEPURA:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMTRABJDEPURA:oDesde ,oNMTRABJDEPURA:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oNMTRABJDEPURA:oPeriodo:nAt=LEN(oNMTRABJDEPURA:oPeriodo:aItems) .AND. oNMTRABJDEPURA:lWhen ;
                FONT oFont

   oNMTRABJDEPURA:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oNMTRABJDEPURA:oHasta  VAR oNMTRABJDEPURA:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMTRABJDEPURA:oHasta,oNMTRABJDEPURA:dHasta);
                SIZE 76-2,24;
                WHEN oNMTRABJDEPURA:oPeriodo:nAt=LEN(oNMTRABJDEPURA:oPeriodo:aItems) .AND. oNMTRABJDEPURA:lWhen ;
                OF oBar;
                FONT oFont

   oNMTRABJDEPURA:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oNMTRABJDEPURA:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oNMTRABJDEPURA:oPeriodo:nAt=LEN(oNMTRABJDEPURA:oPeriodo:aItems);
               ACTION oNMTRABJDEPURA:HACERWHERE(oNMTRABJDEPURA:dDesde,oNMTRABJDEPURA:dHasta,oNMTRABJDEPURA:cWhere,.T.);
               WHEN oNMTRABJDEPURA:lWhen

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

  oRep:=REPORTE("BRNMTRABJDEPURA",cWhere)
  oRep:cSql  :=oNMTRABJDEPURA:cSql
  oRep:cTitle:=oNMTRABJDEPURA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMTRABJDEPURA:oPeriodo:nAt,cWhere

  oNMTRABJDEPURA:nPeriodo:=nPeriodo


  IF oNMTRABJDEPURA:oPeriodo:nAt=LEN(oNMTRABJDEPURA:oPeriodo:aItems)

     oNMTRABJDEPURA:oDesde:ForWhen(.T.)
     oNMTRABJDEPURA:oHasta:ForWhen(.T.)
     oNMTRABJDEPURA:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMTRABJDEPURA:oDesde)

  ELSE

     oNMTRABJDEPURA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMTRABJDEPURA:oDesde:VarPut(oNMTRABJDEPURA:aFechas[1] , .T. )
     oNMTRABJDEPURA:oHasta:VarPut(oNMTRABJDEPURA:aFechas[2] , .T. )

     oNMTRABJDEPURA:dDesde:=oNMTRABJDEPURA:aFechas[1]
     oNMTRABJDEPURA:dHasta:=oNMTRABJDEPURA:aFechas[2]

     cWhere:=oNMTRABJDEPURA:HACERWHERE(oNMTRABJDEPURA:dDesde,oNMTRABJDEPURA:dHasta,oNMTRABJDEPURA:cWhere,.T.)

     oNMTRABJDEPURA:LEERDATA(cWhere,oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA:cServer,oNMTRABJDEPURA)

  ENDIF

  oNMTRABJDEPURA:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "NMTRABAJADOR.FECHA_EGR"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('NMTRABAJADOR.FECHA_EGR',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('NMTRABAJADOR.FECHA_EGR',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oNMTRABJDEPURA:cWhereQry)
       cWhere:=cWhere + oNMTRABJDEPURA:cWhereQry
     ENDIF

     oNMTRABJDEPURA:LEERDATA(cWhere,oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA:cServer,oNMTRABJDEPURA)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oNMTRABJDEPURA)
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
          "  CODIGO, "+;
          "  TRA_NOMAPL, "+;
          "  FECHA_ING, "+;
          "  FECHA_EGR, "+;
          "  CONDICION, "+;
          "  MAX(REC_FECHAS) AS REC_ULTFCH, "+;
          "  COUNT(*) "+;
          "  FROM nmtrabajador "+;
          "  INNER JOIN NMRECIBOS ON CODIGO=REC_CODTRA "+;
          "  WHERE (CONDICION='I' OR CONDICION='L')  "+;
          "  GROUP BY CODIGO "+;
          "  ORDER BY FECHA_EGR"+;
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

   DPWRITE("TEMP\BRNMTRABJDEPURA.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',CTOD(""),CTOD(""),'',CTOD(""),0})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,5]:=SAYOPTIONS("nmtrabajador","CONDICION",a[5])})

   IF ValType(oBrw)="O"

      oNMTRABJDEPURA:cSql   :=cSql
      oNMTRABJDEPURA:cWhere_:=cWhere

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
      AEVAL(oNMTRABJDEPURA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMTRABJDEPURA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMTRABJDEPURA.MEM",V_nPeriodo:=oNMTRABJDEPURA:nPeriodo
  LOCAL V_dDesde:=oNMTRABJDEPURA:dDesde
  LOCAL V_dHasta:=oNMTRABJDEPURA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMTRABJDEPURA)
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


    IF Type("oNMTRABJDEPURA")="O" .AND. oNMTRABJDEPURA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMTRABJDEPURA:cWhere_),oNMTRABJDEPURA:cWhere_,oNMTRABJDEPURA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oNMTRABJDEPURA:LEERDATA(oNMTRABJDEPURA:cWhere_,oNMTRABJDEPURA:oBrw,oNMTRABJDEPURA:cServer)
      oNMTRABJDEPURA:oWnd:Show()
      oNMTRABJDEPURA:oWnd:Restore()

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

   oNMTRABJDEPURA:aHead:=EJECUTAR("HTMLHEAD",oNMTRABJDEPURA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oNMTRABJDEPURA)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

