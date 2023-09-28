    processor 6502
    seg code
    org $F000
start:
    lda #1
    ldx #2
    ldy #3
    inx
    iny
    adc #1
    sbc #1
    dey
    dex
    org $FFFC
    .word start
    .word start
