// Programa   : NMTRABGUARD
// Fecha/Hora : 24/04/2005 02:14:44
// Propósito  : Incluir/Modificar NMTRABGUARD
// Creado Por : DpXbase
// Llamado por: NMTRABGUARD.LBX
// Aplicación : Nómina                                  
// Tabla      : NMTRABGUARD

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION NMTRABGUARD(nOption,cNumero,cCodTra)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,oDpLbx
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cCodGua,cParent,cApellido,cNombre,dDesde,dHasta
  LOCAL cTitle:="Registro de Guardería",;
        aItems1:={},;
        aItems2:={}

  DEFAULT nOption:=1,cCodTra:="1002",cNumero:=""

//  ? CNS(96),"96",cNumero,cCodTra

  nClrText:=10485760 // Color del texto

  oDpLbx:=GetDpLbx(oDp:nNumLbx)

  cNombre  :=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))

  cSql     :=[SELECT * FROM NMTRABGUARD WHERE GXT_NUMERO]+GetWhere("=",cNumero)+[ ]+;
                                       [  AND GXT_CODTRA]+GetWhere("=",cCodTra)

  cTitle   :=" Incluir {oDp:NMTRABGUARD}"
  oTable   :=OpenTable(cSql,.T.)

  IF nOption=1

     cNumero:=SQLGETMAX("NMTRABGUARD","GXT_NUMERO","GXT_CODTRA"+GetWhere("=",cCodTra))
     cNumero:=STRZERO(VAL(cNumero)+1,LEN(cNumero))

     aItems1:=aTable("SELECT FAM_PARENT FROM NMFAMILIA WHERE FAM_CODTRA"+GetWhere("=",cCodTra)+;
                     " AND LEFT(FAM_PARENT,3)='Hij' "+;
                     " GROUP BY FAM_PARENT")

     IF Empty(aItems1)
        MensajeErr("Trabajador "+cCodTra+" no Posee Familiares Registrados")
        RETURN .F.
     ENDIF

     aItems2 :=aTable("SELECT CONCAT(FAM_APELLI,',',FAM_NOMBRE) FROM NMFAMILIA WHERE FAM_CODTRA"+GetWhere("=",cCodTra)+;
                      " AND FAM_PARENT"+GetWhere("=",aItems1[1]))

  ENDIF

  IF nOption!=1
// .AND. oTable:RecCount()=0 // Genera Cursor Vacio
//
//     oTable:End()
//     cSql     :=[SELECT * FROM NMTRABGUARD]
//     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
//  ELSE

     cTitle :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:NMTRABGUARD}"
     aItems1:={}
     AADD(aItems1,oTable:GXT_PARENT)
     aItems2:={}
     AADD(aItems2,ALLTRIM(oTable:GXT_APELLI)+','+ALLTRIM(oTable:GXT_NOMBRE))

  ENDIF

  oTable:cPrimary:="GXT_CODTRA,GXT_NUMERO" // Clave de Validación de Registro

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  oNMTRABGUARD:=DPEDIT():New(cTitle,"NMTRABGUARD.edt","oNMTRABGUARD" , .F. )

  oNMTRABGUARD:nOption  :=nOption
  oNMTRABGUARD:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oNMTRABGUARD
  oNMTRABGUARD:SetScript()        // Asigna Funciones DpXbase como Metodos de oNMTRABGUARD
  oNMTRABGUARD:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oNMTRABGUARD:nClrPane  :=oDp:nGris
  oNMTRABGUARD:GXT_CODTRA:=cCodTra
  oNMTRABGUARD:cNombre   :=cNombre

  IF oNMTRABGUARD:nOption=1 // Incluir en caso de ser Incremental
//     oNMTRABGUARD:RepeatGet(NIL,"GXT_CODGUA") // Repetir Valores
     oNMTRABGUARD:GXT_CODGUA:=oTable:GXT_CODGUA
     // AutoIncremental 
  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oNMTRABGUARD:CreateWindow()       // Presenta la Ventana

  oNMTRABGUARD:ViewTable("NMGUARDERIAS","GRD_NOMBRE","GRD_CODIGO","GXT_CODGUA")

  @ .5,1 GROUP oNMTRABGUARD:oGrupo1 TO 4, 21.5 PROMPT " Trabajador "    
  @ 02,1 GROUP oNMTRABGUARD:oGrupo2 TO 4, 21.5 PROMPT " Registro de Guardería "+cNumero+" "    

 

  //
  // Campo : GXT_CODGUA
  // Uso   : Guardería                               
  //
  @ 1.0, 1.0 BMPGET oNMTRABGUARD:oGXT_CODGUA  VAR oNMTRABGUARD:GXT_CODGUA ;
                VALID oNMTRABGUARD:oNMGUARDERIAS:SeekTable("GRD_CODIGO",oNMTRABGUARD:oGXT_CODGUA,NIL,oNMTRABGUARD:oGRD_NOMBRE);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("NMGUARDERIAS"), oDpLbx:GetValue("GRD_CODIGO",oNMTRABGUARD:oGXT_CODGUA)); 
                    WHEN (AccessField("NMTRABGUARD","GXT_CODGUA",oNMTRABGUARD:nOption);
                    .AND. oNMTRABGUARD:nOption!=0);
                    FONT oFontG;
                    SIZE 24,10

    oNMTRABGUARD:oGXT_CODGUA:cMsg    :="Guardería"
    oNMTRABGUARD:oGXT_CODGUA:cToolTip:="Guardería"

  @ oNMTRABGUARD:oGXT_CODGUA:nTop-08,oNMTRABGUARD:oGXT_CODGUA:nLeft SAY oNMTRABGUARD:oNMGUARDERIAS:cSingular PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527

//oNMTRABGUARD:oNMGUARDERIAS:cSingular
  @ oNMTRABGUARD:oGXT_CODGUA:nTop,oNMTRABGUARD:oGXT_CODGUA:nRight+5 SAY oNMTRABGUARD:oGRD_NOMBRE;
                            PROMPT oNMTRABGUARD:oNMGUARDERIAS:GRD_NOMBRE PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 

  //
  // Campo : GXT_PARENT
  // Uso   : Parentesco                              
  //
  @ 2.3, 1.0 COMBOBOX oNMTRABGUARD:oGXT_PARENT VAR oNMTRABGUARD:GXT_PARENT ITEMS aItems1;
                      WHEN (AccessField("NMTRABGUARD","GXT_PARENT",oNMTRABGUARD:nOption);
                     .AND. oNMTRABGUARD:nOption!=0);
                      ON CHANGE oNMTRABGUARD:PAREN_CHANGE();
                      FONT oFontG;


 ComboIni(oNMTRABGUARD:oGXT_PARENT)


    oNMTRABGUARD:oGXT_PARENT:cMsg    :="Parentesco"
    oNMTRABGUARD:oGXT_PARENT:cToolTip:="Parentesco"

  @ oNMTRABGUARD:oGXT_PARENT:nTop-08,oNMTRABGUARD:oGXT_PARENT:nLeft SAY "Parentesco" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : GXT_APELLI
  // Uso   : Apellido                                
  //
  @ 3.6, 1.0 COMBOBOX oNMTRABGUARD:oGXT_APELLI VAR oNMTRABGUARD:GXT_APELLI ITEMS aItems2;
                      ON CHANGE oNMTRABGUARD:GXTAPELLI(oNMTRABGUARD:GXT_APELLI);
                      WHEN (AccessField("NMTRABGUARD","GXT_APELLI",oNMTRABGUARD:nOption);
                     .AND. oNMTRABGUARD:nOption!=0);
                      FONT oFontG;


  ComboIni(oNMTRABGUARD:oGXT_APELLI)


    oNMTRABGUARD:oGXT_APELLI:cMsg    :="Apellido"
    oNMTRABGUARD:oGXT_APELLI:cToolTip:="Apellido"

  @ oNMTRABGUARD:oGXT_APELLI:nTop-08,oNMTRABGUARD:oGXT_APELLI:nLeft SAY "Apellido" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : GXT_DESDE 
  // Uso   : Desde                                   
  //
  @ 5.4, 1.0 BMPGET oNMTRABGUARD:oGXT_DESDE   VAR oNMTRABGUARD:GXT_DESDE   PICTURE "99/99/9999";
             NAME "BITMAPS\Calendar.bmp";
             VALID !Empty(oNMTRABGUARD:GXT_DESDE);
             ACTION LbxDate(oNMTRABGUARD:oGXT_DESDE,oNMTRABGUARD:GXT_DESDE);
                    WHEN (AccessField("NMTRABGUARD","GXT_DESDE",oNMTRABGUARD:nOption);
                    .AND. oNMTRABGUARD:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oNMTRABGUARD:oGXT_DESDE :cMsg    :="Desde"
    oNMTRABGUARD:oGXT_DESDE :cToolTip:="Desde"

  @ oNMTRABGUARD:oGXT_DESDE :nTop-08,oNMTRABGUARD:oGXT_DESDE :nLeft SAY "Desde" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : GXT_HASTA 
  // Uso   : Hasta                                   
  //
  @ 7.2, 1.0 BMPGET oNMTRABGUARD:oGXT_HASTA   VAR oNMTRABGUARD:GXT_HASTA   PICTURE "99/99/9999";
             NAME "BITMAPS\Calendar.bmp";
             VALID (oNMTRABGUARD:GXT_DESDE<=oNMTRABGUARD:GXT_HASTA);
             ACTION LbxDate(oNMTRABGUARD:oGXT_HASTA,oNMTRABGUARD:GXT_HASTA);
                    WHEN (AccessField("NMTRABGUARD","GXT_HASTA",oNMTRABGUARD:nOption);
                    .AND. oNMTRABGUARD:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oNMTRABGUARD:oGXT_HASTA :cMsg    :="Hasta"
    oNMTRABGUARD:oGXT_HASTA :cToolTip:="Hasta"

  @ oNMTRABGUARD:oGXT_HASTA :nTop-08,oNMTRABGUARD:oGXT_HASTA :nLeft SAY "Hasta" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527


  //
  // Campo : GXT_MONTO 
  // Uso   : Mensual                                 
  //
  @ 9.0, 1.0 GET oNMTRABGUARD:oGXT_MONTO   VAR oNMTRABGUARD:GXT_MONTO   PICTURE "9999999999999.99";
                    VALID oNMTRABGUARD:GXT_MONTO>0;
                    WHEN (AccessField("NMTRABGUARD","GXT_MONTO",oNMTRABGUARD:nOption);
                    .AND. oNMTRABGUARD:nOption!=0);
                    FONT oFontG;
                    SIZE 64,10;
                  RIGHT


    oNMTRABGUARD:oGXT_MONTO :cMsg    :="Mensual"
    oNMTRABGUARD:oGXT_MONTO :cToolTip:="Mensual"

  @ oNMTRABGUARD:oGXT_MONTO :nTop-08,oNMTRABGUARD:oGXT_MONTO :nLeft SAY "Mensual" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527 RIGHT


  @ 1,1 SAY oNMTRABGUARD:cNombre


  //
  // Campo : GXT_MTOINS
  // Uso   : Mensual Inscripción                                
  //
  @ 9.0, 1.0 GET oNMTRABGUARD:oGXT_MTOINS   VAR oNMTRABGUARD:GXT_MTOINS   PICTURE "9999999999999.99";
                    VALID oNMTRABGUARD:GXT_MTOINS>=0;
                    WHEN (AccessField("NMTRABGUARD","GXT_MTOINS",oNMTRABGUARD:nOption);
                    .AND. oNMTRABGUARD:nOption!=0);
                    FONT oFontG;
                    SIZE 64,10;
                  RIGHT


    oNMTRABGUARD:oGXT_MTOINS:cMsg    :="Monto de Inscripción"
    oNMTRABGUARD:oGXT_MTOINS:cToolTip:="Monto de Inscripción"

  @ oNMTRABGUARD:oGXT_MTOINS:nTop-08,oNMTRABGUARD:oGXT_MTOINS :nLeft SAY "Inscripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527 RIGHT


  //
  // Campo : GXT_FCHINS
  // Uso   : Mensual Inscripción                                
  //
  @ 7.2, 1.0 BMPGET oNMTRABGUARD:oGXT_FCHINS   VAR oNMTRABGUARD:GXT_FCHINS   PICTURE "99/99/9999";
             NAME "BITMAPS\Calendar.bmp";
             VALID IIF(!Empty(oNMTRABGUARD:GXT_MTOINS),!Empty(oNMTRABGUARD:GXT_FCHINS),.T.);
             ACTION LbxDate(oNMTRABGUARD:oGXT_FCHINS,oNMTRABGUARD:GXT_FCHINS);
                    WHEN (AccessField("NMTRABGUARD","GXT_FCHINS",oNMTRABGUARD:nOption);
                    .AND. oNMTRABGUARD:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oNMTRABGUARD:oGXT_FCHINS :cMsg    :="Fecha del Pago para la Inscripción"
    oNMTRABGUARD:oGXT_FCHINS :cToolTip:="Fecha del Pago para la Inscripción"

  @ oNMTRABGUARD:oGXT_FCHINS :nTop-08,oNMTRABGUARD:oGXT_FCHINS :nLeft SAY "Fecha de Pago"+CRLF+"Inscripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,15724527 RIGHT

  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMTRABGUARD:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oNMTRABGUARD:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oNMTRABGUARD:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF

  oNMTRABGUARD:Activate(NIL)

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oNMTRABGUARD

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oNMTRABGUARD:nOption=1 // Incluir en caso de ser Incremental
     
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
  LOCAL lResp:=.T.,oTable,cNumero

  // Condiciones para no Repetir el Registro

  oTable:=OpenTable("SELECT FAM_APELLI,FAM_NOMBRE FROM NMFAMILIA "+;
                    "HAVING CONCAT(FAM_APELLI,',',FAM_NOMBRE)"+GetWhere("=",oNMTRABGUARD:GXT_APELLI))

  oNMTRABGUARD:GXT_APELLI:=oTable:FAM_APELLI
  oNMTRABGUARD:GXT_NOMBRE:=oTable:FAM_NOMBRE

  oTable:End()

  IF EMPTY(oNMTRABGUARD:GXT_DESDE) .OR. EMPTY(oNMTRABGUARD:GXT_HASTA)
     MensajeErr("Fecha no puede estar Vacía")
     RETURN .F.
  ENDIF


  IF oNMTRABGUARD:nOption=1
     cNumero:=SQLGETMAX("NMTRABGUARD","GXT_NUMERO","GXT_CODTRA"+GetWhere("=",oNMTRABGUARD:GXT_CODTRA))
     cNumero:=STRZERO(VAL(cNumero)+1,LEN(cNumero))
     oNMTRABGUARD:GXT_NUMERO:=cNumero
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
  oNMTRABGUARD:oFocus:=oNMTRABGUARD:oGXT_CODGUA
  EJECUTAR("NMCUOTASGUARD",oNMTRABGUARD:GXT_CODTRA,oNMTRABGUARD:GXT_NUMERO)
//DpFocus(oNMTRABGUARD:oGXT_CODGUA)

RETURN .T.

FUNCTION PAREN_CHANGE()
  LOCAL aItems2:={}

  aItems2 :=aTable("SELECT CONCAT(FAM_APELLI,',',FAM_NOMBRE) FROM NMFAMILIA WHERE FAM_CODTRA"+GetWhere("=",oNMTRABGUARD:GXT_CODTRA)+;
                   " AND FAM_PARENT"+GetWhere("=",oNMTRABGUARD:GXT_PARENT))
/*
//  ? ClpCopy("SELECT CONCAT(FAM_APELLI,',',FAM_NOMBRE) FROM NMFAMILIA WHERE FAM_CODTRA"+GetWhere("=",oNMTRABGUARD:GXT_CODTRA)+;
//           " AND FAM_PARENT"+GetWhere("=",oNMTRABGUARD:GXT_PARENT))
*/
  IF !Empty(aItems2) 
    oNMTRABGUARD:oGXT_APELLI:SetItems(aItems2)
    oNMTRABGUARD:oGXT_APELLI:VarPut(aItems2[1])
  ENDIF
  
  oNMTRABGUARD:GXTAPELLI()

RETURN .T.

/*
// Busca los Datos Anteriores a la Guardería
*/
FUNCTION GXTAPELLI(cApellido)
  LOCAL oTable,dFecha,cSql

  IF Empty(oNMTRABGUARD:GXT_APELLI) .OR. oNMTRABGUARD:nOption!=1
    RETURN .F.
  ENDIF

  cSql:=" SELECT GXT_APELLI,GXT_NOMBRE,MAX(GXT_HASTA) AS GXT_HASTA FROM NMTRABGUARD WHERE "+;
        " GXT_CODTRA"+GetWhere("=",oNMTRABGUARD:GXT_CODTRA)+" AND "+;
        " GXT_PARENT"+GetWhere("=",oNMTRABGUARD:GXT_PARENT)+"  "+;
        " GROUP BY GXT_APELLI,GXT_NOMBRE "+;
        " HAVING CONCAT(GXT_APELLI,',',GXT_NOMBRE)"+GetWhere("=",oNMTRABGUARD:GXT_APELLI)

  oTable:=OpenTable(cSql,.T.)
  dFecha:=SqlToDate(oTable:GXT_HASTA)
  oTable:End()

  IF !Empty(dFecha)
    dFecha:=FchFinMes(dFecha+1)
      oNMTRABGUARD:oGXT_DESDE:VARPUT(dFecha,.T.)
  ENDIF

RETURN .T.

/*
<LISTA:GXT_CODGUA:N:BMPGETL:N:N:Y:Guardería,GXT_PARENT:N:COMBO:N:N:Y:Parentesco,GXT_APELLI:N:COMBO:N:N:Y:Apellido,GXT_DESDE:N:BMPGET:N:N:Y:Desde
,GXT_HASTA:N:BMPGET:N:N:Y:Hasta,GXT_MONTO:N:GET:N:N:Y:Mensual>
*/
