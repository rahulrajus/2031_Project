; This program uses the SLOW_SRAM device to write and read some
;  values from the DE2 external SRAM chip. It reads a value from
;  the switches, and stores THAT value at THAT address. Then, it
;  runs an endless loop where it reads the switches and displays 
;  the value at that address on the left seven-segment displays.
;  If DE2 is powered off, then on, then this program is run with
;  the switches set for 0000, then it will display 0000, but if
;  the switches are moved to other values, it will display the 
;  random data still at those locations.
;  Resetting the DE2 and running again, without powering off,
;  allows the user to write one new value each time.
;  Limitations:  
;   - cannot specify an address over 16-bits
;   - not a particularly good way to test a lot of locations
;   - uses the SLOW_SRAM device, taking 9-12 instructions for
;       a single read or write
; This program includes...
; - Several useful subroutines (ATAN2, Neg, Abs, mult, div).
; - Some useful constants (masks, numbers, robot stuff, etc.)

ORG 0

;***************************************************************
;* Main code
;***************************************************************
Main:
	; Set the address to 5
	LOADI   0
	OUT		SRAM_ADHI
	LOADI   5
	OUT		SRAM_ADLOW
	; Write a value
	LOADI   10
	OUT		SRAM_DATA
	; Set the address to 6
	LOADI   6
	OUT		SRAM_ADLOW
	; Write a value
	LOADI   11
	OUT		SRAM_DATA
	; Set the address to 7
	LOADI   7
	OUT		SRAM_ADLOW
	; Write a value
	LOADI   12
	OUT		SRAM_DATA


	; Read a value from address 0x105
	LOADI   &H105
	OUT		SRAM_ADLOW
	IN      SRAM_DATA   ; Data will be in AC after this
	
	; Read the previously-written values from addresses 5-8
	LOADI   5
	OUT		SRAM_ADLOW
	IN      SRAM_DATA   ; Data will be in AC after this
	LOADI   6
	OUT		SRAM_ADLOW
	IN      SRAM_DATA   ; Data will be in AC after this
	LOADI   7
	OUT		SRAM_ADLOW
	IN      SRAM_DATA   ; Data will be in AC after this


	
Done:

	JUMP	Done

;***************************************************************
;* Variables
;***************************************************************
Temp:     DW 0 ; "Temp" is not a great name, but can be useful

;***************************************************************
;* Constants
;* (though there is nothing stopping you from writing to these)
;***************************************************************
NegOne:   DW -1
Zero:     DW 0
One:      DW 1
Two:      DW 2
Three:    DW 3
Four:     DW 4
Five:     DW 5
Six:      DW 6
Seven:    DW 7
Eight:    DW 8
Nine:     DW 9
Ten:      DW 10

; Some bit masks.
; Masks of multiple bits can be constructed by ORing these
; 1-bit masks together.
Mask0:    DW &B00000001
Mask1:    DW &B00000010
Mask2:    DW &B00000100
Mask3:    DW &B00001000
Mask4:    DW &B00010000
Mask5:    DW &B00100000
Mask6:    DW &B01000000
Mask7:    DW &B10000000
LowByte:  DW &HFF      ; binary 00000000 1111111
LowNibl:  DW &HF       ; 0000 0000 0000 1111

; some useful movement values
OneMeter: DW 961       ; ~1m in 1.04mm units
HalfMeter: DW 481      ; ~0.5m in 1.04mm units
Ft2:      DW 586       ; ~2ft in 1.04mm units
Ft3:      DW 879
Ft4:      DW 1172
Deg90:    DW 90        ; 90 degrees in odometer units
Deg180:   DW 180       ; 180
Deg270:   DW 270       ; 270
Deg360:   DW 360       ; can never actually happen; for math only
FSlow:    DW 100       ; 100 is about the lowest velocity value that will move
RSlow:    DW -100
FMid:     DW 350       ; 350 is a medium speed
RMid:     DW -350
FFast:    DW 500       ; 500 is almost max speed (511 is max)
RFast:    DW -500

MinBatt:  DW 140       ; 14.0V - minimum safe battery voltage
I2CWCmd:  DW &H1190    ; write one i2c byte, read one byte, addr 0x90
I2CRCmd:  DW &H0190    ; write nothing, read one byte, addr 0x90

DataArray:
	DW 0
;***************************************************************
;* IO address space map
;***************************************************************
SWITCHES: EQU &H00  ; slide switches
LEDS:     EQU &H01  ; red LEDs
TIMER:    EQU &H02  ; timer, usually running at 10 Hz
XIO:      EQU &H03  ; pushbuttons and some misc. inputs
SSEG1:    EQU &H04  ; seven-segment display (4-digits only)
SSEG2:    EQU &H05  ; seven-segment display (4-digits only)
LCD:      EQU &H06  ; primitive 4-digit LCD display
XLEDS:    EQU &H07  ; Green LEDs (and Red LED16+17)
BEEP:     EQU &H0A  ; Control the beep
CTIMER:   EQU &H0C  ; Configurable timer for interrupts
LPOS:     EQU &H80  ; left wheel encoder position (read only)
LVEL:     EQU &H82  ; current left wheel velocity (read only)
LVELCMD:  EQU &H83  ; left wheel velocity command (write only)
RPOS:     EQU &H88  ; same values for right wheel...
RVEL:     EQU &H8A  ; ...
RVELCMD:  EQU &H8B  ; ...
I2C_CMD:  EQU &H90  ; I2C module's CMD register,
I2C_DATA: EQU &H91  ; ... DATA register,
I2C_RDY:  EQU &H92  ; ... and BUSY register
UART_DAT: EQU &H98  ; UART data
UART_RDY: EQU &H99  ; UART status
SONAR:    EQU &HA0  ; base address for more than 16 registers....
DIST0:    EQU &HA8  ; the eight sonar distance readings
DIST1:    EQU &HA9  ; ...
DIST2:    EQU &HAA  ; ...
DIST3:    EQU &HAB  ; ...
DIST4:    EQU &HAC  ; ...
DIST5:    EQU &HAD  ; ...
DIST6:    EQU &HAE  ; ...
DIST7:    EQU &HAF  ; ...
SONALARM: EQU &HB0  ; Write alarm distance; read alarm register
SONARINT: EQU &HB1  ; Write mask for sonar interrupts
SONAREN:  EQU &HB2  ; register to control which sonars are enabled
XPOS:     EQU &HC0  ; Current X-position (read only)
YPOS:     EQU &HC1  ; Y-position
THETA:    EQU &HC2  ; Current rotational position of robot (0-359)
RESETPOS: EQU &HC3  ; write anything here to reset odometry to 0
RIN:      EQU &HC8
LIN:      EQU &HC9
IR_HI:    EQU &HD0  ; read the high word of the IR receiver (OUT will clear both words)
IR_LO:    EQU &HD1  ; read the low word of the IR receiver (OUT will clear both words)
SRAM_CTRL: EQU &H10 ; write the two bits controlling SRAM function (bit 1 is write, bit 0 is output enable)
SRAM_DATA: EQU &H11 ; write the data to go to SRAM (before setting control bits) or read the data from SRAM (after setting bits)
SRAM_ADLOW: EQU &H12 ; write the lower 16 bits of the SRAM address (before setting control bits)
SRAM_ADHI: EQU &H13  ; write the upper 2 bits of the SRAM address (before setting control bits)