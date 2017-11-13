;;;;;;Init Variables;;;;;;
RS EQU P2.7
RW EQU P2.6
E  EQU P2.5
;;;;;;Allocate Memory;;;;;;
TEMP EQU 48H
HUM  EQU 49H
ORG 000H
;;;;;;INIT;;;;;;
INIT:			;Program Initialization
MOV DPTR,#VALUES		;Move DPTR to Values LUT
SETB P3.5			;Set DHT11 Data Port
CLR P2.0			;Clear Output*
MOV TMOD,#00100001B		;Set TMOD
MOV TL1,#00D			;Set Timer Low Byte
ACALL LCD_INIT			;Call LCD Init subroutine
ACALL WELCOME			;Call Welcome Text

MAIN:			;Main Routine
MOV R1,#16D			;Set R1 -> 16D ->10H
SETB P3.5			;Set DHT11 Data Port
CLR P3.5			;CLR DHT11 Data Port
;ACALL DELAY1			;Delay
SETB P3.5			;Set DHT11 Data Port
WAIT1:JB P3.5,$			;Wait till Data Port LOW
WAIT2:JNB P3.5,$		;Wait till Data Port HIGH
WAIT3:JB P3.5,$			;Wait till Data Port LOW

DATALOOP:		;DHT11 Data Colection LOOP
JNB P3.5,DATALOOP		;Wait till Data Port HIGH
RL A				;Rotate ACC Left
MOV R0,A			;Move ACC to Register 0
SETB TR1			;SET Timer 1 RUN
WAIT4:
JB P3.5,$			;Wait till Data Port LOW
CLR TR1				;Stop Timer 1
MOV A,TL1			;Move Timer 1 Low to ACC
SUBB A,#50D			;ACC - 50D[00110010b] If carry is set, bit is low
MOV A,R0			;Move Register 0 to ACC
JB PSW.7, NEXT			;Jump to Next if Carry High
SETB ACC.0			;Set ACC.0 to 1
SJMP DISP			;Jump to DISP

NEXT:
CLR ACC.0			;Clear ACC Bit 0

DISP:
MOV TL1,#00D			;Set Timer 1 Low -> 0H
CLR PSW.7			;Clear carry flag
DJNZ R1,DATALOOP		;Decrement R1, and Jump to DATALOOP if not zero

ACALL LINE2
ACALL TEXT2
ACALL HMDTY
ACALL CHECK
ACALL DELAY2
LJMP MAIN


DELAY1:			;18ms Delay
MOV TH0,#0B9H			;Time high set -> 185D
MOV TL0,#0B0H			;Time low set -> 176D
SETB TR0			;Timer RUN
JNB TF0,$			;Stay Here till TF0 set
CLR TR0				;Clear Timer RUN
CLR TF0				;Clear Timer Overflow
RET

DELAY2:
;MOV R1,#112D
;BACK:
;ACALL DELAY1
;DJNZ R1,BACK
RET

CHECK:
MOV A,R0
MOV B,#65D
SUBB A,B
JB PSW.7,NEXT1
ACALL TEXT3
SETB P2.0
SJMP DISP1

NEXT1:
ACALL TEXT4
CLR P2.0

DISP1:CLR PSW.7
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


WELCOME:

MOV A,#'W'
ACALL WRITE
MOV A,#'e'
ACALL WRITE
MOV A,#'l'
ACALL WRITE
MOV A,#'c'
ACALL WRITE
MOV A,#'o'
ACALL WRITE
MOV A,#'m'
ACALL WRITE
MOV A,#'e'
ACALL WRITE
MOV A,#' '
ACALL WRITE
MOV A,#' '
ACALL WRITE
MOV A,#' '
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

LCD_INIT:		;Initializtion for the LCD
MOV A,#38H			;Set Function SET
LCALL SETD			;SET
MOV A,#0FH			;Set Display/Cursor Settings
LCALL SETD			;SET
MOV A,#1H 			;Clear Display
LCALL SETD			;SET
MOV A,#6H			;Entry Mode Set
LCALL SETD			;SET
MOV A,#80H			;Set DDRAM Address
LCALL SETD			;SET
RET

LINE2:			;Shifts Display to Line 2
MOV A,#0C0H
LCALL SETD			;SET
RET

DELAY:			;LCD Delay
CLR E				;Clear Enable
CLR RS				;Clear RS
SETB RW				;Clear R/W
MOV P0,#0FFH			;Set P0 -> 1111 1111b
SETB E				;Set Enable
MOV A,P0			;Set ACC to P0
JB ACC.7,DELAY			;Jump to Delay if ACC.7 set
CLR E				;Clear Enable
CLR RW				;Clear R/W
RET

ASCII:
MOVC A,@A+DPTR
RET
ENDP:
SJMP ENDP

VALUES:
DB  48D
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