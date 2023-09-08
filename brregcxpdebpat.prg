// Programa   : BRREGCXPDEBPAT
// Fecha/Hora : 16/09/2021 23:25:27
// Propósito  : "Registrar Cuentas por Pagar Deberes Patronales"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRREGCXPDEBPAT.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oREGCXPDEBPAT")="O" .AND. oREGCXPDEBPAT:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oREGCXPDEBPAT,GetScript())
   ENDIF

   EJECUTAR("DPNOMINAINTCREA") 

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
             ENDIF

   ENDIF


   cTitle:="Registrar Cuentas por Pagar Deberes Patronales" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oREGCXPDEBPAT

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oREGCXPDEBPAT","BRREGCXPDEBPAT.EDT")
// oREGCXPDEBPAT:CreateWindow(0,0,100,550)
   oREGCXPDEBPAT:Windows(0,0,aCoors[3]-160,MIN(2192,aCoors[4]-10),.T.) // Maximizado

   oREGCXPDEBPAT:cCodSuc  :=cCodSuc
   oREGCXPDEBPAT:lMsgBar  :=.F.
   oREGCXPDEBPAT:cPeriodo :=aPeriodos[nPeriodo]
   oREGCXPDEBPAT:cCodSuc  :=cCodSuc
   oREGCXPDEBPAT:nPeriodo :=nPeriodo
   oREGCXPDEBPAT:cNombre  :=""
   oREGCXPDEBPAT:dDesde   :=dDesde
   oREGCXPDEBPAT:cServer  :=cServer
   oREGCXPDEBPAT:dHasta   :=dHasta
   oREGCXPDEBPAT:cWhere   :=cWhere
   oREGCXPDEBPAT:cWhere_  :=cWhere_
   oREGCXPDEBPAT:cWhereQry:=""
   oREGCXPDEBPAT:cSql     :=oDp:cSql
   oREGCXPDEBPAT:oWhere   :=TWHERE():New(oREGCXPDEBPAT)
   oREGCXPDEBPAT:cCodPar  :=cCodPar // Código del Parámetro
   oREGCXPDEBPAT:lWhen    :=.T.
   oREGCXPDEBPAT:cTextTit :="" // Texto del Titulo Heredado
   oREGCXPDEBPAT:oDb      :=oDp:oDb
   oREGCXPDEBPAT:cBrwCod  :="REGCXPDEBPAT"
   oREGCXPDEBPAT:lTmdi    :=.T.
   oREGCXPDEBPAT:aHead    :={}
   oREGCXPDEBPAT:lBarDef  :=.T. // Activar Modo Diseño.

   // Guarda los parámetros del Browse cuando cierra la ventana
   oREGCXPDEBPAT:bValid   :={|| EJECUTAR("BRWSAVEPAR",oREGCXPDEBPAT)}

   oREGCXPDEBPAT:lBtnRun     :=.F.
   oREGCXPDEBPAT:lBtnMenuBrw :=.F.
   oREGCXPDEBPAT:lBtnSave    :=.F.
   oREGCXPDEBPAT:lBtnCrystal :=.F.
   oREGCXPDEBPAT:lBtnRefresh :=.F.
   oREGCXPDEBPAT:lBtnHtml    :=.T.
   oREGCXPDEBPAT:lBtnExcel   :=.T.
   oREGCXPDEBPAT:lBtnPreview :=.T.
   oREGCXPDEBPAT:lBtnQuery   :=.F.
   oREGCXPDEBPAT:lBtnOptions :=.T.
   oREGCXPDEBPAT:lBtnPageDown:=.T.
   oREGCXPDEBPAT:lBtnPageUp  :=.T.
   oREGCXPDEBPAT:lBtnFilters :=.T.
   oREGCXPDEBPAT:lBtnFind    :=.T.

   oREGCXPDEBPAT:nClrPane1:=16775408
   oREGCXPDEBPAT:nClrPane2:=16771797

   oREGCXPDEBPAT:nClrText :=0
   oREGCXPDEBPAT:nClrText1:=0
   oREGCXPDEBPAT:nClrText2:=0
   oREGCXPDEBPAT:nClrText3:=0

   oREGCXPDEBPAT:oBrw:=TXBrowse():New( IF(oREGCXPDEBPAT:lTmdi,oREGCXPDEBPAT:oWnd,oREGCXPDEBPAT:oDlg ))
   oREGCXPDEBPAT:oBrw:SetArray( aData, .F. )
   oREGCXPDEBPAT:oBrw:SetFont(oFont)

   oREGCXPDEBPAT:oBrw:lFooter     := .T.
   oREGCXPDEBPAT:oBrw:lHScroll    := .T.
   oREGCXPDEBPAT:oBrw:nHeaderLines:= 2
   oREGCXPDEBPAT:oBrw:nDataLines  := 1
   oREGCXPDEBPAT:oBrw:nFooterLines:= 1


   oREGCXPDEBPAT:aData            :=ACLONE(aData)

   AEVAL(oREGCXPDEBPAT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  // Campo: ITN_CODIGO
  oCol:=oREGCXPDEBPAT:oBrw:aCols[1]
  oCol:cHeader      :='ID'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 24

  // Campo: ITN_RIF
  oCol:=oREGCXPDEBPAT:oBrw:aCols[2]
  oCol:cHeader      :='RIF'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 96

  // Campo: PRO_NOMBRE
  oCol:=oREGCXPDEBPAT:oBrw:aCols[3]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 800

  // Campo: ITN_CONRET
  oCol:=oREGCXPDEBPAT:oBrw:aCols[4]
  oCol:cHeader      :='Código'+CRLF+'Concepto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  // Campo: CON_DESCRI
  oCol:=oREGCXPDEBPAT:oBrw:aCols[5]
  oCol:cHeader      :='Descripción del Concepto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: ITN_CONPAT
  oCol:=oREGCXPDEBPAT:oBrw:aCols[6]
  oCol:cHeader      :='Aporte'+CRLF+'Patronal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 32

  // Campo: CIC_CUENTA
  oCol:=oREGCXPDEBPAT:oBrw:aCols[7]
  oCol:cHeader      :='Cuenta'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  // Campo: CTA_DESCRI
  oCol:=oREGCXPDEBPAT:oBrw:aCols[8]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: APORTE_TRA
  oCol:=oREGCXPDEBPAT:oBrw:aCols[9]
  oCol:cHeader      :='Aporte'+CRLF+'Trabajador'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oREGCXPDEBPAT:oBrw:aArrayData[oREGCXPDEBPAT:oBrw:nArrayAt,9],;
                              oCol  := oREGCXPDEBPAT:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[9],oCol:cEditPicture)


  // Campo: APORTE_PAT
  oCol:=oREGCXPDEBPAT:oBrw:aCols[10]
  oCol:cHeader      :='Aporte'+CRLF+'Patronal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oREGCXPDEBPAT:oBrw:aArrayData[oREGCXPDEBPAT:oBrw:nArrayAt,10],;
                              oCol  := oREGCXPDEBPAT:oBrw:aCols[10],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[10],oCol:cEditPicture)


  // Campo: TOTAL_CXP
  oCol:=oREGCXPDEBPAT:oBrw:aCols[11]
  oCol:cHeader      :='Total'+CRLF+'Cuenta por Pagar'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 136
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oREGCXPDEBPAT:oBrw:aArrayData[oREGCXPDEBPAT:oBrw:nArrayAt,11],;
                              oCol  := oREGCXPDEBPAT:oBrw:aCols[11],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[11],oCol:cEditPicture)


  oCol:=oREGCXPDEBPAT:oBrw:aCols[12]
  oCol:cHeader      :='Tipo'+CRLF+"Doc."
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oREGCXPDEBPAT:oBrw:aCols[13]
  oCol:cHeader      :='Tipo'+CRLF+"Nómina"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oREGCXPDEBPAT:oBrw:aCols[14]
  oCol:cHeader      :='Otra'+CRLF+"Nómina"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oREGCXPDEBPAT:oBrw:aCols[15]
  oCol:cHeader      :='Número'+CRLF+"Fecha"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oREGCXPDEBPAT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80




   oREGCXPDEBPAT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oREGCXPDEBPAT:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oREGCXPDEBPAT:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oREGCXPDEBPAT:nClrText,;
                                                 nClrText:=IF(.F.,oREGCXPDEBPAT:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oREGCXPDEBPAT:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oREGCXPDEBPAT:nClrPane1, oREGCXPDEBPAT:nClrPane2 ) } }

//   oREGCXPDEBPAT:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oREGCXPDEBPAT:oBrw:bClrFooter            := {|| {0,14671839 }}

   oREGCXPDEBPAT:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oREGCXPDEBPAT:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oREGCXPDEBPAT:oBrw:bLDblClick:={|oBrw|oREGCXPDEBPAT:RUNCLICK() }

   oREGCXPDEBPAT:oBrw:bChange:={||oREGCXPDEBPAT:BRWCHANGE()}
   oREGCXPDEBPAT:oBrw:CreateFromCode()


   oREGCXPDEBPAT:oWnd:oClient := oREGCXPDEBPAT:oBrw



   oREGCXPDEBPAT:Activate({||oREGCXPDEBPAT:ViewDatBar()})

   oREGCXPDEBPAT:BRWRESTOREPAR()

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oREGCXPDEBPAT:lTmdi,oREGCXPDEBPAT:oWnd,oREGCXPDEBPAT:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oREGCXPDEBPAT:oBrw:nWidth()

   oREGCXPDEBPAT:oBrw:GoBottom(.T.)
   oREGCXPDEBPAT:oBrw:Refresh(.T.)

   IF !File("FORMS\BRREGCXPDEBPAT.EDT")
     oREGCXPDEBPAT:oBrw:Move(44,0,2192+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oREGCXPDEBPAT:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP";
          ACTION oREGCXPDEBPAT:SAVECXP()

    oBtn:cToolTip:="Registrar Cuenta por Pagar"


/*
   IF Empty(oREGCXPDEBPAT:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","REGCXPDEBPAT")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","REGCXPDEBPAT"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oREGCXPDEBPAT:oBrw,"REGCXPDEBPAT",oREGCXPDEBPAT:cSql,oREGCXPDEBPAT:nPeriodo,oREGCXPDEBPAT:dDesde,oREGCXPDEBPAT:dHasta,oREGCXPDEBPAT)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oREGCXPDEBPAT:oBtnRun:=oBtn



       oREGCXPDEBPAT:oBrw:bLDblClick:={||EVAL(oREGCXPDEBPAT:oBtnRun:bAction) }


   ENDIF




IF oREGCXPDEBPAT:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oREGCXPDEBPAT");
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oREGCXPDEBPAT:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF


IF oREGCXPDEBPAT:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT:oFrm)
ENDIF

IF oREGCXPDEBPAT:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oREGCXPDEBPAT),;
                  EJECUTAR("DPBRWMENURUN",oREGCXPDEBPAT,oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT:cBrwCod,oREGCXPDEBPAT:cTitle,oREGCXPDEBPAT:aHead));
          WHEN !Empty(oREGCXPDEBPAT:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oREGCXPDEBPAT:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oREGCXPDEBPAT:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oREGCXPDEBPAT:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT);
          ACTION EJECUTAR("BRWSETFILTER",oREGCXPDEBPAT:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oREGCXPDEBPAT:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oREGCXPDEBPAT:oBrw);
          WHEN LEN(oREGCXPDEBPAT:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oREGCXPDEBPAT:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oREGCXPDEBPAT:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oREGCXPDEBPAT:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oREGCXPDEBPAT)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oREGCXPDEBPAT:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT:cTitle,oREGCXPDEBPAT:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oREGCXPDEBPAT:oBtnXls:=oBtn

ENDIF

IF oREGCXPDEBPAT:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oREGCXPDEBPAT:HTMLHEAD(),EJECUTAR("BRWTOHTML",oREGCXPDEBPAT:oBrw,NIL,oREGCXPDEBPAT:cTitle,oREGCXPDEBPAT:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oREGCXPDEBPAT:oBtnHtml:=oBtn

ENDIF


IF oREGCXPDEBPAT:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oREGCXPDEBPAT:oBrw))

   oBtn:cToolTip:="Previsualización"

   oREGCXPDEBPAT:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRREGCXPDEBPAT")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oREGCXPDEBPAT:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oREGCXPDEBPAT:oBtnPrint:=oBtn

   ENDIF

IF oREGCXPDEBPAT:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oREGCXPDEBPAT:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oREGCXPDEBPAT:oBrw:GoTop(),oREGCXPDEBPAT:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oREGCXPDEBPAT:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oREGCXPDEBPAT:oBrw:PageDown(),oREGCXPDEBPAT:oBrw:Setfocus())
  ENDIF

  IF  oREGCXPDEBPAT:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oREGCXPDEBPAT:oBrw:PageUp(),oREGCXPDEBPAT:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oREGCXPDEBPAT:oBrw:GoBottom(),oREGCXPDEBPAT:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oREGCXPDEBPAT:Close()

  oREGCXPDEBPAT:oBrw:SetColor(0,oREGCXPDEBPAT:nClrPane1)

  oREGCXPDEBPAT:SETBTNBAR(40,40,oBar)


  EVAL(oREGCXPDEBPAT:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oREGCXPDEBPAT:oBar:=oBar

    nCol:=1832
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oREGCXPDEBPAT:oPeriodo  VAR oREGCXPDEBPAT:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oREGCXPDEBPAT:LEEFECHAS();
                WHEN oREGCXPDEBPAT:lWhen


  ComboIni(oREGCXPDEBPAT:oPeriodo )

  @ nLin, nCol+103 BUTTON oREGCXPDEBPAT:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oREGCXPDEBPAT:oPeriodo:nAt,oREGCXPDEBPAT:oDesde,oREGCXPDEBPAT:oHasta,-1),;
                         EVAL(oREGCXPDEBPAT:oBtn:bAction));
                WHEN oREGCXPDEBPAT:lWhen


  @ nLin, nCol+130 BUTTON oREGCXPDEBPAT:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oREGCXPDEBPAT:oPeriodo:nAt,oREGCXPDEBPAT:oDesde,oREGCXPDEBPAT:oHasta,+1),;
                         EVAL(oREGCXPDEBPAT:oBtn:bAction));
                WHEN oREGCXPDEBPAT:lWhen


  @ nLin, nCol+160 BMPGET oREGCXPDEBPAT:oDesde  VAR oREGCXPDEBPAT:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oREGCXPDEBPAT:oDesde ,oREGCXPDEBPAT:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oREGCXPDEBPAT:oPeriodo:nAt=LEN(oREGCXPDEBPAT:oPeriodo:aItems) .AND. oREGCXPDEBPAT:lWhen ;
                FONT oFont

   oREGCXPDEBPAT:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oREGCXPDEBPAT:oHasta  VAR oREGCXPDEBPAT:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oREGCXPDEBPAT:oHasta,oREGCXPDEBPAT:dHasta);
                SIZE 76-2,24;
                WHEN oREGCXPDEBPAT:oPeriodo:nAt=LEN(oREGCXPDEBPAT:oPeriodo:aItems) .AND. oREGCXPDEBPAT:lWhen ;
                OF oBar;
                FONT oFont

   oREGCXPDEBPAT:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oREGCXPDEBPAT:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oREGCXPDEBPAT:oPeriodo:nAt=LEN(oREGCXPDEBPAT:oPeriodo:aItems);
               ACTION oREGCXPDEBPAT:HACERWHERE(oREGCXPDEBPAT:dDesde,oREGCXPDEBPAT:dHasta,oREGCXPDEBPAT:cWhere,.T.);
               WHEN oREGCXPDEBPAT:lWhen

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

  oRep:=REPORTE("BRREGCXPDEBPAT",cWhere)
  oRep:cSql  :=oREGCXPDEBPAT:cSql
  oRep:cTitle:=oREGCXPDEBPAT:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oREGCXPDEBPAT:oPeriodo:nAt,cWhere

  oREGCXPDEBPAT:nPeriodo:=nPeriodo


  IF oREGCXPDEBPAT:oPeriodo:nAt=LEN(oREGCXPDEBPAT:oPeriodo:aItems)

     oREGCXPDEBPAT:oDesde:ForWhen(.T.)
     oREGCXPDEBPAT:oHasta:ForWhen(.T.)
     oREGCXPDEBPAT:oBtn  :ForWhen(.T.)

     DPFOCUS(oREGCXPDEBPAT:oDesde)

  ELSE

     oREGCXPDEBPAT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oREGCXPDEBPAT:oDesde:VarPut(oREGCXPDEBPAT:aFechas[1] , .T. )
     oREGCXPDEBPAT:oHasta:VarPut(oREGCXPDEBPAT:aFechas[2] , .T. )

     oREGCXPDEBPAT:dDesde:=oREGCXPDEBPAT:aFechas[1]
     oREGCXPDEBPAT:dHasta:=oREGCXPDEBPAT:aFechas[2]

     cWhere:=oREGCXPDEBPAT:HACERWHERE(oREGCXPDEBPAT:dDesde,oREGCXPDEBPAT:dHasta,oREGCXPDEBPAT:cWhere,.T.)

     oREGCXPDEBPAT:LEERDATA(cWhere,oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT:cServer,oREGCXPDEBPAT)

  ENDIF

  oREGCXPDEBPAT:SAVEPERIODO()

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

     IF !Empty(oREGCXPDEBPAT:cWhereQry)
       cWhere:=cWhere + oREGCXPDEBPAT:cWhereQry
     ENDIF

     oREGCXPDEBPAT:LEERDATA(cWhere,oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT:cServer,oREGCXPDEBPAT)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oREGCXPDEBPAT)
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
          "  ITN_CODIGO, "+;
          "  ITN_RIF, "+;
          "  PRO_NOMBRE, "+;
          "  ITN_CONRET, "+;
          "  CON_DESCRI, "+;
          "  ITN_CONPAT, "+;
          "  CIC_CUENTA, "+;
          "  CTA_DESCRI, "+;
          "  SUM(IF(HIS_CODCON=ITN_CONRET, HIS_MONTO*-1, 0 )) AS APORTE_TRA, "+;
          "  SUM(IF(HIS_CODCON=ITN_CONPAT, HIS_MONTO   , 0 )) AS APORTE_PAT, "+;
          "  SUM(IF(HIS_CODCON=ITN_CONRET, HIS_MONTO*-1, 0 )+IF(HIS_CODCON=ITN_CONPAT, HIS_MONTO   , 0 )) AS TOTAL_CXP,ITN_TIPDOC,FCH_TIPNOM,FCH_OTRNOM,FCH_NUMERO  "+;
          "  FROM NMHISTORICO  "+;
          "  INNER JOIN nmrecibos       ON NMHISTORICO.HIS_CODSUC=NMRECIBOS.REC_CODSUC AND NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO  "+;
          "  INNER JOIN nmfechas        ON NMRECIBOS.REC_CODSUC  =NMFECHAS.FCH_CODSUC  AND NMRECIBOS.REC_NUMFCH  =NMFECHAS.FCH_NUMERO  "+;
          "  INNER JOIN nmconceptos     ON HIS_CODCON=CON_CODIGO "+;
          "  INNER JOIN dpnominaint     ON nmhistorico.HIS_CODCON=ITN_CONRET OR nmhistorico.HIS_CODCON=ITN_CONPAT "+;
          "  INNER JOIN dpproveedor     ON PRO_RIF=ITN_RIF "+;
          "  LEFT  JOIN NMCONCEPTOS_CTA ON CIC_CODIGO=ITN_CONPAT AND CIC_CODINT='CUENTA' "+;
          "  LEFT  JOIN dpcta           ON CIC_CTAMOD=CTA_CODMOD AND CIC_CUENTA=CTA_CODIGO "+;
          "  WHERE FCH_CODSUC=&oDp:cSucursal "+;
          "  GROUP BY ITN_CODIGO "+;
          "  ORDER BY ITN_CODIGO"+;
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

   DPWRITE("TEMP\BRREGCXPDEBPAT.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','','','','',0,0,0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oREGCXPDEBPAT:cSql   :=cSql
      oREGCXPDEBPAT:cWhere_:=cWhere

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
      AEVAL(oREGCXPDEBPAT:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oREGCXPDEBPAT:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRREGCXPDEBPAT.MEM",V_nPeriodo:=oREGCXPDEBPAT:nPeriodo
  LOCAL V_dDesde:=oREGCXPDEBPAT:dDesde
  LOCAL V_dHasta:=oREGCXPDEBPAT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oREGCXPDEBPAT)
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


    IF Type("oREGCXPDEBPAT")="O" .AND. oREGCXPDEBPAT:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oREGCXPDEBPAT:cWhere_),oREGCXPDEBPAT:cWhere_,oREGCXPDEBPAT:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oREGCXPDEBPAT:LEERDATA(oREGCXPDEBPAT:cWhere_,oREGCXPDEBPAT:oBrw,oREGCXPDEBPAT:cServer)
      oREGCXPDEBPAT:oWnd:Show()
      oREGCXPDEBPAT:oWnd:Restore()

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

   oREGCXPDEBPAT:aHead:=EJECUTAR("HTMLHEAD",oREGCXPDEBPAT)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oREGCXPDEBPAT)
RETURN .T.

FUNCTION SAVECXP()
  // Registrar Cuenta por Pagar

  EJECUTAR("BRREGCXPDEBPATSAVE",oREGCXPDEBPAT:cSql,oREGCXPDEBPAT:dDesde,oREGCXPDEBPAT:dHasta)
  oREGCXPDEBPAT:Close()

RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

