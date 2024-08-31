DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800
  
  .org $8000

  lda #$ff 
  sta DDRA ; Set PORTA as output

  ldx #00 ; x = 0
loop:
  stx $00 ; ram[0] = x
  lda $00 ; a = ram[0]
  sta PORTA ; print a
  inx
  jmp loop