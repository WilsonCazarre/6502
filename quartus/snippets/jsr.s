DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800

  .org $8000
  lda #$ff
  ; 1 = output, 0 = input
  sta DDRA
  sta DDRB
  
  lda #$16 ; load low byte
  sta $02

  ldx #$2
  lda #$41
  sta $16

  lda #$05

  adc ($00, x)
exit:
  jmp exit

nmi:
  lda #$50
  rti

  .org $fffa
  .word nmi
