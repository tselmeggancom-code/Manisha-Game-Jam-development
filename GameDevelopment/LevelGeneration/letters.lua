local letter = {}
letter.__index = letter

function letter:new()
    local instance = setmetatable({},letter)
    instance.Typed = false
    instance.CurLetter = ""
    instance.tran = 1
    instance.shakeTimer = 0
    instance.colour = {1,1,1}
    instance.DamageShown = nil

    return instance
end


function letter:ChangeLetter(NewLetter)
    if NewLetter == "," then
        self.DamageShown = false
    end
    self.CurLetter = NewLetter
end

function letter:getCurrentLetter()
    return self.CurLetter
end

function letter:ChangeStatus(status)
    self.Typed = status
end

function letter:GetStatus()
    return self.Typed
end

return letter