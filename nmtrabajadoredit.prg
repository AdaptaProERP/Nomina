// Programa   : NMTRABAJADOREDIT
// Fecha/Hora : 15/09/2021 01:52:29
// Prop�sito  : Editar Browse del Trabajador
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL cTable,cPrimary,aFields,aPicture,aTitles,cWhere,cTitle

   cTable  :="NMTRABAJADOR"
   cPrimary:="CODIGO"
   aFields :={cPrimary,"APELLIDO","NOMBRE","SALARIO","SALARIOD"}
   aPicture:={NIL,NIL,NIL,"999,999,999,999.99","999,999,999,999.99"}
   cWhere  :="CONDICION"+GetWhere("=","A")
   aTitles :={"C�digo","Apellido","Nombre", "Salario"+CRLF+oDp:cMoneda,"Salario"+CRLF+oDp:cMonedaExt}

RETURN EJECUTAR("BREDITTABLAS",cTable,cPrimary,aFields,aPicture,aTitles,cWhere,cTitle)
// EOF