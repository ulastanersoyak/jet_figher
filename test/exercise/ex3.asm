    processor 6502
    seg code
    org $F000
start:
    lda #15
    tax
    tay
    txa
    tya
    ldx #6
    txa
    tay
    org $FFFC
    .word start
    .word start