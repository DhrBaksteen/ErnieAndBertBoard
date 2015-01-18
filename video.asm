org 0x0000

w			equ	0x00
f			equ	0x01
status		equ 0x03
portA		equ 0x05
portB		equ	0x06

pinSync		equ	0x00
pinVideo	equ	0x01
pinHReset	equ	0x07
pinH512		equ	0x06
pinVReset	equ	0x05
pinVClock	equ	0x04
pinDebug	equ	0x03

lineNum		equ	0x0C
counter1	equ	0x0D
counter2	equ	0x0E

init:
	bsf		status, 5
	movlw	0x00
	movwf	portA
	movlw	0x40
	movwf	portB
	bcf		status, 5
	clrf	portA
	clrf	portB

video:
	call	vSync

emptyTop:
	movlw	0x17
	movwf	lineNum
	movlw	0x2A
	movwf	counter1
emptyTop_1:
	decfsz	counter1
	goto	emptyTop_1
	nop
emptyTop_2:
	bcf		portA, pinSync
	movlw	0x02
	movwf	counter1
emptyTop_3:
	decfsz	counter1
	goto	emptyTop_3
	nop
	nop
	bsf		portA, pinSync
	movlw	0x30
	movwf	counter1
emptyTop_4:	
	decfsz	counter1
	goto	emptyTop_4
	nop
	decfsz	lineNum
	goto	emptyTop_2
	nop

mainVideo:
	bcf		portA, pinSync
	clrf	lineNum					; Set number of video lines to 256
	bsf		portB, pinVReset		; Reset vertical counter
	bcf		portB, pinVReset

videoLine:
	movlw	0x01
	movwf	counter1
lineHSync_1:
	decfsz	counter1
	goto	lineHSync_1
	bcf		portB, pinVClock		; Send vertical clock pulse
	bsf		portB, pinVClock
	bsf		portA, pinSync
	
	nop
	nop
	nop

	bsf		portB, pinHReset		; Reset H counter
	bcf		portB, pinHReset

	movlw	0x03					; Wait for hSync
	movwf	counter1
lineHSync_2:
	decfsz	counter1
	goto	lineHSync_2
	nop
	nop

	movlw	0x12					; Set line delay
	movwf	counter1
	bsf		portA, pinVideo			; Enable video
waitLine:
	bsf		portB, pinDebug
	nop
	nop
	bcf		portB, pinDebug
	decfsz	counter1				; Wait for line end
	goto	waitLine
	nop
	nop
	nop

	bcf		portA, pinVideo			; Disable video output
	bcf		portA, pinSync			; Start hSync

	decfsz	lineNum					; Loop until 256 lines are done
	goto	videoLine
	movlw	0x17					; 41 empty lines follow
	movwf	lineNum
	nop
	nop
	nop
	nop
	nop

emptyBottom:
	bsf		portA, pinSync
	movlw	0x31
	movwf	counter1
emptyBottom_1:
	decfsz	counter1
	goto	emptyBottom_1
	nop
	bcf		portA, pinSync
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz	lineNum
	goto	emptyBottom
	nop
	bsf		portA, pinSync
	movlw	0x2F
	movwf	counter1
emptyBottom_2:
	decfsz	counter1
	goto	emptyBottom_2
	nop
	goto	video


vSync:
	movlw	0x06
	movwf	counter2
vSync_1:
	bcf		portA, pinSync
	nop
	nop
	nop
	nop
	bsf		portA, pinSync
	movlw	0x17
	movwf	counter1
vSync_2:
	decfsz	counter1
	goto	vSync_2
	movlw	0x05				; Prepare next field counter in case we need it
	decfsz	counter2
	goto	vSync_1
	movwf	counter2			; Update field counter :)

vSync_3:
	bcf		portA, pinSync
	movlw	0x18
	movwf	counter1
vSync_4:
	decfsz	counter1
	goto	vSync_4
	nop
	bsf		portA, pinSync
	movlw	0x05
	decfsz	counter2
	goto	vSync_3
	movwf	counter2	

vSync_5:
	bcf		portA, pinSync
	nop
	nop
	nop
	nop	
	bsf		portA, pinSync
	movlw	0x17
	movwf	counter1
vSync_6:
	decfsz	counter1
	goto	vSync_6
	nop
	decfsz	counter2
	goto	vSync_5
	nop

; Perform a horizontal sync
; You return from here at the exact moment the next line of video starts!
hSync:
	bcf		portA, pinSync
	movlw	0x02
	movwf	counter1
hSync_1:
	decfsz	counter1
	goto	hSync_1
	nop
	nop
	bsf		portA, pinSync
	movlw	0x05
	movwf	counter1
hSync_2:
	decfsz	counter1
	goto	hSync_2
	nop
	return

end