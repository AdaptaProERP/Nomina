// Programa   : NMTRABJ3MESES
// Fecha/Hora : 07/09/2008 23:32:50
// Propósito  : Determinar los trabajadores en el tiempo de Prueba
// Creado Por : Juan Navas
// Llamado por: Panel/ERP
// Aplicación : 
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dFecha,lSoloRojos,lPanel)
  LOCAL nCantid:=0,cSql,cWhere:="",aData

  DEFAULT lPanel:=.T.

  IF !oDp:lNomina
     RETURN 0
  ENDIF

  DEFAULT dFecha:=oDp:dFecha,lSoloRojos:=.F.

  EJECUTAR("TABLASNOMINA")

  dFecha:=dFecha-29
  cWhere:="FECHA_ING"+GetWhere(">=",dFecha)+" AND CONDICION"+GetWhere("=","A")

  IF lPanel

     aData:=GETDATA(dFecha)

     IF !Empty(aData) 
        ViewData(aData,"Trabajadores en Periodo de Prueba, desde: "+DTOC(dFecha)+", Menor o Igual 29 días")
     ELSEIF !oDp:lPanel
        MensajeErr("No hay Trabajadores en Periodo de Prueba al "+DTOC(dFecha))
     ENDIF

  ENDIF

//? cWhere

  nCantid:=COUNT("NMTRABAJADOR",cWhere)

RETURN nCantid

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol
   LOCAL oFont,oFontB

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oTrab3:=DPEDIT():New(cTitle,"NMTRABJ3M.EDT","oTrab3",.T.)
   oTrab3:lMsgBar :=.F.

   oTrab3:oBrw:=TXBrowse():New( oTrab3:oDlg )
   oTrab3:oBrw:SetArray( aData, .T. )
   oTrab3:oBrw:SetFont(oFont)

   oTrab3:oBrw:lFooter     := .T.
   oTrab3:oBrw:lHScroll    := .F.
   oTrab3:oBrw:nHeaderLines:= 2
   oTrab3:oBrw:lFooter     :=.F.
   oTrab3:oBrw:cNombre     :=""


   AEVAL(oTrab3:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oTrab3:oBrw:aCols[1]   
   oCol:cHeader      :="Código"
   oCol:nWidth       :=100

   oCol:=oTrab3:oBrw:aCols[2]
   oCol:cHeader      :="Apellidos"
   oCol:nWidth       :=150

   oCol:=oTrab3:oBrw:aCols[3]   
   oCol:cHeader      :="Nombre"
   oCol:nWidth       :=150

   oCol:=oTrab3:oBrw:aCols[4]   
   oCol:cHeader      :="Ingreso"
   oCol:nWidth       :=80

   oCol:=oTrab3:oBrw:aCols[5]   
   oCol:cHeader      :="Días"+CRLF+"Antig"+CHR(252)+"edad"
   oCol:nWidth       :=60

   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oTrab3:oBrw:aArrayData[oTrab3:oBrw:nArrayAt,5],;
                                TRAN(nMonto,"9999")}
   oCol:=oTrab3:oBrw:aCols[6]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Por"+CRLF+"Transc"
   oCol:nWidth       :=60
   oCol:bStrData     :={|nMonto|nMonto:=oTrab3:oBrw:aArrayData[oTrab3:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"9999")}

   oCol:=oTrab3:oBrw:aCols[7]   
   oCol:cHeader      :="Fecha"+CRLF+"Tope"
   oCol:nWidth       :=60

   oCol:=oTrab3:oBrw:aCols[8]   
   oCol:cHeader      :="Día"+CRLF+"Semana"
   oCol:nWidth       :=60

   oCol:=oTrab3:oBrw:aCols[9]   
   oCol:cHeader      :="Ultimo Día"+CRLF+"Hábil"
   oCol:nWidth       :=126

   oTrab3:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oTrab3:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                           nClrText:=IIF(oTrab3:oBrw:aArrayData[oTrab3:oBrw:nArrayAt,6]<=31,25542   ,nClrText),;
                                           nClrText:=IIF(oTrab3:oBrw:aArrayData[oTrab3:oBrw:nArrayAt,6]<=15,CLR_HRED,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15724510, 15000777 ) } }

   oTrab3:oBrw:bClrHeader            := {|| {0,14671839 }}
   oTrab3:oBrw:bClrFooter            := {|| {0,14671839 }}


//   oTrab3:oBrw:bLDblClick:={|oBrw|oTrab3:oRep:=oTrab3:VERPROVEEDOR() }

   oTrab3:oBrw:CreateFromCode()

   oTrab3:Activate({||oTrab3:ViewDatBar(oTrab3)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oTrab3)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTrab3:oDlg,oBtnCal

   oTrab3:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

/*

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oTrab3:oRep:=REPORTE(oTrab3:cRep),;
                  oTrab3:oRep:SetRango(1,oTrab3:cCodInv,oTrab3:cCodInv))

   oBtn:cToolTip:="Imprimir"

*/
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTrab3:oBrw,oTrab3:cTitle,oTrab3:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTrab3:oBrw:GoTop(),oTrab3:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTrab3:oBrw:GoBottom(),oTrab3:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTrab3:Close()

  oTrab3:oBrw:SetColor(0,15724510)
// 15724510, 15000777 
  oBar:SetColor(CLR_BLACK,15724527 )

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,15724527)})


RETURN .T.

FUNCTION GETDATA()
  LOCAL aData:={},I,dDia

  aData :=ASQL("SELECT CODIGO,APELLIDO,NOMBRE,FECHA_ING,0 AS CERO, 0 AS DIAS,0 AS FECHA,0 AS DIASEMANA, 0 AS DIAHABIL FROM NMTRABAJADOR "+;
               " WHERE " + cWhere)

  AEVAL(aData,{|a,n| aData[n,5]:=oDp:dFecha-a[4] ,;
                     aData[n,6]:=29-aData[n,5]   ,;
                     aData[n,7]:=aData[n,4]+29   ,;
                     aData[n,8]:=CSEMANA(aData[n,7]) })

  FOR I=1 TO LEN(aData)

     dDia:=aData[I,7]

     IF EJECUTAR("DIAS_HAB",dDia,dDia)=0
        dDia:=dDia-1

        WHILE EJECUTAR("DIAS_HAB",dDia,dDia)=0
          dDia--
        ENDDO

       aData[I,9]:=DTOC(dDia)+" "+CSEMANA(dDia)

     ELSE

       aData[I,9]:=""

     ENDIF
     
     
  NEXT I

  
RETURN aData
// eof

