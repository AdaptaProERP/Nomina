// Programa   : BRRECIBOS
// Fecha/Hora : 05/01/2018 09:57:42
// Propósito  : "Lista de Recibos con forma de Pago"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRRECIBOS.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oRECIBOS")="O" .AND. oRECIBOS:oWnd:hWnd>0
      EJECUTAR("BRRUNNEW",oRECIBOS,GetScript())
      RETURN .T.
   ENDIF

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   cTitle:="Lista de Recibos con forma de Pago" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oRECIBOS
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oRECIBOS","BRRECIBOS.EDT")

   oRECIBOS:Windows(0,0,aCoors[3]-160,690+210,.T.) // Maximizado

   oRECIBOS:cCodSuc  :=cCodSuc
   oRECIBOS:lMsgBar  :=.F.
   oRECIBOS:cPeriodo :=aPeriodos[nPeriodo]
   oRECIBOS:cCodSuc  :=cCodSuc
   oRECIBOS:nPeriodo :=nPeriodo
   oRECIBOS:cNombre  :=""
   oRECIBOS:dDesde   :=dDesde
   oRECIBOS:cServer  :=cServer
   oRECIBOS:dHasta   :=dHasta
   oRECIBOS:cWhere   :=cWhere
   oRECIBOS:cWhere_  :=cWhere_
   oRECIBOS:cWhereQry:=""
   oRECIBOS:cSql     :=oDp:cSql
   oRECIBOS:oWhere   :=TWHERE():New(oRECIBOS)
   oRECIBOS:cCodPar  :=cCodPar // Código del Parámetro
   oRECIBOS:lWhen    :=.T.
   oRECIBOS:cTextTit :="" // Texto del Titulo Heredado
   oRECIBOS:oDb     :=oDp:oDb
   oRECIBOS:cBrwCod  :="RECIBOS"
   oRECIBOS:lTmdi    :=.T.

   oRECIBOS:oBrw:=TXBrowse():New( IF(oRECIBOS:lTmdi,oRECIBOS:oWnd,oRECIBOS:oDlg ))
   oRECIBOS:oBrw:SetArray( aData, .F. )
   oRECIBOS:oBrw:SetFont(oFont)

   oRECIBOS:oBrw:lFooter     := .T.
   oRECIBOS:oBrw:lHScroll    := .T.
   oRECIBOS:oBrw:nHeaderLines:= 2
   oRECIBOS:oBrw:nDataLines  := 1
   oRECIBOS:oBrw:nFooterLines:= 1

   oRECIBOS:aData            :=ACLONE(aData)
  oRECIBOS:nClrText :=0
  oRECIBOS:nClrPane1:=16773345
  oRECIBOS:nClrPane2:=16765864

   AEVAL(oRECIBOS:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oRECIBOS:oBrw:aCols[1]
  oCol:cHeader      :='Recibo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 56

  oCol:=oRECIBOS:oBrw:aCols[2]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oRECIBOS:oBrw:aCols[3]
  oCol:cHeader      :='Apellido Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  oCol:=oRECIBOS:oBrw:aCols[4]
  oCol:cHeader      :='Forma de Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 24+120

  oCol:=oRECIBOS:oBrw:aCols[5]
  oCol:cHeader      :='Número'+CRLF+'Nómina'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oRECIBOS:oBrw:aCols[6]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 96
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oRECIBOS:oBrw:aArrayData[oRECIBOS:oBrw:nArrayAt,6],FDP(nMonto,'999,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[6],'999,999,999,999.99')

  oCol:=oRECIBOS:oBrw:aCols[7]
  oCol:cHeader      :='Desde'
  oCol:nWidth       := 70

  oCol:=oRECIBOS:oBrw:aCols[8]
  oCol:cHeader      :='Hasta'
  oCol:nWidth       := 70

  oCol:=oRECIBOS:oBrw:aCols[9]
  oCol:cHeader      :='Sistema'
  oCol:nWidth       := 70


  oCol:=oRECIBOS:oBrw:aCols[10]
  oCol:cHeader      :='Tipo'
  oCol:nWidth       := 40

  oCol:=oRECIBOS:oBrw:aCols[11]
  oCol:cHeader      :='Otra'
  oCol:nWidth       := 40


  oCol:=oRECIBOS:oBrw:aCols[12]
  oCol:lAvg:=.T.
  oCol:cHeader      :='Valor'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :=oDp:cPictureDivisa
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRECIBOS:oBrw:aArrayData[oRECIBOS:oBrw:nArrayAt,12],;
                               oCol  := oRECIBOS:oBrw:aCols[12],;
                               FDP(nMonto,oCol:cEditPicture)}

  oCol:=oRECIBOS:oBrw:aCols[13]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRECIBOS:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRECIBOS:oBrw:aArrayData[oRECIBOS:oBrw:nArrayAt,13],;
                              oCol  := oRECIBOS:oBrw:aCols[13],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[13],oCol:cEditPicture)



  oCol:=oRECIBOS:oBrw:aCols[14]
  oCol:cHeader      :='Correo'
  oCol:nWidth       := 40

  oCol:=oRECIBOS:oBrw:aCols[15]
  oCol:cHeader      :='Nombre del Banco'
  oCol:nWidth       := 120


   oRECIBOS:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oRECIBOS:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oRECIBOS:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oRECIBOS:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oRECIBOS:nClrPane1, oRECIBOS:nClrPane2 ) } }

   oRECIBOS:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRECIBOS:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oRECIBOS:oBrw:bLDblClick:={|oBrw|oRECIBOS:RUNCLICK() }

   oRECIBOS:oBrw:bChange:={||oRECIBOS:BRWCHANGE()}
   oRECIBOS:oBrw:CreateFromCode()
    oRECIBOS:bValid   :={|| EJECUTAR("BRWSAVEPAR",oRECIBOS)}
    oRECIBOS:BRWRESTOREPAR()


   oRECIBOS:oWnd:oClient := oRECIBOS:oBrw


   oRECIBOS:Activate({||oRECIBOS:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oRECIBOS:lTmdi,oRECIBOS:oWnd,oRECIBOS:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oRECIBOS:oBrw:nWidth()

   oRECIBOS:oBrw:GoBottom(.T.)
   oRECIBOS:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\VIEW.BMP",NIL,"BITMAPS\VIEWG.BMP";
         WHEN ISTABCON("NMTRABAJADOR");
         ACTION oRECIBOS:VERTRABAJADOR()

   oBtn:cToolTip:="Consultar Trabajador"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\TRABAJADOR.BMP";
         ACTION oRECIBOS:EDITTRABAJADOR()

   oBtn:cToolTip:="Ficha del Trabajador"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EMAIL.BMP",NIL,"BITMAPS\EMAILG.BMP";
          ACTION oRECIBOS:ENVIARMAIL();
          WHEN ISRELEASE("21.10")

  oBtn:cToolTip:="Enviar Recibo por Correo"

  
/*
   IF Empty(oRECIBOS:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","RECIBOS")))
*/

   DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\RECIBO.BMP";
       ACTION oRECIBOS:VERRECIBO()

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oRECIBOS:oBtnRun:=oBtn

       oRECIBOS:oBrw:bLDblClick:={||EVAL(oRECIBOS:oBtnRun:bAction) }


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oRECIBOS:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oRECIBOS:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oRECIBOS:oBrw);
          WHEN LEN(oRECIBOS:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300 .OR. .T.

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oRECIBOS:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oRECIBOS)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oRECIBOS:oBrw,oRECIBOS:cTitle,oRECIBOS:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oRECIBOS:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oRECIBOS:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oRECIBOS:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oRECIBOS:oBrw))

   oBtn:cToolTip:="Previsualización"

   oRECIBOS:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","RECIBOS")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oRECIBOS:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oRECIBOS:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oRECIBOS:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oRECIBOS:oBrw:GoTop(),oRECIBOS:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oRECIBOS:oBrw:PageDown(),oRECIBOS:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oRECIBOS:oBrw:PageUp(),oRECIBOS:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oRECIBOS:oBrw:GoBottom(),oRECIBOS:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRECIBOS:Close()

  oRECIBOS:oBrw:SetColor(0,oRECIBOS:nClrPane1)

  EVAL(oRECIBOS:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oRECIBOS:oBar:=oBar

  

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
  LOCAL aLine:=oRECIBOS:oBrw:aArrayData[oRECIBOS:oBrw:nArrayAt]

  oRep:=REPORTE("RECIBOS",cWhere)
  oRep:SetRango(1,aLine[1],aLine[1])

  oRep:SetCriterio(1,aLine[10])
  oRep:SetCriterio(2,aLine[11])
  oRep:SetCriterio(3,aLine[7])
  oRep:SetCriterio(4,aLine[8])


  oRep:cSql  :=oRECIBOS:cSql
  oRep:cTitle:=oRECIBOS:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oRECIBOS:oPeriodo:nAt,cWhere

  oRECIBOS:nPeriodo:=nPeriodo


  IF oRECIBOS:oPeriodo:nAt=LEN(oRECIBOS:oPeriodo:aItems)

     oRECIBOS:oDesde:ForWhen(.T.)
     oRECIBOS:oHasta:ForWhen(.T.)
     oRECIBOS:oBtn  :ForWhen(.T.)

     DPFOCUS(oRECIBOS:oDesde)

  ELSE

     oRECIBOS:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oRECIBOS:oDesde:VarPut(oRECIBOS:aFechas[1] , .T. )
     oRECIBOS:oHasta:VarPut(oRECIBOS:aFechas[2] , .T. )

     oRECIBOS:dDesde:=oRECIBOS:aFechas[1]
     oRECIBOS:dHasta:=oRECIBOS:aFechas[2]

     cWhere:=oRECIBOS:HACERWHERE(oRECIBOS:dDesde,oRECIBOS:dHasta,oRECIBOS:cWhere,.T.)

     oRECIBOS:LEERDATA(cWhere,oRECIBOS:oBrw,oRECIBOS:cServer)

  ENDIF

  oRECIBOS:SAVEPERIODO()

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

     IF !Empty(oRECIBOS:cWhereQry)
       cWhere:=cWhere + oRECIBOS:cWhereQry
     ENDIF

     oRECIBOS:LEERDATA(cWhere,oRECIBOS:oBrw,oRECIBOS:cServer)

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

   cSql:=" SELECT REC_NUMERO,REC_CODTRA,CONCAT(APELLIDO,',',NOMBRE) AS NOMBRE , REC_FORMAP,REC_NUMFCH,SUM(HIS_MONTO) AS HIS_MONTO,FCH_DESDE,FCH_HASTA,FCH_SISTEM,FCH_TIPNOM,FCH_OTRNOM,REC_VALCAM,SUM(HIS_MONTO)/REC_VALCAM AS REC_MTODIV,"+;
         " EMAIL,DPBANCODIR.BAN_NOMBRE "+;
         " FROM NMHISTORICO "+;
         " INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
         " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
         " LEFT  JOIN DPBANCODIR   ON NMTRABAJADOR.BANCO=DPBANCODIR.BAN_CODIGO "+;
         " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" HIS_CODCON<='DZZZ'  "+;
         " GROUP BY REC_NUMERO,REC_CODTRA "+;
         ""

   oDp:lExcluye:=.T.

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','',0})
   ENDIF

   DPWRITE("TEMP\BRRECIBOS.SQL",oDp:cSql)

   AEVAL(aData,{|a,n| aData[n,4]:=SAYOPTIONS("NMTRABAJADOR","FORMA_PAG",a[4])})


   IF ValType(oBrw)="O"

      oRECIBOS:cSql   :=cSql
      oRECIBOS:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oRECIBOS:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')

      oRECIBOS:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oRECIBOS:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oRECIBOS:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRRECIBOS.MEM",V_nPeriodo:=oRECIBOS:nPeriodo
  LOCAL V_dDesde:=oRECIBOS:dDesde
  LOCAL V_dHasta:=oRECIBOS:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oRECIBOS)
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


    IF Type("oRECIBOS")="O" .AND. oRECIBOS:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oRECIBOS":cWhere_),"oRECIBOS":cWhere_,"oRECIBOS":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oRECIBOS:LEERDATA(oRECIBOS:cWhere_,oRECIBOS:oBrw,oRECIBOS:cServer)
      oRECIBOS:oWnd:Show()
      oRECIBOS:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION VERTRABAJADOR()
    LOCAL cCodTra:=oRECIBOS:oBrw:aArrayData[oRECIBOS:oBrw:nArrayAt,2]
RETURN EJECUTAR("NMTRABJCON",NIL,cCodTra)

FUNCTION EDITTRABAJADOR()
    LOCAL cCodTra:=oRECIBOS:oBrw:aArrayData[oRECIBOS:oBrw:nArrayAt,2]
    oDp:cCodTraIni:=cCodTra
    EJECUTAR("NMTRABAJADOR",0,cCodTra)
    oDp:cCodTraIni:=""
RETURN NIL

FUNCTION VERRECIBO()
  LOCAL cRecibo:=oRECIBOS:oBrw:aArrayData[oRECIBOS:oBrw:nArrayAt,1]
  EJECUTAR("NMRECVIEW",cRecibo)
RETURN NIL

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oRECIBOS)


FUNCTION ENVIARMAIL()
  LOCAL cMemo:="",I,cFile,cRecibo,cWhere:="",cCodigo,cCodRem,cMail,cAsunto:="Recibo de Nómina ",lWait:=.T.
  LOCAL aData:=ACLONE(oRECIBOS:oBrw:aArrayData)

  ADEPURA(aData,{|a,n| Empty(a[14])})

  IF Empty(aData)
     MsgMemo("Requiere Trabajadores con Registro de Correo")
     RETURN .T.
  ENDIF

  IF !MsgNoYes("Desea Crear Correspondencia "+LSTR(LEN(aData))+" Recibos")
     RETURN .T.
  ENDIF

  FOR I=1 TO LEN(aData)

    cRecibo:=ALLTRIM(aData[I,1])
    cCodigo:=aData[I,02]
    cMail  :=aData[I,14]
    cFile  :="TEMP\"+cRecibo+".HTML"
    cAsunto:="Recibo de Nómina "+cRecibo

    EJECUTAR("HTMNMRECIBO",cRecibo,cFile,.F.)

    EJECUTAR("NMRECIBOHTMLSAVE","CODIGO"+GetWhere("=",cCodigo),cCodRem,cFile,cMail,cAsunto,lWait)

  NEXT I

  cWhere:=""

  EJECUTAR("NMBLATENVIA",.T.,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cWhere)

//  cMemo:=MemoRead(cFile)
//  EJECUTAR("NMBLAT",oRecView:cCodTra,"Recibo de Pago "+oRecView:cRecibo ,cMemo)
// oBlat:oText:VarPut(cMemo,.T.)
// AEVAL(oBlat:oBar:aControls,{|o,n|o:ForWhen(.T.)})

RETURN NIL

// EOF
