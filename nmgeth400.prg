// Programa   : NMGETH400  
// Fecha/Hora : 22/03/2012 18:35:51
// Propósito  : Obtener Ultimo Valor del Concepto Historico H400
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
   LOCAL nH400:=0

   DEFAULT cCodTra:="3003"

   nH400:=SQLGET("NMHISTORICO","HIS_MONTO"," INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
                                           " INNER JOIN NMFECHAS  ON FCH_NUMERO=REC_NUMFCH "+;
                                           " WHERE REC_CODTRA"+GetWhere("=",cCodTra)+;
                                           " ORDER BY FCH_HASTA DESC LIMIT 1 ")

   ? nH400

RETURN nH400
// EOF
