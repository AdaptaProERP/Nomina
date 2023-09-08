// Programa   : NMACTRUN
// Fecha/Hora : 20/04/2005 22:59:00
// Prop�sito  : Ejecuci�n en cada Recibo de N�mina Cuando Se Actualiza
// Creado Por : Juan Navas
// Llamado por: ACTUALIZA
// Aplicaci�n : N�mina
// Tabla      : NMRECIBOS

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oNomina)

  /*
  // Debe ser Aplicado Cuando se Requiere Reprocesar Salarios
  */
  IF ValType(oNomina)="O" .AND. .F.
    EJECUTAR("NMRECSALARIO",CODIGO,oNomina:dDesde,oNomina:dHasta)
  ENDIF

RETURN .T.
// EOF
