;;;;;;Assign Port Names;;;;;;
RS EQU P2.7
RW EQU P2.6
E  EQU P2.5
;;;;;;Init Variables;;;;;;
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
LCALL LCD_INIT			;Call LCD Init subroutine
LCALL WELCOME			;Call Welcome Text

MAIN:			;Main Routine
MOV R1,#8D			;Set R1 -> 8D ->08H
SETB P3.5			;Set DHT11 Data Port
CLR P3.5			;Clear DHT11 Data Port
;LCALL DELAY1			;Delay
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
JB PSW.7, LOW			;Jump to LOW if Carry High
SETB ACC.0			;Set ACC.0 to 1 -- High Bit Recieved
SJMP DISP			;Jump to DISP

LOW:
CLR ACC.0			;Clear ACC Bit 0 -- Low Bit Recieved

DISP:
MOV TL1,#00D			;Set Timer 1 Low -> 0H
CLR PSW.7			;Clear carry flag
DJNZ R1,DATALOOP		;Decrement R1, and Jump to DATALOOP if not zero
JB PSW.6, AGAIN			;Jump if Decimal skip bit = 1
JB PSW.5, SAVETEMP		;If F0 is 1, Save Temp
SAVEHUM:
MOV HUM, A			;Store Accumulator Value in HUM
SETB PSW.6			;Set Skip Decimal Data
AGAIN:
SETB PSW.5			;Set Directing bit   0 = HUM   1 = TEMP
MOV R1, #08D
LJMP DATALOOP
SAVETEMP:
MOV TEMP, A			;Store Accumulator Value in TEMP
CLR PSW.5			;Clear Directing bit   0 = HUM   1 = TEMP
CLR PSW.6			;Clear Decimal Skip bit

DIAGNOSTIC_DISPLAY:	;Displays Full Diagnostic screen with updating values
LCALL LINE2
LCALL TEXT2
LCALL HMDTY
LCALL CHECK
LCALL DELAY2
LJMP MAIN


DELAY1:			;18ms Delay
MOV TH0,#0B9H			;Time high set -> 185D
MOV TL0,#0B0H			;Time low set -> 176D
SETB TR0			;Timer RUN
JNB TF0,$			;Stay Here till TF0 set
CLR TR0				;Clear Timer RUN
CLR TF0				;Clear Timer Overflow
RET

DELAY2:			;******Change to timer_counter
;MOV R1,#112D
;BACK:
;LCALL DELAY1
;DJNZ R1,BACK
RET

CHECK:			;Basic value check
MOV A,R0
MOV B,#65D
SUBB A,B
JB PSW.7,NEXT1
LCALL TEXT3
SETB P2.0
SJMP DISP1

NEXT1:
LCALL TEXT4
CLR P2.0

DISP1:
CLR PSW.7
RET

SETD:
MOV P0,A
CLR RS
CLR RW
SETB E
CLR E
;LCALL DELAY
RET

WRITE:

MOV P0,A
SETB RS
CLR RW
SETB E
CLR E
;LCALL DELAY
RET

HMDTY:			;Assembles Humidity reading percentage
MOV A,HUM			;Store HUM Value in ACC
MOV B,#10D			;Store 10D in B ACC
DIV AB				;Divide ACC by B ACC
MOV R3,B			;Store remainder in register 3
MOV B,#10D			;Store 10D in B ACC
DIV AB				;Divide ACC by B ACC
LCALL ASCII			;Convert to ASCII
LCALL WRITE			;Write to Display
MOV A,B				;Store remainder in ACC
LCALL ASCII			;Convert to ASCII
LCALL WRITE			;Write to Display
MOV A,R3			;Store register 3 in ACC
LCALL ASCII			;Convert to ASCII
LCALL WRITE			;Write to Display
MOV A,#'%'			;Store Percent symbol in ACC
LCALL WRITE			;Write to Display
RET

TEMPERATURE:		;Assembles Temperature reading
MOV A,TEMP			;Store TEMP Value in ACC
MOV B,#10D			;Store 10D in B ACC
DIV AB				;Divide ACC by B ACC
MOV R3,B			;Store remainder in register 3
MOV B,#10D			;Store 10D in B ACC
DIV AB				;Divide ACC by B ACC
LCALL ASCII			;Convert to ASCII
LCALL WRITE			;Write to Display
MOV A,B				;Store remainder in ACC
LCALL ASCII			;Convert to ASCII
LCALL WRITE			;Write to Display
MOV A,R3			;Store register 3 in ACC
LCALL ASCII			;Convert to ASCII
LCALL WRITE			;Write to Display
MOV A,#11011111b		;Store Degree symbol in ACC
LCALL WRITE			;Write to Display
MOV A,#'C'			;Store 'C' in ACC
LCALL WRITE
RET

WELCOME:
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#'W'
LCALL WRITE
MOV A,#'e'
LCALL WRITE
MOV A,#'l'
LCALL WRITE
MOV A,#'c'
LCALL WRITE
MOV A,#'o'
LCALL WRITE
MOV A,#'m'
LCALL WRITE
MOV A,#'e'
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
RET

TEXT2:			;Writes 'RH = ' to Display
MOV A,#'R'
LCALL WRITE
MOV A,#'H'
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#'='
LCALL WRITE
MOV A,#' '
LCALL WRITE
RET 
TEXT3: 
MOV A,#' '
LCALL WRITE
MOV A,#' '
LCALL WRITE
MOV A,#'O'
LCALL WRITE
MOV A,#'N'
LCALL WRITE
RET
 
 TEXT4:
MOV A,#' '
LCALL WRITE
MOV A,#'O'
LCALL WRITE
MOV A,#'F'
LCALL WRITE
MOV A,#'F'
LCALL WRITE
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