// Programa   : LOTTT
// Fecha/Hora : 27/11/2024 22:20:24
// Contenido: https://github.com/AdaptaProERP/Nomina/blob/main/LOTTT.txt
// Prop�sito  :
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL cFile:="DP\LOTTT.TXT"
   LOCAL aData:={},cMemo,nContar,I,cArticulo:="",cTitle:="",aNew:={},cAnt:=""

   cMemo:=MEMOREAD(cFile)

   cMemo:=STRTRAN(cMemo,"ó","�")
   cMemo:=STRTRAN(cMemo,"ía","�")
   cMemo:=STRTRAN(cMemo,"é","�")
   cMemo:=STRTRAN(cMemo,"ú","�")
   cMemo:=STRTRAN(cMemo,"ñ","�")
   cMemo:=STRTRAN(cMemo,"�"+CHR(173),"�")
   cMemo:=STRTRAN(cMemo,"á","�")
   cMemo:=STRTRAN(cMemo,"�"+CHR(226),"�")
   cMemo:=STRTRAN(cMemo,"Ñ","�")
   cMemo:=STRTRAN(cMemo,"É","�")
   cMemo:=STRTRAN(cMemo,"º","�")
   cMemo:=STRTRAN(cMemo,"ó","�")
   cMemo:=STRTRAN(cMemo,CRLF,CHR(10))
   cMemo:=STRTRAN(cMemo,"CAP�","CAP�")
   cMemo:=STRTRAN(cMemo,"Ámbito",CHR(181)+"mbito") 

   aData:=_VECTOR(cMemo,CHR(10))

   nContar:=0
   cAnt   :=aData[1]
   WHILE nContar<LEN(aData)

      nContar++

      IF LEFT(aData[nContar],8)="Art�culo"
         cTitle   :=cAnt
         cArticulo:=aData[nContar]
         AADD(aNew,{cTitle,cArticulo})
      ENDIF

      cAnt:=aData[nContar]
      
   ENDDO

// ? cTitle   
  
IF .F.

  CLOSE ALL
  SELE A
  USE DP\DPLEYES.DBF EXCLU ALIAS LEYES VIA "DBFCDX"

  ZAP

//  BROWSE()

  FOR I=1 TO LEN(aNew)

     APPEND BLANK

     cAnt     :="culo "+LSTR(I)+"�."

     IF I>9
       cAnt     :="culo "+LSTR(I)+"."
     ENDIF
     
     aNew[I,2]:=STRTRAN(aNew[I,2],cAnt,cAnt+CRLF)

     REPLACE LEY_CAMPO  WITH "LOT"+STRZERO(I,3)
     REPLACE LEY_TITULO WITH aNew[I,1]
     REPLACE LEY_TEXTO  WITH aNew[I,2] 
      
     COMMIT

  NEXT I

// ViewArray(aData)
// ViewArray(aNew)
//  BROWSE()
// ViewArray(DBSTRUCT())

  CLOSE ALL

ENDIF

  EJECUTAR("NMLEYTRA")

RETURN
