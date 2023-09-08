// Programa   : DPCAL_LPH
// Fecha/Hora : 16/10/2008 11:36:31
// Propósito  : Calcular LPH desde Nómina
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dDesde,dHasta,aCodCon,cTipDoc,cCodPro,cTitle)
   LOCAL nMonto:=0,oTable,cSql,aData,cTipIva,cRefere

   DEFAULT aCodCon:={"D028","H005"},;
           dDesde :=FCHINIMES(oDp:dFecha),;
           dHasta :=FCHFINMES(oDp:dFecha),;
           cTipDoc:="APH"

   IF !oDp:lNomina 
      RETURN 0
   ENDIF

   cCodPro:=SQLGET("DPPROVEEDORPROG","PGC_CODIGO,PGC_REFERE,PGC_IVA","PGC_TIPDOC"+GetWhere("=",cTipDoc))

   IF !Empty(oDp:aRow)
     cRefere:=oDp:aRow[2]
     cTipIva:=oDp:aRow[3]
   ENDIF

   cTitle:=SQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc))

   IF Empty(cCodPro) 
      MensajeErr("No hay Planificación definida para "+cTipDoc,cTitle)
      RETURN 0
   ENDIF

   EJECUTAR("TABLASNOMINA")

   cSql:=" SELECT HIS_CODCON,CON_DESCRI,CON_CUENTA,CTA_DESCRI,SUM(HIS_MONTO) FROM NMFECHAS "+;
         " INNER JOIN NMRECIBOS    ON REC_NUMFCH=FCH_NUMERO "+;
         " INNER JOIN NMHISTORICO  ON REC_NUMERO=HIS_NUMREC "+;
         " INNER JOIN NMCONCEPTOS  ON HIS_CODCON=CON_CODIGO "+;
         " LEFT  JOIN DPCTA        ON CON_CUENTA=CTA_CODIGO "+;
         " WHERE "+GetWhereOr("HIS_CODCON",aCodCon)+;
         "   AND "+GetWhereAnd("FCH_DESDE",dDesde,dHasta)+;
         " GROUP BY HIS_CODCON,CON_DESCRI,CON_CUENTA "


   aData:=ASQL(cSql)

   AEVAL(aData,{|a,n| aData[n,5]:=IIF( a[5]<0 , a[5]*-1 , a[5] ) })

   cTitle:=" Calcular "+cTitle

   ViewData(aData,cCodPro,cTipDoc,cTitle,cTipIva,cRefere)

RETURN nMonto

FUNCTION ViewData(aData,cCodPro,cTipDoc,cTitle,cTipIva,cRefere)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData),cNumero:=SPACE(10)
   LOCAL oFont,oFontB

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -14 BOLD

   oCalLph:=DPEDIT():New(cTitle,"DPCAL_LPH.EDT","oCalLph",.T.)
   oCalLph:cCodPro :=cCodPro
   oCalLph:cTipDoc :=cTipDoc
// oCalLph:cNumero :=cNumero
   oCalLph:cRefere :=cRefere
   oCalLph:cTipIva :=cTipIva

   oCalLph:cControl:=SPACE(10)
   oCalLph:nTotal  :=aTotal[5]

   oCalLph:cNombre :=ALLTRIM(MYSQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",cCodPro)))
   oCalLph:lMsgBar :=.F.

   oCalLph:oBrw:=TXBrowse():New( oCalLph:oDlg )
   oCalLph:oBrw:SetArray( aData, .F. )
   oCalLph:oBrw:SetFont(oFont)
   oCalLph:oBrw:lFooter     := .T.
   oCalLph:oBrw:lHScroll    := .F.
   oCalLph:oBrw:nHeaderLines:= 1
   oCalLph:oBrw:lFooter     :=.T.
   oCalLph:cPicture         :="999,999,999.99"    
   oCalLph:nTotal           :=aTotal[5]
   oCalLph:lValCta          :=.T.

   oCalLph:cCodSuc  :=cCodSuc

   oCalLph:aData    :=ACLONE(aData)

   AEVAL(oCalLph:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oCalLph:oBrw:aCols[1]   
   oCol:cHeader      :="Codigo"
   oCol:nWidth       :=46

   oCol:=oCalLph:oBrw:aCols[2]
   oCol:cHeader      :="Concepto"
   oCol:nWidth       := 250

   oCol:=oCalLph:oBrw:aCols[3]  
   oCol:cHeader      :="Cuenta Contable"
   oCol:nWidth       :=140
   oCol:bOnPostEdit  :={|oCol,uValue| oCalLph:VALCTA(oCol,uValue,3)}
   oCol:nEditType    :=EDIT_GET_BUTTON
   oCol:bEditBlock   :={||oCalLph:LISTARCTA()}
   oCol:lAutoList    :=.T.

   oCol:=oCalLph:oBrw:aCols[4]  
   oCol:cHeader      :="Nombre de la Cuenta"
   oCol:nWidth       :=200

   oCol:=oCalLph:oBrw:aCols[5]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Monto"
   oCol:nWidth       :=115
   oCol:bStrData     :={|nMonto|nMonto:=oCalLph:oBrw:aArrayData[oCalLph:oBrw:nArrayAt,5],;
                                TRAN(nMonto,oCalLph:cPicture)}

   oCol:cFooter      :=TRAN( aTotal[5],oCalLph:cPicture)

   oCalLph:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oCalLph:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          {nClrText,iif( !oBrw:nArrayAt%2=0, 14087148, 11790521 ) } }

   oCalLph:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCalLph:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  

   oCalLph:oBrw:DelCol(9)

   oCalLph:oBrw:CreateFromCode()

   oCalLph:Activate( { ||oCalLph:ViewDatBar() } )

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oCalLph:oDlg

   oCalLph:oBrw:GoTop(.T.)
   oCalLph:oBrw:SelectCol(3)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          WHEN !Empty(oCalLph:nTotal);
          ACTION oCalLph:HACERREGISTRO()

   oBtn:cToolTip:="Registrar Documento"
   oCalLph:oBtnSave:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XEDIT.BMP";
          ACTION oCalLph:EDITARCTA()

   oBtn:cToolTip:="Indicar Monto"
   oCalLph:oBtnPago:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROVEEDORES.BMP";
          ACTION oCalLph:VIEWPROVEEDOR(oCalLph:cCodPro)

   oBtn:cToolTip:=oDp:DPPROVEEDOR

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oCalLph:oBrw,oCalLph:cTitle,oCalLph:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oCalLph:oBrw:GoTop(),oCalLph:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oCalLph:oBrw:PageDown(),oCalLph:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oCalLph:oBrw:PageUp(),oCalLph:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oCalLph:oBrw:GoBottom(),oCalLph:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCalLph:Close()

  oCalLph:oBrw:SetColor(0,14087148)

  oCalLph:oBrw:bChange:={|| oCalLph:oBtnPago:ForWhen(.T.) }

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCalLph:oBtnSave:ForWhen(.T.)

RETURN .T.

FUNCTION VALCTA(oCol,uValue,nCol)

   IF !oCalLph:lValCta
      oCalLph:lValCta:=.T.
      RETURN .T.
   ENDIF

   IF !ISSQLGET("DPCTA","CTA_CODIGO",uValue)
      oCalLph:LISTARCTA(uValue)
   ENDIF

   oCalLph:oBrw:aArrayData[oCalLph:oBrw:nArrayAt,4]:=SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",uValue))
   oCalLph:oBrw:DrawLine(.T.)

RETURN .T.

/*
// Registra el Documento de CxP
*/
FUNCTION HACERREGISTRO()
   LOCAL oFrm,I,aData:=ACLONE(oCalLph:oBrw:aArrayData),uValue,aCuentas:={}
   LOCAL cTipIva,cNumero,nPorIva:=0,nTotal:=0,nMtoIva:=0

   FOR I=1 TO LEN(aData)

     uValue:=aData[I,3]
     IF Empty(SQLGET("DPCTA","CTA_CODIGO","CTA_CODIGO"+GetWhere("=",uValue)))

        MensajeErr("Cuenta Contable "+ aData[I,3] + " no está Registrada")
        oCalLph:oBrw:nArrayAt:=I
        oCalLph:oBrw:Refresh(.T.)
        RETURN .F.

      ELSE
 
        SQLUPDATE("NMCONCEPTOS","CON_CUENTA",aData[I,3] ,"CON_CODIGO"+GetWhere("=",aData[I,1]))

      ENDIF

      AADD(aCuentas , {oCalLph:cRefere,;
                       oCalLph:cTipIva,;
                       NIL            ,;
                       aData[I,5]     ,;
                       nPorIva        ,;
                       nMtoIva        ,;
                       nTotal         ,;
                       .F.            ,;
                       aData[I,3]     ,;
                      .T.             ,;
                      .T.             ,;
                      aData[I,2]  })


   NEXT I

   cNumero:=SQLINCREMENTAL("DPDOCPRO","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
                                                   "DOC_TIPDOC"+GetWhere("=",oCalLph:cTipDoc)+" AND "+;
                                                   "DOC_CODIGO"+GetWhere("=",oCalLph:cCodPro)+" AND "+;
                                                   "DOC_ACT=1")

   oFrm:=EJECUTAR("DPDOCCXP",oCalLph:cTipDoc,oCalLph:cCodPro,oCalLph:cTipDoc)

   oProDoc:aDataGrid:=ACLONE(aCuentas)
   oProDoc:oFolder:aEnable[1]:=.T.
   oProDoc:oFolder:Refresh(.T.)

   oProDoc:oDOC_NUMERO:VarPut(cNumero ,.T.)
   oProDoc:oDOC_NUMERO:KeyBoard(13)

   EJECUTAR("DPDOCCXPPUTCTA",oProDoc)
   oProDoc:oFolder:aEnable[1]:=.T.

   // Cierra el Formulario
   oCalLph:Close()

RETURN .T.
/*
// Editar Cuenta
*/

FUNCTION LISTARCTA(uValue)
   LOCAL cCodCta:=oCalLph:oBrw:aArrayData[oCalLph:oBrw:nArrayAt,3]

   DPLBX("DPCTA",NIL,NIL,NIL,NIL,cCodCta)

   oDp:oLbx:GetValue("CTA_CODIGO",oCalLph:oBrw:aCols[3])
   oCalLph:lValCta:=.F.

RETURN .F.
// EOF
