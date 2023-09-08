// Programa   : NMASGCHEQUE
// Fecha/Hora : 16/02/2004 16:39:12
// Propósito  : Asignación de Cheques
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
        "INNER JOIN NMRECIBOS   ON REC_NUMFCH=FCH_NUMERO "+;
        "INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC "+;
        "WHERE LEFT(HIS_CODCON,1)='A' OR LEFT(HIS_CODCON,1)='D' "+;
        "GROUP BY FCH_TIPNOM"

  aAplica:=aTable(cSql,.t.)

  AEVAL(aAplica,{|a,n|aAplica[n]:=SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",a)})

  AADD(aAplica," Todos")
  AADD(aAplica," Mostrar sólo los Seleccionados")

  oTable  :=OpenTable("SELECT FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI, "+;
                      "COUNT(*) AS CUANTOS "+;
                      "FROM NMFECHAS "+;
                      "LEFT  JOIN NMOTRASNM   ON OTR_CODIGO=FCH_OTRNOM "+;
                      "INNER JOIN NMRECIBOS   ON REC_NUMFCH=FCH_NUMERO "+;
                      "INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC "+;
                      " WHERE REC_FORMAP='C' AND (LEFT(HIS_CODCON,1)='A' OR LEFT(HIS_CODCON,1)='D')"+;
                      "GROUP BY FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI "+;
                      "HAVING COUNT(*) > 0 "+;
                      "ORDER BY FCH_NUMERO DESC",.T.)

  CLPCOPY(oTable:cSql)

  WHILE !oTable:Eof()
    oTable:Replace("FCH_MARCAR",.T.)
    oTable:Replace("FCH_TIPNOM",SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oTable:FCH_TIPNOM))
    oTable:Replace("CUANTOS"  ,0  )
    oTable:Skip()
  ENDDO

  aFechas:=ACLONE(oTable:aDataFill)
  oTable:End()

  IF Empty(aFechas)
     MensajeErr("No hay Periodos de Nómina con Forma de pago CHEQUE")
     RETURN .T.
  ENDIF

  nMarcar:=oTable:FieldPos("FCH_MARCAR")
  AEVAL(aFechas,{|a,n|nCuantos:=nCuantos+IIF(a[nMarcar],1,0)})

  DEFINE FONT oFontBrw NAME "Verdana" SIZE 0,-12

  oFrmAsgChq:=DPEDIT():New("Seleccionar Periodo para la Asignación de Cheques","NMASGCHQ.EDT","oFrmAsgChq",.T.)
  oFrmAsgChq:cModulo :=" Todos"
  oFrmAsgChq:aTodos  :=ACLONE(aFechas)  // Todos los Programas
  oFrmAsgChq:nCuantos:=nCuantos
  oFrmAsgChq:nMarcar :=nMarcar
  oFrmAsgChq:cFileChm:="CAPITULO2.CHM"


  aData:=COPYMODULO(oFrmAsgChq,oFrmAsgChq:cModulo,.F.)

  @ 1,12 COMBOBOX oFrmAsgChq:oModulo VAR oFrmAsgChq:cModulo ITEMS aAplica;
         ON CHANGE oFrmAsgChq:PRGCHANGE(oFrmAsgChq)

  oFrmAsgChq:oBrw:=TXBrowse():New( oFrmAsgChq:oDlg )
  oFrmAsgChq:oBrw:SetArray( aData )

  oBrw:=oFrmAsgChq:oBrw
  oBrw:SetFont(oFontBrw)

  oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .F.
  oBrw:nFreeze  := 3

  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "Número"
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}

  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Desde"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}

  oCol:=oBrw:aCols[3]
  oCol:cHeader   := "Hasta"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}

  oCol:=oBrw:aCols[4]
  oCol:cHeader   := "Nómina"
  oCol:nWidth       := 90
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}

  oCol:=oBrw:aCols[5]
  oCol:cHeader   := "Otra"
  oCol:nWidth       := 40
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}

  oCol:=oBrw:aCols[6]
  oCol:cHeader   := "Otra Nómina"
  oCol:nWidth       := 300
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}

  oCol:=oBrw:aCols[7]
  oCol:cHeader   := "N/Chq"
  oCol:nWidth       := 50
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:nFootStrAlign:= AL_RIGHT

  oCol:=oBrw:aCols[8]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrw:=oFrmAsgChq:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,8],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oFrmAsgChq:NOMSELECT(oFrmAsgChq)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oFrmAsgChq:ChangeAllImp(oFrmAsgChq,nRow,nCol,nKey,oCol,.T.)}

  oBrw:bClrStd   := {|oBrw|oBrw:=oFrmAsgChq:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,8], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrw:nArrayAt%2=0, 14737632 ,  16777215  ) } }

  oBrw:bClrSel   := {|oBrw|oBrw:=oFrmAsgChq:oBrw, { 65535,  16733011}}

  oFrmAsgChq:oBrw:CreateFromCode()

  oBrw:bClrHeader := {|| { 0,  12632256}}

  oFrmAsgChq:oFocus:=oBrw
  oFrmAsgChq:Activate({||oFrmAsgChq:NMCONBAR(oFrmAsgChq)})

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION NMCONBAR(oFrmAsgChq)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmAsgChq:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oFrmAsgChq:AsignaChq(oFrmAsgChq)

   oBtn:cToolTip:="Asignación de Cheques"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SELECT.BMP";
          ACTION oFrmAsgChq:SelectAll(oFrmAsgChq)

   oBtn:cToolTip:="Seleccionar Todas las Fechas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION oFrmAsgChq:SelFecha(oFrmAsgChq)

   oBtn:cToolTip:="Seleccionar Fecha de Tablas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oFrmAsgChq:oBrw)

  oBtn:cToolTip:="Buscar Programa"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xTOP.BMP";
         ACTION (oFrmAsgChq:oBrw:GoTop(),oFrmAsgChq:oBrw:Setfocus())

  oBtn:cToolTip:="Primer Periodo de la Lista"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xSIG.BMP";
         ACTION (oFrmAsgChq:oBrw:PageDown(),oFrmAsgChq:oBrw:Setfocus())

  oBtn:cToolTip:="Siguiente Periodo"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xANT.BMP";
         ACTION (oFrmAsgChq:oBrw:PageUp(),oFrmAsgChq:oBrw:Setfocus())

  oBtn:cToolTip:="Periodo Anterior"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xFIN.BMP";
         ACTION (oFrmAsgChq:oBrw:GoBottom(),oFrmAsgChq:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Periodo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFrmAsgChq:Close()

   oBtn:cToolTip:="Cerrar Formulario"

   AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip})

   oFrmAsgChq:oBrw:SetColor(0,15790320)

   @ 0.1,60 SAY oFrmAsgChq:oCuantos PROMPT " Seleccionados: "+STRZERO(oFrmAsgChq:nCuantos,4)+"/"+;
                STRZERO(LEN(oFrmAsgChq:aTodos),4);
                OF oBar BORDER SIZE 190,18 UPDATE

   oBar:SetColor(CLR_BLACK,15724527)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

 
RETURN .T.

/*
// Seleccionar Concepto
*/
FUNCTION NOMSELECT(oFrmAsgChq)
  LOCAL oBrw:=oFrmAsgChq:oBrw
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
  nAt:=ASCAN(oFrmAsgChq:aTodos,{|a,n|a[1]=oBrw:aArrayData[oBrw:nArrayAt,1]})

  IF nAt>0
    oFrmAsgChq:aTodos[nAt,8]:=!lSelect
  ENDIF

  AEVAL(oFrmAsgChq:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[8],1,0)})
  oFrmAsgChq:nCuantos:=nCuantos
  oFrmAsgChq:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Exportar Programas
*/
FUNCTION AsignaChq(oFrmAsgChq)
  LOCAL aSelect:={},cSql,oData

//AEVAL(oFrmAsgChq:aTodos,{|a,n| IIF(a[8],AADD(aSelect,a[1]),NIL)})
  AEVAL(oFrmAsgChq:oBrw:aArrayData,{|a,n| IIF(a[8],AADD(aSelect,a[1]),NIL)})

  oFrmAsgChq:aSelect:=aSelect
  oFrmAsgChq:cWhere :=GetWhereOr("REC_NUMFCH",aSelect)

  IF EMPTY(aSelect) 
     MensajeErr("No hay Periodos Seleccionados")
     RETURN .F.
  ENDIF

  // Asigna Número de Cheque
  IF ALLTRIM(oDp:cPathCta)="SGE"

    EJECUTAR("NMSETCHEQUESGE" , oFrmAsgChq:cWhere)

  ELSE

    EJECUTAR("NMSETCHEQUE" , oFrmAsgChq:cWhere)

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
FUNCTION PRGCHANGE(oFrmAsgChq)
  LOCAL aData,I

  IF UPPE(LEFT(ALLTRIM(oFrmAsgChq:cModulo),1))="T"
     aData:=ACLONE(oFrmAsgChq:aTodos)
  ELSE
     aData:=oFrmAsgChq:COPYMODULO(oFrmAsgChq,LEFT(ALLTRIM(oFrmAsgChq:cModulo),2),.T.)
  ENDIF

  oFrmAsgChq:oBrw:aArrayData:=ACLONE(aData)
  oFrmAsgChq:oBrw:nArrayAt  :=MIN(LEN(oFrmAsgChq:oBrw:aArrayData),oFrmAsgChq:oBrw:nArrayAt)

  oFrmAsgChq:oBrw:GoTop()
  oFrmAsgChq:oBrw:Refresh(.T.)

  DpFocus(oFrmAsgChq:oBrw)

RETURN .T.

FUNCTION COPYMODULO(oFrmAsgChq,cModulo,lShow)
   LOCAL aData:={},I,nCol:=4

   cModulo:=UPPE(cModulo)

   IF ALLTRIM(cModulo)="TO" 
      cModulo:=.T.
      nCol   :=6
   ELSE
      cModulo:=Left(cModulo,2)
   ENDIF

// ? "COPYMODULO"
//   IF lShow
//     ? cModulo,LEN(cModulo),oFrmAsgChq:aTodos[1,nCol]
//   ENDIF

   IF ALLTRIM(Left(cModulo,2))="MO" // Solo los Seleccionados
     nCol=0
   ENDIF
  
   FOR I=1 TO LEN(oFrmAsgChq:aTodos)

//   ? Left(ALLTRIM(oFrmAsgChq:aTodos[I,nCol]),2),cModulo

     IF nCol>0 .AND. (nCol=6 .OR. UPPE(Left(ALLTRIM(oFrmAsgChq:aTodos[I,nCol]),2))=cModulo)
        AADD(aData,oFrmAsgChq:aTodos[I])  
     ENDIF

     IF nCol=0 .AND. oFrmAsgChq:aTodos[I,8]
        AADD(aData,oFrmAsgChq:aTodos[I])  
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
FUNCTION SelectAll(oFrmAsgChq)
   LOCAL I,cModulo,nCol:=4,nCuantos:=0,lSelect:=.T.

   cModulo:=Left(ALLTRIM(oFrmAsgChq:cModulo),2)
   lSelect:=!oFrmAsgChq:oBrw:aArrayData[1,8]

   FOR I=1 TO LEN(oFrmAsgChq:aTodos)
     IF oFrmAsgChq:aTodos[I,nCol]=cModulo .OR. cModulo="TO"
       oFrmAsgChq:aTodos[I,8]:=lSelect
     ENDIF
   NEXT I

   FOR I=1 TO LEN(oFrmAsgChq:oBrw:aArrayData)
      oFrmAsgChq:oBrw:aArrayData[I,8]:=lSelect
   NEXT I
   
  oFrmAsgChq:oBrw:Refresh(.T.)

  AEVAL(oFrmAsgChq:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[8],1,0)})
  oFrmAsgChq:nCuantos:=nCuantos
  oFrmAsgChq:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Seleccionar Fecha de Programas
*/
FUNCTION SelFecha(oFrmAsgChq)
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

    FOR I=1 TO LEN(oFrmAsgChq:aTodos)

      IF !lAdd
        oFrmAsgChq:aTodos[I,8]:=!lSelect
      ENDIF

      IF oFrmAsgChq:aTodos[I,3]>=dDesde .AND. oFrmAsgChq:aTodos[I,3]<=dHasta
        oFrmAsgChq:aTodos[I,8]:=lSelect
      ENDIF

    NEXT I

    FOR I=1 TO LEN(oFrmAsgChq:oBrw:aArrayData)

       IF !lAdd
          oFrmAsgChq:oBrw:aArrayData[I,8]:=!lSelect
       ENDIF

       IF oFrmAsgChq:oBrw:aArrayData[I,8]>=dDesde .AND. oFrmAsgChq:oBrw:aArrayData[I,3]<=dHasta
          oFrmAsgChq:oBrw:aArrayData[I,8]:=lSelect
       ENDIF

    NEXT I

    oFrmAsgChq:oModulo:Select( LEN(oFrmAsgChq:oModulo:aItems) )
    oFrmAsgChq:cModulo:="MO"
    oFrmAsgChq:PRGCHANGE(oFrmAsgChq)

    oFrmAsgChq:oBrw:Refresh(.T.)

    AEVAL(oFrmAsgChq:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[8],1,0)})
    oFrmAsgChq:nCuantos:=nCuantos
    oFrmAsgChq:oCuantos:Refresh(.T.)
   
  ENDIF

RETURN .T.

/*
// Selecciona o Desmarca a Todos
*/
FUNCTION ChangeAllImp(oFrmAsgChq)
   LOCAL oBrw:=oFrmAsgChq:oBrw
   LOCAL lSelect:=!oBrw:aArrayData[1,8]

   AEVAL(oBrw:aArrayData,{|a,n|oBrw:aArrayData[n,8]:=lSelect})

   IF LEFT(ALLTRIM(oFrmAsgChq:cModulo),2)="TO"
      AEVAL(oFrmAsgChq:aTodos,{|a,n|oFrmAsgChq:aTodos[n,8]:=lSelect})
   ENDIF

   oFrmAsgChq:nCuantos:=IIF(lSelect,LEN(oBrw:aArrayData),0)
   oFrmAsgChq:oCuantos:Refresh(.F.)

   oBrw:Refresh(.F.)

RETURN .T.

// EOF
