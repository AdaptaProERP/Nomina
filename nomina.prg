// ivillarro@cantv.net
/*
// Incluido en la Ejecución de DpNmWin
*/

#INCLUDE "\DPNMWIN\INCLUDE\DPXBASE.CH"
REQUEST ISOEM,TOLEAUTO //,TTxtEdit
REQUEST __SETFORMAT,TRDDARRAY

MEMVAR oDp,nResult,lVariac
MEMVAR VARIAC,FCHDESDE,FCHHASTA,TIP_NOM,OTRA_NOM,VAR1,ISR_ASIG,ASIGNA,DEDUCC,oNMTABVAC,oNMTABLIQ,VARMEMO
// MEMVAR TABDESDE,TABHASTA,TABDIAS
MEMVAR nFactor1,nFactor2,nFactor3,nFactor4,VAROBSERV
// MEMVAR SALARIOBAS,PRESTAC

//FUNCTION MYPRG()
//RETURN .T.


/*
 * Tnomina
*/
CLASS TNOMINA // FROM TDpClass

   DATA cTipoNom
   DATA cOtraNom
   DATA cCalendar
   DATA cTable
   DATA cTableObs
   DATA cNomina                            // Nombre del Tipo de N+mina
   DATA cModelRpt                          // Formato Crystal
   DATA cCrystal                           // Formato Crystal
   DATA cGrupoIni                          // Grupo de Trabajadores
   DATA cGrupoFin                          // Grupo de Trabajadores
   DATA cDepIni                            // Departamento Inicial
   DATA cDepFin                            // Departamento Final
   DATA cCodigoIni
   DATA cCodigoFin
   DATA cTitle
   DATA cError                             // Error en las Funciones
   DATA cCodCon                            // Concepto en Ejecución
   DATA cCodSuc   INIT oDp:cSucursal       // Código de Sucursal
   DATA cCodMon   INIT oDp:cMoneda         // Código de la Moneda
   DATA cRecibo                            // Número de Recibo
   DATA cSql
   DATA cFields                            // Campos de los Trabajadores
   DATA cWhereTrabj                        // Where Adicional que desea ser Agregado
   DATA cInnerTrabj                            // Relación Con Trabajador
   DATA cFchNumero
   DATA cScript      INIT "NOMINA"
// DATA cWhereTrabj  INIT ""  // Para Reversion especifica de Recibos,

   //  DATA cCodSuc    INIT oDp:cCodSuc
   // DATA cCodigoIni                         // Primer Trabajador Encontrado
   // DATA cRepProc                           // Reporte del Proceso

   DATA oTable                             // Aqui Se Genera la Prenómina
   DATA oTableObs                          // Observaciones en Prenómina
   DATA oMeter                             // Control Meter (Recorrido de Proceso)
   DATA oSayTrab                           // Visualiza el Nombre del Trabajador
   DATA oForm                              // Formulario de Edicion
   DATA oLee                               // Todos los Trabajadores de la Nómina
   DATA oTrabajador                        // Trabajador en Proceso
   DATA oRecibo                            // Recibos de Actualización
   DATA oGrabar
   DATA oHistorico
   DATA oObserv                            // Tabla de Observaciones
   DATA oScript
   DATA oSay
   DATA oJornadas
   DATA oMemo                              // Muestra la Traza de Ejecución

   DATA dDesde
   DATA dHasta

   DATA dDesdeAnt                          // Desde Anterior
   DATA dHastaAnt                          // Hasta Anterior

   DATA dFchRepIni                         // Fecha de Inicio de Reposo
   DATA dFchRepFin                         // Fecha Final del Reposo
//   DATA dFchTraIni                         // Fecha Inicial del Periodo de Pago
//   DATA dFchTraFin                         // Fecha Final del Periodo de Pago

   DATA lActualiza
   DATA lPrenomina
   DATA lReversar                          // Indica si está
   DATA lValidar                           // Requiere Validar el Programa
   DATA lCompilado                         // Requeire Compilar las Formulas
   DATA lModhrb INIT .F.                   // Indica que Ejecutará Módulos HRB
   DATA lLoad                              // Carga de Tablas
   DATA lDebug                             // Depurar
   DATA lPrint                             // No requiere Imprimir
   DATA lCancelar                          // Presionar Boton Cancelar
   DATA lArray                             // Resultados en un Arreglo
   DATA lEnd                               // Indicador de la Culminaci+n del Proceso
   DATA lCrystal                           // Si es por Crystal
   DATA lMsgAlert                          // Si Emite o no Mensaje
// DATA lOptimiza
   DATA lTodos                             // Todos los Trabajadores
   DATA lVariacion                         // Esta en Variaciones
   DATA lSysError                          // Indica la Activación de Errores
   DATA lHistorico                         // Indica si Excluye a los Históricos
   DATA lTablaLiq                          // Indica que el Trabajador esta en Tabla de Liquidacion
   DATA lSaveRec                           // Indica si el Recibo fue Grabado
   DATA lRecalcular                        // Recalcular Salarios
   DATA lMsgError  INIT .T.                // Indica si el Script Muestra el Error
   DATA lDeleteRec INIT .T.                // Remover Registros
   DATA lOptimiza  INIT .T.                // Optimiza la inserción de Registros, valida que el recibo no exista, para validar registro no repetido
// DATA lReciboSave

   DATA aConceptos                         // Lista de Conceptos ya Compilados
   DATA aConceptosErr INIT {}              // Lista de Conceptos con Errores
   DATA aListCon                           // Lista de Conceptos Válidos
   DATA aClearCon                          // Conceptos que deben ser Vacios
   DATA aConstantes                        // Lista de Constantes
   DATA aJornadas                          // Lista de Jornadas, por defecto es ORD
   DATA aHoras                             // Horas de las Jornadas
   DATA aClasifica                         // Clasificiaci+n de Conceptos
   DATA aListVar                           // ListVar
   DATA aPrenomina                         // Un Trabajador Específico
   DATA aTodos                             // Todos los Trabajadores
   DATA aErrors                            // Lista de Todos los Errores
   DATA aConceptosA                             // Acumulado01
   DATA aConceptosB                             // Acumulado02
   DATA aConceptosC                             // Acumulado03
   DATA aConceptosD                             // Acumulado04
   DATA aLink                               // Tablas Enlazadas
   DATA aRecAus                            // Registros de Ausencia
   DATA aRecibos   INIT {}                 // Recibos Existentes

   DATA aTracerFunc                        // Traza de Funciones y Conceptos
   DATA aCodTra                            // Trabajadores Excluidos
   DATA aTrabajador                        // Trabajadores Incluidos
   DATA aVariac                            // Variaciones
   DATA aUpDateRecibo                      // Complemento de los recibos
   DATA aVarCon                            // Conceptos que Califican Para Variaciones
   DATA aVar_Trab
   DATA aTabVac                            // Trabajadores en Vacaciones
   DATA aTabLiq                            // Trabajadores en Liquidaciones
   DATA aVar_Depu                           // Variables de Depuración
//   DATA aTiempos

   DATA nProcess                           // Cantidad de Trabajadores Procesados
   DATA nLenTra                            // Longitud del Código de Trabajador
   DATA nLenGru                            // Longitud dek Código del Grupo
   DATA nTime1
   DATA nTime2
   DATA nAsigna                            // Asignación por Trabajador
   DATA nDeduccion                         // Deducción por Trabajador
   DATA nNumObs                            // Numero de Observación
   DATA nSinSalario                        // Cantidad de Trabajadores Sin Salario
   DATA nRecibos                           // Cantidad de Recibos Existentes
   DATA nPromedioA                         // Promedios en Prenómina A
   DATA nPromedioB                         // Promedios en Prenómina B
   DATA nPromedioC                         // Promedios en Prenómina C
   DATA nPromedioD                         // Promedios en Prenómina D
   DATA nConceptos INIT 0                  // Indica la Cantidad de Conceptos Ejecutados en Function conceptos
   DATA nHoras     INIT 0 // Cantidad de Horas Durante Periodo de Pago

   DATA nBaseA                           // Sólo Asignaciones y Deducc A
   DATA nBaseB                           // Sólo Asignaciones y Deducc B
   DATA nBaseC                           // Sólo Asignaciones y Deducc C
   DATA nBaseD                           // Sólo Asignaciones y Deducc D
   DATA nLenRec                          // Longitud del Recibo
   DATA nDias                              // Dias Trabajados

  DATA  nLunAm INIT 0
  DATA  nLunPm INIT 0
  DATA  nLunes INIT 0

  DATA  nMarAm  INIT 0
  DATA  nMarPm  INIT 0
  DATA  nMartes INIT 0

  DATA  nMieAm     INIT 0
  DATA  nMiePm     INIT 0
  DATA  nMiercoles INIT 0

  DATA  nJueAm   INIT 0
  DATA  nJuePm   INIT 0
  DATA  nJueves  INIT 0

  DATA  nVieAm   INIT 0
  DATA  nViePm   INIT 0
  DATA  nViernes INIT 0

  DATA  nSabAm   INIT 0
  DATA  nSabPm   INIT 0
  DATA  nSabado  INIT 0

  DATA  nDomAm   INIT 0
  DATA  nDomPm   INIT 0
  DATA  nDomingo INIT 0

  DATA nSemana INIT 0
  DATA nHoras  INIT 0

  DATA HANDLEEVENT

   METHOD New(  cScript , cVarName ) CONSTRUCTOR
   METHOD Inspect()  INLINE EJECUTAR("INSPECT",SELF)
   METHOD Procesar()
   METHOD Compila()                         // Compila los Conceptos
   METHOD IniVars()                         // Genera todas las Variables desde Annn Hasta Znnn
   METHOD Constantes()                      // Genera los Valores de las Constantes
   METHOD jornadas()                        // Carga Todas las Jornadas
   METHOD Feriados()                        // Carga los Dias Feriados
   METHOD Iniciar()                         // Inicia todos los Valores
   METHOD Calcular()                        // Calcula el Resultado
   METHOD CreateTempo(cTable)
   METHOD GetRecibo()
   METHOD GetNumObs()
   METHOD SaveRecibo()
   METHOD SaveConcepto(nMonto,nVariac)
   METHOD CommitHistorico()
   METHOD UpDateFecha()
   METHOD UpDateRecibo()
   METHOD Reversar()
   METHOD LoadTrabajador()
   METHOD SaveMemo(cMemo)
   METHOD ClassName() INLINE "Nomina"
   METHOD Promedios()
   METHOD Link()
   METHOD CargaVariac() INLINE RunMacro("CargaVariac()")

   METHOD Set(cVar,uValue) INLINE (__objAddData( Self, cVar ),oSend(Self ,cVar , uValue))


   METHOD DESDE() INLINE ::dDesde // INLINE MensajeErr(GETPROCE(),"METHOD DESDE")
   METHOD HASTA() INLINE ::dHasta // INLINE MensajeErr(GETPROCE(),"METHOD HASTA")

   METHOD DESDEN() INLINE ::dDesde            // INLINE MensajeErr(GETPROCE(),"METHOD DESDE")
   METHOD HASTAN() INLINE FchFinMes(::dHasta) // INLINE MensajeErr(GETPROCE(),"METHOD HASTA")

   // METHOD BuildLee(cSql)

   METHOD GetRepProc()

/*
INLINE "Grupo: "+IIF( Empty(::cGrupoIni), "Ninguno ",CTOSQL(::cGrupoIni)+" - "+CTOSQL(::cGrupoFin))+CRLF+;
                              "Recibos Existentes: "+LSTR(::nRecibos) +CRLF+;
                              "Tipo Nómina : "+::cTipoNom                  +CRLF+;
                              "otra Nómina : "+::cOtraNom                  +CRLF+;
                              "Sin Salario : "+LSTR(::nSinSalario)         +CRLF+;
                              "Trabajadores: "+LSTR(::oLee:RecCount())     +CRLF+;
                              "Conceptos   : "+LSTR(LEN(::aConceptos ))
AEVAL(oNomina:aConceptosErr,{|a,n| cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+"CON_CODIGO"+GetWhere("=",a[1])})
*/

   METHOD End()

   ERROR HANDLER OnError( cMsg,nPar1,nPar2,nPar3,nPar4,nPar5,nPar6,nPar7,nPar8,nPar9,nPar10,nPar11,nPar12,nError )


// ERROR HANDLER OnError( cMsg,nPar1,nPar2,nPar3,nPar4,nPar5,nPar6,nPar7,nPar8,nPar9,nPar10,nPar11,nPar12,nError )

ENDCLASS

METHOD New( cScript , cVarName) CLASS TNOMINA
   LOCAL oTable

   DEFAULT cVarName:="oNm"
   DEFAULT cScript :="NOMINAINI"

   ::nLenRec:=SQLGET("DPCAMPOS","CAM_LEN","CAM_TABLE"+GetWhere("=","NMRECIBOS")+ " AND CAM_NAME"+GetWhere("=","REC_NUMERO"))
   oDp:oNm:=Self

   EJECUTAR("NOMINA",Self)
   ::oScript:=GetScript("NOMINA") // Obtiene Ultimo Script

// ? ::cCodSuc,"::cCodSuc"
// ? ::nLenRec ,"nLenRec"
// ::Super:New() //  cScript , cVarName)

   HrbLoad("DPNOMINA.HRB")

   PUBLICO(cVarName,SELF)

   // Variables Públicas
   PUBLICO("FCHINICIO",oDp:dFchInicio)
   PUBLICO("FCHFIN"   ,oDp:dFchCierre)
   PUBLICO("FECHAINI" ,oDp:dFchIni)
   PUBLICO("FECHAFIN" ,oDp:dFchFin)
   PUBLICO("FECHASIS" ,oDp:dFecha )
   PUBLICO("LIQCAUSA","")
   PUBLICO("CRLF",CRLF)

// ::cScript:=cScript // "NOMINAINI"
// ::oScript:=XCOMPILA(::cScript) // Programa Xbase
// Valores de N+mina

   ::cTipoNom   :="S"                   // Tipo de N+mina
   ::cOtraNom   :="  "                  // Otra N+mina
   ::cCalendar  :=""                    // Valores del Calendario
   ::cTable     :="NMHISTORICO"         // Hist+rico de Pagos
   ::cNomina    :=""                    // Nombre del Tipo de N+mina
   ::cCodigoIni :=""                    // Primer Trabajador encontrado
   ::cFchNumero :=""
   ::aRecAus    :={}                    // Registros leidos de Ausencias

// ::cRepProc   :=""
// ::cTotal     :=""                    // Total Trabajadores

   ::oTable     :=NIL                   // Tabla de Pagos
   ::oMeter     :=NIL                   // Control Meter (Recorrido de Proceso)
   ::oSayTrab   :=NIL                   // Visualiza el Nombre del Trabajador
   ::oForm      :=NIL                   // Formulario de Edicion

   ::dDesde     :=CTOD("01/07/2003")    // Periodo Inicial
   ::dHasta     :=CTOD("07/07/2003")    // Periodo Final

   ::dDesdeAnt  :=oDp:dDesdeAnt         // Desde Periodo Anterior
   ::dHastaAnt  :=oDp:dHastaAnt         // Hasta Periodo Anterior

   ::dFchRepIni :=CTOD("")              // Fecha de Inicio de Reposo
   ::dFchRepFin :=CTOD("")              // Fecha Final del Reposo

   ::lActualiza :=.F.                   // Est+ en Pren+mina
   ::lPrenomina :=.F.                   // Indica que est+ en Pren+mina
   ::lValidar   :=.F.                   // Requiere Validar el Programa
   ::lCompilado :=.F.                   // Requeire Compilar las Formulas
   ::lLoad      :=.F.                   // Carga de Tablas
   ::lPrint     :=.T.                   // No requiere Imprimir
   ::lCancelar  :=.F.                   // Presionar Boton Cancelar
   ::lArray     :=.F.                   // Resultados en un Arreglo
   ::lDebug     :=.F.                   // Depurar
   ::lEnd       :=.F.                   // Indicador de la Culminaci+n del Proceso
   ::lCrystal   :=.T.                   // Si es por Crystal
   ::lMsgAlert  :=.T.                   // Si Indica el Mensaje
   ::lOptimiza  :=.T.
   ::lReversar  :=.F.
   ::lVariacion :=.F.
   ::lSysError  :=.F.
   ::lHistorico :=.F.                   // Excluir Conceptos H del proceso de Prenómina

   ::aConceptos :={}                    // Lista de Conceptos ya Compilados
   ::aTrabajador:={}                    // Trabajadores Incluidos
   ::aListCon   :={}                    // Lista de Conceptos Válidos
   ::aConstantes:={}                    // Lista de Constantes
   ::aJornadas  :={}                    // Lista de Jornadas, por defecto es ORD
   ::aHoras     :={}                    // Horas de las Jornadas
   ::aListVar   :={}                    // ListVar
   ::aClasifica :={}                    // Clasificiaci+n de Conceptos
// ::aNomina    :=GetOptions("NMTRABAJADOR","TIPO_NOM") // Tipos de Nómina
   ::aVar_Trab   :={}                    // Variables Según Trabajadores
   ::aVar_Depu   :={}                    // Variables del Depurador
   ::aErrors     :={}                    // Lista de Errores
   ::aConceptosA     :={}                    // Acumulado 01
   ::aConceptosB     :={}                    // Acumulado 02
   ::aConceptosC     :={}                    // Acumulado 03
   ::aConceptosD     :={}                    // Acumulado 04
   ::aTracerFunc :={}                    // Traza de Funciones y Conceptos
   ::aCodTra     :={}                    // Trabajadores Válidos
   ::aVarCon     :={}
   ::aLink       :={}
   ::aTabVac     :={}                   // Trabajadores en Vacaciones
   ::aTabLiq     :={}                   // Trabajadores en Liquidaciones

   ::nProcess   :=0                     // Cantidad de Trabajadores Procesados
   ::nTime1     :=0
   ::nTime2     :=0
   ::nSinSalario:=0
   ::nRecibos   :=0

   ::nPromedioA :=0
   ::nPromedioB :=0
   ::nPromedioC :=0
   ::nPromedioD :=0

   ::nBaseA:=0
   ::nBaseB:=0
   ::nBaseC:=0
   ::nBaseD:=0

   ::cModelRpt  :=oDp:cPathCrp+"PRENOMINA.RPT" // Formato Crystal
   ::cCrystal   :=""                           // Formato Crystal
   ::cGrupoIni  :=""                           // Grupo de Trabajadores
   ::cGrupoFin  :=""                           // Grupo de Trabajadores
   ::cDepIni    :=""                           // Dpto Inicial
   ::cDepFin    :=""                           // Dpto Final
   ::cCodigoIni :=""
   ::cCodigoFin :=""
   ::cWhereTrabj:=""                           // Where Adicional
   ::cInnerTrabj:=""                           // Relación con Trabjador

   ::nLenTra    :=IIF( oDp:nLenTra=NIL,SQLFIELDLEN("NMGRUPO"     ,"GTR_CODIGO") , oDp:nLenTra )
   ::nLenGru    :=IIF( oDp:nLenGru=NIL,SQLFIELDLEN("NMTRABAJADOR","CODIGO"    ) , oDp:nLenGru )

   ::cCodigoIni :=SPACE(::nLenTra)
   ::cCodigoFin :=SPACE(::nLenTra)

   oDp:nLenTra  :=::nLenTra
   oDp:nLenGru  :=::nLenGru

   ::aVar_Depu:={}

   AADD(::aVar_Depu,{"Priva","VARIAC"   })
   AADD(::aVar_Depu,{"Priva","NFACTOR1" })
   AADD(::aVar_Depu,{"Priva","NFACTOR2" })
   AADD(::aVar_Depu,{"Priva","NFACTOR3" })
   AADD(::aVar_Depu,{"Priva","NFACTOR4" })
   AADD(::aVar_Depu,{"Priva","ISR_ASIG" })
   AADD(::aVar_Depu,{"Priva","ASIGNA"   })
   AADD(::aVar_Depu,{"Priva","DEDUCC"   })
   AADD(::aVar_Depu,{"Priva","VAROBSERV"})
   AADD(::aVar_Depu,{"Priva","VARMEMO"  })
   AADD(::aVar_Depu,{"Priva","FCHDESDE" })
   AADD(::aVar_Depu,{"Priva","FCHINICIO"})
   AADD(::aVar_Depu,{"Priva","FCHCIERRE"})
   AADD(::aVar_Depu,{"Priva","FCHHASTA" })
   AADD(::aVar_Depu,{"Priva","FECHASIS" })
   AADD(::aVar_Depu,{"Priva","TIP_NOM"  })
   AADD(::aVar_Depu,{"Priva","OTRA_NOM" })

   oDp:oNomina:=SELF

RETURN SELF

/*
// Reversar Nómina
*/
METHOD Reversar() CLASS TNOMINA
   LOCAL cSql,cTotal,cCodTra,cWhere,cSqlAll:="",cWhereTra:="",I
   LOCAL aObserv:={},aCodTra:={},aCodigos:={}
   LOCAL oRecibos,oTrabajador,oTable,aRecibos:={},aGrabar
   LOCAL oOdbc:=OpenOdbc(oDp:cDsnData)
   LOCAL oGrabar
   LOCAL uValue,cWhereGra:="",cNumFch
   LOCAL aFields:=ACLONE(OpenTable("SELECT * FROM NMTRABAJADOR",.F.):aFields),nAt:=0

   ::cCodSuc:=IIF(Empty(::cCodSuc),oDp:cSucursal,::cCodSuc)

// ? ::cCodSuc,"::cCodSuc"

   IF !EMPTY(::cCodigoIni)

        cWhereTra:="(NMTRABAJADOR.CODIGO "+GetWhere(">=",::cCodigoIni)+" AND "+;
                   " NMTRABAJADOR.CODIGO "+GetWhere("<=",::cCodigoFin)+")"

   ENDIF

   IF !EMPTY(::cGrupoIni)

      cWhereTra:=cWhereTra + IIF( Empty(cWhere ), "" , " AND ")+;
                 "(NMTRABAJADOR.GRUPO "+GetWhere(">=",::cGrupoIni)+" AND "+;
                 " NMTRABAJADOR.GRUPO "+GetWhere("<=",::cGrupoFin)+")"

   ENDIF

   // JN 13/12/2012
   // oTable:=OpenTable("SELECT * FROM NMTRABAJADOR",.F.)
   //aFields:=ACLONE(oTable:aFields)
   // oTable:End()


   ::cFields:=",CODIGO,APELLIDO,NOMBRE,COD_DPTO,BANCO"  // Campos Válidos del Trabajador
   ::nTime1 :=SECONDS()

   IF ::oLee=NIL

     IF !::Iniciar()
        Return .F.
     ENDIF
   ENDIF

   ::UpDateFecha() // 01/09/2021

   CursorWait()

   IF !Empty(oDp:cConfidWhere)
      cWhereTra:=ADDWHERE(cWhereTra,oDp:cConfidWhere)
   ENDIF

   cNumFch:=SQLGET("NMFECHAS","FCH_NUMERO","FCH_CODSUC"+GetWhere("=",::cCodSuc     )+" AND "+;
                                           "FCH_DESDE "+GetWhere("=",::dDesde      )+" AND "+;
                                           "FCH_HASTA "+GetWhere("=",::dHasta      )+" AND "+;
                                           "FCH_TIPNOM"+GetWhere("=",::cTipoNom    )+" AND "+;
                                           "FCH_OTRNOM"+GetWhere("=",::cOtraNom))


//   ? cNumFch, "FECHA "

   // JN  01/11/2019
   IF !Empty(::cWhereTrabj)
     cWhereTra:=IIF(Empty(cWhereTra),""," AND ")+::cWhereTrabj
   ENDIF

   ::cCodSuc:=IIF(Empty(::cCodSuc),oDp:cSucursal,::cCodSuc)

   cSql:="SELECT REC_CODTRA,REC_NUMERO FROM  NMRECIBOS "+;
         " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
         " INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
         " WHERE "+cWhereTra+IIF( Empty(cWhereTra) , " ", " AND " )+;
         " FCH_CODSUC"+GetWhere("=",::cCodSuc)+" AND FCH_NUMERO"+GetWhere("=",cNumFch)

   oDp:lExcluye:=.F.

   oTable:=OpenTable(cSql,.T.)
// oTable:Browse()
   AEVAL(oTable:aDataFill,{|a,n|AADD(aCodigos,a[1]),AADD(aRecibos,a[2])})
   ASORT(aCodigos)
   oTable:End()

   // Verifica la Reversión de Nómina
   IF !EJECUTAR("NMREVVAL",Self,cSql,aCodigos,aRecibos,cWhereTra)
      RETURN .F.
   ENDIF

   oTable:End()

//  cWhereGra:=GetWhereOr("GRA_NUMREC",aRecibos)

   IF LEN(aRecibos)>0

// JN 30/04/2014
     oTable:=OpenTable("SELECT GRA_CAMPO,REC_CODTRA,GRA_CONTEN FROM NMGRABAR "+;
                       "INNER JOIN NMRECIBOS ON REC_CODSUC=GRA_CODSUC AND REC_NUMERO=GRA_NUMREC "+;
                       "WHERE GRA_CODSUC"+GetWhere("=",::cCodSuc)+" AND "+;
                       GetWhereOr("GRA_NUMREC",aRecibos),.T.)
     cWhereGra:=oTable:cWhere
     aGrabar:=ACLONE(oTable:aDataFill)
     oTable:End()



   ENDIF

// JN 30/04/2014


/*
   cSql:="SELECT COUNT(*) FROM  NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
          " INNER JOIN NMFECHAS     ON REC_CODSUC AND FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
          " WHERE REC_CODSUC"+GetWhere("=",::cCodSuc)+" AND "+;
          cWhereTra+IIF( Empty(cWhereTra) , " ", " AND " )+;
          "        REC_NUMFCH"+GetWhere("=",cNumFch)

? "cSql1",CLPCOPY(cSql)
*/

/*
          "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
          "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
          "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
          "FCH_OTRNOM"+GetWhere("=",::cOtraNom)
*/

//     ? cSql
//   MemoWrit("sql.sql",cSql)
//   ::dDesde,::dHasta,::cTipoNom,::cOtraNom
//   ErrorSys(.T.)

//   oRecibos:=OpenTable(cSql,.T.)
//   ::nProcess:=oRecibos:FieldGet(1)
//   oRecibos:End()

// ? "ANTES DE CONTAR,cNumFch",cNumFch
// ErrorSys(.T.)

   ::nProcess:=COUNT("NMRECIBOS"," INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
                                 " INNER JOIN NMFECHAS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO "+;
                                 " WHERE REC_CODSUC" +GetWhere("=",::cCodSuc)+" AND "+;
                                 cWhereTra+IIF( Empty(cWhereTra) , " ", " AND " )+;
                                 "REC_NUMFCH"+GetWhere("=",cNumFch))

//? CLPCOPY(oDp:cSql),"::nProcess"

   IF Empty(::nProcess)

      ::oLee:End()
      MensajeErr("No hay Recibos para Reversar","Advertencia")
      ::UpDateFecha()
      EJECUTAR("NMRECFCH",::cTipoNom,::cOtraNom,::dDesde,::dHasta)

      RETURN .F.

   ELSEIF !MsgNoYes("Desea Reversar "+ALLTRIM(STR(::nProcess))+" Recibos ","Eliminar Recibos")

      RETURN .F.

   ENDIF

   AUDITAR("NREV" , NIL ,"NMRECIBOS", "" + ;
           +::cTipoNom+":"+::cOtraNom+"["+F8(::dDesde)+"-"+F8(::dHasta)+"]"+;
           +"/"+ALLTRIM(STR(::nProcess))+"Rec "+;
           +IIF( EMPTY(::cCodigoIni) , " " , "/C:["+ALLTRIM(::cCodigoIni)+"-"+ALLTRIM(::cCodigoFin)+"]"))

   IIF(::oMeter!=NIL,::oMeter:SetTotal(::nProcess),NIL)

   // Borrar NMOBSERV

   cSql:="DELETE NMOBSERV FROM NMOBSERV,NMRECIBOS,NMTRABAJADOR,NMHISTORICO,NMFECHAS "+;
         IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
         "FCH_CODSUC"+GetWhere("=",::cCodSuc )+" AND "+;
         "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
         "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
         "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
         "FCH_OTRNOM"+GetWhere("=",::cOtraNom)+;
         " AND NMTRABAJADOR.CODIGO   =NMRECIBOS.REC_CODTRA "+;
         " AND NMHISTORICO.HIS_CODSUC=NMRECIBOS.REC_CODSUC AND NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "+;
         " AND NMFECHAS.FCH_NUMERO   =NMRECIBOS.REC_NUMFCH "+;
         " AND NMHISTORICO.HIS_NUMOBS=NMOBSERV.OBS_NUMERO "


// ? "AQUI1",CLPCOPY(cSql)


     IF ::oLee:cType$"ADS,DBF,MSSQL"

       cWhere:=" WHERE "+cWhereTra+IIF( Empty(cWhereTra) , " " , " AND " )+;
               "  NMHISTORICO.HIS_NUMOBS> 0 AND "+;
               "  NMFECHAS.FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
               "  NMFECHAS.FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
               "  NMFECHAS.FCH_TIPONM"+GetWhere("=",::cTipoNom)+" AND "+;
               "  NMFECHAS.FCH_OTRNOM"+GetWhere("=",::cOtraNom)+" "

       oTable:=OpenTable("SELECT HIS_NUMOBS FROM NMHISTORICO "+;
                         "INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_CODTRA "+;
                         "INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=REC_CODTRA "+;
                         cWhere,.T.)

       oTable:GoTop()
       WHILE !oTable:Eof()
          oTable:oOdbc:Execute("DELETE FROM NMOBSERV WHERE OBS_NUMERO"+GetWhere("=",oTable:HIS_NUMOBS))
          oTable:Skip()
       ENDDO

       oTable:End()

     ELSEIF !oOdbc:Execute(cSql)

         MemoWrit("delete.sql",cSql)

         MensajeErr("No es Posible Reversar Observaciones de Nómina")

     ENDIF
/*
     cSql:="DELETE NMRECIBOS,NMHISTORICO FROM NMRECIBOS,NMTRABAJADOR,NMHISTORICO,NMFECHAS "+;
            IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
           "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
           "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
           "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
           "FCH_OTRNOM"+GetWhere("=",::cOtraNom)+" AND "+;
           " NMTRABAJADOR.CODIGO   =NMRECIBOS.REC_CODTRA AND "+;
           " NMFECHAS.FCH_NUMERO   =NMRECIBOS.REC_NUMFCH AND "+;
           " NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "
*/

    cSql:="DELETE NMHISTORICO FROM NMRECIBOS,NMTRABAJADOR,NMHISTORICO,NMFECHAS "+;
           IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
           "FCH_CODSUC"+GetWhere("=",::cCodSuc )+" AND "+;
           "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
           "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
           "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
           "FCH_OTRNOM"+GetWhere("=",::cOtraNom)+;
          " AND NMTRABAJADOR.CODIGO   =NMRECIBOS.REC_CODTRA "+;
          " AND NMHISTORICO.HIS_CODSUC=NMRECIBOS.REC_CODSUC AND NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "+;
          " AND NMFECHAS.FCH_NUMERO   =NMRECIBOS.REC_NUMFCH "
          //IIF(Empty(cWhereTra)  ," ", " AND "+cWhereTra  )+;
          //IIF(Empty(::cWhereRev)," ", " AND "+::cWhereRev))

      DPWRITE("TEMP\REVERSAR.SQL",cSql)

     IF !oOdbc:Execute(cSql)
        MensajeErr("No pudo ser eliminado NMHISTORICO")
     ENDIF


/*
// Reversar podrá remover especificamente recibos
*/

IF ::lDeleteRec

     cSql:="DELETE NMRECIBOS FROM NMRECIBOS,NMTRABAJADOR,NMHISTORICO,NMFECHAS "+;
            IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
           "REC_CODSUC"+GetWhere("=",::cCodSuc )+" AND "+;
           "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
           "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
           "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
           "FCH_OTRNOM"+GetWhere("=",::cOtraNom)+" AND "+;
           " NMTRABAJADOR.CODIGO   =NMRECIBOS.REC_CODTRA AND "+;
           " NMFECHAS.FCH_CODSUC   =NMRECIBOS.REC_CODSUC AND NMFECHAS.FCH_NUMERO   =NMRECIBOS.REC_NUMFCH AND "+;
           " NMHISTORICO.HIS_CODSUC=NMRECIBOS.REC_CODSUC AND NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "
ENDIF

//
//           "HIS_TIPONM"+GetWhere("=",::cTipoNom)+" AND "+;
//           "HIS_OTRANM"+GetWhere("=",::cOtraNom)+;

//      ? cSql
//      ? oOdbc:Execute(cSql),cSql
//      Memowrit("sql.sql",cSql)

// ? CLPCOPY(cSql)


     IF ::oLee:cType$"ADS,DBF,MSSQL"

       cSql:=" SELECT REC_NUMERO FROM  NMRECIBOS "+;
             " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
             " INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
             " WHERE "+cWhereTra+IIF( Empty(cWhereTra) , " ", " AND " )+;
             "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
             "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
             "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
             "FCH_OTRNOM"+GetWhere("=",::cOtraNom)

        oTable:=OpenTable(cSql,.T.)
        oTable:GoTop()
        WHILE !oTable:Eof()
           oTable:oOdbc:Execute("DELETE FROM NMRECIBOS   WHERE REC_NUMERO"+GetWhere("=",oTable:REC_NUMERO))
           oTable:oOdbc:Execute("DELETE FROM NMHISTORICO WHERE HIS_NUMREC"+GetWhere("=",oTable:REC_NUMERO))
           oTable:Skip()
        ENDDO

        oTable:End()

     ELSEIF ::lDeleteRec

        DPWRITE("TEMP\NMRECIBOSDELETE.sql",cSql)

        IF !oOdbc:Execute(cSql)

           MemoWrit("TEMP\NMRECIBOSDELETE.sql",oDp:cSql)

           MensajeErr("No es Posible borrar Recibos")

        ELSE
            /*
            // Puede darse el caso de Borrar el Cuerpo, la cabeza no se Borra
            */
            cSql:="DELETE NMRECIBOS FROM NMRECIBOS,NMTRABAJADOR,NMFECHAS "+;
                   IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
                  "NMRECIBOS.REC_NUMFCH=NMFECHAS.FCH_NUMERO  AND "+;
                  "NMTRABAJADOR.CODIGO =NMRECIBOS.REC_CODTRA AND "+;
                  "REC_NUMFCH"+GetWhere("=",cNumFch)+; //"FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;               "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
                  "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
                  "FCH_OTRNOM"+GetWhere("=",::cOtraNom)

            IF !SQLDELETE("NMRECIBOS","REC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+GetWhereOr("REC_NUMERO",aRecibos))
               MemoWrit("TEMP\NMRECIBOSDELETE.sql",oDp:cSql)
            ENDIF

//            ? oDp:cSql

/*
                   IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
                  "NMRECIBOS.REC_NUMFCH=NMFECHAS.FCH_NUMERO  AND "+;
                  "NMTRABAJADOR.CODIGO =NMRECIBOS.REC_CODTRA AND "+;
                  "REC_NUMFCH"+GetWhere("=",cNumFch)+; //"FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;               "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
                  "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
                  "FCH_OTRNOM"+GetWhere("=",::cOtraNom)
*/

            IF .F. .AND. !oOdbc:Execute(cSql)

              MemoWrit("delete.sql",cSql)

              MensajeErr("No es Posible borrar Recibos")

            ENDIF

        ENDIF

     ENDIF


     // Aqui se puede Recuperar el Campo del Trabajador
     FOR I := 1 TO LEN(aGrabar)

         nAt:=ASCAN(aFields,{|a,n|ALLTRIM(aGrabar[I,1])=ALLTRIM(a[1])})

         IF nAt>0
            aGrabar[I,3]:=CTOO(aGrabar[I,3],aFields[nAt,2]) // Convierte el Tipo de Datos
            SQLUPDATE("NMTRABAJADOR",aGrabar[I,1],aGrabar[I,3],"CODIGO"+GetWhere("=",aGrabar[i,2]))
         ENDIF

      NEXT

      cSql:="DELETE FROM NMGRABAR "+cWhereGra

      IF !EMPTY(cWhereGra) .AND. !oOdbc:Execute(cSql)
         MensajeErr("No es posible Remover a NMGRABAR","Ver DELETE.SQL")
         MemoWrit("delete.sql",cSql)
      ENDIF

/*
    cSql:="SELECT GRA_CODTRA,GRA_CAMPO,RTRIM(GRA_CONTEN) AS GRA_CONTEN ,GRA_TIPO,GRA_LONGIT FROM NMGRABAR "+;
           "INNER JOIN NMTRABAJADOR ON CODIGO=GRA_CODTRA "+;
           IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
           "GRA_DESDE "+GetWhere("=",::dDesde               )+" AND "+;
           "GRA_HASTA "+GetWhere("=",::dHasta               )+" AND "+;
           "GRA_TIPNOM"+GetWhere("=",::cTipoNom+::cOtraNom)+;
           " ORDER BY GRA_CODTRA,GRA_CAMPO"

     // ErrorSys(.T.)
     // ? cSql

     IIF( ::lSysError, ErrorSys(.T.) ,NIL)

     oGrabar:=OpenTable(cSql,.T.)

//     IIF(::oMeter!=NIL,::oMeter:SetTotal(oGrabar:RecCount()),NIL)
//     ? oGrabar:Eof(),"oGrabar"

     WHILE !oGrabar:Eof()

      cCodTra:=oGrabar:GRA_CODTRA
      cSql   :=""

      IF ::oMeter!=NIL
        oTrabajador:=OpenTable("SELECT APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)
        cTotal     :="["+GetNumRel(oGrabar:Recno(),oGrabar:RecCount())+"]"
        ::oMeter:Set(oGrabar:Recno())
        IIF( ValType(::oSayTrab)="O",::oSayTrab:SetText(cTotal+" "+ALLTRIM(oTrabajador:APELLIDO)+","+oTrabajador:NOMBRE),NIL)
        oTrabajador:End()
      ENDIF

      WHILE !oGrabar:Eof() .AND. cCodTra=oGrabar:GRA_CODTRA

         IF !(ALLTRIM(oGrabar:GRA_CAMPO)+"="$cSql)
           uValue:=CTOO(oGrabar:GRA_CONTEN,oGrabar:GRA_TIPO)
           uValue:=IIF( ValType(uValue)="C" , ALLTRIM(Left(uValue,oGrabar:GRA_LONGIT)) , uValue )
           cSql  :=cSql+IIF(Empty(cSql),"",",")+" "+ALLTRIM(oGrabar:GRA_CAMPO)+GetWhere("=",uValue)
         ENDIF

         oGrabar:Skip()

      ENDDO

      cSql   :="UPDATE NMTRABAJADOR SET "+ALLTRIM(cSql)+" WHERE CODIGO"+GetWhere("=",ALLTRIM(cCodTra))

      AADD(aCodTra,cCodTra)

      IF !oOdbc:Execute(cSql)
         MensajeErr(cSql,"Reversando Nómina")
      ENDIF

    ENDDO

  //  ? LEN(aCodTra),"aCodTra"

    oGrabar:End()

    cSql:="DELETE NMGRABAR FROM NMGRABAR,NMTRABAJADOR "+;
          IIF( Empty(::oLee:cWhere)," WHERE " , ::oLee:cWhere+" AND ")+;
          "NMTRABAJADOR.CODIGO=NMGRABAR.GRA_CODTRA AND "+;
          "NMGRABAR.GRA_DESDE "+GetWhere("=",::dDesde               )+" AND "+;
          "NMGRABAR.GRA_HASTA "+GetWhere("=",::dHasta               )+" AND "+;
          "NMGRABAR.GRA_TIPNOM"+GetWhere("=",::cTipoNom+::cOtraNom)

    IF ::oLee:cType$"ADS,DBF,MSSQL"

       FOR  I:= 1 TO LEN(aCodTra)

         cSql:="DELETE FROM NMGRABAR "+;
               "WHERE GRA_CODTRA"+GetWhere("=",aCodTra[i])+" AND "+;
               "NMGRABAR.GRA_DESDE "+GetWhere("=",::dDesde               )+" AND "+;
               "NMGRABAR.GRA_HASTA "+GetWhere("=",::dHasta               )+" AND "+;
               "NMGRABAR.GRA_TIPNOM"+GetWhere("=",::cTipoNom+::cOtraNom)

         ::oLee:Execute(cSql)

       NEXT

    ELSEIF !oOdbc:Execute(cSql)

       MensajeErr("No Puede Borrar NMGRABAR ")

   ENDIF
*/
   // IIF(::oSayTrab!=NIL,::oSayTrab:SetText("Actualizando Fechas"),NIL)
   // ::UpDateFecha()

//   AUDITAR("NREV" , NIL , NIL ,DTOC(::dDesde)+" - "+DTOC(::dHasta)+"/"+LSTR(::nProcess)+" Recibos")

   IIF(::oSayTrab!=NIL,::oSayTrab:SetText("Calculando Salarios"),NIL)

   FOR I=1 TO LEN(aCodigos)

      IF !::lRecalcular
          EXIT
      ENDIF

      IIF(::oMeter  !=NIL,::oMeter:Set(I,NIL)            ,NIL)
      IIF(::oSayTrab!=NIL,::oSayTrab:SetText("Calculando Salarios del Código:"+ALLTRIM(aCodigos[I])+" "+;
                SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",aCodigos[I]))),NIL)


      EJECUTAR("NMRECSALARIO",aCodigos[I],::dDesde,::dHasta,cNumFch)
/*      ::oLee:cSql:="SELECT CODIGO FROM NMTRABAJADOR WHERE CODIGO='"+aCodigos[i]+"'"
      ::oLee:Reload()
      oTable:=OpenTable("SELECT CODIGO,APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO='"+aCodigos[i]+"'",.T.)
      IIF(::oSayTrab!=NIL,::oSayTrab:SetText(aCodigos[I]+" "+ALLTRIM(oTable:APELLIDO)+","+ALLTRIM(oTable:NOMBRE)),NIL)
      oTable:End()
      ::Promedios() // Determina los Promedios
*/
   NEXT

//   IF !::lCompilado
//      ::Compila()
//   ENDIF

//   ::oLee:GoTop()

/*
   IIF(::oMeter!=NIL,::oMeter:SetTotal(Len(aCodigos)),NIL)

   FOR I=1 TO LEN(aCodigos)
      IIF(::oMeter  !=NIL,::oMeter:Set(I,NIL)            ,NIL)
      ::oLee:cSql:="SELECT CODIGO FROM NMTRABAJADOR WHERE CODIGO='"+aCodigos[i]+"'"
      ::oLee:Reload()
      oTable:=OpenTable("SELECT CODIGO,APELLIDO,NOMBRE FROM NMTRABAJADOR WHERE CODIGO='"+aCodigos[i]+"'",.T.)
      IIF(::oSayTrab!=NIL,::oSayTrab:SetText(aCodigos[I]+" "+ALLTRIM(oTable:APELLIDO)+","+ALLTRIM(oTable:NOMBRE)),NIL)
      oTable:End()
      ::Promedios() // Determina los Promedios
   NEXT

   IIF(::oMeter!=NIL,::oMeter:Set(Len(aCodigos)),NIL)
*/
   ::oLee:End()

//   IF ::nProcess>0 // Si Hubo Procesados
     EJECUTAR("NMREVFIN"  ,Self,aCodigos)  // Reversion

     IIF(::oSayTrab!=NIL,::oSayTrab:SetText("Calculando Promedios y Acumulados"),NIL)
     IIF(::lTodos,(aCodigos:={}),NIL)

     EJECUTAR("NMCALACUMC",::dHasta)       // Acumulador por Conceptos
     EJECUTAR("NMCALACUMT",Self,aCodigos)  // Calcula Acumulados por Concepto
//   ENDIF

   IIF(::oMeter!=NIL,::oMeter:Set(::nProcess),NIL)

//   ? "MEDIDOR",::oMeter:ClassName(),::nProcess

   ::nTime2:=SECONDS()

   STORE NIL TO oTable

RETURN .T.

/*
// Carga los Datos del Trabajador
*/
METHOD LoadTrabajador() CLASS TNOMINA

   IF ::oTrabajador=NIL
      ::cFields    :="*"
      ::oTrabajador:=OpenTable("SELECT "+::cFields+" FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",::oLee:CODIGO),.T.)
      AEVAL(::oTrabajador:aFields,{|a,i|Publico(a[1],::oTrabajador:FieldGet(i))})
      RETURN .T.
   ENDIF

   ::oTrabajador:cSql:="SELECT "+::cFields+" FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",::oLee:CODIGO)
   ::oTrabajador:ReLoad()
   AEVAL(::oTrabajador:aFields,{|a,i|Publico(a[1],::oTrabajador:FieldGet(i))})

RETURN .T.


/*
// Recorre todos los Trabajadores
*/
METHOD PROCESAR(lErrorSys) CLASS TNOMINA

   LOCAL cWhereCod,cWhereGru,cSql,cCampos:="",cCodCon
   LOCAL nLen,nCon,nAjuste,nResult
   LOCAL lProcess
   LOCAL oVariac,oScript
   LOCAL aData:={},aVarName:={}

// LOCAL oRecibo
   ::aUpDateRecibo:={}
   ::nTime1:=SECONDS()

   IF ValType(lErrorSys)="L"
      ::lSysError:=lErrorSys
   ENDIF

   // ErrorSys(.t.)
   IIF( ::lSysError, ErrorSys(.T.) ,NIL)

   IF !EJECUTAR("NMPROCESAR",SELF)
      RETURN .F.
   ENDIF

   IF ::oLee=NIL

     IF !::Iniciar()
        Return .F.
     ENDIF

   ENDIF

   IIF( ::lSysError, ErrorSys(.T.) ,NIL)

   // ErrorSys(.T.)

   IF ::lActualiza

      ::cSql      :=""
      ::oGrabar   :=OpenTable("SELECT * FROM NMGRABAR ",.F.)
      ::oGrabar:SetInsert(IIF(!::lOptimiza,0,10)) // 50)

      ::oHistorico:=OpenTable("SELECT * FROM NMHISTORICO",.F.)
      ::oHistorico:SetInsert(IIF(!::lOptimiza,0,40)) // 150)

      // ::oRecibo   :=OpenTable("SELECT * FROM NMRECIBOS",.F.)
      // ::oRecibo:SetInsert(1) // IIF(!::lOptimiza,0,10)) //0)

      ::oObserv   :=OpenTable("SELECT * FROM NMOBSERV",.F.)
      ::oObserv:SetInsert(1) // IIF(!::lOptimiza,0,10)) // 30)

//      ::UpDateFecha(.T.) // Debe Indicar que la Nómina Se Inicio

   ENDIF

   // PUBLICO("oNm",SELF)



   WHILE !::oLee:Eof() .AND. !::lCancelar

      // Si Devuelve .F. no se Ejecuta
      IF EJECUTAR("NMTRABCALCINI",Self)
        ::Calcular()
      ENDIF

      ::oLee:Skip()

   ENDDO

//   IF ::lPrenomina
//
//       AUDITAR("NPRE" , NIL ,"NMPRENOMINA", "" + ;
//               +::cTipoNom+":"+::cOtraNom+"["+F8(::dDesde)+"-"+F8(::dHasta)+"]"+;
//               +IIF( EMPTY(::cCodigoIni) , " " , "/C:["+ALLTRIM(::cCodigoIni)+"-"+ALLTRIM(::cCodigoFin)+"]"))
//
//   ENDIF

   IF ::lActualiza

      SysRefresh(.T.)

      ::oHistorico:End()
      ::oGrabar:End()
      // ::oRecibo:Commit(.T.) // Debe Grabar el Remanente
      // ::oRecibo:End()
      ::oObserv:End()

      ::UpDateRecibo()
      // ::UpDateFecha()

      IF ::nProcess>0
        // IIF(::lTodos,(::aCodTra:={}),NIL) // Van Todos

        IIF(::oSayTrab!=NIL,::oSayTrab:SetText("Actualizando Promedios y Acumulados"),NIL)

        AUDITAR("NACT" , NIL ,"NMRECIBOS", "" + ;
               +::cTipoNom+":"+::cOtraNom+"["+F8(::dDesde)+"-"+F8(::dHasta)+"]"+;
               +"/"+ALLTRIM(STR(::nProcess))+"Rec "+;
               +IIF( EMPTY(::cCodigoIni) , " " , "/C:["+ALLTRIM(::cCodigoIni)+"-"+ALLTRIM(::cCodigoFin)+"]"))

        EJECUTAR("NMCALACUMC",::dHasta) // Calcula Acumulados por Concepto

        IF ::lTodos
           EJECUTAR("NMCALACUMT",Self,{})   // Calcula Acumulados por Concepto
        ELSE
           EJECUTAR("NMCALACUMT",Self,::aCodTra)   // Calcula Acumulados por Concepto
        ENDIF

      ENDIF

   ENDIF

   IIF(::oMeter!=NIL,::oMeter:Set(::oLee:RecCount()),NIL) // Finaliza

   ::nTime2:=SECONDS()

   ::oLee:End()
   ::IniVars(.F.)  // Borra las Variables

   EJECUTAR("NMRUNEND",Self)

RETURN .T. // aPrenomina

/*
// Prepara todos los Valores para Generar el proceso de Calculo
*/
METHOD Iniciar(lMsg,lLoadTrabj) CLASS TNOMINA
   LOCAL cCampos:="",nLenGru,oGrupo,T1:=SECONDS(),cSql:="",cMsg:=""
   LOCAL oTrabajador,oRecibo,oVariac // ,oNMTABVAC
   LOCAL aCampos:={}

   DEFAULT lMsg:=.T. // Mensaje
   DEFAULT lLoadTrabj:=.T.

// SET DECI TO 2, AHORA SE DECLARA EN NMINI  COMO SET DECI TO 3

  // ?  ERRORSYS(.T.),"ERRORSYS EN INICIAR"

   IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:SetTotal(7),::oSayTrab:SetText("Cargando Nómina")),NIL)

   // Emulación DpNm24
   PUBLICO("oTrabajador",NIL)
   PUBLICO("VARIAC"     ,0  ) // Variaci+n de N+mina
   PUBLICO("FCHDESDE"   ,::dDesde)
   PUBLICO("FCHHASTA"   ,::dHasta)
   PUBLICO("FECHASIS"   ,oDp:dFecha)
   PUBLICO("TIP_NOM"    ,::cTipoNom)
   PUBLICO("OTRA_NOM"   ,::cOtraNom)
   PUBLICO("VAR1"       ,0)    // Variación
   PUBLICO("ISR_ASIG"   ,0)    // Asignaciones que Afectan ISLR
   PUBLICO("ASIGNA"     ,0)    // Total Asignaciones
   PUBLICO("DEDUCC"     ,0)    // Total Deducciones
   PUBLICO("oNm"        ,SELF) // Las Funciones Requieren esta Clase

   IF TYPE("ONMTABLIQ")="O"
      MACROEJE("ONMTABLIQ:END()")
      ONMTABLIQ:=NIL
   ENDIF

   IF TYPE("ONMTABVAC")="O"
      MacroEje("oNMTABVAC:End()")
   ENDIF

   PUBLIC ONMTABVAC
   PUBLIC ONMTABLIQ
/*
   IF ::lActualiza
      AUDITAR("NACT" , NIL , NIL ,DTOC(::dDesde)+" - "+DTOC(::dHasta)+ " Tipo: "+::cTipoNom)
   ENDIF

   IF ::lPrenomina
      AUDITAR("NPRE" , NIL , NIL ,DTOC(::dDesde)+" - "+DTOC(::dHasta))
   ENDIF
*/
//   IF TYPE("ONMTABLIQ")="O"
//      MacroEje("oNMTABLIQ:END()")
//   ENDIF


//   PUBLICO("TABDESDE"   ,CTOD(""))
//   PUBLICO("TABHASTA"   ,CTOD(""))
//   PUBLICO("TABDIAS"    ,0       )

   oNMTABVAC:=OpenTable("SELECT * FROM NMTABVAC LIMIT 1",.F.)
   AEVAL(oNMTABVAC:aFields,{|a,n,cField|cField:=STRTRAN(a[1],"_",""),PUBLICO(cField,oNMTABVAC:FieldGet(n))})
   oNMTABVAC:End()

   // ::aVariac   :={}
   ::nProcess   :=0   // Trabajadores Procesados
   ::aTodos     :={}
   ::nConceptos :=0
   ::nSinSalario:=0

   IF(ValType(::oMemo)="O",::oMemo:SetText("Iniciando Nómina"+CRLF),NIL)

   IF lLoadTrabj .AND. !EJECUTAR("NMRUNINI",Self)
      IF(ValType(::oMemo)="O",::oMemo:Append("Nómina no Iniciada"+CRLF),NIL)
      RETURN .F.
   ENDIF

   IF !::lLoad
     // T1:=SECONDS()
     IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:Set(1),::oSayTrab:SetText("Iniciando Valores")),NIL)
     ::IniVars(.T.)   // Genera todas las Variables desde Annn Hasta Znnn
     // ? SECONDS()-T1,"INIVARS"
     // T1:=SECONDS()
     IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:Set(2),::oSayTrab:SetText("Leyendo Constantes")),NIL)
     ::Constantes()   // Genera los Valores de las Constantes
     // ? SECONDS()-T1,"CONSTANTES"
     // T1:=SECONDS()
     IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:Set(3),::oSayTrab:SetText("Leyendo Jornadas")),NIL)
     ::jornadas()     // Carga Todas las Jornadas
     // ? SECONDS()-T1,"JORNADAS"
     T1:=SECONDS()
     IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:Set(4),::oSayTrab:SetText("Leyendo Calendario")),NIL)
     ::Feriados()     // Carga los Dias Feriados
     // ? SECONDS()-T1,"FERIADOS"
     ::lLoad:=.T.
   ENDIF

   // Lista de Clasificaciones
   ::aClasifica:={}
   IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:Set(5),::oSayTrab:SetText("Compilando Conceptos")),NIL)

   IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:Set(6),::oSayTrab:SetText("Leyendo Trabajadores")),NIL)

   IF ::cTipoNom!="O" .AND. !::lReversar // Se reversa es el Recibo

     cSql:=ADDWHERE(cSql,"NMTRABAJADOR.TIPO_NOM"+GetWhere("=",Left(::cTipoNom,2)))

   ENDIF

// ? cSql,"1"


   IF !EMPTY(::cCodigoIni) // Condigo del Trabajador

      cSql:=ADDWHERE(cSql,"(NMTRABAJADOR.CODIGO "+GetWhere(">=",::cCodigoIni)+" AND "+;
                          " NMTRABAJADOR.CODIGO "+GetWhere("<=",::cCodigoFin)+")")

   ELSEIF !EMPTY(::aTrabajador)

       cSql:=ADDWHERE(cSql,GetWhereOr("CODIGO",::aTrabajador))

   ENDIF

// ? cSql,"2"

   IF !EMPTY(::cGrupoIni) // Condigo del Trabajador

      cSql:=ADDWHERE(cSql,"(NMTRABAJADOR.GRUPO "+GetWhere(">=",::cGrupoIni)+" AND "+;
                          " NMTRABAJADOR.GRUPO "+GetWhere("<=",::cGrupoFin)+")")

   ENDIF

// ? cSql,"3"


   IF !EMPTY(::cDepIni) // Condigo del Trabajador

       cSql:=ADDWHERE(cSql,"(NMTRABAJADOR.COD_DPTO "+GetWhere(">=",::cDepIni)+" AND "+;
                           " NMTRABAJADOR.COD_DPTO "+GetWhere("<=",::cDepFin)+")")

   ENDIF

//   IF !EMPTY(oDp:cTrabExc) // Condicion de Trabajador Excluidos
//      cSql:=ADDWHERE(cSql," NMTRABAJADOR.CONDICION"+GetWhere("<>",oDp:cTrabExc))
//   ENDIF

//   IF !EMPTY(oDp:nTrabExc) // Condicion de Trabajador Excluidos
//      cSql:=ADDWHERE(cSql," (FECHA_EGR"+GetWhere("=",CTOD(""))+" OR FECHA_EGR"+GetWhere(">",oDp:dFecha-oDp:nTrabExc)+")")
//   ENDIF

   IF !EMPTY(oDp:cWhereTrab) .AND. !::lReversar
      cSql:=ADDWHERE(cSql,oDp:cWhereTrab)
   ENDIF

// ? cSql,"4"


   IF !Empty(oDp:cConfidWhere)
      cSql:=ADDWHERE(cSql,oDp:cConfidWhere)
   ENDIF


// ? cSql,"5"


   IF !EMPTY(::cWhereTrabj) // Condicion Indicada por Usuario
      cSql:=ADDWHERE(cSql,::cWhereTrabj)
   ENDIF

// ? cSql,"6"


   // MensajeErr(cSql,"cSql")

   ::lTodos:=Empty(::cCodigoIni+::cGrupoIni)

   IF EMPTY(::cCodigoIni) .AND. (::lActualiza .OR. ::lPrenomina) .AND. ::cTipoNom="O" .AND. ;
      SQLGET("NMOTRASNM","OTR_VARIAC","OTR_CODIGO"+GetWhere("=",::cOtraNom)) .AND. !::lVariacion

      oVariac:=OpenTable("SELECT VAR_CODTRA FROM  NMVARIAC WHERE "+;
                      "   VAR_DESDE "+GetWhere("=",::dDesde  )+;
                      "   AND VAR_HASTA "+GetWhere("=",::dHasta  )+;
                      "   AND VAR_TIPNOM"+GetWhere("=",::cTipoNom)+;
                      "   AND VAR_OTRNOM"+GetWhere("=",::cOtraNom)+;
                      " GROUP BY VAR_CODTRA ",.T.) // !::lVariacion)

       IF oVariac:RecCount()>0
          cSql:=ADDWHERE(cSql,GetWhereOr("CODIGO",oVariac:aDataFill))
       ELSE
          cMsg:="No hay Variaciones"
          cSql:=ADDWHERE(cSql,"1=0") // No debe Procesar
       ENDIF

       oVariac:End()

   ENDIF

   // ? ::cCodigoIni+::cGrupoIni,::lTodos,"TODOS"
   // ? cSql

/*
   cWhere:=IIF(Empty(::cWhereTra)

//," ", " AND "+::cWhereTra  )+;
//           IIF(Empty(::cWhereRev)," ", " AND "+::cWhereRev)

   IF !Empty(cWhere)
      cSql:=cSql+" AND "+::cWhereTra
   ENDIF
*/

   cSql:="SELECT CODIGO FROM NMTRABAJADOR "+::cInnerTrabj+;
         IIF( Empty(cSql) .OR. " WHERE "$cSql,""," WHERE ")+cSql+;
         " ORDER BY CODIGO"

// ? cSql,"7"

   DPWRITE("TEMP\RUNNOMINA.SQL",cSql)

 // ? ClpCopy(cSQL)

   IF ::lPrenomina .AND. !::lArray .AND. !::lVariacion  // Creación del Temporal Pren+mina

//    ::cTable:=SQLCREATEMPO("PRENOMINA","NMHISTORICO")
      ::cTable:="NMPRENOMINA" // SQLCREATEMPO("PRENOMINA","NMPRENOMINA")
      SQLZAP(::cTable)
      ::oTable:=OpenTable(::cTable,.T.)

      MensajeErr(::cTable+" Es el Temporal")

      IF ::oTable:MsgError("Proceso PreNómina")
         ::oTable:End()
         RETURN .F.
      ENDIF
      ::oTable:End()

      // Observaciones de Prenómina 12345678
/*
      ::cTableObs:=SQLCREATEMPO("OBSERVA","NMOBSERV")
      SQLZAP(::cTableObs)
      ::oTableObs:=OpenTable(::cTableObs,.T.)

      IF ::oTable:MsgError("Proceso PreNómina")
         ::oTable:End()
         RETURN .F.
      ENDIF
*/
   ELSEIF !::lPrenomina

      ::cTable:="NMHISTORICO"

   ENDIF

   IF ::lReversar // Solo Necesito el Where
      ::oLee:=OPENTABLE(cSql,.F.)
      RETURN .T.
   ENDIF

   IIF( ValType(::oLee)="O" , ::oLee:End() , NIL)

   ::oLee:=OPENTABLE(cSql,lLoadTrabj)

   IF ValType(::oMemo)="O"
      ::oMemo:Append("Procesando "+LSTR(::oLee:RecCount())+" Trabajadores "+CRLF)
   ENDIF

   IIF(::oSayTrab!=NIL,::oSayTrab:SetText("Procesando "+ALLTRIM(STR(::oLee:RecCount()))+" Trabajadores"),NIL)
   IIF(::oMeter  !=NIL,::oMeter:SetTotal(::oLee:RecCount()),NIL) // Empieza

   IF ::oLee:RecCount()=0 .AND. lLoadTrabj

      DPWRITE("NMNINGUNTRABAJADOR.SQL",cSql)

      MensajeErr("Ningún Trabajador para Nómina: "+::cNomina+" "+::cOtraNom+CRLF+;
                 "Grupo : "+::cGrupoIni+" -"+::cGrupoFin+CRLF+cMsg,NIL,{||lMsg})

//      ::oLee:End()
//      ::oLee:=NIL

      RETURN .F.
   ENDIF

  // Variables Públicas Según Trabajadores
   ::aVar_Trab   :={}
   IF ValType(::cFields)!="C"
      ::cFields    :=""
      ::oTrabajador:=OpenTable("SELECT * FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",::oLee:CODIGO),.T.)
      AEVAL(::oTrabajador:aFields,{|a,i|::cFields:=::cFields+IIF( i=1,"" ,",")+a[1],Publico(a[1],::oTrabajador:FieldGet(i))})
   ELSE
      aCampos       :=_VECTOR(::cFields)
      AEVAL(aCampos,{|a,i|a:=uppe(alltrim(a)),__QQPUB(a),MOVER(NIL,a)})
   ENDIF

   aCampos:=_Vector(::cFields)
   ASORT(aCampos)
   AEVAL(aCampos,{|a,n|AADD(::aVar_Depu,{"Field",a})})

   ::aVar_Trab:=SAVE_VAR(cCampos) // Variables Públicas Según Trabajadores

//   ::aCodTra  :={}
// ? "AQUI E"

   IF ((::lActualiza .OR. ::lPrenomina) .AND. !::lVariacion) .AND. lLoadTrabj

/*
      oRecibo:=Opentable("SELECT REC_CODTRA FROM NMRECIBOS "+;
                         "INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO"+;
                         " WHERE "+;
                         "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
                         "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
                         "FCH_TIPNOM"+GetWhere("=",LEFT(::cTipoNom,1))+" AND "+;
                         "FCH_OTRNOM"+GetWhere("=",::cOtraNom)+;
                         " GROUP BY REC_CODTRA ",.T.)

       ? oRecibo:Browse(),oDp:cSql

      AEVAL(oRecibo:aDataFill,{|a,n|AADD(::aCodTra,a[1])})
*/

      ::nRecibos:=LEN(::aCodTra)

      // oRecibo:End()

      IF ValType(::oMemo)="O"
        ::oMemo:Append("Recibos del Periodo "+LSTR(::nRecibos)+CRLF)
      ENDIF

   ENDIF

// ? "AQUI F"

   IIF( ::lVariacion .AND. ValType(::oMeter)="O", (::oMeter:Set(7),::oSayTrab:SetText("Procesando")),NIL)

   IF (!::lCompilado .AND. ::oLee:RecCount()>0) .OR. !lLoadTrabj

      IF ValType(::oMemo)="O"
        ::oMemo:Append("Compilando Conceptos "+CRLF)
      ENDIF

      ::Compila()

   ENDIF

   EJECUTAR("NMINICIAR",SELF)

   IF ValType(::oMemo)="O"
      ::oMemo:Append("Nómina Iniciada "+CRLF)
   ENDIF


RETURN .T.

/*
// Calcula un Sólo Trabajador
*/
METHOD Calcular() CLASS TNOMINA

   LOCAL cWhereCod,cWhereGru,cSql,cTotal,cCampos:="",cCodCon,cVar
   LOCAL nLen,nCon,nAjuste,nResult,nAt // : =ErrorSys(.T.)
   LOCAL lProcess:=.F.
   LOCAL oVariac,oScript
   LOCAL aData   :={},aVarName:={},cMemo:=""
   LOCAL lSaveCon:=.F.
   LOCAL nAtTrab :=ASCAN(::aCodTra,{|a|a==::oLee:CODIGO})


// ? "AQUI ES CALCULAR"

   ::lSaveRec:=.F.

   IF ValType(::oMemo)="O" .AND. ::lSysError
     ::oMemo:Append("Leyendo Código "+::oLee:CODIGO+CRLF)
   ENDIF

   IIF( ::lSysError, ErrorSys(.T.) ,NIL)

   IIF(::oMeter!=NIL,::oMeter:Set(::oLee:Recno()),NIL)

   IF (::lActualiza .OR. ::lPrenomina) .AND. nAtTrab!=0

      IF ValType(::oMemo)="O"
      // ::oMemo:Append("Código "+::oLee:CODIGO+CRLF+" No Aceptado en ::aCodTra"+CRLF)
      ENDIF

      RETURN .F.
   ENDIF

   cTotal :="["+GetNumRel(::oLee:Recno(),::oLee:RecCount())+"]"

   IIF(ValType(::oTrabajador)="O",::oTrabajador:End(),NIL)

   ::oTrabajador:=OPENTABLE("SELECT "+::cFields+" FROM NMTRABAJADOR WHERE CODIGO"+;
                  GetWhere("=",::oLee:CODIGO)+" LIMIT 1",.T.)


   IF ValType(::oSayTrab)="O"
      ::oSayTrab:SetText("Código "+::oLee:CODIGO)
   ENDIF

//   IF ValType(::oMemo)="O"
//      ::oMemo:Append("Código "+::oLee:CODIGO+CRLF)
//   ENDIF


   AEVAL(::oTrabajador:aFields,{|a,i|Publico(a[1],::oTrabajador:FieldGet(i))})

   //  AADD(::aBuffers,{uValue,ALLTRIM(UPPE(::aFields[I,1])),::aFields[I,2],::aFields[I,3]})

   PUBLICO("oTrabajador",::oTrabajador)

/*
   ? "       VAR_CODTRA"+GetWhere("=",ALLTRIM(::oTrabajador:CODIGO))
   ? "   AND VAR_DESDE "+GetWhere("=",::dDesde  )
   ? "   AND VAR_HASTA "+GetWhere("=",::dHasta  )
   ? "   AND VAR_TIPNOM"+GetWhere("=",::cTipoNom)
   ? "   AND VAR_OTRNOM"+GetWhere("=",::cOtraNom)
   ? !::lVariacion
*/

   oVariac:=OpenTable("SELECT VAR_CODCON,VAR_CANTID,VAR_OBSERV,VAR_AJUSTE FROM NMVARIAC WHERE "+;
                      "       VAR_CODTRA"+GetWhere("=",ALLTRIM(::oTrabajador:CODIGO))+;
                      "   AND VAR_DESDE "+GetWhere("=",::dDesde  )+;
                      "   AND VAR_HASTA "+GetWhere("=",::dHasta  )+;
                      "   AND VAR_TIPNOM"+GetWhere("=",::cTipoNom)+;
                      "   AND VAR_OTRNOM"+GetWhere("=",::cOtraNom),.T.) // !::lVariacion)

   //  lVariac:=(oVariac:RecCount()>0) // Verifica si Hay Variaciones
   ::aVariac:=ACLONE(oVariac:aDataFill) // aFillData


 // ViewArray(::aVariac)



//   IF "3095"$::oLee:CODIGO
//      ? LEN(::aVariac),oVariac:VAR_CANTID
//   ENDIF
   // ? LEN(::aVariac),oVariac:VAR_CANTID,::oTrabajador:CODIGO
   //? lVariac,oVariac:RecCount(),LEN(aVariac),oVariac:cSql

   oVariac:End()

   nCon:=0

   ::aPrenomina:={} // Prenómina por Trabajador
   ::aVarCon   :={}
   ::nAsigna   :=0
   ::nDeduccion:=0
   ::nPromedioA:=0
   ::nPromedioB:=0
   ::nPromedioC:=0
   ::nPromedioD:=0

   ::nBaseA:=0                  // Sólo Asignaciones y Deducc A
   ::nBaseB:=0                  // Sólo Asignaciones y Deducc B
   ::nBaseC:=0                  // Sólo Asignaciones y Deducc C
   ::nBaseD:=0                  // Sólo Asignaciones y Deducc D

   ::lTablaLiq :=.F.
   ::nDias     :=0  // Dias Trabajados

   ASIGNA   :=0
   DEDUCC   :=0
   ISR_ASIG :=0


   // Tabla de Vacaciones
   PUBLICO("oNm",SELF)
   EJECUTAR("NMJORNADAS_CAL",SELF)

   ::Link() // Estable las Relaciones de las Tablas


// ::lSysError:=.T.

   IIF( ::lSysError, ErrorSys(.T.) ,NIL)

   oDp:lNext:=.T. // Valor del Depurador

   AEVAL(::aClearCon,{|a|EVAL(a)}) // Inicia Todas las Variables

   WHILE nCon<LEN(::aConceptos) .AND. !::lCancelar // .AND. oDp:lNext

       nCon++

       VAROBSERV:=""
       cCodCon  :=::aConceptos[nCon,1]

       ::cCodCon:=cCodCon // Concepto en Proceso

       IF ::lSysError  .AND. ValType(::oMeter)="O"
         ::oMeter:oWnd:oWnd:SetText(cCodCon+" "+::oTrabajador:CODIGO)
         ::oMeter:oWnd:oWnd:Refresh(.t.)
       ENDIF

      IF ValType(::oMemo)="O"  .AND. ::lSysError
         ::oMemo:Append(cCodCon+" "+::oTrabajador:CODIGO+CRLF)
      ENDIF


       // ? ::oMeter:Classname()
       // ? ::cCodCon,"Calculando"

       IF LEFT(cCodCon,1)="F" .OR. ::aConceptos[nCon,2]=NIL // Funciones no se Procesan
          LOOP
       ENDIF

//       ? ::lActualiza,::lHistorico,Left(cCodCon,1) // Solo AyD

       IF !::lActualiza .AND. !::lHistorico .AND. Left(cCodCon,1)="H" // Solo AyD
          LOOP
       ENDIF

       ::cError:=""  // Error en las Funciones

       IIF(!::oForm=NIL,::oForm:SetMsg("Trabajador: "+::oLee:CODIGO+" ["+cCodCon+"] "+cTotal),NIL)

       // oDp:oFrameDp:SetText(cCodCon)

       // Resultado
       PUBLICO(cCodCon,0)      // Asigna Hacia la Variable del Concepto
       PUBLICO("C_"+cCodCon,0) // Emulaci+n DpNM24

       nResult:=0
       // VARIAC :=0
       // VAR1   :=0
       lVariac:=.F. // Indica si Cumple con la Condicion para ser Variacion
       nAjuste:=0

       // Lectura de Variaciones
       VAROBSERV   :="" // Línea1"+CRLF+"Línea2"+CRLF+"Línea3"+CRLF+"Línea4"
       VARMEMO     :="" // Memo
       VARIAC      :=0

//     IF (::aConceptos[nCon,11]) .AND. (nAt:=ASCAN(::aVariac,{|a,n|a[1]==cCodCon}),nAt>0) // lVariac
//     ? LEN(::aVariac),"::aVariac" // ,::aVariac[1,1]

       IF ((nAt:=ASCAN(::aVariac,{|a,n|a[1]==cCodCon}),nAt>0)) // lVariac

//? nAt,"AQUI BUSCA LA VARIACION"

          VARIAC      := ::aVariac[nAt,2] // oVariac:VAR_CANTID)   // Variaci¦n
          VAROBSERV   := ::aVariac[nAt,3] // oVariac:VAR_OBSERV
          nAjuste     := ::aVariac[nAt,4] // oVariac:VAR_AJUSTE

//        ? VARIAC,"VARIAC, SI EXISTE ",cCodCon

       ENDIF

       nFactor1:=0
       nFactor2:=0
       nFactor3:=0
       nFactor4:=0

       oScript:=::aConceptos[nCon,2]

       IF !::lModHrb
         oScript:cError:=""
       ENDIF

       IF (::lDebug .OR. ::aConceptos[nCon,12]) .AND. !::lModHrb
         oScript:bRun := {|oLine| DebugDlg(oLine,NIL,::aVar_Depu) } // Esta en FiveScr
       ENDIF

    // ? ErrorSys(.T.) ,cCodCon,"Concepto"

       IF ::lModHrb
         EVAL(::aConceptos[nCon,2])
       ELSE
         nResult:=oScript:Run() // Ejecuta los Par+metros
       ENDIF
       // nResult:=IIF( ValType(nResult)<>"C" , 0 ,nResult )

       IF nAt=0 .AND. !EMPTY(VARIAC) .OR. !EMPTY(VAROBSERV)
          AADD(::aVariac,{cCodCon,VARIAC,VAROBSERV,0})
       ENDIF

       if !::lModHrb .AND. !Empty(oScript:cError) .OR. !ValType(nResult)="N"

          AADD(::aErrors,"Concepto "+cCodCon+" "+oScript:cError)
          MensajeErr(oScript:cError,"Error, Concepto :"+::aConceptos[nCon,1])
          ::aConceptos[nCon,2]:=NIL
          nResult:=0

       ELSEIF (nAt:=ASCAN(::aVariac,{|a,n|a[1]==cCodCon}),nAt>0) // lVariac

          ::aVariac[nAt,2]:=VARIAC
          ::aVariac[nAt,3]:=VAROBSERV // oVariac:VAR_OBSERV

       ENDIF

       IF ::lVariacion

//        IF LEFT(cCodCon,1)="N"
//          ? ::aConceptos[nCon,09],"lVariacion",cCodCon,::oTrabajador:CODIGO
//        ENDIF

          ::aConceptos[nCon,09]:=VARIAC
          ::aConceptos[nCon,10]:=PADR(VAROBSERV,60)

          IF lVariac .AND. ::aConceptos[nCon,11]
            AADD(::aVarCon,cCodCon)
          ENDIF

          LOOP

       ENDIF

       IF Empty(::cError) // Error en Función
          AADD(::aErrors,::cError)
       ENDIF

       nResult:=REDONDEA(nResult*IIF(LEFT(cCodCon,1)="D",-1,1))

       IF nResult==0 // Sin Resultado, Valores Vacios no se Graban
         LOOP
       ENDIF

       // ACUMULA PROMEDIOS
       IF ASCAN(::aConceptosA,cCodCon)>0
          ::nPromedioA+=nResult
          ::nBaseA:=::nBaseA + IIF( Left(cCodCon,1)$"AD" , nResult  , 0 )
       ENDIF

       IF ASCAN(::aConceptosB,cCodCon)>0
          ::nPromedioB+=nResult
          ::nBaseB:=::nBaseB + IIF( Left(cCodCon,1)$"AD" , nResult  , 0 )
       ENDIF

       IF ASCAN(::aConceptosC,cCodCon)>0
          ::nPromedioC+=nResult
          ::nBaseC:=::nBaseC +  IIF( Left(cCodCon,1)$"AD" , nResult  , 0 )
       ENDIF

       IF ASCAN(::aConceptosD,cCodCon)>0
          ::nPromedioD+=nResult
          ::nBaseD:=::nBaseD +  IIF( Left(cCodCon,1)$"AD" , nResult  , 0 )
       ENDIF

       // Total Asignación y Deduccion
       ::nAsigna   :=::nAsigna   +IIF( LEFT(cCodCon,1)="A",nResult   ,0)
       ::nDeduccion:=::nDeduccion+IIF( LEFT(cCodCon,1)="D",nResult*-1,0)
       ::cCodigoIni:=IIF( Empty(::cCodigoIni),::oLee:CODIGO,::cCodigoIni )
       cVar:="C_"+Left(cCodCon,1)
       MOVER(MacroEje(cVar)+nResult,cVar)
       ASIGNA:=::nAsigna
       DEDUCC:=::nDeduccion

       // ? ::cCodigoIni,"::cCodigoIni"
       // EXIT
       // ? ::aConceptos[nCon,8],LEN(::aConceptos[nCon])

       ISR_ASIG+=IIF(::aConceptos[nCon,8],nResult,0)

       MOVER(nResult,cCodCon)      // Asigna Hacia la Variable del Concepto
       MOVER(nResult,"C_"+cCodCon) // Emulaci+n DpNM24

       ::nConceptos:=::nConceptos + IIF( Empty(nResult) , 0 , 1 )

       IF ::lArray  .AND. !nResult==0


//      ? ::lHistorico,"::lHistorico"

         AADD(::aTodos    ,{::oTrabajador:CODIGO,;
                            cCodCon,;
                            ::aConceptos[nCon,5],;
                            ::aConceptos[nCon,6],;
                            VARIAC,;
                            nResult,;
                            VAROBSERV,;
                            ALLTRIM(::oTrabajador:APELLIDO)+" "+ALLTRIM(::oTrabajador:NOMBRE),;
                            VARMEMO ,;
                            nFactor1,;
                            nFactor2,;
                            nFactor3,;
                            nFactor4})

         IF LEFT(cCodCon,1)<>"H" .OR. ::lHistorico .OR. .T. // JN 12/11/2020

                 AADD(::aPrenomina,{cCodCon,::aConceptos[nCon,5],;
                                ::aConceptos[nCon,6],VARIAC,nResult,nAjuste,VAROBSERV,::aConceptos[nCon,7]})

         ELSE

              nResult:=0

         ENDIF

       ENDIF

       // Visualizar el Trabajador
       IF ::lActualiza .AND. !::lSaveRec
//          ? "grabar recibo"
          ::SaveRecibo()
          ::lSaveRec:=.T. // Ya Guardó el Recibo
       ENDIF

       IF ::lActualiza .AND. ::lSaveRec // .AND. !lSaveCon
//           ? "grabar concepto"
           ::SaveConcepto(nResult,VARIAC)
           lSaveCon:=.T.
       ENDIF

       IF ::oMeter!=NIL .AND. !lProcess
          ::nProcess++
          IIF( ValType(::oSayTrab)="O",::oSayTrab:SetText(cTotal+" "+ALLTRIM(::oTrabajador:APELLIDO)+","+::oTrabajador:NOMBRE),NIL)
          lProcess:=.T.
       ENDIF

     ENDDO

     IF ValType(::oMemo)="O"  .AND. ::lSysError
        ::oMemo:Append(::oTrabajador:CODIGO+" Concluido")
     ENDIF

//     IF ::lActualiza .AND. ::lSaveRec
//       ::oRecibo:CommitSpeed(.T.)
//       ::oHistorico:CommitSpeed(.T.)
//     ENDIF

     IF ValType(oDp:oDlg)="O"
        oDp:oDlg:End()
        oDp:oDlg:=NIL
     ENDIF

     IF ValType(oNMTABLIQ)="O"
        MACROEJE("oNMTABLIQ:End()")
     ENDIF

//     ErrorSys(.t.)
//     ? "CALCULAR FIN"

     ::nSinSalario+=IIF( Empty(::oTrabajador:SALARIO) , 1 , 0 )

     IF ::lVariacion
        RETURN !EMPTY(::aVarCon)
     ENDIF

     IF ::lActualiza .AND. ::lSaveRec
        AADD(::aUpDateRecibo,{::cRecibo,::nAsigna-::nDeduccion,::oLee:CODIGO})
        ::Promedios()
        ::oHistorico:CommitSpeed(.t.)
        EJECUTAR("NMACTRUN",Self)
     ENDIF

     IIF(!::oForm=NIL .AND. !lProcess,;
          ::oForm:SetMsg("Trabajador: "+::oLee:CODIGO+" "+cTotal),NIL)

RETURN !EMPTY(::aPrenomina) // aPrenomina

/*
// Genera de Modo Publico Todas las Variables Creadas para los Conceptos
*/
METHOD IniVars(lCreate) CLASS TNOMINA

   IF EMPTY(::aListVar)
     ::aClearCon:={}
     ::aListVar:=ATABLE("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE LEFT(CON_CODIGO,1)<>'F'")
     AEVAL(::aListVar,{|a,cVar|cVar:="C_"+a+":=0",AADD(::aClearCon,BloqueCod(cVar)),PUBLICO("C_"+LEFT(a,1),0)})
   ENDIF

   DEFAULT lCreate:=.T.

   IF !lCreate
      AEVAL(::aListVar,{|cCon,i|__MVXRelease(cCon),__MVXRelease("C_"+cCon)}) // Borra las Variables
      __MVXRelease("oTrabajador")
      REST_VAR(::aVar_Trab,.T.) // Restaura las Variables, Anteriores
   ELSE
      AEVAL(::aListVar,{|cCon,i|PUBLICO("C_"+cCon,0)})
   ENDIF

RETURN NIL

/*
// Convierte Prenómina en Temporal
*/
METHOD CreateTempo(cTable,cTableM) CLASS TNOMINA

   LOCAL cSql,I,cLine,oTable
   LOCAL aFields:={},nContar:=0,nNumMem:=0,nError:=0
   LOCAL cAlias:=ALIAS()
   LOCAL cIndexM

   AADD(aFields,{"MEM_NUMERO","N",06,0})
   AADD(aFields,{"MEM_DESCRI","C",50,0})
   AADD(aFields,{"MEM_MEMO"  ,"M",10,0})
   AADD(aFields,{"MEM_FACTO1","N",16,2})
   AADD(aFields,{"MEM_FACTO2","N",16,2})
   AADD(aFields,{"MEM_FACTO3","N",16,2})
   AADD(aFields,{"MEM_FACTO4","N",16,2})

   DEFAULT cTable :="NMPRENOMINA"
   //DEFAULT cTable :="PRENOMINA"

   IF cTableM=NIL
      cTableM:=oDp:cPathCrp+"NMMEMO.DBF"
      cIndexM:=oDp:cPathCrp+"NMMEMO.CDX"
   //   WHILE FILE(oDp:cPathCrp+IIF(nContar=0, "" , strzero(nContar++,4))+cTableM+".DBF")
   //   ENDDO
   //   ? cTableM,"listo"
   ENDIF

   ferase(cIndexM)
   DBCREATE(cTableM,aFields,"DBFCDX")

   USE (cTableM) VIA "DBFCDX" EXCLU NEW
   INDEX ON FIELD->MEM_NUMERO TAG "NMMEMO1" TO (cIndexM)
   USE

   USE (cTableM) VIA "DBFCDX" EXCLU NEW
   SET INDEX TO (cIndexM)

   cTable:="NMPRENOMINA"

   cTable:=SQLCREATEMPO(cTable,"NMPRENOMINA")
   // MensajeErr(cTable,"Esta es la Nueva Tabla")
   SqlZap(cTable)

   // ? "AQUI TRATARA DE ABRIRLA"
   oTable:=OpenTable(cTable,.F.)
   // ? "AQUI DEBE EXISTIR",cTable
   // oTable:SetInsert(100)

   IF oTable:MsgError("Proceso PreNómina")
      oTable:End()
      RETURN .F.
   ENDIF

//   IF oTable:cType$"ADS,DBF"
//      MsgAlert("ADS REQUIERE OTRO MODELO")
//      USE
//      USE (cTable) VIA "DBFCDX" EXCLU NEW SHARED
//   ENDIF

//   cSql   := "INSERT INTO " + cTable + " (HIS_CODTRA,HIS_CODCON,HIS_VARIAC,HIS_NUMMEM,HIS_MONTO) VALUES "
   nContar:= 0
   nNumMem:= 0

   oTable:SetInsert(::aTodos)

   FOR I=1 TO LEN(::aTodos)

      nNumMem:=0

      IF !Empty(::aTodos[I,07]) .OR. !Empty(::aTodos[I,09]) .OR.;
         !Empty(::aTodos[I,10]) .OR. !Empty(::aTodos[I,11]) .OR.;
         !Empty(::aTodos[I,12]) .OR. !Empty(::aTodos[I,13])

         nContar++
         nNumMem:=nContar

         APPEND BLANK

         REPLA MEM_NUMERO WITH nContar,;
               MEM_DESCRI WITH ::aTodos[I,07],;
               MEM_MEMO   WITH ::aTodos[I,09],;
               MEM_FACTO1 WITH ::aTodos[I,10],;
               MEM_FACTO2 WITH ::aTodos[I,11],;
               MEM_FACTO3 WITH ::aTodos[I,12],;
               MEM_FACTO4 WITH ::aTodos[I,13]

      ENDIF

      oTable:AppendBlank()

      oTable:ReplaceSpeed("HIS_CODTRA" , ::aTodos[I,1] )
      oTable:ReplaceSpeed("HIS_CODCON" , ::aTodos[I,2] )
      oTable:ReplaceSpeed("HIS_VARIAC" , ::aTodos[I,5] )
      oTable:ReplaceSpeed("HIS_NUMMEM" , nNumMem)
      oTable:ReplaceSpeed("HIS_MONTO"  , ::aTodos[I,06])
      oTable:ReplaceSpeed("HIS_MEMO"   , ::aTodos[I,09])
      oTable:ReplaceSpeed("HIS_CODSUC" , ::cCodSuc )
      oTable:CommitSpeed(.F.)

/*      cLine:=CTOSQL(ALLTRIM(::aTodos[I,1]))+","+;
             CTOSQL(::aTodos[I,2])+","+;
             CTOSQL(::aTodos[I,5])+","+;
             CTOSQL(nNumMem)      +","+;
             CTOSQL(::aTodos[I,6])

      IF oTable:cType$"ADS,DBF"

        IF !oTable:oOdbc:Execute(cSql+"("+cLine+")")
           nError++
        Endif

      ELSE

         cSql:=cSql+IIF(I=1,"",",")+"("+cLine+")"

      ENDIF
  */
   NEXT I

//   If !oTable:cType$"ADS,DBF" .AND. !oTable:oOdbc:Execute(cSql)
//      MensajeErr("Error en Temporal",cSql)
//   EndIf

   USE

   DPSELECT(cAlias)

   oTable:End()

RETURN .T.
// EOF
/*
// Ejecuta los enlaces con las tablas relacionadas
*/
METHOD Link()
   LOCAL I,cSql,oTable,nPos,cTable,nAt,cVar
/*
   nAt:=ASCAN(::aLink,{|a,n|a[1]="NMTABVAC".OR.a[1]="NMTABLIQ"})

   IF nAt>0
      ADEL(::aLink,nAT)
      ASIZE(::aLink,LEN(::aLink)-1)
   ENDIF
*/
   FOR I := 1 TO LEN(::aLink)

       cVar:="O"+::aLink[I,1]

       IF TYPE(cVar)="O"
         MacroEje(cVar+":End()")
       ENDIF

       cSql:="SELECT * FROM "+::aLink[I,1]+" WHERE "+::aLink[I,2]+;
              GetWhere("=",::oTrabajador:Get(::aLink[I,3]))

       oTable:=OpenTable(cSql,.T.)
       PUBLICO(ALLTRIM("O"+::aLink[I,1]),oTable)
//       AADD(::aLink[I],oTable)

   NEXT I

RETURN .T.


/*
// Carga y Compila Todos los Conceptos de Pago Seg+n el Tipo de N+mina
*/
METHOD Compila() CLASS TNOMINA
   LOCAL oConcepto,cSql,cMemo,oScript,i,cWhere,cCampo,aClasifica:={},aLink:={},nAt
   LOCAL aCampos   :={"CON_SEMANA","CON_QUINCE","CON_MENSUA","CON_OTRA","CON_CATORC"}
   LOCAL oTable    :=OpenTable("SELECT * FROM NMTRABAJADOR",.F.),oLink
   LOCAL aFields   :={}
   LOCAL cComp

//? ValType(::aListCon),"::aListCon"

   ::aConceptosErr:={}

   oLink:= OpenTable("SELECT LNK_TABLES,LNK_FIELDS,LNK_FIELDD FROM DPLINK WHERE (LNK_TABLED='NMTRABAJADOR'"+;
                     " AND LNK_REFERE='') OR (LNK_TABLES='NMTABLIQ' OR LNK_TABLES='NMTABVAC')",.T.)

// oLink:Browse()

   WHILE !oLink:Eof()

// ?  oLink:LNK_TABLES,oLink:LNK_FIELDS,oLink:LNK_FIELDD,"oLink:LNK_TABLES,oLink:LNK_FIELDS,oLink:LNK_FIELDD"

      AADD(aLink,{ALLTRIM(UPPE(oLink:LNK_TABLES)),ALLTRIM(oLink:LNK_FIELDS),ALLTRIM(oLink:LNK_FIELDD)})
      oLink:skip(1)
   ENDDO

   oLink:End()

// ViewArray(aLink)

   AEVAL(oTable:aFields,{|a|AADD(aFields,a[1])})

// ViewArray(aFields)

   oTable:End()

   i            :=AT(::cTipoNom,"SQMOC")

// ? i,"debe ser mayor que cero",::cTipoNom

   IF I=0
      MensajeErr("Necesario definir el Tipo de Nómina","Valor de ::cTipoNom "+CTOO(::cTipoNom,"C"))
      RETURN .F.
   ENDIF

   cCampo       :=" WHERE "+aCampos[i]+"=1 AND CON_ACTIVO=1"

// ? cCampo,"cCampo"

   IF !EMPTY(::aListCon)
     cCampo:=cCampo+" AND ("+GetWhereOr("CON_CODIGO",::aListCon)+")"
     // ? cCampo,"cCampo"
   ENDIF

// ? cCampo,"cCampo"
//   IF ::lVariacion
      //  cCampo+=" AND CON_MENSAJ<>'' OR LEFT(CON_CODIGO,1)>'F'" // Sin Mensaje de Variacion
      // cCampo+="LEFT(CON_CODIGO,1)<'H'" // Sin Mensaje de Variacion
//   ENDIF
// ::oConcepto :={}

   ::aConceptosA :={}
   ::aConceptosB :={}
   ::aConceptosC :={}
   ::aConceptosD :={}
   ::cFields     :=",CODIGO,APELLIDO,NOMBRE,FECHA_ING,FECHA_EGR,FECHA_VAC,FECHA_CON,FECHA_FIN,TURNO,COD_DPTO,BANCO,GRUPO,COD_UND"  // Campos Válidos del Trabajador

   // ::aConceptosErr:={}

   IF ::lActualiza
     ::cFields   +=",FORMA_PAG"  // Campos Válidos del Trabajador
   ENDIF

 // ? ::cFields,"::cFields"
// ? cCampo,"cCampo"

   cSql:="SELECT CON_CODIGO,CON_DESCRI,CON_FORMUL,CON_REPRES,CON_MENSAJ,CON_ISLR,CON_DEPURA "+;
         "FROM NMCONCEPTOS "+cCampo +" ORDER BY CON_CODIGO"

// ? CLPCOPY(cSql)

// IIF( !::lVariacion,",CON_ACUM01,CON_ACUM02,CON_ACUM03,CON_ACUM04 ", " ")+;
// ErrorSys(.T.)

   oConcepto:=OPENTABLE(cSql,.T.)

// ? "AQUI EMPEZARA A LEER CONCEPTOS",oConcepto:RecCount()

   WHILE !oConcepto:Eof()

      IF ValType(::oSayTrab)="O"
        ::oSayTrab:SetText("Compilando: "+oConcepto:CON_CODIGO)
      ENDIF

      oDp:cCodCon:=oConcepto:CON_CODIGO

      cMemo :=STRSQLOFF(ALLTRIM(oConcepto:CON_FORMUL))
      cComp :=UPPE(cMemo)

      IF LEFT(oConcepto:CON_CODIGO,1)!="F"
        AADD(::aVar_Depu,{"Result","C_"+oConcepto:CON_CODIGO })
      ENDIF

      FOR I := 1 TO LEN(aFields)
         IF I>0 .AND. aFields[I]$cComp .AND. !(","+aFields[I])$::cFields
            ::cFields+=","+aFields[I]
            ADEL(aFields,I)
            ASIZE(aFields,Len(aFields)-1)
            I:=1
            LOOP
         ENDIF
      NEXT

      FOR I := 1 TO LEN(aLink)
         IF "O"+aLink[I,1]+":"$cComp
            AADD(::aLink,aLink[I])
            IF !(","+aLink[I,3])$::cFields
               ::cFields+=","+aLink[I,3]
            ENDIF
            ADEL(aLink,I)
            ASIZE(aLink,Len(aLink)-1)
            I:=1
         ENDIF
      NEXT I

//    IF !::lVariacion .AND. oConcepto:CON_ACUM01
//      AADD(::aConceptosA,oConcepto:CON_CODIGO)
//    ENDIF

//    IF !::lVariacion .AND. oConcepto:CON_ACUM02
//      AADD(::aConceptosB,oConcepto:CON_CODIGO)
//    ENDIF

//    IF !::lVariacion .AND. oConcepto:CON_ACUM03
//      AADD(::aConceptosC,oConcepto:CON_CODIGO)
//    ENDIF

//    IF !::lVariacion .AND. oConcepto:CON_ACUM04
//      AADD(::aConceptosD,oConcepto:CON_CODIGO)
//    ENDIF

      // Pueden ser Ejecutados HRB y Script


      IF !::lModHrb .OR. oConcepto:CON_DEPURA

// ? "ANTES DE COMPILAR",cMemo,ErrorSys(.T.)

        oScript:=TScript():New(cMemo)
        oScript:cProgram:=oConcepto:CON_CODIGO
        oScript:Compile(NIL,.F.)

        IF !Empty(oScript:cError)
           ? "Error Compilación",oScript:cError,oScript:cProgram
           AADD(::aConceptosErr,{oConcepto:CON_CODIGO,oScript:cError})
        ENDIF

        // Nombre del Programa
        // ? oScript:ClassName(),oScript:cError,CLPCOPY(cMemo)

      ELSE
        oScript:=BLOQUECOD(""+oConcepto:CON_CODIGO+"_"+oDp:cCodEmp+"()")
        HRBLOAD("C_"+oConcepto:CON_CODIGO+"_"+oDp:cCodEmp+".HRB")
        oDp:Set("lHrbLoad"+oDp:cCodEmp,.T.)  // Inidca que los Módulos HRB ya estan en Memoria
      ENDIF

      AADD(::aConceptos,{UPPE(ALLTRIM(oConcepto:CON_CODIGO)),;
                         oScript,;
                         "C_"+oConcepto:CON_CODIGO,;
                         aClasifica,;
                         oConcepto:CON_DESCRI,;
                         oConcepto:CON_REPRES,;
                         oConcepto:CON_MENSAJ,;
                         oConcepto:CON_ISLR,;
                         0,;
                         0,;
                         !EMPTY(oConcepto:CON_MENSAJ),;
                         oConcepto:CON_DEPURA})

//    IF oConcepto:CON_NORMAL // Conceptos
//       AADD(::aConceptosA,oConcepto:CON_CODIGO)                         // Conceptos (Sueldo Normal)
//    ENDIF

//    IF oConcepto:CON_PRESTA
//       AADD(::aConceptosB,oConcepto:CON_CODIGO)                        // Conceptos que Afecta Prestaciones
//    ENDIF

      oConcepto:DbSkip()

   ENDDO

// ? "COMPILA Z",ErrorSys(.T.)

   EJECUTAR("NMWHERECON")

   ::aConceptosA:=oDp:aConceptosA // AaTable("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_ACUM01=1")
   ::aConceptosB:=oDp:aConceptosB //aTable("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_ACUM02=1")
   ::aConceptosC:=oDp:aConceptosC //aTable("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_ACUM03=1")
   ::aConceptosD:=oDp:aConceptosD //aTable("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_ACUM04=1")

   ::cFields   :=Subs(::cFields,2,LEN(::cFields))

   // Necesario para Utiliza la Reconstrucción NMRECSALARIO
   /*
   oDp:cConceptosA:=::aConceptosA
   oDp:cConceptosB:=::aConceptosB
   oDp:cConceptosC:=::aConceptosC
   oDp:cConceptosD:=::aConceptosD
   */
   oConcepto:End()

//   EJECUTAR("NMCALACUMT",Self) // Calcula Acumulados por Concepto

   // Debe Leer CON_NORMAL
/*
   oConcepto:=OpenTable("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_NORMAL=1 ORDER BY CON_CODIGO",.T.)

   AEVAL(oConcepto:aDataFill,{|a,i|AADD(::aConceptosA,a[1])})

   oConcepto:End()

   // Debe Leer CON_PRESTA
   oConcepto:=OpenTable("SELECT CON_CODIGO FROM NMCONCEPTOS WHERE CON_PRESTA=1 ORDER BY CON_CODIGO",.T.)
   //  ::aConceptosB:=ACLONE(oConcepto:aDataFill)
   AEVAL(oConcepto:aDataFill,{|a,i|AADD(::aConceptosB,a[1])})
   oConcepto:End()
*/
//   ? SECONDS()-T1
   /*
   // Quita las tablas que usa, la funcion tablavac
   */

   nAt:=ASCAN(::aLink,{|a,n|a[1]="NMTABVAC"})

   IF nAt>0
      ADEL(::aLink,nAT)
      ASIZE(::aLink,LEN(::aLink)-1)
   ENDIF

   nAt:=ASCAN(::aLink,{|a,n|a[1]="NMTABLIQ"})

   IF nAt>0
      ADEL(::aLink,nAT)
      ASIZE(::aLink,LEN(::aLink)-1)
   ENDIF

RETURN .T.

/*
// Lee los Dias Feriados
*/
METHOD Feriados() CLASS TNOMINA

   LOCAL oTable,aFecha:={}

   ::cCalendar:="" // Lista del Calendario

   oTable:=OPENTABLE("SELECT CAN_DIA,CAN_MES FROM NMFERIADOS",.T.)
   oTable:GoTop()

   WHILE !oTable:EOF()
      ::cCalendar+=IIF(EMPTY(::cCalendar),"",".")+oTable:CAN_DIA+"/"+oTable:CAN_MES
      oTable:DbSkip()
   ENDDO
   oTable:End()

   IF oDp:lPascua

      aFecha:={MacroEje("Carnaval()"   ),;
               MacroEje("Carnaval()+1" ),;
               MacroEje("SemanaSanta()"),;
               MacroEje("SemanaSanta()+1")}

      Aeval(aFecha,{|dFecha,n,cDia,cMes|cDia:=STRZERO(Day(dFecha)  ,2),;
                                        cMes:=STRZERO(Month(dFecha),2),;
                                        ::cCalendar+=IIF(EMPTY(::cCalendar),"",".")+cDia+"/"+cMes})

   ENDIF

RETURN NIL

/*
// Carga y Prepara las Jornadas de Trabajo
// Por defecto la Jornada de Trabajo est+ Asociada al Tipo de N+mina
*/
METHOD JORNADAS() CLASS TNOMINA
      LOCAL aDia   :=ARRAY(4),aSemana,aTiempo:={}
      LOCAL oTable,I,nLen
      LOCAL cLunes :="AP",cMartes :="AP",cMiercoles:="AP",cJueves:="AP",cViernes:="AP"
      LOCAL cSabado:="AP",cDomingo:="AP"

      oTable:=OpenTable("SELECT JOR_CODIGO,;
                                JOR_DOAM,JOR_DOPM,;
                                JOR_LUAM,JOR_LUPM,;
                                JOR_MAAM,JOR_MAPM,;
                                JOR_MIAM,JOR_MIPM,;
                                JOR_JUAM,JOR_JUPM,;
                                JOR_VIAM,JOR_VIPM,;
                                JOR_SAAM,JOR_SAPM FROM NMJORNADAS",.T.)
      oTable:GoTop()

// oTable:Browse()

      ::aJornadas:={}

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

//        ? oTable:JOR_CODIGO,aTiempo[1],aTiempo[2],aTiempo[3],aTiempo[4],aTiempo[5],aTiempo[6],aTiempo[7],;
//          aSemana[1],aSemana[2],aSemana[3],aSemana[4],aSemana[5],aSemana[6],aSemana[7]

          AADD(::aJornadas,{ALLTRIM(oTable:JOR_CODIGO),aTiempo,aSemana})

          oTable:Skip(1)

      ENDDO

      oTable:End()


RETURN NIL

/*
// Genera las Constantes para las Ecuaciones
*/
METHOD CONSTANTES() CLASS TNOMINA
    LOCAL oTable,I,uValue:=0

    oTable:=OpenTable("SELECT CNS_CODIGO,CNS_VALOR,CNS_TIPO FROM NMCONSTANTES",.T.)

    ::aConstantes:={}

    WHILE !oTable:Eof()

       DO CASE

           Case oTable:CNS_TIPO="N"
              uValue:=VAL(oTable:CNS_VALOR)

           Case oTable:CNS_TIPO$"DF" // Fecha
              uValue:=EVAL(oDp:bFecha,ALLTRIM(oTable:CNS_VALOR))

           Case oTable:CNS_TIPO$"L" // Fecha
              uValue:=UPPE(ALLTRIM(oTable:CNS_VALOR))=".T."

           OTHER

             uValue:=CTOO(oTable:CNS_VALOR,oTable:CNS_TIPO)

       ENDCASE

       AADD(::aConstantes,{oTable:CNS_CODIGO,uValue})
       oTable:Dbskip()

    ENDDO

    oTable:End()

RETURN NIL

/*
// Guardar Conceptos
*/
METHOD SaveConcepto(nMonto,nVariac) CLASS TNOMINA
    LOCAL nNumObs:=0,nNumMemo:=0

    ::oHistorico:Append()
    ::oHistorico:lAppend:=.T.
    ::oHistorico:ReplaceSpeed("HIS_CODCON" ,::cCodCon)
    ::oHistorico:ReplaceSpeed("HIS_NUMREC" ,::cRecibo)
//  ? "AQUI TIENE QUE SER HIS_CODTRA"
//  ::oHistorico:ReplaceSpeed("HIS_CODTRA" ,::oTrabajador:CODIGO)
//  ::oHistorico:ReplaceSpeed("HIS_DESDE"  ,::dDesde  )
//  ::oHistorico:ReplaceSpeed("HIS_HASTA"  ,::dHasta  )
//  ::oHistorico:ReplaceSpeed("HIS_TIPONM" ,::cTipoNom)
//  ::oHistorico:ReplaceSpeed("HIS_OTRANM" ,::cOtraNom)
    ::oHistorico:ReplaceSpeed("HIS_MONTO"  ,nMonto    )
    ::oHistorico:ReplaceSpeed("HIS_VARIAC" ,nVariac   )
    ::oHistorico:ReplaceSpeed("HIS_CODSUC" ,::cCodSuc )

    // Grabar Comentarios de la Observación
    // ? nFactor1

    IF !Empty(VAROBSERV) .OR. !Empty(nFactor1) .OR. !Empty(nFactor2) .OR. !Empty(nFactor3) .OR. !Empty(nFactor4)

      // ? "grabar nfactor1"

      ::GetNumObs()
      nNumObs:=::nNumObs

      ::oObserv:Append()
      ::oObserv:ReplaceSpeed("OBS_NUMERO",nNumObs   )
      ::oObserv:ReplaceSpeed("OBS_FACTO1",nFactor1  )
      ::oObserv:ReplaceSpeed("OBS_FACTO2",nFactor2  )
      ::oObserv:ReplaceSpeed("OBS_FACTO3",nFactor3  )
      ::oObserv:ReplaceSpeed("OBS_FACTO4",nFactor4  )
      ::oObserv:ReplaceSpeed("OBS_OBSERV",VAROBSERV )
      ::oObserv:ReplaceSpeed("OBS_CODSUC",::cCodSuc )


    ENDIF

    IF !Empty(VARMEMO)
      nNumMemo:=::SaveMemo(VARMEMO)
    ENDIF

    ::oHistorico:ReplaceSpeed("HIS_NUMOBS" ,nNumObs )
    ::oHistorico:ReplaceSpeed("HIS_NUMMEM" ,nNumMemo)

    IF !Empty(nNumObs)
       ::oHistorico:CommitSpeed(.F.) // la integridad ref, lo requiere
       ::oHistorico:SaveSpeed() // la integridad ref, lo requiere
       ::oObserv:CommitSpeed(.F.)
       ::oObserv:SaveSpeed()

    ELSE
       ::oHistorico:CommitSpeed(.F.) // la integridad ref, lo requiere
    ENDIF

RETURN .T.

/*
// Salvar Conceptos de Nómina, Solo sera utilizado en las Funciones que requiren leer históricos
// Si alguna funcion requiere leer el histórico esta debe se vaciada
*/
METHOD CommitHistorico() CLASS TNOMINA
/*
   IF !::lActualiza .OR. .T.
      RETURN .F.
   ENDIF

//   ? ::lSaveRec,"::lSaveRec" , ::cRecibo

   IF !::lSaveRec
     ::SaveRecibo()
     ::lSaveRec:=.T. // Ya Guardó el Recibo
  //   ? "debe grabar los registros"
   ENDIF

   IF ::oHistorico:nCountIns>0
      ::oHistorico:CommitSpeed(.T.)
    //  ? "debe cerrar commitSpeed"
   ELSE
      ::oHistorico:Commit()
    //  ? "debe cerrar commit"
   ENDIF

   // ? "actualizar"
*/
RETURN .T.

/*
// Guarda el Recibo
*/
METHOD SaveRecibo() CLASS TNOMINA

  LOCAL oRecibo

  IF EMPTY(::cRecibo)
     ::GetRecibo()
  ELSE
     ::cRecibo:=STRZERO(VAL(::cRecibo)+1,::nLenRec)
//? ::cRecibo,"INCREMENTAL","GETPROCE,SAVERECIBO"
  ENDIF

  WHILE !::lOptimiza // .T. 02/09/2021

    // COUNT(cTable,cWhere,oDb)>0
    IF COUNT("NMRECIBOS","REC_CODSUC"+GetWhere("=",::cCodSuc)+" AND REC_NUMERO"+GetWhere("=",::cRecibo))>0
      //oRecibo:=OpenTable("SELECT REC_NUMERO FROM NMRECIBOS WHERE REC_CODSUC"+GetWhere("=",::cCodSuc)+" AND REC_NUMERO"+GetWhere("=",::cRecibo),.T.)
      // IF oRecibo:RecCount()>0 // ya Existe
      //oRecibo:End()
      ::GetRecibo()
      LOOP
    ENDIF
    // oRecibo:End()
    EXIT

  ENDDO

  IF EMPTY(::cFchNumero) .AND. ::lActualiza

     ::UpDateFecha(.T.)

  ENDIF

//ErrorSys(.T.)

  IF ::oRecibo=NIL
    ::oRecibo:=OpenTable("SELECT * FROM NMRECIBOS",.F.)
  ENDIF

  ::oRecibo:Append()
  ::oRecibo:Replace("REC_NUMERO" ,::cRecibo )
  ::oRecibo:Replace("REC_CODTRA" ,::oTrabajador:CODIGO   )
  ::oRecibo:Replace("REC_CODSUC" ,::cCodSuc              )
  ::oRecibo:Replace("REC_CODDEP" ,::oTrabajador:COD_DPTO )
  ::oRecibo:Replace("REC_CODUND" ,::oTrabajador:COD_UND  )
  ::oRecibo:Replace("REC_CODGRU" ,::oTrabajador:GRUPO    )
  ::oRecibo:Replace("REC_CODBCO" ,::oTrabajador:BANCO)
//oRecibo:Replace("REC_DESDE"  ,::dDesde  )
//oRecibo:Replace("REC_HASTA"  ,::dHasta  )
  ::oRecibo:Replace("REC_FECHAS" ,oDp:dFecha)
  ::oRecibo:Replace("REC_FCHCHQ" ,oDp:dFecha) // Fecha del Cheque
//oRecibo:Replace("REC_TIPNOM" ,::cTipoNom)
//oRecibo:Replace("REC_OTRANM" ,::cOtraNom)
  ::oRecibo:Replace("REC_USUARI" ,oDp:cUsuario)
  ::oRecibo:Replace("REC_FORMAP" ,::oTrabajador:FORMA_PAG)
  ::oRecibo:Replace("REC_CONTAB" ,"N")
  ::oRecibo:Replace("REC_INTEGR" ,"N")
  ::oRecibo:Replace("REC_NUMFCH" ,::cFchNumero)
  ::oRecibo:Replace("REC_CODMON" ,::cCodMon   )



// ? ::cCodSuc ,"CODIGO DE SUCURSAL"

  // Falta Asignación, Deducción
   ::oRecibo:Commit() //,"GRABO ALGO" // Integridad Ref Requiere .T.
//  ? "PRIMERO PASA POR AQUI",::cRecibo
  IF !::lOptimiza
    ::oRecibo:End()
    ::oRecibo:=NIL
  ENDIF

// ? ::lOptimiza,"::lOptimiza",oDp:cSql

  ::lSaveRec:=.T. // Ya Guardó el Recibo

 //  ? oDp:dFecha,"fecha del Recibo"

RETURN NIL
/*
// Determina el Número del Recibo
*/
METHOD GetRecibo() CLASS TNOMINA

   LOCAL oRecibo

   IF !::lOptimiza // No Optimiza
      ::cRecibo:=""
   Endif

   IF ::lActualiza .AND. Empty(::cRecibo)
/*
      IF .F.

//        ::cRecibo:=SQLGETMAX("NMRECIBOS","REC_NUMERO")


      ELSE
*/

        ::cRecibo:=SQLGETMAX("NMRECIBOS","REC_NUMERO","REC_CODSUC"+GetWhere("=",::cCodSuc))

        // ::cRecibo:=SQLINCREMENTAL("NMRECIBOS","REC_NUMERO","REC_CODSUC"+GetWhere("=",::cCodSuc))

        IF Empty(::cRecibo)
          ::cRecibo:=STRZERO(1,7)
        ENDIF
//      ENDIF

   ENDIF

   IF ::lActualiza // !Empty(::cRecibo)
      //? ::cRecibo,"RECIBO",GETPROCE()
      ::cRecibo:=StrZero(Val(::cRecibo)+1,::nLenRec)
   ENDIF

RETURN NIL

/*
// Determina el Número de Observación
*/
METHOD SaveMemo(cMemo) CLASS TNOMINA
   LOCAL nNumMemo:=0,oMemo

   oMemo:=OpenTable("SELECT MAX(MEM_NUMERO) FROM NMMEMO",.T.)
   nNumMemo:=oMemo:FieldGet(1)+1
   oMemo:End()
   oMemo:=OpenTable("SELECT * FROM NMMEMO",.F.)
   oMemo:Append()
   oMemo:Replace("MEM_MEMO" ,cMemo    )
   oMemo:Replace("MEM_NUMERO",nNumMemo)
   oMemo:Commit()
   oMemo:End()

RETURN nNumMemo


/*
// Determina el Número de Observación
*/
METHOD GetNumObs() CLASS TNOMINA

   LOCAL oObserv

//   IF !::lOptimiza // No Optimiza
      ::nNumObs:=0
//   Endif

   IF ::lActualiza .AND. Empty(::nNumObs)
      oObserv:=OpenTable("SELECT MAX(OBS_NUMERO) FROM NMOBSERV",.T.)
      ::nNumObs:=oObserv:FieldGet(1)
      oObserv:End()
   ENDIF

   IF ::lActualiza // !Empty(::cRecibo)
      ::nNumObs:=::nNumObs+1
   ENDIF

RETURN NIL

METHOD GetRepProc() CLASS TNOMINA
  LOCAL cError:=""
  LOCAL cText :="Grupo: "+IIF( Empty(::cGrupoIni), "Ninguno ",CTOSQL(::cGrupoIni)+" - "+CTOSQL(::cGrupoFin))+CRLF+;
                             "Recibos Existentes: "+LSTR(::nRecibos) +CRLF+;
                             "Tipo Nómina : "+::cTipoNom                  +CRLF+;
                             "otra Nómina : "+::cOtraNom                  +CRLF+;
                             "Sin Salario : "+LSTR(::nSinSalario)         +CRLF+;
                             IF(ValType(::oLee)="O","Trabajadores: "+LSTR(::oLee:RecCount())+CRLF,"")+;
                             "Conceptos   : "+LSTR(LEN(::aConceptos ))

  AEVAL(::aConceptosErr,{|a,n| cError:=cError+IF(Empty(cError),"",CRLF)+"Concepto:"+a[1]+" "+a[2]})

  cText:=cText+IF(Empty(cError),"",CRLF+cError)

RETURN cText


/*
 *  OnError()
*/
METHOD OnError( uValue,nError,nPar3,nPar4,nPar5,nPar6,nPar7,nPar8,nPar9,nPar10,nPar11 ) CLASS TNOMINA
  LOCAL cErrorLog,cMsg,lScript:=.F.,cError:=GETPROCE()
  LOCAL lResp:=.F.

  cMsg   := ALLTRIM(UPPE(__GetMessage()))

  if Left( cMsg, 1 ) == "_" // Asignar Valor

      cMsg:=Subs(cMsg,2,Len(cMsg))

      __objAddData( Self, cMsg )
      oSend(Self ,cMsg , uValue)

      RETURN NIL

   ENDIF

   IF !ValType(::oScript)="O" .OR. !::oScript:IsFunction(cMsg)
      MensajeErr("Requiere Compilar "+::oScript:cProgram+CRLF+"Funcion "+cMsg,GetProce())
      RETURN NIL
   ENDIF

   lScript:=::oScript:IsFunction(cMsg)

   IF !lScript
      MensajeErr("Funcion "+cMsg+" no Existe en "+::cScript )
      RETURN SELF
   ENDIF

   ::oScript:lNoError:=!::lMsgError
   lResp:=::oScript:Run(cMsg,uValue,nError,nPar3,nPar4,nPar5,nPar6,nPar7,nPar8,nPar9,nPar10,nPar11)

   IF !Empty(::oScript:cError) .AND. ::lMsgError
      MensajeErr(::oScript:cError,"Programa: "+::cScript+CRLF+"Function: "+cMsg+CRLF+cError)
   ENDIF

RETURN lResp


METHOD End() CLASS TNOMINA
   LOCAL I

   FOR I := 1 TO LEN(::aConceptos) // Borra Todas los Conceptos
      IIF(ValType(::aConceptos[I,2])="O",(::aConceptos[I,2]:End(),::aConceptos[I,2]:=NIL),NIL)
   NEXT

   AEVAL(::aLink,{|a,n,cVar|cVar:="O"+a[1],IIF( TYPE(cVar)="O",(MacroEje(cVar+":End()"),__MXRELEASE(cVar)),NIL)})

//  JN 21/08/2013
//   ::aLink     :={}
//   ::aConceptos:={}
//   ::aCodTra   :={}

   IF TYPE("oNMTABVAC")="O"
      oNMTABVAC:End()
   ENDIF

   IF TYPE("oNMTABLIQ")="O"
      oNMTABLIQ:End()
   ENDIF

   oNMTABVAC:=NIL
   oNMTABLIQ:=NIL

   IIF( ValType(::oLee)       ="O" , ::oLee:End()          , NIL)
   IIF( Valtype(::oTrabajador)="O" , ::oTrabajador:End()   , NIL)

   IIF( ValType(::oTable)     ="O" , ::oTable:End()        , NIL)
   IIF( ValType(::oTableObs)  ="O" , ::oTableObs:End()     , NIL)

   ::aClearCon:={}

RETURN NIL //  ::Super:End()

/*
// Actualiza los Valores de los Pagos
*/
METHOD UpDateRecibo() CLASS TNOMINA
     LOCAL cSql,I,T1:=SECONDS(),cSqlAll:=""
     LOCAL oOdbc
     LOCAL oTable

     IF !::lActualiza
        Return .F.
     ENDIF

     oTable:=OpenTable("SELECT REC_NUMERO FROM NMRECIBOS ",.F.)
     oOdbc:=oTable:oOdbc
     oTable:End()

     ::aCodTra:={}
/*
     FOR I := 1 TO LEN(::aUpDateRecibo)

        cSql:="UPDATE NMRECIBOS  SET REC_MONTO"+GetWhere("=",::aUpDateRecibo[I,2])+"  WHERE "+;
              "REC_NUMERO"+GetWhere("=",::aUpDateRecibo[I,1])

        AADD(::aCodTra,::aUpDateRecibo[I,3]) // Trabajadores Válidos

        IF !oOdbc:Execute(cSql)
           MensajeErr(cSql,"Errror:Actualizando Recibos ")
        ENDIF

     NEXT
  */
     ::aUpDateRecibo:={}
     Memory(-1)
     oOdbc:=NIL

RETURN .T.

/*
// Actualizar Fecha
*/
METHOD UpDateFecha(lStart) CLASS TNOMINA
   LOCAL oFecha,oRecibos
   LOCAL cEstado :="P"
   LOCAL nRecibos:=0

   DEFAULT lStart:=.F. // Indica que la Nómina Inicio

   IF ::lActualiza

      cEstado:=IIF( ::lTodos,"P","I")  // Procesada o iniciada

   ELSE

      oRecibos:=OpenTable("SELECT COUNT(*) FROM NMRECIBOS "+;
                          " INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
                          " WHERE "+;
                          "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
                          "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
                          "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
                          "FCH_OTRNOM"+GetWhere("=",::cOtraNom),.T.)

      nRecibos:=oRecibos:FieldGet(1)
      oRecibos:End()

      cEstado:="R"

   ENDIF

   oFecha:=OpenTable("SELECT * FROM NMFECHAS WHERE "+;
                     "FCH_CODSUC"+GetWhere("=",::cCodSuc )+" AND "+;
                     "FCH_DESDE "+GetWhere("=",::dDesde  )+" AND "+;
                     "FCH_HASTA "+GetWhere("=",::dHasta  )+" AND "+;
                     "FCH_TIPNOM"+GetWhere("=",::cTipoNom)+" AND "+;
                     "FCH_OTRNOM"+GetWhere("=",::cOtraNom),.T.)

   ::cFchNumero:=oFecha:FCH_NUMERO

   IF oFecha:RecCount()=0

//      IF Empty(::nProcess) .AND. Empty(::aCodTra) .AND. ::lActualiza
//         oFecha:End()
//         Return .F.
//      ENDIF

      IF lStart
         cEstado   :="I"  // Procesada o iniciada
         ::nProcess:=0    // Aun no Existe Ninguno
      ENDIF

//      ::cFchNumero:=STRZERO(Val(SqlGetMax("NMFECHAS","FCH_NUMERO"))+1,LEN(::cFchNumero))
      ::cFchNumero:=SQLINCREMENTAL("NMFECHAS","FCH_NUMERO","FCH_CODSUC"+GetWhere("=",::cCodSuc),NIL,NIL,.T.)

      oFecha:Append()
      oFecha:Replace("FCH_INTEGR"  ,"N"  )
      oFecha:Replace("FCH_CONTAB"  ,"N"  )
      oFecha:Replace("FCH_NUMERO"  ,::cFchNumero )
      oFecha:Replace("FCH_HORA"    ,TIME() )
      oFecha:Replace("FCH_CODSUC"  ,::cCodSuc    )

   ENDIF

   oFecha:Replace("FCH_DESDE"  ,::dDesde    )
   oFecha:Replace("FCH_HASTA"  ,::dHasta    )
   oFecha:Replace("FCH_TIPNOM" ,::cTipoNom  )
   oFecha:Replace("FCH_OTRNOM" ,::cOtraNom  )
   oFecha:Replace("FCH_SISTEM" ,oDp:dFecha  )
   oFecha:Replace("FCH_USUARI" ,oDp:cUsuario)
   oFecha:Replace("FCH_ESTADO" ,cEstado     )
   oFecha:Replace("FCH_CODSUC" ,::cCodSuc   )
// oFecha:Replace("FCH_NUMREC" ,MAX(oFecha:FCH_NUMREC+(::nProcess*IIF( ::lActualiza, 1 ,-1 )),0))

   IF ::lReversar .AND. nRecibos=0  .AND. oFecha:RecCount()>0
      oFecha:Delete(oFecha:cWhere)
   ELSE
     oFecha:Commit(IIF( oFecha:RecCount()=0,"",oFecha:cWhere))
   ENDIF

   oFecha:End()

RETURN .T.
/*
// Actualiza Promedios
*/
METHOD Promedios()
/*
     LOCAL dIniMes:=FCHINIMES(::dHasta)
     LOCAL dFinMes:=FCHFINMES(::dHasta)
     LOCAL dDesde,dHasta
     LOCAL oTable,oAppend
     LOCAL aMonto   :={0,0,0,0,0,0}
     LOCAL aDias    :={0,0,0,0}
     LOCAL aFecha   :={NIL,NIL,NIL,NIL}
     LOCAL aAcumCon:={::aConceptosA,::aConceptosB,::aConceptosC,::aConceptosD}
     LOCAL I,nDiaMes:=MIN(dFinMes-dIniMes,30) // No puede ser Mayor que 30 Dias
     LOCAL cAno     :=STRZERO(YEAR(::dHasta) ,4),;
           cMes     :=STRZERO(MONTH(::dHasta),2),;
           cSql     :=""

     FOR I := 1 TO LEN(aACumCon)

       IF !EMPTY(aAcumCon[I])

         dDesde   :=RunMacro("GETFCHINIHIS(oPar1,oPar2,oPar3)",aAcumCon[I],dIniMes,dFinMes)
         dHasta   :=::dHasta //RunMacro("GETFCHFINHIS(oPar1,oPar2,oPar3)",aAcumCon[I],dIniMes,dFinMes)
         aMonto[I]:=RunMacro("ACUMC_FCH(oPar1,oPar2,oPar3)"  ,aAcumCon[I],dDesde,dHasta)

         aFecha[I]:={dDesde,dHasta}
         aDias[I] :=dHasta-dDesde

       ENDIF

     NEXT I

     FOR I := 1 TO LEN(aFecha)
       aMonto[1]:=DIV(aMonto[I],aDias[I])*nDiaMes
     NEXT

     // Calcula Total Asignaciones

     cSql  :="SELECT SUM(HIS_MONTO) AS MONTO FROM NMHISTORICO WHERE "+;
             "HIS_CODTRA"+GetWhere("=",::oLee:CODIGO)+" AND "+;
             "HIS_DESDE" +GetWhere(">=",dIniMes)     +" AND "+;
             "HIS_HASTA" +GetWhere("<=",dFinMes)

     oTable:=OpenTable(cSql+" AND LEFT(HIS_CODCON,1)='A'",.T.)
     aMonto[5]:=oTable:FieldGet(1)
     oTable:End()

     oTable:=OpenTable(cSql+" AND LEFT(HIS_CODCON,1)='D'",.T.)
     aMonto[6]:=oTable:FieldGet(1)*-1
     oTable:End()

     oTable:=OpenTable("SELECT RMT_CODTRA FROM NMRESTRA "+;
                       "WHERE RMT_CODTRA"+GetWhere("=",::oLee:CODIGO)+;
                       "  AND RMT_ANO   "+GetWhere("=",cAno)+;
                       "  AND RMT_MES   "+GetWhere("=",cMes),.T.)

     IF oTable:RecCount()=0
       oAppend:=OpenTable("SELECT RMT_CODTRA,RMT_ANO,RMT_MES FROM NMRESTRA",.F.)
       oAppend:AppendBlank()
       oAppend:Replace("RMT_CODTRA",::oLee:CODIGO)
       oAppend:Replace("RMT_ANO"   ,cAno)
       oAppend:Replace("RMT_MES"   ,cMes)
       oAppend:Commit()
       oAppend:End()
     ENDIF

     cSql:="UPDATE NMRESTRA SET RMT_PROM_A"+GetWhere("=",aMonto[1])+;
                              ",RMT_PROM_B"+GetWhere("=",aMonto[2])+;
                              ",RMT_PROM_C"+GetWhere("=",aMonto[3])+;
                              ",RMT_PROM_D"+GetWhere("=",aMonto[4])+;
                              ",RMT_ASIGNA"+GetWhere("=",aMonto[5])+;
                              ",RMT_DEDUCC"+GetWhere("=",aMonto[6])+;
                              " "+oTable:cWhere

     IF !oTable:oOdbc:Execute(cSql)
        MensajeErr("Error, Trabajador: "+::oLee:CODIGO,"Error Actualizando Promedios")
     ENDIF

     oTable:End()
*/
RETURN .T.


// METHOD OnError( uValue,nError,nPar3,nPar4,nPar5,nPar6,nPar7,nPar8,nPar9,nPar10,nPar11 ) CLASS TNOMINA
// RETURN ::Super:OnError( uValue,nError,nPar3,nPar4,nPar5,nPar6,nPar7,nPar8,nPar9,nPar10,nPar11 )

////////////////////////////// TVIEWPRENOMINA BEGIN ///////////////////////////////

/*
 * TViewPrenom
CLASS TVIEWPRENOMINA FROM DPEDIT

   DATA cTipoNom
   DATA cOtraNom

   DATA dDesde
   DATA dHasta

   DATA lMsgAlert                          // Si Emite o no Mensaje

   DATA aConceptos                         // Lista de Conceptos ya Compilados

   DATA oNomina                            // Calcula Nómina
   DATA oTable

   METHOD New() CONSTRUCTOR
   METHOD SkipTrabajador()
   METHOD End()

ENDCLASS

METHOD New() CLASS TVIEWPRENOMINA

   EJECUTAR("FCH_RANGO",oDp:cTipoNom,NIL,oDp:cOtraNom) // Determina la Fecha

   ::oNomina:=TNOMINA("NOMINAINI","oNomina"):New()
   ::oNomina:cTipoNom     :=Left(oDp:cTipoNom,1)
   ::oNomina:cOtraNom     :="  "
   ::oNomina:dDesde       :=oDp:dDesde
   ::oNomina:dHasta       :=oDp:dHasta
   ::oNomina:lMsgAlert    :=.F.
   ::oNomina:cGrupoIni    :=""               // Grupo de Trabajadores
   ::oNomina:cGrupoFin    :=""               // Grupo de Trabajadores
   ::oNomina:lArray       :=.T.
   ::oNomina:lPrenomina   :=.T.
   ::oNomina:lPrint       :=.F.
   ::oNomina:lLoad        :=.F.

   ::aConceptos:={}
   ::SkipTrabajador()

   ? "SIN VENTANA"

   // ::Super:New("Visualización de Prenómina "+DTOC(oDp:dFecha),"VIEWPRE.edt","oFrmView",.T.)
   // ::Activate()

RETURN SELF

METHOD End() CLASS TVIEWPRENOMINA

//   ::oNomina:End()

RETURN ::Super:End()
*/

/*
// Obtiene el Siguiente Trabajador

METHOD SkipTrabajador() CLASS TVIEWPRENOMINA
  LOCAL oTabla

  DO WHILE .T.

      IF LEFT(::oNomina:cTipoNom,1)!="O" // Debe Determinar el Primer Trabajador

        oTabla :=OpenTable("SELECT MIN(CODIGO) AS CODIGO FROM NMTRABAJADOR WHERE TIPO_NOM"+GetWhere("=",::oNomina:cTipoNom)+;
                           " AND CODIGO"+GetWhere(">",::oNomina:cCodigoIni),.T.)

      ELSE

        oTabla :=OpenTable("SELECT MIN(CODIGO) AS CODIGO FROM NMTRABAJADOR WHERE "+;
                           "CODIGO"+GetWhere(">",::oNomina:cCodigoIni),.T.)

      ENDIF

      ::oNomina:cCodigoIni:=oTabla:CODIGO
      ::oNomina:cCodigoFin:=oTabla:CODIGO

      oTabla:End()

      IF EMPTY(::oNomina:cCodigoIni) // Ningun Trabajador
         EXIT
      ENDIF

      ::aConceptos:=::oNomina:PROCESAR()
      ::oTable:=NIL

      IF !EMPTY(::aConceptos)
        EXIT
      ENDIF

  ENDDO

  oTabla:=NIL

// ? ::oNomina:dDesde,::oNomina:dHasta,cCodTra,LEN(aView),LEN(aView[1])
// ? aView[1,1],aView[1,2],aView[1,3],aView[1,4],aView[1,5],aView[1,6]

RETURN .T.

FUNCTION VIEWPRENOMINA()
  LOCAL oView

  oView:=TviewPrenomina():New()

RETURN oView
*/

////////////////////////////// TVIEWPRENOMINA END ///////////////////////////////

/*
// Redondea de 5 a 0
*/
FUNCTION REDONDEA(nValue)
    // REDONDEO DE DECIMALES DE 5 A 0 //
    LOCAL ENT:=nValue*10
    LOCAL INT:=INT(ENT)
    LOCAL DEC:=(ENT-INT)/10

    IF !oDp:lRedondeo // !EMP_REDOND // No Requiere Redondeo

       IF !nValue=0
          nValue:=VAL(LEFT(STR(nValue,19,3),18)) // JN 8/3/2008
          // nValue=INT(nValue*100)
          // nValue=nValue/100
       ENDIF

       RETURN nValue

    ENDIF

    INT:=INT/10

    IF DEC>0.04
       DEC=0.05
    ELSE
       DEC=0
    ENDIF

RETURN INT+DEC


/*
IF !HB_ZIPFILE( cFileZip , cDest,,,,,FALSE )
     MsgStop( "Los Datos de CD no fueron creados completos!" , "Verifique" )
     Return NIL
EndIF

IF !HB_UNZIPFILE( cFileDat,,,,cDir )
   MsgInfo( "DATOS CORRUPTOS!!!!", "Verifique" )
   Return FALSE
EndIF
*/

/*
function HelpTopic( nHelpId )
   MSGALERT("HELPTOPIC")
RETURN .T.
//-----------------------------------------------------------------------//

function HelpIndex()

  ? "HELPINDEX",oDp:cHelpFile,oDp:cHelpTopic

return NIL

//-----------------------------------------------------------------------//

function HelpSearch( cSearch )      // this is not working it just brings search screen

   ? "HELPSERARC"

return NIL

//-----------------------------------------------------------------------//

function HelpPopup( nHelpId )

   ? "HELPPOPUP"
return NIL

//-----------------------------------------------------------------------//

function WinHelp( cHelpFile, nId, nParams )   // this don't work.


   ? "WINHELP"

return NIL
*/
/*
FUNCTION  IF_OPEN()
RETURN NIL

FUNCTION IF_WRITE()
RETURN NIL

FUNCTION IF_READ()
RETURN NIL

FUNCTION IF_ERROR1()
RETURN NIL

FUNCTION IF_ERROR2()
RETURN NIL

FUNCTION IF_SERIAL()
RETURN NIL

FUNCTION IF_TRACE()
RETURN NIL

FUNCTION IF_SETLOG()
RETURN NIL
*/

