// Programa   : ACTUALIZA
// Fecha/Hora : 19/07/2003 02:39:58
// Propósito  : Ejecutar Actualizar Nómina   
// Creado Por : Juan Navas
// Llamado por: Menú Principal
// Aplicaci¢n : Nómina
// Tabla      : TRABAJADORES

#INCLUDE "DPXBASE.CH"

PROCEDURE PRENOMINA(cNumReg,cTipoNom,cOtraNom)
  LOCAL oGrp,oBtn,cTitle:=""
  LOCAL aRadio  :={}

  IF Type("oFrmAct")="O" .AND. oFrmAct:oWnd:hWnd>0
     EJECUTAR("BRRUNNEW",oFrmAct,GetScript())
     RETURN .T.
  ENDIF

  DEFAULT cNumReg:=""

  EJECUTAR("NMTIPNOM",.T.)

  IF LEN(oDp:aTipoNom)=0
     AADD(oDp:aTipoNom,"Ninguno")
     MensajeErr("Usuario No tiene Permisos para Los Tipos de Nómina")
     RETURN .T.
  ENDIF


  cTitle:=IIF(!Empty(oDp:cExcluyeTrab),"No Confidencial",cTitle) // Trabajadores Confidenciales para este Usuarios
  cTitle:=IIF(!Empty(oDp:cConfidWhere),"Confidencial"   ,cTitle) // Trabajadores Confidenciales para los demás Usuarios

  IF !Empty(cTitle)
    cTitle:=" ["+cTitle+"]"
  ENDIF   

  IF !EMPTY(cTipoNom)
     oDp:cTipoNom:=cTipoNom
  ENDIF

  IF !EMPTY(cOtraNom)
    oDp:cOtraNom:=cOtraNom
  ENDIF



 
  oFrmAct:=DPEDIT():New("Actualizar Nómina "+DTOC(oDp:dFecha)+" "+cTitle,"ACTUALIZA.edt","oFrmAct",.T.)

  oFrmAct:cTipoNom     :=oDp:cTipoNom
  oFrmAct:cOtraNom     :=oDp:cOtraNom
  oFrmAct:dDesde       :=oDp:dDesde 
  oFrmAct:dHasta       :=oDp:dHasta
  oFrmAct:oMeter       :=NIL
  oFrmAct:nTrabajadores:=0
  oFrmAct:oSayTrab     :=NIL
  oFrmAct:lCancel      :=.T.
  oFrmAct:oNm          :=NIL
  oFrmAct:cGrupo       :="TODOS"
  oFrmAct:cCodGru      :=oDp:cCodGru
  oFrmAct:nSalida      :=2
  oFrmAct:cCodigoIni   :=oDp:cCodTraIni   // Trabajador Desde
  oFrmAct:cCodigoFin   :=oDp:cCodTraFin   // Trabajador Hasta
  oFrmAct:lCodigo      :=.T.              // Requiere Rango del Trabajador
  oFrmAct:lFecha       :=.F.              // Rango de Fecha
  oFrmAct:lOptimiza    :=.T.              // Proceso Optimizado                       
  oFrmAct:dFecha       :=oDp:dFecha       // Toma la Fecha del Sistema
  oFrmAct:cTopic       :="ACTUALIZAR"
  oFrmAct:cFileChm     :="CAPITULO2.CHM"
  oFrmAct:lMenu        :=.T.
  oFrmAct:cCodSuc      :=oDp:cSucursal
  oFrmAct:dFecha       :=oDp:dFecha 
  oFrmAct:cCodMon      :=oDp:cMonedaExt
  oFrmAct:nDivisa      :=SQLGET("DPHISMON","HMN_VALOR,HMN_FECHA,HMN_HORA","HMN_CODIGO"+GetWhere("=",oDp:cMonedaExt)+" AND HMN_FECHA"+GetWhere("=",oFrmAct:dFecha)+"  ORDER BY CONCAT(HMN_FECHA,HMN_HORA) DESC LIMIT 1")
  oFrmAct:cNumReg      :=cNumReg 

  IF Empty(oFrmAct:nDivisa)
    oFrmAct:nDivisa      :=SQLGET("DPHISMON","HMN_VALOR,HMN_FECHA,HMN_HORA","HMN_CODIGO"+GetWhere("=",oDp:cMonedaExt)+"  ORDER BY CONCAT(HMN_FECHA,HMN_HORA) DESC LIMIT 1")
  ENDIF

  oFrmAct:dFechaD      :=DPSQLROW(2,CTOD(""))



  IF !oFrmAct:cTipoNom="O"
    oFrmAct:cOtraNom     :=oDp:aOtraNom[LEN(oDp:aOtraNom)]
  ENDIF

  oFrmAct:cNumero      :=SQLGET("NMFECHAS","FCH_NUMERO","FCH_CODSUC"+GetWhere("=",oFrmAct:cCodSuc )        +" AND "+;
                                                        "FCH_TIPNOM"+GetWhere("=",LEFT(oFrmAct:cTipoNom,1))+" AND "+;
                                                        "FCH_OTRNOM"+GetWhere("=",IF(LEFT(oFrmAct:cTipoNom,1)="O",LEFT(oFrmAct:cOtraNom,2),""))+" AND "+;
                                                        "FCH_DESDE" +GetWhere("=",oFrmAct:dDesde  )+" AND "+;
                                                        "FCH_HASTA" +GetWhere("=",oFrmAct:dHasta  ))
//? oFrmAct:cNumero,CLPCOPY(oDp:cSql)

  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Nómina"
  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Trabajador"
  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Periodo"

  @ 1,2 SAY "Tipo de Nómina"
  @ 3,2 SAY  GetFromVar("{oDp:XNMGRUPO}")
  @ 4,2 SAY "Otra Nómina"

  @ 1,12 COMBOBOX oFrmAct:oTipoNom  VAR oFrmAct:cTipoNom  ITEMS oDp:aTipoNom;
         ON CHANGE oFrmAct:GetFecha(oFrmAct)

  @ 2,12 COMBOBOX oFrmAct:oOTraNom  VAR oFrmAct:cOtraNom  ITEMS oDp:aOTraNom;
         WHEN oFrmAct:cTipoNom="O";
         ON CHANGE oFrmAct:GetFecha(oFrmAct)

  @ 4,2 SAY oFrmAct:oGrupo PROMPT PADR("Todos",40)
  oFrmAct:VALGRUPO(oFrmAct,oFrmAct:cCodGru,.T.)

  @ 4,12 BMPGET oFrmAct:oCodGru VAR oFrmAct:cCodGru;
         NAME   "BITMAPS\FIND.bmp";
         SIZE   40,NIL;
         VALID  oFrmAct:ValGrupo(oFrmAct,oFrmAct:cCodGru);
         WHEN   oDp:nGrupos>0;
         ACTION oFrmAct:LISTGRU(oFrmAct,"cCodGru","oCodGru")

  // RANGO DE FECHA

  @ 4,12 BMPGET oFrmAct:oDesde VAR oFrmAct:dDesde PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN oFrmAct:lFecha;
         ACTION LbxDate(oFrmAct:oDesde,oFrmAct:dDesde)

  @ 5,12 BMPGET oFrmAct:oHasta VAR oFrmAct:dHasta PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN oFrmAct:lFecha;
         VALID (Igualar(oFrmAct:oDesde,oFrmAct:oHasta).AND.oFrmAct:dHasta>=oFrmAct:dDesde.AND.!EMPTY(oFrmAct:dHasta));
         ACTION LbxDate(oFrmAct:oHasta,oFrmAct:dHasta)

  // RANGO DE TRABAJADOR 

  @ 4,12 BMPGET oFrmAct:oCodDesde VAR oFrmAct:cCodigoIni;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmAct:lCodigo;
         VALID oFrmAct:VALCODTRA(oFrmAct,oFrmAct:oCodDesde);
         ACTION oFrmAct:LISTTRAB(oFrmAct,"cCodigoIni","oCodDesde")

  @ 5,12 BMPGET oFrmAct:oCodHasta VAR oFrmAct:cCodigoFin;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmAct:lCodigo;
         VALID oFrmAct:VALCODTRA(oFrmAct,oFrmAct:oCodHasta).AND.;
               (Igualar(oFrmAct:oCodDesde,oFrmAct:oCodHasta).AND.oFrmAct:cCodigoFin>=oFrmAct:cCodigoIni);
         ACTION oFrmAct:LISTTRAB(oFrmAct,"cCodigoFin","oCodHasta")

  @09, 33  SBUTTON oBtn ;
           SIZE 42, 23 ;
           FILE "BITMAPS\ERASE01.BMP" ;
           LEFT PROMPT "Borrar";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris, 1 };
           ACTION (oFrmAct:oCodDesde:VarPut(SPACE(10),.T.),;
                   oFrmAct:oCodHasta:VarPut(SPACE(10),.T.))

  oBtn:cToolTip:="Borrar Rango de Trabajador"
  oBtn:cMsg    :="Borrar Rango de Trabajador"

  @ 08,01 METER oFrmAct:oMeter VAR oFrmAct:nTrabajadores

  @ 08,01 SAY oFrmAct:oSayTrab PROMPT "Trabajador:"+SPACE(30)


  @ 5,12 BMPGET oFrmAct:oFechaD;
         VAR oFrmAct:dFechaD PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN .T.;
         VALID oFrmAct:VALFECHAD();
         ACTION LbxDate(oFrmAct:oFechaD,oFrmAct:dFechaD)


  @ 7,0 CheckBox oFrmAct:oOptimiza VAR oFrmAct:lOptimiza PROMPT "Optimizar"

/*
  @ 6,07 BUTTON oFrmAct:oBtnIniciar PROMPT "Iniciar " ACTION  (CursorWait(),;
                                    oFrmAct:SetMsg("Ejecutar Actualización"),;
                                    oFrmAct:NOMEJECUTAR(oFrmAct))

  @ 6,10 BUTTON oFrmAct:oBtnCerrar PROMPT "Cerrar  " ACTION oFrmAct:Detener(oFrmAct) CANCEL
*/

//  @ 1,2 SAY "Divisa "+LEFT(CSEMANA(oFrmAct:dFechaD),3)+"/"+DTOC(oFrmAct:dFechaD) RIGHT

  @ 01,2 SAY oFrmAct:oSayFecha PROMPT "Divisa "+oDp:cMonedaExt+"/"+LEFT(CSEMANA(oFrmAct:dFechaD),3)+CRLF+F8(oFrmAct:dFechaD) RIGHT

  @ 10,2 SAY "Fecha"+CRLF+"Divisa" RIGHT

  @ 4,10 GET oFrmAct:oDivisa VAR oFrmAct:nDivisa PICTURE oDp:cPictureDivisa RIGHT

  oFrmAct:Activate({||oFrmAct:ViewDatBar()})

  oFrmAct:GetFecha(oFrmAct)

  IF !EJECUTAR("NMCONCHK") // Revisar si Existen Conceptos de Pago
     RETURN .F.
  ENDIF

RETURN NIL

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oFrmAct:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 60,60 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD 

   DEFINE BUTTON oFrmAct:oBtnIniciar;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Calcular";
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          ACTION (CursorWait(),;
                  oFrmAct:SetMsg("Ejecutar Actualización"),;
                  oFrmAct:NOMEJECUTAR(oFrmAct))

   oFrmAct:oBtnIniciar:cToolTip:="Calcular"

   IF !Empty(oFrmAct:cNumero)

        DEFINE BUTTON oFrmAct:oBtnMenu;
               OF oBar;
               NOBORDER;
               FONT oFont;
               TOP PROMPT "Menú";
               FILENAME "BITMAPS\MENU.BMP",NIL,"BITMAPS\MENUG.BMP";
               ACTION (CursorWait(),;
                       EJECUTAR("DPNMFCHMNU",oFrmAct:cCodSuc,oFrmAct:cNumero))

        oFrmAct:oBtnMenu:cToolTip:="Menú"


   ENDIF

   DEFINE BUTTON oFrmAct:oBtnCerrar;
          OF oBar;
          FONT oFont;
          TOP PROMPT "Cerrar";
          NOBORDER;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION;
          iif(oFrmAct:Detener(oFrmAct),oFrmAct:Close(),nil);
          CANCEL


   oFrmAct:oBtnCerrar:cToolTip:="Salir"

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -28 BOLD 

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   @ .0,30.5 SAY " Actualizar Nómina "+oFrmAct:cNumero FONT oFont OF oBar SIZE 140+150+50+50,40 COLOR 16022016,oDp:nGris

   IF !Empty(oFrmAct:cNumReg)

     DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -18 BOLD 

     @ 2.5,30.5 SAY " #"+oFrmAct:cNumReg FONT oFont OF oBar SIZE 140+150+50+50,40 COLOR 16022016,oDp:nGris

   ENDIF



   oFrmAct:oCodHasta:oJump:=oFrmAct:oBtnIniciar

RETURN .T.

FUNCTION NOMEJECUTAR(oFrmAct)
   LOCAL oNomina,aNomina,cTitle1,cTitle2,lHubo:=.F.
   LOCAL cNumFch

   IF oDp:oNmVac!=NIL
      oDp:oNmVac:End()
      oDp:oNmVac:=NIL
   ENDIF

   oDp:cTipoNom:=Left(oFrmAct:cTipoNom,1)  
   oDp:cOtraNom:=IIF(oDp:cTipoNom="O",Left(oFrmAct:cOtraNom,2),"")
   oDp:cCodGru :=oFrmAct:cCodGru

   oDp:cCodTraIni:=oFrmAct:cCodigoIni
   oDp:cCodTraFin:=oFrmAct:cCodigoFin
   oDp:lVacacion :=.F.   

   EJECUTAR("NMSAVEDAT")
// EJECUTAR("VARUPHTTP",oDp:cTipoNom,oDp:cOtraNom,oFrmAct:dDesde,oFrmAct:dHasta)

//   IF oFrmAct:nSalida=1 // Salida por Formulario
//      RETURN VIEWPRENM(oFrmAct)
//   ENDIF

   oFrmAct:oBtnIniciar:Disable()
   oFrmAct:oBtnCerrar:SetText(" Detener ")

   oNomina:=TNOMINA():New()
   oNomina:dDesde:=oFrmAct:dDesde
   oNomina:dHasta:=oFrmAct:dHasta
   oNomina:cCodSuc:=oDp:cSucursal

   // Nómina ZARA
   oNomina:dHastaN:=FchFinMes(oNomina:dHasta)

   oNomina:lPlanifica:=.F.
   oNomina:lPrenomina:=.F.
   oNomina:lActualiza:=.T.
   oNomina:lPrint    :=.F.
   oNomina:lArray    :=.F.
   oNomina:lSysError :=.F. // Inactivar Control de Errores
   oNomina:lOptimiza :=oFrmAct:lOptimiza

   oNomina:cTipoNom  :=oDp:cTipoNom
   oNomina:cOtraNom  :=oDp:cOtraNom

   oNomina:cCodigoIni:=oFrmAct:cCodigoIni
   oNomina:cCodigoFin:=oFrmAct:cCodigoFin
   oNomina:oMeter    :=oFrmAct:oMeter
   oNomina:oSayTrab  :=oFrmAct:oSayTrab

   oNomina:cGrupoIni :=oFrmAct:cCodGru
   oNomina:cGrupoFin :=oFrmAct:cCodGru 
   oNomina:nDivisa   :=oFrmAct:nDivisa 
   oNomina:nProcess  :=0
   oNomina:cCodMon   :=oFrmAct:cCodMon

   // Asociar Proceso con el Formulario
   oFrmAct:oNm:=oNomina

   oDp:nDivisa:=oNomina:nDivisa

   oDp:lPlanifica:=.F.

   oNomina:Procesar()

//   ViewArray(oNomina:aConceptos)

   oFrmAct:oSayTrab:SetText(ALLTRIM(STR(oNomina:nProcess))+" Trabajadores Procesados en "+;
                    ALLTRIM(STR(oNomina:nTime2-oNomina:nTime1))+" Segundos")


   DEFAULT oNomina:oLee:=OpenTable("SELECT * FROM NMTRABAJADOR",.F.)

   IF Empty(oNomina:nProcess)
      MensajeErr("Nómina no Procesada"+CRLF+oNomina:GetRepProc(),"Reporte del Proceso")
   ELSE
      lHubo:=.T.
   ENDIF

   oNomina:End() // Finaliza N®mina
  
   oFrmAct:oNm:=NIL

   oFrmAct:oBtnCerrar:SetText(" Cerrar ")
   oFrmAct:oBtnIniciar:Enable()
   oFrmAct:oMeter:SetTotal(0)
   oFrmAct:oMeter:Set(0)

   oFrmAct:cNumero      :=SQLGET("NMFECHAS","FCH_NUMERO","FCH_CODSUC"+GetWhere("=",oFrmAct:cCodSuc )+" AND "+;
                                                         "FCH_TIPNOM"+GetWhere("=",LEFT(oFrmAct:cTipoNom,1))+" AND "+;
                                                         "FCH_OTRNOM"+GetWhere("=",IF(LEFT(oFrmAct:cTipoNom,1)="O",LEFT(oFrmAct:cOtraNom,2),""))+" AND "+;
                                                         "FCH_DESDE" +GetWhere("=",oFrmAct:dDesde  )+" AND "+;
                                                         "FCH_HASTA" +GetWhere("=",oFrmAct:dHasta  ))
   IF lHubo

     SQLUPDATE("NMRECIBOS","REC_VALCAM",oFrmAct:nDivisa,"REC_CODSUC"+GetWhere("=",oFrmAct:cCodSuc)+" AND REC_NUMFCH"+GetWhere("=",oFrmAct:cNumero))
     SQLUPDATE("NMFECHAS" ,{"FCH_VALCAM","FCH_REGPLA"},{oFrmAct:nDivisa,oFrmAct:cNumReg},"FCH_CODSUC"+GetWhere("=",oFrmAct:cCodSuc)+" AND FCH_NUMERO"+GetWhere("=",oFrmAct:cNumero))

     EJECUTAR("SETNOMINADOLARIZA",.F.)
     EJECUTAR("DPDOCPROPROGCALNOM",NIL,oFrmAct:dDesde,oDp:dFchCierre)

     IF !Empty(oFrmAct:cNumReg)

       oFrmAct:oSayTrab:SetText("Generando Cuenta por Pagar")

       EJECUTAR("NOMTOCXP",oFrmAct:cCodSuc,oFrmAct:cNumero)

       oFrmAct:oSayTrab:SetText(ALLTRIM(STR(oNomina:nProcess))+" Trabajadores Procesados en "+;
                        ALLTRIM(STR(oNomina:nTime2-oNomina:nTime1))+" Segundos")

     ENDIF

     IF oFrmAct:lMenu 
       EJECUTAR("DPNMFCHMNU",oFrmAct:cCodSuc,oFrmAct:cNumero)
     ELSE
       REPORTE("RECIBOS")
     ENDIF
//      Ejecutar("NMACTFIN",oFrmAct:dDesde,oFrmAct:dHasta)
   ENDIF

   oNomina:=NIL

RETURN .T.

//
// DETIENE EL PROCESO DE ACTUALIZACION
//
FUNCTION DETENER(oFrmAct)

    IF oFrmAct:oNm=NIL
       oFrmAct:Close()
       RETURN .T.
    ENDIF

    oNm:lCancelar:=.T.
    SysRefresh(.T.)

RETURN .T.

/*
// Determina las Fecha de Proceso
*/
FUNCTION GetFecha(oFrmAct)
  LOCAL nLen    :=LEN(oFrmAct:oOtraNom:aItems)
  LOCAL cTipoNom:=UPPE(Left(oFrmAct:cTipoNom,1))
  LOCAL cOtraNom:=UPPE(Left(oFrmAct:cOtraNom,2))
  LOCAL oDesde  :=oFrmAct:oDesde
  LOCAL oTabla 

  IF cTipoNom!="O"
     // Otra N®mina debe Ser Ninguna
     EVAL(oFrmAct:oOtraNom:bSetGet,oFrmAct:oOtraNom:aItems[nLen])
     oFrmAct:lFecha :=.F.
     oFrmAct:oOtraNom:Refresh(.T.)
  ELSE
    oTabla:=OpenTable("SELECT OTR_PERIOD FROM NMOTRASNM WHERE OTR_CODIGO"+GetWhere("=",cOtraNom),.T.)
    oFrmAct:lFecha :=(oTabla:OTR_PERIOD="I")
    oTabla:End()
  ENDIF

  oDp:cTipoNom:=cTipoNom
  oDp:cOtraNom:=cOtraNom

  EJECUTAR("FCH_RANGO",cTipoNom,oFrmAct:dFecha,cOtraNom)
  EJECUTAR("NMTIPNOM") // Determina las Condiciones del Tipo de Nómina

  IF oFrmAct:lFecha .AND. !EMPTY(oDp:dDesdeOtr)
     oDp:dDesde:=oDp:dDesdeOtr
     oDp:dHasta:=oDp:dHastaOtr
  ENDIF

  oFrmAct:dDesde:=oDp:dDesde // Toma las Fechas generadas por FCH_RANGO
  oFrmAct:dHasta:=oDp:dHasta

  DpSetVar(oFrmAct:oDesde,oDp:dDesde)
  DpSetVar(oFrmAct:oHasta,oDp:dHasta)

  IF EMPTY(oDp:dDesde)
    oFrmAct:lFecha:=.T. // Si Puede Editar la Fecha
//    IF Empty(oFrmAct:dDesde)
//       oFrmAct:dDesde:=oDp:dDesde
//    ENDIF
  ENDIF

  oFrmAct:oOtraNom:ForWhen(.T.)

RETURN .T.

/*
// Determina los Datos de Otras N®minas
*/
FUNCTION GetOtraNm(oFrmAct)
  LOCAL oTable
  LOCAL cOtra

  IF LEFT(oFrmAct:cTipoNom,1)!="O" // Semanal
     oFrmAct:lFecha :=.F.
     RETURN .T.
  ENDIF

RETURN .T.
/*
// Listra de Trabajadores
*/
FUNCTION LISTTRAB(oFrmAct,cVarName,cVarGet)
     LOCAL uValue,lResp,oGet,cWhere:=""

     uValue:=oFrmAct:Get(cVarName)
     oGet  :=oFrmAct:Get(cVarGet)

     IF LEFT(oFrmAct:cTipoNom,1)!="O"
       cWhere:="TIPO_NOM"+GetWhere("=",LEFT(oFrmAct:cTipoNom,1))
     ENDIF

     IF !Empty(oFrmAct:cCodigoIni)
       cWhere:=ADDWHERE(cWhere,"CODIGO"+GetWhere(">=",oFrmAct:cCodigoIni))
     ENDIF

     IF !EMPTY(oFrmAct:cCodGru)
       cWhere:=ADDWHERE(cWhere," GRUPO"+GetWhere("=",oFrmAct:cCodGru))
     ENDIF

     cWhere:=ADDWHERE(cWhere,oDp:cWhereTrab)

     lResp:=DPBRWPAG("NMTRABAJADOR.BRW",0,@uValue,NIL,.T.,cWhere)

     IF !Empty(uValue)
       oFrmAct:Set(UPPE(cVarName),uValue)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .T.

/*
// Listar Grupos
*/
FUNCTION LISTGRU(oFrmAct,cVarName,cVarGet)
     LOCAL cTable :="NMGRUPO"
     LOCAL aFields:={"GTR_CODIGO","GTR_DESCRI"}
     LOCAL cWhere :=""
     LOCAL uValue,lResp,oGet
     LOCAL lGroup :=.F.

     DEFAULT cWhere:=""

     oGet  :=oFrmAct:Get(cVarGet)
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
FUNCTION VALGRUPO(oFrmAct,cCodGru,lView)
   LOCAL oTable,lFound:=.T.
   LOCAL cTipoNom:=Left(oFrmAct:cTipoNom,1)

   DEFAULT lView:=.F.

   IF Empty(cCodGru)
     oFrmAct:oGrupo:SetText("Todos")
     RETURN .T.
   ENDIF

   oTable:=OpenTable("SELECT GTR_DESCRI FROM NMGRUPO WHERE GTR_CODIGO"+GetWhere("=",cCodGru),.T.)
   lFound:=(oTable:RecCount()>0)

   IIF(lFound,oFrmAct:oGrupo:SetText(oTable:GTR_DESCRI),NIL)

   oTable:End()

   IF lView
     RETURN .T.
   ENDIF

   IF !lFound
      MensajeErr(GetFromVar("{oDp:XNMGRUPO}")+" : "+cCodGru+" no Existe ")
   ENDIF

   IF lFound

     oTable:=OpenTable("SELECT COUNT(*) FROM NMTRABAJADOR WHERE GRUPO"+;
                       GetWhere("=",oFrmAct:cCodGru)+;
                       IIF(cTipoNom="O",""," AND TIPO_NOM"+GetWhere("=",cTipoNom)),;
                        .T.)

     IF Empty(oTable:FieldGet(1))

         MensajeErr("No Hay Trabajadores Asociados "+CRLF+;
                    "en el Grupo ["+oFrmAct:cCodGru+"]"+;
                    IIF(cTipoNom="O",""," para N¢mina ["+ALLTRIM(SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",cTipoNom))+"]"))
         lFound:=.F.

         oFrmAct:oCodGru:VarPut(SPACE(LEN(cCodGru)),.T.)


     ENDIF

     oTable:End()

   ENDIF

RETURN lFound

/*
// Validar Trabajador
*/
FUNCTION VALCODTRA(oFrmAct,oGet)
   LOCAL oTable,lFound:=.T.
   LOCAL cTipoNom:=Left(oFrmAct:cTipoNom,1)
   LOCAL cCodTra :=oGet:VarGet()
   LOCAL cWhere

   IF Empty(cCodTra)
     RETURN .T.
   ENDIF

   cWhere:=ADDWHERE(" CODIGO"+GetWhere("=",cCodTra),oDp:cWhereTrab)

   oTable:=OpenTable("SELECT CODIGO,APELLIDO,NOMBRE,TIPO_NOM FROM NMTRABAJADOR WHERE "+cWhere ,.T.)
   lFound:=(oTable:RecCount()>0)

   IIF(lFound,oFrmAct:oSayTrab:SetText(ALLTRIM(oTable:APELLIDO)+","+oTable:NOMBRE),NIL)

   IF lFound .AND. cTipoNom<>"O" .AND. cTipoNom<>oTable:TIPO_NOM

      MensajeErr("Trabajador Corresponde al Tipo de Nómina "+oTable:TIPO_NOM)
      lFound:=.F.

   ELSE

     IF !lFound

        oTable:End()
        oTable:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)

        IF oTable:RecCount()=0
          MensajeErr("Trabajador no Encontrado, Revise Fecha de Egreso o Fecha de Contratación: ")
        ELSE
          MensajeErr("Trabajador: "+ALLTRIM(oTable:APELLIDO)+","+ALLTRIM(oTable:NOMBRE)+" no Cumple Condiciones para ser Aceptado")
        ENDIF

        lFound:=.T.
        
     END

   ENDIF

   oTable:End()

   IF !lFound
      eval(oGet:bAction)
      RETURN .F.
   ENDIF

RETURN .T.


/*
// Validar la Fecha 
*/
FUNCTION VALFECHAD()

  oFrmAct:nDivisa:=EJECUTAR("KPIDIVISAGET",oFrmAct:cCodMon,oFrmAct:dFechaD) // obtiene valor divisa

  oFrmAct:oDivisa:VarPut(oFrmAct:nDivisa,.T.)
  oFrmAct:oSayFecha:Refresh(.T.)

RETURN .T.



// EOF

