// Programa   : NMTRAAUSEN
// Fecha/Hora : 22/09/2004 20:59:09
// Propósito  : Consultar Ausencias por Trabajador
// Creado Por : Juan Navas
// Llamado por: NMTRABCON	
// Aplicación : Nómina	
// Tabla      : NMAUSENCIA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
   LOCAL cSql,oTable,nAnos:=0,nMeses:=0,nDias:=0,aData:={},n_Anos:=0,n_Meses:=0,n_Dias:=0,n_Tdias:=0
   LOCAL oFont,oFontB,cNombre,oDlg,oBrw,cTitle:=""

   DEFAULT cCodTra:="1002"

   cSql:=" SELECT PER_NUMERO,PER_DESDE,PER_HASTA,PER_CAUSA,TAU_DESCRI FROM NMAUSENCIA "+;
         " INNER JOIN NMTIPAUS ON PER_CAUSA=TAU_CODIGO "+;
         " WHERE PER_CODTRA"+GetWhere("=",cCodTra)

   CURSORWAIT()

   oTable:=OPENTABLE(cSql,.T.)

   WHILE !oTable:Eof()
       ANTIGUEDAD(oTable:PER_DESDE,oTable:PER_HASTA,@nAnos,@nMeses,@nDias)
       nDias:=nDias+IIF(nDias>0,1,0)
       oTable:REPLACE("ANO" ,nAnos )
       oTable:REPLACE("MES" ,nMeses)
       oTable:REPLACE("DIA" ,nDias )
       oTable:REPLACE("TDIA",oTable:PER_HASTA-oTable:PER_DESDE+1 )
       n_Dias :=n_Dias +nDias
       n_Meses:=n_Meses+nMeses
       n_Anos :=n_Anos +nAnos
       n_Tdias:=n_Tdias+oTable:TDIA
       oTable:DbSkip(1)
   ENDDO

   aData:=ACLONE(oTable:aDataFill)
   oTable:End()

   oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
   cNombre:=ALLTRIM(oTable:APELLIDO)+","+ALLTRIM(oTable:NOMBRE)
   oTable:End()

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oTrabAus:=DPEDIT():New("Registros de Ausencias"+cTitle,"NMTRAAUSEN.edt","oTrabAus",.T.)

   oTrabAus:cCodTra  :=cCodTra
   oTrabAus:cTrabajad:=cNombre
   oTrabAus:cPictureM:="999"

   oDlg:=oTrabAus:oDlg

   oBrw:=TXBrowse():New( oDlg )

   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
   oBrw:SetArray( aData, .F. )
   oBrw:lHScroll            := .F.
   oBrw:lFooter             := .T.
   oBrw:oFont               :=oFont
   oBrw:nHeaderLines        := 2

   AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oBrw:CreateFromCode()

   oBrw:aCols[1]:cHeader:="Número"+CRLF+"Reg."
   oBrw:aCols[1]:nWidth :=65
   oBrw:aCols[1]:cFooter :=ALLTRIM(STR(LEN(aData),4))+"Reg"

   oBrw:aCols[2]:cHeader:="Fecha"+CRLF+"Desde"
   oBrw:aCols[2]:nWidth :=70

   oBrw:aCols[3]:cHeader:="Fecha"+CRLF+"Hasta"
   oBrw:aCols[3]:nWidth :=70

   oBrw:aCols[4]:cHeader:="Tipo"+CRLF+"Ausencia"
   oBrw:aCols[4]:nWidth :=70

   oBrw:aCols[5]:cHeader:=""+CRLF+"Descripción"
   oBrw:aCols[5]:nWidth :=180

   oBrw:aCols[6]:cHeader:="Años"
   oBrw:aCols[6]:nWidth :=50
   oBrw:aCols[6]:cEditPicture:="9999"

   oBrw:aCols[7]:cHeader:="Meses"
   oBrw:aCols[7]:nWidth :=50
   oBrw:aCols[7]:cEditPicture:="9999"

   oBrw:aCols[8]:cHeader :="Días"
   oBrw:aCols[8]:nWidth  :=50
   oBrw:aCols[8]:cEditPicture:="9999"

   oBrw:aCols[9]:cHeader :="Total"+CRLF+"Días"
   oBrw:aCols[9]:nWidth  :=60
   oBrw:aCols[9]:cFooter :=STR(n_Tdias,4)
   oBrw:aCols[9]:cEditPicture:="9999"

   oBrw:bClrHeader:= {|| {0,14671839 }}
   oBrw:bClrFooter:= {|| {0,14671839 }}

   oBrw:bClrStd   :={|oBrw,nClrText|oBrw:=oTrabAus:oBrw,;
                                   nClrText:=0,;
                                   {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }

  oBrw:bLDblClick:={|oBrw,cNumero|oBrw:=oTrabAus:oBrw,cNumero:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                     EJECUTAR("NMAUSENCIA",2,cNumero)}


  oBrw:SetFont(oFont)

  oTrabAus:oBrw:=oBrw

  oTrabAus:Activate({||oTrabAus:LeyBar(oTrabAus)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg

RETURN .T.

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oTrabAus)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTrabAus:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REPOSO.BMP";
          ACTION EVAL(oTrabAus:oBrw:bLDblClick)

   oBtn:cToolTip:="Consultar Permiso"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTrabAus:oBrw,oTrabAus:cTitle,oTrabAus:cTrabajad))

   oBtn:cToolTip:="Exportar hacia Excel"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oTrabAus:RECIMPRIME(oTrabAus)

   oBtn:cToolTip:="Imprimir Recibo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTrabAus:oBrw:GoTop(),oTrabAus:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oTrabAus:oBrw:PageDown(),oTrabAus:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oTrabAus:oBrw:PageUp(),oTrabAus:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTrabAus:oBrw:GoBottom(),oTrabAus:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTrabAus:Close()

  oTrabAus:oBrw:SetColor(0,15790320)

  @ 0.1,55 SAY oTrabAus:cTrabajad OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,15724527)
  AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip,o:SetColor(CLR_BLACK,15724527)})

RETURN .T.

FUNCTION RECIMPRIME(oTrabAus)
  LOCAL aVar   :={}
  LOCAL oBrw   :=oTrabAus:oBrw
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[1]

  aVar:={oDp:cCodTraIni,;
         oDp:cCodTraFin}

  oDp:cCodTraIni:=oTrabAus:cCodTra 
  oDp:cCodTraFin:=oTrabAus:cCodTra 

  REPORTE("NMAUSXTRAB")

  oDp:cCodTraIni:=aVar[1]
  oDp:cCodTraFin:=aVar[2]

RETURN .T.

// EOF
