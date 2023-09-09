// Programa   : NMTRABAJFCH
// Fecha/Hora : 01/05/2006 08:12:09
// Propósito  : Fechas de los Trabajadores
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Gerencia 
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,nPeriodo,dDesde,dHasta,cCodVen)

   LOCAL aData,cTitle,cWhere,aFechas,cWhere

   DEFAULT cCodSuc:=oDp:cSucursal,;
           nPeriodo:=4

   cTitle:="Trabajadores por Fechas"

   IF !oDp:lNomina
      RETURN NIL
   ENDIF

   IF Empty(dDesde)
     aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
     dDesde :=aFechas[1]
     dHasta :=aFechas[2]
   ENDIF

   aData :=LEERTRABJ(dDesde,dHasta)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,cCodVen)
            
RETURN .T.

FUNCTION ViewData(aData,cTitle,cCodVen)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oNmFch:=DPEDIT():New(cTitle,"NMTRABAJFCH.EDT","oNmFch",.T.)

   oNmFch:cCodSuc :=oDp:cSucursal
   oNmFch:lMsgBar :=.F.
   oNmFch:cPeriodo:=aPeriodos[nPeriodo]
   oNmFch:cCodSuc :=cCodSuc
   oNmFch:nPeriodo:=nPeriodo

   oNmFch:dDesde  :=dDesde
   oNmFch:dHasta  :=dHasta

   oNmFch:oBrw:=TXBrowse():New( oNmFch:oDlg )
   oNmFch:oBrw:SetArray( aData, .T. )
   oNmFch:oBrw:SetFont(oFont)

   oNmFch:oBrw:lFooter     := .T.
   oNmFch:oBrw:lHScroll    := .F.
   oNmFch:oBrw:nHeaderLines:= 1
   oNmFch:oBrw:lFooter     :=.T.

   oNmFch:aData            :=ACLONE(aData)

   AEVAL(oNmFch:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oNmFch:oBrw:aCols[1]   
   oCol:cHeader      :="Cód"
   oCol:nWidth       :=045

   oCol:=oNmFch:oBrw:aCols[2]
   oCol:cHeader      :="Descripción"
   oCol:nWidth       :=300

   oCol:=oNmFch:oBrw:aCols[3]   
   oCol:cHeader      :="Cant."
   oCol:nWidth       :=100
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oNmFch:oBrw:aArrayData[oNmFch:oBrw:nArrayAt,3],;
                                TRAN(nMonto,"99999")}
   oCol:cFooter      :=TRAN( aTotal[3],"99999")



   oNmFch:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oNmFch:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }

   oNmFch:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oNmFch:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oNmFch:oBrw:bLDblClick:={|oBrw|oNmFch:oRep:=oNmFch:VERTRABJ() }

   oNmFch:oBrw:CreateFromCode()

   oNmFch:Activate({||oNmFch:ViewDatBar(oNmFch)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oNmFch)
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oNmFch:oDlg

   oNmFch:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\TRABAJADOR.BMP",NIL,"BITMAPS\TRABAJADORG.BMP";
          ACTION oNmFch:oRep:=oNmFch:VERTRABJ();
          WHEN !Empty(oNmFch:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:DPCLIENTES

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oNmFch:oBrw,oNmFch:cTitle,oNmFch:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oNmFch:Close()

  oNmFch:oBrw:SetColor(0,16773862)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


  //
  // Campo : Periodo
  //

  @ 1.0, (084-60) COMBOBOX oNmFch:oPeriodo  VAR oNmFch:cPeriodo ITEMS aPeriodos;
               SIZE 100,NIL;
               OF oBar;
               FONT oFont;
               ON CHANGE oNmFch:LEEFECHAS()

  @ oNmFch:oPeriodo:nTop,080 SAY "Periodo:" OF oBar BORDER SIZE 34,24

  ComboIni(oNmFch:oPeriodo )

  @ 0.75, (76.5) BUTTON oNmFch:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oNmFch:oPeriodo:nAt,oNmFch:oDesde,oNmFch:oHasta,-1),;
                         EVAL(oNmFch:oBtn:bAction))



  @ 0.75, (81) BUTTON oNmFch:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               ACTION (EJECUTAR("PERIODOMAS",oNmFch:oPeriodo:nAt,oNmFch:oDesde,oNmFch:oHasta,+1),;
               EVAL(oNmFch:oBtn:bAction))


  @ 1.15,037    BMPGET oNmFch:oDesde  VAR oNmFch:dDesde;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNmFch:oDesde ,oNmFch:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oNmFch:oPeriodo:nAt=LEN(oNmFch:oPeriodo:aItems);
                FONT oFont

   oNmFch:oDesde:cToolTip:="F6: Calendario"

  @ 1.15, 47    BMPGET oNmFch:oHasta  VAR oNmFch:dHasta;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oNmFch:oHasta,oNmFch:dHasta);
                SIZE 80,23;
                WHEN oNmFch:oPeriodo:nAt=LEN(oNmFch:oPeriodo:aItems);
                OF oBar;
                FONT oFont

   oNmFch:oHasta:cToolTip:="F6: Calendario"

   @ 0.75, (126+10)+10 BUTTON oNmFch:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               WHEN oNmFch:oPeriodo:nAt=LEN(oNmFch:oPeriodo:aItems);
               ACTION oNmFch:LEERTRABJ(oNmFch:dDesde,oNmFch:dHasta,oNmFch:oBrw)


   oNmFch:oDesde:ForWhen(.T.)
   oNmFch:oBtn:Refresh(.T.)

   oNmFch:oBar:=oBar

//   oBtnCal:bWhen:={|| !Empty(oNmFch:oBrw:aArrayData[1,1]) .AND. ;
//                      !(oNmFch:oPeriodo:nAt=LEN(oNmFch:oPeriodo:aItems)) }


RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodInv)
  LOCAL oRep
RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oNmFch:oPeriodo:nAt,cWhere

  oNmFch:nPeriodo:=nPeriodo

  IF oNmFch:oPeriodo:nAt=LEN(oNmFch:oPeriodo:aItems)

     oNmFch:oDesde:ForWhen(.T.)
     oNmFch:oHasta:ForWhen(.T.)
     oNmFch:oBtn  :ForWhen(.T.)

     DPFOCUS(oNmFch:oDesde)

  ELSE

     oNmFch:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oNmFch:oDesde:VarPut(oNmFch:aFechas[1] , .T. )
     oNmFch:oHasta:VarPut(oNmFch:aFechas[2] , .T. )

     oNmFch:dDesde:=oNmFch:aFechas[1]
     oNmFch:dHasta:=oNmFch:aFechas[2]

     oNmFch:LEERTRABJ(oNmFch:dDesde,oNmFch:dHasta,oNmFch:oBrw)

  ENDIF

RETURN .T.

FUNCTION LEERTRABJ(dDesde,dHasta,oBrw)
   LOCAL aData:={},aTotal:={}
   LOCAL cSql,cCodSuc:=oDp:cSucursal
   LOCAL nPrueba:=0,nAniv:=0,nCumple:=0,nContrat:=0,nPerCont:=

   nPrueba :=COUNT("NMTRABAJADOR","FECHA_ING"+GetWhere(">=",dHasta-89)+" AND CONDICION"+GetWhere("=","A"))
   nAniv   :=COUNT("NMTRABAJADOR",GetWhereAnd("MONTH(FECHA_ING)",MONTH(dDesde),MONTH(dHasta))+;
           " AND CONDICION"+GetWhere("=","A"))
   nCumple :=COUNT("NMTRABAJADOR","MONTH(FECHA_NAC)"+GetWhere("=",MONTH(dHasta))+" AND CONDICION"+GetWhere("=","A"))
   nContrat:=COUNT("NMTRABAJADOR",GetWhereAnd("FECHA_CON",dDesde,dHasta)+" AND CONDICION"+GetWhere("=","A"))
   nPerCont:=COUNT("NMTRABAJADOR","FECHA_CON"+GetWhere("<>",CTOD(""))+" AND CONDICION"+GetWhere("=","A"))


   AADD(aData,{"01","Periodo de Prueba    ",nPrueba })
   AADD(aData,{"02","Fecha Aniversario    ",nAniv   })
   AADD(aData,{"03","Cumpleañenos         ",nCumple })
   AADD(aData,{"04","Contratos por Vencer ",nContrat})
   AADD(aData,{"05","Personal Contratado  ",nPerCont})

   IF ValType(oBrw)="O"
      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1
/*
      oBrw:aCols[3]:cFooter      :=TRAN( aTotal[3],"999,999,999,999.99")
      oBrw:aCols[4]:cFooter      :=TRAN( aTotal[4],"999,999,999,999.99")
      oBrw:aCols[5]:cFooter      :=TRAN( aTotal[5],"999,999,999,999.99")

      oBrw:aCols[6]:cFooter      :=TRAN( aTotal[6],"9999999")

*/
      oBrw:Refresh(.T.)
      AEVAL(oNmFch:oBar:aControls,{|o,n| o:ForWhen(.T.)})
   ENDIF

RETURN aData

FUNCTION VERTRABJ()
  LOCAL cCod:=oNmFch:oBrw:aArrayData[oNmFch:oBrw:nArrayAt,1]

  IF cCod="01"
    EJECUTAR("NMTRABJ3MESES",oNmFch:dHasta)
  ENDIF

  IF cCod="02"
    EJECUTAR("NMTRABJANIV")
  ENDIF

  IF cCod="03"
    EJECUTAR("NMTRABJCUMP")
  ENDIF

  IF cCod="04"
    EJECUTAR("NMTRABJCONT")
  ENDIF

RETURN NIL
