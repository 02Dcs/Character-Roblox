local ts = game:GetService("TextService")
local tcs, rp = game:GetService("TextChatService"),  game:GetService("ReplicatedStorage")

local function trim(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end

local bl = {}
local success, response = pcall(function()
    local r = request({
        Url = "https://raw.githubusercontent.com/02Dcs/Character-Roblox/main/blacklistwords.txt",
        Method = "GET"
    })
    if r and r.Success then
        local cleaned = trim(r.Body:gsub("\r?\n", " "):gsub("%s+", " "))
        bl = string.split(cleaned, " ")
    end
end)

getgenv().lmsg = 0

local function br(t)
    local w = t:lower():split(" ")
    for _, x in ipairs(w) do
        if table.find(bl, x) then return true end
    end
    return false
end

local function can()
    local n = tick()
    if n - lmsg >= 1 then lmsg = n return true end
    return false
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local a = {...}
    local m = getnamecallmethod()
    
    if m == "FireServer" and self.Name == "SayMessageRequest" then
        local msg = a[1]
        if msg:find("#") or br(msg) then
            if msg ~= "[Message Filtered]" and can() then
                rp:WaitForChild('DefaultChatSystemChatEvents'):WaitForChild('SayMessageRequest'):FireServer("[Message Filtered]", "All")
            end
            return
        end
    end
    return old(self, ...)
end)

setreadonly(mt, true)

tcs.OnIncomingMessage = function(m)
    if m.Text:find("#") or br(m.Text) then
        if m.Text ~= "[Message Filtered]" and can() then
            tcs.ChatInputBarConfiguration.TargetTextChannel:SendAsync("[Message Filtered]")
        end
        return {Text = "", PrefixText = "", Status = Enum.TextChatMessageStatus.Sending}
    end
end

tcs.SendingMessage:Connect(function(m)
    return m.Text:find("#") or br(m.Text)
end)

