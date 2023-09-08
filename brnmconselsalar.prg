// Programa   : BRNMCONSELSALAR
// Fecha/Hora : 10/12/2021 08:50:48
// Propósito  : "Seleccionar Conceptos que Inciden en los Salarios Promedios"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMCONSELSALAR.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oNMCONSELSALAR")="O" .AND. oNMCONSELSALAR:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oNMCONSELSALAR,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Seleccionar Conceptos que Inciden en los Salarios Promedios" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oNMCONSELSALAR

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oNMCONSELSALAR","BRNMCONSELSALAR.EDT")
// oNMCONSELSALAR:CreateWindow(0,0,100,550)
   oNMCONSELSALAR:Windows(0,0,aCoors[3]-160,MIN(828,aCoors[4]-10),.T.) // Maximizado



   oNMCONSELSALAR:cCodSuc  :=cCodSuc
   oNMCONSELSALAR:lMsgBar  :=.F.
   oNMCONSELSALAR:cPeriodo :=aPeriodos[nPeriodo]
   oNMCONSELSALAR:cCodSuc  :=cCodSuc
   oNMCONSELSALAR:nPeriodo :=nPeriodo
   oNMCONSELSALAR:cNombre  :=""
   oNMCONSELSALAR:dDesde   :=dDesde
   oNMCONSELSALAR:cServer  :=cServer
   oNMCONSELSALAR:dHasta   :=dHasta
   oNMCONSELSALAR:cWhere   :=cWhere
   oNMCONSELSALAR:cWhere_  :=cWhere_
   oNMCONSELSALAR:cWhereQry:=""
   oNMCONSELSALAR:cSql     :=oDp:cSql
   oNMCONSELSALAR:oWhere   :=TWHERE():New(oNMCONSELSALAR)
   oNMCONSELSALAR:cCodPar  :=cCodPar // Código del Parámetro
   oNMCONSELSALAR:lWhen    :=.T.
   oNMCONSELSALAR:cTextTit :="" // Texto del Titulo Heredado
   oNMCONSELSALAR:oDb      :=oDp:oDb
   oNMCONSELSALAR:cBrwCod  :="NMCONSELSALAR"
   oNMCONSELSALAR:lTmdi    :=.T.
   oNMCONSELSALAR:aHead    :={}
   oNMCONSELSALAR:lBarDef  :=.T. // Activar Modo Diseño.
   oNMCONSELSALAR:aFields  :={"CON_CODIGO","CON_DESCRI","CON_ACUM01","CON_ACUM02","CON_ACUM03","CON_ACUM04"}

   // Guarda los parámetros del Browse cuando cierra la ventana
   oNMCONSELSALAR:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMCONSELSALAR)}

   oNMCONSELSALAR:lBtnRun     :=.F.
   oNMCONSELSALAR:lBtnMenuBrw :=.F.
   oNMCONSELSALAR:lBtnSave    :=.F.
   oNMCONSELSALAR:lBtnCrystal :=.F.
   oNMCONSELSALAR:lBtnRefresh :=.F.
   oNMCONSELSALAR:lBtnHtml    :=.T.
   oNMCONSELSALAR:lBtnExcel   :=.T.
   oNMCONSELSALAR:lBtnPreview :=.T.
   oNMCONSELSALAR:lBtnQuery   :=.F.
   oNMCONSELSALAR:lBtnOptions :=.T.
   oNMCONSELSALAR:lBtnPageDown:=.T.
   oNMCONSELSALAR:lBtnPageUp  :=.T.
   oNMCONSELSALAR:lBtnFilters :=.T.
   oNMCONSELSALAR:lBtnFind    :=.T.

   oNMCONSELSALAR:nClrPane1:=16775408
   oNMCONSELSALAR:nClrPane2:=16771797

   oNMCONSELSALAR:nClrText :=0
   oNMCONSELSALAR:nClrText1:=0
   oNMCONSELSALAR:nClrText2:=0
   oNMCONSELSALAR:nClrText3:=0




   oNMCONSELSALAR:oBrw:=TXBrowse():New( IF(oNMCONSELSALAR:lTmdi,oNMCONSELSALAR:oWnd,oNMCONSELSALAR:oDlg ))
   oNMCONSELSALAR:oBrw:SetArray( aData, .F. )
   oNMCONSELSALAR:oBrw:SetFont(oFont)

   oNMCONSELSALAR:oBrw:lFooter     := .T.
   oNMCONSELSALAR:oBrw:lHScroll    := .F.
   oNMCONSELSALAR:oBrw:nHeaderLines:= 2
   oNMCONSELSALAR:oBrw:nDataLines  := 1
   oNMCONSELSALAR:oBrw:nFooterLines:= 1




   oNMCONSELSALAR:aData            :=ACLONE(aData)

   AEVAL(oNMCONSELSALAR:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: CON_CODIGO
  oCol:=oNMCONSELSALAR:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  // Campo: CON_DESCRI
  oCol:=oNMCONSELSALAR:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 480

  // Campo: CON_ACUM01
  oCol:=oNMCONSELSALAR:oBrw:aCols[3]
  oCol:cHeader      :='Básico'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 8
  // Campo: CON_ACUM01
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oNMCONSELSALAR:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,3],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}

  // Campo: CON_ACUM02
  oCol:=oNMCONSELSALAR:oBrw:aCols[4]
  oCol:cHeader      :='Integral'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 8
  // Campo: CON_ACUM02
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oNMCONSELSALAR:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,4],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}

  // Campo: CON_ACUM03
  oCol:=oNMCONSELSALAR:oBrw:aCols[5]
  oCol:cHeader      :='Utilidades'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 8
  // Campo: CON_ACUM03
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oNMCONSELSALAR:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,5],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}

  // Campo: CON_ACUM04
  oCol:=oNMCONSELSALAR:oBrw:aCols[6]
  oCol:cHeader      :='Vacaciones'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 8
  // Campo: CON_ACUM04
 oCol:AddBmpFile("BITMAPS\checkverde.bmp") 
 oCol:AddBmpFile("BITMAPS\checkrojo.bmp") 
 oCol:bBmpData    := { |oBrw|oBrw:=oNMCONSELSALAR:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,6],1,2) }
 oCol:nDataStyle  := oCol:DefStyle( AL_RIGHT, .F.) 
 oCol:bStrData    :={||""}

  // Campo: DESDE
  oCol:=oNMCONSELSALAR:oBrw:aCols[7]
  oCol:cHeader      :='Fecha'+CRLF+'Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: HASTA
  oCol:=oNMCONSELSALAR:oBrw:aCols[8]
  oCol:cHeader      :='Fecha'+CRLF+'Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  // Campo: CUANTOS
  oCol:=oNMCONSELSALAR:oBrw:aCols[9]
  oCol:cHeader      :='Cant.'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMCONSELSALAR:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMCONSELSALAR:oBrw:aArrayData[oNMCONSELSALAR:oBrw:nArrayAt,9],;
                              oCol  := oNMCONSELSALAR:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}



   oNMCONSELSALAR:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMCONSELSALAR:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oNMCONSELSALAR:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oNMCONSELSALAR:nClrText,;
                                                 nClrText:=IF(.F.,oNMCONSELSALAR:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oNMCONSELSALAR:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oNMCONSELSALAR:nClrPane1, oNMCONSELSALAR:nClrPane2 ) } }

//   oNMCONSELSALAR:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oNMCONSELSALAR:oBrw:bClrFooter            := {|| {0,14671839 }}

   oNMCONSELSALAR:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMCONSELSALAR:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oNMCONSELSALAR:oBrw:bLDblClick:={|oBrw|oNMCONSELSALAR:RUNCLICK() }

   oNMCONSELSALAR:oBrw:bChange:={||oNMCONSELSALAR:BRWCHANGE()}
   oNMCONSELSALAR:oBrw:CreateFromCode()


   oNMCONSELSALAR:oWnd:oClient := oNMCONSELSALAR:oBrw



   oNMCONSELSALAR:Activate({||oNMCONSELSALAR:ViewDatBar()})

   oNMCONSELSALAR:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMCONSELSALAR:lTmdi,oNMCONSELSALAR:oWnd,oNMCONSELSALAR:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oNMCONSELSALAR:oBrw:nWidth()

   oNMCONSELSALAR:oBrw:GoBottom(.T.)
   oNMCONSELSALAR:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMCONSELSALAR.EDT")
     oNMCONSELSALAR:oBrw:Move(44,0,828+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oNMCONSELSALAR:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMCONSELSALAR:oBrw,oNMCONSELSALAR:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF







/*
   IF Empty(oNMCONSELSALAR:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMCONSELSALAR")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMCONSELSALAR"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMCONSELSALAR:oBrw,"NMCONSELSALAR",oNMCONSELSALAR:cSql,oNMCONSELSALAR:nPeriodo,oNMCONSELSALAR:dDesde,oNMCONSELSALAR:dHasta,oNMCONSELSALAR)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMCONSELSALAR:oBtnRun:=oBtn



       oNMCONSELSALAR:oBrw:bLDblClick:={||EVAL(oNMCONSELSALAR:oBtnRun:bAction) }


   ENDIF




IF oNMCONSELSALAR:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oNMCONSELSALAR");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oNMCONSELSALAR:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oNMCONSELSALAR:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oNMCONSELSALAR:oBrw,oNMCONSELSALAR:oFrm)
ENDIF

IF oNMCONSELSALAR:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oNMCONSELSALAR),;
                  EJECUTAR("DPBRWMENURUN",oNMCONSELSALAR,oNMCONSELSALAR:oBrw,oNMCONSELSALAR:cBrwCod,oNMCONSELSALAR:cTitle,oNMCONSELSALAR:aHead));
          WHEN !Empty(oNMCONSELSALAR:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oNMCONSELSALAR:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMCONSELSALAR:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oNMCONSELSALAR:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oNMCONSELSALAR:oBrw,oNMCONSELSALAR);
          ACTION EJECUTAR("BRWSETFILTER",oNMCONSELSALAR:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oNMCONSELSALAR:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMCONSELSALAR:oBrw);
          WHEN LEN(oNMCONSELSALAR:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oNMCONSELSALAR:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMCONSELSALAR:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oNMCONSELSALAR:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMCONSELSALAR)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oNMCONSELSALAR:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMCONSELSALAR:oBrw,oNMCONSELSALAR:cTitle,oNMCONSELSALAR:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMCONSELSALAR:oBtnXls:=oBtn

ENDIF

IF oNMCONSELSALAR:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oNMCONSELSALAR:HTMLHEAD(),EJECUTAR("BRWTOHTML",oNMCONSELSALAR:oBrw,NIL,oNMCONSELSALAR:cTitle,oNMCONSELSALAR:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oNMCONSELSALAR:oBtnHtml:=oBtn

ENDIF


IF oNMCONSELSALAR:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMCONSELSALAR:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMCONSELSALAR:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMCONSELSALAR")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMCONSELSALAR:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMCONSELSALAR:oBtnPrint:=oBtn

   ENDIF

IF oNMCONSELSALAR:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMCONSELSALAR:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMCONSELSALAR:oBrw:GoTop(),oNMCONSELSALAR:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oNMCONSELSALAR:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oNMCONSELSALAR:oBrw:PageDown(),oNMCONSELSALAR:oBrw:Setfocus())
  ENDIF

  IF  oNMCONSELSALAR:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oNMCONSELSALAR:oBrw:PageUp(),oNMCONSELSALAR:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMCONSELSALAR:oBrw:GoBottom(),oNMCONSELSALAR:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMCONSELSALAR:Close()

  oNMCONSELSALAR:oBrw:SetColor(0,oNMCONSELSALAR:nClrPane1)

  oNMCONSELSALAR:SETBTNBAR(40,40,oBar)


  EVAL(oNMCONSELSALAR:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMCONSELSALAR:oBar:=oBar

  

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL aLine:=oNMCONSELSALAR:oBrw:aArrayData[oNMCONSELSALAR:oBrw:nArrayAt]
  LOCAL lSel 

  IF oNMCONSELSALAR:oBrw:nColSel>2 .AND. oNMCONSELSALAR:oBrw:nColSel<7
     
     lSel:=oNMCONSELSALAR:oBrw:aArrayData[oNMCONSELSALAR:oBrw:nArrayAt,oNMCONSELSALAR:oBrw:nColSel]
     oNMCONSELSALAR:oBrw:aArrayData[oNMCONSELSALAR:oBrw:nArrayAt,oNMCONSELSALAR:oBrw:nColSel]:=!lSel
     oNMCONSELSALAR:oBrw:DrawLine(.t.)
     SQLUPDATE("NMCONCEPTOS",oNMCONSELSALAR:aFields[oNMCONSELSALAR:oBrw:nColSel],!lSel,"CON_CODIGO"+GetWhere("=",aLine[1]))

  ENDIF


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRNMCONSELSALAR",cWhere)
  oRep:cSql  :=oNMCONSELSALAR:cSql
  oRep:cTitle:=oNMCONSELSALAR:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMCONSELSALAR:oPeriodo:nAt,cWhere

  oNMCONSELSALAR:nPeriodo:=nPeriodo


  IF oNMCONSELSALAR:oPeriodo:nAt=LEN(oNMCONSELSALAR:oPeriodo:aItems)

     oNMCONSELSALAR:oDesde:ForWhen(.T.)
     oNMCONSELSALAR:oHasta:ForWhen(.T.)
     oNMCONSELSALAR:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMCONSELSALAR:oDesde)

  ELSE

     oNMCONSELSALAR:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMCONSELSALAR:oDesde:VarPut(oNMCONSELSALAR:aFechas[1] , .T. )
     oNMCONSELSALAR:oHasta:VarPut(oNMCONSELSALAR:aFechas[2] , .T. )

     oNMCONSELSALAR:dDesde:=oNMCONSELSALAR:aFechas[1]
     oNMCONSELSALAR:dHasta:=oNMCONSELSALAR:aFechas[2]

     cWhere:=oNMCONSELSALAR:HACERWHERE(oNMCONSELSALAR:dDesde,oNMCONSELSALAR:dHasta,oNMCONSELSALAR:cWhere,.T.)

     oNMCONSELSALAR:LEERDATA(cWhere,oNMCONSELSALAR:oBrw,oNMCONSELSALAR:cServer,oNMCONSELSALAR)

  ENDIF

  oNMCONSELSALAR:SAVEPERIODO()

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

     IF !Empty(oNMCONSELSALAR:cWhereQry)
       cWhere:=cWhere + oNMCONSELSALAR:cWhereQry
     ENDIF

     oNMCONSELSALAR:LEERDATA(cWhere,oNMCONSELSALAR:oBrw,oNMCONSELSALAR:cServer,oNMCONSELSALAR)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oNMCONSELSALAR)
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
          "  CON_CODIGO, "+;
          "  CON_DESCRI, "+;
          "  CON_ACUM01, "+;
          "  CON_ACUM02, "+;
          "  CON_ACUM03, "+;
          "  CON_ACUM04, "+;
          "  MIN(FCH_DESDE) AS DESDE, "+;
          "  MAX(FCH_HASTA) AS HASTA, "+;
          "  COUNT(*) AS CUANTOS "+;
          "  FROM nmconceptos "+;
          "  INNER JOIN nmhistorico ON CON_CODIGO=HIS_CODCON "+;
          "  LEFT JOIN nmrecibos ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
          "  LEFT JOIN nmfechas  ON REC_CODSUC=FCH_CODSUC AND FCH_NUMERO=REC_NUMFCH "+;
          "  WHERE LEFT(CON_CODIGO,1)='A' OR LEFT(CON_CODIGO,1)='D' "+;
          "  GROUP BY CON_CODIGO"+;
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

   DPWRITE("TEMP\BRNMCONSELSALAR.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0,0,0,CTOD(""),CTOD(""),0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oNMCONSELSALAR:cSql   :=cSql
      oNMCONSELSALAR:cWhere_:=cWhere

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
      AEVAL(oNMCONSELSALAR:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMCONSELSALAR:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMCONSELSALAR.MEM",V_nPeriodo:=oNMCONSELSALAR:nPeriodo
  LOCAL V_dDesde:=oNMCONSELSALAR:dDesde
  LOCAL V_dHasta:=oNMCONSELSALAR:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMCONSELSALAR)
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


    IF Type("oNMCONSELSALAR")="O" .AND. oNMCONSELSALAR:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMCONSELSALAR:cWhere_),oNMCONSELSALAR:cWhere_,oNMCONSELSALAR:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oNMCONSELSALAR:LEERDATA(oNMCONSELSALAR:cWhere_,oNMCONSELSALAR:oBrw,oNMCONSELSALAR:cServer)
      oNMCONSELSALAR:oWnd:Show()
      oNMCONSELSALAR:oWnd:Restore()

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

   oNMCONSELSALAR:aHead:=EJECUTAR("HTMLHEAD",oNMCONSELSALAR)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oNMCONSELSALAR)
RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

