local aistack = {}
aistack.__index = aistack
--This was obaitned from another project of random path set for game

function aistack.new() --constructor with the metatable to make the instance
   local instance = setmetatable({},aistack) -- this allows the creation of the instance
   instance.pointer = 1
   instance.paths = {}
   instance.tableValues = {}
   instance.MaxP = 101
   return instance
end

function aistack:Push(value, path) -- push in stack
    if (self.pointer < self.MaxP) then
        table.insert(self.paths, self.pointer, path)
        table.insert(self.tableValues, self.pointer, value)
        self.pointer = self.pointer + 1    
    end
end

function aistack:Pop() -- Pop in stack
    if (self.pointer > 1) then -- it is not a zero based indexed language
        local lastPath = table.remove(self.paths)
        self.pointer = self.pointer - 1
        local lastValue = table.remove(self.tableValues)
        return lastValue, lastPath
    end
end

function aistack:GetValues() -- getter to get values
    return self.tableValues
end

function aistack:ReturnLength() -- getter to get length of values
    return #self.tableValues
end
--This is the stack inplementation#
local collectionofTiles = {}
---------------------------------------------------------------------------------------------------------------------


local enemy = {}
enemy.__index = enemy
local imagecache = {}
local endpath = {}

function enemy:new(PassedRange,NewGridX,NewGridY,X,Y,EnemyType,HP,passedDamage)
    local instance = setmetatable({},enemy)
    instance.range = PassedRange
    instance.GridX = NewGridX
    instance.GridY = NewGridY
    instance.Type = EnemyType
    instance.OgType = EnemyType
    instance.X = X
    instance.Y = Y
    instance.EndPath = nil
    instance.OgHp = HP
    instance.HP = HP
    instance.Damage = passedDamage
    return instance
end

local hearts = {
    [0] = love.graphics.newImage("assets/Heart/1.png"),
    [1] = love.graphics.newImage("assets/Heart/2.png"),
    [2] = love.graphics.newImage("assets/Heart/3.png")
}


function enemy:GetImage()
   if not imagecache[self.Type] then
       imagecache[self.Type] = love.graphics.newImage("assets/"..self.Type..".png")
       return imagecache[self.Type]
   end
   return imagecache[self.Type]
end


function enemy:ChangeAnimation(decider)
    local EnemyImageGrabber = self.OgType
    if decider == 0 then --Dont know how to do switch case but could have been switch case for this condition
        self.Type = EnemyImageGrabber
    elseif decider == 1 then
        self.Type = EnemyImageGrabber.."1"
    elseif  decider == 2 then
        self.Type = EnemyImageGrabber.."2"
    elseif  decider == 3 then
        self.Type = EnemyImageGrabber.."3"
    end
end

function enemy:HpChange(ChangeParam)
    self.HP = self.HP + ChangeParam
end



function enemy:AiDetection(gridmap,pathcollection)
    local stack = aistack:new()
    local RootNode = gridmap[self.GridX][self.GridY]
    local path = {RootNode}
    local Visited = {}
    stack:Push(RootNode, path)
    local endgoal = pathcollection[math.random(#pathcollection)]
    Visited[RootNode] = true
    while stack:ReturnLength() > 0 do 
        local current,newpath = stack:Pop()
        local neighbours = current:FindNormalNeighbours(1)


        if current == endgoal then
           endpath = newpath
           self.EndPath = endpath
           break
        end

        for index,tiles in ipairs(neighbours) do
            if not Visited[tiles] then
                    Visited[tiles] = true
                    local newPath = {unpack(newpath)}
                    table.insert(newPath, tiles)
                    stack:Push(tiles, newPath)
            end 
        end
    end
end


function enemy:CheckPlayer(player)
    if self.GridX == player.GridX and self.GridY == player.GridY then
        return true
    end
    if self.GridX - 1 >= 1 then -- left
            if player.GridX == self.GridX - 1 and player.GridY == self.GridY then
                return true
            end
    end
    if self.GridX + 1 <= 13 then -- right
            if player.GridX == self.GridX + 1 and player.GridY == self.GridY then
                return true
            end
    end  
    if self.GridY - 1 >= 1 then -- up
            if player.GridY == self.GridY - 1 and player.GridX == self.GridX then
                return true
            end
    end 
    if self.GridY + 1 <= 13 then -- down
            if player.GridY == self.GridY + 1 and player.GridX == self.GridX then
                return true
            end
    end
    return false
end

return enemy