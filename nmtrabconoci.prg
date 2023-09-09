// Programa   : NMTRABCONOCI
// Fecha/Hora : 26/01/2005 23:10:42
// Propósito  : Conocimiento por Trabajador
// Creado Por : Juan Navas
// Llamado por: NMTRABAJADOR
// Aplicación : NMTRABCONOCI
// Tabla      : NMFAMILIA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cRif,cNombre,cRef)
  LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,oFontB,oFont,cTitle:=GETFROMVAR("{oDp:NMTRABCONOCI}")
  LOCAL aItems :=GETOPTIONS("NMTRABCONOCI","CXT_VALOR")
//LOCAL aGrupo :=ATABLE("SELECT GRC_CODIGO FROM NMGRUCONOCI")
  LOCAL aGrupo :=ATABLE("SELECT CNC_GRUCON FROM NMCONOCI GROUP BY CNC_GRUCON ")
  LOCAL aGrupos:=ASQL("SELECT CNC_GRUCON,CNC_CLACON FROM NMCONOCI ")
  LOCAL aConoci:={},aClaCon:={},cCodTra:=NIL

  IF Empty(aGrupo) 
    MsgMemo("Necesario registrar las definiciones en "+GETFROMVAR("{oDp:NMGRUCONOCI}"))
    EJECUTAR("NMGRUCONOCI")
    RETURN .F.
  ENDIF

  aConoci:=LOADCONOCI(aGrupos[1,1],aGrupos[1,2])
  aClaCon:=LOADCLACON(aGrupo[1])

  DEFAULT cRif   :=SQLGET("NMTRABAJADOR","RIF"),;
          cCodTra:=SQLGET("NMTRABAJADOR","CODIGO","RIF"+GetWhere("=",cRif)),;
          cRef   :="Trabajador"

  cTitle:="Registro de Conocimiento por "+cRef+" "

  DEFAULT cCodTra:="1002",cNombre:=SQLGET("NMTRABAJADOR","CONCAT(APELLIDO,',',NOMBRE)","CODIGO"+GetWhere("=",cCodTra))

  // Font Para el Browse
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  oNmTCon:=DOCENC(cTitle,"oNmTCon","NMTRABCONOCI.EDT")
  oNmTCon:cCodTra:=cCodTra
  oNmTCon:cRif   :=cRif
  oNmTCon:cNombre:=cNombre
  oNmTCon:aItem  :=aItems
  oNmTCon:aGrupo :=aGrupo
  oNmTCon:aClaCon:=ACLONE(aClaCon)
  oNmTCon:aConoci:=ACLONE(aConoci)

  oNmTCon:lBar:=.F.
  oNmTCon:lAutoEdit:=.T.
  oNmTCon:SetTable("NMTRABAJADOR","CODIGO"," WHERE CODIGO"+GetWhere("=",cCodTra))
  oNmTCon:Windows(0,0,oDp:aCoors[3]-160,785+5)

//  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Trabajador [ "+ALLTRIM(oNmTCon:CODIGO)+" ]"
//  @ 2,5 SAY oNombre PROMPT oNmTCon:cNombre
	
  cSql :=" SELECT * "+;
         " FROM NMTRABCONOCI "

  oGrid:=oNmTCon:GridEdit( "NMTRABCONOCI",oNmTCon:cPrimary , "CXT_CODTRA" , cSql ) 
  oGrid:nGris    :=oDp:nGris // 14933984
  oGrid:cScript  :="NMTRABCONOCI"
  oGrid:aSize    :={110-20-22, 0 , 645+120+18-5, oDp:aCoors[3]-160-130}
  oGrid:oFont    :=oFontB
  oGrid:bValid   :=".T."
  oGrid:lBar     :=.t.
/*
  oGrid:nClrPane1:=15790320
  oGrid:nClrPane2:=16382457
  oGrid:nClrPane2:=11595005
  oGrid:nClrPane1:=14285567
  oGrid:nClrPaneH   := 4511739
  oGrid:nRecSelColor:= 4511739
*/
  oGrid:nClrPane2   :=oDp:nClrPane2
  oGrid:nClrPane1   :=oDp:nClrPane1
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
  oGrid:nClrTextH   :=0
  oGrid:nRecSelColor:=oDp:nRecSelColor  // oDp:nLbxClrHeaderPane // 12578047 // 16763283



  oGrid:cPostSave :="GRIDPOSTSAVE"
  oGrid:cLoad     :="GRIDLOAD"
  oGrid:cTotal    :="GRIDTOTAL"
  oGrid:cPreSave  :="GRIDPRESAVE" 
  oGrid:cPreDelete:="GRIDPREDELETE" 
  oGrid:oFontH    :=oFontB // Fuente para los Encabezados
  oGrid:oFont     :=oFont  // Fuente para los Encabezados
  // 21-10-2008 Marlon Ramos oGrid:cPrimary  :="CXT_GRUCON,CXT_CLACON,CXT_CONOCI,CXT_VALOR"
  // oGrid:cPrimary  :="CXT_CODTRA,CXT_GRUCON,CXT_CLACON,CXT_CONOCI,CXT_VALOR"
  // 29/06/2023 
  oGrid:cPrimary  :="CXT_RIF,CXT_GRUCON,CXT_CLACON,CXT_CONOCI,CXT_VALOR"
  oGrid:bDataDel  :={||"("+ALLTRIM(oGrid:CXT_GRUCON)+") "+ALLTRIM(oGrid:CXT_CLACON)+" "+ALLTRIM(oGrid:CXT_CONOCI)+" ["+ALLTRIM(oGrid:CXT_VALOR)+"]"}

  // Grupo
  oCol:=oGrid:AddCol("CXT_GRUCON")
  oCol:cTitle   :=GetFromVar("{oDp:xNMGRUCONOCI}")
  oCol:nWidth   :=210
  oCol:bValid   :={||oGrid:CXTGRUCON()}
  oCol:lRepeat  :=.T.
  oCol:aItems    :={||oNmTCon:aGrupo }
  oCol:aItemsData:={||oNmTCon:aGrupo }

  // Clasificación
  oCol:=oGrid:AddCol("CXT_CLACON")
  oCol:cTitle   :="Clasificación"
  oCol:nWidth   :=210
  oCol:bValid   :={||oGrid:CXTCLACON()}
  oCol:lRepeat  :=.T.
  oCol:aItems    :={||oNmTCon:aClaCon}
  oCol:aItemsData:={||oNmTCon:aClaCon}

  // Clasificación
  oCol:=oGrid:AddCol("CXT_CONOCI")
  oCol:cTitle   :="Conocimiento"
  oCol:nWidth   :=210
  oCol:bValid   :={||oGrid:CXTCONOCI()}
  oCol:lRepeat  :=.T.
  oCol:aItems    :={||oNmTCon:aConoci}
  oCol:aItemsData:={||oNmTCon:aConoci}

  // Valor
  oCol:=oGrid:AddCol("CXT_VALOR")
  oCol:cTitle    :="Valor"
  oCol:aItems    :={||oNmTCon:aItem }
  oCol:aItemsData:={||oNmTCon:aItem }
  oCol:nWidth    :=100
  oCol:lRepeat   :=.F.

  oGrid:SetColorHead(nil,oDp:nGris,NIL)
  oNmTCon:oFocus:=oGrid:oBrw

  oNmTCon:Activate({||oNmTCon:INICIO()})

RETURN

FUNCTION INICIO()
  LOCAL oFontB

  oNmTCon:oBar:SetSize(NIL,80,.T.)

  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  oNmTCon:oBar:SetSize(NIL,70,.T.)

  @ 2.8,02.5 SAY " "+oNmTCon:cRif BORDER;
             SIZE 90,20 OF oNmTCon:oBar FONT oFontB;
             COLOR oDp:nClrYellowText,oDp:nClrYellow

  @ 2.8,18  SAY " "+SQLGET("DPRIF","RIF_NOMBRE","RIF_ID"+GetWhere("=",oNmTCon:cRif)) BORDER;
             SIZE 290,20 OF oNmTCon:oBar FONT oFontB;
             COLOR oDp:nClrYellowText,oDp:nClrYellow




RETURN .T.
// EOF

/*
// Carga los Datos
*/
FUNCTION LOAD()
RETURN .T.

/*
// Ejecuta la Impresión del Documento
*/
FUNCTION PRINTER()
RETURN .T.

/*
// Permiso para Borrar
*/
FUNCTION GRIDPREDELETE()
RETURN .T.

/*
// Después de Borrar
*/
FUNCTION POSTDELETE()
RETURN .T.


/*
// Carga para Incluir o Modificar en el Grid
*/
FUNCTION GRIDLOAD()

  oGrid:CXT_RIF:=oNmTCon:cRif

RETURN NIL

/*
// PreValidar
*/
FUNCTION GRIDPRESAVE()

   IF Empty(SQLGET("NMCLACONOCI","CDC_GRUPO","CDC_GRUPO"+GetWhere("=",oGrid:CXT_GRUCON)))
      MensajeErr("Registro "+ALLTRIM(oGrid:CXT_GRUCON)+" en "+oDp:xNMCLACONOCI+" no Existe")
      RETURN .F.
   ENDIF

   IF Empty(SQLGET("NMCONOCI","CNC_CLACON","CNC_GRUCON"+GetWhere("=",oGrid:CXT_GRUCON)+" AND CNC_CLACON"+GetWhere("=",oGrid:CXT_CLACON)))
      MensajeErr("Registro "+ALLTRIM(oGrid:CXT_GRUCON)+" "+oGrid:CXT_CLACON+" en "+oDp:xNMCONOCI+" no Existe")
      RETURN .F.
   ENDIF

   IF !oGrid:ChkRecord()
     RETURN .F.
   ENDIF

RETURN .T.

/*
// Ejecución despues de Grabar el Item
*/
FUNCTION GRIDPOSTSAVE()
RETURN .T.

/*
// Genera los Totales por Grid
*/
FUNCTION GRIDTOTAL()
RETURN .T.

FUNCTION CXTGRUCON()
   LOCAL nAt:=0,aData,I

   oNmTCon:aClaCon:=oGrid:LOADCLACON(oGrid:CXT_GRUCON)

   IF Empty(oNmTCon:aClaCon)
      oNmTCon:aClaCon:={}
      AADD(oNmTCon:aClaCon,"Indefinido")
   ENDIF

   nAt:=ASCAN(oNmTCon:aClaCon,{|a,n|a=oGrid:CXT_CLACON})

   IF nAt=0

     oGrid:Set("CXT_CLACON",oNmTCon:aClaCon[1],.T.)
     oGrid:CXTCLACON()

   ENDIF

   IF oGrid:nOption=1

     FOR I=1 TO LEN(oNmTCon:aItem)
        nAt:=ASCAN(oGrid:oBrw:aArrayData,{|a,n|a[4]=oNmTCon:aItem[I]})
     NEXT I

   ENDIF

RETURN .T.

/*
// Valida Clasificación
*/
FUNCTION CXTCLACON()
   LOCAL nAt:=0

   oNmTCon:aConoci:=oGrid:LOADCONOCI(oGrid:CXT_GRUCON,oGrid:CXT_CLACON)
 
   IF Empty(oNmTCon:aConoci)
     oNmTCon:aConoci:={}
     AADD(oNmTCon:aConoci,"Indefinido")
   ENDIF

   nAt:=ASCAN(oNmTCon:aConoci,{|a,n|a=oGrid:CXT_CONOCI})

   IF nAt=0
     oGrid:Set("CXT_CONOCI",oNmTCon:aConoci[1],.T.)
   ENDIF

RETURN .T.


/*
// Valida Conocimiento
*/
FUNCTION CXTCONOCI()
RETURN .T.

/*
// Lee Clasificación de Conocimientos
*/
FUNCTION LOADCLACON(cCodGru)
 LOCAL aData:=ATABLE("SELECT CDC_DESCRI FROM NMCLACONOCI WHERE CDC_GRUPO"+GetWhere("=",cCodGru))
RETURN aData

/*
// Lee Conocimientos
*/
FUNCTION LOADCONOCI(cCodGru,cCodCla)
 LOCAL aData:=ATABLE("SELECT CNC_DESCRI FROM NMCONOCI WHERE CNC_GRUCON"+GetWhere("=",cCodGru)+ " AND "+;
                                                           "CNC_CLACON"+GetWhere("=",cCodCla))
RETURN aData

FUNCTION GRIDVIEW()

RETURN .T.
// EOF
