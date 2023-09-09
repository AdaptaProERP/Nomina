// Programa   : NMTRABJCUMP
// Fecha/Hora : 07/09/2008 23:32:50
// Propósito  : Determinar los trabajadores en Fecha de Cumpleaños
// Creado Por : Juan Navas
// Llamado por: Panel/ERP
// Aplicación :  
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL nCantid:=0,cSql,dFecha:=oDp:dFecha,cWhere,aData

  IF !oDp:lNomina
     RETURN 0
  ENDIF

  EJECUTAR("TABLASNOMINA")

  cWhere:="MONTH(FECHA_NAC)"+GetWhere("=",MONTH(dFecha))
  dFecha:=oDp:dFecha-0

  IF !oDp:lPanel

     aData :=GETDATA(dFecha)

     IF !Empty(aData)
        ViewData(aData,LSTR(LEN(aData))+" Trabajador(es) con Mes de Cumpleaños: "+CMES(dFecha)+"/"+STRZERO(YEAR(oDp:dFecha)))
     ELSE
        MensajeErr("No hay Trabajadores con Mes de Cumpleaños "+CMES(dFecha))
     ENDIF

  ENDIF

  nCantid:=COUNT("NMTRABAJADOR",cWhere)

RETURN nCantid

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol
   LOCAL oFont,oFontB

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oTrabC:=DPEDIT():New(cTitle,"NMTRABJCUMP.EDT","oTrabC",.T.)
   oTrabC:lMsgBar :=.F.

   oTrabC:oBrw:=TXBrowse():New( oTrabC:oDlg )
   oTrabC:oBrw:SetArray( aData, .T. )
   oTrabC:oBrw:SetFont(oFont)

   oTrabC:oBrw:lFooter     := .T.
   oTrabC:oBrw:lHScroll    := .F.
   oTrabC:oBrw:nHeaderLines:= 2
   oTrabC:oBrw:lFooter     :=.F.
   oTrabC:oBrw:cNombre     :=""


   AEVAL(oTrabC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oTrabC:oBrw:aCols[1]   
   oCol:cHeader      :="Código"
   oCol:nWidth       :=100

   oCol:=oTrabC:oBrw:aCols[2]
   oCol:cHeader      :="Apellidos"
   oCol:nWidth       :=150

   oCol:=oTrabC:oBrw:aCols[3]   
   oCol:cHeader      :="Nombre"
   oCol:nWidth       :=150

   oCol:=oTrabC:oBrw:aCols[4]   
   oCol:cHeader      :="Ingreso"
   oCol:nWidth       :=80

   oCol:=oTrabC:oBrw:aCols[5]   
   oCol:cHeader      :="Edad"+CRLF+"Años"
   oCol:nWidth       :=60

   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oTrabC:oBrw:aArrayData[oTrabC:oBrw:nArrayAt,5],;
                                TRAN(nMonto,"9999")}

   oTrabC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oTrabC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15724510, 15000777 ) } }

   oTrabC:oBrw:bClrHeader            := {|| {0,14671839 }}
   oTrabC:oBrw:bClrFooter            := {|| {0,14671839 }}


   oTrabC:oBrw:CreateFromCode()

   oTrabC:Activate({||oTrabC:ViewDatBar(oTrabC)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oTrabC)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTrabC:oDlg,aMeses:={"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

   oTrabC:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTrabC:oBrw,oTrabC:cTitle,oTrabC:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTrabC:oBrw:GoTop(),oTrabC:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTrabC:oBrw:GoBottom(),oTrabC:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTrabC:Close()

  oTrabC:oBrw:SetColor(0,15724510)
  oBar:SetColor(CLR_BLACK,15724527 )

  oTrabC:cMes:=aMeses[MONTH(oDp:dFecha)]

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

  @ 1,60 COMBOBOX oTrabC:oMeses VAR oTrabC:cMes;
         OF oBar;
         ITEMS ameses ;
         SIZE 110,NIL;
         ON CHANGE oTrabC:GETDATA(CTOD("01/"+STRZERO(oTrabC:oMeses:nAt,2)+"/"+LSTR(YEAR(oDp:dFecha))),oTrabC:oBrw);
         FONT oFont

RETURN .T.

FUNCTION GETDATA(dFecha,oBrw)
  LOCAL aData
  LOCAL cWhere:="MONTH(FECHA_NAC)"+GetWhere("=",MONTH(dFecha))

  aData :=ASQL("SELECT CODIGO,APELLIDO,NOMBRE,FECHA_NAC,0 AS CERO FROM NMTRABAJADOR "+;
               " WHERE " + cWhere)

  IF !Empty(aData)
    AEVAL(aData,{|a,n| aData[n,5]:=YEAR(oDp:dFecha)-YEAR(a[4]) })
  ENDIF

  IF ValType(oBrw)="O"

     IF EMPTY(aData) 
       aData:={}
       AADD(aData,{"","No hay Trabajadores","",CTOD(""),0})
       oBrw:oWnd:oWnd:SetText("Trabajadores con Mes de Cumpleaños: ")
     ELSE
       oBrw:oWnd:oWnd:SetText(LSTR(LEN(aData))+" Trabajador(es) con Mes de Cumpleaños: "+CMES(dFecha)+"/"+STRZERO(YEAR(dFecha)))
     ENDIF

     oBrw:nArrayAt  :=1
     oBrw:aArrayData:=ACLONE(aData)
     oBrw:GoBottom(.T.)
     OBrw:Refresh(.t.)

  ENDIF

RETURN aData
// EOF
