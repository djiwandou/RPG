--[[
    GD50 
    Final Project

    Author: Daniel Schwartz
    daniel.schwartz.music@gmail.com

    -- Game Over State --

    This state is pushed when the player has been defeated.  From here
    you return back to the start state and restart the game loop.
]]

GameOverState = Class{__includes = BaseState}

function GameOverState:init()
    love.audio.stop()
    gMusic['gameover']:play()
end

function GameOverState:update(dt) 

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')
        or love.keyboard.wasPressed('space') then
        gSfx['menu_select']:play()
        gStateStack:push(FadeInState(BLACK, 1, true, 
        function ()
            gMusic['gameover']:stop()
            gStateStack:pop()
            gStateStack:push(StartState())
            gStateStack:push(FadeOutState(BLACK, 1, false))
        end))  
    end
end

function GameOverState:render()
    love.graphics.clear(0, 0, 0, 255)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 2 - 64, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf('Tekan Enter', 0, VIRTUAL_HEIGHT / 2 + 32, VIRTUAL_WIDTH, 'center')
end