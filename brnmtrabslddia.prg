// Programa   : BRNMTRABSLDDIA
// Fecha/Hora : 21/09/2020 09:19:45
// Propósito  : "Trabajadores con Sueldo Diario"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMTRABSLDDIA.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oNMTRABSLDDIA")="O" .AND. oNMTRABSLDDIA:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oNMTRABSLDDIA,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Trabajadores con Sueldo Diario" +IF(Empty(cTitle),"",cTitle)

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

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oNMTRABSLDDIA

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oNMTRABSLDDIA","BRNMTRABSLDDIA.EDT")
// oNMTRABSLDDIA:CreateWindow(0,0,100,550)
   oNMTRABSLDDIA:Windows(0,0,aCoors[3]-160,MIN(654,aCoors[4]-10),.T.) // Maximizado



   oNMTRABSLDDIA:cCodSuc  :=cCodSuc
   oNMTRABSLDDIA:lMsgBar  :=.F.
   oNMTRABSLDDIA:cPeriodo :=aPeriodos[nPeriodo]
   oNMTRABSLDDIA:cCodSuc  :=cCodSuc
   oNMTRABSLDDIA:nPeriodo :=nPeriodo
   oNMTRABSLDDIA:cNombre  :=""
   oNMTRABSLDDIA:dDesde   :=dDesde
   oNMTRABSLDDIA:cServer  :=cServer
   oNMTRABSLDDIA:dHasta   :=dHasta
   oNMTRABSLDDIA:cWhere   :=cWhere
   oNMTRABSLDDIA:cWhere_  :=cWhere_
   oNMTRABSLDDIA:cWhereQry:=""
   oNMTRABSLDDIA:cSql     :=oDp:cSql
   oNMTRABSLDDIA:oWhere   :=TWHERE():New(oNMTRABSLDDIA)
   oNMTRABSLDDIA:cCodPar  :=cCodPar // Código del Parámetro
   oNMTRABSLDDIA:lWhen    :=.T.
   oNMTRABSLDDIA:cTextTit :="" // Texto del Titulo Heredado
   oNMTRABSLDDIA:oDb      :=oDp:oDb
   oNMTRABSLDDIA:cBrwCod  :="NMTRABSLDDIA"
   oNMTRABSLDDIA:lTmdi    :=.T.
   oNMTRABSLDDIA:aHead    :={}

   // Guarda los parámetros del Browse cuando cierra la ventana
   oNMTRABSLDDIA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMTRABSLDDIA)}

   oNMTRABSLDDIA:lBtnRun     :=.F.
   oNMTRABSLDDIA:lBtnMenuBrw :=.F.
   oNMTRABSLDDIA:lBtnSave    :=.F.
   oNMTRABSLDDIA:lBtnCrystal :=.F.
   oNMTRABSLDDIA:lBtnRefresh :=.F.
   oNMTRABSLDDIA:lBtnHtml    :=.T.
   oNMTRABSLDDIA:lBtnExcel   :=.T.
   oNMTRABSLDDIA:lBtnPreview :=.T.
   oNMTRABSLDDIA:lBtnQuery   :=.F.
   oNMTRABSLDDIA:lBtnOptions :=.T.
   oNMTRABSLDDIA:lBtnPageDown:=.T.
   oNMTRABSLDDIA:lBtnPageUp  :=.T.
   oNMTRABSLDDIA:lBtnFilters :=.T.
   oNMTRABSLDDIA:lBtnFind    :=.T.

   oNMTRABSLDDIA:nClrPane1:=16775666
   oNMTRABSLDDIA:nClrPane2:=16771545

   oNMTRABSLDDIA:nClrText :=0
   oNMTRABSLDDIA:nClrText1:=0
   oNMTRABSLDDIA:nClrText2:=0
   oNMTRABSLDDIA:nClrText3:=0




   oNMTRABSLDDIA:oBrw:=TXBrowse():New( IF(oNMTRABSLDDIA:lTmdi,oNMTRABSLDDIA:oWnd,oNMTRABSLDDIA:oDlg ))
   oNMTRABSLDDIA:oBrw:SetArray( aData, .F. )
   oNMTRABSLDDIA:oBrw:SetFont(oFont)

   oNMTRABSLDDIA:oBrw:lFooter     := .T.
   oNMTRABSLDDIA:oBrw:lHScroll    := .F.
   oNMTRABSLDDIA:oBrw:nHeaderLines:= 2
   oNMTRABSLDDIA:oBrw:nDataLines  := 1
   oNMTRABSLDDIA:oBrw:nFooterLines:= 1




   oNMTRABSLDDIA:aData            :=ACLONE(aData)

   AEVAL(oNMTRABSLDDIA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: CODIGO
  oCol:=oNMTRABSLDDIA:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABSLDDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: APELLIDO
  oCol:=oNMTRABSLDDIA:oBrw:aCols[2]
  oCol:cHeader      :='Apellido'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABSLDDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  // Campo: NOMBRE
  oCol:=oNMTRABSLDDIA:oBrw:aCols[3]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABSLDDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  // Campo: CAR_DESCRI
  oCol:=oNMTRABSLDDIA:oBrw:aCols[4]
  oCol:cHeader      :='Salario'+CRLF+'Diario'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABSLDDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 104

  // Campo: TRA_SALDIA
  oCol:=oNMTRABSLDDIA:oBrw:aCols[5]
  oCol:cHeader      :='Fecha'+CRLF+'Ingreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABSLDDIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMTRABSLDDIA:oBrw:aArrayData[oNMTRABSLDDIA:oBrw:nArrayAt,5],;
                              oCol  := oNMTRABSLDDIA:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}



   oNMTRABSLDDIA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMTRABSLDDIA:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oNMTRABSLDDIA:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oNMTRABSLDDIA:nClrText,;
                                                 nClrText:=IF(.F.,oNMTRABSLDDIA:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oNMTRABSLDDIA:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oNMTRABSLDDIA:nClrPane1, oNMTRABSLDDIA:nClrPane2 ) } }

//   oNMTRABSLDDIA:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oNMTRABSLDDIA:oBrw:bClrFooter            := {|| {0,14671839 }}

   oNMTRABSLDDIA:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMTRABSLDDIA:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oNMTRABSLDDIA:oBrw:bLDblClick:={|oBrw|oNMTRABSLDDIA:RUNCLICK() }

   oNMTRABSLDDIA:oBrw:bChange:={||oNMTRABSLDDIA:BRWCHANGE()}
   oNMTRABSLDDIA:oBrw:CreateFromCode()


   oNMTRABSLDDIA:oWnd:oClient := oNMTRABSLDDIA:oBrw



   oNMTRABSLDDIA:Activate({||oNMTRABSLDDIA:ViewDatBar()})

   oNMTRABSLDDIA:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMTRABSLDDIA:lTmdi,oNMTRABSLDDIA:oWnd,oNMTRABSLDDIA:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oNMTRABSLDDIA:oBrw:nWidth()

   oNMTRABSLDDIA:oBrw:GoBottom(.T.)
   oNMTRABSLDDIA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMTRABSLDDIA.EDT")
     oNMTRABSLDDIA:oBrw:Move(44,0,654+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oNMTRABSLDDIA:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oNMTRABSLDDIA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMTRABSLDDIA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMTRABSLDDIA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMTRABSLDDIA:oBrw,"NMTRABSLDDIA",oNMTRABSLDDIA:cSql,oNMTRABSLDDIA:nPeriodo,oNMTRABSLDDIA:dDesde,oNMTRABSLDDIA:dHasta,oNMTRABSLDDIA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMTRABSLDDIA:oBtnRun:=oBtn



       oNMTRABSLDDIA:oBrw:bLDblClick:={||EVAL(oNMTRABSLDDIA:oBtnRun:bAction) }


   ENDIF




IF oNMTRABSLDDIA:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oNMTRABSLDDIA");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oNMTRABSLDDIA:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oNMTRABSLDDIA:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA:oFrm)
ENDIF

IF oNMTRABSLDDIA:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oNMTRABSLDDIA),;
                  EJECUTAR("DPBRWMENURUN",oNMTRABSLDDIA,oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA:cBrwCod,oNMTRABSLDDIA:cTitle,oNMTRABSLDDIA:aHead));
          WHEN !Empty(oNMTRABSLDDIA:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oNMTRABSLDDIA:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMTRABSLDDIA:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oNMTRABSLDDIA:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA);
          ACTION EJECUTAR("BRWSETFILTER",oNMTRABSLDDIA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oNMTRABSLDDIA:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMTRABSLDDIA:oBrw);
          WHEN LEN(oNMTRABSLDDIA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oNMTRABSLDDIA:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMTRABSLDDIA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oNMTRABSLDDIA:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMTRABSLDDIA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oNMTRABSLDDIA:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA:cTitle,oNMTRABSLDDIA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMTRABSLDDIA:oBtnXls:=oBtn

ENDIF

IF oNMTRABSLDDIA:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oNMTRABSLDDIA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oNMTRABSLDDIA:oBrw,NIL,oNMTRABSLDDIA:cTitle,oNMTRABSLDDIA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oNMTRABSLDDIA:oBtnHtml:=oBtn

ENDIF


IF oNMTRABSLDDIA:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMTRABSLDDIA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMTRABSLDDIA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMTRABSLDDIA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMTRABSLDDIA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMTRABSLDDIA:oBtnPrint:=oBtn

   ENDIF

IF oNMTRABSLDDIA:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMTRABSLDDIA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMTRABSLDDIA:oBrw:GoTop(),oNMTRABSLDDIA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oNMTRABSLDDIA:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oNMTRABSLDDIA:oBrw:PageDown(),oNMTRABSLDDIA:oBrw:Setfocus())
  ENDIF

  IF  oNMTRABSLDDIA:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oNMTRABSLDDIA:oBrw:PageUp(),oNMTRABSLDDIA:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMTRABSLDDIA:oBrw:GoBottom(),oNMTRABSLDDIA:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMTRABSLDDIA:Close()

  oNMTRABSLDDIA:oBrw:SetColor(0,oNMTRABSLDDIA:nClrPane1)

  EVAL(oNMTRABSLDDIA:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMTRABSLDDIA:oBar:=oBar

  

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

  oRep:=REPORTE("BRNMTRABSLDDIA",cWhere)
  oRep:cSql  :=oNMTRABSLDDIA:cSql
  oRep:cTitle:=oNMTRABSLDDIA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMTRABSLDDIA:oPeriodo:nAt,cWhere

  oNMTRABSLDDIA:nPeriodo:=nPeriodo


  IF oNMTRABSLDDIA:oPeriodo:nAt=LEN(oNMTRABSLDDIA:oPeriodo:aItems)

     oNMTRABSLDDIA:oDesde:ForWhen(.T.)
     oNMTRABSLDDIA:oHasta:ForWhen(.T.)
     oNMTRABSLDDIA:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMTRABSLDDIA:oDesde)

  ELSE

     oNMTRABSLDDIA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMTRABSLDDIA:oDesde:VarPut(oNMTRABSLDDIA:aFechas[1] , .T. )
     oNMTRABSLDDIA:oHasta:VarPut(oNMTRABSLDDIA:aFechas[2] , .T. )

     oNMTRABSLDDIA:dDesde:=oNMTRABSLDDIA:aFechas[1]
     oNMTRABSLDDIA:dHasta:=oNMTRABSLDDIA:aFechas[2]

     cWhere:=oNMTRABSLDDIA:HACERWHERE(oNMTRABSLDDIA:dDesde,oNMTRABSLDDIA:dHasta,oNMTRABSLDDIA:cWhere,.T.)

     oNMTRABSLDDIA:LEERDATA(cWhere,oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA:cServer)

  ENDIF

  oNMTRABSLDDIA:SAVEPERIODO()

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

     IF !Empty(oNMTRABSLDDIA:cWhereQry)
       cWhere:=cWhere + oNMTRABSLDDIA:cWhereQry
     ENDIF

     oNMTRABSLDDIA:LEERDATA(cWhere,oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
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
          "  APELLIDO, "+;
          "  NOMBRE, "+;
          "  CAR_DESCRI, "+;
          "  SALARIO/IF(TIPO_NOM='S',1,30) AS TRA_SALDIA "+;
          "  FROM nmtrabajador "+;
          "  LEFT JOIN nmcargos ON CAR_CODIGO=COD_CARGO "+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" CONDICION='A'"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRNMTRABSLDDIA.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','',0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oNMTRABSLDDIA:cSql   :=cSql
      oNMTRABSLDDIA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
/*
      // 
      oCol:=oNMTRABSLDDIA:oBrw:aCols[5]
      
*/
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      // oNMTRABSLDDIA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

      // oBrw:Refresh(.T.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oNMTRABSLDDIA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMTRABSLDDIA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMTRABSLDDIA.MEM",V_nPeriodo:=oNMTRABSLDDIA:nPeriodo
  LOCAL V_dDesde:=oNMTRABSLDDIA:dDesde
  LOCAL V_dHasta:=oNMTRABSLDDIA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMTRABSLDDIA)
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


    IF Type("oNMTRABSLDDIA")="O" .AND. oNMTRABSLDDIA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMTRABSLDDIA:cWhere_),oNMTRABSLDDIA:cWhere_,oNMTRABSLDDIA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oNMTRABSLDDIA:LEERDATA(oNMTRABSLDDIA:cWhere_,oNMTRABSLDDIA:oBrw,oNMTRABSLDDIA:cServer)
      oNMTRABSLDDIA:oWnd:Show()
      oNMTRABSLDDIA:oWnd:Restore()

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

   oNMTRABSLDDIA:aHead:=EJECUTAR("HTMLHEAD",oNMTRABSLDDIA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oNMTRABSLDDIA)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

