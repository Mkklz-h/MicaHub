local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new(library)
    local self = setmetatable({}, LoadingScreen)
    self.library = library
    self.player = Players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")
    self.tweens = {}
    self.connections = {}
    self.customSteps = {}
    return self
end

function LoadingScreen:CreateElement(class, properties)
    return self.library:Create(class, properties)
end

function LoadingScreen:Init()
    self.screenGui = self:CreateElement("ScreenGui", {
        Name = "LoadingScreen",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = self.playerGui
    })

    self.loadingContainer = self:CreateElement("Frame", {
        Name = "LoadingContainer",
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundTransparency = 1,
        Parent = self.screenGui
    })

    self.loadingFrame = self:CreateElement("ImageLabel", {
        Name = "LoadingFrame",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(20, 20, 20),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.04,
        Parent = self.loadingContainer
    })

    self.title = self:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "CARREGANDO",
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.loadingFrame
    })

    self.progressContainer = self:CreateElement("Frame", {
        Name = "ProgressContainer",
        Size = UDim2.new(0.8, 0, 0, 20),
        Position = UDim2.new(0.1, 0, 0, 90),
        BackgroundTransparency = 1,
        Parent = self.loadingFrame
    })

    self.progressBackground = self:CreateElement("ImageLabel", {
        Name = "ProgressBackground",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(40, 40, 40),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        Parent = self.progressContainer
    })

    self.progressBar = self:CreateElement("ImageLabel", {
        Name = "ProgressBar",
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(255, 65, 65),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        ClipsDescendants = true,
        Parent = self.progressBackground
    })

    self.percentageText = self:CreateElement("TextLabel", {
        Name = "PercentageText",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 125),
        BackgroundTransparency = 1,
        Text = "0%",
        TextSize = 18,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.loadingFrame
    })

    self.statusText = self:CreateElement("TextLabel", {
        Name = "StatusText",
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 155),
        BackgroundTransparency = 1,
        Text = "Iniciando...",
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.loadingFrame
    })

    return self:StartRainbowEffect():StartLoadingSequence()
end

function LoadingScreen:StartRainbowEffect()
    local rainbowTime = 3
    local startTime = tick()
    
    local heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not self.progressBar or not self.progressBar.Parent then
            return
        end
        local hue = ((tick() - startTime) % rainbowTime) / rainbowTime
        self.progressBar.ImageColor3 = Color3.fromHSV(hue, 0.8, 1)
    end)
    
    table.insert(self.connections, heartbeatConnection)
    return self
end

function LoadingScreen:UpdateProgress(progress, status)
    progress = math.clamp(progress, 0, 100)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.progressBar, tweenInfo, {Size = UDim2.new(progress / 100, 0, 1, 0)})
    table.insert(self.tweens, tween)
    tween:Play()
    
    self.percentageText.Text = math.floor(progress) .. "%"
    
    if status then
        self.statusText.Text = status
    end
    
    return self
end

function LoadingScreen:SetSteps(steps)
    self.customSteps = steps or {
        {10, "Conectando ao servidor..."},
        {25, "Carregando recursos..."},
        {40, "Inicializando sistemas..."},
        {60, "Carregando interface..."},
        {80, "Aplicando configurações..."},
        {95, "Finalizando..."},
        {100, "Concluído!"}
    }
    return self
end

function LoadingScreen:StartLoadingSequence()
    if #self.customSteps == 0 then
        self:SetSteps()
    end
    
    spawn(function()
        wait(1)
        
        for i, step in ipairs(self.customSteps) do
            local progress, status = step[1], step[2]
            self:UpdateProgress(progress, status)
            
            if i == #self.customSteps then
                wait(0.8)
            else
                wait(math.random(0.5, 1.2))
            end
        end
        
        wait(0.5)
        self:Destroy()
    end)
    
    return self
end

function LoadingScreen:Destroy()
    for _, conn in ipairs(self.connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    
    for _, tween in ipairs(self.tweens) do
        if tween then
            tween:Cancel()
        end
    end
    
    if self.screenGui and self.screenGui.Parent then
        self.screenGui:Destroy()
    end
    
    self.tweens = nil
    self.connections = nil
    self.screenGui = nil
    self.loadingContainer = nil
    self.loadingFrame = nil
    self.title = nil
    self.progressContainer = nil
    self.progressBackground = nil
    self.progressBar = nil
    self.percentageText = nil
    self.statusText = nil
    self.player = nil
    self.playerGui = nil
    self.customSteps = nil
    
    setmetatable(self, nil)
    return nil
end

_G.LoadingScreen = LoadingScreen

return LoadingScreen
