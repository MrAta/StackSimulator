*-----------------------------------------------------------
* Title      : Ata Stack Simulator.
* Written by : Mr.Ata Fatahi Barzi 
* Date       : 19 , Jan , 2014
* Description: This program simulates Stack Data Structure. which contains two command button , one for Push data into Stack and
*               another for pop data from Stack.                                   
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    lea  $10000 , a6
    movea.L a6 , a3
    movea.L a3 , a4
    move.l #450 , d6
    * Initialize Trap #15 vector
    move.l  #versionTrap,$BC    ; Trap #15
    move.b  #4,d1               ; request Sim68K version number
    move.b  #32,d0              ; task 32 Simulator Environment.
    trap    #15
    * If Sim68K is new enough to have task 32 then the trap will return to here.
    * D1.L will contain the version number or be unchanged on versions that do not
    * understand the #4 version number request.
    * If the simulator is too old to have task 32 then the Trap will be
    * sent to versionTrap.
    if.l d1 <lo> #$040000 then.s    ; if version prior to 4.0.0
versionTrap
        move.b  #14,d0              ; display text
        lea     oldVerMsg,a1
        trap    #15
        MOVE.B  #9,D0
        TRAP    #15                 ; Halt Simulator
    endi

; Initialize IRQ vectors 
    move.l  #mouseDownIRQ,$64       ; IRQ1
    andi.w  #$00,SR                 ; put CPU in User mode 

    move.b  #60,d0                  ; set mouse IRQ
    move.w  #$0101,d1               ; IRQ1 for mouse down
    trap    #15

    move.b  #32,d0                  ; trap task 32 Hardware/Simulator control
    move.b  #5,d1                   ; d1.b = 5, enable exception processing
    trap    #15
    
    bsr     init
    
loop    NOP
        nop
        bra loop
       

mouseDownIRQ
    bsr init
    move.b  #61,d0                  ; read mouse
    move.b  #2,d1                   ; mouse down state
    trap    #15
    bsr     mouseData
    rte
                
mouseData
    move.l  d0,d4                   ; save mouse buttons
    move.l  d1,d3                   ; save mouse Y
    and.l   #$0000FFFF,d1           ; remove Y from D1  ,d1 = x
    and.l #$FFFF0000 , d3
    swap d3
   if.l d1 <ge> #20 then.s
        if.l d1 <le> #100 then.s
            if.l d3 <ge> #50 then.s
                if.l d3 <le> #100 then.s
                
                    bsr pushAction
                endi
            endi
        endi
    endi
    if.l d1 <ge> #120 then.s
        if.l d1 <le> #200 then.s
            if.l d3 <ge> #50 then.s
                if.l d3 <le> #100 then.s
                    bsr popAction
                endi
            endi
        endi
    endi  
;    movem.l (a7)+,d0-d4/a1
    rts 

pushAction
     
    MOVE #$FF00 , D1
    MOVE #11 , D0
    TRAP #15
    
    MOVE.L #$00FF00FF , D1
    MOVE #81 , D0
    TRAP #15            ; fill color with PINK
    
    MOVE #0 , D1
    MOVE #0 , D2
    move #89 ,d0
    trap #15            ; background color with PINK
    
    
        
    lea entermsg  , a1
    move #14 , d0
    trap #15
    
    move #4 , d0
    trap #15
    
     move.l d1 , -(a6)
  
    MOVE #$FF00 , D1
    MOVE #11 , D0
    TRAP #15
 
    bsr showPushData
    
   
 
    rts
    
popAction
    cmpa.l a6 , a3
    beq equalAddress
    bsr init
    
    bsr showPopData
    rts
    
    
    ;///////////////init///////////////////
init
    MOVE.L #$00FF00FF , D1
    MOVE #81 , D0
    TRAP #15            ; fill color with ?????
    
    MOVE #0 , D1
    MOVE #0 , D2
    move #89 ,d0
    trap #15            ; background color with ?????
    ;..............................................
    MOVE.L #$00FF00FF , D1
    MOVE #81 , D0
    TRAP #15            ; set pen color to ...
    
    MOVE #0 , D1       
    MOVE #30 , D2
    MOVE #640 , D3
    MOVE #30 , D4
    MOVE #87 , D0
    TRAP #15            ;TOP rectangle
    
    MOVE.L #$00000000  , D1
    MOVE #80 , D0
    TRAP #15            ; set pen color  black.
    
    MOVE #250 , D1
    MOVE #10 , D2
    LEA ata , A1
    MOVE #95 , D0
    TRAP #15            ; writ'Ata' on rectangle
    
    ;...............................................
    
    MOVE.L #$000000FF , D1
    MOVE #81 , D0
    TRAP #15            ; set pen color to red
    
    MOVE #20 , D1       
    MOVE #50 , D2
    MOVE #100 , D3
    MOVE #100 , D4
    MOVE #87 , D0
    TRAP #15            ; rectangle for push button
    
    MOVE.L #$00000000  , D1
    MOVE #80 , D0
    TRAP #15            ; set pen color  black.
    
    MOVE #43 , D1
    MOVE #70 , D2
    LEA push , A1
    MOVE #95 , D0
    TRAP #15            ; write 'push' on rectangle
    
    
    
    MOVE.L #$00FF0000 , D1
    MOVE #81 , D0
    TRAP #15            ; set pen color to green
    
    MOVE #120 , D1
    MOVE #50 , D2
    MOVE #200 , D3
    MOVE #100 , D4
    MOVE #87 , D0
    TRAP #15            ; rectangle for pop button.

    MOVE.L #$00000000  , D1
    MOVE #80 , D0
    TRAP #15            ; set pen color  black.
    
    MOVE #143 , D1
    MOVE #70 , D2
    LEA pop , A1
    MOVE #95  , D0
    TRAP #15            ; write 'pop' on rectangle  
    ;////
    MOVE.L #$00FFFFFF , D1
    MOVE #81  , D0
    TRAP #15            ; set fill color to WHITE
    
    MOVE #350 , D1       
    MOVE #155 , D2
    MOVE #450 , D3
    MOVE #455 , D4
    MOVE #87  , D0
    TRAP #15            ; rectangle for Stack.
      ;/////////cells
    move #350 , d1
    move #185 , d2
    move #450 , d3
    move #185 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #218 , d2
    move #450 , d3
    move #218 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #245 , d2
    move #450 , d3
    move #245 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #280 , d2
    move #450 , d3
    move #280 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #307 , d2
    move #450 , d3
    move #307 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #335 , d2
    move #450 , d3
    move #335 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #365 , d2
    move #450 , d3
    move #365 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #395 , d2
    move #450 , d3
    move #395 , d4
    move #84 , d0
    trap #15
    ;///////////
    move #350 , d1
    move #425 , d2
    move #450 , d3
    move #425 , d4
    move #84 , d0
    trap #15
    ;/////////// end of drawing cells in stack rectangle.
    
     MOVE.L #$00FF00FF , D1
    MOVE #81 , D0
    TRAP #15            ; set fill color to WHITE
     MOVE.L #$0 , D1
    MOVE #80 , D0
    TRAP #15            ; set fill color to WHITE
    
    move #250 , d1
    move #300 , d2
    LEA  stackData , a1
    move #95 , d0
    trap #15    ; write 'Stack Data' beside Stack.
    ;//////////////
    MOVE.L #$00FFFFFF , D1
    MOVE #81 , D0
    TRAP #15            ; set fill color to WHITE
    ;///////////////////
    MOVE #130 , D1       
    MOVE #437 , D2
    MOVE #230 , D3
    MOVE #470 , D4
    MOVE #87 , D0
    TRAP #15            ; rectangle for show poped value.
    ;///////////////////////
    MOVE.L #$00FF00FF , D1
    MOVE #81 , D0
    TRAP #15            ; set fill color to WHITE
     MOVE.L #$0 , D1
    MOVE #80 , D0
    TRAP #15            ; set fill color to WHITE
    ;///////////////
    move #20 , d1
    move #450 , d2
    LEA  popedValue , a1
    move #95 , d0
    trap #15
    rts             ;  write 'poped value' beseide its rectangle
showPushData 
     bsr init
    MOVE.L #$000000FF , D1
    MOVE #81 , D0
    TRAP #15        ; setpen color to black.

    movea.l a3 , a4
     
showloop
    
    move   offsetShow , d1
    move   #11 , d0
    trap   #15
    
    CLR D1
    
    move.l -(a4) , d1
    move    #3 , d0
    trap    #15
    sub   #2 , offsetShow
    cmpa.l a4 , a6
    bne showloop
    move #$311D ,offsetShow
    
    rts
    
showPopData
    bsr init
    
    MOVE.L #$00FF0000 , D1
    MOVE #81, D0
    TRAP #15

    movea.l a3 , a4
    add  #4, a6
    cmpa.l a6 , a3
    beq oneValue

showloop2
    move   offsetShow , d1
    move   #11 , d0
    trap   #15
    
    CLR D1
    
    move.l -(a4) , d1
    move    #3 , d0
    trap    #15
    
    sub   #2 , offsetShow
    cmpa.l a4 , a6
    bne showloop2
    move #$311D ,offsetShow
    move.l -(a4) , d5
    bsr showPopValue
    
    RTS
    
showPopValue

    move   #$151E , d1
    move   #11 , d0
    trap   #15
    
    MOVE.L D5 , D1
    MOVE #3  ,D0
    TRAP #15
    
    RTS
        
equalAddress
    MOVE.L #$00FF0000 , D1
    MOVE #81 , D0
    TRAP #15        ; setpen color to black.

    move #145 , d1
    move #450 , d2
    LEA  noVal , a1
    move #95 , d0
    trap #15
    
    rts
oneValue   
    
    move   #$151E , d1
    move   #11 , d0
    trap   #15
    
    MOVE.L -(a4) , D1
    MOVE #3  ,D0
    TRAP #15
    RTS
fullData
    MOVE.L #$000000FF , D1
    MOVE #81 , D0
    TRAP #15        ; setpen color to black.

    move #145 , d1
    move #250 , d2
    LEA  fullD , a1
    move #95 , d0
    trap #15
    
    rts

    SIMHALT             ; halt simulator

* Put variables and constants here
nd             DC.W           0
offsetShow      DC.W  $311D
push            DC.B 'Push' , 0
pop             DC.B 'Pop' , 0
ata             DC.B 'Ata Stack Simuator' , 0
entermsg        DC.B 'Push a (.L) bumber : ' , 0
stackData       DC.B 'Stack Data :' , 0
popedValue      DC.B 'Poped Value :'  , 0
oldVerMsg       DC.B    'This program requires Sim68K version 4.0.0 or later.',0
noVal           DC.B 'no value' , 0
fullD           DC.B 'Erorr : Stack OverFlow!' , 0

    END    START        ; last line of source
                








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
