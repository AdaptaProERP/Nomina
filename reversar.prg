// Programa   : REVERSAR
// Fecha/Hora : 03/11/2019 10:28:37
// Propósito  : REVERSAR
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCEDURE REVERSAR()
  LOCAL oGrp,cWhere
  LOCAL oTable,nLen,cTitle:=""
  LOCAL oGrp
  LOCAL aRadio  :={},aCrystal:={}

  EJECUTAR("NMTIPNOM")

  IF oDp:nVersion>=6 .AND. .F.
     EJECUTAR("REVERSARV60")
     RETURN .T.
  ENDIF


  IF LEN(oDp:aTipoNom)=0
     AADD(oDp:aTipoNom,"Ninguno")
     MensajeErr("Usuario No tiene Permisos para Los Tipos de Nómina")
     RETURN .T.
  ENDIF

  // Remueve Fechas sin Recibos asociados
  EJECUTAR("NMFECHASDEPURA")

  cWhere :=" LEFT JOIN NMRECIBOS ON REC_CODSUC=FCH_CODSUC AND REC_NUMERO=FCH_NUMERO "+; 
           " WHERE "+;
           " FCH_TIPNOM"+GetWhere("=",LEFT(oDp:cTipoNom,1))+ " AND "+;
           " FCH_OTRNOM"+GetWhere("=",LEFT(oDp:cOtraNom,2))+" ORDER BY FCH_DESDE DESC LIMIT 1"
  
  oTable:=OpenTable("SELECT FCH_DESDE,FCH_HASTA,REC_NUMERO FROM NMFECHAS "+cWhere,.T.)

  IF oTable:RecCount()=0
     oTable:End()
     MensajeErr("No hay Nóminas Procesadas para Nómina "+LEFT(oDp:cTipoNom,1)+IF(oDp:cTipoNom="O","/"+LEFT(oDp:cOtraNom,2)),"Reversión")
//   Return .F.
  ENDIF

  oTable:End()

  cTitle:=IIF(!Empty(oDp:cExcluyeTrab),"No Confidencial",cTitle) // Trabajadores Confidenciales para este Usuarios
  cTitle:=IIF(!Empty(oDp:cConfidWhere),"Confidencial"   ,cTitle) // Trabajadores Confidenciales para los demás Usuarios

  IF !Empty(cTitle)
    cTitle:=" ["+cTitle+"]"
  ENDIF   

  EJECUTAR("FCH_REVER",oDp:cTipoNom,oDp:dFecha,oDp:cOtraNom)

  DPEDIT():New("Reversión de Nómina "+cTitle,"REVERSAR.edt","oFrmRev",.T.)

  oFrmRev:cFileChm     :="CAPITULO2.CHM"
  oFrmRev:cTipoNom     :=oDp:cTipoNom
  oFrmRev:cOtraNom     :=oDp:cOtraNom
  oFrmRev:nTrabajadores:=0
  oFrmRev:dDesde       :=oTable:FCH_DESDE // oDp:dDesde 
  oFrmRev:dHasta       :=oTable:FCH_HASTA // oDp:dHasta
  oFrmRev:dFecha       :=oDp:dFecha    // Toma la Fecha del Sistema
  oFrmRev:oMeter       :=NIL
  oFrmRev:oSayTrab     :=NIL
  oFrmRev:oNm          :=NIL
  oFrmRev:lCancel      :=.T. // No Solicita Cancelar
  oFrmRev:lCrystal     :=.F.
  oFrmRev:lCodigo      :=.T.           // Requiere Rango del Trabajador
  oFrmRev:lRecalcular  :=.F.           // Recalcular Salarios
  oFrmRev:lFecha       :=.F.           // Rango de Fecha
  oFrmRev:lOptimiza    :=.T.           // Proceso Optimizado                       
  oFrmRev:cCodGru      :=oDp:cCodGru
  oFrmRev:cCodigoIni   :=oDp:cCodTraIni   // Trabajador Desde
  oFrmRev:cCodigoFin   :=oDp:cCodTraFin   // Trabajador Hasta
  oFrmRev:cGrupo       :=""
  oFrmRev:cWhere       :=cWhere

  IF !oFrmRev:cTipoNom="O"
    oFrmRev:cOtraNom     :=oDp:aOtraNom[LEN(oDp:aOtraNom)]
  ENDIF

  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Nómina"
  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Trabajador"
  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Periodo"

  @ 1,2 SAY "Tipo de Nómina"
  @ 3,2 SAY  GetFromVar("{oDp:XNMGRUPO}")
  @ 4,2 SAY "Otra Nómina"

  @ 1,12 COMBOBOX oFrmRev:oTipoNom  VAR oFrmRev:cTipoNom  ITEMS oDp:aTipoNom;
         ON CHANGE oFrmRev:GetFecha(oFrmRev)

  @ 2,12 COMBOBOX oFrmRev:oOTraNom  VAR oFrmRev:cOtraNom  ITEMS oDp:aOTraNom;
         WHEN oFrmRev:cTipoNom="O";
         ON CHANGE oFrmRev:GetFecha(oFrmRev)

  @ 4,2 SAY oFrmRev:oGrupo PROMPT PADR("Todos",40)
  oFrmRev:VALGRUPO(oFrmRev,oFrmRev:cCodGru,.T.)

  @ 4,12 BMPGET oFrmRev:oCodGru VAR oFrmRev:cCodGru;
         NAME   "BITMAPS\FIND.bmp";
         SIZE   40,NIL;
         VALID  oFrmRev:ValGrupo(oFrmRev,oFrmRev:cCodGru);
         WHEN   oDp:nGrupos>0;
         ACTION oFrmRev:LISTGRU(oFrmRev,"cCodGru","oCodGru")

  // RANGO DE TRABAJADOR 

  @ 4,12 BMPGET oFrmRev:oCodDesde VAR oFrmRev:cCodigoIni;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmRev:lCodigo;
         VALID oFrmRev:VALCODTRA(oFrmRev,oFrmRev:oCodDesde);
         ACTION oFrmRev:LISTTRAB(oFrmRev,"cCodigoIni","oCodDesde")

  @ 5,12 BMPGET oFrmRev:oCodHasta VAR oFrmRev:cCodigoFin;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmRev:lCodigo;
         VALID oFrmRev:VALCODTRA(oFrmRev,oFrmRev:oCodHasta).AND.;
              (Igualar(oFrmRev:oCodDesde,oFrmRev:oCodHasta).AND.oFrmRev:cCodigoFin>=oFrmRev:cCodigoIni);
         ACTION oFrmRev:LISTTRAB(oFrmRev,"cCodigoFin","oCodHasta")

  @ 08,01 METER oFrmRev:oMeter VAR oFrmRev:nTrabajadores

  @ 08,01 SAY oFrmRev:oSayTrab PROMPT "Trabajador:"+SPACE(30)

  // RANGO DE FECHA

  @ 4,12 SAY oFrmRev:oDesde PROMPT {||CFECHA(oFrmRev:dDesde)}

  @ 5,12 SAY oFrmRev:oHasta PROMPT {||CFECHA(oFrmRev:dHasta)}

  @10, 3 BUTTON oFrmRev:oBtnIniciar;
         PROMPT " Iniciar ";
         WHEN !Empty(oFrmRev:dHasta);
         ACTION  (CursorWait(),;
         oFrmRev:SetMsg("Ejecutar Actualización"),;
         oFrmRev:EJECUTARREV(oFrmRev))

  oFrmRev:oBtnIniciar:cMsg    :="Iniciar Proceso de Reversión"
  oFrmRev:oBtnIniciar:cToolTip:="Iniciar Reversión"


  @10,15 BUTTON oFrmRev:oBtnCerrar;
         PROMPT " Cerrar  ";
         ACTION  (CursorWait(),oFrmRev:Detener(oFrmRev)) CANCEL

  oFrmRev:oBtnCerrar:cMsg    :="Cerrar Proceso de Reversión"
  oFrmRev:oBtnCerrar:cToolTip:="Cerrar Reversión"

  @09,33  SBUTTON oBtn ;
          SIZE 42, 23 ;
          FILE "BITMAPS\ERASE01.BMP" ;
          LEFT PROMPT "Borrar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION (oFrmRev:oCodDesde:VarPut(SPACE(10),.T.),;
                  oFrmRev:oCodHasta:VarPut(SPACE(10),.T.))

  @ 7,0 CheckBox oFrmRev:lRecalcular PROMPT "Recalcular Salarios"

  oFrmRev:Activate({||oFrmRev:ViewDatBar()})

RETURN NIL

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oFrmRev:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 60,60 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD 


   DEFINE BUTTON oFrmRev:oBtnIniciar;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Reversar";
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          ACTION (oFrmRev:SetMsg("Ejecutar Actualización"),;
                 oFrmRev:EJECUTARREV(oFrmRev))

   oFrmRev:oBtnIniciar:cToolTip:="Calcular"

/*
   DEFINE BUTTON oFrmRev:oBtnDebug;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Revisión";
          FILENAME "BITMAPS\BUG.BMP",NIL,"BITMAPS\BUGG.BMP";
          ACTION (CursorWait(),;
                  oFrmRev:SetMsg("Ejecutando Prenómina"),;
                  oFrmRev:EJECUTARNOM(oFrmRev,.T.),;
                  oFrmRev:lProcesa:=.F.)

   oFrmRev:oBtnDebug:cToolTip:="Calcular en Modo Depuración "
*/

 DEFINE BUTTON oFrmRev:oBtnVer;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Recibos";
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oFrmRev:VERDETALLES()
                 
   oFrmRev:oBtnVer:cToolTip:="Ver recibos del Periodo"



   DEFINE BUTTON oFrmRev:oBtnCerrar;
          OF oBar;
          FONT oFont;
          TOP PROMPT "Cerrar";
          NOBORDER;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION;
          iif(oFrmRev:Detener(oFrmRev),oFrmRev:Close(),nil);
          CANCEL


   oFrmRev:oBtnCerrar:cToolTip:="Salir"

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -28 BOLD 

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   @ .1,45 SAY " Reversar Nómina " FONT oFont OF oBar SIZE 140+150,40 COLOR 16022016,oDp:nGris


RETURN .T.


FUNCTION EJECUTARREV()
   LOCAL oNomina,aNomina,cTitle1,cTitle2,cContab:="",cOtra,oTable,cWhere
   LOCAL cCodFyT,oTable

   oDp:cTipoNom:=Left(oFrmRev:cTipoNom,1)  
   oDp:cOtraNom:=IIF(oDp:cTipoNom="O",Left(oFrmRev:cOtraNom,2),"")
   oDp:cCodGru :=oFrmRev:cCodGru

   oDp:cCodTraIni:=oFrmRev:cCodigoIni   // Trabajador Desde
   oDp:cCodTraFin:=oFrmRev:cCodigoFin   // Trabajador Hasta

   IF oDp:oNmVac!=NIL
      oDp:oNmVac:End()
      oDp:oNmVac:=NIL
   ENDIF

   cOtra  :=IIF(Left(oFrmRev:cTipoNom,1)!="O","",LEFT(oFrmRev:cOtraNom,2))

   cWhere :="FCH_TIPNOM"+GetWhere("=",Left(oFrmRev:cTipoNom,1))+ " AND "+;
            "FCH_OTRNOM"+GetWhere("=", cOtra                  )+ " AND "+;
            "FCH_DESDE "+GetWhere("=", oFrmRev:dDesde         )+ " AND "+;
            "FCH_HASTA "+GetWhere("=", oFrmRev:dHasta         )

   oTable:=OpenTable("SELECT * FROM NMFECHAS WHERE "+cWhere,.T.)

   // oTable:Browse()
   oTable:End()

   IF oTable:FCH_CONTAB="S" 

      MensajeErr("Nómina ya está Contabilizada"+CRLF+;
                 "Fecha "+DTOC(oTable:FCH_SISTEM),"Comprobante Contable: "+oTable:FCH_NUMCBT)

      RETURN .F.

   ENDIF

   IF oTable:FCH_INTEGR="S"

      MensajeErr("Nómina ya se Integró con el Sistema Administrativo"+CRLF+;
                 "Fecha "+DTOC(oTable:FCH_SISTEM),"No es Posible Reversar Nómina")

      RETURN .F.

   ENDIF


// EJECUTAR("VARUPHTTP",oDp:cTipoNom,oDp:cOtraNom,oFrmRev:dDesde,oFrmRev:dHasta)

   oFrmRev:oBtnIniciar:Disable()
   oFrmRev:oBtnCerrar:SetText(" Detener ")

// ErrorSys(.T.)

   oNomina:=TNOMINA():New()
   oNomina:dDesde:=oFrmRev:dDesde
   oNomina:dHasta:=oFrmRev:dHasta

   oNomina:lPrenomina :=.F.
   oNomina:lActualiza :=.F.
   oNomina:lReversar  :=.T.
   oNomina:lRecalcular:=oFrmRev:lRecalcular 
   oNomina:lPrint     :=.F.
   oNomina:lArray     :=.F.
   oNomina:lOptimiza  :=oFrmRev:lOptimiza
   oNomina:lPlanifica :=.F.

   oNomina:cTipoNom  :=oDp:cTipoNom
   oNomina:cOtraNom  :=LEFT(oDp:cOtraNom,2)

   oNomina:cCodigoIni:=oFrmRev:cCodigoIni
   oNomina:cCodigoFin:=oFrmRev:cCodigoFin
   oNomina:oMeter    :=oFrmRev:oMeter
   oNomina:oSayTrab  :=oFrmRev:oSayTrab

   oNomina:cGrupoIni :=oFrmRev:cGrupo
   oNomina:cGrupoFin :=oFrmRev:cGrupo    

   // Asociar Proceso con el Formulario
   oFrmRev:oNm:=oNomina

   IF oNomina:Reversar()

      oFrmRev:oSayTrab:SetText(ALLTRIM(STR(oNomina:nProcess))+" Trabajadores Reversados en "+;
                       ALLTRIM(STR(oNomina:nTime2-oNomina:nTime1))+" Segundos")

      MsgInfo(LSTR(oNomina:nProcess)+" Recibo(s) Reversados","Mensaje")

   ELSE

   ENDIF
//   IF Empty(oNomina:nProcess)
//      MensajeErr("Ningún Recibo fué Reversado","Advertencia")
//   ENDIF

   cCodFyT:="PRENOMINA-"+oNomina:cTipoNom+;
            IIF(Empty(oNomina:cOtraNom),"","-"+oNomina:cOtraNom)


   IF !Empty(SQLGET("DPFORMYTAREAS","FYT_CODIGO","FYT_CODIGO"+GetWhere("=",cCodFyT)))

     // Guarda la Ejecución del Proceso

     EJECUTAR("DPFORMYTARGRAB" , cCodFyt  , NIL , oNomina:dDesde , oNomina:dHasta,NIL,NIL,NIL,.T.) 
    
   ENDIF




   oNomina:End() // Finaliza N«mina
   oNomina:=NIL
   oFrmRev:oNm:=NIL

   oFrmRev:oBtnCerrar:SetText(" Cerrar ")
   oFrmRev:oBtnIniciar:Enable()
   oFrmRev:oMeter:SetTotal(0)
   oFrmRev:oMeter:Set(0)
   oFrmRev:GetFecha(oFrmRev) // Repasa las Condiciones de Fecha

   EJECUTAR("DPDOCPROPROGCALNOM",NIL,oFrmRev:dDesde,oDp:dFchCierre)

   EJECUTAR("NMFECHASDEPURA")

   oTable:=OpenTable("SELECT FCH_DESDE,FCH_HASTA,REC_NUMERO FROM NMFECHAS "+oFrmRev:cWhere,.T.)
   oFrmRev:dDesde:=oTable:FCH_DESDE
   oFrmRev:dHasta:=oTable:FCH_HASTA

   oFrmRev:oDesde:Refresh(.T.)
   oFrmRev:oHasta:Refresh(.T.)

   oTable:End()


RETURN .T.

//
// DETIENE EL PROCESO DE ACTUALIZACION
//
FUNCTION DETENER(oFrmRev)

    IF oFrmRev:oNm=NIL
       oFrmRev:Close()
       RETURN .T.
    ENDIF

    oNm:lCancelar:=.T.
    SysRefresh(.T.)

RETURN .T.

/*
// Determina las Fecha de Proceso
*/
FUNCTION GetFecha(oFrmRev)
  LOCAL nLen    :=LEN(oFrmRev:oOtraNom:aItems)
  LOCAL cTipoNom:=UPPE(Left(oFrmRev:cTipoNom,1))
  LOCAL cOtraNom:=UPPE(Left(oFrmRev:cOtraNom,2))
  LOCAL oDesde  :=oFrmRev:oDesde
  LOCAL oTabla,cWhere 

  IF cTipoNom!="O"

     // Otra N«mina debe Ser Ninguna
     EVAL(oFrmRev:oOtraNom:bSetGet,oFrmRev:oOtraNom:aItems[nLen])
     oFrmRev:lFecha :=.F.
     oFrmRev:oOtraNom:Refresh(.T.)

  ELSE

     cOtraNom:=UPPE(Left(oFrmRev:cOtraNom,2))
     IF oFrmRev:oOtraNom:nAt=Len(oFrmRev:oOtraNom:aItems)
        oFrmRev:oOtraNom:Select(1)
        cOtraNom:=Left(oFrmRev:oOtraNom:aItems[1],2)
     ENDIF
     oTabla:=OpenTable("SELECT OTR_PERIOD FROM NMOTRASNM WHERE OTR_CODIGO"+GetWhere("=",cOtraNom),.T.)
     oFrmRev:lFecha :=(oTabla:OTR_PERIOD="I")
     oTabla:End()

  ENDIF

//  EJECUTAR("FCH_REVER",cTipoNom,oFrmRev:dFecha,cOtraNom)
//  oDp:cTipoNom:=cTipoNom
//  oDp:cOtraNom:=cOtraNom
//  EJECUTAR("NMTIPNOM",.T.)

  cWhere :=" LEFT JOIN NMRECIBOS ON REC_CODSUC=FCH_CODSUC AND REC_NUMERO=FCH_NUMERO "+; 
           " WHERE "+;
           " FCH_TIPNOM"+GetWhere("=",cTipoNom,1)+;
           IF(cTipoNom="O"," AND FCH_OTRNOM"+GetWhere("=",cOtraNom,2),"")+" ORDER BY FCH_DESDE DESC LIMIT 1"
  
  oTable:=OpenTable("SELECT FCH_DESDE,FCH_HASTA,REC_NUMERO FROM NMFECHAS "+cWhere,.T.)

  oFrmRev:dDesde:=oTable:FCH_DESDE
  oFrmRev:dHasta:=oTable:FCH_HASTA

  oFrmRev:oDesde:Refresh(.T.)
  oFrmRev:oHasta:Refresh(.T.)

  IF oTable:RecCount()>0
     oDp:dDesde  :=oFrmRev:dDesde // Toma las Fechas generadas por FCH_RANGO
     oDp:dHasta  :=oFrmRev:dHasta
     oDp:cTipoNom:=cTipoNom         
     oDp:cOtraNom:=cOtraNom
  ENDIF

//  oFrmRev:dDesde:=oDp:dDesde // Toma las Fechas generadas por FCH_RANGO
//  oFrmRev:dHasta:=oDp:dHasta
  oFrmRev:oDesde:Refresh()
  oFrmRev:oHasta:Refresh()

//  oFrmRev:oHasta
// DpSetVar(oFrmRev:oDesde,oDp:dDesde)
// DpSetVar(oFrmRev:oHasta,oDp:dHasta)

  IF EMPTY(oDp:dDesde)
    oFrmRev:lFecha:=.T. // Si Puede Editar la Fecha
  ENDIF

  oFrmRev:oOtraNom:ForWhen(.T.)

RETURN .T.

/*
// Determina los Datos de Otras N«minas
*/
FUNCTION GetOtraNm(oFrmRev)
  LOCAL oTable
  LOCAL cOtra

  IF LEFT(oFrmRev:cTipoNom,1)!="O" // Semanal
     oFrmRev:lFecha :=.F.
     RETURN .T.
  ENDIF

RETURN .T.

/*
// Listar Trabajador
*/
FUNCTION LISTTRAB(oFrmRev,cVarName,cVarGet)
     LOCAL uValue,lResp,oGet,cWhere:=""

     uValue:=oFrmRev:Get(cVarName)
     oGet  :=oFrmRev:Get(cVarGet)

     IF LEFT(oFrmRev:cTipoNom,1)!="O"
       cWhere:="TIPO_NOM"+GetWhere("=",LEFT(oFrmRev:cTipoNom,1))
     ENDIF

     IF !Empty(oFrmRev:cCodigoIni)
       cWhere:=ADDWHERE(cWhere,"CODIGO"+GetWhere(">=",oFrmRev:cCodigoIni))
     ENDIF

     IF !EMPTY(oFrmRev:cCodGru)
       cWhere:=ADDWHERE(cWhere," GRUPO"+GetWhere("=",oFrmRev:cCodGru))
     ENDIF

     cWhere:=ADDWHERE(cWhere,oDp:cWhereTrab)

     lResp:=DPBRWPAG("NMTRABAJADOR.BRW",0,@uValue,NIL,.T.,cWhere)

     IF !Empty(uValue)
       oFrmRev:Set(UPPE(cVarName),uValue)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .T.

/*
// Determina la Ultima Fecha según tipo de Nómina
*/
FUNCTION GetLastDate()

RETURN .T.


/*
// Listar Grupos
*/
FUNCTION LISTGRU(oFrmRev,cVarName,cVarGet)
     LOCAL cTable :="NMGRUPO"
     LOCAL aFields:={"GTR_CODIGO","GTR_DESCRI"}
     LOCAL cWhere :=""
     LOCAL uValue,lResp,oGet
     LOCAL lGroup :=.F.

     DEFAULT cWhere:=""

     oGet  :=oFrmRev:Get(cVarGet)
     uValue:=EJECUTAR("REPBDLIST",cTable,aFields,lGroup,cWhere)

     IF !Empty(uValue)
       oGet:VarPut(uValue,.T.)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .F.

/*
// Validar Grupo
*/
FUNCTION VALGRUPO(oFrmRev,cCodGru,lView)
   LOCAL oTable,lFound:=.T.
   LOCAL cTipoNom:=Left(oFrmRev:cTipoNom,1)

   DEFAULT lView:=.F.

   IF Empty(cCodGru)
     oFrmRev:oGrupo:SetText("Todos los Grupos")
     RETURN .T.
   ENDIF

   oTable:=OpenTable("SELECT GTR_DESCRI FROM NMGRUPO WHERE GTR_CODIGO"+GetWhere("=",cCodGru),.T.)
   lFound:=(oTable:RecCount()>0)

   IIF(lFound,oFrmRev:oGrupo:SetText(oTable:GTR_DESCRI),NIL)

   oTable:End()

   IF lView
     RETURN .T.
   ENDIF

   IF !lFound
      MensajeErr(GetFromVar("{oDp:XNMGRUPO}")+" : "+cCodGru+" no Existe ")
   ENDIF

   IF lFound

     oTable:=OpenTable("SELECT COUNT(*) FROM NMTRABAJADOR WHERE GRUPO"+;
                       GetWhere("=",oFrmRev:cCodGru)+;
                       IIF(cTipoNom="O",""," AND TIPO_NOM"+GetWhere("=",cTipoNom)),;
                        .T.)

     IF Empty(oTable:FieldGet(1))

         MensajeErr("No Hay Trabajadores Asociados "+CRLF+;
                    "en el Grupo ["+oFrmRev:cCodGru+"]"+;
                    IIF(cTipoNom="O",""," para N¢mina ["+ALLTRIM(SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",cTipoNom))+"]"))
         lFound:=.F.

         oFrmRev:oCodGru:VarPut(SPACE(LEN(cCodGru)),.T.)


     ENDIF

     oTable:End()

   ENDIF

RETURN lFound

/*
// Validar Trabajador
*/
FUNCTION VALCODTRA(oFrmRev,oGet)
   LOCAL oTable,lFound:=.T.
   LOCAL cTipoNom:=Left(oFrmRev:cTipoNom,1)
   LOCAL cCodTra :=oGet:VarGet()
   LOCAL cWhere

   IF Empty(cCodTra)
     RETURN .T.
   ENDIF

   cWhere:=ADDWHERE(" CODIGO"+GetWhere("=",cCodTra),oDp:cWhereTrab)

   oTable:=OpenTable("SELECT CODIGO,APELLIDO,NOMBRE,TIPO_NOM FROM NMTRABAJADOR WHERE "+cWhere ,.T.)
   lFound:=(oTable:RecCount()>0)

   IIF(lFound,oFrmRev:oSayTrab:SetText(ALLTRIM(oTable:APELLIDO)+","+oTable:NOMBRE),NIL)

   IF lFound .AND. cTipoNom<>"O" .AND. cTipoNom<>oTable:TIPO_NOM
      MensajeErr("Trabajador Corresponde al Tipo de Nómina "+oTable:TIPO_NOM)
      lFound:=.F.
   ENDIF

   oTable:End()

   IF !lFound
      eval(oGet:bAction)
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION VERDETALLES()
  LOCAL cWhere:="FCH_TIPNOM"+GetWhere("=",LEFT(oFrmRev:cTipoNom,1))
  LOCAL cCodSuc:=oDp:cSucursal,nPeriodo:=11,dDesde,dHasta,cTitle:=NIL
  LOCAL cField:=HISFECHA(oDp:cTipFecha)


  IF LEFT(oFrmRev:cTipoNom,1)="O"
    cWhere:=cWhere+" AND FCH_OTRNOM"+GetWhere("=",LEFT(oFrmRev:cOtraNom,2))
  ENDIF

  cWhere:=cWhere+" AND FCH_DESDE"+GetWhere("=",oFrmRev:dDesde)+" AND FCH_HASTA"+GetWhere("=",oFrmRev:dHasta)

RETURN EJECUTAR("BRRECIBOS",cWhere,cCodSuc,nPeriodo,oFrmRev:dDesde,oFrmRev:dHasta,cTitle)
// EOF
