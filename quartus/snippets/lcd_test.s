PORTA=$ffff
PORTB=$fffe

EN=%10000000
RW=%01000000
RS=%00100000

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  sta PORTB

  lda #0         ; Clear E/RW/RS
  sta PORTA
  lda #EN
  sta PORTA
  lda #0         ; Clear E/RW/RS
  sta PORTA

  lda #%00000001 ; Set 8-bit mode; 2-line display; 5x8 font
  sta PORTB

  lda #0         ; Clear E/RW/RS
  sta PORTA
  lda #EN
  sta PORTA
  lda #0         ; Clear E/RW/RS
  sta PORTA

  lda #%00001111 ; Display on; Cursor on; Cursor blink
  sta PORTB
  
  lda #0         ; Clear E/RW/RS
  sta PORTA
  lda #EN
  sta PORTA
  lda #0         ; Clear E/RW/RS
  sta PORTA

  lda #%00000110 ; Entry mode set
  sta PORTB

  lda #0         ; Clear E/RW/RS
  sta PORTA
  lda #EN
  sta PORTA
  lda #0         ; Clear E/RW/RS
  sta PORTA

  lda #"H"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"e"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"l"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"l"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"o"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #","       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #" "       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"w"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"o"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"r"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"l"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"d"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA

  lda #"!"       ; Display on; Cursor on; Cursor blink
  sta PORTB

  lda #RS        ; Clear E/RW/RS
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        ; Clear E/RW/RS
  sta PORTA
loop:
  nop
  jmp loop