    processor 6502
    seg code
    org $F000
start:
    lda #$A
    ldx #%1010
    sta $80
    stx $81
    lda #10
    clc
    adc $80
    adc $81
    sta $82
    org $FFFC
    .word start
    .word start