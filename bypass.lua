local ts = game:GetService("TextService")
local tc = game:GetService("TextChatService")
local rp = game:GetService("ReplicatedStorage")
local t = 0

local l = {
    a = "ạ", b = "ḅ", c = "ċ", d = "ḍ", e = "ẹ",
    f = "ḟ", g = "ɡ", h = "ḥ", i = "ị", j = "ǰ",
    k = "ḳ", l = "ḷ", m = "ṃ", n = "ṇ", o = "ọ",
    p = "ṗ", q = "ꝗ", r = "ṛ", s = "ṣ", t = "ṭ",
    u = "ụ", v = "ṿ", w = "ẉ", x = "ẋ", y = "ỵ", z = "ẓ"
}

local w = {}
pcall(function()
    local r = request({
        Url = "https://raw.githubusercontent.com/02Dcs/Character-Roblox/refs/heads/main/blacklistwords.txt",
        Method = "GET"
    })
    if r and r.Success then
        w = r.Body:gsub("%s+", " "):split(" ")
    end
end)

local function c(s)
    return l[s:lower()] or s
end

local function cw(s)
    local r = ""
    for i = 1, #s do
        local ch = s:sub(i,i)
        local cv = c(ch)
        if ch:upper() == ch then
            cv = cv:upper()
        end
        r = r .. cv
    end
    return r
end

local function g(w)
    local cv = cw(w)
    local f = {
        [w] = cv,
        [w:upper()] = cv:upper(),
        [w:sub(1,1):upper() .. w:sub(2)] = cv:sub(1,1):upper() .. cv:sub(2)
    }
    if #w > 3 then
        f[w.."ing"] = cw(w.."ing")
        f[w.."ed"] = cw(w.."ed")
        f[w.."s"] = cw(w.."s")
        f[w.."'s"] = cw(w.."'s")
        f[w.."es"] = cw(w.."es")
    end
    return f
end

local r = {}
for _, w in ipairs(w) do
    if w and w ~= "" then
        local f = g(w)
        for k, v in pairs(f) do
            r[k] = v
        end
    end
end

local function ct(s)
    if not s then return s end
    local t = " "..s.." "
    for w, rp in pairs(r) do
        t = t:gsub("([^%w])"..w.."([^%w])", "%1"..rp.."%2")
    end
    return t:sub(2, -2)
end

local mt = getrawmetatable(game)
local o = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local a, m = {...}, getnamecallmethod()
    if m == "FireServer" and self.Name == "SayMessageRequest" then
        local msg = ct(a[1])
        return o(self, msg, select(2, ...))
    end
    return o(self, ...)
end)

setreadonly(mt, true)

tc.OnIncomingMessage = function(m)
    local msg = ct(m.Text)
    if msg ~= m.Text then
        tc.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
        return {Text = "", PrefixText = "", Status = Enum.TextChatMessageStatus.Sending}
    end
end

tc.SendingMessage:Connect(function() return false end)
