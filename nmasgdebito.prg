// Programa   : NMASGDEBITO
// Fecha/Hora : 16/02/2004 16:39:12
// Propósito  : Asignación de Débitos por Transferencia Bancaria
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Nómina
// Tabla      : NMFECHAS
#INCLUDE "INCLUDE\DPXBASE.CH"

PROCE MAIN()
  LOCAL oTable,aData,nCuantos:=0
  LOCAL aFechas:={},I,oFontBrw,oBrw,oCol,cSql,nAt,nMarcar:=0
  LOCAL oClaXCon,aAplica:={},cTipos:="SQMO",aCuantos:={}

  CursorWait()

  cSql:="SELECT FCH_TIPNOM FROM NMFECHAS "+;
        "GROUP BY FCH_TIPNOM "

  aAplica:=aTable(cSql,.t.)
  
/*
  FOR I=1 TO LEN(cTipos)
      nAt:=ASCAN(aCuantos,{|a|a=SUBS(cTipos,I,1)})
      IF nAt>0
         AADD(aAplica,aCuantos[nAt])
      ENDIF
  NEXT I

  AADD(aAplica,"O")
*/

  AEVAL(aAplica,{|a,n|aAplica[n]:=SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",a)})

  AADD(aAplica," Todos")
  AADD(aAplica," Mostrar sólo los Seleccionados")

  oTable  :=OpenTable("SELECT FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI, "+;
                      "COUNT(*) AS CUANTOS "+;
                      "FROM NMFECHAS "+;
                      "LEFT  JOIN NMOTRASNM ON OTR_CODIGO=FCH_OTRNOM "+;
                      "INNER JOIN NMRECIBOS ON REC_NUMFCH=FCH_NUMERO "+;
                      " WHERE REC_FORMAP='T' "+;
                      "   AND FCH_INTEGR<>'S' "+;
                      "GROUP BY FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI "+;
                      "HAVING COUNT(*) > 0 "+;
                      "ORDER BY FCH_NUMERO DESC ",.T.)

  WHILE !oTable:Eof()
    oTable:Replace("FCH_MARCAR",.T.)
    oTable:Replace("FCH_TIPNOM",SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oTable:FCH_TIPNOM))
    oTable:Skip()
  ENDDO

  aFechas:=ACLONE(oTable:aDataFill)
  oTable:End()

  IF Empty(aFechas)
     MensajeErr("No Periodos de Nómina  con forma de pago Transferencia")
     RETURN .T.
  ENDIF

  nMarcar:=oTable:FieldPos("FCH_MARCAR")
  AEVAL(aFechas,{|a,n|nCuantos:=nCuantos+IIF(a[nMarcar],1,0)})

  DEFINE FONT oFontBrw NAME "Verdana" SIZE 0,-12

  oFrmAsgDeb:=DPEDIT():New("Seleccionar Periodo para la Asignación de Débitos por Transferencia Bancaria","NMASGCHQ.EDT","oFrmAsgDeb",.T.)
  oFrmAsgDeb:cModulo :=" Todos"
  oFrmAsgDeb:aTodos  :=ACLONE(aFechas)  // Todos los Programas
  oFrmAsgDeb:nCuantos:=nCuantos
  oFrmAsgDeb:nMarcar :=nMarcar
  oFrmAsgDeb:cFileChm:="CAPITULO2.CHM"
  oFrmAsgDeb:cTopic  :="NMDTB"

  aData:=COPYMODULO(oFrmAsgDeb,oFrmAsgDeb:cModulo,.F.)

  @ 1,12 COMBOBOX oFrmAsgDeb:oModulo VAR oFrmAsgDeb:cModulo ITEMS aAplica;
         ON CHANGE oFrmAsgDeb:PRGCHANGE(oFrmAsgDeb)

  oFrmAsgDeb:oBrw:=TXBrowse():New( oFrmAsgDeb:oDlg )
  oFrmAsgDeb:oBrw:SetArray( aData )

  oBrw:=oFrmAsgDeb:oBrw
  oBrw:SetFont(oFontBrw)

  oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .F.
  oBrw:nFreeze  := 3

  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "Número"
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}

  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Desde"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}

  oCol:=oBrw:aCols[3]
  oCol:cHeader   := "Hasta"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}

  oCol:=oBrw:aCols[4]
  oCol:cHeader   := "Nómina"
  oCol:nWidth       := 90
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}

  oCol:=oBrw:aCols[5]
  oCol:cHeader   := "Otra"
  oCol:nWidth       := 40
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}

  oCol:=oBrw:aCols[6]
  oCol:cHeader   := "Otra Nómina"
  oCol:nWidth       := 270
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}

  oCol:=oBrw:aCols[7]
  oCol:cHeader   := "Recibos"
  oCol:nWidth       := 55
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT

  oCol:=oBrw:aCols[8]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrw:=oFrmAsgDeb:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,8],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oFrmAsgDeb:PrgSelect(oFrmAsgDeb)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oFrmAsgDeb:ChangeAllImp(oFrmAsgDeb,nRow,nCol,nKey,oCol,.T.)}

  oBrw:bClrStd   := {|oBrw|oBrw:=oFrmAsgDeb:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,8], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrw:nArrayAt%2=0, 14737632 ,  16777215  ) } }

  oBrw:bClrSel   := {|oBrw|oBrw:=oFrmAsgDeb:oBrw, { 65535,  16733011}}



  oFrmAsgDeb:oBrw:CreateFromCode()

  oBrw:bClrHeader := {|| { 0,  12632256}}

  oFrmAsgDeb:oFocus:=oBrw
  oFrmAsgDeb:Activate({||oFrmAsgDeb:NMCONBAR(oFrmAsgDeb)})

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION NMCONBAR(oFrmAsgDeb)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmAsgDeb:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oFrmAsgDeb:AsignaDeb(oFrmAsgDeb)

   oBtn:cToolTip:="Asignación de Notas de Débito"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SELECT.BMP";
          ACTION oFrmAsgDeb:SelectAll(oFrmAsgDeb)

   oBtn:cToolTip:="Seleccionar Todas las Fechas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION oFrmAsgDeb:SelFecha(oFrmAsgDeb)

   oBtn:cToolTip:="Seleccionar Fecha de Tablas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oFrmAsgDeb:oBrw)

  oBtn:cToolTip:="Buscar Periodo"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xTOP.BMP";
         ACTION (oFrmAsgDeb:oBrw:GoTop(),oFrmAsgDeb:oBrw:Setfocus())

  oBtn:cToolTip:="Primer Periodo de la Lista"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xSIG.BMP";
         ACTION (oFrmAsgDeb:oBrw:PageDown(),oFrmAsgDeb:oBrw:Setfocus())

  oBtn:cToolTip:="Siguiente Periodo"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xANT.BMP";
         ACTION (oFrmAsgDeb:oBrw:PageUp(),oFrmAsgDeb:oBrw:Setfocus())

  oBtn:cToolTip:="Periodo Anterior"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xFIN.BMP";
         ACTION (oFrmAsgDeb:oBrw:GoBottom(),oFrmAsgDeb:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Periodo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFrmAsgDeb:Close()

   oBtn:cToolTip:="Cerrar Formulario"

   AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip})

   oFrmAsgDeb:oBrw:SetColor(0,15790320)

   @ 0.1,60 SAY oFrmAsgDeb:oCuantos PROMPT " Seleccionados: "+STRZERO(oFrmAsgDeb:nCuantos,4)+"/"+;
                STRZERO(LEN(oFrmAsgDeb:aTodos),4);
                OF oBar BORDER SIZE 190,18 UPDATE

   oBar:SetColor(CLR_BLACK,15724527)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

  
RETURN .T.

/*
// Seleccionar Concepto
*/
FUNCTION PrgSelect(oFrmAsgDeb)
  LOCAL oBrw:=oFrmAsgDeb:oBrw
  LOCAL nArrayAt,nRowSel,nAt:=0,nCuantos:=0
  LOCAL lSelect
  LOCAL nCol:=8
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
  nAt:=ASCAN(oFrmAsgDeb:aTodos,{|a,n|a[1]=oBrw:aArrayData[oBrw:nArrayAt,1]})

  IF nAt>0
    oFrmAsgDeb:aTodos[nAt,8]:=!lSelect
  ENDIF

  AEVAL(oFrmAsgDeb:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[8],1,0)})
  oFrmAsgDeb:nCuantos:=nCuantos
  oFrmAsgDeb:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Exportar Programas
*/
FUNCTION AsignaDeb(oFrmAsgDeb)
  LOCAL aSelect:={},cSql,oData

  AEVAL(oFrmAsgDeb:aTodos,{|a,n| IIF(a[8],AADD(aSelect,a[1]),NIL)})

  oFrmAsgDeb:aSelect:=aSelect
  oFrmAsgDeb:cWhere :=GetWhereOr("FCH_NUMERO",aSelect)

  IF EMPTY(aSelect) 
     MensajeErr("No hay Periodos Seleccionados")
     RETURN .F.
  ENDIF

  // Asigna Número de Débito

  IF ALLTRIM(oDp:cPathCta)="SGE"
    EJECUTAR("NMSETDEBITOSGE" , oFrmAsgDeb:cWhere)
  ELSE
    EJECUTAR("NMSETDEBITO" , oFrmAsgDeb:cWhere)
  ENDIF

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
FUNCTION PRGCHANGE(oFrmAsgDeb)
  LOCAL aData,I

  IF UPPE(LEFT(ALLTRIM(oFrmAsgDeb:cModulo),1))="T"
     aData:=ACLONE(oFrmAsgDeb:aTodos)
  ELSE
     aData:=oFrmAsgDeb:COPYMODULO(oFrmAsgDeb,LEFT(ALLTRIM(oFrmAsgDeb:cModulo),2),.T.)
  ENDIF

  oFrmAsgDeb:oBrw:aArrayData:=ACLONE(aData)
  oFrmAsgDeb:oBrw:nArrayAt  :=MIN(LEN(oFrmAsgDeb:oBrw:aArrayData),oFrmAsgDeb:oBrw:nArrayAt)

  oFrmAsgDeb:oBrw:GoTop()
  oFrmAsgDeb:oBrw:Refresh(.T.)

  DpFocus(oFrmAsgDeb:oBrw)

RETURN .T.

FUNCTION COPYMODULO(oFrmAsgDeb,cModulo,lShow)
   LOCAL aData:={},I,nCol:=4

   cModulo:=UPPE(cModulo)

   IF ALLTRIM(cModulo)="TO" 
      cModulo:=.T.
      nCol   :=6
   ELSE
      cModulo:=Left(cModulo,2)
   ENDIF

//   IF lShow
//     ? cModulo,LEN(cModulo),oFrmAsgDeb:aTodos[1,nCol]
//   ENDIF

   IF ALLTRIM(Left(cModulo,2))="MO" // Solo los Seleccionados
     nCol=0
//     IF lShow
//       ? "nCol",nCol
//     ENDIF
   ENDIF
  
   FOR I=1 TO LEN(oFrmAsgDeb:aTodos)

//   ? Left(ALLTRIM(oFrmAsgDeb:aTodos[I,nCol]),2),cModulo

     IF nCol>0 .AND. (nCol=6 .OR. UPPE(Left(ALLTRIM(oFrmAsgDeb:aTodos[I,nCol]),2))=cModulo)
        AADD(aData,oFrmAsgDeb:aTodos[I])  
     ENDIF

     IF nCol=0 .AND. oFrmAsgDeb:aTodos[I,8]
        AADD(aData,oFrmAsgDeb:aTodos[I])  
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
FUNCTION SelectAll(oFrmAsgDeb)
   LOCAL I,cModulo,nCol:=4,nCuantos:=0,lSelect:=.T.

   cModulo:=Left(ALLTRIM(oFrmAsgDeb:cModulo),2)
   lSelect:=!oFrmAsgDeb:oBrw:aArrayData[1,8]

   FOR I=1 TO LEN(oFrmAsgDeb:aTodos)
     IF oFrmAsgDeb:aTodos[I,nCol]=cModulo .OR. cModulo="TO"
       oFrmAsgDeb:aTodos[I,8]:=lSelect
     ENDIF
   NEXT I

   FOR I=1 TO LEN(oFrmAsgDeb:oBrw:aArrayData)
      oFrmAsgDeb:oBrw:aArrayData[I,8]:=lSelect
   NEXT I
   
  oFrmAsgDeb:oBrw:Refresh(.T.)

  AEVAL(oFrmAsgDeb:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[8],1,0)})
  oFrmAsgDeb:nCuantos:=nCuantos
  oFrmAsgDeb:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Seleccionar Fecha de Programas
*/
FUNCTION SelFecha(oFrmAsgDeb)
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

    FOR I=1 TO LEN(oFrmAsgDeb:aTodos)

      IF !lAdd
        oFrmAsgDeb:aTodos[I,8]:=!lSelect
      ENDIF

      IF oFrmAsgDeb:aTodos[I,3]>=dDesde .AND. oFrmAsgDeb:aTodos[I,3]<=dHasta
        oFrmAsgDeb:aTodos[I,8]:=lSelect
      ENDIF

    NEXT I

    FOR I=1 TO LEN(oFrmAsgDeb:oBrw:aArrayData)

       IF !lAdd
          oFrmAsgDeb:oBrw:aArrayData[I,8]:=!lSelect
       ENDIF

       IF oFrmAsgDeb:oBrw:aArrayData[I,8]>=dDesde .AND. oFrmAsgDeb:oBrw:aArrayData[I,3]<=dHasta
          oFrmAsgDeb:oBrw:aArrayData[I,8]:=lSelect
       ENDIF

    NEXT I

    oFrmAsgDeb:oModulo:Select( LEN(oFrmAsgDeb:oModulo:aItems) )
    oFrmAsgDeb:cModulo:="MO"
    oFrmAsgDeb:PRGCHANGE(oFrmAsgDeb)

    oFrmAsgDeb:oBrw:Refresh(.T.)

    AEVAL(oFrmAsgDeb:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[8],1,0)})
    oFrmAsgDeb:nCuantos:=nCuantos
    oFrmAsgDeb:oCuantos:Refresh(.T.)
   
  ENDIF

RETURN .T.

/*
// Selecciona o Desmarca a Todos
*/
FUNCTION ChangeAllImp(oFrmAsgDeb)
   LOCAL oBrw:=oFrmAsgDeb:oBrw
   LOCAL lSelect:=!oBrw:aArrayData[1,8]

// LOCAL lSelect:=!oBrw:aArrayData[1,8]

   AEVAL(oBrw:aArrayData,{|a,n|oBrw:aArrayData[n,8]:=lSelect})

   IF LEFT(ALLTRIM(oFrmAsgDeb:cModulo),2)="TO"
      AEVAL(oFrmAsgDeb:aTodos,{|a,n|oFrmAsgDeb:aTodos[n,8]:=lSelect})
   ENDIF

   oFrmAsgDeb:nCuantos:=IIF(lSelect,LEN(oBrw:aArrayData),0)
   oFrmAsgDeb:oCuantos:Refresh(.T.)

   oBrw:Refresh(.T.)

RETURN .T.

// EOF


