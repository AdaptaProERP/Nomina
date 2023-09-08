// Programa   : NMCALANT
// Fecha/Hora : 05/06/2004 02:39:58
// Propósito  : Calcular Antiguedad laboral
// Creado Por : Juan Navas
// Llamado por: Menú Principal
// Aplicación : Nómina
// Tabla      : TRABAJADORES
// Modificado por Daniel Ramírez el 27/04/2006 (Ajustes varios) DR20060427

#INCLUDE "DPXBASE.CH"

PROCEDURE NMCALANT(cCodIni,cCodFin)
  LOCAL oGrp,bInit,oTable,oFont,oBtn

  DEFAULT cCodFin:=cCodIni,oDp:nTrabajad:=0

  IF !EMPTY(cCodIni) 
    oDp:cCodTraIni:=cCodIni
    oDp:cCodTraFin:=cCodFin
    bInit:={||DpFocus(oFrmAnt:oBtnIniciar),.F.}
  ENDIF

  IF oDp:nTrabajad=0  

    oTable:=OpenTable("SELECT COUNT(*) AS CUANTOS FROM NMTRABAJADOR",.T.)
    oDp:nTrabajad:=oTable:FieldGet(1)
    oTable:End()

    IF oDp:nTrabajad=0  

      MensajeErr("No hay Trabajadores Registrados")

      oTable:=GetDpLbx(oDp:nNumLbx)

      IF ValType(oTable)="O" 
        oTable:oWnd:End() // Debe Cerrarse
        oTable:=NIL
      ENDIF

      RETURN .T.

    ENDIF

  ENDIF

  EJECUTAR("NMTIPNOM")

  oFrmAct:=DPEDIT():New("Calcular Antiguedad Laboral","NMCALANT.edt","oFrmAnt",.T.)

  oFrmAnt:cTipoNom     :=oDp:cTipoNom
  oFrmAnt:cOtraNom     :=oDp:cOtraNom
  oFrmAnt:dDesde       :=CTOD("")
  oFrmAnt:dHasta       :=CTOD("")
  oFrmAnt:oMeter       :=NIL
  oFrmAnt:nTrabajadores:=0
  oFrmAnt:oSayTrab     :=NIL
  oFrmAnt:lCancel      :=.T.
  oFrmAnt:oNm          :=NIL
  oFrmAnt:lBorrar      :=.T.
  oFrmAnt:cGrupo       :="TODOS"
  oFrmAnt:cCodGru      :=oDp:cCodGru
  oFrmAnt:nMeses       :=3    // A Partir de Tres Meses Antigua LOT
  oFrmAnt:nMeses1      :=1    // A Partir de Primer Mes Actual LOTTT
  oFrmAnt:cCodigoIni   :=oDp:cCodTraIni   // Trabajador Desde
  oFrmAnt:cCodigoFin   :=oDp:cCodTraFin   // Trabajador Hasta
  oFrmAnt:lCodigo      :=.T.              // Requiere Rango del Trabajador
  oFrmAnt:dFecha       :=oDp:dFecha       // Toma la Fecha del Sistema
  oFrmAnt:lDetener     :=.F.
  oFrmAnt:lProcess     :=.F.
  oFrmAnt:aCodTrab     :={}     // Código de Trabajadores Procesados
  oFrmAnt:oGrupo       :=NIL

   

  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Trabajador"
  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Periodo"

  //@ 3,2 SAY  GetFromVar("{oDp:XNMGRUPO}")

  @ 3,2 SAY  GetFromVar("{oDp:NMGRUPO}")

  @ 4,2 SAY oFrmAnt:oGrupo PROMPT PADR("Todos",40)
  oFrmAnt:VALGRUPO(oFrmAnt,oFrmAnt:cCodGru,.T.)

  @ 4,12 BMPGET oFrmAnt:oCodGru VAR oFrmAnt:cCodGru;
         NAME   "BITMAPS\FIND.bmp";
         SIZE   40,NIL;
         VALID  oFrmAnt:ValGrupo(oFrmAnt,oFrmAnt:cCodGru);
         WHEN   oDp:nGrupos>0;
         ACTION oFrmAnt:LISTGRU(oFrmAnt,"cCodGru","oCodGru")

  // RANGO DE TRABAJADOR 

  @ 4,12 BMPGET oFrmAnt:oCodDesde VAR oFrmAnt:cCodigoIni;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmAnt:lCodigo;
         VALID oFrmAnt:VALCODTRA(oFrmAnt,oFrmAnt:oCodDesde);
         ACTION oFrmAnt:LISTTRAB(oFrmAnt,"cCodigoIni","oCodDesde")

  @ 5,12 BMPGET oFrmAnt:oCodHasta VAR oFrmAnt:cCodigoFin;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmAnt:lCodigo;
         VALID oFrmAnt:VALCODTRA(oFrmAnt,oFrmAnt:oCodHasta).AND.;
               (Igualar(oFrmAnt:oCodDesde,oFrmAnt:oCodHasta).AND.oFrmAnt:cCodigoFin>=oFrmAnt:cCodigoIni);
         ACTION oFrmAnt:LISTTRAB(oFrmAnt,"cCodigoFin","oCodHasta")


@02, 23  SBUTTON oBtn ;
           SIZE 42, 23 ;
           FILE "BITMAPS\ERASE01.BMP" ;
           LEFT PROMPT "Borrar";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oFrmAnt:oCodDesde:VarPut(SPACE(10),.T.),;
                   oFrmAnt:oCodHasta:VarPut(SPACE(10),.T.))

  oBtn:cToolTip:="Borrar Rango de Trabajador"
  oBtn:cMsg    :="Borrar Rango de Trabajador"


  // RANGO DE FECHA

  @ 4,12 BMPGET oFrmAnt:oDesde VAR oFrmAnt:dDesde PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN .T.;
         ACTION 1=1

  @ 5,12 BMPGET oFrmAnt:oHasta VAR oFrmAnt:dHasta PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN .T.;
         VALID (Igualar(oFrmAnt:oDesde,oFrmAnt:oHasta).AND.(oFrmAnt:dHasta>=oFrmAnt:dDesde.OR.!EMPTY(oFrmAnt:dHasta)));
         ACTION 1=1

  @ 08,01 METER oFrmAnt:oMeter VAR oFrmAnt:nTrabajadores

  @ 08,01 SAY oFrmAnt:oSayTrab PROMPT "Trabajador:"+SPACE(30)
  @ 09,01 SAY oFrmAnt:oSay     PROMPT "Periodo"+SPACE(40)

  @ 08,2  CHECKBOX oFrmAnt:lBorrar PROMPT ANSITOOEM([Borrar Cálculos Existentes "]+oDp:cConPres+["])

  IF !EMPTY(oFrmAnt:cCodigoIni)
     oFrmAnt:VALCODTRA(oFrmAnt,oFrmAnt:oCodDesde,.T.)
  ENDIF

/*
  @ 6,07 BUTTON oFrmAnt:oBtnIniciar PROMPT "Iniciar ";
                                    ACTION  (CursorWait(),;
                                             oFrmAnt:SetMsg("Ejecutar Actualización"),;
                                             oFrmAnt:EJECUTAR(oFrmAnt));
                                    WHEN    oDp:lCal108 

  @ 6,10 BUTTON oFrmAnt:oBtnCerrar PROMPT "Cerrar  " ACTION oFrmAnt:Detener(oFrmAnt) CANCEL
*/

  @09, 33  SBUTTON oFrmAnt:oBtnIniciar ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\RUN.BMP" NOBORDER;
           LEFT PROMPT "Calcular";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION  (CursorWait(),;
                   oFrmAnt:SetMsg("Ejecutar Actualización"),;
                   oFrmAnt:EJECUTAR(oFrmAnt));
                   WHEN    oDp:lCal108 

//    oBtn:cToolTip:="Grabar Registro"
//    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oFrmAnt:oBtnCerrar ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION oFrmAnt:Detener(oFrmAnt) CANCEL

//    oFrmAnt:oBtnCerrar:lCancel :=.T.
//    oFrmAnt:oBtnCerrar:cToolTip:="Cerrar Formulario "
//    oFrmAnt:oBtnCerrar:cMsg    :=oFrmAnt:cToolTip

  oFrmAnt:Activate(bInit)

RETURN NIL

FUNCTION EJECUTAR(oFrmAnt)
   LOCAL cSql,cWhere:="",cDelete
   LOCAL oLee,oHisto,oTable,oRecibo,cRecibo
   LOCAL dDesde,dHasta,dIniMes,dFinMes
   LOCAL cWhere,nMonto:=0,cTotal
   LOCAL nAnos,nSalario,nMeses,nMeses1,nMes,nSalarioA,nDias,nCuantos:=0,cNumFecha:=""
   LOCAL cTipoNomRA,cOtraNomRA // DR20060427. Variables para Nómina de Recálculo de Antiguedad.
   LOCAL oHisto2 // DR20060427. Permite almacenar registros a borrar
   LOCAL aBorrar,nBorrar // DR20060427. Guarda los recibos que serán eliminados

   // DR20060427. Estos valores deben ser creados por Definiciones -> Otra Nóminas (Nómina Indefinida)
   cTipoNomRA:="O" 
   cOtraNomRA:="RA"

   oDp:cCodGru   :=oFrmAnt:cCodGru

   // A Futuro podemos colocar instrucciones que creen el tipo de Nómina si no está creado para evitar
   // errores de integridad referencial
   // DR20060427.

//   PUBLICO("oNm",TNOMINA("oNm"))    // Crea el Objeto Nómina
//  oNm:Constantes()                // Genera los Valores de las Constantes

   cSql:="SELECT * FROM NMTRABAJADOR "

   oFrmAnt:lProcess:=.T.
   oFrmAnt:lDetener:=.F.

   IF !EMPTY(oFrmAnt:cCodigoIni)

      cWhere:="CODIGO"+GetWhere(">=",oFrmAnt:cCodigoIni)+" AND "+;
              "CODIGO"+GetWhere("<=",oFrmAnt:cCodigoFin)

   ENDIF

   oNomina:cGrupoIni  :=oFrmAnt:cCodGru
   oNomina:cGrupoFin  :=oFrmAnt:cCodGru

? oNomina:cGrupoIni
/*
   IF !EMPTY(oFrmAnt:cCodGru) // Codigo del Trabajador

      cSql:=ADDWHERE(cSql,"(NMTRABAJADOR.GRUPO "+GetWhere(">=",oFrmAnt:cCodGru)+" AND "+;
                          " NMTRABAJADOR.GRUPO "+GetWhere("<=",oFrmAnt:cCodGru)+")")

   ENDIF
*/
   cSql:=cSql+IIF(EMPTY(cWhere),""," WHERE ")+cWhere+;
         " ORDER BY CODIGO"

   oLee:=OpenTable(cSql,.T.)   

   oFrmAnt:oBtnIniciar:Disable()
   oFrmAnt:oBtnCerrar:SetText("Detener")
   oLee:GoTop()

   oFrmAnt:oMeter:SetTotal(oLee:RecCount())

   oFrmAnt:aCodTrab:={} // Codigo de Trabajadores

   WHILE !oLee:Eof() .AND. !oFrmAnt:lDetener

      oFrmAnt:oSayTrab:SetText(ALLTRIM(oLee:CODIGO)+" "+ALLTRIM(oLee:APELLIDO)+","+ALLTRIM(oLee:NOMBRE))
      oFrmAnt:oMeter:Set(oLee:RecNo())
      SysRefresh(.T.)
      // Calcula Mes a Mes

      dDesde   :=MAX(FCHFINMES(oLee:FECHA_ING)+1,CNS(82))
      dDesde   :=MAX(oFrmAnt:dDesde,dDesde)
      dHasta   :=MAX(oFrmAnt:dHasta,oDp:dFecha)
      nMes     :=0
      nSalarioA:=0

      oTable:=OpenTable("SELECT RMT_PROM_"+oDp:cSalPres+" FROM NMRESTRA "+;
                        "WHERE RMT_CODTRA "+GetWhere("=",oLee:CODIGO)+;
                        " ORDER BY RMT_ANO,RMT_MES LIMIT 1",.T.)

      nSalarioA:=oTable:FieldGet(1)
      oTable:End()


      // Borrar Antiguedad en Fechas Menor a la Fecha de Ingreso
      oTable:=OpenTable("SELECT HIS_NUMREC FROM NMHISTORICO "+;
                        "INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
                        "INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
                        "WHERE HIS_CODCON"+GetWhere("=" ,oDp:cConPres)+;
                        " AND REC_CODTRA"+GetWhere("=" ,oLee:CODIGO)+;
                        IIF(oFrmAnt:lBorrar,""," AND FCH_HASTA "+GetWhere("<=",oLee:FECHA_ING)),;
                        .T.)

      IF oTable:RecCount()>0

        CursorWait()

        oFrmAnt:oSay:SetText("Borrando Recibos y Generando Auditoría")

        oTable:Gotop()

        // DR20060427. Esto queda deshabilitado, porque la anulación se haría por el histórico
        //WHILE !oTable:Eof()
           // AUDITAR("DELI" , NIL ,"NMRECIBOS","["+oTable:HIS_NUMREC+"] Eliminado desde Desde Calcular Antiguedad")
           // oTable:DbSkip()
        //ENDDO

        // DR20060427. Se elimina por histórico, si queda vacío el recibo, entonces se procede a eliminar.
        cDelete  :="DELETE FROM NMHISTORICO WHERE HIS_CODCON"+GetWhere("=" ,oDp:cConPres)+" AND "+GetWhereOr("HIS_NUMREC",oTable:aDataFill)
        oLee:Execute(cDelete)
        aBorrar:={}
        WHILE !oTable:Eof()
           // DR20060427. Verifica si el historico queda vacío
           cSql     :="SELECT * FROM NMHISTORICO"+;
                      " WHERE HIS_NUMREC"+GetWhere("=",oTable:HIS_NUMREC)
           oHisto2 :=OpenTable(cSql,.T.)
           IF oHisto2:RECCOUNT()=0
              AUDITAR("DELI" , NIL ,"NMRECIBOS","["+oTable:HIS_NUMREC+"] Eliminado desde Desde Calcular Antiguedad")
              AADD(aBorrar,oTable:HIS_NUMREC)
           ENDIF
           oTable:DbSkip()
        ENDDO
        *cDelete  :="DELETE FROM NMRECIBOS WHERE "+GetWhereOr("REC_NUMERO",oTable:aDataFill)
        *oLee:Execute(cDelete)
        nBorrar:=1
        WHILE nBorrar<=LEN(aBorrar)
           cDelete  :="DELETE FROM NMRECIBOS WHERE REC_NUMERO"+GetWhere("=",aBorrar[nBorrar])
           oLee:Execute(cDelete)
           nBorrar:=nBorrar+1
        ENDDO
       // DR20060427
      ENDIF

      oTable:End()

      WHILE dDesde<dHasta .AND. !oFrmAnt:lDetener

        IF (!EMPTY(oFrmAnt:dHasta) .AND. dDesde>oFrmAnt:dHasta) .OR. (!EMPTY(oFrmAnt:dDesde) .AND. dDesde<oFrmAnt:dDesde)
            dDesde:=FchFinMes(dDesde)+1
            LOOP
         ENDIF

         SysRefresh(.T.)

         cTotal :="["+GetNumRel(oLee:Recno(),oLee:RecCount())+"]"

         dIniMes:=FCHINIMES(dDesde)
         dFinMes:=FCHFINMES(dDesde)
         oFrmAnt:oSay:SetText(cTotal+" Mes: ["+STRZERO(nMes,4)+"] Periodo: ["+CMES(dIniMes)+"/"+STRZERO(YEAR(dIniMes),4)+"]")

         // Aun no Tiene Tres Meses
         cWhere     :="REC_CODTRA"+GetWhere("=" ,oLee:CODIGO)+" AND "+;
                      "FCH_DESDE "+GetWhere(">=",dIniMes)        +" AND "+;
                      "FCH_HASTA "+GetWhere(">=",dFinMes)        +" AND "+;
                      "HIS_CODCON"+GetWhere("=" ,oDp:cConPres )

          cSql     :=SELECTFROM("NMHISTORICO")+;
                     " INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
                     " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
                     " WHERE "+cWhere

 
          nSalario :=PROMEDIO(oDp:cSalPres,dFinMes,dFinMes,.F.,oLee:CODIGO)
 
          IF EMPTY(nSalario)

             nSalario :=PROMEDIO(oDp:cSalPres,CTOD("01/01/"+STRZERO(YEAR(dFinMes),4)),CTOD("31/12/"+STRZERO(YEAR(dFinMes),4)),.F.,oLee:CODIGO)
//           nSalario :=PROMEDIO(oDp:cSalPres,DTOC("01/01/"+STRZERO(YEAR(dFinMes),4)),CTOD("31/12/"+STRZERO(YEAR(dFinMes),4)),.F.,oLee:CODIGO)

          ENDIF

          nSalario :=iif(Empty(nSalario),nSalarioA,nSalario) // Si esta Vacio asume el Anterior

          // Sino, lo Calcula
          IF Empty(nSalario)
             nSalario :=IIF(oLee:TIPO_NOM!="S",DIV(oLee:SALARIO,30),oLee:SALARIO)
             // Debe sumarle la Alicuota de Utilidades
             nSalario+=DIV(nSalario*CNS(52),360)
          Endif

          nSalarioA:=nSalario

          // No hay Sueldo
          IF Empty(nSalario)
             dDesde:=FchFinMes(dDesde)+1
             LOOP
          ENDIF

          nMes    :=nMes+1
          nAnos   :=INT(DIV(MESES(MAX(oLee:FECHA_ING,CNS(82)),dFinMes),12))

          IF nAnos>=2 .AND. nAnos<16 //.AND. nAnos=INT(nAnos) 
             nAnos:=IIF(nAnos=2,2,(nAnos-1)*2)  // Suma Dos Dias por Año Adicional
             // nAnos:=2
             nAnos:=MIN(nAnos,30) // No debe pasar de 15 Dias Adicionales
             IF !oDp:lDistAnosA .AND. !ANIVERSARIO(oLee:FECHA_ING,dIniMes,dFinMes)
                nAnos:=0
             ENDIF
          ELSE
             nAnos:=0
          ENDIF

          IF oDp:lDistAnosA // Distribuir Años Adicionales
              nDias   :=INT(DIV(CNS(61)+nAnos,12)*100)/100
          ELSE
              // Asi lo Hace SPI 
              nDias   :=INT(DIV(CNS(61),12)*100)/100
              nDias   :=nDias+nAnos
              nAnos   :=0
          ENDIF

          nDias   :=MIN(nDias,30)
          nMonto  :=nSalario*nDias
          
          //  ? dIniMes,dFinMes,nSalario,nMonto,nDias

          oHisto :=OpenTable(cSql,.T.)


          IF oLee:FECHA_ING<CNS(100)

//? "antes LOTTT"
          //IF !(MESES(MAX(oLee:FECHA_ING,CNS(82)),dFinMes)>oFrmAnt:nMeses)
 
          IF !(MESES(MAX(oLee:FECHA_ING,CNS(82)),dFinMes)>oFrmAnt:nMeses)
             // No tiene Tres meses
             // IF oHisto:RecCount()>0
                // Elimina
             //   oHisto:Delete(oHisto:cWhere)
             //   oHisto:End()
             // ENDIF
             // dDesde:=FchFinMes(dDesde)+1
             // LOOP
             nMonto:=0
             nDias :=0
          ENDIF

          ELSE

//? "AHORA lottt"

          IF !(MESES(MAX(oLee:FECHA_ING,CNS(82)),dFinMes)>=oFrmAnt:nMeses1)
             // No tiene Tres meses
             // IF oHisto:RecCount()>0
                // Elimina
             //   oHisto:Delete(oHisto:cWhere)
             //   oHisto:End()
             // ENDIF
             // dDesde:=FchFinMes(dDesde)+1
             // LOOP
             nMonto:=0
             nDias :=0
          ENDIF

          ENDIF

//RETURN

          IF oHisto:RecCount()=0

            // DR20060427 Inactivamos este para usar el tipo de nómina definido  cNumFecha:=GetNumFecha(oLee:TIPO_NOM,"",dIniMes,dFinMes)
             cNumFecha:=GetNumFecha(cTipoNomRA,cOtraNomRA,dIniMes,dFinMes)

             oRecibo:=OpenTable("SELECT * FROM NMRECIBOS",.F.)
             oRecibo:Append()
             cRecibo:=STRZERO(VAL(SQLGETMAX("NMRECIBOS","REC_NUMERO"))+1,7)
             oRecibo:Replace("REC_NUMERO",cRecibo)
             oRecibo:Replace("REC_CODTRA",oLee:CODIGO)
//             oRecibo:Replace("REC_DESDE" ,dIniMes)
//             oRecibo:Replace("REC_HASTA" ,dFinMes)
//             oRecibo:Replace("REC_MONTO" ,nMonto )
//             oRecibo:Replace("REC_TIPNOM",oLee:TIPO_NOM)
             oRecibo:Replace("REC_FECHAS",oDp:dFecha)
//             oRecibo:Replace("REC_OTRANM","" )
             oRecibo:Replace("REC_NUMFCH",cNumFecha)
             oRecibo:Replace("REC_CODSUC",oDp:cSucursal)
             oRecibo:Commit()
             oRecibo:End()

             // Historico
             oHisto:Append()
             oHisto:Replace("HIS_NUMREC",cRecibo)
             oHisto:Replace("HIS_CODCON",oDp:cConPres)
             oHisto:Replace("HIS_MONTO" ,nMonto )
             oHisto:Replace("HIS_VARIAC",nDias  )
             oHisto:Replace("HIS_CODSUC",oDp:cSucursal)

             oHisto:Commit()

             AUDITAR("DINC" , NIL ,"NMRECIBOS","["+cRecibo+"] Creado desde Calcular Antiguedad")

          ELSE

             AUDITAR("DMOD" , NIL ,"NMRECIBOS","["+cRecibo+"] Reprocesado Desde Calcular Antiguedad")

             oHisto:Replace("HIS_MONTO",nMonto )
             oHisto:Replace("HIS_CODSUC",oDp:cSucursal)  
             oHisto:Commit("HIS_NUMREC"+GetWhere("=",oHisto:HIS_NUMREC))
        

             oRecibo:=OpenTable("SELECT * FROM NMRECIBOS WHERE REC_NUMERO"+GetWhere("=",oHisto:HIS_NUMREC),.T.)
             oRecibo:Replace("REC_FECHAS",oDp:dFecha)
             oRecibo:Replace("REC_CODSUC",oDp:cSucursal)
             oRecibo:Commit(oRecibo:cWhere)
             oRecibo:End()

          ENDIF

          oHisto:End()

          dDesde:=FchFinMes(dDesde)+1
          nCuantos++

      ENDDO

      AADD(oFrmAnt:aCodTrab,{oLee:CODIGO   ,;
                             oLee:APELLIDO ,;
                             oLee:NOMBRE   ,;
                             oLee:FECHA_ING,;
                             STRZERO(nMes,4)})

//      IF oLee:Recno()>5
//         ? "TERMINDO",dDesde,dHasta
//         EXIT
//      ENDIF

      oLee:DbSkip(1)

   ENDDO

   oFrmAnt:oBtnIniciar:Enable()
   oFrmAnt:oBtnCerrar:SetText("Cerrar")
   oFrmAnt:lProcess:=.F.
   oFrmAnt:oMeter:Set(oLee:RecCount())

// oNm:End()

   CURSORWAIT()

   IF nCuantos>0 .AND. oLee:RecCount()=1
     EJECUTAR("NMCALANTVIEW",oFrmAnt:aCodTrab)
   ENDIF

   oLee:End()

RETURN .T.

//
// DETIENE EL PROCESO DE ACTUALIZACION
//
FUNCTION DETENER(oFrmAnt)

    IF !oFrmAnt:lProcess 
       oFrmAnt:Close()
       RETURN .T.
    ENDIF

    oFrmAnt:lDetener:=MsgNoYes("Desea Detener el proceso","Seleccione una Opción")
    SysRefresh(.T.)

RETURN .T.

/*
// Determina las Fecha de Proceso
*/
FUNCTION GetFecha(oFrmAnt)
RETURN .T.

/*
// Determina los Datos de Otras N®minas
*/
FUNCTION GetOtraNm(oFrmAnt)
  LOCAL oTable
  LOCAL cOtra

  IF LEFT(oFrmAnt:cTipoNom,1)!="O" // Semanal
     oFrmAnt:lFecha :=.F.
     RETURN .T.
  ENDIF

RETURN .T.
/*
// Listra de Trabajadores
*/
FUNCTION LISTTRAB(oFrmAnt,cVarName,cVarGet)
     LOCAL uValue,lResp,oGet,cWhere:=""

     uValue:=oFrmAnt:Get(cVarName)
     oGet  :=oFrmAnt:Get(cVarGet)

     IF LEFT(oFrmAnt:cTipoNom,1)!="O"
       cWhere:="TIPO_NOM"+GetWhere("=",LEFT(oFrmAnt:cTipoNom,1))
     ENDIF

     IF !Empty(oFrmAnt:cCodigoIni)
       cWhere:=ADDWHERE(cWhere,"CODIGO"+GetWhere(">=",oFrmAnt:cCodigoIni))
     ENDIF

     IF !EMPTY(oFrmAnt:cCodGru)
       cWhere:=ADDWHERE(cWhere," GRUPO"+GetWhere("=",oFrmAnt:cCodGru))
     ENDIF

     cWhere:=ADDWHERE(cWhere,oDp:cWhereTrab)

     lResp:=DPBRWPAG("NMTRABAJADOR.BRW",0,@uValue,NIL,.T.,cWhere)

     IF !Empty(uValue)
       oFrmAnt:Set(UPPE(cVarName),uValue)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .T.

/*
// Listar Grupos
*/
FUNCTION LISTGRU(oFrmAnt,cVarName,cVarGet)
     LOCAL cTable :="NMGRUPO"
     LOCAL aFields:={"GTR_CODIGO","GTR_DESCRI"}
     LOCAL cWhere :=""
     LOCAL uValue,lResp,oGet
     LOCAL lGroup :=.F.

     DEFAULT cWhere:=""

     oGet  :=oFrmAnt:Get(cVarGet)
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
FUNCTION VALGRUPO(oFrmAnt,cCodGru,lView)
   LOCAL oTable,lFound:=.T.
   LOCAL cTipoNom:=Left(oFrmAnt:cTipoNom,1)

   DEFAULT lView:=.F.

   IF Empty(cCodGru)
     oFrmAnt:oGrupo:SetText("Todos")
     RETURN .T.
   ENDIF

   oTable:=OpenTable("SELECT GTR_DESCRI FROM NMGRUPO WHERE GTR_CODIGO"+GetWhere("=",cCodGru),.T.)
   lFound:=(oTable:RecCount()>0)

   IIF(lFound,oFrmAnt:oGrupo:SetText(oTable:GTR_DESCRI),NIL)

   oTable:End()

   IF lView
     RETURN .T.
   ENDIF

   IF !lFound
      MensajeErr(GetFromVar("{oDp:XNMGRUPO}")+" : "+cCodGru+" no Existe ")
   ENDIF

   IF lFound

     oTable:=OpenTable("SELECT COUNT(*) FROM NMTRABAJADOR WHERE GRUPO"+;
                       GetWhere("=",oFrmAnt:cCodGru)+;
                       IIF(cTipoNom="O",""," AND TIPO_NOM"+GetWhere("=",cTipoNom)),;
                        .T.)

     IF Empty(oTable:FieldGet(1))

         MensajeErr("No Hay Trabajadores Asociados "+CRLF+;
                    "en el Grupo ["+oFrmAnt:cCodGru+"]"+;
                    IIF(cTipoNom="O",""," para N¢mina ["+ALLTRIM(SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",cTipoNom))+"]"))
         lFound:=.F.

         oFrmAnt:oCodGru:VarPut(SPACE(LEN(cCodGru)),.T.)


     ENDIF

     oTable:End()

   ENDIF

RETURN lFound

/*
// Validar Trabajador
*/
FUNCTION VALCODTRA(oFrmAnt,oGet,lIni)
   LOCAL oTable,lFound:=.T.
   LOCAL cTipoNom:=Left(oFrmAnt:cTipoNom,1)
   LOCAL cCodTra :=oGet:VarGet()
   LOCAL cWhere

   DEFAULT lIni:=.F.

   IF Empty(cCodTra) 
     RETURN .T.
   ENDIF

   cWhere:=ADDWHERE(" CODIGO"+GetWhere("=",cCodTra),oDp:cWhereTrab)

   oTable:=OpenTable("SELECT CODIGO,APELLIDO,NOMBRE,TIPO_NOM FROM NMTRABAJADOR WHERE "+cWhere ,.T.)
   lFound:=(oTable:RecCount()>0)

   IIF(lFound,oFrmAnt:oSayTrab:SetText(ALLTRIM(oTable:APELLIDO)+","+oTable:NOMBRE),NIL)

//   IF lFound .AND. cTipoNom<>"O" .AND. cTipoNom<>oTable:TIPO_NOM
//      MensajeErr("Trabajador Corresponde al Tipo de Nómina "+oTable:TIPO_NOM)
//      lFound:=.F.
//   ENDIF

   oTable:End()

   IF !lFound .AND. !lIni
      eval(oGet:bAction)
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION GetNumFecha(cTipo,cOtraNom,dDesde,dHasta)

   LOCAL oFecha,cNumero:=""

   oFecha:=OpenTable("SELECT FCH_NUMERO FROM NMFECHAS WHERE "+;
                     "FCH_DESDE "+GetWhere("=",dDesde  )+" AND "+;
                     "FCH_HASTA "+GetWhere("=",dHasta  )+" AND "+;
                     "FCH_TIPNOM"+GetWhere("=",cTipo)+" AND "+;
                     "FCH_OTRNOM"+GetWhere("=",cOtraNom),.T.)

  cNumero:=oFecha:FCH_NUMERO
  oFecha:End()

  IF EMPTY(cNumero)

     cNumero:=STRZERO(Val(SqlGetMax("NMFECHAS","FCH_NUMERO"))+1,LEN(cNumero))

  ELSE

     RETURN cNumero

  ENDIF


   oFecha:=OpenTable("SELECT * FROM NMFECHAS",.F.)

   oFecha:Append()
   oFecha:Replace("FCH_INTEGR"  ,"N"          )
   oFecha:Replace("FCH_CONTAB"  ,"N"          )
   oFecha:Replace("FCH_NUMERO"  ,cNumero      )
   oFecha:Replace("FCH_DESDE"   ,dDesde       )
   oFecha:Replace("FCH_HASTA"   ,dHasta       )
   oFecha:Replace("FCH_TIPNOM"  ,cTipo        )
   oFecha:Replace("FCH_OTRNOM"  ,cOtraNom     )
   oFecha:Replace("FCH_SISTEM"  ,oDp:dFecha   )
   oFecha:Replace("FCH_USUARI"  ,oDp:cUsuario )
   oFecha:Replace("FCH_ESTADO"  ,"A"          ) // Nacio Calc/Antiguedad
   oFecha:Replace("FCH_CODSUC"  ,oDp:cSucursal)
   oFecha:Commit()
   oFecha:End()

   AUDITAR("DINC" , NIL ,"NMFECHAS","["+cNumero+"] Creado desde Calcular Antiguedad")

RETURN cNumero

// EOF
