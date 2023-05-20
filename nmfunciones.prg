//
// Funciones de Nómina cargadas en módulos HRB
// Juan Navas  18/07/2003
// Continuación de DataPro Nómina para DOS (1987)
// Sólo para ser utilizado para uso documentado en el uso de las funciones
//

/*
                               DpNómina Versión 2.4
  Nómina / Semanal  ¦              EDUCATIVA              ¦ Sáb/26/Jul/2003
+------------------------ TRABAJADORES DE NOMINA SEMANAL ----------------------+
¦  Código....: 002                        Fecha de Ingreso.: 01/01/2002        ¦
¦  Apellido..: 32132                      Cédula...........: V-   12323        ¦
¦  Nombre....: 123213                     Tipo de Nómina...: Semanal           ¦
¦  Condición.: Activo                     Forma de Pago....: Efectivo          ¦
Ã------------------------------------------------------------------------------Â
¦ Descripción del Campo                ¦Und.¦ Valor                            ¦
Ã------------------------------------------------------------------------------Â

*/


FUNCTION NLUNES(dDesde,dHasta) ; RETURN NDIAS(dDesde,dHasta,2) // Lunes
FUNCTION NDOM(dDesde,dHasta)   ; RETURN NDIAS(dDesde,dHasta,1) // Domingo
FUNCTION NLUN(dDesde,dHasta)   ; RETURN NDIAS(dDesde,dHasta,2) // Lunes
FUNCTION NMAR(dDesde,dHasta)   ; RETURN NDIAS(dDesde,dHasta,3) // Martes
FUNCTION NMIE(dDesde,dHasta)   ; RETURN NDIAS(dDesde,dHasta,4) // Miercoles
FUNCTION NJUE(dDesde,dHasta)   ; RETURN NDIAS(dDesde,dHasta,5) // Jueves
FUNCTION NVIE(dDesde,dHasta)   ; RETURN NDIAS(dDesde,dHasta,6) // Viernes
FUNCTION NSAB(dDesde,dHasta)   ; RETURN NDIAS(dDesde,dHasta,7) // Sábado

/*
// Determina según el Número de la Semana la Cantidad de Dias
*/

FUNCTION NDIAS(dDesde,dHasta,nDow)
    LOCAL nDias:=0

    DEFAULT dDesde:=oNm:dDesde
    DEFAULT dHasta:=oNm:dHasta
    DEFAULT nDow  :=0

    dDesde :=EVAL(oDp:bFecha,dDesde)  //  Convierte en Fecha
    dHasta :=EVAL(oDp:bFecha,dHasta)  //  Convierte en Fecha

    IF EMPTY(dDesde).OR.EMPTY(dHasta)
       RETURN 0
    ENDIF

    DO WHILE dDesde<=dHasta
      IF DOW(dDesde)=nDow
        nDias++
      ENDIF
      dDesde++
    ENDDO

RETURN nDias

/*
// Antigua Función Constante
*/
FUNCTION CNS(cCodigo)
RETURN CONSTANTE(cCodigo)

/*
// Nueva Función Constante
*/
FUNCTION CONSTANTE(cCodigo)
   LOCAL uValue:=0,nAt,oTable

   DEFAULT cCodigo:="001"

   IF ValType(cCodigo)="N"
      cCodigo=STRZERO(cCodigo,3)
   ENDIF

   IF Type("oNm")!="O" // No existe Objeto Nómina
      oTable:=OpenTable("SELECT CNS_VALOR,CNS_TIPO FROM NMCONSTANTES WHERE CNS_CODIGO"+GetWhere("=",cCodigo),.T.)
      uValue:=CTOO(oTable:CNS_VALOR,oTable:CNS_TIPO)
      oTable:End()
      RETURN uValue
   ENDIF

   nAt:=ASCAN(oNm:aConstantes,{|a,n|a[1]=cCodigo})

   IF nAt>0
      uValue:=oNm:aConstantes[nAt,2]
   ENDIF

RETURN uValue

/*
// Determina la Cantidad de Dias Trabajados Segun el periodo Activo de Trabajo
*/
FUNCTION DIAS_TRAB(nDiasTrab,cCodJornada,dDesde,dHasta,nDiasHab,nDiasVac)
     LOCAL dDesde_,dHasta_,lVacacion:=.F.
     LOCAL bRangoVac:={||.F.}    // Rango de Vacaciones
     LOCAL dInicio  :=NIL
     LOCAL nAt      :=0          // Posición de la Jornada
     LOCAL aJornadas:={}         // Jornadas Semanales
     LOCAL nDia     :=0
     LOCAL FECHA_VAC:=oTrabajador:FECHA_VAC
     LOCAL FECHA_FIN:=oTrabajador:FECHA_FIN
     LOCAL dDesdeN,dHastaN

     FECHATABVAC(oTrabajador:CODIGO,@FECHA_VAC,@FECHA_FIN)

     nDiasHab :=0                    // Dias Hábiles, Trabajados Durante el Periodo
     nDiasVac :=0                    // Dias de Vacaciones, Transcurridos durante el periodo

     DEFAULT dDesde     :=oNm:dDesde // Periodo Desde Según Nómina
     DEFAULT dHasta     :=oNm:dHasta // Periodo Desde Según Nómina

     DEFAULT dDesdeN     :=oNm:dDesde // Periodo Desde Según Nómina
     DEFAULT dHastaN     :=oNm:dHasta // Periodo Desde Según Nómina

     DEFAULT cCodJornada:=oTrabajador:TURNO    // Asume Tipo de Nómina Como Jornada

     dDesde_:=dDesde
     dHasta_:=dHasta

     cCodJornada:=ALLTRIM(cCodJornada)

     nAt    :=ASCAN(oNm:aJornadas,{|a,n|ALLTRIM(a[1])=cCodJornada})

     IF nAt>0
       aJornadas:=oNm:aJornadas[nAt,2]
     ENDIF

     dInicio:=dDesde

     IF dInicio>=FECHA_VAC
        RETURN nDiasTrab
     ENDIF

     IF ((dDesde>=EVAL(oDp:bFecha,oTrabajador:FECHA_ING)).AND.EMPTY(oTrabajador:FECHA_EGR).AND.EMPTY(FECHA_VAC).AND.EMPTY(FECHA_FIN) .AND. EMPTY(oTrabajador:FECHA_CON)) .OR. (dInicio<=FECHA_VAC)  // FCH2>=oTrabajador:FECHA_EGR.AND.EMPTY(oTrabajador:FECHA_CON) // SI LA FECHA DE EGRESO/INGRESO ESTAN FUERA DEL RANGO
        RETURN nDiasTrab
     ENDIF

     // Verifica la Fecha de Ingreso
     dDesde:=MAX(EVAL(oDp:bFecha,oTrabajador:FECHA_ING),dDesde)

     // Verifica la Fecha de Egreso
     IF !EMPTY(EVAL(oDp:bFecha,oTrabajador:FECHA_EGR))
        dHasta:=MIN(EVAL(oDp:bFecha,oTrabajador:FECHA_EGR),dHasta) // FECHA DE EGRESO
     ENDIF

     // Fecha de Contratación
     IF !EMPTY(EVAL(oDp:bFecha,oTrabajador:FECHA_CON))
        dHasta:=MIN(EVAL(oDp:bFecha,oTrabajador:FECHA_CON),dHasta) // FECHA DE EGRESO
     ENDIF


     // Personal el Periodo de Vacaciones
     IF !EMPTY(EVAL(oDp:bFecha,FECHA_VAC)) .AND. EVAL(oDp:bFecha,FECHA_VAC)<=dDesde.AND.EVAL(oDp:bFecha,FECHA_FIN)>=dHasta // FECHA DE VACACIONES
        RETURN 0 // Personal está de Vacaciones
     ENDIF

     // Personal Egresado en Periodo de Pago
     IF (!EMPTY(EVAL(oDp:bFecha,FECHA_FIN))) .AND. EVAL(oDp:bFecha,FECHA_FIN)>=dDesde.AND.EVAL(oDp:bFecha,FECHA_FIN)<=dHasta
        dDesde=EVAL(oDp:bFecha,FECHA_FIN)+1
     ENDIF

     // Periodo de Pago dentro del Periodo de Vacaciones
     IF (!EMPTY(EVAL(oDp:bFecha,FECHA_VAC))) .AND. EVAL(oDp:bFecha,FECHA_VAC)>=dDesde.AND.EVAL(oDp:bFecha,FECHA_VAC)<=dHasta
        dHasta:=EVAL(oDp:bFecha,FECHA_VAC)-1
     ENDIF

     IF (dDesde_<FECHA_VAC .AND. dDesde_<FECHA_FIN) .AND. (dHasta_>FECHA_VAC .AND. dHasta_>FECHA_FIN)
       nDiasVac:=FECHA_FIN-FECHA_VAC+1
       //     MensajeErr("dias de vacaciones",nDiasVac)
       dDesde:=dDesde_
       dHasta:=dHasta_
     ENDIF

     // Nómina Mensual y Quincenal sobre Base de 30 Días
     IF DAY(dHasta)=31 .AND. oTrabajador:TIPO_NOM$"QM"
        dHasta--
     ENDIF

     // Calcula los Días del Periodo          ROUND
     dInicio:=dDesde

     DO WHILE dInicio<=dHasta.AND.nAt>0 .AND. dInicio<=FECHA_VAC //.AND. FECHA_FIN<=dDesde

        IF oTrabajador:TIPO_NOM=[S]
           nDiasHab+=aJornadas[DOW(dInicio)] // SUMA LOS DIAS
        ELSE // Los demas tipos de Nómina no generan Semanas Completas
           nDia:=aJornadas[DOW(dInicio)] // := Hay que determinar si en esta fecha hay 1/2 Tiempo para Descontar
           nDia:=IIF( nDia=0 , 1 , nDia)
           nDiasHab:=nDiasHab+nDia // := Hay que determinar si en esta fecha hay 1/2 Tiempo para Descontar
        ENDIF

        dInicio++

    ENDDO

    // Mes de Febrero preparada para Nómina Quincenal/Mensual
    IF MONTH(dHasta)=2.AND.MONTH(dDesde)=2.AND.DAY(dDesde)=16.AND.DAY(dHasta)>=28.AND.EVAL(oDp:bFecha,FECHA_FIN)<>dHasta.AND.EVAL(oDp:bFecha,FECHA_FIN)<dDesde
       IF DAY(dHasta)=28 .AND. DAY(oNm:dDesde)<>29
          nDiasHab:=nDiasHab+2
       ELSEIF DAY(dHasta)=29
          nDiasHab:=nDiasHab+1
       ENDIF
    ENDIF

    // Debe contar Cuantos días de vacaciones transcurrieron Antes de tomar vacaciones
    dInicio=dDesde

    DO WHILE dInicio<FECHA_VAC .AND. nAt>0 .AND. FECHA_FIN<=dDesde

      IF oTrabajador:TIPO_NOM=[S]
         nDiasVac+=aJornadas[DOW(dInicio)] // SUMA LOS DIAS
      ELSE
         nDiasVac++
      ENDIF
      dInicio++
    ENDDO

RETURN MIN(nDiasTrab,nDiasHab) // +nDiasVac

/*
// Determina Cuantos Días Hábiles hay en un Periodo
*/
FUNCTION DIAS_HAB(dDesde,dHasta,cCodJornada,lFeriados)
     // CALCULA LOS DIAS HABILES                                      //
     // NECESITA EL DIA INICIAL Y FINAL, EN CASO DE NO RECIBIRLOS     //
     // LOS OBTIENE DEL TIPO DE NOMINA                                //
     // TOMA COMO PUNTO DE PARTIDA LA FECHA INICIAL DEL PERIODO O LA  //
     // FECHA EN QUE EL TRABAJADOR SE INICIA EN LA EMPRESA            //
     LOCAL nDiasHab :=0
     LOCAL bRangoVac:={||.F.}
     LOCAL nAt      :=0          // Posición de la Jornada
     LOCAL cCalendar:=""
     LOCAL aJornadas:={}
     LOCAL FECHA_VAC:=oTrabajador:FECHA_VAC
     LOCAL FECHA_FIN:=oTrabajador:FECHA_FIN

     FECHATABVAC(oTrabajador:CODIGO,@FECHA_VAC,@FECHA_FIN)

     IF TYPE("oNm")="O"  // Carga las Jornadas
        aJornadas:=ACLONE(oNm:aJornadas)
        cCalendar:=oNm:cCalendar
     ELSE
        aJornadas:=LoadJornadas()
        cCalendar:=LeeFeriados()
     ENDIF

     DEFAULT cCodJornada:=oTrabajador:TURNO,lFeriados:=.T. // TIPO_NOM // Asume Tipo de Nómina Como Jornada

     IF !lFeriados  // No necesita los dias Feriados
       cCalendar:=""
     ENDIF

     cCodJornada:=IIF( Empty(cCodJornada),oTrabajador:TIPO_NOM,cCodJornada) // Asume Tipo de Nómina Como Jornada
     cCodJornada:=ALLTRIM(cCodJornada)

     // Localizar la Jornada, según el Trabajador
     nAt    :=ASCAN(aJornadas,{|a,n|a[1]==cCodJornada})

     IF nAt>0
       aJornadas:=ACLONE(aJornadas[nAt,2])
     ELSE
       aJornadas:={1,1,1,1,1,0,0} // no Existe
     ENDIF

     IF dDesde=NIL // No envio Ningún Parametro

        dHasta:=oNm:dHasta
        dDesde:=MAX(EVAL(oDp:bFecha,oTrabajador:FECHA_ING),oNm:dDesde) // FECHA DE INGRESO     FECHA DE INGRESO

        IF !EMPTY(EVAL(oDp:bFecha,oTrabajador:FECHA_EGR))
           dHasta:=MIN(EVAL(oDp:bFecha,oTrabajador:FECHA_EGR),dHasta) // FECHA DE EGRESO
        ENDIF

        IF !EMPTY(EVAL(oDp:bFecha,FECHA_VAC))
           bRangoVac:={||dDesde>=EVAL(oDp:bFecha,FECHA_VAC) .AND. dDesde<=EVAL(oDp:bFecha,FECHA_FIN)} // PERIODO DE VACACIONES
        ENDIF

     ENDIF

     dDesde:=EVAL(oDp:bFecha,dDesde)
     dHasta:=EVAL(oDp:bFecha,dHasta)

     IF EMPTY(dDesde)
        ? "dDesde,Invalido",GETPROCE()
        RETURN 0
     ENDIF

     DO WHILE dDesde<=dHasta .AND. DOW(dDesde)>0 // !EMPTY(FCH1)
        IF !LEFT(DTOC(dDesde),5)$cCalendar.AND.!EVAL(bRangoVac).AND.!EMPTY(aJornadas)
           nDiasHab+=aJornadas[DOW(dDesde)] // SUMA LOS DIAS
        ENDIF
        dDesde++
     ENDDO

RETURN nDiasHab

/*
// Determina la Cantidad de Dias no Habiles entre un Periodo
*/
FUNCTION DIAS_NOHAB(dDesde,dHasta)
     LOCAL nDiasHab  :=0
     LOCAL nDiasNoHab:=0

     DEFAULT dDesde:=oNm:dDesde
     DEFAULT dHasta:=oNm:dHasta

     dDesde    :=EVAL(oDp:bFecha,dDesde)
     dHasta    :=EVAL(oDp:bFecha,dHasta)
     nDiasHab  :=DIAS_HAB(dDesde,dHasta)
     nDiasNoHab:=(dHasta-dDesde)+1

RETURN nDiasNoHab-nDiasHab

/*
// Determina la Cantidad de Dias Feriados
*/
FUNCTION DIAS_FERIADOS(dDesde,dHasta,cJornada,lDescanso)
RETURN DIASFERIAD(dDesde,dHasta,cJornada,lDescanso)

/*
// Determina si X dia es Feriado
*/
FUNCTION DIAFERIADO(dFecha)
      DEFAULT dFecha:=oNm:dDesde
RETURN LEFT(DTOC(EVAL(oDp:bFecha,dFecha)),5)$oNm:cCalendar

/*
// Determina si la fecha de pago es Quincenal
*/
FUNCTION QUINCE(dFecha)
   DEFAULT dFecha:=oNm:dHasta

 //  ? "AQUI EN DPNOMINA cambio de nuevo  sip"

RETURN(DAY(dFecha)<=15)

/*
// Determina si el Periodo de Pago es Fin de Mes
*/
FUNCTION FINMES(lDesde,dDesde,dHasta)
  LOCAL dFinMes // :=FCHFINMES(oNm:dDesde) // FINAL DEL MES (VERSION CARMEN)
  LOCAL lFinCond:=.T.

  DEFAULT dDesde:=oNm:dDesde
  DEFAULT dHasta:=oNm:dHasta
  DEFAULT lDesde:=.T.

  dFinMes :=FCHFINMES(oNm:dDesde) // FINAL DEL MES (VERSION CARMEN)

  IF lDesde // Asume Fecha Desde
    lFinCond:=MONTH(dDesde)<>MONTH(dHasta) .OR.  dFinMes=dHasta
  ELSE
    lFinCond:=MONTH(dDesde)= MONTH(dHasta) .AND. dHasta>(dFinMes-7)
  ENDIF

  // 08/10/2013
  IF oTrabajador:TIPO_NOM=[S]

     // Si la Siguiente Semana pertene al mes que viene es fin de mes
     IF MONTH(dHasta)<>MONTH(dHasta+7) .OR. FCHFINMES(dHasta)=dHasta
        RETURN .T.
     ENDIF

     IF MONTH(dHasta)<>MONTH(dDesde)
         RETURN .F.
     ENDIF


     RETURN .F.

  ENDIF


  IF oTrabajador:TIPO_NOM=[S].AND.lFinCond
     RETURN .T.
  ENDIF

  IF dDesde<=dFinMes .AND. dHasta>=dFinMes .AND. oTrabajador:TIPO_NOM<>"S" // NO PARA SEMANAL
     RETURN .T.
  ENDIF

RETURN .F.

*/ ************************************
*/ Procedimiento que asigna un valor  *
*/ a una variable o crea una variable *
*/ de memoria.                        *
*/                                    *
*/ Recibe dos parametros:             *
*/    VARIABLE := variable que recibe *
*/                el valor.           *
*/    VALOR    := valor a pasar       *
*/                                    *
*/ Retorna --> .T.                    *
*/ ************************************
FUNCTION CREAVAR(cVarName,uValue)

     DEFAULT cVarName:="VARIAC"

     IF Type(cVarName)=[U]

       PUBLICO(cVarName,uValue)

     ENDIF

     Mover(uValue,cVarName)

     oDp:uResp:=uValue

RETURN 0 // uValue

/*
// Lectura de Variacion de Otro Concepto en Prenómina, Mismo Trabajador
*/
FUNCTION VarPre(cCodCon)
   LOCAL nAt,nResult:=0,aCodCon:={},I

   IF ValType(oNm:aVariac)!="A"
      oNm:CargaVariac()
   ENDIF

   aCodCon:=_VECTOR(cCodCon)

   FOR I := 1 TO  LEN(aCodCon)
     cCodCon:=aCodCon[I]
     IF LEN(oNm:aVariac)>0 .AND. (nAt:=ASCAN(oNm:aVariac,{|a,n|a[1]=cCodCon}),nAt>0)
       nResult:=nResult+oNm:aVariac[nAt,2]
     ELSE
       // OJO Debe Ejecutar el Concepto y Buscar el Valor de Variac
     ENDIF
   NEXT

RETURN nResult


/*
// Carga las Variaciones
*/
FUNCTION CargaVariac()
   LOCAL oVariac

   oVariac:=OpenTable("SELECT VAR_CODCON,VAR_CANTID,VAR_OBSERV,VAR_AJUSTE FROM NMVARIAC WHERE "+;
                      "       VAR_CODTRA"+GetWhere("=",ALLTRIM(oNm:oTrabajador:CODIGO))+;
                      "   AND VAR_DESDE "+GetWhere("=",oNm:dDesde  )+;
                      "   AND VAR_HASTA "+GetWhere("=",oNm:dHasta  )+;
                      "   AND VAR_TIPNOM"+GetWhere("=",oNm:cTipoNom)+;
                      "   AND VAR_OTRNOM"+GetWhere("=",oNm:cOtraNom),.T.) // !::lVariacion)

   oNm:aVariac:=ACLONE(oVariac:aDataFill) // aFillData

   oVariac:End()

RETURN .T.

/*
// Ejecuta Función de Concepto
*/
FUNCTION FUNCION(nNumCon,nPar1,nPar2,nPar3,nPar4,nPar5,nPar6)
   LOCAL cCodigo

   DEFAULT nNumCon:=0

   IF ValType(nNumCon)="N"
      cCodigo:="F"+STRZERO(nNumCon,3)
   ELSE
      cCodigo:=ALLTRIM(nNumCon)
   ENDIF

RETURN CONCEPTO(cCodigo,nPar1,nPar2,nPar3,nPar4,nPar5,nPar6)

/*
// Function CONCEPTO, Ejecuta cualquier Concepto
*/
FUNCTION CONCEPTO(cCodigo,nPar1,nPar2,nPar3,nPar4,nPar5,nPar6)
   LOCAL nResult:=0,oScript,nAt,nAtV,aCodCon:={},nTotal:=0,aConceptos:={}
   LOCAL cOldCodCon
   LOCAL aVar:=Save_Var("nFactor1,nFactor2,nFactor3,nFactor4,cVarDescri,VARIAC,VAROBSERV")

   PRIVATE nFactor1  :=0,nFactor2:=0,nFactor3:=0,nFactor4:=0
   PRIVATE cVarDescri:="",VARIAC:=0

   IF !TYPE("oNm")="O"
      RETURN 0
   ENDIF

   oNm:nConceptos:=1

   // JN 21/08/2013 (Recursividad de Conceptos, CONCEPTOS("A800:A820","A805:A806")
   IF ","$cCodigo
      aCodCon:=_VECTOR(cCodigo,",")
      oNm:nCantConRel:=0

      AEVAL(aCodCon,{|cCodCon,n,nResult| nResult:=CONCEPTO(cCodCon),;
                                         nTotal :=nTotal+nResult   ,;
                                         oNm:nCantConRel:=oNm:nCantConRel+IIF(nResult=0,0,1)})
      oNm:nCantConceptos:=1

      oNm:nCantConAbs:=LEN(aCodCon)             // Cantidad de Conceptos Absolutos, generados en FUNCTION CONCEPTOS


       // oNm:nCantConRel:=0                        // Cantidad de Conceptos Relativos, generados en FUNCTION CONCEPTOS

      RETURN nTotal
   ENDIF

// ? cCodigo, "cCodigo"
 //? aCodCon,"aCodCon"

   IF oNm:cCodCon=cCodigo
      MensajeErr("No es posible Ejecutar el mismo Concepto en forma Recursiva","Ejecución desde el Concepto:"+cCodigo)
      RETURN 0
   ENDIF

   cOldCodCon:=oNm:cCodCon

   nAt:=ASCAN(oNm:aConceptos,{|a,i|a[1]=cCodigo})

   IF nAt=0

      aConceptos:=EJECUTAR("NMCOMPILACONCEPTO",cCodigo,oNm)

      IF !Empty(aConceptos)

        AADD(oNm:aConceptos,aConceptos)
      ENDIF

   ENDIF

   nAt:=ASCAN(oNm:aConceptos,{|a,i|a[1]=cCodigo})

   IF nAt>0 .AND. ValType(oNm:aConceptos[nAt,2])="O"

     oNm:cCodCon:=cCodigo
     oScript    :=oNm:aConceptos[nAt,2]

     IF oNm:aConceptos[nAt,12] // Modo Depuración
        oScript:bRun := {|oLine| DebugDlg(oLine,NIL,oNm:aVar_Depu) } // Esta en FiveScr
     ENDIF

     oScript:cError:=""

     IF (nAtV:=ASCAN(oNm:aVariac,{|a,n|a[1]==cCodigo}),nAtV>0) // lVariac
        // Actualiza las Observaciones
        VARIAC      := oNm:aVariac[nAtV,2] // oVariac:VAR_CANTID)   // Variaci¦n
        VAROBSERV   := oNm:aVariac[nAtV,3] // oVariac:VAR_OBSERV
     ENDIF

     oScript:cError:=""
     nResult:=oScript:Run() // Ejecuta los Par+metros

     IF nAtV=0 .AND. !EMPTY(VARIAC) // Existe Variacion
        AADD(oNm:aVariac,{cCodigo,VARIAC,VAROBSERV,0})
     ENDIF

     oNm:cCodCon:=cOldCodCon

     if !empty(oScript:cError)

        MensajeErr(oScript:cError+CRLF+"Concepto será inactivado","Error, Concepto :"+cCodigo)

        IF nAt>0
          oNm:aConceptos[nAt,2]:=NIL
        ENDIF

        nResult:=0

     ELSEIF (nAt:=ASCAN(oNm:aVariac,{|a,n|a[1]==cCodigo}),nAt>0) // lVariac

        // Actualiza las Observaciones

        oNm:aVariac[nAt,2]:=VARIAC // oVariac:VAR_CANTID)   // Variaci¦n
        oNm:aVariac[nAt,3]:=VAROBSERV // oVariac:VAR_OBSERV

     ENDIF

   ELSE

     MensajeErr("Concepto: "+cCodigo+" NO existe"+CRLF+"Será Activado para todos los Tipos de Nómina","Ejecute nuevamente el Proceso")

     SQLUPDATE("NMCONCEPTOS",{"CON_SEMANA","CON_QUINCE","CON_MENSUA","CON_CATORC"},;
                             {.T.         ,.T.         ,.T.         ,.T.         },"CON_CODIGO"+GetWhere("=",cCodigo))

   ENDIF

   Rest_Var(aVar)
   PUBLICO("C_"+UPPE(cCodigo),nResult)

   oScript:=NIL

RETURN nResult
/*
// Indica si el trabajador está en la tabla de Vacaciones
*/
FUNCTION TABLAVAC()
   LOCAL lFound

   IF oDp:lVacacion // Esta Solicitado en el Formulario de Vacaciones
      RETURN .T.
   ENDIF

   IF ValType(oNMTABVAC)="O"
      IF oNMTABVAC:TAB_CODTRA=oTrabajador:CODIGO
         RETURN .T.
      ENDIF
      oNMTABVAC:End()
   ENDIF

   oNMTABVAC:=OpenTable("SELECT * FROM NMTABVAC WHERE TAB_CODTRA"+;
                     GetWhere("=",oTrabajador:CODIGO)+;
                     " AND TAB_PROCES=0 ",.t.) // No Procesados

   AEVAL(oNMTABVAC:aFields,{|a,n,cField|cField:=STRTRAN(a[1],"_",""),PUBLICO(cField,oNMTABVAC:FieldGet(n))})

RETURN oNMTABVAC:RecCount()>0


/*
// Graba al Trabajador en la Tabla de Vacaciones
*/
FUNCTION GRATABVAC(cField,uValue)
     LOCAL oTable

     oTable:=OpenTable("SELECT TAB_DESDE,TAB_HASTA,TAB_DIAS,"+;
                       cField+" FROM NMTABVAC WHERE TAB_CODTRA"+;
                       GetWhere("=",oTrabajador:CODIGO)+" AND TAB_PROCES=0 AND TAB_CODSUC"+GetWhere("=",oDp:cSucursal),.T.)

     IF oTable:RecCount()>0
        oTable:Replace(cField,uValue)
        oTable:Commit(oTable:cWhere)
        PUBLICO("TABDESDE",oTable:TAB_DESDE)
        PUBLICO("TABHASTA",oTable:TAB_HASTA)
        PUBLICO("TABDIAS" ,oTable:TAB_DIAS )
        PUBLICO(STRTRAN(cField,"_",""),uValue)
     ENDIF

     oTable:End()

RETURN oDp:uResp

/*
// Determina la Cantidad de Domingos Feriados
*/
FUNCTION FERIAD_DOM(dFchIni,dFchFin,nDia)
     LOCAL nFeriados:=0,bDia:={||.T.},cCalendar:=""

     IF ValType(nDia)="B"

        bDia:=nDia

     ELSE

       DEFAULT nDia:=1 // Domingos

       bDia:={||DOW(dFchIni)=nDia} // DOMINGO

     ENDIF

     DEFAULT dFchIni:=oNm:dDesde
     DEFAULT dFchFin:=oNm:dHasta

     dFchFin:=EVAL(oDp:bFecha,dFchFin)

     IF TYPE("oNm")="O"  // Carga las Jornadas
        cCalendar:=oNm:cCalendar
     ELSE
        cCalendar:=LeeFeriados()
     ENDIF

     DO WHILE dFchIni<=dFchFin
        IF EVAL(bDia) .AND. LEFT(DTOC(dFchIni),5)$cCalendar
           nFeriados++
        ENDIF
        dFchIni++
     ENDDO

RETURN nFeriados

/*
// Martes Feriados
*/
FUNCTION FERIAD_LUN(dDesde,dHasta)
RETURN FERIAD_DOM(dDesde,dHasta,2)

/*
// Martes Feriados
*/
FUNCTION FERIAD_MAR(dDesde,dHasta)
RETURN FERIAD_DOM(dDesde,dHasta,3)

/*
// Miercoles Feriados
*/
FUNCTION FERIAD_MIE(dDesde,dHasta)
RETURN FERIAD_DOM(dDesde,dHasta,4)

/*
// Jueves Feriados
*/
FUNCTION FERIAD_JUE(dDesde,dHasta)
RETURN FERIAD_DOM(dDesde,dHasta,5)

/*
// Viernes Feriados
*/
FUNCTION  FERIAD_VIE(dDesde,dHasta)
RETURN FERIAD_DOM(dDesde,dHasta,6)

/*
// Sábados Feriados
*/
FUNCTION  FERIAD_SAB(dDesde,dHasta)
RETURN FERIAD_DOM(dDesde,dHasta,7)

/*
// Dias Feriados
*/
FUNCTION DIASFERIAD(dDesde,dHasta,cJornada)
LOCAL FERIAD_DOM
RETURN FERIAD_DOM(dDesde,dHasta,{||.T.},cJornada)

/*
// Determina los Dias de Descaso
*/
FUNCTION DIAS_DESCANSO(dDesde,dHasta,cJornada)
// LOCAL nDias:=dHasta-dDesde,nHabil:=DIAS_HAB(dDesde,dHasta,cJornada,.T.)
  LOCAL nDescanso:=0
  WHILE dDesde<dHasta
     IF DIAS_HAB(dDesde,dDesde,cJornada,.F.)=0
       nDescanso:=nDescanso+1
     ENDIF
     dDesde++
  ENDDO
RETURN nDescanso // (nDias-nHabil)


/*
// Determina la Siguiente Fecha Habil
*/
FUNCTION FCHHABIL(dFecha,nDias,cJornada)
     // CALCULA LA PROXIMA FECHA HABIL SEGUN  //
     // LOS DIAS HABILES INDICADOS            //
     LOCAL nContar:=1
     LOCAL dDia   :=EVAL(oDp:bFecha,dFecha)

     dFecha:=EVAL(oDp:bFecha,dFecha)

     DEFAULT nDias:=0,cJornada:=oTrabajador:TURNO

     // SET DATE FREN
     IF nDias=0.AND.!DIAS_HAB(dFecha,dFecha,cJornada)=1 // DIA NO HABIL
        nDias:=1
     ENDIF

     DO WHILE .T. // H_CONTAR<=H_NDIAS // H_CONTAR<=H_NDIAS

        IF DIAS_HAB(dFecha,dFecha,cJornada)=1 // DIA HABIL
           dDia:=dFecha
           nContar++
        ENDIF

        IF nContar>nDias
           EXIT
        ENDIF
        dFecha++

     ENDDO

RETURN dDia

/*
// Actualiza el Valor de un Campo
*/
FUNCTION ACTUAL(uValue,cField,cSigno)

   IF oNm:lPrenomina
       RETURN uValue
   ENDIF
//   ? uValue,cField,"Actual"
RETURN uValue

FUNCTION ASIGN_NORM(dDesde,dHasta,A_DH)
RETURN ASIGN(dDesde,dHasta,.F.,[AD],,,A_DH,.T.)

/*
// Salario Normal es aquel que no incluye prestaciones, Conceptos A001,A002,A003,A004,A010
*/
FUNCTION ASIGN(dFechaIni,dFechaFin,lPrestac,cTipoCon,cTipoNom,cOtraNom,cTipFecha,lNormal)
   LOCAL nResult:=0
   LOCAL cWhere   :="",cSql:=""
   LOCAL oCursor
   LOCAL aConceptos:={}

   IF oNm:lValidar
      RETURN 0
   ENDIF

   DEFAULT cTipFecha:=oDp:cTipFecha // EMP_FECHDH  // Indica si la Fecha usada es DESDE/HASTA

   DEFAULT lPrestac:=.F.
   DEFAULT lNormal :=.F.

   DEFAULT cTipoCon :="A"
   DEFAULT dFechaIni:=oNm:dDesde
   DEFAULT dFechaFin:=oNm:dHasta

   dFechaIni:=CTOO(dFechaIni,"D") // EVAL(BFECHA,dFechaIni)
   dFechaFin:=CTOO(dFechaFin,"D") // AL(BFECHA,dFechaFin)

   IF oNm:lActualiza
      oNm:CommitHistorico()
   ENDIF

   ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere(">=",dFechaIni)," AND ")
   ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere("<=",dFechaFin)," AND ")

   IF !cTipoNom=NIL
      cWhere+=" AND REC_TIPNOM"+GetWhere("<>",cTipoNom) //Barrido por DpFecha {||cTipoNom<>cTipoNom}
   ENDIF

   IF !cOtraNom=NIL
      cWhere+=" AND FCH_OTRNOM"+GetWhere("<>",cOtraNom) //Barrido por DpFecha {||cOtraNom<>XOTRNOM}
   ENDIF

   // Según Tipos de Conceptos

   DO CASE

      CASE ValType(cTipoCon)="A"

         aConceptos:=ACLONE(cTipoCon)

      CASE lPrestac .AND. lNormal

         AEVAL(oNm:aAcum01,{|a,n| IIF( Left(a,1)$cTipoCon , AADD(aConceptos,a) , NIL)})
         AEVAL(oNm:aAcum02,{|a,n| IIF( Left(a,1)$cTipoCon , AADD(aConceptos,a) , NIL)})

      CASE lPrestac .AND. !lNormal

         AEVAL(oNm:aAcum02,{|a,n| IIF( Left(a,1)$cTipoCon , AADD(aConceptos,a) , NIL )})

      CASE !lPrestac .AND. lNormal

         AEVAL(oNm:aAcum01,{|a,n| IIF( Left(a,1)$cTipoCon , AADD(aConceptos,a) , NIL )})

    ENDCASE

    cWhere :="REC_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+;
             IIF(Empty(cWhere) , "" , " AND "+"("+cWhere+")" ) +;
             IIF( !lPrestac .AND. !lNormal,;
                 " AND (LEFT(HIS_CODCON,1)='A' OR LEFT(HIS_CODCON,1)='D') " ,;
                 GetWhereOr("HIS_CODCON",aConceptos,"="," AND ")) // Lista

     nResult:=SQLGET("NMHISTORICO","SUM(HIS_MONTO)",;
              " INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
              IIF("FCH_"$cWhere," INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO ","")+;
              " WHERE "+cWhere)

RETURN nResult

/*
// Indicar Liquidación
*/
FUNCTION TABLALIQ()
     LOCAL oTable,lFound,cSql

     IF ValType(oNMTABLIQ)="O" .AND. oNMTABLIQ:LIQ_CODTRA=oTrabajador:CODIGO
        RETURN .T.
     ENDIF

     IF ValType(oNMTABLIQ)="O"
        oNMTABLIQ:End()
     ENDIF

     cSql:="SELECT * FROM NMTABLIQ WHERE LIQ_CODTRA"+;
                  GetWhere("=",oTrabajador:CODIGO)+" AND LIQ_PROCES=0"

     oNMTABLIQ:=OpenTable(cSql,.T.)
     lFound:=oNMTABLIQ:RecCount()>0

     AEVAL(oNMTABLIQ:aFields,{|a,n,cField|cField:=STRTRAN(a[1],"_",""),;
                                          PUBLICO(a[1]  ,oNMTABLIQ:FieldGet(n)),;
                                          PUBLICO(cField,oNMTABLIQ:FieldGet(n))})

     oNm:lTablaLiq:=lFound

     IF lFound .AND. ASCAN(oNm:aTabLiq,oTrabajador:CODIGO)=0
        AADD(oNm:aTabLiq,oTrabajador:CODIGO)
     ENDIF

RETURN lFound

/*
// Acumulado por Concepto (De un Mes)
*/
FUNCTION ACUMC_MES(aConceptos,dFechaIni,aVariac,aDebHab,cTipoNom,cOtraNom,cWhere,lRevaloriza)
   LOCAL dFechaFin,nResult:=0

   DEFAULT aVariac:="C"
   DEFAULT dFechaIni:=oNm:dDesde // IIF(FCHINICIO=NIL,FCHDESDE,FCHINICIO)

   DEFAULT lRevaloriza:=.F.

   IF ValType(dFechaIni)=[C]

      IF LEN(dFechaIni)=2 // MES EN DIAS (nResult)
         dFechaIni=CTOD("01/"+dFechaIni+STRZERO(YEAR(oDp:dFecha),4))
      ELSE
         dFechaIni:=CTOO(dFechaIni,"D") // FCHINICIO=CTOD(FCHINICIO)
      ENDIF
   ENDIF

   dFechaIni:=FCHINIMES(dFechaIni) // CTOD("01"+RIGHT(DTOC(FCHINICIO),6)) // PRIMERO DEL MES
   dFechaFin:=FCHFINMES(dFechaIni) // OBTIENE AL FECHA FIN DE MES
   nResult  :=ACUMC_FCH(aConceptos,dFechaIni,dFechaFin,aVariac,aDebHab,cTipoNom,cOtraNom,cWhere,lRevaloriza)

   IF !EMPTY(oNm:cError)
      oNm:cError:=[ACUMC_MES("dCONCEPTO",dMES,"DH",cTipoNom,cOtraNom,cWhere,lRevaloriza)]
   ENDIF

RETURN nResult

/*
// Determina los Dias de Permiso
*/
FUNCTION REPOSO(dDesde,dHasta,nDiasCal,cDescri,cCodTra)
  LOCAL oTipAus,aCodAus:={}

  IF oDp:aCodAus=NIL

    oTipAus:=OpenTable("SELECT TAU_CODIGO FROM NMTIPAUS "+;
                       " WHERE TAU_REPOSO=1",.T.)


    AEVAL(oTipAus:aDataFill,{|a,n|AADD(aCodAus,a[1])})

    oTipAus:End()

    oDp:aCodAus:=Aclone(oDp:aCodAus)

  ELSE

    aCodAus:=ACLONE(oDp:aCodAus)

  ENDIF

RETURN AUSENCIA(aCodAus,dDesde,dHasta,@nDiasCal,@cDescri,cCodTra)

/*
// Determina los Dias de Permiso
*/
FUNCTION PERMISO(dDesde,dHasta,nDiasCal,cDescri,cCodTra)
  LOCAL oTipAus,aCodAus:={}

  IF oDp:aCodAusR=NIL

    oTipAus:=OpenTable("SELECT TAU_CODIGO FROM NMTIPAUS "+;
                       " WHERE TAU_REPOSO=0",.T.)

    AEVAL(oTipAus:aDataFill,{|a,n|AADD(aCodAus,a[1])})

    oTipAus:End()

    oDp:aCodAusR:=Aclone(aCodAus)

  ELSE

    aCodAus:=ACLONE(oDp:aCodAusR)

  ENDIF

RETURN AUSENCIA(aCodAus,dDesde,dHasta,@nDiasCal,@cDescri,cCodTra)

/*
// Determina todos los Días de Reposo
*/

FUNCTION ASIGN_PRES(FCH1,FCH2,A_DH)
RETURN ASIGN(FCH1,FCH2,.T.,[AD],,,A_DH)

/*
// Determina el Salario Integral
// 1= Es Salario Básico
*/
FUNCTION PROMEDIO_A(dFecha)

  LOCAL nSalario:=0
  nSalario:=EJECUTAR("NMCALACUMT",oNm,{oNm:oLee:CODIGO},1,.F.)

RETURN nSalario

/*
// Determina la Cantidad de Horas por Jornada
*/
FUNCTION HORAJORNADA(cTipoJorna,dDesde,dHasta)
   LOCAL nHoras:=0
RETURN nHoras
/*
// Determina el Salario Integral
// 2= Es Salario Integral
*/
FUNCTION PROMEDIO_B(dFecha)
  LOCAL nSalario:=0
  nSalario:=EJECUTAR("NMCALACUMT",oNm,{oNm:oLee:CODIGO},2,.F.)

RETURN nSalario

/*
// Determina el Salario Integral
// Determina el Salario Promedio Entre dos Periodos
= Es Salario Utilidades
*/
FUNCTION PROMEDIO_C(dDesde,dHasta)
RETURN SALARIOAVG("C",dDesde,dHasta)

/*
// Determina el Salario Integral
// 3 = Es Salario Utilidades
*/
FUNCTION PROMEDIO_D(dFecha)
  LOCAL nSalario:=0
  nSalario:=EJECUTAR("NMCALACUMT",oNm,{oNm:oLee:CODIGO},4,.F.)
RETURN nSalario

/*
// Devuelve el Slario Promedio
*/
FUNCTION PROMEDIO(cTipo,dDesde,dFecha,lCalcular,cCodTra)
   LOCAL nSalario:=0,cMes,cYear
   LOCAL nAt     :=0
   LOCAL oTable

   dDesde:=Eval(oDp:bFecha,dDesde)

   DEFAULT cTipo    :="A",;
           dFecha   :=oNm:dHasta,;
           lCalcular:=.F.,;
           cCodTra  :=oNm:oLee:CODIGO

   nAt:=AT(cTipo,"ABDC")

   IF nAt=0
      RETURN 0
   ENDIF

   IF lCalcular // Debe Calcular
      DO CASE
         CASE cTipo="A"
            nSalario:=PROMEDIO_A(dFecha)
         CASE cTipo="B"
            nSalario:=PROMEDIO_B(dFecha)
         CASE cTipo="C"
            nSalario:=PROMEDIO_C(dFecha)
         CASE cTipo="D"
            nSalario:=PROMEDIO_D(dFecha)
      ENDCASE

      RETURN nSalario

   ENDIF

/*   IF ValType(dFecha)<>"D"
      ? "dFecha no Sirve",dFecha
   ENDIF */

   cYear:=STRZERO(YEAR(dFecha) ,4)
   cMes :=STRZERO(MONTH(dFecha),2)

   oTable:=OpenTable("SELECT RMT_PROM_"+cTipo+" FROM NMRESTRA "+;
                     "WHERE RMT_CODTRA"+GetWhere("=",cCodTra)+;
                     "  AND RMT_ANO   "+GetWhere("=",cYear  )+;
                     "  AND RMT_MES   "+GetWhere("=",cMes   ),.T.)

   nSalario:=oTable:FieldGet(1)
   oTable:End()

RETURN nSalario

/*
  CALCULA LAS DEDUCCIONES
  UTILIZANDO LA MISMA FUNCIONE ASIGN
*/
FUNCTION DEDUCC(FCH1,FCH2,A_DH)
RETURN ASIGN(FCH1,FCH2,NIL,"D",,,A_DH)*-1

FUNCTION TOTAL(FCH1,FCH2,A_DH)
         // CALCULA LAS ASIGNACIONES - DEDUCCIONES
         // UTILIZANDO LA MISMA FUNCIONES
RETURN ASIGN(FCH1,FCH2,NIL,"AD",,,A_DH)

/*
// Graba el Contenido de un Campo
*/
FUNCTION GRABARCAM(cField,uValue,lResp) //
     LOCAL nLong:=0,cType,uValueOld:=uValue
     LOCAL lFound,oTable

     // cField:=PADR(LEFT(ALLTRIM(cField),10),10)

     DEFAULT lResp:=uValue

     IF oNm:lValidar
        RETURN FUNVAL("GRABARCAM",uValue)
     ENDIF

     IF oNm:lPrenomina .OR. !oNm:lActualiza
        RETURN lResp // IIF(lResp=NIL,oDp:uResp,lResp)
     ENDIF

     IF oTrabajador:FieldPos(cField)="O"
        RETURN .F.
     ENDIF

     IF !oNm:lSaveRec
       oNm:SaveRecibo()
       oNm:lSaveRec:=.T. // Ya Guardó el Recibo
     ENDIF

     uValueOld:=oTrabajador:FieldGet(cField)
     cType    :=ValType(uValueOld)
     uValueOld:=CTOO(uValueOld,"C") // Todo se Requiere en Cadenas

     oNm:oGrabar:Append()
     oNm:oGrabar:ReplaceSpeed("GRA_CAMPO" ,cField)
     oNm:oGrabar:ReplaceSpeed("GRA_CODTRA",oTrabajador:CODIGO)
     oNm:oGrabar:ReplaceSpeed("GRA_NUMREC",oNm:cRecibo) // oTrabajador:CODIGO)
     oNm:oGrabar:ReplaceSpeed("GRA_CODSUC",oNm:cCodSuc) // oTrabajador:CODIGO)
     oNm:oGrabar:ReplaceSpeed("GRA_CONTEN",uValueOld     )
     oNm:oGrabar:CommitSpeed(.F.)

     oTrabajador:Replace(cField,uValue)

     oTable:=OpenTable("SELECT "+cField+" FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",oTrabajador:CODIGO),.T.)

     oTable:Replace(cField,uValue)
     oTable:Commit(oTable:cWhere)
     oTable:End()

     STORE uValue TO (&cField)

RETURN IIF(lResp=NIL,oDp:uResp,lResp)

/*
// Validador de Sintaxis en Funciones
*/
STATIC FUNCTION FUNVAL(cName)
RETURN 0
/*
// Determina las Fechas Desde y Hasta
*/
FUNCTION GetFchFinHis(aConceptos,dDesde,dHasta,cTipCampo,cTipFecha,cTipoNom,cOtraNom,lMin)
RETURN GetFchIniHis(aConceptos,dDesde,dHasta,cTipCampo,cTipFecha,cTipoNom,cOtraNom,.F.)

/*
// Determina las Fechas Desde y Hasta
*/
//FUNCTION GetFchIniHis(aConceptos,dDesde,dHasta,lMin)
FUNCTION GetFchIniHis(aConceptos,dDesde,dHasta,cTipCampo,cTipFecha,cTipoNom,cOtraNom,lMin)
     LOCAL cWhere :="",cField,cSql,I
     LOCAL dFecha :=CTOD("")
     LOCAL oTable

     DEFAULT cTipCampo:=[C] // Tipo de Campo
     DEFAULT cTipFecha:=oDp:cTipFecha
     DEFAULT lMin:=.T.

     IF oNm:lActualiza
        oNm:CommitHistorico()
     ENDIF

     IF !EMPTY(cTipoNom)
       cWhere+="FCH_TIPNOM"+GetWhere("=",cTipoNom)
     ENDIF

     IF !EMPTY(cTipoNom)
       cWhere+=IIF( Empty(cWhere),"" ," AND ")+" FCH_OTRNOM"+GetWhere("=",cOtraNom)
     ENDIF

     IF !Empty(dDesde)

       cWhere:=ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere(">=",dDesde)," AND ")

     ENDIF

     IF !Empty(dHasta)
        cWhere:=ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere("<=",dHasta)," AND ")
     ENDIF

     IF ValType(aConceptos)="C"
         aConceptos:=_VECTOR(aConceptos)
     ENDIF

     cWhere    :="REC_CODTRA"+GetWhere("=",oNm:oLee:CODIGO)+;
                  IIF( Empty(cWhere), " " , " AND ")+cWhere

     cField    :=IIF( lMin,"FCH_DESDE","FCH_HASTA")

     FOR I := 1 TO LEN(aConceptos)

         cSql:=" SELECT "+IIF( lMin,"MIN","MAX")+"("+cField+") AS FECHA FROM NMHISTORICO INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
               " INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
               " WHERE "+cWhere+;
               " AND HIS_CODCON"+GetWhere("=",aConceptos[I])

         oTable :=OpenTable(cSql,.T.)
         dFecha :=oTable:FieldGet(1)
         oTable:End()

         IF !EMPTY(dFecha)
            EXIT
         ENDIF

     NEXT I

RETURN dFecha

/*
// Acumulado por Conceptos
*/
FUNCTION ACUMC_FCH(aConceptos,dDesde,dHasta,cTipCampo,cTipFecha,cTipoNom,cOtraNom,cWhere,lRevaloriza)
     // OBTIENE EL VALOR ACUMULADO DEL CONCEPTO DESDE CUALQUIER FECHA
     // FUNCTION ORIGINAL EN NOMINA DATAPRO DOS
     // LOCAL XAREA:=ALIAS(),XREG:=0,nResult:=0,XORD,__CAMPO,_ACUM,FDESDE,FHASTA
     // LOCAL bTIP_NOM,bOTRA_NOM,nLENACUM,bBLQACUM1,bBLQACUM2
     LOCAL cField,cSql,cInner:=""
     LOCAL nResp:=0
     LOCAL oTable
     LOCAL cMultiplica:=""
     LOCAL cFecha  :=HISFECHA()

     DEFAULT cTipCampo  :=[C],;
             cTipFecha  :=oDp:cTipFecha,;
             cWhere     :="",;
             lRevaloriza:=.F.

     IF oNm:lActualiza
        oNm:CommitHistorico()
     ENDIF

     IF !EMPTY(cTipoNom)
       cWhere+=IIF( Empty(cWhere),"" ," AND ")+"REC_TIPNOM"+GetWhere("=",cTipoNom)
     ENDIF

     IF !EMPTY(cTipoNom)
       cWhere+=IIF( Empty(cWhere),"" ," AND ")+" FCH_OTRNOM"+GetWhere("=",cOtraNom)
     ENDIF

     IF !Empty(dDesde)
        cWhere:=ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere(">=",dDesde)," AND ")
     ENDIF

     IF !Empty(dHasta)
        cWhere:=ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere("<=",dHasta)," AND ")
     ENDIF

     IF ValType(aConceptos)="C"
         aConceptos:=_VECTOR(aConceptos)
     ENDIF

    cWhere    :="REC_CODTRA"+GetWhere("=",oNm:oLee:CODIGO)+;
                 IIF( Empty(cWhere), " " , " AND ")+cWhere   +;
                 GetWhereOr("HIS_CODCON",aConceptos,"="," AND ")

    cField    :="HIS_MONTO"

    DO CASE
       CASE cTipCampo=[V]
            cField:="HIS_VARIAC"
       CASE cTipCampo=[1]
            cField:="OBS_FACTO1"
       CASE cTipCampo=[2]
            cField:="OBS_FACTO2"
       CASE cTipCampo=[3]
            cField:="OBS_FACTO3"
       CASE cTipCampo=[4]
            cField:="OBS_FACTO4"
    ENDCASE

    IF lRevaloriza

      DEFAULT oDp:cNomRevaloriza:="/"

      cMultiplica:=oDp:cNomRevaloriza+"REC_VALCAM"

    ENDIF

    IF "OBS_"$cField // INCLUYE LAS OBSERVACIONES
       cInner:="INNER JOIN NMOBSERV ON HIS_NUMOBS=OBS_NUMERO "
   ENDIF

   DEFAULT oDp:cNmExcluye :="FCH_OTRNOM"+GetWhere("<>","RM"),;
           oDp:dFchIniRec:=CTOD(""),;
           oDp:dFchFinRec:=CTOD(""),;
           oDp:nRecMonDiv:=1000000,;
           oDp:cNmExcluye :=""

   IF !Empty(oDp:dFchIniRec) .AND. Empty(cTipCampo) // 18/05/2023

      cField        :="(HIS_MONTO*IF("+cFecha+GetWhere(">=",oDp:dFchIniRec)+" AND "+cFecha+GetWhere("<=",oDp:dFchFinRec)+","+LSTR(oDp:nRecMonDiv)+",1))"
      oDp:cNmExcluye:="FCH_OTRNOM"+GetWhere("<>","RM") // Excluye Nómina reconversión Monetaria en Salario Promedio

      IF !("FCH_"$cWhere)
        cInner        :=cInner+" INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "
      ENDIF

   ENDIF

    nResp:=SQLGET("NMHISTORICO","SUM("+cField+cMultiplica+") AS HIS_MONTO ",;
                  " INNER JOIN NMRECIBOS ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
                  IIF("FCH_"$cWhere," INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+IF(Empty(oDp:cNmExcluye),""," AND "+oDp:cNmExcluye),"")+;
                  cInner+;
                  " WHERE "+cWhere)

   oDp:cSqlAcum:=oDp:cSql

   nResp:=IF(ValType(nResp)="N",nResp,0)

RETURN nResp

/*
// Suma un Campo desde la Ficha de Trabajadores
*/
FUNCTION SUM(cField,cWhere)
     LOCAL nSum:=0,oTable

     IF EMPTY(cField)
        RETURN 0
     ENDIF

     DEFAULT cWhere:=""

     cWhere:=IIF( Empty(cWhere),"" , " WHERE " )+cWhere
     oTable:=Opentable("SELECT "+cField+" FROM NMTRABAJADOR "+cWhere,.T.)
     nSum  :=oTable:FieldGet(1)
     oTable:End()

RETURN  nSum

/*
// Cuenta la Cantidad de Trabajadores Según la Condición
*/
FUNCTION CONTAR(cWhere)
   LOCAL nContar:=0,oTable

   DEFAULT cWhere:=""

   cWhere:=IIF( Empty(cWhere),"" , " WHERE " )+cWhere

   oTable:=OpenTable("SELECT COUNT(*) FROM NMTRABAJADOR "+cWhere,.T.)
   nContar:=oTable:FieldGet(1)
   oTable:End()

RETURN nContar

/*
// Lee Acumulado de Variaciones Variaciones
*/
FUNCTION ACUMV_FCH(aConceptos,dDesde,dHasta,cTipFecha,cTipoNom,cOtraNom)
RETURN ACUMC_FCH(aConceptos,dDesde,dHasta,[V],cTipFecha,cTipoNom,cOtraNom)
/*     IF !EMPTY(FUNERR1)
        FUNERR1:=[ACUMV_FCH("CONCEPTO",FECHA_DESDE,FECHA_HASTA,"DH",TIP_NOM,OTRA_NOM)]
  ENDIF */
//RETURN RESULT
// FCHANUAL Esta en DPWIN32.HRB

/*
// Determina el Salario Promedio entre Varios Meses
*/
FUNCTION SALARIOPRO(nMeses,dFecha,cTipo)
     LOCAL nAno,nMes,nAcumul:=0,nCant:=0,I
     LOCAL dDesde,oTable

     DEFAULT cTipo :=oDp:cSalPres
     DEFAULT dFecha:=oDp:dFecha

     nAno  :=YEAR(dFecha)
     nMes  :=MONTH(dFecha)
     dDesde:=dFecha

     FOR I := 1 TO  nMeses
       dDesde:=FchIniMes(dDesde)-1
     NEXT

     oTable:=OpenTable("SELECT RMT_PROM_"+cTipo+" FROM NMRESTRA "+;
                       "WHERE RMT_CODTRA"+GetWhere("=",oNm:oLee:CODIGO)+;
                       "  AND RMT_ANO   "+GetWhere(">=",YEAR(dDesde)) +;
                       "  AND RMT_MES   "+GetWhere(">=",MONTH(dDesde))+;
                       " ORDER BY RMT_ANO,RMT_MES "+;
                       " LIMIT "+STR(nMeses),.T.)

     oTable:GoTop()
     WHILE !oTable:Eof()
        nAcumul+=oTable:FieldGet(1)
        nCant++
        oTable:DbSkip()
     ENDDO

     oTable:End()

RETURN DIV(nAcumul,nCant)

/*
// Incluye de Forma Automátical el Trabajador en la Tabla de Vacaciones
*/
FUNCTION CREATABVAC(dDesde,dHasta,nDias)
     LOCAL oTable,lFound,cNumero

     oTable:=OpenTable("SELECT * FROM NMTABVAC WHERE TAB_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+" AND TAB_PROCES=0",.T.)

     IF oTable:RecCount()=0

       oTable:Append()

       cNumero:=oTable:GetMax("TAB_NUMERO")
       cNumero:=STRZERO(VAL(cNumero)+1,LEN(cNumero))

       oTable:Replace("TAB_NUMERO",cNumero)
       oTable:Replace("TAB_CODTRA",oTrabajador:CODIGO)
       oTable:Replace("TAB_BORRAR",.T.)
       oTable:Replace("TAB_PROCES",.F.)

     ELSE

        oTable:cWhere:="TAB_NUMERO"+GetWhere("=",oTable:TAB_NUMERO)

     ENDIF

     oTable:Replace("TAB_DESDE",dDesde)
     oTable:Replace("TAB_HASTA" ,dHasta)
     oTable:Replace("TAB_DIAS"  ,nDias) // Dias de Vacaciones
     oTable:Replace("TAB_PROCES",.F.)
     oTable:Replace("TAB_FECHA",oDp:dFecha)
     oTable:Commit(IIF(oTable:RecCount()=0,NIL,oTable:cWhere))
     oTable:End()

     PUBLICO("TABDESDE",dDesde)
     PUBLICO("TABHASTA",dHasta)
     PUBLICO("TABDIAS",nDias)

RETURN 0

/*
// Lee los Factores asociados a los historicos
// NMOBSERV.OBS_FACTOR1
*/
FUNCTION ACUMF1_FCH(aConceptos,dDesde,dHasta,aDebHab,cTipoNom,cOtraNom)
RETURN ACUMC_FCH(aConceptos,dDesde,dHasta,[1],aDebHab,cTipoNom,cOtraNom)
/*
// Lee los Factores asociados a los historicos
// NMOBSERV.OBS_FACTOR2
*/
FUNCTION ACUMF2_FCH(aConceptos,dDesde,dHasta,aDebHab,cTipoNom,cOtraNom)
RETURN ACUMC_FCH(aConceptos,dDesde,dHasta,[2],aDebHab,cTipoNom,cOtraNom)
/*
// Lee los Factores asociados a los historicos
// NMOBSERV.OBS_FACTOR3
*/
FUNCTION ACUMF3_FCH(aConceptos,dDesde,dHasta,aDebHab,cTipoNom,cOtraNom)
RETURN ACUMC_FCH(aConceptos,dDesde,dHasta,[3],aDebHab,cTipoNom,cOtraNom)

/*
// Lee los Factores asociados a los historicos
// NMOBSERV.OBS_FACTOR4
*/
FUNCTION ACUMF4_FCH(aConceptos,dDesde,dHasta,aDebHab,cTipoNom,cOtraNom)
RETURN ACUMC_FCH(aConceptos,dDesde,dHasta,[4],aDebHab,cTipoNom,cOtraNom)

FUNCTION INTERESES()
RETURN 0

FUNCTION TABLA()
RETURN 0


FUNCTION IFF(lCondic,uTrue,uFalse)
RETURN IIF(lCondic,uTrue,uFalse)

/*
// Carga las Jornadas
*/
FUNCTION LOADJORNADAS()
      LOCAL aDia   :=ARRAY(4),aSemana,aTiempo:={}
      LOCAL oTable,I,nLen
      LOCAL cLunes :="AP",cMartes :="AP",cMiercoles:="AP",cJueves:="AP",cViernes:="AP"
      LOCAL cSabado:="AP",cDomingo:="AP"
      LOCAL aJornadas:={}

      IF !EMPTY(oDp:aJornadas)
         RETURN oDp:aJornadas
      ENDIF

      oTable:=OpenTable("SELECT JOR_CODIGO,;
                                JOR_DOAM,JOR_DOPM,;
                                JOR_LUAM,JOR_LUPM,;
                                JOR_MAAM,JOR_MAPM,;
                                JOR_MIAM,JOR_MIPM,;
                                JOR_JUAM,JOR_JUPM,;
                                JOR_VIAM,JOR_VIPM,;
                                JOR_SAAM,JOR_SAPM FROM NMJORNADAS",.T.)

 // oTable:Browse()

      oTable:GoTop()
      aJornadas:={}

      WHILE !oTable:EOF()

          cDomingo  :=IIF(oTable:JOR_DOAM,"A","")+IIF(oTable:JOR_DOPM,"P","")
          cLunes    :=IIF(oTable:JOR_LUAM,"A","")+IIF(oTable:JOR_LUPM,"P","")
          cMartes   :=IIF(oTable:JOR_MAAM,"A","")+IIF(oTable:JOR_MAPM,"P","")
          cMiercoles:=IIF(oTable:JOR_MIAM,"A","")+IIF(oTable:JOR_MIPM,"P","")
          cJueves   :=IIF(oTable:JOR_JUAM,"A","")+IIF(oTable:JOR_JUPM,"P","")
          cViernes  :=IIF(oTable:JOR_VIAM,"A","")+IIF(oTable:JOR_VIPM,"P","")
          cSabado   :=IIF(oTable:JOR_SAAM,"A","")+IIF(oTable:JOR_SAPM,"P","")
          aSemana   :={cDomingo,cLunes,cMartes,cMiercoles,cJueves,cViernes,cSabado}
          aTiempo   :=Array(len(aSemana))

          FOR I=1 TO LEN(aSemana)
             nLen:=LEN(aSemana[I])
             nLen:=IIF( nLen=0,0,IIF(nLen=2,1,.5))
             aTiempo[i]:=nLen
          NEXT I

          AADD(aJornadas,{ALLTRIM(oTable:JOR_CODIGO),aTiempo,aSemana})

          oTable:Skip(1)

      ENDDO

      oTable:End()

      oDp:aJornadas:=ACLONE(aJornadas)

RETURN aJornadas

/*
// Lee los Dias Feriados
*/
FUNCTION LeeFeriados()
RETURN EJECUTAR("NMFERIADOSLEE")

/*
// Graba al Trabajador en la Tabla de Vacaciones
*/
FUNCTION GRATABLIQ(cField,uValue)
     LOCAL oTable
     LOCAL lFound:=.F.

     oTable:=OpenTable("SELECT "+cField+" FROM NMTABLIQ WHERE LIQ_CODTRA"+;
                       GetWhere("=",oTrabajador:CODIGO)+" AND LIQ_PROCES=0",.T.)

     IF oTable:RecCount()>0
        oTable:Replace(cField,uValue)
        oTable:Commit(oTable:cWhere)
        lFound:=.T.
     ENDIF

     oTable:End()

RETURN lFound

/*
// Crea Tabla de Prestamos
*/
FUNCTION CREATABPRES(nMonto,nCuota,nTasa,cNumero,cId)
   LOCAL oTable

   DEFAULT cId:=""

   IF EMPTY(nMonto)
      RETURN nMonto
   ENDIF

   nCuota :=IIF( nCuota=0 , nMonto , nCuota )

   cNumero:=SQLINCREMENTAL("NMTABPRES","PRE_NUMERO",;
                           " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO "+;
                           " WHERE REC_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+;
                           "   AND REC_CODSUC"+GetWhere("=",oNm:cCodSuc        )+;
                           " AND   PRE_ID"    +GetWhere("=",cID               )+;
                           " AND (PRE_TIPO='P'  OR PRE_TIPO='C')")

   IF oNm:lPrenomina
      RETURN nMonto
   ENDIF

   IIF(!oNm:lSaveRec,oNm:SaveRecibo(),NIL)

   oTable:=OpenTable("SELECT * FROM NMTABPRES",.F.)
   oTable:Append()
   oTable:Replace("PRE_NUMERO",cNumero)
   oTable:Replace("PRE_CODSUC",oNm:cCodSuc) // Sucursal
   oTable:Replace("PRE_MONTO" ,nMonto )
   oTable:Replace("PRE_CUOTA" ,nCuota )
   oTable:Replace("PRE_TASA"  ,nTasa  )
   oTable:Replace("PRE_NUMREC",oNm:cRecibo)
   oTable:Replace("PRE_CODTRA",oNm:oTrabajador:CODIGO)
   oTable:Replace("PRE_TIPO"  ,"P"    )
   oTable:Replace("PRE_MODO"  ,1      ) // Siempre
   oTable:Replace("PRE_ACTIVO",.T.    ) // Todos Estan Activos
   oTable:Replace("PRE_PROXIM",.T.    ) // Descuenta en Proximo
   oTable:Replace("PRE_ID"    ,cId    ) // ID del préstamo

   oTable:Commit()
   oTable:End()

RETURN nMonto

/*
// Devuelve las Cuotas de los Prestamos
*/
FUNCTION LEEPRESTAMO(nCuota,cMemo,lDeuda,lInteres,cCodTra,cId)
   LOCAL nMonto:=0,oTable,cWhere:="",cNumero:="",nDeuda:=0,oPagos:=0,nCuotas:=0
   LOCAL nCuantos:=0,nLen:=0,nInteres:=0,oUpdate,nMtoLee:=0
   LOCAL cLinea:="",cSql,lTieneCrono:=.F.

   DEFAULT cCodTra:=oTrabajador:CODIGO,lDeuda:=.F.,lInteres:=.F.,cId:=""

   oTable :=OpenTable("SELECT PRE_NUMERO,PRE_MONTO,PRE_CUOTA,PRE_TASA,REC_FECHAS FROM NMTABPRES"+;
                      " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO "+;
                      " WHERE REC_CODTRA"+GetWhere("=",cCodTra     )+;
                      "   AND REC_CODSUC"+GetWhere("=",oNm:cCodSuc )+; // JN 16/04/2016
                      " AND PRE_ID"+GetWhere("=",cId)+;
                      " AND PRE_TIPO='P'",.T.)

   IF oTable:RecCount()=0
     oTable:End()
     RETURN 0
   ENDIF

   /// oTable:Browse()

   WHILE !oTable:Eof()

     oPagos:=OpenTable("SELECT SUM(PRE_MONTO) AS PRE_MONTO,COUNT(*) AS CUANTOS FROM NMTABPRES "+;
                       " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO    "   +;
                       " WHERE REC_CODTRA"+GetWhere("=",cCodTra)              +;
                       "       AND PRE_CODSUC"+GetWhere("=",oNm:cCodSuc      )+;  // JN 16/04/2016
                       "       AND PRE_NUMERO"+GetWhere("=",oTable:PRE_NUMERO)+;
                       "       AND PRE_ID    "+GetWhere("=",cId)+;
                       "       AND PRE_TIPO='A'",.T.)

     //
     // Si tiene Cuotas Programadas, el monto es nCuotas cero
     //

     nCuotas    :=0
     lTieneCrono:=.T.

     IF SQLGET("NMFCHPRESTM","SUM(FDP_CUOTA)","FDP_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
                                              "FDP_ID    "+GetWhere("=",cId    )+" AND "+;
                                              "FDP_CODSUC"+GetWhere("=",oNm:cCodSuc)+" AND "+;
                                              "FDP_NUMPRS"+GetWhere("=",oTable:PRE_NUMERO))=0
        lTieneCrono:=.F.
        nCuotas    :=oTable:PRE_CUOTA // Paga la Cuota

     ENDIF

     nCuantos:=oPagos:FieldGet(2)+1
     // Deuda o Saldo
     nDeuda  :=oTable:PRE_MONTO-oPagos:PRE_MONTO

     // Cuota no Definida en el Préstamo
     IF nCuotas=0 .AND. !lTieneCrono
        nCuotas:=oTable:PRE_MONTO-oPagos:PRE_MONTO
     ENDIF

     // Cuota es Mayor que la Deuda
     IF nCuotas>oTable:PRE_MONTO-oPagos:PRE_MONTO .OR. lDeuda
        nCuotas:=oTable:PRE_MONTO-oPagos:PRE_MONTO
     ENDIF

     oPagos:End()

     IF nCuota>0 .AND. nMonto+nCuotas>nCuota
        nCuotas:=nCuotas+(nCuota-(nMonto+nCuotas))
     ENDIF

     nMtoLee:=0

     IF NMFCHPRESTM(cCodtra,oNm:dHasta,@nMtoLee,cId)
        nCuotas:=nMtoLee
     ENDIF

     nMonto:=nMonto+nCuotas

     IF nCuotas>0

        nLen  :=LEN(ALLTRIM(STR(nCuantos,10)))
        cLinea:="#"+oTable:PRE_NUMERO+" "+F8(oTable:REC_FECHAS)+" Cuota#"+STRZERO(nCuantos,nLen)+;
                ":"+ALLTRIM(TRAN(nCuotas,"999,999,999.99"))+" Saldo:"+ALLTRIM(TRAN(nDeuda-nCuotas,"999,999,999.99"))+""
        cMemo :=cMemo + IIF( EMPTY(cMemo) , "" , CRLF ) + cLinea

     ENDIF

     oDp:nTasa:=0 // Tasa Calculada por NMINTPRESTM

     IF lInteres

        nInteres:=EJECUTAR("NMINTPRESTM",NIL,oTable:PRE_NUMERO,nDeuda,oTable:PRE_TASA,NIL,oNm:dHasta)
        cLinea:="Interes: "+ALLTRIM(TRANS(nInteres,"999,999,999.99"))
        // +CRLF+;
        // oDp:cMemo
        cMemo :=cMemo + IIF( EMPTY(cMemo) , "" , CRLF ) + cLinea

     ENDIF

     /*
     // Debe Hacer el Registro del Pago
     */

     IF nCuotas>0 .AND. oNm:lActualiza

        IIF(!oNm:lSaveRec,oNm:SaveRecibo(),NIL)

        oPagos:=OpenTable("SELECT * FROM NMTABPRES",.F.)
        oPagos:Append()
        oPagos:Replace("PRE_NUMERO",oTable:PRE_NUMERO)
        oPagos:Replace("PRE_CODSUC",oNm:cCodSuc) // JN 16/04/2016
        oPagos:Replace("PRE_CODTRA",oNm:oTrabajador:CODIGO)
        oPagos:Replace("PRE_MONTO" ,nCuotas  )
        oPagos:Replace("PRE_CUOTA" ,0        )
        oPagos:Replace("PRE_NUMREC",oNm:cRecibo)
        oPagos:Replace("PRE_TIPO"  ,"A"      )
        oPagos:Replace("PRE_INTERE",nInteres )
        oPagos:Replace("PRE_ACTIVO",1        )
        oPagos:Replace("PRE_TASA"  ,oDp:nTasa)
        oPagos:Replace("PRE_ID"    ,cId      )

        oPagos:Commit()
        oPagos:End()

        oPagos:=OpenTable("SELECT SUM(PRE_MONTO) AS PRE_MONTO FROM NMTABPRES "+;
                          "INNER JOIN NMRECIBOS ON NMTABPRES.PRE_NUMREC=NMRECIBOS.REC_NUMERO "+;
                          "WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
                          "  AND PRE_NUMERO"+GetWhere("=",oTable:PRE_NUMERO)+;
                          "  AND PRE_CODSUC"+GetWhere("=",oNm:cCodSuc      )+;
                          "  AND PRE_ID"    +GetWhere("=",cId)+;
                          "  AND PRE_TIPO"  +GetWhere("=","A"),.T.)

         IF oPagos:PRE_MONTO>=oTable:PRE_MONTO

            cSql:="UPDATE NMTABPRES,NMRECIBOS SET PRE_ACTIVO=0 WHERE "+;
                  "REC_NUMERO=PRE_NUMREC AND "+;
                  "REC_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
                  "PRE_ID"    +GetWhere("=",cId    )+" AND "+;
                  "PRE_CODSUC"+GetWhere("=",oNm:cCodSuc)+" AND "+;
                  "PRE_NUMERO"+GetWhere("=",oTable:PRE_NUMERO)

            oPagos:EXECUTE(cSql)

         ENDIF

         oPagos:End()

     ENDIF

     oTable:DbSkip()

   ENDDO

//   ? "AQUI DEBE CAMBIAR EL ESTATUS DEL PRESTAMO"

   oTable:End()

RETURN nMonto

/*
// Determina la cantidad de Horas Trabajadas
*/
FUNCTION HORAS_TRAB(cCodJornada,dDesde,dHasta,lFeriados,lDescanso)
     // CALCULA LOS DIAS HABILES                                      //
     // NECESITA EL DIA INICIAL Y FINAL, EN CASO DE NO RECIBIRLOS     //
     // LOS OBTIENE DEL TIPO DE NOMINA                                //
     // TOMA COMO PUNTO DE PARTIDA LA FECHA INICIAL DEL PERIODO O LA  //
     // FECHA EN QUE EL TRABAJADOR SE INICIA EN LA EMPRESA            //
     LOCAL nDiasHab :=0
     LOCAL bRangoVac:={||.F.}
     LOCAL nAt      :=0          // Posición de la Jornada
     LOCAL cCalendar:=""
     LOCAL aJornadas:={}
     LOCAL nHoras   :=0

     LOCAL FECHA_VAC:=oTrabajador:FECHA_VAC
     LOCAL FECHA_FIN:=oTrabajador:FECHA_FIN

     FECHATABVAC(oTrabajador:CODIGO,@FECHA_VAC,@FECHA_FIN)

     IF TYPE("oNm")="O"  // Carga las Jornadas
        aJornadas:=ACLONE(oNm:aJornadas)
        cCalendar:=oNm:cCalendar
     ELSE
        aJornadas:=LoadJornadas()
        cCalendar:=LeeFeriados()
     ENDIF

     DEFAULT cCodJornada:=oTrabajador:TURNO,lFeriados:=.T. // TIPO_NOM // Asume Tipo de Nómina Como Jornada

     IF !lFeriados  // No necesita los dias Feriados
       cCalendar:=""
     ENDIF

     cCodJornada:=IIF( Empty(cCodJornada),oTrabajador:TIPO_NOM,cCodJornada) // Asume Tipo de Nómina Como Jornada
     cCodJornada:=ALLTRIM(cCodJornada)

     // Localizar la Jornada, según el Trabajador
     nAt    :=ASCAN(aJornadas,{|a,n|a[1]==cCodJornada})

     IF nAt>0
        aJornadas:=ACLONE(aJornadas[nAt,2])
     ELSE
        aJornadas:={1,1,1,1,1,0,0} // no Existe
     ENDIF


     IF dDesde=NIL // No envio Ningún Parametro

        dHasta:=oNm:dHasta
        dDesde:=MAX(EVAL(oDp:bFecha,oTrabajador:FECHA_ING),oNm:dDesde) // FECHA DE INGRESO     FECHA DE INGRESO

        IF !EMPTY(EVAL(oDp:bFecha,oTrabajador:FECHA_EGR))
           dHasta:=MIN(EVAL(oDp:bFecha,oTrabajador:FECHA_EGR),dHasta) // FECHA DE EGRESO
        ENDIF

        IF !EMPTY(EVAL(oDp:bFecha,FECHA_VAC))
           bRangoVac:={||dDesde>=EVAL(oDp:bFecha,FECHA_VAC) .AND. dDesde<=EVAL(oDp:bFecha,FECHA_FIN)} // PERIODO DE VACACIONES
        ENDIF

     ENDIF

     dDesde:=EVAL(oDp:bFecha,dDesde)
     dHasta:=EVAL(oDp:bFecha,dHasta)

     IF EMPTY(dDesde)
        ? "dDesde,Invalido",GETPROCE()
        RETURN 0
     ENDIF

  //   ? dDesde,"dDesde",dHasta,"dHasta"

     DO WHILE dDesde<=dHasta .AND. DOW(dDesde)>0 // !EMPTY(FCH1)
        IF !LEFT(DTOC(dDesde),5)$cCalendar.AND.!EVAL(bRangoVac).AND.!EMPTY(aJornadas)
           nHoras  :=8 // Debe buscar las Jornadas
           nDiasHab+=IIF(aJornadas[DOW(dDesde)]>0,nHoras,0) // SUMA LOS DIAS
        ENDIF
        dDesde++
     ENDDO

RETURN nDiasHab

/*
// Determina que Fecha se Emplea para
*/
FUNCTION HISFECHA(cTipFecha,cTipNom)

   LOCAL cFecha:="FCH_SISTEM"

   DEFAULT cTipFecha:=oDp:cTipFecha,;
           cTipNom  :=""

 // EMP_FECHDH  // Indica si la Fecha usada es DESDE/HASTA
   IF (cTipNom="Q" .OR. cTipNom="M")
      cTipFecha:="H"
   ENDIF

   IF cTipFecha="D"
      cFecha:="FCH_DESDE"
   ELSEIF cTipFecha="H"
      cFecha:="FCH_HASTA"
   ENDIF

RETURN cFecha

/*
// Grabar el Valor del Sueldo en NMRESTRA
*/
FUNCTION GRABARSUELDO(nMonto,lMinimo)
   LOCAL oTable,cAno,cMes
   LOCAL cCodTra:=oTrabajador:CODIGO
   LOCAL dFecha :=IIF(oDp:cTipFecha="D",oNm:dDesde,oNm:dHasta) // Solo Graba si Actualiza

   IF !oNm:lActualiza
      RETURN nMonto
   ENDIF

   DEFAULT lMinimo:=.F.

   dFecha:=Eval(oDp:bFecha,dFecha)
   cMes  :=STRZERO(Month(dFecha),2)
   cAno  :=STRZERO(Year(dFecha),4)

   oTable:=OpenTable("SELECT * FROM NMRESTRA WHERE RMT_CODTRA"+GetWhere("=",cCodTra)+;
                     " AND RMT_ANO"+GetWhere("=",cAno)+;
                     " AND RMT_MES"+GetWhere("=",cMes),.T.)

   IF oTable:RecCount()=0
      oTable:Append()
      oTable:Replace("RMT_CODTRA",cCodTra)
      oTable:Replace("RMT_ANO"   ,cAno   )
      oTable:Replace("RMT_MES"   ,cMes   )
   ENDIF

   oTable:Replace("RMT_CODSUC",oDp:cSucursal) // Sucursal
   oTable:Replace("RMT_SUELDO",nMonto) // Sueldo Básico Mensual
   oTable:Replace("RMT_MINIMO",lMinimo) // Sueldo Básico Mensual
   oTable:Commit(IIF(oTable:lAppend,"",oTable:cWhere))
   oTable:End()

RETURN nMonto

/*
// Grabar Tabla de Salarios Promedios
*/
FUNCTION GRABARSALARIO(cTipo,nMonto,dFecha,cCodTra,lGrabar)
   LOCAL oTable,cAno,cMes,cField

   DEFAULT cCodTra:=oTrabajador:CODIGO,;      // Asume Código del Trabajador
           lGrabar:=oNm:lActualiza    ,;      // Si no actualiza no Graba
           dFecha :=IIF(oDp:cTipFecha="D",oNm:dDesde,oNm:dHasta) // Solo Graba si Actualiza


   IF !lGrabar
       RETURN nMonto
   ENDIF

   IF LEN(ALLTRIM(cTipo))=1
      cField:="RMT_PROM_"+cTipo
   ELSE
      cField:=cTipo
   ENDIF

   dFecha:=Eval(oDp:bFecha,dFecha)
   cMes  :=STRZERO(Month(dFecha),2)
   cAno  :=STRZERO(Year(dFecha),4)

   oTable:=OpenTable("SELECT * FROM NMRESTRA WHERE RMT_CODTRA"+GetWhere("=",cCodTra)+;
                     " AND RMT_ANO"+GetWhere("=",cAno)+;
                     " AND RMT_MES"+GetWhere("=",cMes),.T.)

   IF oTable:RecCount()=0
      oTable:Append()
      oTable:Replace("RMT_CODTRA",cCodTra)
      oTable:Replace("RMT_ANO"   ,cAno   )
      oTable:Replace("RMT_MES"   ,cMes   )
   ENDIF

   oTable:Replace(cField,nMonto)
   oTable:Commit(IIF(oTable:lAppend,"",oTable:cWhere))
   oTable:End()

RETURN nMonto

/*
// Devuelve si la Fecha es Aniversario
*/
FUNCTION ANIVERSARIO(dFecha,dDesde,dHasta)
   LOCAL nDia,nMes

   dFecha:=EVAL(oDp:bFecha,dFecha)
   dFecha:=FCHANUAL(dFecha,dHasta)
   dDesde:=EVAL(oDp:bFecha,dDesde)
   dHasta:=EVAL(oDp:bFecha,dHasta)

   // ? dFecha>=dDesde.AND.dFecha<=dHasta,dDesde,dFecha,dHasta

RETURN (dFecha>=dDesde .AND. dFecha<=dHasta)

/*
// Salario Promedio
*/
FUNCTION SALARIOAVG(cTipo , dDesde , dHasta , cCodTra)
   LOCAL nSalario:=0,cSql,cAnoIni,cMesIni,cAnoFin,cMesFin,oTable
   LOCAL aConceptos:={}

   DEFAULT cCodTra:=oNm:oLee:CODIGO,dHasta:=dDesde

   DEFAULT oDp:lSalarioAvg:=.T.

   // JN 15/10/2021
   IF oDp:lSalarioAvg

      aConceptos:=IF(cTipo="A",oNm:aConceptosA,aConceptos)
      aConceptos:=IF(cTipo="B",oNm:aConceptosB,aConceptos)
      aConceptos:=IF(cTipo="C",oNm:aConceptosC,aConceptos)
      aConceptos:=IF(cTipo="D",oNm:aConceptosD,aConceptos)

      nSalario:=AVG_FCH(aConceptos,dDesde,dHasta) // ,cTipCampo,cTipFecha,cTipoNom,cOtraNom,cWhere)

      RETURN nSalario

   ENDIF

   cAnoIni:=STRZERO(YEAR(dDesde),4)
   cMesIni:=STRZERO(MONTH(dDesde),2)

   cAnoFin:=STRZERO(YEAR(dHasta),4)
   cMesFin:=STRZERO(MONTH(dHasta),2)


   cSql:="SELECT AVG(RMT_PROM_"+cTipo+") FROM NMRESTRA WHERE RMT_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
         " (RMT_ANO"+GetWhere(">=",cAnoIni)+" AND RMT_MES"+GetWhere(">=",cMesIni)+") AND "+;
         " (RMT_ANO"+GetWhere("<=",cAnoFin)+" AND RMT_MES"+GetWhere("<=",cMesFin)+") "

   oTable:=OpenTable(cSql,.T.)
   nSalario:=oTable:FieldGet(1)
   oTable:End()

   DPWRITE("TEMP\SALARIOAVG_"+ALLTRIM(cCodTra),oDp:cSql)

RETURN nSalario

/*
// Carga las tasas de Interes
*/
FUNCTION LASTASAS(dDesde,dHasta,cField,nTasa)
     // CARGA EN VECTORES LAS TASAS DE INTERESES DESDE EL PERIODO _DESDE,HASTA)
     LOCAL oTable,aTasas:={}
     LOCAL aFields:={"  "}

     IF !EMPTY(nTasa) // Tasa Fija
        AADD(aTasas,{dDesde,nTasa})
        AADD(aTasas,{dHasta,nTasa})
        RETURN aTasas
     ENDIF

     DEFAULT dDesde:=oNm:dDesde,;
             dHasta:=oNm:dHasta,;
             cField:="INT_TASA"

     oTable:=OpenTable(" SELECT INT_HASTA,"+cField+" FROM NMTASASINT "+;
                       " ORDER BY INT_HASTA ",.T.)

     aTasas:=oTable:aDataFill
     oTable:End()

RETURN aTasas

/*
// Busca los Intereses
*/
STATIC FUNCTION BUSCAINT(dFecha,aTasas)
   LOCAL I:=1,nTasa:=0,nLen:=LEN(aTasas)

   IF EMPTY(aTasas)
      RETURN 0
   ENDIF

   IF dFecha>=aTasas[nLen,1] // Si es Mayor que la Ultima
   // ? "entra en IF dFecha"
      RETURN aTasas[nLen,2]
   ENDIF

   WHILE I<=nLen .AND. (aTasas[I,1]<=dFecha)
      nTasa:=aTasas[I,2]
      I++
   ENDDO
RETURN nTasa

/*
// dFchIni, indica el periodo en que empieza a Calcular Intereses.
// nTasa es la Tasa Fija de Interes IBASE
*/
FUNCTION INTERES(cField,cDeuda,cAbonos,dDesde,dHasta,aVector,NEGATIVO,ANIODIAS,nTasa,_CFINMES,_CAPCOR,cCodTra,lIndexa,nBase,dFchIni,cSql)
   LOCAL aTasas :={},aCodCon:={},aPagos:={},aFechas:={},aSigno:={}
   LOCAL oTable
   LOCAL cFecha:=HISFECHA(),cWhere
   LOCAL nMax,nContar:=0,nDeuda:=0,nPagos:=0,nInteres:=0,nCapital:=0,nDias,I,nAt
   LOCAL nBaseAcu:=0
   LOCAL nBaseAnual:=oDp:nBaseAnual,nInteresT:=0
   LOCAL dFecha,dFechaA,dDia,dFechaNext
   LOCAL nBaseCap // := Capital Base
   LOCAL aData:={}
   LOCAL A1:=0,A2:=0,A3:=0

   DEFAULT nBaseAnual:=360

   nBase :=0 // Es Solicitado desde el Concepto para Conocer la Base de Cálculo

   DEFAULT aVector:={}

   DEFAULT cField :="INT_TASA",;
           cAbonos:="",;
           lIndexa:=.T.

   SET DECI TO 2

   DEFAULT cCodTra:=oTrabajador:CODIGO


   IF EMPTY(aVector)

      DEFAULT cCodTra:=oTrabajador:CODIGO,;
              dHasta :=oNm:dHasta

      aVector:={}
      cWhere :="REC_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
               "FCH_HASTA"+GetWhere("<=",dHasta)+" AND "+;
               GetWhereOr("HIS_CODCON",_Vector(cDeuda + IIF(EMPTY(cAbonos) , "" , "," ) + cAbonos))+;
               " ORDER BY FCH_HASTA"

      oTable:=OpenTable("SELECT HIS_CODCON,HIS_MONTO,"+cFecha+" FROM NMHISTORICO INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
                        "INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
                        " WHERE " + cWhere,.T.)


      WHILE !oTable:Eof()

         dFecha:=oTable:FIELDGET(3)
         nDias :=DAY(dFecha)

         IF nBaseAnual=360 .AND. (nDias>30)
            dFecha:=dFecha-1
         ENDIF

         AADD(aData,{oTable:HIS_CODCON,oTable:HIS_MONTO,dFecha,IIF(oTable:HIS_CODCON$cDeuda,1,-1)})
         oTable:DbSkip()

      ENDDO

      oTable:End()

   ELSE

      aData  :=ACLONE(aVector)
      aVector:={}

   ENDIF

   IF EMPTY(aData) // No hay Deuda
      RETURN 0
   ENDIF

   nMax:=Len(aData)
   dDia:=aData[nMax,3]

   aTasas:=LASTASAS(dDia,dHasta,cField,nTasa)

   FOR I:= 1 TO LEN(aTasas)

      IF aTasas[I,1]<dDia
         LOOP
      ENDIF

      dFecha:=aTasas[I,1]

      AADD(aData,{"INT1%",0,dFecha,1})

   NEXT

   // Ahora debe Buscar todos los Cambios de Tasa
   dDia:=aData[1,3] // Primera Fecha

   FOR I:= 1 TO LEN(aTasas)

     IF aTasas[I,1]<dDia
        LOOP
     ENDIF

     nAt:=ASCAN(aData,{|a,n|a[3]=aTasas[I,1]})

   NEXT

   // Contiene el Remanente de Días Transcurridos
   AADD(aData,{"INT3%",0,dHasta,1})

   aData:= ASORT(aData,,, { |x, y| x[3] < y[3] }) // Ordena por Fecha

   FOR I=1 TO LEN(aData)

      dFecha:=aData[i,3]
      nDias :=DAY(dFecha)

      IF nBaseAnual=360 .AND. (nDias>30)
        dFecha:=dFecha-1
      ENDIF

      // Determinar Año biciesto
      IF Month(dFecha)=2 .AND. Day(dFecha)=28 .AND. YEAR(dFecha)/4=INT(YEAR(dFecha)/4)
         dFecha:=dFecha+1
      ENDIF

      aData[i,3]:=dFecha

   NEXT I

   nMax:=Len(aData)
   dDia:=aData[nMax,3]

   DEFAULT dDesde:=aData[1,3],dHasta:=aData[nMax,3]

   aTasas:=LASTASAS(dDesde,dHasta,cField,nTasa)

   WHILE nContar<nMax

      nContar++
      dFecha  :=aData[nContar,3]
      nTasa   :=BUSCAINT(dFecha,aTasas) // BUSCA LA PRIMERA TASA DE INTERES

      nDeuda  :=aData[nContar,2] // aPagos[nContar]
      nPagos  :=0

      IF aData[nContar,1]$cAbonos
         nPagos  :=aData[nContar,2]
         nDeuda  :=0
      ENDIF

      nBase   :=nDeuda-nPagos
      dFechaNext:=dFecha

      nInteres:=0

      IF !EMPTY(dFechaA)  // Debe Calcular Interes

        nDias    :=0
        nInteres :=0
        dFechaNext:=dFecha

//        FOR dDia:= dFechaA+1 TO dFecha
//           EXIT
//        NEXT

        IF nInteres=0 // no hubo Cambio de Tasa

           // Debe Calcular Interes del Periodo Complero
           dDia :=dFechaNext
           nDias:=dFechaNext-dFechaA

           IF nBaseAnual=360 .AND. (nDias>30 .OR. (nDias>=28 .AND. MONTH(dFechaNext)=2))
              nDias:=30
           ENDIF

           IF lIndexa
             nInteres :=DIV(PORCEN(nCapital,nTasa),nBaseAnual)*nDias // Anual
           ELSE
             nInteres :=DIV(PORCEN(nBaseAcu,nTasa),nBaseAnual)*nDias // Anual
           ENDIF

           IF !Empty(dFchIni) .AND. dDia<dFchIni
               nInteres:=0
           ENDIF
           nInteres :=DIV(INT(nInteres*100),100)
           nCapital :=nCapital + nInteres
           nInteresT+=nInteres

           nBaseAcu:=nBaseAcu+nBase
           AADD(aVector,{aData[nContar,1],dDia,nBase,nBaseAcu,nTasa,nDias,nInteres,nCapital})

        ENDIF

      ELSE

         // Empieza la Semilla

         AADD(aVector,{aData[nContar,1],dFecha,nBase,nBase,0,0,0,nBase})
         nDeuda  :=nBase
         nBaseAcu:=nBase

      ENDIF

      nCapital:=nCapital+nDeuda // +nPagos-nInteres

      dFechaA :=dFecha // Fecha Anterior

   ENDDO

   nBase:=nBaseAcu

//   ? dDesde,dHasta,LEN(aVector)

RETURN nInteresT

/*
// Lectura de Ausencias
// nDiasCal, Viene por Ref e Indica los Días Calendarios
*/
FUNCTION AUSENCIA(cCodAus,dDesde,dHasta,nDiasCal,cDescri,cCodTra)
   LOCAL nResult:=EJECUTAR("NMFUNCAUSEN",@cCodAus,@dDesde,@dHasta,@nDiasCal,@cDescri,@cCodTra)

   cCodAus :=oNm:cCodAus
   dDesde  :=oNm:dDesde_Aus
   dHasta  :=oNm:dHasta_Aus
   cDescri :=oNm:cDescri_Aus
   nDiasCal:=oNm:nDiasCal_Aus

RETURN nResult

/*
// Crea un Nuevo Concepto para Variación
*/
FUNCTION CREAVARCON(cCodCon,nVariac,cObserv)

  LOCAL oTable

  oTable:=OpenTable("SELECT * FROM NMVARIAC WHERE "+;
                    "     VAR_CODTRA"+GetWhere("=",oNm:oLee:CODIGO)+;
                    " AND VAR_CODCON"+GetWhere("=",cCodCon        )+;
                    " AND VAR_TIPNOM"+GetWhere("=",oNm:cTipoNom   )+;
                    " AND VAR_OTRNOM"+GetWhere("=",oNm:cOtraNom   )+;
                    " AND VAR_DESDE "+GetWhere("=",oNm:dDesde     )+;
                    " AND VAR_HASTA "+GetWhere("=",oNm:dHasta     ),.T.)

  // ? oTable:cSql,ChkSql(oTable:cSql)

  IF oTable:RecCount()=0

     oTable:Append()
     oTable:Replace("VAR_CODTRA",oNm:oLee:CODIGO)
     oTable:Replace("VAR_CODCON",cCodCon        )
     oTable:Replace("VAR_TIPNOM",oNm:cTipoNom   )
     oTable:Replace("VAR_OTRNOM",oNm:cOtraNom   )
     oTable:Replace("VAR_DESDE ",oNm:dDesde     )
     oTable:Replace("VAR_HASTA ",oNm:dHasta     )
     oTable:Replace("VAR_CODSUC",oNm:cCodSuc    )
     oTable:Replace("VAR_CANTID",nVariac)
     oTable:Commit(oTable:cWhere)

  ELSE

  ENDIF

  oTable:Replace("VAR_CANTID",nVariac)
  oTable:Replace("VAR_OBSERV",cObserv)

  oTable:Commit(oTable:cWhere)

  oTable:End()

  oNm:CargaVariac()

RETURN .T.
/*
// Busca la Fecha de Vacación del Trabajador
*/
FUNCTION FECHATABVAC(cCodTra,dFechaIni,dFechaFin)

   LOCAL oTabla

   oTabla:=OpenTable("SELECT TAB_DESDE,TAB_HASTA FROM NMTABVAC WHERE TAB_CODTRA"+GetWhere("=",cCodTra)+;
                     " ORDER BY TAB_HASTA ",.T.)

   IF oTabla:Reccount()>0

      // oTabla:Browse()
      oTabla:GoBottom()
      dFechaIni:=oTabla:TAB_DESDE
      dFechaFin:=oTabla:TAB_HASTA

   ENDIF

   oTabla:End()

RETURN NIL

/*
// Devuelve el Monto por Inscripción de Guardería
// dDesde: Inicio de rastreo
// dHasta: Fin de Rastro
// cMemo : Contiene el Monto en Caso de Tener Varios Representados
// Se paga solo las inscripciones del periodo
*/
FUNCTION GuardIns(dDesde,dHasta,cMemo,nMax,bEdad,nSumMin)
    LOCAL nMonto:=0,oTable,cSql
    LOCAL nAnos :=0,nMeses:=0,nDias:=0

    DEFAULT nMax:=0,bEdad:={||.T.},nSumMin:=0

    cSql   :="SELECT * FROM NMTRABGUARD "+;
             " INNER JOIN NMFAMILIA ON FAM_CODTRA=GXT_CODTRA AND FAM_APELLI=GXT_APELLI AND FAM_NOMBRE=GXT_NOMBRE AND FAM_PARENT=GXT_PARENT "+;
             " WHERE "+;
             " GXT_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+" AND "+;
             GetWhereAnd("GXT_FCHINS",dDesde,dHasta)

    oTable :=OpenTable(cSql,.T.)

    WHILE !oTable:Eof()

       ANTIGUEDAD(oTable:FAM_FCHNAC,oTable:CMG_FECHA,@nAnos,@nMeses,@nDias)

       IF !Eval(bEdad,nAnos,nMeses,nDias)
          oTable:DbSkip()
          LOOP
       ENDIF

       nMonto :=nMonto +MIN(oTable:GXT_MTOINS,nMax)
       nSumMin:=nSumMin+nMax // Suma los Valores Mínimos

       cMemo  :=cMemo+IIF(Empty(cMemo),"",CRLF+CRLF)+;
                ALLTRIM(oTable:GXT_PARENT)+":"+" ("+ALLTRIM(oTable:GXT_APELLI)+","+ALLTRIM(oTable:GXT_NOMBRE)+") "+CRLF+;
                " Edad  :"+ANTIGUEDAD(oTable:FAM_FCHNAC,dHasta)+" Nacimiento:"+DTOC(oTable:FAM_FCHNAC)+CRLF+;
                " Monto :"+ALLTRIM(TRAN(MIN(oTable:GXT_MTOINS,nMax),"999,999,999.99"))

       oTable:Skip()

    ENDDO

    oTable:End()

RETURN nMonto

/*
// Devuelve el Monto por Inscripción de Guardería
// dDesde: Inicio de rastreo
// dHasta: Fin de Rastro
// cMemo : Contiene el Monto en Caso de Tener Varios Representados
// Se paga solo las inscripciones del periodo
// lMin:=.T.
*/
FUNCTION GuardCuotas(dDesde,dHasta,cMemo,nMax,bEdad,nSumMin,nCuantos)
    LOCAL nMonto:=0,oTable,cSql,nMin,cGrupo:="",nContar:=0,cLine:="",cHijo:="",I
    LOCAL nAnos :=0,nMeses:=0,nDias:=0,aCuotas:={},cWhere:=""

    DEFAULT nMax:=0,nSumMin:=0,bEdad:={||.T.}

    nCuantos:=0

    cSql   :="SELECT GXT_APELLI,GXT_NOMBRE,GXT_PARENT,CMG_MONTO,CMG_FECHA,CMG_NUMERO,FAM_FCHNAC FROM NMCUOTASGUARD "+;
             "INNER JOIN NMTRABGUARD ON GXT_CODTRA=CMG_CODTRA AND GXT_NUMERO=CMG_NUMREG "+;
             "INNER JOIN NMFAMILIA   ON GXT_CODTRA=FAM_CODTRA AND GXT_PARENT=FAM_PARENT AND FAM_APELLI=GXT_APELLI AND FAM_NOMBRE=GXT_NOMBRE "+;
             "WHERE "+;
             "GXT_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+" AND "+;
             GetWhereAnd("CMG_FECHAP",dDesde,dHasta)+" "+;
             " ORDER BY GXT_APELLI,GXT_NOMBRE,GXT_PARENT"

    oTable :=OpenTable(cSql,.T.)

    WHILE !oTable:Eof()

       cHijo  :=ALLTRIM(oTable:GXT_PARENT)+":"+" ("+ALLTRIM(oTable:GXT_APELLI)+","+ALLTRIM(oTable:GXT_NOMBRE)+") "+CRLF+;
                " Edad  :"+ANTIGUEDAD(oTable:FAM_FCHNAC,dHasta)+" Nacimiento:"+DTOC(oTable:FAM_FCHNAC)

       cGrupo :=oTable:GXT_APELLI+oTable:GXT_NOMBRE+oTable:GXT_PARENT
       nContar:=0
       cLine  :=""

       WHILE !oTable:Eof() .AND. cGrupo==oTable:GXT_APELLI+oTable:GXT_NOMBRE+oTable:GXT_PARENT

          nAnos :=0
          nMeses:=0
          nDias :=0

          ANTIGUEDAD(oTable:FAM_FCHNAC,oTable:CMG_FECHA,@nAnos,@nMeses,@nDias)

          IF !Eval(bEdad,nAnos,nMeses,nDias)
             oTable:DbSkip()
             LOOP
          ENDIF


          nMin   :=MIN(oTable:CMG_MONTO,nMax)

          AADD(aCuotas,{oTable:CMG_FECHA,oTable:CMG_NUMERO,nMin})

          nSumMin :=nSumMin+nMax // Suma los Valores Mínimos
          nCuantos:=nCuantos+1
          nMonto  :=nMonto+nMin
          cLine   :=cLine +IIF( Empty(cLine),"" ,CRLF )+;
                  "Cuota:"+oTable:CMG_NUMERO+" Fecha:"+DTOC(oTable:CMG_FECHA)+ " Monto :"+ALLTRIM(TRAN(nMin,"999,999,999.99"))

          nContar++
          oTable:DbSkip()

       ENDDO

        IF !Empty(cLine)
          cMemo :=cMemo+IIF(Empty(cMemo),"",CRLF+CRLF)+cHijo
          cMemo :=cMemo+CRLF+cLine
        ENDIF

    ENDDO

    // Debe Actualizar

    IF !Empty(aCuotas) .AND. oNm:lActualiza

       cWhere:=""

       AEVAL(aCuotas,{|a,n|cWhere:=cWhere+;
                           IIF( Empty(cWhere), "" , " OR " )+;
                           "("+;
                           "CMG_FECHA" +GetWhere("=",a[1] )+" AND "+;
                           "CMG_NUMERO"+GetWhere("=",a[2] )+")"})

       IF Empty(oNm:cRecibo) // Se requiere Recibo
          oNm:SaveRecibo()
       ENDIF

       cSql:="UPDATE NMCUOTASGUARD SET CMG_RECNUM"+GetWhere("=",oNm:cRecibo)+" WHERE "+;
             " CMG_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+" AND "+;
             +"("+cWhere+")"

       oTable:EXECUTE(cSql)

       FOR I := 1 TO LEN(aCuotas)

           cWhere:="CMG_FECHA" +GetWhere("=",aCuotas[I,1] )+" AND "+;
                   "CMG_NUMERO"+GetWhere("=",aCuotas[I,2] )+""

           cSql  :="UPDATE NMCUOTASGUARD SET CMG_MTOAPL"+GetWhere("=",aCuotas[I,3])+;
                                           ",CMG_RECNUM"+GetWhere("=",oNm:cRecibo)+;
                   " WHERE "+;
                   " CMG_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+" AND "+;
                     cWhere

           oTable:EXECUTE(cSql)

       NEXT


    ENDIF

    oTable:End()

RETURN nMonto
    //HCM ffffffffffffffffffffffffffffffffffffffff
/*
// Obtiene el Interes del HCM Familiar
*/
FUNCTION HcmFamInteres(dDesde,dHasta,cMemo)
RETURN HcmFamCapital(dDesde,dHasta,@cMemo,.F.)

/*
// Obtiene el Interes del HCM Familiar
*/
FUNCTION HcmFamCapital(dDesde,dHasta,cMemo,lCapital)
   LOCAL cSql,nMonto:=0,cLine:="",oTable,cItem:="",nCuota:=0

   DEFAULT dDesde  :=oNm:dDesde,;
           dHasta  :=oNm:dHasta,;
           lCapital:=.T.

   cMemo:=""

   cSql:="SELECT HCF_ITEM,NMHCMFAMILIA.HFM_APELLI,NMHCMFAMILIA.HFM_NOMBRE,HCF_NUMCUO,HCF_FECHA,HCF_CUOTA,HCF_CAPITA,HCF_INTERE "+;
         "FROM NMHCMFAMCUOTAS "+;
         "INNER JOIN NMHCMFAMILIA ON HFM_CODTRA=HCF_CODTRA AND HFM_NUMERO=HCF_NUMERO AND HCF_ITEM=HFM_ITEM "+;
         "WHERE HCF_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+" AND "+;
         GetWhereAnd("HCF_FECHA",dDesde,dHasta)+;
         " ORDER BY HCF_ITEM "

   oTable:=OpenTable(cSql,.T.)
   // oTable:Browse()
   cMemo :=""

   WHILE !oTable:Eof()

      cItem:=oTable:HCF_ITEM
      cLine:=""

      WHILE !oTable:Eof() .AND.  cItem=oTable:HCF_ITEM

        nCuota:=IIF( lCapital , oTable:HCF_CAPITA , oTable:HCF_INTERE )

        cLine :=cLine+IIF( Empty(cLine),"" , CRLF )+;
               "Asegurado: "+ALLTRIM(oTable:HFM_APELLI)+","+ALLTRIM(oTable:HFM_NOMBRE)+CRLF+;
               IIF( lCapital,"Capital: ","Interés: ")+oTable:HCF_NUMCUO+" "+DTOC(oTable:HCF_FECHA)+;
               " Monto: "+ALLTRIM(TRAN(nCuota,"999,999,999.99"))

        nMonto:=nMonto+nCuota

        oTable:DbSkip()

      ENDDO

      cMemo:=cMemo+IIF( Empty(cMemo), "" ,CRLF  )+cLine

   ENDDO

   oTable:End()

//   ? cSql

RETURN nMonto
     //HCM fffffffffffffffffffffffffffffffffff
/*
// Cargas Familiares, Reemplaza el Campo CARGAS_FAM
*/
FUNCTION CARGAS_FAM(cWhere,cCodTra)

    DEFAULT cCodTra:=oTrabajador:CODIGO,cWhere:=""

    cWhere:=IIF( Empty(cWhere), " " , " OR (" + cWhere +")" )

RETURN COUNT("NMFAMILIA","FAM_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
                               "FAM_DEPEND"+GetWhere("=","S")+cWhere)

/*
// Número de Descendientes
*/
FUNCTION NUM_DESCEN(cAnd,cCodTra)
    LOCAL nCargas:=0
    LOCAL cWhere :=" AND LEFT(FAM_PARENT,3)='Hij' "

    DEFAULT cCodTra:=oTrabajador:CODIGO,cWhere:=""

    cAnd:=IIF( Empty(cAnd), " " , " OR (" + cAnd +")" )

//  ? "FAM_CODTRA"+GetWhere("=",cCodTra)+ cWhere + cAnd

RETURN COUNT("NMFAMILIA","FAM_CODTRA"+GetWhere("=",cCodTra)+ cWhere + cAnd )

/*
// Número de Ascendentes (PADRES)
*/
FUNCTION NUM_ASCEND(cAnd,cCodTra)
    LOCAL nCargas:=0
    LOCAL cWhere :=" AND ( FAM_PARENT='Madre' OR FAM_PARENT='Padre') "

    DEFAULT cCodTra:=oTrabajador:CODIGO,cWhere:=""

    cAnd:=IIF( Empty(cAnd), " " , " OR (" + cAnd +")" )

//  ? "FAM_CODTRA"+GetWhere("=",cCodTra)+ cWhere + cAnd

RETURN COUNT("NMFAMILIA","FAM_CODTRA"+GetWhere("=",cCodTra)+ cWhere + cAnd )

/*
// Determina la Cantidad de Horas Semanales
*/
FUNCTION JOR_SEMHRS(cJornada,cDia)
   LOCAL nHoras:=0,oTable,I,cAmPm,U
   LOCAL aDias:={"LU","MA","MI","JU","VI","SA","DO"}
   LOCAL aAmPm:={"AM","PM"},cEnt,cSal

   DEFAULT cJornada:=oTrabajador:TURNO

   oTable:=OpenTable("SELECT * FROM NMJORNADAS WHERE JOR_CODIGO"+GetWhere("=",cJornada),.T.)

   FOR I := 1 TO LEN(aDias)
      FOR U := 1 TO LEN(aAmPm)
         cAmPm:="JOR_"+aDias[I]+aAmPm[U]
         IF oTable:FieldGet(cAmPm)
           cEnt:="JOR_"+aDias[I]+"E"+aAmPm[U]
           cSal:="JOR_"+aDias[I]+"S"+aAmPm[U]
           // ? oTable:FieldGet(cAmPm),cAmPm,cEnt,cSal
           nHoras:=nHoras+NTIME(oTable:FieldGet(cEnt)+"A",oTable:FieldGet(cSal)+"A")
         ENDIF
      NEXT U
   NEXT

   oTable:End()

RETURN nHoras

/*
// Determina el Tiempo, Entre dos Horas
*/
FUNCTION NTIME(cDesde,cHasta,cTime)
   LOCAL nVal1,nVal2,cMin,cMax,nTime:=0,cAmPm:=")*1",nIni,nMax,nMin
   LOCAL cMin1,cMin2
   LOCAL cHora1,cHora2,nMas:=0

   DEFAULT cDesde:="02:30A",cHasta:="04:30P"

   IF Left(cDesde,3)="12:"
     cDesde:=STRTRAN(cDesde,"12:","00:")
   ENDIF

   cMin:=IIF(cDesde<cHasta,cDesde,cHasta)
   cMax:=IIF(cDesde>cHasta,cDesde,cHasta)

   IF !RIGHT(cMin,1)$"AM"
      cMin:=cMin+"A"
   ENDIF

   IF !RIGHT(cMax,1)$"AM"
      cMax:=cMax+"A"
   ENDIF

   IF RIGHT(cMin,1)<>RIGHT(cMax,1)
      nMas:=12
   ENDIF

   cMin:="("+STRTRAN(cMin,":","*60)+")
   cMax:="("+STRTRAN(cMax,":","*60)+")

   cMin:=STRTRAN(cMin,"P",cAmPm)
   cMin:=STRTRAN(cMin,"A",cAmPm)
   cMax:=STRTRAN(cMax,"P",")*1")
   cMax:=STRTRAN(cMax,"A",")*1")

   cMin:="("+cMin
   cMax:="("+cMax

   nMax:=MACROEJE(cMax)
   nMin:=MACROEJE(cMin)

   // ? cMin,cMax,nMin,nMax,cMin1,cMin2
   nTime:=DIV(ABS(nMax-nMin),60)
   nTime:=nTime+nMas
   nMas :=nTime-INT(nTime)

   IF nMas>0
      nMas:=nMas*60
      cTime:=STRZERO(INT(nTime),2)+":"+STRZERO(nMas,2)
   ENDIF

RETURN nTime

/*
// Obtiene el Capital del HCM del Trabajador
*/
FUNCTION HcmCapital(dDesde,dHasta,cMemo,lCapital,lTrabajador)
   LOCAL cSql,nMonto:=0,cLine:="",oTable,cItem:="",nCuota:=0,nTasa:=0
   LOCAL nPago

   DEFAULT dDesde     :=oNm:dDesde,;
           dHasta     :=oNm:dHasta,;
           lCapital   :=.T.,;
           lTrabajador:=.F.   // No incluye Exoneración

   cMemo:=""

   cSql :=" SELECT CHC_CAPITA,CHC_INTERE,CHC_NUMCUO,CHC_FECHA,HCM_EXONER "+;
          " FROM NMHCMCUOTAS "+;
          " INNER JOIN NMHCM ON HCM_NUMERO=CHC_NUMERO  AND HCM_CODTRA=CHC_CODTRA "+;
          " WHERE CHC_CODTRA"+GetWhere("=",oTrabajador:CODIGO)+" AND "+;
           GetWhereAnd("CHC_FECHA",dDesde,dHasta)+;
          " ORDER BY CHC_NUMCUO "

//   ? CLPCOPY(cSql) // ,CHKSQL(cSql)

   oTable:=OpenTable(cSql,.T.)
   cMemo :=""

   WHILE !oTable:Eof()

      cItem :=oTable:CHC_NUMCUO
      cLine :=""
      nPago :=IIF( lCapital , oTable:CHC_CAPITA , oTable:CHC_INTERE )
      nTasa :=oTable:HCM_EXONER

      IF lTrabajador // Solo Obtiene la Parte Exonerada
         nTasa :=100-nTasa
      ENDIF

      nCuota:=PORCEN(nPago,nTasa)

      cLine :=cLine+IIF( Empty(cLine),"" , CRLF )+;
              "Cuota:"+oTable:CHC_NUMCUO+" "+DTOC(oTable:CHC_FECHA)+" "+;
              IIF( lCapital,"Capital: ","Interés: ") + ALLTRIM(TRAN(nPago,"999,999,999.99"))+;
              IIF( nTasa<>0,IIF( lTrabajador , " Exento:" , " Carga:" ) + LSTR(nTasa)+"%","")

      nMonto:=nMonto+nCuota

      oTable:DbSkip()

      cMemo:=cMemo+IIF( Empty(cMemo), "" ,CRLF  )+cLine

   ENDDO

   oTable:End()

RETURN nMonto

/*
// Obtiene el Interes del HCM  Trabajador
*/
FUNCTION HcmInteres(dDesde,dHasta,cMemo,lExonera)
RETURN HcmCapital(dDesde,dHasta,@cMemo,.F.,lExonera)

/*
// Obtiene la Parte que le corresponde al Trabajador
*/
  FUNCTION HcmTrabCapital(dDesde,dHasta,cMemo)
  RETURN HcmCapital(dDesde,dHasta,@cMemo,.T.,.T.)

/*
// Obtiene el Interes del HCM  Trabajador
*/
FUNCTION HcmTrabInteres(dDesde,dHasta,cMemo)
RETURN HcmCapital(dDesde,dHasta,@cMemo,.F.,.T.)

FUNCTION NMFCHPRESTM(cCodtra,dFecha,nMonto,cId)
   LOCAL lResp:=.F.

   DEFAULT cId:=""

   oDp:aRow:={}

   nMonto:=SQLGET("NMFCHPRESTM","FDP_CUOTA,FDP_FECHA",;
           "FDP_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
           "FDP_ID"    +GetWhere("=",cId    )+" AND "+;
           "FDP_FECHA "+GetWhere("=",dFecha))

   IF !Empty(oDp:aRow)
      lResp:=.T.
   ELSE
      nMonto:=0
   ENDIF

RETURN lResp

/*
// Acumulado por Clasificación de Conceptos
*/
FUNCTION ACUMULA_CLA(dDesde,dHasta,cCodCla)
RETURN ASIGN(dDesde,dHasta,.F.,ACONCEPTOS_CLA(cCodCla),,,NIL,.T.)

/*
// Acumulado por Clasificación de Conceptos
*/
FUNCTION ACONCEPTOS_CLA(cCodCla)
   LOCAL aConceptos:={}

   IF !Empty(cCodCla)

     IF ValType(cCodCla)="A"
       aConceptos:=ASQL("SELECT CYC_CODCON FROM NMCLAXCON WHERE "+GetWhereOr("CYC_CODCLA",cCodCla)+" GROUP BY CYC_CODCON")
     ELSE
       aConceptos:=ASQL("SELECT CYC_CODCON FROM NMCLAXCON WHERE CYC_CODCLA"+GetWhere("=",cCodCla)+" GROUP BY CYC_CODCON")
     ENDIF

     AEVAL(aConceptos,{|a,n|aConceptos[n]:=a[1] })

   ENDIF

RETURN ACLONE(aConceptos)

FUNCTION SUMCONCEPTOS(aCodCon,lRun)
   LOCAL cSuma:=""

   DEFAULT aCodCon:={},;
           lRun   :=.F.

   // Aqui Ejecuta los Conceptos y Crea las Variables

// ? GETPROCE()
// ViewArray(aCodCon)

   IF lRun

     AEVAL(aCodCon,{|a,n|CONCEPTO(a)})
   ENDIF

   AEVAL(aCodCon,{|a,n| cSuma:=cSuma+IIF(Empty(cSuma),"","+")+"C_"+a})

   IF Empty(cSuma)
      cSuma:="0"
   ENDIF

   oDp:cSuma:=cSuma

RETURN (&cSuma.)

FUNCTION SUMCONCEPTOSXCLA(cCodCla,lRun)
// ? "AQUI ES,SUMCONCEPTOSXCLA",cCodCla
RETURN SUMCONCEPTOS(ACONCEPTOS_CLA(cCodCla),lRun)

// Fecha/Hora : 22/08/2013 02:10:49
// Propósito  : Genera lista de Conceptos al Estilo Excel SUM("A001:A100")
// Creado Por : Juan Navas

FUNCTION NMSUM(cSum,cExc)
  LOCAL aCon:={},aExc:={},cCon:=""

  DEFAULT cSum:="",;
          cExc:=""

  aCon:=GETSUM(cSum)
  aExc:=GETSUM(cExc)

  // Remueve los Excluidos
  AEVAL(aExc,{|a,n,nAt| nAt:=ASCAN(aCon,a), IIF(nAt>0,ARREDUCE(aCon,nAt),NIL )})

  AEVAL(aCon,{|a,n| cCon:=cCon+IIF(Empty(cCon),"",",")+a})

RETURN cCon

FUNCTION GETSUM(cSum)
    LOCAL aSum:={},nAt1,nAt2,I,aCon:={}
    // ,oNm:=oDp:oNm,

    DEFAULT cSum:="A090:A090"

    IF oNm=NIL
       MensajeErr("Objeto oNm, no se ha Iniciado")
       RETURN ""
    ENDIF

    IF ","$cSum
       RETURN _VECTOR(cSum,",")
    ENDIF
    aSum:=_VECTOR(cSum,":")

    IF Empty(aSum)
       RETURN {}
    ENDIF

    nAt1:=ASCAN(oNm:aConceptos,{|a,n| a[1]>=aSum[1] })

    IF nAt1=0
       RETURN {}
    ENDIF

    I   :=nAt1

    WHILE I<=LEN(oNm:aConceptos)

       IF oNm:aConceptos[I,1]<=aSum[2]
          nAt2:=I
          AADD(aCon,oNm:aConceptos[I,1])
          I++
       ELSE
          EXIT
       ENDIF

    ENDDO

RETURN aCon

FUNCTION DESDE()
  MensajeErr(GETPROCE(),"Function DESDE ZARA "+DTOC(oNm:dDesde))
RETURN oNm:dDesde

FUNCTION HASTA()
  MensajeErr(GETPROCE(),"Function DESDE ZARA "+DTOC(oNm:dHasta))
RETURN oNm:dHasta

/*
// Average por Concepto
*/
FUNCTION AVG_FCH(aConceptos,dDesde,dHasta,cTipCampo,cTipFecha,cTipoNom,cOtraNom,cWhere)
     // OBTIENE EL VALOR ACUMULADO DEL CONCEPTO DESDE CUALQUIER FECHA
     //LOCAL XAREA:=ALIAS(),XREG:=0,nResult:=0,XORD,__CAMPO,_ACUM,FDESDE,FHASTA
     //LOCAL bTIP_NOM,bOTRA_NOM,nLENACUM,bBLQACUM1,bBLQACUM2
     LOCAL cField,cSql,cInner:=""
     LOCAL nResp:=0
     LOCAL oTable
     LOCAL cFecha:=HISFECHA()

     DEFAULT cTipCampo:=[C],;
             cTipFecha:=oDp:cTipFecha,;
             cWhere :=""

     IF oNm:lActualiza
        oNm:CommitHistorico()
     ENDIF

     IF !EMPTY(cTipoNom)
       cWhere+=IIF( Empty(cWhere),"" ," AND ")+"REC_TIPNOM"+GetWhere("=",cTipoNom)
     ENDIF

     IF !EMPTY(cTipoNom)
       cWhere+=IIF( Empty(cWhere),"" ," AND ")+" FCH_OTRNOM"+GetWhere("=",cOtraNom)
     ENDIF

     IF !Empty(dDesde)
        cWhere:=ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere(">=",dDesde)," AND ")
     ENDIF

     IF !Empty(dHasta)
        cWhere:=ADDWHERE(cWhere,HISFECHA(cTipFecha)+GetWhere("<=",dHasta)," AND ")
     ENDIF

     IF ValType(aConceptos)="C"
         aConceptos:=_VECTOR(aConceptos)
     ENDIF

     cWhere    :="REC_CODTRA"+GetWhere("=",oNm:oLee:CODIGO)+;
                  IIF( Empty(cWhere), " " , " AND ")+cWhere   +;
                  GetWhereOr("HIS_CODCON",aConceptos,"="," AND ")

    cField    :="HIS_MONTO"

    DO CASE
       CASE cTipCampo=[V]
            cField:="HIS_VARIAC"
       CASE cTipCampo=[1]
            cField:="OBS_FACTO1"
       CASE cTipCampo=[2]
            cField:="OBS_FACTO2"
       CASE cTipCampo=[3]
            cField:="OBS_FACTO3"
       CASE cTipCampo=[4]
            cField:="OBS_FACTO4"
    ENDCASE

    IF "OBS_"$cField // INCLUYE LAS OBSERVACIONES
       cInner:="INNER JOIN NMOBSERV ON HIS_NUMOBS=OBS_NUMERO "
    ENDIF

    DEFAULT oDp:cNmExcluye :="FCH_OTRNOM"+GetWhere("<>","RM"),;
            oDp:dFchIniRec:=CTOD(""),;
            oDp:dFchFinRec:=CTOD(""),;
            oDp:nRecMonDiv:=1000000,;
            oDp:cNmExcluye :=""

    IF !Empty(oDp:dFchIniRec)
       cField         :="(HIS_MONTO/IF("+cFecha+GetWhere(">=",oDp:dFchIniRec)+" AND "+cFecha+GetWhere("<=",oDp:dFchFinRec)+","+LSTR(oDp:nRecMonDiv)+",1))"
       oDp:cNmExcluye :="FCH_OTRNOM"+GetWhere("<>","RM") // Excluye Nómina reconversión Monetaria en Salario Promedio
       // cInner         :=cInner+" INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "
    ENDIF

    nResp:=SQLGET("NMHISTORICO","AVG("+cField+") AS HIS_MONTO",;
                  " INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
                  " INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+IF(Empty(oDp:cNmExcluye),""," AND ")+oDp:cNmExcluye+;
                  cInner+;
                  " WHERE "+cWhere)

    oDp:cSqlAcum:=oDp:cSql

    nResp:=IF(ValType(nResp)="N",nResp,0)

    DPWRITE("TEMP\AVG_FCH_"+ALLTRIM(oNm:oLee:CODIGO)+".SQL",oDp:cSql)

RETURN nResp

/*
// Calcular Salario Promedio (Dinámico desde valores Historicos según definición de Conceptos)
*/
FUNCTION AVGSALARIO(cCodTra,dDesde,dHasta,cWhereCon)
  LOCAL cFecha  :=HISFECHA(),cSql,nDivisa:=0,nPromedio,cFieldR,cWhere:=""

  // Definición de Variables

  DEFAULT cCodTra:=oTrabajador:CODIGO

  DEFAULT oDp:cNmExcluye :="FCH_OTRNOM"+GetWhere("<>","RM"),;
          oDp:dFchIniRec:=CTOD(""),;
          oDp:dFchFinRec:=CTOD(""),;
          oDp:nRecMonDiv:=1000000,;
          oDp:cNmExcluye :="",;
          cWhereCon     :=""

   DEFAULT dDesde:=oDp:dFchInicio,;
           dHasta:=oDp:dFchCierre

   cWhere:="REC_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
           GetWhereAnd(cFecha,dDesde,dHasta)

   IF !Empty(cWhereCon)
      cWhere:=cWhere+" AND "+cWhereCon
   ENDIF

   cFieldR:="HIS_MONTO"

   IF !Empty(oDp:dFchIniRec)
      cFieldR       :="(HIS_MONTO/IF("+cFecha+GetWhere(">=",oDp:dFchIniRec)+" AND "+cFecha+GetWhere("<=",oDp:dFchIniRec)+","+LSTR(oDp:nRecMonDiv)+",1))"
      oDp:cNmExcluye :="FCH_OTRNOM"+GetWhere("<>","RM") // Excluye Nómina reconversión Monetaria en Salario Promedio
   ENDIF

   // Excluye Transición Nómina para la Reconversión
   cWhere:=cWhere+IF(Empty(oDp:cNmExcluye),""," AND "+oDp:cNmExcluye)

   nPromedio:=SQLGET("NMHISTORICO","AVG("+cFieldR+") AS HIS_MONTO,AVG("+cFieldR+"/IF(REC_VALCAM>0,REC_VALCAM,HMN_VALOR)) AS HIS_MTODIV ",;
                     " INNER JOIN NMRECIBOS ON REC_CODSUC=HIS_CODSUC AND REC_NUMERO=HIS_NUMREC "+;
                     " INNER JOIN NMFECHAS  ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
                     " LEFT  JOIN DPHISMON  ON HMN_CODIGO"+GetWhere("=",oDp:cMonedaExt)+" AND HMN_FECHA="+oDp:cFchDivisa+;
                     " WHERE "+cWhere)

   oDp:nPromedioDiv:=DPSQLROW(2,0) // Promedio en DivisaS

RETURN nPromedio


