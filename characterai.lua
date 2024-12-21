--[[ 
################ Beta Version ###########
                Made by 020300
]]

local Http = game:GetService("HttpService")
local Plrs = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")

-- loadstring(game:HttpGet("https://raw.githubusercontent.com/02Dcs/Character-Roblox/refs/heads/main/filtering.lua", true))() With Filter
loadstring(game:HttpGet("https://raw.githubusercontent.com/02Dcs/Character-Roblox/refs/heads/main/bypass.lua", true))() -- Bypasses The Filter
loadstring(game:HttpGet("https://raw.githubusercontent.com/02Dcs/Character-Roblox/refs/heads/main/servercheck.lua", true))() -- Checks if the server is running

local _cfg = {}
local cfg = setmetatable({
    url = "http://localhost:3000/chat",
    prox = 10,
    mDel = 0.5,
    mq = {},
    proc = false,
    lmt = 0,
    mRet = 5,
    rDel = 0.2,
    current_player = nil
}, {
    __newindex = function(t, k, v)
        if _cfg[k] == nil then _cfg[k] = v end
        return _cfg[k]
    end,
    __index = function(t, k) return _cfg[k] end
})

for k, v in pairs(cfg) do _cfg[k] = v end

local function sMsg(m)
    if not m or m:gsub("%s", "") == "" then return false end
    
    m = m:gsub("%s+", " ") 
     local s = false
    pcall(function()
        if not rp:FindFirstChild('DefaultChatSystemChatEvents') then
            local g = game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel:SendAsync(m)
            g:SetExtraData("BubbleChatEnabled", false)
            s = true
        else 
            rp:FindFirstChild('DefaultChatSystemChatEvents').SayMessageRequest:FireServer(tostring(m), "All")
            s = true
        end
    end)
    return s
 end

local function near(p)
    local lp = Plrs.LocalPlayer
    if not lp or p == lp then return false end
    
    local c = p.Character
    if not c then return false end
    
    local r = c:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    
    if not lp.Character then return false end
    
    local lr = lp.Character:FindFirstChild("HumanoidRootPart")
    if not lr then return false end
    
    local d = (r.Position - lr.Position).Magnitude
    if d <= cfg.prox then
        if not cfg.current_player then cfg.current_player = p end
        return p == cfg.current_player
    end
    return false
end

local function findNewPlayer()
    local lp = Plrs.LocalPlayer
    if not lp then return end
    
    for _, p in ipairs(Plrs:GetPlayers()) do
        if p ~= lp and near(p) then
            cfg.current_player = p
            print(string.format("[%s] Now talking with %s", os.date("%H:%M:%S"), p.Name))
            return
        end
    end
    cfg.current_player = nil
end

local function ask(m, p, r)
    r = r or 0
    if not near(p) then return end
    if not m or m == "" then return end

    local s, res = pcall(function()
        return request({
            Url = cfg.url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Accept"] = "application/json"
            },
            Body = Http:JSONEncode({
                message = m,
                retry = r
            })
        })
    end)
    
    if not s then
        if r < cfg.mRet then
            task.wait(cfg.rDel)
            ask(m, p, r + 1)
        else
            sMsg("Error connecting to server")
        end
        return
    end
    
    if s and res then
        if res.StatusCode ~= 200 then
            if r < cfg.mRet then
                task.wait(cfg.rDel)
                ask(m, p, r + 1)
            end
            return
        end

        local ds, d = pcall(function() return Http:JSONDecode(res.Body) end)
        
        if ds and d then
            if d.filtered then return end
            if d.error then
                if r < cfg.mRet then
                    task.wait(cfg.rDel)
                    ask(m, p, r + 1)
                end
                return
            end
            
            local resp = tostring(d.response)
            if resp and resp ~= "" then
                if resp:find("#") then return end
                sMsg(resp)
            elseif r < cfg.mRet then
                task.wait(cfg.rDel)
                ask(m, p, r + 1)
            end
        else
            if r < cfg.mRet then
                task.wait(cfg.rDel)
                ask(m, p, r + 1)
            end
        end
    end
end

local function proc()
    if cfg.proc or #cfg.mq == 0 then return end
    cfg.proc = true
    
    local ct = os.time()
    if ct - cfg.lmt < cfg.mDel then
        cfg.proc = false
        return
    end
    
    local nm = table.remove(cfg.mq, 1)
    if nm and nm.message then
        ask(nm.message, nm.player, 0)
    end
    cfg.lmt = ct
    cfg.proc = false
    
    task.wait(cfg.mDel)
    proc()
end

Plrs.PlayerChatted:Connect(function(ct, p, m)
    if m and m ~= "" then
        table.insert(cfg.mq, {message = m, player = p, time = os.time()})
        proc()
    end
end)

Plrs.PlayerRemoving:Connect(function(p)
    if p == cfg.current_player then findNewPlayer() end
end)


findNewPlayer()
