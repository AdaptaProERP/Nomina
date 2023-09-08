// Programa   : NMINTCAJBCO
// Fecha/Hora : 16/02/2004 16:39:12
// Propósito  : Seleccionar Periodos Contables
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Nómina
// Tabla      : NMFECHAS
#INCLUDE "INCLUDE\DPXBASE.CH"

PROCE MAIN()
  LOCAL oTable,aData,nCuantos:=0
  LOCAL aProgram:={},I,oFontBrw,oBrw,oCol,cSql,nAt
  LOCAL oClaXCon,aAplica:={},cTipos:="SQMO",aCuantos:={}

  CursorWait()

  IF Empty(oDp:cPathBco) 
     MensajeErr("No está Definida la Ruta del Sistema Administrativo")
     EJECUTAR("DPUBIDPDOS")
     RETURN .F.
  ENDIF

  EJECUTAR("NMRECASGBCO") // Reasigna Bancos y Departamentos
  EJECUTAR("DPCTADSN")

  IF oDp:cPathCta!="SGE" .AND. !EJECUTAR("NMDBFADM")
     RETURN .F.
  ENDIF

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

  AADD(aAplica,"O")

  AEVAL(aAplica,{|a,n|aAplica[n]:=SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",a)})

  AADD(aAplica," Todos")
  AADD(aAplica," Mostrar sólo los Seleccionados")

  oTable  :=OpenTable("SELECT FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI "+;
                      "FROM NMFECHAS "+;
                      "LEFT  JOIN NMOTRASNM ON OTR_CODIGO=FCH_OTRNOM "+;
                      "INNER JOIN NMRECIBOS ON REC_NUMFCH=FCH_NUMERO "+;
                      "INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC "+;
                      "WHERE FCH_INTEGR='N' "+;
                      "  AND HIS_CODCON<='DZZZ' "+;
                      "GROUP BY FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI "+;
                      "ORDER BY FCH_NUMERO ",.T.)

  WHILE !oTable:Eof()
    oTable:Replace("FCH_MARCAR",.T.)
    oTable:Replace("FCH_TIPNOM",SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oTable:FCH_TIPNOM))
    oTable:Skip()
  ENDDO

  aProgram:=ACLONE(oTable:aDataFill)
  oTable:End()

  IF Empty(aProgram)
     MensajeErr("No Periodos de Nómina  para Integrar con Caja y Bancos")
     RETURN .T.
  ENDIF

  AEVAL(aProgram,{|a,n|nCuantos:=nCuantos+IIF(a[3],1,0)})

  DEFINE FONT oFontBrw NAME "Verdana" SIZE 0,-12

  oSelNmDeb:=DPEDIT():New("Seleccionar Periodos para Integrar con Caja y Bancos ["+oDp:cPathBco+"]","NMINTADM.EDT","oSelNmDeb",.T.)
  oSelNmDeb:cModulo :=" Todos"
  oSelNmDeb:aTodos  :=ACLONE(aProgram)  // Todos los Programas
  oSelNmDeb:nCuantos:=nCuantos
  oSelNmDeb:cFileChm:="CAPITULO2.CHM"

  aData:=COPYMODULO(oSelNmDeb,oSelNmDeb:cModulo,.F.)

  @ 1,12 COMBOBOX oSelNmDeb:oModulo VAR oSelNmDeb:cModulo ITEMS aAplica;
         ON CHANGE oSelNmDeb:PRGCHANGE(oSelNmDeb)

  oSelNmDeb:oBrw:=TXBrowse():New( oSelNmDeb:oDlg )
  oSelNmDeb:oBrw:SetArray( aData )

  oBrw:=oSelNmDeb:oBrw
  oBrw:SetFont(oFontBrw)

  oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .F.
  oBrw:nFreeze  := 3

  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "Número"
  oCol:bLDClickData:={||oSelNmDeb:PrgSelect(oSelNmDeb)}

  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Desde"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oSelNmDeb:PrgSelect(oSelNmDeb)}

  oCol:=oBrw:aCols[3]
  oCol:cHeader   := "Hasta"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oSelNmDeb:PrgSelect(oSelNmDeb)}

  oCol:=oBrw:aCols[4]
  oCol:cHeader   := "Nómina"
  oCol:nWidth       := 90
  oCol:bLDClickData:={||oSelNmDeb:PrgSelect(oSelNmDeb)}

  oCol:=oBrw:aCols[5]
  oCol:cHeader   := "Otra"
  oCol:nWidth       := 40
  oCol:bLDClickData:={||oSelNmDeb:PrgSelect(oSelNmDeb)}

  oCol:=oBrw:aCols[6]
  oCol:cHeader   := "Otra Nómina"
  oCol:nWidth       := 300
  oCol:bLDClickData:={||oSelNmDeb:PrgSelect(oSelNmDeb)}

  oCol:=oBrw:aCols[7]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrw:=oSelNmDeb:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,7],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oSelNmDeb:PrgSelect(oSelNmDeb)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oSelNmDeb:ChangeAllImp(oSelNmDeb,nRow,nCol,nKey,oCol,.T.)}

  oBrw:bClrStd   := {|oBrw|oBrw:=oSelNmDeb:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,7], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrw:nArrayAt%2=0, 14737632 ,  16777215  ) } }

  oBrw:bClrSel   := {|oBrw|oBrw:=oSelNmDeb:oBrw, { 65535,  16733011}}



  oSelNmDeb:oBrw:CreateFromCode()

  oBrw:bClrHeader := {|| { 0,  12632256}}

  oSelNmDeb:oFocus:=oBrw
  oSelNmDeb:Activate({||oSelNmDeb:NMCONBAR(oSelNmDeb)})

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION NMCONBAR(oSelNmDeb)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oSelNmDeb:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oSelNmDeb:EXPORTMOV(oSelNmDeb)

   oBtn:cToolTip:="Iniciar Generación de Registros para Caja y Bancos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SELECT.BMP";
          ACTION oSelNmDeb:SelectAll(oSelNmDeb)

   oBtn:cToolTip:="Seleccionar Todas las Fechas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION oSelNmDeb:SelFecha(oSelNmDeb)

   oBtn:cToolTip:="Seleccionar Fecha de Tablas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oSelNmDeb:oBrw)

  oBtn:cToolTip:="Buscar Periodo"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xTOP.BMP";
         ACTION (oSelNmDeb:oBrw:GoTop(),oSelNmDeb:oBrw:Setfocus())

  oBtn:cToolTip:="Primer Periodo de la Lista"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xSIG.BMP";
         ACTION (oSelNmDeb:oBrw:PageDown(),oSelNmDeb:oBrw:Setfocus())

  oBtn:cToolTip:="Siguiente Periodo"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xANT.BMP";
         ACTION (oSelNmDeb:oBrw:PageUp(),oSelNmDeb:oBrw:Setfocus())

  oBtn:cToolTip:="Periodo Anterior"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xFIN.BMP";
         ACTION (oSelNmDeb:oBrw:GoBottom(),oSelNmDeb:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Periodo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oSelNmDeb:Close()

   oBtn:cToolTip:="Cerrar Formulario"

   AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip})

   oSelNmDeb:oBrw:SetColor(0,15790320)

   @ 0.1,60 SAY oSelNmDeb:oCuantos PROMPT " Seleccionados: "+STRZERO(oSelNmDeb:nCuantos,4)+"/"+;
                STRZERO(LEN(oSelNmDeb:aTodos),4);
                OF oBar BORDER SIZE 190,18 UPDATE

   oBar:SetColor(CLR_BLACK,15724527)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

  
RETURN .T.

/*
// Seleccionar Concepto
*/
FUNCTION PrgSelect(oSelNmDeb)
  LOCAL oBrw:=oSelNmDeb:oBrw
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
  nAt:=ASCAN(oSelNmDeb:aTodos,{|a,n|a[1]=oBrw:aArrayData[oBrw:nArrayAt,1]})

  IF nAt>0
    oSelNmDeb:aTodos[nAt,7]:=!lSelect
  ENDIF

  AEVAL(oSelNmDeb:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[7],1,0)})
  oSelNmDeb:nCuantos:=nCuantos
  oSelNmDeb:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Exportar Programas
*/
FUNCTION EXPORTMOV(oSelNmDeb)
  LOCAL aSelect:={},cSql,oData

  AEVAL(oSelNmDeb:aTodos,{|a,n| IIF(a[7],AADD(aSelect,a[1]),NIL)})

  oSelNmDeb:aSelect:=aSelect
  oSelNmDeb:cWhere :=GetWhereOr("FCH_NUMERO",aSelect)

  cSql:="SELECT * FROM NMFECHAS WHERE "+oSelNmDeb:cWhere

  IF EMPTY(aSelect) 
     MensajeErr("No hay Periodos Seleccionados")
     RETURN .F.
  ENDIF

  // Genera los Asientos Contables
  EJECUTAR("NMINIADM", oSelNmDeb:cWhere,oSelNmDeb)

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
FUNCTION PRGCHANGE(oSelNmDeb)
  LOCAL aData,I

  IF UPPE(LEFT(ALLTRIM(oSelNmDeb:cModulo),1))="T"
     aData:=ACLONE(oSelNmDeb:aTodos)
  ELSE
     aData:=oSelNmDeb:COPYMODULO(oSelNmDeb,LEFT(ALLTRIM(oSelNmDeb:cModulo),2),.T.)
  ENDIF

  oSelNmDeb:oBrw:aArrayData:=ACLONE(aData)
  oSelNmDeb:oBrw:nArrayAt  :=MIN(LEN(oSelNmDeb:oBrw:aArrayData),oSelNmDeb:oBrw:nArrayAt)

  oSelNmDeb:oBrw:GoTop()
  oSelNmDeb:oBrw:Refresh(.T.)

  DpFocus(oSelNmDeb:oBrw)

RETURN .T.

FUNCTION COPYMODULO(oSelNmDeb,cModulo,lShow)
   LOCAL aData:={},I,nCol:=4

   cModulo:=UPPE(cModulo)

   IF ALLTRIM(cModulo)="TO" 
      cModulo:=.T.
      nCol   :=6
   ELSE
      cModulo:=Left(cModulo,2)
   ENDIF

//   IF lShow
//     ? cModulo,LEN(cModulo),oSelNmDeb:aTodos[1,nCol]
//   ENDIF

   IF ALLTRIM(Left(cModulo,2))="MO" // Solo los Seleccionados
     nCol=0
//     IF lShow
//       ? "nCol",nCol
//     ENDIF
   ENDIF
  
   FOR I=1 TO LEN(oSelNmDeb:aTodos)

//   ? Left(ALLTRIM(oSelNmDeb:aTodos[I,nCol]),2),cModulo

     IF nCol>0 .AND. (nCol=6 .OR. UPPE(Left(ALLTRIM(oSelNmDeb:aTodos[I,nCol]),2))=cModulo)
        AADD(aData,oSelNmDeb:aTodos[I])  
     ENDIF

     IF nCol=0 .AND. oSelNmDeb:aTodos[I,7]
        AADD(aData,oSelNmDeb:aTodos[I])  
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
FUNCTION SelectAll(oSelNmDeb)
   LOCAL I,cModulo,nCol:=4,nCuantos:=0,lSelect:=.T.

   cModulo:=Left(ALLTRIM(oSelNmDeb:cModulo),2)
   lSelect:=!oSelNmDeb:oBrw:aArrayData[1,7]

   FOR I=1 TO LEN(oSelNmDeb:aTodos)
     IF oSelNmDeb:aTodos[I,nCol]=cModulo .OR. cModulo="TO"
       oSelNmDeb:aTodos[I,7]:=lSelect
     ENDIF
   NEXT I

   FOR I=1 TO LEN(oSelNmDeb:oBrw:aArrayData)
      oSelNmDeb:oBrw:aArrayData[I,7]:=lSelect
   NEXT I
   
  oSelNmDeb:oBrw:Refresh(.T.)

  AEVAL(oSelNmDeb:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[7],1,0)})
  oSelNmDeb:nCuantos:=nCuantos
  oSelNmDeb:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Seleccionar Fecha de Programas
*/
FUNCTION SelFecha(oSelNmDeb)
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

    FOR I=1 TO LEN(oSelNmDeb:aTodos)

      IF !lAdd
        oSelNmDeb:aTodos[I,7]:=!lSelect
      ENDIF

      IF oSelNmDeb:aTodos[I,3]>=dDesde .AND. oSelNmDeb:aTodos[I,3]<=dHasta
        oSelNmDeb:aTodos[I,7]:=lSelect
      ENDIF

    NEXT I

    FOR I=1 TO LEN(oSelNmDeb:oBrw:aArrayData)

       IF !lAdd
          oSelNmDeb:oBrw:aArrayData[I,7]:=!lSelect
       ENDIF

       IF oSelNmDeb:oBrw:aArrayData[I,3]>=dDesde .AND. oSelNmDeb:oBrw:aArrayData[I,3]<=dHasta
          oSelNmDeb:oBrw:aArrayData[I,7]:=lSelect
       ENDIF

    NEXT I

    oSelNmDeb:oModulo:Select( LEN(oSelNmDeb:oModulo:aItems) )
    oSelNmDeb:cModulo:="MO"
    oSelNmDeb:PRGCHANGE(oSelNmDeb)

    oSelNmDeb:oBrw:Refresh(.T.)

    AEVAL(oSelNmDeb:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[7],1,0)})
    oSelNmDeb:nCuantos:=nCuantos
    oSelNmDeb:oCuantos:Refresh(.T.)
   
  ENDIF

RETURN .T.

/*
// Selecciona o Desmarca a Todos
*/
FUNCTION ChangeAllImp(oSelNmDeb)
   LOCAL oBrw:=oSelNmDeb:oBrw
   LOCAL lSelect:=!oBrw:aArrayData[1,7]

   AEVAL(oBrw:aArrayData,{|a,n|oBrw:aArrayData[n,7]:=lSelect})

   IF LEFT(ALLTRIM(oSelNmDeb:cModulo),2)="TO"
      AEVAL(oSelNmDeb:aTodos,{|a,n|oSelNmDeb:aTodos[n,7]:=lSelect})
   ENDIF

   oSelNmDeb:nCuantos:=IIF(lSelect,LEN(oBrw:aArrayData),0)
   oSelNmDeb:oCuantos:Refresh(.T.)

   oBrw:Refresh(.T.)

RETURN .T.

// EOF



