    processor 6502
    seg code
    org $F000
start:
    lda #$82
    ldx #82
    ldy $82

    org $FFFC
    .word start 
    .word start 