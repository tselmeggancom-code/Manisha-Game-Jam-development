local Shop = {}
Shop.__index = Shop

function Shop:new(PassScreenX,PassScreenY,Cost)
   local instance = setmetatable({},Shop)
   instance.ScreenX = PassScreenX
   instance.ScreenY = PassScreenY
   instance.cost = Cost
   instance.level = 0
   return instance
end

function Shop:Clicked(MouseX,MouseY,ControlSize)
   if self.ScreenX + ControlSize >= MouseX and MouseX >= self.ScreenX and MouseY >= self.ScreenY and MouseY <= self.ScreenY + ControlSize then
       return true
   end  
end


function Shop:IncrementLevel(playercoins)
    if playercoins - self.cost >= 0 then
        if self.level < 3 then
            self.level = self.level + 1
            return true
        else
            return false
        end
    end
    return false
end

function Shop:IncrementCost()
    if self.level == 1 then
        self.cost = 50
    end
    if self.level == 2 then
        self.cost = 100
    end
    if self.level == 3 then
        self.cost = 100
    end
end

return Shop