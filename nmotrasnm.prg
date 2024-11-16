// Programa   : NMOTRASNM
// Fecha/Hora : 11/10/2004 15:57:45
// Propósito  : Incluir/Modificar NMOTRASNM
// Creado Por : DpXbase
// Llamado por: NMOTRASNM.LBX
// Aplicación : Nómina                                  
// Tabla      : NMOTRASNM

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION NMOTRASNM(nOption,cTipo,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Otras Nóminas",;
        aItems1:=GETOPTIONS("NMOTRASNM","OTR_PERIOD"),;
        aItems2:=GETOPTIONS("NMOTRASNM","OTR_TIPTRA")

  cExcluye:="OTR_CODIGO,;
             OTR_DESCRI,;
             OTR_PERIOD,;
             OTR_INICIO,;
             OTR_FIN,;
             OTR_CODFOR,;
             OTR_CODREP,;
             OTR_VARIAC,;
             OTR_TIPTRA"

  DEFAULT cTipo:="O",cCodigo:="VI"

  DEFAULT nOption:=1

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD 
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM NMOTRASNM WHERE OTR_TIPO]+GetWhere("=",cTipo)+[ AND OTR_CODIGO]+GetWhere("=",cCodigo)
    cTitle   :=" Incluir {oDp:NMOTRASNM}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM NMOTRASNM WHERE OTR_TIPO]+GetWhere("=",cTipo)+[ AND OTR_CODIGO]+GetWhere("=",cCodigo)
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Otras Nóminas                           "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:NMOTRASNM}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM NMOTRASNM]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="OTR_TIPO,OTR_CODIGO" // Clave de Validación de Registro

  oNMOTRASNM:=DPEDIT():New(cTitle,"NMOTRASNM.edt","oNMOTRASNM" , .F. )

  oNMOTRASNM:nOption  :=nOption
  oNMOTRASNM:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oNMOTRASNM
  oNMOTRASNM:SetScript()        // Asigna Funciones DpXbase como Metodos de oNMOTRASNM
  oNMOTRASNM:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oNMOTRASNM:nOption  :=nOption

  IF oNMOTRASNM:nOption=1 // Incluir en caso de ser Incremental
     // oNMOTRASNM:RepeatGet(NIL,"OTR_CODIGO") // Repetir Valores
     // AutoIncremental 
//   oNMOTRASNM:OTR_REPPRE:=PADR("PRENOMINA",LEN(oNMOTRASNM:OTR_REPPRE))
     oNMOTRASNM:OTR_CODREP:=PADR("RECIBO"   ,LEN(oNMOTRASNM:OTR_CODREP))
  ELSE

     oNMOTRASNM:OTR_TIPO:=cTipo

  ENDIF

  //Tablas Relacionadas con los Controles del Formulario

  oNMOTRASNM:CreateWindow()       // Presenta la Ventana

  oNMOTRASNM:OTR_CODCTA:=EJECUTAR("DPGETCTAMOD","NMOTRASNM_CTA",oNMOTRASNM:OTR_CODIGO,"","CUENTA")

  
  oNMOTRASNM:ViewTable("DPREPORTES","REP_DESCRI","REP_CODIGO","OTR_CODREP")
  oNMOTRASNM:ViewTable("DPREPORTES","REP_DESCRI","REP_CODIGO","OTR_REPPRE",,"ODPREPPRE")
  oNMOTRASNM:ViewTable("DPTABMON"  ,"MON_DESCRI","MON_CODIGO","OTR_CODMON")

  oNMOTRASNM:oNMCTA   :=oNMOTRASNM:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","OTR_CODCTA")

  @ 1,12 COMBOBOX oNMOTRASNM:oOTR_TIPO  VAR oNMOTRASNM:OTR_TIPO  ITEMS {"Semanal","Catorcenal","Quincenal","Mensual","Otra"};
         WHEN (AccessField("NMOTRASNM","OTR_TIPO",oNMOTRASNM:nOption);
              .AND. oNMOTRASNM:nOption!=0);
         ON CHANGE (1=1)

  COMBOINI(oNMOTRASNM:oOTR_TIPO)

  //
  // Campo : OTR_CODIGO
  // Uso   : Código                                  
  //
  @ 1.0, 1.0 GET oNMOTRASNM:oOTR_CODIGO  VAR oNMOTRASNM:OTR_CODIGO  VALID oNMOTRASNM:VALUNIQUE(LEFT(oNMOTRASNM:OTR_TIPO,1)+oNMOTRASNM:OTR_CODIGO,"OTR_TIPO,OTR_CODIGO");
                   .AND. !VACIO(oNMOTRASNM:OTR_CODIGO,NIL);
                    WHEN (AccessField("NMOTRASNM","OTR_CODIGO",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0 .AND. LEFT(oNMOTRASNM:OTR_TIPO,1)="O");
                    FONT oFontG

    oNMOTRASNM:oOTR_CODIGO:cMsg    :="Código"
    oNMOTRASNM:oOTR_CODIGO:cToolTip:="Código"

  @ oNMOTRASNM:oOTR_CODIGO:nTop-08,oNMOTRASNM:oOTR_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : OTR_DESCRI
  // Uso   : Descripción                             
  //
  @ 2.8, 1.0 GET oNMOTRASNM:oOTR_DESCRI  VAR oNMOTRASNM:OTR_DESCRI ;
                    WHEN (AccessField("NMOTRASNM","OTR_DESCRI",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                    FONT oFontG

    oNMOTRASNM:oOTR_DESCRI:cMsg    :="Descripción"
    oNMOTRASNM:oOTR_DESCRI:cToolTip:="Descripción"

  @ oNMOTRASNM:oOTR_DESCRI:nTop-08,oNMOTRASNM:oOTR_DESCRI:nLeft SAY "Descripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : OTR_PERIOD
  // Uso   : Periodo de Actualización                
  //
  @ 4.1, 1.0 COMBOBOX oNMOTRASNM:oOTR_PERIOD VAR oNMOTRASNM:OTR_PERIOD ITEMS aItems1;
                      WHEN (AccessField("NMOTRASNM","OTR_PERIOD",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                      FONT oFontG;

// ? oNMOTRASNM:OTR_PERIOD,"oNMOTRASNM:OTR_PERIOD"

  ComboIni(oNMOTRASNM:oOTR_PERIOD)


  oNMOTRASNM:oOTR_PERIOD:cMsg    :="Periodo de Actualización"
  oNMOTRASNM:oOTR_PERIOD:cToolTip:="Periodo de Actualización"

  @ oNMOTRASNM:oOTR_PERIOD:nTop-08,oNMOTRASNM:oOTR_PERIOD:nLeft SAY "Periodo de Actualización" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : OTR_INICIO
  // Uso   : Fecha de Inicio                         
  //
  @ 5.9, 1.0 BMPGET oNMOTRASNM:oOTR_INICIO  VAR oNMOTRASNM:OTR_INICIO  PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
          ACTION LbxDate(oNMOTRASNM:oOTR_INICIO,oNMOTRASNM:OTR_INICIO);
                    WHEN (AccessField("NMOTRASNM","OTR_INICIO",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                    FONT oFontG

    oNMOTRASNM:oOTR_INICIO:cMsg    :="Fecha de Inicio"
    oNMOTRASNM:oOTR_INICIO:cToolTip:="Fecha de Inicio"

  @ oNMOTRASNM:oOTR_INICIO:nTop-08,oNMOTRASNM:oOTR_INICIO:nLeft SAY "Fecha de Inicio" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : OTR_FIN   
  // Uso   : Fecha de Culminación                    
  //
  @ 7.7, 1.0 BMPGET oNMOTRASNM:oOTR_FIN     VAR oNMOTRASNM:OTR_FIN     PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
          ACTION LbxDate(oNMOTRASNM:oOTR_FIN,oNMOTRASNM:OTR_FIN);
                    WHEN (AccessField("NMOTRASNM","OTR_FIN",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                    FONT oFontG

    oNMOTRASNM:oOTR_FIN   :cMsg    :="Fecha de Culminación"
    oNMOTRASNM:oOTR_FIN   :cToolTip:="Fecha de Culminación"

  @ oNMOTRASNM:oOTR_FIN   :nTop-08,oNMOTRASNM:oOTR_FIN   :nLeft SAY "Fecha de Cierre" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

/*
  //
  // Campo : OTR_CODFOR
  // Uso   : Formato Crystal                         
  //
  @ 9.5, 1.0 BMPGET oNMOTRASNM:oOTR_CODFOR  VAR oNMOTRASNM:OTR_CODFOR ;
          NAME "BITMAPS\FIND.BMP";
          ACTION  (cFile:=cGetFile32("Fichero(*.*) |*.*|Ficheros (*.*) |*.*",;
                    "Seleccionar Archivo (*.*)",1,cFilePath(oNMOTRASNM:OTR_CODFOR),.f.,.t.),;
                    cFile:=STRTRAN(cFile,"/","/"),;
                    oNMOTRASNM:OTR_CODFOR:=IIF(!EMPTY(cFile),cFile,oNMOTRASNM:OTR_CODFOR),;
                    DPFOCUS(oNMOTRASNM:oOTR_CODFOR));
                    WHEN (AccessField("NMOTRASNM","OTR_CODFOR",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                    FONT oFontG

    oNMOTRASNM:oOTR_CODFOR:cMsg    :="Formato Crystal"
    oNMOTRASNM:oOTR_CODFOR:cToolTip:="Formato Crystal"

  @ oNMOTRASNM:oOTR_CODFOR:nTop-08,oNMOTRASNM:oOTR_CODFOR:nLeft SAY "Formato Crystal para el Recibo de Pago" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

*/

  //
  // Campo : OTR_CODREP
  // Uso   : Reporte de Reporte de Recibos
  //
  @ 1.0,15.0 BMPGET oNMOTRASNM:oOTR_CODREP  VAR oNMOTRASNM:OTR_CODREP  VALID CERO(oNMOTRASNM:OTR_CODREP);
                   .AND. oNMOTRASNM:oDPREPORTES:SeekTable("REP_CODIGO",oNMOTRASNM:oOTR_CODREP,NIL,oNMOTRASNM:oREP_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPREPORTES"), oDpLbx:GetValue("REP_CODIGO",oNMOTRASNM:oOTR_CODREP)); 
                    WHEN (AccessField("NMOTRASNM","OTR_CODREP",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                    FONT oFontG

    oNMOTRASNM:oOTR_CODREP:cMsg    :="Reporte de Recibos"
    oNMOTRASNM:oOTR_CODREP:cToolTip:="Reporte de Pecibos"

  @ oNMOTRASNM:oOTR_CODREP:nTop-08,oNMOTRASNM:oOTR_CODREP:nLeft SAY "Reporte para Recibos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

//oNMOTRASNM:oDPREPORTES:cSingular
  @ oNMOTRASNM:oOTR_CODREP:nTop,oNMOTRASNM:oOTR_CODREP:nRight+5 SAY oNMOTRASNM:oREP_DESCRI;
                            PROMPT oNMOTRASNM:oDPREPORTES:REP_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  



  //
  // Campo : OTR_REPPRE
  // Uso   : Reporte de Prenómina                    
  //
  @ 1.0,15.0 BMPGET oNMOTRASNM:oOTR_REPPRE  VAR oNMOTRASNM:OTR_REPPRE  VALID EMPTY(oNMOTRASNM:OTR_REPPRE) .OR. (CERO(oNMOTRASNM:OTR_REPPRE);
                   .AND. oNMOTRASNM:oDPREPPRE:SeekTable("REP_CODIGO",oNMOTRASNM:oOTR_REPPRE,NIL,oNMOTRASNM:oREP_DESCRI2));
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPREPORTES"), oDpLbx:GetValue("REP_CODIGO",oNMOTRASNM:oOTR_REPPRE)); 
                    WHEN (AccessField("NMOTRASNM","OTR_REPPRE",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                    FONT oFontG

    oNMOTRASNM:oOTR_REPPRE:cMsg    :="Reporte de Prenómina"
    oNMOTRASNM:oOTR_REPPRE:cToolTip:="Reporte de Prenómina"

  @ oNMOTRASNM:oOTR_REPPRE:nTop-08,oNMOTRASNM:oOTR_REPPRE:nLeft SAY "Reporte para PreNómina" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ oNMOTRASNM:oOTR_REPPRE:nTop,oNMOTRASNM:oOTR_REPPRE:nRight+5 SAY oNMOTRASNM:oREP_DESCRI2;
                            PROMPT oNMOTRASNM:oDPREPPRE:REP_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


  //
  // Campo : OTR_CODCTA
  // Uso   : Cuenta Contable                         
  //
  @ 1.8,10.0 BMPGET oNMOTRASNM:oOTR_CODCTA  VAR oNMOTRASNM:OTR_CODCTA;
                    VALID (Empty(oNMOTRASNM:OTR_CODCTA) .OR. oNMOTRASNM:oNMCTA:SeekTable("CTA_CODIGO",oNMOTRASNM:oOTR_CODCTA,NIL));
                          .AND. oNMOTRASNM:PUTCUENTA(oNMOTRASNM:OTR_CODCTA,oNMOTRASNM:oSayCtaOtr);
                          .AND. EJECUTAR("ISCTADET",oNMOTRASNM:OTR_CODCTA);
                    NAME "BITMAPS\FIND.BMP"; 
                    ACTION (oDpLbx:=DPLBX("DPCTAUTILIZACION.LBX"),;
                            oDpLbx:GetValue("CTA_CODIGO",oNMOTRASNM:oOTR_CODCTA)); 
                    WHEN .T.;
                    FONT oFontG

// ACTION (oDpLbx:=DPLBX("DPCTAUTILIZACION.LBX",NIL,NIL,NIL,"CTA_CODIGO",NIL,NIL,NIL,NIL,oNMOTRASNM:oOTR_CODCTA),oDpLbx:GetValue("CTA_CODIGO",oNMOTRASNM:oOTR_CODCTA)); 


  oNMOTRASNM:oOTR_CODCTA:cMsg    :="Cuenta Contable para Nómina por Pagar"
  oNMOTRASNM:oOTR_CODCTA:cToolTip:="Cuenta Contable para Nómina por Pagar"

  @ 0,0 SAY "Cuenta Nómina por Pagar:" 

  @ 3,1  SAY oNMOTRASNM:oSayCtaOtr;
         PROMPT SPACE(40) 

  oNMOTRASNM:PUTCUENTA(oNMOTRASNM:OTR_CODCTA,oNMOTRASNM:oSayCtaOtr)  


  // Campo : OTR_ACTIVO
  // Uso   : Depende de Variaciones                  
  //
  @ 1.8,15.0 CHECKBOX oNMOTRASNM:oOTR_ACTIVO  VAR oNMOTRASNM:OTR_ACTIVO  PROMPT ANSITOOEM("Activo");
                    WHEN (AccessField("NMOTRASNM","OTR_ACTIVO",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 172,10

  oNMOTRASNM:oOTR_ACTIVO:cMsg    :="Registro Activo"
  oNMOTRASNM:oOTR_ACTIVO:cToolTip:="Registro Activo"


  // Campo : OTR_PLAFIN
  // Uso   : Depende de Variaciones                  
  //
  @ 2.8,15.0 CHECKBOX oNMOTRASNM:oOTR_PLAFIN  VAR oNMOTRASNM:OTR_PLAFIN  PROMPT ANSITOOEM("Planificación Financiera");
                    WHEN (AccessField("NMOTRASNM","OTR_PLAFIN",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 172,10

  oNMOTRASNM:oOTR_PLAFIN:cMsg    :="Planificación Financiera"
  oNMOTRASNM:oOTR_PLAFIN:cToolTip:="Planificación Financiera"

  // Campo : OTR_VARIAC
  // Uso   : Depende de Variaciones                  
  //
  @ 2.8,15.0 CHECKBOX oNMOTRASNM:oOTR_VARIAC  VAR oNMOTRASNM:OTR_VARIAC  PROMPT ANSITOOEM("Depende de Variaciones");
                    WHEN (AccessField("NMOTRASNM","OTR_VARIAC",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 172,10

    oNMOTRASNM:oOTR_VARIAC:cMsg    :="Depende de Variaciones"
    oNMOTRASNM:oOTR_VARIAC:cToolTip:="Depende de Variaciones"


  //
  // Campo : OTR_TIPTRA
  // Uso   : Tipo de Trabajador                      
  //
  @ 4.1,15.0 COMBOBOX oNMOTRASNM:oOTR_TIPTRA VAR oNMOTRASNM:OTR_TIPTRA ITEMS aItems2;
                      WHEN (AccessField("NMOTRASNM","OTR_TIPTRA",oNMOTRASNM:nOption);
                    .AND. oNMOTRASNM:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMOTRASNM:oOTR_TIPTRA)


    oNMOTRASNM:oOTR_TIPTRA:cMsg    :="Tipo de Trabajador"
    oNMOTRASNM:oOTR_TIPTRA:cToolTip:="Tipo de Trabajador"

  @ oNMOTRASNM:oOTR_TIPTRA:nTop-08,oNMOTRASNM:oOTR_TIPTRA:nLeft SAY "Tipo de Trabajador" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  //
  // Campo : OTR_CODMON
  // Uso   : Código Moneda                        
  //
  @ 1.8,10.0 BMPGET oNMOTRASNM:oOTR_CODMON  VAR oNMOTRASNM:OTR_CODMON;
                    VALID (Empty(oNMOTRASNM:OTR_CODMON) .OR. (oNMOTRASNM:oDPTABMON:SeekTable("MON_CODIGO",oNMOTRASNM:oOTR_CODMON,NIL) .AND. oNMOTRASNM:VALCODMON()) );
                    NAME "BITMAPS\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("DPTABMON"), oDpLbx:GetValue("MON_CODIGO",oNMOTRASNM:oOTR_CODMON)); 
                    WHEN .T.;
                    FONT oFontG

  oNMOTRASNM:oOTR_CODMON:cMsg    :="Código de Moneda"
  oNMOTRASNM:oOTR_CODMON:cToolTip:="Código de Moneda"

  @ 0,0 SAY "Código Moneda:" 

  @ 3,1  SAY oNMOTRASNM:oSayCodMon PROMPT SQLGET("DPTABMON","MON_DESCRI","MON_CODIGO"+GetWhere("=",oNMOTRASNM:OTR_CODMON))

  @ 10,0 SAY "Tipo" 




  @ 21, 1.0 BMPGET oNMOTRASNM:oOTR_CTAPRE  VAR oNMOTRASNM:OTR_CTAPRE ;
            VALID  oNMOTRASNM:VALCTAPRE();
                   NAME "BITMAPS\FIND.BMP"; 
                   ACTION (oDpLbx:=DpLbx("DPCTAPRESUP",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL), oDpLbx:GetValue("CPP_CODIGO",oNMOTRASNM:oOTR_CTAPRE)); 
                   WHEN (AccessField("DPDPGRU","OTR_CTAPRE",oNMOTRASNM:nOption);
                         .AND. oNMOTRASNM:nOption!=0);
                   FONT oFontG;
                   SIZE 40,10

    oNMOTRASNM:oOTR_CTAPRE:cMsg    :="Cuenta Presupuestaria"
    oNMOTRASNM:oOTR_CTAPRE:cToolTip:="Cuenta Presupuestaria"

  @ 20,0 SAY GetFromVar("{oDp:xDPCTAPRESUP}")

  @ 20,0  SAY oNMOTRASNM:oCPP_DESCRI;
         PROMPT SQLGET("DPCTAPRESUP","CPP_DESCRI","CPP_CODIGO"+GetWhere("=",oNMOTRASNM:OTR_CTAPRE)) PIXEL;
         SIZE NIL,12 FONT oFont COLOR 16777215,16711680 

  oNMOTRASNM:Activate({||oNMOTRASNM:ViewDatBar()})

  oNMOTRASNM:oOTR_DESCRI:VARPUT(oTable:OTR_DESCRI,.T.)

  oNMOTRASNM:OTR_PERIOD:=oTable:OTR_PERIOD
  COMBOINI(oNMOTRASNM:oOTR_PERIOD)


  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oNMOTRASNM

FUNCTION VALCODMON()
  oNMOTRASNM:oSayCodMon:Refresh(.T.)
RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn
   LOCAL oDlg:=oNMOTRASNM:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-5,60-5 OF oDlg 3D CURSOR oCursor

   IF oNMOTRASNM:nOption=2 


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            TOP PROMPT "Cerrar";
            ACTION (oNMOTRASNM:Close())

     oBtn:cToolTip:="Salir"

   ELSE

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            TOP PROMPT "Grabar";
            ACTION (oNMOTRASNM:Save())

     oBtn:cToolTip:="Grabar"

     DEFINE BUTTON oBtn;
            OF oBar;
            FONT oFont;
            NOBORDER;
            FILENAME "BITMAPS\\XCANCEL.BMP";
            TOP PROMPT "Cancelar";
            ACTION (oNMOTRASNM:Cancel()) CANCEL

     oBtn:cToolTip:="Cancelar"

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.



/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oNMOTRASNM:nOption=1 // Incluir en caso de ser Incremental
     
     // AutoIncremental 
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  // lResp:=oNMOTRASNM:ValUnique(oNMOTRASNM:OTR_CODIGO)

  oNMOTRASNM:OTR_TIPO:=LEFT(oNMOTRASNM:OTR_TIPO,1)

  lResp:=oNMOTRASNM:VALUNIQUE(LEFT(oNMOTRASNM:OTR_TIPO,1)+oNMOTRASNM:OTR_CODIGO,"OTR_TIPO,OTR_CODIGO");

  IF !lResp
        MsgAlert("Registro "+CTOO(oNMOTRASNM:OTR_CODIGO),"Ya Existe")
  ENDIF

  IF Empty(oNMOTRASNM:OTR_CTAPRE)
     EJECUTAR("DPCTAPRESUP_INDEF")
     oNMOTRASNM:OTR_CTAPRE:=oDp:cCtaPre
   ENDIF


RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)

  oDb:EXECUTE("UPDATE NMOTRASNM SET OTR_CODNOM=CONCAT(OTR_TIPO,OTR_CODIGO)")

  EJECUTAR("SETCTAINTMOD","NMOTRASNM_CTA",oNMOTRASNM:OTR_CODIGO,"","CUENTA",oNMOTRASNM:OTR_CODCTA,.T.)

RETURN .T.

/*
// Busca el Nombre de la Cuenta Contable
*/
FUNCTION PUTCUENTA(cCodCta,oSayCta)
   oSayCta:SETTEXT(SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta)))
RETURN .T.

FUNCTION VALCTAPRE()
   LOCAL cTipo

   oNMOTRASNM:oCPP_DESCRI:Refresh(.T.)

   IF !ISSQLFIND("DPCTAPRESUP","CPP_CODIGO"+GetWhere("=",oNMOTRASNM:OTR_CTAPRE))
     oNMOTRASNM:oNMOTRASNM_CTAPRE:KeyBoard(VK_F6)
   ENDIF

   cTipo:=SQLGET("DPCTAPRESUP","CPP_TIPO","CPP_CODIGO"+GetWhere("=",oNMOTRASNM:OTR_CTAPRE))

   IF cTipo<>"D"
      oNMOTRASNM:oOTR_CTAPRE:MsgErr("Cuenta "+oNMOTRASNM:OTR_CTAPRE+CRLF+"Debe Aceptar Transacciones","Validación")
      oNMOTRASNM:oOTR_CTAPRE:KeyBoard(VK_F6)
      RETURN .F.
   ENDIF

RETURN .T.



/*
<LISTA:OTR_CODIGO:Y:GET:N:N:N:Código,OTR_DESCRI:N:GET:N:N:Y:Descripción,OTR_PERIOD:N:COMBO:N:N:Y:Periodo de Actualización,OTR_INICIO:N:BMPGET:N:N:Y:Fecha de Inicio
,OTR_FIN:N:BMPGET:N:N:Y:Fecha de Cierre,OTR_CODFOR:N:BMPGETF:N:N:Y:Formato Crystal para el Recibo de Pago,OTR_CODREP:N:BMPGETL:N:N:Y:Reporte de Prenómina,OTR_VARIAC:N:CHECKBOX:N:N:Y:Depende de Variaciones
,OTR_TIPTRA:N:COMBO:N:N:Y:Tipo de Trabajador>
*/

