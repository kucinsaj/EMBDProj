RS EQU P2.7
RW EQU P2.6
E  EQU P2.5
ORG 000H
MOV DPTR,#LUT
SETB P3.5
CLR P2.0
MOV TMOD,#00100001B
MOV TL1,#00D
ACALL DINT

ACALL TEXT1

MAIN: MOV R1,#16D
      SETB P3.5
      CLR P3.5
      ;ACALL DELAY1
      SETB P3.5
HERE:JB P3.5,HERE
HERE1:JNB P3.5,HERE1
HERE2:JB P3.5,HERE2
LOOP:JNB P3.5,LOOP
     RL A
     MOV R0,A
     SETB TR1
HERE4:JB P3.5,HERE4
      CLR TR1
      MOV A,TL1
      SUBB A,#50D
      MOV A,R0
      JB PSW.7, NEXT
      SETB ACC.0
      SJMP ESC
NEXT:CLR ACC.0
ESC: MOV TL1,#00D
     CLR PSW.7
     DJNZ R1,LOOP
     ACALL DINT
     ACALL TEXT1
     ACALL LINE2
     ACALL TEXT2
     ACALL HMDTY
     ACALL CHECK
     ACALL DELAY2
     LJMP MAIN


DELAY1: MOV TH0,#0B9H
        MOV TL0,#0B0H
        SETB TR0
HERE5: JNB TF0,HERE5
       CLR TR0
       CLR TF0
       RET 

DELAY2:MOV R1,#112D
  BACK:ACALL DELAY1
       DJNZ R1,BACK
       RET
 
 CHECK:MOV A,R0
       MOV B,#65D
       SUBB A,B
       JB PSW.7,NEXT1
       ACALL TEXT3
       SETB P2.0
       SJMP ESC1
  NEXT1:ACALL TEXT4
        CLR P2.0
  ESC1:CLR PSW.7
       RET

 CMD: MOV P0,A
    CLR RS
    CLR RW
    SETB E
    CLR E
    ;ACALL DELAY
    RET

WRITE:

MOV P0,A
    SETB RS
    CLR RW
    SETB E
    CLR E
   ; ACALL DELAY
    RET

HMDTY:MOV A,R0
      MOV B,#10D
      DIV AB
      MOV R2,B
      MOV B,#10D
      DIV AB
      ACALL ASCII
      ACALL WRITE
      MOV A,B
      ACALL ASCII
      ACALL WRITE
      MOV A,R2
      ACALL ASCII
      ACALL WRITE
      MOV A,#'%'
      ACALL WRITE
      RET


TEXT1: MOV A,#'h'
       ACALL WRITE
       MOV A,#'y'
       ACALL WRITE
       MOV A,#'g'
       ACALL WRITE
       MOV A,#'r'
       ACALL WRITE
       MOV A,#'o'
       ACALL WRITE
       MOV A,#'m'
       ACALL WRITE
       MOV A,#'e'
       ACALL WRITE
       MOV A,#'t'
       ACALL WRITE
       MOV A,#'e'
       ACALL WRITE
       MOV A,#'r'
       ACALL WRITE
       RET      
       
TEXT2: MOV A,#'R'
       ACALL WRITE
       MOV A,#'H'
       ACALL WRITE
       MOV A,#' '
       ACALL WRITE
       MOV A,#'='
       ACALL WRITE
       MOV A,#' '
       ACALL WRITE
       RET 
 TEXT3: MOV A,#' '
       ACALL WRITE
       MOV A,#' '
       ACALL WRITE
       MOV A,#'O'
       ACALL WRITE
       MOV A,#'N'
       ACALL WRITE
       RET
 
 TEXT4:MOV A,#' '
       ACALL WRITE
       MOV A,#'O'
       ACALL WRITE
       MOV A,#'F'
       ACALL WRITE
       MOV A,#'F'
       ACALL WRITE
       RET
 
 DINT:MOV A,#38H 
    ACALL CMD
    MOV A,#0FH 
    ACALL CMD
    MOV A,#1H 
    ACALL CMD
    MOV A,#6H
    ACALL CMD
    MOV A,#80H 
    ACALL CMD
    RET
    
LINE2:MOV A,#0C0H 
      ACALL CMD
      RET
          
          
DELAY: CLR E
    CLR RS
    SETB RW
    MOV P0,#0FFH
    SETB E
    MOV A,P0
    JB ACC.7,DELAY
    CLR E
    CLR RW
    RET

ASCII: MOVC A,@A+DPTR
       RET
ENDP:
SJMP ENDP
LUT: DB  48D
     DB  49D
     DB  50D
     DB  51D
     DB  52D
     DB  53D
     DB  54D
     DB  55D
     DB  56D
     DB  57D
    END