// Programa   : IMPORTEJM
// Fecha/Hora : 09/05/2003 16:24:28
// Prop¢sito  : Importar Ejemplos de DpAdmWin
// Creado Por : Juan Navas
// Llamado por: Menu Principal Definiciones y Mantenimiento
// Aplicaci½n : Definiciones de N¢mina.
// Tabla      : Todas las de Configuraci¢n

#INCLUDE "DPXBASE.CH"
#INCLUDE "RichEdit.ch"

PROCE MAIN()

  IF Empty(oDp:hDllRtf) // Carga RTF
     oDp:hDLLRtf := LoadLibrary( "Riched20.dll" )
  ENDIF

  oImpEjm:=DPEDIT():New("Importar Ejemplos","forms\ImportEjm.edt","oImpEjm",.T.)
 
  oImpEjm:nFiles  :=0
  oImpEjm:nRecord :=0
  oImpEjm:cDsn    :=oDp:cDsnData 
  oImpEjm:oMeterT :=NIL
  oImpEjm:oMeterR :=NIL
  oImpEjm:cDir    :=Padr(CurDrive()+":\"+CurDir()+"\ejemplo\",30)
  oImpEjm:nAcepta :=2
  oImpEjm:cMemo   :=MemoRead("ejemplo\ejemplo.txt")
  oImpEjm:lEjemplo:=.F.
  oImpEjm:oMemo   :=NIL

  @ 0,0 GET oImpEjm:cMemo OF oImpEjm:oDlg MEMO HSCROLL SIZE 90,90

  @ 3,2 SAY "Directorio Origen"

  @ 3,2 SAY oImpEjm:oSayTable  PROMPT "Tablas:" UPDATE
  @ 3,2 SAY oImpEjm:oSayRecord PROMPT "Registros:"

  @ 3,2 SAY "Dsn Actual:"
  @ 4,2 SAY oImpEjm:cDsn 
  @ 1,1 BMPGET oImpEjm:oDir VAR oImpEjm:cDir NAME "BITMAPS\FOLDER5.BMP";
                           ACTION (cDir:=cGetDir(oImpEjm:cDir),;
                           IIF(!EMPTY(cDir),oImpEjm:cDir:=PADR(cDir,30),NIL),;
                           DpFocus(oImpEjm:oDir))


  @ 5.4,29.0 CHECKBOX oImpEjm:oEjemplo VAR oImpEjm:lEjemplo  PROMPT ANSITOOEM("Importar Datos para Realizar Pruebas")

  oImpEjm:oEjemplo:cMsg    :="Incluir Datos para Realizar Pruebas"
  oImpEjm:oEjemplo:cToolTip:=oImpEjm:oEjemplo:cMsg 


  @ 03.0,01 RADIO oImpEjm:nAcepta PROMPT "Acepto","No Acepto" 

  @ 02,01 METER oImpEjm:oMeterT VAR oImpEjm:nFiles
  @ 02,01 METER oImpEjm:oMeterR VAR oImpEjm:nRecord

  @ 6,07 BUTTON "Aceptar " ACTION  oImpEjm:Import() WHEN oImpEjm:nAcepta=1 
  @ 6,10 BUTTON "Cerrar  " ACTION  oImpEjm:Close() CANCEL

  oImpEjm:Activate(NIL)

Return nil

/*
// Exporta todos las Tablas del DSN hacia DBF
*/
FUNCTION IMPORT()
  LOCAL cFile,i,cLista:=""
  LOCAL cDir  :=ALLTRIM(oImpEjm:cDir)
  LOCAL aFiles:={}

  cDir:=cDir+IIF(RIGHT(cDir,1)="\","","\")

  AADD(aFiles,{"DPCTA"   ,NIL,NIL,})
  AADD(aFiles,{"DPCENCOS",NIL,NIL,})

  IF COUNT("DPUNDMED")>1
     SQLDELETE("DPINVMED")
     SQLDELETE("DPUNDMED")
  ENDIF

//  IF COUNT("DPBANCOS")=1
//     SQLDELETE("DPBANCOS")
//  ENDIF

  AADD(aFiles,{"DPCTAEGRESO",NIL,NIL,})
  AADD(aFiles,{"DPCODINTEGRA",NIL,NIL,})  

  AADD(aFiles,{"DPPAISES"        ,NIL,NIL,})
  AADD(aFiles,{"DPCLIENTESWORD"  ,NIL,NIL,})
  AADD(aFiles,{"DPESTADOS"       ,NIL,NIL,})
  AADD(aFiles,{"DPMUNICIPIOS"    ,NIL,NIL,})
  AADD(aFiles,{"DPPARROQUIAS"    ,NIL,NIL,})
  AADD(aFiles,{"DPCARGOS"        ,NIL,NIL,})
  AADD(aFiles,{"DPEXPTEMAS"      ,NIL,NIL,})
//  AADD(aFiles,{"DPCONRETISLR"    ,NIL,NIL,})
//  AADD(aFiles,{"DPTARIFASRET"    ,NIL,NIL,})
  AADD(aFiles,{"DPIVATIP"        ,NIL,NIL,})
  AADD(aFiles,{"DPIVATAB"        ,NIL,NIL,})
  AADD(aFiles,{"DPIVATABC"       ,NIL,NIL,})
  AADD(aFiles,{"DPTABMON"        ,NIL,NIL,})
  AADD(aFiles,{"DPCAJAINST"      ,NIL,NIL,})
  AADD(aFiles,{"DPMARCASFINANC"  ,NIL,NIL,})
  AADD(aFiles,{"DPCAJAINSTXMARCA",NIL,NIL,})
  AADD(aFiles,{"DPACTIVIDAD_E"   ,NIL,NIL,})
  AADD(aFiles,{"DPGRU"           ,NIL,NIL,})
  AADD(aFiles,{"DPMARCAS"        ,NIL,NIL,})
  AADD(aFiles,{"DPIMPPAT"        ,NIL,NIL,})
  AADD(aFiles,{"DPUNDMED"        ,NIL,NIL,})
  AADD(aFiles,{"DPINV"           ,NIL,NIL,})
  AADD(aFiles,{"DPTALLAS"        ,NIL,NIL,})
  AADD(aFiles,{"DPINVMED"        ,NIL,NIL,})
  AADD(aFiles,{"DPPRECIOTIP"     ,NIL,NIL,})
  AADD(aFiles,{"DPPRECIOS"       ,NIL,NIL,})
  AADD(aFiles,{"DPEQUIV"         ,NIL,NIL,})
  AADD(aFiles,{"DPMOVINV"        ,NIL,NIL,})

  // Producción
  AADD(aFiles,{"DPDPTOPRODUCC"   ,NIL,NIL,})
  AADD(aFiles,{"DPCOMPONENTES"   ,NIL,NIL,})

  AADD(aFiles,{"DPPROCLA"       ,NIL,NIL,})
  AADD(aFiles,{"DPPROVEEDOR"    ,NIL,NIL,})
  AADD(aFiles,{"DPPROVEEDORPER" ,NIL,NIL,})
  AADD(aFiles,{"DPPROVEEDORCTA" ,NIL,NIL,})

  AADD(aFiles,{"DPCAJA"       ,NIL,NIL,})
  AADD(aFiles,{"DPCAJAMOV"    ,NIL,NIL,})
  AADD(aFiles,{"DPBANCOS"     ,NIL,NIL,})
  AADD(aFiles,{"DPCTABANCO"   ,NIL,NIL,})
  AADD(aFiles,{"DPCTABANCOMOV",NIL,NIL,})

  AADD(aFiles,{"DPVENDEDOR"    ,NIL,NIL,})
  AADD(aFiles,{"DPCLICLA"      ,NIL,NIL,})
  AADD(aFiles,{"DPCLIENTES"    ,NIL,NIL,})
  AADD(aFiles,{"DPCLIENTESPER" ,NIL,NIL,})
  AADD(aFiles,{"DPCLIENTECTA"  ,NIL,NIL,})
  AADD(aFiles,{"DPCLIENTEPROG" ,NIL,NIL,})

  AADD(aFiles,{"DPDOCCLI"     ,NIL,NIL,})
  AADD(aFiles,{"DPDOCCLICTA"  ,NIL,NIL,})
  AADD(aFiles,{"DPDOCCLIDIR"  ,NIL,NIL,})
  AADD(aFiles,{"DPDOCCLIISLR" ,NIL,NIL,})
  AADD(aFiles,{"DPDOCCLIIVA"  ,NIL,NIL,})
  AADD(aFiles,{"DPDOCCLIRTI"  ,NIL,NIL,})
  AADD(aFiles,{"DPCLIENTESCERO",NIL,NIL,})

  AADD(aFiles,{"DPDOCPRO"     ,NIL,NIL,})
  AADD(aFiles,{"DPDOCPROCTA"  ,NIL,NIL,})
  AADD(aFiles,{"DPDOCPRODIR"  ,NIL,NIL,})
  AADD(aFiles,{"DPDOCPROISLR" ,NIL,NIL,})
  AADD(aFiles,{"DPDOCPROIVA"  ,NIL,NIL,})
  AADD(aFiles,{"DPDOCPRORTI"  ,NIL,NIL,})
  AADD(aFiles,{"DPPROVEEDORCERO",NIL,NIL,})

  AADD(aFiles,{"DPRECIBOSCLI" ,NIL,NIL,})
  AADD(aFiles,{"DPCBTEPAGO"   ,NIL,NIL,})

  // ACTIVOS

  AADD(aFiles,{"DPGRUACTIVOS"  ,NIL,NIL,})
  AADD(aFiles,{"DPUBIACTIVOS"  ,NIL,NIL,})
  AADD(aFiles,{"DPACTIVOS"   ,NIL,NIL,})
  AADD(aFiles,{"DPDEPRECIAACT" ,NIL,NIL,})

  IF oImpEjm:lEjemplo
/*
     AADD(aFiles,{"DPDPTO"      ,NIL,NIL,})
     AADD(aFiles,{"NMGRUPO"     ,NIL,NIL,})
     AADD(aFiles,{"NMUNDFUNC"   ,NIL,NIL,})
     AADD(aFiles,{"NMBANCOS"    ,NIL,NIL,})
     AADD(aFiles,{"NMCARGOS"    ,NIL,NIL,})
     AADD(aFiles,{"NMTRABAJADOR",NIL,NIL,})
     AADD(aFiles,{"NMTABPRES"   ,NIL,NIL,})
     AADD(aFiles,{"NMTABVAC"    ,NIL,NIL,})
     AADD(aFiles,{"NMTABLIQ"    ,NIL,NIL,})
     AADD(aFiles,{"NMFECHAS"    ,NIL,NIL,})
     AADD(aFiles,{"NMRECIBOS"   ,NIL,NIL,})
     AADD(aFiles,{"NMHISTORICO" ,NIL,NIL,})
     AADD(aFiles,{"NMVARIAC"    ,NIL,NIL,})
     AADD(aFiles,{"NMRESTRA"    ,NIL,NIL,})
     AADD(aFiles,{"NMTIPAUS"    ,NIL,NIL,})
     AADD(aFiles,{"NMAUSENCIA"  ,NIL,NIL,})
     AADD(aFiles,{"NMDATASET"   ,NIL,NIL,})
     AADD(aFiles,{"NMCURRICULUM",NIL,NIL,})
     AADD(aFiles,{"NMMEMO"      ,NIL,NIL,})
*/
  ENDIF


  cFile:=cDir+"DPCTA.DBF"

  // Exporta Contabilidad
  IF FILE(cFile)
     CLOSE ALL
     SELE A
     USE (cFile) EXCLU

     IF RECCOUNT()>1

//      SQLDELETE("DPCTA")
        AADD(aFiles,{"DPCTA"      ,NIL,NIL,})
        AADD(aFiles,{"DPCBTE"     ,NIL,NIL,})
        AADD(aFiles,{"DPASIENTOS" ,NIL,NIL,})

     ENDIF
     USE

  ENDIF

  FOR I=1 TO LEN(aFiles)
    cFile:=cDir+aFiles[I,1]+".DBF"
    IF !FILE(cFile)
      cLista:=cLista+IIF(EMPTY(cLista),"",",")+cFile+CRLF
    ENDIF
    aFiles[I,2]:=aFiles[I,1]
    aFiles[I,1]:=cFile // {cFile,aFiles[I],NIL,NIL}
  NEXT I

  IF !EMPTY(cLista)
     MsgAlert("Archivo(s):"+CRLF+cLista,"No Existe")
     RETURN .F.
  ENDIF

  EJECUTAR("DPDATACREA",.T.)

  IF Count("DPPAISES")<=1
    SQLDELETE("DPPAISES",nil,.f.)
  ENDIF

  IF Count("DPGRU")<=1
    SQLDELETE("DPGRU",nil,.f.)
  ENDIF

  IF Count("DPMARCAS")<=1
    SQLDELETE("DPMARCAS",nil,.f.)
  ENDIF

  IF Count("DPESTADOS")<=1
    SQLDELETE("DPESTADOS",nil,.f.)
  ENDIF

  IF Count("DPMUNICIPIOS")<=1
    SQLDELETE("DPMUNICIPIOS",nil,.f.)
  ENDIF

  IF Count("DPPARROQUIAS")<=1
    SQLDELETE("DPPARROQUIAS",nil,.f.)
  ENDIF

  IF Count("DPCLICLA")<=1
     SQLDELETE("DPCLICLA")
  ENDIF

  IF Count("DPVENDEDOR")<=1
     SQLDELETE("DPVENDEDOR")
  ENDIF

  IF Count("DPACTIVIDAD_E")<=1
    SQLDELETE("DPACTIVIDAD_E")
  ENDIF

  // Debe Borrar DPPAISES, si s¢lo existe un Registro
  // Ejecuta Importar //
  IF Type("oImpEjm")="O"
    EJECUTAR("IMPORTDP",oImpEjm:cDsn,aFiles,oImpEjm:oMeterT,oImpEjm:oMeterR,oImpEjm:oSayTable,oImpEjm:oSayRecord,.F.)
  ENDIF
  
RETURN .T.

// EOF


























