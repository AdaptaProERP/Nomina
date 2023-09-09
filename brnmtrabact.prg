// Programa   : BRNMTRABACT
// Fecha/Hora : 18/04/2014 19:38:30
// Propósito  : "Trabajadores Activos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMTRABACT.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")

   cTitle:="Trabajadores Activos" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4 


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T.

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

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere))

   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere))

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)

   oDp:oFrm:=oNMTRABACT
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRNMTRABACT.EDT","oNMTRABACT",.F.)

   oNMTRABACT:CreateWindow(NIL,NIL,NIL,550,640+58)

   oNMTRABACT:cCodSuc  :=cCodSuc
   oNMTRABACT:lMsgBar  :=.F.
   oNMTRABACT:cPeriodo :=aPeriodos[nPeriodo]
   oNMTRABACT:cCodSuc  :=cCodSuc
   oNMTRABACT:nPeriodo :=nPeriodo
   oNMTRABACT:cNombre  :=""
   oNMTRABACT:dDesde   :=dDesde
   oNMTRABACT:dHasta   :=dHasta
   oNMTRABACT:cWhere   :=cWhere
   oNMTRABACT:cWhere_  :=""
   oNMTRABACT:cWhereQry:=""
   oNMTRABACT:cSql     :=oDp:cSql
   oNMTRABACT:oWhere   :=TWHERE():New(oNMTRABACT)
   oNMTRABACT:cCodPar  :=cCodPar // Código del Parámetro


   oNMTRABACT:oBrw:=TXBrowse():New( oNMTRABACT:oDlg )
   oNMTRABACT:oBrw:SetArray( aData, .T. )
   oNMTRABACT:oBrw:SetFont(oFont)

   oNMTRABACT:oBrw:lFooter     := .T.
   oNMTRABACT:oBrw:lHScroll    := .F.
   oNMTRABACT:oBrw:nHeaderLines:= 1
   oNMTRABACT:oBrw:nDataLines  := 1
   oNMTRABACT:oBrw:nFooterLines:= 1

   oNMTRABACT:aData            :=ACLONE(aData)

   AEVAL(oNMTRABACT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oNMTRABACT:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oNMTRABACT:oBrw:aCols[2]
  oCol:cHeader      :='Apellido'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  oCol:=oNMTRABACT:oBrw:aCols[3]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 200

  oCol:=oNMTRABACT:oBrw:aCols[4]
  oCol:cHeader      :='Salario'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  oCol:=oNMTRABACT:oBrw:aCols[5]
  oCol:cHeader      :='Fecha de Ingreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMTRABACT:oBrw:aArrayData[oNMTRABACT:oBrw:nArrayAt,5],TRAN(nMonto,'999,999,999.99')}



  oCol:=oNMTRABACT:oBrw:aCols[6]
  oCol:cHeader      :='Fecha de Ingreso'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMTRABACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

   oNMTRABACT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMTRABACT:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMTRABACT:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15790320, 14671839 ) } }

   oNMTRABACT:oBrw:bClrHeader            := {|| {0,14671839 }}
   oNMTRABACT:oBrw:bClrFooter            := {|| {0,14671839 }}


   oNMTRABACT:oBrw:bLDblClick:={|oBrw|oNMTRABACT:oRep:=oNMTRABACT:RUNCLICK() }

   oNMTRABACT:oBrw:CreateFromCode()

   oNMTRABACT:Activate({||oNMTRABACT:ViewDatBar(oNMTRABACT)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oNMTRABACT)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oNMTRABACT:oDlg
   LOCAL nLin:=0

   oNMTRABACT:oBrw:GoBottom(.T.)
   oNMTRABACT:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMTRABACT.EDT")
     oNMTRABACT:oBrw:Move(44,0,640+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


   IF .F.

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMTRABACT:oBrw,oNMTRABACT:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   IF .F.

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EMAIL.BMP";
            ACTION oNMTRABACT:GENMAIL()

     oBtn:cToolTip:="Generar Correspondencia Masiva"


   ENDIF

  

   IF !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMTRABACT")))

         DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XBROWSE.BMP";
         ACTION EJECUTAR("BRWRUNBRWLINK",oNMTRABACT:oBrw,"NMTRABACT",oNMTRABACT:cSql,oNMTRABACT:nPeriodo,oNMTRABACT:dDesde,oNMTRABACT:dHasta)

         oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"

         oNMTRABACT:oBtnRun:=oBtn

         oNMTRABACT:oBrw:bLDblClick:={||EVAL(oNMTRABACT:oBtnRun:bAction) }


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMTRABACT:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMTRABACT:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oNMTRABACT:oBrw,oNMTRABACT:cTitle,oNMTRABACT:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oNMTRABACT:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oNMTRABACT:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oNMTRABACT:oBtnHtml:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oNMTRABACT:IMPRIMIR()

   oBtn:cToolTip:="Imprimir"

   oNMTRABACT:oBtnPrint:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMTRABACT:BRWQUERY()

   oBtn:cToolTip:="Imprimir"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMTRABACT:oBrw:GoTop(),oNMTRABACT:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNMTRABACT:oBrw:PageDown(),oNMTRABACT:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNMTRABACT:oBrw:PageUp(),oNMTRABACT:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMTRABACT:oBrw:GoBottom(),oNMTRABACT:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMTRABACT:Close()

  oNMTRABACT:oBrw:SetColor(0,15790320)

  oBar:SetColor(CLR_BLACK,15724527)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

  oNMTRABACT:oBar:=oBar

  

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

  oRep:=REPORTE("BRNMTRABACT",cWhere)
  oRep:cSql  :=oNMTRABACT:cSql
  oRep:cTitle:=oNMTRABACT:cTitle


RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMTRABACT:oPeriodo:nAt,cWhere

  oNMTRABACT:nPeriodo:=nPeriodo

  IF oNMTRABACT:oPeriodo:nAt=LEN(oNMTRABACT:oPeriodo:aItems)

     oNMTRABACT:oDesde:ForWhen(.T.)
     oNMTRABACT:oHasta:ForWhen(.T.)
     oNMTRABACT:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMTRABACT:oDesde)

  ELSE

     oNMTRABACT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMTRABACT:oDesde:VarPut(oNMTRABACT:aFechas[1] , .T. )
     oNMTRABACT:oHasta:VarPut(oNMTRABACT:aFechas[2] , .T. )

     oNMTRABACT:dDesde:=oNMTRABACT:aFechas[1]
     oNMTRABACT:dHasta:=oNMTRABACT:aFechas[2]

     cWhere:=oNMTRABACT:HACERWHERE(oNMTRABACT:dDesde,oNMTRABACT:dHasta,oNMTRABACT:cWhere,.T.)

     oNMTRABACT:LEERDATA(cWhere,oNMTRABACT:oBrw)

  ENDIF

  oNMTRABACT:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oNMTRABACT:cWhereQry)
       cWhere:=cWhere + oNMTRABACT:cWhereQry
     ENDIF

     oNMTRABACT:LEERDATA(cWhere,oNMTRABACT:oBrw)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}

   DEFAULT cWhere:=""

   cSql:=" SELECT CODIGO,APELLIDO,NOMBRE,TIPO_NOM,SALARIO,FECHA_ING FROM NMTRABAJADOR WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" CONDICION='A'"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   aData:=ASQL(cSql)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
//    AADD(aData,{'','','','',0,CTOD("")})
   ENDIF

   IF ValType(oBrw)="O"

      oNMTRABACT:cSql   :=cSql
      oNMTRABACT:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oNMTRABACT:oBrw:aCols[5]
      

      oNMTRABACT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oNMTRABACT:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMTRABACT:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMTRABACT.MEM",V_nPeriodo:=oNMTRABACT:nPeriodo
  LOCAL V_dDesde:=oNMTRABACT:dDesde
  LOCAL V_dHasta:=oNMTRABACT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMTRABACT)
RETURN .T.

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()

    IF Type("oNMTRABACT")="O" .AND. oNMTRABACT:oWnd:hWnd>0

      oNMTRABACT:LEERDATA(oNMTRABACT:cWhere_,oNMTRABACT:oBrw)
      oNMTRABACT:oWnd:Show()
      oNMTRABACT:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/


// EOF
