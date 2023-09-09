// Programa   : NMTRABJANIV
// Fecha/Hora : 07/09/2008 23:32:50
// Propósito  : Determinar los trabajadores en Fecha Aniversaria
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

  cWhere:="MONTH(FECHA_ING)"+GetWhere("=",MONTH(dFecha))
  dFecha:=oDp:dFecha-0

  IF !oDp:lPanel

     aData :=GETDATA(dFecha)

     IF !Empty(aData)
        ViewData(aData,LSTR(LEN(aData))+" Trabajador(es) con Fecha Aniversario: "+CMES(dFecha)+"/"+STRZERO(YEAR(oDp:dFecha)))
     ELSE
        MensajeErr("No hay Trabajadores con Fecha Aniversario "+CMES(dFecha))
     ENDIF

  ENDIF

  nCantid:=COUNT("NMTRABAJADOR",cWhere)

RETURN nCantid

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol
   LOCAL oFont,oFontB

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oTrabV:=DPEDIT():New(cTitle,"NMTRABJVAC.EDT","oTrabV",.T.)
   oTrabV:lMsgBar :=.F.

   oTrabV:oBrw:=TXBrowse():New( oTrabV:oDlg )
   oTrabV:oBrw:SetArray( aData, .T. )
   oTrabV:oBrw:SetFont(oFont)

   oTrabV:oBrw:lFooter     := .T.
   oTrabV:oBrw:lHScroll    := .F.
   oTrabV:oBrw:nHeaderLines:= 2
   oTrabV:oBrw:lFooter     :=.F.
   oTrabV:oBrw:cNombre     :=""


   AEVAL(oTrabV:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oTrabV:oBrw:aCols[1]   
   oCol:cHeader      :="Código"
   oCol:nWidth       :=100

   oCol:=oTrabV:oBrw:aCols[2]
   oCol:cHeader      :="Apellidos"
   oCol:nWidth       :=150

   oCol:=oTrabV:oBrw:aCols[3]   
   oCol:cHeader      :="Nombre"
   oCol:nWidth       :=150

   oCol:=oTrabV:oBrw:aCols[4]   
   oCol:cHeader      :="Ingreso"
   oCol:nWidth       :=80

   oCol:=oTrabV:oBrw:aCols[5]   
   oCol:cHeader      :="Años"+CRLF+"Antig"+CHR(252)+"edad"
   oCol:nWidth       :=60

   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oTrabV:oBrw:aArrayData[oTrabV:oBrw:nArrayAt,5],;
                                TRAN(nMonto,"9999")}

   oTrabV:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oTrabV:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15724510, 15000777 ) } }

   oTrabV:oBrw:bClrHeader            := {|| {0,14671839 }}
   oTrabV:oBrw:bClrFooter            := {|| {0,14671839 }}


   oTrabV:oBrw:CreateFromCode()

   oTrabV:Activate({||oTrabV:ViewDatBar(oTrabV)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oTrabV)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTrabV:oDlg,aMeses:={"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

   oTrabV:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTrabV:oBrw,oTrabV:cTitle,oTrabV:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTrabV:oBrw:GoTop(),oTrabV:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTrabV:oBrw:GoBottom(),oTrabV:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTrabV:Close()

  oTrabV:oBrw:SetColor(0,15724510)
  oBar:SetColor(CLR_BLACK,15724527 )

  oTrabV:cMes:=aMeses[MONTH(oDp:dFecha)]

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})

  @ 1,60 COMBOBOX oTrabV:oMeses VAR oTrabV:cMes;
         OF oBar;
         ITEMS ameses ;
         SIZE 110,NIL;
         ON CHANGE oTrabV:GETDATA(CTOD("01/"+STRZERO(oTrabV:oMeses:nAt,2)+"/"+LSTR(YEAR(oDp:dFecha))),oTrabV:oBrw);
         FONT oFont



RETURN .T.

FUNCTION GETDATA(dFecha,oBrw)
  LOCAL aData
  LOCAL cWhere:="MONTH(FECHA_ING)"+GetWhere("=",MONTH(dFecha))

  aData :=ASQL("SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING,0 AS CERO FROM NMTRABAJADOR "+;
               " WHERE " + cWhere)

  IF !Empty(aData)
    AEVAL(aData,{|a,n| aData[n,5]:=YEAR(oDp:dFecha)-YEAR(a[4]) })
  ENDIF

  IF ValType(oBrw)="O"

     IF EMPTY(aData) 
       aData:={}
       AADD(aData,{"","No hay Trabajadores","",CTOD(""),0})
       oBrw:oWnd:oWnd:SetText("Trabajadores con Fecha Aniversario: ")
     ELSE
       oBrw:oWnd:oWnd:SetText(LSTR(LEN(aData))+" Trabajador(es) con Fecha Aniversario: "+CMES(dFecha)+"/"+STRZERO(YEAR(dFecha)))
     ENDIF

     oBrw:nArrayAt  :=1
     oBrw:aArrayData:=ACLONE(aData)
     oBrw:GoBottom(.T.)
     OBrw:Refresh(.t.)


  ENDIF

RETURN aData
// EOF

