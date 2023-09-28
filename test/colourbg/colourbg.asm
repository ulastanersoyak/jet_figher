    processor 6502
    include "../macros/vcs.h"
    include "../macros/macro.h"
    seg code
    org $F000 ;define origin of cartridge
start:
    CLEAN_START  ;a macro to safely clean the memory registers
    lda #$1E ;https://en.wikipedia.org/wiki/List_of_video_game_console_palettes
    sta COLUBK ;store a into background colour location - COLUBK is an macro (alias) for the $09
    jmp start ; loop

    org $FFFC 
    .word start ;reset vector (where program starts)
    .word start ;unused macro