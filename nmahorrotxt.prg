// Programa   : NMAHORROTXT
// Fecha/Hora : 29/04/2004 12:44:44
// Propósito  : Remesa Electrónica de Caja de Ahorro
// Creado Por : Juan Navas
// Llamado por: ACTUALIZA
// Aplicación : Nómina
// Tabla      : Todas

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dDesde,dHasta,cTipoNom,cOtraNom)

  LOCAL aBancos :=GETOPTIONS("NMBANCOS"    ,"BAN_BCOTXT"),;
        nAt     :=0
  LOCAL cFile  
  LOCAL oData

  EJECUTAR("NMTIPNOM")

  nAt:=ASCAN(aBancos,"Ninguno")

  IF nAt>0
    ADEL(aBancos,nAt)
    ASIZE(aBancos,Len(aBancos)-1)
  ENDIF

  oData  :=DATASET("NOMINA","ALL")
  oDp:cBanco:=oData:Get("cAhorroTxt",aBancos[1])   // Modelo de Banco    
  cFile     :=oData:Get("cFileBcofh" ,PADR(oDp:cPath+"fondoah.txt",90))

  oData:End()
 
  oFrmCaj:=DPEDIT():New("Remesa Electrónica Caja/Fondo de Ahorro para el Banco","NOMAHORRTXT.edt","oFrmCaj",.T.)
  oFrmCaj:cFileChm     :="CAPITULO2.CHM"
  oFrmCaj:cTipoNom     :=oDp:cTipoNom
  oFrmCaj:cOtraNom     :=oDp:cOtraNom
  oFrmCaj:cBanco       :=oDp:cBanco  
  oFrmCaj:dDesde       :=FCHINIMES(oDp:dFecha)
  oFrmCaj:dHasta       :=FCHFINMES(oDp:dFecha)
  oFrmCaj:oMeter       :=NIL
  oFrmCaj:nTrabajadores:=0
  oFrmCaj:oSayTrab     :=NIL
  oFrmCaj:lCancel      :=.F.
  oFrmCaj:oNm          :=NIL
  oFrmCaj:lCancel      :=.T. // No Solicita Cancelar
  oFrmCaj:cCodGru      :=oDp:cCodGru
  oFrmCaj:oCodGru      :=NIL
  oFrmCaj:nSalida      :=2
  oFrmCaj:lCodigo      :=.T.           // Requiere Rango del Trabajador
  oFrmCaj:lFecha       :=.T.           // Rango de Fecha
  oFrmCaj:lEditar      :=.T.           // Proceso Optimizado                       
  oFrmCaj:dFecha       :=oDp:dFecha    // Toma la Fecha del Sistema
  oFrmCaj:cFileBcofh   :=cFile
  oFrmCaj:cFileOld     :=oFrmCaj:cFileBcofh
  oFrmCaj:cSql         :=""
  oFrmCaj:cOtraNom     :=oDp:cOtraNom 

  @ 0,1 GROUP oGrp TO 4, 21.5 PROMPT "Nómina"
  @ 4,1 GROUP oGrp TO 4, 21.5 PROMPT "Periodo"

  @ 5,2 SAY "Banco"
  @ 6,2 SAY "Archivo Destino"

  @ 3,12 COMBOBOX oFrmCaj:oBanco  VAR oFrmCaj:cBanco  ITEMS aBancos  

  // RANGO DE FECHA

  @ 8,12 BMPGET oFrmCaj:oFileTxt  VAR oFrmCaj:cFileBcofh;
         NAME "BITMAPS\FIND.bmp";
         VALID 1=1;
         ACTION (oFrmCaj:FileOld:= cGetFile32(MI("Fichero ")+"TXT (*.txt) |*.txt| "+MI("Seleccionar Fichero ")+" DBF (*.txt) |*.txt|",;
                 MI("Seleccionar Fichero ")+"TXT ", 1, oFrmCaj:cFileBcofh, .t.),;
                 oFrmCaj:oFileTxt:VarPut(IIF(Empty(oFrmCaj:FileOld),oFrmCaj:FileTxt,oFrmCaj:FileOld),.t.),;
                 DpFocus(oFrmCaj:oFileTxt))

  @ 4,12 BMPGET oFrmCaj:oDesde VAR oFrmCaj:dDesde PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN oFrmCaj:lFecha;
         ACTION LbxDate(oFrmCaj:oDesde,oFrmCaj:dDesde)

  @ 5,12 BMPGET oFrmCaj:oHasta VAR oFrmCaj:dHasta PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN oFrmCaj:lFecha;
         VALID (Igualar(oFrmCaj:oDesde,oFrmCaj:oHasta).AND.oFrmCaj:dHasta>=oFrmCaj:dDesde.AND.!EMPTY(oFrmCaj:dHasta));
         ACTION LbxDate(oFrmCaj:oHasta,oFrmCaj:dHasta)

  // RANGO DE TRABAJADOR 

  @ 3,12 CHECKBOX oFrmCaj:lEditar PROMPT "Editar Archivo"

  @ 08,01 METER oFrmCaj:oMeter VAR oFrmCaj:nTrabajadores

  @ 08,01 SAY oFrmCaj:oSayTrab  PROMPT "Trabajador:"+SPACE(30)

//  @ 08,01 SAY oFrmCaj:oGrupo PROMPT ""+SPACE(30)
//  oFrmCaj:ValGrupo(oFrmCaj,oFrmCaj:cCodGru)

  @ 6,07 BUTTON oFrmCaj:oBtnIniciar PROMPT "Iniciar " ACTION  (CursorWait(),;
                                    oFrmCaj:SetMsg("Ejecutar Actualización"),;
                                    oFrmCaj:EJECUTAR(oFrmCaj,.F.))

  @ 6,07 BUTTON oFrmCaj:oBtnIniciar PROMPT "Listar " ACTION  (CursorWait(),;
                                    oFrmCaj:SetMsg("Generando Listado"),;
                                    oFrmCaj:EJECUTAR(oFrmCaj,.T.))

  @ 6,10 BUTTON oFrmCaj:oBtnCerrar PROMPT "Cerrar  " ACTION oFrmCaj:Detener(oFrmCaj) CANCEL

  oFrmCaj:Activate(NIL)

RETURN NIL

FUNCTION EJECUTAR(oFrmCaj,lListar)
   LOCAL aNomina,cTitle1,cTitle2,lHubo:=.F.
   LOCAL oTable,oTrabj,oNomina
   LOCAL nTrabj  :=0 // Cantidad de Trabajadores
   LOCAL cTipoNom:=LEFT(oFrmCaj:cTipoNom,1)
   LOCAL cOtraNom:=IIF(cTipoNom!="O","",LEFT(oFrmCaj,2))
   LOCAL cSql,oData,cWhere

   LOCAL cWhereGru:=EJECUTAR("NMWHEREGRU",oFrmCaj:cCodGru)

   oData  :=DATASET("NOMINA","ALL")
   oData:cAhorroTxt:=oFrmCaj:cBanco
   oData:cFileBcofh:=oFrmCaj:cFileBcofh
   oData:End()

   oTrabj:=OpenTable(" SELECT COUNT(*) FROM NMTRABAJADOR "+;
                     " INNER JOIN NMBANCOS ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
                     " WHERE NMBANCOS.BAN_BCOTXT"+GetWhere("=",oFrmCaj:cBanco),.T.)

   nTrabj:=oTrabj:FieldGet(1)
   oTrabj:End()

   IF Empty(nTrabj)

      MensajeErr("No hay Trabajadores Asociados con el Banco: "+CRLF+;
                 oFrmCaj:cBanco,;
                 "Información no Encontrada")

      RETURN .F.

   ENDIF

   cWhere:=GETWHEREOR("HIS_CODCON",{oDp:cDAhorro,oDp:cHAhorro,oDp:cNAhorro})

   cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,CTABANAHOR AS BANCO_CTA,TIPO_CED,CEDULA,SUM(ABS(HIS_MONTO)) AS REC_MONTO FROM NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO=NMRECIBOS.REC_CODTRA "+;
          " INNER JOIN NMBANCOS     ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
          " INNER JOIN NMHISTORICO  ON HIS_NUMREC=REC_NUMERO "+;
          " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
          " WHERE "+;
          " FCH_SISTEM "+GetWhere(">=",oFrmCaj:dDesde  )+" AND "+;
          " FCH_SISTEM "+GetWhere("<=",oFrmCaj:dHasta  )+" AND "+;
          " BANCO_CTA<>'' "+;
            cWhereGru  +" AND "+;
          " NMBANCOS.BAN_BCOTXT"+GetWhere("=",oFrmCaj:cBanco)+ " AND "+cWhere+;
          " GROUP BY CODIGO,APELLIDO,NOMBRE,BANCO_CTA,TIPO_CED,CEDULA"

    oTable:=OpenTable(cSql,.T.)
    oTable:GoTop()

    If Empty(oTable:RecCount())

      MensajeErr("Recibos no Encontrados"+CRLF+;
                 "Asegúrese que los trabajadores esten Asociados al Banco:"+oFrmCaj:cBanco+CRLF+;
                 "Trabajadores Asociados "+ALLTRIM(STR(nTrabj)),;
                 "Información no Encontrada")
      
      oTable:End()

      RETURN .F.

    Endif

    IF lListar

      oFrmCaj:TXTIMPRIME(oFrmCaj,oTable)

    ELSE

      DO CASE

         CASE "BANPLUS"$UPPE(oFrmCaj:cBanco)

            EJECUTAR("BCOBANP",oTable,ALLTRIM(oFrmCaj:cFileBcofh),oFrmCaj:oMeter,oFrmCaj:oSayTrab,oFrmCaj:lEditar)

         CASE UPPE(oFrmCaj:cBanco)="PROVINCIAL"

            EJECUTAR("BCOPROV",oTable,ALLTRIM(oFrmCaj:cFileBcofh),oFrmCaj:oMeter,oFrmCaj:oSayTrab,oFrmCaj:lEditar)

         CASE UPPE(oFrmCaj:cBanco)="FEDERAL"

            EJECUTAR("BCOFEDERAL",oTable,ALLTRIM(oFrmCaj:cFileBcofh),oFrmCaj:oMeter,oFrmCaj:oSayTrab,oFrmCaj:lEditar)

         CASE UPPE(oFrmCaj:cBanco)="INDUSTRIAL"

            EJECUTAR("BCOIND",oTable,ALLTRIM(oFrmCaj:cFileBcofh),oFrmCaj:oMeter,oFrmCaj:oSayTrab,oFrmCaj:lEditar)
 
         CASE UPPE(oFrmCaj:cBanco)="MERCANTIL"

            EJECUTAR("BCOMERC",oTable,ALLTRIM(oFrmCaj:cFileBcofh),oFrmCaj:oMeter,oFrmCaj:oSayTrab,oFrmCaj:lEditar)

         CASE UPPE(oFrmCaj:cBanco)="VENEZOLANO"

            EJECUTAR("BCOVCRE",oTable,ALLTRIM(oFrmCaj:cFileBcofh),oFrmCaj:oMeter,oFrmCaj:oSayTrab,oFrmCaj:lEditar)

      ENDCASE

    ENDIF

    oTable:End()

RETURN .T.

//
// DETIENE EL PROCESO DE ACTUALIZACION
//
FUNCTION DETENER(oFrmCaj)

    IF oFrmCaj:oNm=NIL
       oFrmCaj:Close()
       RETURN .T.
    ENDIF

    SysRefresh(.T.)

RETURN .T.

/*
// Determina las Fecha de Proceso
*/
FUNCTION GetFecha(oFrmCaj)
  LOCAL nLen    :=LEN(oFrmCaj:oOtraNom:aItems)
  LOCAL cTipoNom:=UPPE(Left(oFrmCaj:cTipoNom,1))
  LOCAL cOtraNom:=UPPE(Left(oFrmCaj:cOtraNom,2))
  LOCAL oDesde  :=oFrmCaj:oDesde
  LOCAL oTabla 

  IF cTipoNom!="O"
     // Otra N«mina debe Ser Ninguna
     EVAL(oFrmCaj:oOtraNom:bSetGet,oFrmCaj:oOtraNom:aItems[nLen])
     oFrmCaj:lFecha :=.F.
     oFrmCaj:oOtraNom:Refresh(.T.)
  ELSE
    oTabla:=OpenTable("SELECT OTR_PERIOD FROM NMOTRASNM WHERE OTR_CODIGO"+GetWhere("=",cOtraNom),.T.)
    oFrmCaj:lFecha :=(oTabla:OTR_PERIOD="I")
    oTabla:End()
  ENDIF

  EJECUTAR("FCH_RANGO",cTipoNom,oFrmCaj:dFecha,cOtraNom)

  oFrmCaj:dDesde:=oDp:dDesde // Toma las Fechas generadas por FCH_RANGO
  oFrmCaj:dHasta:=oDp:dHasta

  DpSetVar(oFrmCaj:oDesde,oDp:dDesde)
  DpSetVar(oFrmCaj:oHasta,oDp:dHasta)

  IF EMPTY(oDp:dDesde)
    oFrmCaj:lFecha:=.T. // Si Puede Editar la Fecha
  ENDIF

  oFrmCaj:oOtraNom:ForWhen(.T.)

RETURN .T.

/*
// Determina los Datos de Otras N«minas
*/
FUNCTION GetOtraNm(oFrmCaj)
  LOCAL oTable
  LOCAL cOtra

  IF LEFT(oFrmCaj:cTipoNom,1)!="O" // Semanal
     oFrmCaj:lFecha :=.F.
     RETURN .T.
  ENDIF

RETURN .T.

FUNCTION LISTTRAB(oFrmCaj,cVarName,cVarGet)
     LOCAL uValue,lResp,oGet,cWhere:=""

     uValue:=oFrmCaj:Get(cVarName)
     oGet  :=oFrmCaj:Get(cVarGet)

     IF LEFT(oFrmCaj:cTipoNom,1)!="O"
       cWhere:="TIPO_NOM"+GetWhere("=",LEFT(oFrmCaj:cTipoNom,1))
     ENDIF

     lResp:=DPBRWPAG("NMTRABAJADOR.BRW",0,@uValue,NIL,.T.,cWhere)

     IF !Empty(uValue)
       oFrmCaj:Set(UPPE(cVarName),uValue)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .T.

/*
// Listar Grupos
*/
FUNCTION LISTGRU(oFrmCaj,cVarName,cVarGet)
     LOCAL cTable :="NMGRUPO"
     LOCAL aFields:={"GTR_CODIGO","GTR_DESCRI"}
     LOCAL cWhere :=""
     LOCAL uValue,lResp,oGet
     LOCAL lGroup :=.F.

     DEFAULT cWhere:=""

     oGet  :=oFrmCaj:Get(cVarGet)
     uValue:=EJECUTAR("REPBDLIST",cTable,aFields,lGroup,cWhere)

     IF !Empty(uValue)
       oGet:VarPut(uValue,.T.)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .F.

/*
// Listado
*/

#include "include\REPORT.ch"

FUNCTION TXTIMPRIME(oFrmCaj,oCursor)
     LOCAL nLineas:=0

     PRIVATE oReport

     oCursor:=OpenTable(cSql,.T.)

     oCursor:GoTop()
     nLineas:=oCursor:RecCount()

     REPORT oReport TITLE  "Nómina para: "+ALLTRIM(oFrmCaj:cBanco),;
            ALLTRIM(oDp:cEmpresa),;
            "Periodo <"+DTOC(oFrmCaj:dDesde)+" - "+DTOC(oFrmCaj:dHasta)+">",;
            "Fecha: "+dtoc(Date())+" Hora: "+TIME();
            CAPTION "Nómina para "+oFrmCaj:cBanco  ;
            FOOTER "Página: "+str(oReport:nPage,3)+" Registros: "+alltrim(str(nLineas,5)) CENTER ;
            PREVIEW

     COLUMN TITLE "CODIGO";
            DATA oCursor:CODIGO;
            SIZE 10;
            LEFT 

     COLUMN TITLE "Trabajador";
            DATA ALLTRIM(oCursor:APELLIDO)+","+oCursor:NOMBRE;
            SIZE 30;
            LEFT 

     COLUMN TITLE "CUENTA";
            DATA oCursor:BANCO_CTA;
            SIZE 20;
            LEFT 

     COLUMN TITLE "Monto";
            DATA oCursor:REC_MONTO;
            PICTURE "9,999,999,999,999.99";
            TOTAL ;
            SIZE 14;
            RIGHT  
     
     END REPORT

     oReport:bSkip:={||oCursor:DbSkip()}

     ACTIVATE REPORT oReport ;
              WHILE !oCursor:Eof();

     oTable:End()

RETURN NIL
// EOF
