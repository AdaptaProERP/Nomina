// Programa   : NMTRABAJCON
// Fecha/Hora : 03/08/2004 17:07:41
// Propósito  : Consultar Trabajador
// Creado Por : Juan Navas
// Llamado por: NMTRABAJADOR
// Aplicación : Todas
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oForm)
    LOCAL cCodTra:="1002",cNombre,lH400:=.F.
    LOCAL oBtn,oFont,lPrestamo

    IF ValType(oForm)="O"
       cCodTra:=oForm:CODIGO
    ENDIF


    DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD

//    lH400:=COUNT("NMHISTORICO","INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
//                 " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+" AND HIS_CODCON"+GetWhere("=",oDp:cConPres))>0
// Optimizado

    lH400:=!EMPTY(SQLGET("NMRECIBOS","HIS_CODCON","INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC "+;
                  " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+" AND HIS_CODCON"+GetWhere("=",oDp:cConPres)+" LIMIT 1 "))

    cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))

    oFrmRRHH:=DPEDIT():New("Opciones RR.HH ","NMTRABOPC.edt","oFrmRRHH",.T.)

    oFrmRRHH:cFileChm  :=GetFileChm("NMTRABAJADOR")
    oFrmRRHH:CODIGO    :=cCodTra      
    oFrmRRHH:cNombre   :=cNombre
    oFrmRRHH:lH400     :=lH400
    oFrmRRHH:lPrestamo :=COUNT("NMTABPRES","INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO "+;
                               " WHERE REC_CODTRA"+GetWhere("=",cCodTra))>0

   @ 2,1 GROUP oFrmRRHH:oGrupo1 TO 4, 21.5 PROMPT " Trabajador ["+oFrmRRHH:CODIGO+" ]"
   @ 2,30 SAY oFrmRRHH:cNombre 

   oFrmRRHH:lEscClose:=.T.

   @01, 16 SBUTTON oFrmRRHH:oBtn ;
           SIZE 50, 50 ;
           FILE "BITMAPS\XSALIR.BMP" ;
           LEFT PROMPT "Salir" NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 3 };
           ACTION (oFrmRRHH:Close())

   @01, 01 SBUTTON oBtn ;
           SIZE 42, 23 FONT oFont;
           WHEN oDp:lCtaCon;
           FILE "BITMAPS\CONTABILIDAD.BMP",,"BITMAPS\CONTABILIDAD3.BMP";
           PROMPT "Cuentas Contables";
           NOBORDER;
           COLORS IIF(oDp:lCtaCon,CLR_BLACK,oDp:nGris2), { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:CUENTAS()

   oBtn:cToolTip:="Cuentas Contables"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

  @02, 01 SBUTTON oBtn ;
          SIZE 42, 23 FONT oFont;
          FILE "BITMAPS\FAMILIA.BMP",,"BITMAPS\FAMILIA2.BMP";
          PROMPT "Datos Familiares";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
          ACTION EJECUTAR("NMFAMILIA",oFrmRRHH:CODIGO,oFrmRRHH:cNombre)

   oBtn:cToolTip:="Datos Familiares"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

  @04, 01 SBUTTON oBtn ;
          SIZE 42, 23 FONT oFont;
          FILE "BITMAPS\FORMACION.BMP",,"BITMAPS\FORMACION.BMP";
          PROMPT "Formación Académica";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
          ACTION EJECUTAR("NMACADEMICO",oFrmRRHH:CODIGO,oFrmRRHH:cNombre)

   oBtn:cToolTip:="Cuentas Contables"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

  @06, 01 SBUTTON oBtn ;
          SIZE 42, 23 FONT oFont;
          FILE "BITMAPS\EXPERIENCIALABORAL.BMP",,"BITMAPS\EXPERIENCIALABORAL.BMP";
          PROMPT "Experiencia Laboral";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
          ACTION EJECUTAR("NMEXPLABORAL",oFrmRRHH:CODIGO,oFrmRRHH:cNombre)

   oBtn:cToolTip:="Experiencia Laboral"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

  @06, 01 SBUTTON oBtn ;
          SIZE 42, 23 FONT oFont;
          FILE "BITMAPS\GUARDERIA.BMP",,"BITMAPS\GUARDERIA.BMP";
          PROMPT "Guardería";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
          ACTION oFrmRRHH:GUARDERIAS()

   oBtn:cToolTip:="Guardería"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

  @06, 01  SBUTTON oBtn ;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\HCM.BMP",,"BITMAPS\HCM.BMP";
           PROMPT "Seguro HCM";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:HCM()

   oBtn:cToolTip:="Seguro HCM"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

  @06, 01  SBUTTON oBtn ;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\CONOCIMIENTO.BMP",,"BITMAPS\CONOCIMIENTO.BMP";
           PROMPT "Conocimientos";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
           ACTION EJECUTAR("NMTRABCONOCI",oFrmRRHH:RIF,oFrmRRHH:cNombre)

   oBtn:cToolTip:="Conocimientos"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\ANTIGUEDAD.BMP",,"BITMAPS\ANTIGUEDADG.BMP";
           PROMPT "Calcular Artículo 142";
           WHEN !oFrmRRHH:lH400 .AND. oDp:lCal108;
           NOBORDER;
           COLORS IIF(!oFrmRRHH:lH400 .AND. oDp:lCal108,CLR_BLACK,oDp:nGris2), { CLR_WHITE, oDp:nGris2, 1 };
           ACTION EJECUTAR("NMCALANT",oFrmRRHH:CODIGO,oFrmRRHH:CODIGO)

   oBtn:cToolTip:="Calcular Artículo 142"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\EXPEDIENTES.BMP",,"BITMAPS\EXPEDIENTES.BMP";
           PROMPT "Expedientes";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:Expediente()

   oBtn:cToolTip:="Expedientes"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\EVALUACION.BMP",,"BITMAPS\EVALUACIONG.BMP";
           PROMPT "Evaluación";
           WHEN .F.;
           NOBORDER;
           COLORS IIF(.F.,CLR_BLACK,oDp:nGris2), { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:Evaluacion()

   oBtn:cToolTip:="Evaluación"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\AUTOEVALUACION.BMP",,"BITMAPS\AUTOEVALUACIONG.BMP";
           PROMPT "Auto Evaluación";
           WHEN .F.;
           NOBORDER;
           COLORS IIF(.F.,CLR_BLACK,oDp:nGris2), { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:AutoEvaluacion()

   oBtn:cToolTip:="Auto Evaluación"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\DOTACION.BMP",,"BITMAPS\DOTACIONG.BMP";
           PROMPT "Dotación";
           WHEN .F.;
           NOBORDER;
           COLORS IIF(.F.,CLR_BLACK,oDp:nGris2), { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:Dotacion()

   oBtn:cToolTip:="Dotación"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\PRESTAMOS.BMP",,"BITMAPS\PRESTAMOSG.BMP";
           PROMPT "Préstamos";
           WHEN oFrmRRHH:lPrestamo;
           NOBORDER;
           COLORS IIF(oFrmRRHH:lPrestamo,CLR_BLACK,oDp:nGris2), { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:Prestamos()

   oBtn:cToolTip:="Préstamos"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\ARI.BMP",,"BITMAPS\ARI.BMP";
           PROMPT "Calcular ARI";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
           ACTION oFrmRRHH:ARI();

   oBtn:cToolTip:="Calcular Artículo 142"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


  @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\ARC.BMP",,"BITMAPS\ARC.BMP";
           PROMPT "Calcular ARC";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
           ACTION EJECUTAR("NMARC",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);

   oBtn:cToolTip:="Calcular Artículo 142"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


  @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\IVSS1402.BMP",,"BITMAPS\IVSS1402.BMP";
           PROMPT "SSO 14-02";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
           ACTION EJECUTAR("FORMA-14-02",oFrmRRHH:CODIGO,oFrmRRHH:cNombre)

   oBtn:cToolTip:="Planilla 14-02, Inscripción del Trabajador"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


 @06, 01  SBUTTON oBtn;
           SIZE 42, 23 FONT oFont;
           FILE "BITMAPS\IVSS1403.BMP",,"BITMAPS\IVSS1403.BMP";
           PROMPT "SSO 14-03";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
           ACTION EJECUTAR("FORMA-14-03",oFrmRRHH:CODIGO,oFrmRRHH:cNombre)

   oBtn:cToolTip:="Planilla 14-03, Retiro del Trabajador"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @06, 01  SBUTTON oBtn;
          SIZE 42, 23 FONT oFont;
          FILE "BITMAPS\IVSS14100.BMP",,"BITMAPS\IVSS14100.BMP";
          PROMPT "SSO 14-100";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, oDp:nGris2, 1 };
          ACTION EJECUTAR("FORMA-14-100",oFrmRRHH:CODIGO,oFrmRRHH:cNombre)

   oBtn:cToolTip:="IVSS0 14-100"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


/*
   @ 0.5,1 BUTTON "Cuentas Contables"   ACTION oFrmRRHH:CUENTAS();
                                         WHEN oDp:lCtaCon;
                                         SIZE NIL,15
    
   @ 1.5,1 BUTTON "Familiares"           ACTION EJECUTAR("NMFAMILIA",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN .T.;
                                          SIZE NIL,15

   @ 1.5,1 BUTTON "Formación Académica"  ACTION EJECUTAR("NMACADEMICO",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN .T.;
                                          SIZE NIL,15

   @ 1.5,1 BUTTON "Experiencia Laboral"  ACTION EJECUTAR("NMEXPLABORAL",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN .T.;
                                          SIZE NIL,15

    @ 3.0,1 BUTTON "Guarderías"           ACTION oFrmRRHH:GUARDERIAS();
                                          WHEN .T.;
                                          SIZE NIL,15

    @ 5.5,1 BUTTON "Seguro H.C.M."        ACTION oFrmRRHH:HCM();
                                          WHEN .T.;
                                          SIZE NIL,15

    @ 6.5,1 BUTTON "Conocimientos"        ACTION EJECUTAR("NMTRABCONOCI",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN .T.;
                                          SIZE NIL,15

    @ 7.5,1 BUTTON "Calcular Art 142"     ACTION EJECUTAR("NMCALANT",oFrmRRHH:CODIGO,oFrmRRHH:CODIGO);
                                          WHEN !oFrmRRHH:lH400 .AND. oDp:lCal108;
                                          SIZE NIL,15

    @ 7.5,1 BUTTON "Calcular ARI"         ACTION oFrmRRHH:ARI();
                                          WHEN .T.;
                                          SIZE NIL,15

    @ 7.5,1 BUTTON "Calcular ARC"         ACTION EJECUTAR("NMARC",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN oDp:lCalARC;
                                          SIZE NIL,15

    @ 7.5,1 BUTTON "Dotación"             ACTION EJECUTAR("NMARC",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN .f.;
                                          SIZE NIL,15

    @ 7.5,1 BUTTON "Evaluación"           ACTION EJECUTAR("NMARC",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN .f.;
                                          SIZE NIL,15

    @ 7.5,1 BUTTON "Auto Evaluación"      ACTION EJECUTAR("NMARC",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                          WHEN .f.;
                                          SIZE NIL,15

    @ 7.5,1 BUTTON "Expedientes"          ACTION oFrmRRHH:Expediente();
                                          SIZE NIL,15


    @ 7.5,1 BUTTON "IVSS 14-01"          ACTION EJECUTAR("NMARC",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                         WHEN .f.;
                                         SIZE NIL,15

    @ 7.5,1 BUTTON "IVSS 14-02"          ACTION EJECUTAR("FORMA-14-02",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                         WHEN .f.;
                                         SIZE NIL,15

    @ 7.5,1 BUTTON "IVSS Constancia"    ACTION EJECUTAR("NMARC",oFrmRRHH:CODIGO,oFrmRRHH:cNombre);
                                        WHEN .f.;
                                        SIZE NIL,15
*/
    oFrmRRHH:Activate()
  
RETURN .T.

/*
// Cuentas Contables
*/
FUNCTION GUARDERIAS()
 LOCAL oDpLbx,cTitle,cWhere,cFileLbx,lPage:=.F.
 LOCAL aItems1

 IF COUNT("NMFAMILIA","WHERE FAM_CODTRA"+GetWhere("=",oFrmRRHH:Codigo)+" AND UPPER(LEFT(FAM_PARENT,3))='HIJ'")=0
   MensajeErr("Trabajador Requiere Registro de Hijos en el Formulario para Datos Familiares")
   RETURN .F.
 ENDIF
 
 cTitle:="Guarderías "+GetFromVar("{oDp:xNMTRABAJADOR}")+" ["+ALLTRIM(oFrmRRHH:cNombre)+"]"

 cWhere:="GXT_CODTRA"+GetWhere("=",oFrmRRHH:Codigo)

 cFileLbx:="NMTRABGUARD.LBX"
 oDpLbx  :=TDpLbx():New(cFileLbx,cTitle,cWhere,lPage)

 oDpLbx:cCargo:=oFrmRRHH:Codigo
 oDpLbx:Activate()

RETURN NIL

/*
// Cuentas Contables
*/
FUNCTION CUENTAS()
 LOCAL oDpLbx,cTitle,cWhere,cFileLbx,lPage:=.F.
 
 cTitle:="Cuentas Contablas, "+GetFromVar("{oDp:xNMTRABAJADOR}")+" ["+ALLTRIM(oFrmRRHH:cNombre)+"]"

 cWhere:="CXT_CODTRA"+GetWhere("=",oFrmRRHH:Codigo)

 cFileLbx:="NMCTAXTRAB.LBX"
 oDpLbx  :=TDpLbx():New(cFileLbx,cTitle,cWhere,lPage)

 oDpLbx:cScope:=cWhere
 oDpLbx:cCargo:=oFrmRRHH:Codigo
 oDpLbx:Activate()

RETURN NIL

/*
// H.C.M. Del Trabajador
*/
FUNCTION HCM()
 LOCAL oDpLbx,cTitle,cWhere,cFileLbx,lPage:=.F.
 LOCAL aItems1
 
 cTitle:="H.C.M. "+GetFromVar("{oDp:xNMTRABAJADOR}")+" ["+ALLTRIM(oFrmRRHH:cNombre)+"]"

 cWhere:="HCM_CODTRA"+GetWhere("=",oFrmRRHH:Codigo)

 cFileLbx:="NMHCM.LBX"

 oDpLbx  :=TDpLbx():New(cFileLbx,cTitle,cWhere,lPage)

 oDpLbx:cScope:=cWhere
 oDpLbx:cCargo:=oFrmRRHH:Codigo
 oDpLbx:Activate()

RETURN NIL

/*
// Expedientes del Trabajador
*/
FUNCTION Expediente()

 LOCAL oDpLbx,cTitle,cWhere,cFileLbx,lPage:=.F.
 LOCAL aItems1
 
 cTitle:=GetFromVar("{oDp:xNMEXPEDIENTE}")+" ["+ALLTRIM(oFrmRRHH:Codigo)+": "+ALLTRIM(oFrmRRHH:cNombre)+"]"

 cWhere:="EXP_CODTRA"+GetWhere("=",oFrmRRHH:Codigo)

 cFileLbx:="NMEXPEDIENTE.LBX"

 oDpLbx  :=TDpLbx():New(cFileLbx,cTitle,cWhere,lPage)

 oDpLbx:cScope:=cWhere
 oDpLbx:cCargo:=oFrmRRHH:Codigo
 oDpLbx:Activate()

RETURN .T.

/*
// Expedientes del Trabajador
*/
FUNCTION ARI()

 LOCAL oDpLbx,cTitle,cWhere,cFileLbx,lPage:=.F.
 LOCAL aItems1

 IF oDp:oNmARI=NIL
   MSGRUN("Compilando Nómina, Calcular Ingreso Anual del Trabajador","Espere....",{||EJECUTAR("NMINIARI")})
 ENDIF
 
 cTitle:=GetFromVar("{oDp:xNMARI}")+" ["+ALLTRIM(oFrmRRHH:Codigo)+": "+ALLTRIM(oFrmRRHH:cNombre)+"]"

 cWhere:="ARI_CODTRA"+GetWhere("=",oFrmRRHH:Codigo)

 cFileLbx:="NMARI.LBX"

 oDpLbx  :=TDpLbx():New(cFileLbx,cTitle,cWhere,lPage)

 oDpLbx:cScope:=cWhere
 oDpLbx:cCargo:=oFrmRRHH:Codigo
 oDpLbx:Activate()

RETURN .T.

FUNCTION DOTACION()
  ? "DOTACION EN DESARROLLO"
RETURN .T.

FUNCTION EVALUACION()
   ? "EVALUACION EN DESARROLLO"
RETURN .T.

FUNCTION AUTOEVALUACION()
   ? "AUTOEVALUACION EN DESARROLLO"
RETURN .T.

FUNCTION PRESTAMOS()
   EJECUTAR("NMTRABPRES",oFrmRRHH:Codigo,,,.F.)
RETURN .T.

// EOF



