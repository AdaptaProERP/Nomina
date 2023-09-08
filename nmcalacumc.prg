// Programa   : NMCALACUMC
// Fecha/Hora : 24/05/2004 01:19:07
// Propósito  : Calcular los Acumulados mensuales por Concepto
// Creado Por : Juan Navas
// Llamado por: Actualizar, Reversar Nómina, Clase TNomina
// Aplicación : Nómina
// Tabla      : NMACUMCON

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dFecha)
  LOCAL oTable,oAcum
  LOCAL dDesde,dHasta
  LOCAL cMes,cWhere,cAno,cSql

  DEFAULT dFecha:=oDp:dHasta

  RETURN .T.
 
// Esto no Hace, falta, para esto son los Query

  dDesde:=FCHINIMES(dFecha)
  dHasta:=FCHFINMES(dFecha)
  cMes  :=STRZERO(MONTH(dHasta),2)
  cAno  :=STRZERO(YEAR(dHasta),4)

  cSql:="SELECT HIS_CODCON,SUM(HIS_MONTO) FROM NMHISTORICO "+;
        " INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
        " WHERE REC_DESDE"+GetWhere(">=",dDesde)+;
        "   AND REC_HASTA"+GetWhere("<=",dHasta)+;
        " GROUP BY HIS_CODCON "

   oTable:=OpenTable(cSql,.T.)

   WHILE !oTable:Eof()

      oAcum:=OpenTable("SELECT ACU_CODCON,ACU_ANO,ACU_"+cMes+" FROM NMACUMCON "+;
                       " WHERE ACU_CODCON"+GetWhere("=",oTable:HIS_CODCON)+;
                       "   AND ACU_ANO   "+GetWhere("=",cAno),.T.)

      IF oAcum:RecCount()=0
         oAcum:Append()
         oAcum:Replace("ACU_CODCON",oTable:HIS_CODCON)
         oAcum:Replace("ACU_ANO"   ,cAno)
         cWhere:=""
      ELSE
         cWhere:=oAcum:cWhere
      ENDIF

      oAcum:Replace(oAcum:FieldName(3),oTable:FieldGet(2)) 
      oAcum:Commit(cWhere)
      oAcum:End()

      oTable:Skip()

   ENDDO
  
   oTable:End()

RETURN .T.
