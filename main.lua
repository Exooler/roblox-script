--// CONFIG
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rayfield Example Window",
   Icon = 0,
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sirius",
   ShowText = "Rayfield",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

--// TAB & SECTION
local Tab = Window:CreateTab("Tab Example", 4483362458)
local Section = Tab:CreateSection("Section Example")

-- Toggle UI
local Toggle = Tab:CreateToggle({
   Name = "Auto Snowflake Teleport",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
      enabled = Value
      print("Snowflake Auto-Teleport:", Value and "ENABLED" or "DISABLED")
   end,
})

--// SETTINGS
local KEYBIND = Enum.KeyCode.P
local CHECK_DELAY = 0.25
local NO_SNOWFLAKE_TIME = 4

local SNOWFLAKE_NAMES = {
    "GreenSnowFlake",
    "LightBlueSnowFlake",
    "BlueSnowFlake",
    "WhiteSnowFlake",
    "PinkSnowFlake",
    "PurpleSnowFlake",
    "YellowSnowFlake"
}

--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local QueueOnTeleport = syn and syn.queue_on_teleport or queue_on_teleport -- for Synapse/X
-- alternative: for other exploits that support QueueOnTeleport

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local enabled = false
local lastFound = os.clock()

--// FIND SNOWFLAKE
local function findSnowflake()
    for _, name in ipairs(SNOWFLAKE_NAMES) do
        local part = workspace:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

--// SERVER HOP
local function serverHop()
    print("No snowflakes found. Switching server...")

    -- Queue the script to run after teleport
    local scriptSource = [[
        loadstring(game:HttpGet('YOUR_SCRIPT_URL'))()
    ]]
    if QueueOnTeleport then
        QueueOnTeleport(scriptSource)
    end

    local success, result = pcall(function()
        local url = string.format(
            "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100",
            game.PlaceId
        )
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if not success or not result or not result.data then
        warn("Failed to fetch server list.")
        return
    end

    for _, server in ipairs(result.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
            return
        end
    end

    warn("No available servers found.")
end

--// MAIN LOOP
task.spawn(function()
    while true do
        task.wait(CHECK_DELAY)

        if enabled then
            local snowflake = findSnowflake()

            if snowflake then
                lastFound = os.clock()
                root.CFrame = snowflake.CFrame + Vector3.new(0, 5, 0)
            else
                if os.clock() - lastFound > NO_SNOWFLAKE_TIME then
                    serverHop()
                end
            end
        end
    end
end)

--// KEYBIND TOGGLE
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == KEYBIND then
        enabled = not enabled
        Toggle:Set(enabled) -- updates the UI toggle
        print("Snowflake Auto-Teleport:", enabled and "ENABLED" or "DISABLED")
    end
end)
