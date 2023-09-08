// Programa   : BRNMHISTRAREC
// Fecha/Hora : 22/10/2018 02:46:14
// Propósito  : "Histórico por Concepto y Trabajador"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCodCon)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMHISTRAREC.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   DEFAULT cCodCon:=SQLGET("NMCONCEPTOS","CON_CODIGO")

   cTitle:="Histórico por Concepto y Trabajador" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oNMHISTRAREC
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oNMHISTRAREC","BRNMHISTRAREC.EDT")
// oNMHISTRAREC:CreateWindow(0,0,100,550)
   oNMHISTRAREC:Windows(0,0,aCoors[3]-160,MIN(aCoors[4]-10,980),.T.) // Maximizado

   oNMHISTRAREC:cCodSuc  :=cCodSuc
   oNMHISTRAREC:lMsgBar  :=.F.
   oNMHISTRAREC:cPeriodo :=aPeriodos[nPeriodo]
   oNMHISTRAREC:cCodSuc  :=cCodSuc
   oNMHISTRAREC:nPeriodo :=nPeriodo
   oNMHISTRAREC:cNombre  :=""
   oNMHISTRAREC:dDesde   :=dDesde
   oNMHISTRAREC:cServer  :=cServer
   oNMHISTRAREC:dHasta   :=dHasta
   oNMHISTRAREC:cWhere   :=cWhere
   oNMHISTRAREC:cWhere_  :=cWhere_
   oNMHISTRAREC:cWhereQry:=""
   oNMHISTRAREC:cSql     :=oDp:cSql
   oNMHISTRAREC:oWhere   :=TWHERE():New(oNMHISTRAREC)
   oNMHISTRAREC:cCodPar  :=cCodPar // Código del Parámetro
   oNMHISTRAREC:lWhen    :=.T.
   oNMHISTRAREC:cTextTit :="" // Texto del Titulo Heredado
    oNMHISTRAREC:oDb     :=oDp:oDb
   oNMHISTRAREC:cBrwCod  :="NMHISTRAREC"
   oNMHISTRAREC:lTmdi    :=.T.
   oNMHISTRAREC:cCodCon  :=cCodCon

   oNMHISTRAREC:nClrPane1:=oDp:nClrPane1
   oNMHISTRAREC:nClrPane2:=oDp:nClrPane2

   oNMHISTRAREC:oBrw:=TXBrowse():New( IF(oNMHISTRAREC:lTmdi,oNMHISTRAREC:oWnd,oNMHISTRAREC:oDlg ))
   oNMHISTRAREC:oBrw:SetArray( aData, .F. )
   oNMHISTRAREC:oBrw:SetFont(oFont)

   oNMHISTRAREC:oBrw:lFooter     := .T.
   oNMHISTRAREC:oBrw:lHScroll    := .F.
   oNMHISTRAREC:oBrw:nHeaderLines:= 2
   oNMHISTRAREC:oBrw:nDataLines  := 1
   oNMHISTRAREC:oBrw:nFooterLines:= 1

   oNMHISTRAREC:aData            :=ACLONE(aData)

   AEVAL(oNMHISTRAREC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oNMHISTRAREC:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 56

  oCol:=oNMHISTRAREC:oBrw:aCols[2]
  oCol:cHeader      :='Apellido y Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 300

  oCol:=oNMHISTRAREC:oBrw:aCols[3]
  oCol:cHeader      :='Monto'+CRLF+oDp:cMoneda
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMHISTRAREC:oBrw:aArrayData[oNMHISTRAREC:oBrw:nArrayAt,3],FDP(nMonto,'999,999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[3],'999,999,999,999.99')


  oCol:=oNMHISTRAREC:oBrw:aCols[4]
//  oCol:cHeader      :='Monto Post'+CRLF+'Conversión'
  oCol:cHeader      :='Valor'+CRLF+"Divisa"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMHISTRAREC:oBrw:aArrayData[oNMHISTRAREC:oBrw:nArrayAt,4],FDP(nMonto,'999,999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[4],'999,999,999,999.99')


  oCol:=oNMHISTRAREC:oBrw:aCols[5]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMHISTRAREC:oBrw:aArrayData[oNMHISTRAREC:oBrw:nArrayAt,5],FDP(nMonto,'999,999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[5],'999,999,999,999.99')


  oCol:=oNMHISTRAREC:oBrw:aCols[6]
  oCol:cHeader      :='Fecha'+CRLF+'Minimo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMHISTRAREC:oBrw:aCols[7]
  oCol:cHeader      :='Fecha'+CRLF+'Máxima'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMHISTRAREC:oBrw:aCols[8]
  oCol:cHeader      :='Cant'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMHISTRAREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMHISTRAREC:oBrw:aArrayData[oNMHISTRAREC:oBrw:nArrayAt,8],FDP(nMonto,'999,999')}
   oCol:cFooter      :=FDP(aTotal[8],'999,999')


   oNMHISTRAREC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMHISTRAREC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMHISTRAREC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oNMHISTRAREC:nClrPane1, oNMHISTRAREC:nClrPane2 ) } }

//   oNMHISTRAREC:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//   oNMHISTRAREC:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oNMHISTRAREC:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMHISTRAREC:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oNMHISTRAREC:oBrw:bLDblClick:={|oBrw|oNMHISTRAREC:RUNCLICK() }

   oNMHISTRAREC:oBrw:bChange:={||oNMHISTRAREC:BRWCHANGE()}
   oNMHISTRAREC:oBrw:CreateFromCode()
   oNMHISTRAREC:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMHISTRAREC)}
   oNMHISTRAREC:BRWRESTOREPAR()

   oNMHISTRAREC:oWnd:oClient := oNMHISTRAREC:oBrw

   oNMHISTRAREC:Activate({||oNMHISTRAREC:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMHISTRAREC:lTmdi,oNMHISTRAREC:oWnd,oNMHISTRAREC:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oNMHISTRAREC:oBrw:nWidth()

   oNMHISTRAREC:oBrw:GoBottom(.T.)
   oNMHISTRAREC:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMHISTRAREC.EDT")
     oNMHISTRAREC:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\TRABAJADOR.BMP";
          ACTION EJECUTAR("NMTRABAJADOR",0,oNMHISTRAREC:cCodTra)

   oBtn:cToolTip:="Ficha del Trabajador"

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION EJECUTAR("NMTRABJCON",NIL,oNMHISTRAREC:cCodTra)

   oBtn:cToolTip:="Consultar Trabajador"
*/
  
/*
   IF Empty(oNMHISTRAREC:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMHISTRAREC")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMHISTRAREC"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMHISTRAREC:oBrw,"NMHISTRAREC",oNMHISTRAREC:cSql,oNMHISTRAREC:nPeriodo,oNMHISTRAREC:dDesde,oNMHISTRAREC:dHasta,oNMHISTRAREC)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMHISTRAREC:oBtnRun:=oBtn



       oNMHISTRAREC:oBrw:bLDblClick:={||EVAL(oNMHISTRAREC:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMHISTRAREC:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oNMHISTRAREC:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMHISTRAREC:oBrw);
          WHEN LEN(oNMHISTRAREC:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMHISTRAREC:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMHISTRAREC)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMHISTRAREC:oBrw,oNMHISTRAREC:cTitle,oNMHISTRAREC:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMHISTRAREC:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oNMHISTRAREC:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oNMHISTRAREC:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMHISTRAREC:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMHISTRAREC:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMHISTRAREC")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMHISTRAREC:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMHISTRAREC:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMHISTRAREC:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMHISTRAREC:oBrw:GoTop(),oNMHISTRAREC:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNMHISTRAREC:oBrw:PageDown(),oNMHISTRAREC:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNMHISTRAREC:oBrw:PageUp(),oNMHISTRAREC:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMHISTRAREC:oBrw:GoBottom(),oNMHISTRAREC:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMHISTRAREC:Close()

  oNMHISTRAREC:oBrw:SetColor(0,oNMHISTRAREC:nClrPane1)

  EVAL(oNMHISTRAREC:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMHISTRAREC:oBar:=oBar

  nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oNMHISTRAREC:oPeriodo  VAR oNMHISTRAREC:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oNMHISTRAREC:LEEFECHAS();
                WHEN oNMHISTRAREC:lWhen 


  ComboIni(oNMHISTRAREC:oPeriodo )

  @ 10, nLin+103 BUTTON oNMHISTRAREC:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMHISTRAREC:oPeriodo:nAt,oNMHISTRAREC:oDesde,oNMHISTRAREC:oHasta,-1),;
                         EVAL(oNMHISTRAREC:oBtn:bAction));
                WHEN oNMHISTRAREC:lWhen 


  @ 10, nLin+130 BUTTON oNMHISTRAREC:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMHISTRAREC:oPeriodo:nAt,oNMHISTRAREC:oDesde,oNMHISTRAREC:oHasta,+1),;
                         EVAL(oNMHISTRAREC:oBtn:bAction));
                WHEN oNMHISTRAREC:lWhen 


  @ 10, nLin+170 BMPGET oNMHISTRAREC:oDesde  VAR oNMHISTRAREC:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMHISTRAREC:oDesde ,oNMHISTRAREC:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oNMHISTRAREC:oPeriodo:nAt=LEN(oNMHISTRAREC:oPeriodo:aItems) .AND. oNMHISTRAREC:lWhen ;
                FONT oFont

   oNMHISTRAREC:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oNMHISTRAREC:oHasta  VAR oNMHISTRAREC:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMHISTRAREC:oHasta,oNMHISTRAREC:dHasta);
                SIZE 80,23;
                WHEN oNMHISTRAREC:oPeriodo:nAt=LEN(oNMHISTRAREC:oPeriodo:aItems) .AND. oNMHISTRAREC:lWhen ;
                OF oBar;
                FONT oFont

   oNMHISTRAREC:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oNMHISTRAREC:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oNMHISTRAREC:oPeriodo:nAt=LEN(oNMHISTRAREC:oPeriodo:aItems);
               ACTION oNMHISTRAREC:HACERWHERE(oNMHISTRAREC:dDesde,oNMHISTRAREC:dHasta,oNMHISTRAREC:cWhere,.T.);
               WHEN oNMHISTRAREC:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  oBar:SetSize(NIL,75,.T.)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 45,015 SAY oNMHISTRAREC:cCodCon  OF oBar;
               SIZE 090,20 BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  @ 45,115 SAY SQLGET("NMCONCEPTOS","CON_DESCRI","CON_CODIGO"+GetWhere("=",oNMHISTRAREC:cCodCon)) OF oBar ;
               SIZE 300,20 BORDER PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

  oNMHISTRAREC:BRWCHANGE()

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

  oRep:=REPORTE("BRNMHISTRAREC",cWhere)
  oRep:cSql  :=oNMHISTRAREC:cSql
  oRep:cTitle:=oNMHISTRAREC:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMHISTRAREC:oPeriodo:nAt,cWhere

  oNMHISTRAREC:nPeriodo:=nPeriodo


  IF oNMHISTRAREC:oPeriodo:nAt=LEN(oNMHISTRAREC:oPeriodo:aItems)

     oNMHISTRAREC:oDesde:ForWhen(.T.)
     oNMHISTRAREC:oHasta:ForWhen(.T.)
     oNMHISTRAREC:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMHISTRAREC:oDesde)

  ELSE

     oNMHISTRAREC:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMHISTRAREC:oDesde:VarPut(oNMHISTRAREC:aFechas[1] , .T. )
     oNMHISTRAREC:oHasta:VarPut(oNMHISTRAREC:aFechas[2] , .T. )

     oNMHISTRAREC:dDesde:=oNMHISTRAREC:aFechas[1]
     oNMHISTRAREC:dHasta:=oNMHISTRAREC:aFechas[2]

     cWhere:=oNMHISTRAREC:HACERWHERE(oNMHISTRAREC:dDesde,oNMHISTRAREC:dHasta,oNMHISTRAREC:cWhere,.T.)

     oNMHISTRAREC:LEERDATA(cWhere,oNMHISTRAREC:oBrw,oNMHISTRAREC:cServer)

  ENDIF

  oNMHISTRAREC:SAVEPERIODO()

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

     IF !Empty(oNMHISTRAREC:cWhereQry)
       cWhere:=cWhere + oNMHISTRAREC:cWhereQry
     ENDIF

     oNMHISTRAREC:LEERDATA(cWhere,oNMHISTRAREC:oBrw,oNMHISTRAREC:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL nDivide:=oDp:nDivide

   nDivide:=1

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF


   cSql:=" SELECT  "+;
         "  REC_NUMERO, "+;
         "  CONCAT(APELLIDO,',',NOMBRE), "+;
         "  SUM(IF(FCH_DESDE"+GetWhere("<" ,oDp:dFchIniRm)+",HIS_MONTO,0))/"+LSTR(nDivide)+" AS HIS_MTOPRE, "+;
         "  SUM(IF(FCH_DESDE"+GetWhere(">=",oDp:dFchIniRm)+",HIS_MONTO,0)) AS HIS_MTOPOS, "+;
         "  (SUM(IF(FCH_DESDE"+GetWhere("<",oDp:dFchIniRm)+",HIS_MONTO,0))/"+LSTR(nDivide)+" + SUM(IF(FCH_DESDE"+GetWhere(">=",oDp:dFchIniRm)+",HIS_MONTO,0))) AS HIS_MONTO,"+;
         " MAX(FCH_DESDE),"+;
         " MAX(FCH_HASTA),"+;
         " COUNT(*) AS CUANTOS"+;
         "   FROM NMHISTORICO "+;
         "  INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
         "  INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
         "  INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
         "  INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
         "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" REC_CODSUC=&oDp:cSucursal"+;
         "  GROUP BY REC_NUMERO "+;
         ""

   cSql:=" SELECT  "+;
         " REC_CODTRA, "+;
         " CONCAT(APELLIDO,',',NOMBRE), "+;
         " SUM(HIS_MONTO)  AS HIS_MTOPRE, "+;
         " AVG(REC_VALCAM) AS REC_VALCAM, "+;
         " SUM(HIS_MONTO/IF(REC_VALCAM=0,1,REC_VALCAM)) AS HIS_MTODIV,"+;
         " MAX(FCH_DESDE),"+;
         " MAX(FCH_HASTA),"+;
         " COUNT(*) AS CUANTOS"+;
         " FROM NMHISTORICO "+;
         " INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
         " INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
         " INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
         " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" REC_CODSUC=&oDp:cSucursal"+;
         " GROUP BY REC_CODTRA "+;
         ""



   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRNMHISTRAREC.SQL",cSql)

// ? CLPCOPY(cSql)
   aData:=ASQL(cSql,oDb)
   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0,0,CTOD(""),CTOD(""),0})
   ENDIF

   IF ValType(oBrw)="O"

      oNMHISTRAREC:cSql   :=cSql
      oNMHISTRAREC:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oNMHISTRAREC:oBrw:aCols[3]
         oCol:cFooter      :=FDP(aTotal[3],'999,999,999.99')
      oCol:=oNMHISTRAREC:oBrw:aCols[4]
         oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')
      oCol:=oNMHISTRAREC:oBrw:aCols[5]
         oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')
      oCol:=oNMHISTRAREC:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'999,999')

      oNMHISTRAREC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oNMHISTRAREC:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMHISTRAREC:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMHISTRAREC.MEM",V_nPeriodo:=oNMHISTRAREC:nPeriodo
  LOCAL V_dDesde:=oNMHISTRAREC:dDesde
  LOCAL V_dHasta:=oNMHISTRAREC:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMHISTRAREC)
RETURN .T.

/*
// Ejecución Cambio de Linea 
*/
FUNCTION BRWCHANGE()

  oNMHISTRAREC:cCodTra:=oNMHISTRAREC:oBrw:aArrayData[oNMHISTRAREC:oBrw:nArrayAt,1]

RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oNMHISTRAREC")="O" .AND. oNMHISTRAREC:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMHISTRAREC:cWhere_),oNMHISTRAREC:cWhere_,oNMHISTRAREC:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oNMHISTRAREC:LEERDATA(oNMHISTRAREC:cWhere_,oNMHISTRAREC:oBrw,oNMHISTRAREC:cServer)
      oNMHISTRAREC:oWnd:Show()
      oNMHISTRAREC:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oNMHISTRAREC)
// EOF

