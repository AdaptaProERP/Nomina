// Programa   : NMTRABOTROS
// Fecha/Hora : 10/08/2015 10:54:26
// Propósito  : Incluir/Modificar NMTRABOTROS
// Creado Por : DpXbase
// Llamado por: NMTRABOTROS.LBX
// Aplicación : Nómina                                  
// Tabla      : NMTRABOTROS

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION NMTRABOTROS(cCodigo,cSexo,nOption)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText,nTurno
  LOCAL cNombre
  LOCAL cTitle:="Datos Adicionales de Trabajadores",;
         aItems1:=GETOPTIONS("NMTRABOTROS","TIP_CTTO"),;
         aItems2:=GETOPTIONS("NMTRABOTROS","TIPTRAB"),;
         aItems3:=GETOPTIONS("NMTRABOTROS","TIPJOR"),;
         aItems4:=GETOPTIONS("NMTRABOTROS","FAMDISC"),;
         aItems5:=GETOPTIONS("NMTRABOTROS","LABDOM"),;
         aItems6:=GETOPTIONS("NMTRABOTROS","SINDICA"),;
         aItems7:=GETOPTIONS("NMTRABOTROS","EMBARAZO"),;
         aItems8:=GETOPTIONS("NMTRABOTROS","FIJ_DISACC"),;
         aItems9:=GETOPTIONS("NMTRABOTROS","FIJ_DISAUD"),;
         aItems10:=GETOPTIONS("NMTRABOTROS","FIJ_DISINT"),;
         aItems11:=GETOPTIONS("NMTRABOTROS","FIJ_DISMEN"),;
         aItems12:=GETOPTIONS("NMTRABOTROS","FIJ_DISMUS"),;
         aItems13:=GETOPTIONS("NMTRABOTROS","FIJ_DISVIS"),;
         aItems14:=GETOPTIONS("NMTRABOTROS","FIJ_ENFER"),;
         aItems15:=GETOPTIONS("NMTRABOTROS","FIJ_INDIGE")

  cExcluye:="CODTRA,;
             TIP_CTTO,;
             TIPTRAB,;
             TIPJOR,;
             DESCGUARD,;
             MTO_GUARD,;
             FAMDISC,;
             CODPRE,;
             ESPECIA,;
             HSEM,;
             LABDOM,;
             SINDICA,;
             CARGAFAM,;
             EMBARAZO,;
             FIJ_DISACC,;
             FIJ_DISAUD,;
             FIJ_DISINT,;
             FIJ_DISMEN,;
             FIJ_DISMUS,;
             FIJ_DISVIS,;
             FIJ_ENFER,;
             FIJ_INDIGE,;
             FIJ_DISOTR"

  IF Empty(aItems5)
     aItems5:={"No","Si"}
  ENDIF

  IF Empty(aItems1)
     aItems1:={"Fijo","Indefinido"}
  ENDIF

  DEFAULT cCodigo:="9967837"

  DEFAULT cSexo:="M"

  DEFAULT nOption:=3


  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM NMTRABOTROS WHERE ]+BuildConcat("CODTRA")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:NMTRABOTROS}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM NMTRABOTROS WHERE ]+BuildConcat("CODTRA")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Datos Adicionales de Trabajadores       "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:NMTRABOTROS}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM NMTRABOTROS]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="CODTRA" // Clave de Validación de Registro

  oNMTRABOTROS:=DPEDIT():New(cTitle,"NMTRABOTROS.edt","oNMTRABOTROS" , .F. )

  oNMTRABOTROS:nOption  :=nOption
  oNMTRABOTROS:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oNMTRABOTROS
  oNMTRABOTROS:SetScript()        // Asigna Funciones DpXbase como Metodos de oNMTRABOTROS
  oNMTRABOTROS:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oNMTRABOTROS:nClrPane:=oDp:nGris

  IF oNMTRABOTROS:nOption=1 // Incluir en caso de ser Incremental
     // oNMTRABOTROS:RepeatGet(NIL,"PRIMARY") // Repetir Valores
     
     // AutoIncremental 
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oNMTRABOTROS:CreateWindow()       // Presenta la Ventana

  oNMTRABOTROS:ViewTable("NMTRABAJADOR",,"CODIGO","CODTRA")
  oNMTRABOTROS:ViewTable("NMOCUPACION","OCU_DESCRI","OCU_CODIGO","CODPRE")
  oNMTRABOTROS:cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE),TURNO,CEDULA,SEXO","CODIGO"+GetWhere("=",cCodigo))

  oNMTRABOTROS:cTurno :=DPSQLROW(2)
  oNMTRABOTROS:NUMCED :=DPSQLROW(3)
  oNMTRABOTROS:cSexo  :=DPSQLROW(4)
  oNMTRABOTROS:HSEM   :=SQLGET("NMTABSXJ","SXJ_HORSEM","SXJ_CODIGO"+GetWhere("=",oNMTRABOTROS:cTurno))

  //
  // Campo : CODTRA    
  // Uso   : Codigo Trabajador                       
  //
  @ 1.0, 1.0 BMPGET oNMTRABOTROS:oCODTRA      VAR oNMTRABOTROS:CODTRA;
                VALID oNMTRABOTROS:ValCodTra(oNMTRABOTROS:CODTRA);
                    NAME "BITMAPS\\FIND.BMP"; 
                     ACTION (oNMTRABOTROS:ValCodTra("")); 
                    WHEN (AccessField("NMTRABOTROS","CODTRA",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0 .and. 1=0);
                    FONT oFontG;
                    SIZE 40,10

    oNMTRABOTROS:oCODTRA    :cMsg    :="Codigo Trabajador"
    oNMTRABOTROS:oCODTRA    :cToolTip:="Codigo Trabajador"

//  @ oNMTRABOTROS:oCODTRA    :nTop-08,oNMTRABOTROS:oCODTRA    :nLeft SAY oNMTRABOTROS:oNMTRABAJADOR:cSingular PIXEL;
//                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527 BORDER


  //
  // Campo : TIP_CTTO  
  // Uso   : Tipo de Contrato                        
  //
  @ 2.3, 1.0 COMBOBOX oNMTRABOTROS:oTIP_CTTO   VAR oNMTRABOTROS:TIP_CTTO   ITEMS aItems1;
                      WHEN (AccessField("NMTRABOTROS","TIP_CTTO",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oTIP_CTTO  )


    oNMTRABOTROS:oTIP_CTTO  :cMsg    :="Tipo de Contrato"
    oNMTRABOTROS:oTIP_CTTO  :cToolTip:="Tipo Contrato"

  @ oNMTRABOTROS:oTIP_CTTO  :nTop-08,oNMTRABOTROS:oTIP_CTTO  :nLeft SAY "Tipo de Contrato" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : TIPTRAB   
  // Uso   : Tipo de Trabajador                      
  //
  @ 3.6, 1.0 COMBOBOX oNMTRABOTROS:oTIPTRAB    VAR oNMTRABOTROS:TIPTRAB    ITEMS aItems2;
                      WHEN (AccessField("NMTRABOTROS","TIPTRAB",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oTIPTRAB   )


    oNMTRABOTROS:oTIPTRAB   :cMsg    :="Tipo de Trabajador"
    oNMTRABOTROS:oTIPTRAB   :cToolTip:="Tipo Trabajador"

  @ oNMTRABOTROS:oTIPTRAB   :nTop-08,oNMTRABOTROS:oTIPTRAB   :nLeft SAY "Tipo Trabajador" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527 


  //
  // Campo : TIPJOR    
  // Uso   : Jornada del Trabajador                  
  //
  @ 4.9, 1.0 COMBOBOX oNMTRABOTROS:oTIPJOR     VAR oNMTRABOTROS:TIPJOR     ITEMS aItems3;
                      WHEN (AccessField("NMTRABOTROS","TIPJOR",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oTIPJOR    )


    oNMTRABOTROS:oTIPJOR    :cMsg    :="Jornada del Trabajador"
    oNMTRABOTROS:oTIPJOR    :cToolTip:="Jornada Trabajador"

  @ oNMTRABOTROS:oTIPJOR    :nTop-08,oNMTRABOTROS:oTIPJOR    :nLeft SAY "Jornada Trabajador" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : DESCGUARD 
  // Uso   : Hijos en Guarderias                     
  //
  @ 6.7, 1.0 GET oNMTRABOTROS:oDESCGUARD   VAR oNMTRABOTROS:DESCGUARD  ;
                    WHEN (AccessField("NMTRABOTROS","DESCGUARD",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                    FONT oFontG;
                    SIZE 4,10

    oNMTRABOTROS:oDESCGUARD :cMsg    :="Hijos en Guarderias"
    oNMTRABOTROS:oDESCGUARD :cToolTip:="Hijos en Guarderias"

  @ oNMTRABOTROS:oDESCGUARD :nTop-08,oNMTRABOTROS:oDESCGUARD :nLeft SAY "Hijos en Guarderias" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : MTO_GUARD 
  // Uso   : Monto Guarderia                         
  //
  @ 8.5, 1.0 GET oNMTRABOTROS:oMTO_GUARD   VAR oNMTRABOTROS:MTO_GUARD   PICTURE "999,999.99";
                    WHEN (AccessField("NMTRABOTROS","MTO_GUARD",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                    FONT oFontG;
                    SIZE 36,10;
                  RIGHT


    oNMTRABOTROS:oMTO_GUARD :cMsg    :="Monto Guarderia"
    oNMTRABOTROS:oMTO_GUARD :cToolTip:="Monto Guarderia"

  @ oNMTRABOTROS:oMTO_GUARD :nTop-08,oNMTRABOTROS:oMTO_GUARD :nLeft SAY "Monto Guarderia" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FAMDISC   
  // Uso   : Familiar con Discapacidad               
  //
  @ 0.5,15.0 COMBOBOX oNMTRABOTROS:oFAMDISC    VAR oNMTRABOTROS:FAMDISC    ITEMS aItems4;
                      WHEN (AccessField("NMTRABOTROS","FAMDISC",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0 );
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFAMDISC   )


    oNMTRABOTROS:oFAMDISC   :cMsg    :="Familiar con Discapacidad"
    oNMTRABOTROS:oFAMDISC   :cToolTip:="Familiar C/Discapacidad"

  @ oNMTRABOTROS:oFAMDISC   :nTop-08,oNMTRABOTROS:oFAMDISC   :nLeft SAY "Familiar C/Discapacidad" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : CODPRE    
  // Uso   : Codigo Oficio                           
  //

  @ 2.3,15.0 BMPGET oNMTRABOTROS:oCODPRE      VAR oNMTRABOTROS:CODPRE    PICTURE "99999";
                  VALID oNMTRABOTROS:oNMOCUPACION:SeekTable("OCU_CODIGO",oNMTRABOTROS:oCODPRE,NIL,oNMTRABOTROS:oOCU_DESCRI);
                  NAME "BITMAPS\FIND.BMP"; 
                  ACTION (oDpLbx:=DpLbx("NMOCUPACION"), oDpLbx:GetValue("OCU_CODIGO",oNMTRABOTROS:oCODPRE));
                  WHEN (AccessField("NMTRABOTROS","CODPRE",oNMTRABOTROS:nOption);
                  .AND. oNMTRABOTROS:nOption!=0);
                  FONT oFontG;
                  SIZE 16,10;
                  CENTER



    oNMTRABOTROS:oCODPRE    :cMsg    :="Codigo Oficio"
    oNMTRABOTROS:oCODPRE    :cToolTip:="Oficio"

  @ oNMTRABOTROS:oCODPRE    :nTop-08,oNMTRABOTROS:oCODPRE    :nLeft SAY "Oficio" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527

 
  @ oNMTRABOTROS:oCODPRE:nTop,oNMTRABOTROS:oCODPRE:nLeft+5 SAY oNMTRABOTROS:oOCU_DESCRI;
                            PROMPT oNMTRABOTROS:oNMOCUPACION:OCU_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 





  //
  // Campo : ESPECIA   
  // Uso   : Especializacion                         
  //
  @ 4.1,15.0 GET oNMTRABOTROS:oESPECIA     VAR oNMTRABOTROS:ESPECIA    ;
                    WHEN (AccessField("NMTRABOTROS","ESPECIA",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                    FONT oFontG;
                    SIZE 100,10

    oNMTRABOTROS:oESPECIA   :cMsg    :="Especialización"
    oNMTRABOTROS:oESPECIA   :cToolTip:="Especialización"

  @ oNMTRABOTROS:oESPECIA   :nTop-08,oNMTRABOTROS:oESPECIA   :nLeft SAY "Especialización" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : HSEM      
  // Uso   : Horas Promedio Semanal                  
  //
  @ 5.9,15.0 GET oNMTRABOTROS:oHSEM        VAR oNMTRABOTROS:HSEM        PICTURE "99";
                    WHEN (AccessField("NMTRABOTROS","HSEM",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0 .AND. 1=0);
                    FONT oFontG;
                    SIZE 8,10;
                  RIGHT


    oNMTRABOTROS:oHSEM      :cMsg    :="Horas Promedio Semanal"
    oNMTRABOTROS:oHSEM      :cToolTip:="Horas Promedio Semanal"

  @ oNMTRABOTROS:oHSEM      :nTop-08,oNMTRABOTROS:oHSEM      :nLeft SAY "Horas Prom. Semanal" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : LABDOM    
  // Uso   : Labora los Domingos                     
  //
  @ 7.2,15.0 COMBOBOX oNMTRABOTROS:oLABDOM     VAR oNMTRABOTROS:LABDOM     ITEMS aItems5;
                      WHEN (AccessField("NMTRABOTROS","LABDOM",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oLABDOM    )


    oNMTRABOTROS:oLABDOM    :cMsg    :="Labora los Domingos"
    oNMTRABOTROS:oLABDOM    :cToolTip:="Labora Domingos?"

  @ oNMTRABOTROS:oLABDOM    :nTop-08,oNMTRABOTROS:oLABDOM    :nLeft SAY "Labora Domingos?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : SINDICA   
  // Uso   : Sindicalizado                           
  //
  @ 8.5,15.0 COMBOBOX oNMTRABOTROS:oSINDICA    VAR oNMTRABOTROS:SINDICA    ITEMS aItems6;
                      WHEN (AccessField("NMTRABOTROS","SINDICA",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oSINDICA   )


    oNMTRABOTROS:oSINDICA   :cMsg    :="Sindicalizado"
    oNMTRABOTROS:oSINDICA   :cToolTip:="Sindicalizado?"

  @ oNMTRABOTROS:oSINDICA   :nTop-08,oNMTRABOTROS:oSINDICA   :nLeft SAY "Sindicalizado?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : CARGAFAM  
  // Uso   : Numero de Carga Familiar                
  //
  @ 10.3,15.0 GET oNMTRABOTROS:oCARGAFAM    VAR oNMTRABOTROS:CARGAFAM    PICTURE "99";
                    WHEN (AccessField("NMTRABOTROS","CARGAFAM",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                    FONT oFontG;
                    SIZE 8,10;
                  RIGHT


    oNMTRABOTROS:oCARGAFAM  :cMsg    :="Numero de Carga Familiar"
    oNMTRABOTROS:oCARGAFAM  :cToolTip:="Nro.Carga Familiar"

  @ oNMTRABOTROS:oCARGAFAM  :nTop-08,oNMTRABOTROS:oCARGAFAM  :nLeft SAY "Nro. Carga Familiar" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : EMBARAZO  
  // Uso   : Esta Embarazada                         
  //
  @ 0.5,29.0 COMBOBOX oNMTRABOTROS:oEMBARAZO   VAR oNMTRABOTROS:EMBARAZO   ITEMS aItems7;
                      WHEN (AccessField("NMTRABOTROS","EMBARAZO",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0 .AND. oNMTRABOTROS:cSexo='F');
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oEMBARAZO  )


    oNMTRABOTROS:oEMBARAZO  :cMsg    :="Esta Embarazada"
    oNMTRABOTROS:oEMBARAZO  :cToolTip:="Embarazada?"

  @ oNMTRABOTROS:oEMBARAZO  :nTop-08,oNMTRABOTROS:oEMBARAZO  :nLeft SAY "Embarazada?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527



  @ 2.3,20.0 GROUP oNMTRABOTROS:oGroup TO 7.3,25 PROMPT "Datos Fijos";
                      FONT oFontG

  //
  // Campo : FIJ_DISACC
  // Uso   : Tiene Discapacidad por Accidente        
  //
  @ 1.8,20.0 COMBOBOX oNMTRABOTROS:oFIJ_DISACC VAR oNMTRABOTROS:FIJ_DISACC ITEMS aItems8;
                      WHEN (AccessField("NMTRABOTROS","FIJ_DISACC",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_DISACC)


    oNMTRABOTROS:oFIJ_DISACC:cMsg    :="Tiene Discapacidad por Accidente"
    oNMTRABOTROS:oFIJ_DISACC:cToolTip:="Discapacidad P/Accidente?"

  @ oNMTRABOTROS:oFIJ_DISACC:nTop-08,oNMTRABOTROS:oFIJ_DISACC:nLeft SAY "Discapacidad P/Accidente?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_DISAUD
  // Uso   : Tiene Discapacidad Auditiva             
  //
  @ 3.1,20.0 COMBOBOX oNMTRABOTROS:oFIJ_DISAUD VAR oNMTRABOTROS:FIJ_DISAUD ITEMS aItems9;
                      WHEN (AccessField("NMTRABOTROS","FIJ_DISAUD",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_DISAUD)


    oNMTRABOTROS:oFIJ_DISAUD:cMsg    :="Tiene Discapacidad Auditiva"
    oNMTRABOTROS:oFIJ_DISAUD:cToolTip:="Discapacidad Auditiva?"

  @ oNMTRABOTROS:oFIJ_DISAUD:nTop-08,oNMTRABOTROS:oFIJ_DISAUD:nLeft SAY "Discapacidad Auditiva?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_DISINT
  // Uso   : Tiene Discapacidad Intelectual          
  //
  @ 4.4,20.0 COMBOBOX oNMTRABOTROS:oFIJ_DISINT VAR oNMTRABOTROS:FIJ_DISINT ITEMS aItems10;
                      WHEN (AccessField("NMTRABOTROS","FIJ_DISINT",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_DISINT)


    oNMTRABOTROS:oFIJ_DISINT:cMsg    :="Tiene Discapacidad Intelectual"
    oNMTRABOTROS:oFIJ_DISINT:cToolTip:="Discapacidad Intelectual?"

  @ oNMTRABOTROS:oFIJ_DISINT:nTop-08,oNMTRABOTROS:oFIJ_DISINT:nLeft SAY "Discapacidad Intelectual?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_DISMEN
  // Uso   : Tiene Discapacidad Mental               
  //
  @ 5.7,20.0 COMBOBOX oNMTRABOTROS:oFIJ_DISMEN VAR oNMTRABOTROS:FIJ_DISMEN ITEMS aItems11;
                      WHEN (AccessField("NMTRABOTROS","FIJ_DISMEN",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_DISMEN)


    oNMTRABOTROS:oFIJ_DISMEN:cMsg    :="Tiene Discapacidad Mental"
    oNMTRABOTROS:oFIJ_DISMEN:cToolTip:="Discapacidad Mental?"

  @ oNMTRABOTROS:oFIJ_DISMEN:nTop-08,oNMTRABOTROS:oFIJ_DISMEN:nLeft SAY "Discapacidad Mental?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_DISMUS
  // Uso   : Tiene Discapacidad Muscular             
  //
  @ 7.0,20.0 COMBOBOX oNMTRABOTROS:oFIJ_DISMUS VAR oNMTRABOTROS:FIJ_DISMUS ITEMS aItems12;
                      WHEN (AccessField("NMTRABOTROS","FIJ_DISMUS",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_DISMUS)


    oNMTRABOTROS:oFIJ_DISMUS:cMsg    :="Tiene Discapacidad Muscular"
    oNMTRABOTROS:oFIJ_DISMUS:cToolTip:="Discapacidad Muscular?"

  @ oNMTRABOTROS:oFIJ_DISMUS:nTop-08,oNMTRABOTROS:oFIJ_DISMUS:nLeft SAY "Discapacidad Muscular?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_DISVIS
  // Uso   : Tiene Discapacidad Visual               
  //
  @ 8.3,20.0 COMBOBOX oNMTRABOTROS:oFIJ_DISVIS VAR oNMTRABOTROS:FIJ_DISVIS ITEMS aItems13;
                      WHEN (AccessField("NMTRABOTROS","FIJ_DISVIS",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_DISVIS)


    oNMTRABOTROS:oFIJ_DISVIS:cMsg    :="Tiene Discapacidad Visual"
    oNMTRABOTROS:oFIJ_DISVIS:cToolTip:="Discapacidad Visual?"

  @ oNMTRABOTROS:oFIJ_DISVIS:nTop-08,oNMTRABOTROS:oFIJ_DISVIS:nLeft SAY "Discapacidad Visual?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_ENFER 
  // Uso   : Enfermedad Laboral                      
  //
  @ 0.5,34.0 COMBOBOX oNMTRABOTROS:oFIJ_ENFER  VAR oNMTRABOTROS:FIJ_ENFER  ITEMS aItems14;
                      WHEN (AccessField("NMTRABOTROS","FIJ_ENFER",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_ENFER )


    oNMTRABOTROS:oFIJ_ENFER :cMsg    :="Enfermedad Laboral"
    oNMTRABOTROS:oFIJ_ENFER :cToolTip:="Enfermedad Laboral?"

  @ oNMTRABOTROS:oFIJ_ENFER :nTop-08,oNMTRABOTROS:oFIJ_ENFER :nLeft SAY "Enfermedad Laboral?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_INDIGE
  // Uso   : Es Indigena                             
  //
  @ 1.8,20.0 COMBOBOX oNMTRABOTROS:oFIJ_INDIGE VAR oNMTRABOTROS:FIJ_INDIGE ITEMS aItems15;
                      WHEN (AccessField("NMTRABOTROS","FIJ_INDIGE",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                      FONT oFontG;


 ComboIni(oNMTRABOTROS:oFIJ_INDIGE)


    oNMTRABOTROS:oFIJ_INDIGE:cMsg    :="Es Indigena"
    oNMTRABOTROS:oFIJ_INDIGE:cToolTip:="Es Indigena?"

  @ oNMTRABOTROS:oFIJ_INDIGE:nTop-08,oNMTRABOTROS:oFIJ_INDIGE:nLeft SAY "Es Indigena?" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : FIJ_DISOTR
  // Uso   : Tiene Otra Discapacidad                 
  //
  @ 3.6,20.0 GET oNMTRABOTROS:oFIJ_DISOTR  VAR oNMTRABOTROS:FIJ_DISOTR ;
                    WHEN (AccessField("NMTRABOTROS","FIJ_DISOTR",oNMTRABOTROS:nOption);
                    .AND. oNMTRABOTROS:nOption!=0);
                    FONT oFontG;
                    SIZE 100,10

    oNMTRABOTROS:oFIJ_DISOTR:cMsg    :="Tiene Otra Discapacidad"
    oNMTRABOTROS:oFIJ_DISOTR:cToolTip:="Otra Discapacidad"

  @ oNMTRABOTROS:oFIJ_DISOTR:nTop-08,oNMTRABOTROS:oFIJ_DISOTR:nLeft SAY "Otra Discapacidad" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527




  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMTRABOTROS:Save(),oNMTRABOTROS:Cancel()) CANCEL

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oNMTRABOTROS:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMTRABOTROS:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF

  @ 5,25 SAY oNMTRABOTROS:oNombre  PROMPT oNMTRABOTROS:cNombre

  IF !EMPTY(cCodigo)
    oNMTRABOTROS:oCODTRA:VarPut(cCodigo)
    oNMTRABOTROS:oCODTRA:Refresh(.T.)
    oNMTRABOTROS:ValCodTra(cCodigo)
  ENDIF
  oNMTRABOTROS:Activate(NIL)

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oNMTRABOTROS

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()


  IF oNMTRABOTROS:nOption=1 // Incluir en caso de ser Incremental
     
     // AutoIncremental 
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

FUNCTION INI(cCodTra)
LOCAL cSql, oTable


   cSql:="SELECT * FROM NMTRABOTROS "+CRLF+;
         "WHERE CODTRA"+GetWhere("=",cCodTra)
   oTable:=OpenTable(cSql,.T.)

   IF !oTable:Eof()
     oNMTRABOTROS:nOption:=3

     oNMTRABOTROS:oTIPTRAB:VarPut(oTable:TIPTRAB)
     oNMTRABOTROS:oTIPTRAB:Refresh()
     oNMTRABOTROS:oTIPJOR:VarPut(oTable:TIPJOR)
     oNMTRABOTROS:oTIPJOR:Refresh()
     oNMTRABOTROS:oTIP_CTTO:VarPut(oTable:TIP_CTTO)
     oNMTRABOTROS:oTIP_CTTO:Refresh()
     oNMTRABOTROS:oMTO_GUARD:VarPut(oTable:MTO_GUARD)
     oNMTRABOTROS:oMTO_GUARD:Refresh()
     oNMTRABOTROS:oFAMDISC:VarPut(oTable:FAMDISC)
     oNMTRABOTROS:oFAMDISC:Refresh()
     oNMTRABOTROS:oESPECIA:VarPut(oTable:ESPECIA)
     oNMTRABOTROS:oESPECIA:Refresh()
     //oNMTRABOTROS:oHSEM:VarPut(oTable:HSEM)
     //oNMTRABOTROS:oHSEM:Refresh()
     oNMTRABOTROS:oLABDOM:VarPut(oTable:LABDOM)
     oNMTRABOTROS:oLABDOM:Refresh()
     oNMTRABOTROS:oDESCGUARD:VarPut(oTable:DESCGUARD)
     oNMTRABOTROS:oDESCGUARD:Refresh()
     oNMTRABOTROS:oSINDICA:VarPut(oTable:SINDICA)
     oNMTRABOTROS:oSINDICA:Refresh()
     oNMTRABOTROS:oCARGAFAM:VarPut(oTable:CARGAFAM)
     oNMTRABOTROS:oCARGAFAM:Refresh()
     oNMTRABOTROS:oEMBARAZO:VarPut(oTable:EMBARAZO)
     oNMTRABOTROS:oEMBARAZO:Refresh()
     oNMTRABOTROS:oFIJ_ENFER:VarPut(oTable:FIJ_ENFER)
     oNMTRABOTROS:oFIJ_ENFER:Refresh()
     oNMTRABOTROS:oFIJ_INDIGE:VarPut(oTable:FIJ_INDIGE)
     oNMTRABOTROS:oFIJ_INDIGE:Refresh()
     oNMTRABOTROS:oFIJ_DISAUD:VarPut(oTable:FIJ_DISAUD)
     oNMTRABOTROS:oFIJ_DISAUD:Refresh()
     oNMTRABOTROS:oFIJ_DISVIS:VarPut(oTable:FIJ_DISVIS)
     oNMTRABOTROS:oFIJ_DISVIS:Refresh()
     oNMTRABOTROS:oFIJ_DISINT:VarPut(oTable:FIJ_DISINT)
     oNMTRABOTROS:oFIJ_DISINT:Refresh()
     oNMTRABOTROS:oFIJ_DISMEN:VarPut(oTable:FIJ_DISMEN)
     oNMTRABOTROS:oFIJ_DISMEN:Refresh()
     oNMTRABOTROS:oFIJ_DISMUS:VarPut(oTable:FIJ_DISMUS)
     oNMTRABOTROS:oFIJ_DISMUS:Refresh()
     oNMTRABOTROS:oFIJ_DISOTR:VarPut(IF(EMPTY(oTable:FIJ_DISOTR),SPACE(25),oTable:FIJ_DISOTR))
     oNMTRABOTROS:oFIJ_DISOTR:Refresh()
     oNMTRABOTROS:oFIJ_DISACC:VarPut(oTable:FIJ_DISACC)
     oNMTRABOTROS:oFIJ_DISACC:Refresh()
  ENDIF
RETURN .T.

/*
// Valida Código del Trabajador
*/
FUNCTION ValCodTra(cCodTra)
  LOCAL aTitles,uValue,cSql,cNombre
  LOCAL oTable

  cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))

  oNMTRABOTROS:oNombre:VarPut(cNombre)
  oNMTRABOTROS:oNombre:Refresh(.T.)

  IF cCodTra=SQLGET("NMTRABAJADOR","CODIGO","CODIGO"+GetWhere("=",cCodTra))
     cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))
     oNMTRABOTROS:oNombre:VarPut(cNombre)
     oNMTRABOTROS:oNombre:Refresh(.T.)
     DPFOCUS(oNMTRABOTROS:oCODTRA)
     oNMTRABOTROS:INI(cCodTra)
     RETURN .T.
  ENDIF

  aTitles:={"Código","Apellido","Nombre"}

  cSql   :="SELECT CODIGO,APELLIDO,NOMBRE FROM NMTRABAJADOR "+;
           "WHERE CONDICION='A'"

 

  uValue :=EJECUTAR("SQLLIST",cSql,NIL,aTitles)

  IF !Empty(uValue)

     cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",uValue))
     oNMTRABOTROS:oNombre:VarPut(cNombre)
     oNMTRABOTROS:oNombre:Refresh(.T.)
     DPFOCUS(oNMTRABOTROS:oCODTRA)

  ENDIF

RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  IF EMPTY(oNMTRABOTROS:CODTRA    ) // Clave de Validación de Registro
     MensajeErr("Registro no debe estar Vacío")
     RETURN .F.
  ENDIF

  // Condiciones para no Repetir el Registro

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
RETURN .T.

/*
<LISTA:CODTRA:N:BMPGETL:N:N:Y:Codigo Trabajador,TIP_CTTO:N:COMBO:N:N:Y:Tipo de Contrato,TIPTRAB:N:COMBO:N:N:Y:Tipo de Trabajador,TIPJOR:N:COMBO:N:N:Y:Jornada del Trabajador
,DESCGUARD:N:GET:N:N:Y:Hijos en Guarderias,MTO_GUARD:N:GET:N:N:Y:Monto Guarderia,FAMDISC:N:COMBO:N:N:Y:Familiar con Discapacidad,CODPRE:N:GET:N:N:Y:Codigo Oficio
,ESPECIA:N:GET:N:N:Y:Especializacion,HSEM:N:GET:N:N:Y:Horas Promedio Semanal,LABDOM:N:COMBO:N:N:Y:Labora los Domingos,SINDICA:N:COMBO:N:N:Y:Sindicalizado
,CARGAFAM:N:GET:N:N:Y:Numero de Carga Familiar,EMBARAZO:N:COMBO:N:N:Y:Esta Embarazada,@Grupo01:N:GROUP:N:N:N:Grupo01,FIJ_DISACC:N:COMBO:N:N:Y:Tiene Discapacidad por Accidente
,FIJ_DISAUD:N:COMBO:N:N:Y:Tiene Discapacidad Auditiva,FIJ_DISINT:N:COMBO:N:N:Y:Tiene Discapacidad Intelectual,FIJ_DISMEN:N:COMBO:N:N:Y:Tiene Discapacidad Mental,FIJ_DISMUS:N:COMBO:N:N:Y:Tiene Discapacidad Muscular
,FIJ_DISVIS:N:COMBO:N:N:Y:Tiene Discapacidad Visual,FIJ_ENFER:N:COMBO:N:N:Y:Enfermadad Laboral,FIJ_INDIGE:N:COMBO:N:N:Y:Es Indigena,FIJ_DISOTR:N:GET:N:N:Y:Tiene Otra Discapacidad
>
*/

