// Programa   : BRNMVERTICAL
// Fecha/Hora : 30/04/2014 15:47:03
// Propósito  : "Nómina Vertical"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"
#INCLUDE "DpxReport.ch"


PROCE MAIN(cSql,nColIni,cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMVERTICAL.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")

   cTitle:="Nómina Vertical" +IF(Empty(cTitle),"",cTitle)

   DEFAULT cSql:=" SELECT CODIGO,APELLIDO,NOMBRE,CEDULA,"+;
                 " SUM(IF(HIS_CODCON='A002',HIS_MONTO,0)) AS A002,"+;
                 " SUM(IF(HIS_CODCON='A017',HIS_MONTO,0)) AS A017,"+;
                 " SUM(IF(HIS_CODCON='A054',HIS_MONTO,0)) AS A054,"+;
                 " SUM(IF(LEFT(HIS_CODCON,1)='A',HIS_MONTO,0)) AS ASIGNA,"+;
                 " SUM(IF(HIS_CODCON='D004',HIS_MONTO,0)) AS D004,"+;
                 " SUM(IF(HIS_CODCON='D005',HIS_MONTO,0)) AS D005,"+;
                 " SUM(IF(HIS_CODCON='D006',HIS_MONTO,0)) AS D006,"+;
                 " SUM(IF(HIS_CODCON='D012',HIS_MONTO,0)) AS D012,"+;
                 " SUM(IF(HIS_CODCON='D014',HIS_MONTO,0)) AS D014,"+;
                 " SUM(IF(HIS_CODCON='D020',HIS_MONTO,0)) AS D020,"+;
                 " SUM(IF(HIS_CODCON='D028',HIS_MONTO,0)) AS D028,"+;
                 " SUM(IF(HIS_CODCON='D071',HIS_MONTO,0)) AS D071,"+;
                 " SUM(IF(LEFT(HIS_CODCON,1)='D',HIS_MONTO,0)) AS DEDUCC"+;
                 " FROM NMHISTORICO "+;
                 " INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO  "+;
                 " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
                 " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO  WHERE 1=1"


   DEFAULT nColIni:=5

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4 


   // Obtiene el Código del Parámetro

   aData :=LEERDATA(cSql)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)

   oDp:oFrm:=oNMVERTICAL
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL I,cBlq,cHeader,nWidth:=100,cPicture:=["999,999,999.99"],oTable

   oTable:=OpenTable(cSql,.F.)
   oTable:End()

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRNMVERTICAL.EDT","oNMVERTICAL",.F.)

   oNMVERTICAL:CreateWindow(NIL,NIL,NIL,550,544+58)

   oNMVERTICAL:cCodSuc  :=cCodSuc
   oNMVERTICAL:lMsgBar  :=.F.
   oNMVERTICAL:cPeriodo :=aPeriodos[nPeriodo]
   oNMVERTICAL:cCodSuc  :=cCodSuc
   oNMVERTICAL:nPeriodo :=nPeriodo
   oNMVERTICAL:cNombre  :=""
   oNMVERTICAL:dDesde   :=dDesde
   oNMVERTICAL:dHasta   :=dHasta
   oNMVERTICAL:cWhere   :=cWhere
   oNMVERTICAL:cWhere_  :=""
   oNMVERTICAL:cWhereQry:=""
   oNMVERTICAL:cSql     :=oDp:cSql
   oNMVERTICAL:oWhere   :=TWHERE():New(oNMVERTICAL)
   oNMVERTICAL:cCodPar  :=cCodPar // Código del Parámetro

   oNMVERTICAL:oBrw:=TXBrowse():New( oNMVERTICAL:oDlg )
   oNMVERTICAL:oBrw:SetArray( aData, .T. )
   oNMVERTICAL:oBrw:SetFont(oFont)

   oNMVERTICAL:oBrw:lFooter     := .T.
   oNMVERTICAL:oBrw:lHScroll    := .T.
   oNMVERTICAL:oBrw:nHeaderLines:= 2
   oNMVERTICAL:oBrw:nDataLines  := 1
   oNMVERTICAL:oBrw:nFooterLines:= 1

   oNMVERTICAL:aData            :=ACLONE(aData)

   AEVAL(oNMVERTICAL:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  
   oCol:=oNMVERTICAL:oBrw:aCols[1]
   oCol:cHeader      :='Código'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMVERTICAL:oBrw:aArrayData ) } 
   oCol:nWidth       := 80

   oCol:=oNMVERTICAL:oBrw:aCols[2]
   oCol:cHeader      :='Apellido'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMVERTICAL:oBrw:aArrayData ) } 
   oCol:nWidth       := 200

   oCol:=oNMVERTICAL:oBrw:aCols[3]
   oCol:cHeader      :='Nombre'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMVERTICAL:oBrw:aArrayData ) } 
   oCol:nWidth       := 200

   oCol:=oNMVERTICAL:oBrw:aCols[4]
   oCol:cHeader      :='Cédula'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMVERTICAL:oBrw:aArrayData ) } 
   oCol:nWidth       := 64
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
//   oCol:bStrData:={|nMonto|nMonto:= oNMVERTICAL:oBrw:aArrayData[oNMVERTICAL:oBrw:nArrayAt,4],TRAN(nMonto,'999,999,999.99')}
//  oCol:cFooter      :=TRAN(aTotal[4],'999,999,999.99')


   FOR I=nColIni TO LEN(oTable:aFields)

     oCol:=oNMVERTICAL:oBrw:aCols[I]
     oCol:cHeader:=ALLTRIM(SQLGET("NMCONCEPTOS","CON_COLUMN","CON_CODIGO"+GetWhere("=",oTable:FieldName(I))))+CRLF+;
                   oTable:FieldName(I)

     oCol:nWidth :=120

     oCol:nDataStrAlign:= AL_RIGHT
     oCol:nHeadStrAlign:= AL_RIGHT
     oCol:nFootStrAlign:= AL_RIGHT

     cBlq:="{|nMonto|nMonto:=oNMVERTICAL:oBrw:aArrayData[oNMVERTICAL:oBrw:nArrayAt,"+LSTR(I)+"],"+;
            "TRAN(nMonto,"+cPicture+")}"

     oCol:bStrData:=BloqueCod(cBlq)
     oCol:cFooter      :=TRAN(aTotal[I],&cPicture.)

   NEXT I

   oNMVERTICAL:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMVERTICAL:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMVERTICAL:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15790320, 14671839 ) } }

   oNMVERTICAL:oBrw:bClrHeader            := {|| {0,14671839 }}
   oNMVERTICAL:oBrw:bClrFooter            := {|| {0,14671839 }}


   oNMVERTICAL:oBrw:bLDblClick:={|oBrw|oNMVERTICAL:oRep:=oNMVERTICAL:RUNCLICK() }

   oNMVERTICAL:oBrw:bChange:={||oNMVERTICAL:BRWCHANGE()}
   oNMVERTICAL:oBrw:CreateFromCode()

   oNMVERTICAL:Activate({||oNMVERTICAL:ViewDatBar(oNMVERTICAL)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oNMVERTICAL)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oNMVERTICAL:oDlg
   LOCAL nLin:=0

   oNMVERTICAL:oBrw:GoBottom(.T.)
   oNMVERTICAL:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMVERTICAL.EDT")
     oNMVERTICAL:oBrw:Move(44,0,544+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("NMTRABJCON",NIL,oNMVERTICAL:oBrw:aArrayData[oNMVERTICAL:oBrw:nArrayAt,1])

     oBtn:cToolTip:="Consultar Trabajador"

 

   IF !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMVERTICAL")))

         DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XBROWSE.BMP";
         ACTION EJECUTAR("BRWRUNBRWLINK",oNMVERTICAL:oBrw,"NMVERTICAL",oNMVERTICAL:cSql,oNMVERTICAL:nPeriodo,oNMVERTICAL:dDesde,oNMVERTICAL:dHasta)

         oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"

         oNMVERTICAL:oBtnRun:=oBtn

         oNMVERTICAL:oBrw:bLDblClick:={||EVAL(oNMVERTICAL:oBtnRun:bAction) }


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMVERTICAL:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oNMVERTICAL:oBrw,oNMVERTICAL:cTitle,oNMVERTICAL:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oNMVERTICAL:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oNMVERTICAL:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oNMVERTICAL:oBtnHtml:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oNMVERTICAL:IMPRIMIR()

   oBtn:cToolTip:="Imprimir"

   oNMVERTICAL:oBtnPrint:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION EJECUTAR("BRWPREVIEW",oNMVERTICAL:oBrw,oNMVERTICAL:cTitle)

   oBtn:cToolTip:="Previsualizar"

   oNMVERTICAL:oBtnPreviewt:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMVERTICAL:BRWQUERY()

   oBtn:cToolTip:="Imprimir"
 

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMVERTICAL:oBrw:GoTop(),oNMVERTICAL:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNMVERTICAL:oBrw:PageDown(),oNMVERTICAL:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNMVERTICAL:oBrw:PageUp(),oNMVERTICAL:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMVERTICAL:oBrw:GoBottom(),oNMVERTICAL:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMVERTICAL:Close()

  oNMVERTICAL:oBrw:SetColor(0,15790320)

  EVAL(oNMVERTICAL:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,15724527)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

  oNMVERTICAL:oBar:=oBar

  

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

  oRep:=REPORTE("BRNMVERTICAL",cWhere)
  oRep:cSql  :=oNMVERTICAL:cSql
  oRep:cTitle:=oNMVERTICAL:cTitle


RETURN .T.

FUNCTION LEEFECHAS()
RETURN .T.


FUNCTION LEERDATA(cSql,cWhere,oBrw)
   LOCAL aData:={},aTotal:={},oCol,aLines:={}

   DEFAULT cWhere:=""

   aData:=ASQL(cSql)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   IF ValType(oBrw)="O"
      oBrw:Refresh(.T.)
      AEVAL(oNMVERTICAL:oBar:aControls,{|o,n| o:ForWhen(.T.)})
      oNMVERTICAL:SAVEPERIODO()
   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMVERTICAL.MEM",V_nPeriodo:=oNMVERTICAL:nPeriodo
  LOCAL V_dDesde:=oNMVERTICAL:dDesde
  LOCAL V_dHasta:=oNMVERTICAL:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMVERTICAL)
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

    IF Type("oNMVERTICAL")="O" .AND. oNMVERTICAL:oWnd:hWnd>0

      oNMVERTICAL:LEERDATA(oNMVERTICAL:cWhere_,oNMVERTICAL:oBrw)
      oNMVERTICAL:oWnd:Show()
      oNMVERTICAL:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION BRWREPORT()
   LOCAL lPreview:=.T.,lModal:=.F.
   oNMVERTICAL:oBrw:Print( lPreview, lModal, oNMVERTICAL ) 
RETURN NIL

/*
// Genera Correspondencia Masiva
*/
// EOF
