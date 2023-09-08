// Programa   : BRREPPATEMP
// Fecha/Hora : 22/06/2017 11:34:05
// Propósito  : "Reporte Patronal de Asegurados"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodigo,cNumero,oFrm)
   LOCAL aData,aFechas,cFileMem:="USER\BRREPPATEMP.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   IF Type("oREPPATEMP")="O" .AND. oREPPATEMP:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oREPPATEMP,GetScript())
   ENDIF


   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Reporte Patronal de Asegurados" +IF(Empty(cTitle),"",cTitle)

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

   IF .T. .AND. (!nPeriodo=10 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oREPPATEMP
            
RETURN oREPPATEMP


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oREPPATEMP","BRREPPATEMP.EDT")
//  oREPPATEMP:CreateWindow(0,0,100,550)
   oREPPATEMP:Windows(0,0,aCoors[3]-150,aCoors[4]-10,.T.) // Maximizado

   oREPPATEMP:cCodSuc  :=cCodSuc
   oREPPATEMP:lMsgBar  :=.F.
   oREPPATEMP:cPeriodo :=aPeriodos[nPeriodo]
   oREPPATEMP:cCodSuc  :=cCodSuc
   oREPPATEMP:nPeriodo :=nPeriodo
   oREPPATEMP:cNombre  :=""
   oREPPATEMP:dDesde   :=dDesde
   oREPPATEMP:cServer  :=cServer
   oREPPATEMP:dHasta   :=dHasta
   oREPPATEMP:cWhere   :=cWhere
   oREPPATEMP:cWhere_  :=cWhere_
   oREPPATEMP:cWhereQry:=""
   oREPPATEMP:cSql     :=oDp:cSql
   oREPPATEMP:oWhere   :=TWHERE():New(oREPPATEMP)
   oREPPATEMP:cCodPar  :=cCodPar // Código del Parámetro
   oREPPATEMP:lWhen    :=.T.
   oREPPATEMP:cTextTit :="" // Texto del Titulo Heredado
   oREPPATEMP:oDb     :=oDp:oDb
   oREPPATEMP:cBrwCod  :="REPPATEMP"
   oREPPATEMP:lTmdi    :=.T.
   oREPPATEMP:cCodigo  :=cCodigo
   oREPPATEMP:cNumero  :=cNumero
   oREPPATEMP:oFrm     :=oFrm

   oREPPATEMP:oBrw:=TXBrowse():New( IF(oREPPATEMP:lTmdi,oREPPATEMP:oWnd,oREPPATEMP:oDlg ))
   oREPPATEMP:oBrw:SetArray( aData, .F. )
   oREPPATEMP:oBrw:SetFont(oFont)

   oREPPATEMP:oBrw:lFooter     := .T.
   oREPPATEMP:oBrw:lHScroll    := .F.
   oREPPATEMP:oBrw:nHeaderLines:= 2
   oREPPATEMP:oBrw:nDataLines  := 1
   oREPPATEMP:oBrw:nFooterLines:= 1




   oREPPATEMP:aData            :=ACLONE(aData)
  oREPPATEMP:nClrText :=0
  oREPPATEMP:nClrPane1:=16774120
  oREPPATEMP:nClrPane2:=16765864

   AEVAL(oREPPATEMP:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oREPPATEMP:oBrw:aCols[1]
  oCol:cHeader      :='Cédula'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oREPPATEMP:oBrw:aArrayData[oREPPATEMP:oBrw:nArrayAt,1],FDP(nMonto,'99,999,999')}
//   oCol:cFooter      :=FDP(aTotal[1],'999,999,999')


  oCol:=oREPPATEMP:oBrw:aCols[2]
  oCol:cHeader      :='Apellido'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  oCol:=oREPPATEMP:oBrw:aCols[3]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  oCol:=oREPPATEMP:oBrw:aCols[4]
  oCol:cHeader      :='Fecha'+CRLF+"Nacimiento"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oREPPATEMP:oBrw:aCols[5]
  oCol:cHeader      :='Tip'+CRLF+"Céd"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  oCol:=oREPPATEMP:oBrw:aCols[6]
  oCol:cHeader      :='Sexo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  oCol:=oREPPATEMP:oBrw:aCols[7]
  oCol:cHeader      :='Dirección'+CRLF+"Habitación"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 840

  oCol:=oREPPATEMP:oBrw:aCols[8]
  oCol:cHeader      :="Número"+CRLF+"Seguro Social"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oREPPATEMP:oBrw:aCols[9]
  oCol:cHeader      :="Fecha"+CRLF+"Ingreso"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oREPPATEMP:oBrw:aCols[10]
  oCol:cHeader      :="Fecha"+CRLF+"Egreso"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oREPPATEMP:oBrw:aCols[11]
  oCol:cHeader      :='Salario'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 88
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oREPPATEMP:oBrw:aArrayData[oREPPATEMP:oBrw:nArrayAt,11],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[11],'999,999,999.99')


  oCol:=oREPPATEMP:oBrw:aCols[12]
  oCol:cHeader      :="Código"+CRLF+"Profesión"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oREPPATEMP:oBrw:aCols[13]
  oCol:cHeader      :='Profesión'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oREPPATEMP:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

   oREPPATEMP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oREPPATEMP:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oREPPATEMP:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oREPPATEMP:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oREPPATEMP:nClrPane1, oREPPATEMP:nClrPane2 ) } }

   oREPPATEMP:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oREPPATEMP:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oREPPATEMP:oBrw:bLDblClick:={|oBrw|oREPPATEMP:RUNCLICK() }

   oREPPATEMP:oBrw:bChange:={||oREPPATEMP:BRWCHANGE()}
   oREPPATEMP:oBrw:CreateFromCode()
   oREPPATEMP:bValid   :={|| EJECUTAR("BRWSAVEPAR",oREPPATEMP)}
   oREPPATEMP:BRWRESTOREPAR()

   oREPPATEMP:oWnd:oClient := oREPPATEMP:oBrw

   oREPPATEMP:Activate({||oREPPATEMP:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oREPPATEMP:lTmdi,oREPPATEMP:oWnd,oREPPATEMP:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oREPPATEMP:oBrw:nWidth()

   oREPPATEMP:oBrw:GoBottom(.T.)
   oREPPATEMP:oBrw:Refresh(.T.)

   IF !File("FORMS\BRREPPATEMP.EDT")
     oREPPATEMP:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\TRABAJADOR.BMP";
          ACTION oREPPATEMP:CONSULTAR()

   oBtn:cToolTip:="Consultar Trabajador"



  
/*
   IF Empty(oREPPATEMP:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","REPPATEMP")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","REPPATEMP"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oREPPATEMP:oBrw,"REPPATEMP",oREPPATEMP:cSql,oREPPATEMP:nPeriodo,oREPPATEMP:dDesde,oREPPATEMP:dHasta,oREPPATEMP)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oREPPATEMP:oBtnRun:=oBtn



       oREPPATEMP:oBrw:bLDblClick:={||EVAL(oREPPATEMP:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oREPPATEMP:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oREPPATEMP:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oREPPATEMP:oBrw);
          WHEN LEN(oREPPATEMP:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          ACTION IF(oREPPATEMP:oWnd:IsZoomed(),oREPPATEMP:oWnd:Restore(),oREPPATEMP:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"





IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oREPPATEMP:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oREPPATEMP)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oREPPATEMP:oBrw,oREPPATEMP:cTitle,oREPPATEMP:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oREPPATEMP:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oREPPATEMP:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oREPPATEMP:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oREPPATEMP:oBrw))

   oBtn:cToolTip:="Previsualización"

   oREPPATEMP:oBtnPreview:=oBtn

ENDIF

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\XPRINT.BMP";
           ACTION oREPPATEMP:IMPRIMIR()

     oBtn:cToolTip:="Imprimir"

     oREPPATEMP:oBtnPrint:=oBtn

 
IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oREPPATEMP:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oREPPATEMP:oBrw:GoTop(),oREPPATEMP:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oREPPATEMP:oBrw:PageDown(),oREPPATEMP:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oREPPATEMP:oBrw:PageUp(),oREPPATEMP:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oREPPATEMP:oBrw:GoBottom(),oREPPATEMP:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oREPPATEMP:Close()

  oREPPATEMP:oBrw:SetColor(0,oREPPATEMP:nClrPane1)

  EVAL(oREPPATEMP:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oREPPATEMP:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oREPPATEMP:oPeriodo  VAR oREPPATEMP:cPeriodo ITEMS aPeriodos;
                SIZE 100,NIL;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oREPPATEMP:LEEFECHAS();
                WHEN oREPPATEMP:lWhen 


  ComboIni(oREPPATEMP:oPeriodo )

  @ 10, nLin+103 BUTTON oREPPATEMP:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oREPPATEMP:oPeriodo:nAt,oREPPATEMP:oDesde,oREPPATEMP:oHasta,-1),;
                         EVAL(oREPPATEMP:oBtn:bAction));
                WHEN oREPPATEMP:lWhen 


  @ 10, nLin+130 BUTTON oREPPATEMP:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oREPPATEMP:oPeriodo:nAt,oREPPATEMP:oDesde,oREPPATEMP:oHasta,+1),;
                         EVAL(oREPPATEMP:oBtn:bAction));
                WHEN oREPPATEMP:lWhen 


  @ 10, nLin+170 BMPGET oREPPATEMP:oDesde  VAR oREPPATEMP:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oREPPATEMP:oDesde ,oREPPATEMP:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oREPPATEMP:oPeriodo:nAt=LEN(oREPPATEMP:oPeriodo:aItems) .AND. oREPPATEMP:lWhen ;
                FONT oFont

   oREPPATEMP:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oREPPATEMP:oHasta  VAR oREPPATEMP:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oREPPATEMP:oHasta,oREPPATEMP:dHasta);
                SIZE 80,23;
                WHEN oREPPATEMP:oPeriodo:nAt=LEN(oREPPATEMP:oPeriodo:aItems) .AND. oREPPATEMP:lWhen ;
                OF oBar;
                FONT oFont

   oREPPATEMP:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oREPPATEMP:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oREPPATEMP:oPeriodo:nAt=LEN(oREPPATEMP:oPeriodo:aItems);
               ACTION oREPPATEMP:HACERWHERE(oREPPATEMP:dDesde,oREPPATEMP:dHasta,oREPPATEMP:cWhere,.T.);
               WHEN oREPPATEMP:lWhen

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

  oRep:=REPORTE("REGPATRONALASEG",cWhere)
  
  oRep:SetCriterio(2,oREPPATEMP:dDesde)
  oRep:SetCriterio(3,oREPPATEMP:dHasta)

  oRep:cSql  :=oREPPATEMP:cSql
  oRep:cTitle:=oREPPATEMP:cTitle

  IF !Empty(oREPPATEMP:cNumero)
  
    oDp:cWhereRun:="PFT_CODIGO"+GetWhere("=",oREPPATEMP:cCodigo)+" AND "+;
                   "PFT_CODEMP"+GetWhere("=",oDp:cEmpCod       )+" AND "+;
                   "PFT_CODSUC"+GetWhere("=",oDp:cSucursal     )+" AND "+;
                   "PFT_NUMERO"+GetWhere("=",oREPPATEMP:cNumero)

    oRep:bPostRun:={|| SQLUPDATE("DPFORMYTAREASPROG",{"PFT_FCHEJE","PFT_ESTADO"},{oDp:dFecha,"E"},oDp:cWhereRun),;
                       IF(ValType(oREPPATEMP:oFrm)="O",oREPPATEMP:oFrm:BRWREFRESCAR(),NIL)}

  ENDIF

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oREPPATEMP:oPeriodo:nAt,cWhere

  oREPPATEMP:nPeriodo:=nPeriodo


  IF oREPPATEMP:oPeriodo:nAt=LEN(oREPPATEMP:oPeriodo:aItems)

     oREPPATEMP:oDesde:ForWhen(.T.)
     oREPPATEMP:oHasta:ForWhen(.T.)
     oREPPATEMP:oBtn  :ForWhen(.T.)

     DPFOCUS(oREPPATEMP:oDesde)

  ELSE

     oREPPATEMP:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oREPPATEMP:oDesde:VarPut(oREPPATEMP:aFechas[1] , .T. )
     oREPPATEMP:oHasta:VarPut(oREPPATEMP:aFechas[2] , .T. )

     oREPPATEMP:dDesde:=oREPPATEMP:aFechas[1]
     oREPPATEMP:dHasta:=oREPPATEMP:aFechas[2]

     cWhere:=oREPPATEMP:HACERWHERE(oREPPATEMP:dDesde,oREPPATEMP:dHasta,oREPPATEMP:cWhere,.T.)

     oREPPATEMP:LEERDATA(cWhere,oREPPATEMP:oBrw,oREPPATEMP:cServer)

  ENDIF

  oREPPATEMP:SAVEPERIODO()

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

     IF !Empty(oREPPATEMP:cWhereQry)
       cWhere:=cWhere + oREPPATEMP:cWhereQry
     ENDIF

     oREPPATEMP:LEERDATA(cWhere,oREPPATEMP:oBrw,oREPPATEMP:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF


   cSql:=" SELECT "+;
          " NMTRABAJADOR.CEDULA,"+;
          " NMTRABAJADOR.APELLIDO,"+;
          " NMTRABAJADOR.NOMBRE,"+;
          " NMTRABAJADOR.FECHA_NAC,"+;
          " NMTRABAJADOR.TIPO_CED,"+;
          " NMTRABAJADOR.SEXO,"+;
          " CONCAT(NMTRABAJADOR.DIR_HAB1,NMTRABAJADOR.DIR_HAB2,NMTRABAJADOR.DIR_HAB3) AS DIRECCION,"+;
          " NMTRABAJADOR.NUM_SSO,"+;
          " NMTRABAJADOR.FECHA_ING,"+;
          " NMTRABAJADOR.FECHA_EGR,"+;
          " NMTRABAJADOR.SALARIO,"+;
          " NMTRABAJADOR.COD_PROF,"+;
          " NMPROFESION.PRF_NOMBRE "+;
          " FROM NMTRABAJADOR "+;
          " LEFT  JOIN NMPROFESION ON NMTRABAJADOR.COD_PROF=NMPROFESION.PRF_CODIGO "+;
          " INNER JOIN NMRECIBOS   ON NMTRABAJADOR.CODIGO  =NMRECIBOS.REC_CODTRA "+;
          " INNER JOIN NMFECHAS    ON NMRECIBOS.REC_CODSUC =NMFECHAS.FCH_CODSUC AND NMRECIBOS.REC_NUMFCH=NMFECHAS.FCH_NUMERO "+;
          " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" (NMTRABAJADOR.DESCONTAR= 'S') "+;
          " GROUP BY CEDULA"+;
          " ORDER BY NMTRABAJADOR.CEDULA"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.F.

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{0,'','',CTOD(""),'','','','',CTOD(""),CTOD(""),0,'',''})
   ENDIF

   IF ValType(oBrw)="O"

      oREPPATEMP:cSql   :=cSql
      oREPPATEMP:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oREPPATEMP:oBrw:aCols[1]
         oCol:cFooter      :=FDP(aTotal[1],'999,999,999.99')
      oCol:=oREPPATEMP:oBrw:aCols[11]
         oCol:cFooter      :=FDP(aTotal[11],'999,999,999.99')

      oREPPATEMP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oREPPATEMP:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oREPPATEMP:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRREPPATEMP.MEM",V_nPeriodo:=oREPPATEMP:nPeriodo
  LOCAL V_dDesde:=oREPPATEMP:dDesde
  LOCAL V_dHasta:=oREPPATEMP:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oREPPATEMP)
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


    IF Type("oREPPATEMP")="O" .AND. oREPPATEMP:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oREPPATEMP":cWhere_),"oREPPATEMP":cWhere_,"oREPPATEMP":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oREPPATEMP:LEERDATA(oREPPATEMP:cWhere_,oREPPATEMP:oBrw,oREPPATEMP:cServer)
      oREPPATEMP:oWnd:Show()
      oREPPATEMP:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION CONSULTAR()
  LOCAL nCedula:=oREPPATEMP:oBrw:aArrayData[oREPPATEMP:oBrw:nArrayAt,1]
  LOCAL cCodigo:=SQLGET("NMTRABAJADOR","CODIGO","CEDULA"+GetWhere("=",nCedula))

  IF !Empty(cCodigo)
    EJECUTAR("NMTRABJCON",NIL,cCodigo)
  ENDIF

RETURN .T.

/*
// Genera Correspondencia Masiva
*/




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oREPPATEMP)
// EOF
