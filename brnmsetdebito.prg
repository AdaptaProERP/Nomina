// Programa   : BRNMSETDEBITO
// Fecha/Hora : 22/09/2016 23:12:11
// Propósito  : "Asignar Cheques en Recibos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cNumFch)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMDEBITO.MEM",V_nPeriodo:=4,cCodPar
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

   cTitle:="Asignar Débito por Transferencia Bancaria en Recibos "+DTOC(dFecha) +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oNMSETDEB
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRNMSETDEBITO.EDT","oNMSETDEB",.F.)

   oNMSETDEB:CreateWindow(NIL,NIL,NIL,550,850+58)

   oNMSETDEB:cCodSuc  :=cCodSuc
   oNMSETDEB:lMsgBar  :=.F.
   oNMSETDEB:cPeriodo :=aPeriodos[nPeriodo]
   oNMSETDEB:cCodSuc  :=cCodSuc
   oNMSETDEB:nPeriodo :=nPeriodo
   oNMSETDEB:cNombre  :=""
   oNMSETDEB:dDesde   :=dDesde
   oNMSETDEB:cServer  :=cServer
   oNMSETDEB:dHasta   :=dHasta
   oNMSETDEB:cWhere   :=cWhere
   oNMSETDEB:cWhere_  :=cWhere_
   oNMSETDEB:cWhereQry:=""
   oNMSETDEB:cSql     :=oDp:cSql
   oNMSETDEB:oWhere   :=TWHERE():New(oNMSETDEB)
   oNMSETDEB:cCodPar  :=cCodPar // Código del Parámetro
   oNMSETDEB:lWhen    :=.T.
   oNMSETDEB:cTextTit :="" // Texto del Titulo Heredado
   oNMSETDEB:oDb      :=oDp:oDb
   oNMSETDEB:cNumFch  :=cNumFch
   oNMSETDEB:cCodBco  :=SPACE(06)
   oNMSETDEB:cCodCta  :="Ninguna"
   oNMSETDEB:aCuentas :={oNMSETDEB:cCodCta}
   oNMSETDEB:dFecha   :=dFecha
   oNMSETDEB:cNumDeb  :=SPACE(20)
   oNMSETDEB:cTipDoc  :="CRET" // Tipo de Documento

   oNMSETDEB:oBrw:=TXBrowse():New( oNMSETDEB:oDlg )
   oNMSETDEB:oBrw:SetArray( aData, .F. )
   oNMSETDEB:oBrw:SetFont(oFont)

   oNMSETDEB:oBrw:lFooter     := .T.
   oNMSETDEB:oBrw:lHScroll    := .F.
   oNMSETDEB:oBrw:nHeaderLines:= 2
   oNMSETDEB:oBrw:nDataLines  := 1
   oNMSETDEB:oBrw:nFooterLines:= 1

   oNMSETDEB:aData            :=ACLONE(aData)

   AEVAL(oNMSETDEB:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oNMSETDEB:oBrw:aCols[1]
  oCol:cHeader      :='Num.'+CRLF+'Recibo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 56

  oCol:=oNMSETDEB:oBrw:aCols[2]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oNMSETDEB:oBrw:aCols[3]
  oCol:cHeader      :='Nombre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 270

  oCol:=oNMSETDEB:oBrw:aCols[4]
  oCol:cHeader      :='Cód.'+CRLF+"Banco"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 50


  oCol:=oNMSETDEB:oBrw:aCols[5]
  oCol:cHeader      :='Banco'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 150


  oCol:=oNMSETDEB:oBrw:aCols[6]
  oCol:cHeader      :='Cuenta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 150

  oCol:=oNMSETDEB:oBrw:aCols[7]
  oCol:cHeader      :='Número'+CRLF+'Transf.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
//  oCol:bOnPostEdit  :={|oCol,uValue|oNMSETDEB:SETDEBITO(oCol,uValue,7)}


  oCol:=oNMSETDEB:oBrw:aCols[8]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMSETDEB:oBrw:aArrayData ) } 
  oCol:nWidth       := 96
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')

  oCol:=oNMSETDEB:oBrw:aCols[9]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\ledverde.bmp")
  oCol:AddBmpFile("BITMAPS\ledrojo.bmp")
  oCol:bBmpData    := { ||oBrw:=oNMSETDEB:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,9],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
//oCol:bLDClickData:={||oNMSETDEB:SELTODOS()}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oNMSETDEB:SELTODOS()}


  oNMSETDEB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oNMSETDEB:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMSETDEB:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=0,;
                                         {nClrText,iif( oBrw:nArrayAt%2=0,oMdi:nClrPane1,oMdi:nClrPane2 ) } }

  oNMSETDEB:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oNMSETDEB:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oNMSETDEB:oBrw:bLDblClick:={|oBrw|oNMSETDEB:RUNCLICK() }
  oNMSETDEB:oBrw:bKeyDown  :={|nKey|IIF(nKey=13, oNMSETDEB:RUNCLICK(),NIL) }


  oNMSETDEB:oBrw:bChange:={||oNMSETDEB:BRWCHANGE()}
  oNMSETDEB:oBrw:CreateFromCode()

  oNMSETDEB:Activate({||oNMSETDEB:ViewDatBar(oNMSETDEB)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oNMSETDEB)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oNMSETDEB:oDlg
   LOCAL nLin:=0
   LOCAL nWidth:=oNMSETDEB:oBrw:nWidth()

   oNMSETDEB:oBrw:GoBottom(.T.)
   oNMSETDEB:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos

   IF .F. .AND. Empty(oNMSETDEB:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMSETDEB:oBrw,oNMSETDEB:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

  
/*
   IF Empty(oNMSETDEB:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMSETDEBITO")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMSETDEBITO"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMSETDEB:oBrw,"NMSETDEBITO",oNMSETDEB:cSql,oNMSETDEB:nPeriodo,oNMSETDEB:dDesde,oNMSETDEB:dHasta,oNMSETDEB)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMSETDEB:oBtnRun:=oBtn



       oNMSETDEB:oBrw:bLDblClick:={||EVAL(oNMSETDEB:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMSETDEB:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oNMSETDEB:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMSETDEB:oBrw);
          WHEN LEN(oNMSETDEB:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMSETDEB:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMSETDEB)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMSETDEB:oBrw,oNMSETDEB:cTitle,oNMSETDEB:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMSETDEB:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oNMSETDEB:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oNMSETDEB:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMSETDEB:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMSETDEB:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRNMSETDEBITO")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMSETDEB:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMSETDEB:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMSETDEB:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMSETDEB:oBrw:GoTop(),oNMSETDEB:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oNMSETDEB:oBrw:PageDown(),oNMSETDEB:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oNMSETDEB:oBrw:PageUp(),oNMSETDEB:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMSETDEB:oBrw:GoBottom(),oNMSETDEB:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMSETDEB:Close()

  oNMSETDEB:oBrw:SetColor(0,15790320)

  EVAL(oNMSETDEB:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMSETDEB:oBar:=oBar

  // Tiene Cheque Asignado
  IF LEN(oNMSETDEB:oBrw:aArrayData)>0 .AND. !Empty(oNMSETDEB:oBrw:aArrayData[1,7])
    oNMSETDEB:cCodBco:=oNMSETDEB:oBrw:aArrayData[1,4]
  ENDIF


  // Código Bancario
  @ 1,550+60 BMPGET oNMSETDEB:oCodBco VAR oNMSETDEB:cCodBco;
                 VALID oNMSETDEB:VALCODBCO();
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPBANCOS",NIL,"",NIL,NIL,NIL,NIL,NIL,NIL,oNMSETDEB:oCodBco),;
                        oDpLbx:GetValue("BAN_CODIGO",oNMSETDEB:oCodBco)); 
                 SIZE 58,20 OF oBar PIXEL 


  oNMSETDEB:oCodBco:cToolTip:="F6 Catálogo de Bancos"

  oNMSETDEB:oCodBco:bKeyDown:={|nKey| IIF(nKey=13, oNMSETDEB:VALCODBCO(), NIL ) }


  @ 1,610+60 SAY oNMSETDEB:oBcoNombre PROMPT;
             " "+SQLGET("DPBANCOS","BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oNMSETDEB:cCodBco)) UPDATE OF oBar BORDER SIZE 300,20 PIXEL

  //
  // Campo : Cuenta
  // Uso   : Moneda                                  
  //

  @ 22, 610 COMBOBOX oNMSETDEB:oCodCta VAR oNMSETDEB:cCodCta ITEMS oNMSETDEB:aCuentas;
                    VALID oNMSETDEB:MOBCUENTA();
                    WHEN (!EMPTY(oNMSETDEB:cCodBco);
                          .AND.LEN(oNMSETDEB:oCodCta:aItems)>1) OF oBar SIZE 200,10 PIXEL UPDATE


  @ 1,545 SAY " Banco: "  OF oBar BORDER SIZE 60,20 PIXEL RIGHT
  @22,545 SAY " Cuenta: " OF oBar BORDER SIZE 60,20 PIXEL RIGHT
  @23,810 SAY " Num:" OF oBar BORDER SIZE 40,20 PIXEL RIGHT


  /*
  // Código Bancario
  */
  @ 23,550+305 BMPGET oNMSETDEB:oNumDeb VAR oNMSETDEB:cNumDeb;
               VALID oNMSETDEB:VALNUMDEB();
               SIZE 140,20 OF oBar PIXEL 



  ComboIni(oNMSETDEB:oCodCta)

  // Tiene Debito Asignado
  IF LEN(oNMSETDEB:oBrw:aArrayData)>0 .AND. !Empty(oNMSETDEB:oBrw:aArrayData[1,7])
    oNMSETDEB:cCodBco:=oNMSETDEB:oBrw:aArrayData[1,4]
    oNMSETDEB:oCodCta:VarPut(oNMSETDEB:cCodBco,.T.)
    oNMSETDEB:VALCODBCO()
    oNMSETDEB:cCodCta:=oNMSETDEB:oBrw:aArrayData[1,6]
    oNMSETDEB:cNumDeb:=oNMSETDEB:oBrw:aArrayData[1,7]
    oNMSETDEB:oNumDeb:VarPut(oNMSETDEB:cNumDeb,.t.)
  ENDIF

  oNMSETDEB:oCodCta:ForWhen(.T.)

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL lSel:=oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,9]

  IF Empty(oNMSETDEB:cCodBco)
     oNMSETDEB:oCodBco:MsgErr("Requiere Código del Banco")
     oNMSETDEB:oCodBco:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  IF Empty(oNMSETDEB:cNumDeb)
     oNMSETDEB:oNumDeb:MsgErr("Requiere Número de Débito","Mensaje")
     DPFOCUS(oNMSETDEB:oNumDeb)
     RETURN .F.
  ENDIF

  oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,4]:=oNMSETDEB:cCodBco
  oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,5]:=ALLTRIM(oNMSETDEB:oBcoNombre:GetText())
  oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,6]:=oNMSETDEB:cCodCta
  oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,7]:=oNMSETDEB:cNumDeb
  oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,9]:=!lSel

  oNMSETDEB:oBrw:nColSel:=7

  oNMSETDEB:oBrw:DrawLine(.T.)

  IF !ISSQLFIND("DPCTABANCO","BCO_CODIGO"+GetWhere("=",oNMSETDEB:cCodBco)+" AND BCO_CTABAN"+GetWhere("=",oNMSETDEB:cCodCta))
     oNMSETDEB:oCodBco:MsgErr("Cuenta Bancaria no Existe")
     oNMSETDEB:oCodBco:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF


  oNMSETDEB:SETRECDEBITO(oNMSETDEB:oBrw:nArrayAt,!lSel)

//  oNMSETDEB:oBrw:aCols[7]:nEditType:=1
//  oNMSETDEB:oBrw:aCols[7]:Edit(.T.)

RETURN .T.



/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRNMSETDEBITO",cWhere)
  oRep:cSql  :=oNMSETDEB:cSql
  oRep:cTitle:=oNMSETDEB:cTitle

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

     IF !Empty(oNMSETDEB:cWhereQry)
       cWhere:=cWhere + oNMSETDEB:cWhereQry
     ENDIF

     oNMSETDEB:LEERDATA(cWhere,oNMSETDEB:oBrw,oNMSETDEB:cServer)

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
          " REC_NUMERO,REC_CODTRA,CONCAT(APELLIDO,',',NOMBRE) AS NOMBRE,REC_CODBCO,BAN_NOMBRE,REC_CTABCO,REC_NUMCHQ,SUM(HIS_MONTO) AS HIS_MONTO,0 AS LOGICO "+;
          " FROM NMHISTORICO "+;
          " INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
          " INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
          " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
          " LEFT JOIN DPBANCOS      ON REC_CODBCO=BAN_CODIGO"+;
          " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" REC_FORMAP='T'  AND HIS_CODCON<='DZZZ'"+;
          " GROUP BY REC_NUMERO"+;
          " ORDER BY REC_NUMERO"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   aData:=ASQL(cSql,oDb)

   AEVAL(aData,{|a,n| aData[n,9]:=!Empty(a[7]) })

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

      oNMSETDEB:cSql   :=cSql
      oNMSETDEB:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oNMSETDEB:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')

      oNMSETDEB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oNMSETDEB:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMSETDEB:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMSETDEBITO.MEM",V_nPeriodo:=oNMSETDEB:nPeriodo
  LOCAL V_dDesde:=oNMSETDEB:dDesde
  LOCAL V_dHasta:=oNMSETDEB:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMSETDEB)
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


    IF Type("oNMSETDEB")="O" .AND. oNMSETDEB:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oNMSETDEB":cWhere_),"oNMSETDEB":cWhere_,"oNMSETDEB":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oNMSETDEB:LEERDATA(oNMSETDEB:cWhere_,oNMSETDEB:oBrw,oNMSETDEB:cServer)
      oNMSETDEB:oWnd:Show()
      oNMSETDEB:oWnd:Maximize()

    ENDIF

RETURN NIL
/*
// Valida Código del Banco
*/
FUNCTION VALCODBCO()
   LOCAL aCuentas,cCodBco:="",nAt

   cCodBco:=SQLGET("DPBANCOS","BAN_CODIGO,BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oNMSETDEB:cCodBco))

   IF !(ALLTRIM(cCodBco)==ALLTRIM(oNMSETDEB:cCodBco)) .OR. EMPTY(oNMSETDEB:cCodBco)
     oNMSETDEB:oCodBco:KeyBoard(VK_F6)
     RETURN .F.
   ENDIF

   oNMSETDEB:cBcoNombre:=oDp:aRow[2]
   oNMSETDEB:oBcoNombre:Refresh(.T.)

   aCuentas:=ASQL("SELECT BCO_CTABAN FROM DPCTABANCO WHERE BCO_CODIGO"+GetWhere("=",oNMSETDEB:cCodBco))

   IF Empty(aCuentas)
      MensajeErr("Banco no Posee Cuentas Bancarias")
      RETURN .F.
   ENDIF

   AEVAL(aCuentas,{|a,n|aCuentas[n]:=a[1]})

   IF EMPTY(aCuentas)
     oNMSETDEB:aCuentas:={"Ninguna"}
   ENDIF

   nAt:=MAX(ASCAN(oNMSETDEB:oCodCta:aItems,oNMSETDEB:cCodCta),1)

   oNMSETDEB:oCodCta:SetItems(aCuentas)
   oNMSETDEB:oCodCta:ForWhen(.T.)

   oNMSETDEB:oCodCta:Set(aCuentas[nAt])
   oNMSETDEB:oCodCta:Select(nAt)
   oNMSETDEB:oCodCta:Refresh(.T.)
   oNMSETDEB:oCodCta:ForWhen(.T.)
   oNMSETDEB:cCodCta:=aCuentas[nAt]

   COMBOINI(oNMSETDEB:oCodCta)

   oNMSETDEB:MOBCUENTA()
 
   DPFOCUS(oNMSETDEB:oBrw)

RETURN .T.

/*
// Asignar Cheque y Validar que no esté Repetido
*/
FUNCTION SETRECDEBITO(I,lSel,lSaveBco)
  LOCAL cWhere,oTable
  LOCAL aLine  :=oNMSETDEB:oBrw:aArrayData[I]
  LOCAL cNumRec:=aLine[1]
  LOCAL cNombre:=aLine[3]
  LOCAL cCodBco:=aLine[4]
  LOCAL cCtaBco:=aLine[6]
  LOCAL nMonto :=aLine[8]

  DEFAULT oDp:nDebBanc:=0,;
          lSaveBco    :=.T.

//oNMSETDEB:oBrw:aArrayData[oNMSETDEB:oBrw:nArrayAt,7]:=cCheque

  cWhere:="REC_CODSUC"+GetWhere("=",oNMSETDEB:cCodSuc)+" AND "+;
          "REC_NUMERO"+GetWhere("=",aLine[1])

  IF lSel

    SQLUPDATE("NMRECIBOS",{"REC_CODBCO","REC_CTABCO","REC_NUMCHQ"      ,"REC_TIPDOC"},;              
                          {aLine[4]    ,aLine[6]    ,oNMSETDEB:cNumDeb ,oNMSETDEB:cTipDoc},cWhere,NIL,oNMSETDEB:oDb)
  ELSE

    SQLUPDATE("NMRECIBOS",{"REC_CODBCO","REC_CTABCO","REC_NUMCHQ","REC_TIPDOC"},;              
                          {""          ,""          ,""          ,""          },cWhere,NIL,oNMSETDEB:oDb)

  ENDIF

  IF lSaveBco 
     oNMSETDEB:SETDEBITOBCO()
  ENDIF


RETURN .T.

/*
// Aqui valida la Cuenta
*/
FUNCTION MOBCUENTA()
RETURN .T.

FUNCTION VALNUMDEB()
RETURN .T.

FUNCTION SELTODOS()
  LOCAL I:=1
  LOCAL lSel:=oNMSETDEB:oBrw:aArrayData[I,9]

  IF Empty(oNMSETDEB:cCodBco)
     oNMSETDEB:oCodBco:MsgErr("Requiere Código del Banco")
     oNMSETDEB:oCodBco:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF

  IF Empty(oNMSETDEB:cNumDeb)
     oNMSETDEB:oNumDeb:MsgErr("Requiere Número de Débito","Mensaje")
     DPFOCUS(oNMSETDEB:oNumDeb)
     RETURN .F.
  ENDIF

  IF !ISSQLFIND("DPCTABANCO","BCO_CODIGO"+GetWhere("=",oNMSETDEB:cCodBco)+" AND BCO_CTABAN"+GetWhere("=",oNMSETDEB:cCodCta))
     oNMSETDEB:oCodBco:MsgErr("Cuenta Bancaria no Existe")
     oNMSETDEB:oCodBco:KeyBoard(VK_F6)
     RETURN .F.
  ENDIF


  FOR I=1 TO LEN(oNMSETDEB:oBrw:aArrayData)

     oNMSETDEB:oBrw:aArrayData[I,4]:=oNMSETDEB:cCodBco
     oNMSETDEB:oBrw:aArrayData[I,5]:=ALLTRIM(oNMSETDEB:oBcoNombre:GetText())
     oNMSETDEB:oBrw:aArrayData[I,6]:=oNMSETDEB:cCodCta
     oNMSETDEB:oBrw:aArrayData[I,7]:=IF(lSel,"",oNMSETDEB:cNumDeb)
     oNMSETDEB:oBrw:aArrayData[I,9]:=!lSel

     oNMSETDEB:SETRECDEBITO(I,!lSel,.F.)

  NEXT I

  oNMSETDEB:oBrw:Refresh(.T.)

  oNMSETDEB:SETDEBITOBCO()

RETURN .T.

/*
// Todos los Recibos vinculados con Una Transferencia, sólo puede realizar un registro en la tabla de Movimiento Bancarios
// El registro que vincula el recibo con la tranferencia es REC_FCHNUM, 
// En un registro NMFECHA FCH_NUMERO puede vincular con Varias Transferencias vinculadas con varios Recibo, el Monto de la Transferencia
// es la suma de todos los recibos vinculados.
*/

FUNCTION SETDEBITOBCO()

   LOCAL oTable:={},cWhere:=oNMSETDEB:cWhere,cSql,cTipDoc:=oNMSETDEB:cTipDoc,cNumTra,oBcoMov

   cSql:=" SELECT"+;
         " REC_CODBCO,REC_CTABCO,REC_NUMCHQ,SUM(HIS_MONTO) AS REC_MONTO "+;
         " FROM NMHISTORICO "+;
         " INNER JOIN NMRECIBOS    ON HIS_CODSUC=REC_CODSUC AND HIS_NUMREC=REC_NUMERO "+;
         " INNER JOIN NMFECHAS     ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO "+;
         " LEFT  JOIN NMBANCOS      ON REC_CODBCO=BAN_CODIGO"+;
         " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" REC_FORMAP='T'  AND HIS_CODCON<='DZZZ' "+;
         "   AND REC_NUMCHQ"+GetWhere("<>","")+;
         "   AND REC_TIPDOC"+GetWhere("=" ,cTipDoc)+;
         " GROUP BY REC_CODBCO,REC_CTABCO,REC_NUMCHQ"+;
         " ORDER BY REC_CODBCO,REC_CTABCO,REC_NUMCHQ"

//? CLPCOPY(cSql)

     /*
     // Inactiva todos las transferencias Bancarias vinculadas con Numero de registro de fecha de Nómina
     */
     cWhere:="MOB_CODSUC"+GetWhere("=",oNMSETDEB:cCodSuc)+" AND "+;
             "MOB_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
             "MOB_ORIGEN"+GetWhere("=","NOM"            )+" AND "+;
             "MOB_DOCASO"+GetWhere("=",oNMSETDEB:cNumFch)

     SQLUPDATE("DPCTABANCOMOV","MOB_ACT",0,cWhere)

     oTable:=OpenTable(cSql,.t.)

     WHILE !oTable:Eof()

      cWhere:="MOB_CODSUC"+GetWhere("=",oNMSETDEB:cCodSuc)+" AND "+;
              "MOB_CODBCO"+GetWhere("=",oTable:REC_CODBCO)+" AND "+;
              "MOB_CUENTA"+GetWhere("=",oTable:REC_CTABCO)+" AND "+;
              "MOB_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
              "MOB_DOCUME"+GetWhere("=",oTable:REC_NUMCHQ)

      oBcoMov:=OpenTable("SELECT * FROM DPCTABANCOMOV WHERE "+cWhere,.T.)

      IF oBcoMov:RecCount()=0

         oTable:cWhere:=""

         cWhere:="MOB_CODSUC"+GetWhere("=",oNMSETDEB:cCodSuc   )+" AND "+;
                 "MOB_CODBCO"+GetWhere("=",oTable:REC_CODBCO   )+" AND "+;
                 "MOB_CUENTA"+GetWhere("=",oTable:REC_CTABCO   )+" AND "+;
                 "MOB_TIPO  "+GetWhere("=",cTipDoc             )


         cNumTra:=SQLINCREMENTAL("DPCTABANCOMOV","MOB_NUMTRA",cWhere)
         oTable:AppendBlank()
         oBcoMov:Replace("MOB_NUMTRA",cNumTra)

      ENDIF

      oBcoMov:Replace("MOB_CODBCO", oTable:REC_CODBCO   )
      oBcoMov:Replace("MOB_CUENTA", oTable:REC_CTABCO   )
      oBcoMov:Replace("MOB_CODSUC", oNMSETDEB:cCodSuc   )
      oBcoMov:Replace("MOB_TIPO  ", cTipDoc             )
      oBcoMov:Replace("MOB_ACT  " , 1                   )
      oBcoMov:Replace("MOB_DEBCRE", -1                  )
      oBcoMov:Replace("MOB_MONTO ", oTable:REC_MONTO    )
      oBcoMov:Replace("MOB_MONNAC", oTable:REC_MONTO    )
      oBcoMov:Replace("MOB_ORIGEN", "NOM"               )
      oBcoMov:Replace("MOB_IDB"   , PORCEN(oTable:REC_MONTO,oDp:nDebBanc))
      oBcoMov:Replace("MOB_DESCRI", "Nómina Número "+oNMSETDEB:cNumFch )
      oBcoMov:Replace("MOB_DOCUME", oTable:REC_NUMCHQ   )   // Numero de Transferencia
      oBcoMov:Replace("MOB_DOCASO", oNMSETDEB:cNumFch   )
      oBcoMov:Replace("MOB_FECHA" , oNMSETDEB:dFecha    )
      oBcoMov:Replace("MOB_HORA"  , TIME()              )
      oBcoMov:Replace("MOB_NUMTRA", cNumTra             )
      oBcoMov:Commit(oBcoMov:cWhere)

      oBcoMov:End()

      oTable:DbSkip()

    ENDDO

    oTable:End()

RETURN .T.



 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oNMSETDEB)
// EOF