// Programa   : NMTRABXLIB
// Fecha/Hora : 30/05/2012 02:59:20
// Propósito  : Trabajadores por Liquidar
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCon)
  LOCAL cSql:="",aData:={},aCodigos:={},I,nAt
  LOCAL aLiq
  LOCAL cTitle:="Resumen de Cuentas por Cobrar "


  DEFAULT cCodCon:="A413"

  EJECUTAR("TABLASNOMINA")

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"NMTRABAJADOR")
     MensajeErr("Tabla NMTRABAJADOR no Existe")
     RETURN .F.
  ENDIF

  cSql:=" SELECT LIQ_CODTRA,CEDULA,APELLIDO,NOMBRE,FECHA_ING,FECHA_EGR,CONDICION,0 AS DIAS FROM NMTABLIQ "+;
        " INNER JOIN NMTRABAJADOR ON CODIGO=LIQ_CODTRA "+;
        " GROUP BY LIQ_CODTRA "

   VISUALIZAR(ASQL(cSql))


  aData:=ASQL(cSql)

  IF EMPTY(aData)
     AADD(aData,{"LIQ_CODTRA","CEDULA","APELLIDO","NOMBRE",CTOD(""),CTOD(""),0})
  ENDIF

  AEVAL(aData,{|a,n| AADD(aCodigos,a[1]) })

  aLiq:=ASQL(" SELECT CODIGO FROM NMTRABAJADOR "+;
             " INNER JOIN NMRECIBOS   ON REC_CODTRA=CODIGO "+;
             " INNER JOIN NMHISTORICO ON REC_NUMERO=HIS_NUMREC  "+;
             " INNER JOIN NMFECHAS    ON FCH_NUMERO=REC_NUMFCH "+;
             " WHERE HIS_CODCON"+GetWhere("=",cCodCon))


 // VISUALIZAR(ASQL(cSql))


  IF Empty(aLiq)
     AADD(aLiq,{"CODIGO"})
  ENDIF

  FOR I=1 TO LEN(aLiq)

     nAt:=ASCAN(aData,{|a,n| aData[n,1]=aLiq[I,1]})

     IF nAt>0
        ARREDUCE(aData,nAt)
     ENDIF

  NEXT I

  FOR I=1 TO LEN(aData)
//   aData[n,7]:=SAYOPTIONS("NMTRABAJADOR","DOC_ESTADO",cEstado)
  NEXT I

  //VISUALIZAR(ASQL(cSql))

 //ViewArray(aData)
 
RETURN aData

FUNCTION VISUALIZAR(aData,cTitle)

   DEFINE FONT oFont  NAME "Verdana"   SIZE 0, -14 BOLD 
   DEFINE FONT oFontB NAME "Arial"     SIZE 0, -14 BOLD

   DPEDIT():New("Personal Liquidado o Sin pago","NMLIQ.EDT","oLiq",.T.)

   


   oLiq:oBrw:=TXBrowse():New( oLiq:oDlg )
   oLiq:oBrw:SetArray( aData, .F. )

   oLiq:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oAnt:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16766975, 16382457 ) } }

   oLiq:oBrw:=TXBrowse():New( oLiq:oDlg )
   oLiq:oBrw:SetArray( aData , .T. )
   oLiq:oBrw:SetFont(oFont)
   oLiq:oBrw:lFooter     := .T.
   oLiq:oBrw:lHScroll    := .F.
   oLiq:oBrw:nHeaderLines:= 1
   oLiq:oBrw:lFooter     :=.F.
   oLiq:oBrw:nDataLines  :=3


   oLiq:oBrw:CreateFromCode()


 AEVAL(oLiq:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})


   oCol:=oLiq:oBrw:aCols[1]   
   oCol:cHeader    :="Código"
   oCol:nWidth       :=080



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

RETURN .T.
//



// EOF


