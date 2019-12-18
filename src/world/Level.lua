--[[
    GD50 
    Final Project

    Author: Daniel Schwartz
    daniel.schwartz.music@gmail.com

    -- Level --
]]

Level = Class{}

function Level:init(camera, dungeon)
    self.camera = camera

    self.dungeon = Dungeon(100, 100, 8)

    self.player = Entity {
        -- spawn the player in the middle of the first room
        mapX = math.modf(self.dungeon.rooms[1].x + (self.dungeon.rooms[1].width / 2)),
        mapY =  math.modf(self.dungeon.rooms[1].y + (self.dungeon.rooms[1].height / 2)),
        width = 16,
        height = 16,
        animations = ENTITY_DEFS['player'].animations
    }

    --print(self.player.mapX.. ', ' .. self.player.mapY)

    self.player.stateMachine = StateMachine {
        ['walk'] = function() return PlayerWalkState(self.player, self) end,
        ['idle'] = function() return PlayerIdleState(self.player) end
    }
    self.player.stateMachine:change('idle')

    self.camera.offsetX = self.player.x - VIRTUAL_WIDTH / 2
    self.camera.offsetY = self.player.y - VIRTUAL_HEIGHT / 2
end

function Level:update(dt) 
    self.player:update(dt)
end

function Level:render()
    self.dungeon.floor:render(self.camera)
    self.dungeon.walls:render(self.camera)
    self.player:render(self.camera)
end
