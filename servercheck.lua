local function c()
    local s = pcall(function()
        local r = request({
            Url = "http://localhost:3000",
            Method = "g"
        })
        
        if not r or not r.Success then
            game.Players.LocalPlayer:Kick("Server is not running. Please start server.js first.")
            return
        end
        
        print("Server is running!")
    end)
    
    if not s then
        game.Players.LocalPlayer:Kick("Server is not running. Please start server.js first.")
    end
end

c()
