// Programa   : NMANTIGLABXINDROT
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Antiguedad Laboral por Indice de Rotación
// Creado Por : Juan Navas
// Llamado por: NMTRABJCON
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,nAno,nMes)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,cConcepto:=""
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nVar:=0,nMonto:=0,cTitle:=""
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )
  LOCAL aTotal:={}

  DEFAULT cCodTra:=SQLGET("NMRECIBOS","REC_CODTRA")

// cSql:=" SELECT REC_NUMERO,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,REC_USUARI,REC_FORMAP,SUM(HIS_MONTO) AS REC_MONTO FROM NMRECIBOS "+;
//       " INNER JOIN NMFECHAS    ON REC_NUMFCH=FCH_NUMERO"+;
//       " INNER JOIN NMHISTORICO ON HIS_NUMREC=REC_NUMERO"+;
//       " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+ " AND HIS_CODCON<='DZZZ' "+;
//       " GROUP BY REC_NUMERO,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,REC_USUARI,REC_FORMAP"

/*
  cSql:=" SELECT REC_NUMERO,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,REC_USUARI,REC_FORMAP,SUM(HIS_MONTO) AS REC_MONTO FROM NMRECIBOS "+;
        " INNER JOIN NMFECHAS    ON REC_NUMFCH=FCH_NUMERO"+;
        " INNER JOIN NMHISTORICO ON HIS_NUMREC=REC_NUMERO"+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+ " AND ( LEFT(HIS_CODCON,1)<='D' OR LEFT(HIS_CODCON,1)='H') "+;
        " GROUP BY REC_NUMERO,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,REC_USUARI,REC_FORMAP"
*/
  // 03/10/2019
  cSql:=" SELECT REC_NUMERO,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,REC_USUARI,REC_FORMAP,"+;
        [ SUM(IF(LEFT(HIS_CODCON,1)="A",HIS_MONTO,0)) AS REC_ASIGNA,]+;
        [ SUM(IF(LEFT(HIS_CODCON,1)="D",HIS_MONTO*-1,0)) AS REC_DEDUCC,]+;
        [ SUM(IF(LEFT(HIS_CODCON,1)="A" OR LEFT(HIS_CODCON,1)="D",HIS_MONTO,0)) AS REC_MONTO ]+;
        " FROM NMRECIBOS "+;
        " INNER JOIN NMFECHAS    ON REC_NUMFCH=FCH_NUMERO"+;
        " INNER JOIN NMHISTORICO ON HIS_NUMREC=REC_NUMERO"+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+ " AND ( LEFT(HIS_CODCON,1)<='D' OR LEFT(HIS_CODCON,1)='H') "+;
        " GROUP BY REC_NUMERO,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,REC_USUARI,REC_FORMAP"

  IF nMes<>NIL .AND. nAno<>NIL
     nMes:=CTOO(nMes,"N")
     nAno:=CTOO(nAno,"N")
     cSql:=cSql +" AND "+;
                 " YEAR(REC_FECHAS) "+GetWhere("=",nAno)

     IF nMes<13

        cSql:=cSql +" AND "+;
                     " MONTH(REC_FECHAS)"+GetWhere("=",nMes)
        cTitle:=" [Periodo: "+STRZERO(nAno,4)+"/"+CMES(nMes)+"]"

     ELSE

        cTitle:=" [Año: "+STRZERO(nAno,4)+"]"

     ENDIF
     
  ENDIF

  oTable:=OpenTable(cSql,.T.)

  DPWRITE("TEMP\NMTRABREC.SQL",oDp:cSql)

  aData:=ACLONE(oTable:aDataFill)

  AEVAL(aData,{|a,n|nMonto:=nMonto+a[9]})
  aTotal:=ATOTALES(aData)

  cPictureM:=oTable:GetPicture("REC_MONTO",.T.)
//cPictureM:="999,999,999.99"
//? cPictureM,"cPictureM"

  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Trabajador "+cCodTra+" no Tiene Recibos "+cTitle)
     RETURN .F.
  ENDIF

  oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
  cNombre:=cCodTra+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
  oTable:End()

  DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

//  oTrabRec:=DPEDIT():New("Recibos de Pago por Trabajador"+cTitle,"NMTRABREC.edt","oTrabRec",.T.)

  oTrabRec:=DpMdi("Recibos de Pago por Trabajador"+cTitle,"oTrabRec","NMTRABREC.edt")

  oTrabRec:Windows(0,0,aCoors[3]-160,MIN(910+20,aCoors[4]-10),.T.) // Maximizado

  oTrabRec:cCodTra  :=cCodTra
  oTrabRec:cTrabajad:=cNombre
  oTrabRec:cPictureM:=cPictureM
  oTrabRec:nClrPane1:=16770250
  oTrabRec:nClrPane2:=16766894 


  oDlg:=oTrabRec:oDlg

  oBrw:=TXBrowse():New( oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .T. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 2

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:aCols[1]:cHeader:="Número"+CRLF+"Recibo"
  oBrw:aCols[1]:nWidth :=70

  oBrw:aCols[2]:cHeader:="Fecha"+CRLF+"Desde"
  oBrw:aCols[2]:nWidth :=70

  oBrw:aCols[3]:cHeader:="Fecha"+CRLF+"Hasta"
  oBrw:aCols[3]:nWidth :=70

  oBrw:aCols[4]:cHeader:="Fecha"+CRLF+"Proceso"
  oBrw:aCols[4]:nWidth :=70

  oBrw:aCols[5]:cHeader:="Tipo"+CRLF+"Nómina"
  oBrw:aCols[5]:nWidth :=60

  oBrw:aCols[6]:cHeader:="Otra"+CRLF+"Nómina"
  oBrw:aCols[6]:nWidth :=60

  oBrw:aCols[7]:cHeader:="Usuario"
  oBrw:aCols[7]:nWidth :=60  

  oBrw:aCols[8]:cHeader:="Forma"+CRLF+"Pago"
  oBrw:aCols[8]:nWidth :=60

  oBrw:aCols[9]:cHeader:="Asignación"
  oBrw:aCols[9]:nWidth :=110
  oBrw:aCols[9]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[9]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[9]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[9]:cFooter       := TRAN(aTotal[09],cPictureM)
  oBrw:aCols[9]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,FDP(oBrw:aArrayData[oBrw:nArrayAt,9],oTrabRec:cPictureM)}

  oBrw:aCols[09]:bClrStd        :={|oBrw,nClrText|oBrw:=oTrabRec:oBrw,;
                                   nClrText:=CLR_HBLUE,;
                                   {nClrText, iif( oBrw:nArrayAt%2=0, oTrabRec:nClrPane1, oTrabRec:nClrPane2 ) } }



  oBrw:aCols[10]:cHeader:="Deducción"
  oBrw:aCols[10]:nWidth :=110
  oBrw:aCols[10]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[10]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[10]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[10]:cFooter       := TRAN(aTotal[10],cPictureM)
  oBrw:aCols[10]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,10],oTrabRec:cPictureM)}

  oBrw:aCols[10]:bClrStd        :={|oBrw,nClrText|oBrw:=oTrabRec:oBrw,;
                                   nClrText:=CLR_HRED,;
                                   {nClrText, iif( oBrw:nArrayAt%2=0, oTrabRec:nClrPane1, oTrabRec:nClrPane2 ) } }


  oBrw:aCols[11]:cHeader:="Monto"
  oBrw:aCols[11]:nWidth :=110
  oBrw:aCols[11]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[11]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[11]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[11]:cFooter       := TRAN(aTotal[11],cPictureM)
  oBrw:aCols[11]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,11],oTrabRec:cPictureM)}

//  oBrw:bClrHeader:= {|| {0,14671839 }}
//  oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd   :={|oBrw,nClrText|oBrw:=oTrabRec:oBrw,;
                                   nClrText:=0,;
                                   {nClrText, iif( oBrw:nArrayAt%2=0, oTrabRec:nClrPane1, oTrabRec:nClrPane2 ) } }

  oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oTrabRec:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                     EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,1])}

  oBrw:SetFont(oFont)

  oBrw:CreateFromCode()
  
  oTrabRec:oBrw:=oBrw
  oTrabRec:oWnd:oClient := oTrabRec:oBrw
  oTrabRec:Activate({||oTrabRec:LeyBar(oTrabRec)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oTrabRec)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTrabRec:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RECIBO.BMP";
          ACTION EVAL(oTrabRec:oBrw:bLDblClick)

   oBtn:cToolTip:="Visualizar Cuerpo del Recibo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTrabRec:oBrw,oTrabRec:cTitle,oTrabRec:cTrabajad))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oTrabRec:RECIMPRIME(oTrabRec)

   oBtn:cToolTip:="Imprimir Recibo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oTrabRec:oBrw)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION EJECUTAR("BRWTOHTML",oTrabRec:oBrw)

   oBtn:cToolTip:="Generar Archivo html"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTrabRec:oBrw:GoTop(),oTrabRec:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oTrabRec:oBrw:PageDown(),oTrabRec:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oTrabRec:oBrw:PageUp(),oTrabRec:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTrabRec:oBrw:GoBottom(),oTrabRec:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTrabRec:Close()

  oTrabRec:oBrw:SetColor(0,oTrabRec:nClrPane1)
// oTrabRec:nClrPane1, oTrabRec:nClrPane2

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

//  @ 0.1,65 SAY " "+oTrabRec:cCodTra   OF oBar BORDER SIZE 345,18 COLOR oDp:nClrYellowText,oDp:nClrYellow
  @ 0.1,65 SAY " "+oTrabRec:cTrabajad OF oBar BORDER SIZE 345,18 COLOR oDp:nClrYellowText,oDp:nClrYellow
 

RETURN .T.

FUNCTION RECIMPRIME(oTrabRec)
  LOCAL aVar   :={}
  LOCAL oBrw   :=oTrabRec:oBrw
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[1]

  aVar:={oDp:cTipoNom  ,;
         oDp:cOtraNom  ,;
         oDp:cCodTraIni,;
         oDp:cCodTraFin,;
         oDp:cCodGru   ,;
         oDp:dDesde    ,;
         oDp:dHasta    ,;
         oDp:cRecIni   ,;
         oDp:cRecFin    }

  oDP:cTipoNom  :=""
  oDp:cOtraNom  :=""
  oDp:cCodTraIni:=""
  oDp:cCodTraFin:=""
  oDp:cCodGru   :=""
  oDp:dDesde    :=CTOD("")
  oDp:dHasta    :=CTOD("")
  oDp:cRecIni   :=cNumRec
  oDp:cRecFin   :=cNumRec

  REPORTE("RECIBOS")

  oDp:cTipoNom  :=aVar[1]
  oDp:cOtraNom  :=aVar[2]
  oDp:cCodTraIni:=aVar[3]
  oDp:cCodTraFin:=aVar[4]
  oDp:cCodGru   :=aVar[5]
  oDp:dDesde    :=aVar[6]
  oDp:dHasta    :=aVar[7]
  oDp:cRecIni   :=aVar[8]
  oDp:cRecFin   :=aVar[9]

RETURN .T.

// EOF

