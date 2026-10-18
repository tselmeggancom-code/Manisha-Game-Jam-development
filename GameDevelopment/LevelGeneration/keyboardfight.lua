local keyboardFight = {}
local letter = require("letters")
local WordPool = {"destroy","world","hatred","envy","rampage","dark","selfish","lost","control"}
local FallenWordPool = {"regret","failure","loss","cure","world","suffering","distress"}
local Bober = {"brains","food","eat","chomp","feast","devour","need","despair","hunger"}

keyboardFight.__index = keyboardFight

function keyboardFight:new()
    local instance = setmetatable({},keyboardFight)
    instance.elements = {}
    instance.TotalWords = ""
    instance.currentletter = ""
    instance.Timer = 20
    instance.SecondTimer = 1
    instance.CurrentKeyboard = nil
    instance.CurrentWord = 1
    return instance
end

--this needs to be placed in a lua file

function keyboardFight:GenerateWords(Enemy)
    self.elements = {}
    self.CurrentWord = 1
    local randomWord
    if Enemy == "Skeleton" then
        randomWord = WordPool[math.random(#WordPool)]
    elseif Enemy == "Fallen" then
        randomWord = FallenWordPool[math.random(#FallenWordPool)]
    elseif Enemy == "Zombie" then
        randomWord = Bober[math.random(#Bober)]
    end
    table.insert(self.elements, randomWord)
end

function keyboardFight:WordToString()
    for index,cur in ipairs(self.elements) do
        self.TotalWords = self.TotalWords .. cur
        self.TotalWords = self.TotalWords .. ","
    end
    self.TotalWords = self.TotalWords:sub(1,-2)
end

function keyboardFight:LengthOfWord()
    return #self.elements[self.CurrentWord]
end

function keyboardFight:Update(dt)
    self.SecondTimer = self.SecondTimer - (dt * 1) 
    if self.Timer == 0 then
        return false
    end
    if self.SecondTimer <= 0 then
        self.Timer = self.Timer - 1
        self.SecondTimer = 1
    end
end

function keyboardFight:RestorePreviousTime(PrevTimer)
    self.Timer = PrevTimer
end

function keyboardFight:Reset()
    self.elements = {}
    self.TotalWords = ""
    self.CurrentWord = 1
end

function keyboardFight:KillEnemyReward(EnemyType)
    local reward
    if EnemyType == "Skeleton" then
        reward = math.random(1,10)
    elseif EnemyType == "Zombie" then
        reward = math.random(1,10)
    elseif EnemyType == "Fallen" then
        reward = math.random(1,10)
    end
    return reward
end


function keyboardFight:BreakDownWords()
    local tempCollection = {}
    local word = self.elements[self.CurrentWord]
    for i = 1, #word do
        local char = word:sub(i,i)
        local LetterObject = letter:new()
        LetterObject:ChangeLetter(char)
        table.insert(tempCollection, LetterObject)
    end
    return tempCollection
end


return keyboardFight