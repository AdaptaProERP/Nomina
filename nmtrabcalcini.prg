// Programa   : NMTRABCALCINI
// Fecha/Hora : 22/08/2013 02:17:52
// Prop�sito  : Se Ejecuta al Uniciar la ejecuci�n N�mina de Cada Trabajador
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oNomina)
   LOCAL cWhere
   // Si devuelve .F. no se Ejecuta


   IF (oNm:cOtraNom=[LR] .OR. oNm:cOtraNom=[LI]) .AND.TABLALIQ()
      // Carga las Variables de la Tabla de Liquidaci�n

      cWhere   :="LIQ_CODTRA"+GetWhere("=",CODIGO)
      oNMTABLIQ:=OpenTable("SELECT * FROM NMTABLIQ WHERE "+cWhere,.T.)

  oNMTABLIQ:Browse()
 
      AEVAL(oNMTABLIQ:aFields,{|a,i|Publico(a[1],oNMTABLIQ:FieldGet(i))})

      oNMTABLIQ:END()
      
   ENDIF


RETURN .T.
