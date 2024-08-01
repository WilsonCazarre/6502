PORTA=$ffff
PORTB=$fffe

EN=%10000000
RW=%01000000
RS=%00100000

N_1=$01ff
N_2=$01fe


  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  sta PORTB

  lda #0         ; Clear E/RW/RS
  sta PORTA
  lda #EN
  sta PORTA
  lda #0         ; Clear E/RW/RS
  sta PORTA

  lda #%00000001 ; Clear display
  sta PORTB

  lda #0         ; Clear E/RW/RS
  sta PORTA
  lda #EN
  sta PORTA
  lda #0         ; Clear E/RW/RS
  sta PORTA

  lda #1
  sta N_1
  sta N_2
loop:
  lda N_1
  adc N_2
  ldx N_1
  sta N_1
  sta PORTA
  stx N_2
  jmp loop


loop:
  lda #2
  bcc -2