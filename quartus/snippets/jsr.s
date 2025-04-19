DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800

  .org $8000
  lda #$ff

  sta DDRA
  sta DDRB
  
  lda #$16 ; load low byte
  sta $00

  

  lda #$05
  ldx #$2

  lda #$40
  sta $16, x 
  
  adc ($00, x)
exit:
  jmp exit
