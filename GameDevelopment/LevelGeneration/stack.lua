local stack = {}
stack.__index = stack

function stack.new()
   local instance = setmetatable({}, stack)
   instance.pointer = 1
   instance.tableValues = {}
   instance.MaxP = 101
   return instance
end

function stack:Push(value)
    if (self.pointer < self.MaxP) then
        table.insert(self.tableValues, self.pointer, value)
        self.pointer = self.pointer + 1    
    end
end

function stack:Pop()
    if (self.pointer > 1) then
        self.pointer = self.pointer - 1
        local poppedval = self.tableValues[self.pointer]
        self.tableValues[self.pointer] = nil
        return poppedval
    end
end


function stack:GetValues()
    return self.tableValues
end

function stack:ReturnLength()
    return #self.tableValues
end

return stack