// Programa   : BUILDDEMOTRABAJADOR
// Fecha/Hora : 14/08/2021 06:57:58
// Propósito  : Convierte los Datos del Proveedor
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oTable:=Opentable("SELECT CODIGO FROM NMTRABAJADOR",.T.),nContar:=0
  LOCAL cCodigo,cSql,oDb:=OpenOdbc(oDp:cDsnData)
  LOCAL oLink:=OpenTable("SELECT LNK_TABLED,LNK_FIELDD FROM DPLINK WHERE LNK_TABLES"+GetWhere("=","NMTRABAJADOR")+" AND LNK_RUN=1")

  IF !ISPCPRG()
     oTable:End()
     RETURN .T.
  ENDIF

  oTable:Browse()
  oLink:Browse()
  oLink:End()

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  WHILE !oTable:Eof()

     nContar++

     cCodigo:=STRZERO(nContar,10)
//     WHILE ISSQLFIND("NMTRABAJADOR","CLI_CODIGO"+GetWhere("=",cCodigo))
//        nContar++
//        cCodigo:=STRZERO(nContar,10)
//     ENDDO

     SQLUPDATE("NMTRABAJADOR",{"CODIGO","CEDULA","RIF"},{cCodigo,LSTR(nContar),"V"+LSTR(nContar)},"CODIGO"+GetWhere("=",oTable:CODIGO))


     oLink:GoTop()
     WHILE !oLink:Eof()
        SQLUPDATE(ALLTRIM(oLink:LNK_TABLED),ALLTRIM(oLink:LNK_FIELDD),cCodigo,oLink:LNK_FIELDD+GetWhere("=",oTable:CODIGO))
        oLink:DbSkip()
     ENDDO

     SQLUPDATE("NMRECIBOS"   ,"REC_CODTRA",cCodigo,"REC_CODTRA"+GetWhere("=",oTable:CODIGO))
//   SQLUPDATE("DPMOVINV"   ,"MOV_CODCTA",{cCodigo},"MOV_APLORG"+GetWhere("=","3")+" AND MOV_CODCTA"+GetWhere("=",oTable:CLI_CODIGO))

     oTable:DbSkip()

     SysRefresh(.T.)

  ENDDO

  oTable:End()

//  cSql:=[UPDATE dpclientes SET CLI_LOGIN="",CLI_CELUL1="",CLI_CELUL2="",CLI_AREA="",CLI_DIR1="",CLI_DIR2="",CLI_TEL1="",CLI_TEL2="",CLI_TEL3="",CLI_TEL4:="",CLI_TEL5="",CLI_TEL6="",CLI_DIR1="",CLI_DIR2="",CLI_DIR3="",CLI_EMAIL=""]
//  oDb:Execute(cSql)

//  cSql:=" SET FOREIGN_KEY_CHECKS = 1"
//  oDb:Execute(cSql)

RETURN .T.
// EOF


