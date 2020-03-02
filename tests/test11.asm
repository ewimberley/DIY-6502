  define  sysRandom  $fe ; an address
  define  a_dozen    $0c ; a constant
 
  LDA sysRandom  ; equivalent to "LDA $fe"

  LDX #a_dozen   ; equivalent to "LDX #$0c"
