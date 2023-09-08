// Programa   : NMFORMAP
// Fecha/Hora : 20/05/2004 11:08:10
// Propósito  : Editar los Res£mes de los Promedios
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Nómina
// Tabla      : NMRESTRA

#INCLUDE "DPXBASE.CH"

PROCE NMFORMAP()

  LOCAL aForma :=GETOPTIONS("NMTRABAJADOR","FORMA_PAG")
  LOCAL cNumero:=SqlGetMax("NMRECIBOS","REC_NUMERO")

  IF EMPTY(cNumero)
     MensajeErr("No Existen Recibos de Pago")
     RETURN .F.
  ENDIF

  oFormaP:=DPEDIT():New("Forma de Pago en Recibos","NMFORMAP.edt","oFormaP",.T.)
  
  oFormaP:cNumero    :=cNumero
  oFormaP:cFormaP    :="C"
  oFormaP:cNumChq    :=SPACE(15)
  oFormaP:cCodTra    :=SPACE(10)
  oFormaP:cTrabajador:=""
  oFormaP:nNumChq    :=0
  oFormaP:nMonto     :=0
  oFormaP:cCodCta    :=SPACE(12)

  READRECIBO(cNumero)

  @ 2,0 SAY "Recibo:"

  // Número del Recibo
  @ 2,10 GET oFormaP:cNumero;
         PICTURE "9999999";
         VALID CERO(oFormaP:cNumero);
         RIGHT

  // Forma de Pago
  @ 2,0 SAY "Forma Pago:"
  @ 5.6,15.0 COMBOBOX oFormaP:oForma  VAR oFormaP:cFormaP  ITEMS aForma;
                      WHEN AccessField("NMTRABAJADOR","FORMA_PAG",3)

  ComboIni(oFormaP:oForma )

  @ 3,0 SAY "Código:"
  @ 3,0 SAY oFormaP:oCodTra     PROMPT oFormaP:cCodTra     UPDATE

  @ 4,0 SAY "Apellido y Nombre"
  @ 4,0 SAY oFormaP:oTrabajador PROMPT oFormaP:cTrabajador UPDATE

  @ 4,0 SAY "Monto:"
  @ 4,0 SAY oFormaP:oMonto PROMPT TRAN(oFormaP:nMonto,"999,999,999.99");
            UPDATE RIGHT 

  @ 7,0 SAY "Banco:"

  @ 7,0 BMPGET oFormaP:oCodCta VAR oFormaP:cCodCta;
               NAME "BITMAPS\find.bmp";
               ACTION 1=1

  @ 7,0 SAY "Cheque:"
  @ 7,0 GET oFormaP:oNumChq VAR oFormaP:nNumChq;
        PICTURE "99999999999";
        RIGHT

  @ 8,0 SAY "Nombre del Banco:"
  @ 8,0 SAY oFormaP:oBanco  PROMPT oFormaP:cBanco

  oFormaP:Activate({||oFormaP:NMFORMAPBTN(oFormaP)})


RETURN NIL

/*
// Botones de Barra
*/
FUNCTION NMFORMAPBTN(oFormaP)
   LOCAL oBar,oCursor,oBtn,oFont

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oFormaP:oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xEDIT.BMP";
          ACTION (1=1)

   oBtn:cToolTip:="Modificar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIND.BMP";
          ACTION (1=1)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION 1=1

   oBtn:cToolTip:="Primer Trabajador"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION 1=1

   oBtn:cToolTip:="Siguiente"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION 1=1

   oBtn:cToolTip:="Anterior"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION 1=1

   oBtn:cToolTip:="Ultimo Trabajador"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSALIR.BMP";
          ACTION oFormaP:Close()

   oBtn:cToolTip:="Cerrar y Salir"

   oBar:SetColor(0,16777215)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(0,16777215)})

RETURN .T.

/*
// Lee el Recibo
*/
FUNCTION READRECIBO(cNumero)
  LOCAL oTable,cSql

  cSql:=" SELECT REC_CODTRA,APELLIDO,NOMBRE,REC_FORMAP,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,"+;
        " REC_NUMCHQ,REC_CODCTA,"+;
        " SUM(HIS_MONTO) AS REC_MONTO FROM NMRECIBOS "+;
        " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO"+;
        " INNER JOIN NMHISTORICO  ON HIS_NUMREC=REC_NUMERO"+;
        " INNER JOIN NMTRABAJADOR ON REC_CODTRA=REC_CODTRA"+;
        " WHERE REC_NUMERO"+GetWhere("=",cNumero)+ " AND HIS_CODCON<='DZZZ' "+;
        " GROUP BY "+;
        " REC_CODTRA,APELLIDO,NOMBRE,REC_FORMAP,FCH_DESDE,FCH_HASTA,REC_FECHAS,FCH_TIPNOM,FCH_OTRNOM,"+;
        " REC_NUMCHQ,REC_CODCTA "

  oTable:=OpenTable(cSql,.T.)

  oFormaP:cFormaP    :=oTable:REC_FORMAP
  oFormaP:cTrabajador:=RTRIM(oTable:APELLIDO)+", "+RTRIM(oTable:NOMBRE)
  oFormaP:cCodTra    :=oTable:REC_CODTRA
  oFormaP:nMonto     :=oTable:REC_MONTO
  oFormaP:nNumChq    :=oTable:REC_NUMCHQ
  oFormaP:cCodCta    :=oTable:REC_CODCTA
  oFormaP:cBanco     :=SQLGET("NMBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oFormaP:cCodCta))

  oTable:End()

RETURN .T.
// EOF

