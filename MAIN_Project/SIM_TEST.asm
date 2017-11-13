;;;;;;;;;; Initialise Values ;;;;;;;;;;;;;;;;;
Timer_CTR .EQU  33H
UPPER	.EQU	40H
LOWER	.EQU	41H
ASTOR	.EQU	42H
CLR	P2.6	; Clear R/W
CLR	P2.7	; Clear RS
CLR	P2.5	; Clear Enable


INITIALIZE_LCD:
;MOV     TIMER_CTR, #3H ; Make timer loop  times (3 x 10ms = 30ms)
;LCALL	TIMERLOOP ; 30ms timer
MOV	P0, #38H
LCALL ENB
;LCALL	USTIMER
MOV	P0, #0FH
LCALL ENB
;LCALL	USTIMER	; 50us timer
MOV	P0, #1H
LCALL ENB
;LCALL	USTIMER ; 1.7ms timer
MOV	P0, #6H
LCALL ENB
;LCALL	USTIMER
MOV	P0, #80H
LCALL ENB
;LCALL TIMER

LCALL CLEAR



;LCALL	TIMER
;SETB 	P2.7
;LCALL	USTIMER
TOP:
MOV A, #00110000b
LCALL WRITE
MOV A, #00110000b
LCALL WRITE

LCALL ENDIT


SJMP	TOP

TIMERLOOP:
LCALL   TIMER                   ; 39 us delay
DJNZ    Timer_CTR, TIMERLOOP    ; loop if Greater Than 0
MOV     TIMER_CTR, #1H 		; Reset timer count to 1
RET

TIMER:                      ; 10 ms timer
MOV     TMOD,#01h               ; set timer mode
CLR     TF0                     ; Clear timer done
CLR     TR0                     ; Clear time run
MOV     TH0, #0D8H              ; High byte of 55,535
MOV     TL0, #0EFH              ; Low byte of 55,535;
;MOV 	TH0, #0FFH	;Test Num	
; 	TL0, #0FAH	;Test Num
SETB    TR0                     ; Start the timer
JNB     TF0,$                   ; Stay here until TF0 is set
RET                             ; End timer sub-routine


USTIMER:                      ; 39 us timer
MOV     TMOD,#01h               ; set timer mode
CLR     TF0                     ; Clear timer done
CLR     TR0                     ; Clear time run
MOV     TH0, #0F0H              ; High byte of 65,496
MOV     TL0, #0CDH              ; Low byte of 65,496
;MOV 	TH0, #0FFH	;Test Num	
;MOV 	TL0, #0FAH	;Test Num
SETB    TR0                     ; Start the timer
JNB     TF0,$                   ; Stay here until TF0 is set
RET                             ; End timer sub-routine

fTIMER:                      ; 39 us timer
MOV     TMOD,#01h               ; set timer mode
CLR     TF0                     ; Clear timer done
CLR     TR0                     ; Clear time run
MOV     TH0, #0F9H              ; High byte of 65,496
MOV     TL0, #05BH              ; Low byte of 65,496
;MOV 	TH0, #0FFH	;Test Num	
;MOV 	TL0, #0FAH	;Test Num
SETB    TR0                     ; Start the timer
JNB     TF0,$                   ; Stay here until TF0 is set
RET                             ; End timer sub-routine
ENB:
setb p2.5
nop
clr p2.5
RET

WRITE:
SETB    P2.7
NOP
SETB	P2.5
NOP
ClR	P2.5
NOP
CLR	P2.7
;LCALL TIMER
RET
HOME:
MOV	P0, #02H
LCALL ENB
RET
CLEAR:
MOV 	A, #0H  		; Re-Start accumulator with value 0
MOV 	ASTOR, #00H
MOV	UPPER, #00H		;0 UPPER
MOV 	LOWER, #00H		;0 LOWER
RET

ENDIT:
SJMP ENDIT

.END