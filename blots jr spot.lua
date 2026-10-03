-- Blot’s Jr. Spot  |  Dandy's World
-- Разделы: 📖 Main, 😀 Player, 🤖 Auto, 👁 Visual
-- Допущение для ESP: модели Twisted лежат в Workspace и называются как в таблице ("GoobMonster" и т.д.)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local lp = Players.LocalPlayer

---------------------------------------------------------------- данные
local newestToon = "Waxwell"

local rarities = {
	BoxtenMonster = "Common", BrushaMonster = "Common", CosmoMonster = "Common",
	LooeyMonster = "Common", PoppyMonster = "Common", ShrimpoMonster = "Common",
	TishaMonster = "Common", YattaMonster = "Common", RibeccaMonster = "Common",
	RudieMonster = "Common", EggsonMonster = "Common",

	BrightneyMonster = "Uncommon", ConnieMonster = "Uncommon", FinnMonster = "Uncommon",
	RazzleDazzleMonster = "Uncommon", RodgerMonster = "Uncommon", TeaganMonster = "Uncommon",
	ToodlesMonster = "Uncommon", SoulvesterMonster = "Uncommon", GingerMonster = "Uncommon",
	FlyteMonster = "Uncommon",

	BlottMonster = "Rare", FlutterMonster = "Rare", GigiMonster = "Rare",
	GlistenMonster = "Rare", GoobMonster = "Rare", ScrapsMonster = "Rare",
	SquirmMonster = "Rare", EclipseMonster = "Rare", CoalMonster = "Rare",
	CocoaMonster = "Rare", WaxwellMonster = "Rare",

	AstroMonster = "Main", PebbleMonster = "Main", ShellyMonster = "Main",
	SproutMonster = "Main", VeeMonster = "Main", GourdyMonster = "Main",
	BobetteMonster = "Main", BassieMonster = "Main",

	DandyMonster = "Lethal", DyleMonster = "Lethal",
}

local grabbers = { GoobMonster = true, ScrapsMonster = true, GigiMonster = true }

local rarityOrder = { "Common", "Uncommon", "Rare", "Main", "Lethal" }
local rarityColors = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(80, 200, 120),
	Rare = Color3.fromRGB(80, 140, 255),
	Main = Color3.fromRGB(255, 170, 0),
	Lethal = Color3.fromRGB(255, 40, 40),
}

---------------------------------------------------------------- состояние
local state = {
	esp = true, labels = true,
	speedOn = false, speed = 24,
	jumpOn = false, jump = 60,
	infJump = false,
	antiAfk = false,
}

local connections = {}
local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(connections, c)
	return c
end

local function getHum()
	local ch = lp.Character
	return ch and ch:FindFirstChildOfClass("Humanoid")
end

---------------------------------------------------------------- тема
local C = {
	bg = Color3.fromRGB(12, 12, 12),
	panel = Color3.fromRGB(24, 24, 24),
	item = Color3.fromRGB(40, 40, 40),
	line = Color3.fromRGB(70, 70, 70),
	text = Color3.fromRGB(235, 235, 235),
	sub = Color3.fromRGB(150, 150, 150),
	on = Color3.fromRGB(190, 190, 190),
	off = Color3.fromRGB(70, 70, 70),
}

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner(o, r) new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o) end

local lo = 0
local function nextLO() lo = lo + 1 return lo end

---------------------------------------------------------------- окно
local parentGui = (gethui and gethui()) or lp:WaitForChild("PlayerGui")
local old = parentGui:FindFirstChild("BlotsJrSpot")
if old then old:Destroy() end

local gui = new("ScreenGui", { Name = "BlotsJrSpot", ResetOnSpawn = false }, parentGui)

local FULL_SIZE = UDim2.new(0, 440, 0, 300)
local main = new("Frame", {
	Size = FULL_SIZE, Position = UDim2.new(0.5, -220, 0.5, -150),
	BackgroundColor3 = C.bg, BorderSizePixel = 0, Active = true,
}, gui)
corner(main, 10)
new("UIStroke", { Color = C.line, Thickness = 1 }, main)

local bar = new("Frame", {
	Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, main)
corner(bar, 10)

new("TextLabel", {
	Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 14, 0, 0),
	BackgroundTransparency = 1, Text = "Blot’s Jr. Spot",
	TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
}, bar)

local function barButton(txt, xOffset)
	local b = new("TextButton", {
		Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, xOffset, 0.5, -12),
		BackgroundColor3 = C.item, Text = txt, TextColor3 = C.text,
		Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = true,
	}, bar)
	corner(b, 6)
	return b
end
local minBtn = barButton("–", -68)
local closeBtn = barButton("✕", -36)

-- перетаскивание за заголовок
local dragging, dragStart, startPos
connect(bar.InputBegan, function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging, dragStart, startPos = true, i.Position, main.Position
	end
end)
connect(UIS.InputChanged, function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
connect(UIS.InputEnded, function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local body = new("Frame", {
	Size = UDim2.new(1, 0, 1, -36), Position = UDim2.new(0, 0, 0, 36),
	BackgroundTransparency = 1,
}, main)

local minimized = false
connect(minBtn.MouseButton1Click, function()
	minimized = not minimized
	body.Visible = not minimized
	main.Size = minimized and UDim2.new(0, 440, 0, 36) or FULL_SIZE
end)

---------------------------------------------------------------- вкладки
local sidebar = new("Frame", {
	Size = UDim2.new(0, 56, 1, 0), BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, body)
new("UIListLayout", {
	Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)
new("UIPadding", { PaddingTop = UDim.new(0, 8) }, sidebar)

local content = new("Frame", {
	Size = UDim2.new(1, -56, 1, 0), Position = UDim2.new(0, 56, 0, 0),
	BackgroundTransparency = 1,
}, body)

local tabs = { { "Main", "📖" }, { "Player", "😀" }, { "Auto", "🤖" }, { "Visual", "👁" } }
local pages, tabButtons = {}, {}

local function selectTab(name)
	for n, p in pairs(pages) do p.Visible = (n == name) end
	for n, b in pairs(tabButtons) do b.BackgroundColor3 = (n == name) and C.item or C.panel end
end

for idx, t in ipairs(tabs) do
	local name, icon = t[1], t[2]
	local b = new("TextButton", {
		Size = UDim2.new(0, 44, 0, 44), BackgroundColor3 = C.panel,
		Text = icon, TextSize = 24, TextColor3 = C.text, Font = Enum.Font.Gotham,
		LayoutOrder = idx, AutoButtonColor = false,
	}, sidebar)
	corner(b, 8)
	tabButtons[name] = b

	local page = new("ScrollingFrame", {
		Size = UDim2.new(1, -12, 1, -12), Position = UDim2.new(0, 6, 0, 6),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.line, CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
	}, content)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	pages[name] = page

	new("TextLabel", {
		Size = UDim2.new(1, -6, 0, 26), BackgroundTransparency = 1, Text = icon .. "  " .. name,
		TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextLO(),
	}, page)

	connect(b.MouseButton1Click, function() selectTab(name) end)
end

---------------------------------------------------------------- компоненты
local function infoLabel(page, str, color)
	return new("TextLabel", {
		Size = UDim2.new(1, -6, 0, 22), BackgroundTransparency = 1, Text = str,
		TextColor3 = color or C.sub, Font = Enum.Font.Gotham, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		LayoutOrder = nextLO(),
	}, page)
end

local function toggle(page, label, default, cb)
	local row = new("Frame", {
		Size = UDim2.new(1, -6, 0, 38), BackgroundColor3 = C.item, BorderSizePixel = 0,
		LayoutOrder = nextLO(),
	}, page)
	corner(row, 8)
	new("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1, Text = label, TextColor3 = C.text,
		Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local sw = new("TextButton", {
		Size = UDim2.new(0, 44, 0, 22), Position = UDim2.new(1, -54, 0.5, -11),
		Text = "", AutoButtonColor = false, BackgroundColor3 = C.off,
	}, row)
	corner(sw, 11)
	local knob = new("Frame", { Size = UDim2.new(0, 18, 0, 18), BorderSizePixel = 0 }, sw)
	corner(knob, 9)
	local on = default
	local function render()
		sw.BackgroundColor3 = on and C.on or C.off
		knob.BackgroundColor3 = on and C.bg or C.text
		knob.Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
	end
	render()
	connect(sw.MouseButton1Click, function()
		on = not on
		render()
		cb(on)
	end)
end

local function numberInput(page, label, default, cb)
	local row = new("Frame", {
		Size = UDim2.new(1, -6, 0, 38), BackgroundColor3 = C.item, BorderSizePixel = 0,
		LayoutOrder = nextLO(),
	}, page)
	corner(row, 8)
	new("TextLabel", {
		Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1, Text = label, TextColor3 = C.text,
		Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local box = new("TextBox", {
		Size = UDim2.new(0, 64, 0, 24), Position = UDim2.new(1, -74, 0.5, -12),
		BackgroundColor3 = C.bg, TextColor3 = C.text, Font = Enum.Font.Gotham,
		TextSize = 14, Text = tostring(default), ClearTextOnFocus = false,
	}, row)
	corner(box, 6)
	local current = default
	connect(box.FocusLost, function()
		local n = tonumber(box.Text)
		if n and n > 0 and n <= 500 then
			current = n
			cb(n)
		end
		box.Text = tostring(current)
	end)
end

local function button(page, label, cb)
	local b = new("TextButton", {
		Size = UDim2.new(1, -6, 0, 38), BackgroundColor3 = C.item, Text = label,
		TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 14,
		LayoutOrder = nextLO(),
	}, page)
	corner(b, 8)
	connect(b.MouseButton1Click, cb)
end

---------------------------------------------------------------- ESP
local tracked = {} -- [model] = { highlight, billboard }

local function refreshESP()
	for _, data in pairs(tracked) do
		if data[1] then data[1].Enabled = state.esp end
		if data[2] then data[2].Enabled = state.esp and state.labels end
	end
end

local function removeESP(model)
	local data = tracked[model]
	if not data then return end
	for _, obj in pairs(data) do
		if obj then obj:Destroy() end
	end
	tracked[model] = nil
end

local function addESP(model)
	if tracked[model] then return end
	local rarity = rarities[model.Name]
	if not rarity then return end
	local color = rarityColors[rarity]

	local hl = new("Highlight", {
		FillColor = color, OutlineColor = color, FillTransparency = 0.6,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Adornee = model,
		Enabled = state.esp,
	}, model)

	local billboard
	local part = model.PrimaryPart
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChildWhichIsA("BasePart", true)
	if part then
		billboard = new("BillboardGui", {
			Size = UDim2.new(0, 140, 0, 36), StudsOffset = Vector3.new(0, 3, 0),
			AlwaysOnTop = true, Adornee = part, Enabled = state.esp and state.labels,
		}, gui)
		local shown = model.Name:gsub("Monster$", "")
		new("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = color,
			TextStrokeTransparency = 0.3, Font = Enum.Font.GothamBold, TextSize = 14,
			Text = shown .. " [" .. rarity .. "]" .. (grabbers[model.Name] and "\nGRABBER!" or ""),
		}, billboard)
	end

	tracked[model] = { hl, billboard }
	model.AncestryChanged:Connect(function(_, parent)
		if not parent then removeESP(model) end
	end)
end

local function scan(obj)
	if obj:IsA("Model") then addESP(obj) end
end

for _, d in ipairs(workspace:GetDescendants()) do scan(d) end
connect(workspace.DescendantAdded, function(d) task.defer(scan, d) end)

---------------------------------------------------------------- 📖 Main
local twistedCount = 0
for _ in pairs(rarities) do twistedCount = twistedCount + 1 end

infoLabel(pages.Main, "Blot’s Jr. Spot — меню для Dandy's World", C.text)
infoLabel(pages.Main, "Новейший тун: " .. newestToon)
infoLabel(pages.Main, "Twisted в базе: " .. twistedCount)
infoLabel(pages.Main, "Окно можно двигать за заголовок, – сворачивает, ✕ закрывает.")

---------------------------------------------------------------- 😀 Player
local origSpeed, origJump = 16, 50

toggle(pages.Player, "Своя скорость", false, function(on)
	local h = getHum()
	if on then
		if h then origSpeed = h.WalkSpeed end
	elseif h then
		h.WalkSpeed = origSpeed
	end
	state.speedOn = on
end)
numberInput(pages.Player, "Значение скорости", state.speed, function(n) state.speed = n end)

toggle(pages.Player, "Свой прыжок", false, function(on)
	local h = getHum()
	if on then
		if h then origJump = h.JumpPower end
	elseif h then
		h.JumpPower = origJump
	end
	state.jumpOn = on
end)
numberInput(pages.Player, "Значение прыжка", state.jump, function(n) state.jump = n end)

toggle(pages.Player, "Бесконечный прыжок", false, function(on) state.infJump = on end)

connect(RunService.Heartbeat, function()
	local h = getHum()
	if not h then return end
	if state.speedOn then h.WalkSpeed = state.speed end
	if state.jumpOn then
		h.UseJumpPower = true
		h.JumpPower = state.jump
	end
end)

connect(UIS.JumpRequest, function()
	if state.infJump then
		local h = getHum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

---------------------------------------------------------------- 🤖 Auto
toggle(pages.Auto, "Anti-AFK", false, function(on) state.antiAfk = on end)
connect(lp.Idled, function()
	if state.antiAfk then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)
infoLabel(pages.Auto, "Автоскиллчек и автомашины появятся, когда будет известна структура игры (путь из Explorer / Dex).")

---------------------------------------------------------------- 👁 Visual
toggle(pages.Visual, "Подсветка Twisted", true, function(on)
	state.esp = on
	refreshESP()
end)
toggle(pages.Visual, "Подписи (имя и редкость)", true, function(on)
	state.labels = on
	refreshESP()
end)
infoLabel(pages.Visual, "Цвета редкости:", C.text)
for _, r in ipairs(rarityOrder) do
	infoLabel(pages.Visual, "●  " .. r, rarityColors[r])
end

---------------------------------------------------------------- закрытие
local function unload()
	local h = getHum()
	if h then
		if state.speedOn then h.WalkSpeed = origSpeed end
		if state.jumpOn then h.JumpPower = origJump end
	end
	state.speedOn, state.jumpOn, state.infJump, state.antiAfk = false, false, false, false
	for _, c in ipairs(connections) do c:Disconnect() end
	for model in pairs(tracked) do removeESP(model) end
	gui:Destroy()
end

button(pages.Main, "Закрыть скрипт (Unload)", unload)
connect(closeBtn.MouseButton1Click, unload)

selectTab("Main")
