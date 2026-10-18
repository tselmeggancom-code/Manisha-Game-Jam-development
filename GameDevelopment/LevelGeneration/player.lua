local player = {}
local imagecache = {}
player.__index = player


local animations = {
    [0] = "Player",
    [1] = "Player1",
    [2] = "Player2",
    [3] = "Player3"
}

local keyboards = {
    DamageMultiplier = false,
    IncreaseTimer = false,
    DamageIncrease = false,
    DoubleCoins = false
}

local hearts = {
    [0] = love.graphics.newImage("assets/Heart/1.png"),
    [1] = love.graphics.newImage("assets/Heart/2.png"),
    [2] = love.graphics.newImage("assets/Heart/3.png")
}

function player:new(TypeOfImage,X,Y,GridX,GridY,DMG,Stab)
    local instance = setmetatable({},player)
    instance.Type = TypeOfImage
    instance.X = X
    instance.Y = Y
    instance.GridX = GridX
    instance.GridY = GridY
    instance.Damage = DMG
    instance.StabTimer = 2
    instance.HP = 100
    instance.Stab = Stab
    instance.MaxStab = Stab
    instance.MaxHP = 100
    return instance
end

local actions = {
    up = function(selfp,GridMap,x1,y1)
        if selfp.GridY - 1 >= 1 and GridMap[selfp.GridX][selfp.GridY - 1].typeofTile ~= "Stone1" then
            selfp.GridY = selfp.GridY - 1
            selfp.Y = selfp.Y - 50
        end
    end,
    down = function(selfp,GridMap,x1,y1)
        if selfp.GridY + 1 <= y1 and GridMap[selfp.GridX][selfp.GridY + 1].typeofTile ~= "Stone1" then
            selfp.GridY = selfp.GridY + 1
            selfp.Y = selfp.Y + 50
        end
    end,
    left = function(selfp,GridMap,x1,y1)
        if selfp.GridX - 1 >= 1 and GridMap[selfp.GridX - 1][selfp.GridY].typeofTile ~= "Stone1" then
            selfp.GridX = selfp.GridX - 1
            selfp.X = selfp.X - 50
        end
    end,
    right = function(selfp,GridMap,x1,y1)
        if selfp.GridX + 1 <= x1 and GridMap[selfp.GridX + 1][selfp.GridY].typeofTile ~= "Stone1" then
            selfp.GridX = selfp.GridX + 1
            selfp.X = selfp.X + 50 
        end
    end
}

function player:GetImage()
   if not imagecache[self.Type] then
       local image = love.graphics.newImage("assets/".. self.Type .. ".png")
       imagecache[self.Type] = image
       return image
   else
      return imagecache[self.Type]
   end
end

function player:CheckMove(direction,GridMap,x,y)
    if actions[direction] then
        actions[direction](self,GridMap,x,y)
    end
end

function player:StabilityReduce(dt)
    local cal = dt
    self.StabTimer = self.StabTimer - cal
    if self.StabTimer <= 0 then
       self.StabTimer = 2
       self.Stab = self.Stab - 2 
    end
end


function player:ChangeAnimation(decider)
    self.Type = animations[decider] --better like switch case
end

function player:ChangeHp(number)
    if self.HP + number < self.MaxHP then
        self.HP = self.HP + number 
    else
        self.HP = self.MaxHP
    end
end


function player:checkHealth() 
   if self.HP <= 60 and self.HP > 20 then
       return hearts[1]
   elseif self.HP <= 20 then
       return hearts[2]
   else
    return hearts[0]
   end
end



return player
