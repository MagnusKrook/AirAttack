' ----------------------------------------------
'                  Includes
' ----------------------------------------------

#include <string.bas>
#include <keys.bas>
#include <nextlib.bas>

' ----------------------------------------------
'                 Definitions
' ----------------------------------------------

#define KeyUp 0
#define KeyDown 1
#define KeyLeft 2
#define KeyRight 3
#define KeyAcc 4
#define KeyDec 5
#define KeyFire 6
#define KeyBomb 7

#define Keyboard 1
#define Kempston 2

' ----------------------------------------------
'                 Declarations
' ----------------------------------------------

dim KeyMapAscii(7) as ubyte
dim KeyMapName$(7) as string
dim KeyMapScanCode(7) as uinteger

dim InputMethod as ubyte = Keyboard

declare function ReadKeys() as ubyte
declare function CheckBit(value as ubyte, bit as ubyte) as ubyte

' ----------------------------------------------
'              Set up key controls
' ----------------------------------------------

' Assign ScanCode values
for i = 0 to 7
    Read KeyMapScanCode(i)
next i
data KEYQ, KEYA, KEYO, KEYP, KEY1, KEYZ, KEYSPACE, KEYB

' Assign Key names
for i = 0 to 7
    Read KeyMapName$(i)
next i
data "Up", "Down", "Left", "Right", "Accelerate", "Decelerate", "Fire", "Bomb"

' ----------------------------------------------
'             Player input routines
' ----------------------------------------------

' Read keyboard and return a byte containing information about user input
' 	Bit 0 = Increase speed
' 	Bit 1 = Slow down
' 	Bit 2 = Move left
' 	Bit 3 = Move right
' 	Bit 4 = Move up
' 	Bit 5 = Move down
' 	Bit 6 = Drop bomb
' 	Bit 7 = Fire missile
function ReadKeys() as ubyte
	dim inputByte as ubyte = 0
	if InputMethod = 1 then
		if MultiKeys(KeyMapScanCode(KeyRight)) ' Right
			inputByte = 8
		else if MultiKeys(KeyMapScanCode(KeyLeft)) ' Left
			inputByte = 4
		end if
		if MultiKeys(KeyMapScanCode(KeyUp)) ' Up
			inputByte = inputByte + 16
		else if MultiKeys(KeyMapScanCode(KeyDown)) ' Down
			inputByte = inputByte + 32
		end if
		if MultiKeys(KeyMapScanCode(KeyFire)) ' Fire and bomb
			inputByte = inputByte + 128 + 64
		end if	
		if MultiKeys(KeyMapScanCode(KeyBomb)) ' Bomb
			inputByte = inputByte + 64 ' Set bit 6 if bomb is pressed
		end if
		if MultiKeys(KeyMapScanCode(KeyAcc)) ' Increase speed
			inputByte = inputByte + 1
		else if MultiKeys(KeyMapScanCode(KeyDec)) ' Slow down
			inputByte = inputByte + 2
		end if
	else
		dim kempstonValue as ubyte = 0
		kempstonValue = in 31
		if CheckBit(kempstonValue, 0) = 1 ' Right
			inputByte = 8
		else if CheckBit(kempstonValue, 1) = 1 ' Left
			inputByte = 4
		end if
		if CheckBit(kempstonValue, 3) = 1 ' Down
			inputByte = inputByte + 32
		else if CheckBit(kempstonValue, 2) = 1 ' Up
			inputByte = inputByte + 16
		end if
		if CheckBit(kempstonValue, 4) = 1 'Fire and bomb
			inputByte = inputByte + 128 + 64
		end if

	end if
	return inputByte
end function

' Reassign keys (called from the main menu)
sub KeyboardConfig()
	paper 0
	cls
	dim x as ubyte
	dim key as uinteger
	for i = 0 to 7
		key = 0
		print "Select key for ";KeyMapName$(i);" ";
		WaitKey()
		key = GetKeyScanCode()
		KeyMapAscii(i) = getkey()
		KeyMapScanCode(i) = key
		if KeyMapScanCode(i) = KEYSPACE then print ink 4;"SPACE" else  print ink 4; chr KeyMapAscii(i)
	next i
	print
	print "Press any key to continue..."
	WaitKey()
end sub

function CheckBit(value as ubyte, bit as ubyte) as ubyte
	return (value >> bit) band 1
end function