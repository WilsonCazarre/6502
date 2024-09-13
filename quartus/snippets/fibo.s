DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800

N1=$00
N2=$01
R=$02

  .org $8000
  
  lda #$00 ; 0 - Input / 1 - Output
  sta DDRB

  lda #$ff
  sta DDRA

restart:
  lda #0
  sta N1
  lda #$01
  sta N2
  sta R
loop:
  lda R
  cmp PORTB
  bcs restart
  sta PORTA
  lda N1
  clc
  adc N2
  sta R
  lda N2
  sta N1
  lda R
  sta N2
  jmp loop



