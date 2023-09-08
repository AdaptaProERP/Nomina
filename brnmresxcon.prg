// Programa   : BRNMRESXCON
// Fecha/Hora : 22/09/2016 08:17:18
// Propósito  : "Resumen por Conceptos para Contabilizar"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumero,lCxP,cNumDoc)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMRESXCON.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:Nm_cServer
   LOCAL lConectar:=.F.
   LOCAL cNumFch

   IF Empty(oDp:cNmContab) 
     EJECUTAR("NMRESTDATA")
   ENDIF

   DEFAULT lCxP:=(oDp:cNmContab="P")

   IF cNumero=NIL

     DEFAULT oDp:lNumCom:=.F.

     cNumero:=oDp:cNumCom

     IF oDp:lNumCom
        cNumero:=EJECUTAR("DPNUMCBTE","NOMINA")
     ENDIF

   ENDIF

   DEFAULT cNumero:=SPACE(10)

   IF !EJECUTAR("TABLASNOMINA")
      RETURN .F.
   ENDIF

   oDp:cRunServer:=oDp:Nm_cServer

   IF !Empty(oDp:Nm_cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   IF !lCxP
     cTitle:="Resumen por Conceptos para Contabilizar" +IF(Empty(cTitle),""," ["+ALLTRIM(cTitle)+"]")
   ELSE
     cTitle:="Resumen por Concepto para Crear Cuentas por Pagar " +IF(Empty(cTitle),""," ["+ALLTRIM(cTitle)+"]")
   ENDIF

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           lCxP    :=.F.

   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF Empty(cWhere)
      cNumFch:=SQLGET("NMFECHAS","FCH_NUMERO","1=1 ORDER BY FCH_HASTA DESC LIMIT 1",NIL,oDp:oDb)
      cWhere :="FCH_NUMERO"+GetWhere("=",cNumFch)
      cNumDoc:=cNumFch
   ENDIF

   aData :=LEERDATA(cWhere,NIL,cServer)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oNMRESXCON
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB,oGrupo
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

// DPEDIT():New(cTitle,"BRNMRESXCON.EDT","oNMRESXCON",.F.)
// oNMRESXCON:CreateWindow(NIL,NIL,NIL,550,772+58)

   DpMdi(cTitle,"oNMRESXCON","BRNMRESXCON.EDT")
   oNMRESXCON:Windows(0,0,oDp:aCoors[3]-160,MIN(772+58,oDp:aCoors[4]-10),.T.) // Maximizado

   oNMRESXCON:cCodSuc  :=cCodSuc
   oNMRESXCON:lMsgBar  :=.F.
   oNMRESXCON:cPeriodo :=aPeriodos[nPeriodo]
   oNMRESXCON:cCodSuc  :=cCodSuc
   oNMRESXCON:nPeriodo :=nPeriodo
   oNMRESXCON:cNombre  :=""
   oNMRESXCON:dDesde   :=dDesde
   oNMRESXCON:cServer  :=cServer
   oNMRESXCON:dHasta   :=dHasta
   oNMRESXCON:cWhere   :=cWhere
   oNMRESXCON:cWhere_  :=cWhere_
   oNMRESXCON:cWhereQry:=""
   oNMRESXCON:cSql     :=oDp:cSql
   oNMRESXCON:oWhere   :=TWHERE():New(oNMRESXCON)
   oNMRESXCON:cCodPar  :=cCodPar // Código del Parámetro
   oNMRESXCON:lWhen    :=.T.
   oNMRESXCON:cTextTit :="" // Texto del Titulo Heredado
   oNMRESXCON:oDb      :=oDp:oDb
   oNMRESXCON:cBrwCod  :="NMRESXCON"
   oNMRESXCON:cNumero  :=cNumero
   oNMRESXCON:lCheck   :=.F.
   oNMRESXCON:lBarDef  :=.T.
   oNMRESXCON:lCxP     :=lCxP
   oNMRESXCON:cNumDoc  :=cNumDoc
   oNMRESXCON:dFecha   :=oDp:dFecha
   oNMRESXCON:cNumFch  :=cNumFch
   
   oNMRESXCON:oBrw:=TXBrowse():New( oNMRESXCON:oDlg )
   oNMRESXCON:oBrw:SetArray( aData, .F. )
   oNMRESXCON:oBrw:SetFont(oFont)

   oNMRESXCON:oBrw:lFooter     := .T.
   oNMRESXCON:oBrw:lHScroll    := .F.
   oNMRESXCON:oBrw:nHeaderLines:= 2
   oNMRESXCON:oBrw:nDataLines  := 1
   oNMRESXCON:oBrw:nFooterLines:= 1

   oNMRESXCON:aData            :=ACLONE(aData)
   oNMRESXCON:nClrText :=0
   oNMRESXCON:nClrPane1:=16775408
   oNMRESXCON:nClrPane2:=16771797

/*
   @ 3.1,.3 GROUP oGrupo TO 10.7, 33.6 PROMPT " Comprobante " 

   @ 2,1 SAY "Número: " RIGHT
   @ 3,1 SAY "Fecha : " RIGHT  

   @ 3,1 GET oNMRESXCON:cNumero VALID oNMRESXCON:VALNUMERO()
   @ 3,1 SAY oDp:Nm_cPeriodo
*/
   AEVAL(oNMRESXCON:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oNMRESXCON:oBrw:aCols[1]
   oCol:cHeader      :='Cód.'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 38+10

   oCol:=oNMRESXCON:oBrw:aCols[2]
   oCol:cHeader      :='Descripción'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 300

   oCol:=oNMRESXCON:oBrw:aCols[3]
   oCol:cHeader      :='Cuenta'+CRLF+'Contable'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 120

   oCol:=oNMRESXCON:oBrw:aCols[4]
   oCol:cHeader      :='Cuenta'+CRLF+'Contrapartida'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 120

   oCol:=oNMRESXCON:oBrw:aCols[5]
   oCol:cHeader      :='Debe'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 100
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oNMRESXCON:oBrw:aArrayData[oNMRESXCON:oBrw:nArrayAt,5],FDP(nMonto,'999,999,999,999.99',NIL,NIL,.T.)}
   oCol:cFooter      :=FDP(aTotal[5],'999,999,999,999.99')

   oCol:=oNMRESXCON:oBrw:aCols[6]
   oCol:cHeader      :='Haber'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 100
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oNMRESXCON:oBrw:aArrayData[oNMRESXCON:oBrw:nArrayAt,6],FDP(nMonto,'999,999,999,999.99',NIL,NIL,.T.)}
   oCol:cFooter      :=FDP(aTotal[6],'999,999,999,999,999.99')

   oCol:=oNMRESXCON:oBrw:aCols[7]
   oCol:cHeader      :='Fecha'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 70

   oCol:=oNMRESXCON:oBrw:aCols[8]
   oCol:cHeader      :='Org'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oNMRESXCON:oBrw:aArrayData ) } 
   oCol:nWidth       := 30


   oNMRESXCON:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMRESXCON:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMRESXCON:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=if(aData[5]>0,CLR_HBLUE,CLR_HRED),;
                                           nClrText:=if(LEFT(aData[1],1)="H",0,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0,oMdi:nClrPane1,oMdi:nClrPane2 ) } }

   oNMRESXCON:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMRESXCON:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oNMRESXCON:oBrw:bLDblClick:={|oBrw|oNMRESXCON:RUNCLICK() }

   oNMRESXCON:oBrw:bChange:={||oNMRESXCON:BRWCHANGE()}
   oNMRESXCON:oBrw:CreateFromCode()

   oNMRESXCON:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMRESXCON)}
   oNMRESXCON:BRWRESTOREPAR()

   oNMRESXCON:oWnd:oClient := oNMRESXCON:oBrw

   oNMRESXCON:Activate({||oNMRESXCON:ViewDatBar(oNMRESXCON)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oNMRESXCON)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oNMRESXCON:oDlg
   LOCAL nLin:=0,nCol:=0
   LOCAL nWidth:=oNMRESXCON:oBrw:nWidth()

   oNMRESXCON:oBrw:GoBottom(.T.)
   oNMRESXCON:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRNMRESXCON.EDT")
//     oNMRESXCON:oBrw:Move(44,0,772+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oNMRESXCON:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMRESXCON:oBrw,oNMRESXCON:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

  
/*
   IF Empty(oNMRESXCON:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMRESXCON")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMRESXCON"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMRESXCON:oBrw,"NMRESXCON",oNMRESXCON:cSql,oNMRESXCON:nPeriodo,oNMRESXCON:dDesde,oNMRESXCON:dHasta,oNMRESXCON)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMRESXCON:oBtnRun:=oBtn

       oNMRESXCON:oBrw:bLDblClick:={||EVAL(oNMRESXCON:oBtnRun:bAction) }

   ENDIF


   IF oNMRESXCON:lCxP

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             ACTION oNMRESXCON:GUARDARCXP()

      oBtn:cToolTip:="Crear Cuentas por Pagar"

   ELSE


      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\RUN.BMP";
             ACTION oNMRESXCON:RUNASIENTOS(.F.)
  
      oBtn:cToolTip:="Contabilizar"

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CONTABILIDAD.BMP";
          ACTION EJECUTAR("NMCTAXCON",oNMRESXCON:oBrw:aArrayData[oNMRESXCON:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Asignar Cuentas Contables"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\DEPURAR.BMP";
          ACTION oNMRESXCON:RUNASIENTOS(.T.)

   oBtn:cToolTip:="Revisar Cuentas Contables"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMRESXCON:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oNMRESXCON:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMRESXCON:oBrw);
          WHEN LEN(oNMRESXCON:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMRESXCON:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMRESXCON)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMRESXCON:oBrw,oNMRESXCON:cTitle,oNMRESXCON:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMRESXCON:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oNMRESXCON:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oNMRESXCON:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMRESXCON:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMRESXCON:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMRESXCON")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMRESXCON:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMRESXCON:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMRESXCON:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMRESXCON:oBrw:GoTop(),oNMRESXCON:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNMRESXCON:oBrw:PageDown(),oNMRESXCON:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNMRESXCON:oBrw:PageUp(),oNMRESXCON:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMRESXCON:oBrw:GoBottom(),oNMRESXCON:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMRESXCON:Close()

  oNMRESXCON:oBrw:SetColor(0,oMdi:nClrPane1)

  EVAL(oNMRESXCON:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  oNMRESXCON:oBar:=oBar

  oNMRESXCON:SETBTNBAR(40,40,oBar)

  nCol:=32
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),nCol:=nCol+o:nWidth()})

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   IF oNMRESXCON:lCxP

    @ 1,nCol+500 SAY "Fecha  " RIGHT OF oBar BORDER PIXEL FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow
    @ 2,nCol+500 SAY "Número " RIGHT OF oBar BORDER PIXEL FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow

//    @ 01,nCol+500 GET oNMRESXCON:dFecha VALID;
//                  oNMRESXCON:VALFECHA() OF oBar PIXEL FONT oFont

    @ 03,nCol+73 BMPGET oNMRESXCON:oFecha VAR oNMRESXCON:dFecha;
                 PICTURE "99/99/9999";
                 PIXEL;
                 NAME "BITMAPS\Calendar.bmp";
                 ACTION LbxDate(oNMRESXCON:oFecha,oNMRESXCON:dFecha);
                 SIZE 76-2,20;
                 OF   oBar;
                 WHEN .T.;
                 FONT oFont

    oNMRESXCON:oFecha:cToolTip:="F6: Calendario"

    @ 20,nCol+500-30 SAY oNMRESXCON:cNumDoc OF oBar SIZE 34,20 BORDER	;
                     PIXEL FONT oFont COLOR oDp:nClrLabelText,oDp:nClrLabelPane SIZE 20,20


    BMPGETBTN(oBar,oFont,13)

  ELSE

    @ 1,nCol+500 SAY "Número " RIGHT OF oBar BORDER PIXEL FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow
    @ 2,nCol+500 SAY "Fecha  " RIGHT OF oBar BORDER PIXEL FONT oFont COLOR oDp:nClrYellowText,oDp:nClrYellow

    @ 01,nCol+500 GET oNMRESXCON:cNumero VALID oNMRESXCON:VALNUMERO() OF oBar PIXEL FONT oFont
    @ 20,nCol+500 SAY oDp:Nm_cPeriodo OF oBar PIXEL FONT oFont COLOR oDp:nClrLabelText,oDp:nClrLabelPane

  ENDIF


RETURN .T.

FUNCTION VALFECHA()
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

  oRep:=REPORTE("BRNMRESXCON",cWhere)
  oRep:cSql  :=oNMRESXCON:cSql
  oRep:cTitle:=oNMRESXCON:cTitle

RETURN .T.


FUNCTION LEERDATA(cWhere,oBrw,cServer,cCodSuc)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb
   LOCAL cField  :=EJECUTAR("NMFCHCONTAB")
   LOCAL aCheques:={},cSqlMov,oTable

   DEFAULT cWhere :="",;
           cCodSuc:=oDp:cSucursal

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cSql:=" SELECT HIS_CODCON,CON_DESCRI,CON_CUENTA,CON_CTACON,IF(HIS_MONTO>0,SUM(HIS_MONTO),0),IF(HIS_MONTO<0,SUM(HIS_MONTO*-1),0), "+;
         " "+cField+","+GetWhere("","N")+;
         " FROM NMHISTORICO "+;
         " INNER JOIN NMCONCEPTOS ON CON_CODIGO=HIS_CODCON "+;
         " INNER JOIN NMRECIBOS   ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC                             "+;
         " INNER JOIN NMFECHAS    ON FCH_CODSUC=REC_CODSUC AND FCH_NUMERO=REC_NUMFCH "+;
         " WHERE (LEFT(HIS_CODCON,1)='A' OR LEFT(HIS_CODCON,1)='D' OR (LEFT(HIS_CODCON,1)='H' AND CON_CUENTA<>''))"+;
         " GROUP BY "+cField+",HIS_CODCON"+;
         " ORDER BY "+cField+",HIS_CODCON"

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   IF !Empty(cWhere)
     cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   oDp:lExcluye:=.T.

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',0})
   ENDIF

   IF "YEAR("$cField
      AEVAL(aData,{|a,n| aData[n,7]:=FCHFINMES(CTOD("01/"+RIGHT(a[7],2)+"/"+LEFT(a[7],4)))})
     // Agrega Fecha de Fin de Mes
   ENDIF

   AEVAL(aData,{|a,n| aData[n,6]:=IF(LEFT(a[1],1)="H",a[5],a[6]),;
                      aData[n,8]:="N"})

   // Transferencias Bancarias Vista MBREGTRANSFBCO 

   cSqlMov:=" SELECT BXT_NUMFCH,CONCAT(BAN_NOMBRE,',',BXT_CTABCO) AS BAN_NOMBRE,CIC_CUENTA AS BCO_CUENTA,0,BXT_MONTO,0,BXT_FECHA "+;
            " FROM VIEW_MBREGTRANSFBCO "+;
            " INNER JOIN NMFECHAS       ON FCH_CODSUC=BXT_CODSUC AND FCH_NUMERO=BXT_NUMFCH "+;
            " INNER JOIN DPCTABANCO     ON BXT_CODBCO=BCO_CODIGO AND BXT_CTABCO=BCO_CTABAN  "+;
            " LEFT  JOIN DPCTABANCO_CTA ON CIC_CODIGO=DPCTABANCO.BCO_CODIGO AND CIC_COD2=DPCTABANCO.BCO_CTABAN AND CIC_CTAMOD"+GetWhere("=",oDp:cCtaMod)+;
            " INNER JOIN DPBANCOS       ON BXT_CODBCO=BAN_CODIGO  "+;
            " WHERE "+cWhere+;
            " GROUP BY BXT_NUMFCH "

   oTable:=OpenTable(cSqlMov,.T.)
   oTable:GoTop()

   WHILE !oTable:Eof()
       AADD(aData,{oTable:BXT_NUMFCH,oTable:BAN_NOMBRE,"",oTable:BCO_CUENTA,0,oTable:BXT_MONTO,oTable:BXT_FECHA,"B"})
       oTable:DbSkip()
   ENDDO

   oTable:End()

   IF ValType(oBrw)="O"

      oNMRESXCON:cSql   :=cSql
      oNMRESXCON:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      oCol:=oNMRESXCON:oBrw:aCols[4]
      oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')

      oNMRESXCON:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oNMRESXCON:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMRESXCON:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMRESXCON.MEM",V_nPeriodo:=oNMRESXCON:nPeriodo
  LOCAL V_dDesde:=oNMRESXCON:dDesde
  LOCAL V_dHasta:=oNMRESXCON:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMRESXCON)
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


    IF Type("oNMRESXCON")="O" .AND. oNMRESXCON:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oNMRESXCON":cWhere_),"oNMRESXCON":cWhere_,"oNMRESXCON":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oNMRESXCON:LEERDATA(oNMRESXCON:cWhere_,oNMRESXCON:oBrw,oNMRESXCON:cServer)
      oNMRESXCON:oWnd:Show()
      oNMRESXCON:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION LEE_RECIBOS(cWhere)
   LOCAL aRecibos:={}
RETURN aRecibos

/*
// Evalua las Cuentas Contables de los Asientos
*/
FUNCTION RUNASIENTOS(lCheck)
   LOCAL aData:=oNMRESXCON:oBrw:aArrayData
   LOCAL lPreContab:=.F.

   DEFAULT lCheck:=.F.

   IF lCheck
     oNMRESXCON:lCheck:=lCheck
   ENDIF

   CursorWait()
/*
   IF !oNMRESXCON:lCheck

     IF !EJECUTAR("CONTABNOM",oNMRESXCON:oDb,oNMRESXCON:oBrw:aArrayData,oNMRESXCON:cWhere_,oNMRESXCON:cCodSuc,oNMRESXCON:cNumero,.T.,lPreContab)
        RETURN .F.
     ENDIF
      
   ENDIF
*/

   IF !EJECUTAR("CONTABNOM",oNMRESXCON:oDb,oNMRESXCON:oBrw:aArrayData,oNMRESXCON:cWhere_,oNMRESXCON:cCodSuc,oNMRESXCON:cNumero,.T.,lPreContab)
      RETURN .F.
   ENDIF

   IF lCheck
      RETURN .F.
   ENDIF

   IF !EJECUTAR("CONTABNOM",oNMRESXCON:oDb,oNMRESXCON:oBrw:aArrayData,oNMRESXCON:cWhere_,oNMRESXCON:cCodSuc,oNMRESXCON:cNumero,.F.,lPreContab)
      RETURN .F.
   ELSE
      MensajeErr("Nómina Contabilizada ")
   ENDIF

RETURN .T.

FUNCTION VALNUMERO()
RETURN .T.
/*
// Genera Correspondencia Masiva
*/

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oNMRESXCON)

FUNCTION GUARDARCXP()

   EJECUTAR("NOMTOCXP",oNMRESXCON:cCodSuc,oNMRESXCON:cNumDoc)

RETURN .T.
// EOF
