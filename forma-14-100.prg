// Programa   : FORMA-14-100
// Fecha/Hora : 26/08/2004 08:38:14
// Propósito  : Planilla de SSO
// Creado Por : Juan Navas
// Llamado por: NMMENU
// Aplicación : Nómina
// Tabla      : FORMA-14-100
// Modificacion:  Cambiado la forma de visualizar los Años ahora presenta primero 
// el año reciente  Leonardo Palleschi/ Revisado TJ

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"

PROCE MAIN(cCodTra,cNombre)
  LOCAL oBtn,oFont,aData,nClrText:=CLR_BLUE,cSql,aTotal:={}
  LOCAL oTable,oCol,oBrw,oData,cSql,i,aData:={},nAno:=year(oDp:dFecha),nMeses:=0,cAno:="",cMes,nAt:=0,aAno:={}
  LOCAL oFontHead,oFontBrw,aCodCon,dFchIng,cWhere

  DEFAULT cCodTra:=SQLGET("NMRECIBOS","REC_CODTRA"),;
          cNombre:=SQLGET("NMTRABAJADOR","APELLIDO","CODIGO"+GetWhere("=",cCodTra))
   
  dFchIng:=SQLGET("NMTRABAJADOR","FECHA_ING","CODIGO"+GetWhere("=",cCodTra))

  cWhere:=GetWhereOr("HIS_CODCON",ATABLE("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_CODIGO<='DZZZ' AND (CON_ACUM01=1 OR CON_ACUM02=1 OR CON_ACUM03=1 OR CON_ACUM04=1)"))

  cSql:=" SELECT SUM(HIS_MONTO) AS HIS_MONTO, MONTH(FCH_HASTA) AS MES ,YEAR(FCH_HASTA) AS ANO "+;
        " FROM NMHISTORICO "+;
        " INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO "+;
        " INNER JOIN NMFECHAS  ON FCH_NUMERO=REC_NUMFCH "+;
        " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
        "   AND FCH_DESDE "+GetWhere(">=",dFchIng)+;
        "   AND "+cWhere+;
        " GROUP BY MONTH(FCH_HASTA),YEAR(FCH_HASTA) "+;
        " ORDER BY FCH_HASTA "

  oTable:=OpenTable(cSql,.t.)

//oTable:Browse()

  IF oTable:RecCount()>0
    oTable:GoBottom()
    nAno :=CTOO(oTable:ANO,"N")
  ENDIF

  aData:={}
  FOR I=1 TO 12
    AADD(aData,{CMES(I),0,0,0,0,0,0})
  NEXT I

//? cMes,"cMes"

  aTotal:=ARRAY(6)
  AEVAL(aTotal,{|a,n|aTotal[n]:=0})
  aAno:={}

  AEVAL(oTable:aDataFill,{|a,n| oTable:aDataFill[n,2]:=CTOO(a[2],"C"),;
                                oTable:aDataFill[n,3]:=CTOO(a[3],"C")})


 //oTable:Browse()

  FOR I=6 TO 1 STEP -1
    cAno:=STRZERO(nAno,4)
    AADD(aAno,cAno)
    FOR nMeses=1 TO 12
      cMes:=ALLTRIM(STR(nMeses))
      nAt :=ASCAN(oTable:aDataFill,{|a,n|a[2]==cMes .AND. a[3]==cAno})
      IF nAt>0
        aData[nMeses,I+1]:=oTable:aDataFill[nAt,1]
        aTotal[I]:=aTotal[I]+oTable:aDataFill[nAt,1]
      ENDIF
    NEXT nMeses

    nAno:=nAno-1
  NEXT I

  oTable:End()

  CURSORWAIT()

  DEFINE FONT oFont     NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontBrw  NAME "Tahoma" SIZE 0, -11    
  DEFINE FONT oFontHead NAME "Tahoma" SIZE 0, -10 BOLD  

  oData:=DATASET("NOMINA","ALL",,,,"CMINTRA,CLUGAR,CINFORM,CPICTSSO,CSSO")

  oF14100:=DPEDIT():New("Forma 14-100 ","NMFORMA14100.EDT","oF14100",.T.)

  oF14100:nCant     :=0
  oF14100:nPag      :=1 // Cantidad de Páginas
  oF14100:cDir      :=PADR(ALLTRIM(oDp:cDir1)+" "+ALLTRIM(oDp:cDir2)+" "+ALLTRIM(oDp:cDir3),80)
   
  oF14100:cMinTra    :=oData:Get("cMinTra"   ,SPACE(10))
  oF14100:cPictSSO   :=oData:Get("cPictSSO"  ,"9999999")
  oF14100:cSSO       :=oData:Get("cSSO"      ,SPACE(10))
  oF14100:cInform    :=oData:Get("cInform"   ,PADR(oDp:cUsNombre,30))   // Informante
  oF14100:cCargo     :=oData:Get("cCargo"    ,SPACE(30))                // Cargo del Firmante
  oF14100:cRepres    :=oData:Get("cRepres"   ,SPACE(40))                // Representante
  oF14100:nCedula    :=oData:Get("nCedula"   ,0        )                // Cédula
  oF14100:nCIFIRM    :=oData:Get("nCIFIRM"   ,0        )                // Cédula del Firmante

  oF14100:cTelefono  :=oData:Get("ctelefo"   ,SPACE(12))                // Cédula
  oF14100:cLugar     :=oData:Get("cLugar"    ,SPACE(30))                // cLugar 
  oF14100:lRun       :=.T.
  oF14100:dFecha     :=oDp:dFecha
  oF14100:cNombre    :=cNombre
  oF14100:cCodigo    :=cCodTra
  oF14100:dDesde     :=FCHINIMES(oDp:dFecha)
  oF14100:dHasta     :=FCHFINMES(oDp:dFecha)
  oF14100:lSueldos   :=.T.
  oF14100:lPerRep    :=.T.
  oF14100:cPictSSO   :=PADR(oF14100:cPictSSO,10)
  oF14100:cPicture   :="999,999,999,999.99"
  oF14100:aAno       :=ACLONE(aAno  )
  oF14100:aTotal     :=ACLONE(aTotal)
  oF14100:cObserv    :=SPACE(60)

  oData:End(.F.)

  @ 0.5,0.5 GROUP  oF14100:oGrupo TO 4, 21.5 PROMPT " Trabajador [ "+ALLTRIM(cCodTra)+" ]"
//@ 5.5,0.5 GROUP  oF14100:oGrupo TO 8, 21.5 PROMPT " Patrono "    
//@ 5.5,0.5 GROUP  oF14100:oGrupo TO 8, 21.5 PROMPT " Firmante "    

  @ 1,1 SAY " "+oF14100:cNombre

  @ 5,01 SAY "Nombre del Patrono/Representante"
  @ 5,00 GET oF14100:oRepres VAR oF14100:cRepres

  @ 5,10 SAY "Cédula"
  @ 5,10 GET oF14100:oCedula VAR oF14100:nCedula PICTURE "99999999" RIGHT

  @ 5,20 SAY "Teléfono"
  @ 5,20 GET oF14100:oTelefono VAR oF14100:cTelefono 

  @ 7,0 SAY "Fecha"
  @ 7,1 BMPGET oF14100:oFecha VAR oF14100:dFecha PICTURE "99/99/9999";
        NAME "BITMAPS\Calendar.bmp";
        ACTION LbxDate(oF14100:oFecha,oF14100:dFecha)

  @ 6,0 SAY "Lugar"
  @ 6,0 GET oF14100:oLugar  VAR oF14100:cLugar

  @ 5,1 SAY "Nombre del Firmante"
  @ 5,0 GET oF14100:oInform VAR oF14100:cInform

  @ 5,1 SAY "Cédula"
  @ 5,0 GET oF14100:oCiFirm VAR oF14100:nCIFIRM RIGHT

  oF14100:oCiFirm:cToolTip:="Cédula del Firmante"
  oF14100:oCiFirm:cMsg    :="Cédula del Firmante"

  @ 6,0 SAY "Cargo"
  @ 6,0 GET oF14100:oCargo  VAR oF14100:cCargo

  @ 4,0 SAY "Observaciones"
  @ 4,0 GET oF14100:oObserv  VAR oF14100:cObserv

  oBrw:=TXBrowse():New( oF14100:oDlg )
  oBrw:SetArray( aData )
  oF14100:oBrw:=oBrw
  
  oBrw:SetFont(oFontBrw)

//oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .T.
  oBrw:lFooter  := .T.
  oBrw:nFreeze  := 1

  oCol:=oBrw:aCols[1]
  oCol:cHeader      := "Mes"
  oCol:cFooter      :=""

  oCol:=oBrw:aCols[7]
  oCol:cHeader      := aAno[6]
  oCol:nWidth       := 80
  oCol:cEditPicture :=oF14100:cPicture
  oCol:cFooter      :=TRAN(aTotal[1],oF14100:cPicture)
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nWidth       := 120
  oCol:bStrData     :={|oBrw|oBrw:=oF14100:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,2],oF14100:cPicture)}
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:bOnPostEdit  := {|o, v, n| IIF( n != VK_ESCAPE, oF14100:ResSaveCol( oF14100 , v , 2), ) }

  oCol:=oBrw:aCols[6]
  oCol:cHeader      := aAno[5]
  oCol:cFooter      :=TRAN(aTotal[2],oF14100:cPicture)
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nWidth       := 80
  oCol:cEditPicture :=oF14100:cPicture
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nWidth       := 120
  oCol:bStrData     :={|oBrw|oBrw:=oF14100:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],oF14100:cPicture)}
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:bOnPostEdit  := {|o, v, n| IIF( n != VK_ESCAPE, oF14100:ResSaveCol( oF14100 , v , 3), ) }

  oCol:=oBrw:aCols[5]
  oCol:cHeader      := aAno[4]
  oCol:cFooter      :=TRAN(aTotal[3],oF14100:cPicture)
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nWidth       := 80
  oCol:cEditPicture :=oF14100:cPicture
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nWidth       := 120
  oCol:bStrData     :={|oBrw|oBrw:=oF14100:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],oF14100:cPicture)}
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:bOnPostEdit  := {|o, v, n| IIF( n != VK_ESCAPE, oF14100:ResSaveCol( oF14100 , v , 4), ) }

  oCol:=oBrw:aCols[4]
  oCol:cHeader      := aAno[3]
  oCol:cFooter      :=TRAN(aTotal[4],oF14100:cPicture)
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nWidth       := 80
  oCol:cEditPicture :=oF14100:cPicture
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nWidth       := 120
  oCol:bStrData     :={|oBrw|oBrw:=oF14100:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,5],oF14100:cPicture)}
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:bOnPostEdit  := {|o, v, n| IIF( n != VK_ESCAPE, oF14100:ResSaveCol( oF14100 , v , 5), ) }

  oCol:=oBrw:aCols[3]
  oCol:cHeader      := aAno[2]
  oCol:cFooter      :=TRAN(aTotal[5],oF14100:cPicture)
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nWidth       := 80
  oCol:cEditPicture :=oF14100:cPicture
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nWidth       := 120
  oCol:bStrData     :={|oBrw|oBrw:=oF14100:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,6],oF14100:cPicture)}
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:bOnPostEdit  := {|o, v, n| IIF( n != VK_ESCAPE, oF14100:ResSaveCol( oF14100 , v , 6), ) }

  oCol:=oBrw:aCols[2]
  oCol:cHeader      := aAno[1]
  oCol:cFooter      := TRAN(aTotal[6],oF14100:cPicture)
  oCol:nFootStrAlign:= AL_RIGHT
  oCol:nWidth       := 80
  oCol:cEditPicture := oF14100:cPicture
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:nWidth       := 120
  oCol:bStrData     := {|oBrw|oBrw:=oF14100:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],oF14100:cPicture)}
  oCol:nHeadStrAlign:= AL_RIGHT
  oCol:bOnPostEdit  := {|o, v, n| IIF( n != VK_ESCAPE, oF14100:ResSaveCol( oF14100 , v , 7), ) }

  oF14100:oBrw:bClrStd := {|oBrw|oBrw:=oF14100:oBrw,{0, IIF( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2 ) } }

//  oF14100:oBrw:bClrHeader:= {|| {0,14671839 }}
//  oF14100:oBrw:bClrFooter:= {|| {0,14671839 }}

  oF14100:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oF14100:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


  oF14100:oBrw:CreateFromCode()

  AEVAL(oBrw:aCols,{|oCol,n|oCol:oFooterFont:=oFontHead,oCol:oHeaderFont:=oFontHead})

//  oBrw:bClrHeader := {|| { 0,  12632256}}
/*
  @ 09, 33 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\RUN.BMP" NOBORDER;
           LEFT PROMPT "Ejecutar";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oF14100:SaveNmConfig(oF14100))

  oBtn:cToolTip:="Grabar Datos y Ejecutar Planilla"
  oBtn:cMsg    :=oBtn:cToolTip

  @ 09, 43 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
           LEFT PROMPT "Cancelar";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oF14100:Close()) CANCEL

  oBtn:lCancel :=.T.
  oBtn:cToolTip:="Cancelar y Cerrar Formulario "
  oBtn:cMsg    :=oBtn:cToolTip

  @ 01, 63 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\HELP.BMP" NOBORDER;
           LEFT PROMPT "Instructivo";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_YELLOW, 1} ;
           ACTION EJECUTAR("RUNCHM","FORMA14100","FORMA14100") CANCEL

  oBtn:lCancel :=.T.
  oBtn:cToolTip:="Mostrar Instructivo de la Forma 14-100 del IVSS "
  oBtn:cMsg    :=oBtn:cToolTip
*/

  oF14100:Activate({|| oF14100:FRMONINIT()})

RETURN NIL


FUNCTION FRMONINIT()
  LOCAL oBar,oBtn,oBtn3

  DEFINE BUTTONBAR oBar SIZE 39, 39 3D OF oF14100:oDlg

  DEFINE XBUTTON oBtn ;
         FILE oDp:cPathBitMaps+"PREVIEW.BMP";
         TOOLTIP "Visualizar ";
         SIZE 38,38;
         ACTION oF14100:SaveNmConfig(oF14100) OF oBar

/*
  DEFINE XBUTTON oBtn ;
         FILE oDp:cPathBitMaps+"PRINTER2.BMP";
         TOOLTIP "Imprimir y Registrar";
         SIZE 38,38;
         ACTION oF14100:SaveNmConfig(oF14100,2) OF oBar

  oBtn:cToolTip:="Grabar Datos y Ejecutar Planilla"
  oBtn:cMsg    :=oBtn:cToolTip
*/

  DEFINE XBUTTON oBtn;
         FILE oDp:cPathBitMaps+"\HELP.BMP";
         SIZE 38,38;
         TOOLTIP "Mostrar Instructivo de la Forma 14-02 ";
         ACTION EJECUTAR("RUNCHM","FORMA14100","FORMA14100") OF oBar

  oBtn:lCancel :=.T.
  oBtn:cToolTip:="Mostrar Instructivo de la Forma 14-03 "
  oBtn:cMsg    :=oBtn:cToolTip


  DEFINE XBUTTON oBtn ;
         FILE oDp:cPathBitMaps+"xSalir.BMP";
         TOOLTIP "Grabar";
         SIZE 38,38;
         ACTION oF14100:Close();
         OF oBar

   Aeval(oBar:aControls,{|a,n|a:SetColor(NIL,oDp:nGris)})

   oBar:SetColor(NIL,oDp:nGris)

RETURN .T.



/*
// Grabar Empresa
*/
FUNCTION SaveNmConfig(oF14100)
  LOCAL cFileDbf,cField
  LOCAL cCI,cFchNac,cFchIng,cSalario
  LOCAL oData,oTable,nAnos,nMeses,i,nAno:=0

  CURSORWAIT()

  oData:=DATASET("NOMINA","ALL")

  oData:Set("cInform",oF14100:cInform  )
  oData:Set("cLugar" ,oF14100:cLugar   )
  oData:Set("REPRES" ,oF14100:cRepres  )
  oData:Set("CEDULA" ,oF14100:nCedula  )
  oData:Set("TELEFO" ,oF14100:cTelefono)
  oData:Set("CIFIRM" ,oF14100:nCIFIRM  )
  oData:Save()
  oData:End()

  CursorWait()

  oTable:=OpenTable(" SELECT APELLIDO,NOMBRE,CEDULA,TIPO_CED,SEXO,FECHA_ING,FECHA_EGR,FECHA_NAC,SALARIO,MANO,TIPO_NOM, "+;
                    " DIR_HAB1,DIR_HAB2,DIR_HAB3, "+;
                    " NMPROFESION.PRF_NOMBRE AS PROFESION "+;
                    " FROM NMTRABAJADOR "+;
                    " LEFT JOIN NMPROFESION ON COD_PROF=PRF_CODIGO "+;
                    " WHERE CODIGO "+GetWhere("=",oF14100:cCodigo),.T.)

  cSalario:=TRAN(IIF(oTable:TIPO_NOM="S",oTable:SALARIO*7,DIV(oTable:SALARIO,30)*7),"999,999,999.99")

  oTable:Replace("SEMANAL"   , cSalario    )
  oTable:Replace("EMPRESA"   , oDp:cEmpresa)
  oTable:Replace("APELLINOMB", ALLTRIM(oTable:APELLIDO)+", "+ALLTRIM(oTable:NOMBRE))
  oTable:Replace("DIREMPRESA", oF14100:cDir)
  oTable:Replace("SEXO_M",  IIF(oTable:SEXO    ="M","X"," "))
  oTable:Replace("SEXO_F",  IIF(oTable:SEXO    ="F","X"," "))
  oTable:Replace("SURDO_S", IIF(oTable:MANO    ="S","X"," "))
  oTable:Replace("SURDO_N", IIF(oTable:MANO    ="D","X"," "))
  oTable:Replace("CI_V"   , IIF(oTable:TIPO_CED="V","X"," "))
  oTable:Replace("CI_E"   , IIF(oTable:TIPO_CED="E","X"," "))

  oTable:Replace("MINTRA_1",SUBS(oF14100:cMinTra,1,1))
  oTable:Replace("MINTRA_2",SUBS(oF14100:cMinTra,2,1))
  oTable:Replace("MINTRA_3",SUBS(oF14100:cMinTra,3,1))
  oTable:Replace("MINTRA_4",SUBS(oF14100:cMinTra,4,1))
  oTable:Replace("MINTRA_5",SUBS(oF14100:cMinTra,5,1))
  oTable:Replace("MINTRA_6",SUBS(oF14100:cMinTra,6,1))
  oTable:Replace("MINTRA_7",SUBS(oF14100:cMinTra,7,1))
  oTable:Replace("MINTRA_8",SUBS(oF14100:cMinTra,8,1))
  oTable:Replace("MINTRA_9",SUBS(oF14100:cMinTra,9,1))

  oTable:Replace("SSO_1",SUBS(oF14100:cSSO,1,1))
  oTable:Replace("SSO_2",SUBS(oF14100:cSSO,2,1))
  oTable:Replace("SSO_3",SUBS(oF14100:cSSO,3,1))
  oTable:Replace("SSO_4",SUBS(oF14100:cSSO,4,1))
  oTable:Replace("SSO_5",SUBS(oF14100:cSSO,5,1))
  oTable:Replace("SSO_6",SUBS(oF14100:cSSO,6,1))
  oTable:Replace("SSO_7",SUBS(oF14100:cSSO,7,1))
  oTable:Replace("SSO_8",SUBS(oF14100:cSSO,8,1))
  oTable:Replace("SSO_9",SUBS(oF14100:cSSO,9,1))

  cCI    :=STRZERO(oTable:CEDULA,8)
  oTable :Replace("CI_1"  ,SUBS(cCI,1,1))
  oTable :Replace("CI_2"  ,SUBS(cCI,2,1))
  oTable :Replace("CI_3"  ,SUBS(cCI,3,1))
  oTable :Replace("CI_4"  ,SUBS(cCI,4,1))
  oTable :Replace("CI_5"  ,SUBS(cCI,5,1))
  oTable :Replace("CI_6"  ,SUBS(cCI,6,1))
  oTable :Replace("CI_7"  ,SUBS(cCI,7,1))
  oTable :Replace("CI_8"  ,SUBS(cCI,8,1))

  cFchNac:=DTOC(oTable:FECHA_EGR)
  oTable:Replace("EGR_D1", SUBS(cFchNac,01,1))
  oTable:Replace("EGR_D2", SUBS(cFchNac,02,1))
  oTable:Replace("EGR_M1", SUBS(cFchNac,04,1))
  oTable:Replace("EGR_M2", SUBS(cFchNac,05,1))
  oTable:Replace("EGR_A1", SUBS(cFchNac,09,1))
  oTable:Replace("EGR_A2", SUBS(cFchNac,10,1))

  cFchNac:=DTOC(oTable:FECHA_ING)
  oTable:Replace("ING_D1", SUBS(cFchNac,01,1))
  oTable:Replace("ING_D2", SUBS(cFchNac,02,1))
  oTable:Replace("ING_M1", SUBS(cFchNac,04,1))
  oTable:Replace("ING_M2", SUBS(cFchNac,05,1))
  oTable:Replace("ING_A1", SUBS(cFchNac,09,1))
  oTable:Replace("ING_A2", SUBS(cFchNac,10,1))

  oTable:Replace("CARGO"   ,oF14100:cCargo   )
  oTable:Replace("REPRES"  ,oF14100:cRepres  )
  oTable:Replace("CEDULA"  ,oF14100:nCedula  )
  oTable:Replace("TELEFO"  ,oF14100:cTelefono)
  oTable:Replace("LUGAR"   ,oF14100:cLugar   )
  oTable:Replace("OBSERV"  ,oF14100:cObserv  )
  oTable:Replace("FIRMANTE",oF14100:cInform  )
  oTable:Replace("CIFIRMAN",oF14100:nCIFIRM  )

  cFchNac:=DTOC(oF14100:dFecha)

  oTable:Replace("FCH_D1", SUBS(cFchNac,01,1))
  oTable:Replace("FCH_D2", SUBS(cFchNac,02,1))
  oTable:Replace("FCH_M1", SUBS(cFchNac,04,1))
  oTable:Replace("FCH_M2", SUBS(cFchNac,05,1))
  oTable:Replace("FCH_A1", SUBS(cFchNac,09,1))
  oTable:Replace("FCH_A2", SUBS(cFchNac,10,1))

  nAno=6
  FOR I=1 TO 6 
    cField:="A"+ALLTRIM(STR(I))+"_"
    oTable:Replace(cField+"ANO"  ,oF14100:aAno[nAno])
    oTable:Replace(cField+"TOTAL",oF14100:aTotal[I])
    FOR nMeses=1 TO 12
      cField:="A"+ALLTRIM(STR(I))+"_MES"+STRZERO(nMeses,2)
      oTable:Replace(cField,oF14100:oBrw:aArrayData[nMeses,I+1])
    NEXT nMeses
    nAno=nAno-1
  NEXT I

 // oTable:Browse()

  cFileDbf:=oDp:cPathCrp+"FORMA14100.DBF"
  oTable:CTODBF(cFileDbf)
  oTable:End()

  IF ISFIELD("NMTRABAJADOR","OBS14100")
    SQLUPDATE("NMTRABAJADOR","OBS14100",oF14100:cObserv,"CODIGO"+GetWhere("=",oF14100:cCodigo))
  ENDIF

  RUNRPT(oDp:cPathCrp+"FORMA14100.RPT",{cFileDbf},1,"Forma 14-100 ")

  AUDITAR("DSSO" , NIL , "NMTRABAJADOR" , oF14100:cCodigo+" FORMA 14-100")

  CursorArrow()
RETURN .T.

FUNCTION oF14100:ResSaveCol( oFrm , uValue , nCol)
RETURN uValue

// EOF
