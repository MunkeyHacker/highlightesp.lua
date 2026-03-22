local module = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

module.meta = {
    name = "ESP",
    tab = "Visual",
    side = "Left",
    priority = 1
}

module.Color = Color3.fromRGB(255,0,0)
module.Transparency = 0.5
module.Tracers = false
module.Enabled = false
module.TextSize = 14

local ESPObjects = {}
local Loop
local PlayerAddedConnection

local function removeESP(plr)

    if ESPObjects[plr] then

        if ESPObjects[plr].Highlight then
            ESPObjects[plr].Highlight:Destroy()
        end

        if ESPObjects[plr].Tracer then
            ESPObjects[plr].Tracer:Remove()
        end

        if ESPObjects[plr].Name then
            ESPObjects[plr].Name:Destroy()
        end

        ESPObjects[plr] = nil

    end

end

local function createESP(plr)

    if plr == LocalPlayer then return end

    local function apply(char)

        removeESP(plr)

        local highlight = Instance.new("Highlight")
        highlight.FillColor = module.Color
        highlight.FillTransparency = module.Transparency
        highlight.Parent = char

        local name = Instance.new("BillboardGui")
        name.Size = UDim2.new(0,200,0,50)
        name.AlwaysOnTop = true
        name.StudsOffset = Vector3.new(0,3,0)
        name.Parent = char

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextScaled = false
        label.TextSize = module.TextSize
        label.Font = Enum.Font.SourceSansBold
        label.TextColor3 = Color3.new(1,1,1)
        label.TextStrokeTransparency = 0
        label.Text = plr.Name
        label.Parent = name

        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 2

        ESPObjects[plr] = {
            Highlight = highlight,
            Tracer = tracer,
            Label = label,
            Name = name
        }

    end

    if plr.Character then
        apply(plr.Character)
    end

    plr.CharacterAdded:Connect(apply)

end

function module.enable()

    if module.Enabled then return end
    module.Enabled = true

    for _,plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end

    PlayerAddedConnection = Players.PlayerAdded:Connect(createESP)

    Loop = RunService.RenderStepped:Connect(function()

        if not module.Enabled then return end

        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local myPos, myOnScreen = Camera:WorldToViewportPoint(myRoot.Position)

        for plr,data in pairs(ESPObjects) do

            if data.Label then
                data.Label.TextSize = module.TextSize
            end

            if data.Highlight then
                data.Highlight.FillColor = module.Color
                data.Highlight.FillTransparency = module.Transparency
            end

            if module.Tracers and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

                local pos,onscreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)

                data.Tracer.Visible = onscreen and myOnScreen
                data.Tracer.From = Vector2.new(myPos.X,myPos.Y)
                data.Tracer.To = Vector2.new(pos.X,pos.Y)
                data.Tracer.Color = module.Color

            else
                data.Tracer.Visible = false
            end

        end

    end)

end

function module.disable()

    module.Enabled = false

    if Loop then
        Loop:Disconnect()
        Loop = nil
    end

    if PlayerAddedConnection then
        PlayerAddedConnection:Disconnect()
        PlayerAddedConnection = nil
    end

    for plr,_ in pairs(ESPObjects) do
        removeESP(plr)
    end

end

function module.init(ctx)

    local box = ctx.box

    box:AddToggle("ESPToggle",{Text="Enable ESP"})
    Toggles.ESPToggle:OnChanged(function(v)
        if v then module.enable() else module.disable() end
    end)

    box:AddToggle("TracerToggle",{Text="Tracers"})
    Toggles.TracerToggle:OnChanged(function()
        module.Tracers = Toggles.TracerToggle.Value
    end)

    box:AddLabel("ESP Color")
    :AddColorPicker("ESPColor",{Default = module.Color})
    Options.ESPColor:OnChanged(function()
        module.Color = Options.ESPColor.Value
    end)

    box:AddSlider("ESPTransparency",{
        Text="Transparency",
        Default=0.5,
        Min=0,
        Max=1,
        Rounding=2
    })
    Options.ESPTransparency:OnChanged(function()
        module.Transparency = Options.ESPTransparency.Value
    end)

    box:AddSlider("ESPTextSize",{
        Text="Text Size",
        Default=14,
        Min=10,
        Max=40,
        Rounding=0
    })
    Options.ESPTextSize:OnChanged(function()
        module.TextSize = Options.ESPTextSize.Value
    end)

end

return module
