// Programa   : NMTRABJREC
// Fecha/Hora : 20/08/2018 04:37:40
// Propósito  : "Transición del Valor Asientos Contables"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRTRMVALCTA.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL cNmTraj  :="NMTRABAJADOR_HIS"
 
   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   IF Empty(oDp:dFchFinRec)
      MensajeErr("Requiere Fecha Inicial Reconversión, será Asumida 30/09/2021")
      oDp:dFchFinRec:=CTOD("30/09/2021")
   ENDIF

   DpMsgRun("Procesando","Realizando Copia de Seguridad")

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cNmTraj)

      cSql:="CREATE TABLE "+cNmTraj+" SELECT * FROM NMTRABAJADOR LIMIT 0"
      oDb:Execute(cSql)

   ENDIF
 

   DpMsgRun("Procesando","Leyendo Trabajadores")

   EJECUTAR("CREATERECORD","NMOTRASNM",{"OTR_CODIGO","OTR_DESCRI"            ,"OTR_CODMON" ,"OTR_PERIOD","OTR_TIPTRA" },;
                                       {"RM"        ,"Reconversión Monetaria","BSD"        ,"Indefinido","Activos"    },;
                                       NIL,.T.,"OTR_CODIGO"+GetWhere("=","RM"))


   EJECUTAR("NMRESTDATA")
   DpMsgClose()


   cTitle:="Reconversión de Salario y Transición de Históricos "+DTOC(oDp:dFchFinRec)+" Dividido/"+LSTR(oDp:nDivide)+IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oNMTRABJREC
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oNMTRABJREC","NMTRABJREC.EDT")

   oNMTRABJREC:Windows(0,0,aCoors[3]-160,MIN(860+50+210,aCoors[4]-10),.T.) // Maximizado

   oNMTRABJREC:cCodSuc  :=cCodSuc
   oNMTRABJREC:lMsgBar  :=.F.
   oNMTRABJREC:cPeriodo :=aPeriodos[nPeriodo]
   oNMTRABJREC:cCodSuc  :=cCodSuc
   oNMTRABJREC:nPeriodo :=nPeriodo
   oNMTRABJREC:cNombre  :=""
   oNMTRABJREC:dDesde   :=dDesde
   oNMTRABJREC:cServer  :=cServer
   oNMTRABJREC:dHasta   :=dHasta
   oNMTRABJREC:cWhere   :=cWhere
   oNMTRABJREC:cWhere_  :=cWhere_
   oNMTRABJREC:cWhereQry:=""
   oNMTRABJREC:cSql     :=oDp:cSql
   oNMTRABJREC:oWhere   :=TWHERE():New(oNMTRABJREC)
   oNMTRABJREC:cCodPar  :=cCodPar // Código del Parámetro
   oNMTRABJREC:lWhen    :=.T.
   oNMTRABJREC:cTextTit :="" // Texto del Titulo Heredado
    oNMTRABJREC:oDb     :=oDp:oDb
   oNMTRABJREC:cBrwCod  :="TRMVALCTA"
   oNMTRABJREC:lTmdi    :=.T.


   oNMTRABJREC:oBrw:=TXBrowse():New( IF(oNMTRABJREC:lTmdi,oNMTRABJREC:oWnd,oNMTRABJREC:oDlg ))
   oNMTRABJREC:oBrw:SetArray( aData, .F. )
   oNMTRABJREC:oBrw:SetFont(oFont)

   oNMTRABJREC:oBrw:lFooter     := .T.
   oNMTRABJREC:oBrw:lHScroll    := .F.
   oNMTRABJREC:oBrw:nHeaderLines:= 2
   oNMTRABJREC:oBrw:nDataLines  := 1
   oNMTRABJREC:oBrw:nFooterLines:= 1

   oNMTRABJREC:aData            :=ACLONE(aData)
  oNMTRABJREC:nClrText :=0
  oNMTRABJREC:nClrPane1:=16771538
  oNMTRABJREC:nClrPane2:=16768443

  AEVAL(oNMTRABJREC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
 
  oCol:=oNMTRABJREC:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 48

  oCol:=oNMTRABJREC:oBrw:aCols[2]
  oCol:cHeader      :='Apellido'+CRLF+"Nombre"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 160

  oCol:=oNMTRABJREC:oBrw:aCols[3]
  oCol:cHeader      :='Condición'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  oCol:=oNMTRABJREC:oBrw:aCols[4]
  oCol:cHeader      :='Salario'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 140
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,4],FDP(nMonto,'99,999,999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[4],'9,999,999,999,999.99')


  oCol:=oNMTRABJREC:oBrw:aCols[5]
  oCol:cHeader      :='Salario'+CRLF+'Reconvertido'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,5],FDP(nMonto,'99,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[5],'99,999,999,999.99')


  oCol:=oNMTRABJREC:oBrw:aCols[6]
  oCol:cHeader      :='Vehiculo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 140
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,6],FDP(nMonto,'99,999,999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[6],'9,999,999,999,999.99')


  oCol:=oNMTRABJREC:oBrw:aCols[7]
  oCol:cHeader      :='Vehiculo'+CRLF+'Reconvertido'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,7],FDP(nMonto,'99,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[7],'99,999,999,999.99')

  oCol:=oNMTRABJREC:oBrw:aCols[6+2]
  oCol:cHeader      :='Fecha'+CRLF+"Ingreso"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMTRABJREC:oBrw:aCols[9]
  oCol:cHeader      :='Salario'+CRLF+'Pre-Reconversión'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,9],FDP(nMonto,'999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[9],'99,999,999,999.99')

  oCol:=oNMTRABJREC:oBrw:aCols[10]
  oCol:cHeader      :='Vehiculo'+CRLF+'Pre-Reconversión'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,10],FDP(nMonto,'999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[10],'99,999,999,999.99')


/*
  oCol:=oNMTRABJREC:oBrw:aCols[7]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMTRABJREC:oBrw:aCols[8]
  oCol:cHeader      :='Cant.'+CRLF+'Asientos'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 60
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,8],FDP(nMonto,'99,999,999,999')}
  oCol:cFooter      :=FDP(aTotal[8],'99,999,999,999')
*/

/*
  oCol:=oNMTRABJREC:oBrw:aCols[9]
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:cHeader      := "Cuenta"+CRLF+"Asiento"
  oCol:nWidth       := 60
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkjrojo.bmp")
  oCol:bBmpData    := { ||oBrw:=oNMTRABJREC:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,9],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bStrData    :={||""}

  oCol:=oNMTRABJREC:oBrw:aCols[10]
  oCol:cHeader      :='Cta.'+CRLF+"Modelo"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABJREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
*/

   oNMTRABJREC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMTRABJREC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMTRABJREC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oNMTRABJREC:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oNMTRABJREC:nClrPane1, oNMTRABJREC:nClrPane2 ) } }

   oNMTRABJREC:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMTRABJREC:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oNMTRABJREC:oBrw:bLDblClick:={|oBrw|oNMTRABJREC:RUNCLICK() }

   oNMTRABJREC:oBrw:bChange:={||oNMTRABJREC:BRWCHANGE()}
   oNMTRABJREC:oBrw:CreateFromCode()
    oNMTRABJREC:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMTRABJREC)}
    oNMTRABJREC:BRWRESTOREPAR()


   oNMTRABJREC:oWnd:oClient := oNMTRABJREC:oBrw


   oNMTRABJREC:Activate({||oNMTRABJREC:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMTRABJREC:lTmdi,oNMTRABJREC:oWnd,oNMTRABJREC:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oNMTRABJREC:oBrw:nWidth()

   oNMTRABJREC:oBrw:GoBottom(.T.)
   oNMTRABJREC:oBrw:Refresh(.T.)

   IF !File("FORMS\BRTRMVALCTA.EDT")
     oNMTRABJREC:oBrw:Move(44,0,788+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


 // Emanager no Incluye consulta de Vinculos


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oNMTRABJREC:NOMTRANSICION()

   oBtn:cToolTip:="Ejecutar Transición"



   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("NMTRABAJADOR",0,oNMTRABJREC:oBrw:aArrayData[oNMTRABJREC:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Consultar Cuenta de Caja "


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XDELETE.BMP";
            ACTION oNMTRABJREC:DELASIENTOS()

   oBtn:cToolTip:="Remover Transición "




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMTRABJREC:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oNMTRABJREC:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMTRABJREC:oBrw);
          WHEN LEN(oNMTRABJREC:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMTRABJREC:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF .F.

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMTRABJREC)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
ENDIF

IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMTRABJREC:oBrw,oNMTRABJREC:cTitle,oNMTRABJREC:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMTRABJREC:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oNMTRABJREC:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oNMTRABJREC:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMTRABJREC:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMTRABJREC:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRTRMVALCTA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMTRABJREC:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMTRABJREC:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMTRABJREC:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMTRABJREC:oBrw:GoTop(),oNMTRABJREC:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNMTRABJREC:oBrw:PageDown(),oNMTRABJREC:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNMTRABJREC:oBrw:PageUp(),oNMTRABJREC:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMTRABJREC:oBrw:GoBottom(),oNMTRABJREC:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMTRABJREC:Close()

  oNMTRABJREC:oBrw:SetColor(0,oNMTRABJREC:nClrPane1)

  EVAL(oNMTRABJREC:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMTRABJREC:oBar:=oBar

  

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

  oRep:=REPORTE("BRTRMVALCTA",cWhere)
  oRep:cSql  :=oNMTRABJREC:cSql
  oRep:cTitle:=oNMTRABJREC:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMTRABJREC:oPeriodo:nAt,cWhere

  oNMTRABJREC:nPeriodo:=nPeriodo


  IF oNMTRABJREC:oPeriodo:nAt=LEN(oNMTRABJREC:oPeriodo:aItems)

     oNMTRABJREC:oDesde:ForWhen(.T.)
     oNMTRABJREC:oHasta:ForWhen(.T.)
     oNMTRABJREC:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMTRABJREC:oDesde)

  ELSE

     oNMTRABJREC:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMTRABJREC:oDesde:VarPut(oNMTRABJREC:aFechas[1] , .T. )
     oNMTRABJREC:oHasta:VarPut(oNMTRABJREC:aFechas[2] , .T. )

     oNMTRABJREC:dDesde:=oNMTRABJREC:aFechas[1]
     oNMTRABJREC:dHasta:=oNMTRABJREC:aFechas[2]

     cWhere:=oNMTRABJREC:HACERWHERE(oNMTRABJREC:dDesde,oNMTRABJREC:dHasta,oNMTRABJREC:cWhere,.T.)

     oNMTRABJREC:LEERDATA(cWhere,oNMTRABJREC:oBrw,oNMTRABJREC:cServer)

  ENDIF

  oNMTRABJREC:SAVEPERIODO()

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

     IF !Empty(oNMTRABJREC:cWhereQry)
       cWhere:=cWhere + oNMTRABJREC:cWhereQry
     ENDIF

     oNMTRABJREC:LEERDATA(cWhere,oNMTRABJREC:oBrw,oNMTRABJREC:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData  :={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb    :=OpenOdbc(oDp:cDsnData),oTable
   LOCAL cNmTraj:="NMTRABAJADOR_HIS"
   LOCAL cNmHisto :="NMHISTORICO_HIS"

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   IF Empty(oDp:dFchIniRm)
     MensajeErr("Requiere Fecha de Inicio oDp:dFchIniRm")
   ENDIF
 
   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cNmTraj)

      cSql:="CREATE TABLE "+cNmTraj+" SELECT * FROM NMTRABAJADOR LIMIT 0"
      oDb:Execute(cSql)

   ENDIF

   cSql:=[ SELECT ]+;
         [ NMTRABAJADOR.CODIGO,]+;
         [ CONCAT(NMTRABAJADOR.APELLIDO,",",NMTRABAJADOR.NOMBRE) AS NOMBRE,]+;
         [ NMTRABAJADOR.CONDICION,]+;
         [ NMTRABAJADOR.SALARIO  ,]+;
         [ ROUND(NMTRABAJADOR.SALARIO/]+LSTR(oDp:nDivide)+[,2) AS SALDIV,]+;
         [ NMTRABAJADOR.VEHICULO,ROUND(NMTRABAJADOR.VEHICULO/]+LSTR(oDp:nDivide)+[,2) AS VEHDIV,]+;
         [ NMTRABAJADOR.FECHA_ING,NMTRABAJADOR_HIS.SALARIO,NMTRABAJADOR_HIS.VEHICULO ]+;
         [ FROM NMTRABAJADOR ]+;
         [ LEFT JOIN NMTRABAJADOR_HIS ON NMTRABAJADOR_HIS.CODIGO=NMTRABAJADOR.CODIGO ]+;
         [ WHERE NMTRABAJADOR.SALARIO>0 AND  ( NOT (NMTRABAJADOR.CONDICION="I" OR NMTRABAJADOR.CONDICION="L")) AND NMTRABAJADOR.FECHA_ING]+GetWhere("<=",oDp:dFchFinRec)+;
         [ GROUP BY NMTRABAJADOR.CODIGO ]+;
         [ ORDER BY NMTRABAJADOR.FECHA_ING ]

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.F.

//   oTable:=EJECUTAR("OPENTABLEPAG",cSql)
//   aData :=oTable:aDataFill
//   oTable:End()
   aData:=ASQL(cSql,oDb)

   DPWRITE("TEMP\BRTRABJREC.SQL",cSql)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',0,0})
   ENDIF

   AEVAL(aData,{|a,n| aData[n,3]:=SAYOPTIONS("NMTRABAJADOR","CONDICION",a[3]) })

   IF ValType(oBrw)="O"

      oNMTRABJREC:cSql   :=cSql
      oNMTRABJREC:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oNMTRABJREC:oBrw:aCols[4]
      oCol:cFooter      :=FDP(aTotal[4],'99,999,999,999.99')
      oCol:=oNMTRABJREC:oBrw:aCols[5]
      oCol:cFooter      :=FDP(aTotal[5],'99,999,999,999.99')

      oNMTRABJREC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oNMTRABJREC:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMTRABJREC:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRTRMVALCTA.MEM",V_nPeriodo:=oNMTRABJREC:nPeriodo
  LOCAL V_dDesde:=oNMTRABJREC:dDesde
  LOCAL V_dHasta:=oNMTRABJREC:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMTRABJREC)
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

    IF Type("oNMTRABJREC")="O" .AND. oNMTRABJREC:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMTRABJREC:cWhere_),oNMTRABJREC:cWhere_,oNMTRABJREC:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oNMTRABJREC:LEERDATA(oNMTRABJREC:cWhere_,oNMTRABJREC:oBrw,oNMTRABJREC:cServer)
      oNMTRABJREC:oWnd:Show()
      oNMTRABJREC:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/

FUNCTION NOMTRANSICION()
   LOCAL aData:=ACLONE(oNMTRABJREC:oBrw:aArrayData)
   LOCAL cWhere
   LOCAL dFecha:=oDp:dFchIniRm-1 
   LOCAL oNew,oCbte  
   LOCAL cCodTra
   LOCAL I
   LOCAL cDb:=IF(!Empty(oDp:cDbDepura),oDp:cDbDepura,oDp:cDsnData),oDb,oCbte
   LOCAL cNumCbt,cNumEje
   LOCAL aCodSuc :={},cCodSuc,nAt,cNumTra,aRecord:={},cCodCaj,aLine:={}	
   LOCAL cNmTraj :="NMTRABAJADOR_HIS"
   LOCAL cNmHisto:="NMHISTORICO_HIS"

   LOCAL oFile,cSql
   LOCAL cFile:=LOWER("RECONVERSION\"+oDp:cDsnData+"_NMTRABAJADOR.TXT")
   LOCAL aTotales:=ATOTALES(oNMTRABJREC:oBrw:aArrayData)

   oDb   :=OPENODBC(cDb)
//   aData :=ADEPURA(aData,{|a,n| Empty(a[4]) })

   IF !Empty(aTotales[10])
      MensajeErr("Salarios ya Fueron Reconvertidos")
      RETURN .T.
   ENDIF

   IF Empty(aData)
      MensajeErr("No hay Asientos Contables")
      RETURN .F.
   ENDIF

   IF !MsgNoYes("Desea Realizar Reconversión "+LSTR(LEN(aData))+" Trabajadores")
      RETURN .F.
   ENDIF

   DpMsgRun("Procesando","Realizando copias de Seguridad ")

   EJECUTAR("NMTABLASRECM") // Realizar Copias

   oFile:=TFile():New(cFile)

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cNmHisto)

      cSql:="CREATE TABLE "+cNmHisto+" SELECT * FROM NMHISTORICO"
      oDb:Execute(cSql)
      
   ELSE

      cSql:="INSERT INTO "+cNmHisto+" SELECT * FROM NMHISTORICO"
      oDb:Execute(cSql)

   ENDIF

   oFile:AppStr( cSql+CRLF)

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cNmTraj)

     cSql:="CREATE TABLE "+cNmTraj+" SELECT * FROM NMTRABAJADOR"
     oDb:Execute(cSql)

     oFile:AppStr( cSql+CRLF)

  ELSE

     cSql:="DELETE FROM "+cNmTraj
     oDb:Execute(cSql)
     oFile:AppStr( cSql+CRLF)

     cSql:="INSERT INTO "+cNmTraj+" SELECT * FROM NMTRABAJADOR"
     oDb:Execute(cSql)
     oFile:AppStr( cSql+CRLF)

   ENDIF

   // oCbte :=OpenTable("SELECT * FROM DPCBTE"    ,.F.,oDb)
   // Agregamos Comprobante
/*
   cSql:=[ UPDATE nmtrabajador ]+;
         [ INNER JOIN nmtrabajador_his on nmtrabajador_his.codigo=nmtrabajador.codigo ]+;
         [ SET nmtrabajador.SALARIO=nmtrabajador_his.salario,  ]+;
         [     nmtrabajador.VEHICULO=nmtrabajador_his.VEHICULO ]
*/
   oDb:Execute(cSql)
   oFile:AppStr( cSql+CRLF)

   DpMsgRun("Procesando","Reconvirtiendo Salario ",NIL,LEN(aData))
   DpMsgSetTotal(LEN(aData))

   FOR I=1 TO LEN(aData)

      // Si el Ciere de Inventario, esta Realizado Volvera a Repetirlo
      aLine  :=aData[I] 
      cCodTra:=aLine[1]
      DpMsgSet(I,.T.,NIL,"Actualizando "+cCodTra+" "+LSTR(I)+"/"+LSTR(LEN(aData)))

      IF aLine[4]>0 .AND. aLine[4]=aLine[9]

        SQLUPDATE("NMTRABAJADOR",{"SALARIO","VEHICULO"},{aLine[05],aLine[07]},"CODIGO"+GetWhere("=",cCodTra))

        oFile:AppStr( cSql+CRLF)

        EJECUTAR("NMRECIBOSRECMN","REC_CODTRA"+GetWhere("=",cCodTra))

      ELSE

        IF aLine[09]>0
          SQLUPDATE("NMTRABAJADOR",{"SALARIO","VEHICULO"},{aLine[09],aLine[10]},"CODIGO"+GetWhere("=",cCodTra))
          oFile:AppStr( cSql+CRLF)
        ENDIF

      ENDIF

      // oDb:Execute(oDp:cSql)
      oFile:AppStr( cSql+CRLF)

   NEXT I
/*
   oNew:End()
*/
   oFile:Close()
   oFile:End()
   DpMsgClose()

RETURN .T.

FUNCTION DELASIENTOS()
   LOCAL cSql,cWhere:="",cWhereF,cNumFch
   LOCAL oDb:=OpenOdbc(oDp:cDsnData)
   LOCAL oData     :=DATACONFIG("RECONVERSION","ALL")

   oDp:dFchIniRec:=oData:Get("dFchIniRec"  ,CTOD("30/09/2021"))
   oDp:dFchFinRec:=oData:Get("dFchFinRec"  ,CTOD("30/09/2021"))
   oDp:nRecMonDiv:=oData:Get("nRecMonDiv"  ,1000000)
   oDp:cCodMonDiv:=oData:Get("cCodMon"     ,"BSD")

   oDp:dFchIniRm:=oDp:dFchFinRec
   oDp:nDivide  :=oDp:nRecMonDiv
   oData:End(.F.)

   IF !MsgNoyes("Desea Remover la Reconversión en Trabajadores")
      RETURN .T.
   ENDIF

   cSql:=[ UPDATE nmtrabajador ]+;
         [ INNER JOIN nmtrabajador_his on nmtrabajador_his.codigo=nmtrabajador.codigo ]+;
         [ SET nmtrabajador.SALARIO=nmtrabajador_his.salario,  ]+;
         [     nmtrabajador.VEHICULO=nmtrabajador_his.VEHICULO ]

   oDb:Execute(cSql)

//   cSql:=[ DELETE FROM nmtrabajador_his ]
//   oDb:Execute(cSql)


   cWhereF:="FCH_OTRNOM"+GetWhere("=","RM")+" AND FCH_DESDE"+GetWhere("=",oDp:dFchFinRec)+" AND FCH_HASTA"+GetWhere("=",oDp:dFchFinRec)
   cNumFch:=SQLGET("NMFECHAS","FCH_NUMERO",cWhereF)

   IF !Empty(cNumFch)

      SQLDELETE("NMFECHAS" ,"FCH_NUMERO"+GetWhere("=",cNumFch))
      SQLDELETE("NMRECIBOS","REC_NUMFCH"+GetWhere("=",cNumFch))

      cSql:=" DELETE NMHISTORICO FROM NMHISTORICO "+;
            " INNER JOIN NMRECIBOS   ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
            " INNER JOIN NMFECHAS    ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO"+;
            "  WHERE NMFECHAS.FCH_NUMERO"+GetWhere("=",cNumFch)

//     ? oDb:Execute(cSql),CLPCOPY(cSql)

   ENDIF


   IF EJECUTAR("DBISTABLE",oDp:cDsnData,"nmhistorico_his") 

     cSql:=[ UPDATE  nmhistorico ]+;
           [ INNER JOIN nmhistorico_his ON NMHISTORICO.HIS_NUMREC=nmhistorico_his.HIS_NUMREC  AND nmhistorico_his.HIS_CODCON=nmhistorico.HIS_CODCON ]+;
           [ SET NMHISTORICO.HIS_MONTO=NMHISTORICO_HIS.HIS_MONTO ]

     oDb:Execute(cSql)
 
     cSql:=[ DELETE FROM nmhistorico_his ]
     oDb:Execute(cSql)

   ENDIF

   oNMTRABJREC:BRWREFRESCAR()

RETURN  NIL

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oNMTRABJREC)
// EOF
