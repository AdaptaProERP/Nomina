// Programa   : NMIMPORT6COL
// Fecha/Hora : 25/08/2004 10:11:21
// Propósito  : Importar Datos de las Prestaciones
// Creado Por : Juan Navas
// Llamado por: DPXBASE
// Aplicación : Nómina
// Tabla      : NMHISTORICO

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  Local cFile:="\dpwin32\dpwin32.exe"
  LOCAL aFiles:={}

  oSPI:=DPEDIT():New("Importar Datos para Antiguedad e Intereses :"+oDp:cDsnData,"SPI.edt","oSPI",.T.)
 
  oSPI:nRecord :=0
  oSPI:oMeterR :=NIL
  oSPI:cDir    :=PADR(cFilePath( GetModuleFileName( GetInstance() ))+"EJEMPLO\",30)
  oSPI:cFileChm:="CAPITULO2.CHM"

  @ 3,2 SAY "Ruta del Archivo DATA.DBF o DATA.XLS"

  @ 4,2 SAY oSPI:oSay PROMPT "Trabajador"

  @ 1,1 BMPGET oSPI:oDir VAR oSPI:cDir NAME "BITMAPS\FOLDER5.BMP";
                           ACTION (cDir:=cGetDir(oSPI:cDir),;
                           IIF(!EMPTY(cDir),oSPI:cDir:=PADR(cDir,30),NIL),;
                           DpFocus(oSPI:oDir))

  @ 02,01 METER oSPI:oMeterR VAR oSPI:nRecord

  @ 6,07 BUTTON oSPI:oBtnImport PROMPT "Iniciar " ACTION  oSPI:Import(oSPI)
  @ 6,10 BUTTON "Cerrar  " ACTION  oSPI:Close() CANCEL

  oSPI:Activate(NIL)

Return nil

/*
// Importar
*/
FUNCTION IMPORT(oSPI)
  LOCAL cFile :=ALLTRIM(oSPI:cDir)+"DATA.DBF"
  LOCAL cIndex:=ALLTRIM(oSPI:cDir)+"DATA.CDX"
  LOCAL dFecha,dFchAnt,lHacer
  LOCAL cSql,bCodigo
  LOCAL nCI,nMonto,nCuota,nContar:=0,nMtoAnt:=0,nAbono:=0,i,nSkip:=0
  LOCAL oTabla
  LOCAL oHisto,oRecibo
  LOCAL cCodTra:="",cNumFecha:=""
  LOCAL cRecibo:="" // Numero de Recibo
  LOCAL cFileDBf,cMemo:="",cFile,oFont,cDir,cClave,nRefresh:=0
  LOCAL aCodCon:={"H400","A411",oDp:cConAdel}

  cDir  :=ALLTRIM(oSPI:cDir)
  cDir  :=cDir+IIF(RIGHT(cDir,1)<>"\","\","")

  cFile :=ALLTRIM(cDir)+"DATA.DBF"
  cIndex:=ALLTRIM(cDir)+"DATA.CDX"

  IF FILE(STRTRAN(cFile,".DBF",".XLS"))
     cFile:=STRTRAN(cFile,".DBF",".XLS")
  ENDIF
  
  IF !FILE(cFile)
     MensajeErr("Archivo "+cFile+" no Existe")
     RETURN .F.
  ENDIF

  IF ".XLS"$cFile

     cFileDbf:=STRTRAN(UPPE(cFile),".XLS",".DBF")
     lHacer  :=!FILE(cFileDbf)

     IF !lHacer .AND. MsgYesNo("Archivo :"+cFileNoPath(cFileDbf)+" ya Existe","Generar desde:"+cFileNoPath(cFile))
        lHacer:=.T.
     ENDIF


     IF lHacer
     //    cFileDbf:=EJECUTAR("XLSTODBF",cFile)
         CursorWait()
         MsgRun("Leyendo Datos desde "+cFile,"Espere....",{||cFileDbf:=EJECUTAR("XLSTODBF",cFile)})
         cFile   :=cFileDbf
         cIndex  :=STRTRAN(cFile,".DBF",".CDX")
         FERASE(cIndex)
      ENDIF

     cFile   :=cFileDbf
  //   cIndex  :=STRTRAN(cFile,".DBF",".CDX")
  //   FERASE(cIndex)

  ENDIF

  // Verifica la existencia de los conceptos
  FOR I=1 TO LEN(aCodCon)
    IF SQLGET("NMCONCEPTOS","CON_CODIGO","CON_CODIGO"+GetWhere("=",aCodCon[I]))<>aCodCon[I] 
       cMemo:=cMemo+IIF(Empty(cMemo),"",",")+aCodCon[I]
    ENDIF
  NEXT I

  IF !EMPTY(cMemo)
     MensajeErr("Concepto(s): "+cMemo+" no Encontrados")
     RETURN .F.
  ENDIF

  oSPI:oBtnImport:Disable()

  CLOSE ALL
  SELE A
  
  USE (cFILE) VIA "DBFCDX" EXCLU

  IF !FILE(cIndex)
    INDEX ON CEDULA TAG "CEDULA" TO (cIndex)
    USE
    USE (cFILE) VIA "DBFCDX" EXCLU
  ENDIF

  SET INDEX TO (cIndex)

  oSPI:oMeterR:SetTotal(RECCOUNT())

  SET ORDE TO 1
  GO TOP

  oHisto :=OpenTable("SELECT * FROM NMHISTORICO",.F.)
  oRecibo:=OpenTable("SELECT * FROM NMRECIBOS",.F.)

  CURSORWAIT()

  A->(DBGOTOP())

  DO WHILE !A->(EOF()) 

    nCI:=CTOO(A->CEDULA,"N")

    IF ValType(nCI)="C"
      nCI:=VAL(LSTR(nCI))
    ENDIF

    nCI:=CTOO(nCI,"N")

    oTabla:=OpenTable("SELECT * FROM NMTRABAJADOR WHERE CEDULA"+GetWhere("=",nCI),.T.)

    oSPI:oMeterR:Set(A->(OrdKeyNo()))

    IF oTabla:RecCount()=0 // No Existe


       oSPI:oSay:SETTEXT("["+GetNumRel(OrdKeyNo(),RecCount())+"]"+;
                        " CI: "+LSTR(nCI)+" no Existe")



       IF !LSTR(nCI)$cMemo 

         cMemo:=cMemo+IIF(!Empty(cMemo),CRLF,"")+;
                "CI:"+LSTR(nCI)+" No Existe"

       ENDIF

       A->(DBSKIP())
       LOOP
/*
       oTabla:Append()
       oTabla:Replace("CODIGO"  ,STR(nCI,10,0))
       oTabla:Replace("CEDULA"  ,nCI)
       oTabla:Replace("NOMBRE"  ,"Creado por DpNmWin")
       oTabla:Replace("APELLIDO","Creado por DpNmWin")
       oTabla:Replace("TIPO_NOM","Q")
       oTabla:Replace("CONDICION","A")
       oTabla:Commit()
*/
    ENDIF

//    oSPI:oSay:SETTEXT("["+GetNumRel(OrdKeyNo(),RecCount())+"]"+;
//                      " Código: "+oTabla:CODIGO)

    SysRefresh(.T.)

    cCodTra:=oTabla:CODIGO

    oSPI:oSay:SETTEXT("["+GetNumRel(OrdKeyNo(),RecCount())+"]"+;
                      " Código: "+oTabla:CODIGO)


    /*
    // Borrar Registros Existentes
    */

    // Solo funciona con MySQL con Tablas MYISAM
    cSql:=" SELECT REC_NUMERO FROM NMRECIBOS "+;
          " INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC "+;
          " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
          " AND REC_INTEGR='X' "+;
          " AND (HIS_CODCON='H400' OR HIS_CODCON"+GetWhere("=",oDp:cConAdel )+" OR HIS_CODCON='A411')"

    aCodCon:=aTable(cSql)

    IF !EMPTY(aCodCon)
       cSql:="DELETE FROM NMRECIBOS WHERE "+GetWhereOr("REC_NUMERO",aCodCon)
    ELSE
       cSql:=""
    ENDIF

//    cSql:="DELETE NMRECIBOS,NMHISTORICO FROM NMRECIBOS,NMHISTORICO "+;
//          " WHERE NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "+;
//          " AND (HIS_CODCON='H400' OR HIS_CODCON='A410' OR HIS_CODCON='A411') AND REC_CODTRA"+GetWhere("=",cCodTra)

    IF !Empty(cSql) .AND. !oTabla:Execute(cSql)
       MensajeErr(cSql,"Error")
    ENDIF

    nMtoAnt:=0
    nAbono :=0
    cClave :=A->CEDULA

    WHILE !EOF() .AND. cClave=A->CEDULA

      oSPI:oMeterR:Set(A->(OrdKeyNo()))

      IF ++nRefresh>20
         nRefresh:=0
         SysRefresh(.T.)
      ENDIF

      nCuota :=CTOO(A->MONTO,"N")
      cRecibo:=SqlGetMax("NMRECIBOS","REC_NUMERO") 
      cRecibo:=STRZERO(VAL(cRecibo)+1,LEN(cRecibo))
      dFecha :=A->FECHA

      IF EMPTY(dFecha)
        dFecha:=FCHFINMES(FCHFINMES(dFchAnt)+1)
      ENDIF

      cNumFecha:=GetNumFecha(oTabla:TIPO_NOM,"",dFecha,dFecha)

      dFchAnt:=dFecha

      oRecibo:Append()
      oRecibo:Replace("REC_NUMFCH",cNumFecha)
      oRecibo:Replace("REC_NUMERO",cRecibo  )
      oRecibo:Replace("REC_CODTRA",cCodTra  )
      oRecibo:Replace("REC_DESDE" ,dFecha   )
      oRecibo:Replace("REC_HASTA" ,dFecha   )
      oRecibo:Replace("REC_FECHAS",dFecha   )
      oRecibo:Replace("REC_MONTO" ,0)
      oRecibo:Replace("REC_TIPNOM",oTabla:TIPO_NOM)
      oRecibo:Replace("REC_USUARI",oDp:cUsuario)
      oRecibo:Replace("REC_FORMAP","E")
      oRecibo:Replace("REC_INTEGR","X") // Indica que fué Creado por este Proceso

      oRecibo:Commit()

      AUDITAR("DINC" , NIL ,"NMRECIBOS","["+cRecibo+"] Creado desde Importar Antiguead")

      oHisto:Append()
//    oHisto:Replace("HIS_CODTRA",cCodTra )
      oHisto:Replace("HIS_CODCON","H400"  )
//    oHisto:Replace("HIS_DESDE" ,dFecha  )
//    oHisto:Replace("HIS_HASTA" ,dFecha  )
      oHisto:Replace("HIS_VARIAC",A->DIAS )
      oHisto:Replace("HIS_MONTO" ,nCuota  )
      oHisto:Replace("HIS_NUMREC",cRecibo )
//    oHisto:Replace("HIS_TIPONM","Q"     )
      oHisto:Commit()

      IF A->ANTICIPOS>0 

// ? oDp:cConAdel,"oDp:cConAdel"

         oHisto:Append()
         oHisto:Replace("HIS_CODCON",oDp:cConAdel )
         oHisto:Replace("HIS_VARIAC",0       )
         oHisto:Replace("HIS_MONTO" ,A->ANTICIPOS)
         oHisto:Replace("HIS_NUMREC",cRecibo )
         oHisto:Commit()

      ENDIF

      IF A->INTERESES>0 
//  IF TYPE("A->INTERESES")="N" .AND. A->INTERESES>0 

//? "INTERESE"
         oHisto:Append()
         oHisto:Replace("HIS_CODCON","A411"  )
         oHisto:Replace("HIS_VARIAC",0       )
         oHisto:Replace("HIS_MONTO" ,A->INTERESES)
         oHisto:Replace("HIS_NUMREC",cRecibo )
         oHisto:Commit()

      ENDIF

      IF TYPE("A->INTCALCULO")="N" .AND. A->INTCALCULO>0 
         oHisto:Append()
         oHisto:Replace("HIS_CODCON","A417"  )
         oHisto:Replace("HIS_VARIAC",0       )
         oHisto:Replace("HIS_MONTO" ,A->INTCALCULO)
         oHisto:Replace("HIS_NUMREC",cRecibo )
         oHisto:Commit()

      ENDIF

      DBSKIP()

    ENDDO

    oTabla:End()

//  nSkip++
//    IF nSkip>5
//      EXIT
//    ENDIF

  ENDDO

  oHisto:End()
  oRecibo:End()

  oSPI:oMeterR:Set(RECCOUNT())

  USE

  MensajeErr("Proceso Concluido")

  IF !EMPTY(cMemo)

    cFile:=cTempFile() 

    MemoWrit(cFile,cMemo)

    DEFINE FONT oFont     NAME "Courier"   SIZE 0, -10

    VIEWRTF(cFile,"Archivo "+cFile+" Trabajadores no Registrados",oFont)

  ENDIF

  oSPI:oBtnImport:Enable()

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
   oFecha:Replace("FCH_INTEGR"  ,"N"  )
   oFecha:Replace("FCH_CONTAB"  ,"N"  )
   oFecha:Replace("FCH_NUMERO"  ,cNumero     )
   oFecha:Replace("FCH_DESDE"   ,dDesde      )
   oFecha:Replace("FCH_HASTA"   ,dHasta      )
   oFecha:Replace("FCH_TIPNOM"  ,cTipo       )
   oFecha:Replace("FCH_OTRNOM"  ,cOtraNom    )
   oFecha:Replace("FCH_SISTEM"  ,oDp:dFecha  )
   oFecha:Replace("FCH_USUARI"  ,oDp:cUsuario)
   oFecha:Replace("FCH_ESTADO"  ,"A"         ) // Nacio Calc/Antiguedad
   oFecha:Commit()
   oFecha:End()

   AUDITAR("DINC" , NIL ,"NMFECHAS","["+cNumero+"] Creado desde Calcular Antiguedad")

RETURN cNumero

// EOF
