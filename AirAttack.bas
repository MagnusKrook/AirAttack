' ----------------------------------------------
'                 Directives
' ----------------------------------------------
'!ORG=$6000
'!HEAP=4096
'!opt=4

#define NEX

' ----------------------------------------------
'                  Includes
' ----------------------------------------------

' Built-in modules
#include <nextlib.bas>
#include <keys.bas>
#include <attr.bas>

' Extra modules
#include "Status.bas"
#include "Input.bas"
#include "AYFXPlayer.bas"

' ----------------------------------------------
'                 Definitions
' ----------------------------------------------

' Sound effects
#define ShotSound 1
#define BombExplosionSound 0
#define PlayerExplosionSound 3
#define BombMissSound 2

' Player constants
#define PlayerInitialPosX 110
#define PlayerInitialPosY 170
#define PlayerInitialAltitude 20
#define PlayerMaxAltitude 42
#define PlayerPosXMin 24
#define PlayerPosXMax 260
#define PlayerPosYMin 48
#define PlayerPosYMax 208
#define NumberOfBullets 3
#define NumberOfLives 3

' Sprite images
#define PlayerPlane 0
#define Explosion 13
#define Bullet 12
#define Bomb 21
#define BombExplosion 29
#define EnemyJet 40
#define EnemyPlane 18
#define EnemyJetShadow 43
#define BombCrossHairs 25
#define EnemyBulletLower 51
#define EnemyBulletWarning 52
#define EnemyBulletHigher 53
#define LauncherDamagedImage 31
#define GroundUnitDamagedImage 31
#define GroundUnitActiveImage 39

#define DamagedBuildingImage 45
#define LauncherActiveImage 55

' Sprites
#define GroundUnitSprite 0
#define LauncherSprite 10
#define BuildingSprite 20
#define BombCrossHairsSprite 30
#define PlayerShadowSprite 31
#define EnemyPlaneShadowSprite 32
#define EnemyJetShadowSprite 35
#define EnemyMissileSprite 36
#define BombSprite 37
#define EnemyPlaneSprite 39
#define PlayerBulletSprite 40
#define EnemyPlaneBulletSpriteLower 50
#define TankShellSprite 60
#define LauncherBulletSpriteLower 70
#define EnemyJetSprite 80
#define PlayerSprite 90
#define LauncherBulletSpriteHigher 100
#define EnemyPlaneBulletSpriteHigher 110

' Other constants
#define Layer2Bank 95
#define NumberOfEnemyPlaneBullets 4
#define NumberOfEnemyMissiles 1
#define NumberOfGroundUnits 5
#define NumberOfLaunchers 3
#define NumberOfTankShells 4
#define NumberOfLauncherBullets 4

#define GroundUnitTileId 46
#define LauncherTileId 74
#define BuildingTileId 69
#define NextLevelTileId 67

#define MapWidth 128
#define MapHeight 32


' ----------------------------------------------
'                 Declarations
' ----------------------------------------------

' The ActivityCounter is a counter that is updated every frame.
' It is used for triggering various subroutines at specific intervals.
dim ActivityCounter as ubyte

dim TileMapBank as ubyte = 35
dim TileSpritesBank as ubyte = 30

' Variables for the player plane.
dim PlayerPosX as float
dim PlayerPosY as float
dim PlayerAltitude as byte
dim PlayerHit as ubyte
dim PlayerExplosionCycle as ubyte

' The player and enemy sprites have 9 variants:
' - 3 directions; left, center and right leaning and
' - 3 propeller positions per direction.
dim PlayerSpriteDirection as ubyte = 0 
dim EnemyPlaneSpriteDirection as ubyte = 0
dim PropellerCycle as ubyte = 0

dim BulletPosX(NumberOfBullets) as integer
dim BulletPosY(NumberOfBullets) as integer
dim BulletAltitude(NumberOfBullets) as integer
dim BulletActive(NumberOfBullets) as ubyte
dim BulletDelay as ubyte

dim BombPosX as integer
dim BombPosY as integer
dim BombAltitude as byte
dim BombActive as ubyte
dim BombCrossHairsX as integer
dim BombCrossHairsY as integer

dim EnemyPlaneBulletPosX(NumberOfEnemyPlaneBullets) as integer
dim EnemyPlaneBulletPosY(NumberOfEnemyPlaneBullets) as integer
dim EnemyPlaneBulletVectorX(NumberOfEnemyPlaneBullets) as byte
dim EnemyPlaneBulletVectorY(NumberOfEnemyPlaneBullets) as byte
dim EnemyPlaneBulletAltitude(NumberOfEnemyPlaneBullets) as integer
dim EnemyPlaneBulletActive(NumberOfEnemyPlaneBullets) as ubyte

dim EnemyPlanePosX, EnemyPlanePosY as uinteger
dim EnemyPlaneAltitude as uinteger
dim EnemyPlaneActive as ubyte
dim EnemyPlaneXVector as byte
dim EnemyPlaneYVector as byte
dim EnemyPlanePhase as ubyte
dim EnemyPlaneVector as ubyte
dim EnemyPlaneHit as ubyte
dim EnemyPlaneExplosionCycle as ubyte

dim EnemyJetPosX, EnemyJetPosY, EnemyJetAltitude as integer
dim EnemyJetActive as ubyte
dim EnemyJetExplosionCycle as ubyte
dim EnemyJetHit as ubyte

dim EnemyJetMissilePosX as integer
dim EnemyJetMissilePosY as integer
dim EnemyMissileAltitude as integer
dim EnemyJetMissileActive as ubyte

dim TargetColumn as integer
dim TargetRow as integer
dim updateColumn as integer
dim updateRow as integer
dim ScrollPosX as integer = 0
dim ScrollPosY as integer = 0
dim WindowPosColumn as integer = 0
dim WindowPosRow as integer = 0
dim PixelScroll as ubyte

dim GroundUnitPosX(NumberOfGroundUnits) as integer
dim GroundUnitPosY(NumberOfGroundUnits) as integer
dim GroundUnitStatus(NumberOfGroundUnits) as ubyte
' Status 0 = Not visible
' Status 1 = Visible, active
' Status 2 = Visible, damaged

dim LauncherPosX(NumberOfLaunchers) as integer
dim LauncherPosY(NumberOfLaunchers) as integer
dim LauncherStatus(NumberOfLaunchers) as ubyte
' Status 0 = Not visible
' Status 1 = Visible, active
' Status 2 = Visible, damaged

dim BuildingPosX as integer
dim BuildingPosY as integer
dim BuildingStatus as ubyte

dim TankShellPosX(NumberOfTankShells) as integer
dim TankShellPosY(NumberOfTankShells) as integer
dim TankShellAltitude(NumberOfTankShells) as integer
dim TankShellActive(NumberOfTankShells) as ubyte

dim LauncherBulletPosX(NumberOfLauncherBullets) as integer
dim LauncherBulletPosY(NumberOfLauncherBullets) as integer
dim LauncherBulletVectorX(NumberOfLauncherBullets) as integer
dim LauncherBulletVectorY(NumberOfLauncherBullets) as integer
dim LauncherBulletAltitude(NumberOfLauncherBullets) as float
dim LauncherBulletActive(NumberOfLauncherBullets) as ubyte

dim keyPress as ubyte

dim Score as uinteger
dim Lives as ubyte
dim HighScore as uinteger = 0
dim Level as ubyte = 1
dim NextLevel as ubyte = false

declare function CheckGroundTargetHit(x as uinteger, y as uinteger) as ubyte
declare function CheckCollision(x1 as integer, y1 as integer, a1 as byte, x2 as integer, y2 as integer, a2 as byte, distance as byte) as ubyte
declare function L2GroundAttribute(x as ubyte, y as ubyte, scrollIndexX as ubyte, scrollIndexY as ubyte, l2bank as ubyte) as ubyte
declare function OutOfBounds(x as integer, y as integer) as ubyte

declare function GetTileAddressAtPosition(mapBank as ubyte, x as ubyte, y as ubyte) as uinteger
declare function GetTileMapAddress(row as ubyte, col as ubyte) as uinteger

' ----------------------------------------------
'            Next control registers
' ----------------------------------------------

' Set contention off 
NextReg(8, 208)

' ----------------------------------------------
'                Set up audio
' ----------------------------------------------

AYFX_Init(@EffectsBank)

' ----------------------------------------------
'          Load sprites and tiles data
' ----------------------------------------------

LoadSDBank("Sprites.spr",0,0,0,40) ' Sprites (16 KB)

' Background tiles. Size: 24 KB
LoadSDBank("Tilemap1.spr",0,0,0,30)
LoadSDBank("Tilemap2.spr",0,0,0,33)
'LoadSDBank("Tilemap3.spr",0,0,0,36) ' Not implemented.

' Background tilemaps. Size: 16 KB
LoadSDBank("Tilemap1.nxm",0,0,0,42)
LoadSDBank("Tilemap2.nxm",0,0,0,44)
'LoadSDBank("Tilemap3.nxm",0,0,0,46) ' Not implemented.

' Palettes. Size: 512 B
LoadSDBank("Palette1.pal",0,0,0,50)
LoadSDBank("Palette2.pal",0,0,0,51)
' LoadSDBank("Palette3.pal",0,0,0,52) ' Not implemented.

' ---------------------------------------
'             Setup sprites
' ---------------------------------------

' Set the clip window for sprites (NEXTREG $19)
ClipSprite(0,239,16,191)

' Load 64 sprites from bank 40
InitSprites2(63,0,40)

' ---------------------------------------
'            Setup the screen
' ---------------------------------------

' Setup layer 2
NextReg(LAYER2_RAM_BANK_NR_12,Layer2Bank / 2) 
ShowLayer2(1)
ClipLayer2(0,239,16,196)
CLS256(1)

' Set ULA transparency to bright magenta
NextReg(GLOBAL_TRANSPARENCY_NR_14,231) 

' Setup ULA screen with at transparent background
border 0
paper 0
bright 1
cls

' Set layer order to ULA, Sprites, Layer 2. Activate sprites.
NextReg(SPRITE_CONTROL_NR_15, %00010001) 

' ---------------------------------------
'              Start game
' ---------------------------------------

Level = 1
PrepareLevel()

RunAt(3)
Randomize
StartScreen()
PrepareGame()
RestartPlayer()

' ---------------------------------------
'               Main loop
' ---------------------------------------

do	
	' Check if the next level has been reached.
	if NextLevel = true then
		NextLevel = false
		Level = Level + 1
		' There are only two levels, so after level 2 it is back to level 1.
		if Level = 3 then Level = 1
		PrepareLevel()
	endif

	' Check player input (as long as the player is not hit).
	if not PlayerHit then	
		keyPress = ReadKeys()
		HandleKeys(keyPress)	
		
		' The player sprite is modified by an offset found in
		' bit 2-3 of the result from the ReadKeys call.
		PlayerSpriteDirection = keyPress band 12

		' There is a delay between bullets.
		if BulletDelay > 0 then BulletDelay = BulletDelay - 1
	end if	
	
	UpdatePropellerCycle()
	UpdatePlayerSprite()
	UpdatePlayerBullets()
	UpdateBomb()

	if EnemyPlaneActive = false
		TriggerEnemy()
	end if

	if EnemyPlaneActive
		if not EnemyPlaneHit
			if CheckBit(ActivityCounter,0) = 1
				UpdateEnemy()
			end if
			DrawEnemy()			
		else
			DrawHitEnemy()
		end if
	end if

	If not PlayerHit and PlayerAltitude < 10 then TriggerTankShell(PlayerPosX, PlayerPosY)

	TriggerLauncherBullet(PlayerPosX, PlayerPosY, PlayerAltitude)

	' Enemy bullets are updated every other frame.
	if ActivityCounter band 1 = 0 then		
		UpdateTankShells()
		UpdateLauncherBullets()
		UpdateEnemyPlaneBullets()
	end if

	if not EnemyJetActive and rnd > 0.999 then
		TriggerEnemyJet()
	end if

	if EnemyJetActive 
		if not EnemyJetHit then
			if CheckBit(ActivityCounter,0) then UpdateEnemyJet()
			DrawEnemyJet()
		else
			DrawHitEnemyJet()
		end if
	end if

	UpdateEnemyJetMissile()

	' Check if plane collides with something.
	if PlayerHit = false then
		if PlayerAltitude > 15
			if EnemyPlaneActive = 1 and EnemyPlaneHit = 0
				CheckEnemyPlaneCollision()
			end if
			if EnemyJetActive = 1 and EnemyJetHit = 0
				CheckEnemyJetCollision()
			end if
		else
			CheckGroundCollision()
		end if	
	end if
	
	' Check if player bullets hit something.
	CheckBulletHit()

	' Check if player is hit by something.
	CheckEnemyOrdnanceHit(ActivityCounter - 1)
	
	WaitRaster(192) 
	AYFX_PlayFrame()
	
	ActivityCounter = ActivityCounter + 1
	
	if CheckBit(ActivityCounter,0) = 0 then
		ScrollBackground(PlayerPosX, TileMapBank, TileSpritesBank)
	end if

	if ActivityCounter = 4 then
		ActivityCounter = 0
	end if
	
	PrintScore(Score)

loop

sub UpdatePlayerSprite()
	if PlayerHit
		PlayerExplosionCycle = PlayerExplosionCycle + 1
		UpdateSprite(PlayerPosX, PlayerPosY - PlayerAltitude, PlayerSprite, Explosion + PlayerExplosionCycle / 8, 0, 0)
		if PlayerExplosionCycle = 40 then ' Explosion cycle is finished
			PlayerHit = 0
			LifeLost()
			RestartPlayer()
		end if
	else
		UpdateSprite(PlayerPosX, PlayerPosY - PlayerAltitude, PlayerSprite, PlayerPlane + PlayerSpriteDirection + PropellerCycle, 0, 0)
		UpdateSprite(PlayerPosX, PlayerPosY, PlayerShadowSprite, PlayerPlane + PlayerSpriteDirection + 3, 0, 0)
		
		if not BombActive
			BombCrossHairsX = PlayerPosX + PlayerAltitude
			BombCrossHairsY = PlayerPosY - PlayerAltitude
			UpdateSprite(BombCrossHairsX, BombCrossHairsY, BombCrossHairsSprite, BombCrossHairs, 0, 0)
		end if
	end if
end sub

sub TriggerEnemy()
	EnemyPlaneAltitude = PlayerAltitude
	if rnd() > 0.5 then
		EnemyPlanePosX = 0
		EnemyPlanePosY = 32
		EnemyPlaneXVector = 2
		EnemyPlaneYVector = 1
		EnemyPlaneSpriteDirection = 8
	else				
		EnemyPlanePosX = 320
		EnemyPlanePosY = 224
		EnemyPlaneXVector = -2
		EnemyPlaneYVector = -1
		EnemyPlaneSpriteDirection = 4
	end if
	EnemyPlaneActive = true
	EnemyPlaneHit = false
	EnemyPlanePhase = 0
end sub

sub TriggerEnemyJet()
	EnemyJetAltitude = 40
	EnemyJetPosX = PlayerPosX - 100
	EnemyJetPosY = PlayerPosY + 100
	EnemyJetActive = true
end sub

sub UpdateEnemy()
		
	dim deltaY as integer = PlayerPosY - EnemyPlanePosY
	dim deltaX as integer = PlayerPosX - EnemyPlanePosX

	if EnemyPlanePhase = 0 then
		if EnemyPlanePosX = 170 then
			EnemyPlanePhase = 1
			EnemyPlaneSpriteDirection = 0
			EnemyPlaneXVector = 0
			EnemyPlaneYVector = 0
		end if
	else
		if RND() > 0.96 then
			EnemyPlaneVector = int(rnd() * 3)
			if EnemyPlaneVector = 0 then
				EnemyPlaneSpriteDirection = 4
				EnemyPlaneXVector = - 2
				EnemyPlaneYVector = - 1
			else if EnemyPlaneVector = 1 then
				EnemyPlaneSpriteDirection = 0
				EnemyPlaneXVector = 0
				EnemyPlaneYVector = 0
			else
				EnemyPlaneSpriteDirection = 8
				EnemyPlaneXVector = 2
				EnemyPlaneYVector = 1
			end if
		end if
			' Check if enemy shoots a bullet
		if Rnd() > 0.94 and PlayerHit = false then
				TriggerEnemyPlaneBullet(deltaX, deltaY)
		end if
	end if

	EnemyPlanePosX = EnemyPlanePosX + EnemyPlaneXVector
	EnemyPlanePosY = EnemyPlanePosY + EnemyPlaneYVector

	' Enemy plane will match player plane altitude but not below 15
	if EnemyPlaneAltitude > PlayerAltitude and EnemyPlaneAltitude >= 15 then
		EnemyPlaneAltitude = EnemyPlaneAltitude - 1
	else if EnemyPlaneAltitude < PlayerAltitude then
		EnemyPlaneAltitude = EnemyPlaneAltitude + 1
	end if

	if OutOfBounds(EnemyPlanePosX, EnemyPlanePosY - EnemyPlaneAltitude) then RemoveEnemyPlane()

end sub

sub UpdateEnemyJet()
	' Check if enemy jet fires a missile
	if Rnd() * 100 > 95 and EnemyJetPosX <= PlayerPosX and EnemyJetPosY >= PlayerPosY and PlayerHit = false then TriggerEnemyMissile()

	EnemyJetPosX = EnemyJetPosX + 1
	EnemyJetPosY = EnemyJetPosY - 1
	if EnemyJetPosX > 320 or EnemyJetPosY < 0 then RemoveEnemyJet()
end sub

sub DrawEnemy()
	if EnemyPlaneActive = 1 and EnemyPlaneHit = 0 then
		UpdateSprite(EnemyPlanePosX, EnemyPlanePosY - EnemyPlaneAltitude, EnemyPlaneSprite, EnemyPlane + EnemyPlaneSpriteDirection + PropellerCycle, 0, 0)
		UpdateSprite(EnemyPlanePosX, EnemyPlanePosY, EnemyPlaneShadowSprite, PlayerPlane + EnemyPlaneSpriteDirection + 3 , 0, 0)
	end if
end sub

sub DrawEnemyJet()
		UpdateSprite(EnemyJetPosX, EnemyJetPosY - EnemyJetAltitude, EnemyJetSprite, EnemyJet + PropellerCycle, 0, 0)
		UpdateSprite(EnemyJetPosX, EnemyJetPosY, EnemyJetShadowSprite, EnemyJetShadow , 0, 0)
end sub

sub RemoveEnemyPlane()
	RemoveSprite(EnemyPlaneShadowSprite, 0)
	RemoveSprite(EnemyPlaneSprite, 0)
	EnemyPlaneActive = 0
	EnemyPlaneExplosionCycle = 0
	EnemyPlaneHit = 0
end sub

sub RemoveEnemyJet()
	RemoveSprite(EnemyJetShadowSprite, 0)
	RemoveSprite(EnemyJetSprite, 0)
	EnemyJetActive = 0
	EnemyJetExplosionCycle = 0
	EnemyJetHit = 0
end sub

sub DrawHitEnemy()
	UpdateSprite(EnemyPlanePosX, EnemyPlanePosY - EnemyPlaneAltitude, EnemyPlaneSprite, EnemyPlaneExplosionCycle / 8 + Explosion, 0, 0)
	EnemyPlaneExplosionCycle = EnemyPlaneExplosionCycle + 1
	if EnemyPlaneExplosionCycle = 40 then
		RemoveEnemyPlane()
	end if
end sub

sub DrawHitEnemyJet()
	UpdateSprite(EnemyJetPosX, EnemyJetPosY - EnemyJetAltitude, EnemyJetSprite, EnemyJetExplosionCycle / 8 + Explosion, 0, 0)
	EnemyJetExplosionCycle = EnemyJetExplosionCycle + 1
	if EnemyJetExplosionCycle = 40 then
		RemoveEnemyJet()
	end if
end sub

sub UpdatePropellerCycle()
	PropellerCycle = PropellerCycle + 1
	if PropellerCycle > 2 then PropellerCycle = 0
end sub

sub TriggerEnemyPlaneBullet(deltaX as integer, deltaY as integer)
	for i = 0 TO NumberOfEnemyPlaneBullets - 1
		if EnemyPlaneBulletActive(i) = 0 then
			EnemyPlaneBulletPosX(i) = EnemyPlanePosX - 5
			EnemyPlaneBulletPosY(i) = EnemyPlanePosY + 5
			EnemyPlaneBulletAltitude(i) = EnemyPlaneAltitude
			EnemyPlaneBulletActive(i) = 1
			if deltaX > 0 then EnemyPlaneBulletVectorX(i) = 0 else EnemyPlaneBulletVectorX(i) = -2
			if abs(deltaY) < 30 then EnemyPlaneBulletVectorY(i) = 0 else EnemyPlaneBulletVectorY(i) = 2* sgn(deltaY)
			Exit for
		end if
	next i
end sub

sub TriggerEnemyMissile()
	if EnemyJetMissileActive = false then
		EnemyJetMissilePosX = EnemyJetPosX + 5
		EnemyJetMissilePosY = EnemyJetPosY - 5
		EnemyMissileAltitude = EnemyJetAltitude
		EnemyJetMissileActive = true
	end if
end sub

sub TriggerBullet()
	for i = 0 TO NumberOfBullets - 1
		if BulletActive(i) = 0 then
			BulletPosX(i) = PlayerPosX + 5
			BulletPosY(i) = PlayerPosY - 5
			BulletAltitude(i) = PlayerAltitude
			BulletActive(i) = 1
			Exit for
		end if
	next i
end sub

sub UpdatePlayerBullets()
	dim attr as ubyte
	for i = 0 TO NumberOfBullets - 1
		if BulletActive(i) = 1 and BulletPosX(i) > 0 then
			BulletPosX(i) = BulletPosX(i) + 3
			BulletPosY(i) = BulletPosY(i) - 3
			if BulletPosX(i) > 310 or BulletPosY(i) - BulletAltitude(i)  < 12 then
				BulletActive(i) = 0
			else
				UpdateSprite(BulletPosX(i), BulletPosY(i) - BulletAltitude(i), PlayerBulletSprite + i, Bullet, 0, 0)
			end if
			if BulletAltitude(i) < 20 then
				attr = L2GroundAttribute(BulletPosX(i) + 8 - 32, BulletPosY(i) - BulletAltitude(i) - 56, ScrollPosX, ScrollPosY, Layer2Bank)
				if attr = 28 then
					RemoveBullet(i)
					AYFX_Play(BombMissSound)
				end if
			end if
		end if
	next i
end sub

sub TriggerBomb()
	if BombActive = 0 and PlayerAltitude > 0 then
		BombPosX = PlayerPosX + 0
		BombPosY = PlayerPosY - 0
		BombAltitude = PlayerAltitude
		BombActive = 1
		RemoveSprite(BombCrossHairsSprite,0)
	end if
end sub

sub UpdateBomb()
	if BombActive = 1 then
		if CheckBit(ActivityCounter,0) = 1  then BombAltitude = BombAltitude - 1
		UpdateSprite(BombPosX, BombPosY - BombAltitude, BombSprite, Bomb, 0, 0)
		if BombAltitude = 0 then
			BombActive = 2 ' This initiates the bomb explosion cycle.
			AYFX_Play(BombMissSound)
			CheckGroundTargetHit(BombPosX, BombPosY)
		end if
	else if BombActive >= 2 and BombActive < 5 then ' The bomb has hit the ground an is exploding in phase 1/2
		UpdateSprite(BombPosX - 1, BombPosY + 1, BombSprite, BombExplosion, 0, 0)
		BombActive = BombActive + 1
	else if BombActive >= 5 and BombActive <= 7 then ' The bomb has hit the ground an is exploding in phase 2/2
		UpdateSprite(BombPosX - 2, BombPosY + 2, BombSprite, BombExplosion + 1, 0, 0)
		BombActive = BombActive + 1
	else if BombActive = 8 ' The bomb has finished exploding and can be re-armed
		RemoveSprite(BombSprite, 0)
		BombActive = 0
	end if
end sub

' Return true if a bomb or bullet has hit any ground target at coordinate x, y.
function CheckGroundTargetHit(x as uinteger, y as uinteger) as ubyte
	for j = 0 TO NumberOfGroundUnits - 1
		if GroundUnitStatus(j) = 1 then
			if abs(GroundUnitPosX(j) - x) <= 8 and abs(GroundUnitPosY(j) - y) <= 8 then
				GroundUnitStatus(j) = 2
				Score = Score + 20
				AYFX_Play(BombExplosionSound)
				return true
			end if
		end if
	next j

	if abs(x - BuildingPosX) < 24 and abs(y - BuildingPosY) < 24  then
		if BuildingStatus = 1 then
			Score = Score + 50
			BuildingStatus = 2
		end if
		AYFX_Play(BombExplosionSound)
		return true
	end if
	for j = 0 TO NumberOfLaunchers - 1
		if LauncherStatus(j) = 1 then
			if abs(LauncherPosX(j) - x) <= 8 and abs(LauncherPosY(j) - y) <= 8 then
				LauncherStatus(j) = 2
				Score = Score + 20
				AYFX_Play(BombExplosionSound)
				return true
			end if
		end if
	next j
	return false
end function

sub UpdateEnemyPlaneBullets()
	for i = 0 TO NumberOfEnemyPlaneBullets - 1
		if EnemyPlaneBulletActive(i) = 1 then
			EnemyPlaneBulletPosX(i) = EnemyPlaneBulletPosX(i) + EnemyPlaneBulletVectorX(i)
			EnemyPlaneBulletPosY(i) = EnemyPlaneBulletPosY(i) + EnemyPlaneBulletVectorY(i)
			if OutOfBounds(EnemyPlaneBulletPosX(i), EnemyPlaneBulletPosY(i) - EnemyPlaneBulletAltitude(i)) then
				EnemyPlaneBulletActive(i) = 0
				RemoveSprite(EnemyPlaneBulletSpriteLower + i ,false)
				RemoveSprite(EnemyPlaneBulletSpriteHigher + i ,false)
			else
				if ABS (EnemyPlaneBulletAltitude(i) - PlayerAltitude) <= 10 then
					RemoveSprite(EnemyPlaneBulletSpriteHigher + i ,false)
					UpdateSprite(EnemyPlaneBulletPosX(i), EnemyPlaneBulletPosY(i) - EnemyPlaneBulletAltitude(i), EnemyPlaneBulletSpriteLower + i,  EnemyBulletWarning, 0, 0)
				else if EnemyPlaneBulletAltitude(i) < PlayerAltitude
					RemoveSprite(EnemyPlaneBulletSpriteHigher + i ,false)
					UpdateSprite(EnemyPlaneBulletPosX(i), EnemyPlaneBulletPosY(i) - EnemyPlaneBulletAltitude(i), EnemyPlaneBulletSpriteLower + i,  EnemyBulletLower, 0, 0)
				else
					RemoveSprite(EnemyPlaneBulletSpriteLower + i ,false)
					UpdateSprite(EnemyPlaneBulletPosX(i), EnemyPlaneBulletPosY(i) - EnemyPlaneBulletAltitude(i), EnemyPlaneBulletSpriteHigher + i,  EnemyBulletHigher, 0, 0)
				end if
			end if
		end if
	next i
end sub

sub UpdateEnemyJetMissile()
	if EnemyJetMissileActive = 1 then
		dim deltaY as byte = EnemyJetMissilePosY - PlayerPosY
		dim deltaX as byte = PlayerPosX - EnemyJetMissilePosX
		dim EnemyMissileXVector as ubyte

		' Check if missile should change direction
		if Rnd() * 100 > 50 and deltaX > 0 and deltaY > 0 then
			if deltaX > deltaY
				EnemyMissileXVector = 2
			else if deltaX < deltaY
				EnemyMissileXVector = 0
			end if
			if PlayerAltitude > EnemyMissileAltitude then
				EnemyMissileAltitude = EnemyMissileAltitude + 1
			else if PlayerAltitude < EnemyMissileAltitude then
				EnemyMissileAltitude = EnemyMissileAltitude - 1
			end if
		else
			EnemyMissileXVector = 1
		end if
		EnemyJetMissilePosX = EnemyJetMissilePosX + EnemyMissileXVector
		EnemyJetMissilePosY = EnemyJetMissilePosY - 1
		if EnemyJetMissilePosX > 310 or EnemyJetMissilePosY - EnemyMissileAltitude  < 12 then
			EnemyJetMissileActive = 0
		else
			UpdateSprite(EnemyJetMissilePosX, EnemyJetMissilePosY - EnemyMissileAltitude, EnemyMissileSprite, Bullet, 0, 0)
		end if
	end if
end sub

sub UpdateTankShells()
	for i = 0 TO NumberOfTankShells - 1
		if TankShellActive(i) = 1 then
			TankShellPosX(i) = TankShellPosX(i) - 2
			TankShellPosY(i) = TankShellPosY(i) + 2
			if TankShellPosX(i) < 0 or TankShellPosY(i) - TankShellAltitude(i)  > 224 then
				TankShellActive(i) = 0
				RemoveSprite(TankShellSprite + i ,false)
			else
				UpdateSprite(TankShellPosX(i), TankShellPosY(i) - TankShellAltitude(i), TankShellSprite + i, Bullet, 0, 0)
			end if
		end if
	next i
end sub

sub UpdateLauncherBullets()
	for i = 0 TO NumberOfLauncherBullets - 1
		if LauncherBulletActive(i) = 1 then
			LauncherBulletPosX(i) = LauncherBulletPosX(i) - LauncherBulletVectorX(i)
			LauncherBulletPosY(i) = LauncherBulletPosY(i) - LauncherBulletVectorY(i)
			' Bullets will ascend to max altitude and then disappear
			if LauncherBulletAltitude(i) < PlayerMaxAltitude then
				LauncherBulletAltitude(i) = LauncherBulletAltitude(i) + 0.5
	
				if OutOfBounds(LauncherBulletPosX(i), LauncherBulletPosY(i) - LauncherBulletAltitude(i)) then
					LauncherBulletActive(i) = 0
					RemoveSprite(LauncherBulletSpriteLower + i ,false)
					RemoveSprite(LauncherBulletSpriteHigher + i ,false)	
				else
					if ABS (LauncherBulletAltitude(i) - PlayerAltitude) <= 10 then
						RemoveSprite(LauncherBulletSpriteHigher + i ,false)	
						UpdateSprite(LauncherBulletPosX(i), LauncherBulletPosY(i) - LauncherBulletAltitude(i), LauncherBulletSpriteLower + i,  EnemyBulletWarning, 0, 0)
					else if LauncherBulletAltitude(i) < PlayerAltitude
						RemoveSprite(LauncherBulletSpriteHigher + i ,false)	
						UpdateSprite(LauncherBulletPosX(i), LauncherBulletPosY(i) - LauncherBulletAltitude(i), LauncherBulletSpriteLower + i,  EnemyBulletLower, 0, 0)
					else
						RemoveSprite(LauncherBulletSpriteLower + i ,false)
						UpdateSprite(LauncherBulletPosX(i), LauncherBulletPosY(i) - LauncherBulletAltitude(i), LauncherBulletSpriteHigher + i,  EnemyBulletHigher, 0, 0)
					end if
					
				end if
			else
				' Bullet has reached max altitude
					RemoveSprite(LauncherBulletSpriteLower + i ,false)
					RemoveSprite(LauncherBulletSpriteHigher + i ,false)
				LauncherBulletActive(i) = 0
			end if
		end if
	next i
end sub

' Remove all enemy bullets, missiles and shells.
sub RemoveEnemyOrdnance()
	for i = 0 TO NumberOfEnemyPlaneBullets - 1
			EnemyPlaneBulletActive(i) = 0
			RemoveSprite(EnemyPlaneBulletSpriteLower + i, 0)
			RemoveSprite(EnemyPlaneBulletSpriteHigher + i, 0)
	next i
	for i = 0 TO NumberOfTankShells - 1
			TankShellActive(i) = 0
			RemoveSprite(TankShellSprite + i, 0)
	next i
	for i = 0 TO NumberOfLauncherBullets - 1
			LauncherBulletActive(i) = 0
			RemoveSprite(LauncherBulletSpriteLower + i ,false)
			RemoveSprite(LauncherBulletSpriteHigher + i ,false)
	next i
		EnemyJetMissileActive = 0
		RemoveSprite(EnemyMissileSprite, 0)
end sub

' Check if player is hit by any enemy ordnance.
sub CheckEnemyOrdnanceHit(index as ubyte)
	if EnemyPlaneBulletActive(index) then
		if CheckCollision(EnemyPlaneBulletPosX(index), EnemyPlaneBulletPosY(index), EnemyPlaneBulletAltitude(index), PlayerPosX, PlayerPosY, PlayerAltitude, 8) then
			HandlePlayerHit()
		end if
	end if
	if LauncherBulletActive(index) then
		if CheckCollision(LauncherBulletPosX(index), LauncherBulletPosY(index), LauncherBulletAltitude(index), PlayerPosX, PlayerPosY, PlayerAltitude, 8) then		
			HandlePlayerHit()
		end if
	end if
	if TankShellActive(index) then
		if CheckCollision(GroundUnitPosX(index), GroundUnitPosY(index), 0, PlayerPosX, PlayerPosY, PlayerAltitude, 8) then	
			HandlePlayerHit()
		end if
	end if
	if EnemyJetMissileActive then
		if CheckCollision(EnemyJetMissilePosX, EnemyJetMissilePosY, EnemyMissileAltitude, PlayerPosX, PlayerPosY, PlayerAltitude, 8) then		
			HandlePlayerHit()
		end if
	end if
end sub

' Check if player collides with an enemy plane.
sub CheckEnemyPlaneCollision()
	if 	CheckCollision(EnemyPlanePosX, EnemyPlanePosY, EnemyPlaneAltitude, PlayerPosX, PlayerPosY, PlayerAltitude, 16) then
		RemoveEnemyPlane()
		RemoveEnemyOrdnance()
		HandlePlayerHit()
	end if
end sub

' Check if player collides with an enemy jet.
sub CheckEnemyJetCollision()
	if 	CheckCollision(EnemyJetPosX, EnemyJetPosY, EnemyJetAltitude, PlayerPosX, PlayerPosY, PlayerAltitude, 16) then
		RemoveEnemyJet()
		RemoveEnemyOrdnance()
		HandlePlayerHit()
	end if
end sub

' Check if player collides with the ground.
sub CheckGroundCollision()
	' Call L2GroundAttribute to get the attribute at the player position.
	' We assume that the ground objects are three dimensional so we check the attribute at the actual
	' player sprite position (offset to roughly the middle of the sprite).
	' Note that the PlayerY coordinate is the Y coordinate on the ground, so we have to subtract
	' the PlayerAltitude to get the corresponding Y coordinate on the screen.
	' We also need to substract 32 from X and Y to take the border width into account.
	' Why we also subtract an additional 24 from the PlayerY coordinate, I can't explain why - I would expect to instead
	' add 8 to get to the centre of the sprite. Apparently something is 32 pixels off in the
	' L2GroundAttribute function.
	dim ground as ubyte = L2GroundAttribute(PlayerPosX + 8 - 32, PlayerPosY - PlayerAltitude - 56, ScrollPosX, ScrollPosY, Layer2Bank)
	if Level = 1 then
		if ground = 24 or ground = 16 or ground = 108 or ground = 12 HandlePlayerHit()
	else if ground = 30 or ground = 12 HandlePlayerHit()
end sub

' Player has been hit.
sub HandlePlayerHit()	
	' Some sprites need to be removed when the player has been hit
	RemoveSprite(PlayerShadowSprite,0)
	RemoveSprite(BombCrossHairsSprite,0)
	RemoveSprite(BombSprite,0)
	BombActive = 0
	RemoveEnemyOrdnance()
	
	' Initialize the player explosion cycle
	PlayerHit = 1
	PlayerExplosionCycle = 0
	AYFX_Play(PlayerExplosionSound)	
end sub

' Check if a player bullet has hit something.
sub CheckBulletHit()
		for i = 0 TO NumberOfBullets - 1
			if BulletActive(i) = 1 then
				if BulletAltitude(i) < 10 then
					if CheckGroundTargetHit(BulletPosX(i), BulletPosY(i)) = 1 then
						RemoveBullet(i)
					end if
				end if
				if EnemyPlaneActive and CheckCollision(EnemyPlanePosX, EnemyPlanePosY, EnemyPlaneAltitude, BulletPosX(i), BulletPosY(i), BulletAltitude(i), 8) and not EnemyPlaneHit then
					EnemyPlaneHit = 1
					AYFX_Play(PlayerExplosionSound)
					Score = Score + 10
					RemoveSprite(EnemyPlaneShadowSprite, 0)
					RemoveBullet(i)
				end if
				if EnemyJetActive and CheckCollision(EnemyJetPosX, EnemyJetPosY, EnemyJetAltitude, BulletPosX(i), BulletPosY(i), BulletAltitude(i), 8) and not EnemyJetHit then
					EnemyJetHit = 1
					AYFX_Play(PlayerExplosionSound)
					Score = Score + 10
					RemoveSprite(EnemyJetShadowSprite, 0)
					RemoveBullet(i)
				end if	
			end if
		next i 
end sub

sub RemoveBullet(index as ubyte)
	BulletActive(index) = 0
	RemoveSprite(PlayerBulletSprite + index, 0)
end sub

' Initialize a player plane.
sub RestartPlayer()
	' Remove any enemy sprites
	RemoveEnemyPlane()
	RemoveEnemyJet()
	RemoveEnemyOrdnance()
	
	' Let a new plane enter from bottom left corner
	dim ApproachCycles as ubyte = 70
	dim ScrollTiming as ubyte = 0
	PlayerPosX = PlayerInitialPosX - ApproachCycles
	PlayerPosY = PlayerInitialPosY + ApproachCycles
	PlayerAltitude = PlayerInitialAltitude
	PlayerSpriteDirection = 0	       
	PlayerHit = 0
	dim counter as ubyte
	for counter = 1 to ApproachCycles
		PlayerPosX = PlayerPosX + 1
		PlayerPosY = PlayerPosY - 1
		UpdatePropellerCycle()
		UpdatePlayerSprite()
		WaitRaster(192)
		AYFX_PlayFrame()
		ScrollTiming = ScrollTiming + 1
		if ScrollTiming = 2 then
			ScrollTiming = 0
			ScrollBackground(PlayerPosX, TileMapBank, TileSpritesBank)
		end if
	next counter
end sub

' When a life has been lost, handle game over or next life.
sub LifeLost()
	Lives = Lives - 1

	if Lives = 0 then ' Game over
		PrintLives(0)
		RemoveSprite(PlayerSprite,0)

		' Print to ULA screen
		print at 10,7; paper 0; "G A M E  O V E R"

		' Let the explosion effect play out
		for n = 1 to 127
			WaitRaster(192)
			AYFX_PlayFrame()
		next n
		
		WaitKey()
		cls
		StartScreen()
		PrepareGame()
	else ' Continue
		PrintLives(Lives)
	end if
end sub

' Prepare a new game.
sub PrepareGame()
	Score = 0
	Lives = NumberOfLives
	PrintScore(Score)
	PrintLives(Lives)
	PrintHighScore(HighScore)
	PlayerPosX = PlayerInitialPosX
	PlayerPosY = PlayerInitialPosY
	PlayerAltitude = PlayerInitialAltitude
	SetupBackground(TileMapBank, TileSpritesBank)
end sub

' Display the game start screen.
sub StartScreen()
	dim selection as uinteger = 0

	while selection <> KEY1 and selection <> KEY2
		paper 0
		cls
		if Score > HighScore then HighScore = Score
		PrintScore(Score)
		PrintHighScore(HighScore)
		PrintLives(NumberOfLives)
		print at 5,8; ink 4;"AIR ATTACK"
		print at 7,8;"1. KEYBOARD"
		print at 9,8;"2. KEMPSTON"
		print at 11,8;"3. REASSIGN KEYS"

		waitkey()
		selection = GetKeyScanCode()

		if selection = KEY1 then
			InputMethod = Keyboard
		else if selection = KEY2 then
			InputMethod = Kempston
		else if selection = KEY3 then
			KeyboardConfig()
		end if

	wend
	paper 3
	cls
end sub

' Handle player input.
' The parameter is a byte that is defined by the ReadKeys function in Input.bas
sub HandleKeys(inputByte as ubyte)
	if  CheckBit(inputByte, 3)
		if PlayerPosX < PlayerPosXMax and PlayerPosY < PlayerPosYMax then
			PlayerPosX = PlayerPosX + 1
			PlayerPosY = PlayerPosY + 0.5
			if PlayerAltitude = 0 then HandlePlayerHit()
		end if
	else if CheckBit(inputByte, 2)
		if PlayerPosX > PlayerPosXMin and PlayerPosY - PlayerAltitude > PlayerPosYMin then
			PlayerPosX = PlayerPosX - 1
			PlayerPosY = PlayerPosY - 0.5
			if PlayerAltitude = 0 then HandlePlayerHit()
		endif
	end if
	if CheckBit(inputByte, 4) and PlayerAltitude <= PlayerMaxAltitude and PlayerPosY - PlayerAltitude > PlayerPosYMin 
		PlayerAltitude = PlayerAltitude + 1
	else if CheckBit(inputByte, 5) = true and PlayerAltitude > 0
		PlayerAltitude = PlayerAltitude - 1
	end if
	if CheckBit(inputByte, 7) and BulletDelay = 0 then
		AYFX_Play(ShotSound)
		BulletDelay = 10
		TriggerBullet()
	end if	
	if CheckBit(inputByte, 6) and BombActive = false
		TriggerBomb()
	end if
	if CheckBit(inputByte, 0)
		if PlayerPosX < PlayerPosXMax and PlayerPosY - PlayerAltitude > PlayerPosYMin then 
			PlayerPosY = PlayerPosY - 0.5
			PlayerPosX = PlayerPosX + 0.5
		end if
	else if CheckBit(inputByte, 1)
		if PlayerPosX > PlayerPosXMin and PlayerPosY < PlayerPosYMax then 
			PlayerPosY = PlayerPosY + 0.5
			PlayerPosX = PlayerPosX - 0.5
		end if
	end if
end sub

' ----------------------------------------------
'       Routines for background management
' ----------------------------------------------

' Scroll the background diagonally top-down and right-left.
sub ScrollBackground(planePosX as uinteger, mapBank as ubyte, TileSpritesBank as ubyte)

	' Scroll background
	ScrollPosX = ScrollPosX + 1
	if ScrollPosX > 255 then ScrollPosX = 0	
	
	ScrollPosY = ScrollPosY - 1
	if ScrollPosY < 0 then ScrollPosY = 191

	ScrollLayer(ScrollPosX, ScrollPosY)

	' Update ground units. Note that active units (status = 1) are displayed from the tile map,
	' but when they have been hit (status > 1), an explosion sprite cycle is painted on the background.
	for i = 0 to NumberOfGroundUnits - 1
		if GroundUnitStatus(i) > 0 then
			' Move ground units with background.
			GroundUnitPosX(i) = GroundUnitPosX(i) - 1
			GroundUnitPosY(i) = GroundUnitPosY(i) + 1
			' If status > 1 then the ground unit has been hit and needs to have an explosion animation.
			if GroundUnitStatus(i) = 2
				UpdateSprite(GroundUnitPosX(i), GroundUnitPosY(i), GroundUnitSprite + i, GroundUnitDamagedImage , 0, 0)
				GroundUnitStatus(i) = GroundUnitStatus(i) + 1
			else if GroundUnitStatus(i) = 3
				UpdateSprite(GroundUnitPosX(i), GroundUnitPosY(i), GroundUnitSprite + i, GroundUnitDamagedImage + 1 , 0, 0)
				GroundUnitStatus(i) = GroundUnitStatus(i) + 1
			else if GroundUnitStatus(i) = 4
				UpdateSprite(GroundUnitPosX(i), GroundUnitPosY(i), GroundUnitSprite + i, GroundUnitDamagedImage + 2 , 0, 0)
				GroundUnitStatus(i) = GroundUnitStatus(i) + 1
			else if GroundUnitStatus(i) = 5
				UpdateSprite(GroundUnitPosX(i), GroundUnitPosY(i), GroundUnitSprite + i, GroundUnitDamagedImage + 3 , 0, 0)
				GroundUnitStatus(i) = GroundUnitStatus(i) + 1
			else if GroundUnitStatus(i) >= 6 and GroundUnitStatus(i) < 10
				UpdateSprite(GroundUnitPosX(i), GroundUnitPosY(i), GroundUnitSprite + i, GroundUnitDamagedImage + 4 , 0, 0)
				GroundUnitStatus(i) = GroundUnitStatus(i) + 1
			else if GroundUnitStatus(i) >= 9 and GroundUnitStatus(i) < 13
				UpdateSprite(GroundUnitPosX(i), GroundUnitPosY(i), GroundUnitSprite + i, GroundUnitDamagedImage + 5 , 0, 0)
				GroundUnitStatus(i) = GroundUnitStatus(i) + 1
				if GroundUnitStatus(i) = 13 then GroundUnitStatus(i) = 6
			end if
		end if
	next i

	' Update launchers. Note that active launchers (status = 1) are displayed from the tile map,
	' but when they have been hit (status > 1), an explosion sprite cycle is painted on the background.
	for i = 0 to NumberOfLaunchers - 1
		if LauncherStatus(i) > 0 then
			' Move launcger with background.
			LauncherPosX(i) = LauncherPosX(i) - 1
			LauncherPosY(i) = LauncherPosY(i) + 1
			' If status > 1 then the launcher has been hit and needs to have an explosion animation.
			if LauncherStatus(i) = 2
				UpdateSprite(LauncherPosX(i), LauncherPosY(i), LauncherSprite + i, LauncherDamagedImage , 0, 0)
				LauncherStatus(i) = LauncherStatus(i) + 1
			else if LauncherStatus(i) = 3
				UpdateSprite(LauncherPosX(i), LauncherPosY(i), LauncherSprite + i, LauncherDamagedImage + 1 , 0, 0)
				LauncherStatus(i) = LauncherStatus(i) + 1
			else if LauncherStatus(i) = 4
				UpdateSprite(LauncherPosX(i), LauncherPosY(i), LauncherSprite + i, LauncherDamagedImage + 2 , 0, 0)
				LauncherStatus(i) = LauncherStatus(i) + 1
			else if LauncherStatus(i) = 5
				UpdateSprite(LauncherPosX(i), LauncherPosY(i), LauncherSprite + i, LauncherDamagedImage + 3 , 0, 0)
				LauncherStatus(i) = LauncherStatus(i) + 1
			else if LauncherStatus(i) >= 6 and LauncherStatus(i) < 10
				UpdateSprite(LauncherPosX(i), LauncherPosY(i), LauncherSprite + i, LauncherDamagedImage + 4 , 0, 0)
				LauncherStatus(i) = LauncherStatus(i) + 1
			else if LauncherStatus(i) >= 9 and LauncherStatus(i) < 13
				UpdateSprite(LauncherPosX(i), LauncherPosY(i), LauncherSprite + i, LauncherDamagedImage + 5 , 0, 0)
				LauncherStatus(i) = LauncherStatus(i) + 1
				if LauncherStatus(i) = 13 then LauncherStatus(i) = 6
			end if
		end if
	next i

	' Update building
	if BuildingStatus > 0 then
		' Move building with background.
			BuildingPosX = BuildingPosX - 1
			BuildingPosY = BuildingPosY + 1
		' If status > 1 then the building has been hit and needs to have an explosion animation.
		if BuildingStatus >= 2 and BuildingStatus <= 4 then
			UpdateSprite(BuildingPosX + 3, BuildingPosY + 6, BuildingSprite, DamagedBuildingImage + 1, 0, 0)
			UpdateSprite(BuildingPosX - 5, BuildingPosY + 2, BuildingSprite + 1, DamagedBuildingImage, 0, 0)
			UpdateSprite(BuildingPosX - 13, BuildingPosY - 2, BuildingSprite + 2, DamagedBuildingImage + 2, 0, 0)
			BuildingStatus = BuildingStatus + 1
		else if BuildingStatus > 4 and BuildingStatus <= 8 then
			UpdateSprite(BuildingPosX + 3, BuildingPosY + 6, BuildingSprite, DamagedBuildingImage + 2, 0, 0)
			UpdateSprite(BuildingPosX - 5, BuildingPosY + 2, BuildingSprite + 1, DamagedBuildingImage + 1, 0, 0)
			UpdateSprite(BuildingPosX - 13, BuildingPosY - 2, BuildingSprite + 2, DamagedBuildingImage, 0, 0)
			BuildingStatus = BuildingStatus + 1
		else if BuildingStatus > 8 and BuildingStatus <= 12 then
			UpdateSprite(BuildingPosX + 3, BuildingPosY + 6, BuildingSprite, DamagedBuildingImage, 0, 0)
			UpdateSprite(BuildingPosX - 5, BuildingPosY + 2, BuildingSprite + 1, DamagedBuildingImage + 2, 0, 0)
			UpdateSprite(BuildingPosX - 13, BuildingPosY - 2, BuildingSprite + 2, DamagedBuildingImage + 1, 0, 0)
			BuildingStatus = BuildingStatus + 1
		else if BuildingStatus > 12
			UpdateSprite(BuildingPosX + 3, BuildingPosY + 6, BuildingSprite, DamagedBuildingImage + 1, 0, 0)
			UpdateSprite(BuildingPosX - 5, BuildingPosY + 2, BuildingSprite + 1, DamagedBuildingImage, 0, 0)
			UpdateSprite(BuildingPosX - 13, BuildingPosY - 2, BuildingSprite + 2, DamagedBuildingImage + 2, 0, 0)
			BuildingStatus = 3
		end if
	end if

	' Remove ground units that are off-screan
	for i = 0 to NumberOfGroundUnits - 1
		if GroundUnitStatus(i) > 0 then
			if GroundUnitPosX(i) < 0 OR GroundUnitPosY(i) > 224 then
				GroundUnitStatus(i) = 0
				RemoveSprite(GroundUnitSprite + i, 0)
			end if
		end if
	next i

	' Remove launchers that are off-screan
	for i = 0 to NumberOfLaunchers - 1
		if LauncherStatus(i) > 0 then
			if LauncherPosX(i) < 0 OR LauncherPosY(i) > 224 then
				LauncherStatus(i) = 0
				RemoveSprite(LauncherSprite + i, 0)
			end if
		end if
	next i

	' Remove building that is off-screen
	if BuildingStatus > 0 and (BuildingPosX < 0 or BuildingPosY > 256) then
		BuildingStatus = 0
		RemoveSprite(BuildingSprite, 0)
		RemoveSprite(BuildingSprite + 1, 0)
		RemoveSprite(BuildingSprite + 2, 0)
	end if
	
	' After scrolling 16 pixels, it is time to load a new row and a new column of tiles.
	PixelScroll = ScrollPosY mod 16
	if PixelScroll = 0 then

		' WindowPosColumn and WindowPosRow determine where in the tilemap the visible window is.
		' Move the visible window one tile to the right and wrap around if necessary.
		WindowPosColumn = WindowPosColumn + 1
		if WindowPosColumn > MapWidth - 1 then WindowPosColumn = 0

		' Fetch a new column of tiles.
		FetchColumn(mapBank, TileSpritesBank)

		' The TargetColumn variable specifies where on the scrolled screen the
		' rightmost column is located currently. For the first update it will be
		' column 0 because the screen has been scrolled 16 pixels to the left and
		' column 0 has been wrapped around to right edge of the screen.

		' Now, increase the target column for the next time we get here.
		' and also for the row update which will start on column 1 for the first update.
		TargetColumn = TargetColumn + 1
		if TargetColumn > 15 then TargetColumn = 0
		
		' Move the visible window one tile upwards and wrap around if necessary.
		WindowPosRow = WindowPosRow - 1
		if WindowPosRow < 0 then WindowPosRow = MapHeight - 1
		
		' Decrease the target row.
		TargetRow = TargetRow - 1
		if TargetRow = -1 then TargetRow = 11
		
		' Fetch a row of tiles for the uppermost row on the screen.
		FetchRow(mapBank, TileSpritesBank)

	end if
end sub

sub TriggerTankShell(planePosX as uinteger, planePosY as uinteger)
	for i = 0 to NumberOfGroundUnits - 1
		if GroundUnitStatus(i) = 1 and rnd() > 0.97 and GroundUnitPosX(i) > planePosX and GroundUnitPosY(i) < planePosY then
			for j = 0 to NumberOfTankShells - 1
				if TankShellActive(j) = 0  then
					TankShellPosX(j) = GroundUnitPosX(i) - 6
					TankShellPosY(j) = GroundUnitPosY(i) + 17
					TankShellAltitude(j) = 10
					TankShellActive(j) = 1
					Exit for
				end if
			next j
		end if
	next i
end sub

sub TriggerLauncherBullet(planePosX as uinteger, planePosY as uinteger, planeAltitude as uinteger)
	for i = 0 to NumberOfLaunchers - 1
		if LauncherStatus(i) = 1 and rnd() > 0.99 then			
			dim deltaX as integer = LauncherPosX(i) - planePosX
			dim deltaY as integer = LauncherPosY(i) - planePosY
			' Don't fire any bullets if launcher is too close to player.
			if abs(deltaX) + abs(deltaY) > 40 then
				for j = 0 to NumberOfLauncherBullets - 1
					if LauncherBulletActive(j) = 0  then
						LauncherBulletPosX(j) = LauncherPosX(i)
						LauncherBulletPosY(j) = LauncherPosY(i) + 8
						if abs(deltaX) < 20 then
							LauncherBulletVectorX(j) = 0
						else
							LauncherBulletVectorX(j) = 2 * sgn(deltaX)
						end if

						if abs(deltaY) < 20 then
							LauncherBulletVectorY(j) = 0
						else
							LauncherBulletVectorY(j) = 2 * sgn(deltaY)
						end if

						LauncherBulletAltitude(j) = 10
						LauncherBulletActive(j) = 1
						Exit for
					end if
				next j
			end if
		end if
	next i
end sub


' The tile map is 128 x 32 size.
sub FetchColumn(mapBank as ubyte, TileSpritesBank as ubyte)
    dim rowCount as uinteger
    dim tileAddress as uinteger
	dim tile as uinteger	
    dim tileColumn as uinteger
	dim tileRow as uinteger

	' Find the correct column in the tilemap (with wrap around).
    if WindowPosColumn + 15 < MapWidth then
        tileColumn = WindowPosColumn + 15
    else
        tileColumn = WindowPosColumn + 15 - MapWidth
    end if

	' Map MMU0 to tile map bank.
	NextRegA($50,mapBank)

	' Loop through 12 rows.
    for rowCount = 0 to 11

		' Find the correct row in the tilemap (with wrap around).
		if WindowPosRow + rowCount < MapHeight then
			tileRow = WindowPosRow + rowCount
			else
				tileRow = WindowPosRow + rowCount - MapHeight
			end if

		' Find the screen row to update (with wrap around)
		updateRow = TargetRow + rowCount
		if updateRow > 11 then updateRow = updateRow - 12

		' Place the tile.
        tileAddress = tileColumn + tileRow * MapWidth
		tile = peek(tileAddress)
		DoTileBank16(TargetColumn, updateRow, peek(tileAddress), TileSpritesBank)

		' Initialize ground targets.
		if tile = GroundUnitTileId then 
			InitializeGroundUnit(272, (rowCount + 3) * 16)
		end if

		if tile = BuildingTileId then 
			InitializeBuilding(272, (rowCount + 3) * 16)
		end if

		if tile = LauncherTileId then 
			InitializeLauncher(272, (rowCount + 3) * 16)
		end if

    next
	' Map MMU0 back to ROM.
 	NextReg($50,$FF)
end sub

sub FetchRow(mapBank as ubyte, TileSpritesBank as ubyte)
    dim colCount as uinteger
    dim tileAddress as uinteger
	dim tile as uinteger	
    dim tileRow as uinteger
	dim tileColumn as uinteger

	' Find the correct row in the tilemap (with wrap around).
    if WindowPosRow >= 0 then
        tileRow = WindowPosRow
    else
		tileRow = MapHeight - 1 - WindowPosRow
    end if

	' Map MMU0 to the tile map bank.
	NextRegA($50,mapBank)

    ' Loop through 16 columns.
	for colCount = 0 to 15

		' Find the correct column in the tilemap (with wrap around).
		if WindowPosColumn + colCount < MapWidth then
			tileColumn = WindowPosColumn + colCount
		else
			tileColumn = WindowPosColumn + colCount - MapWidth
		end if

		' Find the screen column to update (with wrap around)
		updateColumn = TargetColumn + colCount
		if updateColumn > 15 then updateColumn = updateColumn - 16

		' Place the tile.
		tileAddress = tileColumn + tileRow * MapWidth
		tile = peek(tileAddress)
        DoTileBank16(updateColumn, TargetRow, tile, TileSpritesBank)

		' Initialize ground targets.
		if tile = GroundUnitTileId then InitializeGroundUnit((colCount + 2) * 16, 32)
		if tile = BuildingTileId then InitializeBuilding((colCount + 2) * 16, 32)
		if tile = LauncherTileId then InitializeLauncher((colCount + 2) * 16, 32)

		' When a special tile is encountered, we hav reached the next level.
		if tile = NextLevelTileId then NextLevel = true
    next

	' Map MMU0 back to ROM.
	NextReg($50,$FF)
end sub

sub InitializeGroundUnit(x as uinteger, y as uinteger)
	for i = 0 to NumberOfGroundUnits - 1
		if GroundUnitStatus(i) = 0 then
			GroundUnitPosX(i) = x
			GroundUnitPosY(i) = y
			GroundUnitStatus(i) = 1
			Exit for
		end if
	next i
end sub

sub InitializeLauncher(x as uinteger, y as uinteger)
	for i = 0 to NumberOfLaunchers - 1
		if LauncherStatus(i) = 0 then
			LauncherPosX(i) = x
			LauncherPosY(i) = y
			LauncherStatus(i) = 1
			Exit for
		end if
	next i
end sub

sub InitializeBuilding(x as uinteger, y as uinteger)
		if BuildingStatus = 0 then
			BuildingPosX = x
			BuildingPosY = y
			BuildingStatus = 1
		end if
end sub

' Reset background to initial values
sub InitialValues()
	TargetColumn = 0
	TargetRow = 0
	updateColumn = 0
	updateRow = 0
	ScrollPosX = 0
	ScrollPosY = 0
	WindowPosColumn = 0
	WindowPosRow = 0
	PixelScroll = 0
	for i = 0 to NumberOfGroundUnits - 1
		GroundUnitStatus(i) = 0
		RemoveSprite(GroundUnitSprite + i, 0)
	next i
	for i = 0 to NumberOfLaunchers - 1
		LauncherStatus(i) = 0
		RemoveSprite(LauncherSprite + i, 0)
	next i
	BuildingStatus = 0
	RemoveSprite(BuildingSprite, 0)
	RemoveSprite(BuildingSprite + 1, 0)
	RemoveSprite(BuildingSprite + 2, 0)
end sub

' Draw the initial background on Layer 2
sub SetupBackground(mapBank as ubyte, TileSpritesBank as ubyte)	
	dim address as uinteger = 0
	dim row, col as ubyte

	InitialValues()

	' Map MMU0 to the tile map bank
	NextRegA($50, mapBank) 
	' Our visible window to the tilemap is 12 rows x 16 columns

	for row = 0 to 11
		for col = 0 to 15 
			address = GetTileMapAddress(row, col)
			DoTileBank16(col,row,peek(address),TileSpritesBank) ' The actual tiles
		next col
	next row 

	' Map MMU0 back to ROM
	NextReg($50,$FF) 
end sub

' Setup the tiles and palettes for the current level.
sub PrepareLevel()
	' Tilemaps occupies two banks each, starting at bank 42.
	TileMapBank = 40 + Level * 2

	' Tiles occupies three banks each, starting at bank 30.
	TileSpritesBank = 27 + Level * 3

	' Palettes occupy one bank each, starting at bank 50.
	dim p as ubyte = 49 + Level

	' Select register for Layer2 first palette.
	NextReg(PALETTE_CONTROL_NR_43, %00010000)

	' Map MMU0 to the palette bank.
	NextRegA(MMU0_0000_NR_50, p)

	' Upload palette data.
	PalUpload(0,254,0)

	' Select register for Sprite first palette.
	NextReg(PALETTE_CONTROL_NR_43,%00100000)

	' Map MMU0 to the palette bank.
	NextRegA(MMU0_0000_NR_50, p)

	' Upload palette data.
	PalUpload(0,254,0)

	' Map MMU0 to ROM.
	NextReg(MMU0_0000_NR_50,$FF)

	Pause 0
end sub


' Check if two objects have collided.
' Parameters are x, y and altitude coordinates for both objects and the minimum distance between them before they collide.
' Collision can only occur if the altitude difference is less than 11 units.
function CheckCollision(x1 as integer, y1 as integer, a1 as byte, x2 as integer, y2 as integer, a2 as byte, distance as byte) as ubyte
	if abs(a1 - a2) > 10 then return false else
		if abs(x1 - x2) <= distance and abs(y1 - y2) <= distance
			return true
		else
			return false
		end if
	end if
end function

' Return the byte value at a given Layer2 coordinate.
function L2GroundAttribute(x as ubyte, y as ubyte, scrollIndexX as ubyte, scrollIndexY as ubyte, l2bank as ubyte) as ubyte

	#define RowsPerBank	32

	' Calculate a virtual Y-value by adding the scroll index (0-191) to Y.
	dim virtualY as uinteger = cast(uinteger, y) + cast(uinteger, scrollIndexY)
	' After reaching 191, the virtual Y-value resets to 0.
	if virtualY > 191 then virtualY = virtualY - 192
	' Calculate the bank index (0-5) for the virtual Y value.
	dim bankIndex as ubyte = int((virtualY) / RowsPerBank)
	' Calculate the actual bank number.
	dim bank as ubyte = l2bank + bankIndex
	' Calculate the Y-value within the bank (0-31)
	dim yInBank as ubyte = virtualY - RowsPerBank * bankIndex
	' Calculate memory address within the bank.
	dim address as uinteger = yInBank * 256 + x + scrollIndexX

	' BankPoke(bank,address,1) ' Show where on the screen the byte value is checked.
	' Return the byte value at the calculated memory address.
	return BankPeek(bank,address)

end function

' Check if a point is within the screen area.
function OutOfBounds(x as integer, y as integer) as ubyte
    if x < 0 or x > 320 or y < 0 or y > 256 then
        return true
    else 
        return false
    end if
end function

' Get the tile map index corresponding to a tile position on the
' screen (row 0-11, colum 0-15) in the current visible area
' at WindowPosRow and WindowPosColumn.
function GetTileMapAddress(row as ubyte, col as ubyte) as uinteger
	dim tileX, tileY as uinteger
	' The tilemap is 64 columns wide and 48 rows high.
	' We wrap the tilemap so that we can scroll it endlessly.
	if col + WindowPosColumn < MapWidth then tileX = col + WindowPosColumn else tileX = col + WindowPosColumn - MapWidth
	if row + WindowPosRow < MapHeight then tileY = row + WindowPosRow else tileY = row + WindowPosRow - MapHeight	
	RETURN tileX + tileY * MapWidth	
end function

stop

EffectsBank:
ASM
	incbin "data\ayfx.afb"
END ASM