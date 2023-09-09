// Programa   : NMTRABHISCON
// Fecha/Hora : 03/08/2004 17:21:13
// Propósito  : Visualizar Trabajador Histórico
// Creado Por : Juan Navas
// Llamado por: NMTRABJCON
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra,nAno,nMes,cWhereC)
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oTable,oDlg,aData,cWhere:="",cTitle:=""
  LOCAL cSql,cPictureV,cPictureM,cNombre:="",nMonto:=0,cInner:=""
  LOCAL cFecha  :=HISFECHA()

  DEFAULT cCodTra:="1002",;
          cWhereC:=""

  CursorWait()

  IF nMes<>NIL .AND. nAno<>NIL

     nMes  :=CTOO(nMes,"N")
     nAno  :=CTOO(nAno,"N")
     cInner:=" INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO "+CRLF+;
             " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+CRLF

     cWhere:=" AND "+;
             " YEAR("+cFecha+") "+GetWhere("=",nAno)

     IF nMes<13

        cWhere:=cWhere +" AND "+;
                     " MONTH(REC_FECHAS)"+GetWhere("=",nMes)
        cTitle:=" [Periodo: "+STRZERO(nAno,4)+"/"+CMES(nMes)+"]"

     ELSE

        cTitle:=" [Año: "+STRZERO(nAno,4)+"]"

     ENDIF
     
  ENDIF

  IF !Empty(cWhereC)
     cWhereC:=" AND "+cWhereC
  ENDIF

  cSql:="SELECT HIS_CODCON,CON_DESCRI,CON_REPRES,SUM(HIS_VARIAC) AS HIS_VARIAC,SUM(HIS_MONTO) AS HIS_MONTO FROM NMHISTORICO "+;
        "INNER JOIN NMCONCEPTOS ON HIS_CODCON=CON_CODIGO "+;
        "INNER JOIN NMRECIBOS   ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
        "INNER JOIN NMFECHAS    ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
        "WHERE REC_CODTRA"+GetWhere("=",cCodTra)+cWhere+" "+cWhereC+;
        "GROUP BY HIS_CODCON,CON_DESCRI,CON_REPRES"

  oTable:=OpenTable(cSql,.T.)

  DPWRITE("TEMP\NMTRABHISCON.SQL",oDp:cSql)

//  ClpCopy(cSql)

  aData:=ACLONE(oTable:aDataFill)

  AEVAL(aData,{|a,n,n1|n1:=0,;
                    n1:=IIF(Left(a[1],1)="A", 1,n1),;
                    n1:=IIF(Left(a[1],1)="D", 1,n1),;
                    nMonto:=nMonto+(a[5]*n1)})

  cPictureV:=oTable:GetPicture("HIS_VARIAC",.T.)
  cPictureM:=oTable:GetPicture("HIS_MONTO",.T.)

  oTable:End()

  IF EMPTY(aData)
     MensajeErr("Trabajador "+cCodTra+" No posee Registros en el Histórico de Pagos")
     RETURN .T.
  ENDIF

  oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
  cNombre:=cCodTra+" "+ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
  oTable:End()

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//  oHisDetCon:=DPEDIT():New("Resumen por Concepto "+cTitle,"NMTRABHCON.edt","oHisDetCon",.T.)

  DpMdi("Resumen por Concepto "+cTitle,"oHisDetCon","NMTRABHCON.edt")
  oHisDetCon:Windows(0,0,oDp:aCoors[3]-160,MIN(650+155,oDp:aCoors[4]-10),.T.) // Maximizado


  oHisDetCon:nClrPane1:=oDp:nClrPane1 // 15790320
  oHisDetCon:nClrPane2:=oDp:nClrPane2 // 16382457

  oHisDetCon:cCodTra:=cCodTra
  oHisDetCon:cPictureV:=cPictureV
  oHisDetCon:cPictureM:=cPictureM
  oHisDetCon:cTrabajad:=" "+cNombre

  oDlg:=oHisDetCon:oDlg

  oBrw:=TXBrowse():New( oDlg )

//  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aData, .T. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .T.
  oBrw:oFont               :=oFont

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  
  oBrw:aCols[1]:cHeader:="Código"
  oBrw:aCols[1]:nWidth :=70

  oBrw:aCols[2]:cHeader:="Descripción"
  oBrw:aCols[2]:nWidth :=280

  oBrw:aCols[3]:cHeader:="Repres."
  oBrw:aCols[3]:nWidth :=90

  oBrw:aCols[4]:cHeader:="Variación"
  oBrw:aCols[4]:nWidth :=125
  oBrw:aCols[4]:cPicture:=cPictureV   
  oBrw:aCols[4]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[4]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[4]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oHisDetCon:cPictureV)}

  oBrw:aCols[5]:cHeader:="Monto"
  oBrw:aCols[5]:nWidth :=150
  oBrw:aCols[5]:cPicture:=cPictureM
  oBrw:aCols[5]:nDataStrAlign := AL_RIGHT
  oBrw:aCols[5]:nHeadStrAlign := AL_RIGHT
  oBrw:aCols[5]:nFootStrAlign := AL_RIGHT
  oBrw:aCols[5]:bStrData      := { |oObj,oBrw|oBrw:=oObj:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oHisDetCon:cPictureM)}
  oBrw:aCols[5]:cFooter       := TRAN(nMonto,cPictureM)

  // oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  // oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oHisDetCon:oBrw,cCod:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                               cCod:=Left(cCod,1),;
                               nClrText:=0,;
                               nClrText:=IIF(cCod="A",CLR_HBLUE,nClrText),;
                               nClrText:=IIF(cCod="D",CLR_HRED ,nClrText),;
                               {nClrText, iif( oBrw:nArrayAt%2=0, oHisDetCon:nClrPane1, oHisDetCon:nClrPane2 ) } }
  oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oHisDetCon:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
                     EJECUTAR("NMTRABHISDET",oHisDetCon:cCodTra,cCodCon)}

  oBrw:SetFont(oFont)

  oHisDetCon:oBrw:=oBrw

  oBrw:CreateFromCode()
  oHisDetCon:oWnd:oClient := oBrw

  oHisDetCon:bValid   :={|| EJECUTAR("BRWSAVEPAR",oHisDetCon)}
  oHisDetCon:BRWRESTOREPAR()
 
  oHisDetCon:Activate({||oHisDetCon:LeyBar(oHisDetCon)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oHisDetCon)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oHisDetCon:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\COMPARATIVO.BMP" ;
          ACTION oHisDetCon:COMPARATIVOS()

   oBtn:cToolTip:="Visualizar Valores Comparativos"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RESUMENXCONCEPTO.BMP";
          ACTION EVAL(oHisDetCon:oBrw:bLDblClick)

  oBtn:cToolTip:="Visualizar Detalle del Concepto"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\EXCEL.BMP";
         ACTION (EJECUTAR("BRWTOEXCEL",oHisDetCon:oBrw,oHisDetCon:cTitle,oHisDetCon:cTrabajad))

  oBtn:cToolTip:="Exportar hacia Excel"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oHisDetCon:oBrw:GoTop(),oHisDetCon:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oHisDetCon:oBrw:PageDown(),oHisDetCon:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oHisDetCon:oBrw:PageUp(),oHisDetCon:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oHisDetCon:oBrw:GoBottom(),oHisDetCon:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oHisDetCon:Close()

  oHisDetCon:oBrw:SetColor(0,oDp:nGris)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,70-5 SAY oHisDetCon:cTrabajad OF oBar BORDER SIZE 345,18 COLOR oDp:nClrYellowText,oDp:nClrYellow

  
RETURN .T.

/*
// Visualizar Comparativos
*/
FUNCTION COMPARATIVOS()
   LOCAL cScope,aLine:=oHisDetCon:oBrw:aArrayData[oHisDetCon:oBrw:nArrayAt]
   LOCAL cTitle  :="Valores Comparativos del Concepto "+aLine[1]+" "+aLine[2]

   cScope :="REC_CODTRA"+GetWhere("=",oHisDetCon:cCodTra)+" AND "+;
            "HIS_CODCON"+GetWhere("=",aLine[1])

   EJECUTAR("DPRUNCOMP","CONCEPTOS",oHisDetCon:cCodTra,oHisDetCon:cTrabajad ,cTitle,"Mensual",cScope, .T. , .T. )
 
RETURN NIL

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oHisDetCon)
// EOF
