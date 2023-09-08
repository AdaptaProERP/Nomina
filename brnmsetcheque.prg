// Programa   : BRNMSETCHEQUE
// Fecha/Hora : 22/09/2016 23:12:11
// Propósito  : "Asignar Cheques en Recibos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumFch)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMSETCHEQUE.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL dFecha,oDb

   IF !EJECUTAR("TABLASNOMINA")
       RETURN .F.
   ENDIF

   cServer:=oDp:Nm_cServer

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF 

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4 

   DEFAULT cNumFch:="00133",;
           cWhere:="FCH_NUMERO"+GetWhere("=",cNumFch)

   dFecha:=SQLGET("NMFECHAS","FCH_SISTEM","FCH_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                                                 "FCH_NUMERO"+GetWhere("=",cNumFch),NIL,oDb)

   cTitle:="Asignar Cheques en Recibos "+DTOC(dFecha) +IF(Empty(cTitle),"",cTitle)

   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oNMSETCHEQUE
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)

   DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD

// DPEDIT():New(cTitle,"BRNMSETCHEQUE.EDT","oNMSETCHEQUE",.F.)
// oNMSETCHEQUE:CreateWindow(NIL,NIL,NIL,550,850+58)

   DpMdi(cTitle,"oNMSETCHEQUE","BRDOCPROVIEW.EDT")
   oNMSETCHEQUE:Windows(0,0,oDp:aCoors[3]-160,MIN(850+58,oDp:aCoors[4]-10),.T.) // Maximizado

   oNMSETCHEQUE:cCodSuc  :=cCodSuc
   oNMSETCHEQUE:lMsgBar  :=.F.
   oNMSETCHEQUE:cPeriodo :=aPeriodos[nPeriodo]
   oNMSETCHEQUE:cCodSuc  :=cCodSuc
   oNMSETCHEQUE:nPeriodo :=nPeriodo
   oNMSETCHEQUE:cNombre  :=""
   oNMSETCHEQUE:dDesde   :=dDesde
   oNMSETCHEQUE:cServer  :=cServer
   oNMSETCHEQUE:dHasta   :=dHasta
   oNMSETCHEQUE:cWhere   :=cWhere
   oNMSETCHEQUE:cWhere_  :=cWhere_
   oNMSETCHEQUE:cWhereQry:=""
   oNMSETCHEQUE:cSql     :=oDp:cSql
   oNMSETCHEQUE:oWhere   :=TWHERE():New(oNMSETCHEQUE)
   oNMSETCHEQUE:cCodPar  :=cCodPar // Código del Parámetro
   oNMSETCHEQUE:lWhen    :=.T.
   oNMSETCHEQUE:cTextTit :="" // Texto del Titulo Heredado
   oNMSETCHEQUE:oDb      :=oDp:oDb
   oNMSETCHEQUE:cBrwCod  :="NMSETCHEQUE"
   oNMSETCHEQUE:cNumFch  :=cNumFch
   oNMSETCHEQUE:cCodBco  :=SPACE(06)
   oNMSETCHEQUE:cCodCta  :="Ninguna"
   oNMSETCHEQUE:aCuentas :={oNMSETCHEQUE:cCodCta}
   oNMSETCHEQUE:dFecha   :=dFecha
   oNMSETCHEQUE:lDownAuto:=.T.

   oNMSETCHEQUE:nClrPane1:=oDp:nClrPane1
   oNMSETCHEQUE:nClrPane2:=oDp:nClrPane2

   oNMSETCHEQUE:oBrw:=TXBrowse():New( oNMSETCHEQUE:oDlg )
   oNMSETCHEQUE:oBrw:SetArray( aData, .F. )
   oNMSETCHEQUE:oBrw:SetFont(oFont)

   oNMSETCHEQUE:oBrw:lFooter     := .T.
   oNMSETCHEQUE:oBrw:lHScroll    := .F.
   oNMSETCHEQUE:oBrw:nHeaderLines:= 2
   oNMSETCHEQUE:oBrw:nDataLines  := 1
   oNMSETCHEQUE:oBrw:nFooterLines:= 1

   oNMSETCHEQUE:aData            :=ACLONE(aData)

   AEVAL(oNMSETCHEQUE:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oNMSETCHEQUE:oBrw:aCols[1]
  oCol:cHeader      :='Num.'+CRLF+'Recibo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 56

  oCol:=oNMSETCHEQUE:oBrw:aCols[2]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oNMSETCHEQUE:oBrw:aCols[3]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  oCol:=oNMSETCHEQUE:oBrw:aCols[4]
  oCol:cHeader      :='Cód.'+CRLF+"Banco"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 50


  oCol:=oNMSETCHEQUE:oBrw:aCols[5]
  oCol:cHeader      :='Banco'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 150


  oCol:=oNMSETCHEQUE:oBrw:aCols[6]
  oCol:cHeader      :='Cuenta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 150

  oCol:=oNMSETCHEQUE:oBrw:aCols[7]
  oCol:cHeader      :='Cheque'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:bOnPostEdit  :={|oCol,uValue|oNMSETCHEQUE:SETCHEQUE(oCol,uValue,7)}


  oCol:=oNMSETCHEQUE:oBrw:aCols[8]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETCHEQUE:oBrw:aArrayData ) } 
  oCol:nWidth       := 96
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMSETCHEQUE:oBrw:aArrayData[oNMSETCHEQUE:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')

  oNMSETCHEQUE:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oNMSETCHEQUE:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMSETCHEQUE:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=0,;
                                         {nClrText,iif( oBrw:nArrayAt%2=0,oMdi:nClrPane1,oMdi:nClrPane2 ) } }

  oNMSETCHEQUE:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oNMSETCHEQUE:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oNMSETCHEQUE:oBrw:bLDblClick:={|oBrw|oNMSETCHEQUE:RUNCLICK() }
  oNMSETCHEQUE:oBrw:bKeyDown  :={|nKey|IIF(nKey=13, oNMSETCHEQUE:RUNCLICK(),NIL) }

  oNMSETCHEQUE:oWnd:oClient   := oNMSETCHEQUE:oBrw
  oNMSETCHEQUE:oBrw:bChange   :={||oNMSETCHEQUE:BRWCHANGE()}

  oNMSETCHEQUE:oBrw:CreateFromCode()

  oNMSETCHEQUE:Activate({||oNMSETCHEQUE:ViewDatBar(oNMSETCHEQUE)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oNMSETCHEQUE)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oNMSETCHEQUE:oDlg
   LOCAL nLin:=0
   LOCAL nWidth:=oNMSETCHEQUE:oBrw:nWidth()

   oNMSETCHEQUE:oBrw:GoBottom(.T.)
   oNMSETCHEQUE:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRNMSETCHEQUE.EDT")
//     oNMSETCHEQUE:oBrw:Move(44,0,850+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

 // Emanager no Incluye consulta de Vinculos

   IF .F. .AND. Empty(oNMSETCHEQUE:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMSETCHEQUE:oBrw,oNMSETCHEQUE:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF
  
/*
   IF Empty(oNMSETCHEQUE:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMSETCHEQUE")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMSETCHEQUE"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMSETCHEQUE:oBrw,"NMSETCHEQUE",oNMSETCHEQUE:cSql,oNMSETCHEQUE:nPeriodo,oNMSETCHEQUE:dDesde,oNMSETCHEQUE:dHasta,oNMSETCHEQUE)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMSETCHEQUE:oBtnRun:=oBtn



       oNMSETCHEQUE:oBrw:bLDblClick:={||EVAL(oNMSETCHEQUE:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMSETCHEQUE:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oNMSETCHEQUE:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMSETCHEQUE:oBrw);
          WHEN LEN(oNMSETCHEQUE:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMSETCHEQUE:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMSETCHEQUE)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMSETCHEQUE:oBrw,oNMSETCHEQUE:cTitle,oNMSETCHEQUE:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMSETCHEQUE:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oNMSETCHEQUE:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oNMSETCHEQUE:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMSETCHEQUE:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMSETCHEQUE:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMSETCHEQUE")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMSETCHEQUE:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMSETCHEQUE:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMSETCHEQUE:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMSETCHEQUE:oBrw:GoTop(),oNMSETCHEQUE:oBrw:Setfocus())

IF nWidth>800 .AND. .F.

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNMSETCHEQUE:oBrw:PageDown(),oNMSETCHEQUE:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNMSETCHEQUE:oBrw:PageUp(),oNMSETCHEQUE:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMSETCHEQUE:oBrw:GoBottom(),oNMSETCHEQUE:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMSETCHEQUE:Close()

  oNMSETCHEQUE:oBrw:SetColor(0,oNMSETCHEQUE:nClrPane1)

  EVAL(oNMSETCHEQUE:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMSETCHEQUE:oBar:=oBar

  // Tiene Cheque Asignado
  IF LEN(oNMSETCHEQUE:oBrw:aArrayData)>0 .AND. !Empty(oNMSETCHEQUE:oBrw:aArrayData[1,7])
    oNMSETCHEQUE:cCodBco:=oNMSETCHEQUE:oBrw:aArrayData[1,4]
  ENDIF

  nLin:=200
  // Código Bancario
  @ 1,550+60-nLin BMPGET oNMSETCHEQUE:oCodBco VAR oNMSETCHEQUE:cCodBco;
                 VALID oNMSETCHEQUE:VALCODBCO();
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPBANCOS",NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,oNMSETCHEQUE:oCodBco),;
                        oDpLbx:GetValue("BAN_CODIGO",oNMSETCHEQUE:oCodBco)); 
                 SIZE 58,20 OF oBar PIXEL FONT oFont


  oNMSETCHEQUE:oCodBco:cToolTip:="F6 Catálogo de Bancos"

  oNMSETCHEQUE:oCodBco:bKeyDown:={|nKey| IIF(nKey=13, oNMSETCHEQUE:VALCODBCO(), NIL ) }

  
  @ 1,610+60-nLin+12 SAY oNMSETCHEQUE:oBcoNombre PROMPT;
             " "+SQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oNMSETCHEQUE:cCodBco)) UPDATE OF oBar BORDER SIZE 300,20;
             PIXEL  COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

  //
  // Campo : Cuenta
  // Uso   : Moneda                                  
  //

  @ 22, 610-nLin COMBOBOX oNMSETCHEQUE:oCodCta VAR oNMSETCHEQUE:cCodCta ITEMS oNMSETCHEQUE:aCuentas;
                    VALID oNMSETCHEQUE:MOBCUENTA();
                    WHEN (!EMPTY(oNMSETCHEQUE:cCodBco);
                          .AND.LEN(oNMSETCHEQUE:oCodCta:aItems)>1) OF oBar SIZE 200,10 PIXEL UPDATE FONT oFont


  @  1,545-nLin SAY " Banco  " OF oBar BORDER SIZE 60,20 PIXEL RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
  @ 22,545-nLin SAY " Cuenta " OF oBar BORDER SIZE 60,20 PIXEL RIGHT COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont


  ComboIni(oNMSETCHEQUE:oCodCta)

  // Tiene Cheque Asignado
  IF LEN(oNMSETCHEQUE:oBrw:aArrayData)>0 .AND. !Empty(oNMSETCHEQUE:oBrw:aArrayData[1,7])

    // Solo si existe la cuenta bancaria
    oNMSETCHEQUE:cCodBco:=oNMSETCHEQUE:oBrw:aArrayData[1,4]
    oNMSETCHEQUE:VALCODBCO()

    IF Empty(SQLGET("DPCTABANCO","BCO_CTABAN","BCO_CODIGO"+GetWhere("=",oNMSETCHEQUE:cCodBco)+" AND BCO_CTABAN"+GetWhere("=",oNMSETCHEQUE:cCodCta)))
      oNMSETCHEQUE:cCodCta:=oNMSETCHEQUE:oBrw:aArrayData[1,6]
      ComboIni(oNMSETCHEQUE:oCodCta)
    ENDIF

  ENDIF

  oNMSETCHEQUE:oCodCta:ForWhen(.T.)

  BMPGETBTN(oNMSETCHEQUE:oCodBco)



RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  
  IF Empty(oNMSETCHEQUE:cCodBco)
     oNMSETCHEQUE:oCodBco:MsgErr("Requiere Código del Banco")
     oNMSETCHEQUE:oCodBco:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  oNMSETCHEQUE:oBrw:aArrayData[oNMSETCHEQUE:oBrw:nArrayAt,4]:=oNMSETCHEQUE:cCodBco
  oNMSETCHEQUE:oBrw:aArrayData[oNMSETCHEQUE:oBrw:nArrayAt,5]:=ALLTRIM(oNMSETCHEQUE:oBcoNombre:GetText())
  oNMSETCHEQUE:oBrw:aArrayData[oNMSETCHEQUE:oBrw:nArrayAt,6]:=oNMSETCHEQUE:cCodCta
  oNMSETCHEQUE:oBrw:nColSel:=7

  oNMSETCHEQUE:oBrw:DrawLine(.T.)
  oNMSETCHEQUE:oBrw:aCols[7]:nEditType:=1
  oNMSETCHEQUE:oBrw:aCols[7]:Edit(.T.)

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRNMSETCHEQUE",cWhere)
  oRep:cSql  :=oNMSETCHEQUE:cSql
  oRep:cTitle:=oNMSETCHEQUE:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oNMSETCHEQUE:cWhereQry)
       cWhere:=cWhere + oNMSETCHEQUE:cWhereQry
     ENDIF

     oNMSETCHEQUE:LEERDATA(cWhere,oNMSETCHEQUE:oBrw,oNMSETCHEQUE:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF


   cSql:=" SELECT"+;
          " REC_NUMERO,REC_CODTRA,CONCAT(APELLIDO,',',NOMBRE) AS NOMBRE,REC_CODBCO,BAN_NOMBRE,REC_CTABCO,REC_NUMCHQ,SUM(HIS_MONTO) AS HIS_MONTO "+;
          " FROM NMHISTORICO "+;
          " INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
          " INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
          " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
          " LEFT JOIN NMBANCOS      ON REC_CODBCO=BAN_CODIGO"+;
          " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" REC_FORMAP='C'  AND HIS_CODCON<='DZZZ'"+;
          " GROUP BY REC_NUMERO"+;
          " ORDER BY REC_NUMERO"+;
""
//? CLPCOPY(cSql)

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','',CTOD(""),'',0})
   ENDIF

   // BD en Otro Servidor
   IF !Empty(cServer)
      AEVAL(aData,{|a,n| aData[n,5]:=SQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",a[4]))})
   ENDIF

   IF ValType(oBrw)="O"

      oNMSETCHEQUE:cSql   :=cSql
      oNMSETCHEQUE:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oNMSETCHEQUE:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')

      oNMSETCHEQUE:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oNMSETCHEQUE:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMSETCHEQUE:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMSETCHEQUE.MEM",V_nPeriodo:=oNMSETCHEQUE:nPeriodo
  LOCAL V_dDesde:=oNMSETCHEQUE:dDesde
  LOCAL V_dHasta:=oNMSETCHEQUE:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMSETCHEQUE)
RETURN .T.

/*
// Ejecución Cambio de Linea 
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere

    IF Type("oNMSETCHEQUE")="O" .AND. oNMSETCHEQUE:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oNMSETCHEQUE":cWhere_),"oNMSETCHEQUE":cWhere_,"oNMSETCHEQUE":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oNMSETCHEQUE:LEERDATA(oNMSETCHEQUE:cWhere_,oNMSETCHEQUE:oBrw,oNMSETCHEQUE:cServer)
      oNMSETCHEQUE:oWnd:Show()
      oNMSETCHEQUE:oWnd:Maximize()

    ENDIF

RETURN NIL
/*
// Valida Código del Banco
*/
FUNCTION VALCODBCO()
   LOCAL aCuentas,cCodBco:="",nAt

   cCodBco:=SQLGET("DPBANCOS","BAN_CODIGO,BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oNMSETCHEQUE:cCodBco))

   IF !(ALLTRIM(cCodBco)==ALLTRIM(oNMSETCHEQUE:cCodBco)) .OR. EMPTY(oNMSETCHEQUE:cCodBco)
     oNMSETCHEQUE:oCodBco:KeyBoard(VK_F6)
     RETURN .F.
   ENDIF

   oNMSETCHEQUE:cBcoNombre:=oDp:aRow[2]
   oNMSETCHEQUE:oBcoNombre:Refresh(.T.)

   aCuentas:=ASQL("SELECT BCO_CTABAN FROM DPCTABANCO WHERE BCO_CODIGO"+GetWhere("=",oNMSETCHEQUE:cCodBco))

   IF Empty(aCuentas)
      MensajeErr("Banco no Posee Cuentas Bancarias")
      RETURN .F.
   ENDIF

   AEVAL(aCuentas,{|a,n|aCuentas[n]:=a[1]})

   IF EMPTY(aCuentas)
     oNMSETCHEQUE:aCuentas:={"Ninguna"}
   ENDIF

   nAt:=MAX(ASCAN(oNMSETCHEQUE:oCodCta:aItems,oNMSETCHEQUE:cCodCta),1)

   oNMSETCHEQUE:oCodCta:SetItems(aCuentas)
   oNMSETCHEQUE:oCodCta:ForWhen(.T.)

   oNMSETCHEQUE:oCodCta:Set(aCuentas[nAt])
   oNMSETCHEQUE:oCodCta:Select(nAt)
   oNMSETCHEQUE:oCodCta:Refresh(.T.)
   oNMSETCHEQUE:oCodCta:ForWhen(.T.)
   oNMSETCHEQUE:cCodCta:=aCuentas[nAt]

   COMBOINI(oNMSETCHEQUE:oCodCta)

   oNMSETCHEQUE:MOBCUENTA()
 
   DPFOCUS(oNMSETCHEQUE:oBrw)

RETURN .T.

/*
// Asignar Cheque y Validar que no esté Repetido
*/
FUNCTION SETCHEQUE(oCol,cCheque)
  LOCAL cWhere,oTable
  LOCAL aLine  :=oNMSETCHEQUE:oBrw:aArrayData[oNMSETCHEQUE:oBrw:nArrayAt]
  LOCAL cNumRec:=aLine[1]
  LOCAL cNombre:=aLine[3]
  LOCAL cCodBco:=aLine[4]
  LOCAL cCtaBco:=aLine[6]
  LOCAL cTipDoc:="CHQ",cNumTra
  LOCAL nMonto :=aLine[8]
  LOCAL cRecCodBco,cRecCtaBco,cRecCheque // Valores del Recibo

  DEFAULT oDp:nDebBanc:=0

  cWhere:="BCO_CODIGO"+GetWhere("=",cCodBco)+" AND "+;
          "BCO_CTABAN"+GetWhere("=",cCtaBco)

  IF Empty(SQLGET("DPCTABANCO","BCO_CTABAN",cWhere))

    oNMSETCHEQUE:oBrw:nColSel:=6
    EJECUTAR("XSCGMSGERR",oNMSETCHEQUE:oBrw,"Cuenta Bancaria no existe en Banco "+cCodBco,cCtaBco)
    oNMSETCHEQUE:oBrw:aArrayData[oNMSETCHEQUE:oBrw:nArrayAt,6]:=oNMSETCHEQUE:cCodCta
    oNMSETCHEQUE:oBrw:DrawLine(.T.)
    RETURN .F.

  ENDIF

  oNMSETCHEQUE:oBrw:aArrayData[oNMSETCHEQUE:oBrw:nArrayAt,7]:=cCheque

  cWhere:="REC_CODSUC"+GetWhere("=",oNMSETCHEQUE:cCodSuc)+" AND "+;
          "REC_NUMERO"+GetWhere("=",aLine[1])


  // Busca los datos Anteriores del Recibo para Modificar la Operacion Bancaria
  cRecCodBco:=SQLGET("NMRECIBOS","REC_CODBCO,REC_CTABCO,REC_NUMCHQ",cWhere,NIL,oNMSETCHEQUE:oDb)
  cRecCtaBco:=DPSQLROW(2,"")
  cRecCheque:=DPSQLROW(3,"")


  SQLUPDATE("NMRECIBOS",{"REC_CODBCO","REC_CTABCO","REC_NUMCHQ"},;              
                        {aLine[4]    ,aLine[6]    ,cCheque     },cWhere,NIL,oNMSETCHEQUE:oDb)

  /*
  // Actualiza los datos del Recibo de Nomina
  */

/*
  cWhere:="MOB_CODSUC"+GetWhere("=",oNMSETCHEQUE:cCodSuc)+" AND "+;
          "MOB_ORIGEN"+GetWhere("=","NOM"               )+" AND "+;
          "MOB_DOCASO"+GetWhere("=",cNumRec             )

? cWhere,"cWhere"
*/

//   cWhere:="MOB_CODSUC"+GetWhere("=",oNMSETCHEQUE:cCodSuc)+" AND "+;
//           "MOB_CODBCO"+GetWhere("=",cCodBco             )+" AND "+;
//           "MOB_CUENTA"+GetWhere("=",cCtaBco             )+" AND "+;
//           "MOB_TIPO  "+GetWhere("=",cTipDoc             )+" AND "+;
//           "MOB_DOCUME"+GetWhere("=",cCheque             )

   cWhere:="MOB_CODSUC"+GetWhere("=",oNMSETCHEQUE:cCodSuc)+" AND "+;
           "MOB_CODBCO"+GetWhere("=",cRecCodBco             )+" AND "+;
           "MOB_CUENTA"+GetWhere("=",cRecCtaBco             )+" AND "+;
           "MOB_TIPO  "+GetWhere("=",cTipDoc               )+" AND "+;
           "MOB_DOCUME"+GetWhere("=",cRecCheque             )


   oTable:=OpenTable("SELECT * FROM DPCTABANCOMOV WHERE "+cWhere,.T.)

   IF oTable:RecCount()=0

       oTable:cWhere:=""

       cWhere:="MOB_CODSUC"+GetWhere("=",oNMSETCHEQUE:cCodSuc)+" AND "+;
               "MOB_CODBCO"+GetWhere("=",cCodBco             )+" AND "+;
               "MOB_CUENTA"+GetWhere("=",cCtaBco             )+" AND "+;
               "MOB_TIPO  "+GetWhere("=",cTipDoc             )


       cNumTra:=SQLINCREMENTAL("DPCTABANCOMOV","MOB_NUMTRA",cWhere)
       oTable:AppendBlank()
       oTable:Replace("MOB_NUMTRA",cNumTra)

   ENDIF

  oTable:Replace("MOB_CODBCO", cCodBco             )
  oTable:Replace("MOB_CUENTA", cCtaBco             )
  oTable:Replace("MOB_CODSUC", oNMSETCHEQUE:cCodSuc)
  oTable:Replace("MOB_TIPO  ", cTipDoc             )
  oTable:Replace("MOB_ACT  " , 1                   )
  oTable:Replace("MOB_DEBCRE", -1                  )
  oTable:Replace("MOB_MONTO ", nMonto              )
  oTable:Replace("MOB_MONNAC", nMonto              )
  oTable:Replace("MOB_ORIGEN", "NOM"               )
//oTable:Replace("MOB_COMPRO", cCompro             )
  oTable:Replace("MOB_IDB"   , PORCEN(nMonto,oDp:nDebBanc))
  oTable:Replace("MOB_DESCRI", cNombre             )
  oTable:Replace("MOB_DOCASO", cNumRec             )
  oTable:Replace("MOB_DOCUME", cCheque             )
  oTable:Replace("MOB_FECHA" , oNMSETCHEQUE:dFecha )
  oTable:Replace("MOB_HORA"  , TIME()              )
  oTable:Replace("MOB_NUMTRA", cNumTra             )
  oTable:Commit(oTable:cWhere)

  oNMSETCHEQUE:oBrw:Drawline(.T.)
  oNMSETCHEQUE:oBrw:keyBoard(VK_DOWN)
               
RETURN NIL

/*
// Aqui valida la Cuenta
*/
FUNCTION MOBCUENTA()

RETURN .T.




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oNMSETCHEQUE)
// EOF
