// Programa   : NMCONFIG
// Fecha/Hora : 26/08/2004 08:38:14
// Propósito  : Configuración de la Empresa
// Creado Por : Juan Navas
// Llamado por: NMMENU
// Aplicación : Definicione
// Tabla      : NMTDATASET
// 26/09/2008 Desactivada la Opcion de Reconversion Monetaria (TJ)

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"

PROCE MAIN()
  LOCAL oBtn,oFont,oData,nClrText:=CLR_BLUE,oTable,lH400,lH410
  LOCAL aFechas:={"Desde" ,"Hasta","Sistema"}
  LOCAL aSemana:={"Lunes" ,"Martes","Miércoles","Jueves","Viernes","Sábado","Domingo"}
  LOCAL aContab:={"Concepto","Departamento","Unidad Funcional","Grupo"}
  LOCAL aVertical:={"Estandar","Construcción"}
  LOCAL aTipPer  :={"Jurídica" ,"Natural","Gobierno"}
  LOCAL aTipCon  :={"Ordinario","Especial","Formal"}
  LOCAL aRegimen :={"Parcial","Total"}
  LOCAL aRiesgo  :={"Mínimo","Medio","Máximo"}

//  EJECUTAR("NMRESTDATA")

  DEFAULT oDp:cContab:=aContab[1],;
          oDp:cTipPer:="J",;
          oDp:cTipCon:=aTipCon[1]

  oDp:lDpXbase:=.T.

  CURSORWAIT()

  oDp:aMonedas:=aTable("SELECT MON_CODIGO,MON_DESCRI FROM DPTABMON WHERE MON_ACTIVO=1",.T.)

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD

  oData:=DATASET("NOMINA","ALL")

  lH400:=COUNT("NMHISTORICO","HIS_CODCON"+GetWhere("=",oDp:cConPres))>0

// ? ValType(oDp:cSso),"oDp:cSso ",oDp:cMintra,"oDp:cMintra",ValType(oDp:cMintra)

  DEFAULT oDp:cSso   :=SPACE(100),;
          oDp:cMintra:=SPACE(100)

  oCnf:=DPEDIT():New("Configuración de la Empresa","NMCONFIG.edt","oCnf",.T.)
  oCnf:cFileChm     :="CAPITULO4.CHM"
  oCnf:cTopic       :="NMCONFIG"
  oCnf:cSalario     :=MEMOREAD("DP\SALARIOS.TXT")

  oCnf:cDir1    :=oData:Get("cDir1" ,oDp:cDir1)           // Dirección 1
  oCnf:cDir2    :=oData:Get("cDir2" ,oDp:cDir2)           // Dirección 2
  oCnf:cDir3    :=oData:Get("cDir3" ,oDp:cDir3)           // Dirección 3
  oCnf:cTel1    :=oData:Get("cTel1" ,oDp:cTel1)           // Teléfono 1 
  oCnf:cTel2    :=oData:Get("cTel2" ,oDp:cTel2)           // Teléfono 2 
  oCnf:cTel3    :=oData:Get("cTel3" ,oDp:cTel3)           // Teléfono 3 

  oCnf:cWeb     :=oData:Get("cWeb"     ,oDp:cWeb )        // Pagina Web
  oCnf:cMail    :=oData:Get("cMail"    ,oDp:cMail)        // Email

  oCnf:cRif     :=oData:Get("cRif"     ,oDp:cRif)         // Rif
  oCnf:cNit     :=oData:Get("cNit"     ,oDp:cNit)         // NIT
  oCnf:cMintra  :=oData:Get("cMintra"  ,oDp:cMintra)      // Numero de Informacion Laboral Ministerio del Trabajo
  oCnf:cSso     :=oData:Get("cSso"     ,oDp:cSso )        // Seguro Social

  oCnf:cRegimen :=oData:Get("cRegimen"  ,"Parcial")       // Tipo de Regimen
  oCnf:cRiesgo  :=oData:Get("cRiesgo"   ,"Medio")         // Tipo de Riesgo
  oCnf:dFchInsI :=oData:Get("dFchInsI",CTOD("") )         // Fecha de Inscripcion Ante el IVSS

  oCnf:cBilletes:=oData:Get("cBilletes",oDp:cBilletes)    // Billetes
  oCnf:cTipPer  :=oData:Get("cTipPer"  ,oDp:cTipPer)     // Persona
  oCnf:cTipCon   :=oData:Get("cTipCon" ,oDp:cTipCon)     // Contribuyente


  oCnf:cMoneda   :=oData:Get("cMoneda"     ,oDp:cMoneda)     // cMoneda
  oCnf:cMonedaExt:=oData:Get("cMonedaExt"  ,oDp:cMonedaExt)  // cMonedaExt
  

// oCnf:cMintra  :=oData:Get("cMintra"  ,SPACE(14))        // Numero de Informacion Laboral Ministerio del Trabajo 

  oCnf:cFchDH   :=oData:Get("cFchDH"   ,"Hasta")          // Cálculos históricos Según Fecha
  oCnf:cIniSem  :=oData:Get("cIniSem"  ,"Lunes")          // Inicio de la Semana 
  oCnf:cContab  :=oData:Get("cContab"  ,oDp:cContab)      // Contabilizar
  oCnf:lRedondeo:=oData:Get("lRedondeo",.T.     )         // Redondea de 5 a 0
  oCnf:nDebBanc :=oData:Get("nDebBanc" ,oDp:nDebBanc )    // Débito Bancario
  oCnf:cCtaIdb  :=oData:Get("cCtaIdb"  ,oDp:cCtaIdb  )    // Cuenta Débito Bancario
  oCnf:cCtaNxP  :=oData:Get("cCtaNXP"  ,oDp:cCtaNxp  )    // Cuenta Nómina por Pagar
  oCnf:cCtaEfe  :=oData:Get("cCtaEfe"  ,oDp:cCtaEfe  )    // Cuenta Nómina por Pagar
  oCnf:cCtaEfe  :=PADR(oCnf:cCtaEfe,20)                   
  oCnf:lPascua  :=oData:Get("lPascua" , oDp:lPascua  )    // Carnavales y Semana Santa

   // Prestaciones Sociales
  oCnf:cConPres  :=oData:Get("cConPres" ,"H400")          // Concepto Acumulado Prestaciones
  oCnf:cConPresTr:=oData:Get("cConPresTr" ,"H410")          // Concepto Acumulado Prestaciones Trimestral
  oCnf:cConAdel  :=oData:Get("cConAdel" ,"A073")          // Adelanto de Prestaciones
  //  oCnf:cConAdelTr :=oData:Get("cConAdelTr" ,"A075")          // Adelanto de Prestaciones
  oCnf:cConInter :=oData:Get("cConInter","A411")          // Pago de Intereses sobre Prestaciones
  //  oCnf:cConInterTr :=oData:Get("cConInterTr","A409")          // Pago de Intereses sobre Prestaciones
  oCnf:cPagInter :=oData:Get("cPagInter","N411")          // Intereses ya Calculados sobre Antiguedad Laboral
  // oCnf:cPagInterTr :=oData:Get("cPagInterTr","N409")          // Intereses ya Calculados sobre Antiguedad Laboral


  oCnf:lBaseAnual:=oData:Get("lBaseAnual",.T.)            // Base para el Cálculo de Intereses 360 ó 365TJB
  oCnf:lIndexaInt:=oData:Get("lIndexaInt",.T.  )          // Indexar Intereses sobre Prestaciones
  oCnf:lAniverInt:=oData:Get("lAniverInt",.T.  )          // Intereses en Fecha Aniversario
  oCnf:lDistAnosA:=oData:Get("lDistAnosA",.T.  )          // Distribuir Días Adicionales Durante el Año
  oCnf:dFchIniInt:=oData:Get("dFchIniInt",CTOD(""))       // Inicio en el Cálculo de Intereses
  oCnf:lUtilDif  :=oData:Get("lUtilDif"  ,.T.  )          // Diferir Utilidades para Liquidación
  oCnf:lH400     :=lH400                                  // Indica si Tiene Movimientos
  oCnf:lArt104   :=oDp:lArt104                            // Incluye el Pago de Art104
  oCnf:lArt108Adi:=oDp:lArt108Adi                         // Incluye en la Nómina los Dos Días Adicionales


  // Salarios
  oCnf:lSalarioA :=oData:Get("lSalarioA"  ,.F.)            // Salario A, calculado por Acumulado y no por histórico
  oCnf:lSalarioB :=oData:Get("lSalarioB"  ,.F.)            // Salario B, calculado por Acumulado y no por histórico
  oCnf:lSalarioC :=oData:Get("lSalarioC"  ,.F.)            // Salario C, calculado por Acumulado y no por histórico
  oCnf:lSalarioD :=oData:Get("lSalarioD"  ,.F.)            // Salario D, calculado por Acumulado y no por histórico

  // Vacaciones
  oCnf:cDiasVac  :=oData:Get("cDiasVac"  ,oDp:cDiasVac  )   // Concepto Acumulado Prestaciones
  oCnf:cDiasRein :=oData:Get("cDiasRein" ,oDp:cDiasRein )   // Dias de Reintegro
  oCnf:cDiasProx :=oData:Get("cDiasProx" ,oDp:cDiasProx )   // Días para proximo Disfrute
  oCnf:cDiasAdic :=oData:Get("cDiasAdic" ,oDp:cDiasAdic )   // Días Adicionales de Disfrute
  oCnf:cDiasDisf :=oData:Get("cDiasDisf" ,oDp:cDiasDisf )   // Días disfrutados  
  oCnf:lColectiva:=oData:Get("lColectiva",.T.           )   // Días disfrutados  
  oCnf:lBono_VacV:=oData:Get("lBono_VacV",.T.           )   // Bono lo Cobra en Vacaciones o Aniversario
  oCnf:nVacacion :=IIF(oCnf:lColectiva,1,2)
  oCnf:nBono_VacV:=IIF(oCnf:lBono_VacV,1,2)
  oCnf:dFchIniVac:=oData:Get("dFchIniVac",oDp:dFchIniVac)   // Inicio de Vacacion Colectiva
  oCnf:dFchFinVac:=oData:Get("dFchFinVac",oDp:dFchFinVac)   // Fin del Periodo de Vacación Colectiva

  // Prestamos
  oCnf:cA_Prestm :=oData:Get("cA_Prestm" ,oDp:cA_Prestm)         // Asignación Prestamo   
  oCnf:cD_Prestm :=oData:Get("cD_Prestm" ,oDp:cD_Prestm)         // Deducción Préstamo
  oCnf:cI_Prestm :=oData:Get("cI_Prestm" ,oDp:cI_Prestm)         // Intereses Sobre Préstamos
  oCnf:lI_Prestm :=oData:Get("lI_Prestm" ,oDp:lI_Prestm)         // Aplica intereses sobre Préstamos

  // InterNet y Otros
  oCnf:lCgiOtrosC:=oData:Get("lCgiOtrosC" ,.F.)                  // Visualizar Otros Conceptos desde InterNet
  oCnf:lDifSSO   :=oData:Get("lDifSSO"    ,.F.)                  // Diferir SSO para Fín de Mes
  oCnf:lDifLPH   :=oData:Get("lDifLPH"    ,.F.)                  // Diferir LPH para Fín de Mes
  oCnf:lDifRPF   :=oData:Get("lDifRPF"    ,.F.)                  // Diferir RPT para Fín de Mes


  oCnf:nMClrPane :=oData:Get("nMClrPane" ,oDp:nMenuItemClrPane    ) // Color del Menú en Cada Empresa

//  oCnf:dFchIniVac:=oData:Get("dFchIniVac",oDp:dFchIniVac)   // Inicio de Vacacion Colectiva
//  oCnf:dFchFinVac:=oData:Get("dFchFinVac",oDp:dFchFinVac)   // Fin del Periodo de Vacación Colectiva
//  Reconversion Monetaria
//  oCnf:dFchIniRec:=oData:Get("dFchIniRec"     ,oDp:dFchIniRec )
//  oCnf:dFchFinRec:=oData:Get("dFchFinRec"     ,oDp:dFchFinRec )
//  oCnf:cCtaMonRec:=oData:Get("cCtaMonRec"     ,oDp:cCtaMonRec )

  //oDp:cTipCon    :=LEFT(oDp:cTipCon,1)

  oCnf:cRif:=PADR(oCnf:cRif,12)
  //
  // cVertical
  //

  oCnf:cVertical:=oData:Get("cVertical"    ,aVertical[1])   
  oData:End(.F.)

  oCnf:oColor2:=NIL

  oCnf:ONMCONCEPTO:=oCnf:ViewTable("NMCONCEPTOS","CON_DESCRI","CON_CODIGO","CCONPRES")
  oCnf:ONMCTA     :=oCnf:ViewTable("NMCTA","CTA_DESCRI","CTA_CODIGO","CCTAIDB")


//  OCnf:nRecord:=0
//  oCnf:cDir   :=PADR("A:\\\\",30)

//  @ 0.5,0.5 SAY "Empresa:"
//  @ 0.5,2.0 SAY oDp:cEmpresa BORDER

  @ 6.8, 1.0 FOLDER oCnf:oFolder ITEMS "Empresa","Antigüedad e Intereses","Vacaciones","Préstamos","Otros","Ctas Contables e ITF",;
                                       "Uso de Salarios"

  oCnf:oFolder:aEnable[6]:=!(oDp:cType="SGE")

  SETFOLDER( 1)


  //
  // Campo : DEM_DIR1  
  // Uso   : Dirección 1                             
  //
  @ 1.0, 1.0 GET oCnf:oDir1    VAR oCnf:cDIR1 WHEN !(oDp:cType="SGE")

  oCnf:oDir1  :cMsg    :="Dirección 1"
  oCnf:oDir1  :cToolTip:="Dirección 1"

  @ oCnf:oDir1  :nTop-08,oCnf:oDir1:nLeft SAY "Dirección" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  //
  // Campo : DEM_DIR2  
  // Uso   : Dirección 2                             
  //
  @ 2.8, 1.0 GET oCnf:oDir2    VAR oCnf:cDIR2 WHEN !(oDp:cType="SGE")

    oCnf:oDir2  :cMsg    :="Dirección 2"
    oCnf:oDir2  :cToolTip:="Dirección 2"

  //
  // Campo : cDIR3  
  // Uso   : Direcci«n 3                             
  //
  @ 4.6, 1.0 GET oCnf:oDir3    VAR oCnf:CDIR3 WHEN !(oDp:cType="SGE")  

    oCnf:oDir3  :cMsg    :="Dirección 3"
    oCnf:oDir3  :cToolTip:="Dirección 3"




  //
  // Campo : cTEL1  
  // Uso   : Tel\\\'fono 1                              
  //
  @ 6.4, 1.0 GET oCnf:ocTEL1    VAR oCnf:cTEL1   WHEN !(oDp:cType="SGE")

    oCnf:ocTEL1  :cMsg    :="Teléfono 1"
    oCnf:ocTEL1  :cToolTip:="Teléfono 1"

  @ oCnf:ocTEL1  :nTop-08,oCnf:ocTEL1  :nLeft SAY "Teléfonos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  //
  // Campo : cTEL2  
  // Uso   : Tel\\\'fono 2                              
  //
  @ 07.2, 1.0 GET oCnf:ocTEL2    VAR oCnf:cTEL2  WHEN !(oDp:cType="SGE")

    oCnf:ocTEL2  :cMsg    :="Teléfono 2"
    oCnf:ocTEL2  :cToolTip:="Teléfono 2"

  //
  // Campo : cTEL3  
  // Uso   : Tel\\\'fono 3                              
  //
  @ 08.0, 1.0 GET oCnf:ocTEL3    VAR oCnf:cTEL3  WHEN !(oDp:cType="SGE")


    oCnf:ocTEL3:cMsg    :="Teléfono 3"
    oCnf:ocTEL3:cToolTip:="Teléfono 3"

  //
  // Campo : DEM_WEB  
  // Uso   : Pagina Web                             
  //
  @ 08.0, 1.0 GET oCnf:oCWEB    VAR oCnf:cWEB WHEN !(oDp:cType="SGE")

  oCnf:oCWEB  :cMsg    :="Pagina Web"
  oCnf:oCWEB  :cToolTip:="Pagina Web"

  @ oCnf:oCWEB  :nTop-08,oCnf:oCWEB  :nLeft SAY "Pagina Web" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL


  // VV
  // Campo : DEM_MAIL  
  // Uso   : Correo Correo Electrónico                            
  //
  @ 08.0, 1.0 GET oCnf:oCMAIL VAR oCnf:cMAIL WHEN !(oDp:cType="SGE")

  oCnf:oCMAIL  :cMsg    :="Correo Electrónico"
  oCnf:oCMAIL  :cToolTip:="Correo Electrónico"

  @ oCnf:oCMAIL :nTop-08,oCnf:oCMAIL :nLeft SAY "Correo Electrónico" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL

  //
  // Campo : CRIF   
  // Uso   : RIF                                     
  //
  @ 1.0,15.0 GET oCNF:oCRIF     VAR oCNF:CRIF VALID .T. WHEN !(oDp:cType="SGE")

   oCnf:oCRIF:bKeyDown:={|| oCnf:oBtnSave:ForWhen(.T.)}

    oCNF:oCRIF   :cMsg    :="R.I.F"
    oCNF:oCRIF   :cToolTip:="R.I.F"

  @ oCNF:oCRIF   :nTop-08,oCNF:oCRIF   :nLeft SAY "R.I.F" PIXEL;
                         SIZE NIL,7 FONT oFont COLOR nClrText,NIL 



  @ 30,1  BUTTON oCnf:oBtnRif PROMPT " > " PIXEL;
                                   ACTION oCnf:VALRIF() CANCEL;
                                   WHEN !Empty(oCnf:oCRIF)   


                              
  //
  // Campo : CMINTRA
  // Uso   : Numero de Informacion Laboral  Antes Ministerio del Trabajo                 
  //
  @ 2.8,15.0 GET oCNF:oCMINTRA  VAR oCNF:CMINTRA

    oCNF:oCMINTRA:cMsg    :="Numero de Información Laboral"            // Numero de Informacion Laboral
    oCNF:oCMINTRA:cToolTip:="Numero de Información Laboral"            // Numero de Informacion Laboral

  @ oCNF:oCMINTRA:nTop-08,oCNF:oCMINTRA:nLeft SAY "N.I.L" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  //
  // Campo : CSSO   
  // Uso   : Nº Patronal IVSS                           
  //
  @ 4.6,15.0 GET oCNF:oCSSO     VAR oCNF:CSSO 

    oCNF:oCSSO   :cMsg    :="Nº Patronal IVSS"
    oCNF:oCSSO   :cToolTip:="Nº Patronal IVSS"

  @ oCNF:oCSSO   :nTop-08,oCNF:oCSSO   :nLeft SAY "Nº Patronal IVSS" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 
  //
  // Campo : dFchInsI
  // Uso   : Fecha Inscripcion en IVSS
  //
  @ 4.6,15.0 BMPGET oCnf:odFchInsI VAR oCnf:dFchInsI;
                    NAME "BITMAPS\\\\Calendar.bmp"; 
                    ACTION LbxDate(oCnf:odFchInsI,oCnf:dFchInsI)




  oCnf:odFchInsI:cMsg    :="Fecha Inscripcion en IVSS"
  oCnf:odFchInsI:cToolTip:=OCnf:odFchInsI:cMsg 

  @ OCNF:odFchInsI:nTop-08,OCNF:odFchInsI:nLeft SAY "Fecha Inscripcion en IVSS" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL

  oData:Set("dFchInsI",oCnf:dFchInsI) // Fecha Inscripcion en IVSS





  //
  // Campo : cRegimen
  // Uso   : Tipo de Regimen                     
  //
  @ 0.5,29.0 COMBOBOX OCNF:ocREGIMEN VAR OCNF:cREGIMEN ITEMS aRegimen

  ComboIni(OCNF:ocREGIMEN)

  OCNF:ocREGIMEN:cMsg    :="Régimen"
  OCNF:ocREGIMEN:cToolTip:="Régimen"

  @ OCNF:ocREGIMEN:nTop-08,OCNF:ocREGIMEN:nLeft SAY "Régimen" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 



  //
  // Campo : cRiesgo
  // Uso   : Tipo de Riesgo                     
  //
  @ 0.5,29.0 COMBOBOX OCNF:ocRIESGO VAR OCNF:cRIESGO ITEMS aRiesgo

  ComboIni(OCNF:ocRIESGO)

  OCNF:ocRIESGO:cMsg    :="Riesgo"
  OCNF:ocRIESGO:cToolTip:="Riesgo"

  @ OCNF:ocRIESGO:nTop-08,OCNF:ocRIESGO:nLeft SAY "Riesgo" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL

/*
  //
  // Campo : NNIT   
  // Uso   : Número de NIT
  //
  @ 4.6,15.0 GET oCNF:oNNIT     VAR oCNF:CNIT 

    oCNF:oNNIT   :cMsg    :="Número de N.I.T."
    oCNF:oNNIT   :cToolTip:="Número de N.I.T."

  @ oCNF:oNNIT   :nTop-08,oCNF:oNNIT   :nLeft SAY "N.I.T." PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 
*/


  //
  // Campo : DFCHDH 
  // Uso   : Fecha Desde o Hasta                     
  //
  @ 11.3,15.0 COMBOBOX oCnf:ocFchDH  VAR oCnf:cFchDH  ITEMS aFechas

  ComboIni(oCNF:ocFchDH )

  OCNF:ocFCHDH :cMsg    :="Utilizar Fecha en Históricos"
  OCNF:ocFCHDH :cToolTip:="Utilizar Fecha en Históricos"

  @ OCNF:ocFCHDH :nTop-08,OCNF:ocFCHDH :nLeft SAY "Utilizar Fecha en Históricos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : cINISEM
  // Uso   : Inicio de la Semana                     
  //
  @ 0.5,29.0 COMBOBOX OCNF:ocINISEM VAR OCNF:cINISEM ITEMS aSemana

  ComboIni(OCNF:ocINISEM)

  OCNF:ocINISEM:cMsg    :="Inicio de la Semana"
  OCNF:ocINISEM:cToolTip:="Inicio de la Semana"

  @ OCNF:ocINISEM:nTop-08,OCNF:ocINISEM:nLeft SAY "Inicio de la Semana" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  //
  // Campo : cCONTAB
  // Uso   : Por Departamento o Unidad Funcional     
  //
  @ 1.8,29.0 COMBOBOX OCNF:ocCONTAB VAR OCNF:cCONTAB ITEMS aContab

  ComboIni(OCNF:ocCONTAB)

  OCNF:ocCONTAB:cMsg    :="Origen de los Asientos Contables"
  OCNF:ocCONTAB:cToolTip:="Origen de los Asientos Contables"

  @ OCNF:ocCONTAB:nTop-08,OCNF:ocCONTAB:nLeft SAY "Forma de Contabilizar" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 


  //
  // Campo : cVertical 
  // Uso   : Utilizar Vertical del Sistema                  
  //
  @ 1,1 COMBOBOX oCnf:oVertical  VAR oCnf:cVertical  ITEMS aVertical

  ComboIni(oCnf:oVertical )

  OCNF:ocFCHDH :cMsg    :="Utilizar Vertical del Sistema"
  OCNF:ocFCHDH :cToolTip:="Utilizar Vertical del Sistema"


  //
  // Campo : Tipo de Persona
  // Uso   : Tipo de Persona                       
  //
  @ 1,1 COMBOBOX oCnf:oTipPer  VAR oCnf:cTipPer  ITEMS aTipPer WHEN !(oDp:cType="SGE")

  ComboIni(oCnf:oTipPer )

  oCnf:oTipPer:cMsg    :="Tipo de Persona"
  oCnf:oTipPer:cToolTip:="Tipo de Persona"

  @ 10,10 SAY "Tipo de Persona:"



  //
  // Campo : Tipo de Contribuyente
  // Uso   : Tipo de Contribuyente                       
  //
  @ 0,1 COMBOBOX oCnf:oTipCon  VAR oCnf:cTipCon  ITEMS aTipCon  WHEN !(oDp:cType="SGE")


  ComboIni(oCnf:oTipCon )

  oCnf:oTipPer:cMsg    :="Tipo de Contribuyente"
  oCnf:oTipPer:cToolTip:="Tipo de Contribuyente"

  @ 10,10 SAY "Tipo de Contribuyente:"


  //
  // Campo : cREDOND
  // Uso   : Redondeo de 5 a 0                       
  //
  @ 5.4,29.0 CHECKBOX OCNF:olRedondeo  VAR OCNF:lRedondeo  PROMPT ANSITOOEM("Redondeo de 5 a 0");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

    OCNF:olRedondeo:cMsg    :="Redondeo de 5 a 0"
    OCNF:olRedondeo:cToolTip:="Redondeo de 5 a 0"



 //
  // Campo : PASCUA
  // Uso   : Incluye Semana Santa y Carnavales en Calendario
  //
  @ 5.4,29.0 CHECKBOX OCNF:olPascua    VAR OCNF:lPascua  PROMPT ANSITOOEM("Detecta Carnaval y Semana Santa");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:olPascua:cMsg    :="Detecta Carnaval y Semana Santa "
  OCNF:olPascua:cToolTip:="Detecta Carnaval "+DTOC(Carnaval())+CRLF+;
                          "Semana Santa "+DTOC(SemanaSanta())

  //
  // Campo : CBILLETES
  // Uso   : Billetes
  //
  @ 2.8,15.0 GET oCNF:oCBILLETES  VAR oCNF:CBILLETES

    oCNF:oCBILLETES:cMsg    :="Distribución Monetaria"
    oCNF:oCBILLETES:cToolTip:=oCNF:oCBILLETES:cToolTip

  @ oCNF:oCBILLETES:nTop-08,oCNF:oCBILLETES:nLeft SAY "Distribución Monetaria" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 
           
  @ 1,1 SAY "Uso Vertical"

  @ 10,1 SAY oCnf:oColor2 PROMPT "Color del Menú"
  @ 12,1 BMPGET oCnf:oMClrPane VAR oCnf:nMClrPane NAME "BITMAPS\COLORS.BMP";
                                SIZE 50,10;
                                ACTION (oCnf:oColor2:SelColor(),;
                                        oCnf:oMClrPane:VarPut(oCnf:oColor2:nClrPane,.T.),;
                                        oCnf:PINTARMENU());
                                VALID (oCnf:PINTARMENU(),.T.);
                                WHEN oDp:nVersion>=5


  @ 10,1 SAY "Moneda:" 
//@ 21,1 SAY "Divisa:" 

  @ 1.6, 06.0 COMBOBOX oCnf:oMoneda VAR oCnf:cMoneda ITEMS oDp:aMonedas;
         WHEN LEN(oDp:aMonedas)>1 .AND. oDp:cType="NOM"

  ComboIni(oCnf:oMoneda)
	
  @ 0,1 SAY "Moneda Extranjera:"

  @ 1.6, 06.0 COMBOBOX oCnf:oMonedaExt VAR oCnf:cMonedaExt ITEMS oDp:aMonedas;
         WHEN LEN(oDp:aMonedas)>1;
         VALID oCnf:cMonedaExt<>oCnf:cMoneda .AND. oDp:cType="NOM"

  ComboIni(oCnf:oMonedaExt)

        
  SETFOLDER( 2)

  //
  // Campo : cConPres
  // Uso   : Prestaciones Sociales
  //

  @ 3.8,10.0 BMPGET oCnf:ocConPres  VAR oCnf:cConPres;
                    VALID (EMPTY(OCNF:cConPres) .AND. OCNF:PUTCUENTA(OCNF:cConPres,OCNF:oSAYCON));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocConPres,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cConPres,OCNF:oSAYCON));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocConPres))

  oCnf:ocConPres:cMsg    :="Concepto para Acumulado de Antigüedad Laboral"
  oCnf:ocConPres:cToolTip:= OCNF:ocConPres:cMsg 

  @ OCNF:ocConPres:nTop-08,OCNF:ocConPres:nLeft SAY "Antigüedad Laboral:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocConPres:nTop,OCNF:ocConPres:nRight+5 SAY OCNF:oSAYCON;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cConPres,OCNF:oSAYCON)

////////////////////////
//
  // Campo : cConPres
  // Uso   : Prestaciones Sociales
  //

  @ 3.8,10.0 BMPGET oCnf:ocConPresTr  VAR oCnf:cConPresTr;
                    VALID (EMPTY(oCnf:cConPresTr) .AND. OCNF:PUTCUENTA(oCnf:cConPresTr,OCNF:oSAYCON));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",oCnf:ocConPresTr,NIL);
                          .AND. OCNF:SAY_CPTO(oCnf:cConPresTr,OCNF:oSAYCON));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",oCnf:ocConPresTr))

  oCnf:ocConPresTr:cMsg    :="Acumulado de Antigüedad Laboral Trimestral"
  oCnf:ocConPresTr:cToolTip:= oCnf:ocConPresTr:cMsg 

  @ oCnf:ocConPresTr:nTop-08,oCnf:ocConPresTr:nLeft SAY "Antigüedad Labora Trimestral:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ oCnf:ocConPresTr:nTop,oCnf:ocConPresTr:nRight+5 SAY OCNF:oSAYCON;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(oCnf:cConPresTr,OCNF:oSAYCON)

  //
  // Campo : cConAdel
  // Uso   : Anticipos de Antigüedad
  //

  @ 3.8,10.0 BMPGET oCnf:ocConAdel  VAR oCnf:cConAdel;
                    VALID (EMPTY(OCNF:cConAdel) .AND. OCNF:PUTCUENTA(OCNF:cConAdel,OCNF:oSAYADEL));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocConAdel,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cConAdel,OCNF:oSAYADEL));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocConAdel))

  oCnf:ocConAdel:cMsg    :="Concepto para Anticipos de Antigüedad"
  oCnf:ocConAdel:cToolTip:= OCNF:ocConAdel:cMsg 


  @ OCNF:ocConAdel:nTop-08,OCNF:ocConAdel:nLeft SAY "Anticipos de Antigüedad:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocConAdel:nTop,OCNF:ocConAdel:nRight+5 SAY OCNF:oSAYADEL;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cConAdel,OCNF:oSAYADEL)


/*
  // Anticipos Trimestal
  //
  // Campo : cConAdelTr
  // Uso   : Anticipos de Antigüedad
  //

  @ 3.8,10.0 BMPGET oCnf:ocConAdelTr  VAR oCnf:cConAdelTr;
                    VALID (EMPTY(OCNF:cConAdelTr) .AND. OCNF:PUTCUENTA(OCNF:cConAdelTr,OCNF:oSAYADEL));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocConAdelTr,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cConAdelTr,OCNF:oSAYADEL));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocConAdelTr))

  oCnf:ocConAdelTr:cMsg    :="Concepto para Anticipos de Antigüedad"
  oCnf:ocConAdelTr:cToolTip:= OCNF:ocConAdelTr:cMsg 


  @ OCNF:ocConAdelTr:nTop-08,OCNF:ocConAdelTr:nLeft SAY "Anticipos de Antigüedad:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocConAdelTr:nTop,OCNF:ocConAdelTr:nRight+5 SAY OCNF:oSAYADEL;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cConAdelTr,OCNF:oSAYADEL)
*/


  //
  // Campo : cConInter
  // Uso   : Concepto Pago de Intereses sobre Antigüedad
  //

  @ 3.8,10.0 BMPGET oCnf:ocConInter  VAR oCnf:cConInter;
                    VALID (EMPTY(OCNF:cConInter) .AND. OCNF:PUTCUENTA(OCNF:cConInter,OCNF:OSAYINTER));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocConInter,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cConInter,OCNF:OSAYINTER));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocConInter))

  oCnf:ocConInter:cMsg    :="Concepto Pago de Intereses sobre Antigüedad"
  oCnf:ocConInter:cToolTip:= OCNF:ocConInter:cMsg 

  @ OCNF:ocConInter:nTop-08,OCNF:ocConInter:nLeft SAY "Concepto Pago de Intereses sobre Antigüedad:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocConInter:nTop,OCNF:ocConInter:nRight+5 SAY OCNF:OSAYINTER;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cConInter,OCNF:OSAYINTER)

/*
  //
  //Pago intereses Trimestral
  //

  //
  // Campo : cConInterTrTr
  // Uso   : Concepto Pago de Intereses sobre Antigüedad
  //

  @ 3.8,10.0 BMPGET oCnf:ocConInterTr  VAR oCnf:cConInterTr;
                    VALID (EMPTY(OCNF:cConInterTr) .AND. OCNF:PUTCUENTA(OCNF:cConInterTr,OCNF:OSAYINTER));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocConInterTr,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cConInterTr,OCNF:OSAYINTER));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocConInterTr))

  oCnf:ocConInterTr:cMsg    :="Concepto Pago de Intereses sobre Antigüedad"
  oCnf:ocConInterTr:cToolTip:= OCNF:ocConInterTr:cMsg 

  @ OCNF:ocConInterTr:nTop-08,OCNF:ocConInterTr:nLeft SAY "Concepto Pago de Intereses sobre Antigüedad:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocConInterTr:nTop,OCNF:ocConInterTr:nRight+5 SAY OCNF:OSAYINTER;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cConInterTr,OCNF:OSAYINTER)

*/

//
  // Campo : cPagInter
  // Uso   : Concepto Pago de Intereses ya Calculados sobre Antigüedad
  //

  @ 3.8,10.0 BMPGET oCnf:ocPagInter  VAR oCnf:cPagInter;
                    VALID (EMPTY(OCNF:cPagInter) .AND. OCNF:PUTCUENTA(OCNF:cPagInter,OCNF:OSAYINTER));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocPagInter,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cPagInter,OCNF:OSAYINTER));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocPagInter))

  oCnf:ocPagInter:cMsg    :="Concepto Pago de Intereses ya Calculados sobre Antigüedad"
  oCnf:ocPagInter:cToolTip:= OCNF:ocPagInter:cMsg 

  @ OCNF:ocPagInter:nTop-08,OCNF:ocPagInter:nLeft SAY "Concepto Pago de Intereses ya Calculados sobre Antigüedad:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocPagInter:nTop,OCNF:ocPagInter:nRight+5 SAY OCNF:OSAYINTER;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cPagInter,OCNF:OSAYINTER)


/*

  //Intereses ya Calculados

//
  // Campo : cPagInterTr
  // Uso   : Concepto Pago de Intereses ya Calculados sobre Antigüedad
  //

  @ 3.8,10.0 BMPGET oCnf:ocPagInterTr  VAR oCnf:cPagInterTr;
                    VALID (EMPTY(OCNF:cPagInterTr) .AND. OCNF:PUTCUENTA(OCNF:cPagInterTr,OCNF:OSAYINTER));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocPagInterTr,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cPagInterTr,OCNF:OSAYINTER));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocPagInterTr))

  oCnf:ocPagInterTr:cMsg    :="Concepto Pago de Intereses ya Calculados sobre Antigüedad"
  oCnf:ocPagInterTr:cToolTip:= OCNF:ocPagInterTr:cMsg 

  @ OCNF:ocPagInterTr:nTop-08,OCNF:ocPagInterTr:nLeft SAY "Concepto Pago de Intereses ya Calculados sobre Antigüedad:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocPagInterTr:nTop,OCNF:ocPagInterTr:nRight+5 SAY OCNF:OSAYINTER;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cPagInterTr,OCNF:OSAYINTER)
*/


  //
  // Campo : dFchIniInt
  // Uso   : Inicio para el Cálculo de Intereses.
  //
  @ 3.8,10.0 BMPGET oCnf:odFchIniInt VAR oCnf:dFchIniInt;
                    NAME "BITMAPS\\\\Calendar.bmp"; 
                    ACTION LbxDate(oCnf:odFchIniInt,oCnf:dFchIniInt)

  oCnf:odFchIniInt:cMsg    :="Fecha en que se Inicia el Cálculo y Pago de Intereses"
  oCnf:odFchIniInt:cToolTip:=OCnf:odFchIniInt:cMsg 

  @ OCNF:odFchIniInt:nTop-08,OCNF:odFchIniInt:nLeft SAY "Inicio para el Cálculo de Intereses:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL


  // Campo : nBaseAnual
  // Uso   : Define con que base anual se van a calcular los Intereses Sobre Prestaciones
  //
  @ 5.4,29.0 CHECKBOX OCNF:olBaseAnual  VAR OCNF:lBaseAnual  PROMPT ANSITOOEM("Base para el Cálculo de Intereses 360 ó 365");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:olBaseAnual:cMsg    :="Tildado calculara los Intereses en base a 360 días"
  OCNF:olBaseAnual:cToolTip:="Tildado calculara los Intereses en base a 360 días"    //OCNF:olBaseAnual:cMsg


  //
  // Campo : lIndexa
  // Uso   : Indexar Intereses Sobre Prestaciones
  //
  @ 5.4,29.0 CHECKBOX OCNF:olIndexaInt  VAR OCNF:lIndexaInt  PROMPT ANSITOOEM("Indizar Intereses Sobre antigüedad");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

    OCNF:olIndexaInt:cMsg    :="Indexar Intereses sobre Prestaciones Sociales"
    OCNF:olIndexaInt:cToolTip:=OCNF:olIndexaInt:cMsg 

  //
  // Campo : oCnf:lDistAnosA
  // Uso   : Distribuir Días Adicionales 
  //
  @ 5.4,29.0 CHECKBOX OCNF:olDistAnosA  VAR OCNF:lDistAnosA  PROMPT ANSITOOEM("Distribuir Días Adicionales Art.142");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10;
                     WHEN !oCnf:lH400


    OCNF:olDistAnosA:cMsg    :="Distribuir Días Adicionales"
    OCNF:olDistAnosA:cToolTip:=OCNF:olDistAnosA:cMsg 


  //
  // Campo : oCnf:lArt108Adi
  // Uso   : Distribuir Días Adicionales 
  //
  @ 5.4,29.0 CHECKBOX OCNF:olArt108Adi  VAR OCNF:lArt108Adi  PROMPT ANSITOOEM("Incluir en Nómina 2 Días Adicionales Art. 142");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10
    
    OCNF:olArt108Adi:cMsg    :="Incluir en Nómina 2 Días Adicionales Art. 142"
    OCNF:olArt108Adi:cToolTip:=OCNF:olIndexaInt:cMsg 

  //
  // Campo : oCnf:lAniverInt 
  // Uso   : Intereses en Fecha Aniversario 
  //
  @ 5.4,29.0 CHECKBOX OCNF:olAniverInt  VAR OCNF:lAniverInt  PROMPT ANSITOOEM("Pagar Intereses en Fecha Aniversario");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

    OCNF:olAniverInt:cMsg    :="Pago de Intereses en Fecha Aniversario"
    OCNF:olAniverInt:cToolTip:=OCNF:olAniverInt:cMsg 


  //
  // Campo : oCnf:lArt104 
  // Uso   : Incluir Art 104 en Liquidación 
  //
  @ 5.4,29.0 CHECKBOX OCNF:olArt104  VAR OCNF:lArt104  PROMPT ANSITOOEM("Incluir Artículo 104 en Liquidación");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

    OCNF:olArt104:cMsg    :="Incluir Artículo 104 en Liquidación"
    OCNF:olArt104:cToolTip:=OCNF:olArt104:cMsg 

  //
  // Campo : oCnf:lUtilDif 
  // Uso   : Diferir pago de Utilidades en Liquidación
  //

  @ 5.4,29.0 CHECKBOX OCNF:olUtilDif  VAR OCNF:lUtilDif  PROMPT ANSITOOEM("Diferir pago de Utilidades para Liquidación");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:olUtilDif:cMsg    :="Diferir Pago de Utilidades para Liquidación"
  OCNF:olUtilDif:cToolTip:=OCNF:olUtilDif:cMsg 

/*
// Vacaciones
*/
  SETFOLDER(3)
  //
  // Campo : cDiasVac
  // Uso   : Días de Vacaciones
  //

  @ 3.8,10.0 BMPGET oCnf:ocDiasVac  VAR oCnf:cDiasVac;
                    VALID (EMPTY(OCNF:cDiasVac) .AND. OCNF:PUTCUENTA(OCNF:cDiasVac,OCNF:OSAYDIASVAC));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocDiasVac,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cDiasVac,OCNF:OSAYDIASVAC));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocDiasVac))

  oCnf:ocDiasVac:cMsg    :="Concepto para Acumulado de Prestaciones Sociales"
  oCnf:ocDiasVac:cToolTip:= OCNF:ocDiasVac:cMsg 


  @ OCNF:ocDiasVac:nTop-08,OCNF:ocDiasVac:nLeft SAY "Días de Vacaciones:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocDiasVac:nTop,OCNF:ocDiasVac:nRight+5 SAY OCNF:OSAYDIASVAC;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cDiasVac,OCNF:OSAYDIASVAC)

  //
  // Campo : cDiasRein
  // Uso   : Reintegro de Vacaciones

  @ 3.8,10.0 BMPGET oCnf:ocDiasRein  VAR oCnf:cDiasRein;
                    VALID (EMPTY(OCNF:cDiasRein) .AND. OCNF:PUTCUENTA(OCNF:cDiasRein,OCNF:OSAYDIASREIN));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocDiasRein,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cDiasRein,OCNF:OSAYDIASREIN));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocDiasRein))

  oCnf:ocDiasRein:cMsg    :="Reintegro de Días de Vacaciones"
  oCnf:ocDiasRein:cToolTip:= OCNF:ocDiasRein:cMsg 


  @ OCNF:ocDiasRein:nTop-08,OCNF:ocDiasRein:nLeft SAY "Reintegro de Días Vacaciones:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocDiasRein:nTop,OCNF:ocDiasRein:nRight+5 SAY OCNF:OSAYDIASREIN;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cDiasRein,OCNF:OSAYDIASREIN)

  //
  // Campo : cDiasProx
  // Uso   : Proximo Disfrute
  //

  @ 3.8,10.0 BMPGET oCnf:ocDiasProx  VAR oCnf:cDiasProx;
                    VALID (EMPTY(OCNF:cDiasProx) .AND. OCNF:PUTCUENTA(OCNF:cDiasProx,OCNF:OSAYDIASPROX));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocDiasProx,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cDiasProx,OCNF:OSAYDIASPROX));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocDiasProx))

  oCnf:ocDiasProx:cMsg    :="Almacenas Días para Próximo Disfrute"
  oCnf:ocDiasProx:cToolTip:= OCNF:ocDiasProx:cMsg 


  @ OCNF:ocDiasProx:nTop-08,OCNF:ocDiasProx:nLeft SAY "Almacenar Próximo Disfrute:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocDiasProx:nTop,OCNF:ocDiasProx:nRight+5 SAY OCNF:OSAYDIASPROX;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cDiasProx,OCNF:OSAYDIASPROX)

  //
  // Campo : cDiasAdic
  // Uso   : Días Adicionales
  //
  @ 3.8,10.0 BMPGET oCnf:ocDiasAdic  VAR oCnf:cDiasAdic;
                    VALID (EMPTY(OCNF:cDiasAdic) .AND. OCNF:PUTCUENTA(OCNF:cDiasAdic,OCNF:OSAYDIASADIC));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocDiasAdic,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cDiasAdic,OCNF:OSAYDIASADIC));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocDiasAdic))

  oCnf:ocDiasAdic:cMsg    :="Concepto para Días Adicionales de Disfrute"
  oCnf:ocDiasAdic:cToolTip:= OCNF:ocDiasAdic:cMsg 

  @ OCNF:ocDiasAdic:nTop-08,OCNF:ocDiasAdic:nLeft SAY "Días Adicionales de Disfrute:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocDiasAdic:nTop,OCNF:ocDiasAdic:nRight+5 SAY OCNF:OSAYDIASADIC;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cDiasAdic,OCNF:OSAYDIASADIC)


  //
  // Campo : cDiasDisf
  // Uso   : Días Disfrutados
  //

  @ 3.8,10.0 BMPGET oCnf:ocDiasDisf  VAR oCnf:cDiasDisf;
                    VALID (EMPTY(OCNF:cDiasDisf) .AND. OCNF:PUTCUENTA(OCNF:cDiasDisf,OCNF:OSAYDISFIS));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocDiasDisf,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cDiasDisf,OCNF:OSAYDISFIS));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocDiasDisf))

  oCnf:ocDiasDisf:cMsg    :="Concepto para Dias de Vacaciones Disfrutados"
  oCnf:ocDiasDisf:cToolTip:= OCNF:ocDiasDisf:cMsg 


  @ OCNF:ocDiasDisf:nTop-08,OCNF:ocDiasDisf:nLeft SAY "Días Disfrutados:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocDiasDisf:nTop,OCNF:ocDiasDisf:nRight+5 SAY OCNF:OSAYDISFIS;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cDiasDisf,OCNF:OSAYDISFIS)

  @ 1,1 GROUP oGrp TO 4, 21.5 PROMPT "Vacaciones"    
  @ 4,  9 RADIO OCNF:nVacacion  PROMPT "&Colectiva", "&Individual" 

  @ 1,1 GROUP oGrp TO 4, 21.5 PROMPT "Bono Vacacional"    
  @ 7,  9 RADIO OCNF:nBono_VacV PROMPT "&Vacaciones", "&Aniversario" 

  @ 1,1 GROUP oGrp TO 4, 21.5 PROMPT "Periodo Vacacional"    

/*
// Inicio de Vacaciones Colectivas
*/

  @ 3.8,10.0 BMPGET oCnf:oFchIniVac VAR oCnf:dFchIniVac;
                    NAME "BITMAPS\\\\Calendar.bmp"; 
                    ACTION LbxDate(oCnf:oFchIniVac,oCnf:dFchIniVac)

  oCnf:oFchIniVac:cMsg    :="Fecha Inicial del Periodo de Vacaciones Colectivas"
  oCnf:oFchIniVac:cToolTip:=OCnf:odFchIniInt:cMsg 

/*
// Fin de Vacaciones Colectivas
*/

  @ 3.8,10.0 BMPGET oCnf:oFchFinVac VAR oCnf:dFchFinVac;
                    NAME "BITMAPS\\\\Calendar.bmp"; 
                    ACTION LbxDate(oCnf:oFchFinVac,oCnf:dFchFinVac);
                    VALID  MensajeErr("Fecha Inicial debe ser Superior a la Fecha Final",;
                                      NIL,{||!oCnf:dFchIniVac>oCnf:dFchFinVac})

  oCnf:oFchFinVac:cMsg    :="Fecha Final del Periodo de Vacaciones Colectivas"
  oCnf:oFchFinVac:cToolTip:=OCnf:oFchFinVac:cMsg 

/*
// Prestamos
*/
  SETFOLDER( 4)

  //
  // Campo : cA_Prestm
  // Uso   : Asignación Préstamo
  //

  @ 3.8,10.0 BMPGET oCnf:ocA_Prestm  VAR oCnf:cA_Prestm;
                    VALID (EMPTY(OCNF:cA_Prestm) .AND. OCNF:PUTCUENTA(OCNF:cA_Prestm,OCNF:OSAYA_PRESTM));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocA_Prestm,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cA_Prestm,OCNF:OSAYA_PRESTM));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocA_Prestm))

  oCnf:ocA_Prestm:cMsg    :="Otorgamiento de Préstamos"
  oCnf:ocA_Prestm:cToolTip:= OCNF:ocA_Prestm:cMsg 


  @ oCnf:ocA_Prestm:nTop-08,OCNF:ocA_Prestm:nLeft SAY "Otorgamiento de Préstamos:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ oCnf:ocA_Prestm:nTop,OCNF:ocA_Prestm:nRight+5 SAY OCNF:OSAYA_PRESTM;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  oCnf:SAY_CPTO(oCnf:cA_Prestm,OCnf:OSAYA_PRESTM)

  //
  // Campo : cD_Prestm
  // Uso   : Deducción Préstamo
  //
  @ 3.8,10.0 BMPGET oCnf:ocD_Prestm  VAR oCnf:cD_Prestm;
                    VALID (EMPTY(OCNF:cD_Prestm) .AND. OCNF:PUTCUENTA(OCNF:cD_Prestm,OCNF:OSAYD_PRESTM));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocD_Prestm,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cD_Prestm,OCNF:OSAYD_PRESTM));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocD_Prestm))

  oCnf:ocD_Prestm:cMsg    :="Otorgamiento de Préstamos"
  oCnf:ocD_Prestm:cToolTip:= OCNF:ocD_Prestm:cMsg 


  @ OCNF:ocD_Prestm:nTop-08,OCNF:ocD_Prestm:nLeft SAY "Deducción de Préstamos:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocD_Prestm:nTop,OCNF:ocD_Prestm:nRight+5 SAY OCNF:OSAYD_PRESTM;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  oCnf:SAY_CPTO(OCNF:cD_Prestm,OCNF:OSAYD_PRESTM)

  //
  // Campo : cI_Prestm
  // Uso   : Deducción Préstamo
  //
  @ 3.8,10.0 BMPGET oCnf:ocI_Prestm  VAR oCnf:cI_Prestm;
                    VALID (EMPTY(OCNF:cI_Prestm) .AND. OCNF:PUTCUENTA(OCNF:cI_Prestm,OCNF:OSAYI_PRESTM));
                          .OR. (OCNF:ONMCONCEPTO:SeekTable("CON_CODIGO",OCNF:ocI_Prestm,NIL);
                          .AND. OCNF:SAY_CPTO(OCNF:cI_Prestm,OCNF:OSAYI_PRESTM));
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCONCEPTOS"), oDpLbx:GetValue("CON_CODIGO",OCNF:ocI_Prestm))

  oCnf:ocI_Prestm:cMsg    :="Intereses Sobre Préstamos"
  oCnf:ocI_Prestm:cToolTip:= OCNF:ocI_Prestm:cMsg 


  @ OCNF:ocI_Prestm:nTop-08,OCNF:ocI_Prestm:nLeft SAY "Intereses sobre Préstamos:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocI_Prestm:nTop,OCNF:ocI_Prestm:nRight+5 SAY OCNF:OSAYI_PRESTM;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CPTO(OCNF:cI_Prestm,OCNF:OSAYI_PRESTM)


  //
  // Campo : oCnf:lI_Prestm  
  // Uso   : Intereses en Fecha Aniversario 
  //
  @ 5.4,29.0 CHECKBOX OCNF:olI_Prestm VAR OCNF:lI_Prestm   PROMPT ANSITOOEM("Aplicar Intereses Sobre Préstamos");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:olI_Prestm :cMsg    :="Aplicar Intereses Sobre Prestamos"
  OCNF:olI_Prestm :cToolTip:=OCNF:olI_Prestm :cMsg 

/*
// Acceso desde InterNet
*/
  SETFOLDER(5)

  //
  // Campo : oCnf:lI_Prestm  
  // Uso   : Intereses en Fecha Aniversario 
  //
  @ 5.4,29.0 CHECKBOX OCNF:olCgiOtrosC VAR OCNF:lCgiOtrosC   PROMPT ANSITOOEM("Consulta de Otros Conceptos desde DpNmWeb");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:olCgiOtrosC:cMsg    :="Conceptos Diferentes de Asignación y Deducción se pueden Consultar desde InterNet"
  OCNF:olCgiOtrosC:cToolTip:=oCNF:olCgiOtrosC:cMsg 

  //
  // Campo : oCnf:lDifSSO
  // Uso   : Diferir para Fin de Mes SSO
  //

  @ 5.4,29.0 CHECKBOX oCnf:olDifSSO VAR oCnf:lDifSSO   PROMPT ANSITOOEM("Diferir Retención S.S.O. para Fín de Mes.");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  oCnf:olDifSSO:cMsg    :="Diferir Retención del S.S.O. para Fín de Mes"
  oCnf:olDifSSO:cToolTip:=oCNF:olCgiOtrosC:cMsg 

  //
  // Campo : oCnf:lDifRPF
  // Uso   : Diferir Régimen Prestacional de Empleo para Fin de Mes RPE
  //

  @ 5.4,29.0 CHECKBOX oCnf:olDifRPF VAR oCnf:lDifRPF   PROMPT ANSITOOEM("Diferir Régimen Prestacional de Empleo para Fin de Mes");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  oCnf:olDifRPF:cMsg    :="Diferir Régimen Prestacional de Empleo para Fín de Mes"
  oCnf:olDifRPF:cToolTip:=oCNF:olCgiOtrosC:cMsg 

  //
  // Campo : oCnf:lDifLPH
  // Uso   : Diferir para Fin de Mes F.A.O.V
  //

  @ 5.4,29.0 CHECKBOX oCnf:olDifLPH VAR oCnf:lDifLPH   PROMPT ANSITOOEM("Diferir Retención F.A.O.V. para Fín de Mes.");
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  oCnf:olDifLPH:cMsg    :="Diferir Retención del F.A.O.V. para Fín de Mes"
  oCnf:olDifLPH:cToolTip:=oCNF:olCgiOtrosC:cMsg 

  SETFOLDER(6) // Débito Bancario

  //
  // Campo : DEBITO BANCARIO
  // Uso   : Billetes
  //
  @ 2.8,15.0 GET oCNF:oDebBanc  VAR oCNF:nDebBanc RIGHT PICT "999.99"

    oCNF:oDebBanc:cMsg    :="% Impuestos a las Transacciones Financieras"
    oCNF:oDebBanc:cToolTip:=oCNF:oDebBanc:cToolTip

  @ 1,1 SAY "% Débito Bancario" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  //
  // Campo : cCtaIDB
  // Uso   : Débito Bancario
  //

  @ 3.8,10.0 BMPGET oCnf:ocCtaIDB  VAR oCnf:cCtaIDB;
                    VALID (EMPTY(OCNF:cCtaIDB) .AND. OCNF:PUTCTA(OCNF:cCtaIDB,OCNF:OSAYCTA));
                          .OR. (OCNF:ONMCTA:SeekTable("CTA_CODIGO",OCNF:ocCtaIDB,NIL);
                          .AND. OCNF:SAY_CTA(OCNF:cCtaIDB,OCNF:OSAYCTA));
                          .AND. EJECUTAR("ISCTADET",OCNF:cCtaIDB);
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCTA"), oDpLbx:GetValue("CTA_CODIGO",OCNF:ocCtaIDB))

  oCnf:ocCtaIDB:cMsg    :="Cuenta Contable para I.T.F."
  oCnf:ocCtaIDB:cToolTip:= OCNF:ocCtaIDB:cMsg 

  @ OCNF:ocCtaIDB:nTop-08,OCNF:ocCtaIDB:nLeft SAY "Cuenta Contable I.T.F:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocCtaIDB:nTop,OCNF:ocCtaIDB:nRight+5 SAY OCNF:OSAYCTA;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CTA(OCNF:cCtaIDB,OCNF:OSAYCTA)

 //
  // Campo : cCTANXP
  // Uso   : Nómina por Pagar
  //

  @ 3.8,10.0 BMPGET oCnf:ocCTANXP  VAR oCnf:cCTANXP;
                    VALID (EMPTY(OCNF:cCTANXP) .AND. OCNF:PUTCTA(OCNF:cCTANXP,OCNF:OSAYCTANXP));
                          .OR. (OCNF:ONMCTA:SeekTable("CTA_CODIGO",OCNF:ocCTANXP,NIL);
                          .AND. OCNF:SAY_CTA(OCNF:cCTANXP,OCNF:OSAYCTANXP));
                          .AND. EJECUTAR("ISCTADET",OCNF:cCTANXP);
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCTA"), oDpLbx:GetValue("CTA_CODIGO",OCNF:ocCTANXP))

  oCnf:ocCTANXP:cMsg    :="Cuenta Contable para Nómina por Pagar"
  oCnf:ocCTANXP:cToolTip:= OCNF:ocCTANXP:cMsg 

  @ OCNF:ocCTANXP:nTop-08,OCNF:ocCTANXP:nLeft SAY "Cuenta Contable Nómina por Pagar:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocCTANXP:nTop,OCNF:ocCTANXP:nRight+5 SAY OCNF:OSAYCTANXP;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CTA(OCNF:cCTANXP,OCNF:OSAYCTANXP)

  //
  // Campo : cCTAEFE
  // Uso   : Efectivo en Caja
  //

  @ 3.8,10.0 BMPGET oCnf:ocCTAEFE  VAR oCnf:cCTAEFE;
                    VALID (EMPTY(OCNF:cCTAEFE) .AND. OCNF:PUTCTA(OCNF:cCTAEFE,OCNF:OSAYCTAEFE));
                          .OR. (OCNF:ONMCTA:SeekTable("CTA_CODIGO",OCNF:ocCTAEFE,NIL);
                          .AND. OCNF:SAY_CTA(OCNF:cCTAEFE,OCNF:OSAYCTAEFE));
                          .AND. EJECUTAR("ISCTADET",OCNF:cCTAEFE);
                    NAME "BITMAPS\\\\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("NMCTA"), oDpLbx:GetValue("CTA_CODIGO",OCNF:ocCTAEFE))

  oCnf:ocCTAEFE:cMsg    :="Cuenta Contable Efectivo en Caja"
  oCnf:ocCTAEFE:cToolTip:= OCNF:ocCTAEFE:cMsg 

  @ OCNF:ocCTAEFE:nTop-08,OCNF:ocCTAEFE:nLeft SAY "Cuenta Contable Efectivo en Caja:" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,NIL 

  @ OCNF:ocCTAEFE:nTop,OCNF:ocCTAEFE:nRight+5 SAY OCNF:OSAYCTAEFE;
                            PROMPT SPACE(40) PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  OCNF:SAY_CTA(OCNF:cCTAEFE,OCNF:OSAYCTAEFE)


  SETFOLDER(7)

  @ 1,0 SAY " Basado en"+CRLF+" Históricos"

  // Campo : OCNF:lSalarioA
  // Uso   : Determina la Manera para Calcular el Salario.
  //

  @ 1,1 CHECKBOX OCNF:oSalarioA    VAR OCNF:lSalarioA;
                     PROMPT ANSITOOEM(oDp:cSalarioA);
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:oSalarioA:cMsg    :="Forma para decterminar Salario "+oDp:cSalarioA
  OCNF:oSalarioA:cToolTip:="Forma para decterminar Salario "+oDp:cSalarioA+CRLF+;
                           "Histórico=Activo, Acumulado=Inactivo"



  // Campo : OCNF:lSalarioB
  // Uso   : Determina la Manera para Calcular el Salario.
  //

  @ 2,1 CHECKBOX OCNF:oSalarioB    VAR OCNF:lSalarioB;
                     PROMPT ANSITOOEM(oDp:cSalarioB);
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:oSalarioB:cMsg    :="Forma para decterminar Salario "+oDp:cSalarioB
  OCNF:oSalarioB:cToolTip:="Forma para decterminar Salario "+oDp:cSalarioB+CRLF+;
                           "Histórico=Activo, Acumulado=Inactivo"



  // Campo : OCNF:lSalarioC
  // Uso   : Determina la Manera para Calcular el Salario.
  //

  @ 3,1 CHECKBOX OCNF:oSalarioC    VAR OCNF:lSalarioC;
                     PROMPT ANSITOOEM(oDp:cSalarioC);
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:oSalarioC:cMsg    :="Forma para decterminar Salario "+oDp:cSalarioC
  OCNF:oSalarioC:cToolTip:="Forma para decterminar Salario "+oDp:cSalarioC+CRLF+;
                           "Histórico=Activo, Acumulado=Inactivo"


  // Campo : OCNF:lSalarioD
  // Uso   : Determina la Manera para Calcular el Salario.
  //

  @ 4,1 CHECKBOX OCNF:oSalarioD    VAR OCNF:lSalarioD;
                     PROMPT ANSITOOEM(oDp:cSalarioD);
                     FONT oFont COLOR nClrText,NIL SIZE NIL,10

  OCNF:oSalarioD:cMsg    :="Forma para decterminar Salario "+oDp:cSalarioD
  OCNF:oSalarioD:cToolTip:="Forma para decterminar Salario "+oDp:cSalarioD+CRLF+;
                           "Histórico=Activo, Acumulado=Inactivo"

  @ 2,10 GET OCNF:cSalario MULTI READONLY

IF .F.
ENDIF

  SETFOLDER(0)

  oCnf:Activate({||oCnf:ViewDatBar()})

RETURN NIL


/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,
   LOCAL oDlg:=oCnf:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 58,57 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          TOP PROMPT "Grabar";
          ACTION oCnf:SaveNmConfig(oCnf);
          WHEN !Empty(oCnf:cRif) .OR. oDp:cType="SGE"


   oCnf:oBtnSave:=oBtn

   IF oDp:nVersion>=5

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Adjuntar";
            FILENAME "BITMAPS\adjuntar.BMP";
            ACTION EJECUTAR("EMPRESAADJ")

   ENDIF

   IF oDp:nVersion>=6

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Pistas";
            FILENAME "BITMAPS\AUDITORIA.BMP";
            ACTION EJECUTAR("DPAUDITAEMC",NIL,"NMCONFIGEMP")

      oBtn:cToolTip:="Consulta de Auditoría por Campo"


      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             TOP PROMPT "Divisas";
             FILENAME "BITMAPS\DIVISAS.BMP";
             ACTION EJECUTAR("SETDOLARIZA")

      oBtn:cToolTip:="Asignar Valor Divisa en Recibos de Ingreso"

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Cerrar";
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oCnf:Close()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCnf:oBar:=oBar

  IF !oCnf:oColor2=NIL
    oCnf:oColor2:SetColor(NIL,oCnf:nMClrPane)
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ 0.5,44+10 SAY " Empresa" OF oBar BORDER SIZE 80,20 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
  @ 2  ,44+10 SAY oCnf:oEmpresa PROMPT " "+oDp:cEmpresa+" " OF oBar BORDER SIZE 400,20 COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont

RETURN .T.



/*
// Grabar Empresa
*/
FUNCTION SaveNmConfig(oCnf)
  LOCAL oData,nAt,cSqlData,aOld,aNew,I,nAt,cMemo,oTable


  CursorWait()

  oCnf:cRif:=STRTRAN(oCnf:cRif,"-","")

  oData:=DATASET("NOMINA","ALL")
  cSqlData:=oDp:cSql
  aOld:=ASQL(cSqlData)

  oData:Set("cTipPer"   ,oCnf:cTipPer    )  // Persona
  oData:Set("cTipCon"   ,oCnf:cTipCon    )  // Contribuyente

  oData:Set("cDir1",oCnf:cDir1   )       // Dirección 1
  oData:Set("cDir2",oCnf:cDir2   )       // Dirección 2
  oData:Set("cDir3",oCnf:cDir3   )       // Dirección 3
  oData:Set("cTel1",oCnf:cTel1   )       // Teléfono 1
  oData:Set("cTel2",oCnf:cTel2   )       // Teléfono 2
  oData:Set("cTel3",oCnf:cTel3   )       // Teléfono 2

  oData:Set("cWeb" ,oCnf:cWeb   )       // Pagina Web
  oData:Set("cMail",oCnf:cMail  )       // Mail

  oData:Set("cRif     ",oCnf:cRif     )  // Rif
  oData:Set("cMintra  ",oCnf:cMintra  )  // Ministerio del Trabajo
  oData:Set("cSSO     ",oCnf:cSSO     )  // Nº Patronal IVSS
  oData:Set("dFchInsI ",oCnf:dFchInsI )  // Fecha Inscripcion en el IVSS
  oData:Set("cRegimen ",oCnf:cRegimen )  // Regimen segun IVSS
  oData:Set("cRiesgo  ",oCnf:cRiesgo  )  // Riesgo segun IVSS


  oData:Set("cBilletes",oCnf:cBilletes)  // Billetes
  //oData:Set("cNit     ",oCnf:cNit     )  // NIT
  oData:Set("cVertical",oCnf:cVertical)  // Vertical


  oData:Set("cFchDH   ",oCnf:cFchDH    ) // Fecha: Desde o Hasta
  oData:Set("cIniSem  ",oCnf:cIniSem   ) // Inicio de la Semana 
  oData:Set("cContab  ",oCnf:cContab   ) // Contabilizar
  oData:Set("lRedondeo",oCnf:lRedondeo ) // Redondea de 5 a 0
  oData:Set("nDebBanc ",oCnf:nDebBanc  ) // Débito Bancario
  oData:Set("cCtaIDB  ",oCnf:cCtaIDB   ) // Cuenta IDB
  oData:Set("cCtaNXP  ",oCnf:cCtaNXP   ) // Nómina por Pagar
  oData:Set("cCtaEFE  ",oCnf:cCtaEFE   ) // Cuenta Efectivo

  // ? oCnf:lPascua,oData:Set("lPascua
  // Prestaciones Sociales
  oData:Set("cConPres  ",oCnf:cConPres  ) // Concepto Acumulado Prestaciones
  oData:Set("cConAdel  ",oCnf:cConAdel  ) // Adelanto de Prestaciones
  oData:Set("cConInter ",oCnf:cConInter ) // Pago de Intereses sobre Prestaciones
  oData:Set("cPagInter ",oCnf:cPagInter ) // Intereses ya Calculados sobre Antiguedad Laboral

  oData:Set("lArt104   ",oCnf:lArt104   ) // Incluye el Pago de Art104
  oData:Set("lArt108Adi",oCnf:lArt108Adi) // Incluye en Nómina Pago Dos Días Adicionales Art 104 

  oData:Set("dFchIniInt",oCnf:dFchIniInt) // Fecha Inicial para el Cálculo de Intereses.

  oData:Set("lIndexaInt",oCnf:lIndexaInt) // Indexar Intereses sobre Prestaciones
  oData:Set("lBaseAnual",oCnf:lBaseAnual) // TJB Base Calculo de Intereses 360
  oData:Set("lAniverInt",oCnf:lAniverInt) // Pago de Intereses en Fecha Aniversario
  oData:Set("lDistAnosA",oCnf:lDistAnosA) // Distribuir Dias Adicionales, SINO las coloca en el Aniversario

  oData:Set("lUtilDif"  ,oCnf:lUtilDif  )
 // oData:Set("lIndexaInt",oCnf:lIndexaInt)
  oData:Set("lPascua"   ,oCnf:lPascua   ) // Detecta Carnaval y Semana Santa

  // Vacaciones
  oCnf:lColectiva:=(oCnf:nVacacion =1)
  oCnf:lBono_VacV:=(oCnf:nBono_VacV=1)

  oData:Set("cDiasVac"  ,oCnf:cDiasVac  )      // Concepto Acumulado Prestaciones
  oData:Set("cDiasRein" ,oCnf:cDiasRein )     // Dias de Reintegro
  oData:Set("cDiasProx" ,oCnf:cDiasProx )     // Días para proximo Disfrute
  oData:Set("cDiasAdic" ,oCnf:cDiasAdic )     // Días Adicionales de Disfrute
  oData:Set("cDiasDisf" ,oCnf:cDiasDisf )     // Días disfrutados  
  oData:Set("dFchIniVac",oCnf:dFchIniVac)     // Fecha Final de Vacaciones
  oData:Set("dFchFinVac",oCnf:dFchFinVac)     // Fin del Periodo de Vacaciones

  oData:Set("lColectiva",oCnf:lColectiva)     // Colectivas o Individuales
  oData:Set("lBono_VacV",oCnf:lBono_VacV)     // Bono Vacacional

  // Préstamos
  oData:Set("cA_Prestm" ,oCnf:cA_Prestm )        // Asignación Prestamo   
  oData:Set("cD_Prestm" ,oCnf:cD_Prestm )        // Deducción Préstamo
  oData:Set("cI_Prestm" ,oCnf:cI_Prestm )        // Intereses Sobre Préstamos
  oData:Set("lI_Prestm" ,oCnf:lI_Prestm )        // Aplica intereses sobre Préstamos

  // InterNet
  oData:Set("lCgiOtrosC",oCnf:lCgiOtrosC )       // Consultar Otros Conceptos desde InterNet

  oData:Set("lDifSSO"   ,oCnf:lDifSSO   )        // Diferir SSO para Fín de Mes
  oData:Set("lDifLPH"   ,oCnf:lDifLPH   )        // Diferir LPH para Fín de Mes
  oData:Set("lDifRPF"   ,oCnf:lDifRPF   )        // Diferir RPT para Fín de Mes

  oData:Set("lSalarioA",oCnf:lSalarioA  )        // Grabar Salario A
  oData:Set("lSalarioB",oCnf:lSalarioB  )        // Grabar Salario B
  oData:Set("lSalarioC",oCnf:lSalarioC  )        // Grabar Salario C
  oData:Set("lSalarioD",oCnf:lSalarioD  )        // Grabar Salario D


  // Reconversión Monetaria 
  // oData:Set("dFchIniRec"  , oCnf:dFchIniRec )
  // oData:Set("dFchFinRec" , oCnf:dFchFinRec )
  //oData:Set("cCtaMonRec"  , oCnf:cCtaMonRec )

  oData:Set("nMClrPane" ,oCnf:nMClrPane  )  // Color del Menú en Cada Empresa

  oData:Set("cMoneda"   ,oCnf:cMoneda   )
  oData:Set("cMonedaExt",oCnf:cMonedaExt)
	
  oData:Save()
  oData:End()

  //Graba rif en dpempresa
  SQLUPDATE("DPEMPRESA","EMP_RIF",oCnf:cRif,"EMP_CODIGO"+GetWhere("=",oDp:cCodEmp)) 
  
  // Crear Pista de Auditoria JN 04/09/2014
  cMemo:=""
  aNew :=ASQL(cSqlData)
  
//  AEVAL(aOld,{|a,n| cMemo:=cMemo+IIF(Empty(cMemo),"",CRLF)+ALLTRIM(a[1])+"="})

  cMemo:=""
  FOR I=1 TO LEN(aOld)
     nAt:=ASCAN(aNew,{|a,n| aOld[I,1]=a[1]})
     IF nAt>0 .AND. !(ALLTRIM(aOld[I,2])==ALLTRIM(aNew[nAt,2]))
        cMemo:=cMemo+IF(Empty(cMemo),"",CRLF)+ALLTRIM(aNew[I,1])+"="+aOld[I,2]+CHR(9)+ALLTRIM(aNew[nAt,2])
     ENDIF
  NEXT I

  IF !Empty(cMemo)

     oTable:=OpenTable("SELECT * FROM DPAUDITAELIMOD",.F.)
     oTable:AppendBlank()
     oTable:Replace("AEM_TABLA" ,"NMCONFIGEMP") 
     oTable:Replace("AEM_CLAVE" ,"NMCONFIGEMP")
     oTable:Replace("AEM_KEY"   ,"NMCONFIGEMP")
     oTable:Replace("AEM_OPCION","M"          )
     oTable:Replace("AEM_FECHA" ,oDp:dFecha   )
     oTable:Replace("AEM_HORA"  ,TIME()       )
     oTable:Replace("AEM_MEMO"  ,cMemo        )
     oTable:Replace("AEM_ESTACI",oDp:cPcName  )
     oTable:Replace("AEM_IP"    ,oDp:cIpLocal )
     oTable:Replace("AEM_USUARI",oDp:cUsuario )
     oTable:Commit()
     oTable:End()

  ENDIF

  // fin de Pista de Auditoría

  //SQLUPDATE("DPEMPRESA","EMP_NOMBRE",oCnf:cRif,"EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))

  oDp:nBaseAnual:=IIF(oCnf:lBaseAnual, 360 , 365 )
//   ? oDp:nBaseAnual,"oDp:nBaseAnual en NMCONFIG"

  EJECUTAR("NMRESTDATA")
  oCnf:Close()

  EJECUTAR("FCH_RANGO",oDp:cTipoNom,oDp:dFecha,oDp:cOtraNom)
  EJECUTAR("DPBARMSG")

RETURN .T.

/*
// Visualizar
*/
FUNCTION SAY_CPTO(cCodCon,oSay)
   cCodCon:=SQLGET("NMCONCEPTOS","CON_DESCRI","CON_CODIGO"+GetWhere("=",cCodCon))
//   LOCAL oTable
//   oTable:=OpenTable("SELECT CON_DESCRI FROM NMCONCEPTOS WHERE CON_CODIGO"+GetWhere("=",cCodCon),.T.)
   oSay:SETTEXT(cCodCon) // oTable:CON_DESCRI)
//   oTable:End()
RETURN .T.

/*
// VisualizarDD
*/
FUNCTION SAY_CTA(cCta,oSay)

   cCta:=SQLGET("NMCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCta))
   oSay:SETTEXT(cCta)
RETURN .T.

FUNCTION PUTCTA()
RETURN .T.

FUNCTION PINTARMENU()
  oDp:nMenuItemClrPane:=oCnf:oColor2:nClrPane
  EJECUTAR("APLDEF")  
RETURN NIL

FUNCTION VAL_RIF()
RETURN oCnf:VALRIF()
 
FUNCTION VALRIF()

  LOCAL oDp:aRif:={},lOk:=.T.
  LOCAL cRif   :=ALLTRIM(oCnf:CRIF)
  LOCAL cIni   :=LEFT(cRif,1)
  LOCAL cTipPer:=""

  IF Empty(cRif)
     MensajeErr("Es necesario indicar RIF")
     DpFocus(oCnf:oCRIF)
     RETURN .F.
  ENDIF
 
  oDp:cSeniatErr:=""

  IF ISDIGIT(oCnf:CRIF)
    oCnf:cRIF:=STRZERO(VAL(oCnf:CRIF),8)
    oCnf:oCRIF:VarPut(oCnf:CRIF,.T.)
  ENDIF

  cTipPer:="N"
  cTipPer:=IIF(cIni="J","J",cTipPer)
  cTipper:=IIF(cIni="G","G",cTipPer)

  oCnf:oTipPer:Select(MAX(AT(cTipPer,"JNG"),1))
  
  IF cTipPer="G"
   // oCnf:oTipCon:Select(4) // Ente Público
  ENDIF


  MsgRun("Verificando RIF "+oCnf:CRIF,"Por Favor, Espere",;
         {|| lOk:=EJECUTAR("VALRIFSENIAT",oCnf:CRIF,NIL,!ISDIGIT(cRif)) })

  IF lOk .AND. !Empty(oDp:aRif)

        oCnf:oEmpresa:SetText(oDp:aRif[1])

	   SQLUPDATE("DPEMPRESA","EMP_NOMBRE",oDp:aRif[1],"EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))

        oDp:oFrameDp:SetText(oDp:cDpSys+" ["+ALLTRIM(oDp:aRif[1])+"]")
	/*   
        IF LEFT(oDp:aRif[3],1)="C"
           oCnf:oTipCon:Select(1)
           oCnf:oTipCon:VarPut("Ordinario",.T.)
        ENDIF
*/

/*
        IF LEFT(oDp:aRif[3],1)="E"
           oCnf:oTipCon:Select(2)
           oCnf:oTipCon:VarPut("Especial",.T.)
        ENDIF
*/


        IF oDp:cCodEmp="0000" 
        	SQLUPDATE("DPCONFIG","CON_EMPRES",oDp:aRif[1])
	   ENDIF	 

       oCnf:oBtnSave:ForWhen(.T.)

  ENDIF

RETURN lOk


// EOF

