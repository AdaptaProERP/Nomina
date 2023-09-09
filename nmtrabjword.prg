// Programa   : NMTRABJWORD
// Fecha/Hora : 12/05/2004 00:53:10
// Propósito  : Cartas Emitas por Trabajador
// Creado Por : Juan Navas
// Llamado por: NMCONCEPTOS
// Aplicación : Nómina
// Tabla      : 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
  LOCAL aArticulo :={}
  LOCAL aMemo     :={}
  LOCAL aContenido:={}
  LOCAL aTodos    :={}
  LOCAL oDlg,oBrw,oFont,I,uValue,oFontB,oSintax,oMemo,oEjemplo
  LOCAL cFind    :=SPACE(65)
  LOCAL oTable,oData,aCampos,oGet,cName
  LOCAL aCoors  :=GetCoors( GetDesktopWindow() )

  DEFAULT cCodTra:="1002"

  CursorWait()

  oTable:=OpenTable("SELECT CAM_DESCRI,CAM_NAME FROM DPCAMPOS WHERE CAM_TABLE='NMTRABAJADOR' ORDER BY CAM_NAME",.T.)
  aCampos:=ACLONE(oTable:aDataFill)
  oTable:End()

  AADD(aCampos,{"Ciudad"               ,"@CIUDAD"          })
  AADD(aCampos,{"Firmante"             ,"@FIRMANTE"        })
  AADD(aCampos,{"Fecha del Sistema"    ,"@FECHA"           })
  AADD(aCampos,{"Fecha Escrita"        ,"@FECHAESCRITA"    })
  AADD(aCampos,{"Firmante Cargo"       ,"@CARGOFIRMANTE"   })
  AADD(aCampos,{"Salario Diarios"      ,"@SALARIODIA"      }) 
  AADD(aCampos,{"Salario Mensual"      ,"@SALARIOMES"      }) 
  AADD(aCampos,{"Nombre de la Empresa" ,"@EMPRESA"         }) 
  AADD(aCampos,{"Dia"                  ,"@DD"              })
  AADD(aCampos,{"Mes"                  ,"@MES"             })
  AADD(aCampos,{"Año"                  ,"@AÑO"             })
  AADD(aCampos,{"Ciudadano(a)"         ,"@CIUDADANO"       }) 
  AADD(aCampos,{"Díario en Letras"     ,"@SALARIODIAEL"    }) 
  AADD(aCampos,{"Mensual en Letras"    ,"@SALARIOMESEL"    }) 

  AADD(aCampos,{"Observación 1"     ,"@OBSERVACION1"    })
  AADD(aCampos,{"Observación 2"     ,"@OBSERVACION2"    })
  AADD(aCampos,{"Observación 3"     ,"@OBSERVACION3"    })

  AADD(aCampos,{"Fecha 1      "     ,"@FECHA1"          })
  AADD(aCampos,{"Fecha 2      "     ,"@FECHA2"          })
  AADD(aCampos,{"Fecha 3      "     ,"@FECHA3"          })

  AADD(aCampos,{"Monto 1      "    ,"@MONTO1"          })
  AADD(aCampos,{"Monto 2      "    ,"@MONTO2"          })
  AADD(aCampos,{"Monto 3      "    ,"@MONTO3"          })

  AADD(aCampos,{"Apellido y Nombre"      ,"@APELLIDOYNOMBRE" })
  AADD(aCampos,{"Nombre del Cargo"       ,"@NOMBREDELCARGO"  })
  AADD(aCampos,{"Nombre del Dpto"        ,"@NOMBREDELDPTO"   })
  AADD(aCampos,{"Nombre del Grupo"       ,"@NOMBREDELGRUPO"  }) 
  AADD(aCampos,{"Nombre Und Funcional"   ,"@NOMBREDEUNDFUNC" }) 
  AADD(aCampos,{"Nombre del Banco"       ,"@NOMBREDELBANCO"  }) 


  oTable:=OpenTable("SELECT DOC_DESCRI,DOC_MEMO FROM NMDOCWORD ORDER BY DOC_DESCRI",.T.)
  aTodos:=ACLONE(oTable:aDataFill)
  oTable:End()

  IF EMPTY(aTodos) 
     AADD(aTodos,{"Ninguna                        ",""})
  ENDIF

  cName:="_"+UPPE(STRTRAN(aTodos[1,1]," ",""))

  oData:=DATASET("CARTAS","ALL")
  oData:=DATASET(cName,"ALL")

  oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  oFrmWord:=DPEDIT():New("Emisión de Cartas para el Trabajador","NMTRABJWORD.edt","oFrmWord",.T.)
  oFrmWord:cFileChm:="CAPITULO2.CHM"
  oFrmWord:cTopic  :="NMTRABJWORD"
  oFrmWord:cCodTra :=cCodTra
  oFrmWord:cTrabajad:=ALLTRIM(oTable:APELLIDO)+", "+ALLTRIM(oTable:NOMBRE)
  oFrmWord:cNameData:=cName
  oFrmWord:cMemo    :=aTodos[1,2]
  oFrmWord:lEscClose:=.T.
  oFrmWord:bRunAct  :=NIL // ACTIVIDAD DEL TRABAJADOR


  // Datos del Formulario
  oFrmWord:cCiudad   :=oData:Get("cCiudad"   ,SPACE(30))   // Ubicación Bancos
  oFrmWord:cFirNombre:=oData:Get("cFirNombre",SPACE(30))
  oFrmWord:cFirCargo :=oData:Get("cFirCargo" ,SPACE(30))

  oFrmWord:cObs1     :=oData:Get("cObs1"  ,SPACE(60))     // Comentarios  
  oFrmWord:cObs2     :=oData:Get("cObs2"  ,SPACE(60))
  oFrmWord:cObs3     :=oData:Get("cObs3"  ,SPACE(60))

  oFrmWord:nNum1     :=oData:Get("nNum1"  ,0.00)     // Comentarios  
  oFrmWord:nNum2     :=oData:Get("nNum2"  ,0.00)
  oFrmWord:nNum3     :=oData:Get("nNum3"  ,0.00)

  oFrmWord:dFecha1   :=oData:Get("dFecha1",CTOD(""))     // Comentarios  
  oFrmWord:dFecha2   :=oData:Get("dFecha2",CTOD(""))
  oFrmWord:dFecha3   :=oData:Get("dFecha3",CTOD(""))

  oData:ClassName()
  oTable:End()

  @ 5,0 SAY "Ciudad:" RIGHT
  @ 6,0 SAY "Persona Firmante:" RIGHT
  @ 7,0 SAY "Cargo del Firmante:" RIGHT

  @ 5,10 GET oFrmWord:oCiudad VAR oFrmWord:cCiudad
  oFrmWord:oCiudad:cToolTip:="Ciudad"

  @ 6,10 GET oFrmWord:oFirNombre VAR oFrmWord:cFirNombre
  @ 7,10 GET oFrmWord:oFirCargo  VAR oFrmWord:cFirCargo

  @ 6,02 GET oFrmWord:oObs1 VAR oFrmWord:cObs1
  oFrmWord:oObs1:cToolTip:="Observación 1"
  oFrmWord:oObs1:cMsg    :="Observación 3"

  @ 7,02 GET oFrmWord:oObs2 VAR  oFrmWord:cObs2
  oFrmWord:oObs2:cToolTip:="Observación 2"
  oFrmWord:oObs2:cMsg    :="Observación 2"

  @ 8,02 GET oFrmWord:oObs3 VAR oFrmWord:cObs3
  oFrmWord:oObs3:cToolTip:="Observación 3"
  oFrmWord:oObs3:cMsg    :="Observación 3"

  @10,02 GET oFrmWord:oNum1 VAR oFrmWord:nNum1 PICTURE "999,999,999.99" RIGHT
  oFrmWord:oNum1:cToolTip:="Monto 1"
  oFrmWord:oNum1:cMsg    :="Monto 1"

  @11,02 GET oFrmWord:oNum2 VAR oFrmWord:nNum2 PICTURE "999,999,999.99" RIGHT
  oFrmWord:oNum2:cToolTip:="Monto 2"
  oFrmWord:oNum2:cMsg    :="Monto 2"

  @12,02 GET oFrmWord:oNum3 VAR oFrmWord:nNum3 PICTURE "999,999,999.99" RIGHT
  oFrmWord:oNum3:cToolTip:="Monto 3"
  oFrmWord:oNum3:cMsg:="Monto 3"

  @10,10 GET oFrmWord:oFecha1 VAR oFrmWord:dFecha1 PICTURE "99/99/9999" RIGHT
  oFrmWord:oFecha1:cToolTip:="Fecha 1"
  oFrmWord:oFecha1:cMsg    :="Fecha 1"

  @11,10 GET oFrmWord:oFecha2 VAR oFrmWord:dFecha2 PICTURE "99/99/9999" RIGHT
  oFrmWord:oFecha2:cToolTip:="Fecha 2"
  oFrmWord:oFecha2:cMsg    :="Fecha 2"

  @12,10 GET oFrmWord:oFecha3 VAR oFrmWord:dFecha3 PICTURE "99/99/9999" RIGHT
  oFrmWord:oFecha3:cToolTip:="Fecha 3"
  oFrmWord:oFecha3:cMsg    :="Fecha 3"

  @ 6, 5 GET oFrmWord:oMemo VAR oFrmWord:cMemo  ;
         MEMO SIZE 80,120; 
         READONLY;
         ON CHANGE 1=1

  oBrw:=TXBrowse():New( oDlg )

//  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aTodos    , .T. )
  oBrw:lHScroll            := .F.
  oBrw:oFont               :=oFont
  oBrw:bClrStd             :={|oBrw|oBrw:=oFrmWord:oBrw,{0, iif( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2 ) } }

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:CreateFromCode()
  oBrw:aCols[1]:cHeader:="Documentos"
  oBrw:aCols[1]:nWidth :=280+5

 //  oBrw:bClrHeader:= {|| {0,14671839 }}
 // oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oBrw:bClrStd := {|oBrw|oBrw:=oFrmWord:oBrw,{0, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }
  oBrw:SetFont(oFont)
  oBrw:bChange :={||oFrmWord:CambiarDat()}
  oBrw:DelCol(2)

  oFrmWord:oBrw:=oBrw

  // Diccionario de Datos

  oBrw:=TXBrowse():New( oDlg )

//  oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
  oBrw:SetArray( aCampos , .T. )
  oBrw:lHScroll            := .F.
  oBrw:oFont               :=oFont

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:CreateFromCode()
  oBrw:aCols[1]:cHeader:="Descripción"
  oBrw:aCols[1]:nWidth :=270+120

  oBrw:aCols[2]:cHeader:="Campo"
  oBrw:aCols[2]:nWidth :=180+130

//  oBrw:bClrHeader:= {|| {0,14671839 }}
//  oBrw:bClrFooter:= {|| {0,14671839 }}

  oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

//oBrw:bClrStd :={|oBrw|oBrw:=oFrmWord:oBrwD,{0, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }
  oBrw:bClrStd :={|oBrw|oBrw:=oFrmWord:oBrwD,{0, iif( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2 ) } }

  oBrw:SetFont(oFont)

  oBrw:bLDblClick:={|oBrw,cCampo|oBrw  :=oFrmWord:oBrwD,;
                                 cCampo:=oBrw:aArrayData[oBrw:nArrayAt,2],;
                                 cCampo:="{"+cCampo+"}",;
                                 ClpCopy(cCampo),;
                                 MensajeErr(cCampo+" Copiado en Clipboard","Proceso Ejecutado")}

  oFrmWord:oBrwD:=oBrw

  oFrmWord:Activate({||oFrmWord:LeyBar(oFrmWord)})

  IF .T.
    oDp:nDif:=(aCoors[3]-160-oFrmWord:oWnd:nHeight())
    oFrmWord:oWnd:SetSize(NIL,aCoors[3]-160,.T.)
    oFrmWord:oBrwD:SetSize(NIL,oFrmWord:oBrwD:nHeight()+(oDp:nDif-0),.T.)
  ENDIF

  STORE NIL TO oBrw,oDlg,aTodos

RETURN oFrmWord

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oFrmWord)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oFrmWord:oDlg
   
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oFrmWord:CARTARUN(oFrmWord)

   oBtn:cToolTip:="Crear Documento"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\WORD.BMP";
          ACTION oFrmWord:EDITWORD(oFrmWord)

   oBtn:cToolTip:="Editar Carta Modelo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XMEMO.BMP";
          ACTION oFrmWord:VERMEMO(oFrmWord)

   oBtn:cToolTip:="Ver Explicación de la Carta"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSAVE.BMP";
          ACTION  oFrmWord:SaveDataSet(oFrmWord)

   oBtn:cToolTip:="Grabar los Cambios"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oFrmWord:Close()

  oFrmWord:oBrw:SetColor(0,oDp:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 0.1,60 SAY " "+oFrmWord:cCodTra  +" " OF oBar BORDER SIZE 345,18 BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
  @ 1.3,60 SAY " "+oFrmWord:cTrabajad+" " OF oBar BORDER SIZE 345,18 BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont


RETURN .T.

/*
// Ejecución de Carta
*/
FUNCTION CARTARUN(oFrmWord)
  LOCAL oData,aData:={},oTable,I,aDir:={},uValue
  LOCAL cCarta,oBrw:=oFrmWord:oBrw
  LOCAL cDescri:=oBrw:aArrayData[oBrw:nArrayAt,1]
  LOCAL nSalarioD:=0,nSalarioM:=0
  LOCAL cTempo:=STRTRAN("_"+cTempFile()+".DOC","..",".")
  LOCAL cDir,cFecha:=CFECHA(oDp:dFecha)

  CURSORWAIT()
  
  cCarta:=SqlGet("NMDOCWORD","DOC_FILE","DOC_DESCRI"+GetWhere("=",cDescri))
  cCarta:=STRTRAN(cCarta,"/","\")
  cDir  :=cFilePath(cCarta)

  aDir   := Array( ADir( cDir+"_*.DOC" ) )
  aDir( cDir+"_*.DOC", aDir )
  AEVAl(aDir,{|a,n|FERASE(cDir+a)})

  oData:=DATASET("CARTAS","ALL")

  oData:cCiudad  :=oFrmWord:cCiudad  
  oData:cFirmante:=oFrmWord:cFirNombre
  oData:cFirCargo:=oFrmWord:cFirCargo 

  oData:cObs1    :=oFrmWord:cObs1    
  oData:cObs2    :=oFrmWord:cObs2
  oData:cObs3    :=oFrmWord:cObs3 

  oData:nNum1    :=oFrmWord:nNum1
  oData:nNum2    :=oFrmWord:nNum2 
  oData:nNum3    :=oFrmWord:nNum3 

  oData:dFecha1  :=oFrmWord:dFecha1  
  oData:dFecha2  :=oFrmWord:dFecha2  
  oData:dFecha3  :=oFrmWord:dFecha3  

  oData:End()

  AADD(aData,{"@EMPRESA"      ,oDp:cEmpresa})
  AADD(aData,{"@FECHA"        ,oDp:dFecha  })
  AADD(aData,{"@FECHAESCRITA" ,cFecha      })
  AADD(aData,{"@CIUDAD"       ,ALLTRIM(oFrmWord:cCiudad)})  
  AADD(aData,{"@FIRMANTE"     ,ALLTRIM(oFrmWord:cFirNombre)})
  AADD(aData,{"@CARGOFIRMANTE",ALLTRIM(oFrmWord:cFirCargo)}) 
  AADD(aData,{"@DD"           ,STRZERO(DAY(oDp:dFecha),2)})
  AADD(aData,{"@MES"          ,CMES(oDp:dFecha)})
  AADD(aData,{"@AÑO"          ,STRZERO(YEAR(oDp:dFecha),4)})

  AADD(aData,{"@OBSERVACION1" ,oFrmWord:cObs1})
  AADD(aData,{"@OBSERVACION2" ,oFrmWord:cObs2})
  AADD(aData,{"@OBSERVACION3" ,oFrmWord:cObs3})

  AADD(aData,{"@FECHA1"       ,oFrmWord:dFecha1})
  AADD(aData,{"@FECHA2"       ,oFrmWord:dFecha2})
  AADD(aData,{"@FECHA3"       ,oFrmWord:dFecha3})

  AADD(aData,{"@MONTO1"       ,oFrmWord:nNum1})
  AADD(aData,{"@MONTO2"       ,oFrmWord:nNum2})
  AADD(aData,{"@MONTO3"       ,oFrmWord:nNum3})

  oTable:=OpenTable("SELECT * FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",oFrmWord:cCodTra),.T.)

  CURSORWAIT()

  FOR I=1 TO LEN(oTable:aFields)

     uValue:=oTable:FieldGet(I)

     IF ValType(uValue)="C"
        uValue:=SAYOPTIONS("NMTRABAJADOR",oTable:FieldName(i),uValue)
     ENDIF

     AADD(aData,{oTable:aFields[I,1],uValue})

  NEXT I

  nSalarioD:=IIF(oTable:TIPO_NOM ="S",oTable:SALARIO,DIV(oTable:SALARIO,30))
  nSalarioM:=IIF(oTable:TIPO_NOM!="S",oTable:SALARIO,oTable:SALARIO*30     )

  AADD(aData,{"@APELLIDOYNOMBRE",ALLTRIM(oTable:APELLIDO)+", "+ALLTRIM(oTable:NOMBRE)}) 
  AADD(aData,{"@NOMBREDELCARGO" ,SQLGET("NMCARGOS" ,"CAR_DESCRI","CAR_CODIGO"+GetWhere("=",oTable:COD_CARGO ))}) 
  AADD(aData,{"@NOMBREDELDPTO"  ,SQLGET("DPDPTO"   ,"DEP_DESCRI","DEP_CODIGO"+GetWhere("=",oTable:COD_DPTO  ))}) 
  AADD(aData,{"@NOMBREDELGRUPO" ,SQLGET("NMGRUPO"  ,"GTR_DESCRI","GTR_CODIGO"+GetWhere("=",oTable:GRUPO     ))}) 
  AADD(aData,{"@NOMBREDEUNDFUNC",SQLGET("NMUNDFUNC","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oTable:COD_UND   ))}) 
  AADD(aData,{"@NOMBREDELBANCO" ,SQLGET("NMBANCOS" ,"BAN_NOMBRE","BAN_CODIGO"+GetWhere("=",oTable:BANCO     ))}) 
  AADD(aData,{"@CIUDADANO"    ,"CIUDADANO"+IIF(oTable:SEXO="M","0","A")})

  AADD(aData,{"@SALARIODIA"     ,ALLTRIM(TRAN(nSalarioD,"999,999,999.99"))}) 
  AADD(aData,{"@SALARIOMES"     ,ALLTRIM(TRAN(nSalarioM,"999,999,999.99"))}) 

  AADD(aData,{"@SALARIODIAEL"   ,ENLETRAS(nSalarioD)}) 
  AADD(aData,{"@SALARIOMESEL"   ,ENLETRAS(nSalarioM)}) 

  oTable:End()

  cTempo:=cFilePath(cCarta)+cTempo

//  ? cTempo,cCarta
  CursorWait()

  EJECUTAR("WORDBUILD",cCarta,cTempo,aData)

  IIF(ValType(oFrmWord:bRunAct)="B",Eval(oFrmWord:bRunAct),NIL)

RETURN  NIL 
/*
// Ejecución de Carta
*/
FUNCTION EDITWORD(oFrmWord)
  LOCAL oTable,cCarta,oBrw:=oFrmWord:oBrw
  LOCAL cDescri:=oBrw:aArrayData[oBrw:nArrayAt,1]

  cCarta:=SqlGet("NMDOCWORD","DOC_FILE","DOC_DESCRI"+GetWhere("=",cDescri))

  cCarta:=STRTRAN(cCarta,"/","\")

  EJECUTAR("RUNWORD",cCarta)

  STORE NIL TO oBrw

RETURN .T

FUNCTION SaveDataSet(oFrm)
  LOCAL oData

  oData:=DATASET(oFrmWord:cNameData,"ALL") // Antes "CARTAS"

  oData:Set("cCiudad"   ,oFrm:cCiudad   )   // Ubicación Datos
  oData:Set("cFirNombre",oFrm:cFirNombre)
  oData:Set("cFirCargo" ,oFrm:cFirCargo )

  oData:Set("cObs1" ,oFrm:Get("cObs1"  ))     // Comentarios  
  oData:Set("cObs2" ,oFrm:Get("cObs2"  ))
  oData:Set("cObs3" ,oFrm:Get("cObs3"  ))

  oData:Set("nNum1" ,oFrm:Get("nNum1"  ))     // Comentarios  
  oData:Set("nNum2" ,oFrm:Get("nNum2"  ))
  oData:Set("nNum3" ,oFrm:Get("nNum3"  ))

  oData:Set("dFecha1",oFrm:Get("dFecha1"))     // Comentarios  
  oData:Set("dFecha2",oFrm:Get("dFecha2"))
  oData:Set("dFecha3",oFrm:Get("dFecha3"))

  oData:Save()
  oData:End()

RETURN .T.

FUNCTION VERMEMO(oFrm)
  LOCAL cMemo,oBrw:=oFrm:oBrw,oWnd

  LOCAL oDlg,nHeight:=310+25,nWidth:=315,nTop:=155,nLeft:=35-30,oWnd,oGrp,aPoint
  LOCAL oFont,oFontB,oBtn
  LOCAL nColor:=oDp:nGris,lAceptar:=.F.,lSalir:=.F.,cWhere:="",oTable

  cMemo:=SQLGET("NMDOCWORD","DOC_MEMO","DOC_DESCRI"+GetWhere("=",oBrw:aArrayData[oBrw:nArrayAt,1]))
  cMemo:=ALLTRIM(cMemo)

  oWnd:=IIF(ValType(oFrm)="O",oFrm:oDlg,oDp:oFrameDp)

  DEFINE FONT oFont  NAME "MS Sans Serif"   SIZE 0, -12
  DEFINE FONT oFontB NAME "MS Sans Serif"   SIZE 0, -12 BOLD

//  nColor:=14671839
//  nColor:=16772313
  nColor:=14548991
  oDp:lDlg:=.T.

  DEFINE DIALOG oDlg FROM nTop,nLeft TO nTop+nHeight, nLeft+nWidth ;
         TITLE "Cliente Contado" STYLE nOr( WS_POPUP, WS_VISIBLE ) OF oWnd;
         COLOR NIL,nColor PIXEL FONT oFontB
   
  @ .1,.5 GROUP oGrp TO nWidth,nHeight PROMPT "Explicación"

  @ .6, .15 GET cMemo  ;
           MEMO SIZE 157,142+2; 
           READONLY;
           ON CHANGE 1=1;
           FONT oFontB;
           SIZE 40,10;
           COLOR NIL,nColor

  @ 08.6,14.2+6 BUTTON oBtn PROMPT " Salir  " ACTION (lAceptar:=.T.,oDlg:End());
                                              SIZE 32,12 FONT oFontB
                                         
  ACTIVATE DIALOG oDlg  ON INIT;
           oGrp:Move(.1,.5,oDlg:nWidth(),oDlg:nHeight(),.T.)

  oDp:lDlg:=.F.

RETURN lAceptar

/*
// Cambiar DataSet
*/
FUNCTION CambiarDat()
  LOCAL cName
  LOCAL oBrw:=oFrmWord:oBrw,oData
  LOCAL cCiudad,cFirNombre,cFirCargo,cObs1,cObs2,cObs3,nNum1,nNum2,nNum3,dFch1,dFch2,dFch3

  cName:="_"+UPPE(STRTRAN(oBrw:aArrayData[oBrw:nArrayAt,1]," ",""))
  oFrmWord:oMemo:SetText(ALLTRIM(oBrw:aArrayData[oBrw:nArrayAt,2]))

  oData:=DATASET("CARTAS","ALL")
  oData:=DATASET(cName,"ALL")

  oFrmWord:cNameData:=cName

  cCiudad   :=oData:Get("cCiudad"   ,SPACE(30))
  cFirNombre:=oData:Get("cFirNombre",SPACE(30))
  cFirCargo :=oData:Get("cFirCargo" ,SPACE(30))

  cObs1     :=oData:Get("cObs1"  ,SPACE(60))     // Comentarios  
  cObs2     :=oData:Get("cObs2"  ,SPACE(60))
  cObs3     :=oData:Get("cObs3"  ,SPACE(60))

  nNum1     :=oData:Get("nNum1"  ,0.00)     // Comentarios  
  nNum2     :=oData:Get("nNum2"  ,0.00)
  nNum3     :=oData:Get("nNum3"  ,0.00)

  dFecha1   :=oData:Get("dFecha1",CTOD(""))     // Comentarios  
  dFecha2   :=oData:Get("dFecha2",CTOD(""))
  dFecha3   :=oData:Get("dFecha3",CTOD(""))

  IIF(Empty(cCiudad   ) , NIL , oFrmWord:oCiudad   :VarPut(cCiudad    , .T. ))
  IIF(Empty(cFirNombre) , NIL , oFrmWord:oFirNombre:VarPut(cFirNombre , .T. ))
  IIF(Empty(cFirCargo ) , NIL , oFrmWord:oFirCargo :VarPut(cFirCargo  , .T. ))

  IIF(Empty(cObs1)      , NIL , oFrmWord:oObs1     :VarPut(cObs1      , .T. ))
  IIF(Empty(cObs2)      , NIL , oFrmWord:oObs2     :VarPut(cObs2      , .T. ))
  IIF(Empty(cObs3)      , NIL , oFrmWord:oObs3     :VarPut(cObs3      , .T. ))

  IIF(Empty(nNum1)      , NIL , oFrmWord:oNum1     :VarPut(cNum1      , .T. ))
  IIF(Empty(nNum2)      , NIL , oFrmWord:oNum2     :VarPut(cNum2      , .T. ))
  IIF(Empty(nNum3)      , NIL , oFrmWord:oNum3     :VarPut(cNum3      , .T. ))

  IIF(Empty(dFch1)      , NIL , oFrmWord:oFch1     :VarPut(dFch1      , .T. ))
  IIF(Empty(dFch2)      , NIL , oFrmWord:oFch2     :VarPut(dFch2      , .T. ))
  IIF(Empty(dFch3)      , NIL , oFrmWord:oFch3     :VarPut(dFch3      , .T. ))

  oData:End(.T.)

RETURN .T.
// EOF


