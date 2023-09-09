// Programa   : NMTRACORRESPOND
// Fecha/Hora : 19/02/2008 01:36:11
// Propósito  : Incluir/Modificar NMTRACORRESPOND
// Creado Por : DpXbase
// Llamado por: NMTRACORRESPOND.LBX
// Aplicación : Definiciones del Sistema                
// Tabla      : NMTRACORRESPOND

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION NMTRACORRESPOND(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Correspondencia para Trabajador"

  cExcluye:="CLC_CODIGO,;
             CLC_DESCRI,;
             CLC_MEMO"

  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM NMTRACORRESPOND WHERE ]+BuildConcat("CLC_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:NMTRACORRESPOND}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM NMTRACORRESPOND WHERE ]+BuildConcat("CLC_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Correspondencia para NMentes           "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:NMTRACORRESPOND}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM NMTRACORRESPOND]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="CLC_CODIGO" // Clave de Validación de Registro

  oNMCORRESPOND:=DPEDIT():New(cTitle,"NMTRACORRESPOND.edt","oNMCORRESPOND" , .F. )

  oNMCORRESPOND:nOption  :=nOption
  oNMCORRESPOND:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oNMCORRESPOND
  oNMCORRESPOND:SetScript()        // Asigna Funciones DpXbase como Metodos de oNMCORRESPOND
  oNMCORRESPOND:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oNMCORRESPOND:nClrPane:=oDp:nGris

  IF oNMCORRESPOND:nOption=1 // Incluir en caso de ser Incremental
     // oNMCORRESPOND:RepeatGet(NIL,"CLC_CODIGO") // Repetir Valores
     oNMCORRESPOND:CLC_ACTIVO:=.T.
     // AutoIncremental 
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oNMCORRESPOND:CreateWindow()       // Presenta la Ventana

  // Opciones del Formulario

  
  //
  // Campo : CLC_CODIGO
  // Uso   : Código                                  
  //
  @ 1.0, 1.0 GET oNMCORRESPOND:oCLC_CODIGO  VAR oNMCORRESPOND:CLC_CODIGO  VALID oNMCORRESPOND:ValUnique(oNMCORRESPOND:CLC_CODIGO);
                    WHEN (AccessField("NMTRACORRESPOND","CLC_CODIGO",oNMCORRESPOND:nOption);
                    .AND. oNMCORRESPOND:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oNMCORRESPOND:oCLC_CODIGO:cMsg    :="Código"
    oNMCORRESPOND:oCLC_CODIGO:cToolTip:="Código"

  @ oNMCORRESPOND:oCLC_CODIGO:nTop-08,oNMCORRESPOND:oCLC_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : CLC_DESCRI
  // Uso   : Descripción                             
  //
  @ 2.8, 1.0 GET oNMCORRESPOND:oCLC_DESCRI  VAR oNMCORRESPOND:CLC_DESCRI ;
                    WHEN (AccessField("NMTRACORRESPOND","CLC_DESCRI",oNMCORRESPOND:nOption);
                    .AND. oNMCORRESPOND:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oNMCORRESPOND:oCLC_DESCRI:cMsg    :="Descripción"
    oNMCORRESPOND:oCLC_DESCRI:cToolTip:="Descripción"

  @ oNMCORRESPOND:oCLC_DESCRI:nTop-08,oNMCORRESPOND:oCLC_DESCRI:nLeft SAY "Descripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  @ 2,1 BMPGET oNMCORRESPOND:oCLC_FILE VAR oNMCORRESPOND:CLC_FILE NAME "BITMAPS\FOLDER5.BMP";
                                        ACTION oNMCORRESPOND:CLC_FILE:=EJECUTAR("GETFILE",oNMCORRESPOND:CLC_FILE,"*.HTM",NIL,NIL,oNMCORRESPOND:oCLC_FILE);
                                        VALID oNMCORRESPOND:VALFILE();
                                        WHEN !Empty(oNMCORRESPOND:oCLC_MEMO)

  @ 3,1 SAY "Fichero Modelo"

  oNMCORRESPOND:CLC_MEMO:=ALLTRIM(oNMCORRESPOND:CLC_MEMO)  //
  // Campo : CLC_MEMO  
  // Uso   : Contenido                               
  //
  @ 4.6, 1.0 GET oNMCORRESPOND:oCLC_MEMO    VAR oNMCORRESPOND:CLC_MEMO  ;
           MEMO SIZE 80,80; 
      ON CHANGE 1=1;
                    WHEN (AccessField("NMTRACORRESPOND","CLC_MEMO",oNMCORRESPOND:nOption);
                    .AND. oNMCORRESPOND:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oNMCORRESPOND:oCLC_MEMO  :cMsg    :="Contenido"
    oNMCORRESPOND:oCLC_MEMO  :cToolTip:="Contenido"

  @ oNMCORRESPOND:oCLC_MEMO  :nTop-08,oNMCORRESPOND:oCLC_MEMO  :nLeft SAY "Contenido" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  @ 02,01 CHECKBOX oNMCORRESPOND:CLC_ACTIVO  PROMPT ANSITOOEM("Registro Activo")

  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMCORRESPOND:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oNMCORRESPOND:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip


  @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\NMENTE.BMP" NOBORDER;
             LEFT PROMPT "Campos"+CRLF+"del Trabajador";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMCORRESPOND:VerCampos())

    oBtn:cToolTip:="Ver Campos de la Tabla de NMentes"
    oBtn:cMsg    :=oBtn:cToolTip



  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMCORRESPOND:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF


  oNMCORRESPOND:Activate(NIL)

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oNMCORRESPOND

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oNMCORRESPOND:nOption=1 // Incluir en caso de ser Incremental
     
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

  lResp:=oNMCORRESPOND:ValUnique(oNMCORRESPOND:CLC_CODIGO)
  IF !lResp
        MsgAlert("Registro "+CTOO(oNMCORRESPOND:CLC_CODIGO),"Ya Existe")
  ENDIF

  IF EMPTY(oNMCORRESPOND:CLC_CODIGO)
     MensajeErr("Código no Puede estar Vacio")
     RETURN .F.
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
RETURN .T.

FUNCTION VERCAMPOS()
  LOCAL cField:=""

  cField:=BDLIST("DPCAMPOS",{"CAM_NAME","CAM_DESCRI","CAM_TYPE"},.T.,"CAM_TABLE"+GetWhere("=","NMTRABAJADOR"))
//        "Campos de la Tabla "+oDp:xNMTRAENTES)

  IF !Empty(cField)
     oNMCORRESPOND:oCLC_MEMO:Paste( "{"+cField+"}")
     oNMCORRESPOND:oCLC_MEMO:SetFocus()
  ENDIF

RETURN .T.

FUNCTION VALFILE()
RETURN .T.

/*
<LISTA:CLC_CODIGO:Y:GET:N:N:Y:Código,CLC_DESCRI:N:GET:N:N:Y:Descripción,CLC_MEMO:N:GET:N:N:Y:Contenido>
*/

