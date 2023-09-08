// Programa   : BRNMFECHA
// Fecha/Hora : 10/10/2019 05:26:00
// Propósito  : "Resumen de Nóminas Actualizadas"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRNMFECHA.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oNMFECHA")="O" .AND. oNMFECHA:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oNMFECHA,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Resumen de Nóminas Actualizadas" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oNMFECHA
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oNMFECHA","BRNMFECHA.EDT")
// oNMFECHA:CreateWindow(0,0,100,550)
   oNMFECHA:Windows(0,0,aCoors[3]-160,MIN(1132+90,aCoors[4]-10),.T.) // Maximizado

   oNMFECHA:cCodSuc  :=cCodSuc
   oNMFECHA:lMsgBar  :=.F.
   oNMFECHA:cPeriodo :=aPeriodos[nPeriodo]
   oNMFECHA:cCodSuc  :=cCodSuc
   oNMFECHA:nPeriodo :=nPeriodo
   oNMFECHA:cNombre  :=""
   oNMFECHA:dDesde   :=dDesde
   oNMFECHA:cServer  :=cServer
   oNMFECHA:dHasta   :=dHasta
   oNMFECHA:cWhere   :=cWhere
   oNMFECHA:cWhere_  :=cWhere_
   oNMFECHA:cWhereQry:=""
   oNMFECHA:cSql     :=oDp:cSql
   oNMFECHA:oWhere   :=TWHERE():New(oNMFECHA)
   oNMFECHA:cCodPar  :=cCodPar // Código del Parámetro
   oNMFECHA:lWhen    :=.T.
   oNMFECHA:cTextTit :="" // Texto del Titulo Heredado
   oNMFECHA:oDb      :=oDp:oDb
   oNMFECHA:cBrwCod  :="NMFECHA"
   oNMFECHA:lTmdi    :=.T.
   oNMFECHA:aHead    :={}

   oNMFECHA:lBtnMenuBrw :=.F.
   oNMFECHA:lBtnSave    :=.F.
   oNMFECHA:lBtnCrystal :=.F.
   oNMFECHA:lBtnRefresh :=.F.
   oNMFECHA:lBtnHtml    :=.T.
   oNMFECHA:lBtnExcel   :=.T.
   oNMFECHA:lBtnPreview :=.T.
   oNMFECHA:lBtnQuery   :=.F.
   oNMFECHA:lBtnOptions :=.T.
   oNMFECHA:lBtnPageDown:=.T.
   oNMFECHA:lBtnPageUp  :=.T.
   oNMFECHA:lBtnFilters :=.T.
   oNMFECHA:lBtnFind    :=.T.

   oNMFECHA:nClrPane1:=16773345
   oNMFECHA:nClrPane2:=16769734 

   oNMFECHA:oBrw:=TXBrowse():New( IF(oNMFECHA:lTmdi,oNMFECHA:oWnd,oNMFECHA:oDlg ))
   oNMFECHA:oBrw:SetArray( aData, .F. )
   oNMFECHA:oBrw:SetFont(oFont)

   oNMFECHA:oBrw:lFooter     := .T.
   oNMFECHA:oBrw:lHScroll    := .T.
   oNMFECHA:oBrw:nHeaderLines:= 2
   oNMFECHA:oBrw:nDataLines  := 1
   oNMFECHA:oBrw:nFooterLines:= 1


   oNMFECHA:aData            :=ACLONE(aData)

   AEVAL(oNMFECHA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oNMFECHA:oBrw:aCols[1]
  oCol:cHeader      :='Núm.'+CRLF+'Proc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oNMFECHA:oBrw:aCols[2]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMFECHA:oBrw:aCols[3]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMFECHA:oBrw:aCols[4]
  oCol:cHeader      :='Tipo'+CRLF+'Nómina'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:bClrStd      := {|nClrText,uValue|uValue:=oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,4],;
                        nClrText:=COLOR_OPTIONS("NMFECHAS","FCH_TIPNOM",uValue),;
                        {nClrText,iif( oNMFECHA:oBrw:nArrayAt%2=0, oNMFECHA:nClrPane1,oNMFECHA:nClrPane2 ) } } 

  oCol:=oNMFECHA:oBrw:aCols[5]
  oCol:cHeader      :='Otra'+CRLF+'Nómina'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oNMFECHA:oBrw:aCols[6]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 180

  oCol:=oNMFECHA:oBrw:aCols[7]
  oCol:cHeader      :='Cant.'+CRLF+'Rec.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,7],;
                              oCol  := oNMFECHA:oBrw:aCols[7],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[8]
  oCol:cHeader      :='Cant.'+CRLF+'Efec.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,8],;
                              oCol  := oNMFECHA:oBrw:aCols[8],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[8],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[9]
  oCol:cHeader      :='Cant.'+CRLF+'Chq'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,9],;
                              oCol  := oNMFECHA:oBrw:aCols[9],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[9],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[10]
  oCol:cHeader      :='Cant.'+CRLF+'Trab.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,10],;
                              oCol  := oNMFECHA:oBrw:aCols[10],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[10],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[11]
  oCol:cHeader      :='Monto'+CRLF+'Efectivo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,11],;
                              oCol  := oNMFECHA:oBrw:aCols[11],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[11],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[12]
  oCol:cHeader      :='Monto'+CRLF+'Cheque'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,12],;
                              oCol  := oNMFECHA:oBrw:aCols[12],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[12],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[13]
  oCol:cHeader      :='Monto'+CRLF+'Transf.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,13],;
                              oCol  := oNMFECHA:oBrw:aCols[13],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[13],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[14]
  oCol:cHeader      :='Estado'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:bClrStd      := {|nClrText,uValue|uValue:=oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,14],;
                        nClrText:=COLOR_OPTIONS("NMFECHAS","FCH_ESTADO",uValue),;
                        {nClrText,iif( oNMFECHA:oBrw:nArrayAt%2=0, oNMFECHA:nClrPane1,oNMFECHA:nClrPane2 ) } } 


  oCol:nWidth       := 72

  oCol:=oNMFECHA:oBrw:aCols[15]
  oCol:cHeader      :='Conta'+CRLF+'biliz.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  oCol:=oNMFECHA:oBrw:aCols[16]
  oCol:cHeader      :='Número'+CRLF+'Cbte'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMFECHA:oBrw:aCols[17]
  oCol:cHeader      :='Cód.'+CRLF+'Suc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMFECHA:oBrw:aCols[18]
  oCol:cHeader      :='Cód'+CRLF+'Moneda'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oNMFECHA:oBrw:aCols[19]
  oCol:lAvg:=.T.
  oCol:cHeader      :='Monto'+CRLF+oDp:cMoneda
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,19],;
                              oCol  := oNMFECHA:oBrw:aCols[19],;
                              FDP(nMonto,oCol:cEditPicture)}


  oCol:=oNMFECHA:oBrw:aCols[20]
  oCol:lAvg:=.T.
  oCol:cHeader      :='Valor'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :=oDp:cPictureDivisa
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,20],;
                              oCol  := oNMFECHA:oBrw:aCols[20],;
                              FDP(nMonto,oCol:cEditPicture)}

  oCol:=oNMFECHA:oBrw:aCols[21]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='99,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,21],;
                               oCol  := oNMFECHA:oBrw:aCols[21],;
                               FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[21],oCol:cEditPicture)


  oCol:=oNMFECHA:oBrw:aCols[22]
  oCol:cHeader      :='Reg.'+CRLF+'Planificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oNMFECHA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70




   oNMFECHA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oNMFECHA:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNMFECHA:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oNMFECHA:nClrPane1, oNMFECHA:nClrPane2 ) } }

   oNMFECHA:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNMFECHA:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oNMFECHA:oBrw:bLDblClick:={|oBrw|oNMFECHA:RUNCLICK() }

   oNMFECHA:oBrw:bChange:={||oNMFECHA:BRWCHANGE()}
   oNMFECHA:oBrw:CreateFromCode()
   oNMFECHA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oNMFECHA)}
   oNMFECHA:BRWRESTOREPAR()

   oNMFECHA:oWnd:oClient := oNMFECHA:oBrw


   oNMFECHA:BRWRESTOREPAR()

   oNMFECHA:Activate({||oNMFECHA:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oNMFECHA:lTmdi,oNMFECHA:oWnd,oNMFECHA:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oNMFECHA:oBrw:nWidth()

   oNMFECHA:oBrw:GoBottom(.T.)
   oNMFECHA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRNMFECHA.EDT")
     oNMFECHA:oBrw:Move(44,0,1132+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oNMFECHA:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oNMFECHA:oBrw,oNMFECHA:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF


   DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\MENU.BMP";
            ACTION EJECUTAR("DPNMFCHMNU",oNMFECHA:cCodSuc,oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt,1])

     oBtn:cToolTip:="Opciones"


    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\XBROWSE.BMP";
           ACTION oNMFECHA:VERDETALLES()

     oBtn:cToolTip:="Ver Detalles"

  
/*
   IF Empty(oNMFECHA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","NMFECHA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","NMFECHA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oNMFECHA:oBrw,"NMFECHA",oNMFECHA:cSql,oNMFECHA:nPeriodo,oNMFECHA:dDesde,oNMFECHA:dHasta,oNMFECHA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oNMFECHA:oBtnRun:=oBtn



       oNMFECHA:oBrw:bLDblClick:={||EVAL(oNMFECHA:oBtnRun:bAction) }


   ENDIF



IF oNMFECHA:lBtnSave

      DEFINE BITMAP OF OUTLOOK oBRWMENURUN:oOut ;
             BITMAP "BITMAPS\XSAVE.BMP";
             PROMPT "Guardar Consulta";
             ACTION EJECUTAR("DPBRWSAVE",oNMFECHA:oBrw,oNMFECHA:oFrm)
ENDIF

IF oNMFECHA:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          ACTION (EJECUTAR("BRWBUILDHEAD",oNMFECHA),;
                  EJECUTAR("DPBRWMENURUN",oNMFECHA,oNMFECHA:oBrw,oNMFECHA:cBrwCod,oNMFECHA:cTitle,oNMFECHA:aHead));
          WHEN !Empty(oNMFECHA:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oNMFECHA:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oNMFECHA:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oNMFECHA:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oNMFECHA:oBrw,oNMFECHA);
          ACTION EJECUTAR("BRWSETFILTER",oNMFECHA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oNMFECHA:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oNMFECHA:oBrw);
          WHEN LEN(oNMFECHA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oNMFECHA:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oNMFECHA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oNMFECHA:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oNMFECHA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oNMFECHA:lBtnExcel

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oNMFECHA:oBrw,oNMFECHA:cTitle,oNMFECHA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oNMFECHA:oBtnXls:=oBtn

ENDIF

IF oNMFECHA:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oNMFECHA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oNMFECHA:oBrw,NIL,oNMFECHA:cTitle,oNMFECHA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oNMFECHA:oBtnHtml:=oBtn

ENDIF
 

IF oNMFECHA:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oNMFECHA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oNMFECHA:oBtnPreview:=oBtn

ENDIF

   IF .T.
   //ISSQLGET("DPREPORTES","REP_CODIGO","BRNMFECHA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oNMFECHA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oNMFECHA:oBtnPrint:=oBtn

   ENDIF

IF oNMFECHA:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oNMFECHA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oNMFECHA:oBrw:GoTop(),oNMFECHA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oNMFECHA:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            ACTION (oNMFECHA:oBrw:PageDown(),oNMFECHA:oBrw:Setfocus())
  ENDIF

  IF  oNMFECHA:lBtnPageUp  

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           ACTION (oNMFECHA:oBrw:PageUp(),oNMFECHA:oBrw:Setfocus())
  ENDIF

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oNMFECHA:oBrw:GoBottom(),oNMFECHA:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNMFECHA:Close()

  oNMFECHA:oBrw:SetColor(0,oNMFECHA:nClrPane1)

  EVAL(oNMFECHA:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oNMFECHA:oBar:=oBar

    nLin:=772

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oNMFECHA:oPeriodo  VAR oNMFECHA:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oNMFECHA:LEEFECHAS();
                WHEN oNMFECHA:lWhen 


  ComboIni(oNMFECHA:oPeriodo )

  @ 10, nLin+103 BUTTON oNMFECHA:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMFECHA:oPeriodo:nAt,oNMFECHA:oDesde,oNMFECHA:oHasta,-1),;
                         EVAL(oNMFECHA:oBtn:bAction));
                WHEN oNMFECHA:lWhen 


  @ 10, nLin+130 BUTTON oNMFECHA:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNMFECHA:oPeriodo:nAt,oNMFECHA:oDesde,oNMFECHA:oHasta,+1),;
                         EVAL(oNMFECHA:oBtn:bAction));
                WHEN oNMFECHA:lWhen 


  @ 10, nLin+170 BMPGET oNMFECHA:oDesde  VAR oNMFECHA:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMFECHA:oDesde ,oNMFECHA:dDesde);
                SIZE 72,22;
                OF   oBar;
                WHEN oNMFECHA:oPeriodo:nAt=LEN(oNMFECHA:oPeriodo:aItems) .AND. oNMFECHA:lWhen ;
                FONT oFont

   oNMFECHA:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252+4 BMPGET oNMFECHA:oHasta  VAR oNMFECHA:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNMFECHA:oHasta,oNMFECHA:dHasta);
                SIZE 72,22;
                WHEN oNMFECHA:oPeriodo:nAt=LEN(oNMFECHA:oPeriodo:aItems) .AND. oNMFECHA:lWhen ;
                OF oBar;
                FONT oFont

   oNMFECHA:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335+8 BUTTON oNMFECHA:oBtn PROMPT " > " SIZE 27,22;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oNMFECHA:oPeriodo:nAt=LEN(oNMFECHA:oPeriodo:aItems);
               ACTION oNMFECHA:HACERWHERE(oNMFECHA:dDesde,oNMFECHA:dHasta,oNMFECHA:cWhere,.T.);
               WHEN oNMFECHA:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  BMPGETBTN(oBar,oFont,13)

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere:=NIL
  LOCAL aLine:=oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt]
  LOCAL oFecha:=OpenTable("SELECT * FROM NMFECHAS WHERE FCH_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND FCH_NUMERO"+GetWhere("=",aLine[1]),.t.)
  
  oFecha:End()

  oRep:=REPORTE("RECIBOS",cWhere)
  oRep:SetCriterio(1,oFecha:FCH_TIPNOM)
  oRep:SetCriterio(2,oFecha:FCH_OTRNOM)
  oRep:SetCriterio(3,oFecha:FCH_DESDE)
  oRep:SetCriterio(4,oFecha:FCH_HASTA)

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNMFECHA:oPeriodo:nAt,cWhere

  oNMFECHA:nPeriodo:=nPeriodo


  IF oNMFECHA:oPeriodo:nAt=LEN(oNMFECHA:oPeriodo:aItems)

     oNMFECHA:oDesde:ForWhen(.T.)
     oNMFECHA:oHasta:ForWhen(.T.)
     oNMFECHA:oBtn  :ForWhen(.T.)

     DPFOCUS(oNMFECHA:oDesde)

  ELSE

     oNMFECHA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNMFECHA:oDesde:VarPut(oNMFECHA:aFechas[1] , .T. )
     oNMFECHA:oHasta:VarPut(oNMFECHA:aFechas[2] , .T. )

     oNMFECHA:dDesde:=oNMFECHA:aFechas[1]
     oNMFECHA:dHasta:=oNMFECHA:aFechas[2]

     cWhere:=oNMFECHA:HACERWHERE(oNMFECHA:dDesde,oNMFECHA:dHasta,oNMFECHA:cWhere,.T.)

     oNMFECHA:LEERDATA(cWhere,oNMFECHA:oBrw,oNMFECHA:cServer)

  ENDIF

  oNMFECHA:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "NMFECHAS.FCH_SISTEM"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('NMFECHAS.FCH_SISTEM',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('NMFECHAS.FCH_SISTEM',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oNMFECHA:cWhereQry)
       cWhere:=cWhere + oNMFECHA:cWhereQry
     ENDIF

     oNMFECHA:LEERDATA(cWhere,oNMFECHA:oBrw,oNMFECHA:cServer)

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

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT"+;
          "  FCH_NUMERO,"+;
          "  FCH_DESDE,"+;
          "  FCH_HASTA,"+;
          "  FCH_TIPNOM,"+;
          "  FCH_OTRNOM,"+;
          "  OTR_DESCRI,"+;
          "  CRF_CANTID,"+;
          "  CRF_CANEFE,"+;
          "  CRF_CANCHQ,"+;
          "  CRF_CANTRA,  "+;
          "  CRF_MTOEFE,"+;
          "  CRF_MTOCHQ,"+;
          "  CRF_MTOTRA,  "+;
          "  FCH_ESTADO,"+;
          "  FCH_CONTAB,"+;
          "  FCH_NUMCBT,FCH_CODSUC,FCH_CODMON,CRF_NETO,FCH_VALCAM,CRF_MTODIV AS FCH_MTODIV,FCH_REGPLA "+;
          "  FROM NMFECHAS  "+;
          "  LEFT  JOIN NMOTRASNM         ON OTR_CODIGO=FCH_OTRNOM  "+;
          "  INNER JOIN NMRECIBOS         ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO  "+;
          "  INNER JOIN NMHISTORICO       ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC  "+;
          "  LEFT  JOIN VIEW_NMFCHCANTREC ON FCH_CODSUC=CRF_CODSUC AND FCH_NUMERO=CRF_NUMERO  "+;
          "  GROUP BY FCH_NUMERO  "+;
          "  ORDER BY FCH_NUMERO DESC"

   cWhere:=IIF(Empty(cWhere),"",cWhere+" AND ")+" HIS_CODCON<='DZZZ'"

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRNMFECHA.SQL",cSql)

   aData:=ASQL(cSql,oDb)

//? CLPCOPY(oDp:cSql)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'',CTOD(""),CTOD(""),'','','',0,0,0,0,0,0,0,'','',''})
   ENDIF

        AEVAL(aData,{|a,n|aData[n,4]:=SAYOPTIONS("NMFECHAS","FCH_TIPNOM",a[4]),;
          aData[n,14]:=SAYOPTIONS("NMFECHAS","FCH_ESTADO",a[14])})

   IF ValType(oBrw)="O"

      oNMFECHA:cSql   :=cSql
      oNMFECHA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oNMFECHA:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],oCol:cEditPicture)
      oCol:=oNMFECHA:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],oCol:cEditPicture)
      oCol:=oNMFECHA:oBrw:aCols[9]
         oCol:cFooter      :=FDP(aTotal[9],oCol:cEditPicture)
      oCol:=oNMFECHA:oBrw:aCols[10]
         oCol:cFooter      :=FDP(aTotal[10],oCol:cEditPicture)
      oCol:=oNMFECHA:oBrw:aCols[11]
         oCol:cFooter      :=FDP(aTotal[11],oCol:cEditPicture)
      oCol:=oNMFECHA:oBrw:aCols[12]
         oCol:cFooter      :=FDP(aTotal[12],oCol:cEditPicture)
      oCol:=oNMFECHA:oBrw:aCols[13]
         oCol:cFooter      :=FDP(aTotal[13],oCol:cEditPicture)

      oNMFECHA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oNMFECHA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oNMFECHA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRNMFECHA.MEM",V_nPeriodo:=oNMFECHA:nPeriodo
  LOCAL V_dDesde:=oNMFECHA:dDesde
  LOCAL V_dHasta:=oNMFECHA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oNMFECHA)
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


    IF Type("oNMFECHA")="O" .AND. oNMFECHA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oNMFECHA:cWhere_),oNMFECHA:cWhere_,oNMFECHA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oNMFECHA:LEERDATA(oNMFECHA:cWhere_,oNMFECHA:oBrw,oNMFECHA:cServer)
      oNMFECHA:oWnd:Show()
      oNMFECHA:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oNMFECHA:aHead:=EJECUTAR("HTMLHEAD",oNMFECHA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oNMFECHA)
RETURN .T.

FUNCTION VERDETALLES()
  LOCAL aLine:=oNMFECHA:oBrw:aArrayData[oNMFECHA:oBrw:nArrayAt]
  LOCAL cWhere:="FCH_NUMERO"+GetWhere("=",aLine[1]),
  LOCAL cTitle:=" [Nómina : "+aLine[1]+"]"

  EJECUTAR("BRRECIBOS",cWhere,oNMFECHA:cCodSuc,oNMFECHA:nPeriodo,oNMFECHA:dDesde,oNMFECHA:dHasta,cTitle)

RETURN .T.
/*
// Genera Correspondencia Masiva
*/


// EOF

