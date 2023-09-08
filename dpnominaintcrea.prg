// Programa   : DPNOMINAINTCREA
// Fecha/Hora : 16/09/2021 20:13:44
// Propósito  : Crear Tabla Integración Nómina
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL aFields:={},aData:={},I
  LOCAL cSeniat:=EJECUTAR("GETCODSENIAT")

  AADD(aFields,{"ITN_CODIGO","C",03,0,"ID"               ,""})
  AADD(aFields,{"ITN_RIF"   ,"C",12,0,"RIF"              ,""})
  AADD(aFields,{"ITN_CONRET","C",04,0,"Retención"        ,""})
  AADD(aFields,{"ITN_CONPAT","C",04,0,"Aporte Patronal"  ,""})
  AADD(aFields,{"ITN_ACTIVO","L",01,0,"Activo"           ,""})
  AADD(aFields,{"ITN_CODREP","C",20,0,"Código Reporte"   ,""})
  AADD(aFields,{"ITN_TIPDOC","C",03,0,"Tipo Documento"   ,""})
 
  EJECUTAR("DPTABLEADD","DPNOMINAINT","Integración de Nómina","<MULTIPLE",aFields)

  AADD(aData,{"001","G200040769","H003","D004","APORTESSO" ,"SSO"}) // SSO
  AADD(aData,{"002","G200040769","H004","D005","APORTEPF"  ,"SSO"}) // PF
  AADD(aData,{"003","G200000856","H005","D028","APORTELPH" ,"HAB"}) // LPH
  AADD(aData,{"004",oDp:cRif    ,"H001","D012","APORTECAJA","NOM"}) // CAJA AHORRO
  AADD(aData,{"005",cSeniat     ,""    ,"D014","FALTA"     ,"XML"}) // ISLR
  AADD(aData,{"006","G200099224","H001","D012","APORTECAJA","INC"}) // INCE
 
  FOR I=1 TO LEN(aData)

    EJECUTAR("CREATERECORD","DPNOMINAINT",{"ITN_CODIGO","ITN_RIF" ,"ITN_CONPAT","ITN_CONRET","ITN_ACTIVO","ITN_CODREP","ITN_TIPDOC"},;
                                          {aData[I,1]  ,aData[I,2],aData[I,3]  ,aData[I,4]  ,.T.         ,aData[I,5]  ,aData[I,6]  },;
                                          NIL,.T.,"ITN_CODIGO"+GetWhere("=",aData[I,1]))

  NEXT I

/*
SELECT
ITN_CODIGO,
ITN_RIF,
PRO_NOMBRE,
ITN_CONRET,
CON_DESCRI,
ITN_CONPAT,
CIC_CUENTA,
SUM(IF(HIS_CODCON=ITN_CONRET, HIS_MONTO, 0 )) AS APORTE_TRA,
SUM(IF(HIS_CODCON=ITN_CONPAT, HIS_MONTO, 0 )) AS APORTE_PAT 
FROM NMHISTORICO 
INNER JOIN nmrecibos       ON NMHISTORICO.HIS_CODSUC=NMRECIBOS.REC_CODSUC AND NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO 
INNER JOIN nmfechas        ON NMRECIBOS.REC_CODSUC=NMFECHAS.FCH_CODSUC AND NMRECIBOS.REC_NUMFCH=NMFECHAS.FCH_NUMERO 
INNER JOIN nmconceptos     ON HIS_CODCON=CON_CODIGO
INNER JOIN dpnominaint     ON nmhistorico.HIS_CODCON=ITN_CONRET OR nmhistorico.HIS_CODCON=ITN_CONPAT
INNER JOIN dpproveedor     ON PRO_RIF=ITN_RIF
LEFT  JOIN NMCONCEPTOS_CTA ON CIC_CODIGO=ITN_CONPAT AND CIC_CODINT="CUENTA"
LEFT  JOIN dpcta           ON CIC_CTAMOD=CTA_CODMOD AND CIC_CUENTA=CTA_CODIGO
WHERE ((NMFECHAS.FCH_DESDE>= '2021-09-01') AND (NMFECHAS.FCH_HASTA<= '2021-09-30')) 
GROUP BY ITN_CODIGO
ORDER BY ITN_CODIGO

*/

RETURN .T.
// EOF
