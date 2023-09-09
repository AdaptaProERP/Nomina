// Programa   : NMTRABJCONT
// Fecha/Hora : 03/03/2011 23:32:50
// Propósito  : Determinar los trabajadores con Fecha de Contratadas
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

  oDp:lDpXbase:=.T.

  EJECUTAR("TABLASNOMINA")

  cWhere:="MONTH(FECHA_NAC)"+GetWhere("=",MONTH(dFecha))
  dFecha:=oDp:dFecha-0

  IF !oDp:lPanel

     aData :=GETDATA(dFecha)

     IF !Empty(aData)
        ViewData(aData,LSTR(LEN(aData))+" Trabajador(es) con Fecha de Contrato "+CMES(dFecha)+"/"+STRZERO(YEAR(oDp:dFecha)))
     ELSE
        MensajeErr("No hay Trabajadores con Fecha de Contratación "+CMES(dFecha))
     ENDIF

  ENDIF


  nCantid:=COUNT("NMTRABAJADOR",cWhere)

RETURN nCantid

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol
   LOCAL oFont,oFontB

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oTCont:=DPEDIT():New(cTitle,"NMTRABJCONT.EDT","oTCont",.T.)
   oTCont:lMsgBar :=.F.

   oTCont:oBrw:=TXBrowse():New( oTCont:oDlg )
   oTCont:oBrw:SetArray( aData, .T. )
   oTCont:oBrw:SetFont(oFont)

   oTCont:oBrw:lFooter     := .T.
   oTCont:oBrw:lHScroll    := .F.
   oTCont:oBrw:nHeaderLines:= 2
   oTCont:oBrw:lFooter     :=.F.
   oTCont:oBrw:cNombre     :=""


   AEVAL(oTCont:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oTCont:oBrw:aCols[1]   
   oCol:cHeader      :="Código"
   oCol:nWidth       :=100

   oCol:=oTCont:oBrw:aCols[2]
   oCol:cHeader      :="Apellidos"
   oCol:nWidth       :=150

   oCol:=oTCont:oBrw:aCols[3]   
   oCol:cHeader      :="Nombre"
   oCol:nWidth       :=150

   oCol:=oTCont:oBrw:aCols[4]   
   oCol:cHeader      :="Ingreso"
   oCol:nWidth       :=80

   oCol:=oTCont:oBrw:aCols[5]   
   oCol:cHeader      :="Culminación"+CRLF+"Contrato"
   oCol:nWidth       :=80


   oCol:=oTCont:oBrw:aCols[6]   
   oCol:cHeader      :="Días"+CRLF+"Antg"
   oCol:nWidth       :=60

   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oTCont:oBrw:aArrayData[oTCont:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"9999")}

   oCol:=oTCont:oBrw:aCols[7]   
   oCol:cHeader      :="Días"+CRLF+"Remanente"
   oCol:nWidth       :=60

   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oTCont:oBrw:aArrayData[oTCont:oBrw:nArrayAt,7],;
                                TRAN(nMonto,"9999")}



   oTCont:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oTCont:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                           nClrText:=IIF(oTCont:oBrw:aArrayData[oTCont:oBrw:nArrayAt,7]<=31,25542   ,nClrText),;
                                           nClrText:=IIF(oTCont:oBrw:aArrayData[oTCont:oBrw:nArrayAt,7]<=15,CLR_HRED,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15724510, 15000777 ) } }

   oTCont:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oTCont:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oTCont:oBrw:CreateFromCode()

   oTCont:Activate({||oTCont:ViewDatBar(oTCont)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oTCont)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTCont:oDlg,aMeses:={"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

   oTCont:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTCont:oBrw,oTCont:cTitle,oTCont:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTCont:oBrw:GoTop(),oTCont:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTCont:oBrw:GoBottom(),oTCont:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTCont:Close()

  oTCont:oBrw:SetColor(0,15724510)
  oBar:SetColor(CLR_BLACK,oDp:nGris )

  oTCont:cMes:=aMeses[MONTH(oDp:dFecha)]

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 1,60 COMBOBOX oTCont:oMeses VAR oTCont:cMes;
         OF oBar;
         ITEMS ameses ;
         SIZE 110,NIL;
         ON CHANGE oTCont:GETDATA(CTOD("01/"+STRZERO(oTCont:oMeses:nAt,2)+"/"+LSTR(YEAR(oDp:dFecha))),oTCont:oBrw);
         FONT oFont

RETURN .T.

FUNCTION GETDATA(dFecha,oBrw)
  LOCAL aData
//LOCAL cWhere:="FECHA_CON"+GetWhere("<=",dFecha)+" AND FECHA_CON"+GetWhere("<>",CTOD(""))
  LOCAL cWhere:="FECHA_CON"+GetWhere("<>",CTOD(""))

  aData :=ASQL("SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING,FECHA_CON,0 AS CERO ,0 AS FALTANTE FROM NMTRABAJADOR "+;
               " WHERE " + cWhere+" AND CONDICION"+GetWhere("=","A"))

  IF !Empty(aData)
    AEVAL(aData,{|a,n| aData[n,6]:=oDp:dFecha-a[4], aData[n,7]:=a[5]-oDp:dFecha })
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
