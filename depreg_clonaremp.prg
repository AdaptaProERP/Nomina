// Programa   : DEPREG_CLONAREMP
// Fecha/Hora : 26/06/2021 23:04:58
// Propósito  : Clonar Empresa con Rango de Fecha
// Creado Por : Juan Navas
// Llamado por: DPMENUPRIV
// Aplicación : Administración
// Tabla      : DATASET

#INCLUDE "DPXBASE.CH"


PROCE MAIN(cAll,cCodEmp)
  LOCAL oBtn,oFont,oGrp,cDb:=oDp:cDsnData

  DEFAULT cCodEmp:=oDp:cEmpCod

  cDb:=SQLGET("DPEMPRESA","EMP_BD","EMP_CODIGO"+GetWhere("=",cCodEmp))

           
  DPEDIT():New("Clonar Base de Datos con Transacciones por Periodos","DEPREGCLONAR.EDT","oDepRegC",.T.)

  oDepRegC:dDesde :=oDp:dFchInicio
  oDepRegC:dHasta :=oDp:dFchCierre
  oDepRegC:cCodEmp:=cCodEmp 
  oDepRegC:cDbDes :=SPACE(120)
  oDepRegC:cDbOrg :=PADR(cDb,120) // PADR(oDp:cDsnData,120)
  oDepRegC:cMemo  :=""

  oDepRegC:lValid :=.F.


  oDepRegC:ViewTable("DPEMPRESA",,"EMP_CODIGO","cCodEmp")

  @ 3,1 SAY "Desde: "  RIGHT
  @ 4,1 SAY "Hasta: "  RIGHT
  @ 6,1 SAY "Origen: " RIGHT

  @ 7,1 SAY "BD Origen : " RIGHT
  @ 7,1 SAY "BD Destino: " RIGHT
	
  @ 4,1 BMPGET oDepRegC:oDesde  VAR oDepRegC:dDesde UPDATE;
        PICTURE oDp:cFormatoFecha;
        NAME "BITMAPS\Calendar.bmp";
        WHEN .T.;
        ACTION LbxDate(oDepRegC:oFchIniPla,oDepRegC:dDesde);
        SIZE 41,10

 @ 5,1 BMPGET oDepRegC:oHasta  VAR oDepRegC:dHasta UPDATE;
        PICTURE oDp:cFormatoFecha;
        NAME "BITMAPS\Calendar.bmp";
        WHEN .T.;
        ACTION LbxDate(oDepRegC:oHasta,oDepRegC:dHasta);
        SIZE 41,10

 @ 11.5, 1.0 BMPGET oDepRegC:oCodEmp  VAR oDepRegC:cCodEmp;
             VALID oDepRegC:VALEMPCOD();
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPEMPRESA",NIL,"1=1",NIL,NIL,NIL,NIL,NIL,NIL,oDepRegC:oCodEmp),oDpLbx:GetValue("EMP_CODIGO",oDepRegC:oCodEmp)); 
             WHEN .T.;
             SIZE 12,10

  oDepRegC:oCodEmp:cMsg    :="Empresa Origen"
  oDepRegC:oCodEmp:cToolTip:="Empresa Destino"

  @ 10,10 SAY oDepRegC:oEMP_NOMBRE PROMPT SQLGET("DPEMPRESA","EMP_NOMBRE","EMP_CODIGO"+GetWhere("=",oDepRegC:cCodEmp))

  //
  // Campo : BDDES    
  // Uso   : Base de Datos o Ruta                    
  //
  @ 8.2, 1.0 BMPGET oDepRegC:oBdOrg;
                    VAR oDepRegC:cDbOrg;
                    VALID !VACIO(oDepRegC:cDbOrg,NIL);
                    NAME "BITMAPS\DATABASE2.bmp";
                    ACTION oDepRegC:VERBD(oDepRegC:oBdOrg);
                    WHEN .T.;
                    FONT oFont

  @ 12,10 GET oDepRegC:oBdDes VAR oDepRegC:cDbDes VALID oDepRegC:DEPREG_VALBD()

  oDepRegC:lMsgBar  :=.F.

  @12,12 GET oDepRegC:oMemo  VAR oDepRegC:cMemo MULTI READONLY SIZE 200,200

  oDepRegC:Activate({|| oDepRegC:ViewDatBar()})

RETURN .t.

FUNCTION VALEMPCOD()
  LOCAL lFind:=ISSQLFIND("DPEMPRESA","EMP_CODIGO"+GetWhere("=",oDepRegC:cCodEmp))
  oDepRegC:oEMP_NOMBRE:Refresh(.T.)

  IF !lFind 
     EVAL(oDepRegC:oCodEmp:bAction)
     RETURN .F.
  ENDIF

  oDepRegC:cDbOrg:=SQLGET("DPEMPRESA","EMP_BD","EMP_CODIGO"+GetWhere("=",oDepRegC:cCodEmp))
  oDepRegC:oBdOrg:VarPut(oDepRegC:cDbOrg,.T.)

RETURN .T.

/*
// Ver las Bases de Datos
*/
FUNCTION VERBD(oControl)
  LOCAL nLen  :=LEN(oDepRegC:oBdOrg)
  LOCAL x     :=MySqlStart()
  LOCAL cLista:=EJECUTAR("MYSQLLISTBD",oControl,oDepRegC:cDbOrg,"")

  IF "GET"$oControl:ClassName() .AND. !Empty(cLista)
     oControl:VarPut(PADR(cLista,nLen),.T.)
  ENDIF

RETURN cLista


/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
 LOCAL oCursor,oBar,oBtn,oFont,
 LOCAL oDlg:=oDepRegC:oDlg

 DEFINE CURSOR oCursor HAND
 DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
 DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

 DEFINE BUTTON oBtn;
        OF oBar;
        NOBORDER;
        FONT oFont;
        FILENAME oDp:cPathBitMaps+"RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
        WHEN !Empty(oDepRegC:cDbDes) .AND. oDepRegC:lValid;
        ACTION oDepRegC:EMPCLONAR(oDepRegC:dDesde,oDepRegC:dHasta,oDepRegC:oMemo,oDepRegC:cDbOrg,oDepRegC:cDbDes,.T.)

  oDepRegC:oBtnSave:=oBtn

 
  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME oDp:cPathBitMaps+"XSALIR.BMP";
         ACTION oDepRegC:Close()

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(NIL,oDp:nGris)})

  oDepRegC:oBar:=oBar


RETURN .T.

FUNCTION DEPREG_VALBD()
  LOCAL lFind:=ISSQLFIND("DPEMPRESA","EMP_BD"+GetWhere("=",oDepRegC:cDbDes))

  oDepRegC:lValid:=.F.

  IF lFind
     oDepRegC:oBdDes:MsgErr("Base de Datos ya Existe","Validación")
     RETURN .F.
  ENDIF

  oDepRegC:lValid:=.T.
  oDepRegC:oBtnSave:ForWhen(.T.)

RETURN .T.

FUNCTION EMPCLONAR(dDesde,dHasta,oMemo,cDbOrg,cDbDes,lAsk)
  LOCAL aTablas:={},U,I,oDb,cSql:="",cTable,cWhere,cSelect,cInner,cPrimary
  LOCAL cId    :=DTOS(dFecha),nContar:=0
  LOCAL cDb    :=ALLTRIM(cDbDes),lFind,cFile
  LOCAL oEmp   :=NIL

  DEFAULT lAsk:=.T.,;
          cDb :="NUEVA"+DTOS(oDp:dFecha)

  cDbOrg:=ALLTRIM(cDbOrg)
  cDbDes:=ALLTRIM(cDbDes)

  IF lAsk .AND. !MsgNoYes("Desea Clonar Empresa BD "+cDbOrg+"->"+cDbDes+" Periodo "+DTOC(dDesde)+"-"+DTOC(dHasta))
     RETURN .F.
  ENDIF

// ? dDesde,dHasta,oMemo,cDbDes,cCodEmp,lAsk,"dDesde,dHasta,oMemo,cDb,cCodEmp,lAsk"
  
  lFind :=oDp:oMySqlCon:ExistDb( cDbDes )

  IF !lFind
    lFind :=oDp:oMySqlCon:ExistDb( UPPER(cDbDes) )
  ENDIF

  IF !lFind

    oDp:oMySqlCon:CreateDB( cDbDes )
    oDp:lCrearTablas:=.T. // Asi no se ejecta DPSQLBINTONUM 

  ENDIF

  oDb:=OpenOdbc(cDbOrg)

  AADD(aTablas,{"DPINVTRANSF"  ,"TNI_FECHA","",""})
  AADD(aTablas,{"DPDOCMOV"     ,"DOC_FECHA","",""})
  AADD(aTablas,{"DPMOVINV"     ,"MOV_FECHA","",""})
  AADD(aTablas,{"DPDOCCLI"     ,"DOC_FECHA","LEFT JOIN VIEW_DOCCLICXC ON DOC_CODSUC=CXD_CODSUC AND DOC_TIPDOC=CXD_TIPDOC AND DOC_NUMERO=CXD_NUMERO"                     ,"CXD_CODSUC IS NULL"})
  AADD(aTablas,{"DPDOCCLICTA"  ,"DOC_FECHA","INNER JOIN DPDOCCLI ON CCD_CODSUC=DOC_CODSUC AND CCD_TIPDOC=DOC_TIPDOC AND CCD_NUMERO=DOC_NUMERO AND CCD_TIPTRA=DOC_TIPTRA",""})
  AADD(aTablas,{"DPDOCPRO"     ,"DOC_FECHA","",""})
  AADD(aTablas,{"DPDOCPROCTA"  ,"DOC_FECHA","INNER JOIN DPDOCPRO ON CCD_CODSUC=DOC_CODSUC AND CCD_TIPDOC=DOC_TIPDOC AND CCD_CODIGO=DOC_CODIGO AND CCD_NUMERO=DOC_NUMERO AND CCD_TIPTRA=DOC_TIPTRA",""})
  AADD(aTablas,{"DPASIENTOS"   ,"MOC_FECHA","",""})
  AADD(aTablas,{"DPCBTE"       ,"CBT_FECHA","",""})
  AADD(aTablas,{"DPCAJAMOV"    ,"CAJ_FECHA","",""})
  AADD(aTablas,{"DPCTABANCOMOV","MOB_FECHA","",""})


  AADD(aTablas,{"NMFECHAS"     ,"FCH_HASTA",""                                               ,""})
  AADD(aTablas,{"NMRECIBOS"    ,"FCH_HASTA","INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO",""})
  AADD(aTablas,{"NMHISTORICO"  ,"FCH_HASTA","INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO",""})

  cSql:="SET FOREIGN_KEY_CHECKS=0"

  IF oMemo=NIL
    DpMsgRun("Procesando","Clonando DB:"+cDb,NIL,LEN(aTablas))
    DpMsgSetTotal(LEN(aTablas))
  ENDIF

  LMKDIR("SQLLOG")	

  FOR I=1 TO LEN(aTablas)

     IF oMemo=NIL
       DpMsgSet(I,.T.,NIL,"Evaluando "+cDbOrg+"."+aTablas[I,1]+" ["+LSTR(I)+"/"+LSTR(LEN(aTablas))+"]")
     ENDIF

     cTable :=aTablas[I,1]

     IF EJECUTAR("DBISTABLE",cDbOrg,cTable) .AND. !EJECUTAR("DBISTABLE",cDbDes,cTable)

       cSelect :=SELECTFROM(aTablas[I,1],.T.,NIL,oDb)
       cInner  :=aTablas[I,3]
       cWhere  :=aTablas[I,4]
       cWhere  :=IF(Empty(cWhere),""," AND ")+cWhere
       cPrimary:=EJECUTAR("GETPRIMARY",cTable)
       cSql    :="CREATE TABLE "+cDb+"."+cTable+" "+cSelect+" "+cInner+" WHERE "+GetWhereAnd(aTablas[I,2],dDesde,dHasta)+cWhere

       IF !Empty(cPrimary)
          cSql:=cSql+" GROUP BY "+cPrimary
       ENDIF
     
       cSql   :=STRTRAN(cSql," FROM "," FROM "+cDbOrg+".")

       IF oMemo=NIL
         DpMsgSet(I,.T.,NIL,"Copiando Tabla "+cTable+" ["+LSTR(I)+"/"+LSTR(LEN(aTablas))+"]")
       ENDIF

       cFile:="SQLLOG\"+cDbOrg+"_"+cTable+".SQL"
       DPWRITE(cFile,cSql)

       IF oDb:EXECUTE(cSql)
         oMemo:Append("Tabla "+cTable+" Copiada"+" ["+LSTR(I)+"/"+LSTR(LEN(aTablas))+"]"+CRLF)
       ELSE
         oMemo:Append("Tabla "+cTable+" no pudo ser Copiada"+CRLF)
         nContar++
       ENDIF

    ELSE

      IF EJECUTAR("DBISTABLE",cDbDes,cTable)
        oMemo:Append("Tabla "+cDbDes+"."+cTable+" ya Existe "+" ["+LSTR(I)+"/"+LSTR(LEN(aTablas))+"]"+CRLF)
      ELSE
        oMemo:Append("Tabla "+cDbOrg+"."+cTable+" no Existe "+" ["+LSTR(I)+"/"+LSTR(LEN(aTablas))+"]"+CRLF)
      ENDIF

    ENDIF

  NEXT I

  EJECUTAR("DPEMPRESADUPLICA",cDbOrg,cDb,.F.,NIL,NIL,NIL,oMemo)

  cSql:="SET FOREIGN_KEY_CHECKS=1"

  oDb:EXECUTE(cSql)
 
  DpMsgClose()

  oEmp:=EJECUTAR("DPEMPRESA",1,"0000",.F.,NIL,cDbDes)
  oEmp:oEMP_BD:VarPut(cDbDes,.T.)

RETURN (nContar=0)


// EOF

