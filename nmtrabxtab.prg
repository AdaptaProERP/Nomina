// Programa   : NMTRABXTAB
// Fecha/Hora : 20/09/2004 18:12:32
// Propósito  : Visualizar Trabajadores por Tabla
// Creado Por : Juan Navas
// Llamado por: DPLBX()
// Aplicación : Nómina
// Tabla      : NMTRABAJADOR

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTitle,cWhere)
   LOCAL cSql,nContar:=0,oCursor

/*
   cSql:="SELECT COUNT(*) FROM NMTRABAJADOR "+IF(Empty(cWhere),""," WHERE "+cWhere)

   oCursor:=OpenTable(cSql,.T.)
   nContar:=oCursor:FieldGet(1)
   oCursor:End()
*/
 
   nContar:=COUNT("NMTRABAJADOR",cWhere)
   cTitle :=ALLTRIM(GetFromVar(cTitle))

   IF nContar=0
      MensajeErr(cTitle,"No tiene Registros")
      RETURN .F.
   ENDIF

   cTitle:=cTitle+", "+LSTR(nContar)+" Trabajador(es)"

   DPLBX("NMTRABAJADOR.LBX",cTitle,cWhere)

RETURN .T.
// EOF
