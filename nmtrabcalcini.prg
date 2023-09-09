// Programa   : NMTRABCALCINI
// Fecha/Hora : 22/08/2013 02:17:52
// Propósito  : Se Ejecuta al Uniciar la ejecución Nómina de Cada Trabajador
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oNomina)
   LOCAL cWhere
   // Si devuelve .F. no se Ejecuta


   IF (oNm:cOtraNom=[LR] .OR. oNm:cOtraNom=[LI]) .AND.TABLALIQ()
      // Carga las Variables de la Tabla de Liquidación

      cWhere   :="LIQ_CODTRA"+GetWhere("=",CODIGO)
      oNMTABLIQ:=OpenTable("SELECT * FROM NMTABLIQ WHERE "+cWhere,.T.)

  oNMTABLIQ:Browse()
 
      AEVAL(oNMTABLIQ:aFields,{|a,i|Publico(a[1],oNMTABLIQ:FieldGet(i))})

      oNMTABLIQ:END()
      
   ENDIF


RETURN .T.
