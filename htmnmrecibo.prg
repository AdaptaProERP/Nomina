// Programa   : HTMNMRECIBO
// Fecha/Hora : 21/04/2014 21:54:40
// Propósito  : Recibo de Nómina 
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla  

#define HT_LEFT   1 
#define HT_RIGHT  2 
#define HT_CENTER 3 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cRecibo,cFile,lRun)
  LOCAL oH,oTH,cSql,oTable,oCol,nSaldo:=0,nAsigna:=0,nDeducc:=0,oNmTrabj
  
  DEFAULT cRecibo:=SQLGET("NMRECIBOS","REC_NUMERO","1=1"),;
          lRun   :=.T.

  cSql:="SELECT HIS_CODCON,CON_DESCRI,CON_REPRES,HIS_VARIAC,HIS_MONTO,HIS_NUMMEM,HIS_NUMOBS FROM NMHISTORICO "+;
        "INNER JOIN NMCONCEPTOS ON HIS_CODCON=CON_CODIGO WHERE HIS_NUMREC"+GetWhere("=",cRecibo)

  oTable:=OpenTable(cSql,.T.)

  WHILE !oTable:Eof()

     IF LEFT(oTable:HIS_CODCON,1)$"AD"
       nSaldo :=nSaldo +oTable:HIS_MONTO
       nAsigna:=nAsigna+IIF(oTable:HIS_MONTO>0,oTable:HIS_MONTO,0)
       nDeducc:=nDeducc+IIF(oTable:HIS_MONTO<0,ABS(oTable:HIS_MONTO),0)
     ENDIF

     oTable:DbSkip()

  ENDDO

  oTable:GoTop()

  oNmTrabj  :=OpenTable("SELECT NOMBRE,APELLIDO,CEDULA,FCH_TIPNOM,FCH_OTRNOM,REC_CODTRA,FCH_DESDE,FCH_HASTA FROM NMRECIBOS "+;
                        "INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
                        "INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO   "+;
                        "WHERE REC_NUMERO"+GetWhere("=",cRecibo),.T.)

  oDp:lTracer:=.F.

  oTable:GoTop()

  oH:=EJECUTAR("DPHTMLCLASS","Recibo de Nómina",cFile)

  oH:HDEFINEFONT("F1",[FONT FACE="impact" SIZE=6 COLOR="blue"])
  oH:HDEFINEFONT("F2",[FONT FACE="impact" SIZE=2 COLOR="black"])
  oH:HDEFINEFONT("F3",[FONT FACE="impact" SIZE=4 COLOR="Green"])
  oH:HDEFINEFONT("F4",[FONT FACE="impact" SIZE=2 COLOR="Red"])

  oH:HSETSTYLE([ thead tr {background-color: ActiveCaption; color: CaptionText;} ]+CRLF+;
               [ th, td {vertical-align: top; font-family: "Tahoma", Arial, Helvetica, sans-serif; font-size: 8pt; padding: 3px; } ]+CRLF+;
               [ table, td {border: 1px solid MidnightBlue;} ]+CRLF+;
               [ table {border-collapse: collapse;} ])

  oH:HSETFONT("F1")

  oH:HSAY("Empresa:" +oDp:cEmpresa,.F.)
  oH:HSAY(oDp:cRif    ,.T.,"F3")

  oH:HSAY([Recibo de Pago],.F.)
  oH:HSAY(cRecibo,.T.,"F3")
  oH:HSAY([Nombre: ]       ,.F.,"F2")
  OH:HSAY(oNmTrabj:APELLIDO+","+oNmTrabj:NOMBRE,.T.,"F3")

  oH:HSAY([Cédula: ]       ,.F.,"F2")
  OH:HSAY(oNmTrabj:CEDULA,.T.,"F3")


  // Definición de la Tabla
  oTH:=OH:HSETTABLE()

  oCol:=OH:HSETCOL(oTH)
  oCol:cHeader:="Tipo"
  oCol:bStrData:={||oTable:HIS_CODCON}
  oCol:nWidth  :=40

  oCol:=OH:HSETCOL(oTH)
  oCol:cHeader:="Descripción"
  oCol:bStrData:={||oTable:CON_DESCRI}
  oCol:cTotal  :="Registros "+LSTR(oTable:RecCount())
  oCOl:nAlign  :=HT_LEFT

  oCol:=OH:HSETCOL(oTH)
  oCol:cHeader:="Presentación"
  oCol:bStrData:={||oTable:CON_REPRES}
  oCOl:nAlign  :=HT_LEFT

  oCol:=OH:HSETCOL(oTH)
  oCol:cHeader:="Variación"
  oCol:bStrData:={||TRAN(oTable:HIS_VARIAC,"999,999.99")}
  oCOl:nAlign  :=HT_RIGHT

  oCol:=OH:HSETCOL(oTH)
  oCol:cHeader :="Histórico"
  oCol:bStrData:={||IF(LEFT(oTable:HIS_CODCON,1)="H",TRAN(ABS(oTable:HIS_MONTO),"99,999,999.99"),SPACE(10))}
  oCOl:nAlign  :=HT_RIGHT
//oCol:cTotal  :=TRAN(nAsigna,"999,999,999.99")


  oCol:=OH:HSETCOL(oTH)
  oCol:cHeader :="Asignación"
  oCol:bStrData:={||IF(oTable:HIS_MONTO>0 .AND. LEFT(oTable:HIS_CODCON,1)="A",TRAN(ABS(oTable:HIS_MONTO),"99,999,999.99"),SPACE(10))}
  oCOl:nAlign  :=HT_RIGHT
  oCol:cTotal  :=TRAN(nAsigna,"999,999,999.99")

  oCol:=OH:HSETCOL(oTH)
  oCol:cHeader:="Deducción"
  oCol:bStrData:={||IF(oTable:HIS_MONTO<0 .AND. LEFT(oTable:HIS_CODCON,1)="D",TRAN(ABS(oTable:HIS_MONTO),"99,999,999.99"),SPACE(10))}
  oCOl:nAlign  :=HT_RIGHT
  oCol:cTotal  :=TRAN(nDeducc,"999,999,999.99")

  oTH:=OH:HGENTABLE(oTH,oTable)

  OH:HSAY("En Letras : "+Lower(ENLETRAS(nSaldo)),.T.,"F4")

  IF lRun
    oH:HRUN()
  ELSE
    oH:HSAVE()
  ENDIF

  oTable:End()
  oNmTrabj:End()

RETURN NIL
// EOF



