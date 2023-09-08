// Programa   : NMCALAPH
// Fecha/Hora : 20/12/2012 02:24:23
// Propósito  : Calcular Política Habitacional
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(aCodCon,dDesde,dHasta)
 LOCAL cWhere,nMonto:=0

 DEFAULT aCodCon:={"D028","H005"},;
         dDesde :=FCHINIMES(oDp:dFecha),;
         dHasta :=FCHFINMES(oDp:dFecha)

 cWhere:=" INNER JOIN NMRECIBOS    ON HIS_NUMREC=REC_NUMERO "+;
         " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO     "+;
         " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
         " WHERE "+GetWhereOr("HIS_CODCON",aCodCon)+" AND "+;
                  +GetWhereAnd("FCH_DESDE",dDesde,dHasta)

 nMonto:=SQLGET("NMHISTORICO","SUM(ABS(HIS_MONTO))",cWhere)

RETURN nMonto
// EOF

