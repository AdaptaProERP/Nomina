// Programa   : NMTRABAJCON
// Fecha/Hora : 03/08/2004 17:07:41
// Propósito  : Consultar Trabajador
// Creado Por : Juan Navas
// Llamado por: NMTRABAJADOR
// Aplicación : Todas
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oForm,cCodTra)
    LOCAL oTable,lHisto:=.F.,nAnos:=0,nMeses:=0,nDias:=0
    LOCAL lTabVac:=.F.,lRecibo:=.F.,lPrestamo:=.F.,lAusencia:=.f.
    LOCAL lH400  :=.F.,nDiasP,nMeses:=0,nDias104,oBtn,oFont
    LOCAL lH410  :=.F.,nFilMai,cNom

    IF ValType(oForm)="O"
       cCodTra:=oForm:CODIGO
    ENDIF

    DEFAULT cCodTra:=SQLGET("NMTRABAJADOR","CODIGO")

    oTable :=OpenTable("SELECT PRE_NUMERO,PRE_MONTO,PRE_CUOTA,REC_FECHAS FROM NMTABPRES"+;
                       " INNER JOIN NMRECIBOS ON PRE_NUMREC=REC_NUMERO "+;
                       " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
                       " AND PRE_TIPO='P' LIMIT 1",.T.)

    lPrestamo:=oTable:RecCount()>0
    oTable:End()

    oTable:=OpenTable("SELECT TAB_CODTRA FROM NMTABVAC WHERE TAB_CODTRA"+GetWhere("=",cCodTra)+" LIMIT 1",.T.)
    lTabVac:=oTable:RecCount()>0
    oTable:End()

// oTable :=OpenTable("SELECT COUNT(*) AS CUANTOS FROM NMRECIBOS WHERE REC_CODTRA"+GetWhere("=",cCodTra)+" LIMIT 1",.T.)
    lRecibo:=COUNT("NMRECIBOS","REC_CODTRA"+GetWhere("=",cCodTra))>0
    lHisto :=lRecibo
    lH400  :=lRecibo
    lH410  :=lRecibo  //Prestaciones Trimestrales
//  oTable:End()

//  oTable   :=OpenTable("SELECT COUNT(*) AS CUANTOS FROM NMAUSENCIA WHERE PER_CODTRA"+GetWhere("=",cCodTra)+" LIMIT 1",.T.)
//  lAusencia:=oTable:CUANTOS>0
//  oTable:End()

    lAusencia:=COUNT("NMAUSENCIA","PER_CODTRA"+GetWhere("=",cCodTra))>0

    oTable:=OpenTable("SELECT APELLIDO,NOMBRE,FECHA_VAC,FECHA_FIN,FECHA_ING,FECHA_EGR,DESTINO_PR,FILEBMP,CEDULA,CEDULA,TIPO_CED "+;
                      "FROM NMTRABAJADOR WHERE CODIGO"+GetWhere("=",cCodTra),.T.)

    nMeses:=MESES(oTable:FECHA_ING,oDp:dFecha)

    IF nMeses>1 .AND. nMeses<7
       nDiasP:=7
    ENDIF

    IF nMeses>6 .AND. nMeses<12
       nDiasP:=15
    ENDIF
    IF nMeses>11
       nDiasP:=30
    ENDIF

    nDias104:=nDiasP

    IF nMeses>=60 .AND. nMeses<=120
       nDias104:=60
    ENDIF

    IF nMeses>120
       nDias104:=90
    ENDIF

    nDiasP  :=IIF(ValType(nDiasP  )="N",nDiasP  ,0)
    nDias104:=IIF(ValType(nDias104)="N",nDias104,0)


    cNom:=SQLGET("NMTRABAJADOR","NOMBRE,APELLIDO,TRA_FILMAI","CODIGO"+GetWhere("=",cCodTra))

    nFilMai :=IF( Empty( oDp:aRow), 0 , oDp:aRow[3])

    oFrmCon:=DPEDIT():New("Consulta por Trabajador ","NMTRABCON.edt","oFrmCon",.T.)

    oFrmCon:SetTable(oTable)
    oFrmCon:cFileChm  :=GetFileChm("NMTRABAJADOR")
    oFrmCon:CODIGO    :=cCodTra      
    oFrmCon:cNombre   :=ALLTRIM(oTable:APELLIDO)+" "+ALLTRIM(oTable:NOMBRE)
    oFrmCon:FECHA_VAC :=oTable:FECHA_VAC
    oFrmCon:FECHA_FIN :=oTable:FECHA_FIN
    oFrmCon:FECHA_ING :=oTable:FECHA_ING
    oFrmCon:FECHA_EGR :=oTable:FECHA_EGR
    oFrmCon:DESTINO_PR:=oTable:DESTINO_PR
    oFrmCon:FILEBMP   :=oTable:FILEBMP
    oFrmCon:CEDULA    :=oTable:CEDULA
    oFrmCon:nDiasP    :=nDiasP
    oFrmCon:nDias104  :=nDias104
    oFrmCon:oFrm      :=oForm

    oFrmCon:cAntigued:=ANTIGUEDAD(oTable:FECHA_ING,IIF(EMPTY(oTable:FECHA_EGR),;
                                  oDp:FECHA_ING,oTable:FECHA_EGR),@nAnos,@nMeses,@nDias)
    oFrmCon:lHisto   :=lHisto
    oFrmCon:lTabVac  :=lTabVac
    oFrmCon:lRecibo  :=lRecibo
    oFrmCon:lPrestamo:=lPrestamo
    oFrmCon:lAusencia:=lAusencia
    oFrmCon:lH400    :=lH400
    oFrmCon:lH410    :=lH410      //Prestaciones Trimestrales
    oFrmCon:lMsgBar  :=.F.
    oFrmCon:nFilMai  :=nFilMai

//? oFrmCon:nFilMai,"oFrmCon:nFilMai"

    oTable:End()

    oFrmCon:cAntigued:=STRTRAN(oFrmCon:cAntigued,"a",IIF(nAnos >1,"Años " ,"Año " ))
    oFrmCon:cAntigued:=STRTRAN(oFrmCon:cAntigued,"m",IIF(nMeses>1,"Meses ","Mes " ))
    oFrmCon:cAntigued:=STRTRAN(oFrmCon:cAntigued,"d",IIF(nDias >1,"Días " ,"Días "))

    @ 0,30 SAY "Código:"     
    @ 2,30 SAY oFrmCon:cNombre BORDER

    @ 3,30 SAY "Apellidos y Nombre:" 
    @ 4,30 SAY oFrmCon:CODIGO BORDER

    @ 5,30 SAY "Periodo de Vacaciones:" 
    @ 6,30 SAY CFECHA(oFrmCon:FECHA_VAC) BORDER
    @ 6,30 SAY CFECHA(oFrmCon:FECHA_FIN) BORDER

    @ 7,30 SAY "Periodo laborado : "
    @ 8,30 SAY CFECHA(oFrmCon:FECHA_ING) BORDER
    @ 8,50 SAY CFECHA(oFrmCon:FECHA_EGR) BORDER
    @ 9,50 SAY oFrmCon:cAntigued BORDER

    @6, 16 SBUTTON oFrmCon:oBtn ;
           SIZE 50, 50 ;
           FILE "BITMAPS\XSALIR.BMP" ;
           LEFT PROMPT "Cerrar" NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 3 };
           ACTION (oFrmCon:Close())

    @ 5,20 BITMAP oFrmCon:oImage FILENAME oFrmCon:FILEBMP;
                 SIZE 159,199 ADJUST 

   @ 09,30 SAY "Preaviso Art 107 (Renuncia):"
   @ 10,30 SAY LSTR(oFrmCon:nDiasP)+" Días" BORDER

   @ 10,30 SAY "Preaviso Art 104 (Despido):"
   @ 11,30 SAY LSTR(oFrmCon:nDias104)+" Días" BORDER


//    @ 10,30 SAY BORDER


   @01, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           WHEN oFrmCon:lHisto;
           FILE "BITMAPS\RESUMENMENSUAL.BMP",,"BITMAPS\RESUMENMENSUALG.BMP";
           PROMPT "Resumen Mensual de Pagos";
           NOBORDER;
           COLORS IIF(oFrmCon:lHisto,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("NMTRAHISMES",oFrmCon:CODIGO)


   oBtn:cToolTip:="Resumen mensual de Pagos"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

   @01, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           WHEN oFrmCon:lHisto;
           FILE "BITMAPS\RECIBO.BMP",,"BITMAPS\RECIBOG.BMP";
           PROMPT "Recibos de Pago";
           NOBORDER;
           COLORS IIF(oFrmCon:lHisto,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("NMTRABREC",oFrmCon:CODIGO)


   oBtn:cToolTip:="Recibos de Pago"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


 @01, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           WHEN oFrmCon:lHisto;
           FILE "BITMAPS\RESUMENXCONCEPTO.BMP",,"BITMAPS\RESUMENXCONCEPTOG.BMP";
           PROMPT "Resumen por Concepto";
           NOBORDER;
           COLORS IIF(oFrmCon:lHisto,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("NMTRABHISCON",oFrmCon:CODIGO)


   oBtn:cToolTip:="Resumen por Concepto"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @05, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\VACACIONES.BMP",,"BITMAPS\VACACIONESG.BMP";
           PROMPT "Vacaciones";
           NOBORDER;
           COLORS IIF(oFrmCon:lTabVac,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("NMTRABTABVAC",oFrmCon:CODIGO);
           WHEN oFrmCon:lTabVac


   oBtn:cToolTip:="Vacaciones"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


 @07, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\ESTADODECUENTA.BMP",,"BITMAPS\ESTADODECUENTAG.BMP";
           PROMPT "Estado de Cuenta [Prestaciones]";
           NOBORDER;
           COLORS IIF(oFrmCon:lH400,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("NMPRESTVIEW",oFrmCon:CODIGO);
           WHEN oFrmCon:lH400

   oBtn:cToolTip:="Estado de Cuenta [Prestaciones]"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


   @08, 01 SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\INTERES.BMP",,"BITMAPS\INTERESG.BMP";
          PROMPT "Intereses";
          NOBORDER;
          COLORS IIF(oFrmCon:lH400,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION EJECUTAR("NMCALINTERES",oFrmCon:CODIGO);
          WHEN oFrmCon:lH400 .AND. !oFrmCon:DESTINO_PR="B"
                                           
/* 
EJECUTAR("NMPRESTVIEW",;
                                            {{oFrmCon:CODIGO,oFrmCon:cNombre,;
                                            "NOMBRE",oFrmCon:FECHA_ING,0}});

*/

   oBtn:cToolTip:="Intereses"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


   // Prestaciones Trimestrales
  @07, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\ESTADODECUENTA.BMP",,"BITMAPS\ESTADODECUENTAG.BMP";
           PROMPT "Edo de Cuenta [Prest. Trimestral]";
           NOBORDER;
           COLORS IIF(oFrmCon:lH410,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("NMPRESTVIEWTRI",oFrmCon:CODIGO);
           WHEN oFrmCon:lH410
                                           

   oBtn:cToolTip:="Edo de Cuenta [Prest. Trimestral]"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


   @08, 01 SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\INTERES.BMP",,"BITMAPS\INTERESG.BMP";
          PROMPT "Intereses Trimetrales";
          NOBORDER;
          COLORS IIF(oFrmCon:lH400,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION EJECUTAR("NMCALINTERESTRI",oFrmCon:CODIGO);
          WHEN oFrmCon:lH410 .AND. !oFrmCon:DESTINO_PR="B"
                                           
/* 
EJECUTAR("NMPRESTVIEW",;
                                            {{oFrmCon:CODIGO,oFrmCon:cNombre,;
                                            "NOMBRE",oFrmCon:FECHA_ING,0}});

*/

   oBtn:cToolTip:="Intereses"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


  @09, 01 SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\SALARIO.BMP",,"BITMAPS\SALARIOG.BMP";
          PROMPT "Salarios";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION EJECUTAR("NMRESTRA",oFrmCon:CODIGO)
                                          
   oBtn:cToolTip:="Salarios"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @10, 01 SBUTTON oBtn ;
          SIZE 42, 23;
          FILE "BITMAPS\PRESTAMOS.BMP",,"BITMAPS\PRESTAMOSG.BMP";
          PROMPT "Préstamos";
          NOBORDER;
          COLORS IIF(oFrmCon:lPrestamo,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION EJECUTAR("NMTRABPRES",oFrmCon:CODIGO);
          WHEN oFrmCon:lPrestamo
                                           

   oBtn:cToolTip:="Préstamos"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

 @10, 01 SBUTTON oBtn ;
         SIZE 42, 23;
         FILE "BITMAPS\REPOSO.BMP",,"BITMAPS\REPOSOG.BMP";
         PROMPT "Ausencias";
         NOBORDER;
         COLORS IIF(oFrmCon:lAusencia,CLR_BLACK,CLR_HGRAY), { CLR_WHITE, CLR_HGRAY, 1 };
         ACTION EJECUTAR("NMTRAAUSEN",oFrmCon:CODIGO);
         WHEN oFrmCon:lAusencia
                                           
   oBtn:cToolTip:="Ausencias"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

   @10, 01 SBUTTON oBtn ;
         SIZE 42, 23;
         FILE "BITMAPS\TODOSLOSCAMPOS.BMP";
         PROMPT "Todos los Campos";
         NOBORDER;
         COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
         ACTION EJECUTAR("NMFICHA_A",oFrmCon:CODIGO)
                                           
   oBtn:cToolTip:="Todos los Campos de la Ficha"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


   @14, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\AUDITORIA.BMP";
           PROMPT "Auditoría Registro";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("VIEWAUDITOR","NMTRABAJADOR",oFrmCon:CODIGO,oFrmCon:cNombre)
                                           
   oBtn:cToolTip:="Ver Auditoría"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )

/*
   @14, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\AUDITORIAXCAMPO.BMP";
           PROMPT "Auditoría por Campo";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("VIEWAUDITOR","NMTRABAJADOR",oFrmCon:CODIGO,oFrmCon:cNombre)
                                           
   oBtn:cToolTip:="Ver Auditoría"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )
*/


// IF oDp:nVersion>=6 

   @14, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\AUDITORIAXCAMPO.BMP";
           PROMPT "Auditoría por Campo";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("DPAUDITAEMC",oFrmCon:oFrm,"NMTRABAJADOR","NMTRABAJADOR.SCG",oFrmCon:CODIGO,oFrmCon:cNombre)

// ENDIF


                                           
   oBtn:cToolTip:="Ver Auditoría"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


   //
   /*
   Ver archivos adjuntos. 
   */

  
    @14, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\ADJUNTAR.bmp",NIL,"BITMAPS\ADJUNTARG.BMP";
           PROMPT "Digitalización";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION EJECUTAR("DPFILEEMPMAIN",oFrmCon:nFilMai,oFrmCon:CODIGO,NIL,NIL,.T.)

   oBtn:cToolTip:="Ver Archivos Adjuntos"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )


    @14, 01 SBUTTON oBtn ;
           SIZE 42, 23;
           FILE "BITMAPS\GOOGLE.bmp",NIL,"GOOGLE.BMP";
           PROMPT "Google";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION  EJECUTAR("GOOGLEE",oFrmCon:cNombre)

   oBtn:cToolTip:="Buscar Google"
   oBtn:cMsg    :=oBtn:cToolTip
   oBtn:SetText( Nil, 10, 40, nil, nil,nil )



/*
    DEFINE BITMAP OF OUTLOOK oMdiTra:oOut ;
          BITMAP "BITMAPS\GOOGLE.BMP" ;
          PROMPT "Buscar en Google" ;
          ACTION (oMdiTra:REGAUDITORIA("Buscar en Google"),;
                  EJECUTAR("GOOGLEE",oMdiTra:cNombre))

*/

   oFrmCon:Activate()
  
RETURN .T.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"NMTRABAJADOR",oMdiTra:cCodigo,NIL,NIL,NIL,NIL,cConsulta)


// EOF
