// Programa   : DPCLIBUSCAR
// Fecha/Hora : 05/10/2012 00:35:19
// Propósito  : Buscar Clientes con Nombres Similares 
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cNombre,lDialog,oControl)
   LOCAL oCol,oBrw,oFontB,aData

   DEFAULT cNombre:=SQLGET("NMTRABAJADOR","CONCAT(NOMBRE,"+GetWhere(" "," ")+",APELLIDO)"),;
           lDialog:=.F.

   aData:=GETADATA(cNombre)

   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New("Buscar Trabajador por Nombre","NMTRABJBUSCAR.EDT","oCliBus",.T.,lDialog)

   oCliBus:cNombre:=PADR(cNombre,200)
   oCliBus:lDialog:=lDialog
   oCliBus:AdjustWnd(oControl)

/*
   @ 1,01 SAY "Nombre" 
   @ 1,06 GET oCliBus:oNombre VAR oCliBus:cNombre

   @ 2,10 BUTTON " > " ACTION oCliBus:GETADATA(oCliBus:cNombre,oCliBus:oBrw)
*/
   oCliBus:oBrw:=TXBrowse():New( oCliBus:oDlg )
   oCliBus:oBrw:SetArray( aData )

   oBrw:=oCliBus:oBrw
   oBrw:oFont:=oFontB

   oBrw:lFastEdit:= .T.
   oBrw:lHScroll := .F.
   oBrw:nFreeze  := 2
   oBrw:lRecordSelector:=.F.

   oCol:=oBrw:aCols[1]
   oCol:cHeader   := "Texto"
   oCol:nWidth    := 410

   oCol:=oBrw:aCols[2]
   oCol:cHeader      := "Ok"
   oCol:nWidth       := 25
   oCol:AddBmpFile("BITMAPS\ledverde.bmp")
   oCol:AddBmpFile("BITMAPS\ledrojo.bmp")
   oCol:bBmpData    := { ||oBrw:=oCliBus:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,2],1,2) }
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bLDClickData:={||oCliBus:TextSelect()}

   oBrw:bClrStd   := {|oBrw|oBrw:=oCliBus:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,2], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrw:nArrayAt%2=0, 16771797 ,  16766378  ) } }

   oBrw:bClrSel     :={|oBrw|oBrw:=oCliBus:oBrw, { 65535,  16733011}}


   oCliBus:oBrw:CreateFromCode()

   oBrw:bClrHeader  := {|| { 0,  12632256}}

   oCliBus:Activate({||oCliBus:CLIBOTBAR()})

   
RETURN oCliBus:cWhere

/*
// Barra de Botones
*/
FUNCTION CLIBOTBAR()

  LOCAL oBar,oBtn

  DEFINE BUTTONBAR oBar SIZE 39, 39 3D OF oCliBus:oDlg

  DEFINE XBUTTON oBtn ;
         FILE oDp:cPathBitMaps+"run.BMP";
         TOOLTIP "Grabar";
         SIZE 38,38;
         ACTION oCliBus:BUSCAR() OF oBar

  DEFINE XBUTTON oBtn ;
         FILE oDp:cPathBitMaps+"xSalir.BMP";
         TOOLTIP "Grabar";
         SIZE 38,38;
         ACTION oCliBus:Close();
         OF oBar

  oCliBus:oBrw:SetColor(nil,16771797)

  Aeval(oBar:aControls,{|a,n|a:SetColor(NIL,oDp:nGris)})
  oBar:SetColor(NIL,oDp:nGris)
  
  @ .75,15 SAY "Nombre" BORDER SIZE 53,20 OF oBar
  @ 1,18 GET oCliBus:oNombre VAR oCliBus:cNombre SIZE 280,20 OF oBar

  @ .8,72 BUTTON " > " ACTION oCliBus:GETADATA(oCliBus:cNombre,oCliBus:oBrw) SIZE 20,20 OF oBar

  IF ValType(oControl)="O"
      EJECUTAR("FRMMOVE",oCliBus,oControl)
  ENDIF

RETURN .T.

FUNCTION TextSelect()

  oCliBus:oBrw:aArrayData[oCliBus:oBrw:nArrayAt,2]:=!(oCliBus:oBrw:aArrayData[oCliBus:oBrw:nArrayAt,2])
  oCliBus:oBrw:Drawline(.T.)

RETURN NIL

FUNCTION BUSCAR()
  LOCAL aData:={},cWhere,cNombre:=""

  AEVAL(oCliBus:oBrw:aArrayData,{|a,n| IF(a[2],AADD(aData,"%"+a[1]+"%") , NIL )})

  AEVAL(aData,{|a,n| cNombre:=cNombre+" "+a})

  cWhere:=GETWHEREOR("NOMBRE"  ,aData)+" OR "+;
          GETWHEREOR("APELLIDO",aData)

  cWhere:=cWhere+" OR "+;
          EJECUTAR("FINDSOUND",cNombre,"APELLIDO")+" OR "+;
          EJECUTAR("FINDSOUND",cNombre,"NOMBRE") 

  cWhere:=STRTRAN(cWhere,"="," LIKE ")

  oCliBus:cWhere:=cWhere
/*
  IF !oCliBus:lDialog
    DPLBX("DPCLIENTESBUSCAR",NIL,cWhere)
  ELSE
    oCliBus:Close()
  ENDIF
*/

 oCliBus:Close()

RETURN cWhere

FUNCTION GETADATA(cNombre,oBrw)
   LOCAL aData:={},I,nAt

   cNombre:=STRTRAN(cNombre,"=","") 
   aData  :=_VECTOR(ALLTRIM(cNombre)," ")

   IF Empty(aData)
      AADD(aData,"")
   ENDIF

   FOR I=1 TO LEN(aData)
     aData[I]:={aData[I],.T.}
   NEXT I

   nAt:=ASCAN(aData,{|a,n| "C.A"$a[1]})

   IF nAt>0
      aData[nAt,2]:=.F.
   ENDIF

   IF ValType(oBrw)="O"
      oCliBus:oBrw:aArrayData:=ACLONE(aData)
      oCliBus:oBrw:Refresh(.T.)
   ENDIF

RETURN aData
// EOF

