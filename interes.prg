// Programa   : INTERES
// Fecha/Hora : 12/09/2010 16:44:41
// Propósito  : Calcular Interes sobre Antiguedad Laboral
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION INTERES(cField,cDeuda,cAbonos,dDesde,dHasta,aVector,NEGATIVO,ANIODIAS,nTasa,_CFINMES,_CAPCOR,cCodTra,lIndexa,nBase,dFchIni,cConIni)
   LOCAL aTasas :={},aCodCon:={},aPagos:={},aFechas:={},aSigno:={}
   LOCAL oTable
   LOCAL cFecha:=HISFECHA(),cWhere:=""
   LOCAL nMax,nContar:=0,nDeuda:=0,nPagos:=0,nInteres:=0,nCapital:=0,nDias,I,nAt
   LOCAL nBaseAcu:=0
   LOCAL nBaseAnual:=oDp:nBaseAnual,nInteresT:=0
   LOCAL dFecha,dFechaA,dDia,dFechaNext
   LOCAL nBaseCap // := Capital Base
   LOCAL aData:={},aTotal:={}
   LOCAL A1:=0,A2:=0,A3:=0,nCuota:=0
   LOCAL nInteresT:=0,nIntCal:=0

   DEFAULT nBaseAnual:=360

   nBase :=0 // Es Solicitado desde el Concepto para Conocer la Base de Cálculo

   DEFAULT aVector:={}

   DEFAULT cField :="INT_TASA",;
           cAbonos:=cPagos:=oDp:cConAdel+","+oDp:cConInter,;
           lIndexa:=.T.       ,;  
           cCodTra:="1002",;
           dHasta :=oDp:dFecha,;
           cDeuda :="H400",;
           cConIni:="N411"

   SET DECI TO 2

   CURSORWAIT()

   IF TYPE("oTrabajador")="O" .AND. !Empty(cCodTra)

     DEFAULT cCodTra:=oTrabajador:CODIGO

   ENDIF

   oDp:aIntereses:={}

   IF TYPE("oNM")="O"

     DEFAULT dHasta :=oNm:dHasta

   ENDIF

   //
   // La funcion puede recibir un arreglo (se escribe Vector debido a que viene de DOS) 
   // Este arreglo incluya lista de la antiguedad, laboral
   //

   IF EMPTY(aVector)

      // Si el vector esta vacio, hace una consulta con, Concepto, Monto y Fecha
   
      aVector:={}

      cWhere:=" INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
              " INNER JOIN NMFECHAS  ON REC_NUMFCH=FCH_NUMERO "+;
              " WHERE "+;
              " REC_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
              " HIS_CODCON"+GetWhere("=",cConIni)

// ? cWhere,"cWhere",cCodTra,cConIni

      nIntCal:=SQLGET("NMHISTORICO","SUM(HIS_MONTO)",cWhere)

      cWhere :="REC_CODTRA"+GetWhere("=",cCodTra)+" AND "+;
               "FCH_HASTA"+GetWhere("<=",dHasta)+" AND "+;
               GetWhereOr("HIS_CODCON",_Vector(cDeuda + IIF(EMPTY(cAbonos) , "" , "," ) + cAbonos))+;
               " ORDER BY FCH_HASTA"

      oTable:=OpenTable("SELECT HIS_CODCON,HIS_MONTO,"+cFecha+" FROM NMHISTORICO INNER JOIN NMRECIBOS ON REC_NUMERO=HIS_NUMREC "+;
                        "INNER JOIN NMFECHAS ON REC_NUMFCH=FCH_NUMERO "+;
                        " WHERE " + cWhere,.T.)

      WHILE !oTable:Eof()

         dFecha:=oTable:FIELDGET(3)
         nDias :=DAY(dFecha)

         IF nBaseAnual=360 .AND. (nDias>30)

            dFecha:=dFecha-1

         ENDIF

         AADD(aData,{oTable:HIS_CODCON,oTable:HIS_MONTO,dFecha,IIF(oTable:HIS_CODCON$cDeuda,1,-1)})

         oTable:DbSkip()

      ENDDO

//  1  AADD(aCodCon,oTable:HIS_CODCON )
//  2  AADD(aPagos ,oTable:HIS_MONTO  )
//  3  AADD(aFechas,oTable:FIELDGET(3))
//  4  AADD(aSigno ,IIF(oTable:HIS_CODCON$cDeuda,1,-1))

      oTable:End()

   ELSE

      aData  :=ACLONE(aVector)
      aVector:={}

   ENDIF

/*
   AADD(aData,{"H400",15121.16,CTOD("31/12/2009"),1})
   AADD(aData,{"H400",617.15,CTOD("31/01/2010"),1})
   AADD(aData,{"H400",966.00,CTOD("30/04/2010"),1})
   AADD(aData,{"H400",933.80,CTOD("30/09/2010"),1})
   AADD(aData,{"H400",1014.30,CTOD("31/12/2015"),1})
   AADD(aData,{"H400",1014.30,CTOD("31/05/2016"),1})
   AADD(aData,{"H400",1014.30,CTOD("30/08/2016"),1})
*/

   // Los datos del vector se copia en aData

   IF EMPTY(aData) // No hay Deuda
      RETURN 0
   ENDIF

   // Cuando las Tasas de Interes Cambia, hay que hacer el Calculo al estilo cuenta de Ahorros
   // siendo necesario, agregar en el arreglo los dias en donde hubo cambios
   // Si el dia 13 del mes hubo cambio de tasas, el interes se calcula hasta el 13 y luego del dia
   // 14 la nueva tasa.
   // Debe ubicar las nuevas fechas, segun los cambios de tasas

   nMax:=Len(aData)
   dDia:=aData[nMax,3]

   aTasas:=LASTASAS(dDia,dHasta,cField,nTasa)

   FOR I:= 1 TO LEN(aTasas)

      // El arreglo, incrementa una nueva linea con la nueva tasa % de Interes
      IF !(aTasas[I,1]<dDia)
        dFecha:=aTasas[I,1]
//      AADD(aData,{"INT1%",0,dFecha,1})
        AADD(aData,{"%" ,0,dFecha,1})
      ENDIF

   NEXT
   // Ahora debe Buscar todos los Cambios de Tasa
   dDia:=aData[1,3] // Primera Fecha

   FOR I:= 1 TO LEN(aTasas)

     IF !(aTasas[I,1]<dDia)
       nAt:=ASCAN(aData,{|a,n|a[3]=aTasas[I,1]})
     ENDIF

   NEXT

   // Contiene el Remanente de Días Transcurridos
// AADD(aData,{"INT3%",0,dHasta,1})
   AADD(aData,{"%",0,dHasta,1})


   aData:= ASORT(aData,,, { |x, y| x[3] < y[3] }) // Ordena por Fecha

   // 
   // Este ciclo,  ordena y resuelve las fechas con (fin de mes es 30 o 31)?
   //

   FOR I=1 TO LEN(aData)

      dFecha:=aData[i,3]
      nDias :=DAY(dFecha)

      IF nBaseAnual=360 .AND. (nDias>30)

         dFecha:=dFecha-1

      ENDIF

      // Determinar Año biciesto
      IF Month(dFecha)=2 .AND. Day(dFecha)=28 .AND. YEAR(dFecha)/4=INT(YEAR(dFecha)/4)
         dFecha:=FCHFINMES(dFecha) // Final de Febrero 
      ENDIF

      aData[i,3]:=dFecha

   NEXT I

   nMax:=Len(aData)
   dDia:=aData[nMax,3]

   /*
   // Depura redundancia, cada mes debe tener su interes
   */
   aVector:={}

   // Intereses cargados en Valores iniciales

   IF nIntCal>0 .AND. !Empty(aData)

       //            1       2          3    ,4    , 5  , 6        , 7    , 8   ,9
       //            Id     ,Fecha     ,nDias,Cuota,Base, %,interes,Capital, INT ACUM
//     AADD(aVector,{cConIni,aData[1,3],0    ,0     ,0   ,0, nIntCal,0    ,nIntCal  })
       AADD(aVector,{cConIni,aData[1,3],0    ,0     ,0   ,0, 0      ,0    ,0        })


   ENDIF

   FOR I=1 TO LEN(aData)

     dFecha:=aData[I,3]
     nAt   :=0
     // Busca si el mes ya tiene Intereses

     IF "%"$aData[I,1]

        nAt   :=ASCAN(aData,{|a,n| dFecha=a[3] .AND. !("%"$a[1])})

     ENDIF

     IF nAt=0
       nTasa :=BUSCAINT(dFecha,aTasas) 
       //            1          2          3    ,4                    , 5  ,   6 , 7     , 8   ,9
       //            Id        ,Fecha     ,nDias,Cuota                ,Base, %   ,interes,Capital, INT ACUM
       AADD(aVector,{aData[I,1],aData[I,3],0    ,aData[I,2]*aData[I,4],0   ,nTasa,0      ,0   ,0  })
     ENDIF

   NEXT I

   aData  :=ACLONE(aVector)
   aVector:=0

   nCapital:=0

   nInteres:=0
   nCuota  :=0
   nTasa   :=0
   nDias   :=0
   dFechaA :=aData[1,2]

   aData[1,9]:=0

   FOR I=1 TO LEN(aData)

      nCuota  :=aData[I,4] 
      nDias   :=aData[I,2]-dFechaA
      dFechaA :=aData[I,2]

      IF nBaseAnual=360 .AND. (nDias=31 .OR. (nDias>=28 .AND. MONTH(dFechaA)=2))

          // 20/10/2010
          // JN Aqui es interpretativo, si febrero tiene 28 o 29 Dias, y la base es 30
          // Si la base no es 30 entonces sera 28 ??? Cada cliente debe indicar su interpretacion

          nDias:=30

      ENDIF

      nCapital  :=nCapital+aData[I,4]
     
      aData[I,3]:=nDias

      IF I>1
        aData[I,5]:=nCapital
      ENDIF

      // Interes Anual
      nInteres  :=PORCEN(nCapital,aData[I,6])

      IF nDias=30
        nInteres  :=DIV(nInteres,12)
       ELSE
        nInteres  :=DIV(nInteres,nBaseAnual)*nDias
      ENDIF

      // Truncar Decimales
      nInteres    :=INT(nInteres*100)/100 // truca decimales

      // Intereses N411
      IF nIntCal>0 .AND. aData[I,1]=cConIni
         nInteres:=nIntCal
      ENDIF

      aData[I,7]:=nInteres
      //  nCapital  :=nCapital+aData[I,4]

      IF lIndexa  
         nCapital  :=nCapital+nInteres
      ENDIF

      IF nIntCal>0 
         nCapital:=nCapital+nIntCal
         nIntCal :=0
      ENDIF

      aData[I,8]:=nCapital

      nInteresT :=nInteresT+nInteres
      aData[I,9]:=nInteresT


   NEXT I

   aTotal:=ATOTALES(aData)

   oDp:aIntereses:=ACLONE(aData)

RETURN aTotal[7]
// EOF
