// Programa   : DPISLRXML
// Fecha/Hora : 26/01/2008 18:00:36
// Propósito  : Emitir Archivo XML para la declaracion de ISLR 
// Creado Por : Diony López (Enero 2009) - Datapronet Consultores, C.A.
// Llamado por: 
// Aplicación : Compras
// Tabla      : 


#INCLUDE "DPXBASE.CH"
#INCLUDE "FILEIO.CH"

PROCE MAIN(cCodSuc,dDesde,dHasta,cNumReg,dFchReg,oFrm)
  LOCAL cSql,aTotal:={}
  LOCAL oRet,oCol,oFont,oFontB
  LOCAL nHandler,cLine
  LOCAL nMtoRet,nPorcen,dFchRet,cRifEmp
  LOCAL oTable
  LOCAL cNumCntl,oSay,aData:={}
  LOCAL oData:=DATASET("CONFIG","ALL")
  LOCAL cFile:=LOWER(cFileName( GetInstance() ))+"\temp\xmlislr.xml"
  LOCAL cTipDoc:="XML",cWhere
  LOCAL cCodigo:=EJECUTAR("GETCODSENIAT")
  LOCAL oFont,oFontB

  DEFAULT cCodSuc :=oDp:cSucMain,;
          dDesde  :=FCHINIMES(oDp:dFecha),;
          dHasta  :=FCHFINMES(oDp:dFecha)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

 //BOLD

//  oDp:dDesde:=CTOD("01/01/"+LSTR(YEAR(dHasta)))
//  oDp:dhasta:=CTOD("31/12/"+LSTR(YEAR(dHasta)))

  // Requiere Planificación
  cWhere:="PLP_CODSUC"+GetWhere("=",oDp:cSucMain)+" AND PLP_TIPDOC"+GetWhere("=",cTipDoc)

  IF Empty(cNumReg) .AND. COUNT("DPDOCPROPROG",cWhere+" AND "+GetWhereAnd("PLP_FECHA",oDp:dDesde,oDp:dHasta))>0
     EJECUTAR("BRCALFISDET",cWhere)
     RETURN .F.
  ENDIF

  cFile:=STRTRAN(oData:Get("cFile",PADR(cFile,200)),"\\","\")

  AADD(aData,{"","","","",CTOD(""),0,0,0,""})

  oDp:lDpxBase:=.T.
 
  DPEDIT():New("Generar Archivo XML del I.S.L.R","XMLISLR.EDT","oFxml",.T.)

  oFxml:lMsgBar:=.F. // quitar barra de mensajes

  oFxml:dDesde  :=dDesde // sugerimos fecha desde
  oFxml:dHasta  :=dHasta // sugerimos fecha hasta
  oFxml:cNumReg :=cNumReg
  oFxml:dFchReg :=dFchReg
  oFxml:oFrm    :=oFrm
  oFxml:nCuantos:=0                     // para oMeter 
  oFxml:cCodPro :=cCodigo // oData:Get("cSeniat",SPACE(10))
  oFxml:nRecord :=0
  oFxml:cCodSuc :=oDp:cSucursal
  oFxml:cAudita :="Libro de Ventas"
  oFxml:cTable  :="DPLIBVTA"
  oFxml:cMemo   :=""
  oFxml:cMemoTxt:=""
  oFxml:nRecord :=0
  oFxml:nMonto  :=0   // Monto Total Retenciones
  oFxml:lSaved  :=.F. // No Guardado
  oFxml:lProces :=.F. // Procesado
  oFxml:lViewXml:=oData:Get("lViewMxl",.F.) // Visualizar
  oFxml:cTipDoc :=cTipDoc
  oFxml:cConRet :="D014"
  oFxml:lRango  :=.T.

  aTotal:=ATOTALES(aData)


  //oFxml:cFileXml:=cFile
  
  oFxml:cFileXml:=CURDRIVE()+":\"+CURDIR()+PADR("\temp\xmlislr.xml",200)

  //oFxml:cFileXml:=PADR("C:\dpadmwin\temp\xmlislr.xml",200)

  @ 2,2 GROUP oFxml:oGroup TO 07,20 PROMPT " Periodo " 
 
  @ 1,2 SAY "Desde:" 
  @ 2,2 SAY "Hasta:" 

  @ 4,01 BMPGET oFxml:oDesde VAR oFxml:dDesde;
                VALID (oDp:x:=10*20,oFxml:VALFECHAINI() .AND. 1=1);
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oFxml:oDesde ,oFxml:dDesde);
			  WHEN oFxml:lRango;
                SIZE 41,10 

  @ 4,10 BMPGET oFxml:oHasta VAR oFxml:dHasta;
                PICTURE "99/99/9999";
                VALID (oFxml:oBtnHacer:ForWhen(.T.),.T.);
                WHEN oFxml:lRango;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oFxml:oHasta ,oFxml:dHasta);
                SIZE 41,10 
   
  /*
  // SUCURSAL
  */

  @ .1,06 BMPGET oFxml:oCodSuc VAR oFxml:cCodSuc;
                 VALID CERO(oFxml:cCodSuc,NIL,.T.) .AND.;
                            oFxml:FindCodSuc();
                 WHEN Empty(oFxml:cNumReg);
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPSUCURSAL",NIL,NIL),;
                         oDpLbx:GetValue("SUC_CODIGO",oFxml:oCodSuc)); 
                SIZE 48,10

  @ 3,2 SAY oFxml:oSucNombre PROMPT SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",oFxml:cCodSuc));
            UPDATE

  @ 02,01 METER oFxml:oMeter VAR oFxml:nRecord

  @ 4,1 SAY GetFromVar("{oDp:xDPSUCURSAL}")+":"

  @ 4,12 SAY oSay PROMPT "Acceder al PORTAL del SENIAT"

  SayAction(oSay,{||EJECUTAR("WEBRUN","http://contribuyente.seniat.gob.ve/iseniatlogin/juridico.do",.F.)})

  @ 4,01 SAY "Monto Retenido:"
  @ 4,10 SAY oFxml:oMonto PROMPT TRAN(oFxml:nMonto,"999,999,999.99") RIGHT


  @ 10,06 BMPGET oFxml:oCodPro;
                 VAR   oFxml:cCodPro;
                 VALID CERO(oFxml:cCodPro,NIL,.T.) .AND.;
                            oFxml:FindCodPro();
                 NAME "BITMAPS\FIND.BMP"; 
			   WHEN Empty(oFxml:cNumReg);
                 ACTION (oDpLbx:=DpLbx("DPPROVEEDOR",NIL,NIL),;
                         oDpLbx:GetValue("PRO_CODIGO",oFxml:oCodPro)); 
                 SIZE 48,10

  @ 10,2 SAY oFxml:oProNombre PROMPT SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",oFxml:cCodPro));
            UPDATE

  @ 4,01 SAY oDp:xDPPROVEEDOR

  @ 6.8, 1.0 FOLDER oFxml:oFolder ITEMS "Proceso","Retenciones" 

  //
  // Campo : lViewXml
  // Uso   : Envio por Correo
  //
  @ 1, 5 CHECKBOX oFxml:olView  VAR oFxml:lViewXml  PROMPT ANSITOOEM("Visualizar");

  oFxml:olView:cMsg    :="Envio por Correo Electrónico"
  oFxml:olView:cToolTip:="Envio por Correo Electrónico"


  @ 3,2 SAY "Nombre del Archivo"

  //
  // Campo : cFilexml  
  // Uso   : Dirección del Archivo                   
  //

  @ 2.8, 1.0 BMPGET oFxml:oFileXml    VAR oFxml:cFileXml   ;
             NAME "BITMAPS\FIND.BMP";
             ACTION  (cFile:=cGetFile32("Fichero(*.xml) |*.xml|Ficheros (*.xml) |*.xml",;
                     "Seleccionar Archivo (*.xml)",1,cFilePath(oFxml:cFilexml),.f.,.t.),;
                     cFile:=STRTRAN(cFile,"/","/"),;
                     oFxml:cFilexml:=IIF(!EMPTY(cFile),cFile,oFxml:cFilexml),;
                     oFxml:oFileXml:KeyBoard(13));
                     SIZE 200,10
    
  SETFOLDER( 1)

  @ 10,1 GET oFxml:oMemo VAR oFxml:cMemo  MULTILINE READONLY

  SETFOLDER( 2)

   oFxml:oBrw:=TXBrowse():New( oFxml:oFolder:aDialogs[2])
   oFxml:oBrw:SetArray( aData, .F. )
   oFxml:oBrw:SetFont(oFontB)

   oFxml:oBrw:lHScroll    := .F.
   oFxml:oBrw:nHeaderLines:= 2
   oFxml:oBrw:lFooter     :=.T.

   oFxml:aData            :=ACLONE(aData)

   AEVAL(oFxml:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oFxml:oBrw:aCols[1]   
   oCol:cHeader      :="Tipo"
   oCol:nWidth       :=030
   oCol:cFooter      :="#"+LSTR(LEN(aData))

   oCol:=oFxml:oBrw:aCols[2]
   oCol:cHeader      :="Número"
   oCol:nWidth       :=70

   oCol:=oFxml:oBrw:aCols[3]
   oCol:cHeader      :="RIF"
   oCol:nWidth       :=80

   oCol:=oFxml:oBrw:aCols[4]
   oCol:cHeader      :="Nombre del Proveedor"
   oCol:nWidth       :=370

   oCol:=oFxml:oBrw:aCols[5]
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=68

   oCol:=oFxml:oBrw:aCols[6]   
   oCol:cHeader      :="Monto"+CRLF+"Sujeto"
   oCol:nWidth       :=132
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oFxml:oBrw:aArrayData[oFxml:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[6],"999,999,999,999.99")

   oCol:=oFxml:oBrw:aCols[7]   
   oCol:cHeader      :="%"+CRLF+"Ret"
   oCol:nWidth       :=25
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oFxml:oBrw:aArrayData[oFxml:oBrw:nArrayAt,7],;
                                TRAN(nMonto,"99")}

   oCol:=oFxml:oBrw:aCols[8]   
   oCol:cHeader      :="Monto"+CRLF+"Retención"
   oCol:nWidth       :=105
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oFxml:oBrw:aArrayData[oFxml:oBrw:nArrayAt,8],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[8],"999,999,999,999.99")

   oCol:=oFxml:oBrw:aCols[9]
   oCol:cHeader      :="Num"
   oCol:nWidth       :=34

   oFxml:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oFxml:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2 ) } }

//   oFxml:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//   oFxml:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
//   IF ISRELEASE("17.01")
     oFxml:oBrw:bLDblClick:={|oBrw|oFxml:oRep:=oFxml:VERDOCPRO() }
//   ENDIF

   oFxml:oBrw:CreateFromCode()

   oFxml:oBrw:bClrFooter     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oFxml:oBrw:bClrHeader     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oData:End()

   oFxml:ACTIVATE( { ||oFxml:INICIO() } )

RETURN .T.

FUNCTION VALFECHAINI()
  LOCAL lResp

  oFxml:oBtnHacer:ForWhen(.T.) // Replanteamos el Boton Hacer

  lResp:=oFxml:dDesde<=oFxml:dHasta

RETURN lResp

FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL nLin:=330

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 38,38 OF oFxml:oDlg 3D CURSOR oCursor

   IF !Empty(oFxml:cNumReg)

     DEFINE BUTTON oFxml:oBtnHacer;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVE.BMP";
            WHEN (oFxml:dDesde<=oFxml:dHasta);
            ACTION oFxml:CALCULARXML(.T.)

     oFxml:oBtnHacer:cToolTip:="Ejecutar  y Guardar"

   ENDIF

   DEFINE BUTTON oFxml:oBtnHacer;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          WHEN (oFxml:dDesde<=oFxml:dHasta);
          ACTION oFxml:CALCULARXML(.F.)

   oFxml:oBtnHacer:cToolTip:="Ejecutar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          WHEN oFxml:lProces;
          ACTION oFxml:GRABARDOCRET(oFxml:cCodSuc,LSTR(YEAR(oFxml:dHasta)),LSTR(MONTH(oFxml:dHasta)),;
                                   oFxml:nMonto)


   oBtn:cToolTip:="Grabar"


   IF ISRELEASE("17.01")

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP",NIL,"BITMAPS\XBROWSEG.BMP";
          WHEN oFxml:nMonto>0; 
          ACTION EJECUTAR("DPISLRXMLBRW",oFxml:oBrw:aArrayData,"Visualización Declaración XML Retención I.S.L.R [ "+DTOC(oFxml:dDesde)+" "+DTOC(oFxml:dHasta)+" ]")

   oBtn:cToolTip:="Visualizar Retenciones"

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CXP.BMP",NIL,"BITMAPS\CXPG.BMP";
          ACTION EJECUTAR("DPPROVEEDORDOC",oFxml:cCodPro)

   oBtn:cToolTip:="Ver Documentos por Pagar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFxml:Close()

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  IF !Empty(oFxml:cNumReg)

    @ 1,nLin SAY "Registro " OF oBar;
             SIZE 70,18;
             PIXEL BORDER RIGHT COLOR 0,oDp:nClrYellow

    @ 1,nLin+71 SAY " "+oFxml:cNumReg+" " OF oBar;
              SIZE 90,18;
              PIXEL BORDER COLOR 0,oDp:nGris2

    @ 19,nLin SAY "Fecha " OF oBar;
              SIZE 70,18;
              PIXEL BORDER RIGHT COLOR 0,oDp:nClrYellow

    @ 19,nLin+71 SAY " "+DTOC(oFxml:dFchReg)+" " OF oBar;
                 SIZE 90,18;
                 PIXEL BORDER COLOR 0,oDp:nGris2

  ENDIF

  oFxml:oBrw:SetColor(0,oDp:nClrPane1)

RETURN .T.

FUNCTION CALCULARXML(lSave)
  LOCAL cSql,cMemo,aTotal:={}
  LOCAL oRet
  LOCAL nHandler,cLine
  LOCAL cFile:=oFxml:cFileXml
  LOCAL nMtoRet,nPorcen,dFchRet:=oFxml:dHasta,cRifEmp
  LOCAL dFechOpe
  LOCAL cNumCntl,FC_NORMAL,I:=0
  LOCAL oFont,lEdit:=.T.  
  LOCAL cd, odpsc,aData:={},lVacio:=.F.
  LOCAL oData:=DATASET("CONFIG","ALL")

  oData:Set("cFileXml",oFxml:cFileXml)
  oData:Set("lViewXml",oFxml:lViewXml)
  oData:End()

  FERASE(cFile)

  IF FILE(cFile)
     MensajeErr("Fichero "+cFile+CRLF+"Posiblemente Protegido","No es posible Grabar")
     RETURN .F.
  ENDIF

  odpsc:=oFxml:cCodSuc

  cSql:=" SELECT PRO_RIF,RXP_NUMDOC,PRO_NOMBRE,DOC_TIPDOC,DOC_FECHA,DOC_NUMFIS,RXP_CODEQI,RXP_MTOSUJ,RXP_PORCEN,RXP_MTORET,PRO_RIFVAL,"+;
        " PRO_CODIGO,RET_TIPDOC FROM DPDOCPROISLR "+CRLF+;
        " INNER JOIN DPDOCPRO ON DPDOCPROISLR.RXP_CODSUC=DPDOCPRO.DOC_CODSUC AND "+CRLF+;
        " DPDOCPROISLR.RXP_DOCTIP=DPDOCPRO.DOC_TIPDOC AND DPDOCPROISLR.RXP_CODIGO=DPDOCPRO.DOC_CODIGO AND "+CRLF+;
        " DPDOCPROISLR.RXP_DOCNUM=DPDOCPRO.DOC_NUMERO AND DPDOCPROISLR.RXP_TIPTRA=DPDOCPRO.DOC_TIPTRA "+CRLF+;
	   " INNER JOIN DPPROVEEDOR     ON DPDOCPRO.DOC_CODIGO=DPPROVEEDOR.PRO_CODIGO "+CRLF+;
        " LEFT  JOIN VIEW_DOCPROISLR ON RET_CODSUC=DOC_CODSUC AND RET_DOCTIP=DOC_TIPDOC AND RET_CODIGO=DOC_CODIGO AND RET_DOCNUM=DOC_NUMERO AND DOC_TIPTRA='D'  "+;
	   " INNER JOIN DPTIPDOCPRO ON DPDOCPRO.DOC_TIPDOC=DPTIPDOCPRO.TDC_TIPO "+CRLF+" AND "+;
        GetWhereAnd("DOC_FECHA",oFxml:dDesde , oFxml:dHasta)+;
        IIF(Empty(oFxml:cCodSuc),""," WHERE RXP_CODSUC"+GetWhere("=",oFxml:cCodSuc))+;
        " AND DOC_ACT"+GetWhere("=",1)+;
	   " ORDER BY DPPROVEEDOR.PRO_RIF"

  

  oFxml:nMonto  :=0 
  oFxml:oMemo:VarPut("",.T.)
  EJECUTAR("DPCHKOMEMO",oFxml,"[Iniciando Lectura de Datos]")

  cFile  :=ALLTRIM(cFile)
  cRifEmp:=ALLTRIM(STRTRAN(oDp:cRif,"-",""))

  oRet:=OpenTable(cSql,.T.)

  IF oRet:RecCount()=0  
     lVacio:=.T.  
  ENDIF
 
  oFxml:lProces:=.F.
 
  nHandler:=fcreate(cFile,FC_NORMAL)

  cLine :="<?xml version=$1.0$ encoding=$ISO-8859-1$?>"+CRLF
  cLine :=STRTRAN(cLine,"$",CHR(34))
  fwrite(nHandler,cLine)

  //dFchRet:=oGenRep:oRun:aRango[1,3]
  
  cLine :="<RelacionRetencionesISLR RifAgente=$"+ALLTRIM(cRifEmp)+"$ Periodo=$"+;
          CTOO(YEAR(dFchRet),"C")+CTOO(STRZERO(MONTH(dFchRet),2),"C")+"$>"+CRLF
  cLine :=STRTRAN(cLine,"$",CHR(34))
  fwrite(nHandler,cLine)

  oRet:Gotop()

  aData:={}

  WHILE !oRet:Eof()

    I++
    AADD(aData,{oRet:RET_TIPDOC,oRet:RXP_NUMDOC,oRet:PRO_RIF,oRet:PRO_NOMBRE,oRet:DOC_FECHA,oRet:RXP_MTOSUJ,oRet:RXP_PORCEN,oRet:RXP_MTORET,STRZERO(I,4)})

    oFxml:nMonto:=oFxml:nMonto+oRet:RXP_MTORET
 
    /*
    // Numero de Control
    */
    cNumCntl:=ALLTRIM(STRTRAN(oRet:DOC_NUMFIS,"-",""))
    cNumCntl:=RIGHT(cNumCntl,8)

/*  Para que tome todos los digitos del numero de control
    cNumCntl:=ALLTRIM(STRTRAN(oRet:DOC_NUMFIS,"-",""))
    //cNumCntl:=RIGHT(cNumCntl,8)
   // cNumCntl:=RIGHT(cNumCntl)
*/

    //? cNumCntl


    oFxml:lProces:=.T.

    cLine :="<DetalleRetencion>"+CRLF
    fwrite(nHandler,cLine)

    // Rif Proveedor a quien se le aplico la Retencion
    cLine :="<RifRetenido>"+ALLTRIM(STRTRAN(oRet:PRO_RIF,"-",""))+"</RifRetenido>"+CRLF
    fwrite(nHandler,cLine)

    // Numero de Factura
    cLine :="<NumeroFactura>"+ALLTRIM(oRet:RXP_NUMDOC)+"</NumeroFactura>"+CRLF
    fwrite(nHandler,cLine)

    cLine :="<NumeroControl>"+cNumCntl+"</NumeroControl>"+CRLF
    fwrite(nHandler,cLine)

    // Fecha de Operacion(Fecha de pago o abono en cuentaDD/MM/AAAA la fecha no puede ser distinta al
    // periodo que se este declarando)
    cLine :="<FechaOperacion>"+DTOC(oRet:DOC_FECHA)+"</FechaOperacion>"+CRLF
    fwrite(nHandler,cLine)    

    // Codigo concepto de Retencion
    cLine :="<CodigoConcepto>"+ALLTRIM(oRet:RXP_CODEQI)+"</CodigoConcepto>"+CRLF
    fwrite(nHandler,cLine)

    // Monto Operacion(monto sobre el cual se aplicara la retencion) 
    nMtoRet:=CTOO(oRet:RXP_MTOSUJ,"C")
    cLine :="<MontoOperacion>"+ALLTRIM(nMtoRet)+"</MontoOperacion>"+CRLF
    fwrite(nHandler,cLine)

    // Porcentaje de Retencion(porcentaje de retencion que se aplicara)
    nPorcen:=CTOO(oRet:RXP_PORCEN,"C")
    cLine :="<PorcentajeRetencion>"+ALLTRIM(nPorcen)+"</PorcentajeRetencion>"+CRLF
    fwrite(nHandler,cLine)

    cLine :="</DetalleRetencion>"+CRLF
    fwrite(nHandler,cLine)

    IF !oRet:PRO_RIFVAL
      EJECUTAR("DPCHKOMEMO",oFxml,"Rif "+oRet:PRO_RIF+" no Validado, Código "+oRet:PRO_CODIGO)
    ENDIF

    oRet:DbSkip()

  ENDDO

  /*
  // Aqui va Nómina
  */

  oFxml:ADDNOMINA(nHandler,oFxml:dDesde , oFxml:dHasta)


  cLine :="</RelacionRetencionesISLR>"+CRLF
  fwrite(nHandler,cLine)

  fclose(nHandler)

  oFxml:oMemo:Append(MemoRead(cFile),.T.)

  oFxml:oMonto:Refresh(.T.)

  IF Empty(aData)
     AADD(aData,{"","","","",CTOD(""),0,0,0,""})
  ENDIF

  
  aTotal:=ATOTALES(aData)

  oFxml:oBrw:aArrayData:=ACLONE(aData)
  oFxml:oBrw:aCols[1]:cFooter:="#"+LSTR(LEN(aData))

  oFxml:oBrw:aCols[6]:cFooter:=TRAN( aTotal[6],"999,999,999,999.99")
  oFxml:oBrw:aCols[8]:cFooter:=TRAN( aTotal[8],"999,999,999,999.99")

  oFxml:oBrw:Gotop()
  oFxml:oBrw:Refresh(.T.)


  IF lVacio

     EJECUTAR("DPCHKOMEMO",oFxml,"[No Hay Retenciones durante el Periodo ("+CTOO(YEAR(dFchRet),"C")+CTOO(STRZERO(MONTH(dFchRet),2),"C")+")]")

     cMemo:=MEMOREAD("DP\XMLRETISLRVACIO.TXT")
     cMemo:=STRTRAN(cMemo,"{RIF}",cRifEmp)
     cMemo:=STRTRAN(cMemo,"{PERIODO}",CTOO(YEAR(dFchRet),"C")+CTOO(STRZERO(MONTH(dFchRet),2),"C"))

     DPWRITE(cFile,cMemo)

     oRet:End()

     EJECUTAR("DPCHKOMEMO",oFxml,"[Archivo "+cFile+" Generado]")

     IF oFxml:lViewXml
       VIEWRTF(cFile,"Archivo "+cFile+"")
     ENDIF


      // Graba el registro con Monto cero
      IF lSave

          EJECUTAR("DPDOCPROPROGUP",oFxml:cCodSuc,NIL,"XML",oFxml:cNumReg,oFxml:nMonto,DPFECHA(),0)

          IF TYPE("oCALFISDET")="O" .AND. oCALFISDET:oWnd:hWnd>0
             oCALFISDET:BRWREFRESCAR()
          ENDIF

      ENDIF


     RETURN .T.

  ENDIF

  IF lSave
      
      EJECUTAR("DPDOCPROPROGUP",oFxml:cCodSuc,NIL,"XML",oFxml:cNumReg,oFxml:nMonto,DPFECHA(),0)

      IF TYPE("oCALFISDET")="O" .AND. oCALFISDET:oWnd:hWnd>0
        oCALFISDET:BRWREFRESCAR()
      ENDIF

  ENDIF

  IF oFxml:lViewXml
    VIEWRTF(cFile,"Archivo "+cFile+"")
  ENDIF

RETURN .T.

FUNCTION FINDCODSUC()

   oFxml:oSucNombre:Refresh(.T.) 

   IF !oFxml:cCodSuc==SQLGET("DPSUCURSAL","SUC_CODIGO","SUC_CODIGO"+GetWhere("=",oFxml:cCodSuc))

      EVAL(oFxml:oCodSuc:bAction)

    AADD(oFxml:cCodSuc,"Todos")


      RETURN .F.

   ENDIF

RETURN .T.

FUNCTION GRABARDOCRET(cCodSuc,cAno,cMes,nMonto)
  LOCAL oDocPro,oData,cTipDoc:="XML"
  LOCAL oItem,cRefere,cCtaEgr,cCodCta,_cCodCta
  LOCAL cWhere,oTable,cCodPro,cNumero,dFecha,lAppend:=.T.

  IF Empty(SQLGET("DPTIPDOCPRO","TDC_TIPO,TDC_CODCTA","TDC_TIPO"+GetWhere("=",cTipDoc)))

     EJECUTAR("DPTIPDOCPRO",1,cTipDoc)
     oTIPDOCPRO:oTDC_TIPO:VarPut(cTipDoc,.T.)
     oTIPDOCPRO:oTDC_DESCRI:VarPut("Retenciones de IVA en XML",.T.)

     RETURN .F.

  ENDIF

  _cCodCta:=oDp:aRow[2] // Cuenta Contable del Tipo de Documento


  // Fecha
  dFecha:=FCHFINMES(CTOD("01/"+cMes+"/"+cAno))
  dFecha:=oDp:dFecha // este es el Registro de la Transacción
  oData  :=DATASET("CONFIG","ALL")
  cCodPro:=oData:Get("cSeniat",SPACE(10))
  oData:End()

  IF !SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_CODIGO"+GetWhere("=",cCodPro))=cCodPro 
     MensajeErr("Codigo "+cCodPro+" de "+oDp:xDPPROVEEDOR+" no Existe")
     RETURN .F.
  ENDIF

  cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
          "DOC_CODIGO"+GetWhere("=",cCodPro)+" AND "+;
          "DOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
          "DOC_TIPTRA='D'"

  cNumero:=SQLGET("DPDOCPRO","DOC_NUMERO",cWhere)
  lAppend:=Empty(cNumero)

  IF !Empty(cNumero)

    lAppend:=.F.
    cWhere :=" WHERE "+;
             "DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
             "DOC_CODIGO"+GetWhere("=",cCodPro)+" AND "+;
             "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
             "DOC_TIPTRA='D'"
  ELSE

   cWhere:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_CODIGO"+GetWhere("=",cCodPro)+" AND "+;
           "DOC_FECHA "+GetWhere("<",dFecha )+" AND "+;
           "DOC_TIPTRA='D'"
  
   cNumero:=SQLINCREMENTAL("DPDOCPRO","DOC_NUMERO",cWhere)
   cWhere:=""

  ENDIF

  oDocPro:=OpenTable("SELECT * FROM DPDOCPRO "+cWhere , !lAppend )

  IF oDocPro:RecCount()=0
     oDocPro:AppendBlank()
  ENDIF

  oDocPro:Replace("DOC_CODSUC" , cCodSuc)
  oDocPro:Replace("DOC_TIPDOC" , cTipDoc)
  oDocPro:Replace("DOC_CODIGO" , cCodPro)
  oDocPro:Replace("DOC_NUMERO" , cNumero)
  oDocPro:Replace("DOC_TIPTRA" , "D")
  oDocPro:Replace("DOC_CODMON" , oDp:cMoneda)
  oDocPro:Replace("DOC_ACT"    , 1)
  oDocPro:Replace("DOC_CXP"    , 1)
  oDocPro:Replace("DOC_NETO"   , nMonto)
  oDocPro:Replace("DOC_FECHA"  , dFecha)
  oDocPro:Replace("DOC_ESTADO" , "AC")
  oDocPro:Replace("DOC_DOCORG" , "D")
  oDocPro:Replace("DOC_ORIGEN" , "N")
  oDocPro:Replace("DOC_USUARI" , oDp:cUsuario)
  oDocPro:Replace("DOC_VALCAM" , 1)
  oDocPro:Replace("DOC_PLAZO"  , 4)
  oDocPro:Replace("DOC_FCHVEN" , dFecha+4)

  oDocPro:Commit(cWhere)
  oDocPro:End()

  // Crea Item, la Busca en PLANIFICACION DE PAGOS
  cRefere:=SQLGET("DPPROVEEDORPROG","PGC_REFERE,PGC_CTAEGR",;
                                    "PGC_CODIGO"+GetWhere("=",cCodPro)+" AND "+;
                                    "PGC_TIPDOC"+GetWhere("=",cTipDoc ))

  

  SQLDELETE("DPDOCPROCTA","CCD_CODSUC" + GetWhere("=" , cCodSuc)+" AND "+;
                          "CCD_TIPDOC" + GetWhere("=" , cTipDoc)+" AND "+;
                          "CCD_CODIGO" + GetWhere("=" , cCodPro)+" AND "+;
                          "CCD_NUMERO" + GetWhere("=" , cNumero))

  IF !Empty(cRefere)

    cCtaEgr:=oDp:aRow[2]
    cCodCta:=SQLGET("DPCTAEGRESO","CEG_CUENTA","CEG_CODIGO"+GetWhere("=",cCtaEgr))

    oItem:=OpenTable("SELECT * FROM DPDOCPROCTA",.F.)
    oItem:AppendBlank()
    oItem:Replace("CCD_CODSUC" , cCodSuc)
    oItem:Replace("CCD_TIPDOC" , cTipDoc)
    oItem:Replace("CCD_DESCRI" , cTipDoc)
    oItem:Replace("CCD_CODIGO" , cCodPro)
    oItem:Replace("CCD_NUMERO" , cNumero)
    oItem:Replace("CCD_TIPTRA" , "D"    )
    oItem:Replace("CCD_CODCTA" , cCodCta)
    oItem:Replace("CCD_CTAEGR" , cCtaEgr)
    oItem:Replace("CCD_ITEM"   , "001"  )
    oItem:Replace("CCD_CENCOS" , oDp:cCenCos)
    oItem:Replace("CCD_ACT"    , 1      )
    oItem:Replace("CCD_REFERE" , cRefere)
    oItem:Replace("CCD_TIPIVA" , "EX"   )
    oItem:Replace("CCD_MONTO"  , nMonto )

    oItem:Commit()
    oItem:End()

  ELSE

    MensajeErr("Tipo de Documento "+cTipDoc+" no tiene vinculo con Planificación del Proveedor")

  ENDIF

  EJECUTAR("DPFORMYTARGRAB" , "RETISLRXLM" , NIL , FCHINIMES(dFecha),FCHFINMES(dFecha)) // Guarda la Ejecución del Proceso
  EJECUTAR("DPPROVEEDORDOC",cCodPro)

RETURN .T.

FUNCTION FindCodPro()
   ? "POR COPIAR"
RETURN .T.

/*
// Agregar ISLR de Nómina
*/

FUNCTION ADDNOMINA(nHandler,dDesde,dHasta,oMeter,oSay)
  LOCAL cLine,cSql,nCant:=0,nMonto:=0,oFont,nCobro,nMeses,nSalmin:=0,nSalsem:=0,cCond
  LOCAL cNivel:="",nSalario:=0,cCausa,nImp,nMtoRet:=0, nPorcen:=0,cCed,cRifEmp,oTable,cSql
  LOCAL lEdit :=.T.,lServer:=.F.
  LOCAL nMtoNom:=0
  LOCAL lConectar:=.F.,cServer:=oDp:cCodServer,lNomina:=.F.

  oDp:oDb:=OPENODBC(oDp:cDsnData) // BD Local

  lNomina:=EJECUTAR("DBISTABLE",oDp:cDsnData,"NMTRABAJADOR",.F.) 

  IF !lNomina .AND. (!Empty(oDp:cCodServer) .AND. SQLGET("DPSERVERBD","SBD_ACTIVO","SBD_CODIGO"+GetWhere("=",oDp:cCodServer)))

   lServer:=.T.

   MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
         "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

   IF !lConectar
      RETURN .F.
   ENDIF

   lNomina:=EJECUTAR("DBISTABLE",oDp:oDb,"NMTRABAJADOR") 

  ENDIF
 
  IF !lNomina
     RETURN NIL
  ENDIF

/*
  cSql:= " SELECT CEDULA,CODIGO,RIF,ISR1,ISR2,ISR3,ISR4,FCH_HASTA,REC_FECHAS,SUM(HIS_MONTO) AS MTOSUJ, "+;
            " IF(HIS_CODCON"+GetWhere("=",oFxml:cConRet)+",SUM(HIS_MONTO),0) AS MTORET "+;
         " FROM NMRECIBOS;
          INNER JOIN NMHISTORICO ON HIS_NUMREC=REC_NUMERO;
          INNER JOIN NMFECHAS ON FCH_NUMERO=REC_NUMFCH;
          INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO;
          INNER JOIN NMCONCEPTOS ON CON_CODIGO=HIS_CODCON ;
          WHERE FCH_HASTA " +GetWhere("<=",dHasta)+;
          " AND FCH_DESDE " +GetWhere(">=",ddesde)+;
          " AND CON_ISLR"+GetWhere("=","1")+;
          " GROUP BY CEDULA "
*/

   cSql:= " SELECT CEDULA,CODIGO,APELLIDO,NOMBRE,HIS_NUMREC,RIF,ISR1,ISR2,ISR3,ISR4,FCH_HASTA,REC_FECHAS,SUM(IF(HIS_MONTO>0,HIS_MONTO,0)) AS MTOSUJ, "+;
          " SUM(IF(HIS_CODCON='D014',HIS_MONTO*-1,0)) AS MTORET "+;
          " FROM NMRECIBOS;
          INNER JOIN NMHISTORICO ON HIS_NUMREC=REC_NUMERO;
          INNER JOIN NMFECHAS ON FCH_NUMERO=REC_NUMFCH;
          INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO;
          INNER JOIN NMCONCEPTOS ON CON_CODIGO=HIS_CODCON ;
          WHERE FCH_HASTA " +GetWhere("<=",dHasta)+;
          " AND FCH_DESDE " +GetWhere(">=",ddesde)+;
          " AND (CON_ISLR=1 OR HIS_CODCON"+GetWhere("=","D014")+")"+;
          " GROUP BY CEDULA "

//? CLPCOPY(cSql)

  oTable:=OpenTable(cSql,.T.,oDp:oDb,.F.,NIL,.F.)

  oTable:GoTop()

  DEFAULT lEdit:=.T.

  IIF(ValType(oMeter)="O",oMeter:SetTotal(oTable:RecCount()),NIL)

  oTable:GoTop()

  WHILE !oTable:Eof()

    IIF(ValType(oMeter)="O",oMeter:Set(oTable:Recno()),NIL)

    DO CASE

	  CASE MONTH(oTable:FCH_HASTA)<=3
          nImp:=oTable:ISR1
    	  CASE MONTH(oTable:FCH_HASTA)>3 .and. MONTH(oTable:FCH_HASTA)<=6
          nImp:=oTable:ISR2
    	  CASE MONTH(oTable:FCH_HASTA)>6 .and. MONTH(oTable:FCH_HASTA)<=9
          nImp:=oTable:ISR3
	  CASE MONTH(oTable:FCH_HASTA)>9 .and. MONTH(oTable:FCH_HASTA)<=12
          nImp:=oTable:ISR4

    ENDCASE

    IF oTable:Recno()>1
       cLine:=CRLF
    ENDIF

    I++
    AADD(aData,{"REC",oTable:HIS_NUMREC,oTable:RIF,ALLTRIM(oTable:APELLIDO)+","+ALLTRIM(oTable:NOMBRE),oTable:REC_FECHAS,oTable:MTOSUJ,nImp,oTable:MTORET,STRZERO(I,4)})

    cLine :="<DetalleRetencion>"+CRLF
    fwrite(nHandler,cLine)

    cCed:=CTOO( IF(!EMPTY(oTable:Rif), oTable:RIF ,oTable:CEDULA ) ,"C")
    cLine :="<RifRetenido>"+ALLTRIM(STRTRAN(cCed,"-",""))+"</RifRetenido>"+CRLF
    fwrite(nHandler,cLine)

    cLine :="<NumeroFactura>"+"0"+"</NumeroFactura>"+CRLF
    fwrite(nHandler,cLine)

    cLine :="<NumeroControl>"+"NA"+"</NumeroControl>"+CRLF
    fwrite(nHandler,cLine)

    // Fecha
    cLine :="<FechaOperacion>"+DTOC(oTable:REC_FECHAS)+"</FechaOperacion>"+CRLF
    fwrite(nHandler,cLine)

    cLine :="<CodigoConcepto>"+"001"+"</CodigoConcepto>"+CRLF
    fwrite(nHandler,cLine)


    nMtoRet:=CTOO(oTable:MTOSUJ,"C")
    cLine :="<MontoOperacion>"+ALLTRIM(nMtoRet)+"</MontoOperacion>"+CRLF
    fwrite(nHandler,cLine)

    //? nImp
    nPorcen:=CTOO(nImp,"C")
    cLine :="<PorcentajeRetencion>"+ALLTRIM(nPorcen)+"</PorcentajeRetencion>"+CRLF
    fwrite(nHandler,cLine)

    cLine :="</DetalleRetencion>"+CRLF

    fwrite(nHandler,cLine)

//    oFxml:nMonto:=oFxml:nMonto+oTable:MONTO // Suma Monto de Nómina JN 4/4/2017
    nMtoNom:=nMtoNom+oTable:MTORET // Suma Monto de Nómina JN 4/4/2017


    oTable:Skip()

  ENDDO

  oTable:End()

//?  nMtoNom,"Monto Retencion Nómina"

  oFxml:nMonto:=oFxml:nMonto+nMtoNom



  IF lServer .AND. ValType(oDp:oDb)="O"
    EJECUTAR("DPSERVERCLOSE",cServer)
  ENDIF

  oFxml:oMonto:Refresh(.T.)

RETURN NIL

FUNCTION VERDOCPRO()
  LOCAL aLine:=oFxml:oBrw:aArrayData[1] //oFxml:oBrw:nArrayAt]
  LOCAL oFrm
  LOCAL cCodSuc:=oDp:cSucursal,cTipDoc:=aLine[1],cRif:=aLine[3],cNumero:=aLine[2],cCodigo:=SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_RIF"+GetWhere("=",cRif))

  EJECUTAR("DPDOCPROFACCON",oFrm,cCodSuc,cTipDoc,cNumero,cCodigo)

RETURN NIL
// EOF
