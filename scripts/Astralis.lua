-- // apologies for the messy code QwQ\\ --

-- Library Imports
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bottomnoah/UI/refs/heads/main/cola.lua"))()
local drawhelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/bottomnoah/UI/refs/heads/main/drawing"))()
local localplayer = game:GetService("Players").LocalPlayer
local Wait = Library.subs.Wait

if not getgc or not rawget then
   localplayer:Kick("[dsc.gg/kaotiksoftworks]\nExecutor must support getgc and rawget to run this script. Try Using Swift.")
end

local playerModelToReplication = {}

-- Services
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Module Cache
local moduleCache
for _, v in getgc(true) do
    if type(v) == "table" and rawget(v, "ScreenCull") and rawget(v, "NetworkClient") then
        moduleCache = v
        break
    end
end

 if not moduleCache then 
        localplayer:Kick('[dsc.gg/kaotiksoftworks]\nModules Not found. Do you have FFlagDebugRunParallelLuaOnMainThread set to True?');
    end;

local modules = {}
for name, data in moduleCache do modules[name] = data.module end

local effects = modules.Effects
local vector = modules.VectorLib
local physics = modules.PhysicsLib
local raycastLib = modules.Raycast
local cframeLib = modules.CFrameLib
local recoil = modules.RecoilSprings
local network = modules.NetworkClient
local screenCull = modules.ScreenCull
local modifyData = modules.ModifyData
local bulletcheck = modules.BulletCheck
local audioSystem = modules.AudioSystem
local bulletObject = modules.BulletObject
local charObject = modules.CharacterObject
local skinCaseUtils = modules.SkinCaseUtils
local firearmObject = modules.FirearmObject
local desktopHitBox = modules.DesktopHitBox
local cameraObject = modules.MainCameraObject
local playerRegistry = modules.PlayerRegistry
local publicSettings = modules.PublicSettings
local playerDataUtils = modules.PlayerDataUtils
local cameraInterface = modules.CameraInterface
local contentDatabase = modules.ContentDatabase
local hudnotify = modules.HudNotificationConfig
local charInterface = modules.CharacterInterface
local hudScopeInterface = modules.HudScopeInterface
local unscaledScreenGui = modules.UnscaledScreenGui
local replicationObject = modules.ReplicationObject
local thirdPersonObject = modules.ThirdPersonObject
local weaponObject = modules.WeaponControllerObject
local playerClient = modules.PlayerDataClientInterface
local roundSystem = modules.RoundSystemClientInterface
local weaponInterface = modules.WeaponControllerInterface
local replicationInterface = modules.ReplicationInterface
local crosshairsInterface = modules.HudCrosshairsInterface

-- Network Connections
local networkConnections
for _, v in getgc(true) do
    if type(v) == "table" and rawget(v, "died") and rawget(v, "smallaward") then
        networkConnections = v
        break
    end
end

-- Suppress console spam
getfenv(cameraInterface.setCameraType).print = function() end
getfenv(cameraInterface.setCameraType).warn = function() end

local currentObj, started, fakeRepObject
local physicsignore = {workspace.Terrain, workspace.Ignore, workspace.Players, Camera}

fakeRepObject = replicationObject.new(setmetatable({}, {
    __index = function(self, index) return localplayer[index] end,
    __newindex = function(self, index, value) localplayer[index] = value end
}))


-- Settings
local Settings = {
    Aimbot = {
        Enabled = false, 
        HitPart = "Head", 
        WallCheck = false, 
        AutoTargetSwitch = false, 
        MaxDistance = {Enabled = false, Value = 500}, 
        Easing = {Strength = 0.1, Sensitivity = Instance.new("NumberValue")}
    },
    ESP = {
        Enabled = false, 
        MaxDistance = {Enabled = false, Value = 500}, 
        VisibilityCheck = false, 
        UseFOV = false, 
        Features = {
            Box = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)}, 
            Tracer = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)}, 
            DistanceText = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)}, 
            Name = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)}, 
            HeadDot = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)},
             HealthBar = {
                Enabled = false,
                Color = Color3.fromRGB(50, 255, 50),
                BackgroundColor = Color3.fromRGB(20, 20, 20),
                OutlineColor = Color3.fromRGB(100, 100, 100),
                Width = 2,
                Height = 40
            }
        }
    },
    FOV = {
        Enabled = false, 
        FollowGun = false, 
        Radius = 50, 
        Circle = drawing.new("Circle"), 
        OutlineCircle = drawing.new("Circle"), 
        Filled = false, 
        FillColor = Color3.fromRGB(0, 0, 0), 
        FillTransparency = 0.2, 
        OutlineColor = Color3.fromRGB(255, 255, 255), 
        OutlineTransparency = 1
    },
    Chams = {
        Enabled = false, 
        TeamCheck = true, 
        Teammates = false, 
        Fill = {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.5}, 
        Outline = {Color = Color3.fromRGB(255, 255, 255), Transparency = 0}
    },
    Player = {
        Bhop = {Enabled = false}, 
        WalkSpeed = {Enabled = false, Value = 16}, 
        JumpPower = {Enabled = false, Value = 0}
    },
    Misc = {
        Textures = false, 
        VotekickRejoiner = false, 
        Optimized = false
    },
    Crosshair = {
        Enabled = false, 
        Size = 10, 
        Thickness = 1, 
        Gap = 5, 
        Color = Color3.fromRGB(255, 255, 255), 
        Transparency = 1, 
        Dot = false, 
        TStyle = "Default", 
        Drawings = {
            Line1 = drawing.new("Line"), 
            Line2 = drawing.new("Line"), 
            Line3 = drawing.new("Line"), 
            Line4 = drawing.new("Line"), 
            CenterDot = drawing.new("Circle")
        }
    },
    ThirdPerson = {
        Enabled = false, 
        ShowCharacter = false, 
        ApplyAntiAimToCharacter = true, 
        CameraOffsetAlwaysVisible = false, 
        ShowCharacterWhileAiming = false, 
        CameraOffsetX = 3, 
        CameraOffsetY = 1, 
        CameraOffsetZ = 4, 
        HideViewmodel = false
    },
    AntiAim = {
        Enabled = false, 
        Mode = "Spin", 
        SpinSpeed = 50, 
        JitterAngle = 45, 
        StaticAngle = 90, 
        PitchMode = "None", 
        PitchAngle = 45, 
        ForceStance = false
    },
    SilentAim = {
        Enabled = false, 
        HitPart = "Head", 
        UseFOV = false, 
        WallCheck = false,
        HitChance = 100,
    },
    RageBot = {
        Enabled = false, 
        FireRateBypass = false, 
        FirePositionScanning = false, 
        FirePositionOffset = 0.5, 
        HitPositionScanning = false, 
        HitPositionOffset = 0.5, 
        Backtracking = {Enabled = false, Duration = 0.2}, 
        HitBoxes = {Enabled = false, HitPart = "Head", Size = 1.5}
    },
    GunMods = {
        NoRecoil = false, 
        NoSpread = false, 
        NoSway = false, 
        NoWalkSway = false, 
        NoCameraBob = false, 
        NoSniperScope = false, 
        InstantReload = false, 
        SmallCrosshair = false, 
        NoCrosshair = false
    }
}

local Configs = {
    Current = "default",
    Path = "astralis_configs/",
    Files = {}
}

-- Crosshair Helpers
local function setLine(line, visible, from, to, color, thickness, transparency)
    line.Visible = visible
    if visible then line.From = from line.To = to line.Color = color line.Thickness = thickness line.Transparency = transparency end
end

local function setDot(dot, visible, position, radius, color, transparency, filled)
    dot.Visible = visible
    if visible then dot.Position = position dot.Radius = radius dot.Color = color dot.Transparency = transparency dot.Filled = filled end
end

-- Initialize Crosshair
local function initializeCrosshair() for _, d in Settings.Crosshair.Drawings do d.Visible = false end end

local function updateCrosshair()
    if not Settings.Crosshair.Enabled then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local size, gap, thickness, color, transparency = Settings.Crosshair.Size, Settings.Crosshair.Gap, Settings.Crosshair.Thickness, Settings.Crosshair.Color, Settings.Crosshair.Transparency
    local lines = Settings.Crosshair.Drawings
    if Settings.Crosshair.TStyle == "Default" then
        setLine(lines.Line1, true, Vector2.new(center.X, center.Y - gap - size), Vector2.new(center.X, center.Y - gap), color, thickness, transparency)
        setLine(lines.Line2, true, Vector2.new(center.X, center.Y + gap), Vector2.new(center.X, center.Y + gap + size), color, thickness, transparency)
        setLine(lines.Line3, true, Vector2.new(center.X - gap - size, center.Y), Vector2.new(center.X - gap, center.Y), color, thickness, transparency)
        setLine(lines.Line4, true, Vector2.new(center.X + gap, center.Y), Vector2.new(center.X + gap + size, center.Y), color, thickness, transparency)
    else
        setLine(lines.Line1, true, Vector2.new(center.X - size - gap, center.Y), Vector2.new(center.X + size + gap, center.Y), color, thickness, transparency)
        setLine(lines.Line2, true, Vector2.new(center.X, center.Y - size - gap), Vector2.new(center.X, center.Y + size + gap), color, thickness, transparency)
        lines.Line3.Visible = false lines.Line4.Visible = false
    end
    setDot(lines.CenterDot, Settings.Crosshair.Dot, center, thickness, color, transparency, true)
end

initializeCrosshair()

-- FOV Setup
local fov = Settings.FOV
fov.Circle.Visible = false fov.Circle.Filled = fov.Filled fov.Circle.Color = fov.FillColor fov.Circle.Transparency = fov.FillTransparency fov.Circle.Thickness = 0 fov.Circle.Radius = fov.Radius fov.Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
Settings.Aimbot.Easing.Sensitivity.Value = Settings.Aimbot.Easing.Strength
fov.OutlineCircle.Filled = false fov.OutlineCircle.Color = fov.OutlineColor fov.OutlineCircle.Transparency = fov.OutlineTransparency fov.OutlineCircle.Thickness = 1 fov.OutlineCircle.Radius = fov.Radius fov.OutlineCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) fov.OutlineCircle.Visible = fov.Enabled

-- State
local State = {
    IsRightClickHeld = false, TargetPart = nil, OriginalProperties = {}, CachedProperties = {}, PlayersToDraw = {}, Highlights = {}, Storage = {ESPCache = {}},
    MousePreload = {Active = false, LastTime = 0, Interval = 5, Connection = nil}, CrosshairUpdate = nil, ThirdPersonConnection = nil, ViewmodelProperties = {}, AntiAimConnection = nil
}

local function toggleCrosshair(state)
    if state then State.CrosshairUpdate = RunService.RenderStepped:Connect(updateCrosshair)
    else if State.CrosshairUpdate then State.CrosshairUpdate:Disconnect() State.CrosshairUpdate = nil end for _, d in Settings.Crosshair.Drawings do d.Visible = false end
    end
end

local SilentAimFunctions = {}

local ConfigListDropdown

-- Utilities
local function refreshConfigList()
    Configs.Files = {}
    
    if not isfolder(Configs.Path) then
        makefolder(Configs.Path)
    end
    
    for _, file in pairs(listfiles(Configs.Path)) do
        local fileName = file:match("([^/\\]+)$")
        if fileName and fileName:lower():match("%.json$") then
            local configName = fileName:match("(.+)%.json$")
            if configName then
                table.insert(Configs.Files, configName)
            end
        end
    end
    
    table.sort(Configs.Files)
    
    if ConfigListDropdown then
        local listToUse = #Configs.Files > 0 and Configs.Files or {"None"}
        
        pcall(function()
            ConfigListDropdown:Clear()
        end)
        
        for _, config in ipairs(listToUse) do
            pcall(function()
                ConfigListDropdown:Add(config)
            end)
        end
        
        if #Configs.Files > 0 then
            if table.find(Configs.Files, Configs.Current) then
                pcall(function()
                    ConfigListDropdown:Set(Configs.Current)
                end)
            else
                pcall(function()
                    ConfigListDropdown:Set(Configs.Files[1])
                end)
            end
        else
            Configs.Current = ""
            pcall(function()
                ConfigListDropdown:Set("None")
            end)
        end
    end
end


local function saveConfig(name)
    if not name or name == "" or name == "None" then
        Library:Notify({Text = "Please enter a valid config name"})
        return
    end
    
    if not isfolder(Configs.Path) then
        makefolder(Configs.Path)
    end
    
    local configData = {}
    local function serializeTable(t, prefix)
        for k, v in pairs(t) do
            local fullKey = prefix and prefix .. "." .. k or k
            if type(v) == "table" then
                serializeTable(v, fullKey)
            else
                configData[fullKey] = v
            end
        end
    end
    
    serializeTable(Settings)
    writefile(Configs.Path .. name .. ".json", game:GetService("HttpService"):JSONEncode(configData))
    
    Configs.Current = name
    
    refreshConfigList()
    Library:Notify({Text = "Config saved: " .. name})
end


local function deleteConfig(name)
    if not name or name == "" or name == "None" then
        Library:Notify({Text = "Please select a valid config to delete"})
        return
    end
    
    if not isfolder(Configs.Path) or not isfile(Configs.Path .. name .. ".json") then
        Library:Notify({Text = "Config not found: " .. name})
        return
    end
    
    delfile(Configs.Path .. name .. ".json")
    
    if Configs.Current == name then
        Configs.Current = ""
    end
    
    refreshConfigList()
    Library:Notify({Text = "Config deleted: " .. name})
    
    if ConfigNameTextbox and Configs.Current == "" then
        ConfigNameTextbox:Set("")
    end
end

local function raycast(origin, direction, filterlist)
    local params = RaycastParams.new() params.IgnoreWater = true params.FilterDescendantsInstances = filterlist or physicsignore params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, params)
    return result and result.Instance, result and result.Position
end

local function getGunBarrel()
    local furthestPart, maxZ = nil, -math.huge
    for _, model in Camera:GetChildren() do
        if model:IsA("Model") and not model.Name:lower():find("arm") then
            for _, part in model:GetDescendants() do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and pos.Z > maxZ then maxZ = pos.Z furthestPart = part end
                end
            end
        end
    end
    return furthestPart
end

local function updateFOVCirclePosition()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if Settings.FOV.Enabled then
        if Settings.FOV.FollowGun then
            local barrel = getGunBarrel()
            if barrel then
                local pos, onScreen = Camera:WorldToViewportPoint(barrel.Position)
                if onScreen then
                    if State.IsRightClickHeld and math.abs(pos.X - center.X) <= 10 then
                        fov.Circle.Position = center fov.OutlineCircle.Position = center
                    else
                        fov.Circle.Position = Vector2.new(pos.X, pos.Y) fov.OutlineCircle.Position = Vector2.new(pos.X, pos.Y)
                    end
                else
                    fov.Circle.Position = center fov.OutlineCircle.Position = center
                end
            else
                fov.Circle.Position = center fov.OutlineCircle.Position = center
            end
        else
            fov.Circle.Position = center fov.OutlineCircle.Position = center
        end
    else
        fov.Circle.Position = center fov.OutlineCircle.Position = center
    end
end

local function getPlayers()
    local entityList = {}
    for _, team in workspace.Players:GetChildren() do
        for _, player in team:GetChildren() do if player:IsA("Model") then table.insert(entityList, player) end end
    end
    return entityList
end

local function isEnemy(player)
    local localTeam = Players.LocalPlayer.Team.Name
    local helmet = player:FindFirstChildWhichIsA("Folder") and player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    if not helmet then return false end
    local color = helmet.BrickColor.Name
    return (color == "Black" and localTeam == "Ghosts") or (color ~= "Black" and localTeam == "Phantoms")
end

local function cacheObject(object)
    if not State.Storage.ESPCache[object] then
        State.Storage.ESPCache[object] = {
            BoxSquare = drawing.new("Square"), BoxOutline = drawing.new("Square"), TracerLine = drawing.new("Line"),
            DistanceLabel = drawing.new("Text"), NameLabel = drawing.new("Text"), HeadDot = drawing.new("Circle"),
            HealthBarBackground = drawing.new("Square"),
            HealthBarForeground = drawing.new("Square"),
            HealthBarOutline = drawing.new("Square")
        }
        for _, e in State.Storage.ESPCache[object] do e.Visible = false end
    end
end

local function uncacheObject(object)
    if State.Storage.ESPCache[object] then
        for _, e in State.Storage.ESPCache[object] do e:Remove() end
        State.Storage.ESPCache[object] = nil
    end
end

local function getBodyPart(player, name)
    for _, part in player:GetChildren() do
        if part:IsA("BasePart") then
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh and ((name == "Head" and mesh.MeshId == "rbxassetid://6179256256") or (name ~= "Head" and mesh.MeshId == "rbxassetid://4049240078")) then return part end
        end
    end
end

local function isAlly(player)
    local helmet = player:FindFirstChildWhichIsA("Folder") and player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    if not helmet then return false end
    return helmet.BrickColor.Name == "Black" and Players.LocalPlayer.Team == Teams.Phantoms or helmet.BrickColor.Name ~= "Black" and Players.LocalPlayer.Team == Teams.Ghosts
end

local function getClosestPlayer(useFOV)
    useFOV = useFOV == nil and Settings.SilentAim.UseFOV or useFOV
    local closest, shortestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in getPlayers() do
        if not player:IsDescendantOf(workspace.Ignore.DeadBody) then
            local ally = isAlly(player)
            if not (Settings.Chams.TeamCheck and ally) then
                local part = getBodyPart(player, Settings.SilentAim.HitPart or Settings.Aimbot.HitPart)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distToCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        local distToCam = (part.Position - Camera.CFrame.Position).Magnitude
                        if not (Settings.Aimbot.MaxDistance.Enabled and distToCam > Settings.Aimbot.MaxDistance.Value) then
                            if useFOV and Settings.FOV.Enabled then
                                if distToCenter <= Settings.FOV.Radius then
                                    if distToCam <= 30 then return part end
                                    if distToCenter < shortestDist then closest = part shortestDist = distToCenter end
                                end
                            else
                                if distToCam <= 30 then return part end
                                if distToCenter < shortestDist then closest = part shortestDist = distToCenter end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function safeMouseMoveRel(x, y) pcall(mousemoverel, x, y) end

local function preloadMouse()
    local t = tick()
    if t - State.MousePreload.LastTime >= State.MousePreload.Interval then
        safeMouseMoveRel(0.01, 0.01)
        State.MousePreload.LastTime = t
    end
end

local function startMousePreload()
    if State.MousePreload.Active then return end
    State.MousePreload.Active = true
    State.MousePreload.Connection = RunService.Heartbeat:Connect(preloadMouse)
end

local function stopMousePreload()
    if not State.MousePreload.Active then return end
    State.MousePreload.Active = false
    if State.MousePreload.Connection then State.MousePreload.Connection:Disconnect() State.MousePreload.Connection = nil end
end

local function aimAt()
    if not Settings.Aimbot.Easing.Strength or not State.TargetPart or not State.TargetPart:IsDescendantOf(workspace.Players) then return end
    if State.IsRightClickHeld then
        if Settings.Aimbot.AutoTargetSwitch and not State.TargetPart then
            State.TargetPart = getClosestPlayer()
            if not State.TargetPart then State.IsRightClickHeld = false return end
        end
        local pos, onScreen = Camera:WorldToViewportPoint(State.TargetPart.Position)
        if onScreen then
            local mouse = UserInputService:GetMouseLocation()
            local delta = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y)
            if delta.Magnitude > 1 then safeMouseMoveRel(delta.X * Settings.Aimbot.Easing.Sensitivity.Value, delta.Y * Settings.Aimbot.Easing.Sensitivity.Value) end
        end
    end
end

function SilentAimFunctions:SolveQuadratic(A, B, C)
    local Discriminant = B^2 - 4*A*C
    if Discriminant < 0 then return nil, nil end
    local DiscRoot = math.sqrt(Discriminant)
    return (-B - DiscRoot) / (2*A), (-B + DiscRoot) / (2*A)
end

function SilentAimFunctions:GetBallisticFlightTime(direction, gravity, projectileSpeed)
    local Root1, Root2 = SilentAimFunctions:SolveQuadratic(gravity:Dot(gravity) / 4, gravity:Dot(direction) - projectileSpeed^2, direction:Dot(direction))
    if Root1 and Root2 then
        if Root1 > 0 and Root1 < Root2 then return math.sqrt(Root1) end
        if Root2 > 0 and Root2 < Root1 then return math.sqrt(Root2) end
    end
    return 0
end

function SilentAimFunctions:CalculateBulletDrop(To, From, MuzzleVelocity)
    local Time = SilentAimFunctions:GetBallisticFlightTime(From - To, -publicSettings.bulletAcceleration, MuzzleVelocity)
    return 0.5 * -publicSettings.bulletAcceleration * Time^2
end

local function isVisible(part, check)
    if check then
        local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000), {Players.LocalPlayer.Character}, false, true)
        return hit == part
    end
    return true
end

local SilentAimHook
local function initializeSilentAim()
    if SilentAimHook then return end
    local BulletInterface = modules.BulletInterface
    if not BulletInterface then warn("BulletInterface not found") return end
    local OldNewBullet = BulletInterface.newBullet
    BulletInterface.newBullet = function(BulletData)
        if BulletData.extra and Settings.SilentAim.Enabled and math.random(1, 100) <= Settings.SilentAim.HitChance then
            local HitPart = getClosestPlayer()
            if HitPart and (not Settings.SilentAim.WallCheck or isVisible(HitPart, true)) then
                local BulletSpeed = BulletData.extra.firearmObject:getWeaponStat("bulletspeed")
                local VerticalDrop = SilentAimFunctions:CalculateBulletDrop(HitPart.Position, BulletData.position, BulletSpeed)
                local LookVector = (HitPart.Position + VerticalDrop - BulletData.position).unit
                for i, v in debug.getstack(2) do
                    if typeof(v) == "Vector3" and (BulletData.velocity.Unit - v).Magnitude < 0.1 then
                        debug.setstack(2, i, LookVector)
                        break
                    end
                end
                BulletData.velocity = LookVector * BulletSpeed
            end
        end
        return OldNewBullet(BulletData)
    end
    SilentAimHook = OldNewBullet
end

local function cleanupSilentAim()
    if SilentAimHook then modules.BulletInterface.newBullet = SilentAimHook SilentAimHook = nil end
end

local function updateSensitivity(val)
    TweenService:Create(Settings.Aimbot.Easing.Sensitivity, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Value = val}):Play()
end

local function storeOriginalProperties(inst)
    if inst:IsA("BasePart") or inst:IsA("UnionOperation") or inst:IsA("MeshPart") then
        State.OriginalProperties[inst] = {Material = inst.Material, Reflectance = inst.Reflectance, CastShadow = inst.CastShadow, TextureId = inst:FindFirstChild("TextureId") and inst.TextureId or nil}
    end
end

local function optimizeMap()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, inst in map:GetDescendants() do
        storeOriginalProperties(inst)
        if inst:IsA("BasePart") or inst:IsA("UnionOperation") or inst:IsA("MeshPart") then
            inst.Material = Enum.Material.SmoothPlastic inst.Reflectance = 0 inst.CastShadow = false
            if inst:IsA("MeshPart") and inst:FindFirstChild("TextureId") then inst.TextureId = "" end
        end
    end
    Settings.Misc.Optimized = true
end

local function revertMap()
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    for _, inst in map:GetDescendants() do
        local props = State.OriginalProperties[inst]
        if props then inst.Material = props.Material inst.Reflectance = props.Reflectance inst.CastShadow = props.CastShadow if inst:IsA("MeshPart") and inst:FindFirstChild("TextureId") then inst.TextureId = props.TextureId or "" end end
    end
    Settings.Misc.Optimized = false
end

local function isValidPlayer(player) return player and player.Parent and player:IsDescendantOf(workspace.Players) end

local function initializeESP()
    for p in State.Storage.ESPCache do uncacheObject(p) end
    State.PlayersToDraw = {} State.CachedProperties = {}
end

local function cleanupStalePlayers()
    for p in State.Storage.ESPCache do if not isValidPlayer(p) then uncacheObject(p) State.CachedProperties[p] = nil end end
end

local function updatePlayerModelCache()
    playerModelToReplication = {}
    
    replicationInterface.operateOnAllEntries(function(player, entry)
        local thirdPerson = entry:getThirdPersonObject()
        if thirdPerson then
            local characterModel = thirdPerson:getCharacterModel()
            if characterModel then
                playerModelToReplication[characterModel] = entry
            end
        end
    end)
end

local function getPlayerHealth(playerModel)
    if not playerModelToReplication[playerModel] then
        updatePlayerModelCache()
    end
    
    local replicationEntry = playerModelToReplication[playerModel]
    if replicationEntry then
        return replicationEntry:getHealth(), 100
    end
    
    return 100, 100
end

local function updatePlayerCache()
    cleanupStalePlayers()
    State.PlayersToDraw = {}
    for _, p in getPlayers() do
        if isValidPlayer(p) and isEnemy(p) then
            local torso, head = getBodyPart(p, "Torso"), getBodyPart(p, "Head")
            if torso and head then
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if not Settings.ESP.MaxDistance.Enabled or dist <= Settings.ESP.MaxDistance.Value then
                    cacheObject(p)
                    table.insert(State.PlayersToDraw, p)
                    local gui = head:FindFirstChildOfClass("BillboardGui")
                    local label = gui and gui:FindFirstChildOfClass("TextLabel")
                    if gui and label then State.CachedProperties[p] = {Name = label.Text} end
                else
                    uncacheObject(p) State.CachedProperties[p] = nil
                end
            else
                uncacheObject(p) State.CachedProperties[p] = nil
            end
        end
    end
end

local lastCacheUpdate = 0
local function ensureCacheIsUpdated()
    local now = tick()
    if now - lastCacheUpdate > 1 then
        updatePlayerModelCache()
        lastCacheUpdate = now
    end
end


local function applyHighlight(p)
    if State.Highlights[p] then return State.Highlights[p] end
    local h = Instance.new("Highlight") h.FillColor = Settings.Chams.Fill.Color h.OutlineColor = Settings.Chams.Outline.Color h.FillTransparency = Settings.Chams.Fill.Transparency h.OutlineTransparency = Settings.Chams.Outline.Transparency h.Adornee = p h.Parent = game.CoreGui
    State.Highlights[p] = h
    return h
end

local function removeHighlight(p) if State.Highlights[p] then State.Highlights[p]:Destroy() State.Highlights[p] = nil end end

local function updateChams()
    if not Settings.Chams.Enabled then for p in State.Highlights do removeHighlight(p) end return end
    for _, p in getPlayers() do
        if isValidPlayer(p) then
            local ally = isAlly(p)
            if ally and not Settings.Chams.Teammates then removeHighlight(p)
            else
                local torso = getBodyPart(p, "Torso")
                if not torso then removeHighlight(p)
                else
                    local dist = (torso.Position - Camera.CFrame.Position).Magnitude
                    if Settings.ESP.MaxDistance.Enabled and dist > Settings.ESP.MaxDistance.Value then removeHighlight(p)
                    else
                        local h = applyHighlight(p)
                        local vis = isVisible(torso, Settings.ESP.VisibilityCheck)
                        if Settings.ESP.VisibilityCheck and not vis then h.FillColor = Color3.fromRGB(255, 0, 0) h.OutlineColor = Color3.fromRGB(255, 0, 0) h.FillTransparency = 0.5 h.OutlineTransparency = 0.2
                        else h.FillColor = Settings.Chams.Fill.Color h.OutlineColor = Settings.Chams.Outline.Color h.FillTransparency = Settings.Chams.Fill.Transparency h.OutlineTransparency = Settings.Chams.Outline.Transparency end
                    end
                end
            end
        end
    end
    for p in State.Highlights do if not isValidPlayer(p) then removeHighlight(p) end end
end

local function setESPHealthBar(cache, visible, health, maxHealth, position, width, height, foregroundColor, backgroundColor)
    if not cache.HealthBarBackground then
        cache.HealthBarBackground = drawing.new("Square")
        cache.HealthBarForeground = drawing.new("Square")
        cache.HealthBarOutline = drawing.new("Square")
    end
    
    cache.HealthBarBackground.Visible = visible
    cache.HealthBarForeground.Visible = visible
    cache.HealthBarOutline.Visible = visible
    
    if visible then
        local healthPercent = math.max(0, math.min(1, health / maxHealth))
        local actualHeight = height * healthPercent
        
     
        cache.HealthBarOutline.Position = Vector2.new(position.X - 1, position.Y - 1)
        cache.HealthBarOutline.Size = Vector2.new(width + 2, height + 2) 
        cache.HealthBarOutline.Color = Settings.ESP.Features.HealthBar.OutlineColor
        cache.HealthBarOutline.Filled = false
        cache.HealthBarOutline.Transparency = 0.7
        cache.HealthBarOutline.ZIndex = 0
        
       
        cache.HealthBarBackground.Position = position
        cache.HealthBarBackground.Size = Vector2.new(width, height)
        cache.HealthBarBackground.Color = backgroundColor
        cache.HealthBarBackground.Filled = true
        cache.HealthBarBackground.Transparency = 0.85 
        cache.HealthBarBackground.ZIndex = 1 
        

        cache.HealthBarForeground.Position = Vector2.new(position.X, position.Y + (height - actualHeight))
        cache.HealthBarForeground.Size = Vector2.new(width, actualHeight) 
        cache.HealthBarForeground.Color = foregroundColor 
        cache.HealthBarForeground.Filled = true
        cache.HealthBarForeground.Transparency = 1 
        cache.HealthBarForeground.ZIndex = 2
    end
end

-- ESP Render
local function setESPBox(cache, visible, color, position, size)
    cache.BoxSquare.Visible = visible
    if visible then cache.BoxSquare.Color = color cache.BoxSquare.Position = position cache.BoxSquare.Size = size cache.BoxOutline.Position = Vector2.new(position.X - 1, position.Y - 1) cache.BoxOutline.Size = Vector2.new(size.X + 2, size.Y + 2) cache.BoxOutline.Visible = true
    else cache.BoxOutline.Visible = false end
end

local function setESPTracer(cache, visible, color, from, to)
    cache.TracerLine.Visible = visible
    if visible then cache.TracerLine.Color = color cache.TracerLine.From = from cache.TracerLine.To = to end
end

local function setESPText(label, visible, text, color, size, position, center, outline)
    label.Visible = visible
    if visible then label.Text = text label.Color = color label.Size = size label.Position = position label.Center = center label.Outline = outline end
end

local function setESPHeadDot(cache, visible, color, radius, position)
    cache.HeadDot.Visible = visible
    if visible then cache.HeadDot.Color = color cache.HeadDot.Radius = radius cache.HeadDot.Position = position end
end

local function renderESP()
    ensureCacheIsUpdated()

    local camPos = Camera.CFrame.Position
    local viewSize = Camera.ViewportSize
    local center = Vector2.new(viewSize.X / 2, viewSize.Y)
    local fovRad = Settings.FOV.OutlineCircle.Radius
    
    for _, p in State.PlayersToDraw do
        if not isValidPlayer(p) then 
            uncacheObject(p) 
            State.CachedProperties[p] = nil 
            playerModelToReplication[p] = nil
        else
            local cache = State.Storage.ESPCache[p] or (cacheObject(p) and State.Storage.ESPCache[p])
            local torso, head = getBodyPart(p, "Torso"), getBodyPart(p, "Head")
            
            if not torso or not head then 
                for _, e in cache do e.Visible = false end 
            else
                local torsoPos, torsoOn = Camera:WorldToViewportPoint(torso.Position)
                local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
                
                if not torsoOn then 
                    for _, e in cache do e.Visible = false end 
                else
                    local distCam = (torso.Position - camPos).Magnitude
                    local screenPos = Vector2.new(torsoPos.X, torsoPos.Y)
                    local distCenter = (screenPos - center).Magnitude
                    
                    if Settings.ESP.UseFOV and distCenter > fovRad then 
                        for _, e in cache do e.Visible = false end 
                    else
                        local scale = 1000 / distCam * 80 / Camera.FieldOfView
                        local boxW, boxH = math.floor(3 * scale), math.floor(4 * scale)
                        local boxPos = Vector2.new(torsoPos.X - boxW / 2, torsoPos.Y - boxH / 2)
                        local vis = isVisible(head, Settings.ESP.VisibilityCheck)
                        local boxCol = vis and Settings.ESP.Features.Box.Color or Color3.fromRGB(255, 0, 0)
                        
                    
                        cache.BoxSquare.Visible = Settings.ESP.Features.Box.Enabled 
                        if Settings.ESP.Features.Box.Enabled then 
                            cache.BoxSquare.Color = boxCol 
                            cache.BoxSquare.Position = boxPos 
                            cache.BoxSquare.Size = Vector2.new(boxW, boxH) 
                            cache.BoxOutline.Position = Vector2.new(boxPos.X - 1, boxPos.Y - 1) 
                            cache.BoxOutline.Size = Vector2.new(boxW + 2, boxH + 2) 
                        end
                        
                        cache.TracerLine.Visible = Settings.ESP.Features.Tracer.Enabled 
                        if Settings.ESP.Features.Tracer.Enabled then 
                            cache.TracerLine.Color = vis and Settings.ESP.Features.Tracer.Color or Color3.fromRGB(255, 0, 0) 
                            cache.TracerLine.From = Vector2.new(viewSize.X / 2, viewSize.Y) 
                            cache.TracerLine.To = screenPos 
                        end
                        
                        cache.NameLabel.Visible = Settings.ESP.Features.Name.Enabled and State.CachedProperties[p] 
                        if Settings.ESP.Features.Name.Enabled and State.CachedProperties[p] then 
                            cache.NameLabel.Text = State.CachedProperties[p].Name 
                            cache.NameLabel.Color = Settings.ESP.Features.Name.Color 
                            cache.NameLabel.Size = math.max(12, math.min(16, scale * 2.5)) 
                            cache.NameLabel.Center = true 
                            cache.NameLabel.Position = Vector2.new(boxPos.X + (boxW / 2), boxPos.Y - 15) 
                            cache.NameLabel.Outline = true 
                        end
                        
                        cache.DistanceLabel.Visible = Settings.ESP.Features.DistanceText.Enabled 
                        if Settings.ESP.Features.DistanceText.Enabled then 
                            local dist = math.floor(distCam) 
                            cache.DistanceLabel.Text = dist .. " studs" 
                            cache.DistanceLabel.Color = Settings.ESP.Features.DistanceText.Color 
                            cache.DistanceLabel.Size = math.max(14, math.min(18, scale * 2.5)) 
                            cache.DistanceLabel.Position = Vector2.new(boxPos.X + (boxW / 2), boxPos.Y + boxH + 5) 
                            cache.DistanceLabel.Outline = true 
                        end
                        
                        cache.HeadDot.Visible = Settings.ESP.Features.HeadDot.Enabled and headOn 
                        if Settings.ESP.Features.HeadDot.Enabled and headOn then 
                            cache.HeadDot.Color = Settings.ESP.Features.HeadDot.Color 
                            cache.HeadDot.Radius = (boxH / 20) 
                            cache.HeadDot.Position = Vector2.new(headPos.X, headPos.Y) 
                        end
                        
                        if Settings.ESP.Features.HealthBar.Enabled then
                            local health, maxHealth = getPlayerHealth(p)
                            local healthBarWidth = Settings.ESP.Features.HealthBar.Width
                            local healthBarHeight = boxH
                            local healthBarPos = Vector2.new(boxPos.X - healthBarWidth - 2, boxPos.Y)
                            
                            setESPHealthBar(
                                cache, 
                                true, 
                                health, 
                                maxHealth, 
                                healthBarPos, 
                                healthBarWidth, 
                                healthBarHeight, 
                                Settings.ESP.Features.HealthBar.Color, 
                                Settings.ESP.Features.HealthBar.BackgroundColor
                            )
                        else
                            setESPHealthBar(cache, false, 0, 0, Vector2.new(0, 0), 0, 0, Color3.new(), Color3.new())
                        end
                    end
                end
            end
        end
    end
end


local function refreshPlayerCache() if Library.Flags.ESPEnabled then updatePlayerCache() end end

local function getCharacter()
    local char
    while not char do char = workspace.Ignore:FindFirstChildWhichIsA("Model") task.wait() end
    return char
end

local function kickAndRejoin()
    Players.LocalPlayer:Kick("[THIS IS NOT A VOTEKICK!] You've been blocked from being votekicked, Rejoining...")
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end

local function initializeVotekickRejoiner()
    local chatScreenGui = localplayer.PlayerGui:WaitForChild("ChatScreenGui")
    local displayVoteKick = chatScreenGui.Main:WaitForChild("DisplayVoteKick")
    displayVoteKick:GetPropertyChangedSignal("Visible"):Connect(function()
        if displayVoteKick.Visible and Settings.Misc.VotekickRejoiner then
            local textTitle = displayVoteKick.TextTitle.Text
            local words = {}
            for word in string.gmatch(textTitle, "%S+") do table.insert(words, word) end
            if words[2] == localplayer.Name then kickAndRejoin() end
        end
    end)
end

local startTime = os.clock()
local spinAccumulator = 0

local function applyAAAngles(angles)
    local newAngles = angles
    local currentTime = os.clock()
    local deltaTime = currentTime - (lastFrameTime or currentTime)
    lastFrameTime = currentTime
    
    local x, y, z = angles.X, angles.Y, angles.Z
    
    if Settings.AntiAim.Mode == "Spin" then
        local spinRadians = (currentTime - startTime) * math.rad(Settings.AntiAim.SpinSpeed)
        y = spinRadians
        newAngles = Vector3.new(x, y, z)
    elseif Settings.AntiAim.Mode == "Jitter" then
        local jitter = math.rad(math.random(-Settings.AntiAim.JitterAngle, Settings.AntiAim.JitterAngle))
        newAngles = Vector3.new(x, y + jitter, z)
    elseif Settings.AntiAim.Mode == "Static" then
        newAngles = Vector3.new(x, math.rad(Settings.AntiAim.StaticAngle), z)
    end
    
    if Settings.AntiAim.PitchMode == "Up" then
        x = math.clamp(x + math.rad(Settings.AntiAim.PitchAngle), math.rad(-89), math.rad(89))
    elseif Settings.AntiAim.PitchMode == "Down" then
        x = math.clamp(x - math.rad(Settings.AntiAim.PitchAngle), math.rad(-89), math.rad(89))
    elseif Settings.AntiAim.PitchMode == "Random" then
        x = math.clamp(math.rad(math.random(-Settings.AntiAim.PitchAngle, Settings.AntiAim.PitchAngle)), math.rad(-89), math.rad(89))
    end
    
    return Vector3.new(x, newAngles.Y, z)
end

-- Third Person
local step = screenCull.step
screenCull.step = function(...)
    step(...)
    if Settings.ThirdPerson.Enabled then
        local controller = weaponInterface.getActiveWeaponController()
        if controller and (Settings.ThirdPerson.ShowCharacterWhileAiming or not controller:getActiveWeapon()._aiming) then
            local cameraOffset = Vector3.new(Settings.ThirdPerson.CameraOffsetX, Settings.ThirdPerson.CameraOffsetY, Settings.ThirdPerson.CameraOffsetZ)
            local didHit = false
            if Settings.ThirdPerson.CameraOffsetAlwaysVisible then
                local oldPosition = Camera.CFrame.Position
                local newPosition = Camera.CFrame * cameraOffset
                local dir = newPosition - oldPosition
                local hit, position = raycast(oldPosition, dir)
                if hit then Camera.CFrame = Camera.CFrame * CFrame.new(cameraOffset * ((position - oldPosition).Magnitude / cameraOffset.Magnitude) * 0.99) didHit = true end
            end
            if not didHit then Camera.CFrame = Camera.CFrame * CFrame.new(cameraOffset) end
        end
    end
end

local lastPos, deltaTime = nil, 0
local objectChamUncache
RunService.Heartbeat:Connect(function(ndt)
    if Settings.ThirdPerson.Enabled and Settings.ThirdPerson.ShowCharacter then
        local currentCharObject = charInterface.getCharacterObject()
        local rootPart = currentCharObject and currentCharObject:getRealRootPart()
        deltaTime = deltaTime + ndt
        if rootPart then
            local position = rootPart.Position
            lastPos = lastPos or position
            local velocity = (position - lastPos) / deltaTime
            deltaTime = 0
            if currentObj or started then
                if started then
                    local classData = playerClient.getPlayerData().settings.classdata
                    fakeRepObject._player = localplayer
                    fakeRepObject:spawn(nil, classData[classData.curclass])
                    currentObj = fakeRepObject._thirdPersonObject
                    fakeRepObject:setActiveIndex(1)
                    for i = 1, 3 do if fakeRepObject:getWeaponObjects()[i] then currentObj:buildWeapon(i) end end
                end
                local angles = cameraInterface:getActiveCamera():getAngles()
                 if Settings.AntiAim and Settings.AntiAim.Enabled and Settings.ThirdPerson.ApplyAntiAimToCharacter then
                    angles = applyAAAngles(angles)
                end
    
                local clockTime = os.clock()
                local tickTime = tick()
                fakeRepObject._posspring.t = position fakeRepObject._posspring.p = position
                fakeRepObject._lookangles.t = angles fakeRepObject._lookangles.p = angles
                fakeRepObject._smoothReplication:receive(clockTime, tickTime, {t = tickTime, position = position, velocity = velocity, angles = angles, barrelAngles = Vector3.zero, breakcount = 0}, true)
                fakeRepObject._updaterecieved = true fakeRepObject._receivedPosition = position fakeRepObject._receivedFrameTime = network.getTime()
                fakeRepObject._lastPacketTime = clockTime fakeRepObject._lastBarrelAngles = Vector3.zero
                fakeRepObject:step(3, true)
                if currentObj then currentObj.canRenderWeapon = true end
                started = false
                local controller = weaponInterface.getActiveWeaponController()
                local aiming = controller and controller:getActiveWeapon() and controller:getActiveWeapon()._aiming
                if not Settings.ThirdPerson.ShowCharacterWhileAiming and aiming then thirdPersonObject.setCharacterRender(currentObj, false) else thirdPersonObject.setCharacterRender(currentObj, true) end
            end
        elseif not started and currentObj then
            fakeRepObject:despawn() currentObj:Destroy() currentObj = nil lastPos = nil
        end
    end
end)

local setCharacterRender = thirdPersonObject.setCharacterRender
function thirdPersonObject:setCharacterRender(render)
    if Settings.ThirdPerson.Enabled then return setCharacterRender(self, render or (self._player ~= localplayer and Camera:WorldToViewportPoint(self._replicationObject._receivedPosition or self:getRootPart().Position).Z > 0)) end
    return setCharacterRender(self, render)
end

local newSpawnCache = {currentAddition = 0, latency = 0, updateDebt = 0, spawnTime = 0, spawned = false, lastUpdate = nil, lastUpdateTime = 0, walkSpeed = nil}

local originalApplyImpulse = recoil.applyImpulse
function recoil.applyImpulse(...)
    if Settings.GunMods.NoRecoil then return end
    return originalApplyImpulse(...)
end

local originalReload = firearmObject.reload
function firearmObject:reload()
    if Settings.GunMods.InstantReload and self._spareCount > 0 then
        if self._spareCount >= self._weaponData.magsize then self._spareCount = self._spareCount - (self._weaponData.magsize - self._magCount) self._magCount = self._weaponData.magsize
        else self._magCount = self._spareCount self._spareCount = 0 end
        network:send("reload")
        return
    end
    return originalReload(self)
end

local originalComputeWalkSway = firearmObject.computeWalkSway
function firearmObject:computeWalkSway(dy, dx)
    if Settings.GunMods.NoWalkSway then dy = 0 dx = 0 end
    return originalComputeWalkSway(self, dy, dx)
end

local originalComputeGunSway = firearmObject.computeGunSway
function firearmObject.computeGunSway(...)
    if Settings.GunMods.NoSway then return CFrame.identity end
    return originalComputeGunSway(...)
end

local originalFromAxisAngle = cframeLib.fromAxisAngle
function cframeLib.fromAxisAngle(x, y, z)
    if Settings.GunMods.NoCameraSway then
        local controller = weaponInterface.getActiveWeaponController()
        local weapon = controller and controller:getActiveWeapon()
        return (weapon and weapon._blackScoped and CFrame.identity) or originalFromAxisAngle(x, y, z)
    end
    return originalFromAxisAngle(x, y, z)
end

local originalGetModifiedData = modifyData.getModifiedData
function modifyData.getModifiedData(data, ...)
    setreadonly(data, false)
    if Settings.GunMods.NoSpread then data.hipfirespread = 0 data.hipfirestability = 99999 data.hipfirespreadrecover = 99999 end
    if Settings.GunMods.SmallCrosshair then data.crosssize = 10 data.crossexpansion = 0 data.crossspeed = 100 data.crossdamper = 1 end
    if Settings.GunMods.NoCrosshair then data.crosssize = 1000000000 data.crossexpansion = 0 data.crossspeed = 100 data.crossdamper = 1 end
    return originalGetModifiedData(data, ...)
end

local originalUpdateScope = hudScopeInterface.updateScope
function hudScopeInterface.updateScope(...)
    if Settings.GunMods.NoSniperScope then
        local frontLayer = hudScopeInterface._frontLayer local rearLayer = hudScopeInterface._rearLayer
        if frontLayer then frontLayer.ImageTransparency = 1 end if rearLayer then rearLayer.ImageTransparency = 1 end
        for layerIndex = 1, 2 do local layer = layerIndex == 1 and frontLayer or rearLayer if layer then for _, frame in layer:GetChildren() do if frame.ClassName == "Frame" then frame.Visible = false end end end end
    else
        local frontLayer = hudScopeInterface._frontLayer local rearLayer = hudScopeInterface._rearLayer
        if frontLayer then frontLayer.ImageTransparency = 0 end if rearLayer then rearLayer.ImageTransparency = 0 end
        for layerIndex = 1, 2 do local layer = layerIndex == 1 and frontLayer or rearLayer if layer then for _, frame in layer:GetChildren() do if frame.ClassName == "Frame" then frame.Visible = true end end end end
    end
    return originalUpdateScope(...)
end

local originalCameraStep = cameraObject.step
function cameraObject.step(self, dt)
    if Settings.GunMods.NoCameraBob then
        local characterObject = charInterface.getCharacterObject()
        if characterObject then local oldSpeed = characterObject._speed characterObject._speed = 0 originalCameraStep(self, dt) characterObject._speed = oldSpeed return end
    end
    return originalCameraStep(self, dt)
end

local send = network.send
function network:send(name, ...)
    if Settings.ThirdPerson.Enabled and Settings.ThirdPerson.ShowCharacter then
        if name == "spawn" then
            if not started then
                started = true
                newSpawnCache = {
                    currentAddition = 0,
                    latency = 0,
                    updateDebt = 0,
                    spawnTime = os.clock(),
                    spawned = true,
                    lastUpdate = nil,
                    lastUpdateTime = 0
                }
                if not currentObj then
                    if fakeRepObject then
                        currentObj = charInterface.getCharacterObject()
                        if not currentObj then
                            pcall(function()
                                currentObj = thirdPersonObject.new(fakeRepObject)
                                if currentObj then
                                    currentObj:spawn()
                                end
                            end)
                        else
                            currentObj:spawn()
                        end
                    else
                        warn("fakeRepObject is nil, cannot initialize third-person character")
                    end
                end
            end
        elseif currentObj then
            if name == "equip" then
                local slot = ...
                fakeRepObject:setActiveIndex(slot)
                if slot ~= 3 then
                    currentObj:equip(slot)
                else
                    currentObj:equipMelee()
                end
            elseif name == "stab" then
                currentObj:stab()
            elseif name == "aim" then
                local aiming = ...
                currentObj:setAim(aiming)
            elseif name == "sprint" then
                local sprinting = ...
                currentObj:setSprint(sprinting)
            elseif name == "stance" then
                local stance = ...
                currentObj:setStance(stance)
            elseif name == "newbullets" then
            end
        end
    end
    
    if name == "repupdate" then
        local position, angles, angles2, time = ...
        
        if Settings.AntiAim.Enabled then
            angles = applyAAAngles(angles)
            angles2 = Vector3.new(angles.X * 0.99, angles.Y * 0.99, angles.Z * 0.99)
        end
        
        if newSpawnCache.updateDebt > 0 then
            newSpawnCache.updateDebt -= 1
            return
        end
        
        if Settings.Player.WalkSpeed.Enabled and newSpawnCache.lastUpdate then
            send(self, name, newSpawnCache.lastUpdate, angles, angles2, time + newSpawnCache.latency + newSpawnCache.currentAddition)
            newSpawnCache.updateDebt += 1
        end

        newSpawnCache.lastUpdate = position
        newSpawnCache.lastUpdateTime = time

        return send(self, name, position, angles, angles2, time + newSpawnCache.latency + newSpawnCache.currentAddition)
    end
    
    return send(self, name, ...)
end

local preparePickUpFirearm = weaponObject.preparePickUpFirearm
function weaponObject:preparePickUpFirearm(slot, name, attachments, attData, camoData, magAmmo, spareAmmo, newId, wasClient, ...)
    local wepData = {weaponName = name, weaponAttachments = attachments, weaponAttData = attData, weaponCamo = camoData}
    fakeRepObject:setActiveIndex(slot) fakeRepObject:swapWeapon(slot, wepData)
    if currentObj then currentObj:buildWeapon(slot) end
    return preparePickUpFirearm(self, slot, name, attachments, attData, camoData, magAmmo, spareAmmo, newId, wasClient, ...)
end

local preparePickUpMelee = weaponObject.preparePickUpMelee
function weaponObject:preparePickUpMelee(name, camoData, newId, wasClient, ...)
    local wepData = {weaponName = name, weaponCamo = camoData}
    fakeRepObject:setActiveIndex(3) fakeRepObject:swapWeapon(3, wepData)
    if currentObj then currentObj:buildWeapon(3) end
    return preparePickUpMelee(self, name, camoData, newId, wasClient, ...)
end

local setBaseWalkSpeed = charObject.setBaseWalkSpeed
function charObject:setBaseWalkSpeed(speed)
    newSpawnCache.walkSpeed = newSpawnCache.walkSpeed or speed
    return setBaseWalkSpeed(self, Settings.Player.WalkSpeed.Enabled and Settings.Player.WalkSpeed.Value or speed)
end

local jump = charObject.jump
function charObject:jump(height, vaulting)
    return jump(self, 4 + (Settings.Player.JumpPower.Enabled and Settings.Player.JumpPower.Value or 0), vaulting)
end

local callbackList = {}
callbackList["Player%%WalkSpeed"] = function(state)
    if charInterface.isAlive() then
        local object = charInterface.getCharacterObject()
        if state then setBaseWalkSpeed(object, Settings.Player.WalkSpeed.Value) else setBaseWalkSpeed(object, newSpawnCache.walkSpeed) end
        object:updateWalkSpeed()
    end
end

callbackList["Player%%WalkSpeedValue"] = function(value)
    if charInterface.isAlive() and Settings.Player.WalkSpeed.Enabled then
        local object = charInterface.getCharacterObject()
        setBaseWalkSpeed(object, value)
        object:updateWalkSpeed()
    end
end


local function loadConfig(name)
    if not name or name == "" or name == "None" then
        Library:Notify({Text = "Please select a valid config"})
        return
    end
    
    if not isfolder(Configs.Path) or not isfile(Configs.Path .. name .. ".json") then
        Library:Notify({Text = "Config not found: " .. name})
        return
    end
    
    local success, configData = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(Configs.Path .. name .. ".json"))
    end)
    
    if not success then
        Library:Notify({Text = "Failed to load config: " .. name})
        return
    end
    
    local function applyConfigData(data, targetTable)
        for k, v in pairs(data) do
            local keys = {}
            for key in string.gmatch(k, "[^.]+") do
                table.insert(keys, key)
            end
            local current = targetTable
            for i = 1, #keys - 1 do
                current = current[keys[i]]
                if not current then return end
            end
            current[keys[#keys]] = v
        end
    end
    
    applyConfigData(configData, Settings)
    
    if configData["Aimbot.Enabled"] ~= nil then
        Library.Flags["AimbotEnabled"] = configData["Aimbot.Enabled"]
        if configData["Aimbot.Enabled"] then
            startMousePreload()
            State.InputBeganConnection = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then State.IsRightClickHeld = true State.TargetPart = getClosestPlayer() end end)
            State.InputEndedConnection = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then State.IsRightClickHeld = false State.TargetPart = nil end end)
            State.RenderSteppedConnection = RunService.RenderStepped:Connect(function() if State.IsRightClickHeld and State.TargetPart then if Settings.Aimbot.WallCheck then if isVisible(State.TargetPart, true) then aimAt() end else aimAt() end end end)
        else
            stopMousePreload()
            if State.InputBeganConnection then State.InputBeganConnection:Disconnect() end 
            if State.InputEndedConnection then State.InputEndedConnection:Disconnect() end 
            if State.RenderSteppedConnection then State.RenderSteppedConnection:Disconnect() end
        end
    end
    
    local flagMappings = {
        ["Aimbot.Enabled"] = "AimbotEnabled",
        ["Aimbot.HitPart"] = "AimbotHitPart",
        ["Aimbot.WallCheck"] = "AimbotWallCheck",
        ["Aimbot.AutoTargetSwitch"] = "AimbotAutoTargetSwitch",
        ["Aimbot.MaxDistance.Enabled"] = "AimbotMaxDistanceEnabled",
        ["Aimbot.MaxDistance.Value"] = "AimbotMaxDistance",
        ["Aimbot.Easing.Strength"] = "AimbotEasingStrength",
        
        ["SilentAim.Enabled"] = "SilentAimEnabled",
        ["SilentAim.HitPart"] = "SilentAimHitPart",
        ["SilentAim.UseFOV"] = "SilentAimUseFOV",
        ["SilentAim.WallCheck"] = "SilentAimWallCheck",
        ["SilentAim.HitChance"] = "SilentAimHitChance",
        
        ["ESP.Enabled"] = "ESPEnabled",
        ["ESP.Features.Box.Enabled"] = "ESPBox",
        ["ESP.Features.Tracer.Enabled"] = "ESPTracer",
        ["ESP.Features.HeadDot.Enabled"] = "ESPHeadDot",
        ["ESP.Features.DistanceText.Enabled"] = "ESPDistance",
        ["ESP.Features.Name.Enabled"] = "ESPName",
        ["ESP.Features.HealthBar.Enabled"] = "ESPHealthBar",
        ["ESP.VisibilityCheck"] = "ESPVisibilityCheck",
        ["ESP.MaxDistance.Enabled"] = "ESPMaxDistanceEnabled",
        ["ESP.MaxDistance.Value"] = "ESPMaxDistance",
        
        ["ESP.Features.Box.Color"] = "ESPBoxColor",
        ["ESP.Features.Tracer.Color"] = "ESPTracerColor",
        ["ESP.Features.DistanceText.Color"] = "ESPDistanceColor",
        ["ESP.Features.HeadDot.Color"] = "ESPHeadDotColor",
        ["ESP.Features.Name.Color"] = "ESPNameColor",
        ["ESP.Features.HealthBar.Color"] = "ESPHealthBarColor",
        ["ESP.Features.HealthBar.BackgroundColor"] = "ESPHealthBarBG",
        ["ESP.Features.HealthBar.Width"] = "ESPHealthBarWidth",
        ["ESP.Features.HealthBar.Height"] = "ESPHealthBarHeight",
        ["ESP.Features.HealthBar.OutlineColor"] = "ESPHealthBarOutlineColor",
        
        ["FOV.Enabled"] = "FOVEnabled",
        ["FOV.FollowGun"] = "FOVFollowGun",
        ["FOV.Filled"] = "FOVFilled",
        ["FOV.FillColor"] = "FOVFillColor",
        ["FOV.FillTransparency"] = "FOVFillTransparency",
        ["FOV.OutlineColor"] = "FOVOutlineColor",
        ["FOV.OutlineTransparency"] = "FOVOutlineTransparency",
        ["FOV.Radius"] = "FOVRadius",
        
        ["Chams.Enabled"] = "ChamsEnabled",
        ["Chams.Fill.Color"] = "ChamsFillColor",
        ["Chams.Outline.Color"] = "ChamsOutlineColor",
        ["Chams.Fill.Transparency"] = "ChamsFillTransparency",
        ["Chams.Outline.Transparency"] = "ChamsOutlineTransparency",
        
        ["GunMods.NoRecoil"] = "NoRecoil",
        ["GunMods.NoSpread"] = "NoSpread",
        ["GunMods.NoSway"] = "NoSway",
        ["GunMods.NoSniperScope"] = "NoSniperScope",
        ["GunMods.InstantReload"] = "InstantReload",
        ["GunMods.NoWalkSway"] = "NoWalkSway",
        ["GunMods.NoCameraBob"] = "NoCameraBob",
        ["GunMods.SmallCrosshair"] = "SmallCrosshair",
        ["GunMods.NoCrosshair"] = "NoCrosshair",
        
        ["ThirdPerson.Enabled"] = "ThirdPersonEnabled",
        ["ThirdPerson.ShowCharacter"] = "ThirdPersonShowCharacter",
        ["ThirdPerson.ShowCharacterWhileAiming"] = "ThirdPersonShowCharacterWhileAiming",
        ["ThirdPerson.CameraOffsetAlwaysVisible"] = "ThirdPersonCameraOffsetAlwaysVisible",
        ["ThirdPerson.HideViewmodel"] = "ThirdPersonHideViewmodel",
        ["ThirdPerson.CameraOffsetX"] = "ThirdPersonCameraOffsetX",
        ["ThirdPerson.CameraOffsetY"] = "ThirdPersonCameraOffsetY",
        ["ThirdPerson.CameraOffsetZ"] = "ThirdPersonCameraOffsetZ",
        
        ["Player.Bhop.Enabled"] = "BhopEnabled",
        ["Player.WalkSpeed.Enabled"] = "WalkSpeedEnabled",
        ["Player.WalkSpeed.Value"] = "WalkSpeedValue",
        ["Player.JumpPower.Enabled"] = "JumpPowerEnabled",
        ["Player.JumpPower.Value"] = "JumpPowerValue",
        
        ["AntiAim.Enabled"] = "AntiAimEnabled",
        ["AntiAim.Mode"] = "AntiAimMode",
        ["AntiAim.SpinSpeed"] = "AntiAimSpinSpeed",
        ["AntiAim.JitterAngle"] = "AntiAimJitterAngle",
        ["AntiAim.StaticAngle"] = "AntiAimStaticAngle",
        ["AntiAim.PitchMode"] = "AntiAimPitchMode",
        ["AntiAim.PitchAngle"] = "AntiAimPitchAngle",
        
        ["Crosshair.Enabled"] = "CrosshairEnabled",
        ["Crosshair.TStyle"] = "CrosshairStyle",
        ["Crosshair.Dot"] = "CrosshairDot",
        ["Crosshair.Size"] = "CrosshairSize",
        ["Crosshair.Thickness"] = "CrosshairThickness",
        ["Crosshair.Gap"] = "CrosshairGap",
        ["Crosshair.Color"] = "CrosshairColor",
        ["Crosshair.Transparency"] = "CrosshairTransparency",
        
        ["Misc.Textures"] = "MiscTextures",
        ["Misc.VotekickRejoiner"] = "VotekickRejoiner"
    }
    
    for settingPath, flagName in pairs(flagMappings) do
        if configData[settingPath] ~= nil then
            Library.Flags[flagName] = configData[settingPath]
        end
    end
        
    if configData["SilentAim.Enabled"] and configData["SilentAim.Enabled"] then
        initializeSilentAim()
    end
    
    if configData["SilentAim.HitChance"] then
        Settings.SilentAim.HitChance = configData["SilentAim.HitChance"]
    end

    if configData["ESP.Enabled"] ~= nil then
        if configData["ESP.Enabled"] then
            initializeESP()
            State.PlayerCacheUpdate = RunService.Heartbeat:Connect(updatePlayerCache)
            local last = tick()
            local interval = 1 / 240
            State.ESPLoop = RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - last >= interval then
                    renderESP()
                    last = now
                end
            end)
        else
            if State.PlayerCacheUpdate then State.PlayerCacheUpdate:Disconnect() end
            if State.ESPLoop then State.ESPLoop:Disconnect() end
            for p in State.Storage.ESPCache do uncacheObject(p) end
            State.PlayersToDraw = {}
            State.CachedProperties = {}
        end
    end
    
    if configData["FOV.Enabled"] ~= nil then
        Settings.FOV.Circle.Visible = configData["FOV.Enabled"]
        Settings.FOV.OutlineCircle.Visible = configData["FOV.Enabled"]
    end
    
    if configData["Chams.Enabled"] ~= nil then
        if configData["Chams.Enabled"] then
            State.ChamsUpdateConnection = RunService.RenderStepped:Connect(updateChams)
        else
            if State.ChamsUpdateConnection then
                State.ChamsUpdateConnection:Disconnect()
                State.ChamsUpdateConnection = nil
            end
            for p in State.Highlights do
                removeHighlight(p)
            end
        end
    end
    
    if configData["Crosshair.Enabled"] ~= nil then
        toggleCrosshair(configData["Crosshair.Enabled"])
    end
    
    if configData["ThirdPerson.Enabled"] ~= nil then
        if charInterface.isAlive() and configData["ThirdPerson.ShowCharacter"] then
            if configData["ThirdPerson.Enabled"] then
                started = true
            else
                fakeRepObject:despawn()
                if currentObj then
                    currentObj:Destroy()
                    currentObj = nil
                    lastPos = nil
                end
            end
        end
    end
    
    if configData["Player.WalkSpeed.Enabled"] ~= nil then
        callbackList["Player%%WalkSpeed"](configData["Player.WalkSpeed.Enabled"])
    end
    
    if configData["AntiAim.Enabled"] ~= nil then
        startTime = os.clock()
        lastFrameTime = nil
        if configData["AntiAim.Enabled"] then
            State.AntiAimConnection = RunService.Heartbeat:Connect(function()
                if Settings.AntiAim.Enabled and charInterface.isAlive() then
                    local currentCharObject = charInterface.getCharacterObject()
                    if currentCharObject then
                        local rootPart = currentCharObject:getRealRootPart()
                        if rootPart then
                            local angles = cameraInterface:getActiveCamera():getAngles()
                            local modifiedAngles = applyAAAngles(angles)
                        end
                    end
                end
            end)
        else
            if State.AntiAimConnection then
                State.AntiAimConnection:Disconnect()
                State.AntiAimConnection = nil
            end
        end
    end
    
    if configData["Misc.Textures"] ~= nil then
        if configData["Misc.Textures"] then
            optimizeMap()
        else
            revertMap()
        end
    end
    
    if configData["Misc.VotekickRejoiner"] and configData["Misc.VotekickRejoiner"] then
        initializeVotekickRejoiner()
    end
    
    if configData["Aimbot.Easing.Strength"] then
        updateSensitivity(configData["Aimbot.Easing.Strength"])
    end
    
    Library:Notify({Text = "Config loaded: " .. name})
    Configs.Current = name
    
    if ConfigNameTextbox then
        ConfigNameTextbox:Set(name)
    end
end

-- UI
local Window = Library:CreateWindow({Name = "Astralis", Themeable = {Info = "dsc.gg/kaotiksoftworks"}})
local Tabs = {Main = Window:CreateTab({Name = "Main"}), Mods = Window:CreateTab({Name = "Mods"}), Visuals = Window:CreateTab({Name = "Visuals"}), Player = Window:CreateTab({Name = "Player"}), Misc = Window:CreateTab({Name = "Misc"}), Configs = Window:CreateTab({Name = "Configs"})}

local GunModsGroup = Tabs.Mods:CreateSection({Name = "Gun Modifications"})
GunModsGroup:AddToggle({Name = "No Recoil", Flag = "NoRecoil", Value = Settings.GunMods.NoRecoil, Callback = function(s) Settings.GunMods.NoRecoil = s end})
GunModsGroup:AddToggle({Name = "No Spread", Flag = "NoSpread", Value = Settings.GunMods.NoSpread, Callback = function(s) Settings.GunMods.NoSpread = s end})
GunModsGroup:AddToggle({Name = "No Gun Sway", Flag = "NoSway", Value = Settings.GunMods.NoSway, Callback = function(s) Settings.GunMods.NoSway = s end})
GunModsGroup:AddToggle({Name = "No Sniper Scope", Flag = "NoSniperScope", Value = Settings.GunMods.NoSniperScope, Callback = function(s) Settings.GunMods.NoSniperScope = s end})
GunModsGroup:AddToggle({Name = "Instant Reload", Flag = "InstantReload", Value = Settings.GunMods.InstantReload, Callback = function(s) Settings.GunMods.InstantReload = s end})
GunModsGroup:AddToggle({Name = "No Walk Sway", Flag = "NoWalkSway", Value = Settings.GunMods.NoWalkSway, Callback = function(s) Settings.GunMods.NoWalkSway = s end})

local CamModsGroup = Tabs.Mods:CreateSection({Name = "Camera Modifications", Side = "Right"})
CamModsGroup:AddToggle({Name = "No Camera Bob", Flag = "NoCameraBob", Value = Settings.GunMods.NoCameraBob, Callback = function(s) Settings.GunMods.NoCameraBob = s end})

local MiscModsGroup = Tabs.Mods:CreateSection({Name = "Misc Modifications", Side = "Right"})
--MiscModsGroup:AddToggle({Name = "Small Crosshair", Flag = "SmallCrosshair", Value = Settings.GunMods.SmallCrosshair, Callback = function(s) Settings.GunMods.SmallCrosshair = s end})
--MiscModsGroup:AddToggle({Name = "No Crosshair", Flag = "NoCrosshair", Value = Settings.GunMods.NoCrosshair, Callback = function(s) Settings.GunMods.NoCrosshair = s end})

local CrosshairGroup = Tabs.Misc:CreateSection({Name = "Crosshair"})
CrosshairGroup:AddToggle({Name = "Enabled", Flag = "CrosshairEnabled", Value = Settings.Crosshair.Enabled, Callback = function(s) Settings.Crosshair.Enabled = s toggleCrosshair(s) end})
CrosshairGroup:AddDropdown({Name = "Style", Flag = "CrosshairStyle", List = {"Default", "Plus"}, Value = Settings.Crosshair.TStyle, Callback = function(v) Settings.Crosshair.TStyle = v end})
CrosshairGroup:AddToggle({Name = "Center Dot", Flag = "CrosshairDot", Value = Settings.Crosshair.Dot, Callback = function(s) Settings.Crosshair.Dot = s end})
CrosshairGroup:AddSlider({Name = "Size", Flag = "CrosshairSize", Value = Settings.Crosshair.Size, Min = 1, Max = 30, Rounding = 0, Callback = function(v) Settings.Crosshair.Size = v end})
CrosshairGroup:AddSlider({Name = "Thickness", Flag = "CrosshairThickness", Value = Settings.Crosshair.Thickness, Min = 1, Max = 5, Rounding = 0, Callback = function(v) Settings.Crosshair.Thickness = v end})
CrosshairGroup:AddSlider({Name = "Gap", Flag = "CrosshairGap", Value = Settings.Crosshair.Gap, Min = 0, Max = 20, Rounding = 0, Callback = function(v) Settings.Crosshair.Gap = v end})
CrosshairGroup:AddColorPicker({Name = "Color", Flag = "CrosshairColor", Color = Settings.Crosshair.Color, Transparency = 0, Callback = function(v) Settings.Crosshair.Color = v end})
CrosshairGroup:AddSlider({Name = "Transparency", Flag = "CrosshairTransparency", Value = Settings.Crosshair.Transparency, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Settings.Crosshair.Transparency = v end})

local ThirdPersonGroup = Tabs.Player:CreateSection({Name = "Third Person"})
ThirdPersonGroup:AddToggle({Name = "Enabled", Flag = "ThirdPersonEnabled", Value = Settings.ThirdPerson.Enabled, Callback = function(s)
    Settings.ThirdPerson.Enabled = s
    if charInterface.isAlive() and Settings.ThirdPerson.ShowCharacter then
        if s then started = true else fakeRepObject:despawn() if currentObj then currentObj:Destroy() currentObj = nil lastPos = nil end end
    end
end})
ThirdPersonGroup:AddToggle({Name = "Show Character", Flag = "ThirdPersonShowCharacter", Value = Settings.ThirdPerson.ShowCharacter, Callback = function(s)
    Settings.ThirdPerson.ShowCharacter = s
    if charInterface.isAlive() and Settings.ThirdPerson.Enabled then
        if s then started = true else fakeRepObject:despawn() if currentObj then currentObj:Destroy() currentObj = nil lastPos = nil end end
    end
end})
ThirdPersonGroup:AddToggle({Name = "Show Character While Aiming", Flag = "ThirdPersonShowCharacterWhileAiming", Value = Settings.ThirdPerson.ShowCharacterWhileAiming, Callback = function(s) Settings.ThirdPerson.ShowCharacterWhileAiming = s end})
ThirdPersonGroup:AddToggle({Name = "Camera Offset Always Visible", Flag = "ThirdPersonCameraOffsetAlwaysVisible", Value = Settings.ThirdPerson.CameraOffsetAlwaysVisible, Callback = function(s) Settings.ThirdPerson.CameraOffsetAlwaysVisible = s end})
ThirdPersonGroup:AddToggle({Name = "Hide Viewmodel", Flag = "ThirdPersonHideViewmodel", Value = Settings.ThirdPerson.HideViewmodel, Callback = function(s) Settings.ThirdPerson.HideViewmodel = s end})
ThirdPersonGroup:AddSlider({Name = "Camera Offset X", Flag = "ThirdPersonCameraOffsetX", Value = Settings.ThirdPerson.CameraOffsetX, Min = -10, Max = 10, Rounding = 1, Callback = function(v) Settings.ThirdPerson.CameraOffsetX = v end})
ThirdPersonGroup:AddSlider({Name = "Camera Offset Y", Flag = "ThirdPersonCameraOffsetY", Value = Settings.ThirdPerson.CameraOffsetY, Min = -10, Max = 10, Rounding = 1, Callback = function(v) Settings.ThirdPerson.CameraOffsetY = v end})
ThirdPersonGroup:AddSlider({Name = "Camera Offset Z", Flag = "ThirdPersonCameraOffsetZ", Value = Settings.ThirdPerson.CameraOffsetZ, Min = -10, Max = 10, Rounding = 1, Callback = function(v) Settings.ThirdPerson.CameraOffsetZ = v end})

local function storeViewmodelProperties()
    for _, model in workspace.Camera:GetChildren() do
        if model:IsA("Model") and not model.Name:lower():find("arm") then
            for _, part in model:GetDescendants() do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    if not State.ViewmodelProperties[part] then
                        State.ViewmodelProperties[part] = {Transparency = part.Transparency, Textures = {}}
                        for _, texture in part:GetChildren() do if texture:IsA("Texture") or texture:IsA("Decal") or texture.Name == "TextureId" then table.insert(State.ViewmodelProperties[part].Textures, texture) end end
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local controller = weaponInterface.getActiveWeaponController()
    local isAiming = controller and controller:getActiveWeapon() and controller:getActiveWeapon()._aiming
    local shouldHideViewmodel = Settings.ThirdPerson.Enabled and Settings.ThirdPerson.HideViewmodel and (Settings.ThirdPerson.ShowCharacterWhileAiming or not isAiming)
    if shouldHideViewmodel then
        storeViewmodelProperties()
        local gunTexFolder = game.CoreGui:FindFirstChild("guntex") or Instance.new("Folder", game.CoreGui) gunTexFolder.Name = "guntex"
        for _, model in workspace.Camera:GetChildren() do
            if model:IsA("Model") and not model.Name:lower():find("arm") then
                for _, part in model:GetDescendants() do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then part.Transparency = 1 for _, texture in part:GetChildren() do if texture:IsA("Texture") or texture:IsA("Decal") or texture.Name == "TextureId" then texture.Parent = gunTexFolder end end end
                end
            end
        end
    else
        local gunTexFolder = game.CoreGui:FindFirstChild("guntex")
        if gunTexFolder then
            for _, texture in gunTexFolder:GetChildren() do
                for part, props in State.ViewmodelProperties do
                    for _, savedTexture in props.Textures do if savedTexture == texture then texture.Parent = part break end end
                end
            end
            gunTexFolder:Destroy()
        end
        for part, props in State.ViewmodelProperties do if part:IsDescendantOf(workspace) then part.Transparency = props.Transparency end end
        State.ViewmodelProperties = {}
    end
end)

local AimbotGroup = Tabs.Main:CreateSection({Name = "Aimbot"})
AimbotGroup:AddToggle({Name = "Enabled", Flag = "AimbotEnabled", Value = Settings.Aimbot.Enabled, Callback = function(s)
    Settings.Aimbot.Enabled = s
    if s then
        startMousePreload()
        State.InputBeganConnection = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then State.IsRightClickHeld = true State.TargetPart = getClosestPlayer() end end)
        State.InputEndedConnection = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton2 then State.IsRightClickHeld = false State.TargetPart = nil end end)
        State.RenderSteppedConnection = RunService.RenderStepped:Connect(function() if State.IsRightClickHeld and State.TargetPart then if Settings.Aimbot.WallCheck then if isVisible(State.TargetPart, true) then aimAt() end else aimAt() end end end)
    else
        stopMousePreload()
        if State.InputBeganConnection then State.InputBeganConnection:Disconnect() end if State.InputEndedConnection then State.InputEndedConnection:Disconnect() end if State.RenderSteppedConnection then State.RenderSteppedConnection:Disconnect() end
    end
end})
AimbotGroup:AddDropdown({Name = "Hit Part", Flag = "AimbotHitPart", List = {"Head", "Torso"}, Value = Settings.Aimbot.HitPart, Callback = function(v) Settings.Aimbot.HitPart = v end})
AimbotGroup:AddToggle({Name = "Wall Check", Flag = "AimbotWallCheck", Value = Settings.Aimbot.WallCheck, Callback = function(s) Settings.Aimbot.WallCheck = s end})
AimbotGroup:AddToggle({Name = "Auto Target Switch", Flag = "AimbotAutoTargetSwitch", Value = Settings.Aimbot.AutoTargetSwitch, Callback = function(s) Settings.Aimbot.AutoTargetSwitch = s end})
AimbotGroup:AddToggle({Name = "Use Max Distance", Flag = "AimbotMaxDistanceEnabled", Value = Settings.Aimbot.MaxDistance.Enabled, Callback = function(s) Settings.Aimbot.MaxDistance.Enabled = s end})
AimbotGroup:AddSlider({Name = "Max Distance", Flag = "AimbotMaxDistance", Value = Settings.Aimbot.MaxDistance.Value, Min = 10, Max = 1000, Rounding = 0, Callback = function(v) Settings.Aimbot.MaxDistance.Value = v end})
AimbotGroup:AddSlider({Name = "Strength", Flag = "AimbotEasingStrength", Value = Settings.Aimbot.Easing.Strength, Min = 0.1, Max = 1.5, Decimals = 1, Rounding = 1, Callback = function(v) Settings.Aimbot.Easing.Strength = v updateSensitivity(v) end})

local SilentAimGroup = Tabs.Main:CreateSection({Name = "Silent Aim"})
SilentAimGroup:AddToggle({Name = "Enabled", Flag = "SilentAimEnabled", Value = Settings.SilentAim.Enabled, Callback = function(s) Settings.SilentAim.Enabled = s if s then initializeSilentAim() end end})
SilentAimGroup:AddDropdown({Name = "Hit Part", Flag = "SilentAimHitPart", List = {"Head", "Torso"}, Value = Settings.SilentAim.HitPart, Callback = function(v) Settings.SilentAim.HitPart = v end})
SilentAimGroup:AddSlider({Name = "Hit Chance", Flag = "SilentAimHitChance", Value = Settings.SilentAim.HitChance, Min = 0, Max = 100, Rounding = 0, Callback = function(v) Settings.SilentAim.HitChance = v end})
SilentAimGroup:AddToggle({Name = "Use FOV", Flag = "SilentAimUseFOV", Value = Settings.SilentAim.UseFOV, Callback = function(s) Settings.SilentAim.UseFOV = s end})
SilentAimGroup:AddToggle({Name = "Wall Check", Flag = "SilentAimWallCheck", Value = Settings.SilentAim.WallCheck, Callback = function(s) Settings.SilentAim.WallCheck = s end})

local ESPGroup = Tabs.Visuals:CreateSection({Name = "ESP"})
ESPGroup:AddToggle({Name = "Enabled", Flag = "ESPEnabled", Value = Settings.ESP.Enabled, Callback = function(s)
    Settings.ESP.Enabled = s
    if s then initializeESP() State.PlayerCacheUpdate = RunService.Heartbeat:Connect(updatePlayerCache) local last = tick() local interval = 1 / 240 State.ESPLoop = RunService.Heartbeat:Connect(function() local now = tick() if now - last >= interval then renderESP() last = now end end)
    else if State.PlayerCacheUpdate then State.PlayerCacheUpdate:Disconnect() end if State.ESPLoop then State.ESPLoop:Disconnect() end for p in State.Storage.ESPCache do uncacheObject(p) end State.PlayersToDraw = {} State.CachedProperties = {} end
end})
local function updateESPFeature(f, s) Settings.ESP.Features[f].Enabled = s for _, c in State.Storage.ESPCache do if f == "Box" then c.BoxSquare.Visible = s c.BoxOutline.Visible = s elseif f == "Tracer" then c.TracerLine.Visible = s elseif f == "HeadDot" then c.HeadDot.Visible = s elseif f == "DistanceText" then c.DistanceLabel.Visible = s elseif f == "Name" then c.NameLabel.Visible = s end end end
ESPGroup:AddToggle({Name = "Box", Flag = "ESPBox", Value = Settings.ESP.Features.Box.Enabled, Callback = function(s) updateESPFeature("Box", s) end})
ESPGroup:AddToggle({Name = "Tracer", Flag = "ESPTracer", Value = Settings.ESP.Features.Tracer.Enabled, Callback = function(s) updateESPFeature("Tracer", s) end})
ESPGroup:AddToggle({Name = "Head Dot", Flag = "ESPHeadDot", Value = Settings.ESP.Features.HeadDot.Enabled, Callback = function(s) updateESPFeature("HeadDot", s) end})
ESPGroup:AddToggle({Name = "Distance", Flag = "ESPDistance", Value = Settings.ESP.Features.DistanceText.Enabled, Callback = function(s) updateESPFeature("DistanceText", s) end})
ESPGroup:AddToggle({Name = "Name", Flag = "ESPName", Value = Settings.ESP.Features.Name.Enabled, Callback = function(s) updateESPFeature("Name", s) end})
ESPGroup:AddToggle({Name = "Wall Check", Flag = "ESPVisibilityCheck", Value = Settings.ESP.VisibilityCheck, Callback = function(s) Settings.ESP.VisibilityCheck = s end})

local ESPCustomization = Tabs.Visuals:CreateSection({Name = "ESP Colors", Side = "Right"})
local function updateESPColor(f, c) Settings.ESP.Features[f].Color = c for _, cache in State.Storage.ESPCache do if f == "Box" then cache.BoxSquare.Color = c elseif f == "Tracer" then cache.TracerLine.Color = c elseif f == "HeadDot" then cache.HeadDot.Color = c elseif f == "DistanceText" then cache.DistanceLabel.Color = c elseif f == "Name" then cache.NameLabel.Color = c end end end
ESPCustomization:AddColorPicker({Name = "Box Color", Flag = "ESPBoxColor", Color = Settings.ESP.Features.Box.Color, Callback = function(v) updateESPColor("Box", v) end})
ESPCustomization:AddColorPicker({Name = "Tracer Color", Flag = "ESPTracerColor", Color = Settings.ESP.Features.Tracer.Color, Callback = function(v) updateESPColor("Tracer", v) end})
ESPCustomization:AddColorPicker({Name = "Distance Color", Flag = "ESPDistanceColor", Color = Settings.ESP.Features.DistanceText.Color, Callback = function(v) updateESPColor("DistanceText", v) end})
ESPCustomization:AddColorPicker({Name = "Head Dot Color", Flag = "ESPHeadDotColor", Color = Settings.ESP.Features.HeadDot.Color, Callback = function(v) updateESPColor("HeadDot", v) end})
ESPCustomization:AddColorPicker({Name = "Name Color", Flag = "ESPNameColor", Color = Settings.ESP.Features.Name.Color, Callback = function(v) updateESPColor("Name", v) end})

ESPGroup:AddToggle({Name = "Health Bar", Flag = "ESPHealthBar", Value = Settings.ESP.Features.HealthBar.Enabled, Callback = function(s) 
    Settings.ESP.Features.HealthBar.Enabled = s 
    for _, c in State.Storage.ESPCache do 
        if c.HealthBarBackground then c.HealthBarBackground.Visible = s end
        if c.HealthBarForeground then c.HealthBarForeground.Visible = s end
    end 
end})

ESPCustomization:AddColorPicker({Name = "Health Bar Color", Flag = "ESPHealthBarColor", Color = Settings.ESP.Features.HealthBar.Color, Callback = function(v) 
    Settings.ESP.Features.HealthBar.Color = v 
    for _, cache in State.Storage.ESPCache do 
        if cache.HealthBarForeground then cache.HealthBarForeground.Color = v end
    end 
end})

ESPCustomization:AddColorPicker({Name = "Health Bar Background", Flag = "ESPHealthBarBG", Color = Settings.ESP.Features.HealthBar.BackgroundColor, Callback = function(v) 
    Settings.ESP.Features.HealthBar.BackgroundColor = v 
    for _, cache in State.Storage.ESPCache do 
        if cache.HealthBarBackground then cache.HealthBarBackground.Color = v end
    end 
end})

local HealthBarCustomization = Tabs.Visuals:CreateSection({Name = "Health Bar Settings", Side = "Right"})
HealthBarCustomization:AddSlider({Name = "Width", Flag = "ESPHealthBarWidth", Value = Settings.ESP.Features.HealthBar.Width, Min = 1, Max = 5, Rounding = 0, Callback = function(v) Settings.ESP.Features.HealthBar.Width = v end})
HealthBarCustomization:AddSlider({Name = "Height", Flag = "ESPHealthBarHeight", Value = Settings.ESP.Features.HealthBar.Height, Min = 10, Max = 80, Rounding = 0, Callback = function(v) Settings.ESP.Features.HealthBar.Height = v end})
HealthBarCustomization:AddColorPicker({Name = "Outline Color", Flag = "ESPHealthBarOutlineColor", Color = Settings.ESP.Features.HealthBar.OutlineColor, Transparency = 0.7, Callback = function(v) 
    Settings.ESP.Features.HealthBar.OutlineColor = v 
    for _, cache in State.Storage.ESPCache do 
        if cache.HealthBarOutline then cache.HealthBarOutline.Color = v end
    end 
end})

local DistanceCustomization = Tabs.Visuals:CreateSection({Name = "Distance Settings", Side = "Right"})
DistanceCustomization:AddToggle({Name = "Use Max Distance", Flag = "ESPMaxDistanceEnabled", Value = Settings.ESP.MaxDistance.Enabled, Callback = function(s) Settings.ESP.MaxDistance.Enabled = s refreshPlayerCache() end})
DistanceCustomization:AddSlider({Name = "Max Distance", Flag = "ESPMaxDistance", Value = Settings.ESP.MaxDistance.Value, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) Settings.ESP.MaxDistance.Value = v refreshPlayerCache() end})

local FOVGroup = Tabs.Main:CreateSection({Name = "FOV", Side = "Right"})
FOVGroup:AddToggle({Name = "Show FOV Circle", Flag = "FOVEnabled", Value = Settings.FOV.Enabled, Callback = function(s) Settings.FOV.Enabled = s Settings.FOV.Circle.Visible = s Settings.FOV.OutlineCircle.Visible = s end})
FOVGroup:AddToggle({Name = "Follow Gun", Flag = "FOVFollowGun", Value = Settings.FOV.FollowGun, Callback = function(s) Settings.FOV.FollowGun = s end})
FOVGroup:AddToggle({Name = "Fill FOV Circle", Flag = "FOVFilled", Value = Settings.FOV.Filled, Callback = function(s) Settings.FOV.Filled = s Settings.FOV.Circle.Filled = s Settings.FOV.Circle.Color = s and Settings.FOV.FillColor or Settings.FOV.OutlineColor Settings.FOV.Circle.Transparency = s and Settings.FOV.FillTransparency or Settings.FOV.OutlineTransparency Settings.FOV.Circle.Thickness = s and 0 or 1 end})
FOVGroup:AddColorPicker({Name = "Inline Color", Flag = "FOVFillColor", Color = Settings.FOV.FillColor, Transparency = Settings.FOV.FillTransparency, Callback = function(v) Settings.FOV.FillColor = v if Settings.FOV.Filled then Settings.FOV.Circle.Color = v end end})
FOVGroup:AddSlider({Name = "Inline Transparency", Flag = "FOVFillTransparency", Value = Settings.FOV.FillTransparency, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Settings.FOV.FillTransparency = v if Settings.FOV.Filled then Settings.FOV.Circle.Transparency = v end end})
FOVGroup:AddColorPicker({Name = "Outline Color", Flag = "FOVOutlineColor", Color = Settings.FOV.OutlineColor, Transparency = Settings.FOV.OutlineTransparency, Callback = function(v) Settings.FOV.OutlineColor = v Settings.FOV.OutlineCircle.Color = v if not Settings.FOV.Filled then Settings.FOV.Circle.Color = v end end})
FOVGroup:AddSlider({Name = "Outline Transparency", Flag = "FOVOutlineTransparency", Value = Settings.FOV.OutlineTransparency, Min = 0, Max = 1, Rounding = 2, Callback = function(v) Settings.FOV.OutlineTransparency = v Settings.FOV.OutlineCircle.Transparency = v if not Settings.FOV.Filled then Settings.FOV.Circle.Transparency = v end end})
FOVGroup:AddSlider({Name = "FOV Radius", Flag = "FOVRadius", Value = Settings.FOV.Radius, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) Settings.FOV.Radius = v Settings.FOV.Circle.Radius = v Settings.FOV.OutlineCircle.Radius = v end})

local ChamsGroup = Tabs.Visuals:CreateSection({Name = "Chams"})
ChamsGroup:AddToggle({Name = "Enabled", Flag = "ChamsEnabled", Value = Settings.Chams.Enabled, Callback = function(s)
    Settings.Chams.Enabled = s
    if s then State.ChamsUpdateConnection = RunService.RenderStepped:Connect(updateChams)
    else if State.ChamsUpdateConnection then State.ChamsUpdateConnection:Disconnect() State.ChamsUpdateConnection = nil end for p in State.Highlights do removeHighlight(p) end end
end})
ChamsGroup:AddColorPicker({Name = "Fill Color", Flag = "ChamsFillColor", Color = Settings.Chams.Fill.Color, Transparency = 0, Callback = function(v) Settings.Chams.Fill.Color = v for _, h in State.Highlights do h.FillColor = v end end})
ChamsGroup:AddColorPicker({Name = "Outline Color", Flag = "ChamsOutlineColor", Color = Settings.Chams.Outline.Color, Transparency = 0, Callback = function(v) Settings.Chams.Outline.Color = v for _, h in State.Highlights do h.OutlineColor = v end end})
ChamsGroup:AddSlider({Name = "Fill Transparency", Flag = "ChamsFillTransparency", Value = Settings.Chams.Fill.Transparency, Min = 0, Max = 1, Rounding = 1, Callback = function(v) Settings.Chams.Fill.Transparency = v for _, h in State.Highlights do h.FillTransparency = v end end})
ChamsGroup:AddSlider({Name = "Outline Transparency", Flag = "ChamsOutlineTransparency", Value = Settings.Chams.Outline.Transparency, Min = 0, Max = 1, Rounding = 1, Callback = function(v) Settings.Chams.Outline.Transparency = v for _, h in State.Highlights do h.OutlineTransparency = v end end})

local PlayerGroup = Tabs.Player:CreateSection({Name = "Player"})
PlayerGroup:AddToggle({Name = "Bunny Hop", Flag = "BhopEnabled", Value = Settings.Player.Bhop.Enabled, Callback = function(s) Settings.Player.Bhop.Enabled = s end})
PlayerGroup:AddToggle({Name = "Walk Speed", Flag = "WalkSpeedEnabled", Value = Settings.Player.WalkSpeed.Enabled, Callback = function(s) Settings.Player.WalkSpeed.Enabled = s callbackList["Player%%WalkSpeed"](s) end})
PlayerGroup:AddSlider({Name = "Walk Speed Value", Flag = "WalkSpeedValue", Value = Settings.Player.WalkSpeed.Value, Min = 10, Max = 500, Rounding = 0, Callback = function(v) Settings.Player.WalkSpeed.Value = v if Settings.Player.WalkSpeed.Enabled then callbackList["Player%%WalkSpeedValue"](v) end end})
PlayerGroup:AddToggle({Name = "Jump Power", Flag = "JumpPowerEnabled", Value = Settings.Player.JumpPower.Enabled, Callback = function(s) Settings.Player.JumpPower.Enabled = s end})
PlayerGroup:AddSlider({Name = "Jump Height Addition", Flag = "JumpPowerValue", Value = Settings.Player.JumpPower.Value, Min = 0, Max = 20, Rounding = 0, Callback = function(v) Settings.Player.JumpPower.Value = v end})

local AntiAimGroup = Tabs.Player:CreateSection({Name = "Anti-Aim", Side = "Right"})
AntiAimGroup:AddToggle({Name = "Enabled", Flag = "AntiAimEnabled", Value = Settings.AntiAim.Enabled, Callback = function(s) 
    Settings.AntiAim.Enabled = s startTime = os.clock() lastFrameTime = nil
    if s then
        State.AntiAimConnection = RunService.Heartbeat:Connect(function()
            if Settings.AntiAim.Enabled and charInterface.isAlive() then
                local currentCharObject = charInterface.getCharacterObject()
                if currentCharObject then
                    local rootPart = currentCharObject:getRealRootPart()
                    if rootPart then
                        local angles = cameraInterface:getActiveCamera():getAngles()
                        local modifiedAngles = applyAAAngles(angles)
                    end
                end
            end
        end)
    else
        if State.AntiAimConnection then State.AntiAimConnection:Disconnect() State.AntiAimConnection = nil end
        local currentCharObject = charInterface.getCharacterObject()
        if currentCharObject then currentCharObject:setStance("stand") network:send("stance", "stand") if Settings.ThirdPerson.Enabled and currentObj then currentObj:setStance("stand") end end
    end 
end})
AntiAimGroup:AddDropdown({Name = "Mode", Flag = "AntiAimMode", List = {"Spin", "Jitter", "Static"}, Value = Settings.AntiAim.Mode, Callback = function(v) Settings.AntiAim.Mode = v end})
AntiAimGroup:AddSlider({Name = "Spin Speed", Flag = "AntiAimSpinSpeed", Value = Settings.AntiAim.SpinSpeed, Min = 10, Max = 5000, Rounding = 0, Callback = function(v) Settings.AntiAim.SpinSpeed = v end})
AntiAimGroup:AddSlider({Name = "Jitter Angle", Flag = "AntiAimJitterAngle", Value = Settings.AntiAim.JitterAngle, Min = 10, Max = 180, Rounding = 0, Callback = function(v) Settings.AntiAim.JitterAngle = v end})
AntiAimGroup:AddSlider({Name = "Static Angle", Flag = "AntiAimStaticAngle", Value = Settings.AntiAim.StaticAngle, Min = -180, Max = 180, Rounding = 0, Callback = function(v) Settings.AntiAim.StaticAngle = v end})
AntiAimGroup:AddDropdown({Name = "Pitch Mode", Flag = "AntiAimPitchMode", List = {"None", "Up", "Down", "Random"}, Value = Settings.AntiAim.PitchMode, Callback = function(v) Settings.AntiAim.PitchMode = v end})
AntiAimGroup:AddSlider({Name = "Pitch Angle", Flag = "AntiAimPitchAngle", Value = Settings.AntiAim.PitchAngle, Min = 0, Max = 89, Rounding = 0, Callback = function(v) Settings.AntiAim.PitchAngle = v end})

local Optimizations = Tabs.Misc:CreateSection({Name = "Miscellaneous"})
Optimizations:AddToggle({Name = "Toggle Textures", Flag = "MiscTextures", Value = Settings.Misc.Textures, Callback = function(s) Settings.Misc.Textures = s if s then optimizeMap() else revertMap() end end})

local Safety = Tabs.Misc:CreateSection({Name = "Safety", Side = "Right"})
Safety:AddToggle({Name = "Rejoin on Votekick", Flag = "VotekickRejoiner", Value = Settings.Misc.VotekickRejoiner, Callback = function(s) Settings.Misc.VotekickRejoiner = s if s then initializeVotekickRejoiner() end end})

local ConfigGroup = Tabs.Configs:CreateSection({Name = "Configurations", Side = "Left"})

local ConfigNameTextbox = ConfigGroup:AddTextBox({Name = "Config Name", Flag = "ConfigName", Value = Configs.Current, Callback = function(v) Configs.Current = v if ConfigListDropdown then pcall(function() if table.find(Configs.Files, v) then ConfigListDropdown:Set(v) end end) end end})

local ConfigListDropdown
local function createConfigDropdown()
    if ConfigListDropdown then
        pcall(function()
            ConfigListDropdown:Remove()
            ConfigListDropdown = nil
        end)
    end
    
    local listToUse = #Configs.Files > 0 and Configs.Files or {"None"}
    local valueToUse = (#Configs.Files > 0 and Configs.Current and table.find(Configs.Files, Configs.Current)) and Configs.Current or listToUse[1]
    
    ConfigListDropdown = ConfigGroup:AddDropdown({
        Name = "Config List",
        List = listToUse,
        Value = valueToUse,
        Callback = function(selected)
            if selected and selected ~= "None" then
                Configs.Current = selected
                if ConfigNameTextbox then
                    pcall(function()
                        ConfigNameTextbox:Set(selected)
                    end)
                end
            else
                Configs.Current = ""
                if ConfigNameTextbox then
                    pcall(function()
                        ConfigNameTextbox:Set("")
                    end)
                end
            end
        end
    })
end

task.spawn(function()
    task.wait(0.1)
    refreshConfigList()
    createConfigDropdown()
end)

ConfigGroup:AddButton({
    Name = "Save Config",
    Callback = function()
        local configName = Library.Flags.ConfigName or Configs.Current
        if configName and configName ~= "" and configName ~= "None" then
            saveConfig(configName)
            refreshConfigList()
        else
            Library:Notify({Text = "Please enter a valid config name"})
        end
    end
})

ConfigGroup:AddButton({
    Name = "Load Config",
    Callback = function()
        local configName = Library.Flags.ConfigName or Configs.Current
        if configName and configName ~= "" and configName ~= "None" then
            loadConfig(configName)
            refreshConfigList()
        else
            Library:Notify({Text = "Please select or enter a valid config name"})
        end
    end
})

ConfigGroup:AddButton({
    Name = "Delete Config",
    Callback = function()
        local configName = Library.Flags.ConfigName or Configs.Current
        if configName and configName ~= "" and configName ~= "None" then
            deleteConfig(configName)
            refreshConfigList()
        else
            Library:Notify({Text = "Please select or enter a valid config name"})
        end
    end
})

ConfigGroup:AddButton({
    Name = "Refresh List",
    Callback = function()
        refreshConfigList()
        createConfigDropdown()
        Library:Notify({Text = "Config list refreshed"})
    end
})

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFOVCirclePosition)
RunService.Heartbeat:Connect(updateFOVCirclePosition)

local lastJumpTime = 0
local jumpCooldown = 0.818
local function handleBhop()
    if Settings.Player.Bhop.Enabled then
        local t = tick()
        if (t - lastJumpTime) < jumpCooldown then
            local hum = getCharacter():FindFirstChildOfClass("Humanoid")
            if hum then hum.Jump = true end
        end
        lastJumpTime = t
    end
end

UserInputService.InputBegan:Connect(function(i, gp) if gp then return end if i.KeyCode == Enum.KeyCode.Space then handleBhop() end end)

Library:OnUnload(function()
    for p in State.Storage.ESPCache do uncacheObject(p) end
    for p in State.Highlights do removeHighlight(p) end
    if State.PlayerCacheUpdate then State.PlayerCacheUpdate:Disconnect() end
    if State.ESPLoop then State.ESPLoop:Disconnect() end
    if State.ChamsUpdateConnection then State.ChamsUpdateConnection:Disconnect() end
    if State.InputBeganConnection then State.InputBeganConnection:Disconnect() end
    if State.InputEndedConnection then State.InputEndedConnection:Disconnect() end
    if State.RenderSteppedConnection then State.RenderSteppedConnection:Disconnect() end
    if State.CrosshairUpdate then State.CrosshairUpdate:Disconnect() end
    for _, d in Settings.Crosshair.Drawings do d:Remove() end
    Settings.FOV.Circle:Remove() Settings.FOV.OutlineCircle:Remove()
    stopMousePreload()
    revertMap()
    if Settings.ThirdPerson.Enabled and Settings.ThirdPerson.ShowCharacter then fakeRepObject:despawn() if currentObj then currentObj:Destroy() currentObj = nil lastPos = nil end end
    for part, props in State.ViewmodelProperties do if part:IsDescendantOf(workspace) then part.Transparency = props.Transparency for _, texture in props.Textures do if texture:IsDescendantOf(game.CoreGui) then texture.Parent = part end end end end
    State.ViewmodelProperties = {}
    local gunTexFolder = game.CoreGui:FindFirstChild("guntex")
    if gunTexFolder then gunTexFolder:Destroy() end
end)
