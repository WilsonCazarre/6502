DDRA=$0803
DDRB=$0802
PORTA=$0801
PORTB=$0800

EN=%10000000
RW=%01000000
RS=%00100000

  .org $8000
  lda #$ff

  sta DDRA
  sta DDRB

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

  lda #"H"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"e"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"l"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"l"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"o"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #","       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #" "       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"w"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"o"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"r"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"l"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"d"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA

  lda #"!"       
  sta PORTB

  lda #RS        
  sta PORTA
  lda #(EN|RS)
  sta PORTA
  lda #RS        
  sta PORTA
loop:
  jmp loop