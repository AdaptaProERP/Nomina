// Programa   : DPCONTABIL
// Fecha/Hora : 16/02/2004 16:39:12
// Propósito  : Seleccionar Periodos Contables
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Nómina
// Tabla      : NMFECHAS
#INCLUDE "INCLUDE\DPXBASE.CH"

PROCE MAIN()
  LOCAL oTable,aData,nCuantos:=0
  LOCAL aProgram:={},I,oFontBrw,oBrw,oCol,cSql,nAt,cTitle
  LOCAL oClaXCon,aAplica:={},cTipos:="SQMO",aCuantos:={}
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )

  CursorWait()

RETURN EJECUTAR("NMCONTABILIZAR")

/*
  IF Empty(oDp:cPathCta) 

     MensajeErr("Es necesario indicar la Ruta del Sistema de Contabilidad",;
                "No existe Ruta de Contabilidad")

     EJECUTAR("DPUBIDPDOS")

     RETURN .T.

  ENDIF
*/
  EJECUTAR("NMRECASGBCO") // Reasigna Bancos y Departamentos
  EJECUTAR("DPCTADSN")

  oDp:cContab:=iif(Empty(oDp:cContab),"CONCEPTO",oDp:cContab)

  cSql:="SELECT TIPO_NOM FROM NMTRABAJADOR NMTRABAJADOR "+;
        "INNER JOIN NMRECIBOS ON CODIGO=REC_CODTRA "+;
        "GROUP BY TIPO_NOM "

  aCuantos:=aTable(cSql,.t.)

  FOR I=1 TO LEN(cTipos)

      nAt:=ASCAN(aCuantos,{|a|a=SUBS(cTipos,I,1)})

      IF nAt>0
         AADD(aAplica,aCuantos[nAt])
      ENDIF

  NEXT I

//  AADD(aAplica,"O")

  AEVAL(aAplica,{|a,n|aAplica[n]:=SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",a)})

  AADD(aAplica," Todos")
  AADD(aAplica," Mostrar sólo los Seleccionados")

  oTable  :=OpenTable(" SELECT FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI "+;
                      " FROM NMFECHAS "+;
                      " LEFT  JOIN NMOTRASNM   ON OTR_CODIGO=FCH_OTRNOM "+;
                      " INNER JOIN NMRECIBOS   ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
                      " INNER JOIN NMHISTORICO ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
                      " WHERE FCH_CONTAB<>'S' "+;
                      "   AND HIS_CODCON<='DZZZ' "+;
                      " GROUP BY FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI "+;
                      " ORDER BY FCH_NUMERO DESC",.T.)

// ? CLPCOPY(oDp:cSql)
// antes " ORDER BY FCH_NUMERO ",.T.)   "ORDER BY FCH_NUMERO DESC",.T.)

  WHILE !oTable:Eof()
    oTable:Replace("FCH_MARCAR",.T.)
    oTable:Replace("FCH_TIPNOM",SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oTable:FCH_TIPNOM))
    oTable:Skip()
  ENDDO

  aProgram:=ACLONE(oTable:aDataFill)
  oTable:End()

  IF Empty(aProgram)
     MensajeErr("No Periodos de Nómina  para Contabilizar")
     RETURN .T.
  ENDIF

  AEVAL(aProgram,{|a,n|nCuantos:=nCuantos+IIF(a[3],1,0)})

  DEFINE FONT oFontBrw NAME "Verdana" SIZE 0,-12

//  oSelNmCont:=DPEDIT():New("Seleccionar Periodos para Contabilizar por ["+oDp:cContab+"] en ["+oDp:cPathCta+"]","NMSELCONT.EDT","oSelNmCont",.T.)

  cTitle:="Seleccionar Periodos para Contabilizar por ["+oDp:cContab+"] en ["+oDp:cPathCta+"]"

  DpMdi(cTitle,"oSelNmCont","BRDOCPROVIEW.EDT")
  oSelNmCont:Windows(0,0,aCoors[3]-160,MIN(740,aCoors[4]-10),.T.) // Maximizado

  oSelNmCont:cModulo :=" Todos"
  oSelNmCont:aTodos  :=ACLONE(aProgram)  // Todos los Programas
  oSelNmCont:nCuantos:=nCuantos
  oSelNmCont:cFileChm:="CAPITULO2.CHM"

  aData:=COPYMODULO(oSelNmCont,oSelNmCont:cModulo,.F.)

/*
  @ 1,12 COMBOBOX oSelNmCont:oModulo VAR oSelNmCont:cModulo ITEMS aAplica;
         ON CHANGE oSelNmCont:PRGCHANGE(oSelNmCont)
*/
  oSelNmCont:oBrw:=TXBrowse():New( oSelNmCont:oDlg )
  oSelNmCont:oBrw:SetArray( aData )

  oBrw:=oSelNmCont:oBrw
  oBrw:SetFont(oFontBrw)

  oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .F.
  oBrw:nFreeze  := 3

  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "Número"
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}

  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Desde"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}

  oCol:=oBrw:aCols[3]
  oCol:cHeader   := "Hasta"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}

  oCol:=oBrw:aCols[4]
  oCol:cHeader   := "Nómina"
  oCol:nWidth       := 90
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}

  oCol:=oBrw:aCols[5]
  oCol:cHeader   := "Otra"
  oCol:nWidth       := 40
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}

  oCol:=oBrw:aCols[6]
  oCol:cHeader   := "Otra Nómina"
  oCol:nWidth       := 300
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}

  oCol:=oBrw:aCols[7]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrw:=oSelNmCont:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,7],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oSelNmCont:ChangeAllImp(oSelNmCont,nRow,nCol,nKey,oCol,.T.)}

  oBrw:bClrStd   := {|oBrw|oBrw:=oSelNmCont:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,7], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrw:nArrayAt%2=0, 14737632 ,  16777215  ) } }

  oBrw:bClrSel   := {|oBrw|oBrw:=oSelNmCont:oBrw, { 65535,  16733011}}


  oSelNmCont:oWnd:oClient := oSelNmCont:oBrw

  oSelNmCont:oBrw:CreateFromCode()

  oBrw:bClrHeader := {|| { 0,  12632256}}

  oSelNmCont:oFocus:=oBrw
  oSelNmCont:Activate({||oSelNmCont:NMCONBAR(oSelNmCont)})

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION NMCONBAR(oSelNmCont)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oSelNmCont:oDlg

   DEFINE FONT oFont NAME "Verdana" SIZE 0,-12 BOLD
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oSelNmCont:exportmov(oSelNmCont)

   oBtn:cToolTip:="Iniciar Generación de Asientos Contables"


 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oSelNmCont:VERRECIBOS()

   oBtn:cToolTip:="Visualizar Recibos"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SELECT.BMP";
          ACTION oSelNmCont:SelectAll(oSelNmCont)

   oBtn:cToolTip:="Seleccionar Todas las Fechas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION oSelNmCont:SelFecha(oSelNmCont)

   oBtn:cToolTip:="Seleccionar Fecha de Tablas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oSelNmCont:oBrw)

  oBtn:cToolTip:="Buscar Programa"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xTOP.BMP";
         ACTION (oSelNmCont:oBrw:GoTop(),oSelNmCont:oBrw:Setfocus())

  oBtn:cToolTip:="Primer Periodo de la Lista"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xSIG.BMP";
         ACTION (oSelNmCont:oBrw:PageDown(),oSelNmCont:oBrw:Setfocus())

  oBtn:cToolTip:="Siguiente Periodo"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xANT.BMP";
         ACTION (oSelNmCont:oBrw:PageUp(),oSelNmCont:oBrw:Setfocus())

  oBtn:cToolTip:="Periodo Anterior"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xFIN.BMP";
         ACTION (oSelNmCont:oBrw:GoBottom(),oSelNmCont:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Periodo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oSelNmCont:Close()

   oBtn:cToolTip:="Cerrar Formulario"

   AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip})

   oSelNmCont:oBrw:SetColor(0,15790320)

   @ 0.1,60+30 SAY oSelNmCont:oCuantos PROMPT " Seleccionados: "+STRZERO(oSelNmCont:nCuantos,4)+"/"+;
                STRZERO(LEN(oSelNmCont:aTodos),4);
                OF oBar BORDER SIZE 190,18 UPDATE

   oBar:SetColor(CLR_BLACK,15724527)


  @ 22,400 COMBOBOX oSelNmCont:oModulo VAR oSelNmCont:cModulo ITEMS aAplica;
         ON CHANGE oSelNmCont:PRGCHANGE(oSelNmCont) OF oBar SIZE 300,20 PIXEL FONT oFont

   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

  
RETURN .T.

/*
// Seleccionar Concepto
*/
FUNCTION PrgSelect(oSelNmCont)
  LOCAL oBrw:=oSelNmCont:oBrw
  LOCAL nArrayAt,nRowSel,nAt:=0,nCuantos:=0
  LOCAL lSelect
  LOCAL nCol:=7
  LOCAL lSelect

  IF ValType(oBrw)!="O"
     RETURN .F.
  ENDIF

  nArrayAt:=oBrw:nArrayAt
  nRowSel :=oBrw:nRowSel
  lSelect :=oBrw:aArrayData[nArrayAt,nCol]

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=!lSelect
  oBrw:RefreshCurrent()

  // Busca en la Lista General)
  nAt:=ASCAN(oSelNmCont:aTodos,{|a,n|a[1]=oBrw:aArrayData[oBrw:nArrayAt,1]})

  IF nAt>0
    oSelNmCont:aTodos[nAt,7]:=!lSelect
  ENDIF

  AEVAL(oSelNmCont:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[7],1,0)})
  oSelNmCont:nCuantos:=nCuantos
  oSelNmCont:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Exportar Programas
*/
FUNCTION exportmov(oSelNmCont)
  LOCAL aSelect:={},cSql,oData

  AEVAL(oSelNmCont:aTodos,{|a,n| IIF(a[7],AADD(aSelect,a[1]),NIL)})

  oSelNmCont:aSelect:=aSelect
  oSelNmCont:cWhere :=GetWhereOr("FCH_NUMERO",aSelect)

  cSql:="SELECT * FROM NMFECHAS WHERE "+oSelNmCont:cWhere

  IF EMPTY(aSelect) 
     MensajeErr("No hay Periodos Seleccionados")
     RETURN .F.
  ENDIF

  // Genera los Asientos Contables
//? "AQUI PUEDE SER"
  EJECUTAR("NMCONTBLD" , oSelNmCont:cWhere)

RETURN NIL

/*
// Iniciar Exportar Tablas
*/
FUNCTION EXPORTRUN(oEdit)

   ? "EXPORTRUN"

RETURN .T.

/*
// Cambiar Modulo
*/
FUNCTION PRGCHANGE(oSelNmCont)
  LOCAL aData,I

  IF UPPE(LEFT(ALLTRIM(oSelNmCont:cModulo),1))="T"
     aData:=ACLONE(oSelNmCont:aTodos)
  ELSE
     aData:=oSelNmCont:COPYMODULO(oSelNmCont,LEFT(ALLTRIM(oSelNmCont:cModulo),2),.T.)
  ENDIF

  oSelNmCont:oBrw:aArrayData:=ACLONE(aData)
  oSelNmCont:oBrw:nArrayAt  :=MIN(LEN(oSelNmCont:oBrw:aArrayData),oSelNmCont:oBrw:nArrayAt)

  oSelNmCont:oBrw:GoTop()
  oSelNmCont:oBrw:Refresh(.T.)

  DpFocus(oSelNmCont:oBrw)

RETURN .T.

FUNCTION COPYMODULO(oSelNmCont,cModulo,lShow)
   LOCAL aData:={},I,nCol:=4

   cModulo:=UPPE(cModulo)

   IF ALLTRIM(cModulo)="TO" 
      cModulo:=.T.
      nCol   :=6
   ELSE
      cModulo:=Left(cModulo,2)
   ENDIF

//   IF lShow
//     ? cModulo,LEN(cModulo),oSelNmCont:aTodos[1,nCol]
//   ENDIF

   IF ALLTRIM(Left(cModulo,2))="MO" // Solo los Seleccionados
     nCol=0
//     IF lShow
//       ? "nCol",nCol
//     ENDIF
   ENDIF
  
   FOR I=1 TO LEN(oSelNmCont:aTodos)

//   ? Left(ALLTRIM(oSelNmCont:aTodos[I,nCol]),2),cModulo

     IF nCol>0 .AND. (nCol=6 .OR. UPPE(Left(ALLTRIM(oSelNmCont:aTodos[I,nCol]),2))=cModulo)
        AADD(aData,oSelNmCont:aTodos[I])  
     ENDIF

     IF nCol=0 .AND. oSelNmCont:aTodos[I,7]
        AADD(aData,oSelNmCont:aTodos[I])  
     ENDIF

   NEXT I

   IF EMPTY(aData) 
      aData:={}
      AADD(aData,{"",CTOD(""),CTOD(""),"","","Ninguno",.F.})
   ENDIF

RETURN aData

/*
// Seleccionar Todos los Programas de la Lista
*/
FUNCTION SelectAll(oSelNmCont)
   LOCAL I,cModulo,nCol:=4,nCuantos:=0,lSelect:=.T.

   cModulo:=Left(ALLTRIM(oSelNmCont:cModulo),2)
   lSelect:=!oSelNmCont:oBrw:aArrayData[1,7]

   FOR I=1 TO LEN(oSelNmCont:aTodos)
     IF oSelNmCont:aTodos[I,nCol]=cModulo .OR. cModulo="TO"
       oSelNmCont:aTodos[I,7]:=lSelect
     ENDIF
   NEXT I

   FOR I=1 TO LEN(oSelNmCont:oBrw:aArrayData)
      oSelNmCont:oBrw:aArrayData[I,7]:=lSelect
   NEXT I
   
  oSelNmCont:oBrw:Refresh(.T.)

  AEVAL(oSelNmCont:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[7],1,0)})
  oSelNmCont:nCuantos:=nCuantos
  oSelNmCont:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Seleccionar Fecha de Programas
*/
FUNCTION SelFecha(oSelNmCont)
  LOCAL dDesde:=FCHINIMES(oDp:dFecha)
  LOCAL dHasta:=FCHFINMES(oDp:dFecha)
  LOCAL oDlg,oDesde,oHasta,oFont
  LOCAL lSalir:=.F.,lOk:=.F.,lAdd:=.T.,I,lSelect:=.T.,nCuantos:=0

  DEFINE FONT oFont NAME "Arial" SIZE 0,-12 BOLD

  DEFINE DIALOG oDlg TITLE "Rango de Fecha"

  @ .1,.5 SAY "Periodo:";
          SIZE 45,08;
          COLOR CLR_BLACK,15724527;
          FONT oFont

  @ 1,.5 BMPGET oDesde VAR dDesde PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         ACTION LbxDate(oDesde,dDesde);
         SIZE 45,NIL

  @ 2,.5 BMPGET oHasta VAR dHasta PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         ACTION LbxDate(oHasta,dHasta);
         SIZE 45,NIL

  @ 3.1,.5 CHECKBOX lAdd PROMPT "Adicionar con los Periodos  Seleccionados";
           SIZE 155,10;
           COLOR CLR_BLACK,15724527;
           FONT oFont

  @ 3,08 BUTTON " Iniciar " ACTION (lSalir:=.T.,lOk:=.T.,oDlg:End());
         SIZE 45,NIL

  @ 3,16 BUTTON " Cerrar  " ACTION (lSalir:=.T.,lOk:=.F.,oDlg:End());
         SIZE 45,NIL

  ACTIVATE DIALOG oDlg CENTERED;
           ON INIT (oDlg:SetColor(CLR_BLACK,15724527))

  IF lOk

    FOR I=1 TO LEN(oSelNmCont:aTodos)

      IF !lAdd
        oSelNmCont:aTodos[I,7]:=!lSelect
      ENDIF

      IF oSelNmCont:aTodos[I,3]>=dDesde .AND. oSelNmCont:aTodos[I,3]<=dHasta
        oSelNmCont:aTodos[I,7]:=lSelect
      ENDIF

    NEXT I

    FOR I=1 TO LEN(oSelNmCont:oBrw:aArrayData)

       IF !lAdd
          oSelNmCont:oBrw:aArrayData[I,7]:=!lSelect
       ENDIF

       IF oSelNmCont:oBrw:aArrayData[I,3]>=dDesde .AND. oSelNmCont:oBrw:aArrayData[I,3]<=dHasta
          oSelNmCont:oBrw:aArrayData[I,7]:=lSelect
       ENDIF

    NEXT I

    oSelNmCont:oModulo:Select( LEN(oSelNmCont:oModulo:aItems) )
    oSelNmCont:cModulo:="MO"
    oSelNmCont:PRGCHANGE(oSelNmCont)

    oSelNmCont:oBrw:Refresh(.T.)

    AEVAL(oSelNmCont:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[7],1,0)})
    oSelNmCont:nCuantos:=nCuantos
    oSelNmCont:oCuantos:Refresh(.T.)
   
  ENDIF

RETURN .T.

/*
// Selecciona o Desmarca a Todos
*/
FUNCTION ChangeAllImp(oSelNmCont)
   LOCAL oBrw:=oSelNmCont:oBrw
   LOCAL lSelect:=!oBrw:aArrayData[1,7]

   AEVAL(oBrw:aArrayData,{|a,n|oBrw:aArrayData[n,7]:=lSelect})

   IF LEFT(ALLTRIM(oSelNmCont:cModulo),2)="TO"
      AEVAL(oSelNmCont:aTodos,{|a,n|oSelNmCont:aTodos[n,7]:=lSelect})
   ENDIF

   oSelNmCont:nCuantos:=IIF(lSelect,LEN(oBrw:aArrayData),0)
   oSelNmCont:oCuantos:Refresh(.T.)

   oBrw:Refresh(.T.)

RETURN .T.
/*
// Ver recibos
*/
FUNCTION VERRECIBOS()
   LOCAL aLine :=oSelNmCont:oBrw:aArrayData[oSelNmCont:oBrw:nArrayAt]
   LOCAL cWhere:="REC_NUMFCH"+GetWhere("=",aLine[1])

   EJECUTAR("BRRECIBOS",cWhere)
RETURN NIL

// EOF


