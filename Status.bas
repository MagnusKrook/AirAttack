' ----------------------------------------------
'                  Includes
' ----------------------------------------------

#include <string.bas>
#include <nextlib.bas>

' ----------------------------------------------
'                 Definitions
' ----------------------------------------------

#define true 1
#define false 0

' ----------------------------------------------
'                 Declarations
' ----------------------------------------------

declare function NumToString(num as uinteger) as string

' ----------------------------------------------
'            Routines for status info
' ----------------------------------------------

' Define player lives UDG
DIM UDGs(7) AS UBYTE => {_
$10, $10, $28, $FE, $FE, $10, $10, $7C }
POKE Uinteger 23675, @UDGs

sub PrintScore(score as uinteger)
    print at 0,0;"SC: "; NumToString(score)
end sub

sub PrintHighScore(hiScore as uinteger)
    print at 0,12;"HI: "; NumToString(hiScore)
end sub

' Convert a uinteger value to a string with leading zeroes
function NumToString(num as uinteger) as string
    dim numString as string = str(num)
    return LEFT("00000", 5 - LEN(numString)) + numString
end function

sub PrintLives(lives as ubyte)
    if lives = 0 then
        print at 0,26;"   "
    else
        for i = 1 to lives
            print at 0,26 + i;"\A";"   "
        next
    end if
end sub

