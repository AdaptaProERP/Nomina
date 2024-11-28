// Programa   : LOTTT
// Fecha/Hora : 27/11/2024 22:20:24
// Contenido: https://github.com/AdaptaProERP/Nomina/blob/main/LOTTT.txt
// PropÛsito  :
// Creado Por :
// Llamado por:
// AplicaciÛn :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL cFile:="DP\LOTTT.TXT"
   LOCAL aData:={},cMemo,nContar,I,cArticulo:="",cTitle:="",aNew:={},cAnt:=""

   cMemo:=MEMOREAD(cFile)

   cMemo:=STRTRAN(cMemo,"√≥","Û")
   cMemo:=STRTRAN(cMemo,"√≠a","Ì")
   cMemo:=STRTRAN(cMemo,"√©","È")
   cMemo:=STRTRAN(cMemo,"√∫","˙")
   cMemo:=STRTRAN(cMemo,"√±","Ò")
   cMemo:=STRTRAN(cMemo,"√"+CHR(173),"Ì")
   cMemo:=STRTRAN(cMemo,"√°","Ì")
   cMemo:=STRTRAN(cMemo,"√"+CHR(226),"—")
   cMemo:=STRTRAN(cMemo,"√ë","—")
   cMemo:=STRTRAN(cMemo,"√â","…")
   cMemo:=STRTRAN(cMemo,"¬∫","∫")
   cMemo:=STRTRAN(cMemo,"√≥","Ì")
   cMemo:=STRTRAN(cMemo,CRLF,CHR(10))
   cMemo:=STRTRAN(cMemo,"CAP√","CAPÕ")
   cMemo:=STRTRAN(cMemo,"√Åmbito",CHR(181)+"mbito") 

   aData:=_VECTOR(cMemo,CHR(10))

   nContar:=0
   cAnt   :=aData[1]
   WHILE nContar<LEN(aData)

      nContar++

      IF LEFT(aData[nContar],8)="ArtÌculo"
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

     cAnt     :="culo "+LSTR(I)+"∫."

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
