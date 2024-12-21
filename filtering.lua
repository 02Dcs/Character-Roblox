local ts, tcs, rp = game:GetService("TextService"), game:GetService("TextChatService"), game:GetService("ReplicatedStorage")
local bl, lmsg = {}, 0

pcall(function()
    local r = request({Url = "https://raw.githubusercontent.com/02Dcs/Character-Roblox/main/blacklistwords.txt"})
    if r and r.Success then
        bl = r.Body:gsub("[%c%s]+", " "):gsub("^%s*(.-)%s*$", "%1"):split(" ")
    end
end)

local function clean(t)
    return t:lower():gsub("[%p%c%s]", ""):gsub("[13450]", {["1"]="i",["3"]="e",["4"]="a",["5"]="s",["0"]="o"})
end

local function similar(w1, w2)
    w1, w2 = clean(w1), clean(w2)
    if #w1 < 3 or #w2 < 3 then return w1 == w2 end
    
    w1 = w1:gsub("ing$", "e"):gsub("ed$", ""):gsub("'?s$", "")
    w2 = w2:gsub("ing$", "e"):gsub("ed$", ""):gsub("'?s$", "")
    
    local diff = 0
    for i = 1, math.min(#w1, #w2) do
        if w1:sub(i,i) ~= w2:sub(i,i) then diff = diff + 1 end
        if diff > 1 then return false end
    end
    return math.abs(#w1 - #w2) <= 1
end

local function check(text)
    text = clean(text)
    for _, word in ipairs(bl) do
        if text:find(word) or similar(text, word) then return true end
        for part in text:gmatch("%S+") do
            if similar(part, word) then return true end
        end
    end
    return false
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local a, m = {...}, getnamecallmethod()
    if m == "FireServer" and self.Name == "SayMessageRequest" and (a[1]:find("#") or check(a[1])) then
        if a[1] ~= "[Message Filtered]" and tick() - lmsg >= 1 then
            lmsg = tick()
            rp:WaitForChild('DefaultChatSystemChatEvents'):WaitForChild('SayMessageRequest'):FireServer("[Message Filtered]", "All")
        end
        return
    end
    return old(self, ...)
end)

setreadonly(mt, true)

tcs.OnIncomingMessage = function(m)
    if m.Text:find("#") or check(m.Text) then
        if m.Text ~= "[Message Filtered]" and tick() - lmsg >= 1 then
            lmsg = tick()
            tcs.ChatInputBarConfiguration.TargetTextChannel:SendAsync("[Message Filtered]")
        end
        return {Text = "", PrefixText = "", Status = Enum.TextChatMessageStatus.Sending}
    end
end

tcs.SendingMessage:Connect(function(m)
    return m.Text:find("#") or check(m.Text)
end)
