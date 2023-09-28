    processor 6502
    seg code
    org $F000
start:
    lda #$A
    ldx #%11111111
    sta $80
    stx $81

    org $FFFC
    .word start
    .word start