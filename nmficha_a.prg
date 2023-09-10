// Programa   : NMFICHA_A
// Fecha/Hora : 10/08/2004 12:10:53
// Propósito  : Construir la Ficha del Trabajador en Arreglos
// Creado Por : Juan Navas
// Llamado por: REPORTE 
// Aplicación : Nómina
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodIni,cFile,lAdd,cWhere,cOrder,oDlg,oText,oMeter,lEnd)
   LOCAL aStruct:={},cSql,aFields:={},cMemo,cFileScg:="forms\\nmtrabajador.scg",I
   LOCAL aData  :={},aView:={},nAt,uValue,cRefere:="",lParam
   LOCAL oTable,oBtn
   LOCAL cCodFin,oLee
   LOCAL aRecord:={}

   CURSORWAIT()

   lParam:=(!cWhere=NIL)

   DEFAULT cCodIni:=SQLGET("NMTRABAJADOR","CODIGO"),cCodFin:=cCodIni,cFile:=oDp:cPathScr+"FICHATRAB.DBF",lAdd:=.T.

   // oText:SetText("Leyendo Campos de Trabajadores")
   // Tabla de Datos    

   AADD(aStruct,{"CODIGO"  ,"C",10,0})
   AADD(aStruct,{"CAMPO"   ,"C",10,0})
   AADD(aStruct,{"DESCRI"  ,"C",40,0})
   AADD(aStruct,{"VALOR"   ,"C",40,0})
   AADD(aStruct,{"REFERE"  ,"C",40,0}) // Referencia

   // Campos
   AADD(aFields,{"CODIGO"   ,"","",""})
   AADD(aFields,{"APELLIDO" ,"","",""})
   AADD(aFields,{"NOMBRE"   ,"","",""})
   AADD(aFields,{"FECHA_ING","","",""})
   AADD(aFields,{"CONDICION","","",""})
   AADD(aFields,{"TIPO_CED" ,"","",""})
   AADD(aFields,{"CEDULA"   ,"","",""})
   AADD(aFields,{"TIPO_NOM" ,"","",""})
   AADD(aFields,{"FORMA_PAG","","",""})

   // Obtiene los Datos según la Ficha de Carga de Datos
   cMemo :=MemoRead(cFileScg)
   cMemo :=STRTRAN(cMemo,CHR(13),"")
   aData :=_VECTOR(cMemo,CHR(10))

   FOR I=1 TO LEN(aData)

      aData[I]   :=_VECTOR(aData[I],CHR(9))
      aData[I,03]:=STRTRAN(aData[I,03],CHR(8),CRLF)
      aData[I,04]:=STRTRAN(aData[I,04],CHR(8),CRLF)
      aData[I,05]:=STRTRAN(aData[I,05],CHR(8),CRLF)
      aData[I,06]:=STRTRAN(aData[I,06],CHR(8),CRLF) 
      aData[I,07]:=STRTRAN(aData[I,07],CHR(8),"")
      aData[I,08]:=STRTRAN(aData[I,08],CHR(8),"")

      nAt:=ASCAN(aFields,{|a|a[1]==aData[I,1]})

      IF nAt=0
        AADD(aFields,{aData[I,1],aData[I,2],aData[I,07]})
      ENDIF

   NEXT I

   // Complementa los Datos según la Estructura del Trabajador    " AND FCH_DESDE " +GetWhere(">=",oFrmTxt:ddesde)+;
   // lAdd:=.T. Indica los Campos no Visuales de la Ficha
   // original  oTable:=OpenTable("SELECT CAM_NAME,CAM_DESCRI FROM DPCAMPOS WHERE CAM_TABLE='NMTRABAJADOR'",.T.)
/*  QUITADO TJ
   oTable:=OpenTable("SELECT CAM_NAME,CAM_DESCRI FROM DPCAMPOS ;
                      WHERE CAM_TABLE" +GetWhere("=",'NMTRABAJADOR'),.T.)

   oTable:GoTop()
   WHILE !oTable:Eof()
     nAt:=ASCAN(aFields,{|a,n|ALLTRIM(a[1])==ALLTRIM(oTable:CAM_NAME)})
     IF nAt=0
       AADD(aFields,{oTable:CAM_NAME,oTable:CAM_DESCRI,"","",""})
     ENDIF
     IF nAt>0 .AND. EMPTY(aFields[nAt,2])
       aFields[nAt,2]:=oTable:CAM_DESCRI
     ENDIF
     oTable:DbSkip()
   ENDDO
   oTable:End()
*/
   /*
   // Lee trabajador por Trabajador y Genera una Nueva Estructura
   */
   IF EMPTY(cWhere) .AND. !lParam
      cWhere:=" WHERE (CODIGO"+GetWhere(">=",cCodIni)+" AND CODIGO"+GetWhere("<=",cCodFin)+")"
   ENDIF

   cOrder:=IIF( EMPTY(cOrder) , " ORDER BY CODIGO " , cOrder )
  
   oLee:=OpenTable("SELECT CODIGO FROM NMTRABAJADOR "+cWhere+cOrder,.T.)
   oMeter:SetTotal(oLee:RecCount())

   oLee:Gotop()

   WHILE !oLee:Eof() .AND. !lEnd

      oTable:=OpenTable("SELECT * FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",oLee:CODIGO),.T.)

      IF oLee:Recno()=1
         AEVAL(oTable:aFields,{|a,n|PUBLICO(a[1],NIL)})
      ENDIF

      FOR I=1 TO LEN(aFields)
    
         nAt    :=oTable:FieldPos(aFields[I,1])
         uValue :=oTable:FieldGet(nAt)
         cRefere:=""

         IF Empty(aFields[I,2])
            aFields[I,2]:=SQLGET("DPCAMPOS","CAM_DESCRI","CAM_TABLE"+GetWhere("=","NMTRABAJADOR")+" AND CAM_NAME"+GetWhere("=",aFields[I,1]))
         ENDIF

         AEVAL(oTable:aFields,{|a,n|PUBLICO(a[1],oTable:FieldGet(n))})

         IF ValType(uValue)="C".AND.!EMPTY(SAYOPTIONS("NMTRABAJADOR",aFields[I,1],uValue))
            uValue:=SAYOPTIONS("NMTRABAJADOR",aFields[I,1],uValue)
         ENDIF

         IF !EMPTY(aFields[I,3])
            cRefere:=MacroEje(aFields[I,3])
         ENDIF

         AADD(aRecord,{ALLTRIM(aFields[I,2])+":",;
                      uValue      ,;
                      cRefere,;
                      aFields[I,1]})

      NEXT I
              
      oLee:DbSkip()
      oTable:End()

   ENDDO
 
   AEVAL(aRecord,{|a,n|aRecord[n,1]:=GetFromVar(aRecord[n,1])})
   AEVAL(oTable:aFields,{|a,n|__MXRELEASE(a[1])})

   oTable:End()
   oLee:End()

   VIEW_FICHA(aRecord,cCodIni)

RETURN .t.

FUNCTION VIEW_FICHA(aRecord,cCodTra)
  LOCAL oDlg,oFont,oFontB,oBrw
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )
  LOCAL cTitle:="Ficha del Trabajador ["+ALLTRIM(cCodTra)+"]"

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  DpMdi(cTitle,"oFichaT","NMFICHAT.edt")

  oFichaT:Windows(0,0,aCoors[3]-150,MIN(aCoors[4],780+170),.T.) // Maximizado

  oFichaT:cCodTra  :=cCodTra
  oFichaT:cTrabajad:=SQLGET("NMTRABAJADOR",[CONCAT(APELLIDO,"",NOMBRE)],"CODIGO"+GetWhere("=",cCodTra))
  oFichaT:cNombre  :=oFichaT:cTrabajad

  oDlg:=oFichaT:oWnd

  oBrw:=TXBrowse():New( oFichaT:oWnd )

  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aRecord, .F. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .F.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 1

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

//  oBrw:CreateFromCode()

  oBrw:aCols[1]:cHeader:="Descripción del Campo"
  oBrw:aCols[1]:nWidth :=185+20
  oBrw:aCols[1]:nDataStrAlign:= AL_RIGHT
  oBrw:aCols[1]:nHeadStrAlign:= AL_RIGHT

  oBrw:aCols[2]:cHeader  :="Valor"
  oBrw:aCols[2]:nWidth   :=235
  oBrw:aCols[2]:oDataFont:=oFontB

  oBrw:aCols[3]:cHeader:="Referencia"
  oBrw:aCols[3]:nWidth :=305-20

  oBrw:aCols[4]:cHeader:="Nombre del Campo"
  oBrw:aCols[4]:nWidth :=165


//  oBrw:bClrHeader:= {|| {0,14671839 }}
//  oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}



  oBrw:bClrStd   :={|oBrw,cCod,nClrText|oBrw:=oFichaT:oBrw,;
                               nClrText:=0,;
                               {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }

  oBrw:aCols[2]:bClrStd     :={|oBrw|oBrw:=oFichaT:oBrw,;
                               IIF(oBrw:nArrayAt%2=0,{CLR_BLACK,15790320},{CLR_BLUE,16382457})}

  oBrw:aCols[3]:bClrStd     :={|oBrw|oBrw:=oFichaT:oBrw,;
                               IIF(oBrw:nArrayAt%2=0,{CLR_BLACK,15790320},{CLR_RED,16382457})}

//oBrw:bLDblClick:={|oBrw,cCodCon|oBrw:=oFichaT:oBrw,cCodCon:=oBrw:aArrayData[oBrw:nArrayAt,1],;
//                   EJECUTAR("NMRECVIEW",oBrw:aArrayData[oBrw:nArrayAt,09])}

  oBrw:SetFont(oFont)

  oBrw:CreateFromCode()

  oFichaT:oBrw:=oBrw
 

  oFichaT:oWnd:oClient := oFichaT:oBrw


  oFichaT:oBrw:=oBrw
  oFichaT:Activate({||oFichaT:FICHABAR()})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg
  Memory(-1)

RETURN .T.


/*
// Coloca la Barra de Botones
*/
FUNCTION FICHABAR()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFichaT:oWnd

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\XPRINT.BMP";
          ACTION oFichaT:FICHAIMP(oFichaT)

   oBtn:cToolTip:="Imprimir Ficha"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\AUDITORIAXCAMPO.BMP";
          ACTION oFichaT:VERAUDITA()

   oBtn:cToolTip:="Auditoría por Campo"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\XCOPY.BMP";
          ACTION oFichaT:COPIARNCLP()

   oBtn:cToolTip:="Copiar en ClipBoard"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\HTML.BMP";
          ACTION EJECUTAR("BRWTOHTML",oFichaT:oBrw)

   oBtn:cToolTip:="Generar Archivo html"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oFichaT:oBrw)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oFichaT:oBrw,oFichaT:cTitle,oFichaT:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xTOP.BMP";
          ACTION (oFichaT:oBrw:GoTop(),oFichaT:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xSIG.BMP";
          ACTION (oFichaT:oBrw:PageDown(),oFichaT:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xANT.BMP";
          ACTION (oFichaT:oBrw:PageUp(),oFichaT:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\xFIN.BMP";
          ACTION (oFichaT:oBrw:GoBottom(),oFichaT:oBrw:Setfocus())

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\\XSALIR.BMP";
          ACTION oFichaT:Close()

  oFichaT:oBrw:SetColor(0,15790320)

//  @ 0.1,60 SAY oFichaT:cTrabajad OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

/*
// Imprimir Ficha del Trabajador
*/
FUNCTION FICHAIMP(oFichaT)
  LOCAL aData:={oDp:cCodTraIni,oDp:cCodTraFin}

  oDp:cCodTraIni:=oFichaT:cCodTra
  oDp:cCodTraFin:=oFichaT:cCodTra

  REPORTE("0000000011")

  oDp:cCodTraIni:=aData[1]
  oDp:cCodTraFin:=aData[2]

RETURN .T.

FUNCTION COPIARNCLP()
   LOCAL cMemo:="",nLen:=10

   AEVAL(oFichaT:oBrw:aArrayData,{|a,n|nLen:=MAX(nLen,LEN(a[1])) })

   AEVAL(oFichaT:oBrw:aArrayData,{|a,n|cMemo:=cMemo+PADR(a[1],nLen)+":"+CTOO(a[2],"C")+CRLF})

   CLPCOPY(cMemo)

   MensajeErr("Ficha Copiada en ClipBoard")

RETURN .T.

FUNCTION VERAUDITA()
   LOCAL cCampo:=oFichaT:oBrw:aArrayData[oFichaT:oBrw:nArrayAt,4]
   LOCAL cWhere:="AEM_TABLA"+GetWhere("=","NMTRABAJADOR")+" AND AEM_CLAVE"+GetWhere("=",oFichaT:cCodTra)

//   cWhere:=oCampos:cWhere

   EJECUTAR("BRDPAUDITAEMC","NMTRABAJADOR",cWhere,cCampo,oFichaT:cCodTra,oFichaT:cNombre)

RETURN .T.
// EOF

// EOF
