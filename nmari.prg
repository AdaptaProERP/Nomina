// Programa   : NMARI
// Fecha/Hora : 08/08/2005 17:06:06
// Propósito  : Incluir/Modificar NMARI
// Creado Por : DpXbase
// Llamado por: NMARI.LBX
// Aplicación : Recursos Humanos                        
// Tabla      : NMARI

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION NMARI(nOption,dFecha,cCodTra,nTrim)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,oDpLbx
  LOCAL cTitle,cSql,cFile,cExcluye:="",cWhereTra,nCargas:=0
  LOCAL nClrText,nAnual:=0,nAt:=0
  LOCAL cTitle:="A.R.I. Del Trabajador"
  LOCAL aItems1:={"Enero-Marzo","Abril-Junio","Julio-Septiembre","Octubre-Diciembre"}
  LOCAL aFechas:={"31/03/","30/06/","30/09/","31/12/"}

  cExcluye:=""

  DEFAULT dFecha:=oDp:dFecha, nOption:=1,nTrim:=0

  // 04/01/2023, necesario para ejecutar N011

//  IF !TYPE("oNM")="O"
//    PUBLICO("oNm",TNOMINA():New())
//  ENDIF

  IF Empty(oDp:cISLR) 
     MsgRun("Leyendo Definiciones de Nómina")
     EJECUTAR("NMRESTDATA")
  ENDIF

  IF oDp:oNmARI=NIL
    MSGRUN("Compilando Nómina, Calcular Ingreso Anual del Trabajador","Espere....",{||EJECUTAR("NMINIARI")})
  ENDIF


  DEFAULT oDp:dFchIni:=oDp:dFchInicio,;
          oDp:dFchFin:=oDp:dFchCierre

  IF Empty(cCodTra)

 
    oDpLbx:=GetDpLbx(oDp:nNumLbx)

    IF ValType(oDpLbx)="O" .AND. oDpLbx:oWnd:hWnd>0 .AND. ValType(oDpLbx:cCargo)="C"

       cCodTra:=oDpLbx:cCargo // Trabajador
     
    ELSE

      cCodTra:=SQLGET("NMTRABAJADOR","CODIGO")

    ENDIF

  ENDIF

  nAt    :=Max(ASCAN(aFechas,{|a,n,c|c:=Val(Subs(a,4,2)),Month(dFecha)=c}),1)
  cTitle   :=GetFromVar("{oDp:NMARI}")
  nClrText :=10485760 // Color del texto
  cSql     :="SELECT * FROM NMARI WHERE ARI_FECHA"+GetWhere("=",dFecha)+;
             "   AND ARI_CODTRA"+GetWhere("=",cCodTra)


// "   AND ARI_CODSUC"+GetWhere("=",oDp:cSucursal)+; 


  cWhereTra:="ARI_CODTRA"+GetWhere("=",cCodTra)

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD 
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cTitle   :=" Incluir "+cTitle
    nAt++
    nAt      :=MIN(nAt,Len(aFechas))

    IF nTrim>0
       nAt:=nTrim // 11/05/2023
    ENDIF

  ELSE // Modificar o Consultar
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" "+cTitle
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)
//oTable:BROWSE()

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM NMARI]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="ARI_FECHA " // Clave de Validación de Registro

  oNMARI:=DPEDIT():New(cTitle,"NMARI.edt","oNMARI" , .F. )

  oNMARI:nOption  :=nOption
  oNMARI:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oNMARI
  oNMARI:SetScript()        // Asigna Funciones DpXbase como Metodos de oNMARI
  oNMARI:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oNMARI:nClrPane  :=oDp:nGris
  oNMARI:nAno      :=YEAR(oNMARI:ARI_FECHA)
  oNMARI:nAno      :=IIF(oNMARI:nAno=0,YEAR(oDp:dFecha),oNMARI:nAno)
  oNMARI:nTotalIng :=0
  oNmARI:TRIMESTRE :=aItems1[nAt]
  oNmARI:cWhereTra :=cWhereTra
  oNmARI:cMemo     :=ALLTRIM(oNMARI:ARI_MEMO)
  oNmARI:nTrim     :=nTrim


  oNmARI:ARI_CODTRA:=cCodTra
  oNmARI:ARI_RIF   :=SQLGET("NMTRABAJADOR","RIF","CODIGO"+GetWhere("=",cCodTra))

  IF oNMARI:nOption=1 // Incluir en caso de ser Incremental

     oNmARI:cMemo     :=""
     oNmARI:ARI_INGANU:=oNmARI:INGREASOANUAL()
     oNmAri:TRIMESTRE :=aItems1[MAX(nAt,1)]
     oNMARI:nAno      :=YEAR(oDp:dFecha)
    
  ENDIF

  oNmARI:cMemoIng  :="" 
  //Tablas Relacionadas con los Controles del Formulario

  oNMARI:CreateWindow()       // Presenta la Ventana

  @ 2,1 GROUP oNMARI:oGrupo TO 4, 21.5 PROMPT " [ Resultado ]"    
  @ 2,1 GROUP oNMARI:oNMARIpo TO 4, 21.5 PROMPT " Periodo e Ingreso Anual "   
  @ 2,1 GROUP oNMARI:oNMARIpo TO 4, 21.5 PROMPT " Desgravámenes "   
  @ 2,1 GROUP oNMARI:oNMARIpo TO 4, 21.5 PROMPT " % del Trimestre"   
  @ 2,1 GROUP oNMARI:oNMARIpo TO 4, 21.5 PROMPT " Seleccione "   
  @ 2,1 GROUP oNMARI:oNMARIpo TO 4, 21.5 PROMPT " RIF "   
 // @ 4,1 GROUP oNMARI:oNMARIpo TO 4, 21.5 PROMPT " Fecha: "   



  // Opciones del Formulario
  //
  // Campo : ARI_FECHA 
  // Uso   : Fecha                                   
  //
  @ 1.0, 1.0 GET oNMARI:oARI_ANO   VAR oNMARI:nAno  PICTURE "9999";
                 SPINNER;
                 VALID oNmAri:VALFECHA(.F.);
                 WHEN (AccessField("NMARI","ARI_FECHA",oNMARI:nOption);
                 .AND. oNMARI:nOption!=0 .AND. oNmARI:nTrim=0);
                  FONT oFontG

  @ 0,0 SAY "Año:" PIXEL;
        SIZE NIL,7 FONT oFont 


  //
  // Campo : TRIMESTRE  
  // Uso   : Trimeste del Periodo
  //

  @ 02, 10 COMBOBOX oNmAri:oTRIMESTRE  VAR oNmAri:TRIMESTRE ITEMS aItems1;
                       VALID oNmAri:VALFECHA(.T.);
                       WHEN (AccessField("NMTRABAJADOR","TRIMESTRE",oNmAri:nOption);
                      .AND. oNmAri:nOption!=0 .AND. oNmARI:nTrim=0);
                       FONT oFontG;

   ComboIni(oNmAri:oTRIMESTRE  )
   oNmAri:oTRIMESTRE  :cMsg    :="Trimestre del Periodo"
   oNmAri:oTRIMESTRE  :cToolTip:="Trimestre del Periodo"

  @ 0,0 SAY "Trimestre:" PIXEL;
        SIZE NIL,7 FONT oFont 

  //
  // Campo : ARI_INGANU
  // Uso   : Ingreso Anual                           
  //
  @ 2.8, 1.0 GET oNMARI:oARI_INGANU  VAR oNMARI:ARI_INGANU  PICTURE "99,99,999,999,999.99";
                 VALID oNMARI:CALCULAR(); 
                 WHEN (AccessField("NMARI","ARI_INGANU",oNMARI:nOption);
                 .AND. oNMARI:nOption!=0);
                  FONT oFontG;
                  SIZE 64,10;
                  RIGHT


    oNMARI:oARI_INGANU:cMsg    :="Ingreso Anual Estimado por Concepto "+oDp:cCalAnual
    oNMARI:oARI_INGANU:cToolTip:="Ingreso Anual Estimado por Concepto "+oDp:cCalAnual

  @ 0,0 SAY "Ingreso Anual Estimado Según Concepto "+oDp:cCalAnual PIXEL;
             SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  //
  // Campo : ARI_OTRING
  // Uso   : Ingreso Anual                           
  //
  @ 2.8, 1.0 GET oNMARI:oARI_OTRING  VAR oNMARI:ARI_OTRING  PICTURE "99,99,999,999,999.99";
                 VALID oNMARI:CALCULAR(); 
                 WHEN (AccessField("NMARI","ARI_OTRING",oNMARI:nOption);
                 .AND. oNMARI:nOption!=0);
                  FONT oFontG;
                  SIZE 64,10;
                  RIGHT


    oNMARI:oARI_OTRING:cMsg    :="oTros ingresos Estimados"
    oNMARI:oARI_OTRING:cToolTip:="oTros ingresos Estimados"

  @ 2,10 SAY "Otros Ingresos Estimados" PIXEL;
             SIZE NIL,7 FONT oFont COLOR nClrText,15724527



  //
  // Campo : ARI_IMPMAS
  // Uso   : Impuesto Pagado de Más
  //
  @ 2.8, 1.0 GET oNMARI:oARI_IMPMAS  VAR oNMARI:ARI_IMPMAS  PICTURE "99,99,999,999,999.99";
                 VALID oNMARI:CALCULAR(); 
                 WHEN (AccessField("NMARI","ARI_IMPMAS",oNMARI:nOption);
                 .AND. oNMARI:nOption!=0);
                  FONT oFontG;
                  SIZE 64,10;
                  RIGHT


    oNMARI:oARI_IMPMAS:cMsg    :="Impuesto pagado de Más en Años Anteriores"
    oNMARI:oARI_IMPMAS:cToolTip:="Impuesto pagado de Más en Años Anteriores"

  @ 0,0 SAY "Impuesto pagado"+CRLF+"de más";
             SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  // Campo : ARI_INSDOC
  // Uso   : Institutos Docentes                     
  //
  @ 8.2, 1.0 GET oNMARI:oARI_INSDOC  VAR oNMARI:ARI_INSDOC  PICTURE "99,999,999,999.99";
                 VALID oNMARI:CALCULAR();
                 WHEN (AccessField("NMARI","ARI_INSDOC",oNMARI:nOption);
                     .AND. oNMARI:nOption!=0);
                 FONT oFontG;
                 SIZE 56,10;
                 RIGHT


    oNMARI:oARI_INSDOC:cToolTip:="Institutos Docentes por la Educación del Contribuyente y "+CRLF+"Descendientes no Mayores de 25 Años"
    oNMARI:oARI_INSDOC:cMsg    :=STRTRAN(oNMARI:oARI_INSDOC:cToolTip,CRLF,"")

  @ 0,0 SAY "Institutos Docentes"+CRLF+"por la Educación" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : ARI_HCM   
  // Uso   : Primas de H.C.M.                        
  //
  @ 6.4, 1.0 GET oNMARI:oARI_HCM     VAR oNMARI:ARI_HCM     PICTURE "99,999,999,999.99";
                 VALID oNMARI:CALCULAR();
                 WHEN (AccessField("NMARI","ARI_HCM",oNMARI:nOption);
                     .AND. oNMARI:nOption!=0);
                      FONT oFontG;
                      SIZE 56,10;
                      RIGHT


    oNMARI:oARI_HCM   :cMsg    :="Primas de Seguro, de H.C.M."
    oNMARI:oARI_HCM   :cToolTip:="Primas de Seguro, de H.C.M."

  @ oNMARI:oARI_HCM   :nTop-08,oNMARI:oARI_HCM   :nLeft SAY "Primas de Seguro,"+CRLF+"de H.C.M" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  //
  //
  // Campo : ARI_SERMED
  // Uso   : Servicios Médicos Odontológicos         
  //
  @ 10.0, 1.0 GET oNMARI:oARI_SERMED  VAR oNMARI:ARI_SERMED  PICTURE "99,999,999,999.99";
                  VALID oNMARI:CALCULAR();
                  WHEN (AccessField("NMARI","ARI_SERMED",oNMARI:nOption);
                      .AND. oNMARI:nOption!=0);
                  FONT oFontG;
                  SIZE 56,10;
                  RIGHT

    oNMARI:oARI_SERMED:cToolTip:="Servicios Médicos "+CRLF+"Odontológicos y Hospitalización (Incluye Carga Familiar)"
    oNMARI:oARI_SERMED:cMsg    :=STRTRAN(oNMARI:oARI_SERMED:cToolTip,CRLF,"")

  @ oNMARI:oARI_SERMED:nTop-08,oNMARI:oARI_SERMED:nLeft SAY "Servicios Médicos "+CRLF+"Odontológicos y Hospitalización" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  //
  // Campo : ARI_ALQUIL
  // Uso   : Alquiler o Intereses Vivienda           
  //
  @ 4.6, 1.0 GET oNMARI:oARI_ALQUIL  VAR oNMARI:ARI_ALQUIL  PICTURE "99,999,999,999.99";
                 VALID oNMARI:CALCULAR();
                 WHEN (AccessField("NMARI","ARI_ALQUIL",oNMARI:nOption);
                      .AND. oNMARI:nOption!=0);
                      FONT oFontG;
                      SIZE 56,10;
                      RIGHT


    oNMARI:oARI_ALQUIL:cToolTip:="Intereses para la Adquisición para la Vivienda Princial"+CRLF+;
                                 "o de lo pagado por Alquiler de la Vivienda que sirve de"+CRLF+;
                                 "asiento permanente del Hogar"
    oNMARI:oARI_ALQUIL:cMsg    :=STRTRAN(oNMARI:oARI_ALQUIL:cToolTip,CRLF,"")


  @ 0,0 SAY "Intereses Adq. Vivienda Ppal."+CRLF+"o pagado por Alquiler" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,15724527

  //
  // Campo : ARI_PORCEN
  // Uso   : Porcentaje                              
  //
  @ 1.0,15.0 GET oNMARI:oARI_PORCEN  VAR oNMARI:ARI_PORCEN  PICTURE "999.99";
                    VALID oNMARI:CALCULAR();
                    WHEN (AccessField("NMARI","ARI_PORCEN",oNMARI:nOption);
                    .AND. oNMARI:nOption!=0);
                    FONT oFontG;
                    SIZE 24,10;
                    RIGHT


    oNMARI:oARI_PORCEN:cMsg    :="Porcentaje"
    oNMARI:oARI_PORCEN:cToolTip:="Porcentaje"

  @ 0,0 SAY "% " PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,15724527

//  @ 2,1 SAY SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,', ',NOMBRE)","CODIGO"+GetWhere("=",oNmARI:ARI_CODTRA))


  // Campo : cMemo
  //
  @ 1.1, 0.0 GET oNMARI:oMemo VAR oNMARI:ARI_MEMO;
             MEMO SIZE 80,80; 
             READONLY


  @ 12,2  CHECKBOX oNMARI:ARI_DESUNI PROMPT ANSITOOEM("Desgravámen Unico ");
          ON CHANGE oNMARI:CALCULAR()


  //
  // Campo : ARI_RIF
  // Uso   : Rif del Trabajador Obtenido de la Ficha
  //
  @ 09.0,15.0 GET oNMARI:oARI_RIF  VAR oNMARI:ARI_RIF;  
                    WHEN (AccessField("NMTRABAJADOR","ARI_RIF",oNMARI:nOption);
                    .AND. oNMARI:nOption!=0);
                    FONT oFontG;
                    SIZE 24,10;
                    RIGHT


  oNMARI:oARI_PORCEN:cMsg    :="R.I.F. del Trabajador"
  oNMARI:oARI_PORCEN:cToolTip:="R.I.F. del Trabajador"

/*
  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMARI:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oNMARI:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMARI:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF
*/

  oNMARI:Activate({||oNmAri:INICIO()})

//  oNmARI:ARI_INGANU:=oNmARI:INGREASOANUAL()
  // oNMARI:CALCULAR()
  oNMARI:VALFECHA(.F.)

//  oNMARI:oGrupo:Hide()

  oDp:nDif :=(oDp:aCoors[3]-180-oNMARI:oWnd:nHeight())
  oDp:nDifH:=(oDp:aCoors[4]-020-oNMARI:oWnd:nWidth())

  oNMARI:oWnd:SetSize(NIL,oDp:aCoors[3]-180,.T.)
  oNMARI:oMemo:SetSize(NIL,oNMARI:oMemo:nHeight()+oDp:nDif,.T.)



  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oNMARI

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()


  IF oNMARI:nOption=1 // Incluir en caso de ser Incremental
     
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

  IF EMPTY(oNMARI:ARI_FECHA ) // Clave de Validación de Registro
     MensajeErr("Registro no debe estar Vacío")
     RETURN .F.
  ENDIF

  IF !oNmAri:ValUnique(oNmAri:ARI_FECHA ,"ARI_FECHA",NIL,"ARI_CODTRA"+GetWhere("=",oNmAri:ARI_CODTRA))
      RETURN .F.
  ENDIF

  oNmAri:ARI_TRIMES:=oNmAri:oTRIMESTRE:nAt // 11/05/2023
  

  // Condiciones para no Repetir el Registro

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
   LOCAL cField:="ISR"+LSTR(oNmAri:oTRIMESTRE:nAt)
    
   // En caso que el porcentaje sea negativo grabara en la planilla el valor pero
   // en la ficha colocara Cero
   IF oNMARI:ARI_PORCEN>0

      SQLUPDATE("NMTRABAJADOR",cField,oNMARI:ARI_PORCEN,"CODIGO"+GetWhere("=",oNMARI:ARI_CODTRA))
      SQLUPDATE("NMTRABAJADOR","RIF" ,oNMARI:ARI_RIF   ,"CODIGO"+GetWhere("=",oNMARI:ARI_CODTRA))

   ELSE

      SQLUPDATE("NMTRABAJADOR",cField,"0.00","CODIGO"+GetWhere("=",oNMARI:ARI_CODTRA))
      SQLUPDATE("NMTRABAJADOR","RIF" ,oNMARI:ARI_RIF   ,"CODIGO"+GetWhere("=",oNMARI:ARI_CODTRA))

   ENDIF


   oNMARI:IMPRIME()

//   EJECUTAR("NMARIIMP",oNMARI:ARI_CODTRA,oNMARI:ARI_FECHA)

   oNmAri:Close()

RETURN .T.

FUNCTION IMPRIME()
  // Imprimir ARI
RETURN EJECUTAR("ARI-IMPRIMIR",oNMARI:ARI_CODTRA,oNMARI:ARI_FECHA)
/*
  LOCAL oTable,oData
  LOCAL cFileDbf:=oDp:cPathCrp+"ARI.DBF",cCIV,cCIE,cCI

  oData:=DATASET("NOMINA","ALL",,,,"CRIF")


  oTable:=OpenTable(" SELECT * FROM NMARI "+;
                    " INNER JOIN NMTRABAJADOR ON ARI_CODTRA=CODIGO "+;
                    " WHERE ARI_CODTRA"+GetWhere("=",oNMARI:ARI_CODTRA)+;
                    " AND ARI_FECHA"+GetWhere("=",oNMARI:ARI_FECHA),.T.)
  
  cCIV  :=SPACE(8)
  cCIE  :=SPACE(8)
  cCI   :=PADR(LSTR(oTable:CEDULA),8)

  IF oTable:TIPO_CED="V"
     cCIV:=cCI // PADR(LSTR(oTable:CEDULA,8))
  ELSE
     cCIE:=cCI // PADR(LSTR(oTable:CEDULA,8))
  ENDIF

  // CI/VENE
  oTable :Replace("CIV_1"  ,SUBS(cCIV,1,1))
  oTable :Replace("CIV_2"  ,SUBS(cCIV,2,1))
  oTable :Replace("CIV_3"  ,SUBS(cCIV,3,1))
  oTable :Replace("CIV_4"  ,SUBS(cCIV,4,1))
  oTable :Replace("CIV_5"  ,SUBS(cCIV,5,1))
  oTable :Replace("CIV_6"  ,SUBS(cCIV,6,1))
  oTable :Replace("CIV_7"  ,SUBS(cCIV,7,1))
  oTable :Replace("CIV_8"  ,SUBS(cCIV,8,1))


  // CI/EXTRA
  oTable :Replace("CIE_1"  ,SUBS(cCIE,1,1))
  oTable :Replace("CIE_2"  ,SUBS(cCIE,2,1))
  oTable :Replace("CIE_3"  ,SUBS(cCIE,3,1))
  oTable :Replace("CIE_4"  ,SUBS(cCIE,4,1))
  oTable :Replace("CIE_5"  ,SUBS(cCIE,5,1))
  oTable :Replace("CIE_6"  ,SUBS(cCIE,6,1))
  oTable :Replace("CIE_7"  ,SUBS(cCIE,7,1))
  oTable :Replace("CIE_8"  ,SUBS(cCIE,8,1))

  // 
  oTable :Replace("CI_1"  ,SUBS(cCI,1,1))
  oTable :Replace("CI_2"  ,SUBS(cCI,2,1))
  oTable :Replace("CI_3"  ,SUBS(cCI,3,1))
  oTable :Replace("CI_4"  ,SUBS(cCI,4,1))
  oTable :Replace("CI_5"  ,SUBS(cCI,5,1))
  oTable :Replace("CI_6"  ,SUBS(cCI,6,1))
  oTable :Replace("CI_7"  ,SUBS(cCI,7,1))
  oTable :Replace("CI_8"  ,SUBS(cCI,8,1))



  oTable:Replace("APELYNOM",ALLTRIM(oTable:APELLIDO)+" ,"+ALLTRIM(oTable:NOMBRE))
  oTable:Replace("EMPRESA",oDp:cEmpresa)
  
  oTable:Replace("ANOGRAV",YEAR(oNMARI:ARI_FECHA))
  oTable:Replace("TRIMEST1"," ")
  oTable:Replace("TRIMEST2"," ")
  oTable:Replace("TRIMEST3"," ")
  oTable:Replace("TRIMEST4"," ")
  oTable:Replace("TRIMEST"+LSTR(oNmAri:oTRIMESTRE:nAt),"X")


//RIF TRABAJADOR

  oTable :Replace("TRIF_1"  ,SUBS(oNMARI:ARI_RIF,1,1))
  oTable :Replace("TRIF_2"  ,SUBS(oNMARI:ARI_RIF,2,1))
  oTable :Replace("TRIF_3"  ,SUBS(oNMARI:ARI_RIF,3,1))
  oTable :Replace("TRIF_4"  ,SUBS(oNMARI:ARI_RIF,4,1))
  oTable :Replace("TRIF_5"  ,SUBS(oNMARI:ARI_RIF,5,1))
  oTable :Replace("TRIF_6"  ,SUBS(oNMARI:ARI_RIF,6,1))
  oTable :Replace("TRIF_7"  ,SUBS(oNMARI:ARI_RIF,7,1))
  oTable :Replace("TRIF_8"  ,SUBS(oNMARI:ARI_RIF,8,1))
  oTable :Replace("TRIF_9"  ,SUBS(oNMARI:ARI_RIF,9,1))
  oTable :Replace("TRIF_10"  ,SUBS(oNMARI:ARI_RIF,10,1))

  oTable:Replace("ARI_MEMO","")
// "TRIMEST"+LSTR(oNmAri:oTRIMESTRE:nAt)
//  oTable:Browse()

  oTable:CTODBF(cFileDbf)
  
  oTable:End()

  RUNRPT(oDp:cPathCrp+"ARI.RPT",{cFileDbf},1,"ARC "+ALLTRIM(oTable:APELYNOM))

  oData:End(.F.)

RETURN .T.
*/

FUNCTION VALFECHA(lDo)
  LOCAL aFechas:={"31/03/","30/06/","30/09/","31/12/"}

  oNmAri:ARI_FECHA:=CTOD(aFechas[oNmAri:oTRIMESTRE:nAt]+STRZERO(oNMARI:nAno,4))

  IF lDo
     oNmAri:ValUnique(oNmAri:ARI_FECHA ,"ARI_FECHA",NIL,"ARI_CODTRA"+GetWhere("=",oNmAri:ARI_CODTRA))
  ENDIF

RETURN .T.

FUNCTION CALCULAR()
  LOCAL cMemo:="",A:=0,B:=0,C:=0,D:=0,E:=0,F:=0,UT:=0,oTable,G:=0,S:=0,H:=0,H3,H2,H1,I:=0,J,cSql,dDesde,dHasta,nISLR:=0,K:=0,P:=0
  LOCAL nCargas:=COUNT("NMFAMILIA","FAM_CODTRA"+GetWhere("=", oNmARI:ARI_CODTRA)+" AND FAM_DEPEND='S'")
  LOCAL aLista:={},nAsigna:=0
  LOCAL cFecha:=IIF(Left(oDp:cTipFecha,1)="D","FCH_DESDE","FCH_HASTA")
  LOCAL nCNS95:=CNS(95)

  IF Empty(oNmARI:cMemoIng)
     oNmARI:INGREASOANUAL()
  ENDIF

  IF nCNS95=0
     nCNS95:=774 // Cantidad de Unidades Tributarias
  ENDIF
	
  oNMARI:nTotalIng :=oNMARI:ARI_INGANU+oNMARI:ARI_OTRING
  A:=oNMARI:nTotalIng
  UT:=EJECUTAR("NMGETUT",oNmAri:ARI_FECHA)
  B:=DIV(A,UT)

  // C SUMA(T36:AB39) Otros degramenes
  C:=oNMARI:ARI_ALQUIL+oNMARI:ARI_HCM+oNMARI:ARI_INSDOC+oNMARI:ARI_SERMED

  // D D43/I43 D43=C; I43= valor unidad tributaria
  D:=DIV(C,UT)


  // E= SI(T40>0;0;774)  T40 es C;  774 monto fijo degramene
  IF C=0
    E:=nCNS95 // CNS(95)
  ENDIF 

  // F =B47-G47 B- (D o E)
  IF oNMARI:ARI_DESUNI
    //D:=MAX(CNS(95),D)
    F:=B-nCNS95 // CNS(95)
  ELSE
    F:=B-D
  ENDIF

  H1:=1*10
  H2:=(nCargas)*10

  oTable:=OpenTable("SELECT * FROM NMTARIFAISLR ORDER BY TAR_UT",F>0)

  WHILE !oTable:Eof()
    P:=oTable:TAR_PORCEN
    S:=oTable:TAR_SUSTRA       
    IF F<=oTable:TAR_UT
       EXIT
    ENDIF
    oTable:DbSkip()
  ENDDO


/*
  // G =SI(T47<=1000;T47*J74;SI(Y(T47>1000;T47<=1500);(T47*J75)-Z75;SI(Y(T47>1500;T47<=2000);(T47*J76)-Z76;SI(Y(T47>2000;T47<=2500);(T47*J77)-Z77;SI(Y(T47>2500;T47<=3000);(T47*J78)-Z78;SI(Y(T47>3000;T47<=4000);(T47*J79)-Z79;SI(Y(T47>4000;T47<=6000);(T47*J80)-Z80;(T47*J81)-Z81)))))))
  // T47 es F
*/
  G:=((F*P)/100)-S
  
  oTable:End()

  H3:=DIV(oNMARI:ARI_IMPMAS,UT)
  H:=H3+H2+H1

  // I=  +SI(T52<T58;0;T52-T58)
  // I=        G<H ;0;   G-H 
  I :=G-H

  // J= T59/T32*100
  // J=   I/B*100
  J :=DIV(I,B)*100

  IF oNmAri:oTRIMESTRE:nAt>1  // Variación

     dDesde:=CTOD("01/01/"+STRZERO(oNMARI:nAno,4))
     dHasta:=FCHFINMES(FCHINIMES(oNMARI:ARI_FECHA)-1)

     nIslr:=SQLGET("NMHISTORICO","SUM(HIS_MONTO)"," INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO "+;
           " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
           " WHERE REC_CODTRA "+GetWhere("=",oNMARI:ARI_CODTRA)+;
           "   AND HIS_CODCON "+GetWhere("=",oDp:cISLR)+;
           "   AND "+GetWhereAnd(cFecha,dDesde,dHasta))*-1

     aLista:=ATABLE("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_ISLR=1",.T.)

     nAsigna:=SQLGET("NMHISTORICO","SUM(HIS_MONTO)"," INNER JOIN NMRECIBOS ON HIS_NUMREC=REC_NUMERO "+;
              " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
              " WHERE REC_CODTRA "+GetWhere("=",oNMARI:ARI_CODTRA)+;
              "   AND ("+GetWhereOr("HIS_CODCON",aLista)+")"+;
              "   AND "+GetWhereAnd(cFecha,dDesde,dHasta))

    //J :=0

    // K= (T59*I43-T68)/(C26-T69)*100
    // K= ( I * ValorUnTrib - Impuesto retenido hasta la fecha)/
    //    (Total por percibir de la empresa-Total remuneraciones percibidas)*100  
    //K :=((I*UT)- nIslr)/(A-nAsigna)*100

    // nResult:=NMROUND(SALARIO/2,2)

    K :=NMROUND(((I*UT)- nIslr)/(A-nAsigna)*100,2)

    //? K,"K"


  ENDIF

  K:=MAX(K,0) // % no puede ser negativo, JN 04/01/2023



  cMemo:="Otros Ingresos:"+SPACE(19)+FDP(oNMARI:ARI_OTRING,"999,999,999,999.99")+CRLF+;
         "               "+SPACE(19)+"=================="+CRLF+;
         "Total Ingresos:"+SPACE(19)+FDP(oNMARI:nTotalIng,"999,999,999,999.99")+CRLF+CRLF+;
         "Unidad Tributaria                 : "+FDP(UT,"9,999,9999.99")+"("+DTOC(oDp:dFechaUT)+") Al "+DTOC(oNmAri:ARI_FECHA)+CRLF+;
         "Remuneraciones en UT           [B]: "+FDP( B ,"999,999,999")+CRLF+;
         "Total Desgravámenes            [C]: "+FDP( C ,"999,999,999,999,999.99")+CRLF+;
         "Desgravámenes en  UT           [D]: "+FDP( D ,"999,999,999")+IIF(oNMARI:ARI_DESUNI," Optó por Desgravámen Unico","")+CRLF+;
         "Determinación Renta Gravable   [F]: "+FDP( F ,"999,999,999")+CRLF+;
         "Calculo del Impuesto Estimado  [G]: "+FDP( G ,"999999")+CRLF+;
         "Rebaja Personal                [H1]: "+FDP( H1 ,"999999")+" Rebaja Personal " + " 1" +CRLF+;
         "Rebaja en Cargas Familiares    [H2]: "+FDP( H2 ,"999999")+" Cargas Familiares "+LSTR(nCargas)+CRLF+;
	    "Impuesto Retenido de más       [H3]: "+FDP( H3 ,"999999")+" Impuesto Retenido de más " +CRLF+;
         "Rebaja de Impuesto             [H]: "+FDP( H ,"999999")+CRLF+;
         "Impuesto Estimado              [I]: "+FDP( I ,"999999")+CRLF



  IF oNmAri:oTRIMESTRE:nAt>1  // Variación
      
      oNMARI:oARI_PORCEN:VarPut(K,.T.)

      cMemo:=cMemo+;
            "Total Impuesto Retenido a la Fecha  : "   +FDP( nIslr   ,"9,999,9999,999.99")+CRLF+;
            "Asignaciones a la Fecha "+DTOC(dHasta)+":"+FDP( nAsigna ,"9,999,9999,999.99")+CRLF+;
            "% por Variación Aplicables Resto del Año               [K]: "+FDP( K ,"999.99")+CRLF

  ELSE

    oNMARI:oARI_PORCEN:VarPut(J,.T.)

    cMemo:=cMemo+;
            "% de Retención Inicial         [J]: "+FDP( J ,"999.99")+CRLF

  ENDIF

  oNmAri:ARI_A :=A
  oNmAri:ARI_B :=B
  oNmAri:ARI_C :=C
  oNmAri:ARI_D :=D
  oNmAri:ARI_E :=E
  oNmAri:ARI_F :=F
  oNmAri:ARI_G :=G
  oNmAri:ARI_H :=H
  oNmAri:ARI_H1:=H1
  oNmAri:ARI_H2:=H2
  oNmAri:ARI_UT:=UT
  oNmAri:ARI_H3:=H3
  oNmAri:ARI_I :=I
  oNmAri:ARI_J :=J
  oNmAri:ARI_K :=K
  oNmAri:ARI_ISLR  :=nIslr
  oNmAri:ARI_ASIGNA:=nAsigna 
  oNmAri:ARI_CARGAS:=nCargas

  // cMemo:=oNmARI:cMemo+CRLF+cMemo
  cMemo:=oNmARI:cMemoIng+CRLF+cMemo
  oNMARI:oMemo:VarPut(cMemo,.T.)

RETURN .T.

FUNCTION INGREASOANUAL()
  LOCAL nAnual:=0,aN11


  IF oDp:oNmARI=NIL
    MSGRUN("Compilando Nómina, Calcular Ingreso Anual del Trabajador","Espere....",{||EJECUTAR("NMINIARI")})
  ENDIF

  aN11:=ATABLE("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_CODIGO='N011' ",.T.)

//? aN11,"aN11"

//? oDp:cCalAnual,"oDp:cCalAnual"

  oDp:cCalAnual:="N011"
  oDp:cMemo    :=""

  // Calcular Ingreso Anual
  oDp:oNMARI:oLee:CODIGO:=oNmARI:ARI_CODTRA // cCodTra
  oDp:oNMARI:lSysError  :=.F.
  oDp:oNMARI:dDesde :=oDp:dFecha
  oDp:oNMARI:dHasta :=oDp:dFecha
  oDp:oNMARI:cFields:="*" // Todos los Campos
  oDp:oNMARI:LoadTrabajador()
  oDp:oNMARI:CargaVariac() // Carga las Variaciones
  //nAnual:=oDp:cCalAnual
  nAnual:=CONCEPTO("N011") // Dias de Vacaciones de Ley
  //nAnual:=CONCEPTO(oDp:cCalAnual ) // Dias de Vacaciones de Ley
  oNMARI:ARI_MEMO:=oDp:cMemo
  oNmARI:cMemo   :=oDp:cMemo
  oNmARI:cMemoIng:=oNmARI:cMemo

//? nAnual,"nAnual"


RETURN nAnual


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oNMARI:oDlg
   LOCAL nCol:=32

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

   IF oNMARI:nOption!=2


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          ACTION (oNMARI:Save())

   oBtn:cToolTip:="Guardar"

   oNMARI:oBtnSave:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FAMILIA.BMP",NIL,"BITMAPS\FAMILIA2.BMP";
          ACTION EJECUTAR("NMFAMILIA",oNmARI:ARI_CODTRA,oNMARI:oNombre:GetText())

   oBtn:cToolTip:="Datos Familiares"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XCANCEL.BMP";
          ACTION (oNMARI:Cancel()) CANCEL

   ELSE

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oNMARI:Cancel()) CANCEL


   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| nCol:=nCol+o:nWidth(),o:SetColor(CLR_BLACK,oDp:nGris) })

   @ 00,nCol SAY " "+oNmARI:ARI_CODTRA+" " OF oBar BORDER SIZE 90,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL
   @ 21,nCol SAY oNMARI:oNombre PROMPT " "+SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,', ',NOMBRE)","CODIGO"+GetWhere("=",oNmARI:ARI_CODTRA))+" " OF oBar BORDER SIZE 280,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 80,20 PIXEL

RETURN .T.





/*
<LISTA:ARI_FECHA:N:GET:N:N:Y:Fecha,ARI_INGANU:N:GET:N:N:Y:Ingreso Anual,ARI_ALQUIL:N:GET:N:N:Y:Alquiler o Intereses Vivienda,ARI_HCM:N:GET:N:N:Y:Primas de H.C.M.
,ARI_INSDOC:N:GET:N:N:Y:Institutos Docentes,ARI_SERMED:N:GET:N:N:Y:Servicios Médicos Odontológicos,ARI_PORCEN:N:GET:N:N:Y:Porcentaje>
*/
