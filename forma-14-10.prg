// Programa   : FORMA-14-10
// Fecha/Hora : 26/08/2004 08:38:14
// Propósito  : Planilla Declaración Mensual de Empleo
// Creado Por : Juan Navas
// Llamado por: NMMENU
// Aplicación : Nómina
// Tabla      : FORMA-14-10

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"

PROCE MAIN(dDesde,dHasta)
  LOCAL oBtn,oFont,oData,nClrText:=CLR_BLUE

  DEFAULT dDesde    :=FCHINIMES(oDp:dFecha),;
          dHasta    :=FCHFINMES(oDp:dFecha)

  CURSORWAIT()

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD

  oData:=DATASET("NOMINA","ALL")

  oF1410:=DPEDIT():New("Forma 14-10 Novedades","NMFORMA1410.EDT","oF1410",.T.)

//  oF1410:aTrimes   :={}
    oF1410:nCant     :=0
    oF1410:nPag      :=1 // Cantidad de Páginas
    oF1410:cFileChm  :="CAPITULO2.CHM"
    
//  oF1410:cAno      :=STRZERO(YEAR(oDp:dFecha),4)
//  oF1410:cEstado   :=oData:Get("cEstado"   ,SPACE(40))
//  oF1410:cMunicipio:=oData:Get("cMunicipio",SPACE(60))
//  oF1410:cParroquia:=oData:Get("cParroquia",SPACE(60))
//  oF1410:cLocalidad:=oData:Get("cLocalidad",SPACE(60))
//  oF1410:cNumEstabl:=oData:Get("cNumEstabl",SPACE(15))
   oF1410:cMinTra   :=oData:Get("cMinTra"   ,SPACE(10))
   oF1410:cPictSSO  :=oData:Get("cPictSSO"   ,"9999999")
//  oF1410:cRif      :=oData:Get("cRif"      ,SPACE(14))        // Rif
//  oF1410:cNit      :=oData:Get("cNit"      ,SPACE(14))        // NIT
//  oF1410:cSSO      :=oData:Get("cSSO"      ,SPACE(14))        // Seguro Social
//  oF1410:cDir1     :=oData:Get("cDir1"     ,SPACE(14))        // Dirección 1
//  oF1410:cDir2     :=oData:cDir2          // Dirección 2
//  oF1410:cDir3     :=oData:cDir3          // Dirección 3
//  oF1410:cTel1     :=oData:cTel1          // Teléfono 1
//  oF1410:cTel2     :=oData:cTel2          // Teléfono 2
//  oF1410:cTel3     :=oData:Get("cTel3"     ,SPACE(14))        // Teléfono 2
//  oF1410:cEmail    :=oData:Get("cEmail"    ,SPACE(30))        // Email
  oF1410:cInform   :=oData:Get("cInform"   ,PADR(oDp:cUsNombre,30))        // Informante
  oF1410:cLugar    :=oData:Get("cLugar"    ,SPACE(30))        // Cargo 
  oF1410:lRun      :=.T.
  oF1410:dFecha    :=oDp:dFecha

  oF1410:dDesde    :=dDesde // FCHINIMES(oDp:dFecha)
  oF1410:dHasta    :=dHasta //FCHFINMES(oDp:dFecha)

  oF1410:lSueldos  :=.T.
  oF1410:lPerRep   :=.T.
  oF1410:cPictSSO  :=PADR(oF1410:cPictSSO,10)
  oData:End(.F.)

  @ 0.5,0.5 GROUP  oF1410:oGrupo  TO 4, 21.5 PROMPT " Empresa "    
  @ 2.5,0.5 GROUP  oF1410:oGrupo2 TO 4, 21.5 PROMPT " Periodo "    
  @ 5.5,0.5 GROUP  oF1410:oGrupo3 TO 8, 21.5 PROMPT " Datos para la Planilla "    

  @ 0.5,2.0 SAY oDp:cEmpresa 

  @ 4,1 BMPGET oF1410:oDesde VAR oF1410:dDesde PICTURE "99/99/9999";
        NAME "BITMAPS\Calendar.bmp";
        ACTION LbxDate(oF1410:oDesde,oF1410:dDesde)

  @ 5,1 BMPGET oF1410:oHasta VAR oF1410:dHasta PICTURE "99/99/9999";
        NAME "BITMAPS\Calendar.bmp";
        ACTION LbxDate(oF1410:oHasta,oF1410:dHasta)

  @ 5,1 SAY "Representante o Patrono"
  @ 5,0 GET oF1410:oInform VAR oF1410:cInform

  @ 6,0 SAY "Lugar"
  @ 6,0 GET oF1410:oLugar  VAR oF1410:cLugar
 
  @ 7,0 SAY "Fecha"
  @ 7,1 BMPGET oF1410:oFecha VAR oF1410:dFecha PICTURE "99/99/9999";
        NAME "BITMAPS\Calendar.bmp";
        ACTION LbxDate(oF1410:oFecha,oF1410:dFecha)

  @ 7,0 SAY "Formato"
  @ 7,0 GET oF1410:oPictSSO VAR oF1410:cPictSSO RIGHT

  @ 4,1 BUTTON oF1410:oBtn PROMPT "Mes Anterior";
        ACTION (oF1410:oHasta:VarPut(oF1410:dDesde-1,.T.),;
                oF1410:oDesde:VarPut(FchIniMes(oF1410:dHasta),.T.))

  @ 5,2  CHECKBOX oF1410:lSueldos PROMPT "Incluir Aumentos de Sueldos"
  @ 6,2  CHECKBOX oF1410:lPerRep  PROMPT "Permisos y Reposos"

  @ 10,01 METER oF1410:oMeter VAR oF1410:nCant

/*
  @09, 33  SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\RUN.BMP" NOBORDER;
           LEFT PROMPT "Ejecutar";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oF1410:SaveNmConfig(oF1410))


   oBtn:cToolTip:="Grabar Datos y Ejecutar Planilla"
   oBtn:cMsg    :=oBtn:cToolTip

   @09, 43 SBUTTON oBtn ;
           SIZE 45, 20 FONT oFont;
           FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
           LEFT PROMPT "Cancelar";
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION (oF1410:Close()) CANCEL

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Cancelar y Cerrar Formulario "
   oBtn:cMsg    :=oBtn:cToolTip
*/

   oF1410:Activate({||oF1410:FRMONINIT()})

RETURN NIL

FUNCTION FRMONINIT()
  LOCAL oBar,oBtn,oBtn3

  DEFINE BUTTONBAR oBar SIZE 39, 39 3D OF oF1410:oDlg

  DEFINE XBUTTON oBtn ;
         FILE oDp:cPathBitMaps+"RUN.BMP";
         TOOLTIP "Ejecutar";
         SIZE 38,38;
         ACTION oF1410:SaveNmConfig(oF1410) OF oBar

  DEFINE XBUTTON oBtn ;
         FILE oDp:cPathBitMaps+"xSalir.BMP";
         TOOLTIP "Grabar";
         SIZE 38,38;
         ACTION oF1410:Close();
         OF oBar

   Aeval(oBar:aControls,{|a,n|a:SetColor(NIL,oDp:nGris)})

   oBar:SetColor(NIL,oDp:nGris)

RETURN .T.


/*
// Grabar Empresa
*/
FUNCTION SaveNmConfig(oF1410)
  LOCAL aDir,cDir:="planillas\",aData:={},oTable,nAt,U,I,cVar,cVarF,cSql,nContar,cWhere,nPag:=1,nCantP:=0
  LOCAL cCarta:="planillas\forma-14-10.doc"
  LOCAL cTempo:=STRTRAN("_"+cTempFile()+".DOC","..",".")
  LOCAL cPath :=cFilePath(GetModuleFileName( GetInstance() ))+"\planillas\"
  LOCAL oData,nLines:=0
  LOCAL aEmpty:={},cDiaD,cMesD,cDiaH,cMesH,cMemo
  LOCAL oReposo,oPermiso,cReposo,aCodTra:={},cTemp2:="",cSqlS,oSalario
  LOCAL lRun  :=oF1410:lRun,cCodTra:="",nSalario:=0,nSalAnt:=0,cSemAnt:="",cSemAct:="",cMesAnt:="",cMesAct:=""
  LOCAL dFchIniAnt,dFchFinAnt,oAnterior

/*
  AADD(aEmpty,{oF1410:cMinTra,"Número del Ministerio del Trabajo"})
  AADD(aEmpty,{oF1410:cRif   ,"Número del RIF"})
  AADD(aEmpty,{oF1410:cNit   ,"Número del NIT"})
  AADD(aEmpty,{oF1410:cSSO   ,"Número del IVSS"})
*/

  AEVAL(aEmpty,{|a,n|cMemo:=cMemo+;
                     IIF(Empty(a[1]),a[2]+CRLF,"")})

  IF !Empty(cMemo)
     MensajeErr(cMemo,"Campos Vacios, Ver [Configurar Empresa]")
  ENDIF

  CURSORWAIT()

  oData:=DATASET("NOMINA","ALL")

  oData:cInform :=oF1410:cInform
  oData:cLugar  :=oF1410:cLugar
  oData:cPictSSO:=oF1410:cPictSSO

  oData:Save()
  oData:End()

  aDir   := Array( ADir( cDir+"_*.DOC" ) )
  aDir( cDir+"_*.DOC", aDir )
  AEVAl(aDir,{|a,n|FERASE(cPath+a)})

  AADD(aData,{"EMP_NOMBRE"    ,oDp:cEmpresa})
  AADD(aData,{"PAG"           ,"1"         })

  AADD(aData,{"dd"            ,STRZERO(DAY(oF1410:dDesde)  ,2)})
  AADD(aData,{"md"            ,STRZERO(MONTH(oF1410:dDesde),2)})
  AADD(aData,{"ad"            ,RIGHT(STRZERO(YEAR(oF1410:dDesde) ,4),2)})

  AADD(aData,{"dh"            ,STRZERO(DAY(oF1410:dHasta)  ,2)})
  AADD(aData,{"mh"            ,STRZERO(MONTH(oF1410:dHasta),2)})
  AADD(aData,{"ah"            ,RIGHT(STRZERO(YEAR(oF1410:dHasta) ,4),2)})

  AADD(aData,{"INFORMANTE"    ,oF1410:cInform      })
  AADD(aData,{"LUGAR"         ,oF1410:cLugar       })
  AADD(aData,{"XFECHA"        ,DTOC(oF1410:dFecha) })

  FOR I:=1 TO 8
    FOR U:=1 TO 15
      cVar:=CHR(I+64)+IIF(U<=9,STR(U,1),CHR(64+U-9))
      AADD(aData,{cVar,"  "})
    NEXT 
  NEXT I

  FOR I=1 TO 15

     cVar:="NOM"+STRZERO(I,2)
     AADD(aData,{cVar,"  "})
     cVar:="NUM"+STRZERO(I,2)
     AADD(aData,{cVar,"  "})

     cVar:="SS1"+STRZERO(I,2)
     AADD(aData,{cVar,"  "})
     cVar:="SS2"+STRZERO(I,2)
     AADD(aData,{cVar,"  "})

     cVar:="SM1"+STRZERO(I,2)
     AADD(aData,{cVar,"  "})
     cVar:="SM2"+STRZERO(I,2)
     AADD(aData,{cVar,"  "})

  NEXT I

  AADD(aData,{"PAG"           ,"1"})
  AADD(aData,{"a"             ,SUBS(oF1410:cMinTra,1,1)})
  AADD(aData,{"b"             ,SUBS(oF1410:cMinTra,2,1)})
  AADD(aData,{"c"             ,SUBS(oF1410:cMinTra,3,1)})
  AADD(aData,{"d"             ,SUBS(oF1410:cMinTra,4,1)})
  AADD(aData,{"e"             ,SUBS(oF1410:cMinTra,5,1)})
  AADD(aData,{"f"             ,SUBS(oF1410:cMinTra,6,1)})
  AADD(aData,{"g"             ,SUBS(oF1410:cMinTra,7,1)})
  AADD(aData,{"h"             ,SUBS(oF1410:cMinTra,8,1)})
  AADD(aData,{"i"             ,SUBS(oF1410:cMinTra,9,1)})

  cTempo:=cPath+cTempo
  CursorWait()

  cSql:="SELECT PER_DESDE,PER_HASTA,PER_CODTRA,PER_CAUSA,NUM_SSO,CEDULA,CONCAT(APELLIDO,',',NOMBRE) AS NOMBRE FROM NMAUSENCIA "+;
        " INNER JOIN NMTRABAJADOR ON PER_CODTRA=CODIGO "

  // Buscamos los Permisos 

  cWhere:=" AND ("+GetWhereAnd("PER_DESDE",oF1410:dDesde,oF1410:dHasta)+")"           // Iniciaron en el Mes

  oPermiso:=TRDDARRAY():New()
  oPermiso:FromCursor(cSql+" WHERE PER_CAUSA "+GetWhere("=","PNR")+cWhere)
  oPermiso:Replace("REP_DESDE",CTOD(""))
  oPermiso:Replace("REP_HASTA",CTOD(""))

//oPermiso:Browse("Permiso")

  cSql:="SELECT PER_DESDE AS REP_DESDE,PER_HASTA AS REP_HASTA,PER_CODTRA,PER_CAUSA,NUM_SSO,CEDULA,CONCAT(APELLIDO,',',NOMBRE) AS NOMBRE FROM NMAUSENCIA "+;
        " INNER JOIN NMTRABAJADOR ON PER_CODTRA=CODIGO "

  cReposo:=GetWhereOr("PER_CAUSA",ATABLE("SELECT TAU_CODIGO FROM NMTIPAUS WHERE TAU_REPOSO=1"))

  oReposo:=TRDDARRAY():New()
  oReposo:FromCursor(cSql+" WHERE "+cReposo+cWhere)
  oReposo:Replace("PER_DESDE",CTOD(""))
  oReposo:Replace("PER_HASTA",CTOD(""))

  oReposo:Gotop()
  // oReposo:Browse("Reposos")

  // Sumar Permisos y Reposos
  oReposo:Deletefor({|oReposo|Empty(oReposo:PER_CODTRA)})
  oPermiso:Deletefor({|oPermiso|Empty(oPermiso:PER_CODTRA)})

  AEVAL(oReposo:aData ,{|a,n,nAt|AADD(aCodTra,a[3])})
  AEVAL(oPermiso:aData,{|a,n,nAt|AADD(aCodTra,a[3])})

  oTable:=TRDDARRAY():New()
  oTable:Replace("PER_CODTRA"  ,"")
  oTable:Replace("PER_NOMBRE"  ,"")
  oTable:Replace("CEDULA"      ,0 )
  oTable:Replace("REP_DESDE"   ,CTOD(""))
  oTable:Replace("REP_HASTA"   ,CTOD(""))
  oTable:Replace("PER_DESDE"   ,CTOD(""))
  oTable:Replace("PER_HASTA"   ,CTOD(""))
  oTable:Replace("SAL_ANTES"   ,0)
  oTable:Replace("SAL_ACTUAL"  ,0)
  oTable:Zap()
  oReposo:Gotop()
  WHILE !oReposo:Eof() .AND. oF1410:lPerRep
    IF !oTable:LocateFor({|oTable|oTable:PER_CODTRA=oReposo:PER_CODTRA .AND. oTable:REP_DESDE=oReposo:REP_DESDE })
        oTable:Append()
        Aeval(oReposo:aFields,{|a,n|oTable:REPLACE(a,oReposo:FieldGet(a))})
        oTable:Replace("SAL_ACTUAL"  ,0)
        oTable:Replace("SAL_ANTES"   ,0)
    ENDIF
    oReposo:DbSkip()
  ENDDO

  oPermiso:Gotop()
  // Asigna la Fecha de Permisos a oTable: Existente
  WHILE !oPermiso:Eof() .AND. oF1410:lPerRep
    IF oTable:LocateFor({|oTable|oTable:PER_CODTRA=oPermiso:PER_CODTRA .AND. Empty(oTable:PER_DESDE)})
       oTable:REPLACE("PER_DESDE",oPermiso:PER_DESDE)
       oTable:REPLACE("PER_HASTA",oPermiso:PER_HASTA)
       oTable:Replace("SAL_ACTUAL"  ,0)
       oTable:Replace("SAL_ANTES"   ,0)
       oPermiso:Delete()
    ENDIF
    oPermiso:DbSkip()
  ENDDO

  // Agrega los Permisos sin Reposos

  oPermiso:Gotop()
  WHILE !oPermiso:Eof() .AND. oF1410:lPerRep
     oTable:Append()
     Aeval(oPermiso:aFields,{|a,n|oTable:REPLACE(a,oPermiso:FieldGet(a))})
     oPermiso:DbSkip()
  ENDDO

/*
  aEmpty:=oTable:aData
  WHILE oTable:RecCount()<17
     AEVAL(aEmpty,{|a,n|AADD(oTable:aData,a)})
  ENDDO
*/

  oTable:Replace("SAL_ANTES" ,0)
  oTable:Replace("SAL_ACTUAL",0)
  // Mes Anterior
  dFchFinAnt:=FCHINIMES(oF1410:dDesde)-1
  dFchIniAnt:=FCHINIMES(dFchFinAnt)

  cSqlS:=" SELECT REC_CODTRA,HIS_MONTO,APELLIDO,NOMBRE,NUM_SSO,CEDULA FROM NMHISTORICO  "+;
         " INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO     "+;
         " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
         " WHERE HIS_CODCON='H008' AND "+;
                "("+GetWhereAnd("FCH_DESDE",dFchIniAnt,oF1410:dHasta)+")"+;
         " GROUP BY REC_CODTRA,HIS_MONTO "+;
         " ORDER BY REC_CODTRA "

?  CLPSQL(cSqlS)
//  ? cSqlS,dFchIniAnt,dFchFinAnt
//RETURN .T.

  oSalario:=TRDDARRAY():New()
  oSalario:FromCursor(cSqlS)
  oSalario:Browse()

  oTable:Replace("SAL_ANTES"   ,0)
  oTable:Replace("SAL_ACTUAL"  ,0)
  IIF(!oF1410:lPerRep,oTable:Zap(),nil)

//  ? oTable:RecCount(),"zap:OtABLE",ErrorSys(.T.)
// oSalario:Browse()
  oSalario:Gotop()

  WHILE !oSalario:Eof() .AND. oF1410:lSueldos
     cCodTra :=oSalario:REC_CODTRA
     nSalario:=oSalario:HIS_MONTO
     WHILE cCodTra=oSalario:REC_CODTRA .AND. !oSalario:Eof()
       IF !nSalario=oSalario:HIS_MONTO 
          nSalAnt :=nSalario
          nSalario:=oSalario:HIS_MONTO
          IF !oTable:LocateFor({|oTable|oTable:PER_CODTRA=oSalario:REC_CODTRA .AND. Empty(oTable:SAL_ACTUAL)})
             oTable:Append()
             oTable:REPLACE("PER_CODTRA",cCodTra)
             oTable:REPLACE("NUM_SSO"   ,oSalario:NUM_SSO)
             oTable:REPLACE("CEDULA"    ,oSalario:CEDULA )
             oTable:REPLACE("NOMBRE"    ,ALLTRIM(oSalario:APELLIDO)+","+ALLTRIM(oSalario:NOMBRE))
             oTable:REPLACE("PER_DESDE" ,CTOD(""))
             oTable:REPLACE("PER_HASTA" ,CTOD(""))
             oTable:REPLACE("REP_DESDE" ,CTOD(""))
             oTable:REPLACE("REP_HASTA" ,CTOD(""))
          ENDIF

          IF oTable:PER_CODTRA=oSalario:REC_CODTRA
//           oTable:Replace("SAL_ACTUAL"  , DIV(DIV(nSalario,30)*12,52))
//           oTable:Replace("SAL_ANTES"   , DIV(DIV(nSalAnt ,30)*12,52))
             oTable:Replace("SAL_ACTUAL"  , nSalario)
             oTable:Replace("SAL_ANTES"   , nSalAnt )

          ENDIF
       ENDIF
       oSalario:DbSkip()
     ENDDO
  ENDDO

  // Comparamos con el mes Anterior

//   CLPCOPY(cSqlS)
//   oAnterior:=OpenTable(cSqlS,.T.)
//   WHILE !oAnterior:Eof()
//      IF !oTable:LocateFor({|oTable|oTable:PER_CODTRA=oAnterior:REC_CODTRA)})
//      ENDIF
//      oAnterior:DbSkip()
//   ENDDO
// oAnterior:Browse()
// oAnterior:End()
// RETURN .F.

  oTable:Deletefor({|oTable|Empty(oTable:PER_CODTRA)})
  oTable:GoTop()

  IF oTable:RecCount()=0 .AND. oF1410:lPerRep .AND. !oF1410:lSueldos
     MensajeErr("Información no Encontrada del Periodo : "+DTOC(oF1410:dDesde)+" "+DTOC(oF1410:dHasta))
     RETURN .F.
  ENDIF

  nContar:=0
  nCantP :=MAX(INT(DIV(oTable:RecCount(),15)),1)

oTable:Browse()

  WHILE !oTable:Eof()  

    nContar++
    nLines++

    nAt:=ASCAN(aData,{|a,n|a[1]="PAG"})

    IF nAt>0
       aData[nAt,2]:=LSTR(nPag)+"/"+LSTR(nCantP)
    ENDIF

    cVar:="NOM"+STRZERO(nContar,2)
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
       aData[nAt,2]:=ALLTRIM(oTable:NOMBRE)+LSTR(nContar)
    ENDIF

    cVar:="NUM"+STRZERO(nContar,2)
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
       aData[nAt,2]:=IIF(Empty(oTable:NUM_SSO),CTOO(oTable:CEDULA,"C"),oTable:NUM_SSO)
    ENDIF

    // PERMISO NO REMUNERADO
    cDiaD:=STRZERO(  DAY(oTable:PER_DESDE),2)
    cMesD:=STRZERO(MONTH(oTable:PER_DESDE),2)
    cVarF:=IIF(nContar<=9,STR(nContar,1),CHR(64+nContar-9))
    cVar :="A"+cVarF
    nAt  :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cDiaD
    ENDIF

    cVar:="B"+cVarF
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cMesD
    ENDIF

    cDiaH:=STRZERO(  DAY(oTable:PER_HASTA),2)
    cMesH:=STRZERO(MONTH(oTable:PER_HASTA),2)
   
    cVar:="C"+cVarF
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cDiaH
    ENDIF

    cVar:="D"+cVarF
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cMesH
    ENDIF

    // REPOSO
    cDiaD:=STRZERO(  DAY(oTable:REP_DESDE),2)
    cMesD:=STRZERO(MONTH(oTable:REP_DESDE),2)
    cVar :="E"+cVarF
    nAt  :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cDiaD
    ENDIF

    cVar:="F"+cVarF
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cMesD
    ENDIF

    cDiaH:=STRZERO(  DAY(oTable:REP_HASTA),2)
    cMesH:=STRZERO(MONTH(oTable:REP_HASTA),2)
   
    cVar:="G"+cVarF
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cDiaH
    ENDIF

    cVar:="H"+cVarF
    nAt :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cMesH
    ENDIF

    // Salario
    // ? ValType(oTable:SAL_ACTUAL),oTable:SAL_ACTUAL
    cSemAct:=IIF(oTable:SAL_ACTUAL  =0,"",TRAN(oTable:SAL_ACTUAL  *7 ,ALLTRIM(oF1410:cPictSSO)))
    cVar   :="SS2"+STRZERO(nContar,2)
    nAt    :=ASCAN(aData,{|a,n|a[1]=cVar})
    IF nAt>0
      aData[nAt,2]:=cSemAct
    ENDIF

    cSemAnt:=IIF(oTable:SAL_ANTES=0,"",TRAN(oTable:SAL_ANTES*7,ALLTRIM(oF1410:cPictSSO)))
    cVar :="SS1"+STRZERO(nContar,2)
    nAt  :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cSemAnt
    ENDIF

    cMesAct:=IIF(oTable:SAL_ACTUAL  =0,"",TRAN(oTable:SAL_ACTUAL*30,ALLTRIM(oF1410:cPictSSO)))
    cVar   :="SM2"+STRZERO(nContar,2)
    nAt    :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cMesAct
    ENDIF

    // Mes Anterior
    cMesAnt:=IIF(oTable:SAL_ANTES=0,"",TRAN(oTable:SAL_ANTES*30,ALLTRIM(oF1410:cPictSSO)))
    cVar   :="SM1"+STRZERO(nContar,2)
    nAt    :=ASCAN(aData,{|a,n|a[1]=cVar})

    IF nAt>0
      aData[nAt,2]:=cMesAnt
    ENDIF

    oTable:DbSkip()

    // Cambio de Página
    IF nLines>=15 .AND. nCantP>1 .AND. !nPag=nCantP

      WHILE nAt:=ASCAN(aData,{|a,n|a[2]="00"}),nAt>0
        aData[nAt,2]:=""
      ENDDO

      nLines :=0
      nContar:=0
      cTemp2 :=STRTRAN("_"+cTempFile()+".DOC","..",".")
      cTemp2 :=cPath+STRTRAN(cTemp2,"__","__"+ALLTRIM(STR(nPag)))
      nPag++

      WORDBUILD(cCarta,cTemp2,aData,oF1410:oMeter,lRun)

      FOR I:=1 TO 8
        FOR U:=1 TO 15
          cVar:=CHR(I+64)+IIF(U<=9,STR(U,1),CHR(64+U-9))
          nAt :=ASCAN(aData,{|a,n|a[1]=cVar})
          aData[nAt,2]:=""
        NEXT 
      NEXT I

      AEVAL(aData,{|a,n,c|c:=Left(a[1],3),aData[n,2]:=IIF(c="NUM".OR.c="NOM".OR.Left(c,2)="SS".OR.Left(c,2)="SM","",aData[n,2]) })

    ENDIF

  ENDDO

  oTable:End()

  WHILE nAt:=ASCAN(aData,{|a,n|a[2]="00"}),nAt>0
     aData[nAt,2]:=""
  ENDDO

  ViewArray(aData)

//  ? CLPCOPY(cCarta),lRun

  WORDBUILD(cCarta,cTempo,aData,oF1410:oMeter,lRun)

RETURN .T.

PROCE WORDBUILD(cFileDoc,cFileDes,aData,oMeter,lRun)
  LOCAL oWord,nContar:=0,bBlq,cData,I
  LOCAL aBlq:={}

  DEFAULT lRun:=.T.

  AEVAL(aData,{|a,n|aData[n,2]:=CTOO(a[2],"C")})

  WHILE nContar<LEN(aData)
    nContar:=nContar+1
    cData  :=CTOO(aData[nContar,2],"C")
//  bBlq :=[cMemo:=put_campo(cMemo,"]+aData[nContar,1]+[","{","}"," ","]+cData+[")]
    bBlq :=[cMemo:=put_campo(cMemo,"]+aData[nContar,1]+[","",""," ","]+cData+[")]
    AADD(aBlq,BLOQUECOD(bBlq))
  ENDDO

  // Solo Datos, Sin espacios
  WHILE nContar<LEN(aData)
    nContar:=nContar+1
    cData  :=CTOO(aData[nContar,2],"C")
    bBlq :=[cMemo:=put_campo(cMemo,"]+aData[nContar,1]+[","*","*"," ","]+cData+[")]
    AADD(aBlq,BLOQUECOD(bBlq))
  ENDDO

  IF !FILE(cFileDoc)
     MensajeErr("Archivo Original "+cFileDoc+" no Existe")
     RETURN .F.
  ENDIF

  SysRefresh()

  COPYFILEBLQ(cFileDoc,cFileDes,aBlq,NIL,oMeter)

  SysRefresh()

  IF !FILE(cFileDes)
     MensajeErr("Archivo Destino "+cFileDes+" no fué Creado")
     RETURN .F.
  ENDIF

? cFileDes,file(cFileDes)

  IF lRun

     oWord:=TOleAuto():New( "Word.Application" )
     oWord:Documents:Open(cFileDes)

     oWord:Visible := .T.
     oWord:Set( "WindowState", 1 )  // Maximizado

     oWord:End()

  ENDIF

RETURN NIL

FUNCTION COPYFILEBLQ(cFileOrg,cFileDes,bBLQ,nBytes,oMeter)
    LOCAL oFileOrg,oFileDes,aBlq:={},I,aVar:=save_var("cMemo"),cMemo:=""
    // ALERT("INICIO")
    nBytes:=IIF( nBytes=NIL , 1024*8 , nBytes )
    
    IF bBlq=NIL
       bBlq:={||.T.}
    ENDIF
    IF VALTYPE(bBlq)="B"
       aBlq:={bBlq}
    ELSE
       aBlq:=bBlq
    ENDIF
    // alert(str(aBlq))
    FERASE(cFileDes)
    oFileOrg:=TFile():New( cFileOrg )
    oFileDes:=TFile():New( cFileDes )
    IIF(oMeter<>NIL,oMeter:SetTotal(oFileOrg:nLen),NIL)
    WHILE !oFileOrg:lEof()
       cMemo:=oFileOrg:cGetStr(nBytes)
       IIF(oMeter<>NIL,oMeter:Set(oFileOrg:nRecno()),NIL)
       IF .T. // "{"$cMemo .OR. "."$cMemo
         FOR I := 1 TO LEN(aBlq)
           EVAL(aBlq[i])
         NEXT
       ENDIF
       oFileDes:PutStr(cMemo)
    ENDDO
    oFileOrg:Close()
    oFileDes:Close()
    STORE NIL TO oFileOrg,oFileDes
    Rest_var(aVar)

RETURN NIL

/*
// Insertar Texto en Documento
*/
FUNCTION put_campo(cMemo,cCampo,cAbre,cCierra,cRelleno,cNuevo)
  local xCampo:=cAbre+cCampo,I

  IF !cCampo$cMemo
     RETURN cMemo
  ENDIF

  cRelleno:="" 
  cCierra :="."

  FOR I=0 TO 140

   xCampo:=cAbre+cCampo+padr(cRelleno,i)+cCierra

   if xCampo$cMemo
       cMemo:=STRTRAN(cMemo,xCampo,PADR(cNuevo,LEN(xCampo)-0))
       i:=200
    endif

  NEXT I

  if cCampo$cMemo .AND. LEN(cCampo)=2 .AND. I=LEN(cCampo)
     cMemo:=STRTRAN(cMemo,cCampo,cNuevo)
     i:=200
  ENDIF


RETURN cMemo

FUNCTION CREATEHEAD(aData)
  LOCAL aStruct:={}
  LOCAL cType  :="C",nLen:=250,nDec:=0
  LOCAL cFile  :="CRYSTAL\FORMA-1410.DBF"

//  AADD(aStruct,{"NAME",cType,nLen,nDec})
//  AADD(aStruct,{"DATA",cType,nLen,nDec})

  FERASE(cFile)

  IF File(cFile)
     MensajeErr("Archivo: "+cFile+" Posiblemente Abierto")
     RETURN .F.
  ENDIF

/*
  DBCREATE(cFile,aStruct,"DBFCDX")

  USE (cFile) NEW EXCLU VIA "DBFCDX"

  FOR I=1 TO LEN(aData)

    APPEND BLANK
 
    REPLACE NAME WITH aData[I,1],;
            DATA WITH aData[I,2]

  NEXT I

  USE

BROWSE()

  DPSELECT(cAlias)
*/

RETURN .T.
// EOF

