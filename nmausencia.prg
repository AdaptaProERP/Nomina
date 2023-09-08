// Programa   : NMAUSENCIA
// Fecha/Hora : 21/09/2004 16:57:40
// Propósito  : Incluir/Modificar NMAUSENCIA
// Creado Por : DpXbase
// Llamado por: NMAUSENCIA.LBX
// Aplicación : Nómina                                  
// Tabla      : NMAUSENCIA

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION NMAUSENCIA(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,dDesde
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Permisos y Ausencias"

  DEFAULT cCodigo:="1234",nOption:=1,oDp:nTrabajad:=0

  // Verifica Si existe Trabajador
  IF nOption=1 .AND. oDp:nTrabajad=0  

    oTable:=OpenTable("SELECT COUNT(*) AS CUANTOS FROM NMTRABAJADOR",.T.)
    oDp:nTrabajad:=oTable:FieldGet(1)
    oTable:End()

    IF oDp:nTrabajad=0  

      MensajeErr("No es posible Registrar Ausencias"+CRLF+"No hay Trabajadores Registrados")

      oTable:=GetDpLbx(oDp:nNumLbx)

      IF ValType(oTable)="O" 
        oTable:oWnd:End() // Debe Cerrarse
        oTable:=NIL
      ENDIF

      RETURN .T.

    ENDIF

  ENDIF

  IF nOption=3 .AND. .F.

    oTable:=OpenTable("SELECT * FROM NMAUSENCIA WHERE PER_NUMERO"+GetWhere("=",cCodigo),.T.)
    oTable:Browse()
    oTable:End()

    // Busca Fechas de Nómina Procesadas despues de la Fecha Desde
    oTable:=OpenTable("SELECT REC_NUMERO,FCH_DESDE,FCH_HASTA FROM NMRECIBOS "+;
                      "INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
                      "WHERE REC_CODTRA"+GetWhere("=" ,cCodigo)+;
                      "  AND FCH_DESDE "+GetWhere(">=",dDesde),.T.)
    oTable:Browse()
    oTable:End()
    ? "MODIFICAR"
  ENDIF

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  cSql    :="SELECT * FROM NMAUSENCIA WHERE PER_NUMERO"+GetWhere("=",cCodigo)

  IF nOption=1 // Incluir
    cTitle   :=" Incluir {oDp:NMAUSENCIA}"
  ELSE // Modificar o Consultar
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Permisos y Ausencias"
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:NMAUSENCIA}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM NMAUSENCIA]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="PER_NUMERO" // Clave de Validación de Registro

  oNMAUSENCIA:=DPEDIT():New(cTitle,"NMAUSENCIA.edt","oNMAUSENCIA" , .F. )

  oNMAUSENCIA:nOption  :=nOption
  oNMAUSENCIA:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oNMAUSENCIA
  oNMAUSENCIA:SetScript()        // Asigna Funciones DpXbase como Metodos de oNMAUSENCIA
  oNMAUSENCIA:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY

  IF oNMAUSENCIA:nOption=1 // Incluir en caso de ser Incremental
     // oNMAUSENCIA:RepeatGet(NIL,"PER_NUMERO") // Repetir Valores
     oNMAUSENCIA:PER_CODSUC:=oDp:cSucursal
     oNMAUSENCIA:PER_NUMERO:=oNMAUSENCIA:Incremental("PER_NUMERO",.T.,NIL,"PER_CODSUC"+GetWhere("=",oDp:cSucursal))
  ENDIF

  //Tablas Relacionadas con los Controles del Formulario

  oNMAUSENCIA:CreateWindow()       // Presenta la Ventana

  oNMAUSENCIA:ViewTable("NMTRABAJADOR"     ,"APELLIDO","CODIGO","PER_CODTRA",NIL,"ONMTRABJ")
  oNMAUSENCIA:ViewTable("NMTIPAUS"         ,"TAU_DESCRI","TAU_CODIGO","PER_CAUSA")
  oNMAUSENCIA:ViewTable("NMCODENFERMEDADES","CEN_DESCRI","CEN_CODIGO","PER_CODENF")

 
  //
  // Campo : PER_NUMERO
  // Uso   : Número                                  
  //
  @ 1.0, 1.0 GET oNMAUSENCIA:oPER_NUMERO  VAR oNMAUSENCIA:PER_NUMERO  VALID CERO(oNMAUSENCIA:PER_NUMERO) .AND.; 
                 oNMAUSENCIA:ValUnique(oNMAUSENCIA:PER_NUMERO);
                    WHEN (AccessField("NMAUSENCIA","PER_NUMERO",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0) .AND. .F.;
                    FONT oFontG

    oNMAUSENCIA:oPER_NUMERO:cMsg    :="Número"
    oNMAUSENCIA:oPER_NUMERO:cToolTip:="Número"

  @ oNMAUSENCIA:oPER_NUMERO:nTop-08,oNMAUSENCIA:oPER_NUMERO:nLeft SAY "Número" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : PER_CODTRA
  // Uso   : Trabajador                              
  //
  @ 2.8, 1.0 BMPGET oNMAUSENCIA:oPER_CODTRA  VAR oNMAUSENCIA:PER_CODTRA ;
                VALID oNMAUSENCIA:oNMTRABJ:SeekTable("CODIGO",oNMAUSENCIA:oPER_CODTRA,NIL,oNMAUSENCIA:oAPELLIDO);
                NAME "BITMAPS\FIND.BMP"; 
                ACTION (oDpLbx:=DpLbx("NMTRABAJADOR",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oNMAUSENCIA:oPER_CODTRA), oDpLbx:GetValue("CODIGO",oNMAUSENCIA:oPER_CODTRA)); 
                WHEN (AccessField("NMAUSENCIA","PER_CODTRA",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0);
                FONT oFontG

    oNMAUSENCIA:oPER_CODTRA:cMsg    :="Trabajador"
    oNMAUSENCIA:oPER_CODTRA:cToolTip:="Trabajador"

  @ oNMAUSENCIA:oPER_CODTRA:nTop-08,oNMAUSENCIA:oPER_CODTRA:nLeft SAY oDp:xNMTRABAJADOR PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

//oNMAUSENCIA:ONMTRABJ:cSingular
  @ oNMAUSENCIA:oPER_CODTRA:nTop,oNMAUSENCIA:oPER_CODTRA:nRight+5 SAY oNMAUSENCIA:oAPELLIDO;
                            PROMPT oNMAUSENCIA:ONMTRABJ:APELLIDO PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


  //
  // Campo : PER_DESDE 
  // Uso   : Desde                                   
  //
  @ 4.6, 1.0 BMPGET oNMAUSENCIA:oPER_DESDE   VAR oNMAUSENCIA:PER_DESDE   PICTURE "99/99/9999";
             VALID oNMAUSENCIA:VALFECHA(oNMAUSENCIA,.F.);
             NAME "BITMAPS\Calendar.bmp";
             ACTION (LbxDate(oNMAUSENCIA:oPER_DESDE,oNMAUSENCIA:PER_DESDE));
                    WHEN (AccessField("NMAUSENCIA","PER_DESDE",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0);
                    FONT oFontG

    oNMAUSENCIA:oPER_DESDE :cMsg    :="Desde"
    oNMAUSENCIA:oPER_DESDE :cToolTip:="Desde"

  @ oNMAUSENCIA:oPER_DESDE :nTop-08,oNMAUSENCIA:oPER_DESDE :nLeft SAY "Desde" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  oNMAUSENCIA:oPER_DESDE:bKeyDown  :={|nKey|IF(nKey=13,EVAL(oNMAUSENCIA:oPER_DESDE:bValid),NIL)}
  oNMAUSENCIA:oPER_DESDE:bLostFocus:={|| oNMAUSENCIA:oDESDE:Refresh(.T.)}

  //
  // Campo : PER_HASTA 
  // Uso   : Hasta                                   
  //
  @ 6.4, 1.0 BMPGET oNMAUSENCIA:oPER_HASTA   VAR oNMAUSENCIA:PER_HASTA   PICTURE "99/99/9999";
             VALID oNMAUSENCIA:VALFECHA(oNMAUSENCIA,.T.);
             NAME "BITMAPS\Calendar.bmp";
             ACTION (LbxDate(oNMAUSENCIA:oPER_HASTA,oNMAUSENCIA:PER_HASTA));
                    WHEN (AccessField("NMAUSENCIA","PER_HASTA",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0);
                    FONT oFontG

  oNMAUSENCIA:oPER_HASTA:bKeyDown  :={|nKey| IF(nKey=13,EVAL(oNMAUSENCIA:oPER_HASTA:bValid),NIL)}
  oNMAUSENCIA:oPER_HASTA:bLostFocus:={|| oNMAUSENCIA:oHASTA:Refresh(.T.)}


  oNMAUSENCIA:oPER_HASTA :cMsg    :="Hasta"
  oNMAUSENCIA:oPER_HASTA :cToolTip:="Hasta"

  @ oNMAUSENCIA:oPER_HASTA :nTop-08,oNMAUSENCIA:oPER_HASTA :nLeft SAY "Hasta" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : PER_CAUSA 
  // Uso   : Motivo                                  
  //
  @ 8.2, 1.0 BMPGET oNMAUSENCIA:oPER_CAUSA   VAR oNMAUSENCIA:PER_CAUSA   VALID CERO(oNMAUSENCIA:PER_CAUSA );
                   .AND. oNMAUSENCIA:oNMTIPAUS:SeekTable("TAU_CODIGO",oNMAUSENCIA:oPER_CAUSA,NIL,oNMAUSENCIA:oTAU_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("NMTIPAUS",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oNMAUSENCIA:oPER_CAUSA), oDpLbx:GetValue("TAU_CODIGO",oNMAUSENCIA:oPER_CAUSA)); 
                    WHEN (AccessField("NMAUSENCIA","PER_CAUSA",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0);
                    FONT oFontG

    oNMAUSENCIA:oPER_CAUSA :cMsg    :="Tipo de Ausencia"
    oNMAUSENCIA:oPER_CAUSA :cToolTip:="Tipo de Ausencia"

  @ oNMAUSENCIA:oPER_CAUSA :nTop-08,oNMAUSENCIA:oPER_CAUSA :nLeft SAY oDp:xNMTIPAUS PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ oNMAUSENCIA:oPER_CAUSA :nTop,oNMAUSENCIA:oPER_CAUSA :nRight+5 SAY oNMAUSENCIA:oTAU_DESCRI;
                            PROMPT oNMAUSENCIA:oNMTIPAUS:TAU_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


  //
  // Campo : PER_OBSER1
  // Uso   : Observación 1                           
  //
  @ 10.0, 1.0 GET oNMAUSENCIA:oPER_OBSER1  VAR oNMAUSENCIA:PER_OBSER1 ;
                    WHEN (AccessField("NMAUSENCIA","PER_OBSER1",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0);
                    FONT oFontG

    oNMAUSENCIA:oPER_OBSER1:cMsg    :="Observación 1"
    oNMAUSENCIA:oPER_OBSER1:cToolTip:="Observación 1"

  @ oNMAUSENCIA:oPER_OBSER1:nTop-08,oNMAUSENCIA:oPER_OBSER1:nLeft SAY "Observaciones" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : PER_OBSER2
  // Uso   : Observación 2                           
  //
  @ 1.0,15.0 GET oNMAUSENCIA:oPER_OBSER2  VAR oNMAUSENCIA:PER_OBSER2 ;
                    WHEN (AccessField("NMAUSENCIA","PER_OBSER2",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0);
                    FONT oFontG

    oNMAUSENCIA:oPER_OBSER2:cMsg    :="Observación 2"
    oNMAUSENCIA:oPER_OBSER2:cToolTip:="Observación 2"


  @ 0,0 SAY oNMAUSENCIA:oDESDE PROMPT CFECHA(oNMAUSENCIA:PER_DESDE)
  @ 0,0 SAY oNMAUSENCIA:oHASTA PROMPT CFECHA(oNMAUSENCIA:PER_HASTA)



  //
  // Campo : PER_CODENF
  // Uso   : Código de Enfermedad                               
  //
  @ 8.2, 1.0 BMPGET oNMAUSENCIA:oPER_CODENF  VAR oNMAUSENCIA:PER_CODENF  VALID CERO(oNMAUSENCIA:PER_CODENF);
                   .AND. oNMAUSENCIA:oNMCODENFERMEDADES       :SeekTable("CEN_CODIGO",oNMAUSENCIA:oPER_CODENF,NIL,oNMAUSENCIA:oCEN_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("NMCODENFERMEDADES",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oNMAUSENCIA:oPER_CODENF), oDpLbx:GetValue("CEN_CODIGO",oNMAUSENCIA:oPER_CODENF)); 
                    WHEN (AccessField("NMAUSENCIA","PER_CODENF",oNMAUSENCIA:nOption);
                    .AND. oNMAUSENCIA:nOption!=0);
                    FONT oFontG

    oNMAUSENCIA:oPER_CODENF:cMsg    :="Tipo de Ausencia"
    oNMAUSENCIA:oPER_CODENF:cToolTip:="Tipo de Ausencia"

  @ oNMAUSENCIA:oPER_CODENF:nTop-08,oNMAUSENCIA:oPER_CODENF:nLeft SAY oDp:xNMCODENFERMEDADES PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ oNMAUSENCIA:oPER_CODENF:nTop,oNMAUSENCIA:oPER_CODENF:nRight+5 SAY oNMAUSENCIA:oCEN_DESCRI;
                            PROMPT oNMAUSENCIA:oNMCODENFERMEDADES:CEN_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

/*
  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMAUSENCIA:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oNMAUSENCIA:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMAUSENCIA:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF

*/
  oNMAUSENCIA:oFocus:=oNMAUSENCIA:oPER_CODTRA

  oNMAUSENCIA:Activate({||oNMAUSENCIA:INICIO()})

  DPFOCUS(oNMAUSENCIA:oPER_CODTRA)

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oNMAUSENCIA


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oNMAUSENCIA:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD


   IF oNMAUSENCIA:nOption!=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (oNMAUSENCIA:Save())

     oBtn:cToolTip:="Guardar"

     oNMAUSENCIA:oBtnSave:=oBtn


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            ACTION (oNMAUSENCIA:Cancel()) CANCEL


   
   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oNMAUSENCIA:Cancel()) CANCEL

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

RETURN .T.



/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oNMAUSENCIA:nOption=1 // Incluir en caso de ser Incremental
     
     oNMAUSENCIA:PER_NUMERO:=oNMAUSENCIA:Incremental("PER_NUMERO",.T.)
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar


FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  lResp:=oNMAUSENCIA:ValUnique(oNMAUSENCIA:PER_NUMERO)
  IF !lResp
        MsgAlert("Registro "+CTOO(oNMAUSENCIA:PER_NUMERO),"Ya Existe")
  ENDIF
*/

FUNCTION PRESAVE() 
LOCAL lResp:=.T., nCuantos:=0 

lResp:=oNMAUSENCIA:ValUnique(oNMAUSENCIA:PER_NUMERO) 
IF !lResp 
MsgAlert("Registro "+CTOO(oNMAUSENCIA:PER_NUMERO),"Ya Existe") 
ENDIF 


//////////////////////////////////////////////////////////////////////////////// 
nCuantos:= SQLGET ("NMAUSENCIA","COUNT(PER_CODTRA) AS CUANTOS","PER_CODTRA"+Getwhere ("=",oNMAUSENCIA:PER_CODTRA)+; 
" AND ( PER_DESDE"+Getwhere (">=",oNMAUSENCIA:PER_DESDE)+ " "+; 
" AND PER_HASTA" + Getwhere ("<=",oNMAUSENCIA:PER_HASTA)+; 
" OR PER_DESDE" + Getwhere ("<=",oNMAUSENCIA:PER_HASTA)+; 
" AND PER_HASTA" + Getwhere (">=",oNMAUSENCIA:PER_DESDE) +; 
" )") 

IF nCuantos>0 

MensajeErr("Trabajador Posee Registros en Fechas Especificadas","No se puede Registrar"+oNMAUSENCIA:PER_CODTRA) 

RETURN .F. 
ENDIF

RETURN lResp



/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()

    oNMAUSENCIA:oPER_CODTRA:nLastKey:=0 // Evita Lios con CANCEL

RETURN .T.

/*
// Validar Fecha
*/
FUNCTION VALFECHA(oNMAUSENCIA,lValid)
   LOCAL nDias:=0

   IF EMPTY(oNMAUSENCIA:PER_HASTA) .AND. !EMPTY(oNMAUSENCIA:PER_DESDE) .AND. lValid
     oNMAUSENCIA:oPER_DESDE:VARPUT(oNMAUSENCIA:PER_DESDE,.T.)
     oNMAUSENCIA:oPER_DESDE:KEYBOARD(13)
     RETURN .F.
   ENDIF

   IF !EMPTY(oNMAUSENCIA:PER_HASTA) .AND. !EMPTY(oNMAUSENCIA:PER_DESDE)
      nDias:=oNMAUSENCIA:PER_HASTA-oNMAUSENCIA:PER_DESDE+1
   ENDIF

   oNMAUSENCIA:oDESDE:SETTEXT(CFECHA(oNMAUSENCIA:PER_DESDE))
   oNMAUSENCIA:oHASTA:SETTEXT(CFECHA(oNMAUSENCIA:PER_HASTA)+;
   IIF(nDias>0,[ Días:]+ALLTRIM(STR(nDias,3)),""))

RETURN .T.

/*
<LISTA:PER_NUMERO:Y:GET:Y:N:Y:Número,PER_CODTRA:N:BMPGETL:N:N:Y:Trabajador,PER_DESDE:N:BMPGET:N:N:Y:Desde,PER_HASTA:N:BMPGET:N:N:Y:Hasta
,PER_CAUSA:N:BMPGETL:N:N:Y:Motivo,PER_OBSER1:N:GET:N:N:Y:Observaciones,PER_OBSER2:N:GET:N:N:Y:>
*/
