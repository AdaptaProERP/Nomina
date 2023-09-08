// Programa   : NMFECHASDEPURA
// Fecha/Hora : 21/07/2020 17:23:55
// Propósito  : "Remover Fechas que no tienen Recibos Asociados"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
 LOCAL oTable
  oTable:=OpenTable("SELECT FCH_CODSUC,FCH_NUMERO FROM nmfechas LEFT JOIN NMRECIBOS ON REC_CODSUC=FCH_CODSUC AND REC_NUMFCH=FCH_NUMERO WHERE REC_NUMERO IS NULL",.T.)
  WHILE !oTable:EOF()
     SQLDELETE("NMFECHAS","FCH_CODSUC"+GetWhere("=",oTable:FCH_CODSUC)+" AND FCH_NUMERO"+GetWhere("=",oTable:FCH_NUMERO))
     oTable:DbSkip()
  ENDDO
  oTable:End()
RETURN NIL
// EOF

