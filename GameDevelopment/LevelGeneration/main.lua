local collectionofTiles = {}

local DrawingCollectionofTiles = {}
local tile = {}
local CollectionOfPath = {"Path5","Path1","Path2","Path3","Path4"}
local imageCache = {}
local gridWidth = 13 
local numbermax = 13
local stepstotal = 0
local currentLetter = nil
local currentEnemy = nil

tile.__index = tile

function tile.new(paramx, paramy, i, j)
    local instance = setmetatable({}, tile)
    instance.x = paramx         
    instance.y = paramy          
    instance.sizex = 50
    instance.sizey = 50
    instance.mapx = i           
    instance.mapy = j           
    instance.visited = false     
    instance.typeofTile = "Stone1"
    return instance
end

function tile:FindNormalNeighbours()
    local x = self.mapx
    local y = self.mapy
    local Interval = 1
    local n = {}

    if x - Interval >= 1 and collectionofTiles[x - Interval][y].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x - Interval][y])
    end
    if x + Interval <= gridWidth and collectionofTiles[x + Interval][y].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x + Interval][y])
    end
    if y - Interval >= 1 and collectionofTiles[x][y - Interval].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x][y - Interval])
    end
    if y + Interval <= numbermax and collectionofTiles[x][y + Interval].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x][y + Interval])   
    end
    return n
end

function tile:getSizeX() 
    return self.sizex 
end
function tile:getSizeY() 
    return self.sizey 
end 
function tile:GetX() 
    return self.x 
end
function tile:GetY() 
    return self.y 
end
function tile:GetMapX() 
    return self.mapx 
end
function tile:GetMapY() 
    return self.mapy 
end

function tile:GetImage()
    if not imageCache[self.typeofTile] then
        imageCache[self.typeofTile] = love.graphics.newImage("assets/" .. self.typeofTile .. ".png")
    end
    return imageCache[self.typeofTile]
end

function tile:GetVisited() 
    return self.visited 
end

function tile:SetVisited(boolval) 
    self.visited = boolval 
end

---------------------------------
local mapx = 155
local mapy = 5
local sx, sy
local animationCount = 0
local TableOfEnds = {}
local EnemiesCollection = {}
local AmountOfPath = {}
local tilemap
local enemyClass = require("enemy")
local stack = require("stack")
local player = require("player")
local universalsize = 50/12
local enemysize = 50/16
local startplayer = player:new("Player",0,0,0,0,10,200)
local timer = 1
local playerstart = nil
local OGPlayerDamage = 0
local EndTile = nil
local startblocker = true-- blocks the map entities from spawning in 
local cutscenetiles = {} -- this is repsonsible for the black tile cutscene
local FadeBool = false -- allows the fade in sequecne to occur
local FadeAlpha = 1 -- 1 is not transaprent and 0 is transparent
local gametext = love.graphics.newFont("assets/Font/GameFont.ttf",40)
local FightText = love.graphics.newFont("assets/Font/GameFont.ttf",55)
local CutsceneTimer = 0.05 -- timer for the cutscene of the fade screen
local length 
local CollectionOfWords 
local y = 250
local heartx = 20
local hearty = 20
local WordElement = 1
local FadeInBool = false
local FadeOutBool = false
local RandomX = nil
local RandomY = nil
local coinFade = 1
local TextPickUp = ""
local RedFade = 1
local CoinsVariables = {
    [0] = false, --coins collected
    [1] = 0, --TotalAmount
    [2] = love.graphics.newImage("assets/CoinsIcon.png"),
    CoinGottenAmount = 0
}
local PickUpTimer = 0 
local coiny = 0
local coinx = 0 
local ShopClass = require("shop")
local CoinsMoving = false
local CollectionOfCoinsandChest = {}
local coinImage = love.graphics.newImage("assets/Coin2.png")
local CurrentItem
local FightObjectPrevTimer
local timerImage = love.graphics.newImage("assets/Timer.png")
local RedFadeBool = false
local GameMechanic = require("keyboardfight")
local FightObject = GameMechanic:new()
local CurrentKeyboard = nil
local ScreenPopUpSize = nil
local AllKeyboards = {"Damage Keyboard","Gold Keyboard","Heart Keyboard","Damage multipliers keyboard"}
local DamageVisualsBlocker = false
local actualdamage = nil
local moonshine = require("moonshine") -- This was obtained by the moonshine crt effect thing 
local capslockVariables = { -- i started making structs this is very bad and inconsitente but what ever 
    on = false,
    CapsOnImage = love.graphics.newImage("assets/CapsOn.png"),
    CapsOffImage = love.graphics.newImage("assets/CapsOff.png")
}
local HealthBar = { -- the structs are very good i should i thought about this ages ago. The arrays (table) are so ambiegoues tahwt can store any data type
    Image = love.graphics.newImage("assets/HealthBar1.png"),
    HealthBarHp = 200,
    ShakeTimer = 0,
    CutImage = love.graphics.newImage("assets/Cut.png")
}
local KeyboardGame = {
    GameBool = false, -- This is to allow the keyboard game
    GameFade = false, -- you will always need to indicate the fade to start and what to run after the fade
    GameDialogueFade = false,
}
local SkeletonDialogue = {
    blocker = false,
    fade = false,
    timer = 0.5,
    currentword = "",
    lettercount = 1,
    introduction = {""},
    totalword = ""
}
local EndDialogue = {
    blocker = false,
    fade = false,
    timer = 0.5,
    currentword = "",
    lettercount = 1,
    introduction = {"This is just the beginning","Thanks for playing","Maybe part 2","But game jam was stressful"},
    totalword = ""
}
local Sounds = {
    CoinPickUpSoundEffect = love.audio.newSource("assets/Sounds/CoinPickUp.mp3","static"),
    FootStepsSoundEffect = love.audio.newSource("assets/Sounds/FootSteps.mp3","static"),
    KeyTypeSoundEffect = love.audio.newSource("assets/Sounds/KeyType.mp3","static"),
    ChestPickUpSoundEffect = love.audio.newSource("assets/Sounds/ChestPickUp.mp3","static"),
    BackGroundSoundEffect = love.audio.newSource("assets/Sounds/BackGround.mp3","static"),
    DeathSound = love.audio.newSource("assets/Sounds/DeathSound.mp3","static")
}
local LevelsDone = {
    Image = love.graphics.newImage("assets/Stairs.png"),
    Levels = 1
}
local shop = {
    ShopPassed = 0,
    playerimage = love.graphics.newImage("assets/Player.png"),
    Coin = love.graphics.newImage("assets/CoinsIcon.png"),
    heart = love.graphics.newImage("assets/Heart/1.png"),
    dmg = love.graphics.newImage("assets/dmg.png"),
    plus = love.graphics.newImage("assets/Add.png"),
    shopitems = {},
    blocker = false,
    fade = false,
    fadeShopEnd = false,
    ShopEnd = false
}
-- This is apart of the shop
local heatlh = ShopClass:new(600,190,20)
local stability = ShopClass:new(600,290,20)
local damage = ShopClass:new(600,390,20)
local ArrowShop = ShopClass:new(650,500,0)
local ResetButton = ShopClass:new(360,500,0)
local ResetButtonImage = love.graphics.newImage("assets/ResetButton.png")
local ArrowImage = love.graphics.newImage("assets/Arrow.png")
table.insert(shop.shopitems,heatlh)
table.insert(shop.shopitems,stability)
table.insert(shop.shopitems,damage)
local goldImage = love.graphics.newImage("assets/GoldFinish.png")
local LevelCutscene = love.graphics.newImage("assets/LevelCutscene.png")
--- do not touch as it needs to be global so it has full scope

local DialoguePictures = {
    SunImage = love.graphics.newImage("assets/Sun.png"),
    RadImage = love.graphics.newImage("assets/Rads.png"),
    HouseImage = love.graphics.newImage("assets/house.png"),
    MountainImage = love.graphics.newImage("assets/Mountains.png"),
    Tutorial = love.graphics.newImage("assets/Tutorial.png")
}

local Dialogue = {
    blocker = true,
    fade = false,
    timer = 0.5,
    currentword = "",
    lettercount = 1,
    CurrentImage = DialoguePictures.HouseImage,
    introduction = {"Made by Tceller","The year 2066 that destroyed the world","The unstable sun expanded","covering the world in flames and radiation","It mutated everyone on earth to monsters","There is a safe place in the mountains","You must go"},
    totalword = ""
}

local Tutorial = {
    blocker = false,
    fade = false,
    TutorialBool = false,  
    timer = 0.5,
    currentword = "",
    lettercount = 1,
    introduction = {"Use W A S D to move character ","Press r to full restart game","Press q to use health potion","Use keyboard typing during combat","Upgrade stability to replenish it in the shop","Beware of the health and timer during combat","Open chests to get items","Collect gold for upgrades every 4 levels",},
    totalword = ""
}
local healthPotion = {
    healthPotionImage = love.graphics.newImage("assets/Health Potion.png"),
    Gotten = false,
}

local stabilityIcon = { -- i was going to put in a function in here to calculate the fade value according to stab value but you cannot access local elements within the table
    image = love.graphics.newImage("assets/StabPicture.png"),
    fadevalue = 0
}

local DeathHandling = {
    ResetButton = love.graphics.newImage("assets/ResetButton.png"),
    Reason = "Took too long to kill",
    DeathBool = false,
    DeathFade = false,
    ResetFade = false,
    clicked = false,
    DeathByDarkness = false
}

local Skeleton = {
    Name = "Skeleton",
    Damage = 5
}

local Zombie = {
    Name = "Zombie",
    Damage = 20
}

local Fallen = {
    Name = "Fallen",
    Damage = 15
}

local LevelProgressCutscene = {
    blocker = false,
    fade = false,
    timer = 0.5,
    ImageBool = false,
    currentword = "",
    lettercount = 1,
    introduction = {"Delving deeper into the caves","The sense of urgency goes down"},
    totalword = ""
}

local EndMap = {
    tilemap,
    fade = false,
    blocker = false,
    TileGrid = {},
    CureTile = nil,
    GridMap = {
        {1,1,1,1,1,1},
        {1,0,0,0,0,1},
        {1,3,0,0,2,1},
        {1,0,0,0,0,1},
        {1,1,1,1,1,1}
        -- 1 is the The walls
        -- 0 is the stone flooring
        -- 5 is teh starting positino
        -- 3 
    }
}


local currentEnemyOnLevel



function StabCalculate()
    stabilityIcon.fadevalue = startplayer.Stab / startplayer.MaxStab
    stabilityIcon.fadevalue = 1 - stabilityIcon.fadevalue
end


function GetImageLocal()
    if not imageCache[CurrentKeyboard] and CurrentKeyboard ~= nil then
        imageCache[CurrentKeyboard] = love.graphics.newImage("assets/" .. CurrentKeyboard .. ".png")
    end
    return imageCache[CurrentKeyboard]
end


function love.load()
    Sounds.ChestPickUpSoundEffect:setVolume(0.3)
    Sounds.CoinPickUpSoundEffect:setVolume(0.3)
    Sounds.KeyTypeSoundEffect:setVolume(0.15)
    Sounds.DeathSound:setVolume(0.3)
    SkeletonDialogue.totalword = SkeletonDialogue.introduction[1]
    Dialogue.totalword = Dialogue.introduction[1]
    Tutorial.totalword = Tutorial.introduction[1]
    LevelProgressCutscene.totalword = LevelProgressCutscene.introduction[1]
    EndDialogue.totalword = EndDialogue.introduction[1]
    math.randomseed(os.time())
    effect = moonshine(moonshine.effects.filmgrain)
                    .chain(moonshine.effects.vignette)
                    .chain(moonshine.effects.chromasep)
                    .chain(moonshine.effects.crt)
    effect.filmgrain.size = 2
    love.graphics.setFont(gametext)
    tilemap = love.graphics.newCanvas(820, 670)
    love.graphics.setDefaultFilter("nearest", "nearest")
    EndMap.tilemap = love.graphics.newCanvas(820,670)
end

function ShopLevelObtain()
    local y = math.sin(love.timer:getTime() * 2) * 5 
    love.graphics.draw(shop.Coin,20,30)
    love.graphics.print(":".. tostring(CoinsVariables[1]),65,40) 
    love.graphics.draw(shop.playerimage,200,60)
    love.graphics.draw(stabilityIcon.image,100,290 + y)
    love.graphics.draw(shop.heart,100,190+ y)
    love.graphics.draw(shop.dmg,100,390 + y)
    love.graphics.rectangle("line",10,10,800,650)
    love.graphics.print("Upgrade Players Stats",200,75)
    love.graphics.print("Health stat",200,200)
    love.graphics.print("Stability stat",200,300)
    love.graphics.print("Damage stat",200,400)
    love.graphics.draw(shop.plus,600,390)
    love.graphics.draw(shop.plus,600,290)
    love.graphics.print("Cost "..damage.cost,655,405)
    love.graphics.print("Cost "..heatlh.cost,655,205)
    love.graphics.print("Cost "..stability.cost,655,305)
    love.graphics.draw(shop.plus,600,190)
    love.graphics.draw(ArrowImage,650,500)
    love.graphics.print("lvl "..heatlh.level,480,200)
    love.graphics.print("lvl "..stability.level,480,300)
    love.graphics.print("lvl "..damage.level,480,400)
end

function EndGameGen()
    love.graphics.setCanvas(EndMap.tilemap)
    EndMap.blocker = true
    love.graphics.clear()
    EndMap.TileGrid = {}
    local mapx = 300
    local mapy = 200
    for i = 1,5 do
        EndMap.TileGrid[i] = {}
        for j = 1,6 do
            local type = EndMap.GridMap[i][j]
            local newtile = tile.new(mapx,mapy,i,j)
            if type == 0 then
                newtile.typeofTile = "Path1"
            elseif type == 1 then
                newtile.typeofTile = "Stone1"
            elseif type == 2 then
                newtile.typeofTile = "Cure"
                EndMap.CureTile = newtile
            elseif type == 3 then
                playerstart = newtile
                newtile.typeofTile = "Start"
                startplayer.X = newtile:GetX()
                startplayer.Y = newtile:GetY()
                startplayer.GridX = i
                startplayer.GridY = j
            end
            EndMap.TileGrid[i][j] = newtile
            love.graphics.draw(newtile:GetImage(), newtile:GetX(), newtile:GetY(), 0, universalsize, universalsize)
            mapy = mapy + 50
        end
        mapy = 200
        mapx = mapx + 50
    end
    love.graphics.setCanvas()
end

function TileGen()
    for i = 1, gridWidth do
        collectionofTiles[i] = {}
        for j = 1, numbermax do
            local newtile = tile.new(mapx, mapy, i, j)
            collectionofTiles[i][j] = newtile
            table.insert(DrawingCollectionofTiles,newtile)
            newtile.typeofTile = "Stone1"
            mapy = mapy + 50
        end
        mapx = mapx + 50
        mapy = 5
    end
    mapx = 155
end


function DrawTiles()
    love.graphics.setCanvas(tilemap)
    love.graphics.clear()
    for _,newtile in ipairs(DrawingCollectionofTiles) do -- this was optimsied using a foreach loop by using another table brodem
        love.graphics.draw(newtile:GetImage(), newtile:GetX(), newtile:GetY(), 0,universalsize,universalsize)      
    end 
    love.graphics.setCanvas()
end



function getNeighbours(cell, Interval)
    local x, y = cell:GetMapX(), cell:GetMapY()
    local n = {}

    if x - Interval >= 1 and collectionofTiles[x - Interval][y]:GetVisited() == false then
        table.insert(n, collectionofTiles[x - Interval][y])
    end
    if x + Interval <= gridWidth and collectionofTiles[x + Interval][y]:GetVisited() == false then
        table.insert(n, collectionofTiles[x + Interval][y])
    end
    if y - Interval >= 1 and collectionofTiles[x][y - Interval]:GetVisited() == false then
        table.insert(n, collectionofTiles[x][y - Interval])
    end
    if y + Interval <= numbermax and collectionofTiles[x][y + Interval]:GetVisited() == false then
        table.insert(n, collectionofTiles[x][y + Interval])
    end

    return n
end

function MazeGen(enemy)
    ResetTiles()


    sx = math.random(1, gridWidth)
    if sx % 2 == 0 then sx = sx - 1 end
    sy = math.random(1, numbermax)
    if sy % 2 == 0 then sy = sy - 1 end

    local localStack = stack.new()
    local start = collectionofTiles[sx][sy]
    start:SetVisited(true)
    start.typeofTile = "Path5"
    localStack:Push(start)

    while localStack:ReturnLength() > 0 do
        local current = localStack:GetValues()[localStack.pointer - 1]
        local neighbours = getNeighbours(current, 2)
        if #neighbours > 0 then
            local nextCell = neighbours[math.random(#neighbours)]
            
            -- FIXED: Calculate midpoint using grid coordinates (mapx, mapy)
            local mx = math.floor((current:GetMapX() + nextCell:GetMapX()) / 2)
            local my = math.floor((current:GetMapY() + nextCell:GetMapY()) / 2)

            collectionofTiles[mx][my]:SetVisited(true)
            collectionofTiles[mx][my].typeofTile = "Path5"

            nextCell:SetVisited(true)
            nextCell.typeofTile = "Path5"

            localStack:Push(nextCell)
        else
            localStack:Pop()
        end
    end
    
    CountConnections(enemy)
    DrawTiles()
end

function FindNormalNeighbours(tile) -- Oneday optimise this to make it just a method in the tile class so you dont haveb to write two times
    -- this is because of that stupid other algorithims that i wrote man that it didnt work and then i realised it already had a method
    local x = tile:GetMapX()
    local y = tile:GetMapY()
    local Interval = 1
    local n = {}

    if x - Interval >= 1 and collectionofTiles[x - Interval][y].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x - Interval][y])
    end
    if x + Interval <= gridWidth and collectionofTiles[x + Interval][y].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x + Interval][y])
    end
    if y - Interval >= 1 and collectionofTiles[x][y - Interval].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x][y - Interval])
    end
    if y + Interval <= numbermax and collectionofTiles[x][y + Interval].typeofTile ~= "Stone1" then
        table.insert(n, collectionofTiles[x][y + Interval])   
    end
    return n
end




function CountConnections(enemies) 
    for i = 1, gridWidth do -- this can be optimised by adding the end nodes in the dfs i think
        for j = 1, numbermax do
            local curtile = collectionofTiles[i][j]
            
            if curtile.typeofTile == "Path5" then
                local NeighbourTiles = FindNormalNeighbours(curtile)
                
                -- Check if it's a dead end (only 1 neighbor)
                if #NeighbourTiles == 1 then
                    local decider = math.random(1, 4)

                    if playerstart == nil then
                        playerstart = curtile
                        curtile.typeofTile = "Start"
                        startplayer.X = curtile:GetX()
                        startplayer.Y = curtile:GetY()
                        startplayer.GridX = i
                        startplayer.GridY = j
                    else
                        if EndTile == nil then
                             EndTile = curtile
                             curtile.typeofTile = "End"
                             table.insert(CollectionOfCoinsandChest,curtile)
                        else
                            if decider < 3 then
                              local decide = math.random(1,2)
                              if decide == 1 then
                                curtile.typeofTile = "Chest" 
                                table.insert(CollectionOfCoinsandChest, curtile)
                              else
                                curtile.typeofTile = "Coin1"
                                table.insert(CollectionOfCoinsandChest,curtile) 
                              end
                            else
                                table.insert(TableOfEnds,curtile)
                            end           
                        end
                    end
                else 
                    table.insert(AmountOfPath, curtile)
                    local PathImage = CollectionOfPath[math.random(#CollectionOfPath)]
                    curtile.typeofTile = PathImage
                end
            end
        end
    end
    
    SpawnEnemy(enemies)
end

function SpawnEnemy(enemies) 
   local Enemyhp 
   if enemies.Name == "Skeleton" then
        Enemyhp = 75
   elseif enemies.Name == "Zombie" then
        Enemyhp = 140
   elseif enemies.Name == "Fallen" then
        Enemyhp = 110
   end
   for _,tiles in ipairs(TableOfEnds) do
        local enemyobject = enemyClass:new(1,tiles:GetMapX(),tiles:GetMapY(),tiles:GetX(),tiles:GetY(),enemies.Name,100,enemies.Damage)
        table.insert(EnemiesCollection,enemyobject)
        enemyobject:AiDetection(collectionofTiles,AmountOfPath)
   end
   currentEnemyOnLevel = enemies.Name
end

function ResetTiles()
    playerstart = nil
    EndTile = nil
    for i = 1, gridWidth do
        for j = 1, numbermax do
            local t = collectionofTiles[i][j]
            t:SetVisited(false)
            t.typeofTile = "Stone1"
        end
    end
    TableOfEnds= {}
    CollectionOfCoinsandChest = {}
    EnemiesCollection = {}
    AmountOfPath = {}
end

function ResetAnimation()
    cutscenetiles = {}
    startblocker = true
end


function ResetAllStats()
    LevelsDone.Levels = 1
    stabilityIcon.fadevalue = 0
    heatlh.level = 0
    stability.level = 0
    damage.level = 0
    startplayer.HP = 100
    startplayer.Damage = 10
    startplayer.MaxStab = 200
    startplayer.MaxHP = 100
    startplayer.Stab = 200
    CoinsVariables[1] = 0
    currentEnemy = nil
    healthPotion.Gotten = false
    CurrentKeyboard = nil
    KeyboardGame.GameBool = false
    KeyboardGame.GameFade = false
    KeyboardGame.GameDialogueFade = false
    WordElement = 1
    CollectionOfWords = {}
    actualdamage = nil
    FightObject:Reset()
    FightObject:RestorePreviousTime(FightObjectPrevTimer)
    HealthBar.HealthBarHp = 200
    HealthBar.ShakeTimer = 0
    DeathHandling.DeathBool = false
    DeathHandling.DeathFade = false
    DeathHandling.ResetFade = false
    DeathHandling.clicked = false
end

function FadeIn()
    FadeBool = true
    FadeInBool = true
    FadeOutBool = false
    FadeAlpha = 0
    CutsceneTimer = 0.05
end

function FadeOut()
    FadeBool = true
    FadeInBool = false
    FadeOutBool = true
    FadeAlpha = 1
    CutsceneTimer = 0.05
end

function LetterWordAnimation(cal,dt)
    for _, letter in ipairs(CollectionOfWords) do
        if letter:GetStatus() == true then
            letter.tran = letter.tran - cal
            if letter.tran < 0 then
                letter.tran = 0
            end
        end
        if letter.shakeTimer > 0 then
            letter.shakeTimer = letter.shakeTimer - dt
        end
    end
end

function UpdateOneTile(tile)
    love.graphics.setCanvas(tilemap)
    love.graphics.draw(tile:GetImage(),tile:GetX(),tile:GetY(),0,universalsize,universalsize)
    love.graphics.setCanvas()
end

function LoadUpGame(enemy)
    ResetAnimation()
    StartCutscene()
    MazeGen(enemy)
end


local LevelSelector = {
    shop = function()
        print("Shop presented")
         shop.fade = true
         FadeIn()
    end,
    End = function()
        print("THis is the end")
        EndMap.fade = true
        FadeIn()
    end,
    level123 = function()
        LoadUpGame(Skeleton)
        print("Level 1 2 3")
    end,
    level456 = function()
        LoadUpGame(Fallen)
        print("Level 4 5 6")
    end,
    level789 = function()
        LoadUpGame(Zombie)
        print("Level 7 8 9")
    end,
}

function WithinLevelSelector()
    if LevelsDone.Levels == 3 or LevelsDone.Levels == 7 or LevelsDone.Levels == 12 then
        return "shop"
    elseif LevelsDone.Levels == 13 then
        return "End"
    elseif LevelsDone.Levels < 3 then
        return "level123"
    elseif LevelsDone.Levels >= 4 and LevelsDone.Levels <= 7 then
        return "level456"
    elseif LevelsDone.Levels >= 8 and LevelsDone.Levels <= 12 then
        return "level789"
    end
end

function LevelManager()
    local currentlevelselector = WithinLevelSelector()
    if LevelSelector[currentlevelselector] then
        LevelSelector[currentlevelselector]()
    end
end


function PlayerOnImportantTile() 
    if EndMap.blocker == true then
            local x = startplayer.GridX
            local y = startplayer.GridY

            if x == EndMap.CureTile:GetMapX() and y == EndMap.CureTile:GetMapY() then -- the tile is not that imporatnt could just get the x and y coordinates as it is just one tile
                print("Worked")
                EndDialogue.blocker = true
            end
    end
    if startplayer ~= nil and EndMap.blocker == false then
        for index,tiles in ipairs(CollectionOfCoinsandChest) do
            if startplayer.GridX == tiles:GetMapX() and startplayer.GridY == tiles:GetMapY() then
                local TypeOfObject = tiles.typeofTile
                if TypeOfObject == "Coin1" then --This can be opimised aswell but i just copied and pasted pu tthis into a thing
                    coinFade = 1
                    ScreenPopUpSize = 50/12
                    tiles.typeofTile = "Path1"
                    coinx = tiles:GetX()
                    coiny = tiles:GetY()
                    local additionalgold = 0
                    if CurrentKeyboard == "Gold Keyboard" then
                        additionalgold = math.random(5,20)
                    end
                    CurrentItem = coinImage
                    CoinsVariables.CoinGottenAmount =  math.random(1,10) + additionalgold
                    TextPickUp = CoinsVariables.CoinGottenAmount .. " Coins"
                    CoinsVariables[1] = CoinsVariables[1] + CoinsVariables.CoinGottenAmount 
                    print(CoinsVariables.CoinGottenAmount)
                    Sounds.CoinPickUpSoundEffect:play()
                    CoinsVariables[0] = true
                    table.remove(CollectionOfCoinsandChest,index)
                    UpdateOneTile(tiles)
                    break                   
                end
                if TypeOfObject == "Chest" then
                    Sounds.ChestPickUpSoundEffect:play()
                    local chooser = math.random(1,5) --redudntat code should put in subroutine put what ever
                    if chooser > 3 then
                       coinFade = 1
                       OGPlayerDamage = 0 
                       ScreenPopUpSize = 1
                       coinx = tiles:GetX()
                       coiny = tiles:GetY()
                       CurrentItem = healthPotion.healthPotionImage
                       TextPickUp = "Health Potion"
                       CoinsVariables.CoinGottenAmount = nil
                       tiles.typeofTile = "OpenChest"
                       table.remove(CollectionOfCoinsandChest,index)
                       CoinsVariables[0] = true
                       healthPotion.Gotten = true
                       UpdateOneTile(tiles)
                       break
                    end
                    coinFade = 1
                    OGPlayerDamage = 0 
                    ScreenPopUpSize = 1
                    CurrentKeyboard = AllKeyboards[math.random(#AllKeyboards)]
                    coinx = tiles:GetX()
                    coiny = tiles:GetY()
                    CoinsVariables.CoinGottenAmount = nil
                    CurrentItem = GetImageLocal()
                    TextPickUp = CurrentKeyboard
                    if CurrentKeyboard == "Heart Keyboard" then
                      startplayer.HP = startplayer.MaxHP
                      startplayer.HP = math.floor(startplayer.HP * 1.25)
                    end
                    tiles.typeofTile = "OpenChest"
                    table.remove(CollectionOfCoinsandChest,index)
                    CoinsVariables[0] = true
                    UpdateOneTile(tiles)
                    break
                end
                if TypeOfObject == "End" then
                    LevelManager()
                    LevelsDone.Levels = LevelsDone.Levels + 1
                     break
                end
            end      
        end
    end
end

function BigShaketimer(dt)
    if HealthBar.ShakeTimer > 0 then
        HealthBar.ShakeTimer = HealthBar.ShakeTimer - dt
    end
end

function UpdateCoinAndItemPickUp(dt,cal)
    if CoinsVariables[0] == true then
        coiny = coiny + 2
        coinFade = math.max(0, coinFade - cal * 10)
        if coinFade <= 0 then
            coinFade = 1
            CoinsVariables[0] = false
        end
    end
end


function AddWordsToDialogue(ChoosenDialogue)
    if ChoosenDialogue.lettercount <= #ChoosenDialogue.totalword then
        if ChoosenDialogue.lettercount == #ChoosenDialogue.totalword then
            ChoosenDialogue.timer = 5
        end
        ChoosenDialogue.currentword = ChoosenDialogue.currentword ..
            ChoosenDialogue.totalword:sub(ChoosenDialogue.lettercount,ChoosenDialogue.lettercount)
        ChoosenDialogue.lettercount = ChoosenDialogue.lettercount + 1
        Sounds.KeyTypeSoundEffect:stop()
        Sounds.KeyTypeSoundEffect:play()
    else
        ChoosenDialogue.currentword = ""
        ChoosenDialogue.lettercount = 1
        table.remove(ChoosenDialogue.introduction,1)
        if #ChoosenDialogue.introduction > 0 then
            ChoosenDialogue.totalword = ChoosenDialogue.introduction[1]
        else
            ChoosenDialogue.totalword = ""
            if ChoosenDialogue == Tutorial then
                Tutorial.fade = true
                FadeIn()
            elseif ChoosenDialogue == Dialogue then
                Dialogue.fade = true
                FadeIn()
            elseif ChoosenDialogue == SkeletonDialogue then
                KeyboardGame.GameDialogueFade = true
                FadeIn()
            elseif ChoosenDialogue == LevelProgressCutscene then
                LevelProgressCutscene.fade = true
                FadeIn()
            elseif ChoosenDialogue == EndDialogue then
                EndDialogue.fade = true
                FadeIn()
            end
        end
    end
end


function textimerAdjust(ChoosenDialogue,cal)
    if not ChoosenDialogue.fade then
        if ChoosenDialogue.totalword == "" then
            return
        end
        ChoosenDialogue.timer = ChoosenDialogue.timer - cal * 5
        if ChoosenDialogue.timer <= 0 then
            ChoosenDialogue.timer = 0.5
            AddWordsToDialogue(ChoosenDialogue)
        end
    end
end

function DeathScreenDraw()
    local x = (820 - gametext:getWidth(DeathHandling.Reason)) / 2
    local y = math.sin(love.timer:getTime() * 2) * 5
    love.graphics.draw(love.graphics.newImage("assets/DeathImage.png"),260,100)
    love.graphics.draw(ResetButtonImage,360,500)
    love.graphics.print(DeathHandling.Reason,x,y + 400)
    love.graphics.rectangle("line",5,5,810,660)
end

function FadeAnimation(cal) 
    CutsceneTimer = CutsceneTimer - cal 
    if CutsceneTimer <= 0 then 
        CutsceneTimer = 0.05 
        if FadeInBool then 
            FadeAlpha = math.min(1, FadeAlpha + cal * 15) 
            if FadeAlpha >= 1 then 
                FadeAlpha = 1 
                FadeBool = false 
                FadeInBool = false 
                if Tutorial.fade then 
                    Tutorial.fade = false 
                    Tutorial.blocker = false 
                    TileGen() 
                    MazeGen(Skeleton) 
                    ResetAnimation() 
                    StartCutscene() 
                    FadeOut() 
                    Sounds.BackGroundSoundEffect:setLooping(true)
                    Sounds.BackGroundSoundEffect:setVolume(0.3)
                    Sounds.BackGroundSoundEffect:play()
                    print("Worked") 
                end 
                if Dialogue.fade then 
                    Dialogue.fade = false 
                    Dialogue.blocker = false 
                    Tutorial.blocker = true 
                end 
                if KeyboardGame.GameDialogueFade then 
                    KeyboardGame.GameDialogueFade = false 
                    SkeletonDialogue.blocker = false 
                    FadeOut()
                end 
                if EndDialogue.fade then
                    EndDialogue.fade = false
                    EndDialogue.blocker = false
                    love.event.quit()
                end
                if DeathHandling.DeathFade == true then
                    DeathHandling.DeathFade = false
                    DeathHandling.DeathBool = true
                end
                if DeathHandling.ResetFade == true then
                    DeathHandling.ResetFade = false
                    DeathHandling.DeathBool = false
                    shop.blocker = false
                    print("Reset")
                    DeathHandling.clicked = false
                    ResetAllStats()
                    TileGen() 
                    MazeGen(Skeleton) 
                    ResetAnimation() 
                    StartCutscene() 
                    FadeOut() 
                end
                if shop.fade then 
                    shop.fade = false 
                    shop.ShopEnd = true 
                    shop.blocker = true
                end 
                if LevelProgressCutscene.fade then
                    LevelProgressCutscene.blocker = false
                    LevelProgressCutscene.fade = false
                    LevelProgressCutscene.ImageBool = false
                    shop.ShopPassed = shop.ShopPassed + 1
                    local nextLevel = WithinLevelSelector()
                    LevelManager()
                    if nextLevel ~= "shop" and nextLevel ~= "End" then
                        FadeOut()
                    end
                end
                if KeyboardGame.GameFade then 
                    KeyboardGame.GameFade = false 
                    KeyboardGame.GameBool = true 
                end 
                if EndMap.fade then
                   EndMap.fade = false
                   EndGameGen()
                end
            end 
        elseif FadeOutBool then 
            FadeAlpha = math.max(0, FadeAlpha - cal * 5) 
            if FadeAlpha <= 0 then 
                FadeAlpha = 0 
                FadeBool = false 
                FadeOutBool = false 
            end 
        end 
    end 
end

function ChangeFightTimer()
   if currentEnemyOnLevel == "Skeleton" then
       FightObject.Timer = 20
   elseif currentEnemyOnLevel == "Zombie" then
       FightObject.Timer = 10
   elseif currentEnemyOnLevel then
       FightObject.Timer = 15
   end  
end

function love.update(dt)
    local cal = (dt * 1.2)
    if Tutorial.blocker == true then
        textimerAdjust(Tutorial,cal)
    elseif Dialogue.blocker == true then
        textimerAdjust(Dialogue,cal)
    elseif SkeletonDialogue.blocker == true then
        textimerAdjust(SkeletonDialogue,cal)
    elseif LevelProgressCutscene.blocker == true then
        textimerAdjust(LevelProgressCutscene,cal)  
    elseif EndDialogue.blocker then
        textimerAdjust(EndDialogue,cal)
    elseif DeathHandling.DeathBool ~= true then
        timer = timer - cal
        PickUpTimer = PickUpTimer - cal
        if KeyboardGame.GameBool == false and DeathHandling.DeathByDarkness == false and shop.blocker == false and KeyboardGame.GameBool == false and LevelProgressCutscene.blocker == false and EndMap.blocker == false then
            if startplayer.Stab < 2 then
                DeathHandling.Reason = "The darkness consumed you"
                DeathHandling.DeathFade = true
                Sounds.DeathSound:play()
                FadeIn()
                DeathHandling.DeathByDarkness = true
            end
            startplayer:StabilityReduce(dt)
        end

        if RedFadeBool == true then
            RedFade = math.max(0,RedFade - cal * 3)
            if RedFade <= 0 then
                RedFade = 1
                RedFadeBool = false
            end           
        end

        if PickUpTimer <= 0 then
            UpdateCoinAndItemPickUp(dt,cal)
            PickUpTimer = 0.1
        end

        if timer <= 0 and startblocker == true then
            local TempTile = table.remove(cutscenetiles,1)
            if #cutscenetiles > 0 then
                timer = 0.006
            else
                startblocker = false
                timer = 0.3
            end
        end

        if timer <= 0 and startblocker == false and KeyboardGame.GameBool == false then
            animationCount = animationCount + 1
            timer = timer + 0.2
            if animationCount > 3 then
                animationCount = 0
            end
            if shop.blocker == false and EndMap.blocker == false then
              for i,enemies in ipairs(EnemiesCollection) do
                enemies:ChangeAnimation(animationCount)

                local hitbool = enemies:CheckPlayer(startplayer)

                if hitbool == true and currentEnemy == nil then
                    print("Done")
                    KeyboardGame.GameFade = true
                    FadeIn()
                    currentEnemy = enemies
                    ChangeFightTimer() --Chnage the timer
                    FightObjectPrevTimer = FightObject.Timer
                    FightObject:GenerateWords(currentEnemyOnLevel)
                    FightObject:WordToString()
                    CollectionOfWords = FightObject:BreakDownWords()
                    CollectionOfWords[1].colour = {1,0,0}
                    length = FightObject:LengthOfWord()
                end
              end
            end
             startplayer:ChangeAnimation(animationCount)  
        end

        if KeyboardGame.GameBool == true then
            if FightObject:Update(dt) == false then
                KeyboardGame.GameBool = false
                DeathHandling.Reason = "Took too long to kill"
                DeathHandling.DeathFade = true
                Sounds.DeathSound:play()
                FadeIn()
                print("Dead")           
            else
                LetterWordAnimation(cal,dt)
                BigShaketimer(dt)
            end
        end
    end
    FadeAnimation(cal)
end

function EnemyAnimation()
    for index,enemies in ipairs(EnemiesCollection) do
        if enemies.EndPath ~= nil then
            if #(enemies.EndPath) > 0 then
                       local MoveTile = enemies.EndPath[1]
                       table.remove(enemies.EndPath,1)
                       enemies.X = MoveTile:GetX()
                       enemies.Y = MoveTile:GetY()
                       enemies.GridX = MoveTile:GetMapX()
                       enemies.GridY = MoveTile:GetMapY()
            else
                    enemies:AiDetection(collectionofTiles,AmountOfPath)
            end            
        end
    end
end

function RandomXandY()
    RandomX = math.random(50,750)
    RandomY = math.random(50,600)
end

function RemoveEnemy()
   for _, enemy in ipairs(EnemiesCollection) do
       if currentEnemy == enemy then
           table.remove(EnemiesCollection,_)
           break
       end
   end
end

function StartSkeletonDialogue(value) --This is becauses it always get removed so i need to make sure that it is not remoeved
    SkeletonDialogue.timer = 0.5
    SkeletonDialogue.currentword = ""
    SkeletonDialogue.lettercount = 1
    SkeletonDialogue.introduction = {
        "You obtained "..tostring(value) .. " Gold"
    }
    SkeletonDialogue.totalword = SkeletonDialogue.introduction[1]
end

function love.textinput(t)
    if KeyboardGame.GameBool then
        Sounds.KeyTypeSoundEffect:stop()
        local letter = CollectionOfWords[WordElement]
        local length = FightObject:LengthOfWord()
        if t == letter:getCurrentLetter() then
            letter:ChangeStatus(true)
            Sounds.KeyTypeSoundEffect:play()
            WordElement = WordElement + 1
            if WordElement <= length then
                CollectionOfWords[WordElement - 1].colour = {1, 0, 0}
                CollectionOfWords[WordElement].colour = {1,0,0}
            else
                if actualdamage == nil or actualdamage == 0 then
                    actualdamage = startplayer.Damage
                end

                if CurrentKeyboard == "Damage Keyboard" then
                    actualdamage = startplayer.Damage
                    actualdamage = actualdamage + math.floor(actualdamage*1.5)
                elseif CurrentKeyboard == "Damage multipliers keyboard" then
                    actualdamage = math.floor(actualdamage * 1.2)
                else
                    actualdamage = startplayer.Damage
                end
                RandomXandY()
                currentEnemy:HpChange(-actualdamage)
                HealthBar.ShakeTimer = 0.2
                HealthBar.HealthBarHp = (currentEnemy.HP / currentEnemy.OgHp) * 200
                if currentEnemy.HP <= 0 then
                     -- finsishe fight 
                    RemoveEnemy()
                    KeyboardGame.GameBool = false
                    HealthBar.HealthBarHp = 200
                    FightObject:Reset()
                    local value =  FightObject:KillEnemyReward(currentEnemy.OgType)
                    print("Killed enemy")
                    FightObject:RestorePreviousTime(FightObjectPrevTimer)
                    WordElement = 1
                    currentEnemy = nil
                    StartSkeletonDialogue(value) -- I will commerate this name becaues the first enemy was a skeleton for some reason but this handles all enemies talk
                    actualdamage = 0 -- This 
                    SkeletonDialogue.blocker = true
                    CoinsVariables[1] = CoinsVariables[1] + value -- do this after the fade transiton somewhere plaease
                else 
                    RedFadeBool = true
                    FightObject:GenerateWords(currentEnemyOnLevel)
                    CollectionOfWords = FightObject:BreakDownWords()
                    CollectionOfWords[1].colour = {1,0,0}
                    WordElement = 1
                end
            end
        else
            letter.shakeTimer = 0.1
            local afterhealth = startplayer.HP - currentEnemy.Damage
            if afterhealth <= 0 then
               startplayer.HP = 0
               print("Dead")
               DeathHandling.DeathFade = true
               Sounds.DeathSound:play()
               DeathHandling.Reason = "Enemy killed you"
               FadeIn()
               KeyboardGame.GameBool = false
            else
                startplayer:ChangeHp(-currentEnemy.Damage)
            end
        end
    end
end

function DamageVisuals()
    love.graphics.setColor(1, 0, 0, RedFade)
    love.graphics.draw(HealthBar.CutImage,RandomX - 5,RandomY - 20,0,2,2)
    love.graphics.print(tostring(actualdamage), RandomX, RandomY,0,2,2)
    love.graphics.setColor(1, 1, 1, 1)
end


function FunctionMovement(direction)
   startplayer:CheckMove(direction,collectionofTiles,numbermax,gridWidth)
   stepstotal = stepstotal + 1
   EnemyAnimation()
   PlayerOnImportantTile()
end

local KeyDirection ={ --optimised the keydirection movement atleast it moves correctly
    w = function(collectionofTiles)
       FunctionMovement("up")
    end,
    a = function(collectionofTiles)
       FunctionMovement("left")
    end,
    d = function(collectionofTiles)
        FunctionMovement("right")
    end,
    s = function(collectionofTiles)
        FunctionMovement("down")
    end,
    q = function()
        if healthPotion.Gotten == true then
          print("Drunk")
          healthPotion.Gotten = false
          FadeOut()
          startplayer:ChangeHp(20)          
        end
    end,
    r = function()
        print("Reset")
        ResetAllStats()
        TileGen() 
        MazeGen(Skeleton) 
        ResetAnimation() 
        StartCutscene() 
        FadeOut() 
    end
}


function love.keypressed(key)
    if key == "capslock" then
        if capslockVariables.on == false then
           capslockVariables.on = true
        else
            capslockVariables.on = false
        end
    end
    if EndMap.blocker == true and EndDialogue.blocker == false then
       if key == "w" then 
        startplayer:CheckMove("up", EndMap.TileGrid, 5, 6)
       elseif key == "s" then 
        startplayer:CheckMove("down", EndMap.TileGrid, 5, 6)
       elseif key == "a" then 
        startplayer:CheckMove("left", EndMap.TileGrid, 5, 6)
       elseif key == "d" then 
         startplayer:CheckMove("right", EndMap.TileGrid, 5, 6)
       end
        PlayerOnImportantTile()-- I could of put all these and classed as one bool but im too lazy to purposefully insert a bool is true and false at each state that is needed
    elseif KeyDirection[key] and KeyboardGame.GameBool == false and DeathHandling.DeathByDarkness == false and shop.blocker == false and KeyboardGame.GameBool == false and LevelProgressCutscene.blocker == false and EndMap.blocker == false and Tutorial.blocker == false and Dialogue.blocker == false and SkeletonDialogue.blocker == false then
        KeyDirection[key](collectionofTiles)
    end
    if key == "space" and Dialogue.blocker == true or Tutorial.blocker == true then
        print("Skip")
        Tutorial.fade = true
        Dialogue.fade = true
        FadeInBool = true
        FadeAnimation(1)
        Tutorial.blocker = false
        Dialogue.blocker = false
    end
end

function MoveEnemies()
    for _,enemies in ipairs(EnemiesCollection) do
        love.graphics.draw(enemies:GetImage(),enemies.X,enemies.Y,0,enemysize,enemysize)
    end
end


function InventoryBoxes()
    love.graphics.rectangle("line",8,600,60,60)
    love.graphics.rectangle("line",72,600,60,60)
    local CurrentImage = GetImageLocal()
    if CurrentImage ~= nil then
        love.graphics.draw(CurrentImage,47,594,1,1,1)       
    end
    if healthPotion.Gotten then
        love.graphics.draw(healthPotion.healthPotionImage,112,594,1,1,1)
    end
end


function FadeBoolAnimation()
    if FadeBool == true then
        love.graphics.setColor(0,0,0,FadeAlpha)
        love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
        love.graphics.setColor(1,1,1,1)
    end
end


function DrawDialogue(ChoosenDialogue) 
        local stepswobble = math.cos(love.timer.getTime() * 2) * 4
        local x = ((800 - gametext:getWidth(ChoosenDialogue.currentword))/ 2) + 10
        if ChoosenDialogue ~= EndDialogue then
            love.graphics.rectangle("line",10,10,800,420)
        end

        if ChoosenDialogue ~= SkeletonDialogue and ChoosenDialogue ~= LevelProgressCutscene and ChoosenDialogue ~= EndDialogue then
           love.graphics.print("Press Spacebar to skip",315,650,0,0.5)           
        end
        if ChoosenDialogue == Dialogue then
            if ChoosenDialogue.currentword == "The year 2066 that destroyed the world" then
                ChoosenDialogue.CurrentImage = DialoguePictures.SunImage
            elseif ChoosenDialogue.currentword == "covering the world in flames and radiation" then
                ChoosenDialogue.CurrentImage = DialoguePictures.RadImage
            elseif ChoosenDialogue.currentword == "It mutated everyone on earth to monsters" then
                ChoosenDialogue.CurrentImage = DialoguePictures.MountainImage
            end
            love.graphics.draw(ChoosenDialogue.CurrentImage,20,20)
        elseif ChoosenDialogue == Tutorial then
            love.graphics.draw(DialoguePictures.Tutorial,20,20)
        elseif ChoosenDialogue == SkeletonDialogue then
            love.graphics.draw(goldImage,20,20)
        elseif ChoosenDialogue == LevelProgressCutscene then
            love.graphics.draw(LevelCutscene,20,20)
        end
        if ChoosenDialogue ~= EndDialogue then
            love.graphics.rectangle("line",10,10,800,420)
            love.graphics.print(ChoosenDialogue.currentword,x,520 + stepswobble)
        elseif ChoosenDialogue == EndDialogue then
            love.graphics.print(ChoosenDialogue.currentword,x,310+ stepswobble)
        end
        FadeBoolAnimation()  
end

function love.draw()
    if Tutorial.blocker then
        DrawDialogue(Tutorial)
    elseif Dialogue.blocker then
        DrawDialogue(Dialogue)
    elseif SkeletonDialogue.blocker then
        DrawDialogue(SkeletonDialogue)
    elseif DeathHandling.DeathBool then
        DeathScreenDraw()
    elseif shop.blocker == true then
        ShopLevelObtain()
    elseif LevelProgressCutscene.blocker then
        DrawDialogue(LevelProgressCutscene)
    elseif EndDialogue.blocker then
        DrawDialogue(EndDialogue)
    elseif EndMap.blocker then
        love.graphics.draw(EndMap.tilemap,0,0)
        love.graphics.draw(startplayer:GetImage(),startplayer.X,startplayer.Y,0,enemysize,enemysize)
    else
        effect(function()
            love.graphics.draw(tilemap,0,0)
            if CoinsVariables[0] then
                love.graphics.setColor(1,1,0,coinFade)
                local sx = math.cos(love.timer:getTime() * 1) * 0.3
                love.graphics.print(TextPickUp,coinx,coiny - 10,0,0.5,0.5)
                love.graphics.draw(CurrentItem,coinx,coiny,sx,ScreenPopUpSize,ScreenPopUpSize,0,0)
                love.graphics.setColor(1,1,1,1)
            end

            if startblocker == true then
                CutsceneImages()
            end

            if startblocker == false then
                if shop.blocker == false then
                    love.graphics.draw(startplayer:GetImage(),startplayer.X,startplayer.Y,0,enemysize,enemysize)
                    InventoryBoxes()
                    MoveEnemies()
                end
                StabCalculate()
                love.graphics.setColor(0,0,0,stabilityIcon.fadevalue) --this makes the game darker
                love.graphics.rectangle("fill",0,0,820,670)
                love.graphics.setColor(1,1,1)
                local stepswobble = math.sin(love.timer.getTime() * 2) * 3
                love.graphics.draw(CoinsVariables[2],6,80 + stepswobble)
                love.graphics.print(tostring(CoinsVariables[1]),70,90 + stepswobble)
                love.graphics.draw(startplayer:checkHealth(),10,15 + stepswobble)
                love.graphics.draw(stabilityIcon.image,3,130 + stepswobble)
                love.graphics.print(tostring(startplayer.Stab),68,141 + stepswobble)
                love.graphics.print(tostring(startplayer.HP),70,30 + stepswobble)
                love.graphics.draw(LevelsDone.Image,2,190 + stepswobble)
                love.graphics.print(tostring(LevelsDone.Levels),70,205 + stepswobble)
            end

            FadeBoolAnimation()
            if KeyboardGame.GameBool == true then
                love.graphics.setColor(0,0,0)
                local shake = 0

                if HealthBar.ShakeTimer > 0 then
                    shake = math.sin(love.timer.getTime() * 50) * 10
                end

                love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
                love.graphics.setColor(1,0,0)
                love.graphics.rectangle("fill",300,502 + shake,HealthBar.HealthBarHp,47)

                local heartwobble = math.cos(love.timer.getTime() * 2) * 3
                love.graphics.print(tostring(FightObject.Timer),760,32)
                love.graphics.draw(timerImage,700,20,0,1,1,0,0)
                love.graphics.print(tostring(startplayer.HP),80,34 + heartwobble)
                love.graphics.draw(startplayer:checkHealth(),heartx,hearty + heartwobble,0,1,1,0,0)

                love.graphics.setColor(1,1,1)
                love.graphics.draw(HealthBar.Image,300,500 + shake)
                love.graphics.rectangle("line",5,5,810,660)

                local x = (810 - FightText:getWidth(FightObject.elements[FightObject.CurrentWord]))/2
                love.graphics.setFont(FightText)

                if capslockVariables.on then
                    love.graphics.draw(capslockVariables.CapsOnImage,350,600)
                else
                    love.graphics.draw(capslockVariables.CapsOffImage,350,600)
                end

                for index, cur in ipairs(CollectionOfWords) do
                    local shake = 0

                    if cur.shakeTimer > 0 then
                        shake = math.sin(love.timer.getTime() * 50) * 10
                    end
                    local letterwobble = math.sin(love.timer.getTime() * 2 + index) * 2
                    love.graphics.setColor(cur.colour[1],cur.colour[2],cur.colour[3],cur.tran)
                    love.graphics.print(cur:getCurrentLetter(),x,y + letterwobble + shake)
                    x = x + FightText:getWidth(cur:getCurrentLetter())
                end

                love.graphics.setFont(gametext)
            end

            if RedFadeBool == true then
                DamageVisuals()
            end
        end)
    end
end

function StartCutscene() 
    cutscenetiles = {}
    local mapX = 155
    local mapY = 5
    for i = 1, gridWidth do
        for j = 1, numbermax do
            local newtile = tile.new(mapX, mapY, i, j)
            table.insert(cutscenetiles,newtile)
            newtile.typeofTile = "Empty"
            mapY = mapY + 50
        end
        mapX = mapX + 50
        mapY = 5
    end
end

function CutsceneImages()
    for i,tiles in ipairs(cutscenetiles) do
        love.graphics.draw(tiles:GetImage(),tiles.x,tiles.y,0,universalsize,universalsize)
    end
end

function StatIncrease(shop)
    if shop == heatlh then
        startplayer.MaxHP = startplayer.MaxHP + 20
        print(startplayer.MaxHP)
    elseif shop == damage then
        startplayer.Damage = startplayer.Damage + 5
        print(startplayer.Damage)
    elseif shop == stability then
        startplayer.MaxStab = startplayer.MaxStab + 20
        startplayer.Stab = startplayer.MaxStab
        print(startplayer.Stab)
    end
end

function StartLevelProgressCutscene()
    LevelProgressCutscene.blocker = true
    LevelProgressCutscene.fade = false
    LevelProgressCutscene.timer = 0.5
    LevelProgressCutscene.currentword = ""
    LevelProgressCutscene.lettercount = 1

    if shop.ShopPassed == 0 then
        LevelProgressCutscene.introduction = {
        "The caves get darker",
        "Is there any chance of meeting survivors",
        "It looks like it is only you"
        }
    end
    if shop.ShopPassed == 1 then
        LevelProgressCutscene.introduction = {
        "Delving deeper into the caves",
        "The stableness of the mind",
        "falls"
        }
    end
    if shop.ShopPassed == 2 then
        LevelProgressCutscene.introduction = {
        "The immense pressure is building",
        "The will to survive is lowering"
        }
    end

    LevelProgressCutscene.totalword =
        LevelProgressCutscene.introduction[1]
end

function love.mousepressed(x, y, button) -- keep this key mouse thing for testing purposes. 
    if button == 1 and shop.blocker == true then
         for _,pluses in ipairs(shop.shopitems) do
             if pluses:Clicked(x,y,50) then
                if pluses:IncrementLevel(CoinsVariables[1]) then
                    Sounds.CoinPickUpSoundEffect:stop()
                    Sounds.CoinPickUpSoundEffect:play()
                    CoinsVariables[1] = CoinsVariables[1] - pluses.cost
                    pluses:IncrementCost()
                    StatIncrease(pluses)
                    FadeOut()
                    print("WORKEd") 
                    break;
                end
             end
         end
        if ArrowShop:Clicked(x,y,100) then
              shop.blocker = false
              LevelProgressCutscene.ImageBool = true
             StartLevelProgressCutscene()
        end
    elseif button == 1 and DeathHandling.DeathBool == true and DeathHandling.clicked == false then
        if ResetButton:Clicked(x,y,100) then
            DeathHandling.clicked = true
            Sounds.DeathSound:stop()
            print("Worked")
            DeathHandling.ResetFade = true
            DeathHandling.DeathByDarkness = false
            FadeIn()
        end
    end 
end