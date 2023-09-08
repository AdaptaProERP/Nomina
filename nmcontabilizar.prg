// Programa   : NMCONTABILIZAR
// Fecha/Hora : 16/02/2004 16:39:12
// Propósito  : Seleccionar Periodos Contables
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Nómina
// Tabla      : NMFECHAS
#INCLUDE "INCLUDE\DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
  LOCAL oTable,aData,nCuantos:=0
  LOCAL aProgram:={},I,oFontBrw,oBrw,oCol,cSql,nAt,cTitle
  LOCAL oClaXCon,aAplica:={},cTipos:="SQMO",aCuantos:={},aTotal
  LOCAL oDb
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )
  LOCAL cFileMem:="USER\NMCONTABILIZAR.MEM",V_nPeriodo:=4,cCodPar,aFechas
  LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
  LOCAL cServer:=oDp:cRunServer,lConectar:=.F.
  LOCAL cWhere_:=NIL
  
  CursorWait()

  IF Type("oSelNmCont")="O" .AND. oSelNmCont:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oSelNmCont,GetScript())
  ENDIF

  DEFAULT oDp:Nm_cContab:=NIL

  IF Empty(oDp:cNmContab) 
     EJECUTAR("NMRESTDATA")
  ENDIF

IF oDp:cType="SGE"

  oDp:cContab:=oDp:Nm_cContab

  IF Empty(oDp:cContab) 
     MensajeErr("No está definida Integración Nómina")
     EJECUTAR("NMDEFINEINT")
     RETURN .T.
  ENDIF



  IF !EJECUTAR("TABLASNOMINA")
     RETURN .F.
  ENDIF
  
  IF oDp:Nm_nForma=3 .AND. !EJECUTAR("DPSERVERDBOPEN",oDp:Nm_cServer)
      RETURN .F.
  ENDIF

ENDIF

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


  oDb:=oDp:oDb

  cSql:="SELECT TIPO_NOM FROM NMTRABAJADOR NMTRABAJADOR "+;
        "INNER JOIN NMRECIBOS ON CODIGO=REC_CODTRA "+;
        "GROUP BY TIPO_NOM "

  aCuantos:=aTable(cSql,.t.,oDb)

  FOR I=1 TO LEN(cTipos)
      nAt:=ASCAN(aCuantos,{|a|a=SUBS(cTipos,I,1)})
      IF nAt>0
         AADD(aAplica,aCuantos[nAt])
      ENDIF
  NEXT I

  AEVAL(aAplica,{|a,n|aAplica[n]:=SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",a)})

  AADD(aAplica," Todos")
  AADD(aAplica," Mostrar sólo los Seleccionados")

  IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   cWhere_  :=HACERWHERE(dDesde,dHasta,cWhere)

   aProgram:=LEERDATA(cWhere_)

   IF Empty(aProgram)
      MensajeErr("No Periodos de Nómina  para Contabilizar")
      RETURN .T.
   ENDIF

   AEVAL(aProgram,{|a,n|nCuantos:=nCuantos+IIF(a[14],1,0)})


   DEFINE FONT oFontBrw NAME "Tahoma" SIZE 0,-11 BOLD

//
//  DPEDIT():New("Seleccionar Periodos para Contabilizar por ["+oDp:cContab+"]" ,"NMSELCONT.EDT","oSelNmCont",.T.)
//

  cTitle:="Seleccionar Periodos para Contabilizar por ["+oDp:cContab+"]"
  DpMdi(cTitle,"oSelNmCont","BRDOCPROVIEW.EDT")

  oSelNmCont:Windows(0,0,aCoors[3]-160,MIN(980+90+20+20+155,aCoors[4]-10),.T.) // Maximizado

  oSelNmCont:cModulo :=" Todos"
  oSelNmCont:aTodos  :=ACLONE(aProgram)  // Todos los Programas
  oSelNmCont:nCuantos:=nCuantos
  oSelNmCont:cFileChm:="CAPITULO2.CHM"

  oSelNmCont:cPeriodo :=aPeriodos[nPeriodo]
  oSelNmCont:cCodSuc  :=cCodSuc
  oSelNmCont:nPeriodo :=nPeriodo
  oSelNmCont:cNombre  :=""
  oSelNmCont:dDesde   :=dDesde
  oSelNmCont:cServer  :=cServer
  oSelNmCont:dHasta   :=dHasta
  oSelNmCont:cWhere   :=cWhere
  oSelNmCont:cWhere_  :=cWhere_
  oSelNmCont:cWhereQry:=""
  oSelNmCont:cSql     :=oDp:cSql
  oSelNmCont:oWhere   :=TWHERE():New(oSelNmCont)
  oSelNmCont:cCodPar  :=cCodPar // Código del Parámetro
  oSelNmCont:lWhen    :=.T.
  oSelNmCont:cTextTit :="" // Texto del Titulo Heredado
  oSelNmCont:oDb      :=oDp:oDb
  oSelNmCont:cBrwCod  :="REGCXPDEBPAT"
  oSelNmCont:lTmdi    :=.T.
  oSelNmCont:aHead    :={}
 

  oSelNmCont:nClrText :=0
  oSelNmCont:nClrText1:=4144959

  aData:=COPYMODULO(oSelNmCont,oSelNmCont:cModulo,.F.)

  aTotal:=ATOTALES(aData)

//  @ 1,12 COMBOBOX oSelNmCont:oModulo VAR oSelNmCont:cModulo ITEMS aAplica;
//         ON CHANGE oSelNmCont:PRGCHANGE(oSelNmCont)

  oSelNmCont:cModulo:=" Todos"
//  COMBOINI(oSelNmCont:oModulo)

  oSelNmCont:oBrw:=TXBrowse():New( oSelNmCont:oWnd )
  oSelNmCont:oBrw:SetArray( aData )

  oBrw:=oSelNmCont:oBrw
  oBrw:SetFont(oFontBrw)

//  oBrw:lFastEdit   := .T.
  oBrw:lHScroll    := .T.
  oBrw:nFreeze     := 3
  oBrw:nHeaderLines:= 2
  oBrw:lFooter     := .T.

  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "Número"
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Desde"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oCol:=oBrw:aCols[3]
  oCol:cHeader   := "Hasta"
  oCol:nWidth       := 80
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oCol:=oBrw:aCols[4]
  oCol:cHeader      := "Nómina"
  oCol:nWidth       := 70
  oCol:bLDClickData :={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oCol:=oBrw:aCols[5]
  oCol:cHeader      := "Cód."
  oCol:nWidth       := 22
  oCol:bLDClickData :={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }


  oCol:=oBrw:aCols[6]
  oCol:cHeader       := "Otra"+CRLF+"Nómina"
  oCol:nWidth        := 180
  oCol:bLDClickData  :={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }


  oCol:=oBrw:aCols[7]
  oCol:cHeader      := "#"+CRLF+"Rec."
  oCol:nWidth       := 34
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }


  oCol:=oBrw:aCols[8]
  oCol:cHeader      := "Efec-"+CRLF+"tivo"
  oCol:nWidth       := 34
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oCol:=oBrw:aCols[09]
  oCol:cHeader      := "Chq."
  oCol:nWidth       := 34
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }


  oCol:=oBrw:aCols[10]
  oCol:cHeader      := "Tran"+CRLF+"Banc."
  oCol:nWidth       := 34
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }


  oCol:=oBrw:aCols[11]
  oCol:cHeader      :='Monto'+CRLF+'Efectivo'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) } 
  oCol:nWidth       := 96+20
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oSelNmCont:oBrw:aArrayData[oSelNmCont:oBrw:nArrayAt,11],FDP(nMonto,'9,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[11],'99,999,999,999.99')

  oCol:=oBrw:aCols[12]
  oCol:cHeader      :='Monto'+CRLF+'Cheque'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) } 
  oCol:nWidth       := 96+20
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oSelNmCont:oBrw:aArrayData[oSelNmCont:oBrw:nArrayAt,12],FDP(nMonto,'9,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[12],'9,999,999,999.99')

  oCol:=oBrw:aCols[13]
  oCol:cHeader      :='Monto'+CRLF+'Transferencia'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) } 
  oCol:nWidth       := 96+30
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oSelNmCont:oBrw:aArrayData[oSelNmCont:oBrw:nArrayAt,13],FDP(nMonto,'9,999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[13],'999,999,999,999.99')

  oCol:=oBrw:aCols[14]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bBmpData    := { ||oBrw:=oSelNmCont:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,14],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oSelNmCont:PrgSelect(oSelNmCont)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oSelNmCont:SELTODOS(oSelNmCont,nRow,nCol,nKey,oCol,.T.)}


  oCol:=oBrw:aCols[15]
  oCol:cHeader   := "Estado"
  oCol:nWidth    := 65
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oCol:=oBrw:aCols[16]
  oCol:cHeader   := "Conta"+CRLF+"biliz."
  oCol:nWidth    := 45
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oCol:=oBrw:aCols[17]
  oCol:cHeader   := "Cbte"+CRLF+"Contable"
  oCol:nWidth    := 65
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oSelNmCont:oBrw:aArrayData ) }

  oBrw:bClrStd   := {|oBrw|oBrw:=oSelNmCont:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,14], oSelNmCont:nClrText,oSelNmCont:nClrText1),;
                                                   iif( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2  ) } }



//  oBrw:bClrSel   := {|oBrw|oBrw:=oSelNmCont:oBrw, { 65535,  16733011}}

  oBrw:bClrHeader  := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter  := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oSelNmCont:oBrw:CreateFromCode()

  oSelNmCont:bValid   :={|| EJECUTAR("BRWSAVEPAR",oSelNmCont)}
  oSelNmCont:BRWRESTOREPAR()

//oBrw:bClrHeader := {|| { 0,  12632256}}

  oSelNmCont:oWnd:oClient := oSelNmCont:oBrw

  oSelNmCont:oFocus:=oBrw

  oSelNmCont:Activate({||oSelNmCont:NMCONBAR(oSelNmCont)})

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION NMCONBAR(oSelNmCont)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif,nLin:=0,nCol:=0
   LOCAL nWidth   :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight  :=0 // Alto
   LOCAL nLines   :=0 // Lineas
   LOCAL oDlg     :=oSelNmCont:oDlg
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
  
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15+45 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont NAME "Tahoma" SIZE 0,-11 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oSelNmCont:exportmov(1)

   oBtn:cToolTip:="Iniciar Generación de Asientos Contables"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CHEQUE.BMP";
          ACTION oSelNmCont:ASIGNACHEQUE()

   oBtn:cToolTip:="Asignación de Cheques"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\DEBITO.BMP";
          ACTION oSelNmCont:ASIGNADEBITO()

   oBtn:cToolTip:="Asignación de Débito Bancario"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\movimientocaja.bmp";
          ACTION oSelNmCont:ASIGNAEFECTIVO()

   oBtn:cToolTip:="Asignación de Efectivo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\SELECT.BMP";
          ACTION oSelNmCont:SelectAll(oSelNmCont)

   oBtn:cToolTip:="Seleccionar Todas las Fechas"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CALENDAR.BMP";
          ACTION oSelNmCont:SelFecha(oSelNmCont)


   oSelNmCont:oBtnBrw:=oBtn
   oBtn:cToolTip     :="Seleccionar Fecha de Tablas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oSelNmCont:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oSelNmCont:oBrw);
          WHEN LEN(oSelNmCont:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oSelNmCont:oBrw)

  oBtn:cToolTip:="Buscar Programa"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xTOP.BMP";
         ACTION (oSelNmCont:oBrw:GoTop(),oSelNmCont:oBrw:Setfocus())

  oBtn:cToolTip:="Primer Periodo de la Lista"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xSIG.BMP";
         ACTION (oSelNmCont:oBrw:PageDown(),oSelNmCont:oBrw:Setfocus())

  oBtn:cToolTip:="Siguiente Periodo"

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xANT.BMP";
         ACTION (oSelNmCont:oBrw:PageUp(),oSelNmCont:oBrw:Setfocus())

  oBtn:cToolTip:="Periodo Anterior"


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\xFIN.BMP";
         ACTION (oSelNmCont:oBrw:GoBottom(),oSelNmCont:oBrw:Setfocus())

   oBtn:cToolTip:="Ultimo Periodo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oSelNmCont:Close()

   oBtn:cToolTip:="Cerrar Formulario"

   AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip})

   Aeval(oSelNmCont:oBrw:aArrayData,{|a,n| oSelNmCont:oBrw:aArrayData[n,14]:=(n=1)})

   oSelNmCont:oBrw:SetColor(0,oSelNmCont:nClrPane1)

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   oSelNmCont:SETBTNBAR(40,40,oBar)

   // Controles se Inician luego del Ultimo Boton
   nCol:=32
   AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })


  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oSelNmCont:oPeriodo  VAR oSelNmCont:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oSelNmCont:LEEFECHAS();
                WHEN oSelNmCont:lWhen


  ComboIni(oSelNmCont:oPeriodo )

  @ nLin, nCol+103 BUTTON oSelNmCont:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oSelNmCont:oPeriodo:nAt,oSelNmCont:oDesde,oSelNmCont:oHasta,-1),;
                         EVAL(oSelNmCont:oBtn:bAction));
                WHEN oSelNmCont:lWhen


  @ nLin, nCol+130 BUTTON oSelNmCont:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oSelNmCont:oPeriodo:nAt,oSelNmCont:oDesde,oSelNmCont:oHasta,+1),;
                         EVAL(oSelNmCont:oBtn:bAction));
                WHEN oSelNmCont:lWhen


  @ nLin, nCol+160 BMPGET oSelNmCont:oDesde  VAR oSelNmCont:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oSelNmCont:oDesde ,oSelNmCont:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oSelNmCont:oPeriodo:nAt=LEN(oSelNmCont:oPeriodo:aItems) .AND. oSelNmCont:lWhen ;
                FONT oFont

   oSelNmCont:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oSelNmCont:oHasta  VAR oSelNmCont:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oSelNmCont:oHasta,oSelNmCont:dHasta);
                SIZE 76-2,24;
                WHEN oSelNmCont:oPeriodo:nAt=LEN(oSelNmCont:oPeriodo:aItems) .AND. oSelNmCont:lWhen ;
                OF oBar;
                FONT oFont

   oSelNmCont:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oSelNmCont:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oSelNmCont:oPeriodo:nAt=LEN(oSelNmCont:oPeriodo:aItems);
               ACTION oSelNmCont:HACERWHERE(oSelNmCont:dDesde,oSelNmCont:dHasta,oSelNmCont:cWhere,.T.);
               WHEN oSelNmCont:lWhen

   BMPGETBTN(oBar,oFont,13)
   AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

   DEFINE FONT oFont NAME "Tahoma" SIZE 0,-12 BOLD

   @ 45,15 SAY oSelNmCont:oCuantos PROMPT " Seleccionados "+STRZERO(oSelNmCont:nCuantos,4)+"/"+;
               STRZERO(LEN(oSelNmCont:aTodos),4);
               OF oBar BORDER SIZE 212,21 UPDATE PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont

   @ 67,15 COMBOBOX oSelNmCont:oModulo VAR oSelNmCont:cModulo ITEMS aAplica;
           ON CHANGE oSelNmCont:PRGCHANGE(oSelNmCont) OF oBar  PIXEL SIZE 212,20 FONT oFont

   COMBOINI(oSelNmCont:oModulo)

  @ 45,230-2 SAY " Destino " OF oBar;
             BORDER SIZE 130,21 UPDATE PIXEL COLOR oDp:nClrYellowText,oDp:nClrYellow  FONT oFont

  @ 67,230-2 SAY IF(oDp:cNmContab="P"," Cuentas por Pagar "," Contabilidad ") OF oBar;
             BORDER SIZE 130,21 UPDATE PIXEL COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

RETURN .T.

/*
// Seleccionar Concepto
*/
FUNCTION PrgSelect(oSelNmCont)
  LOCAL oBrw:=oSelNmCont:oBrw
  LOCAL nArrayAt,nRowSel,nAt:=0,nCuantos:=0
  LOCAL lSelect
  LOCAL nCol:=14
  LOCAL lSelect

  IF ValType(oBrw)!="O"
     RETURN .F.
  ENDIF

  nArrayAt:=oBrw:nArrayAt
  nRowSel :=oBrw:nRowSel
  lSelect :=oBrw:aArrayData[nArrayAt,nCol]

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=!lSelect
  oBrw:RefreshCurrent()

  // Busca en la Lista General)
  nAt:=ASCAN(oSelNmCont:aTodos,{|a,n|a[1]=oBrw:aArrayData[oBrw:nArrayAt,1]})

  IF nAt>0
    oSelNmCont:aTodos[nAt,14]:=!lSelect
  ENDIF

  AEVAL(oSelNmCont:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[14],1,0)})
  oSelNmCont:nCuantos:=nCuantos
  oSelNmCont:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Exportar Programas
*/
FUNCTION exportmov(nOption)
  LOCAL aSelect:={},cSql,oData
  LOCAL cTitle:=""

  DEFAULT nOption:=1

  AEVAL(oSelNmCont:aTodos,{|a,n| IIF(a[14],AADD(aSelect,a[1]),NIL)})

  oSelNmCont:aSelect:=aSelect
  oSelNmCont:cWhere :=GetWhereOr("FCH_NUMERO",aSelect)

  cTitle:=" ["+ATAIL(aSelect)+"-"+aSelect[1]+"]"  

  cSql:="SELECT * FROM NMFECHAS WHERE "+oSelNmCont:cWhere

  IF EMPTY(aSelect) 
     MensajeErr("No hay Periodos Seleccionados")
     RETURN .F.
  ENDIF

  // Genera los Asientos Contables

  IF nOption=1 .AND. "Concepto"$oDp:Nm_cContab
     EJECUTAR("BRNMRESXCON",oSelNmCont:cWhere,NIL,NIL,NIL,NIL,cTitle) 
  ENDIF

  IF nOption=2
     EJECUTAR("BRNMSETCHEQUE",oSelNmCont:cWhere,NIL,NIL,NIL,NIL,cTitle)
  ENDIF

RETURN NIL

/*
// Iniciar Exportar Tablas
*/
FUNCTION EXPORTRUN(oEdit)

   ? "EXPORTRUN"

RETURN .T.

/*
// Cambiar Modulo
*/
FUNCTION PRGCHANGE(oSelNmCont)
  LOCAL aData,I

  IF UPPE(LEFT(ALLTRIM(oSelNmCont:cModulo),1))="T"
     aData:=ACLONE(oSelNmCont:aTodos)
  ELSE
     aData:=oSelNmCont:COPYMODULO(oSelNmCont,LEFT(ALLTRIM(oSelNmCont:cModulo),2),.T.)
  ENDIF

  oSelNmCont:oBrw:aArrayData:=ACLONE(aData)
  oSelNmCont:oBrw:nArrayAt  :=MIN(LEN(oSelNmCont:oBrw:aArrayData),oSelNmCont:oBrw:nArrayAt)

  oSelNmCont:oBrw:GoTop()
  oSelNmCont:oBrw:Refresh(.T.)

  DpFocus(oSelNmCont:oBrw)

RETURN .T.

FUNCTION COPYMODULO(oSelNmCont,cModulo,lShow)
   LOCAL aData:={},I,nCol:=4

   cModulo:=UPPE(cModulo)

   IF ALLTRIM(cModulo)="TO" 
      cModulo:=.T.
      nCol   :=6
   ELSE
      cModulo:=Left(cModulo,2)
   ENDIF

//   IF lShow
//     ? cModulo,LEN(cModulo),oSelNmCont:aTodos[1,nCol]
//   ENDIF

   IF ALLTRIM(Left(cModulo,2))="MO" // Solo los Seleccionados
     nCol=0
//     IF lShow
//       ? "nCol",nCol
//     ENDIF
   ENDIF
  
   FOR I=1 TO LEN(oSelNmCont:aTodos)

//   ? Left(ALLTRIM(oSelNmCont:aTodos[I,nCol]),2),cModulo

     IF nCol>0 .AND. (nCol=6 .OR. UPPE(Left(ALLTRIM(oSelNmCont:aTodos[I,nCol]),2))=cModulo)
        AADD(aData,oSelNmCont:aTodos[I])  
     ENDIF

     IF nCol=0 .AND. oSelNmCont:aTodos[I,14]
        AADD(aData,oSelNmCont:aTodos[I])  
     ENDIF

   NEXT I

   IF EMPTY(aData) 
      aData:={}
      AADD(aData,{"",CTOD(""),CTOD(""),"","","Ninguno",7,8,9,10,11,12,13,.F.})
   ENDIF

RETURN aData

/*
// Seleccionar Todos los Programas de la Lista
*/
FUNCTION SelectAll(oSelNmCont)
   LOCAL I,cModulo,nCol:=4,nCuantos:=0,lSelect:=.T.

   cModulo:=Left(ALLTRIM(oSelNmCont:cModulo),2)

// ? oSelNmCont:oBrw:aArrayData[1,14]

   lSelect:=!oSelNmCont:oBrw:aArrayData[1,14]

// ? lSelect,"lSelect"

   FOR I=1 TO LEN(oSelNmCont:aTodos)
     IF oSelNmCont:aTodos[I,nCol]=cModulo .OR. cModulo="TO"
       oSelNmCont:aTodos[I,14]:=lSelect
     ENDIF
   NEXT I

   FOR I=1 TO LEN(oSelNmCont:oBrw:aArrayData)
      oSelNmCont:oBrw:aArrayData[I,14]:=lSelect
   NEXT I
   
  oSelNmCont:oBrw:Refresh(.T.)

  AEVAL(oSelNmCont:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[14],1,0)})
  oSelNmCont:nCuantos:=nCuantos
  oSelNmCont:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Seleccionar Fecha de Programas
*/
FUNCTION SelFecha(oSelNmCont)
  LOCAL dDesde:=FCHINIMES(oDp:dFecha)
  LOCAL dHasta:=FCHFINMES(oDp:dFecha)
  LOCAL oDlg,oDesde,oHasta,oFont
  LOCAL lSalir :=.F.,lOk:=.F.,lAdd:=.T.,I,lSelect:=.T.,nCuantos:=0
  LOCAL oBtnBrw:=oSelNmCont:oBtnBrw
  LOCAL nWidth :=200+100
  LOCAL nHeight:=130+35+15
  LOCAL aPoint :=AdjustWnd( oBtnBrw, nWidth, nHeight )
  LOCAL oWnd   :=oBtn:oWnd

  DEFINE FONT oFont NAME "Tahoma" SIZE 0,-12 BOLD

//  DEFINE DIALOG oDlg TITLE "Rango de Fecha" COLOR 0,oDp:nGris2

  DEFINE DIALOG oDlg;
         TITLE "Rango de Fechas ";
         PIXEL OF oBtnBrw:oWnd;
         STYLE nOr( DS_SYSMODAL, DS_MODALFRAME );
         COLOR NIL,oDp:nGris

  @ .1,.5 SAY "Periodo:";
          SIZE 45,08;
          COLOR CLR_BLACK,oDp:nGris2;
          FONT oFont

  @ 1,.5 BMPGET oDesde VAR dDesde PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         ACTION LbxDate(oDesde,dDesde);
         SIZE 52,NIL FONT oFont

  @ 2,.5 BMPGET oHasta VAR dHasta PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         ACTION LbxDate(oHasta,dHasta);
         SIZE 52,NIL FONT oFont

  @ 3.1,.5 CHECKBOX lAdd PROMPT "Adicionar con los Periodos  Seleccionados";
           SIZE 155,10;
           COLOR CLR_BLACK,oDp:nGris2;
           FONT oFont

  @ 3,08 BUTTON " Iniciar " ACTION (lSalir:=.T.,lOk:=.T.,oDlg:End());
         SIZE 45,NIL FONT oFont

  @ 3,16 BUTTON " Cerrar  " ACTION (lSalir:=.T.,lOk:=.F.,oDlg:End());
         SIZE 45,NIL FONT oFont

/*
  ACTIVATE DIALOG oDlg CENTERED;
           ON INIT (oDlg:SetColor(CLR_BLACK,oDp:nGris2))
*/

  ACTIVATE DIALOG oDlg ON INIT (oDlg:SetColor(CLR_BLACK,oDp:nGris2),;
                                oDlg:Move(aPoint[1], aPoint[2],NIL,NIL,.T.),;
                                oDlg:SetSize(nWidth,nHeight));


  IF lOk

    FOR I=1 TO LEN(oSelNmCont:aTodos)

      IF !lAdd
        oSelNmCont:aTodos[I,14]:=!lSelect
      ENDIF

      IF oSelNmCont:aTodos[I,3]>=dDesde .AND. oSelNmCont:aTodos[I,3]<=dHasta
        oSelNmCont:aTodos[I,14]:=lSelect
      ENDIF

    NEXT I

    FOR I=1 TO LEN(oSelNmCont:oBrw:aArrayData)

       IF !lAdd
          oSelNmCont:oBrw:aArrayData[I,14]:=!lSelect
       ENDIF

       IF oSelNmCont:oBrw:aArrayData[I,3]>=dDesde .AND. oSelNmCont:oBrw:aArrayData[I,3]<=dHasta
          oSelNmCont:oBrw:aArrayData[I,14]:=lSelect
       ENDIF

    NEXT I

    oSelNmCont:oModulo:Select( LEN(oSelNmCont:oModulo:aItems) )
    oSelNmCont:cModulo:="MO"
    oSelNmCont:PRGCHANGE(oSelNmCont)

    oSelNmCont:oBrw:Refresh(.T.)

    AEVAL(oSelNmCont:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[14],1,0)})
    oSelNmCont:nCuantos:=nCuantos
    oSelNmCont:oCuantos:Refresh(.T.)
   
  ENDIF

RETURN .T.

/*
// Selecciona o Desmarca a Todos
*/
FUNCTION SELTODOS(oSelNmCont)
   LOCAL oBrw:=oSelNmCont:oBrw
   LOCAL lSelect:=!oBrw:aArrayData[1,14]

   AEVAL(oBrw:aArrayData,{|a,n|oBrw:aArrayData[n,14]:=lSelect})

   IF LEFT(ALLTRIM(oSelNmCont:cModulo),2)="TO"
      AEVAL(oSelNmCont:aTodos,{|a,n|oSelNmCont:aTodos[n,14]:=lSelect})
   ENDIF

   oSelNmCont:nCuantos:=IIF(lSelect,LEN(oBrw:aArrayData),0)
   oSelNmCont:oCuantos:Refresh(.T.)

   oBrw:Refresh(.T.)

RETURN .T.

/*
// Contabilizar por Concepto
*/
FUNCTION NMXCONCEPTO()
  LOCAL oBrw   :=oSelNmCont:oBrw
  LOCAL cWhere
  LOCAL aNumFch:={} // Lista de las Fechas

  AEVAL(oBrw:aArrayData,{|a,n| IF(a[7],AADD(aNumFch,a[1]),NIL)})

  ViewArray(aNumFch)

  EJECUTAR("BRNMRESXCON")         

RETURN NIL

FUNCTION ASIGNACHEQUE()
  LOCAL oBrw   :=oSelNmCont:oBrw
  LOCAL cNumFch:=oBrw:aArrayData[oBrw:nArrayAt,1]
  LOCAL dDesde :=oBrw:aArrayData[oBrw:nArrayAt,2]
  LOCAL dHasta :=oBrw:aArrayData[oBrw:nArrayAt,3]
  LOCAL cWhere :="FCH_NUMERO"+GetWhere("=",oSelNmCont:oBrw:aArrayData[oBrw:nArrayAt,1])
  LOCAL dFecha :=""
  LOCAL cWhere :="FCH_NUMERO"+GetWhere("=",cNumFch)
  LOCAL cTitle :=" [ Nómina Numero "+cNumFch+" "+DTOC(dDesde)+"-"+DTOC(dHasta)+" ]"
  LOCAL aNumFch:={} // Lista de las Fechas

  IF Empty(oBrw:aArrayData[oBrw:nArrayAt,9])
     oBrw:nColSel:=1
     EJECUTAR("XSCGMSGERR",oBrw,"Nómina "+cNumFch+" No tiene Recibos con Pago: Cheque")
     RETURN .F.
  ENDIF

  EJECUTAR("BRNMSETCHEQUE",cWhere,NIL,NIL,NIL,NIL,cTitle,cNumFch)

RETURN NIL

FUNCTION ASIGNADEBITO()
  LOCAL oBrw   :=oSelNmCont:oBrw
  LOCAL cNumFch:=oBrw:aArrayData[oBrw:nArrayAt,1]
  LOCAL dDesde :=oBrw:aArrayData[oBrw:nArrayAt,2]
  LOCAL dHasta :=oBrw:aArrayData[oBrw:nArrayAt,3]
  LOCAL cWhere :="FCH_NUMERO"+GetWhere("=",oSelNmCont:oBrw:aArrayData[oBrw:nArrayAt,1])
  LOCAL dFecha :=""
  LOCAL cWhere :="FCH_NUMERO"+GetWhere("=",cNumFch)
  LOCAL cTitle :=" [ Nómina Numero "+cNumFch+" "+DTOC(dDesde)+"-"+DTOC(dHasta)+" ]"
  LOCAL aNumFch:={} // Lista de las Fechas

  IF Empty(oBrw:aArrayData[oBrw:nArrayAt,10])
     oBrw:nColSel:=1
     EJECUTAR("XSCGMSGERR",oBrw,"Nómina "+cNumFch+" No tiene Recibos con Pago: Transferencia")
     RETURN .F.
  ENDIF

  EJECUTAR("BRNMSETDEBITO",cWhere,NIL,NIL,NIL,NIL,cTitle,cNumFch)

RETURN NIL

FUNCTION ASIGNAEFECTIVO()
  LOCAL oBrw   :=oSelNmCont:oBrw
  LOCAL cNumFch:=oBrw:aArrayData[oBrw:nArrayAt,1]
  LOCAL dDesde :=oBrw:aArrayData[oBrw:nArrayAt,2]
  LOCAL dHasta :=oBrw:aArrayData[oBrw:nArrayAt,3]
  LOCAL cWhere :="FCH_NUMERO"+GetWhere("=",oSelNmCont:oBrw:aArrayData[oBrw:nArrayAt,1])
  LOCAL dFecha :=""
  LOCAL cWhere :="FCH_NUMERO"+GetWhere("=",cNumFch)
  LOCAL cTitle :=" [ Nómina Numero "+cNumFch+" "+DTOC(dDesde)+"-"+DTOC(dHasta)+" ]"
  LOCAL aNumFch:={} // Lista de las Fechas

  IF Empty(oBrw:aArrayData[oBrw:nArrayAt,8])
     oBrw:nColSel:=1
     EJECUTAR("XSCGMSGERR",oBrw,"Nómina "+cNumFch+" No tiene Recibos con Pago: Efectivo")
     RETURN .F.
  ENDIF

RETURN .T.

FUNCTION LEERDATA(cWhere,oBrw,cServer,oFrm)
 LOCAL aProgram,oTable,oDb:=OpenOdbc(oDp:cDsnData),cSql

 cSql:=" SELECT FCH_NUMERO,FCH_DESDE,FCH_HASTA,FCH_TIPNOM,FCH_OTRNOM,OTR_DESCRI,CRF_CANTID,"+CRLF+;
       " CRF_CANEFE,CRF_CANCHQ,CRF_CANTRA, "+;
       " CRF_MTOEFE,CRF_MTOCHQ,CRF_MTOTRA, "+;
       " 0 AS FCH_MARCAR ,FCH_ESTADO,FCH_CONTAB,FCH_NUMCBT"+;
       " FROM NMFECHAS "+;
       " LEFT  JOIN NMOTRASNM         ON OTR_CODIGO=FCH_OTRNOM "+;
       " INNER JOIN NMRECIBOS         ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
       " INNER JOIN NMHISTORICO       ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
       " LEFT  JOIN VIEW_NMFCHCANTREC ON FCH_CODSUC=CRF_CODSUC AND FCH_NUMERO=CRF_NUMERO "+;                 
       " WHERE FCH_CONTAB<>'S' "+;
       "   AND HIS_CODCON<='DZZZ' "+;
       " GROUP BY FCH_NUMERO "+;
       " ORDER BY FCH_NUMERO DESC"

  IF !Empty(cWhere)
    cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
  ENDIF

  oTable  :=OpenTable(cSql,.T.,oDb)

  WHILE !oTable:Eof()
    oTable:Replace("FCH_MARCAR",.T.)
    oTable:Replace("FCH_TIPNOM",SAYOPTIONS("NMTRABAJADOR","TIPO_NOM"  ,oTable:FCH_TIPNOM))
    oTable:Replace("FCH_ESTADO",SAYOPTIONS("NMFECHAS"    ,"FCH_ESTADO",oTable:FCH_ESTADO))
    oTable:Skip()
  ENDDO

  aProgram:=ACLONE(oTable:aDataFill)

  IF ValType(oBrw)="O"

      oSelNmCont:cSql   :=cSql
      oSelNmCont:cWhere_:=cWhere
      oBrw:aArrayData:=ACLONE(aProgram)

      oBrw:Gotop()
      oBrw:Refresh(.T.)

      EJECUTAR("BRWCALTOTALES",oBrw,.F.)
      oSelNmCont:SAVEPERIODO()

   ENDIF

RETURN aProgram

FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
     cWhere:=GetWhereAnd(HISFECHA(),dDesde,dHasta)
   ELSE

     IF !Empty(dHasta)
       cWhere:=GetWhereAnd(HISFECHA(),dDesde,dHasta)
     ENDIF

   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oSelNmCont:cWhereQry)
       cWhere:=cWhere + oSelNmCont:cWhereQry
     ENDIF

     oSelNmCont:LEERDATA(cWhere,oSelNmCont:oBrw,oSelNmCont:cServer,oSelNmCont)

   ENDIF


RETURN cWhere

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oSelNmCont:oPeriodo:nAt,cWhere

  oSelNmCont:nPeriodo:=nPeriodo


  IF oSelNmCont:oPeriodo:nAt=LEN(oSelNmCont:oPeriodo:aItems)

     oSelNmCont:oDesde:ForWhen(.T.)
     oSelNmCont:oHasta:ForWhen(.T.)
     oSelNmCont:oBtn  :ForWhen(.T.)

     DPFOCUS(oSelNmCont:oDesde)

  ELSE

     oSelNmCont:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oSelNmCont:oDesde:VarPut(oSelNmCont:aFechas[1] , .T. )
     oSelNmCont:oHasta:VarPut(oSelNmCont:aFechas[2] , .T. )

     oSelNmCont:dDesde:=oSelNmCont:aFechas[1]
     oSelNmCont:dHasta:=oSelNmCont:aFechas[2]

     cWhere:=oSelNmCont:HACERWHERE(oSelNmCont:dDesde,oSelNmCont:dHasta,oSelNmCont:cWhere,.T.)

     oSelNmCont:LEERDATA(cWhere,oSelNmCont:oBrw,oSelNmCont:cServer)

  ENDIF

  oSelNmCont:SAVEPERIODO()

RETURN .T.

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oSelNmCont)

FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\NMCONTABILIZAR.MEM",V_nPeriodo:=oSelNmCont:nPeriodo
  LOCAL V_dDesde:=oSelNmCont:dDesde
  LOCAL V_dHasta:=oSelNmCont:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

// EOF
