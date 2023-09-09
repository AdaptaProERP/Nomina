// Programa   : NMTRABPRES
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Visualizar Préstamos por Trabajador
// Creado Por : Juan Navas
// Llamado por: NMTRABJCON
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,nAno,nMes,lView)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,cConcepto:="",oPagos
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nVar:=0,nMonto:=0,cTitle:=""
  LOCAL nSaldo:=0,nPago:=0,nTPres:=0

  DEFAULT cCodTra:="1003",lView:=.T.

  cSql:=" SELECT PRE_ID,PRE_NUMERO,REC_FECHAS,PRE_NUMREC,PRE_MONTO,0 AS PRE_PAGADO,0 AS PRE_SALDO,PRE_CUOTA,PRE_INTERE FROM NMTABPRES "+;
        " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO "+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
        " AND PRE_TIPO='P'"

  oTable:=OpenTable(cSql,.T.)

  WHILE !oTable:Eof()

     oPagos:=OpenTable("SELECT SUM(PRE_MONTO) AS PRE_MONTO,SUM(PRE_INTERE) AS PRE_INTERE,COUNT(*) AS CUANTOS FROM NMTABPRES "+;
                       " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO    "   +;
                       " WHERE REC_CODTRA"+GetWhere("=",cCodTra)              +;
                       "       AND PRE_NUMERO"+GetWhere("=",oTable:PRE_NUMERO)+;
                       "       AND PRE_TIPO  "+GetWhere("=","A")+;
                       "       AND PRE_ID"    +GetWhere("=",oTable:PRE_ID)+;
                       "",.T.)
                       

// ? CLPCOPY(oDp:cSql)

     oTable:Replace("PRE_PAGADO",oPagos:PRE_MONTO)
     oTable:Replace("PRE_SALDO" ,oTable:PRE_MONTO-oPagos:PRE_MONTO)
     oTable:Replace("PRE_INTERE",oPagos:PRE_INTERE)

     nMonto:=nMonto+oTable:PRE_MONTO
     nPago :=nPago +oTable:PRE_SALDO
     nTPres:=nTPres+oPagos:PRE_INTERE

     oPagos:End()
     oTable:Skip(1)

  ENDDO

  nSaldo:=nMonto-nPago
  aData :=ACLONE(oTable:aDataFill)

//  VIEWARRAY(aData)
// RETURN NIL


  cPictureM:=oTable:GetPicture("PRE_MONTO",.T.)

  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Trabajador "+cCodTra+" no Tiene Préstamos "+cTitle)
     RETURN .F.
  ENDIF

  oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
  cNombre:=cCodTra+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
  oTable:End()

  DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

  oTrabPres:=DPEDIT():New("Préstamos por Trabajador"+cTitle,"NMTRABPREST.edt","oTrabPres",.T.)

  oTrabPres:cCodTra  :=cCodTra
  oTrabPres:cTrabajad:=cNombre
  oTrabPres:cPictureM:=cPictureM
  oTrabPres:lView    :=lView

  oDlg:=oTrabPres:oDlg

  oBrw:=TXBrowse():New( oDlg )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .T. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 1

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:CreateFromCode()

  oBrw:aCols[1]:cHeader:="ID"
  oBrw:aCols[1]:nWidth :=140

  oBrw:aCols[2]:cHeader:="#"
  oBrw:aCols[2]:nWidth :=40

  oBrw:aCols[3]:cHeader:="Fecha"
  oBrw:aCols[3]:nWidth :=68

  oBrw:aCols[4]:cHeader:="Recibo"
  oBrw:aCols[4]:nWidth :=55

  oBrw:aCols[5]:cHeader:="Monto"
  oBrw:aCols[5]:nWidth :=110
  oBrw:aCols[5]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[5]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[5]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[5]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oTrabPres:cPictureM)}
  oBrw:aCols[5]:cFooter       := TRAN(nMonto,cPictureM)
  oBrw:aCols[5]:cEditPicture  := cPictureM

  oBrw:aCols[6]:cHeader:="Pagos"
  oBrw:aCols[6]:nWidth :=110
  oBrw:aCols[6]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[6]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[6]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[6]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oTrabPres:cPictureM)}
  oBrw:aCols[6]:cFooter       := TRAN(nSaldo,cPictureM)
  oBrw:aCols[6]:cEditPicture  := cPictureM

  oBrw:aCols[7]:cHeader:="Saldo"
  oBrw:aCols[7]:nWidth :=110
  oBrw:aCols[7]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[7]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[7]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[7]:cFooter       := TRAN(nPago,cPictureM)
  oBrw:aCols[7]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],oTrabPres:cPictureM)}
  oBrw:aCols[7]:cEditPicture  := cPictureM

  oBrw:aCols[8]:cHeader:="Cuota"
  oBrw:aCols[8]:nWidth :=110
  oBrw:aCols[8]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[8]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[8]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[8]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,8],oTrabPres:cPictureM)}
  oBrw:aCols[8]:cEditPicture  := cPictureM

  oBrw:aCols[9]:cHeader:="Intereses"
  oBrw:aCols[9]:nWidth :=110  
  oBrw:aCols[9]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[9]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[9]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[9]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,9],oTrabPres:cPictureM)}
  oBrw:aCols[9]:cFooter       := TRAN(nTPres,cPictureM)
  oBrw:aCols[9]:cEditPicture  := cPictureM

  oBrw:bClrHeader:= {|| {0,14671839 }}
  oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrStd   :={|oBrw,nSaldo,nClrText|oBrw:=oTrabPres:oBrw,nSaldo:=oBrw:aArrayData[oBrw:nArrayAt,7],;
                               nClrText:=0,;
                               nClrText:=IIF(nSaldo=0,CLR_HBLUE,nClrText),;
                               nClrText:=IIF(nSaldo>0,CLR_HRED ,nClrText),;
                               {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }

  oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oTrabPres:oBrw,;
                     EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,3])}

  oBrw:SetFont(oFont)

  oTrabPres:oBrw:=oBrw
  oTrabPres:Activate({||oTrabPres:LeyBar(oTrabPres)})
 
  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oTrabPres)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oTrabPres:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   IF !oTrabPres:lView

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\CRONOGRAMADEDUCCION.BMP"

     oBtn:cToolTip:="Cronograma de Deducción"

     oBtn:bAction :={|oBrw,cNumPres,cId|oBrw    :=oTrabPres:oBrw,;
                                        cNumPres:=oBrw:aArrayData[oBrw:nArrayAt,2],;
                                        cId     :=oBrw:aArrayData[oBrw:nArrayAt,1],;
                                        EJECUTAR("NMTABPRES",3,oTrabPres:cCodTra,cNumPres,cId)}

     oBrw:bLDblClick:=oBtn:bAction 

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oTrabPres:oBrw,oTrabPres:cTitle,oTrabPres:cTrabajad))

   oBtn:cToolTip:="Exportar hacia Excel"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RECIBO.BMP";
          ACTION EVAL(oTrabPres:oBrw:bLDblClick)

   oBtn:cToolTip:="Visualizar Recibo de Pago"

   oBtn:bAction:={|oBrw,cCodCon|oBrw:=oTrabPres:oBrw,;
                   EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,3])}



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PAGOS.BMP"

   oBtn:bAction:={|oBrw|oBrw:=oTrabPres:oBrw,;
                     EJECUTAR("NMPRESTPAGO",oBrw:aArrayData[oBrw:nArrayAt,1])}

   oBtn:cToolTip:="Visualizar Pagos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION oTrabPres:RECIMPRIME(oTrabPres)

   oBtn:cToolTip:="Listar Préstamos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oTrabPres:oBrw:GoTop(),oTrabPres:oBrw:Setfocus())

   oBtn:cToolTip:="Primer Préstamo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oTrabPres:oBrw:PageDown(),oTrabPres:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oTrabPres:oBrw:PageUp(),oTrabPres:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oTrabPres:oBrw:GoBottom(),oTrabPres:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Préstamo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oTrabPres:Close()

  oBtn:cToolTip:="Cerrar Formulario"

  oTrabPres:oBrw:SetColor(0,15790320)

  @ 0.1,68 SAY oTrabPres:cTrabajad OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,15724527)

  AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip,o:SetColor(CLR_BLACK,15724527)})

RETURN .T.

FUNCTION RECIMPRIME(oTrabPres)
  LOCAL oRep
/*
  LOCAL aVar   :={}
  LOCAL oBrw   :=oTrabPres:oBrw,oTable
  LOCAL aData  :=oBrw:aArrayData[oBrw:nArrayAt]
  LOCAL cNumRec:=aData[3]
  LOCAL oCodTra:=""

  oTable:=OpenTable("SELECT REC_CODTRA FROM NMRECIBOS WHERE REC_NUMERO"+GetWhere("=",cNumRec),.T.)
  oDp:cCodTraIni:=oTable:REC_CODTRA
  oDp:cCodTraFin:=oTable:REC_CODTRA
  oTable:End()

  aVar:={oDp:cCodTraIni,;
         oDp:cCodTraFin}
*/

  oRep:=REPORTE("NMPRESXTRAB")
  oRep:SetRango(1,oTrabPres:cCodTra,oTrabPres:cCodTra)

/*
  oDp:cCodTraIni:=aVar[1]
  oDp:cCodTraFin:=aVar[2]
*/

RETURN .T.

FUNCTION CANCEL()
RETURN .T.


// EOF
