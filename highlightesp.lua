local module = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

module.Color = Color3.fromRGB(255,0,0)
module.Transparency = 0.5
module.Tracers = false
module.Enabled = false

local ESPObjects = {}

local function createESP(plr)

	if plr == LocalPlayer then return end
	
	local function apply(char)

		local highlight = Instance.new("Highlight")
		highlight.FillColor = module.Color
		highlight.FillTransparency = module.Transparency
		highlight.OutlineTransparency = 0
		highlight.Parent = char
		
		local name = Instance.new("BillboardGui")
		name.Size = UDim2.new(0,200,0,50)
		name.AlwaysOnTop = true
		name.StudsOffset = Vector3.new(0,3,0)
		name.Parent = char
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.TextScaled = true
		label.TextColor3 = Color3.new(1,1,1)
		label.Text = plr.Name
		label.Parent = name
		
		local tracer = Drawing.new("Line")
		tracer.Visible = false
		
		ESPObjects[plr] = {
			Highlight = highlight,
			Tracer = tracer,
			Name = name
		}
		
	end
	
	if plr.Character then
		apply(plr.Character)
	end
	
	plr.CharacterAdded:Connect(apply)

end

function module.start()

	module.Enabled = true
	
	for _,plr in pairs(Players:GetPlayers()) do
		createESP(plr)
	end
	
	Players.PlayerAdded:Connect(createESP)
	
	RunService.RenderStepped:Connect(function()
		
		if not module.Enabled then return end
		
		for plr,data in pairs(ESPObjects) do
			
			if module.Tracers and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				
				local pos,onscreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
				
				data.Tracer.Visible = onscreen
				
				data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
				data.Tracer.To = Vector2.new(pos.X,pos.Y)
				data.Tracer.Color = module.Color
				
			else
				data.Tracer.Visible = false
			end
			
			if data.Highlight then
				data.Highlight.FillColor = module.Color
				data.Highlight.FillTransparency = module.Transparency
			end
			
		end
		
	end)

end

function module.setColor(c)
	module.Color = c
end

function module.setTransparency(v)
	module.Transparency = v
end

function module.setTracer(state)
	module.Tracers = state
end

return module