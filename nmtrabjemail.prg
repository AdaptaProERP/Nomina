// Programa   : NMTRABJEMAIL
// Fecha/Hora : 22/04/2014 22:01:53
// Propósito  : Solicitar eMail del Trabajador
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodTra)
  LOCAL cEmail,oDlg,oGet,oFontG,oFontB,lOk:=.F.,cMail

  DEFAULT cCodTra:=SQLGET("NMTRABAJADOR","CODIGO","EMAIL"+GetWhere("<>",""))

  DEFINE FONT oFontG  NAME "Tahoma" SIZE 0, -14 BOLD
  DEFINE FONT oFontB  NAME "Tahoma" SIZE 0, -12 BOLD

  cEmail:=SQLGET("NMTRABAJADOR","EMAIL,NOMBRE","CODIGO"+GetWhere("=",cCodTra))
//  cEmail :=pALLTRIM(cEmail)

  DEFINE DIALOG oDlg TITLE "Email del "+oDp:xNMTRABAJADOR+" "+cCodTra COLOR NIL,oDp:nGris2

  oDlg:lHelpIcon:=.F.

  @ 0,.2 SAY " "+oDp:aRow[2]+" " SIZE 157,10;
         COLOR oDp:nClrYellowText,oDp:nClrYellow  FONT oFontB

  @ 0.8,.5 SAY "Cuenta de Correo:" FONT oFontB
  @ 1.8,.5 GET cEmail SIZE 150,12;
           FONT oFontG

  @ 3,14 BUTTON " Aceptar " ACTION (lOk:=VALEMAIL(),IF(lOk,oDlg:End(),NIL));
         FONT oFontB;
         SIZE 32,13


  @ 3,20 BUTTON " Cerrar  " ACTION (lOk:=.F.,oDlg:End());
         FONT oFontB;
         SIZE 32,13

  ACTIVATE DIALOG oDlg CENTERED 

  IF lOk
    cMail :=ALLTRIM(cEmail)
    SQLUPDATE("NMTRABAJADOR","EMAIL",cMail,"CODIGO"+GetWhere("=",cCodTra))
  ENDIF
  
RETURN cMail

FUNCTION VALEMAIL()

  IF !EJECUTAR("EMAILVALID",cEmail)
    MensajeErr("Cuenta de Correo "+cEmail+" no es válida")
    RETURN .F.
  ENDIF

RETURN .T.
// EOF
