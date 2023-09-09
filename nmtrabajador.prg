// Programa   : NMTRABAJADOR
// Fecha/Hora : 16/01/2004 16:44:51
// Prop«sito  : Documento NMTRABAJADOR
// Creado Por : DpXbase
// Llamado por: NMTRABAJADOR.LBX
// Aplicaci«n : N®mina                                  
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION NMTRABAJADOR(nOption,cCodigo,nModoFrm,cCenCos,cCodDep)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,oFontx
  LOCAL cSql,cFile,cExcluye:=""
  LOCAL nClrText,cFileEdt

  LOCAL cFilScg1:=NIL
  LOCAL cFilScg2:=NIL
  LOCAL cFilScg3:=NIL
  LOCAL cFileEdtO:="FORMS\NMTRABAJADOR_V6"+oDp:cModeVideo+".edt"
  LOCAL cFilScg1O:="FORMS\NMTRABAJADOR_DATLAB.SCG"
  LOCAL cFilScg2O:="FORMS\NMTRABAJADOR_DATFOR.SCG"
  LOCAL cFilScg3O:="FORMS\NMTRABAJADOR_DATPER.SCG"
  LOCAL oBrw,cSqlCuerpo,oCuerpo,oCol,oCursorC
  LOCAL aCoors  :=GetCoors( GetDesktopWindow() )
  LOCAL cTitle:="Trabajadores Nómina",;
         aItems1:=GETOPTIONS("NMTRABAJADOR","CONDICION"),;
         aItems2:=GETOPTIONS("NMTRABAJADOR","TIPO_CED"),;
         aItems3:=GETOPTIONS("NMTRABAJADOR","TIPO_NOM"),;
         aItems4:=GETOPTIONS("NMTRABAJADOR","FORMA_PAG")

  IF Type("oFrmTrabj")="O" .AND. oFrmTrabj:oWnd:hWnd>0
     EJECUTAR("BRRUNNEW",oFrmTrabj,GetScript())
     RETURN .T.
  ENDIF

  IF oDp:lCatorcenal=NIL
     EJECUTAR("NMRESTDATA")
  ENDIF


  DEFAULT nModoFrm:=0

  DEFAULT oDp:pCapCha:=NIL

  DEFAULT nOption:=0,;
          oDp:lTrabjMenu:=.F.,;
          oDp:cNit:="RIF"

  oDp:cNit:=IF(Empty(oDp:cNit),"RIF",oDp:cNit)

  DEFAULT oDp:aCoors:=GetCoors( GetDesktopWindow() )

  PUBLICO("nAnos" ,0)
  PUBLICO("nMeses",0)
  PUBLICO("nDias" ,0)

  IF EMPTY(oDp:cModeVideo)

    DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
    DEFINE FONT oFontx NAME "Tahoma" SIZE 0, -12 
   // BOLD
    DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD 
    DEFINE FONT oFontG NAME "Tahoma"   SIZE 0, -11

  ELSE

    DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -12 BOLD
    DEFINE FONT oFontx NAME "Tahoma" SIZE 0, -14 
   // BOLD
    DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -14 BOLD 
    DEFINE FONT oFontG NAME "Tahoma"   SIZE 0, -14

  ENDIF

  nClrText:=10485760 // Color del texto

  cTitle   :=" {oDp:NMTRABAJADOR}"

  cSql  :=[SELECT * FROM NMTRABAJADOR]

  DEFAULT cCodigo:=oDp:cCodTraIni

  IF !Empty(cCodigo)
    oDp:cCodTraIni:=cCodigo
  ENDIF

  IF !Empty(oDp:cCodTraIni)
    cCodigo:=oDp:cCodTraIni
  ENDIF

//  cCodigo:=IF ( Empty(oDp:cCodTraIni), cCodigo, oDp:cCodTraIni)
// ? cCodigo,"cCodigo"

  IF !Empty(cCodigo)
     cSql:=cSql+" WHERE CODIGO"+GetWhere("=",oDp:cCodTraIni)
  ELSE
     cSql:=cSql+" WHERE 1=0"
  ENDIF

  oTable:=OpenTable(cSql," WHERE "$cSql) // nOption!=1)

  IF oTable:RecCount()=0 .AND. COUNT("NMTRABAJADOR")=0
    nOption:=1
  ENDIF

  IF oTable:FIELDPOS("SALARIOD")=0
     EJECUTAR("DPCAMPOSADD" ,"NMTRABAJADOR","VEHICULOD" ,"C",250,0,"Datos del Vehículo",NIL,.T.,.F.)
     EJECUTAR("DPCAMPOSADD" ,"NMTRABAJADOR","SALARIOD"  ,"N",010,2,"Sueldo en Divisa") // ,NIL,.T.,.F.)
  ENDIF

// ? cSql
// oTable:Browse()

  oTable:cPrimary:="CODIGO" // Clave de Validaci«n de Registro

  oDp:lDpXbase:=.T.

  cFileEdt:=cFileEdtO	
  cFilScg1:=cFilScg1O
  cFilScg2:=cFilScg2O
  cFilScg3:=cFilScg3O

  IF oDp:lEsp 

    cFileEdt:="FORMS\NMTRABAJADOR_V6"+oDp:cModeVideo+"_ESP.edt"

    IF !FILE(cFileEdt)
       COPY FILE (cFileEdtO) TO (cFileEdt)
    ENDIF

    cFilScg1:="FORMS\NMTRABAJADOR_DATLAB_ESP.SCG"
    cFilScg2:="FORMS\NMTRABAJADOR_DATFOR_ESP.SCG"
    cFilScg3:="FORMS\NMTRABAJADOR_DATPER_ESP.SCG"

    IF !FILE(cFilScg1)
       COPY FILE (cFilScg1O) TO (cFilScg1)
    ENDIF

    IF !FILE(cFilScg2)
       COPY FILE (cFilScg2O) TO (cFilScg2)
    ENDIF

    IF !FILE(cFilScg3)
       COPY FILE (cFilScg3O) TO (cFilScg3)
    ENDIF

  ENDIF

 //? FILE(cFileEdt),cFileEdt,FILE(cFileEdtO),cFileEdtO


  oFrmTrabj:=DPEDIT():New(cTitle,cFileEdt,"oFrmTrabj" , .F. ) 

  oFrmTrabj:cSingular:=GETFROMVAR("{oDp:XNMTRABAJADOR}") // Nombre Singular

  oFrmTrabj:lDlg     :=.T.                // Formulario Sin Dialog
  oFrmTrabj:lPaste   :=oDp:nVersion>3     // Funcionalidad Pegar en Buscar
  oFrmTrabj:nMode    :=1                  // Formulario Tipo de Documento
  oFrmTrabj:lEscClose:=.T.
  oFrmTrabj:nOption  :=nOption
  oFrmTrabj:SetTable( oTable , .F. )  // Asocia la tabla <cTabla> con el formulario oFrmTrabj
  oFrmTrabj:SetScript()               // Asigna Funciones DpXbase como Metodos de oFrmTrabj
  oFrmTrabj:SetDefault()              // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oFrmTrabj:cList     :=IIF(oDp:cTipoNom  ="O" , "NMTRABAJADORT.BRW","NMTRABAJADOR.BRW") 

  // 01/06/2023
  oFrmTrabj:cCenCos   :=cCenCos
  oFrmTrabj:cCodDep   :=cCodDep

  IF !Empty(cCenCos)
     oFrmTrabj:cScope:="COD_UND"+GetWhere("=",cCenCos)
  ENDIF

 IF !Empty(cCodDep)
     oFrmTrabj:cScope:="COD_DPTO"+GetWhere("=",cCodDep)
  ENDIF


      

  IF oDp:lEsp 
    oFrmTrabj:cList     :="NMTRABAJADOR_ESP.BRW"
  ENDIF
 
  oFrmTrabj:cListWhere:=IIF(oDp:cTipoNom  ="O" , NIL , "TIPO_NOM"+GetWhere("=",oDp:cTipoNom)   )
  oFrmTrabj:cListTitle:=IIF(oDp:cTipoNom  ="O" , NIL , "Trabajadores para Nómina "+SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oDp:cTipoNom))
  oFrmTrabj:cView     :="NMTRABJCON"       // Programa Consulta
  oFrmTrabj:RIF       :=STRTRAN(oFrmTrabj:RIF,"-","")
  oFrmTrabj:cRifVal   :=SPACE(LEN(oFrmTrabj:RIF))
  oFrmTrabj:nModoFrm  :=nModoFrm
  oFrmTrabj:nAnos     :=0
  oFrmTrabj:nMeses    :=0
  oFrmTrabj:nDias     :=0

  oFrmTrabj:lSayMsgObj:=.F.
  oFrmTrabj:oBtnRifBar:=NIL
  oFrmTrabj:oRifVal   :=NIL
  oFrmTrabj:oSayRif   :=NIL

  oFrmTrabj:OpcButtons("Ejecutar Prenómina ["+oDp:cTipoNom+IIF(oDp:cTipoNom="O","/"+oDp:cOtraNom,"")+"]"+CRLF+"Tecla [R]","RUN.BMP",[oDpEdit:PRENOM(oDpEdit,.T.)],nil,82)
  oFrmTrabj:OpcButtons("Variaciones de Pago"+CRLF+"Tecla [V]","xVARIACION.BMP",[oDpEdit:PRENOM(oDpEdit,.F.)],nil,86)
  oFrmTrabj:OpcButtons("Emisión de Cartas"  +CRLF+"Tecla [W]","WORD.BMP",[oDpEdit:CARTAS(oDpEdit,.F.)],"oFrmTrabj:nOption=0 .AND. oDp:lCartas",87)
  oFrmTrabj:OpcButtons("Opciones RR.HH"     +CRLF+"Tecla [O]","RRHH.BMP",[EJECUTAR("NMTRABJOPC",oFrmTrabj)],nil,79)

  IF ISRELEASE("16.08")
    oFrmTrabj:OpcButtons("Menú de Opciones","MENU.BMP" ,[EJECUTAR("NMTRABJMNU",NIL,oFrmTrabj:CODIGO)])
  ENDIF

  // Exclusivo ZARA
  IF .F. 
    oFrmTrabj:OpcButtons("Otros Datos" +Chr(13)+Chr(10)+"Tecla [G]","todosloscampos.BMP",'EJECUTAR("NMTRABOTROS",oFrmTrabj:CODIGO,oFrmTrabj:SEXO,1)',nil,79)
  ENDIF

  oFrmTrabj:nBtnWidth:=40
  oFrmTrabj:cBtnList :="xbrowse2.bmp"
  oFrmTrabj:BtnSetMnu("BROWSE","Buscar Nombre por Palabras"    ,"BRWTRABAJADOR","xbrowse2.bmp")  // Agregar Menú en Barra de Botones
  oFrmTrabj:BtnSetMnu("BROWSE","Buscar por Campos"             ,"BRWTRABAJADOR")                 // Agregar Menú en Barra de Botones
  oFrmTrabj:BtnSetMnu("BROWSE","Opciones por Campos"           ,"BRWTRABAJADOR","MENUOPCCAMPO")  // Agregar Menú en Barra de Botones
  oFrmTrabj:BtnSetMnu("BROWSE","Buscar por "+oDp:XDPDPTO       ,"BRWTRABAJADOR")                 // Agregar Menú en Barra de Botones
  oFrmTrabj:BtnSetMnu("BROWSE","Buscar por "+oDp:XDPCENCOS     ,"BRWTRABAJADOR")                 // Agregar Menú en Barra de Botones
//  oFrmTrabj:BtnSetMnu("BROWSE","Buscar por "+oDp:XNMGRUPO    ,"BRWTRABAJADOR")                 // Agregar Menú en Barra de Botones


  oFrmTrabj:OpcButtons("Imprimir Tarjeta"                    ,"BOX.BMP" ,[oFrmTrabj:IMPTARJETA()],nil,79)

  //Tablas Relacionadas con los Controles del Formulario
  
  oFrmTrabj:cScopeOrg:=oFrmTrabj:cScope
  oFrmTrabj:SetMemo("NUMMEMO") // Campo para el Valor Memo
  oFrmTrabj:SetPrgWebCam("NMWEBCAMMDI","TRA_FILMAI") // Tomar foto

  IF  oDp:nVersion>=3.0
    oFrmTrabj:SetAdjuntos("TRA_FILMAI")                 // Vinculo con DPFILEEMP
  ENDIF

  IF !oDp:lEsp .AND. nOption=1
    oFrmTrabj:SET("TIPO_CED" ,"V") // oFrmTrabj:oTIPO_CED:VarGet())
    oFrmTrabj:SET("CONDICION","A") // Activo
  ENDIF


  oFrmTrabj:CreateWindow()        // Presenta la Ventana
  // Opciones del Formulario

  //
  // Campo : CODIGO    
  // Uso   : Código                                  
  //
  @ 3.0, 1.0 GET oFrmTrabj:oCODIGO;
                 VAR oFrmTrabj:CODIGO ;
                 VALID !Empty(oFrmTrabj:CODIGO) .AND. oFrmTrabj:ValUnique(oFrmTrabj:CODIGO);
                       .AND. oFrmTrabj:VALCODIGO(); 
                 WHEN (AccessField("NMTRABAJADOR","CODIGO",oFrmTrabj:nOption);
                      .AND. oFrmTrabj:nOption!=0);
                 FONT oFontG

  oFrmTrabj:oCODIGO    :cMsg    :="Código"
  oFrmTrabj:oCODIGO    :cToolTip:="Código"

  @ 0,0 SAY "Código:" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,NIL RIGHT

  //
  // Campo : APELLIDO  
  // Uso   : Apellido                                
  //
  @ 4.8, 1.0 GET oFrmTrabj:oAPELLIDO    VAR oFrmTrabj:APELLIDO   ;
                   VALID !Empty(oFrmTrabj:APELLIDO);
                    WHEN (AccessField("NMTRABAJADOR","APELLIDO",oFrmTrabj:nOption);
                    .AND. oFrmTrabj:nOption!=0);
                    FONT oFontG

    oFrmTrabj:oAPELLIDO  :cMsg    :="Apellido"
    oFrmTrabj:oAPELLIDO  :cToolTip:="Apellido"

  @ 0,0 SAY "Apellidos:" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,NIL RIGHT


  // Campo : APELLIDO2  
  // Uso   : APELLIDO2                                
  //             
  @ 4.8, 1.0 GET oFrmTrabj:oAPELLIDO2    VAR oFrmTrabj:APELLIDO2   ;
                   VALID !Empty(oFrmTrabj:APELLIDO2);
                    WHEN (AccessField("NMTRABAJADOR","APELLIDO2",oFrmTrabj:nOption);
                    .AND. oFrmTrabj:nOption!=0);
                    FONT oFontG

    oFrmTrabj:oAPELLIDO2  :cMsg    :="APELLIDO2"
    oFrmTrabj:oAPELLIDO2  :cToolTip:="APELLIDO2"

  //
  // Campo : NOMBRE    
  // Uso   : Nombre                                  
  //
  @ 6.6, 1.0 GET oFrmTrabj:oNOMBRE      VAR oFrmTrabj:NOMBRE;
                    VALID !Empty(oFrmTrabj:NOMBRE);
                    WHEN (AccessField("NMTRABAJADOR","NOMBRE",oFrmTrabj:nOption);
                    .AND. oFrmTrabj:nOption!=0);
                    FONT oFontG

    oFrmTrabj:oNOMBRE    :cMsg    :="Nombre"
    oFrmTrabj:oNOMBRE    :cToolTip:="Nombre"

   @ 0,0 SAY "Nombres:" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,NIL RIGHT

  //
  // Campo : NOMBRE2    
  // Uso   : NOMBRE2                                  
  //
  @ 6.6, 1.0 GET oFrmTrabj:oNOMBRE2      VAR oFrmTrabj:NOMBRE2;
                    VALID !Empty(oFrmTrabj:NOMBRE2);
                    WHEN (AccessField("NMTRABAJADOR","NOMBRE2",oFrmTrabj:nOption);
                    .AND. oFrmTrabj:nOption!=0);
                    FONT oFontG

   oFrmTrabj:oNOMBRE2:cMsg    :="2do Nombre"
   oFrmTrabj:oNOMBRE2:cToolTip:="2do Nombre"


  //
  // Campo : FECHA_ING 
  // Uso   : Fecha de Ingreso                        
  //
  @ 8.4, 1.0 BMPGET oFrmTrabj:oFECHA_ING   VAR oFrmTrabj:FECHA_ING   PICTURE "99/99/9999";
             NAME "BITMAPS\Calendar.bmp";
             VALID oFrmTrabj:VALFECHA_ING();
             ACTION LbxDate(oFrmTrabj:oFECHA_ING,oFrmTrabj:FECHA_ING);
             WHEN (AccessField("NMTRABAJADOR","FECHA_ING",oFrmTrabj:nOption);
                  .AND. oFrmTrabj:nOption!=0);
             FONT oFontG

    oFrmTrabj:oFECHA_ING :cMsg    :="Fecha de Ingreso"
    oFrmTrabj:oFECHA_ING :cToolTip:="Fecha de Ingreso"

  @ 0,0 SAY "Ingreso:" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,NIL RIGHT

  //
  // Campo : CONDICION 
  // Uso   : Condicion del Trabajador                
  //
  @ 9.7, 1.0 COMBOBOX oFrmTrabj:oCONDICION  VAR oFrmTrabj:CONDICION  ITEMS aItems1;
                      WHEN (AccessField("NMTRABAJADOR","CONDICION",oFrmTrabj:nOption);
                     .AND. oFrmTrabj:nOption!=0);
                      FONT oFontG;

  ComboIni(oFrmTrabj:oCONDICION )

  oFrmTrabj:oCONDICION :cMsg    :="Condición del Trabajador"
  oFrmTrabj:oCONDICION :cToolTip:="Condición del Trabajador"

  @ 0,0 SAY "Condición:" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,NIL RIGHT


  IF !oDp:lEsp
 
  //
  // Campo : TIPO_CED  
  // Uso   : Tipo de C+dula                          
  //
  @ 11.0, 1.0 COMBOBOX oFrmTrabj:oTIPO_CED   VAR oFrmTrabj:TIPO_CED   ITEMS aItems2;
                       WHEN (AccessField("NMTRABAJADOR","TIPO_CED",oFrmTrabj:nOption);
                      .AND. oFrmTrabj:nOption!=0);
                       FONT oFontG;

  ComboIni(oFrmTrabj:oTIPO_CED  )


  oFrmTrabj:oTIPO_CED  :cMsg    :="Tipo de Cédula de Identidad"
  oFrmTrabj:oTIPO_CED  :cToolTip:="Tipo de Cédula de Identidad"

  ENDIF

  @ 10,0 SAY oFrmTrabj:oAntiguead PROMPT ANTIGUEDAD(oFrmTrabj:FECHA_ING,IIF(EMPTY(oFrmTrabj:FECHA_EGR),;
            oDp:dFecha,oFrmTrabj:FECHA_EGR),@nAnos,@nMeses,@nDias)

  @ .9,06 BMPGET oFrmTrabj:oCOD_DPTO VAR oFrmTrabj:COD_DPTO;
                 VALID oFrmTrabj:VALCODDEP();
                 NAME "BITMAPS\FIND.bmp";
                 ACTION (oDpLbx:=DpLbx("DPDPTO",NIL,"DEP_ACTIVO=1",NIL,NIL,NIL,NIL,NIL,NIL,oFrmTrabj:oCOD_DPTO,NIL),;
                        oDpLbx:GetValue("DEP_CODIGO",oFrmTrabj:oCOD_DPTO));
                 WHEN (AccessField("NMTRABAJADOR","COD_DPTO",oFrmTrabj:nOption);
                       .AND. oFrmTrabj:nOption!=0);
                 SIZE 28,10

  //
  // Campo : RIF    
  // Uso   : Rif                                  
  // PICTURE "!-99999999-9";

  @ 3.5,15.0 BMPGET oFrmTrabj:oRIF VAR oFrmTrabj:RIF;
                    VALID oFrmTrabj:ValUnique(oFrmTrabj:RIF ,"RIF",oDp:cNit+" ya Existe" );
                    WHEN (AccessField("NMTRABAJADOR","RIF",oFrmTrabj:nOption);
                         .AND. oFrmTrabj:nOption!=0);
                    FONT oFontG;
                    ACTION oFrmTrabj:VALRIFSENIAT(oFrmTrabj:RIF);
                    NAME "BITMAPS\FIND.bmp"


  oFrmTrabj:oRIF:cMsg    :=oDp:cNit
  oFrmTrabj:oRIF:cToolTip:=oDp:cNit


  oFrmTrabj:oRIF:bkeyDown:={|nkey| IIF(nKey=13, oFrmTrabj:VALRIFSENIAT(oFrmTrabj:RIF),NIL) }

  @ 0,0 SAY oDp:cNit+":" PIXEL;
        SIZE NIL,NIL FONT oFont RIGHT

IF !oDp:lEsp

  //
  // Campo : CEDULA    
  // Uso   : Cédula                                  
  //
  @ 3.0,15.0 GET oFrmTrabj:oCEDULA      VAR oFrmTrabj:CEDULA      PICTURE "9999999999";
                 VALID (oFrmTrabj:ValUnique(oFrmTrabj:CEDULA ,"CEDULA","Cédula ya Existe" ) .AND. oFrmTrabj:VALCEDULA());
                 WHEN (AccessField("NMTRABAJADOR","CEDULA",oFrmTrabj:nOption);
                 .AND. oFrmTrabj:nOption!=0);
                 FONT oFontG;
                 RIGHT

    oFrmTrabj:oCEDULA    :cMsg    :="Cédula"
    oFrmTrabj:oCEDULA    :cToolTip:="Cédula"

  @ 0,0 SAY "Cédula:" PIXEL;
        SIZE NIL,NIL FONT oFont RIGHT

ENDIF

  //
  // Campo : TIPO_NOM  
  // Uso   : Tipo de Nómina                          
  //
  @ 4.3,15.0 COMBOBOX oFrmTrabj:oTIPO_NOM   VAR oFrmTrabj:TIPO_NOM   ITEMS aItems3;
                      WHEN (AccessField("NMTRABAJADOR","TIPO_NOM",oFrmTrabj:nOption);
                    .AND. oFrmTrabj:nOption!=0);
                      FONT oFontG;

  ComboIni(oFrmTrabj:oTIPO_NOM  )

  oFrmTrabj:oTIPO_NOM  :cMsg    :="Tipo de Nómina"
  oFrmTrabj:oTIPO_NOM  :cToolTip:="Tipo de Nómina"

  @ 0,0 SAY "Nómina:" PIXEL;
             SIZE NIL,7 FONT oFont RIGHT

  //
  // Campo : FORMA_PAG 
  // Uso   : Forma de Pago                           
  //
  @ 5.6,15.0 COMBOBOX oFrmTrabj:oFORMA_PAG  VAR oFrmTrabj:FORMA_PAG  ITEMS aItems4;
                      WHEN (AccessField("NMTRABAJADOR","FORMA_PAG",oFrmTrabj:nOption);
                     .AND. oFrmTrabj:nOption!=0);
                      FONT oFontG;


  ComboIni(oFrmTrabj:oFORMA_PAG )

  oFrmTrabj:oFORMA_PAG :cMsg    :="Forma de Pago"
  oFrmTrabj:oFORMA_PAG :cToolTip:="Forma de Pago"

  @ oFrmTrabj:oFORMA_PAG :nTop-08,oFrmTrabj:oFORMA_PAG :nLeft SAY "Forma de Pago:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL RIGHT

  //
  // Campo : SALARIO
  // Uso   : Salario
  //
  @ 3.0,15.0 GET oFrmTrabj:oSALARIO     VAR oFrmTrabj:SALARIO;
                 PICTURE "99,999,999,999.99" RIGHT ;
                 VALID oFrmTrabj:VALSALARIO();
                 WHEN (AccessField("NMTRABAJADOR","SALARIO",oFrmTrabj:nOption);
                 .AND. oFrmTrabj:nOption!=0);
                 FONT oFontG;
                 RIGHT

  oFrmTrabj:oSALARIO:cMsg    :="Salario"
  oFrmTrabj:oSALARIO:cToolTip:="Salario"

  @ oFrmTrabj:oSALARIO:nTop-08,oFrmTrabj:oSALARIO:nLeft SAY "Salario:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL RIGHT

  @ 20,20 SAY oFrmTrabj:oSAYDPTO PROMPT SQLGET("DPDPTO","DEP_DESCRI","DEP_CODIGO"+GetWhere("=",oFrmTrabj:COD_DPTO))
 
  @ 20,20 SAY oDp:xDPDPTO+":"

  @ 5,10 BITMAP oFrmTrabj:oImage1 FILENAME oFrmTrabj:FILEBMP PIXEL;
        SIZE 60,60 ADJUST

  @ 10, 0 FOLDER oFrmTrabj:oFolder ITEMS "Laborales","Formales","Personales";
          OF oFrmTrabj:oDlg SIZE 952,248


  IF nModoFrm=1
    oFrmTrabj:oFolder:aEnable[2]:=.F.
    oFrmTrabj:oFolder:aEnable[3]:=.F.
    cFilScg1 :="FORMS\NMTRABAJADOR_DATBAS.SCG"
  ENDIF

  SETFOLDER(1)
  //oFrmTrabj:oScroll:=oFrmTrabj:SCROLLGET("NMTRABAJADOR","NMTRABAJADOR_DATLAB.SCG",cExcluye,,,oFontx,0)
  oFrmTrabj:oScroll:=oFrmTrabj:SCROLLGET("NMTRABAJADOR",cFilScg1,cExcluye,,,oFontx,0)

  SETFOLDER(2)
  //oFrmTrabj:oScroll2:=oFrmTrabj:SCROLLGET("NMTRABAJADOR","NMTRABAJADOR_DATFOR.SCG",cExcluye,,,oFontx,0)
  oFrmTrabj:oScroll2:=oFrmTrabj:SCROLLGET("NMTRABAJADOR",cFilScg2,cExcluye,,,oFontx,0)

  SETFOLDER(3)
  //oFrmTrabj:oScroll3:=oFrmTrabj:SCROLLGET("NMTRABAJADOR","NMTRABAJADOR_DATPER.SCG",cExcluye,,,oFontx,0)
  oFrmTrabj:oScroll3:=oFrmTrabj:SCROLLGET("NMTRABAJADOR",cFilScg3,cExcluye,,,oFontx,0)


  IF EMPTY(oDp:cModeVideo)

    oFrmTrabj:oScroll:SetColSize(200,250+15,240)
    oFrmTrabj:oScroll2:SetColSize(200,250+15,240)
    oFrmTrabj:oScroll3:SetColSize(200,250+15,240)

  ELSE

    oFrmTrabj:oScroll:SetColSize( 200+40,250+15+10,240+30)
    oFrmTrabj:oScroll2:SetColSize(200+40,250+15+10,240+30)
    oFrmTrabj:oScroll3:SetColSize(200+40,250+15+10,240+30)

  ENDIF

  oFrmTrabj:oScroll:SetColorHead(0,oDp:nLbxClrHeaderPane,oFont) 

  oFrmTrabj:oScroll:SetColor(oDp:nClrPane1 , CLR_BLUE  , 1 , oDp:nClrPane2 , oFontB) 
  oFrmTrabj:oScroll:SetColor(oDp:nClrPane1 , CLR_BLACK , 2 , oDp:nClrPane2 , oFont ) 
  oFrmTrabj:oScroll:SetColor(oDp:nClrPane1 , CLR_GRAY  , 3 , oDp:nClrPane2 , oFont ) 


  oFrmTrabj:oScroll2:SetColorHead(0,oDp:nLbxClrHeaderPane,oFont) 

  oFrmTrabj:oScroll2:SetColor(oDp:nClrPane1 , CLR_BLUE  , 1 , oDp:nClrPane2 , oFontB) 
  oFrmTrabj:oScroll2:SetColor(oDp:nClrPane1 , CLR_BLACK , 2 , oDp:nClrPane2 , oFont ) 
  oFrmTrabj:oScroll2:SetColor(oDp:nClrPane1 , CLR_GRAY  , 3 , oDp:nClrPane2 , oFont ) 

  oFrmTrabj:oScroll3:SetColorHead(0,oDp:nLbxClrHeaderPane,oFont) 

  oFrmTrabj:oScroll3:SetColor(oDp:nClrPane1 , CLR_BLUE  , 1 , oDp:nClrPane2 , oFontB) 
  oFrmTrabj:oScroll3:SetColor(oDp:nClrPane1 , CLR_BLACK , 2 , oDp:nClrPane2 , oFont ) 
  oFrmTrabj:oScroll3:SetColor(oDp:nClrPane1 , CLR_GRAY  , 3 , oDp:nClrPane2 , oFont ) 

  // Graba en Forma Automatica
  oFrmTrabj:oScroll:bPostEdit:={||oFrmTrabj:Save()}

  oFrmTrabj:oFocus:=oFrmTrabj:oCODIGO

  oFrmTrabj:nOption:=nOption

  oFrmTrabj:Activate({||oFrmTrabj:INICIO()})

  IF .T.
  //nModoFrm=0

    oDp:nDif:=(aCoors[3]-160-oFrmTrabj:oWnd:nHeight())

    oFrmTrabj:oFolder:SetSize(NIL,aCoors[3]-(oFrmTrabj:oFolder:nTop+210)+10,.T.)

//? oFrmTrabj:oFolder:nHeight(),"nHeight(),folder"

    oFrmTrabj:oWnd:SetSize(NIL,aCoors[3]-160,.T.)

    oFrmTrabj:oScroll:oBrw:SetSize(NIL,oFrmTrabj:oFolder:nHeight()-25,.T.)
    oFrmTrabj:oScroll2:oBrw:SetSize(NIL,oFrmTrabj:oFolder:nHeight()-25,.T.)
    oFrmTrabj:oScroll3:oBrw:SetSize(NIL,oFrmTrabj:oFolder:nHeight()-25,.T.)

//  oFrmTrabj:oScroll2:oBrw:SetSize(NIL,oFrmTrabj:oScroll2:oBrw:nHeight()+(oDp:nDif-0),.T.)
//  oFrmTrabj:oScroll3:oBrw:SetSize(NIL,oFrmTrabj:oScroll3:oBrw:nHeight()+(oDp:nDif-0),.T.)

  ENDIF

  oFrmTrabj:nOption:=nOption
  oFrmTrabj:CheckBtn()

// ViewArray(oFrmTrabj:oScroll3:aData)
//  oFrmTrabj:oScroll:SetEdit(.T.)
//  oFrmTrabj:oScroll2:SetEdit(.T.)
//  oFrmTrabj:oScroll3:SetEdit(.T.)
/*
? oFrmTrabj:nOption,":nOption",nOption,"nOption"

   AEVAL(oFrmTrabj:aButtons,{|a,n| a[1]:Hide() }) // Apaga todos los Botones
   	oFrmTrabj:CheckBtn()
*/
  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

// ? cFilScg1,cFilScg2,cFilScg3

RETURN oFrmTrabj

FUNCTION INICIO()
  LOCAL oBtn,oFontG

  DEFINE FONT oFontG NAME "Tahoma"   SIZE 0, -12 BOLD

  DpFocus(oFrmTrabj:oCODIGO)

  oFrmTrabj:oSayRif:=NIL

  // BMPGETBTN(oFrmTrabj:oBar)

  IF !oDp:lEsp .AND. oDp:lAutRif


    @ 22,220 BMPGET oFrmTrabj:oRifVal VAR oFrmTrabj:cRifVal;
             NAME "BITMAPS\FIND.bmp";
             WHEN oFrmTrabj:nOption=1 .OR. oFrmTrabj:nOption=3;
             VALID 1=1;
             ACTION oFrmTrabj:VALRIFSENIATINC(oFrmTrabj:cRifVal,oFrmTrabj:oRifVal);
             OF oFrmTrabj:oBar PIXEL SIZE 100,20 FONT oFontG

    oFrmTrabj:oRifVal:bkeyDown:={|nkey| IIF(nKey=13, oFrmTrabj:VALRIFSENIATINC(oFrmTrabj:cRifVal,oFrmTrabj:oRifVal),NIL) }


    oFrmTrabj:oRifVal:cToolTip:="Introduzca RIF para Incluir Trabajador"

 
    oFrmTrabj:oBtnRifBar:=BMPGETBTN(oFrmTrabj:oRifVal)

    @ 01,220 SAY oFrmTrabj:oSayRif PROMPT " RIF" OF oFrmTrabj:oBar PIXEL SIZE 100,20 BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow

  ENDIF

  IF oFrmTrabj:nOption=0

    IIF(oFrmTrabj:oRifVal   =NIL,NIL,oFrmTrabj:oRifVal:Hide()   )
    IIF(oFrmTrabj:oBtnRifBar=NIL,NIL,oFrmTrabj:oBtnRifBar:Hide())
//  oFrmTrabj:oSayRif:Hide()
    oFrmTrabj:SetEdit(.T.) // Activa la Edicion
    oFrmTrabj:oScroll:SetEdit(.T.)
    oFrmTrabj:oScroll2:SetEdit(.T.)
    oFrmTrabj:oScroll3:SetEdit(.T.)

    DpFocus(oFrmTrabj:oRifVal)

  ENDIF

  oFrmTrabj:oScroll:oBrw:SetColor(0,oDp:nClrPane1)
  oFrmTrabj:oScroll2:oBrw:SetColor(0,oDp:nClrPane1)
  oFrmTrabj:oScroll3:oBrw:SetColor(0,oDp:nClrPane1)


//  DEFINE FONT oFontG NAME "Tahoma"   SIZE 0, -12

  //
  // Campo : FILEBMP   
  // Uso   : Archivo Bmp                             
  //

  @ 23,340 BMPGET oFrmTrabj:oFILEBMP     VAR oFrmTrabj:FILEBMP    ;
                  NAME "BITMAPS\FOLDER5.BMP"; 
                  ACTION (cFile:=cGetFile32("Bmp File (*.bmp) |*.bmp|Archivos BitMaps (*.bmp) |*.bmp",;
                  "Seleccionar Archivo BITMAP (BMP)",1,cFilePath(oFrmTrabj:FILEBMP),.f.,.t.),;
                  cFile:=STRTRAN(cFile,"\","/"),;
                  oFrmTrabj:FILEBMP:=IIF(!EMPTY(cFile),cFile,oFrmTrabj:FILEBMP),;
                  oFrmTrabj:oFILEBMP   :Refresh(),;
                  oFrmTrabj:oImage1:LoadBmp(cFile));
                  WHEN oFrmTrabj:nOption=1 .OR. oFrmTrabj:nOption=3;
                  FONT oFontG OF oFrmTrabj:oBar PIXEL SIZE 300,18

    oFrmTrabj:oFILEBMP   :cMsg    :="Archivo Bmp"
    oFrmTrabj:oFILEBMP   :cToolTip:="Archivo Bmp"

  @ 01,220+120 SAY oFrmTrabj:oSayFilBmp PROMPT " Archivo de Foto " OF oFrmTrabj:oBar PIXEL;
               SIZE 200,20 BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFontG

  oFrmTrabj:oBtnFilBmp:=BMPGETBTN(oFrmTrabj:oFILEBMP)

  IF oFrmTrabj:nOption=0

    oFrmTrabj:oSayFilBmp:Hide()
    oFrmTrabj:oFILEBMP:Hide()
    oFrmTrabj:oBtnFilBmp:Hide()

    IF(oFrmTrabj:oSayRif=NIL,NIL,oFrmTrabj:oSayRif:Hide())

   // oFrmTrabj:LOAD()

  ENDIF

  // Load(1)

  oFrmTrabj:LOAD(oFrmTrabj:nOption)

RETURN .T.

/*
// Carga de los Datos
*/
FUNCTION LOAD()
  LOCAL aTipos:={},nLin:=0

  IIF(oDp:lSemanal   ,AADD(aTipos,"S"),NIL)
  IIF(oDp:lQuincenal ,AADD(aTipos,"Q"),NIL)
  IIF(oDp:lMensual   ,AADD(aTipos,"M"),NIL)
  IIF(oDp:lCatorcenal,AADD(aTipos,"C"),NIL)

  IF .F. // oFrmTrabj:nOption=3 .AND. !Empty(oFrmTrabj:FECHA_EGR)
     MensajeErr("No puede Modificar Trabajador Liquidado","Trabajador Liquidado")
     RETURN .F.
  ENDIF

  IF oFrmTrabj:nOption=3 .AND. ASCAN(aTipos,oFrmTrabj:TIPO_NOM)=0
     MensajeErr("Trabajador Asociado con Tipo de Nómina: "+RTRIM(SayOptions("NMTRABAJADOR",;
                "TIPO_NOM",oFrmTrabj:TIPO_NOM)),"Usuario sin Privilegios para Modificar")
     RETURN .F.
  ENDIF

  IF oFrmTrabj:nOption=0 

     // Incluir en caso de ser Incremental

     IIF(oFrmTrabj:oRifVal   =NIL,NIL,oFrmTrabj:oRifVal:Hide()   )
     IIF(oFrmTrabj:oBtnRifBar=NIL,NIL,oFrmTrabj:oBtnRifBar:Hide())
     IIF(oFrmTrabj:oSayRif   =NIL,NIL,oFrmTrabj:oSayRif:Hide())

     oFrmTrabj:oSayFilBmp:Hide()
     oFrmTrabj:oFILEBMP:Hide()
     oFrmTrabj:oBtnFilBmp:Hide()

  ELSE

     oFrmTrabj:SetEdit(.T.) // Activa la Edicion

  ENDIF

  IF oFrmTrabj:nOption=1 // Incluir en caso de ser Incremental

     oFrmTrabj:SET("TIPO_NOM" ,oFrmTrabj:oTIPO_NOM:VarGet())
     oFrmTrabj:SET("CONDICION",oFrmTrabj:oCONDICION:VarGet())
    
     oFrmTrabj:SET("FORMA_PAG",oFrmTrabj:oFORMA_PAG:VarGet())     
     oFrmTrabj:SET("FECHA_REG",oDp:dFecha)     
     oFrmTrabj:SET("FECHA_ING",CTOD(""),.T.)
     oFrmTrabj:SET("CEDULA"   ,0       ,.T.)
     oFrmTrabj:SET("FILEBMP",CTOEMPTY(oFrmTrabj:FILEBMP),.T.)

     IF !oDp:lEsp
        oFrmTrabj:SET("TIPO_CED" ,"V") // oFrmTrabj:oTIPO_CED:VarGet())
        COMBOINI(oFrmTrabj:oTIPO_CED)
     ENDIF

     oFrmTrabj:oFILEBMP:Refresh(.T.)


     // AutoIncremental 

     IIF(!Empty(oDp:cGrpSug) , oFrmTrabj:SET("GRUPO"    ,oDp:cGrpSug) , NIL )
     IIF(!Empty(oDp:cUndSug) , oFrmTrabj:SET("COD_UND"  ,oDp:cUndSug) , NIL )
     IIF(!Empty(oDp:cCarSug) , oFrmTrabj:SET("COD_CARGO",oDp:cCarSug) , NIL )
     IIF(!Empty(oDp:cPrfSug) , oFrmTrabj:SET("COD_PROF" ,oDp:cPrfSug) , NIL )

     IF !Empty(oFrmTrabj:cCenCos)
       oFrmTrabj:SET("COD_UND"  ,oFrmTrabj:cCenCos,.T.) 
     ELSE
       oFrmTrabj:SET("COD_UND"  ,oDp:cCenCos,.T.) 
     ENDIF

     IF !Empty(oFrmTrabj:cCodDep)
       oFrmTrabj:SET("COD_UND"  ,oFrmTrabj:cCenCos,.T.) 
     ELSE
       IIF(!Empty(oDp:cDptSug) , oFrmTrabj:SET("COD_DPTO" ,oDp:cDptSug) , NIL )
     ENDIF

  ENDIF

  IF oFrmTrabj:IsDef("oScroll")
    oFrmTrabj:oScroll:SetEdit(oFrmTrabj:nOption=1.OR.oFrmTrabj:nOption=3)
  ENDIF

  oFrmTrabj:cTopic:="NMTRABAJADOR"
  oDp:cHelpTopic  :="NMTRABAJADOR"

  IF oFrmTrabj:nOption=3 // Cambiar Ayuda
     oFrmTrabj:cTopic:="NMTRABAJADORMOD"
     oDp:cHelpTopic  :="NMTRABAJADORMOD"
  ENDIF

  IF oFrmTrabj:nOption=4 // Buscar
     oFrmTrabj:cTopic:="NMTRABAJADORBUS"
     oDp:cHelpTopic  :="NMTRABAJADORBUS"
  ENDIF

// ? oFrmTrabj:FILEBMP,"oFrmTrabj:FILEBMP"

  IF Empty(oFrmTrabj:FILEBMP)
    oFrmTrabj:oImage1:LoadImage(NIL,"BITMAPS\sincaptcha.jpg")
  ELSE
    oFrmTrabj:oImage1:LoadBmp(oFrmTrabj:FILEBMP)
  ENDIF

  oFrmTrabj:oImage1:Refresh(.T.)

  IF oFrmTrabj:nOption=1 .OR. oFrmTrabj:nOption=3

     IF(oFrmTrabj:oRifVal   =NIL,NIL,oFrmTrabj:oRifVal:Show())
     IF(oFrmTrabj:oBtnRifBar=NIL,NIL,oFrmTrabj:oBtnRifBar:Show())
     IF(oFrmTrabj:oSayRif   =NIL,NIL,oFrmTrabj:oSayRif:Show())

     oFrmTrabj:oSayFilBmp:Show()
     oFrmTrabj:oFILEBMP:Show()
     oFrmTrabj:oBtnFilBmp:Show()
     oFrmTrabj:oFocus:=oFrmTrabj:oRifVal

     IF oFrmTrabj:nOption=3
        oFrmTrabj:cRifVal:=oFrmTrabj:RIF
     ENDIF

  ENDIF

  oFrmTrabj:oAntiguead:Refresh(.T.)
 
RETURN .T.

/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()

  IF !oFrmTrabj:oBtnRifBar=NIL

    oFrmTrabj:oRifVal:Hide()
    oFrmTrabj:oBtnRifBar:Hide()

  ENDIF

RETURN .T.

FUNCTION ONCLOSE()

   IF COUNT("NMTRABAJADOR")=0 .AND. oFrmTrabj:lCancel
     oFrmTrabj:lCancel:=.F.
     oFrmTrabj:Close() 
     RETURN .T.
   ENDIF

RETURN .T.

/*
// Ejecuci«n PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.
  LOCAL aCampos:={},I:=0,oObj
  LOCAL cList  :="",cRIF:="",cField

  AADD(aCampos,{"CODIGO"   ,"Código"})
  AADD(aCampos,{"NOMBRE"   ,"Nombres"})
  AADD(aCampos,{"APELLIDO" ,"Apellidos"})
  AADD(aCampos,{"FECHA_ING","Fecha de Ingreso"})

  IF !oDp:lEsp
    AADD(aCampos,{"CEDULA"   ,"Cédula"})
  ENDIF

  lResp:=oFrmTrabj:ValUnique(oFrmTrabj:CODIGO    )

  IF !lResp
     MsgAlert("Registro "+CTOO(oFrmTrabj:CODIGO),"Ya Existe")
  ENDIF

  // 15/02/2022
  IF Empty(oFrmTrabj:GRUPO)
     oFrmTrabj:GRUPO:=SQLGET("NMGRUPO","GTR_CODIGO")
  ENDIF

  // 15/02/2022
  IF Empty(oFrmTrabj:COD_UND)
     oFrmTrabj:COD_UND:=SQLGET("NMUNDFUNC","CEN_CODIGO")
  ENDIF

  // 15/02/2022
  IF Empty(oFrmTrabj:TURNO)

     oFrmTrabj:TURNO:=LEFT(oFrmTrabj:TIPO_NOM,1)

     IF !ISSQLFIND("NMJORNADAS","JOR_CODIGO"+GetWhere("=",oFrmTrabj:TURNO))
       oFrmTrabj:TURNO:=SQLGET("NMJORNADAS","JOR_CODIGO")
     ENDIF

  ENDIF

  oFrmTrabj:TRA_NOMAPL:=ALLTRIM(oFrmTrabj:APELLIDO)+" "+ALLTRIM(oFrmTrabj:NOMBRE)
  oFrmTrabj:RIF:=UPPER(oFrmTrabj:RIF)
  oFrmTrabj:lIntRef:=.T. // JN 12/11/2020
  //oFrmTrabj:CLI_RIF:=UPPER(oFrmTrabj:CLI_RIF)
  cRif:=oFrmTrabj:RIF

  //cRif:=oFrmTrabj:CLI_RIF
  cRif:=STRTRAN(cRif,"-","")
                      // Quita los guiones
/*
  IF LEN(ALLTRIM(cRif)) < 9 
    MsgAlert("RIF ERRADO -> Longitud mayor a 9 ")
    RETURN .F.
  ENDIF
*/

  IF !LEFT(cRif,1)$"VE" .AND. !oDp:lEsp
    oFrmTrabj:oRIF:MsgErr("Primera letra debe ser V o E ","Rif Incorrecto")
    RETURN .F.
  ENDIF


  WHILE I<LEN(aCampos) .AND. lResp
       I++
       oObj  :=aCampos[I,1]

//    IF EMPTY(oFrmTrabj:Get(aCampos[I,1]))
      IF oFrmTrabj:ISDEF(oObj) .AND. EMPTY(oFrmTrabj:Get(aCampos[I,1]))

        cList :=cList+IIF(Empty(cList),"",",")+aCampos[I,2]
        oObj  :="o"+aCampos[I,1]

        // oObj :=Macroeje("oFrmTrabj:o"+aCampos[I,1]+" no puede quedar Vacio","Validación")

        IF oFrmTrabj:IsDef(oObj)
          oObj:=oFrmTrabj:Get(oObj)
          oObj:MsgErr("Campo: "+aCampos[I,1]+" no puede quedar Vacio","Validación")
          DPFOCUS(oObj)
          cList:=""
          RETURN .F.
        ENDIF
       
     ENDIF
  ENDDO

  IF !Empty(cList) 
     MensajeErr(cList,"No puede Quedar Vacios")
     lResp:=.F.
  ENDIF

  IF oFrmTrabj:FORMA_PAG="T" .AND. EMPTY(oFrmTrabj:BANCO) .AND. lResp
     MensajeErr("Forma de Pago [Transferencia] Requiere Código del Banco")
     lResp:=.F.
  ENDIF

  IF oFrmTrabj:CONDICION="L" .AND. COUNT("NMTABLIQ","LIQ_CODTRA"+GetWhere("=",oFrmTrabj:CODIGO))=0

     MensajeErr("Es necesario Ingresar al trabajador en la tabla de Liquidación")
     EJECUTAR("NMTABLIQ")
     oFRMTABLIQ:oLIQ_CODTRA:VarPut(oFrmTrabj:CODIGO,.T.)
     oFRMTABLIQ:oLIQ_CODTRA:KeyBoard(13)     
     lResp:=.F.
  ENDIF

// ? oFrmTrabj:COD_DPTO,"oFrmTrabj:COD_DPTO"

  IF !ISSQLFIND("dpdpto","DEP_CODIGO"+GetWhere("=",oFrmTrabj:COD_DPTO))
     MsgMemo("Requiere Código del "+oDp:dpdpto)
     RETURN .F.
  ENDIF

  IF lResp
     lResp:=EJECUTAR("SCROLLGETVALID",oFrmTrabj:oScroll,oFrmTrabj:CODIGO)
  ENDIF

  oFrmTrabj:TRA_ACTIVO:=(LEFT(oFrmTrabj:CONDICION,1)="A" .OR. LEFT(oFrmTrabj:CONDICION,1)="V")

  oDp:cTipoNom:=LEFT(ALLTRIM(oFrmTrabj:TIPO_NOM),1) // 31/05/2023, Tipo de Nómina Según Ultimo Trabajador modificado
  oFrmTrabj:cListWhere:=IIF(oDp:cTipoNom  ="O" , NIL , "TIPO_NOM"+GetWhere("=",oDp:cTipoNom)   )
  oFrmTrabj:cListTitle:=IIF(oDp:cTipoNom  ="O" , NIL , "Trabajadores para Nómina "+SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",oDp:cTipoNom))

//  OpenOdbc(oDp:cDsnData):Execute("SET FOREIGN_KEY_CHECKS=0")

RETURN lResp

/*
// Ejecuci«n despues de Grabar
*/
FUNCTION POSTSAVE()

  // EJECUTAR("NMCREACALXTRAB",oFrmTrabj:CODIGO,oFrmTrabj:GRUPOACT,"Inclusión en Nómina",oFrmTrabj:FECHA_ING)
//   EJECUTAR("NMVIEWCALXTRA" ,oFrmTrabj:CODIGO)
//   OpenOdbc(oDp:cDsnData):Execute("SET FOREIGN_KEY_CHECKS=1")

   IF Empty(oFrmTrabj:CLAVE) .OR. Empty(oFrmTrabj:LOGIN)
      EJECUTAR("NMLOGPASS",oFrmTrabj:CODIGO)
   ENDIF

   IF oDp:lTrabjMenu
     EJECUTAR("NMTRABJOPC",oFrmTrabj)
   ENDIF

// SQLUPDATE("NMTRABAJADOR","COD_DPTO",oFrmTrabj:COD_DPTO,"CODIGO"+GetWhere("=",oFrmTrabj:CODIGO))
// ? SQLGET("NMTRABAJADOR","COD_DPTO","CODIGO"+GetWhere("=",oFrmTrabj:CODIGO)),"GRABADO"
// ? oFrmTrabj:COD_DPTO,"oFrmTrabj:COD_DPTO"

   EJECUTAR("NMTRABAJADORTORIF",oFrmTrabj:CODIGO)

   IF oFrmTrabj:nModoFrm=1
      oFrmTrabj:Close()
   ENDIF

RETURN .T.

/*
// Ejecución para el Borrado 
*/
FUNCTION DELETE()
  LOCAL nCuantos:=0
  LOCAL oTable

//oFrmTrabj:cTopic:="NMTRABAJADORELI"
//oDp:cHelpTopic  :="NMTRABAJADORELI"

  IF oFrmTrabj:CONDICION="L" .AND. !Empty(oFrmTrabj:FECHA_EGR)
     MensajeErr("No puede Eliminar Trabajador Liquidado","Trabajador Liquidado")
     RETURN .F.
  ENDIF

  IF nCuantos:=COUNT("NMHISTORICO","INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO WHERE REC_CODTRA"+GetWhere("=",oFrmTrabj:CODIGO)),nCuantos>0
    MensajeErr("Trabajador Posee "+LSTR(nCuantos)+" Registros en la Tabla Histórico de Pagos","No puede ser Eliminado, Trabajador "+oFrmTrabj:CODIGO)
    RETURN .F.
  ENDIF

  IF MsgNoYes("Código: "+oFrmTrabj:CODIGO+CRLF+ALLTRIM(oFrmTrabj:APELLIDO)+;
                         ","+oFrmTrabj:NOMBRE,;
                        "Eliminar Trabajador")

    oFrmTrabj:DelRecord(NIL,.T.)

  ENDIF

RETURN .T.

/*
// Ejecución para el Borrado 
*/
FUNCTION PRINT()
  LOCAL aData:={oDp:cCodTraIni,oDp:cCodTraFin}
  LOCAL cCodRep:="0000000011",oRep    

  oDp:cCodTraIni:=oFrmTrabj:CODIGO
  oDp:cCodTraFin:=oFrmTrabj:CODIGO

  oRep:=REPORTE(cCodRep) // ,,"NMTRABAJADORPRINT",oFrmTrabj:cFileChm)

  oDp:cCodTraIni:=aData[1]
  oDp:cCodTraFin:=aData[2]

RETURN .T.

/*
// Ejecutar Prenómina
*/
FUNCTION PRENOM(oDpEdit,lPrenomina)

   oDp:cCodTraIni:=oDpEdit:CODIGO
   oDp:cCodTraFin:=oDpEdit:CODIGO

   oDp:cTipoNom  :=LEFT(oDpEdit:TIPO_NOM,1)
   oDp:cOtraNom  :=""

   IF lPrenomina
     EJECUTAR("PRENOMINA")
   ELSE
     EJECUTAR("VARIACIONES")
   ENDIF

RETURN .T.

function validar()
   mensajeErr("estoy en validar")
return .t.

/*
// Ejecutar de Cartas
*/
FUNCTION CARTAS(oDpEdit,lPrenomina)
  EJECUTAR("NMTRABJWORD",oFrmTrabj:CODIGO)
RETURN .T.


FUNCTION IMPTARJETA()
   LOCAL oRep

   // oRep:=REPORTE("TARJETAS")
   oRep:=EJECUTAR("DPREPORTES",0,"TARJETAS")
   oRep:SetRango(2,oFrmTrabj:CODIGO,oFrmTrabj:CODIGO)
   oRep:SetCriterio(2,LEFT(oFrmTrabj:CONDICION,1))

RETURN NIL

/*
// Validar RIF
*/
FUNCTION VALRIFSENIAT(cRif)
  LOCAL lOk,cTipCed,cCedula:=ALLTRIM(cRif)
  LOCAL nLen:=LEN(oFrmTrabj:RIF)


  IF oDp:lEsp

     oFrmTrabj:RIF :=ALLTRIM(STRTRAN(oFrmTrabj:RIF,"-",""))
     oFrmTrabj:RIF :=PADR(oFrmTrabj:RIF,nLen)
     oFrmTrabj:oRIF:VarPut(oFrmTrabj:RIF,.T.)
    
     lOk:=EJECUTAR("ESVALNIF",oFrmTrabj:RIF)

     IF !lOk
       oFrmTrabj:oRIF:MsgErr(oFrmTrabj:RIF+" no es Válido","Validación de "+oDp:cNit)
     ENDIF

     RETURN lOk

  ENDIF

  IF !oDp:lAutRif
     RETURN .T.
  ENDIF


  MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
         {|| lOk:=EJECUTAR("VALRIFSENIAT",cRif,!ISDIGIT(cRif),!ISDIGIT(cRif)) })

/*
  IF !lOk .AND. ISDIGIT(cRif)

    MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
            {||lOk:=EJECUTAR("RIFVAUTODET",cRif,NIL)}) 

   
  ENDIF
*/
  IF !Empty(oDp:aRif)

     oFrmTrabj:RIF :=oDp:aRif[6]
     oFrmTrabj:oRIF:Refresh(.T.)
     oFrmTrabj:oCEDULA:VarPut(VAL(cCedula),.T.)
  
  ENDIF

RETURN .T.


FUNCTION BRWTRABAJADOR(nOption,cOption)
  LOCAL cWhere,cCodigo,cTitle:=oFrmTrabj:cListTitle
  LOCAL nAt:=ASCAN(oFrmTrabj:aButtons,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oFrmTrabj:aButtons[nAt,1],NIL)

  IF nOption=1 

     cWhere:=EJECUTAR("NMTRABJBUSCAR",ALLTRIM(oFrmTrabj:APELLIDO)+" "+ALLTRIM(oFrmTrabj:NOMBRE),.T.,oBtnBrw)

     IF !Empty(cWhere)

        oFrmTrabj:List(cWhere)

        oFrmTrabj:cScope:=oFrmTrabj:cScopeOrg+IF(Empty(oFrmTrabj:cScopeOrg),""," AND ")+cWhere
        oFrmTrabj:RECCOUNT(.T.)
        oFrmTrabj:RECCOUNT(.F.)

     ENDIF

     RETURN .T.

  ENDIF


  IF nOption=2
     cWhere:=EJECUTAR("TABLECOUNTXFIELD","NMTRABAJADOR","CODIGO","TRA_APLNOM",oFrmTrabj)
     RETURN  NIL
  ENDIF

  IF nOption=3


     oDp:cFieldName:=""
     cWhere:=EJECUTAR("DPEXPTRABAJADOR",.T.,oBtnBrw)
     
     IF !Empty(cWhere)

        DEFAULT oFrmTrabj:cListTitle:=oDp:DPCLIENTES

        oFrmTrabj:cListTitle:=oFrmTrabj:cListTitle+" ["+ALLTRIM(oDp:cFieldName)+"] "+cWhere

        oFrmTrabj:cScope:=oFrmTrabj:cScopeOrg+IF(Empty(oFrmTrabj:cScopeOrg),""," AND ")+cWhere
        oFrmTrabj:RECCOUNT(.T.)

        oFrmTrabj:List(cWhere)

     ENDIF

     RETURN .T.

  ENDIF




  IF nOption=4

     oFrmTrabj:BRWXDEPTO() 
     RETURN .T.

  ENDIF

  IF nOption=5

     oFrmTrabj:BRWXCENCOS() 
     RETURN .T.

  ENDIF

RETURN .T.
/*
C014=COD_CARGO           ,'C',008,0,'','C¾digo del Cargo',1
 C015=COD_DPTO            ,'C',006,0,'','C¾digo del Departamento',0
 C016=COD_PROF            ,'C',008,0,'','C¾digo de Profesi¾n',0
 C017=COD_UND    
// Browse por Cuenta Contable
*/
FUNCTION BRWXDEPTO()
  LOCAL cWhere:="",cCodigo:=""
  LOCAL cTitle:="Seleccionar "+oDp:XDPDPTO,aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
 
  cWhere    := " INNER JOIN DPDPTO ON COD_DPTO=DEP_CODIGO "+IF(Empty(oFrmTrabj:cScope)," WHERE 1=1 "," WHERE ")+oFrmTrabj:cScope

  cOrderBy:=" GROUP BY COD_DPTO ORDER BY COD_DPTO "
  aTitle  :={"Código","Nombre","Ingreso;Desde","Ingreso;Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"9999"}
  oDp:aSize      :={60,300,74,74,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","NMTRABAJADOR","COD_DPTO,DEP_DESCRI,MIN(FECHA_ING),MAX(FECHA_ING),COUNT(*) AS CANT",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="COD_DPTO"+GetWhere("=",cCodigo)+;
             IIF(!Empty(oFrmTrabj:cScopeOrg)," AND "+oFrmTrabj:cScopeOrg,"")

     cTitle:=oDp:XDPDPTO+" ["+cCodigo+" "+ALLTRIM(SQLGET("DPDPTO","DEP_DESCRI ","DEP_CODIGO"+GetWhere("=",cCodigo)))+"]"

     oFrmTrabj:cListTitle:=cTitle

     oFrmTrabj:List(cWhere)
  
  ENDIF

RETURN .T.

FUNCTION BRWXCENCOS()
  LOCAL cWhere:="",cCodigo:=""
  LOCAL cTitle:="Seleccionar "+oDp:XCENCOS,aTitle:=NIL,cFind:=NIL,cFilter:=NIL,cSgdoVal:=NIL,cOrderBy:=NIL
 
  cWhere    := " INNER JOIN DPCENCOS ON COD_UND=CEN_CODIGO "+IF(Empty(oFrmTrabj:cScope)," WHERE 1=1 "," WHERE ")+oFrmTrabj:cScope

  cOrderBy:=" GROUP BY COD_UND ORDER BY COD_UND "
  aTitle  :={"Código","Nombre","Ingreso;Desde","Ingreso","Cant.;Reg"}

  oDp:aPicture   :={NIL,NIL,NIL,NIL,"9999"}
  oDp:aSize      :={60,300,74,74,40}
  oDp:lFullHeight:=.T.

  cCodigo:=EJECUTAR("REPBDLIST","NMTRABAJADOR","CEN_CODIGO,CEN_DESCRI,MIN(FECHA_ING),MAX(FECHA_ING),COUNT(*) AS CANT",.F.,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oBtnBrw)

  IF !Empty(cCodigo)

     cWhere:="COD_UND"+GetWhere("=",cCodigo)+;
             IIF(!Empty(oFrmTrabj:cScopeOrg)," AND "+oFrmTrabj:cScopeOrg,"")

     cTitle:=oDp:XDPCENCOS+" ["+cCodigo+" "+ALLTRIM(SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",cCodigo)))+"]"

     oFrmTrabj:cListTitle:=cTitle

     oFrmTrabj:List(cWhere)
  
  ENDIF

RETURN .T.



FUNCTION FINDXFIELD(cWhere,cTitle)

    IF !Empty(cWhere)

      oFrmTrabj:cListTitle:=ALLTRIM(oFrmTrabj:cTitle)+" ["+cTitle+"]"
      oFrmTrabj:List(cWhere)

    ENDIF

RETURN .T.

FUNCTION SELCAMPOSOP(cValue,cField,cWhere,cTitle)
  LOCAL nAt

  DEFAULT cWhere:=cField+[=LEFT("]+UPPER(cValue)+[",LENGTH(]+cField+[))],;
          cTitle:=""

  nAt   :=AT("(",cTitle)
  cTitle:=IF(nAt>0,LEFT(cTitle,nAt-1),cTitle)

  IF COUNT(oFrmTrabj:cTable,cWhere)=0
     MensajeErr("No hay Registros encontrados según "+CRLF+"Campo : "+cTitle+" "+CRLF+"Criterio: "+cValue+"",;
     "Tabla "+GETFROMVAR("{oDp:"+oFrmTrabj:cTable+"}"))
     RETURN .F.
  ENDIF

  oFrmTrabj:cListTitle:=ALLTRIM(oFrmTrabj:cTitle)+" ["+cTitle+"]"
  oFrmTrabj:List(cWhere)

RETURN .T.

/*
// Validar RIF del Trabajador
*/
FUNCTION VALRIFSENIATINC(cRif,oRif)
   LOCAL nLenO:=LEN(cRif),cTipCed,nCedula
   LOCAL nLen :=LEN(ALLTRIM(cRif))
   LOCAL lOk  :=.F.
   LOCAL aLine:={}

   DEFAULT oDp:lCodigoNmAsRif:=.T.
   
   IF ISALLDIGIT(cRif) .AND. nLen<8
      cRif:=PADR("V"+STRZERO(VAL(cRif),8),nLenO)
      oFrmTrabj:oRifVal:VarPut(cRif,.T.)
   ENDIF

/*
   IF ISALLDIGIT(cRif) .AND. nLen=8
      cRif:=PADR("V"+cRif,nLenO)
      oFrmTrabj:oRifVal:VarPut(cRif,.T.)
   ENDIF
*/
   // Debe Activar el Captha
   IF oDp:pCapCha=NIL .OR. .T.
      lOk:=EJECUTAR("RIFANTICAPCHA",cRif,.T.)
   ENDIF

   IF oFrmTrabj:nOption=1 .AND. !Empty(oDp:aDataRif)

      aLine:=ALLTRIM(oDp:aDataRif[1])
      aLine:=_VECTOR(aLine," ")

      IF !Empty(oDp:cDataRif)

         oFrmTrabj:oRifVal:VarPut(oDp:cDataRif,.T.)
         oFrmTrabj:oRIF:VarPut(oDp:cDataRif,.T.)

         IF oDp:lCodigoNmAsRif

            nLen     :=LEN(oFrmTrabj:CODIGO)
            oFrmTrabj:oCODIGO:VarPut(PADR(oDp:cDataRif,nLen),.T.)

         ENDIF

      ENDIF

      IF LEN(aLine)=5 .AND. aLine[3]="DEL"
         aLine[2]:=aLine[3]+" "+aLine[4]
         aLine[3]:=aLine[4]
         aLine[4]:=aLine[5]
         ARREDUCE(aLine,5)
      ENDIF 

      IF LEN(aLine)=5 
         oFrmTrabj:oAPELLIDO:VarPut(aLine[3] ,PADR(LEN(oFrmTrabj:APELLIDO)) ,.T.)
         oFrmTrabj:oAPELLIDO2:VarPut(aLine[4],PADR(LEN(oFrmTrabj:APELLIDO2)),.T.)
         oFrmTrabj:oNOMBRE:VarPut(aLine[1]   ,PADR(LEN(oFrmTrabj:NOMBRE))   ,.T.)
         oFrmTrabj:oNOMBRE2:VarPut(aLine[2]  ,PADR(LEN(oFrmTrabj:NOMBRE2))  ,.T.)
      ENDIF 

      IF LEN(aLine)=3
         oFrmTrabj:oAPELLIDO:VarPut(aLine[3] ,PADR(LEN(oFrmTrabj:APELLIDO)) ,.T.)
         oFrmTrabj:oAPELLIDO2:VarPut(aLine[2],PADR(LEN(oFrmTrabj:APELLIDO2)),.T.)
         oFrmTrabj:oNOMBRE:VarPut(aLine[1]   ,PADR(LEN(oFrmTrabj:NOMBRE))   ,.T.)
      ENDIF 

      IF LEN(aLine)=4 

         oFrmTrabj:oAPELLIDO:VarPut(aLine[3] ,PADR(LEN(oFrmTrabj:APELLIDO)) ,.T.)
         oFrmTrabj:oAPELLIDO2:VarPut(aLine[4],PADR(LEN(oFrmTrabj:APELLIDO2)),.T.)
         oFrmTrabj:oNOMBRE:VarPut(aLine[1]   ,PADR(LEN(oFrmTrabj:NOMBRE))   ,.T.)
         oFrmTrabj:oNOMBRE2:VarPut(aLine[2]  ,PADR(LEN(oFrmTrabj:NOMBRE2))  ,.T.)
 
      ENDIF

      oFrmTrabj:oAPELLIDO:Refresh(.T.)
      oFrmTrabj:oAPELLIDO2:Refresh(.T.)
      oFrmTrabj:oNOMBRE:Refresh(.T.)
      oFrmTrabj:oNOMBRE2:Refresh(.T.)
      oFrmTrabj:VALCODIGO()

      // Actualiza el Campo Tipo de Cedula
      IF !Empty(oDp:cDataRif)

        cTipCed:=LEFT(oDp:cDataRif,1)
        nCedula:=SUBS(oDp:cDataRif,2,LEN(oDp:cDataRif))
        oFrmTrabj:oTIPO_CED:VarPut(cTipCed,.T.)

        oFrmTrabj:oCEDULA:VarPut(nCedula,.T.)
 
        COMBOINI(oFrmTrabj:oTIPO_CED)

        DPFOCUS(oFrmTrabj:oCODIGO)

      ENDIF

   ENDIF

   //ViewArray(oDp:aDataRif)
   
RETURN .T.

FUNCTION VALCODIGO()

  oFrmTrabj:SetEdit(.T.)
  oFrmTrabj:oScroll:SetEdit(.T.)
  oFrmTrabj:oScroll2:SetEdit(.T.)
  oFrmTrabj:oScroll3:SetEdit(.T.)

RETURN .T.

FUNCTION VALSALARIO()
RETURN .T.

FUNCTION VALCODDEP()

  IF !ISSQLFIND("DPDPTO","DEP_CODIGO"+GetWhere("=",oFrmTrabj:COD_DPTO))
     oFrmTrabj:oCOD_DPTO:KeyBoard(VK_F6)
     RETURN .T.
  ENDIF

  oFrmTrabj:oSAYDPTO:Refresh(.T.)

RETURN .T.

FUNCTION VALFECHA_ING()
  oFrmTrabj:oAntiguead:Refresh(.T.)

RETURN .T.

FUNCTION VALCEDULA()
   LOCAL nLen:=LEN(oFrmTrabj:RIF),cRif

   IF Empty(oFrmTrabj:RIF) .AND. !Empty(oFrmTrabj:CEDULA)
      cRif:=PADR(LEFT(oFrmTrabj:TIPO_CED,1)+LSTR(oFrmTrabj:CEDULA),nLen)
      oFrmTrabj:oRIF:VarPut(cRif,.T.)
   ENDIF

RETURN .T.
/*
<LISTA:CODIGO:Y:GET:N:N:Y:C«digo,APELLIDO:N:GET:N:N:Y:Apellido,NOMBRE:N:GET:N:N:Y:Nombre,FECHA_ING:N:BMPGET:N:N:Y:Ingreso
,CONDICION:N:COMBO:N:N:Y:Condici«n,TIPO_CED:N:COMBO:N:N:Y:Tipo de C'dula,CEDULA:N:GET:N:N:Y:C'dula,TIPO_NOM:N:COMBO:N:N:Y:Tipo de N«mina
,FORMA_PAG:N:COMBO:N:N:Y:Forma de Pago,SCROLLGET:N:GET:N:N:N
*/

