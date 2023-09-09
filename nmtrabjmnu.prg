// Programa   : NMTRABJMNU
// Fecha/Hora : 23/04/2014 17:22:34
// Prop¢sito  : Opciones Ficha del TRabajador
// Creado Por : Juan Navas
// Llamado por: NMTRABAJADOR
// Aplicaci¢n : Nómina
// Tabla      : TRABAJADOR

#INCLUDE "DPXBASE.CH"
#include "outlook.ch"
#include "splitter.Ch"

PROCE MAIN(oFrm,cCodigo,cNombre)
   LOCAL oFont,oOut,oSpl,oCursor,oBar,oBtn,oBar,I,oBmp,nGroup,bAction,cTitle,oFontBrw,nNumMem:=0,cWhere
   LOCAL aView,I

   IF ValType(oFrm)="O"
     cCodigo:=oFrm:CODIGO
     cNombre:=oFrm:APELLIDO+","+oFRM:NOMBRE
   ENDIF

   DEFAULT cCodigo:=SQLGET("NMTRABAJADOR","CODIGO"),;
           cNombre:=SQLGET("NMTRABAJADOR",[TRA_NOMAPL],"CODIGO"+GetWhere("=",cCodigo))

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
   DEFINE FONT oFontBrw NAME "Tahoma" SIZE 0,-10 BOLD

   cTitle:="Menú: "+GetFromVar("{oDp:xNMTRABAJADOR}")

   DpMdi(cTitle,"oMnuTrabj","TEST.EDT")

   oMnuTrabj:cCodigo   :=cCodigo
   oMnuTrabj:cNombre   :=cNombre
   oMnuTrabj:lSalir    :=.F.
   oMnuTrabj:nHeightD  :=45
   oMnuTrabj:cTitle    :=cTitle
   oMnuTrabj:nTipInv   :=1
   oMnuTrabj:lMsgBar   :=.F.
   oMnuTrabj:nNumMem   :=nNumMem

   SetScript("DPSUCMNU")

   oMnuTrabj:Windows(0,0,540,410)


  @ 48, -1 OUTLOOK oMnuTrabj:oOut ;
     SIZE 150+250, oMnuTrabj:oWnd:nHeight()-90 ;
     PIXEL ;
     FONT oFont ;
     OF oMnuTrabj:oWnd;
     COLOR CLR_BLACK,16772055

   oMnuTrabj:aData:=ACLONE(aData)


   aView:=ASQL("SELECT VIG_CODIGO,VIG_DESCRI FROM DPVIEWGRU WHERE VIG_TABLA"+GetWhere("=","NMTRABAJADOR"))

   IF oDp:nVersion>=6 .AND. LEN(aView)>0

     DEFINE GROUP OF OUTLOOK oMnuTrabj:oOut PROMPT "&Consultas Definibles"

     FOR I=1 TO LEN(aView)

         DEFINE BITMAP OF OUTLOOK oMnuTrabj:oOut ;
                BITMAP "BITMAPS\VIEW.BMP";
                PROMPT ALLTRIM(aView[I,2]);
                ACTION msginfo("Your code ...", "LISTO" )

       nGroup:=LEN(oMnuTrabj:oOut:aGroup)
       oBtn:=ATAIL(oMnuTrabj:oOut:aGroup[ nGroup, 2 ])

       cWhere :="CODIGO"+GetWhere("=",cCodigo)

       bAction:=[EJECUTAR("BRVIEWRUN","NMTRABAJADOR",NIL,"]+ALLTRIM(oMnuTrabj:cCodigo)+[","]+ALLTRIM(oMnuTrabj:cNombre)+[","]+cWhere+[","]+aView[I,1]+[")]
       bAction:=BLOQUECOD(bAction)

       oBtn:bAction:=bAction

       oBtn:=ATAIL(oMnuTrabj:oOut:aGroup[ nGroup, 3 ])
       oBtn:bLButtonUp:=bAction

     NEXT 

   ENDIF

   DEFINE GROUP OF OUTLOOK oMnuTrabj:oOut PROMPT "&Restricciones"


   DEFINE BITMAP OF OUTLOOK oMnuTrabj:oOut ;
          BITMAP "BITMAPS\xunlock.BMP";
          PROMPT "Usuarios Autorizados";
          ACTION EJECUTAR("DPTABXUSU",oMnuTrabj:cCodigo,oMnuTrabj:cNombre,"NMTRABAJADOR","Usuarios por "+GetFromVar("NMTRABAJADOR"))
/*
   DEFINE BITMAP OF OUTLOOK oMnuTrabj:oOut ;
          BITMAP "BITMAPS\PRODUCTO.BMP";
          PROMPT "Restricción de Productos";
          ACTION EJECUTAR("DPTABXSUC",oMnuTrabj:cCodigo,,,,,,,NIL)

   DEFINE BITMAP OF OUTLOOK oMnuTrabj:oOut ;
          BITMAP "BITMAPS\CLIENTE.BMP";
          PROMPT "Restricción "+oDp:DPCLIENTES;
          ACTION EJECUTAR("DPTABXSUC",oMnuTrabj:cCodigo,oDp:xDPCLIENTES,"DPCLIENTES",oDp:xDPCLIENTES+" por "+oDp:xDPSUCURSAL,"CLI_CODIGO","CLI_NOMBRE",NIL,NIL)

*/

/*
   DEFINE BITMAP OF OUTLOOK oMnuTrabj:oOut ;
          BITMAP "BITMAPS\trabajador.BMP";
          PROMPT "Restricción de Sucursal"+oDp:NMTRABAJADOR;
          ACTION EJECUTAR("DPTABXSUC",oMnuTrabj:cCodigo,oDp:xNMTRABAJADOR,"NMTRABAJADOR",oDp:xNMTRABAJADOR+" por "+oDp:xDPSUCURSAL,"CODIGO","TRA_NOMAPL",NIL,NIL)
*/

   DEFINE DIALOG oMnuTrabj:oDlg FROM 0,oMnuTrabj:oOut:nWidth() TO oMnuTrabj:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oMnuTrabj:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oMnuTrabj:oGrp TO 10,10 PROMPT "Código ["+oMnuTrabj:cCodigo+"]" FONT oFont

   @ .5,.5 SAY oMnuTrabj:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontBrw

   ACTIVATE DIALOG oMnuTrabj:oDlg NOWAIT VALID .F.

   oMnuTrabj:Activate("oMnuTrabj:FRMINIT()")

 
RETURN

FUNCTION FRMINIT()

   oMnuTrabj:oWnd:bResized:={||oMnuTrabj:oDlg:Move(0,0,oMnuTrabj:oWnd:nWidth(),50,.T.),;
                             oMnuTrabj:oGrp:Move(0,0,oMnuTrabj:oWnd:nWidth()-15,oMnuTrabj:nHeightD,.T.)}

   EVal(oMnuTrabj:oWnd:bResized)

RETURN .T.

// EOF

