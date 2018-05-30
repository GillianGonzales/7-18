-----------------------------------------------------------------------------------------
--
-- scene1.lua
--
-- Created By Gillian Gonzales	
-- Created On May 15 2018
--
-- This file will show a level
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local physics = require( "physics" )
local json = require( "json" )
local tiled = require ( "com.ponywolf.ponytiled")

local scene = composer.newScene()

local enemy = nil
local ninjaBoy = nil
local map = nil
local rightArrow = nil
local jumpButton = nil
local shootButton = nil
local playerBullets = {}

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function onRightArrowTouch( event )
    if (event.phase == "began") then
        if ninjaBoy.sequence ~= "run" then
            ninjaBoy.sequence = "run"
            ninjaBoy:setSequence ( "run" )
            ninjaBoy:play()
        end

    elseif (event.phase == "ended") then
        if ninjaBoy.sequence ~= "idle" then
            ninjaBoy.sequence = "idle"
            ninjaBoy:setSequence( "idle" )
            ninjaBoy:play()
        end
    end
    return true
end

local function onJumpButtonTouch( event )
    if (event.phase == "began") then
        if ninjaBoy.sequence ~= "jump" then
            ninjaBoy.sequence = "jump"
            ninjaBoy:setLinearVelocity( 100, -1050)
            ninjaBoy:setSequence ( "jump" )
            ninjaBoy:play()
        end

    elseif (event.phase == "ended") then

    end
    return true
end

local moveNinjaBoy = function ( event )

    if ninjaBoy.sequence == "run" then
        transition.moveBy(ninjaBoy, {
            x = 10,
            y = 0,
            time = 0,
            })
    end

    if ninjaBoy.sequence == "jump" then
        local ninjaBoyVelocityX, ninjaBoyVelocityY = ninjaBoy:getLinearVelocity()

        if ninjaBoyVelocityY == 0 then
            ninjaBoy.sequence = "idle"
            ninjaBoy:setSequence( "idle" )
            ninjaBoy:play()
        end

    end
end


local checkingPlayerBulletsOutOfBounds = function ( event )
    -- check if any bullets have gone off the screen
    local bulletCounter

    if #playerBullets > 0 then
        for bulletCounter = #playerBullets, 1 ,-1 do
            if playerBullets[bulletCounter].x > display.contentWidth + 1000 then
                playerBullets[bulletCounter]:removeSelf()
                playerBullets[bulletCounter] = nil
                table.remove(playerBullets, bulletCounter)
                print("remove bullet")
            end
        end
    end
end

local ninjaThrow = function ( event )
    ninjaBoy.sequence = "idle"
    ninjaBoy:setSequence( "idle" )
    ninjaBoy:play()
end

local function onShootButtonTouch( event )
    if ( event.phase == "began" ) then
        if ninjaBoy.sequence ~= "throw" then
            ninjaBoy.sequence = "throw"
            ninjaBoy:setSequence ("throw")
            ninjaBoy:play()
            timer.performWithDelay( 500, ninjaThrow )
            -- make a bullet appear
            local aSingleBullet = display.newImage( "./assets/sprites/Kunai.png" )
            aSingleBullet.x = ninjaBoy.x
            aSingleBullet.y = ninjaBoy.y
            physics.addBody( aSingleBullet, 'dynamic' )
            -- Make the object a "bullet" type object
            aSingleBullet.isBullet = true
            aSingleBullet.gravityScale = 0
            aSingleBullet.id = "bullet"
            aSingleBullet:setLinearVelocity( 1500, 0 )
            aSingleBullet.isFixedRotation = true

            table.insert(playerBullets,aSingleBullet)
            print("# of bullet: " .. tostring(#playerBullets))
        end
    elseif (event.phase == "ended" ) then

    end
    return true
end

local function enemyShot( event )
    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2
        local whereCollisonOccurredX = obj1.x
        local whereCollisonOccurredY = obj1.y

        if ( ( obj1.id == "enemy" and obj2.id == "bullet" ) or
             ( obj1.id == "bullet" and obj2.id == "enemy" ) ) then

            for bulletCounter = #playerBullets, 1, -1 do
                if ( playerBullets[bulletCounter] == obj1 or playerBullets[bulletCounter] == obj2 ) then
                    playerBullets[bulletCounter]:removeSelf()
                    playerBullets[bulletCounter] = nil
                    table.remove( playerBullets, bulletCounter )
                    break
                end
            end

            --death animation
            enemy.sequence = "dead"
            enemy:setSequence( "dead" )
            enemy:play()

            transition.to( enemy, { time=2000, x=x, y=y, alpha = 0 } )

            local removeEnemy = function ( event )
                enemy:removeSelf()
                enemy = nil
            end
                

            timer.performWithDelay( 3000, removeEnemy) 


            -- Increase score
            print ("you could increase a score here.")

            -- make an explosion sound effect
            local expolsionSound = audio.loadStream( "./assets/sounds/8bit_bomb_explosion.wav" )
            local explosionChannel = audio.play( expolsionSound )

             -- make an explosion happen
            -- Table of emitter parameters
            local emitterParams = {
                startColorAlpha = 1,
                startParticleSizeVariance = 250,
                startColorGreen = 0.3031555,
                yCoordFlipped = -1,
                blendFuncSource = 770,
                rotatePerSecondVariance = 153.95,
                particleLifespan = 0.7237,
                tangentialAcceleration = -1440.74,
                finishColorBlue = 0.3699196,
                finishColorGreen = 0.5443883,
                blendFuncDestination = 1,
                startParticleSize = 400.95,
                startColorRed = 0.8373094,
                textureFileName = "./assets/sprites/fire.png",
                startColorVarianceAlpha = 1,
                maxParticles = 256,
                finishParticleSize = 540,
                duration = 0.25,
                finishColorRed = 1,
                maxRadiusVariance = 72.63,
                finishParticleSizeVariance = 250,
                gravityy = -671.05,
                speedVariance = 90.79,
                tangentialAccelVariance = -420.11,
                angleVariance = -142.62,
                angle = -244.11
            }
            local emitter = display.newEmitter( emitterParams )
            emitter.x = whereCollisonOccurredX
            emitter.y = whereCollisonOccurredY

        end
    end
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
	physics.start()
	physics.setGravity(0, 50)

    local filename = "assets/maps/level0.json"
    local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ))
    map = tiled.new( mapData, "assets/maps")
    
    local sheetOptionsIdle = require("assets.spritesheets.ninjaBoy.ninjaBoyIdle")
    local sheetIdleNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyIdle.png", sheetOptionsIdle:getSheet() )

    local sheetOptionsRun = require("assets.spritesheets.ninjaBoy.ninjaBoyRun")
    local sheetRunNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyRun.png", sheetOptionsRun:getSheet() )

    local sheetOptionsJump = require("assets.spritesheets.ninjaBoy.ninjaBoyJump")
    local sheetJumpNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyJump.png", sheetOptionsJump:getSheet() )

    local sheetOptionsThrow = require("assets.spritesheets.ninjaBoy.ninjaBoyThrow")
    local sheetThrowNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyThrow.png", sheetOptionsThrow:getSheet() )

    local sheetOptionsDead = require("assets.spritesheets.ninjaBoy.ninjaBoyDead")
    local sheetDeadNinja = graphics.newImageSheet("./assets/spritesheets/ninjaBoy/ninjaBoyDead.png", sheetOptionsDead:getSheet() )

    local sequence_data = {
        {
            name = "idle",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetIdleNinja
        },
        {
            name = "run",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetRunNinja
        },
        {
            name = "jump",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 1,
            sheet = sheetJumpNinja
        },
        {
            name = "throw",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 1,
            sheet = sheetThrowNinja
        },
        {
            name = "dead",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 1,
            sheet = sheetDeadNinja        
        }
    }

    local sheetOptionsIdleEnemy = require("assets.spritesheets.zombieMale.zombieMaleIdle")
    local sheetIdleEnemy = graphics.newImageSheet("./assets/spritesheets/zombieMale/zombieMaleIdle.png", sheetOptionsIdleEnemy:getSheet() )

    local sheetOptionsDeadEnemy = require("assets.spritesheets.zombieMale.zombieMaleDead")
    local sheetDeadEnemy = graphics.newImageSheet("./assets/spritesheets/zombieMale/zombieMaleDead.png", sheetOptionsDeadEnemy:getSheet() )

    local sequence_data2 = { 
        {
            name = "idle",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 0,
            sheet = sheetIdleEnemy
        },
        {
            name = "dead",
            start = 1,
            count = 10,
            time = 800,
            loopCount = 1,
            sheet = sheetDeadEnemy        
        }
    }

    ninjaBoy = display.newSprite( sheetIdleNinja, sequence_data)
    physics.addBody( ninjaBoy, "dynamic", { density = 3, bounce = 0, friction = 1.0 })
    ninjaBoy.isFixedRotation = true
    ninjaBoy.x = 500
    ninjaBoy.y = 0 
    ninjaBoy.sequence = "idle"
    ninjaBoy:setSequence("idle")
    ninjaBoy:play()

    enemy = display.newSprite( sheetIdleEnemy, sequence_data2)
    physics.addBody( enemy, "dynamic", { density = 3, bounce = 0, friction = 1.0 })
    enemy.isFixedRotation = true
    enemy.x = 1900
    enemy.y = 0 
    enemy.id = "enemy"
    enemy.sequence = "idle"
    enemy:setSequence("idle")
    enemy:play()

    rightArrow = display.newImageRect("./assets/sprites/rightButton.png",200,200 )
    rightArrow.x = 200
    rightArrow.y = display.contentHeight - 300

    jumpButton = display.newImageRect("./assets/sprites/jumpButton.png",128,128 )
    jumpButton.x = 400
    jumpButton.y = display.contentHeight - 300

    shootButton = display.newImageRect("./assets/sprites/jumpButton.png",128,128 )
    shootButton.x = 600
    shootButton.y = display.contentHeight - 300

    sceneGroup:insert( map )
    sceneGroup:insert( ninjaBoy )
    sceneGroup:insert( enemy ) 
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        sceneGroup:insert( shootButton)
        sceneGroup:insert( rightArrow )
        sceneGroup:insert( jumpButton )
        rightArrow:addEventListener("touch",onRightArrowTouch)
        jumpButton:addEventListener("touch",onJumpButtonTouch)
        shootButton:addEventListener("touch",onShootButtonTouch)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener("enterFrame",checkingPlayerBulletsOutOfBounds)
        Runtime:addEventListener("enterFrame",moveNinjaBoy)
        Runtime:addEventListener("collision", enemyShot ) 
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        rightArrow:addEventListener("touch",onRightArrowTouch)
        jumpButton:addEventListener("touch",onJumpButtonTouch)
        shootButton:addEventListener("touch",onShootButtonTouch)
        Runtime:addEventListener("enterFrame",moveNinjaBoy)
        Runtime:addEventListener("enterFrame",checkingPlayerBulletsOutOfBounds)
        Runtime:addEventListener("collision", enemyShot )
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene