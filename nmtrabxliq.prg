// Programa   : NMTRABXLIB
// Fecha/Hora : 30/05/2012 02:59:20
// Propósito  : Trabajadores por Liquidar
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCon)
  LOCAL cSql:="",aData:={},aCodigos:={},I,nAt,cEstado:=""
  LOCAL aLiq
  LOCAL cTitle:="Resumen de Cuentas por Cobrar "

  DEFAULT cCodCon:="A413"

  EJECUTAR("TABLASNOMINA")

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"NMTRABAJADOR")
     MensajeErr("Tabla NMTRABAJADOR no Existe")
     RETURN .F.
  ENDIF

  cSql:=" SELECT CODIGO,CEDULA,APELLIDO,NOMBRE,FECHA_ING,FECHA_EGR,CONDICION,0 AS DIAS FROM NMTRABAJADORES "+;
        " LEFT JOIN NMTABLIQ ON LIQ_CODTRA=CODIGO AND LIQ_CODTRA IS NULL "+;
        " WHERE CONDICION"+GetWhere("=","A")+" AND FECHA_EGR>FECHA_ING "

  aData:=ASQL(cSql)

  IF EMPTY(aData)
     AADD(aData,{"LIQ_CODTRA","CEDULA","APELLIDO","NOMBRE",CTOD(""),CTOD(""),"L",0})
  ENDIF

  FOR I=1 TO LEN(aLiq)

     nAt:=ASCAN(aData,{|a,n| aData[n,1]=aLiq[I,1]})

     // Busca si Ha recibido Pagos
     IF nAt>0
       // ARREDUCE(aData,nAt)
     ENDIF

  NEXT I

  FOR I=1 TO LEN(aData)

     cEstado   :=aData[I,7]
     cEstado   :=ALLTRIM(SAYOPTIONS("NMTRABAJADOR","DOC_ESTADO",cEstado))

     cEstado   :=IIF( cEstado="L","Liquidado",cEstado)
     cEstado   :=IIF( cEstado="A","Activo"   ,cEstado)
    
     aData[I,7]:=cEstado
     aData[I,8]:=oDp:dFecha-aData[I,6]

  NEXT I

  VISUALIZAR(aData)

RETURN aData

FUNCTION VISUALIZAR(aData,cTitle)
   LOCAL oCol

   DEFINE FONT oFont  NAME "Verdana"   SIZE 0, -14 BOLD 
   DEFINE FONT oFontB NAME "Arial"     SIZE 0, -14 BOLD

   DPEDIT():New("Trabajadores Egresados sin Registro en la Tabla de Liquidación","NMTRABXLIQ.EDT","oLiq",.T.)
   
   oLiq:lMsgBar:=.F.       // Sin Barra de Botones

   // Declaración del Browse
   oLiq:oBrw:=TXBrowse():New( oLiq:oDlg )
   oLiq:oBrw:SetArray( aData , .T. )   // Asignación del Contenido mediante Arreglo, .T. (Ordenar Alfabetico)
   oLiq:oBrw:SetFont(oFont)            // Fuente para el Contenido de Cada Linea
   oLiq:oBrw:lFooter     := .F.        // Si tiene Pie de Pagina
   oLiq:oBrw:lHScroll    := .F.        // Desplazamiento Vertical
   oLiq:oBrw:nHeaderLines:= 2          // Linea para el Encabezado
   oLiq:oBrw:bClrHeader  := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}} // Color del Encabezado
   oLiq:oBrw:bClrFooter  := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}} // Color de la Barra dezplamiento


   // Color de cada Linea, Pares 16773862, Impares 16382457
   oLiq:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oLiq:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( !oBrw:nArrayAt%2=0, 16382457,15790320 ) } }

   // Fuente del Encabezado
   AEVAL(oLiq:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   // Declaracion de Cada Linea
   oCol:=oLiq:oBrw:aCols[1]   
   oCol:cHeader    :="Código"
   oCol:nWidth       :=080

   oCol:=oLiq:oBrw:aCols[2]   
   oCol:cHeader    :="Cédula"
   oCol:nWidth       :=080

   oCol:=oLiq:oBrw:aCols[3]   
   oCol:cHeader    :="Apellidos"
   oCol:nWidth       :=160

   oCol:=oLiq:oBrw:aCols[4]   
   oCol:cHeader    :="Nombre"
   oCol:nWidth       :=160

   oCol:=oLiq:oBrw:aCols[5]   
   oCol:cHeader    :="Ingreso"
   oCol:nWidth       :=76

   oCol:=oLiq:oBrw:aCols[6]   
   oCol:cHeader    :="Egreso"
   oCol:nWidth       :=76

   oCol:=oLiq:oBrw:aCols[7]   
   oCol:cHeader    :="Condición"
   oCol:nWidth       :=80

   oCol:=oLiq:oBrw:aCols[8]   
   oCol:cHeader    :="Días"+CRLF+"Transc"
   oCol:nWidth       :=80

   // Culminacion de Declaración del Browse
   oLiq:oBrw:CreateFromCode()

   oLiq:Activate({|| oLiq:MYBOTONBAR() })

RETURN NIL


FUNCTION MYBOTONBAR()
   LOCAL oCursor,oBar,oBtn,oFont

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oLiq:oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oLiq:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oLiq:Close()

  oLiq:oBrw:SetColor(0,16382457)

// 16382457,15790320

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


RETURN .T.
//



// EOF


