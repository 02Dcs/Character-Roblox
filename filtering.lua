local ts = game:GetService("TextService")
local plrs, tcs, rp = game:GetService("Players"), game:GetService("TextChatService"), game:GetService("ReplicatedStorage")

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local m = getnamecallmethod()
    
    if m == "FireServer" and self.Name == "SayMessageRequest" then
        local msg = args[1]
        if msg:find("#") then
            if msg ~= "[Message Filtered]" then
                local ce = rp:WaitForChild('DefaultChatSystemChatEvents')
                ce:WaitForChild('SayMessageRequest'):FireServer("[Message Filtered]", "All")
            end
            return
        end
    end
    
    return old(self, ...)
end)

setreadonly(mt, true)

tcs.OnIncomingMessage = function(msg)
    if msg.Text:find("#") then
        task.spawn(function()
            if msg.Text ~= "[Message Filtered]" then
                tcs.ChatInputBarConfiguration.TargetTextChannel:SendAsync("[Message Filtered]")
            end
        end)
        return {
            Text = "",
            PrefixText = "",
            Status = Enum.TextChatMessageStatus.Sending
        }
    end
    return nil
end

tcs.SendingMessage:Connect(function(msg)
    if msg.Text:find("#") then
        return true
    end
    return false
end)

