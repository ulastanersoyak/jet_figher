    processor 6502

    seg code
    org $F000 ;define code origin at $F000
start:
    sei ;disable interrupts
    cld ;clear BCD decimal math mode
    ldx #$FF ;load x register with #$FF
    txs ;transfers x register to a stack pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;clear the page zero region ($00 to $FF) 
;meaning the entire RAM and also TIA registers 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0 ;A=0
    ldx #$FF ;X=#$FF
memloop:
    dex ;X--
    sta $0,X ;store the value of a inside the mem address of x+$0
    bne memloop ;loop back to memloop if X != 0 (z flag is set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;fill the ROM size to exactly 4KB                                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word start  ;reset vector at $FFFC (where program starts)
    .word start  ;interrupt vector at $FFFE (unused since atari doesnt have interrupts but its a requirement)