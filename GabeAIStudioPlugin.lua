-- Gabe AI Studio Plugin (Single Script)
-- Paste into a Plugin Script in Roblox Studio

local HttpService = game:GetService("HttpService")

local PROXY = "https://YOUR-RENDER-URL.onrender.com"

local function askAI(provider, model, message)
	local body = {
		provider = provider,
		model = model,
		messages = {
			{ role = "user", content = message }
		}
	}

	local response = HttpService:PostAsync(
		PROXY .. "/chat",
		HttpService:JSONEncode(body),
		Enum.HttpContentType.ApplicationJson,
		false
	)

	local data = HttpService:JSONDecode(response)
	return data.text or "No response"
end

local toolbar = plugin:CreateToolbar("Gabe AI")
local button = toolbar:CreateButton("Open", "Open Gabe AI", "")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	true, false, 400, 300, 200, 200
)

local widget = plugin:CreateDockWidgetPluginGui("GabeAI", widgetInfo)
widget.Title = "Gabe AI Chat"

local frame = Instance.new("Frame", widget)
frame.Size = UDim2.new(1,0,1,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1,-20,0,40)
box.Position = UDim2.new(0,10,1,-50)
box.PlaceholderText = "Ask AI..."
box.TextColor3 = Color3.new(1,1,1)
box.BackgroundColor3 = Color3.fromRGB(40,40,40)

local output = Instance.new("TextLabel", frame)
output.Size = UDim2.new(1,-20,1,-60)
output.Position = UDim2.new(0,10,0,10)
output.TextWrapped = true
output.TextColor3 = Color3.new(1,1,1)
output.BackgroundTransparency = 1
output.Text = "Ready."

box.FocusLost:Connect(function(enter)
	if enter and box.Text ~= "" then
		output.Text = "Thinking..."
		local reply = askAI("openai", "gpt-4o-mini", box.Text)
		output.Text = reply
		box.Text = ""
	end
end)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
