# About the game
AirAttack is a diagonal scrolling game for the ZX Spectrum Next, written in [Boriel Basic](https://zxbasic.readthedocs.io/en/docs/) using [NextBuildStudio](https://wiki.specnext.dev/NextBuildStudio:Main_Page).

This is not a finished game but it is playable.

# Gameplay
You control an aeroplane which can shoot and bomb enemy targets in the air and on the ground.

You can move your plane left, right, up and down. It is also possible to accelerate and decelerate, but this will not affect the scrolling speed; it will only change the plane's position on the screen.

You can only collide with an object if you are both at the same altitude. Bullets don't have shadows, so to help you decide if they are a threat, they will turn red when they are near your altitude.

If you fly at low altitude, you will crash into trees and other objects. If there is nothing in the way, you can fly at zero altitude, but only if you fly straight - turning the plane will tip the wing into the ground.
# Implementation Notes
## Background scrolling
The background tile map size is 128 x 32 tiles (16x16 pixels). As the background scrolls diagonally (leftwards and downwards), a new top row and a new right column are fetched from the tilemap every 16 scroll step, moving up and right in the tile map, wrapping around the edges to achieve a continuous diagonally scrolling background.
## Checking for ground collision
To check if the player collides with a ground object, the program picks up the colour index at a point below the player sprite when the altitude is below a certain value.
## Enemy ground units
Enemy ground units are intialized when specific tiles appear on the background tile map. When a ground unit is hit, a sprite will be assigned to it for the explosion animation.
## Levels
The levels (there are currently only two) are defined by different backgrounds (tiles, tilemaps and palettes). There is no difference in the gameplay between the levels, only the graphics differ.
## Sound effects
For sound effects I used the AYFXPlayer from Duefectu's book "Boriel Basic for ZX Spectrum". It could be used for a soundtrack as well, but for now there is no music.
The code can be found here: https://github.com/Duefectu/BorielBasicGuideForBeginners/blob/main/13.%20The%20AY-3-8912%20chip/AYFXDemo/AYFXPlayer.bas
