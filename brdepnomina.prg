// Programa   : BRDEPNOMINA
// Fecha/Hora : 03/12/2021 12:41:15
// Propósito  : "Depurar Registros de Nómina"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRDEPNOMINA.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oDEPNOMINA")="O" .AND. oDEPNOMINA:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDEPNOMINA,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Depurar Registros de Nómina" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oDEPNOMINA

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oDEPNOMINA","BRDEPNOMINA.EDT")
// oDEPNOMINA:CreateWindow(0,0,100,550)
   oDEPNOMINA:Windows(0,0,aCoors[3]-160,MIN(708,aCoors[4]-10),.T.) // Maximizado



   oDEPNOMINA:cCodSuc  :=cCodSuc
   oDEPNOMINA:lMsgBar  :=.F.
   oDEPNOMINA:cPeriodo :=aPeriodos[nPeriodo]
   oDEPNOMINA:cCodSuc  :=cCodSuc
   oDEPNOMINA:nPeriodo :=nPeriodo
   oDEPNOMINA:cNombre  :=""
   oDEPNOMINA:dDesde   :=dDesde
   oDEPNOMINA:cServer  :=cServer
   oDEPNOMINA:dHasta   :=dHasta
   oDEPNOMINA:cWhere   :=cWhere
   oDEPNOMINA:cWhere_  :=cWhere_
   oDEPNOMINA:cWhereQry:=""
   oDEPNOMINA:cSql     :=oDp:cSql
   oDEPNOMINA:oWhere   :=TWHERE():New(oDEPNOMINA)
   oDEPNOMINA:cCodPar  :=cCodPar // Código del Parámetro
   oDEPNOMINA:lWhen    :=.T.
   oDEPNOMINA:cTextTit :="" // Texto del Titulo Heredado
   oDEPNOMINA:oDb      :=oDp:oDb
   oDEPNOMINA:cBrwCod  :="DEPNOMINA"
   oDEPNOMINA:lTmdi    :=.T.
   oDEPNOMINA:aHead    :={}
   oDEPNOMINA:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oDEPNOMINA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDEPNOMINA)}

   oDEPNOMINA:lBtnRun     :=.F.
   oDEPNOMINA:lBtnMenuBrw :=.F.
   oDEPNOMINA:lBtnSave    :=.F.
   oDEPNOMINA:lBtnCrystal :=.F.
   oDEPNOMINA:lBtnRefresh :=.F.
   oDEPNOMINA:lBtnHtml    :=.T.
   oDEPNOMINA:lBtnExcel   :=.T.
   oDEPNOMINA:lBtnPreview :=.T.
   oDEPNOMINA:lBtnQuery   :=.F.
   oDEPNOMINA:lBtnOptions :=.T.
   oDEPNOMINA:lBtnPageDown:=.T.
   oDEPNOMINA:lBtnPageUp  :=.T.
   oDEPNOMINA:lBtnFilters :=.T.
   oDEPNOMINA:lBtnFind    :=.T.

   oDEPNOMINA:nClrPane1:=16775408
   oDEPNOMINA:nClrPane2:=16771797

   oDEPNOMINA:nClrText :=0
   oDEPNOMINA:nClrText1:=0
   oDEPNOMINA:nClrText2:=0
   oDEPNOMINA:nClrText3:=0




   oDEPNOMINA:oBrw:=TXBrowse():New( IF(oDEPNOMINA:lTmdi,oDEPNOMINA:oWnd,oDEPNOMINA:oDlg ))
   oDEPNOMINA:oBrw:SetArray( aData, .F. )
   oDEPNOMINA:oBrw:SetFont(oFont)

   oDEPNOMINA:oBrw:lFooter     := .T.
   oDEPNOMINA:oBrw:lHScroll    := .F.
   oDEPNOMINA:oBrw:nHeaderLines:= 2
   oDEPNOMINA:oBrw:nDataLines  := 1
   oDEPNOMINA:oBrw:nFooterLines:= 1




   oDEPNOMINA:aData            :=ACLONE(aData)

   AEVAL(oDEPNOMINA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: CODIGO
  oCol:=oDEPNOMINA:oBrw:aCols[1]
  oCol:cHeader      :='Codigo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPNOMINA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: APELLIDO
  oCol:=oDEPNOMINA:oBrw:aCols[2]
  oCol:cHeader      :='Apellido'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPNOMINA:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  // Campo: NOMBRE
  oCol:=oDEPNOMINA:oBrw:aCols[3]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPNOMINA:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  // Campo: CONDICION
  oCol:=oDEPNOMINA:oBrw:aCols[4]
  oCol:cHeader      :='Condición'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPNOMINA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
oCol:bClrStd  := {|nClrText,uValue|uValue:=oDEPNOMINA:oBrw:aArrayData[oDEPNOMINA:oBrw:nArrayAt,4],;
                     nClrText:=COLOR_OPTIONS("NMTRABAJADOR ","CONDICION",uValue),;
                     {nClrText,iif( oDEPNOMINA:oBrw:nArrayAt%2=0, oDEPNOMINA:nClrPane1, oDEPNOMINA:nClrPane2 ) } } 

  // Campo: FECHA_ING
  oCol:=oDEPNOMINA:oBrw:aCols[5]
  oCol:cHeader      :='Fecha'+CRLF+'Ingreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPNOMINA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: FECHA_EGR
  oCol:=oDEPNOMINA:oBrw:aCols[6]
  oCol:cHeader      :='Fecha'+CRLF+'Egreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPNOMINA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: LOGICO
  oCol:=oDEPNOMINA:oBrw:aCols[7]
  oCol:cHeader      :='Sel.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPNOMINA:oBrw:aArrayData ) } 
  oCol:nWidth       := 35
  // Campo: LOGICO
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oDEPNOMINA:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,7],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}
 oCol:bLDClickData:={||oDEPNOMINA:oBrw:aArrayData[oDEPNOMINA:oBrw:nArrayAt,7]:=!oDEPNOMINA:oBrw:aArrayData[oDEPNOMINA:oBrw:nArrayAt,7],oDEPNOMINA:oBrw:DrawLine(.T.)} 
 oCol:bStrData    :={||""}
 oCol:bLClickHeader:={||oDp:lSel:=!oDEPNOMINA:oBrw:aArrayData[1,7],; 
 AEVAL(oDEPNOMINA:oBrw:aArrayData,{|a,n| oDEPNOMINA:oBrw:aArrayData[n,7]:=oDp:lSel}),oDEPNOMINA:oBrw:Refresh(.T.)} 

   oDEPNOMINA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDEPNOMINA:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oDEPNOMINA:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oDEPNOMINA:nClrText,;
                                                 nClrText:=IF(.F.,oDEPNOMINA:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oDEPNOMINA:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oDEPNOMINA:nClrPane1, oDEPNOMINA:nClrPane2 ) } }

//   oDEPNOMINA:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oDEPNOMINA:oBrw:bClrFooter            := {|| {0,14671839 }}

   oDEPNOMINA:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDEPNOMINA:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oDEPNOMINA:oBrw:bLDblClick:={|oBrw|oDEPNOMINA:RUNCLICK() }

   oDEPNOMINA:oBrw:bChange:={||oDEPNOMINA:BRWCHANGE()}
   oDEPNOMINA:oBrw:CreateFromCode()


   oDEPNOMINA:oWnd:oClient := oDEPNOMINA:oBrw



   oDEPNOMINA:Activate({||oDEPNOMINA:ViewDatBar()})

   oDEPNOMINA:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDEPNOMINA:lTmdi,oDEPNOMINA:oWnd,oDEPNOMINA:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oDEPNOMINA:oBrw:nWidth()

   oDEPNOMINA:oBrw:GoBottom(.T.)
   oDEPNOMINA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRDEPNOMINA.EDT")
     oDEPNOMINA:oBrw:Move(44,0,708+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oDEPNOMINA:INIDEPURA()

   oBtn:cToolTip:="Iniciar Depuración"


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\TRABAJADOR.BMP";
            ACTION EJECUTAR("NMTRABAJADOR",0,oDEPNOMINA:oBrw:aArrayData[oDEPNOMINA:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Ficha del Trabajador"

  DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("NMTRABAJADORCON",NIL,oDEPNOMINA:oBrw:aArrayData[oDEPNOMINA:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Consultar Ficha del Trabajador"


   IF .F. .AND. Empty(oDEPNOMINA:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oDEPNOMINA:oBrw,oDEPNOMINA:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oDEPNOMINA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","DEPNOMINA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DEPNOMINA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oDEPNOMINA:oBrw,"DEPNOMINA",oDEPNOMINA:cSql,oDEPNOMINA:nPeriodo,oDEPNOMINA:dDesde,oDEPNOMINA:dHasta,oDEPNOMINA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oDEPNOMINA:oBtnRun:=oBtn



       oDEPNOMINA:oBrw:bLDblClick:={||EVAL(oDEPNOMINA:oBtnRun:bAction) }


   ENDIF




IF oDEPNOMINA:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oDEPNOMINA");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oDEPNOMINA:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oDEPNOMINA:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oDEPNOMINA:oBrw,oDEPNOMINA:oFrm)
ENDIF

IF oDEPNOMINA:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oDEPNOMINA),;
                  EJECUTAR("DPBRWMENURUN",oDEPNOMINA,oDEPNOMINA:oBrw,oDEPNOMINA:cBrwCod,oDEPNOMINA:cTitle,oDEPNOMINA:aHead));
          WHEN !Empty(oDEPNOMINA:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oDEPNOMINA:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oDEPNOMINA:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oDEPNOMINA:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oDEPNOMINA:oBrw,oDEPNOMINA);
          ACTION EJECUTAR("BRWSETFILTER",oDEPNOMINA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oDEPNOMINA:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oDEPNOMINA:oBrw);
          WHEN LEN(oDEPNOMINA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oDEPNOMINA:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oDEPNOMINA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oDEPNOMINA:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oDEPNOMINA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oDEPNOMINA:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oDEPNOMINA:oBrw,oDEPNOMINA:cTitle,oDEPNOMINA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oDEPNOMINA:oBtnXls:=oBtn

ENDIF

IF oDEPNOMINA:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oDEPNOMINA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oDEPNOMINA:oBrw,NIL,oDEPNOMINA:cTitle,oDEPNOMINA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oDEPNOMINA:oBtnHtml:=oBtn

ENDIF


IF oDEPNOMINA:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oDEPNOMINA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDEPNOMINA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDEPNOMINA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oDEPNOMINA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDEPNOMINA:oBtnPrint:=oBtn

   ENDIF

IF oDEPNOMINA:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDEPNOMINA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oDEPNOMINA:oBrw:GoTop(),oDEPNOMINA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oDEPNOMINA:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oDEPNOMINA:oBrw:PageDown(),oDEPNOMINA:oBrw:Setfocus())
  ENDIF

  IF  oDEPNOMINA:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oDEPNOMINA:oBrw:PageUp(),oDEPNOMINA:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDEPNOMINA:oBrw:GoBottom(),oDEPNOMINA:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDEPNOMINA:Close()

  oDEPNOMINA:oBrw:SetColor(0,oDEPNOMINA:nClrPane1)

  oDEPNOMINA:SETBTNBAR(40,40,oBar)


  EVAL(oDEPNOMINA:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDEPNOMINA:oBar:=oBar

    nCol:=348
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oDEPNOMINA:oPeriodo  VAR oDEPNOMINA:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oDEPNOMINA:LEEFECHAS();
                WHEN oDEPNOMINA:lWhen


  ComboIni(oDEPNOMINA:oPeriodo )

  @ nLin, nCol+103 BUTTON oDEPNOMINA:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDEPNOMINA:oPeriodo:nAt,oDEPNOMINA:oDesde,oDEPNOMINA:oHasta,-1),;
                         EVAL(oDEPNOMINA:oBtn:bAction));
                WHEN oDEPNOMINA:lWhen


  @ nLin, nCol+130 BUTTON oDEPNOMINA:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDEPNOMINA:oPeriodo:nAt,oDEPNOMINA:oDesde,oDEPNOMINA:oHasta,+1),;
                         EVAL(oDEPNOMINA:oBtn:bAction));
                WHEN oDEPNOMINA:lWhen


  @ nLin, nCol+160 BMPGET oDEPNOMINA:oDesde  VAR oDEPNOMINA:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDEPNOMINA:oDesde ,oDEPNOMINA:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oDEPNOMINA:oPeriodo:nAt=LEN(oDEPNOMINA:oPeriodo:aItems) .AND. oDEPNOMINA:lWhen ;
                FONT oFont

   oDEPNOMINA:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oDEPNOMINA:oHasta  VAR oDEPNOMINA:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDEPNOMINA:oHasta,oDEPNOMINA:dHasta);
                SIZE 76-2,24;
                WHEN oDEPNOMINA:oPeriodo:nAt=LEN(oDEPNOMINA:oPeriodo:aItems) .AND. oDEPNOMINA:lWhen ;
                OF oBar;
                FONT oFont

   oDEPNOMINA:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oDEPNOMINA:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oDEPNOMINA:oPeriodo:nAt=LEN(oDEPNOMINA:oPeriodo:aItems);
               ACTION oDEPNOMINA:HACERWHERE(oDEPNOMINA:dDesde,oDEPNOMINA:dHasta,oDEPNOMINA:cWhere,.T.);
               WHEN oDEPNOMINA:lWhen

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

  oRep:=REPORTE("BRDEPNOMINA",cWhere)
  oRep:cSql  :=oDEPNOMINA:cSql
  oRep:cTitle:=oDEPNOMINA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDEPNOMINA:oPeriodo:nAt,cWhere

  oDEPNOMINA:nPeriodo:=nPeriodo


  IF oDEPNOMINA:oPeriodo:nAt=LEN(oDEPNOMINA:oPeriodo:aItems)

     oDEPNOMINA:oDesde:ForWhen(.T.)
     oDEPNOMINA:oHasta:ForWhen(.T.)
     oDEPNOMINA:oBtn  :ForWhen(.T.)

     DPFOCUS(oDEPNOMINA:oDesde)

  ELSE

     oDEPNOMINA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDEPNOMINA:oDesde:VarPut(oDEPNOMINA:aFechas[1] , .T. )
     oDEPNOMINA:oHasta:VarPut(oDEPNOMINA:aFechas[2] , .T. )

     oDEPNOMINA:dDesde:=oDEPNOMINA:aFechas[1]
     oDEPNOMINA:dHasta:=oDEPNOMINA:aFechas[2]

     cWhere:=oDEPNOMINA:HACERWHERE(oDEPNOMINA:dDesde,oDEPNOMINA:dHasta,oDEPNOMINA:cWhere,.T.)

     oDEPNOMINA:LEERDATA(cWhere,oDEPNOMINA:oBrw,oDEPNOMINA:cServer,oDEPNOMINA)

  ENDIF

  oDEPNOMINA:SAVEPERIODO()

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

     IF !Empty(oDEPNOMINA:cWhereQry)
       cWhere:=cWhere + oDEPNOMINA:cWhereQry
     ENDIF

     oDEPNOMINA:LEERDATA(cWhere,oDEPNOMINA:oBrw,oDEPNOMINA:cServer,oDEPNOMINA)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oDEPNOMINA)
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

   cSql:=" SELECT CODIGO,APELLIDO,NOMBRE,CONDICION, FECHA_ING,FECHA_EGR, 1 AS LOGICO "+;
          "   FROM NMTRABAJADOR "+;
          "   WHERE (LEFT(CONDICION,1)='L' OR LEFT(CONDICION,1)='I')"+;
          "   ORDER BY FECHA_ING "+;
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


   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRDEPNOMINA.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','',CTOD(""),CTOD(""),0})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,4]:=SAYOPTIONS("NMTRABAJADOR","CONDICION",a[4])})

   IF ValType(oBrw)="O"

      oDEPNOMINA:cSql   :=cSql
      oDEPNOMINA:cWhere_:=cWhere

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
      AEVAL(oDEPNOMINA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDEPNOMINA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDEPNOMINA.MEM",V_nPeriodo:=oDEPNOMINA:nPeriodo
  LOCAL V_dDesde:=oDEPNOMINA:dDesde
  LOCAL V_dHasta:=oDEPNOMINA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDEPNOMINA)
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


    IF Type("oDEPNOMINA")="O" .AND. oDEPNOMINA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDEPNOMINA:cWhere_),oDEPNOMINA:cWhere_,oDEPNOMINA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oDEPNOMINA:LEERDATA(oDEPNOMINA:cWhere_,oDEPNOMINA:oBrw,oDEPNOMINA:cServer)
      oDEPNOMINA:oWnd:Show()
      oDEPNOMINA:oWnd:Restore()

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

   oDEPNOMINA:aHead:=EJECUTAR("HTMLHEAD",oDEPNOMINA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oDEPNOMINA)
RETURN .T.

FUNCTION INIDEPURA()   
   LOCAL aData:=ACLONE(oDEPNOMINA:oBrw:aArrayData),I
   LOCAL aCodigos:={},cWhere,cCodigo,cSql
   LOCAL oTrab,oTrab_New,oRec,oRec_New,oHis,oHis_New

   aData:=ADEPURA(aData,{|a,n| !a[7]})
  
   IF !MsgNoYes("Desea Remover "+LSTR(LEN(aData))+" Registro(s)"," Depuración de Registros")
      RETURN .F.
   ENDIF

   DpMsgRun("Tablas","Actualizando Estructuras",NIL,3)

   IF !EJECUTAR("DBISTABLE",NIL,"NMTRABAJADOR_HIS",.F.)
      EJECUTAR("DPTABLEHIS","NMTRABAJADOR",oDp:cDsnData,"_HIS",.F.)
   ENDIF

   DpMsgSet(1,.T.,NIL,"Tabla=Trabajadores")

   EJECUTAR("DPTABLEHISUPDATE","NMTRABAJADOR","NMTRABAJADOR_HIS")

   IF !EJECUTAR("DBISTABLE",NIL,"NMRECIBOS_HIS")
      EJECUTAR("DPTABLEHIS","NMRECIBOS",oDp:cDsnData,"_HIS",.F.)
   ENDIF

   DpMsgSet(1,.T.,NIL,"Tabla=Recibos")
   EJECUTAR("DPTABLEHISUPDATE","NMRECIBOS","NMRECIBOS_HIS")

   IF !EJECUTAR("DBISTABLE",NIL,"NMHISTORICO_HIS")
      EJECUTAR("DPTABLEHIS","NMHISTORICO",oDp:cDsnData,"_HIS",.F.)
   ENDIF

   DpMsgSet(1,.T.,NIL,"Tabla=Histórico")
   EJECUTAR("DPTABLEHISUPDATE","NMHISTORICO","NMHISTORICO_HIS")

   DpMsgRun("Trabajadores","Removiendo Registros",NIL,LEN(aData))
   DpMsgSetTotal(LEN(aData))


   AEVAL(aData,{|a,n| AADD(aCodigos,a[1])})
   cWhere:=GetWhereOr("CODIGO",aCodigos)

   oTrab    :=OpenTable("SELECT * FROM NMTRABAJADOR     WHERE "+cWhere,.T.)
   oTrab_new:=OpenTable("SELECT * FROM NMTRABAJADOR_HIS",.F.)

   oRec_new :=OpenTable("SELECT * FROM NMRECIBOS_HIS",.F.)
   oHis_new :=OpenTable("SELECT * FROM NMHISTORICO_HIS",.F.)

// cSql:=" SET FOREIGN_KEY_CHECKS = 0"
// oTrab:Execute(cSql)
// oTrab:Browse()
// ? cWhere,oTrab_new:ClassName()

   WHILE !oTrab:Eof()

     I:=oTrab:Recno()
     cCodigo:=oTrab:CODIGO

     DpMsgSet(I,.T.,NIL,"Código: "+cCodigo)

     oTrab_new:AppendBlank()
     AEVAL(oTrab:aFields,{|a,n| oTrab_new:Replace(a[1],oTrab:FieldGet(n))})
     oTrab_new:Commit("")

     oRec:=OpenTable("SELECT * FROM NMRECIBOS WHERE REC_CODTRA"+GetWhere("=",cCodigo),.T.)

     DpMsgSet(I,.T.,NIL,"Código: "+oTrab:CODIGO+" Recibos "+LSTR(oRec:RecCount()))

     WHILE !oRec:Eof()
        oRec_new:AppendBlank()
        AEVAL(oRec:aFields,{|a,n| oRec_new:Replace(a[1],oRec:FieldGet(n))})
        oRec_new:Commit("")
        oRec:DbSkip()
     ENDDO
     oRec:End()

     cSql:=" "+SELECTFROM("NMHISTORICO",.T.)+;
           " INNER JOIN NMRECIBOS ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+; 
           " WHERE REC_CODTRA"+GetWhere("=",oTrab:CODIGO)

     oHis:=OpenTable("SELECT * FROM NMRECIBOS WHERE REC_CODTRA"+GetWhere("=",cCodigo),.T.)

     DpMsgSet(I,.T.,NIL,"Código: "+cCodigo+" Históricos "+LSTR(oHis:RecCount()))

     oHis:=OpenTable(cSql,.T.)

     WHILE !oHis:Eof()

        IF oHis:RecNo()%10=0
          DpMsgSet(I,.T.,NIL,"Código: "+oTrab:CODIGO+" Históricos "+LSTR(oHis:RecNo())+"/"+LSTR(oHis:RecCount()))
        ENDIF

        oHis_new:AppendBlank()
        AEVAL(oHis:aFields,{|a,n| oHis_new:Replace(a[1],oHis:FieldGet(n))})
        oHis_new:Commit("")

        SQLDELETE("NMHISTORICO","HIS_CODSUC"+GetWhere("=",oHis:HIS_CODSUC)+" AND "+;
                                "HIS_NUMREC"+GetWhere("=",oHis:HIS_NUMREC))

        oHis:DbSkip()

     ENDDO

//   cSql:="DELETE nmhistorico FROM nmhistorico INNER JOIN NMRECIBOS ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC WHERE REC_CODTRA"+GetWhere("=",oTrab:CODIGO)
//   oHis:EXECUTE(cSql)

     oHis:End()

     SQLDELETE("NMVARIAC" ,"VAR_CODTRA"+GetWhere("=",oTrab:CODIGO))
     SQLDELETE("NMGRABAR" ,"GRA_CODTRA"+GetWhere("=",oTrab:CODIGO))
     SQLDELETE("NMRECIBOS","REC_CODTRA"+GetWhere("=",oTrab:CODIGO))
     SQLDELETE("NMTABLIQ" ,"LIQ_CODTRA"+GetWhere("=",oTrab:CODIGO))
     SQLDELETE("NMTABVAC" ,"TAB_CODTRA"+GetWhere("=",oTrab:CODIGO))
     SQLDELETE("NMRESTRA" ,"RMT_CODTRA"+GetWhere("=",oTrab:CODIGO))
             
     SQLDELETE("NMTRABAJADOR","CODIGO"    +GetWhere("=",oTrab:CODIGO))

     oTrab:DbSkip()

   ENDDO

//   cSql:=" SET FOREIGN_KEY_CHECKS = 1"
//   oTrab:Execute(cSql)

   oTrab:End()
   oTrab_new:End()
   oRec_new:End()
   oHis_new:End()

   DpMsgClose()

   oDEPNOMINA:BRWREFRESCAR()

RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

