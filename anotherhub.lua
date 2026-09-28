local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local DISCORD_LINK = "https://discord.gg/nnXC6MBjPz"

do
	local function _kick(r)
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "f4xi hub",
				Text = r,
				Duration = 5,
			})
		end)
		task.delay(1, function() player:Kick("[f4xi hub] " .. r) end)
	end

	local spyNames = {
		"Dex", "DexV4", "DexExplorer", "Hydroxide", "SimpleSpy",
		"RemoteSpy", "SynSpy", "ScriptDumper", "InfYield",
		"SimpleSpySource", "DexV3", "DEX", "dex", "SynapseSpy",
	}

	local function scanForSpy()
		for _, g in game:GetService("CoreGui"):GetChildren() do
			for _, name in spyNames do
				if g.Name == name or string.find(string.lower(g.Name), "remotespy") or string.find(string.lower(g.Name), "simplespy") or string.find(string.lower(g.Name), "dex") then
					pcall(function() g:Destroy() end)
					return true
				end
			end
		end
		for _, g in player:WaitForChild("PlayerGui"):GetChildren() do
			for _, name in spyNames do
				if g.Name == name or string.find(string.lower(g.Name), "remotespy") or string.find(string.lower(g.Name), "simplespy") or string.find(string.lower(g.Name), "dex") then
					pcall(function() g:Destroy() end)
					return true
				end
			end
		end
		return false
	end

	if scanForSpy() then
		_kick("Spy/Explorer detected. Close it and re-execute.")
		return
	end

	pcall(function()
		if getgc then
			for _, v in getgc(true) do
				if type(v) == "function" then
					local info = debug.getinfo(v)
					if info and info.source then
						local src = string.lower(info.source)
						if string.find(src, "simplespy") or string.find(src, "remotespy") or string.find(src, "httpspy") then
							_kick("Remote spy detected. Close it and re-execute.")
							return
						end
					end
				end
			end
		end
	end)

	pcall(function()
		if hookfunction and newcclosure then
			local oldNamecall = nil
			oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if method == "SaveInstance" then
					return _kick("SaveInstance blocked.")
				end
				return oldNamecall(self, ...)
			end))
		end
	end)

	task.spawn(function()
		while task.wait(5) do
			if scanForSpy() then
				_kick("Spy/Explorer detected. Script terminated.")
				break
			end
		end
	end)
end

do
	local opened = pcall(function() game:GetService("GuiService"):OpenBrowserWindow(DISCORD_LINK) end)
	if not opened and setclipboard then pcall(function() setclipboard(DISCORD_LINK) end) end
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LogService = game:GetService("LogService")

local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

for _, n in {"F4xiHub", "F4xiNotifs", "F4xiConsole"} do
	local e = playerGui:FindFirstChild(n); if e then e:Destroy() end
end

local SoundService = game:GetService("SoundService")

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local BG         = Color3.fromRGB(10, 8, 20)
local BG_CARD    = Color3.fromRGB(22, 17, 36)
local BG_HOVER   = Color3.fromRGB(33, 24, 54)
local BORDER     = Color3.fromRGB(48, 36, 78)
local WHITE      = Color3.new(1, 1, 1)
local DIM        = Color3.fromRGB(150, 140, 180)
local ACCENT     = Color3.fromRGB(150, 90, 255)
local ACCENT2    = Color3.fromRGB(205, 110, 255)
local ACCENT_DIM = Color3.fromRGB(95, 58, 175)
local TRACK_OFF  = Color3.fromRGB(40, 32, 62)
local TRACK_ON   = Color3.fromRGB(150, 90, 255)
local RED        = Color3.fromRGB(255, 80, 100)
local YELLOW     = Color3.fromRGB(255, 200, 60)
local GREEN      = Color3.fromRGB(80, 255, 140)
local SIDEBAR_BG = Color3.fromRGB(13, 10, 24)

local function playSound(id, vol, pitch)
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://" .. tostring(id)
		s.Volume = vol or 0.5
		s.PlaybackSpeed = pitch or 1
		s.Parent = SoundService
		s:Play()
		game:GetService("Debris"):AddItem(s, 3)
	end)
end

local SFX = {
	click = function() playSound(6895079, 0.3, 1.4) end,
	toggle = function() playSound(6895079, 0.25, 1.8) end,
	swooshOpen = function() playSound(9120386216, 0.4, 1.2) end,
	swooshClose = function() playSound(9120386216, 0.35, 0.8) end,
	notify = function() playSound(6895079, 0.15, 2.0) end,
	intro = function() playSound(9120386216, 0.5, 1.0) end,
}

local function make(className, props, children)
	local inst = Instance.new(className)
	for k, v in props do inst[k] = v end
	for _, child in children or {} do child.Parent = inst end
	return inst
end

local function isClick(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local function getHumanoid() local c = player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c = player.Character; return c and c:FindFirstChild("HumanoidRootPart") end

local function makeDraggable(handle, frame)
	local dragging, dragStart, startPos = false, Vector3.zero, frame.Position
	handle.InputBegan:Connect(function(input)
		if isClick(input) then
			dragging, dragStart, startPos = true, input.Position, frame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and isMove(input) then
			local d = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

------------------------------------------------------------
-- NOTIFICATIONS
------------------------------------------------------------
local notifGui = make("ScreenGui", { Name = "F4xiNotifs", ResetOnSpawn = false, Parent = playerGui })
local notifHolder = make("Frame", {
	Size = UDim2.new(0, 260, 1, -20), Position = UDim2.new(1, -270, 0, 10),
	BackgroundTransparency = 1, Parent = notifGui,
}, { make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom }) })

local function notify(text)
	SFX.notify()
	local isError = text:lower():find("fail") or text:lower():find("error") or text:lower():find("not found") or text:lower():find("stop")
	local isSuccess = text:lower():find("complete") or text:lower():find("done") or text:lower():find("accepted") or text:lower():find("saved")
	local barColor = if isError then RED elseif isSuccess then GREEN else ACCENT
	local barColor2 = if isError then Color3.fromRGB(255, 150, 60) elseif isSuccess then Color3.fromRGB(80, 200, 255) else ACCENT2
	local card = make("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = BG, BackgroundTransparency = 1, Parent = notifHolder }, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }), make("UIStroke", { Color = barColor, Transparency = 1, Thickness = 1 }),
	})
	local accentBar = make("Frame", {
		Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, 7, 0.2, 0),
		BackgroundColor3 = barColor, BackgroundTransparency = 1, Parent = card,
	}, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, barColor), ColorSequenceKeypoint.new(1, barColor2)}), Rotation = 90 }),
	})
	local lbl = make("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
		TextColor3 = WHITE, TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 12, Text = text,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = card,
	})
	card.Position = UDim2.new(0, 40, 0, 0)
	TweenService:Create(card, TWEEN_MED, { BackgroundTransparency = 0.05, Position = UDim2.new(0, 0, 0, 0) }):Play()
	TweenService:Create(lbl, TWEEN_MED, { TextTransparency = 0 }):Play()
	TweenService:Create(accentBar, TWEEN_MED, { BackgroundTransparency = 0 }):Play()
	local s = card:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_MED, { Transparency = 0.3 }):Play() end
	task.delay(3.2, function()
		TweenService:Create(card, TWEEN_SLOW, { BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0) }):Play()
		TweenService:Create(lbl, TWEEN_SLOW, { TextTransparency = 1 }):Play()
		TweenService:Create(accentBar, TWEEN_SLOW, { BackgroundTransparency = 1 }):Play()
		if s then TweenService:Create(s, TWEEN_SLOW, { Transparency = 1 }):Play() end
		task.wait(0.5); card:Destroy()
	end)
end

------------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------------
local gui = make("ScreenGui", { Name = "F4xiHub", ResetOnSpawn = false, Parent = playerGui })

local WINDOW_W = 596
local WINDOW_H_SMALL = 580
local WINDOW_H_BIG = 740
local SIDEBAR_W = 112
local windowExpanded = false

local window = make("Frame", {
	Size = UDim2.fromOffset(WINDOW_W, WINDOW_H_SMALL), Position = UDim2.fromOffset(60, 50),
	BackgroundColor3 = BG, ClipsDescendants = true, Parent = gui,
}, { make("UICorner", { CornerRadius = UDim.new(0, 14) }), make("UIStroke", { Color = ACCENT_DIM, Thickness = 1.5 }) })

local accentTop = make("Frame", {
	Size = UDim2.new(1, -6, 0, 4), Position = UDim2.fromOffset(3, 1),
	BackgroundColor3 = ACCENT, BorderSizePixel = 0, Parent = window,
}, {
	make("UICorner", { CornerRadius = UDim.new(0, 3) }),
	make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 40, 200)), ColorSequenceKeypoint.new(0.2, ACCENT), ColorSequenceKeypoint.new(0.4, ACCENT2), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(230, 120, 235)), ColorSequenceKeypoint.new(0.8, ACCENT2), ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 40, 200))}) }),
})

task.spawn(function()
	local offset = 0
	while accentTop and accentTop.Parent do
		offset = (offset + 0.004) % 1
		local grad = accentTop:FindFirstChildOfClass("UIGradient")
		if grad then grad.Offset = Vector2.new(offset, 0) end
		task.wait(0.025)
	end
end)

local glowBar = make("Frame", {
	Size = UDim2.new(1, -6, 0, 2), Position = UDim2.fromOffset(3, 5),
	BackgroundColor3 = ACCENT, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = window,
}, { make("UIGradient", { Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.2), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(0.7, 0.2), NumberSequenceKeypoint.new(1, 1)}) }) })

local titleBar = make("Frame", { Size = UDim2.new(1, 0, 0, 48), Position = UDim2.fromOffset(0, 6), BackgroundTransparency = 1, Parent = window })
make("TextLabel", {
	Size = UDim2.new(1, -160, 0, 22), Position = UDim2.fromOffset(18, 6), BackgroundTransparency = 1,
	Text = "F4XI HUB", TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextSize = 17,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar,
})
local versionBadge = make("Frame", {
	Size = UDim2.fromOffset(36, 15), Position = UDim2.fromOffset(18, 30), BackgroundColor3 = ACCENT_DIM, Parent = titleBar,
}, {
	make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "v1.0", TextColor3 = ACCENT2, Font = Enum.Font.GothamBlack, TextSize = 9 }),
})
local subtitleLabel = make("TextLabel", {
	Size = UDim2.new(0, 100, 0, 15), Position = UDim2.fromOffset(58, 29), BackgroundTransparency = 1,
	Text = "Slayers 2", TextColor3 = DIM, Font = Enum.Font.GothamMedium, TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar,
})
make("Frame", {
	Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 0, 52), BackgroundColor3 = BORDER, BorderSizePixel = 0, Parent = window,
}, { make("UIGradient", { Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.8)}) }) })

local function makeTitleBtn(text, posX, hoverColor)
	local b = make("TextButton", {
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, posX, 0, 8),
		BackgroundColor3 = BG_CARD, AutoButtonColor = false, Text = text,
		TextColor3 = DIM, Font = Enum.Font.GothamBold, TextSize = 12, Parent = titleBar,
	}, { make("UICorner", { CornerRadius = UDim.new(0, 8) }), make("UIStroke", { Color = BORDER, Thickness = 1 }) })
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TWEEN_FAST, { BackgroundColor3 = hoverColor or BG_HOVER, TextColor3 = WHITE }):Play()
		local ss = b:FindFirstChildOfClass("UIStroke"); if ss then TweenService:Create(ss, TWEEN_FAST, { Color = hoverColor or ACCENT_DIM }):Play() end
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TWEEN_FAST, { BackgroundColor3 = BG_CARD, TextColor3 = DIM }):Play()
		local ss = b:FindFirstChildOfClass("UIStroke"); if ss then TweenService:Create(ss, TWEEN_FAST, { Color = BORDER }):Play() end
	end)
	return b
end

local closeBtn = makeTitleBtn("X", -40, Color3.fromRGB(80, 20, 30))
local minBtn = makeTitleBtn("-", -72)
local expandBtn = makeTitleBtn("<>", -106)

local bodyFrame
local bodyVisible = true
minBtn.MouseButton1Click:Connect(function()
	bodyVisible = not bodyVisible
	if bodyFrame then bodyFrame.Visible = bodyVisible end
	local h = bodyVisible and (windowExpanded and WINDOW_H_BIG or WINDOW_H_SMALL) or 54
	TweenService:Create(window, TWEEN_MED, { Size = UDim2.fromOffset(WINDOW_W, h) }):Play()
	minBtn.Text = bodyVisible and "-" or "+"
end)

expandBtn.MouseButton1Click:Connect(function()
	windowExpanded = not windowExpanded
	local h = windowExpanded and WINDOW_H_BIG or WINDOW_H_SMALL
	TweenService:Create(window, TWEEN_MED, { Size = UDim2.fromOffset(WINDOW_W, h) }):Play()
	notify(windowExpanded and "Expanded" or "Compact")
end)

makeDraggable(titleBar, window)

------------------------------------------------------------
-- KEYBIND SYSTEM
------------------------------------------------------------
local keybinds = {
	speed = Enum.KeyCode.X,
	fly = Enum.KeyCode.Y,
	toggleGui = Enum.KeyCode.RightShift,
	stopQuest = Enum.KeyCode.F8,
}

------------------------------------------------------------
-- FORWARD DECLARATIONS (used across tabs)
------------------------------------------------------------
local freecamOn = false
local freecamAnchorPart = nil
local afkToggle = nil

local guiAnimating = false
local guiVisible = true
local guiSavedPos = UDim2.fromOffset(60, 50)

local function animateGuiOpen()
	if guiAnimating then return end
	guiAnimating = true
	guiVisible = true

	pcall(function() SFX.swooshOpen() end)
	pcall(function() notifGui.Enabled = true end)

	local ws = window:FindFirstChildOfClass("UIStroke")
	local targetH = if bodyVisible then (if windowExpanded then WINDOW_H_BIG else WINDOW_H_SMALL) else 54

	window.Position = guiSavedPos
	window.BackgroundTransparency = 1
	window.Size = UDim2.fromOffset(WINDOW_W, targetH)
	if ws then ws.Transparency = 1 end
	pcall(function() if bodyFrame then bodyFrame.Visible = false; bodyFrame.GroupTransparency = 1 end end)
	pcall(function() if titleBar then titleBar.Visible = false end end)
	pcall(function() if accentTop then accentTop.BackgroundTransparency = 1 end end)
	pcall(function() if glowBar then glowBar.BackgroundTransparency = 1 end end)

	pcall(function()

		TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		}):Play()
		if ws then TweenService:Create(ws, TweenInfo.new(0.3), { Transparency = 0 }):Play() end

		if accentTop then TweenService:Create(accentTop, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play() end
		if glowBar then TweenService:Create(glowBar, TweenInfo.new(0.25), { BackgroundTransparency = 0.3 }):Play() end
		task.wait(0.15)
		if titleBar then titleBar.Visible = true end
		task.wait(0.15)

		if bodyFrame and bodyVisible then
			bodyFrame.Visible = true
			TweenService:Create(bodyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
		end

		task.wait(0.35)
	end)

	pcall(function() window.BackgroundTransparency = 0 end)
	pcall(function() local s = window:FindFirstChildOfClass("UIStroke"); if s then s.Transparency = 0 end end)
	pcall(function() if bodyFrame then bodyFrame.Visible = bodyVisible; bodyFrame.GroupTransparency = 0 end end)
	pcall(function() if titleBar then titleBar.Visible = true end end)
	pcall(function() if accentTop then accentTop.BackgroundTransparency = 0 end end)
	pcall(function() if glowBar then glowBar.BackgroundTransparency = 0.3 end end)
	guiAnimating = false
end

local function animateGuiClose()
	if guiAnimating then return end
	guiAnimating = true

	pcall(function()
		SFX.swooshClose()
		guiSavedPos = window.Position

		local ws = window:FindFirstChildOfClass("UIStroke")

		if bodyFrame then
			TweenService:Create(bodyFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 }):Play()
		end
		task.wait(0.18)
		if bodyFrame then bodyFrame.Visible = false end
		if titleBar then titleBar.Visible = false end

		if accentTop then TweenService:Create(accentTop, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play() end
		if glowBar then TweenService:Create(glowBar, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play() end

		TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
		}):Play()
		if ws then TweenService:Create(ws, TweenInfo.new(0.25), { Transparency = 1 }):Play() end

		task.wait(0.35)
	end)

	pcall(function() window.Position = UDim2.fromOffset(-9999, -9999) end)
	pcall(function() notifGui.Enabled = false end)
	guiVisible = false
	guiAnimating = false
end

closeBtn.MouseButton1Click:Connect(function() animateGuiClose() end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == keybinds.toggleGui then
		if guiVisible then
			animateGuiClose()
		else
			animateGuiOpen()
		end
	end
end)

------------------------------------------------------------
-- TAB SYSTEM (LEFT SIDEBAR)
------------------------------------------------------------
bodyFrame = make("Frame", { Size = UDim2.new(1, 0, 1, -54), Position = UDim2.fromOffset(0, 54), BackgroundTransparency = 1, Parent = window })

local sidebar = make("Frame", {
	Size = UDim2.new(0, SIDEBAR_W, 1, 0), Position = UDim2.fromOffset(0, 0),
	BackgroundColor3 = SIDEBAR_BG, BorderSizePixel = 0, Parent = bodyFrame,
}, {
	make("UICorner", { CornerRadius = UDim.new(0, 0) }),
})

make("Frame", {
	Size = UDim2.new(0, 1, 1, -8), Position = UDim2.new(0, SIDEBAR_W - 1, 0, 4),
	BackgroundColor3 = BORDER, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = bodyFrame,
})

local searchBox = make("TextBox", {
	Size = UDim2.new(1, -8, 0, 26), Position = UDim2.fromOffset(4, 4),
	BackgroundColor3 = Color3.fromRGB(12, 12, 24), Text = "", PlaceholderText = "  Search...",
	PlaceholderColor3 = Color3.fromRGB(80, 80, 110), TextColor3 = WHITE,
	Font = Enum.Font.GothamMedium, TextSize = 10, ClearTextOnFocus = false, Parent = sidebar,
}, {
	make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	make("UIStroke", { Color = BORDER, Thickness = 1 }),
	make("UIPadding", { PaddingLeft = UDim.new(0, 8) }),
})

local tabPages, tabButtons = {}, {}
local activeTab = nil

local sectionRegistry = {}

local function getSectionFor(tab, child)
	local sections = sectionRegistry[tab]
	if not sections then return nil end
	for _, sec in sections do
		for _, m in sec.members do
			if m == child then return sec end
		end
	end
	return nil
end

local function doSearch(query)
	query = query:lower()
	if not activeTab or not tabPages[activeTab] then return end
	local page = tabPages[activeTab]
	for _, child in page:GetChildren() do
		if child:IsA("GuiObject") then
			if query == "" then
				local sec = getSectionFor(activeTab, child)
				child.Visible = (not sec) or sec.expanded
			else
				local matched = false
				for _, desc in child:GetDescendants() do
					pcall(function()
						if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
							if desc.Text:lower():find(query) then matched = true end
						end
					end)
					if matched then break end
				end
				if child:IsA("TextButton") then
					pcall(function() if child.Text:lower():find(query) then matched = true end end)
				end
				child.Visible = matched
			end
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	doSearch(searchBox.Text)
end)

searchBox.Focused:Connect(function()
	local s = searchBox:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = ACCENT2 }):Play() end
end)
searchBox.FocusLost:Connect(function()
	local s = searchBox:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = BORDER }):Play() end
end)

local sidebarList = make("Frame", {
	Size = UDim2.new(1, -4, 1, -36), Position = UDim2.fromOffset(2, 34),
	BackgroundTransparency = 1, Parent = sidebar,
}, {
	make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Vertical }),
})

local TABS = { "Movement", "Visuals", "Character", "Auto", "Teleport", "Slayer", "Demon", "Players", "Utility", "Settings" }
local TAB_SHORT = { "Move", "Visuals", "Character", "Auto", "TP", "Slayer", "Demon", "Players", "Utility", "Config" }
local TAB_ICON = { "MV", "VI", "CH", "AU", "TP", "SL", "DM", "PL", "UT", "CF" }
local TAB_GROUP_START = { [1] = "PLAYER", [4] = "GAMEPLAY", [9] = "SYSTEM" }

local function addSidebarGroupHeader(text, order)
	make("TextLabel", {
		Size = UDim2.new(1, -8, 0, 16), Position = UDim2.fromOffset(8, 0),
		BackgroundTransparency = 1, Text = text, TextColor3 = ACCENT_DIM,
		Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = order, Parent = sidebarList,
	})
end

local sidebarOrder = 0
for i, name in TABS do
	local page = make("ScrollingFrame", {
		Size = UDim2.new(1, -SIDEBAR_W, 1, 0), Position = UDim2.fromOffset(SIDEBAR_W, 0), BackgroundTransparency = 1,
		ScrollBarThickness = 3, ScrollBarImageColor3 = ACCENT_DIM, BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = bodyFrame,
	}, {
		make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingTop = UDim.new(0, 6) }),
	})
	tabPages[name] = page

	if TAB_GROUP_START[i] then
		sidebarOrder += 1
		addSidebarGroupHeader(TAB_GROUP_START[i], sidebarOrder)
	end

	sidebarOrder += 1
	local btn = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = SIDEBAR_BG, BackgroundTransparency = 1,
		AutoButtonColor = false, Text = "", LayoutOrder = sidebarOrder, Parent = sidebarList,
	}, { make("UICorner", { CornerRadius = UDim.new(0, 8) }) })

	local badge = make("Frame", {
		Name = "Badge", Size = UDim2.fromOffset(24, 24), Position = UDim2.fromOffset(6, 7),
		BackgroundColor3 = ACCENT_DIM, BackgroundTransparency = 0.3, Parent = btn,
	}, { make("UICorner", { CornerRadius = UDim.new(0, 7) }) })
	local badgeText = make("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = TAB_ICON[i],
		TextColor3 = ACCENT2, Font = Enum.Font.GothamBlack, TextSize = 10, Parent = badge,
	})

	local nameLabel = make("TextLabel", {
		Size = UDim2.new(1, -42, 1, 0), Position = UDim2.fromOffset(38, 0), BackgroundTransparency = 1,
		Text = TAB_SHORT[i], TextColor3 = DIM, Font = Enum.Font.GothamBold, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
	})

	local indicator = make("Frame", {
		Name = "Indicator", Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, 0, 0.2, 0),
		BackgroundColor3 = ACCENT, BackgroundTransparency = 1, Parent = btn,
	}, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	tabButtons[name] = btn

	btn.MouseButton1Click:Connect(function()
		if activeTab == name then return end
		SFX.click()
		if activeTab and tabPages[activeTab] then
			tabPages[activeTab].Visible = false
			local oldBtn = tabButtons[activeTab]
			TweenService:Create(oldBtn, TWEEN_FAST, { BackgroundTransparency = 1 }):Play()
			local oldName = oldBtn:FindFirstChild("TextLabel")
			if oldName then TweenService:Create(oldName, TWEEN_FAST, { TextColor3 = DIM }):Play() end
			local oldInd = oldBtn:FindFirstChild("Indicator")
			if oldInd then TweenService:Create(oldInd, TWEEN_FAST, { BackgroundTransparency = 1 }):Play() end
		end
		activeTab = name; tabPages[name].Visible = true
		searchBox.Text = ""
		doSearch("")
		TweenService:Create(btn, TWEEN_FAST, { BackgroundTransparency = 0.3, BackgroundColor3 = ACCENT_DIM }):Play()
		TweenService:Create(nameLabel, TWEEN_FAST, { TextColor3 = WHITE }):Play()
		TweenService:Create(indicator, TWEEN_FAST, { BackgroundTransparency = 0 }):Play()
	end)

	btn.MouseEnter:Connect(function()
		if activeTab ~= name then
			TweenService:Create(btn, TWEEN_FAST, { BackgroundTransparency = 0.5, BackgroundColor3 = BG_HOVER }):Play()
			TweenService:Create(nameLabel, TWEEN_FAST, { TextColor3 = ACCENT2 }):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if activeTab ~= name then
			TweenService:Create(btn, TWEEN_FAST, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(nameLabel, TWEEN_FAST, { TextColor3 = DIM }):Play()
		end
	end)
end

tabPages["Movement"].Visible = true; activeTab = "Movement"
tabButtons["Movement"].BackgroundTransparency = 0.3
tabButtons["Movement"].BackgroundColor3 = ACCENT_DIM
local movName = tabButtons["Movement"]:FindFirstChildOfClass("TextLabel")
if movName then movName.TextColor3 = WHITE end
local movInd = tabButtons["Movement"]:FindFirstChild("Indicator")
if movInd then movInd.BackgroundTransparency = 0 end

------------------------------------------------------------
-- COMPONENTS
------------------------------------------------------------
local orders = {}; for _, t in TABS do orders[t] = 0 end

local function addLabel(tab, text)
	orders[tab] += 1
	local myOrder = orders[tab]
	local lbl = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = BG_CARD, BackgroundTransparency = 0.4,
		AutoButtonColor = false, Text = "", LayoutOrder = myOrder, Parent = tabPages[tab],
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 8) }),
	})
	make("Frame", {
		Size = UDim2.new(0, 3, 0, 16), Position = UDim2.fromOffset(8, 7),
		BackgroundColor3 = ACCENT, Parent = lbl,
	}, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 40, 200)), ColorSequenceKeypoint.new(0.5, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2)}) }),
	})
	make("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(20, 0), BackgroundTransparency = 1, Text = text,
		TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = lbl,
	})
	local arrow = make("TextLabel", {
		Size = UDim2.fromOffset(24, 30), Position = UDim2.new(1, -28, 0, 0), BackgroundTransparency = 1,
		Text = "-", TextColor3 = DIM, Font = Enum.Font.GothamBold, TextSize = 15, Parent = lbl,
	})

	sectionRegistry[tab] = sectionRegistry[tab] or {}
	local sec = { order = myOrder, header = lbl, arrow = arrow, expanded = (#sectionRegistry[tab] == 0), members = {} }
	table.insert(sectionRegistry[tab], sec)

	lbl.MouseButton1Click:Connect(function()
		sec.expanded = not sec.expanded
		SFX.click()
		arrow.Text = sec.expanded and "-" or "+"
		if searchBox.Text == "" then
			for _, m in sec.members do m.Visible = sec.expanded end
		end
	end)
	lbl.MouseEnter:Connect(function() TweenService:Create(lbl, TWEEN_FAST, { BackgroundTransparency = 0.1 }):Play() end)
	lbl.MouseLeave:Connect(function() TweenService:Create(lbl, TWEEN_FAST, { BackgroundTransparency = 0.4 }):Play() end)
end

local function finalizeAccordions()
	for tab, sections in sectionRegistry do
		local page = tabPages[tab]
		for idx, sec in sections do
			local nextOrder = sections[idx + 1] and sections[idx + 1].order or math.huge
			for _, child in page:GetChildren() do
				if child:IsA("GuiObject") and child ~= sec.header and child.LayoutOrder > sec.order and child.LayoutOrder < nextOrder then
					table.insert(sec.members, child)
				end
			end
			if not sec.expanded then
				for _, m in sec.members do m.Visible = false end
				sec.arrow.Text = "+"
			end
		end
	end
end

local function addToggle(tab, label, default, callback)
	orders[tab] += 1
	local state = default
	local row = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = BG_CARD, AutoButtonColor = false,
		Text = "", LayoutOrder = orders[tab], Parent = tabPages[tab],
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = BORDER, Thickness = 1 }),
		make("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(18, 0), BackgroundTransparency = 1, Text = label, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }),
	})
	row.MouseEnter:Connect(function()
		TweenService:Create(row, TWEEN_FAST, { BackgroundColor3 = BG_HOVER }):Play()
		local s = row:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = ACCENT_DIM }):Play() end
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(row, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play()
		local s = row:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = BORDER }):Play() end
	end)

	local statusDot = make("Frame", { Size = UDim2.fromOffset(6, 6), Position = UDim2.fromOffset(6, 16), BackgroundColor3 = TRACK_OFF, Parent = row }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local track = make("Frame", { Size = UDim2.fromOffset(40, 22), Position = UDim2.new(1, -50, 0.5, -11), BackgroundColor3 = TRACK_OFF, Parent = row }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local knob = make("Frame", { Size = UDim2.fromOffset(18, 18), BackgroundColor3 = DIM, Parent = track }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local function render(anim)
		local gK = { Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = state and WHITE or DIM }
		local gT = { BackgroundColor3 = state and TRACK_ON or TRACK_OFF }
		local gD = { BackgroundColor3 = state and GREEN or TRACK_OFF }
		if anim then
			TweenService:Create(knob, TWEEN_FAST, gK):Play()
			TweenService:Create(track, TWEEN_FAST, gT):Play()
			TweenService:Create(statusDot, TWEEN_FAST, gD):Play()
		else for k, v in gK do knob[k] = v end; for k, v in gT do track[k] = v end; statusDot.BackgroundColor3 = gD.BackgroundColor3 end
	end

	row.MouseButton1Click:Connect(function()
		state = not state; render(true)
		SFX.toggle()
		notify(label .. " " .. (state and "ON" or "OFF"))
		task.spawn(callback, state)
	end)

	render(false)

	local ctrl = {}
	function ctrl.set(newState)
		if state == newState then return end
		state = newState; render(true)
	end
	function ctrl.get() return state end
	function ctrl.fire()
		state = not state; render(true)
		task.spawn(callback, state)
	end
	return ctrl
end

local function addSlider(tab, label, min, max, default, step, callback)
	orders[tab] += 1; local value = default; step = step or 1
	local row = make("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = BG_CARD, LayoutOrder = orders[tab], Parent = tabPages[tab] }, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = BORDER, Thickness = 1 }),
	})
	local text = make("TextLabel", { Size = UDim2.new(1, -60, 0, 24), Position = UDim2.fromOffset(14, 2), BackgroundTransparency = 1, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
	local valLabel = make("TextLabel", { Size = UDim2.new(0, 50, 0, 24), Position = UDim2.new(1, -58, 0, 2), BackgroundTransparency = 1, TextColor3 = ACCENT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
	local bar = make("Frame", { Size = UDim2.new(1, -28, 0, 8), Position = UDim2.new(0, 14, 0, 32), BackgroundColor3 = TRACK_OFF, BorderSizePixel = 0, Parent = row }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local fill = make("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Parent = bar }, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, ACCENT), ColorSequenceKeypoint.new(0.5, ACCENT2), ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 190, 255))}) }),
	})
	local knobS = make("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = WHITE, Parent = bar }, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIStroke", { Color = ACCENT, Thickness = 2 }),
	})
	local function set(v)
		if step >= 1 then value = math.clamp(math.round(v / step) * step, min, max)
		else value = math.clamp(math.round(v * (1/step)) / (1/step), min, max) end
		local a = (value - min) / (max - min); fill.Size = UDim2.fromScale(a, 1); knobS.Position = UDim2.fromScale(a, 0.5)
		text.Text = label; valLabel.Text = tostring(value)
	end
	local function upX(x) local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); set(min + a * (max - min)); task.spawn(callback, value) end
	local sliding = false
	row.InputBegan:Connect(function(i) if isClick(i) then sliding = true; upX(i.Position.X) end end)
	UserInputService.InputChanged:Connect(function(i) if sliding and isMove(i) then upX(i.Position.X) end end)
	UserInputService.InputEnded:Connect(function(i) if isClick(i) then sliding = false end end)
	set(default)
end

local function addButton(tab, label, callback)
	orders[tab] += 1
	local btn = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = BG_CARD, AutoButtonColor = false,
		Text = "", LayoutOrder = orders[tab], Parent = tabPages[tab],
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = BORDER, Thickness = 1 }),
	})
	local btnAccent = make("Frame", {
		Size = UDim2.new(0, 3, 0.5, 0), Position = UDim2.new(0, 0, 0.25, 0),
		BackgroundColor3 = ACCENT2, BackgroundTransparency = 0.6, Parent = btn,
	}, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	make("TextLabel", {
		Size = UDim2.new(1, -14, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
		Text = label, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center, Parent = btn,
	})
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = ACCENT_DIM }):Play()
		TweenService:Create(btnAccent, TWEEN_FAST, { BackgroundTransparency = 0, BackgroundColor3 = ACCENT2 }):Play()
		local s = btn:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = ACCENT }):Play() end
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play()
		TweenService:Create(btnAccent, TWEEN_FAST, { BackgroundTransparency = 0.6, BackgroundColor3 = ACCENT2 }):Play()
		local s = btn:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = BORDER }):Play() end
	end)
	btn.MouseButton1Click:Connect(function()
		SFX.click()
		TweenService:Create(btn, TweenInfo.new(0.06), { BackgroundColor3 = ACCENT }):Play()
		task.delay(0.08, function() TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play() end)
		task.spawn(callback)
	end)
end

local function addSpacer(tab, h)
	orders[tab] += 1
	make("Frame", { Size = UDim2.new(1, 0, 0, h or 6), BackgroundTransparency = 1, LayoutOrder = orders[tab], Parent = tabPages[tab] })
end

local function addTextInput(tab, placeholder, callback)
	orders[tab] += 1
	local box = make("TextBox", {
		Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Color3.fromRGB(12, 12, 24),
		Text = "", PlaceholderText = "  " .. placeholder, PlaceholderColor3 = Color3.fromRGB(80, 80, 110),
		TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 12,
		ClearTextOnFocus = false, LayoutOrder = orders[tab], Parent = tabPages[tab],
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = BORDER, Thickness = 1 }),
		make("UIPadding", { PaddingLeft = UDim.new(0, 14) }),
	})
	box.Focused:Connect(function()
		local s = box:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = ACCENT2 }):Play() end
		TweenService:Create(box, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(18, 18, 36) }):Play()
	end)
	box.FocusLost:Connect(function(enter)
		local s = box:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = BORDER }):Play() end
		TweenService:Create(box, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(12, 12, 24) }):Play()
		if enter and box.Text ~= "" then task.spawn(callback, box.Text); box.Text = "" end
	end)
end

local function addDropdown(tab, label, options, callback)
	orders[tab] += 1
	local selectedIndex = 1
	local isOpen = false

	local container = make("Frame", {
		Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1,
		LayoutOrder = orders[tab], Parent = tabPages[tab], ClipsDescendants = false,
	})

	local header = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = BG_CARD, AutoButtonColor = false,
		Text = "", Parent = container,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = BORDER, Thickness = 1 }),
	})

	make("TextLabel", {
		Size = UDim2.new(1, -80, 0, 18), Position = UDim2.fromOffset(14, 4),
		BackgroundTransparency = 1,
		Text = label, TextColor3 = ACCENT, Font = Enum.Font.GothamBold, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
	})

	local selectedLabel = make("TextLabel", {
		Size = UDim2.new(1, -80, 0, 22), Position = UDim2.fromOffset(14, 24),
		BackgroundTransparency = 1, Text = options[1] or "None", TextColor3 = WHITE,
		Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = header,
	})

	local arrow = make("TextLabel", {
		Size = UDim2.fromOffset(24, 56), Position = UDim2.new(1, -28, 0, 0),
		BackgroundTransparency = 1, Text = "v", TextColor3 = ACCENT,
		Font = Enum.Font.GothamBold, TextSize = 14, Parent = header,
	})

	local goBtn = make("TextButton", {
		Size = UDim2.fromOffset(38, 26), Position = UDim2.new(1, -68, 0, 15),
		BackgroundColor3 = ACCENT_DIM, AutoButtonColor = false, Text = "GO",
		TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 11, Parent = header,
	}, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	goBtn.MouseEnter:Connect(function() TweenService:Create(goBtn, TWEEN_FAST, { BackgroundColor3 = ACCENT }):Play() end)
	goBtn.MouseLeave:Connect(function() TweenService:Create(goBtn, TWEEN_FAST, { BackgroundColor3 = ACCENT_DIM }):Play() end)
	goBtn.MouseButton1Click:Connect(function() SFX.click(); task.spawn(callback, selectedIndex, options[selectedIndex]) end)

	local maxVisible = 6
	local itemH = 30
	local listH = math.min(#options, maxVisible) * itemH + 4

	local listFrame = make("ScrollingFrame", {
		Size = UDim2.new(1, 0, 0, listH), Position = UDim2.new(0, 0, 0, 58),
		BackgroundColor3 = Color3.fromRGB(10, 10, 20), Visible = false, ZIndex = 50,
		ScrollBarThickness = 3, ScrollBarImageColor3 = ACCENT_DIM, BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, #options * itemH),
		Parent = container,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		make("UIStroke", { Color = ACCENT_DIM, Thickness = 1 }),
		make("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }),
		make("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) }),
	})

	for i, opt in options do
		local item = make("TextButton", {
			Size = UDim2.new(1, 0, 0, itemH), BackgroundColor3 = Color3.fromRGB(10, 10, 20),
			BackgroundTransparency = 0, AutoButtonColor = false, Text = "",
			LayoutOrder = i, ZIndex = 51, Parent = listFrame,
		})
		local itemLbl = make("TextLabel", {
			Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1, Text = opt, TextColor3 = if i == selectedIndex then ACCENT else WHITE,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 51, Parent = item,
		})
		item.MouseEnter:Connect(function() TweenService:Create(item, TWEEN_FAST, { BackgroundColor3 = BG_HOVER }):Play() end)
		item.MouseLeave:Connect(function() TweenService:Create(item, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(10, 10, 20) }):Play() end)
		item.MouseButton1Click:Connect(function()
			selectedIndex = i
			selectedLabel.Text = opt
			for _, c in listFrame:GetChildren() do
				if c:IsA("TextButton") then
					local l2 = c:FindFirstChildOfClass("TextLabel")
					if l2 then l2.TextColor3 = WHITE end
				end
			end
			itemLbl.TextColor3 = ACCENT
			isOpen = false; listFrame.Visible = false; arrow.Text = "v"
			container.Size = UDim2.new(1, 0, 0, 56)
			container.ClipsDescendants = false
		end)
	end

	header.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		listFrame.Visible = isOpen
		arrow.Text = if isOpen then "^" else "v"
		if isOpen then
			container.Size = UDim2.new(1, 0, 0, 56 + listH + 4)
			container.ClipsDescendants = false
		else
			container.Size = UDim2.new(1, 0, 0, 56)
		end
	end)

	header.MouseEnter:Connect(function()
		TweenService:Create(header, TWEEN_FAST, { BackgroundColor3 = BG_HOVER }):Play()
		local s = header:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = ACCENT_DIM }):Play() end
	end)
	header.MouseLeave:Connect(function()
		TweenService:Create(header, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play()
		local s = header:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = BORDER }):Play() end
	end)

	return { getIndex = function() return selectedIndex end, getText = function() return options[selectedIndex] end }
end

local function addCollapsible(tab, title, startOpen)
	orders[tab] += 1
	local isOpen = if startOpen == nil then false else startOpen

	local wrapper = make("Frame", {
		Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1,
		ClipsDescendants = true, LayoutOrder = orders[tab], Parent = tabPages[tab],
	})

	local headerBtn = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = BG_CARD, AutoButtonColor = false,
		Text = "", Parent = wrapper,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = ACCENT_DIM, Thickness = 1 }),
	})

	make("Frame", {
		Size = UDim2.new(0, 3, 0, 16), Position = UDim2.fromOffset(0, 10),
		BackgroundColor3 = ACCENT, Parent = headerBtn,
	}, {
		make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 40, 200)), ColorSequenceKeypoint.new(0.5, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2)}) }),
	})

	make("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
		Text = title, TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = headerBtn,
	})

	local arrow = make("TextLabel", {
		Size = UDim2.fromOffset(24, 36), Position = UDim2.new(1, -28, 0, 0),
		BackgroundTransparency = 1, Text = if isOpen then "^" else "v", TextColor3 = ACCENT,
		Font = Enum.Font.GothamBold, TextSize = 14, Parent = headerBtn,
	})

	local content = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0), Position = UDim2.fromOffset(0, 40),
		BackgroundTransparency = 1, Parent = wrapper,
	})

	local contentLayout = make("UIListLayout", {
		Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content,
	})
	make("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = content })

	local contentOrder = 0

	local function recalcSize()
		local totalH = 0
		for _, child in content:GetChildren() do
			if child:IsA("GuiObject") then
				totalH = totalH + child.AbsoluteSize.Y + 4
			end
		end
		content.Size = UDim2.new(1, 0, 0, totalH)
		if isOpen then
			wrapper.Size = UDim2.new(1, 0, 0, 40 + totalH + 8)
		end
	end

	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local totalH = contentLayout.AbsoluteContentSize.Y
		content.Size = UDim2.new(1, 0, 0, totalH)
		if isOpen then
			wrapper.Size = UDim2.new(1, 0, 0, 40 + totalH + 8)
		end
	end)

	local function toggle()
		isOpen = not isOpen
		arrow.Text = if isOpen then "^" else "v"
		if isOpen then
			local totalH = contentLayout.AbsoluteContentSize.Y
			content.Size = UDim2.new(1, 0, 0, totalH)
			wrapper.Size = UDim2.new(1, 0, 0, 40 + totalH + 8)
		else
			wrapper.Size = UDim2.new(1, 0, 0, 36)
		end
	end

	headerBtn.MouseButton1Click:Connect(toggle)
	headerBtn.MouseEnter:Connect(function()
		TweenService:Create(headerBtn, TWEEN_FAST, { BackgroundColor3 = BG_HOVER }):Play()
	end)
	headerBtn.MouseLeave:Connect(function()
		TweenService:Create(headerBtn, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play()
	end)

	if isOpen then
		task.defer(function()
			local totalH = contentLayout.AbsoluteContentSize.Y
			content.Size = UDim2.new(1, 0, 0, totalH)
			wrapper.Size = UDim2.new(1, 0, 0, 40 + totalH + 8)
		end)
	end

	local api = {}

	function api.addToggle(label, default, callback)
		contentOrder += 1
		local state = default
		local row = make("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = BG_CARD, LayoutOrder = contentOrder, Parent = content }, {
			make("UICorner", { CornerRadius = UDim.new(0, 10) }),
			make("UIStroke", { Color = BORDER, Thickness = 1 }),
		})
		make("TextLabel", {
			Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(14, 0),
			BackgroundTransparency = 1, Text = label, TextColor3 = WHITE,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		local track = make("Frame", {
			Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -50, 0.5, -9),
			BackgroundColor3 = TRACK_OFF, Parent = row,
		}, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local knob = make("Frame", {
			Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2),
			BackgroundColor3 = WHITE, Parent = track,
		}, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local function render(anim)
			local t = if anim then TWEEN_FAST else TweenInfo.new(0)
			if state then
				TweenService:Create(track, t, { BackgroundColor3 = ACCENT }):Play()
				TweenService:Create(knob, t, { Position = UDim2.fromOffset(20, 2) }):Play()
			else
				TweenService:Create(track, t, { BackgroundColor3 = TRACK_OFF }):Play()
				TweenService:Create(knob, t, { Position = UDim2.fromOffset(2, 2) }):Play()
			end
		end
		render(false)
		local btn = make("TextButton", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = row,
		})
		btn.MouseButton1Click:Connect(function()
			state = not state; render(true); task.spawn(callback, state)
		end)
		local ctrl = {}
		function ctrl.set(v) if state == v then return end; state = v; render(true) end
		function ctrl.get() return state end
		return ctrl
	end

	function api.addSlider(label, min, max, default, step, callback)
		contentOrder += 1; local value = default; step = step or 1
		local row = make("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = BG_CARD, LayoutOrder = contentOrder, Parent = content }, {
			make("UICorner", { CornerRadius = UDim.new(0, 10) }),
			make("UIStroke", { Color = BORDER, Thickness = 1 }),
		})
		local text = make("TextLabel", { Size = UDim2.new(1, -60, 0, 24), Position = UDim2.fromOffset(14, 2), BackgroundTransparency = 1, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
		local valLabel = make("TextLabel", { Size = UDim2.new(0, 50, 0, 24), Position = UDim2.new(1, -58, 0, 2), BackgroundTransparency = 1, TextColor3 = ACCENT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
		local bar = make("Frame", { Size = UDim2.new(1, -28, 0, 8), Position = UDim2.new(0, 14, 0, 32), BackgroundColor3 = TRACK_OFF, BorderSizePixel = 0, Parent = row }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local fill = make("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Parent = bar }, {
			make("UICorner", { CornerRadius = UDim.new(1, 0) }),
			make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, ACCENT), ColorSequenceKeypoint.new(0.5, ACCENT2), ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 190, 255))}) }),
		})
		local knobS = make("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = WHITE, Parent = bar }, {
			make("UICorner", { CornerRadius = UDim.new(1, 0) }),
			make("UIStroke", { Color = ACCENT, Thickness = 2 }),
		})
		local function set(v)
			if step >= 1 then value = math.clamp(math.round(v / step) * step, min, max)
			else value = math.clamp(math.round(v * (1/step)) / (1/step), min, max) end
			local a = (value - min) / (max - min); fill.Size = UDim2.fromScale(a, 1); knobS.Position = UDim2.fromScale(a, 0.5)
			text.Text = label; valLabel.Text = tostring(value)
		end
		local function upX(x) local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1); set(min + a * (max - min)); task.spawn(callback, value) end
		local sliding = false
		row.InputBegan:Connect(function(i) if isClick(i) then sliding = true; upX(i.Position.X) end end)
		UserInputService.InputChanged:Connect(function(i) if sliding and isMove(i) then upX(i.Position.X) end end)
		UserInputService.InputEnded:Connect(function(i) if isClick(i) then sliding = false end end)
		set(default)
	end

	function api.addButton(label, callback)
		contentOrder += 1
		local btn = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = BG_CARD, AutoButtonColor = false,
			Text = "", LayoutOrder = contentOrder, Parent = content,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 10) }),
			make("UIStroke", { Color = BORDER, Thickness = 1 }),
		})
		make("TextLabel", {
			Size = UDim2.new(1, -14, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
			Text = label, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center, Parent = btn,
		})
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = ACCENT_DIM }):Play()
			local s = btn:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = ACCENT }):Play() end
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play()
			local s = btn:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = BORDER }):Play() end
		end)
		btn.MouseButton1Click:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.06), { BackgroundColor3 = ACCENT }):Play()
			task.delay(0.08, function() TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play() end)
			task.spawn(callback)
		end)
	end

	function api.addLabel(text)
		contentOrder += 1
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
			Text = text, TextColor3 = ACCENT, Font = Enum.Font.GothamBold, TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = contentOrder, Parent = content,
		})
	end

	function api.addTextInput(placeholder, callback)
		contentOrder += 1
		local box = make("TextBox", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(12, 12, 24),
			Text = "", PlaceholderText = "  " .. placeholder, PlaceholderColor3 = Color3.fromRGB(80, 80, 110),
			TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 12,
			ClearTextOnFocus = false, LayoutOrder = contentOrder, Parent = content,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 10) }),
			make("UIStroke", { Color = BORDER, Thickness = 1 }),
			make("UIPadding", { PaddingLeft = UDim.new(0, 14) }),
		})
		box.FocusLost:Connect(function(enter)
			if enter and box.Text ~= "" then task.spawn(callback, box.Text); box.Text = "" end
		end)
	end

	function api.addDropdown(label, options, callback)
		contentOrder += 1
		local selectedIndex = 1
		local isDropOpen = false
		local ddContainer = make("Frame", {
			Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1,
			LayoutOrder = contentOrder, Parent = content, ClipsDescendants = false,
		})
		local ddHeader = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = BG_CARD, AutoButtonColor = false,
			Text = "", Parent = ddContainer,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 10) }),
			make("UIStroke", { Color = BORDER, Thickness = 1 }),
		})
		make("TextLabel", {
			Size = UDim2.new(1, -80, 0, 18), Position = UDim2.fromOffset(14, 4),
			BackgroundTransparency = 1, Text = label, TextColor3 = ACCENT,
			Font = Enum.Font.GothamBold, TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = ddHeader,
		})
		local ddSelectedLabel = make("TextLabel", {
			Size = UDim2.new(1, -80, 0, 22), Position = UDim2.fromOffset(14, 24),
			BackgroundTransparency = 1, Text = options[1] or "None", TextColor3 = WHITE,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = ddHeader,
		})
		local ddArrow = make("TextLabel", {
			Size = UDim2.fromOffset(24, 56), Position = UDim2.new(1, -28, 0, 0),
			BackgroundTransparency = 1, Text = "v", TextColor3 = ACCENT,
			Font = Enum.Font.GothamBold, TextSize = 14, Parent = ddHeader,
		})
		local maxVis = 6
		local itemH = 30
		local listH = math.min(#options, maxVis) * itemH + 4
		local ddList = make("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, listH), Position = UDim2.new(0, 0, 0, 58),
			BackgroundColor3 = Color3.fromRGB(10, 10, 20), Visible = false, ZIndex = 50,
			ScrollBarThickness = 3, ScrollBarImageColor3 = ACCENT_DIM, BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, #options * itemH),
			Parent = ddContainer,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 8) }),
			make("UIStroke", { Color = ACCENT_DIM, Thickness = 1 }),
		})
		for i, opt in options do
			local btn = make("TextButton", {
				Size = UDim2.new(1, -4, 0, itemH), Position = UDim2.fromOffset(2, (i - 1) * itemH + 2),
				BackgroundColor3 = Color3.fromRGB(18, 18, 36), AutoButtonColor = false,
				Text = opt, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 11,
				ZIndex = 51, Parent = ddList,
			}, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })
			btn.MouseEnter:Connect(function() TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = BG_HOVER }):Play() end)
			btn.MouseLeave:Connect(function() TweenService:Create(btn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(18, 18, 36) }):Play() end)
			btn.MouseButton1Click:Connect(function()
				SFX.click(); selectedIndex = i; ddSelectedLabel.Text = opt
				isDropOpen = false; ddList.Visible = false; ddArrow.Text = "v"
				ddContainer.Size = UDim2.new(1, 0, 0, 56)
				task.spawn(callback, i, opt)
			end)
		end
		ddHeader.MouseButton1Click:Connect(function()
			SFX.click(); isDropOpen = not isDropOpen; ddList.Visible = isDropOpen
			ddArrow.Text = if isDropOpen then "^" else "v"
			ddContainer.Size = if isDropOpen then UDim2.new(1, 0, 0, 56 + listH + 4) else UDim2.new(1, 0, 0, 56)
		end)
	end

	function api.addCustom(inst)
		contentOrder += 1
		inst.LayoutOrder = contentOrder
		inst.Parent = content
	end

	return api
end

------------------------------------------------------------
-- INPUT TRACKING
------------------------------------------------------------
local keysDown = {}
UserInputService.InputBegan:Connect(function(i, gpe) if not gpe then keysDown[i.KeyCode] = true end end)
UserInputService.InputEnded:Connect(function(i) keysDown[i.KeyCode] = nil end)

local function getValuesFolder()
	local vf = nil
	pcall(function()
		vf = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Service")
		if vf then vf = vf:FindFirstChild("Values") end
		if vf then vf = vf:FindFirstChild(player.Name) end
	end)
	return vf
end

------------------------------------------------------------
-- MOVEMENT TAB
------------------------------------------------------------
addLabel("Movement", "SPEED")

local DEFAULT_SPEED = 16
local speedEnabled, speedValue = false, 50

RunService.Heartbeat:Connect(function()
	if speedEnabled then local h = getHumanoid(); if h then h.WalkSpeed = speedValue end end
end)

local speedToggle = addToggle("Movement", "Walk Speed", false, function(on)
	speedEnabled = on
	if not on then local h = getHumanoid(); if h then h.WalkSpeed = DEFAULT_SPEED end end
end)
addSlider("Movement", "Speed", 16, 300, speedValue, 1, function(v) speedValue = v end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == keybinds.speed then
		speedEnabled = not speedEnabled
		speedToggle.set(speedEnabled)
		if not speedEnabled then local h = getHumanoid(); if h then h.WalkSpeed = DEFAULT_SPEED end end
		notify("Speed " .. (speedEnabled and "ON" or "OFF"))
	end
end)

addSpacer("Movement")
addLabel("Movement", "FLIGHT")

local flyEnabled, flySpeed = false, 80
local flyBV, flyBG, flyConn

local function startFly()
	local hrp, humanoid = getHRP(), getHumanoid()
	if not hrp or not humanoid then return end
	humanoid.PlatformStand = true
	flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.one * math.huge; flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
	flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.one * math.huge; flyBG.P = 9000; flyBG.Parent = hrp
	flyConn = RunService.Heartbeat:Connect(function()
		if not flyEnabled then return end
		local cf = camera.CFrame; local dir = Vector3.zero
		if keysDown[Enum.KeyCode.W] then dir += cf.LookVector end
		if keysDown[Enum.KeyCode.S] then dir -= cf.LookVector end
		if keysDown[Enum.KeyCode.A] then dir -= cf.RightVector end
		if keysDown[Enum.KeyCode.D] then dir += cf.RightVector end
		if keysDown[Enum.KeyCode.Space] then dir += Vector3.yAxis end
		if keysDown[Enum.KeyCode.LeftShift] then dir -= Vector3.yAxis end
		if dir.Magnitude > 0 then dir = dir.Unit end
		flyBV.Velocity = dir * flySpeed; flyBG.CFrame = cf
	end)
end

local function stopFly()
	if flyConn then flyConn:Disconnect(); flyConn = nil end
	if flyBV then flyBV:Destroy(); flyBV = nil end
	if flyBG then flyBG:Destroy(); flyBG = nil end
	local h = getHumanoid(); if h then h.PlatformStand = false end
end

local flyToggle = addToggle("Movement", "Fly", false, function(on) flyEnabled = on; if on then startFly() else stopFly() end end)
addSlider("Movement", "Fly Speed", 20, 400, flySpeed, 5, function(v) flySpeed = v end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == keybinds.fly then
		flyEnabled = not flyEnabled
		flyToggle.set(flyEnabled)
		if flyEnabled then startFly() else stopFly() end
		notify("Fly " .. (flyEnabled and "ON" or "OFF"))
	end
end)

player.CharacterAdded:Connect(function()
	if freecamOn then
		freecamAnchorPart = nil
		task.wait(0.5)
		local hrp = getHRP()
		if hrp then hrp.Anchored = true; freecamAnchorPart = hrp end
	end
	if flyEnabled then
		task.wait(0.5)
		stopFly()
		startFly()
	end
end)

addSpacer("Movement")
addLabel("Movement", "JUMPING")

local infJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then local h = getHumanoid(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
addToggle("Movement", "Infinite Jump", false, function(on) infJumpEnabled = on end)

local DEFAULT_JUMP = 50
local jpEnabled, jpValue = false, 120
RunService.Heartbeat:Connect(function()
	if jpEnabled then local h = getHumanoid(); if h then h.UseJumpPower = true; h.JumpPower = jpValue end end
end)
addToggle("Movement", "Jump Power", false, function(on)
	jpEnabled = on; if not on then local h = getHumanoid(); if h then h.JumpPower = DEFAULT_JUMP end end
end)
addSlider("Movement", "Jump Power", 50, 500, jpValue, 10, function(v) jpValue = v end)

addSpacer("Movement")
addLabel("Movement", "COLLISION")

local noclipEnabled = false
RunService.Stepped:Connect(function()
	if not noclipEnabled then return end
	local c = player.Character; if not c then return end
	for _, p in c:GetDescendants() do if p:IsA("BasePart") then p.CanCollide = false end end
end)
addToggle("Movement", "Noclip", false, function(on) noclipEnabled = on end)

addSpacer("Movement")
addLabel("Movement", "STAMINA & DASH")

local infStaminaEnabled = false
addToggle("Movement", "Infinite Stamina", false, function(on)
	infStaminaEnabled = on
	if on then notify("Infinite Stamina ON") end
end)

task.spawn(function()
	while true do
		task.wait(0.05)
		if infStaminaEnabled then
			pcall(function()
				local vf = getValuesFolder()
				if vf then
					local stam = vf:FindFirstChild("Stamina")
					if stam and stam:IsA("NumberValue") then
						if stam.Value < 100 then stam.Value = 100 end
					end
				end
			end)
		end
	end
end)

------------------------------------------------------------
-- VISUALS TAB
------------------------------------------------------------
do -- scope: visuals
addLabel("Visuals", "CAMERA")

local DEFAULT_FOV = 70
addSlider("Visuals", "FOV", 30, 120, DEFAULT_FOV, 1, function(v) camera.FieldOfView = v end)
addButton("Visuals", "Reset FOV", function() camera.FieldOfView = DEFAULT_FOV; notify("FOV reset") end)

local freecamSpeed = 60
local savedCamType
addToggle("Visuals", "Freecam", false, function(on)
	freecamOn = on
	if on then
		savedCamType = camera.CameraType
		camera.CameraType = Enum.CameraType.Scriptable
		local hrp = getHRP()
		if hrp then
			hrp.Anchored = true
			freecamAnchorPart = hrp
		end
		notify("WASD+QE move | Ctrl=fast | Right-click=look")
	else
		camera.CameraType = savedCamType or Enum.CameraType.Custom
		camera.CameraSubject = getHumanoid()
		if freecamAnchorPart then
			pcall(function() freecamAnchorPart.Anchored = false end)
			freecamAnchorPart = nil
		end
	end
end)
addSlider("Visuals", "Cam Speed", 10, 200, freecamSpeed, 5, function(v) freecamSpeed = v end)

RunService.RenderStepped:Connect(function(dt)
	if not freecamOn then return end
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local delta = UserInputService:GetMouseDelta()
		local rx, ry = camera.CFrame:ToEulerAnglesYXZ()
		ry = ry - math.rad(delta.X * 0.3)
		rx = math.clamp(rx - math.rad(delta.Y * 0.3), math.rad(-80), math.rad(80))
		camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(rx, ry, 0)
	end
	local dir = Vector3.zero; local cf = camera.CFrame
	if keysDown[Enum.KeyCode.W] then dir += cf.LookVector end
	if keysDown[Enum.KeyCode.S] then dir -= cf.LookVector end
	if keysDown[Enum.KeyCode.A] then dir -= cf.RightVector end
	if keysDown[Enum.KeyCode.D] then dir += cf.RightVector end
	if keysDown[Enum.KeyCode.E] or keysDown[Enum.KeyCode.Space] then dir += Vector3.yAxis end
	if keysDown[Enum.KeyCode.Q] or keysDown[Enum.KeyCode.LeftShift] then dir -= Vector3.yAxis end
	if dir.Magnitude > 0 then dir = dir.Unit end
	local speed = freecamSpeed; if keysDown[Enum.KeyCode.LeftControl] then speed *= 3 end
	camera.CFrame = CFrame.new(cf.Position + dir * speed * dt) * cf.Rotation
end)

addSpacer("Visuals")
addLabel("Visuals", "ESP")

local espEnabled = false
local mobEspEnabled = false
local npcEspEnabled = false
local espFolder = Instance.new("Folder"); espFolder.Name = "_ESP"; espFolder.Parent = gui
local mobEspFolder = Instance.new("Folder"); mobEspFolder.Name = "_MobESP"; mobEspFolder.Parent = gui
local npcEspFolder = Instance.new("Folder"); npcEspFolder.Name = "_NpcESP"; npcEspFolder.Parent = gui

local TEAM_COLORS = {
	Color3.fromRGB(130, 80, 255),
	Color3.fromRGB(80, 200, 255),
	Color3.fromRGB(255, 130, 80),
	Color3.fromRGB(80, 255, 160),
	Color3.fromRGB(255, 80, 180),
	Color3.fromRGB(255, 220, 80),
}

local function getPlayerColor(p)
	local idx = 1
	for i, pl in Players:GetPlayers() do if pl == p then idx = i; break end end
	return TEAM_COLORS[((idx - 1) % #TEAM_COLORS) + 1]
end

local function clearESP() for _, h in espFolder:GetChildren() do h:Destroy() end end
local function clearMobESP() for _, h in mobEspFolder:GetChildren() do h:Destroy() end end
local function clearNpcESP() for _, h in npcEspFolder:GetChildren() do h:Destroy() end end

local function applyESP()
	clearESP()
	if not espEnabled then return end
	for _, p in Players:GetPlayers() do
		if p ~= player and p.Character then
			local col = getPlayerColor(p)
			local hl = Instance.new("Highlight"); hl.FillColor = col; hl.FillTransparency = 0.65
			hl.OutlineColor = col; hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Adornee = p.Character; hl.Parent = espFolder
			local head = p.Character:FindFirstChild("Head")
			if head then
				local bb = make("BillboardGui", { Size = UDim2.fromOffset(160, 52), StudsOffset = Vector3.new(0, 3.5, 0), AlwaysOnTop = true, Adornee = head, Parent = espFolder })
				local nameFrame = make("Frame", { Size = UDim2.new(0.9, 0, 0, 18), Position = UDim2.new(0.05, 0, 0, 0), BackgroundColor3 = BG, BackgroundTransparency = 0.3, Parent = bb }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
				make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = col, Font = Enum.Font.GothamBold, TextSize = 13, TextStrokeTransparency = 0.3, TextStrokeColor3 = BG, Text = p.DisplayName, Parent = nameFrame })
				local dl = make("TextLabel", { Size = UDim2.new(1, 0, 0, 12), Position = UDim2.fromOffset(0, 20), BackgroundTransparency = 1, TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 10, TextStrokeTransparency = 0.3, TextStrokeColor3 = BG, Text = "", Parent = bb })
				local hpBg = make("Frame", { Size = UDim2.new(0.7, 0, 0, 4), Position = UDim2.new(0.15, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 0.3, Parent = bb }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
				local hpFill = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = GREEN, Parent = hpBg }, {
					make("UICorner", { CornerRadius = UDim.new(1, 0) }),
					make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, GREEN), ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 200, 100))}) }),
				})
				local hpText = make("TextLabel", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.fromOffset(0, 40), BackgroundTransparency = 1, TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 9, TextStrokeTransparency = 0.3, TextStrokeColor3 = BG, Text = "", Parent = bb })
				task.spawn(function()
					while bb.Parent and espEnabled do
						local hrp = getHRP(); local o = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
						local dist = 0
						if hrp and o then dist = math.round((hrp.Position - o.Position).Magnitude); dl.Text = dist .. "m" end
						local oh = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
						if oh then
							local pct = math.clamp(oh.Health / oh.MaxHealth, 0, 1)
							hpFill.Size = UDim2.fromScale(pct, 1)
							hpFill.BackgroundColor3 = pct > 0.5 and GREEN or pct > 0.25 and YELLOW or RED
							hpText.Text = math.round(oh.Health) .. "/" .. math.round(oh.MaxHealth)
						end
						task.wait(0.15)
					end
				end)
			end
		end
	end
end

local function applyMobESP()
	clearMobESP()
	if not mobEspEnabled then return end
	local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
	for _, source in sources do
		if source then
			local regions = source:FindFirstChild("Regions")
			if regions then
				for _, region in regions:GetChildren() do
					local activeNpcs = region:FindFirstChild("ActiveNpcs")
					if activeNpcs then
						for _, npcFolder in activeNpcs:GetChildren() do
							if npcFolder.Name ~= "Horse" then
								for _, child in npcFolder:GetChildren() do
									if child:IsA("Model") then
										local hum = child:FindFirstChildOfClass("Humanoid")
										local head = child:FindFirstChild("Head") or child:FindFirstChild("HumanoidRootPart")
										if hum and hum.Health > 0 and head then
											local hl = Instance.new("Highlight"); hl.FillColor = RED; hl.FillTransparency = 0.8
											hl.OutlineColor = RED; hl.OutlineTransparency = 0.2; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
											hl.Adornee = child; hl.Parent = mobEspFolder
											local bb = make("BillboardGui", { Size = UDim2.fromOffset(140, 38), StudsOffset = Vector3.new(0, 3, 0), AlwaysOnTop = true, Adornee = head, Parent = mobEspFolder })
											make("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, TextColor3 = RED, Font = Enum.Font.GothamBold, TextSize = 11, TextStrokeTransparency = 0.3, TextStrokeColor3 = BG, Text = npcFolder.Name, Parent = bb })
											local mhpBg = make("Frame", { Size = UDim2.new(0.7, 0, 0, 3), Position = UDim2.new(0.15, 0, 0, 16), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = bb }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
											local mhpFill = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = RED, Parent = mhpBg }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
											local mdl = make("TextLabel", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.fromOffset(0, 21), BackgroundTransparency = 1, TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 9, TextStrokeTransparency = 0.3, TextStrokeColor3 = BG, Text = "", Parent = bb })
											task.spawn(function()
												while bb.Parent and mobEspEnabled do
													if hum and hum.Parent then
														local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
														mhpFill.Size = UDim2.fromScale(pct, 1)
														mdl.Text = math.round(hum.Health) .. "/" .. math.round(hum.MaxHealth)
													else bb:Destroy(); hl:Destroy(); break end
													local hrp = getHRP(); local mobRoot = child:FindFirstChild("HumanoidRootPart")
													if hrp and mobRoot then mdl.Text = mdl.Text .. " | " .. math.round((hrp.Position - mobRoot.Position).Magnitude) .. "m" end
													task.wait(0.3)
												end
											end)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

local function applyNpcESP()
	clearNpcESP()
	if not npcEspEnabled then return end
	local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
	for _, source in sources do
		if source then
			local regions = source:FindFirstChild("Regions")
			if regions then
				for _, region in regions:GetChildren() do
					local stationaryNpcs = region:FindFirstChild("StationaryNpcs")
					if stationaryNpcs then
						for _, npc in stationaryNpcs:GetChildren() do
							if npc:IsA("Model") then
								local head = npc:FindFirstChild("Head") or npc:FindFirstChild("HumanoidRootPart")
								if head then
									local hl = Instance.new("Highlight"); hl.FillColor = ACCENT2; hl.FillTransparency = 0.85
									hl.OutlineColor = ACCENT2; hl.OutlineTransparency = 0.3; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
									hl.Adornee = npc; hl.Parent = npcEspFolder
									local bb = make("BillboardGui", { Size = UDim2.fromOffset(120, 16), StudsOffset = Vector3.new(0, 3, 0), AlwaysOnTop = true, Adornee = head, Parent = npcEspFolder })
									make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = ACCENT2, Font = Enum.Font.GothamBold, TextSize = 11, TextStrokeTransparency = 0.3, TextStrokeColor3 = BG, Text = npc.Name, Parent = bb })
								end
							end
						end
					end
					local activeNpcs = region:FindFirstChild("ActiveNpcs")
					if activeNpcs then
						for _, npcFolder in activeNpcs:GetChildren() do
							if npcFolder.Name == "Horse" then
								for _, child in npcFolder:GetChildren() do
									if child:IsA("Model") then
										local head = child:FindFirstChild("Head") or child:FindFirstChild("HumanoidRootPart")
										if head then
											local hl = Instance.new("Highlight"); hl.FillColor = YELLOW; hl.FillTransparency = 0.85
											hl.OutlineColor = YELLOW; hl.OutlineTransparency = 0.3; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
											hl.Adornee = child; hl.Parent = npcEspFolder
											local bb = make("BillboardGui", { Size = UDim2.fromOffset(80, 16), StudsOffset = Vector3.new(0, 3, 0), AlwaysOnTop = true, Adornee = head, Parent = npcEspFolder })
											make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = YELLOW, Font = Enum.Font.GothamBold, TextSize = 11, TextStrokeTransparency = 0.3, TextStrokeColor3 = BG, Text = "Horse", Parent = bb })
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

addToggle("Visuals", "Player ESP", false, function(on) espEnabled = on; applyESP() end)
addToggle("Visuals", "Mob ESP", false, function(on) mobEspEnabled = on; if on then applyMobESP() else clearMobESP() end end)
addToggle("Visuals", "NPC ESP", false, function(on) npcEspEnabled = on; if on then applyNpcESP() else clearNpcESP() end end)

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1); if espEnabled then applyESP() end end) end)
Players.PlayerRemoving:Connect(function() if espEnabled then task.wait(0.5); applyESP() end end)
for _, p in Players:GetPlayers() do if p ~= player then p.CharacterAdded:Connect(function() task.wait(1); if espEnabled then applyESP() end end) end end

task.spawn(function()
	while true do
		task.wait(5)
		if mobEspEnabled then applyMobESP() end
		if npcEspEnabled then applyNpcESP() end
	end
end)

local tracerEnabled = false
local tracerFrames = {}
local hasDrawing = pcall(function() return Drawing end)

addToggle("Visuals", "Tracers", false, function(on)
	tracerEnabled = on
	if not on then
		if hasDrawing then
			for _, l in tracerFrames do pcall(function() l:Remove() end) end
		else
			for _, f in tracerFrames do pcall(function() f:Destroy() end) end
		end
		tracerFrames = {}
	end
end)

RunService.RenderStepped:Connect(function()
	if not tracerEnabled then return end
	local idx = 0
	local vpSize = camera.ViewportSize
	local originX, originY = vpSize.X / 2, vpSize.Y
	for _, p in Players:GetPlayers() do
		if p ~= player and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				idx += 1
				local pos, vis = camera:WorldToViewportPoint(hrp.Position)
				if vis then
					if hasDrawing then
						if not tracerFrames[idx] then
							tracerFrames[idx] = Drawing.new("Line")
							tracerFrames[idx].Color = WHITE
							tracerFrames[idx].Thickness = 1
							tracerFrames[idx].Transparency = 0.6
						end
						tracerFrames[idx].From = Vector2.new(originX, originY)
						tracerFrames[idx].To = Vector2.new(pos.X, pos.Y)
						tracerFrames[idx].Visible = true
					else
						local target = Vector2.new(pos.X, pos.Y)
						local diff = target - Vector2.new(originX, originY)
						local dist = diff.Magnitude
						local angle = math.atan2(diff.Y, diff.X)
						local mid = Vector2.new((originX + pos.X) / 2, (originY + pos.Y) / 2)
						if not tracerFrames[idx] then
							tracerFrames[idx] = make("Frame", {
								Name = "_Tracer", AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = WHITE, BackgroundTransparency = 0.4,
								BorderSizePixel = 0, Parent = gui,
							})
						end
						tracerFrames[idx].Size = UDim2.fromOffset(dist, 1)
						tracerFrames[idx].Position = UDim2.fromOffset(mid.X, mid.Y)
						tracerFrames[idx].Rotation = math.deg(angle)
						tracerFrames[idx].Visible = true
					end
				else
					if tracerFrames[idx] then
						if hasDrawing then tracerFrames[idx].Visible = false
						else tracerFrames[idx].Visible = false end
					end
				end
			end
		end
	end
	for i = idx + 1, #tracerFrames do
		if tracerFrames[i] then
			if hasDrawing then tracerFrames[i].Visible = false
			else tracerFrames[i].Visible = false end
		end
	end
end)

addSpacer("Visuals")
addLabel("Visuals", "ENVIRONMENT")

local savedLighting = {}
addToggle("Visuals", "Fullbright", false, function(on)
	if on then
		savedLighting.Ambient = Lighting.Ambient; savedLighting.Brightness = Lighting.Brightness
		savedLighting.FogEnd = Lighting.FogEnd; savedLighting.GlobalShadows = Lighting.GlobalShadows
		Lighting.Ambient = Color3.new(1, 1, 1); Lighting.Brightness = 2; Lighting.FogEnd = 1e6; Lighting.GlobalShadows = false
		for _, e in Lighting:GetDescendants() do
			if e:IsA("Atmosphere") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("BlurEffect") then e.Enabled = false end
		end
	else
		Lighting.Ambient = savedLighting.Ambient or Color3.fromRGB(128, 128, 128)
		Lighting.Brightness = savedLighting.Brightness or 1; Lighting.FogEnd = savedLighting.FogEnd or 10000
		Lighting.GlobalShadows = if savedLighting.GlobalShadows ~= nil then savedLighting.GlobalShadows else true
		for _, e in Lighting:GetDescendants() do
			if e:IsA("Atmosphere") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("BlurEffect") then e.Enabled = true end
		end
	end
end)

addToggle("Visuals", "No Fog", false, function(on)
	if on then
		savedLighting._FogEnd = Lighting.FogEnd; savedLighting._FogStart = Lighting.FogStart
		Lighting.FogEnd = 1e9; Lighting.FogStart = 1e9
		for _, e in Lighting:GetDescendants() do
			if e:IsA("Atmosphere") then
				savedLighting["_Atmo_" .. e:GetFullName()] = { Density = e.Density, Offset = e.Offset }
				e.Density = 0; e.Offset = 1
			end
		end
		for _, e in workspace:GetDescendants() do
			if e:IsA("Atmosphere") then
				savedLighting["_Atmo_" .. e:GetFullName()] = { Density = e.Density, Offset = e.Offset }
				e.Density = 0; e.Offset = 1
			end
		end
	else
		Lighting.FogEnd = savedLighting._FogEnd or 10000; Lighting.FogStart = savedLighting._FogStart or 0
		for _, e in Lighting:GetDescendants() do
			if e:IsA("Atmosphere") then
				local saved = savedLighting["_Atmo_" .. e:GetFullName()]
				if saved then e.Density = saved.Density; e.Offset = saved.Offset end
			end
		end
		for _, e in workspace:GetDescendants() do
			if e:IsA("Atmosphere") then
				local saved = savedLighting["_Atmo_" .. e:GetFullName()]
				if saved then e.Density = saved.Density; e.Offset = saved.Offset end
			end
		end
	end
	notify("No Fog " .. (on and "ON" or "OFF"))
end)

local xrayOriginals = {}
addToggle("Visuals", "X-Ray", false, function(on)
	if on then
		for _, p in workspace:GetDescendants() do
			if p:IsA("BasePart") and not p:IsDescendantOf(player.Character or Instance.new("Folder")) then
				if p.Transparency < 0.5 then xrayOriginals[p] = p.Transparency; p.Transparency = 0.7 end
			end
		end
	else
		for p, t in xrayOriginals do if p and p.Parent then p.Transparency = t end end
		xrayOriginals = {}
	end
end)

addSlider("Visuals", "Time of Day", 0, 24, 12, 0.5, function(v) Lighting.ClockTime = v end)
end -- scope: visuals

------------------------------------------------------------
-- CHARACTER TAB
------------------------------------------------------------
local signalRemote = nil
local effectsRemoteGlobal = nil
pcall(function()
	signalRemote = game:GetService("ReplicatedStorage").Communication.ServerAndClient.Signals.SignalEvent.Event
end)
if not signalRemote then
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local comm = rs:FindFirstChild("Communication", true)
		if comm then
			local sig = comm:FindFirstChild("SignalEvent", true)
			if sig then
				local evt = sig:FindFirstChild("Event")
				if evt then signalRemote = evt end
			end
		end
	end)
end
if not signalRemote then
	task.spawn(function()
		task.wait(3)
		pcall(function()
			signalRemote = game:GetService("ReplicatedStorage").Communication.ServerAndClient.Signals.SignalEvent.Event
		end)
		if signalRemote then notify("Signal remote found") end
	end)
end

do -- scope: character
addLabel("Character", "SURVIVAL")

local godEnabled = false
RunService.Heartbeat:Connect(function()
	if godEnabled then
		local h = getHumanoid(); if h then
			h.Health = h.MaxHealth
			h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		end
	end
end)
addToggle("Character", "God Mode", false, function(on)
	godEnabled = on
	if not on then
		local h = getHumanoid(); if h then
			h:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		end
	end
end)

local function fireBlockHold()
	local hrp = getHRP(); if not hrp then return end
	if signalRemote then
		pcall(function() signalRemote:FireServer("server_skill_controller_signaler", "Blocking", "Hold", hrp.Position) end)
	end
end

local function fireBlockUnhold()
	local hrp = getHRP(); if not hrp then return end
	if signalRemote then
		pcall(function() signalRemote:FireServer("server_skill_controller_signaler", "Blocking", "UnHold", hrp.Position, nil) end)
	end
end

local autoBlockEnabled = false
addToggle("Character", "Auto Block", false, function(on)
	autoBlockEnabled = on
	if on then
		if not signalRemote then
			pcall(function()
				signalRemote = game:GetService("ReplicatedStorage").Communication.ServerAndClient.Signals.SignalEvent.Event
			end)
		end
		if signalRemote then notify("Auto Block ON") else notify("Signal remote not found!") end
	else
		fireBlockUnhold()
	end
end)

task.spawn(function()
	while true do
		task.wait(0.4)
		if autoBlockEnabled then fireBlockHold() end
	end
end)

local autoParryEnabled = false
local parryHoldTime = 0.65
local parryIsBlocking = false

addToggle("Character", "Auto Parry", false, function(on)
	autoParryEnabled = on
	if on then
		if signalRemote then notify("Auto Parry ON") else notify("Signal remote not found!") end
	else
		fireBlockUnhold()
		parryIsBlocking = false
	end
end)
addSlider("Character", "Parry Hold", 0.3, 1.5, parryHoldTime, 0.05, function(v) parryHoldTime = v end)

local ATTACK_EFFECTS = {
	Normal_Sword_Slash_Effect = true,
	Normal_Punch_Effect = true,
	Combat_Swings = true,
	DoubleCut_effs = true,
	QuickDraw_effs = true,
	Air_Combo_Ground_Slam = true,
	["Regular Katana_Swings"] = true,
	Block_Break_Hit = true,
	NpcNoticeEffect = true,
}

local antiStunEnabled = false
local antiStunConns = {}

local STUN_VALUES = {Stun = true, CombatStun = true, Strict_Stun = true, RagDoll = true}

local function cleanStunValues()
	local vf = getValuesFolder(); if not vf then return end
	for _, child in vf:GetChildren() do
		if STUN_VALUES[child.Name] then
			pcall(function() child:Destroy() end)
		end
	end
end

local function setupAntiStun()
	for _, c in antiStunConns do pcall(function() c:Disconnect() end) end
	antiStunConns = {}
	local vf = getValuesFolder(); if not vf then return end
	table.insert(antiStunConns, vf.ChildAdded:Connect(function(child)
		if antiStunEnabled and STUN_VALUES[child.Name] then
			task.defer(function() pcall(function() child:Destroy() end) end)
		end
	end))
	cleanStunValues()
end

addToggle("Character", "Anti Stun", false, function(on)
	antiStunEnabled = on
	if on then
		notify("Anti Stun ON")
		setupAntiStun()
	else
		for _, c in antiStunConns do pcall(function() c:Disconnect() end) end
		antiStunConns = {}
	end
end)

task.spawn(function()
	while true do
		task.wait(0.06)
		if antiStunEnabled then
			pcall(function()
				cleanStunValues()
				local h = getHumanoid(); if not h then return end
				if h.WalkSpeed == 0 then h.WalkSpeed = 16 end
				if h.JumpPower == 0 then h.JumpPower = 50 end
				h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				if h:GetState() == Enum.HumanoidStateType.FallingDown or h:GetState() == Enum.HumanoidStateType.Ragdoll then
					h:ChangeState(Enum.HumanoidStateType.Running)
				end
			end)
		end
	end
end)

pcall(function()
	local effectsRemote = game:GetService("ReplicatedStorage").Communication.ServerAndClient.Effects.EffectsEvent.Event
	effectsRemoteGlobal = effectsRemote
	effectsRemote.OnClientEvent:Connect(function(effectName, ...)
		if antiStunEnabled and effectName == "Stunned_Effect" then
			task.spawn(function()
				cleanStunValues()
				local h = getHumanoid(); if not h then return end
				h:ChangeState(Enum.HumanoidStateType.Running)
				if h.WalkSpeed == 0 then h.WalkSpeed = 16 end
			end)
		end

		if not autoParryEnabled then return end
		if not ATTACK_EFFECTS[effectName] then return end
		if parryIsBlocking then return end
		local hrp = getHRP(); if not hrp then return end
		parryIsBlocking = true
		local pos = hrp.Position
		if signalRemote then
			signalRemote:FireServer("server_skill_controller_signaler", "Blocking", "Hold", pos)
		end
		task.delay(parryHoldTime, function()
			fireBlockUnhold()
			task.wait(0.05)
			parryIsBlocking = false
		end)
	end)
end)

addSpacer("Character")
addLabel("Character", "APPEARANCE")

addToggle("Character", "Hide Name", false, function(on)
	local h = getHumanoid(); if h then h.DisplayDistanceType = on and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer end
end)

addToggle("Character", "Ghost Mode", false, function(on)
	local c = player.Character; if not c then return end
	for _, p in c:GetDescendants() do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = on and 0.7 or 0 end end
end)

addSlider("Character", "Hip Height", 0, 50, 0, 1, function(v) local h = getHumanoid(); if h then h.HipHeight = v end end)

addSpacer("Character")
addLabel("Character", "ANIMATION")

addTextInput("Character", "Animation ID (e.g. 12345678)", function(text)
	local id = tonumber(text); if not id then notify("Invalid ID"); return end
	local h = getHumanoid(); if not h then return end
	local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://" .. id
	local ok, track = pcall(function() return h:LoadAnimation(anim) end)
	if ok and track then track:Play(); notify("Playing " .. id) end
	anim:Destroy()
end)

addButton("Character", "Stop All Animations", function()
	local h = getHumanoid(); if not h then return end
	for _, t in h:GetPlayingAnimationTracks() do t:Stop() end; notify("Stopped")
end)

addSpacer("Character")
addLabel("Character", "COMBAT")

local hitboxSize = 5
local hitboxEnabled = false
local hitboxVisuals = {}

addToggle("Character", "Hitbox Expander", false, function(on)
	hitboxEnabled = on
	if not on then
		for _, v in hitboxVisuals do pcall(function() v:Destroy() end) end
		hitboxVisuals = {}
		pcall(function()
			local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
			for _, source in sources do
				if source then
					local regions = source:FindFirstChild("Regions")
					if regions then
						for _, region in regions:GetChildren() do
							local activeNpcs = region:FindFirstChild("ActiveNpcs")
							if activeNpcs then
								for _, npcFolder in activeNpcs:GetChildren() do
									for _, mob in npcFolder:GetChildren() do
										if mob:IsA("Model") then
											local mobHRP = mob:FindFirstChild("HumanoidRootPart")
											if mobHRP then
												pcall(function()
													local orig = mobHRP:GetAttribute("_OrigSize")
													if orig then mobHRP.Size = orig end
													mobHRP.Transparency = 1
												end)
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end)
	end
end)

addSlider("Character", "Hitbox Size", 2, 25, 5, 1, function(v) hitboxSize = v end)

task.spawn(function()
	while true do
		task.wait(0.5)
		if hitboxEnabled then
			pcall(function()
				local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
				for _, source in sources do
					if source then
						local regions = source:FindFirstChild("Regions")
						if regions then
							for _, region in regions:GetChildren() do
								local activeNpcs = region:FindFirstChild("ActiveNpcs")
								if activeNpcs then
									for _, npcFolder in activeNpcs:GetChildren() do
										for _, mob in npcFolder:GetChildren() do
											if mob:IsA("Model") then
												local mobHum = mob:FindFirstChildOfClass("Humanoid")
												local mobHRP = mob:FindFirstChild("HumanoidRootPart")
												if mobHum and mobHum.Health > 0 and mobHRP then
													pcall(function()
														if not mobHRP:GetAttribute("_OrigSize") then
															mobHRP:SetAttribute("_OrigSize", mobHRP.Size)
														end
														mobHRP.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
														mobHRP.Transparency = 0.7
														local existing = mobHRP:FindFirstChild("_HitboxVisual")
														if not existing then
															existing = make("SelectionBox", {
																Name = "_HitboxVisual",
																Adornee = mobHRP,
																Color3 = RED,
																LineThickness = 0.05,
																Transparency = 0.3,
																SurfaceColor3 = RED,
																SurfaceTransparency = 0.8,
																Parent = mobHRP,
															})
															table.insert(hitboxVisuals, existing)
														end
													end)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end)
		end
	end
end)

local attackSpamEnabled = false
addToggle("Character", "Attack Spam", false, function(on)
	attackSpamEnabled = on
	if on then
		if not signalRemote then
			pcall(function()
				signalRemote = game:GetService("ReplicatedStorage").Communication.ServerAndClient.Signals.SignalEvent.Event
			end)
		end
		if signalRemote then notify("Attack Spam ON") else notify("Signal remote not found") end
	end
end)

local attackSpamCombo = 0
task.spawn(function()
	while true do
		task.wait(0.085)
		if attackSpamEnabled and signalRemote then
			pcall(function()
				attackSpamCombo = attackSpamCombo + 1
				if attackSpamCombo > 4 then attackSpamCombo = 1 end
				signalRemote:FireServer("Combat_Service", "Combat", attackSpamCombo, false, 0.085, false)
			end)
		end
	end
end)

addSpacer("Character")
addLabel("Character", "ACTIONS")

addButton("Character", "Respawn", function() local h = getHumanoid(); if h then h.Health = 0 end end)
addButton("Character", "Freeze / Unfreeze", function() local hrp = getHRP(); if hrp then hrp.Anchored = not hrp.Anchored; notify(hrp.Anchored and "Frozen" or "Unfrozen") end end)
addButton("Character", "Spin", function()
	local hrp = getHRP(); if not hrp then return end
	local av = hrp:FindFirstChild("_Spin")
	if av then av:Destroy(); notify("Spin OFF"); return end
	local spin = Instance.new("BodyAngularVelocity"); spin.Name = "_Spin"
	spin.MaxTorque = Vector3.new(0, math.huge, 0); spin.AngularVelocity = Vector3.new(0, 30, 0)
	spin.Parent = hrp; notify("Spin ON")
end)

end -- scope: character

------------------------------------------------------------
-- PLAYERS TAB
------------------------------------------------------------
do -- scope: players
local spectatingPlayer = nil

addButton("Players", "Stop Spectating", function()
	stopSpectate()
	notify("Camera reset")
end)
addButton("Players", "Refresh Player List", function() refreshPlayerList(); notify("Refreshed") end)
addSpacer("Players")

local spectateConnection = nil
local spectateCamScript = nil

local function startSpectate(target)
	stopSpectate()
	spectatingPlayer = target
	pcall(function()
		local c = player.Character
		if c then
			local camScript = c:FindFirstChild("CameraHandler") or c:FindFirstChild("CameraScript")
			if camScript then spectateCamScript = camScript; camScript.Disabled = true end
		end
	end)
	pcall(function()
		local pScripts = player:FindFirstChild("PlayerScripts")
		if pScripts then
			local camModule = pScripts:FindFirstChild("PlayerModule")
			if camModule then
				for _, desc in camModule:GetDescendants() do
					if desc.Name == "CameraModule" and desc:IsA("ModuleScript") then
						spectateCamScript = desc
					end
				end
			end
		end
	end)
	spectateConnection = RunService.RenderStepped:Connect(function()
		if not spectatingPlayer then return end
		local char = spectatingPlayer.Character
		local targetHRP = char and char:FindFirstChild("HumanoidRootPart")
		if targetHRP then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
		else
			spectatingPlayer = nil
			if spectateConnection then spectateConnection:Disconnect(); spectateConnection = nil end
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = getHumanoid()
			if spectateCamScript and spectateCamScript:IsA("LocalScript") then pcall(function() spectateCamScript.Disabled = false end) end
			spectateCamScript = nil
			notify("Target lost")
		end
	end)
end

function stopSpectate()
	spectatingPlayer = nil
	if spectateConnection then spectateConnection:Disconnect(); spectateConnection = nil end
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = getHumanoid()
	if spectateCamScript and spectateCamScript:IsA("LocalScript") then pcall(function() spectateCamScript.Disabled = false end) end
	spectateCamScript = nil
end

Players.PlayerRemoving:Connect(function(p)
	if p == spectatingPlayer then
		stopSpectate()
		notify("Spectate ended - player left")
	end
end)

local playerListHolder
orders["Players"] += 1
playerListHolder = make("Frame", {
	Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1, LayoutOrder = orders["Players"], Parent = tabPages["Players"],
}, { make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

function refreshPlayerList()
	playerListHolder:ClearAllChildren()
	make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = playerListHolder })

	make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
		Text = #Players:GetPlayers() .. " PLAYERS", TextColor3 = DIM,
		Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 0, Parent = playerListHolder,
	})

	local ord = 0
	for _, p in Players:GetPlayers() do
		ord += 1; local isLocal = p == player
		local row = make("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = BG_CARD, LayoutOrder = ord, Parent = playerListHolder }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })

		make("TextLabel", {
			Size = UDim2.new(1, -140, 0, 16), Position = UDim2.fromOffset(10, 3), BackgroundTransparency = 1,
			Text = p.DisplayName .. (isLocal and " (You)" or ""), TextColor3 = isLocal and ACCENT or WHITE,
			Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
		})

		local infoLabel = make("TextLabel", {
			Size = UDim2.new(1, -140, 0, 12), Position = UDim2.fromOffset(10, 20), BackgroundTransparency = 1,
			Text = isLocal and "@" .. p.Name or "...", TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})

		if not isLocal then
			local tpBtn = make("TextButton", {
				Size = UDim2.fromOffset(28, 22), Position = UDim2.new(1, -36, 0, 7),
				BackgroundColor3 = BORDER, AutoButtonColor = false, Text = "TP",
				TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row,
			}, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
			tpBtn.MouseEnter:Connect(function() TweenService:Create(tpBtn, TWEEN_FAST, { BackgroundColor3 = WHITE, TextColor3 = BG }):Play() end)
			tpBtn.MouseLeave:Connect(function() TweenService:Create(tpBtn, TWEEN_FAST, { BackgroundColor3 = BORDER, TextColor3 = WHITE }):Play() end)
			tpBtn.MouseButton1Click:Connect(function()
				local hrp = getHRP(); local t = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if hrp and t then hrp.CFrame = t.CFrame + Vector3.new(0, 3, 0); notify("TP -> " .. p.DisplayName) else notify("Can't TP") end
			end)

			local bringBtn = make("TextButton", {
				Size = UDim2.fromOffset(28, 22), Position = UDim2.new(1, -68, 0, 7),
				BackgroundColor3 = BORDER, AutoButtonColor = false, Text = "BR",
				TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row,
			}, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
			bringBtn.MouseEnter:Connect(function() TweenService:Create(bringBtn, TWEEN_FAST, { BackgroundColor3 = ACCENT, TextColor3 = BG }):Play() end)
			bringBtn.MouseLeave:Connect(function() TweenService:Create(bringBtn, TWEEN_FAST, { BackgroundColor3 = BORDER, TextColor3 = WHITE }):Play() end)
			bringBtn.MouseButton1Click:Connect(function()
				local hrp = getHRP(); local t = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if hrp and t then t.CFrame = hrp.CFrame + Vector3.new(0, 3, 3); notify("Brought " .. p.DisplayName .. " to you") else notify("Can't bring") end
			end)

			local specBtn = make("TextButton", {
				Size = UDim2.fromOffset(28, 22), Position = UDim2.new(1, -100, 0, 7),
				BackgroundColor3 = BORDER, AutoButtonColor = false, Text = "SP",
				TextColor3 = WHITE, Font = Enum.Font.Gotham, TextSize = 10, Parent = row,
			}, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
			specBtn.MouseButton1Click:Connect(function()
				startSpectate(p)
				notify("Spectating " .. p.DisplayName)
			end)

			task.spawn(function()
				while infoLabel.Parent and p.Parent do
					local hrp = getHRP(); local o = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					local oh = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
					if hrp and o and oh then
						infoLabel.Text = math.round((hrp.Position - o.Position).Magnitude) .. "m  |  HP " .. math.round(oh.Health) .. "/" .. math.round(oh.MaxHealth)
					else infoLabel.Text = "..." end
					task.wait(0.5)
				end
			end)
		end
	end
end

refreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(1); refreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); refreshPlayerList() end)
end -- scope: players

------------------------------------------------------------
-- TELEPORT TAB
------------------------------------------------------------
do -- scope: teleport

local MAP_REGIONS = {
	{ name = "Windy Peak", pos = Vector3.new(-448, 1241, -919) },
	{ name = "Bamboo Grove", pos = Vector3.new(621, 1017, -195) },
	{ name = "Mistfall Harbor", pos = Vector3.new(137, 874, 733) },
	{ name = "Hidden Mist Village", pos = Vector3.new(1640, 606, -125) },
	{ name = "Butterfly Estate", pos = Vector3.new(-1773, 315, -120) },
	{ name = "Iceveil Valley", pos = Vector3.new(-209, 1353, -2596) },
	{ name = "Final Selection Plains", pos = Vector3.new(-2547, 278, 32) },
}

local SPECIAL_LOCATIONS = {
	{ name = "Muzan's Lair", pos = Vector3.new(55, 832, 782) },
	{ name = "Parkour Training", pos = nil, finder = function()
		local ok, pos = pcall(function()
			local pt = workspace.Map.DetachedMaps:FindFirstChild("ParkourTraining")
			if pt then local p = pt:FindFirstChildWhichIsA("BasePart", true); if p then return p.Position end end
		end)
		return ok and pos or nil
	end },
	{ name = "Training Area", pos = nil, finder = function()
		local ok, pos = pcall(function()
			local t = workspace:FindFirstChild("Training")
			if t then local p = t:FindFirstChildWhichIsA("BasePart", true); if p then return p.Position end end
		end)
		return ok and pos or nil
	end },
	{ name = "Nearest Chest", pos = nil, finder = function()
		local hrp = getHRP(); if not hrp then return nil end
		local best, bestDist = nil, math.huge
		pcall(function()
			for _, c in workspace.Chests:GetDescendants() do
				if c:IsA("BasePart") then
					local d = (c.Position - hrp.Position).Magnitude
					if d < bestDist then bestDist = d; best = c.Position end
				end
			end
		end)
		return best
	end },
	{ name = "Spawn", pos = nil, finder = function()
		for _, d in workspace:GetDescendants() do if d:IsA("SpawnLocation") then return d.Position end end
		return Vector3.new(0, 50, 0)
	end },
}

local SHRINES = {
	{ name = "Windy Peak Shrine", pos = Vector3.new(-409, 1250, -1312) },
	{ name = "Mistfall Harbor Shrine", pos = Vector3.new(17, 968, 372) },
	{ name = "Hidden Mist Village Shrine", pos = Vector3.new(1266, 981, -482) },
	{ name = "Butterfly Estate Shrine", pos = Vector3.new(-1729, 315, 127) },
	{ name = "Frost Veil Shrine", pos = Vector3.new(142, 1385, -2783) },
}

local SEALED_CHESTS = {
	{ name = "Nearest T1 Chest", tag = "T1" },
	{ name = "Nearest T2 Chest", tag = "T2" },
	{ name = "Nearest T3 Chest", tag = "T3" },
}

local regionNames = {}; for _, r in MAP_REGIONS do table.insert(regionNames, r.name) end
local specialNames = {}; for _, s in SPECIAL_LOCATIONS do table.insert(specialNames, s.name) end
local shrineNames = {}; for _, s in SHRINES do table.insert(shrineNames, s.name) end
local chestNames = {}; for _, c in SEALED_CHESTS do table.insert(chestNames, c.name) end

addLabel("Teleport", "MAP REGIONS")
addDropdown("Teleport", "Select Region", regionNames, function(idx, name)
	local hrp = getHRP(); if not hrp then return end
	local r = MAP_REGIONS[idx]; if not r then return end
	hrp.CFrame = CFrame.new(r.pos) + Vector3.new(0, 5, 0)
	notify("TP -> " .. r.name)
end)

addSpacer("Teleport")
addLabel("Teleport", "SPECIAL LOCATIONS")
addDropdown("Teleport", "Select Location", specialNames, function(idx, name)
	local hrp = getHRP(); if not hrp then return end
	local loc = SPECIAL_LOCATIONS[idx]; if not loc then return end
	local pos = loc.pos
	if loc.finder then pos = loc.finder() end
	if pos then
		hrp.CFrame = CFrame.new(pos) + Vector3.new(0, 5, 0)
		notify("TP -> " .. loc.name)
	else
		notify(loc.name .. " not found in map")
	end
end)

addButton("Teleport", "TP: Ouwigahara Portal", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-1605, 1003, 1142) + Vector3.new(0, 5, 0)
	notify("TP -> Ouwigahara Portal")
end)

addSpacer("Teleport")
addLabel("Teleport", "SHRINE TRAVEL")
addDropdown("Teleport", "Select Shrine", shrineNames, function(idx, name)
	local hrp = getHRP(); if not hrp then return end
	local s = SHRINES[idx]; if not s then return end
	pcall(function()
		if signalRemote then signalRemote:FireServer("TravelShrine", s.name) end
	end)
	task.wait(0.5)
	hrp.CFrame = CFrame.new(s.pos + Vector3.new(0, 5, 0))
	notify("TP -> " .. s.name)
end)

addSpacer("Teleport")
addLabel("Teleport", "SEALED CHESTS")
addDropdown("Teleport", "Select Chest Tier", chestNames, function(idx, name)
	local hrp = getHRP(); if not hrp then return end
	local ct = SEALED_CHESTS[idx]; if not ct then return end
	local best, bestDist = nil, math.huge
	for _, desc in workspace:GetDescendants() do
		if desc:IsA("Model") and desc.Name:find(ct.tag) and desc.Name:lower():find("chest") then
			local root = desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChild("Root") or desc:FindFirstChildWhichIsA("BasePart", true)
			if root then
				local dist = (root.Position - hrp.Position).Magnitude
				if dist < bestDist then best = root; bestDist = dist end
			end
		end
	end
	if best then
		hrp.CFrame = CFrame.new(best.Position) + Vector3.new(0, 5, 0)
		notify("TP -> " .. ct.name .. " (" .. math.round(bestDist) .. "m)")
	else
		notify("No " .. ct.tag .. " chest found")
	end
end)

addSpacer("Teleport")
addLabel("Teleport", "QUICK TP")
addButton("Teleport", "TP Forward 50", function() local h = getHRP(); if h then h.CFrame = h.CFrame + h.CFrame.LookVector * 50 end end)
addButton("Teleport", "TP Forward 200", function() local h = getHRP(); if h then h.CFrame = h.CFrame + h.CFrame.LookVector * 200 end end)
addButton("Teleport", "TP Up 100", function() local h = getHRP(); if h then h.CFrame = h.CFrame + Vector3.new(0, 100, 0) end end)

addSpacer("Teleport")
addLabel("Teleport", "CLICK TP")

local clickTPEnabled = false
addToggle("Teleport", "Click TP", false, function(on) clickTPEnabled = on end)

local ctrlClickTP = false
addToggle("Teleport", "Ctrl+Click TP", false, function(on) ctrlClickTP = on end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	local doTP = false
	if clickTPEnabled then doTP = true end
	if ctrlClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then doTP = true end
	if not doTP then return end
	local mouse = player:GetMouse()
	local hrp = getHRP()
	if hrp and mouse.Hit then hrp.CFrame = mouse.Hit + Vector3.new(0, 5, 0) end
end)

addTextInput("Teleport", "TP to part name...", function(name)
	local hrp = getHRP(); if not hrp then return end
	local part = workspace:FindFirstChild(name, true)
	if part and part:IsA("BasePart") then hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0); notify("TP -> " .. name) else notify("Not found: " .. name) end
end)

addSpacer("Teleport")
addLabel("Teleport", "KEY NPCS")

local KEY_NPCS = {
	{ name = "Ren (Gourd Shop)", pos = Vector3.new(-1837, 314, -24) },
	{ name = "Wagasa Maker Genzo", pos = Vector3.new(-1059, 1226, -956) },
	{ name = "Stonemason Tobei", pos = Vector3.new(1876, 659, -206) },
	{ name = "Duelist Hibiki", pos = Vector3.new(-1234, 1427, -4593) },
	{ name = "Weaver Hatsu", pos = Vector3.new(2281, 813, 15) },
	{ name = "Tailor Omi", pos = Vector3.new(1827, 1616, 120) },
	{ name = "Lamplighter Isamu", pos = Vector3.new(1082, 1426, -749) },
}

local npcNames = {}; for _, n in KEY_NPCS do table.insert(npcNames, n.name) end
addDropdown("Teleport", "Select NPC", npcNames, function(idx, name)
	local hrp = getHRP(); if not hrp then return end
	local npc = KEY_NPCS[idx]; if not npc then return end
	hrp.CFrame = CFrame.new(npc.pos) + Vector3.new(0, 5, 0)
	notify("TP -> " .. npc.name)
end)

addSpacer("Teleport")
addLabel("Teleport", "WAYPOINTS")

local waypoints = {}
local waypointList

local function refreshWaypoints()
	if waypointList then waypointList:Destroy() end
	orders["Teleport"] += 1
	waypointList = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = orders["Teleport"], Parent = tabPages["Teleport"],
	}, { make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }) })
	for i, wp in waypoints do
		local row = make("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = BG_CARD, LayoutOrder = i, Parent = waypointList }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		make("TextLabel", { Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = wp.name, TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
		local goBtn = make("TextButton", { Size = UDim2.fromOffset(30, 20), Position = UDim2.new(1, -68, 0, 4), BackgroundColor3 = ACCENT_DIM, AutoButtonColor = false, Text = "Go", TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
		goBtn.MouseButton1Click:Connect(function() local hrp = getHRP(); if hrp then hrp.CFrame = wp.cf; notify("TP -> " .. wp.name) end end)
		goBtn.MouseEnter:Connect(function() TweenService:Create(goBtn, TWEEN_FAST, { BackgroundColor3 = ACCENT }):Play() end)
		goBtn.MouseLeave:Connect(function() TweenService:Create(goBtn, TWEEN_FAST, { BackgroundColor3 = ACCENT_DIM }):Play() end)
		local delBtn = make("TextButton", { Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -32, 0, 4), BackgroundColor3 = Color3.fromRGB(60, 20, 30), AutoButtonColor = false, Text = "X", TextColor3 = RED, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
		delBtn.MouseButton1Click:Connect(function() table.remove(waypoints, i); refreshWaypoints(); notify("Deleted " .. wp.name) end)
		delBtn.MouseEnter:Connect(function() TweenService:Create(delBtn, TWEEN_FAST, { BackgroundColor3 = RED }):Play() end)
		delBtn.MouseLeave:Connect(function() TweenService:Create(delBtn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(60, 20, 30) }):Play() end)
	end
	if #waypoints == 0 then make("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "No waypoints saved", TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 10, Parent = waypointList }) end
end

addTextInput("Teleport", "Type name + Enter to save waypoint", function(name)
	if name == "" then name = "WP " .. (#waypoints + 1) end
	local hrp = getHRP(); if not hrp then return end
	table.insert(waypoints, { name = name, cf = hrp.CFrame }); refreshWaypoints(); notify("Saved: " .. name)
end)

refreshWaypoints()
end -- scope: teleport

------------------------------------------------------------
-- AUTO TAB
------------------------------------------------------------
do -- scope: auto

local autoChestEnabled = false
local autoSpiderLilyEnabled = false
local autoLootDropEnabled = false
local autoCollectSpeed = 0.5

do -- collapsible: auto collect
local sec = addCollapsible("Auto", "AUTO COLLECT", false)
sec.addToggle("Auto Collect Chests", false, function(on) autoChestEnabled = on end)
sec.addToggle("Auto Collect Spider Lily", false, function(on) autoSpiderLilyEnabled = on end)
sec.addToggle("Auto Collect Loot Drops", false, function(on) autoLootDropEnabled = on end)
sec.addSlider("Collect Delay", 0.1, 2, 0.5, 0.1, function(v) autoCollectSpeed = v end)
end

addSpacer("Auto")
addLabel("Auto", "AUTO TRAINING")

local TRAININGS = {
	"Aim Training", "Boulder Push", "Boulder Split",
	"Cup Game", "Meditation", "Parkour Dungeon",
	"Pushups", "Squat Rack"
}

local function startTrainingPrompt(trainingName)
	local hrp = getHRP(); if not hrp then return false end
	local training = workspace:FindFirstChild("Training")
	if not training then return false end
	local folder = training:FindFirstChild(trainingName)
	if not folder then return false end
	local prompts = {}
	for _, desc in folder:GetDescendants() do
		if desc:IsA("ProximityPrompt") then table.insert(prompts, desc) end
	end
	if #prompts == 0 then return false end
	for _, prompt in prompts do
		local pp = prompt.Parent
		if pp and pp:IsA("BasePart") then
			hrp.CFrame = pp.CFrame + Vector3.new(0, 2, 0)
			task.wait(0.3)
		end
		for attempt = 1, 3 do
			pcall(function() fireproximityprompt(prompt) end)
			task.wait(0.2)
		end
	end
	return true
end

local function fireTrainingStop(success)
	if not signalRemote then notify("Signal remote not found"); return false end
	pcall(function()
		signalRemote:FireServer("training_signaler", "Stop", success)
	end)
	return true
end

local function fireTrainingDo()
	if not signalRemote then return end
	pcall(function()
		signalRemote:FireServer("training_signaler", "Do")
	end)
end

local function fireTrainingStateChanged(state)
	if not signalRemote then return end
	pcall(function()
		signalRemote:FireServer("training_signaler", "StateChanged", state)
	end)
end

addDropdown("Auto", "Select Training", TRAININGS, function(idx, trainingName)
	local hrp = getHRP(); if not hrp then return end
	if not signalRemote then notify("Signal remote not found"); return end
	notify("Starting " .. trainingName .. "...")
	pcall(function()
		startTrainingPrompt(trainingName)
		task.wait(2)

		if trainingName == "Boulder Split" then
			fireTrainingDo()
			task.wait(0.3)
			fireTrainingStateChanged()
			task.wait(0.5)
			fireTrainingStop(true)

		elseif trainingName == "Boulder Push" then
			fireTrainingDo()
			task.wait(0.3)
			local training = workspace:FindFirstChild("Training")
			local pushFolder = training and training:FindFirstChild("Boulder Push")
			if pushFolder then
				local goal = pushFolder:FindFirstChild("Goal") or pushFolder:FindFirstChild("WagasaGoal")
				if goal then
					local goalPart = nil
					if goal:IsA("BasePart") then goalPart = goal
					elseif goal:IsA("Model") then goalPart = goal:FindFirstChild("WagasaGoal") or goal:FindFirstChildWhichIsA("BasePart")
					end
					if goalPart then
						notify("Moving to goal...")
						fireTrainingStateChanged(true)
						task.wait(0.3)
						hrp.CFrame = goalPart.CFrame + Vector3.new(0, 2, 0)
						task.wait(0.5)
						if firetouchinterest then
							pcall(function()
								local boulders = workspace:FindFirstChild("Debree")
								if boulders then
									for _, obj in boulders:GetDescendants() do
										if obj.Name == "Boulder" and obj:IsA("BasePart") then
											firetouchinterest(obj, goalPart, 0)
											task.wait(0.1)
											firetouchinterest(obj, goalPart, 1)
										end
									end
								end
							end)
						end
						task.wait(0.5)
					end
				end
			end
			fireTrainingStop(true)

		elseif trainingName == "Meditation" then
			fireTrainingDo()
			task.wait(0.5)
			for rep = 1, 30 do
				pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
				task.wait(0.1)
			end
			task.wait(0.5)
			fireTrainingStop(true)

		elseif trainingName == "Pushups" then
			fireTrainingDo()
			task.wait(0.5)
			for rep = 1, 25 do
				pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
				task.wait(0.12)
			end
			task.wait(0.5)
			fireTrainingStop(true)

		elseif trainingName == "Squat Rack" then
			fireTrainingDo()
			task.wait(0.5)
			for rep = 1, 25 do
				pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
				task.wait(0.12)
			end
			task.wait(0.5)
			fireTrainingStop(true)

		elseif trainingName == "Aim Training" then
			fireTrainingDo()
			task.wait(0.5)
			local training = workspace:FindFirstChild("Training")
			local aimFolder = training and training:FindFirstChild("Aim Training")
			if aimFolder then
				for round = 1, 10 do
					pcall(function()
						for _, desc in aimFolder:GetDescendants() do
							if desc:IsA("BasePart") and (desc.Name:lower():find("target") or desc.Name:lower():find("dummy")) then
								if desc.Transparency < 1 then
									hrp.CFrame = CFrame.new(desc.Position + Vector3.new(0, 2, 3))
									task.wait(0.15)
									pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
								end
							end
						end
					end)
					task.wait(0.2)
				end
			else
				for rep = 1, 10 do
					pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
					task.wait(0.25)
				end
			end
			task.wait(0.3)
			fireTrainingStop(true)

		elseif trainingName == "Cup Game" then
			fireTrainingDo()
			task.wait(0.5)
			for rep = 1, 5 do
				pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
				task.wait(0.2)
			end
			task.wait(0.5)
			fireTrainingStop(true)

		elseif trainingName == "Parkour Dungeon" then
			fireTrainingDo()
			task.wait(0.5)
			local training = workspace:FindFirstChild("Training")
			local pkFolder = training and training:FindFirstChild("Parkour Dungeon")
			if pkFolder then
				local finish = pkFolder:FindFirstChild("Finish") or pkFolder:FindFirstChild("End")
				if finish then
					local finishPart = finish:IsA("BasePart") and finish or finish:FindFirstChildWhichIsA("BasePart")
					if finishPart and hrp then
						hrp.CFrame = finishPart.CFrame + Vector3.new(0, 3, 0)
						task.wait(0.5)
						if firetouchinterest then
							pcall(function()
								firetouchinterest(hrp, finishPart, 0)
								task.wait(0.1)
								firetouchinterest(hrp, finishPart, 1)
							end)
						end
					end
				end
			end
			task.wait(0.5)
			fireTrainingStop(true)

		else
			fireTrainingDo()
			task.wait(0.5)
			for rep = 1, 15 do
				pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
				task.wait(0.15)
			end
			task.wait(0.3)
			fireTrainingStop(true)
		end
		notify(trainingName .. " completed!")
	end)
end)

local openedChestPositions = {}

local function posKey(pos)
	return math.round(pos.X) .. "," .. math.round(pos.Y) .. "," .. math.round(pos.Z)
end

local NPC_ACTION_WORDS = {"chat", "purchase", "set spawn", "tame", "train"}

local function isNpcPrompt(prompt)
	local action = ""
	pcall(function() action = prompt.ActionText:lower() end)
	for _, word in NPC_ACTION_WORDS do
		if action:find(word) then return true end
	end
	local parent = prompt.Parent
	while parent and parent ~= workspace do
		local pName = parent.Name
		if pName == "Humanoids" or pName == "StationaryNpcs" or pName == "ActiveNpcs" or pName == "Regions" then return true end
		if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then return true end
		parent = parent.Parent
	end
	return false
end

local function collectLootDropsNearby(centerPos, range)
	local hrp = getHRP(); if not hrp then return 0 end
	local picked = 0
	pcall(function()
		local debree = workspace:FindFirstChild("Debree")
		local searchContainer = if debree then debree else workspace
		for _, prompt in searchContainer:GetDescendants() do
			if prompt:IsA("ProximityPrompt") and prompt.Enabled and not isNpcPrompt(prompt) then
				local part = prompt.Parent
				if not part or not part:IsA("BasePart") then
					part = prompt.Parent and prompt.Parent:FindFirstChildWhichIsA("BasePart")
				end
				if part and (part.Position - centerPos).Magnitude < range then
					local name = (part.Parent and part.Parent.Name or part.Name):lower()
					if name:find("drop") or name:find("loot") or name:find("pickup") or name:find("reward") or name:find("orb") or name:find("collectible") then
						hrp.CFrame = part.CFrame + Vector3.new(0, 1, 0)
						task.wait(0.15)
						pcall(function() fireproximityprompt(prompt) end)
						picked += 1
						task.wait(0.15)
					end
				end
			end
		end
	end)
	return picked
end

local function isNpcOrMob(obj)
	if obj:FindFirstChildOfClass("Humanoid") then return true end
	if obj:FindFirstChildWhichIsA("Humanoid", true) then return true end
	local parent = obj.Parent
	while parent and parent ~= workspace do
		local pName = parent.Name
		if pName == "Humanoids" or pName == "StationaryNpcs" or pName == "ActiveNpcs" then return true end
		if parent:FindFirstChildOfClass("Humanoid") then return true end
		parent = parent.Parent
	end
	return false
end

local CHEST_NAME_KEYWORDS = {"chest", "crate", "box", "treasure", "reward", "barrel", "supply"}

local function looksLikeChest(name)
	local lower = name:lower()
	for _, kw in CHEST_NAME_KEYWORDS do
		if lower:find(kw) then return true end
	end
	return false
end

local function findChestsWithPrompts(container)
	local chests = {}
	if not container then return chests end
	for _, obj in container:GetChildren() do
		if obj:IsA("BasePart") then
			local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
			if prompt and prompt.Enabled then
				local key = posKey(obj.Position)
				if not openedChestPositions[key] then
					table.insert(chests, {model = obj, part = obj, prompt = prompt, key = key})
				end
			end
		elseif obj:IsA("Model") and not isNpcOrMob(obj) then
			local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt and prompt.Enabled then
				local part = obj:FindFirstChildWhichIsA("BasePart")
				if part then
					local key = posKey(part.Position)
					if not openedChestPositions[key] then
						table.insert(chests, {model = obj, part = part, prompt = prompt, key = key})
					end
				end
			end
		end
	end
	return chests
end

local function collectNearbyChests()
	local hrp = getHRP(); if not hrp then return end
	local savedCF = hrp.CFrame
	local collected = 0

	local allChests = findChestsWithPrompts(workspace:FindFirstChild("Chests"))

	for _, chest in allChests do
		if not autoChestEnabled then break end
		local dist = (chest.part.Position - savedCF.Position).Magnitude
		if dist <= 200 then
			openedChestPositions[chest.key] = os.clock()
			hrp.CFrame = chest.part.CFrame + Vector3.new(0, 3, 0)
			task.wait(0.3)
			pcall(function() fireproximityprompt(chest.prompt) end)
			task.wait(1)
			collected += 1
		end
	end

	if autoChestEnabled and collected > 0 then
		hrp.CFrame = savedCF
		notify("Opened " .. collected .. " chest(s)")
	end

	for key, t in openedChestPositions do
		if os.clock() - t > 120 then
			openedChestPositions[key] = nil
		end
	end
end

task.spawn(function()
	while true do
		task.wait(autoCollectSpeed + 1)
		if autoChestEnabled then pcall(collectNearbyChests) end
	end
end)

task.spawn(function()
	while true do
		task.wait(2)
		if autoSpiderLilyEnabled then
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				local debree = workspace:FindFirstChild("Debree")
				local searchIn = if debree then debree:GetDescendants() else {}
				for _, obj in searchIn do
					if not autoSpiderLilyEnabled then break end
					if (obj.Name == "SpiderLily" or obj.Name == "Spider Lily") then
						local part = obj
						if obj:IsA("Model") then part = obj:FindFirstChildWhichIsA("BasePart") end
						if part and part:IsA("BasePart") then
							hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
							task.wait(autoCollectSpeed)
							local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
							if prompt then pcall(function() fireproximityprompt(prompt) end) end
							local click = obj:FindFirstChildWhichIsA("ClickDetector", true)
							if click then pcall(function() fireclickdetector(click) end) end
							pcall(function()
								if firetouchinterest then
									firetouchinterest(hrp, part, 0)
									task.wait(0.1)
									firetouchinterest(hrp, part, 1)
								end
							end)
						end
					end
				end
			end)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(1.5)
		if autoLootDropEnabled then
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				collectLootDropsNearby(hrp.Position, 200)
			end)
		end
	end
end)

local autoFarmEnabled = false
local autoFarmTarget = "All"
local autoFarmRange = 200
local autoFarmLastPos = nil
local autoFarmHoverHeight = 5
local autoFarmAttackStyle = "top"
local autoFarmSideDistance = 6
local autoFarmWeapon = "Combat"
local autoFarmWeaponSlot = 1

local MOB_TYPES = {
	"All",
	"Bear Cub", "Hoyuzo", "Hoyuzo Subordinate", "Kaiden", "Kaiden Subordinate", "Mother Bear",
	"Greater Demon", "Lesser Demon",
	"Fujiko", "Mizunoe Demon Slayer",
	"Fire Profound Demon", "Ice Profound Demon", "High Demon", "Kanoe Demon Slayer",
	"Beast Born Demon", "Blood Hounded Demon", "Civilian", "Mizunoto",
	"Bandit", "Zuko",
	"Akazo", "Datai", "Domae", "Enru", "Flame Trainee", "Giyen", "Gyorei", "Gyutai",
	"Insect Trainee", "Nezura", "Obari", "Reaper", "Reaper Trainee Kuzan", "Rengu",
	"Saneri", "Serpent Trainee", "Shinora", "Soryu Trainee Goki", "Sound Trainee",
	"Stone Trainee", "Sumari", "Tai Chi Trainee Suzume", "Tengai", "Thunder Trainee",
	"Water Trainee Sabito", "Wind Trainee", "Yahari", "Zentaro",
	"Cache Lancer", "Cache Prowler", "Grove Raider", "Lancer Captain", "Prowler Captain", "Raid Captain",
}

local BOSS_TYPES = {
	"All Bosses",
	"Hoyuzo", "Kaiden", "Mother Bear", "Zuko", "Fujiko",
	"Hoyuzo Subordinate", "Kaiden Subordinate",
	"Lancer Captain", "Prowler Captain", "Raid Captain",
	"Akazo", "Gyutai", "Reaper",
}

local stopFarmHold
local comboCounter = 0

local autoBossFarmEnabled = false
local autoBossFarmTarget = "All Bosses"

do -- collapsible: boss farming
local bossSec = addCollapsible("Auto", "BOSS FARMING", false)

bossSec.addToggle("Auto Farm Bosses", false, function(on)
	autoBossFarmEnabled = on
	autoFarmEnabled = on
	if not on then
		comboCounter = 0
		stopFarmHold()
	end
end)
bossSec.addSlider("Boss Range", 50, 2000, 500, 50, function(v) autoFarmRange = v end)
bossSec.addDropdown("Target Boss", BOSS_TYPES, function(idx, name)
	autoBossFarmTarget = name
	if name == "All Bosses" then
		autoFarmTarget = "All"
	else
		autoFarmTarget = name
	end
	notify("Boss Target: " .. name)
end)
end -- collapsible: boss farming

do -- collapsible: mob farming
local farmSec = addCollapsible("Auto", "MOB FARMING", false)

farmSec.addToggle("Auto Farm Mobs", false, function(on)
	autoFarmEnabled = on
	if not on then
		comboCounter = 0
		stopFarmHold()
	end
end)
farmSec.addSlider("Farm Range", 50, 1000, 200, 50, function(v) autoFarmRange = v end)

farmSec.addDropdown("Target Mob", MOB_TYPES, function(idx, name)
	autoFarmTarget = name
	notify("Targeting: " .. name)
end)

farmSec.addLabel("Attack Style")
farmSec.addButton("Attack: Top (Above)", function()
	autoFarmAttackStyle = "top"
	notify("Attack from above")
end)
farmSec.addButton("Attack: Ground (Side)", function()
	autoFarmAttackStyle = "ground"
	notify("Attack from ground level")
end)
farmSec.addSlider("Hover Height (Top)", 0, 50, 5, 1, function(v) autoFarmHoverHeight = v end)
farmSec.addSlider("Side Distance (Ground)", 1, 20, 6, 1, function(v) autoFarmSideDistance = v end)

farmSec.addLabel("Weapon")
farmSec.addTextInput("Type weapon name...", function(text)
	if text == "" then return end
	autoFarmWeapon = text
	notify("Weapon: " .. autoFarmWeapon)
end)
farmSec.addButton("Weapon: Combat (Fists)", function()
	autoFarmWeapon = "Combat"; autoFarmWeaponSlot = 1
	notify("Weapon: Combat")
end)
farmSec.addButton("Weapon: Regular Katana", function()
	autoFarmWeapon = "Regular Katana"; autoFarmWeaponSlot = 1
	notify("Weapon: Regular Katana")
end)
farmSec.addSlider("Weapon Slot", 1, 9, 1, 1, function(v)
	autoFarmWeaponSlot = v
end)
end -- collapsible: mob farming

local function findSpawnedMob(npcFolder)
	for _, child in npcFolder:GetChildren() do
		if child:IsA("Model") then
			local hum = child:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then return child, hum end
		end
	end
	return nil, nil
end

local function isValidFarmTarget(npcName)
	if autoBossFarmEnabled and autoBossFarmTarget == "All Bosses" then
		for _, bossName in BOSS_TYPES do
			if bossName ~= "All Bosses" and npcName == bossName then return true end
		end
		return false
	end
	return autoFarmTarget == "All" or npcName == autoFarmTarget
end

local function searchRegionsForMobs(regionsFolder, hrp, closest, closestDist, closestModel)
	if not regionsFolder then return closest, closestDist, closestModel end
	for _, region in regionsFolder:GetChildren() do
		local activeNpcs = region:FindFirstChild("ActiveNpcs")
		if activeNpcs then
			for _, npc in activeNpcs:GetChildren() do
				if isValidFarmTarget(npc.Name) then
					local mobModel, mobHum = findSpawnedMob(npc)
					if mobModel and mobHum then
						local mobHRP = mobModel:FindFirstChild("HumanoidRootPart")
						if mobHRP then
							local dist = (mobHRP.Position - hrp.Position).Magnitude
							if dist < closestDist then
								closestDist = dist
								closest = npc
								closestModel = mobModel
							end
						end
					end
				end
			end
		end
	end
	return closest, closestDist, closestModel
end

local function findNearestMob()
	local hrp = getHRP(); if not hrp then return nil, nil end
	local closest, closestDist, closestModel = nil, autoFarmRange, nil
	pcall(function()
		local humanoids = workspace:FindFirstChild("Humanoids")
		if humanoids then
			local regions = humanoids:FindFirstChild("Regions")
			closest, closestDist, closestModel = searchRegionsForMobs(regions, hrp, closest, closestDist, closestModel)
		end
		local debree = workspace:FindFirstChild("Debree")
		if debree then
			local regions2 = debree:FindFirstChild("Regions")
			closest, closestDist, closestModel = searchRegionsForMobs(regions2, hrp, closest, closestDist, closestModel)
		end
	end)
	return closest, closestModel
end

local VIM = nil
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local lastAttackTime = 0

local WEAPON_TIMINGS = {
	Combat = {default = 0.12, finals = {4}, final_cd = 0.15},
	["Regular Katana"] = {default = 0.12, finals = {4}, final_cd = 0.15},
	["Insect Katana"] = {default = 0.12, finals = {4}, final_cd = 0.15},
	["Sound Katanas"] = {default = 0.12, finals = {4}, final_cd = 0.15},
	Scythe = {default = 0.12, finals = {4}, final_cd = 0.15},
	Gauntlet = {default = 0.12, finals = {4}, final_cd = 0.15},
	Spear = {default = 0.12, finals = {4}, final_cd = 0.15},
	Sickles = {default = 0.12, finals = {4}, final_cd = 0.15},
	Claws = {default = 0.14, finals = {4}, final_cd = 0.15},
}

local function getSwingDelay()
	local timing = WEAPON_TIMINGS[autoFarmWeapon]
	if not timing then timing = WEAPON_TIMINGS.Combat end
	local isFinal = false
	for _, f in timing.finals do
		if comboCounter == f then isFinal = true; break end
	end
	if isFinal then return timing.final_cd end
	return timing.default
end

local function equipWeapon(slot)
	if signalRemote then
		pcall(function() signalRemote:FireServer("Item_Equip", slot) end)
	end
end

local function fireAttack()
	local now = os.clock()
	local delay = getSwingDelay()
	if now - lastAttackTime < delay then return end

	equipWeapon(autoFarmWeaponSlot)

	comboCounter = comboCounter + 1
	if comboCounter > 4 then comboCounter = 1 end

	if signalRemote then
		pcall(function()
			signalRemote:FireServer("Combat_Service", "Combat", comboCounter, false, 0.085, false)
		end)
	end

	lastAttackTime = now
end

local killAuraEnabled = false
local killAuraRange = 50

addSpacer("Auto")
addLabel("Auto", "KILL AURA")
addToggle("Auto", "Kill Aura", false, function(on)
	killAuraEnabled = on
	if on then notify("Kill Aura ON") else notify("Kill Aura OFF") end
end)
addSlider("Auto", "Aura Range", 10, 200, 50, 10, function(v) killAuraRange = v end)

task.spawn(function()
	while true do
		task.wait(0.2)
		if killAuraEnabled then
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				local hum = getHumanoid(); if not hum or hum.Health <= 0 then return end
				local nearestHRP = nil
				local nearestDist = killAuraRange
				local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
				for _, source in sources do
					if source then
						local regions = source:FindFirstChild("Regions")
						if regions then
							for _, region in regions:GetChildren() do
								local activeNpcs = region:FindFirstChild("ActiveNpcs")
								if activeNpcs then
									for _, npcFolder in activeNpcs:GetChildren() do
										for _, child in npcFolder:GetChildren() do
											if child:IsA("Model") then
												local mobHum = child:FindFirstChildOfClass("Humanoid")
												local mobHRP = child:FindFirstChild("HumanoidRootPart")
												if mobHum and mobHum.Health > 0 and mobHRP then
													local dist = (mobHRP.Position - hrp.Position).Magnitude
													if dist < nearestDist then
														nearestDist = dist
														nearestHRP = mobHRP
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
				if nearestHRP then
					hrp.CFrame = CFrame.lookAt(hrp.Position, nearestHRP.Position)
					fireAttack()
				end
			end)
		end
	end
end)

player.CharacterAdded:Connect(function(char)
	if autoFarmEnabled and autoFarmLastPos then
		task.wait(2)
		local hrp = getHRP()
		if hrp then
			hrp.CFrame = autoFarmLastPos
			notify("Respawned - resuming farm")
		end
	end
end)

local function getAttackPosition(mobPos, hrp)
	if autoFarmAttackStyle == "top" then
		return Vector3.new(mobPos.X, mobPos.Y + autoFarmHoverHeight, mobPos.Z)
	else
		local dir = hrp.Position - mobPos
		dir = Vector3.new(dir.X, 0, dir.Z)
		local mag = dir.Magnitude
		if mag < 0.1 then dir = Vector3.new(1, 0, 0) else dir = dir / mag end
		local sidePos = mobPos + dir * autoFarmSideDistance
		return Vector3.new(sidePos.X, mobPos.Y, sidePos.Z)
	end
end

local function getAttackCFrame(mobPos, hrp)
	local pos = getAttackPosition(mobPos, hrp)
	if autoFarmAttackStyle == "top" then
		return CFrame.new(pos) * CFrame.Angles(-math.rad(90), 0, 0)
	else
		return CFrame.lookAt(pos, mobPos)
	end
end

local farmBP, farmBG
local lastFarmTarget = Vector3.zero

local function startFarmHold(hrp, targetPos, mobPos)
	if not farmBP or farmBP.Parent ~= hrp then
		if farmBP then farmBP:Destroy() end
		farmBP = Instance.new("BodyPosition")
		farmBP.MaxForce = Vector3.new(50000, 50000, 50000)
		farmBP.D = 1000
		farmBP.P = 10000
		farmBP.Parent = hrp
	end
	if not farmBG or farmBG.Parent ~= hrp then
		if farmBG then farmBG:Destroy() end
		farmBG = Instance.new("BodyGyro")
		farmBG.MaxTorque = Vector3.one * 50000
		farmBG.D = 300
		farmBG.P = 10000
		farmBG.Parent = hrp
	end
	farmBP.Position = targetPos
	if autoFarmAttackStyle == "top" then
		farmBG.CFrame = CFrame.new(targetPos) * CFrame.Angles(-math.rad(90), 0, 0)
	else
		farmBG.CFrame = CFrame.lookAt(targetPos, mobPos)
	end
end

function stopFarmHold()
	if farmBP then farmBP:Destroy(); farmBP = nil end
	if farmBG then farmBG:Destroy(); farmBG = nil end
	pcall(function() local h = getHumanoid(); if h then h.PlatformStand = false end end)
end

task.spawn(function()
	local lockedMob = nil
	local lockedMobHRP = nil
	while true do
		task.wait(0.1)
		if autoFarmEnabled then
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				local hum = getHumanoid(); if not hum or hum.Health <= 0 then stopFarmHold(); lockedMob = nil; return end

				local mobAlive = false
				if lockedMob then
					pcall(function()
						local mhum = lockedMob:FindFirstChildOfClass("Humanoid")
						local mhrp = lockedMob:FindFirstChild("HumanoidRootPart")
						if mhum and mhum.Health > 0 and mhrp and lockedMob.Parent then
							mobAlive = true
							lockedMobHRP = mhrp
						end
					end)
				end
				if not mobAlive then
					if lockedMob then
						stopFarmHold()
						pcall(function() hum.PlatformStand = false end)
						task.wait(1.2)
						pcall(function()
							for _, obj in workspace:GetDescendants() do
								if obj:IsA("ProximityPrompt") then
									local par = obj.Parent
									if par and par:IsA("BasePart") then
										local dist = (par.Position - hrp.Position).Magnitude
										if dist < 30 then
											pcall(function() fireproximityprompt(obj) end)
										end
									end
								end
							end
						end)
						task.wait(0.3)
					end
					lockedMob = nil
					lockedMobHRP = nil
					local _, mobModel = findNearestMob()
					if mobModel then
						lockedMob = mobModel
						lockedMobHRP = mobModel:FindFirstChild("HumanoidRootPart")
						comboCounter = 0
						if lockedMobHRP then
							hum.PlatformStand = true
							local mobPos = lockedMobHRP.Position
							hrp.CFrame = getAttackCFrame(mobPos, hrp)
							task.wait()
							startFarmHold(hrp, getAttackPosition(mobPos, hrp), mobPos)
						end
					end
				end

				if lockedMob and lockedMobHRP then
					hum.PlatformStand = true
					local mobPos = lockedMobHRP.Position
					local targetPos = getAttackPosition(mobPos, hrp)
					startFarmHold(hrp, targetPos, mobPos)
					fireAttack()
				else
					stopFarmHold()
					comboCounter = 0
				end
			end)
		else
			if farmBP or farmBG then stopFarmHold() end
			if lockedMob then lockedMob = nil; lockedMobHRP = nil end
		end
	end
end)

addSpacer("Auto")
addLabel("Auto", "HORSE")

local autoTameHorseEnabled = false
local horseTameInProgress = false
addToggle("Auto", "Auto Tame Horse", false, function(on) autoTameHorseEnabled = on end)

task.spawn(function()
	while true do
		task.wait(0.5)
		if autoTameHorseEnabled and not horseTameInProgress then
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				local horseModel = nil
				pcall(function()
					for _, source in {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")} do
						if not horseModel and source then
							local regions = source:FindFirstChild("Regions")
							if regions then
								for _, region in regions:GetChildren() do
									if horseModel then break end
									local activeNpcs = region:FindFirstChild("ActiveNpcs")
									if activeNpcs then
										for _, npcFolder in activeNpcs:GetChildren() do
											if npcFolder.Name == "Horse" then
												for _, child in npcFolder:GetChildren() do
													if child:IsA("Model") then
														local hum = child:FindFirstChildOfClass("Humanoid")
														if hum and hum.Health > 0 then horseModel = child; break end
													end
												end
												if horseModel then break end
											end
										end
									end
								end
							end
						end
					end
				end)
				if horseModel then
					horseTameInProgress = true
					local horseHRP = horseModel:FindFirstChild("HumanoidRootPart")
					if horseHRP then
						hrp.CFrame = horseHRP.CFrame + Vector3.new(0, 3, 0)
						task.wait(0.5)
					end
					for _, desc in horseModel:GetDescendants() do
						if desc:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(desc) end) end
					end
					notify("Mounted horse, completing taming...")
					task.wait(1.5)
					pcall(function()
						if signalRemote then
							signalRemote:FireServer("training_signaler", "Stop", true)
						end
					end)
					task.wait(1)
					pcall(function()
						local misc = player.PlayerGui:FindFirstChild("Misc")
						if misc then
							for _, desc in misc:GetDescendants() do
								if desc:IsA("TextButton") or desc:IsA("ImageButton") then
									if desc.Visible and (desc.Text == "Yes" or desc.Name == "Yes") then
										pcall(function() desc.Activated:Fire() end)
									end
								end
							end
						end
					end)
					task.wait(2)
					horseTameInProgress = false
					notify("Horse taming attempt complete")
				end
			end)
		end
	end
end)

addSpacer("Auto")
addLabel("Auto", "QUESTS")

local autoDialogueEnabled = false
local autoQuestFarmEnabled = false
local activeQuestData = nil
local currentQuestName = ""

addToggle("Auto", "Auto Skip Dialogue", false, function(on)
	autoDialogueEnabled = on
	if on then notify("Auto dialogue skip enabled") end
end)

orders["Auto"] += 1
local questNameLabel = make("TextLabel", {
	Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
	Text = "Quest: (none)", TextColor3 = ACCENT, Font = Enum.Font.GothamBold, TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = orders["Auto"], Parent = tabPages["Auto"],
})

orders["Auto"] += 1
local questStatusLabel = make("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
	Text = "", TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = orders["Auto"], Parent = tabPages["Auto"],
})

local function getQuestHolder()
	local ps = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Service")
	if not ps then return nil end
	local data = ps:FindFirstChild("Data")
	if not data then return nil end
	local pData = data:FindFirstChild(player.Name)
	if not pData then return nil end
	local slotNum = 1
	pcall(function()
		local se = pData:FindFirstChild("slotEquipped")
		if se then slotNum = se.Value end
	end)
	local slot = pData:FindFirstChild("slots")
	if not slot then return nil end
	local activeSlot = slot:FindFirstChild("Slot" .. slotNum)
	if not activeSlot then return nil end
	local quests = activeSlot:FindFirstChild("Quests")
	if not quests then return nil end
	return quests:FindFirstChild("Holder")
end

local function hasQuest(questName)
	local holder = getQuestHolder()
	if not holder then return false end
	for _, child in holder:GetChildren() do
		local qs = child:FindFirstChild("QuestString")
		if qs and qs.Value == questName then return true end
	end
	return false
end

local function acceptQuest(questName)
	if not signalRemote then return false end
	if hasQuest(questName) then return true end
	for attempt = 1, 8 do
		pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
		task.wait(0.1)
		pcall(function() signalRemote:FireServer("AddQuest", questName) end)
		task.wait(0.2)
		pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
		task.wait(0.4)
		if hasQuest(questName) then
			notify("Quest accepted: " .. questName)
			return true
		end
		if attempt <= 3 then
			pcall(function() signalRemote:FireServer("NpcTalking", "Started") end)
			task.wait(0.2)
		end
	end
	return false
end

local function findNearestQuestMob(mobCode, searchRange, mobCenter)
	local hrp = getHRP(); if not hrp then return nil end
	local best, bestDist = nil, searchRange or 500
	local codeLower = mobCode:lower()
	pcall(function()
		local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
		for _, source in sources do
			if source then
				local regions = source:FindFirstChild("Regions")
				if regions then
					for _, region in regions:GetChildren() do
						local activeNpcs = region:FindFirstChild("ActiveNpcs")
						if activeNpcs then
							for _, npcFolder in activeNpcs:GetChildren() do
								local folderLower = npcFolder.Name:lower()
								if folderLower == codeLower or folderLower:find(codeLower) then
									for _, child in npcFolder:GetChildren() do
										if child:IsA("Model") then
											local hum = child:FindFirstChildOfClass("Humanoid")
											local root = child:FindFirstChild("HumanoidRootPart")
											if hum and hum.Health > 0 and root then
												local dist = (root.Position - hrp.Position).Magnitude
												if dist < bestDist then best = child; bestDist = dist end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end)
	return best
end

local KNOWN_QUESTS = {
	{ name = "Ill take 3 bandits", npc = "Krue", npcPos = Vector3.new(-425, 1244, -952), qtype = "kill", mobCode = "KaruVillageBandit", mobCount = 3, mobCenter = Vector3.new(-297, 1224, -1022), task = "Kill 3 Bandits" },
	{ name = "Ill take the bandit boss(Lv 7)", npc = "Krue", npcPos = Vector3.new(-425, 1244, -952), qtype = "kill", mobCode = "Zuko", mobCount = 1, mobCenter = Vector3.new(-283, 1224, -1032), task = "Kill Bandit Boss Zuko" },
	{ name = "Ill help clear them out", npc = "Kazu", npcPos = Vector3.new(-626, 1243, -1138), qtype = "kill", mobCode = "VillageSpy", mobCount = 4, mobCenter = Vector3.new(-590, 1243, -1031), task = "Kill 4 Village Spies" },
	{ name = "Ill bring him the notes", npc = "Kazu", npcPos = Vector3.new(-626, 1243, -1138), qtype = "deliver", deliverTo = "Noote", deliverPos = Vector3.new(-516, 1243, -1251), task = "Deliver notes to Noote" },
	{ name = "Ill get this letter delivered", npc = "Noote", npcPos = Vector3.new(-516, 1243, -1251), qtype = "deliver", deliverTo = "Chaka", deliverPos = Vector3.new(471, 1146, -1260), task = "Deliver letter to Chaka" },
	{ name = "Ill deliver the package", npc = "MoldySugar", npcPos = Vector3.new(-702, 1243, -983), qtype = "deliver", deliverTo = "Elara", deliverPos = Vector3.new(428, 941, 507), task = "Deliver package to Elara" },
	{ name = "Ill restock the pantry(Lv 10)", npc = "Lucy", npcPos = Vector3.new(-615, 1259, -1177), qtype = "deliver", deliverTo = "Tom", deliverPos = Vector3.new(507, 1121, -970), returnTo = "Lucy", returnPos = Vector3.new(-615, 1259, -1177), task = "Get Bear Meat from Tom, return to Lucy" },
	{ name = "Ill find the pages", npc = "Kona", npcPos = Vector3.new(-792, 1260, -1131), qtype = "collect", mobCenter = Vector3.new(-600, 1243, -1100), task = "Collect 5 Lost Pages around village" },
	{ name = "Ill drive the bears back(Lv 10)", npc = "Tom", npcPos = Vector3.new(507, 1121, -970), qtype = "kill", mobCode = "BearCub", mobCount = 4, mobCenter = Vector3.new(541, 1121, -1024), task = "Kill 4 Bear Cubs" },
	{ name = "Ill fell the Mother Bear(Lv 18)", npc = "Tom", npcPos = Vector3.new(507, 1121, -970), qtype = "kill", mobCode = "MotherBear", mobCount = 1, mobCenter = Vector3.new(541, 1121, -1024), task = "Kill Mother Bear" },
	{ name = "Ill look for it(Lv 10)", npc = "Betty", npcPos = Vector3.new(714, 1121, -808), qtype = "collect", mobCenter = Vector3.new(683, 973, -504), task = "Find Gemstone in the river" },
	{ name = "Ill look for the penny(Lv 14)", npc = "Liv", npcPos = Vector3.new(657, 1019, 140), qtype = "collect", mobCenter = Vector3.new(555, 1011, -215), task = "Find the Lucky Penny" },
	{ name = "Ill find the coins(Lv 21)", npc = "Liv", npcPos = Vector3.new(657, 1019, 140), qtype = "collect", mobCenter = Vector3.new(675, 1019, 134), task = "Collect 500 Pennies" },
	{ name = "Ill clear out his subordinates(Lv 26)", npc = "Chaka", npcPos = Vector3.new(471, 1146, -1260), qtype = "kill", mobCode = "KaidenSub", mobCount = 4, mobCenter = Vector3.new(586, 1147, -1315), task = "Kill 4 Kaiden Subordinates" },
	{ name = "Ill deal with Kaiden(Lv 34)", npc = "Chaka", npcPos = Vector3.new(471, 1146, -1260), qtype = "kill", mobCode = "Kaiden", mobCount = 1, mobCenter = Vector3.new(586, 1147, -1315), task = "Kill Boss Kaiden" },
	{ name = "I will clear out his guards(Lv 40)", npc = "Wagwan", npcPos = Vector3.new(724, 1019, -802), qtype = "kill", mobCode = "HoyuzoSub", mobCount = 4, mobCenter = Vector3.new(533, 1001, -1357), task = "Kill 4 Hoyuzo Guards" },
	{ name = "I will take care of Hoyuzo(Lv 50)", npc = "Wagwan", npcPos = Vector3.new(724, 1019, -802), qtype = "kill", mobCode = "Hoyuzo", mobCount = 1, mobCenter = Vector3.new(747, 1001, -1413), task = "Kill Boss Hoyuzo" },
	{ name = "Ill drive them off(Lv 47)", npc = "Rin", npcPos = Vector3.new(432, 1018, 73), qtype = "kill", mobCode = "BeastBornDemon_MistfallHarbor", mobCount = 5, mobCenter = Vector3.new(171, 889, 604), task = "Kill 5 Beast Born Demons (night)" },
	{ name = "Ill find the jewelry box(Lv 45)", npc = "Ginzo", npcPos = Vector3.new(274, 942, 528), qtype = "collect", mobCenter = Vector3.new(1869, 688, -735), returnTo = "Ginzo", returnPos = Vector3.new(274, 942, 528), task = "Find Jewelry Box in Hidden Mist, return to Ginzo" },
	{ name = "Ill find the permit stamp(Lv 45)", npc = "Sofen", npcPos = Vector3.new(-161, 796, 703), qtype = "collect", mobCenter = Vector3.new(-450, 800, 750), returnTo = "Sofen", returnPos = Vector3.new(-161, 796, 703), task = "Find Permit Stamp near docks, return to Sofen" },
	{ name = "Ill fill your crates(Lv 45)", npc = "Angler Runo", npcPos = Vector3.new(-561, 796, 684), qtype = "deposit", mobCenter = Vector3.new(-574, 800, 682), task = "Deposit 2 each: OuwFish, Sea Horse, Coral, OuwFwesh" },
	{ name = "Ill land the good catch(Lv 60)", npc = "Angler Runo", npcPos = Vector3.new(-561, 796, 684), qtype = "deposit", mobCenter = Vector3.new(-574, 800, 682), task = "Deposit 3 each fish + Clown/Zebra Fish" },
	{ name = "Ill eliminate the Mizunoto(Lv 62)", npc = "Shady Individual", npcPos = Vector3.new(-773, 965, -9), qtype = "kill", mobCode = "Mizunoto_MistfallHarbor", mobCount = 5, mobCenter = Vector3.new(-834, 964, -75), returnTo = "Shady Individual", returnPos = Vector3.new(-773, 965, -9), task = "Kill 5 Mizunoto, collect Broken Nichirin Katanas (Demon)" },
	{ name = "Ill clear the cave(Lv 62)", npc = "Jugg", npcPos = Vector3.new(488, 874, 1008), qtype = "kill", mobCode = "BloodHoundedDemon_MistfallHarbor", mobCount = 7, mobCenter = Vector3.new(789, 830, 927), task = "Kill 7 Blood Hounded Demons (Slayer)" },
	{ name = "Ill find the forge(Lv 65)", npc = "Blacksmith Togane", npcPos = Vector3.new(1732, 694, -765), qtype = "collect", mobCenter = Vector3.new(-1606, 1014, 1143), task = "Find portal to Ouwigahara forge" },
	{ name = "Ill deliver the supply box(Lv 70)", npc = "Niko", npcPos = Vector3.new(-1729, 315, 127), qtype = "deliver", deliverTo = "Shiori", deliverPos = Vector3.new(-1814, 312, -101), returnTo = "Niko", returnPos = Vector3.new(-1729, 315, 127), task = "Deliver supply box to Shiori, return to Niko" },
	{ name = "Ill restock the infirmary(Lv 70)", npc = "Shiori", npcPos = Vector3.new(-1814, 312, -101), qtype = "deposit", mobCenter = Vector3.new(-1848, 315, -120), task = "Deposit 10ea Health/HealthRegen/StaminaRegen Elixir" },
	{ name = "Ill look for your blade(Lv 75)", npc = "Ren", npcPos = Vector3.new(-1795, 312, -85), qtype = "collect", mobCenter = Vector3.new(-1040, 214, 588), returnTo = "Ren", returnPos = Vector3.new(-1795, 312, -85), task = "Find Nichirin Blade, return to Ren" },
	{ name = "Ill stock the reserves(Lv 75)", npc = "Shiori", npcPos = Vector3.new(-1814, 312, -101), qtype = "deposit", mobCenter = Vector3.new(-1848, 315, -120), task = "Deposit 9 each Golden/Clown/Zebra Fish" },
	{ name = "Ill thin them out(Lv 75)", npc = "Demon Slayer Goro", npcPos = Vector3.new(-872, 235, 318), qtype = "kill", mobCode = "LesserDemon_ButterflyEstate", mobCount = 6, mobCenter = Vector3.new(-676, 230, 397), task = "Kill 6 Lesser Demons (cave floor)" },
	{ name = "Ill go up after the greater ones(Lv 83)", npc = "Demon Slayer Goro", npcPos = Vector3.new(-872, 235, 318), qtype = "kill", mobCode = "GreaterDemon_ButterflyEstate", mobCount = 7, mobCenter = Vector3.new(-499, 285, 529), task = "Kill 7 Greater Demons (cave ledges)" },
	{ name = "Ill help you defeat them(Lv 90)", npc = "Wounded Slayer Tomoi", npcPos = Vector3.new(485, 1223, -1813), qtype = "kill", mobCode = "HighDemon", mobCount = 8, mobCenter = Vector3.new(388, 1254, -1927), task = "Kill 8 High Demons" },
	{ name = "Theyre not welcome here(Lv 90)", npc = "Demon Delroy", npcPos = Vector3.new(140, 1254, -1911), qtype = "kill", mobCode = "KanoeDemonSlayer", mobCount = 8, mobCenter = Vector3.new(284, 1302, -2041), task = "Kill 8 Kanoe Demon Slayers (Demon)" },
	{ name = "Ill help you survive the winter(Lv 100)", npc = "Iceveil Guard Shiro", npcPos = Vector3.new(-107, 1349, -2499), qtype = "deposit", mobCenter = Vector3.new(-114, 1354, -2521), task = "Deposit 9 Cooked Bear Meat + 25 Health Elixir" },
	{ name = "Ill fill the winter stores(Lv 105)", npc = "Iceveil Guard Shiro", npcPos = Vector3.new(-107, 1349, -2499), qtype = "deposit", mobCenter = Vector3.new(-114, 1354, -2521), task = "Deposit 12 each Golden/Clown/Zebra Fish + 2 Crustadon/Krathulon" },
	{ name = "Ill drive back the frost(Lv 105)", npc = "Demon Slayer Mitsu", npcPos = Vector3.new(-824, 1382, -2538), qtype = "kill", mobCode = "IceProfoundDemon", mobCount = 9, mobCenter = Vector3.new(-919, 1382, -2447), task = "Kill 9 Ice Profound Demons" },
	{ name = "Ill put out the blaze(Lv 115)", npc = "Demon Slayer Mitsu", npcPos = Vector3.new(-824, 1382, -2538), qtype = "kill", mobCode = "FireProfoundDemon", mobCount = 8, mobCenter = Vector3.new(-916, 1374, -2430), task = "Kill 8 Fire Profound Demons" },
	{ name = "Ill see you to Windy Peak(Lv 105)", npc = "Shrine Messenger Akio", npcPos = Vector3.new(-207, 1350, -2423), qtype = "escort", mobCenter = Vector3.new(-207, 1350, -2423), task = "Escort Akio to Windy Peak (6 ambushes)" },
	{ name = "Ill haul in the deep catch(Lv 125)", npc = "Shrine Messenger Akio", npcPos = Vector3.new(-207, 1350, -2423), qtype = "deposit", mobCenter = Vector3.new(-114, 1354, -2521), task = "Deposit 5 Crustadon + 5 Krathulon + 12 Clown Fish" },
	{ name = "Ill learn Flame Breathing(Lv 25)", npc = "Flame Trainer Rengu", npcPos = Vector3.new(-968, 1029, 1188), qtype = "training", mobCenter = Vector3.new(-968, 1029, 1188), task = "Meditate > Push ups > Boulder Split > Aim > Cup > Beat Trainee" },
	{ name = "Ill learn Water Breathing(Lv 25)", npc = "Water Trainer Urokodaki", npcPos = Vector3.new(667, 1023, -228), qtype = "training", mobCenter = Vector3.new(667, 1023, -228), task = "Parkour > Push ups > Meditation > Cup > Aim > Beat Trainee" },
	{ name = "Ill learn Thunder Breathing(Lv 25)", npc = "Thunder Trainer Zentaro", npcPos = Vector3.new(1970, 1660, -610), qtype = "training", mobCenter = Vector3.new(1970, 1660, -610), task = "Meditate > Cup > Push ups > Aim > Boulder Split > Beat Trainee" },
	{ name = "Ill learn Wind Breathing(Lv 25)", npc = "Wind Trainer Saneri", npcPos = Vector3.new(-276, 1187, -3437), qtype = "training", mobCenter = Vector3.new(-276, 1187, -3437), task = "Training chain at trainer" },
	{ name = "Ill learn Stone Breathing(Lv 25)", npc = "Stone Trainer Gyorei", npcPos = Vector3.new(2579, 1096, -828), qtype = "training", mobCenter = Vector3.new(2579, 1096, -828), task = "Training chain at trainer" },
	{ name = "Ill learn Serpent Breathing(Lv 25)", npc = "Serpent Trainer Obari", npcPos = Vector3.new(37, 1311, -1180), qtype = "training", mobCenter = Vector3.new(37, 1311, -1180), task = "Training chain at trainer" },
	{ name = "Ill learn Insect Breathing(Lv 25)", npc = "Insect Trainer Shinora", npcPos = Vector3.new(-1799, 348, -189), qtype = "training", mobCenter = Vector3.new(-1799, 348, -189), task = "Training chain at trainer" },
	{ name = "Ill learn Sound Breathing(Lv 25)", npc = "Sound Trainer Tengai", npcPos = Vector3.new(465, 1491, -3273), qtype = "training", mobCenter = Vector3.new(465, 1491, -3273), task = "Training chain at trainer" },
}

local questLoopActive = false
local questLoopCount = 0
local questLoopId = 0

local function waitForRespawn()
	while not getHRP() do task.wait(0.5) end
	task.wait(1)
end

local function talkToNpc(npcName, npcPos)
	local hrp = getHRP()
	if not hrp then waitForRespawn(); hrp = getHRP(); if not hrp then return end end
	hrp.CFrame = CFrame.new(npcPos) + Vector3.new(0, 3, 0)
	task.wait(0.8)
	pcall(function()
		for _, desc in workspace:GetDescendants() do
			if desc:IsA("ProximityPrompt") then
				local npcModel = desc:FindFirstAncestorWhichIsA("Model")
				if npcModel and npcModel.Name == npcName then
					pcall(function() fireproximityprompt(desc) end)
				end
			end
		end
	end)
	task.wait(0.3)
	pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
	task.wait(0.2)
end

local function farmMobsUntilQuestDone(quest, myId)
	local hrp = getHRP()
	if not hrp then
		questStatusLabel.Text = "WAITING FOR RESPAWN..."
		while questLoopActive and myId == questLoopId and not getHRP() do task.wait(0.5) end
		if not questLoopActive or myId ~= questLoopId then return false end
		task.wait(1)
		hrp = getHRP()
		if not hrp then return false end
	end
	hrp.CFrame = CFrame.new(quest.mobCenter) + Vector3.new(0, 5, 0)
	task.wait(0.5)
	questStatusLabel.Text = "FIGHTING: " .. quest.task
	comboCounter = 0
	local checkTimer = 0
	local lockedMob = nil
	while questLoopActive and myId == questLoopId do
		task.wait(0.25)
		checkTimer = checkTimer + 0.25
		if checkTimer >= 2.5 then
			checkTimer = 0
			if not hasQuest(quest.name) then
				questStatusLabel.Text = "COMPLETE!"
				return true
			end
		end
		pcall(function()
			local myHrp = getHRP()
			local myHum = getHumanoid()
			if not myHrp or not myHum or myHum.Health <= 0 then
				questStatusLabel.Text = "RESPAWNING..."
				lockedMob = nil
				return
			end
			if (myHrp.Position - quest.mobCenter).Magnitude > 200 then
				myHrp.CFrame = CFrame.new(quest.mobCenter) + Vector3.new(0, 5, 0)
				lockedMob = nil
				return
			end
			local mobAlive = false
			if lockedMob then
				pcall(function()
					local hum = lockedMob:FindFirstChildOfClass("Humanoid")
					local root = lockedMob:FindFirstChild("HumanoidRootPart")
					if hum and hum.Health > 0 and root and lockedMob.Parent then
						mobAlive = true
					end
				end)
			end
			if not mobAlive then
				lockedMob = findNearestQuestMob(quest.mobCode, 500, quest.mobCenter)
				if lockedMob then
					comboCounter = 0
					local root = lockedMob:FindFirstChild("HumanoidRootPart")
					if root then
						myHum.PlatformStand = true
						myHrp.CFrame = getAttackCFrame(root.Position, myHrp)
						task.wait()
						startFarmHold(myHrp, getAttackPosition(root.Position, myHrp), root.Position)
					end
				end
			end
			if lockedMob then
				local root = lockedMob:FindFirstChild("HumanoidRootPart")
				if root then
					myHum.PlatformStand = true
					local mobPos = root.Position
					startFarmHold(myHrp, getAttackPosition(mobPos, myHrp), mobPos)
					fireAttack()
				end
			else
				stopFarmHold()
				if (myHrp.Position - quest.mobCenter).Magnitude > 80 then
					myHrp.CFrame = CFrame.new(quest.mobCenter) + Vector3.new(0, 5, 0)
				end
			end
		end)
	end
	stopFarmHold()
	return false
end

local function runQuestLoop(quest)
	questLoopActive = true
	questLoopCount = 0
	questLoopId = questLoopId + 1
	local myId = questLoopId
	task.spawn(function()
		equipWeapon(autoFarmWeaponSlot)

		while questLoopActive and myId == questLoopId and activeQuestData and activeQuestData.name == quest.name do
			if quest.qtype ~= "kill" then
				questStatusLabel.Text = quest.qtype:upper() .. " | " .. quest.task
				notify(quest.task)
				break
			end

			questStatusLabel.Text = "Going to " .. quest.npc .. "..."
			talkToNpc(quest.npc, quest.npcPos)
			if not questLoopActive or myId ~= questLoopId then break end

			local accepted = acceptQuest(quest.name)
			if not accepted then
				task.wait(0.5)
				accepted = acceptQuest(quest.name)
			end
			if not accepted then
				notify("Failed to accept quest -- retrying in 3s...")
				questStatusLabel.Text = "RETRY ACCEPT..."
				task.wait(3)
				if not questLoopActive or myId ~= questLoopId then break end
				talkToNpc(quest.npc, quest.npcPos)
				accepted = acceptQuest(quest.name)
				if not accepted then
					notify("Could not accept " .. quest.name .. " -- stopping")
					break
				end
			end

			if not questLoopActive or myId ~= questLoopId then break end
			local completed = farmMobsUntilQuestDone(quest, myId)
			if not questLoopActive or myId ~= questLoopId then break end

			if completed then
				questLoopCount = questLoopCount + 1
				notify("Quest done! (x" .. questLoopCount .. ") -- turning in...")
				questStatusLabel.Text = "TURNING IN... (x" .. questLoopCount .. ")"

				talkToNpc(quest.npc, quest.npcPos)
				pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
				task.wait(0.5)
				pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
				task.wait(0.5)

				if not questLoopActive or myId ~= questLoopId then break end
				notify("Turn-in done -- re-accepting...")
			end
		end
		if myId == questLoopId then
			questLoopActive = false
			if questLoopCount > 0 then
				questStatusLabel.Text = "STOPPED (x" .. questLoopCount .. " completed)"
			end
		end
	end)
end

local function stopQuestLoop()
	questLoopActive = false
	autoQuestFarmEnabled = false
	questLoopId = questLoopId + 1
	activeQuestData = nil
	pcall(function() questStatusLabel.Text = "" end)
	stopFarmHold()
end

addButton("Auto", "Stop Auto Quest", function()
	stopQuestLoop()
	notify("Auto quest stopped -- you can move freely")
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == keybinds.stopQuest then
		stopQuestLoop()
		notify("Quest STOPPED (F8)")
	end
end)

addButton("Auto", "Skip Dialogue", function()
	if signalRemote then
		pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
		notify("Dialogue skipped")
	end
end)

addTextInput("Auto", "Search quest by name or NPC...", function(text)
	if text == "" then return end
	local searchLower = text:lower()
	for i, quest in KNOWN_QUESTS do
		if quest.name:lower():find(searchLower) or quest.npc:lower():find(searchLower) or quest.task:lower():find(searchLower) then
			stopQuestLoop()
			task.wait(0.1)
			currentQuestName = quest.name
			activeQuestData = quest
			questNameLabel.Text = "Quest: " .. currentQuestName
			notify("Found: " .. quest.npc .. " -- " .. quest.name)
			if quest.qtype == "kill" then
				runQuestLoop(quest)
			else
				questStatusLabel.Text = quest.qtype:upper() .. " | " .. quest.task
			end
			return
		end
	end
	notify("No quest matching '" .. text .. "'")
end)

local questOptions = {}
for _, quest in KNOWN_QUESTS do
	table.insert(questOptions, quest.npc .. ": " .. quest.name)
end

addDropdown("Auto", "Select Quest", questOptions, function(idx, text)
	local quest = KNOWN_QUESTS[idx]
	if not quest then notify("Invalid quest"); return end
	local hrp = getHRP()
	if not hrp then notify("No character"); return end

	stopQuestLoop()
	task.wait(0.1)

	currentQuestName = quest.name
	questNameLabel.Text = "Quest: " .. currentQuestName

	if quest.qtype == "kill" then
		activeQuestData = quest
		notify("Starting auto quest loop: " .. quest.name)
		runQuestLoop(quest)
	else
		activeQuestData = nil
		questLoopId = questLoopId + 1
		local myId = questLoopId

		if quest.qtype == "deliver" then
			talkToNpc(quest.npc, quest.npcPos)
			if myId ~= questLoopId then return end
			acceptQuest(quest.name)
			if myId ~= questLoopId then return end
			hrp = getHRP(); if not hrp then return end
			hrp.CFrame = CFrame.new(quest.deliverPos) + Vector3.new(0, 3, 0)
			notify("TP to " .. quest.deliverTo)
			task.wait(0.3)
			pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
			if quest.returnTo and quest.returnPos and myId == questLoopId then
				task.wait(0.5)
				hrp = getHRP(); if not hrp then return end
				hrp.CFrame = CFrame.new(quest.returnPos) + Vector3.new(0, 3, 0)
				notify("Returning to " .. quest.returnTo)
				task.wait(0.3)
				pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
			end
			questStatusLabel.Text = "DELIVER | " .. quest.task
		elseif quest.qtype == "collect" then
			talkToNpc(quest.npc, quest.npcPos)
			if myId ~= questLoopId then return end
			acceptQuest(quest.name)
			if myId ~= questLoopId then return end
			hrp = getHRP(); if not hrp then return end
			hrp.CFrame = CFrame.new(quest.mobCenter) + Vector3.new(0, 3, 0)
			notify(quest.task)
			questStatusLabel.Text = "COLLECT | " .. quest.task
		elseif quest.qtype == "deposit" then
			talkToNpc(quest.npc, quest.npcPos)
			if myId ~= questLoopId then return end
			acceptQuest(quest.name)
			if myId ~= questLoopId then return end
			hrp = getHRP(); if not hrp then return end
			hrp.CFrame = CFrame.new(quest.mobCenter) + Vector3.new(0, 3, 0)
			notify(quest.task)
			questStatusLabel.Text = "DEPOSIT | " .. quest.task
		else
			talkToNpc(quest.npc, quest.npcPos)
			if myId ~= questLoopId then return end
			acceptQuest(quest.name)
			notify(quest.task)
			questStatusLabel.Text = quest.task
		end
	end
end)

pcall(function()
	if signalRemote then
		signalRemote.OnClientEvent:Connect(function(eventName, ...)
			if eventName == "NpcTalking" and autoDialogueEnabled and not questLoopActive then
				task.spawn(function()
					task.wait(0.15)
					pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
				end)
			end
		end)
	end
end)

------------------------------------------------------------
-- SCHEMATICS (Auto tab)
------------------------------------------------------------
addSpacer("Auto")
addLabel("Auto", "SCHEMATICS")

local SCHEMATICS = {
	{
		name = "Firstlight Wagasa Schematic",
		npc = "Wagasa Maker Genzo",
		pos = Vector3.new(-1059, 1226, -956),
		how = "Talk NPC (need Damascus Bladed Wagasa)",
		signal = "WagasaGiveSchematic",
		signalArgs = {},
	},
	{
		name = "Nightfall Gauntlet Schematic",
		npc = "Stonemason Tobei",
		pos = Vector3.new(1876, 659, -206),
		how = "Complete Gauntlet Statues puzzle, then talk NPC",
		signal = "GauntletGiveSchematic",
		signalArgs = {},
		preSignal = "GauntletStatuesBegin",
	},
	{
		name = "Firstlight Sound Cleavers Schematic",
		npc = "Duelist Hibiki",
		pos = Vector3.new(-1234, 1427, -4593),
		how = "Win duel vs Hibiki",
		signal = "CleaverDuel",
		signalArgs = {},
	},
	{
		name = "Nightfall Cape Schematic",
		npc = "Weaver Hatsu",
		pos = Vector3.new(2281, 813, 15),
		how = "Trade Lost Cape to NPC",
		signal = "SeriesTrade",
		signalArgs = {"Cape"},
	},
	{
		name = "Firstlight Haori Schematic",
		npc = "Tailor Omi",
		pos = Vector3.new(1827, 1616, 120),
		how = "Trade Lost Outfit to NPC",
		signal = "SeriesTrade",
		signalArgs = {"Haori"},
	},
	{
		name = "Firstlight Lantern Schematic",
		npc = "Lamplighter Isamu",
		pos = Vector3.new(1082, 1426, -749),
		how = "Complete 'The Plate Trial' quest (5 rounds)",
		signal = nil,
	},
	{
		name = "Firstlight Tanto Schematic",
		pos = Vector3.new(-1375, 1420, -3824),
		how = "Dig Chest Mound (need Mushroom Lit Lantern + Shovel)",
		signal = nil,
	},
	{
		name = "Firstlight War Fans Schematic",
		pos = Vector3.new(-425, 1354, -3529),
		how = "Dig Chest Mound (need WarFansClue_4 + Shovel)",
		signal = nil,
	},
	{
		name = "Nightfall Serpent Katana Schematic",
		pos = Vector3.new(0, 0, 0),
		how = "Open Serpent Box (need SerpentKey)",
		signal = nil,
	},
}

local schematicOptions = {}
for _, sch in SCHEMATICS do
	local label = sch.name
	if sch.npc then label = label .. " [" .. sch.npc .. "]" end
	table.insert(schematicOptions, label)
end

addDropdown("Auto", "Select Schematic", schematicOptions, function(idx, text)
	local sch = SCHEMATICS[idx]
	if not sch then notify("Invalid schematic"); return end
	local hrp = getHRP()
	if not hrp then notify("No character"); return end

	if sch.pos and sch.pos.Magnitude > 1 then
		hrp.CFrame = CFrame.new(sch.pos) + Vector3.new(0, 3, 0)
		notify("TP to " .. sch.name)
		task.wait(0.5)
	end

	if sch.signal and signalRemote then
		if sch.preSignal then
			pcall(function() signalRemote:FireServer(sch.preSignal) end)
			task.wait(1)
		end
		pcall(function()
			if #sch.signalArgs > 0 then
				signalRemote:FireServer(sch.signal, unpack(sch.signalArgs))
			else
				signalRemote:FireServer(sch.signal)
			end
		end)
		task.wait(0.3)
		pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
		notify("Fired: " .. sch.signal)
	elseif not sch.signal then
		notify(sch.how)
	else
		notify("Signal remote not found")
	end
end)
end -- scope: auto

------------------------------------------------------------
-- SLAYER TAB
------------------------------------------------------------
do -- scope: slayer

addLabel("Slayer", "GOURD")

local autoGourdTrainEnabled = false

local function getPlayerSlot()
	local slot = nil
	pcall(function()
		local ps = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Service")
		local data = ps.Data:FindFirstChild(player.Name)
		local se = data:FindFirstChild("slotEquipped")
		local slotNum = se and se.Value or 1
		slot = data.slots:FindFirstChild("Slot" .. slotNum)
	end)
	return slot
end

local function getPlayerBreathing()
	local breathing = ""
	pcall(function()
		local slot = getPlayerSlot()
		if slot then
			local powers = slot:FindFirstChild("Powers")
			if powers then
				local b = powers:FindFirstChild("Breathing")
				if b then breathing = b.Value end
			end
		end
	end)
	return breathing
end

local function getPlayerRace()
	local race = "Human"
	pcall(function()
		local slot = getPlayerSlot()
		if slot then
			local r = slot:FindFirstChild("Race")
			if r then race = r.Value end
		end
	end)
	return race
end

addButton("Slayer", "Show My Stats", function()
	pcall(function()
		local slot = getPlayerSlot()
		if not slot then notify("Could not read player data"); return end
		local race = "?"; pcall(function() race = slot:FindFirstChild("Race").Value end)
		local sRank = "?"; pcall(function() sRank = slot:FindFirstChild("SlayerRank").Value end)
		local dRank = "?"; pcall(function() dRank = slot:FindFirstChild("DemonRank").Value end)
		local rep = "?"; pcall(function() rep = tostring(slot:FindFirstChild("Reputation").Value) end)
		local wen = "?"; pcall(function() wen = tostring(slot:FindFirstChild("Wen").Value) end)
		local breathing = "None"; pcall(function() local b = slot.Powers.Breathing.Value; if b ~= "" then breathing = b end end)
		local clan = "?"; pcall(function() clan = slot:FindFirstChild("Clan").Value end)
		notify("Race: " .. race .. " | Clan: " .. clan)
		notify("Slayer: " .. sRank .. " | Demon: " .. dRank)
		notify("Rep: " .. rep .. " | Wen: " .. wen)
		notify("Breathing: " .. breathing)
	end)
end)

addSpacer("Slayer")

addButton("Slayer", "TP to Ren (Gourd Shop)", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-1837, 314, -24) + Vector3.new(0, 5, 0)
	notify("TP -> Ren (Butterfly Estate)")
end)

addButton("Slayer", "Buy Small Gourd", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-1855, 316, 5) + Vector3.new(0, 3, 0)
	task.wait(0.5)
	pcall(function()
		local ren = workspace:FindFirstChild("StationaryNpcs", true)
		if ren then
			for _, obj in ren:GetDescendants() do
				if obj.Name == "Small Gourd" then
					local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
					if prompt then
						fireproximityprompt(prompt)
						notify("Purchasing Small Gourd...")
						return
					end
				end
			end
		end
		for _, obj in workspace:GetDescendants() do
			if obj.Name == "Small Gourd" and obj:IsA("Model") then
				local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then
					fireproximityprompt(prompt)
					notify("Purchasing Small Gourd...")
					return
				end
			end
		end
		notify("Small Gourd prompt not found")
	end)
end)

addButton("Slayer", "Buy Medium Gourd", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-1855, 317, 9) + Vector3.new(0, 3, 0)
	task.wait(0.5)
	pcall(function()
		for _, obj in workspace:GetDescendants() do
			if obj.Name == "Medium Gourd" and obj:IsA("Model") then
				local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then fireproximityprompt(prompt); notify("Purchasing Medium Gourd..."); return end
			end
		end
		notify("Medium Gourd prompt not found")
	end)
end)

addButton("Slayer", "Buy Large Gourd", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-1855, 318, 13) + Vector3.new(0, 3, 0)
	task.wait(0.5)
	pcall(function()
		for _, obj in workspace:GetDescendants() do
			if obj.Name == "Large Gourd" and obj:IsA("Model") then
				local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt then fireproximityprompt(prompt); notify("Purchasing Large Gourd..."); return end
			end
		end
		notify("Large Gourd prompt not found")
	end)
end)

addSpacer("Slayer")
addLabel("Slayer", "GOURD TRAINING")

addToggle("Slayer", "Auto Gourd Training", false, function(on)
	autoGourdTrainEnabled = on
	if not on then return end
	task.spawn(function()
		while autoGourdTrainEnabled do
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				if not signalRemote then notify("Signal remote not found"); autoGourdTrainEnabled = false; return end
				local gourdPrompt = nil
				pcall(function()
					for _, obj in workspace:GetDescendants() do
						if obj:IsA("ProximityPrompt") and obj.ActionText == "Train" then
							local par = obj.Parent
							if par and par:IsA("BasePart") then
								local root = par.Parent or par
								local rootName = root.Name:lower()
								if rootName:find("gourd") or (par.Position - Vector3.new(-1855, 316, 5)).Magnitude < 100 then
									gourdPrompt = obj
									break
								end
							end
						end
					end
				end)
				if gourdPrompt then
					local pp = gourdPrompt.Parent
					if pp and pp:IsA("BasePart") then
						hrp.CFrame = pp.CFrame + Vector3.new(0, 2, 0)
						task.wait(0.3)
					end
					pcall(function() fireproximityprompt(gourdPrompt) end)
					task.wait(0.5)
				end
				pcall(function() signalRemote:FireServer("training_signaler", "Do") end)
				task.wait(0.3)
				for _ = 1, 20 do
					if not autoGourdTrainEnabled then break end
					pcall(function() signalRemote:FireServer("training_signaler", "StateChanged", true) end)
					task.wait(0.1)
				end
				task.wait(0.3)
				pcall(function() signalRemote:FireServer("training_signaler", "Stop", true) end)
			end)
			task.wait(1.5)
		end
	end)
end)

addSpacer("Slayer")
addLabel("Slayer", "BREATHING")

addButton("Slayer", "Check My Breathing Style", function()
	local b = getPlayerBreathing()
	if b == "" then notify("No breathing style learned yet") else notify("Breathing: " .. b) end
end)

addLabel("Slayer", "BREATHING TRAINER TP")
local BREATH_STYLES = { "Thunder", "Wind", "Serpent", "Water", "Stone", "Insect", "Flame", "Sound" }
local breathOptions = {}; for _, s in BREATH_STYLES do table.insert(breathOptions, s .. " Trainer") end
addDropdown("Slayer", "TP to Breathing Trainer", breathOptions, function(idx)
	local hrp = getHRP(); if not hrp then return end
	local style = BREATH_STYLES[idx]
	local styleLow = style:lower()
	local found = false
	pcall(function()
		local function searchStationaryNpcs(container)
			if not container or found then return end
			for _, obj in container:GetDescendants() do
				if found then break end
				pcall(function()
					if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
						local n = obj.Name:lower()
						if n:find(styleLow) and not n:find("trainee") then
							local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
							if part then
								hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
								notify("TP -> " .. obj.Name)
								found = true
							end
						end
					end
				end)
			end
		end
		local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
		for _, source in sources do
			if found then break end
			if source then
				local regions = source:FindFirstChild("Regions")
				if regions then
					for _, region in regions:GetChildren() do
						if found then break end
						local stNpcs = region:FindFirstChild("StationaryNpcs")
						if stNpcs then searchStationaryNpcs(stNpcs) end
					end
				end
			end
		end
	end)
	if not found then notify(style .. " Trainer not found in world") end
end)

addSpacer("Slayer")
addLabel("Slayer", "SLAYER PROGRESSION")

addButton("Slayer", "TP to Final Selection", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-2547, 278, 32) + Vector3.new(0, 5, 0)
	notify("TP -> Final Selection Plains")
end)

addButton("Slayer", "TP to Butterfly Estate", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-1773, 315, -120) + Vector3.new(0, 5, 0)
	notify("TP -> Butterfly Estate")
end)

addButton("Slayer", "Unlock Butterfly Shrine", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-1723, 312, 123) + Vector3.new(0, 5, 0)
	task.wait(0.5)
	pcall(function()
		for _, obj in workspace:GetDescendants() do
			if obj:IsA("ProximityPrompt") and obj.ActionText == "Unlock Shrine" then
				local part = obj.Parent
				if part and part:IsA("BasePart") then
					local dist = (part.Position - hrp.Position).Magnitude
					if dist < 50 then
						fireproximityprompt(obj)
						notify("Unlocking Butterfly Estate Shrine...")
						return
					end
				end
			end
		end
		notify("Shrine prompt not found nearby")
	end)
end)

end -- scope: slayer

------------------------------------------------------------
-- DEMON TAB
------------------------------------------------------------
do -- scope: demon

addLabel("Demon", "SOUL COLLECTION")

local autoSoulEnabled = false

addToggle("Demon", "Auto Pickup Souls", false, function(on)
	autoSoulEnabled = on
	if not on then return end
	task.spawn(function()
		while autoSoulEnabled do
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				local debree = workspace:FindFirstChild("Debree")
				local container = debree or workspace
				local savedCF = hrp.CFrame
				local picked = 0
				for _, obj in container:GetDescendants() do
					if not autoSoulEnabled then break end
					pcall(function()
						if obj:IsA("ProximityPrompt") and obj.Enabled then
							local n = (obj.Parent and obj.Parent.Name or ""):lower()
							if n:find("soul") or n:find("orb") then
								local part = obj.Parent
								if part and part:IsA("BasePart") then
									hrp.CFrame = part.CFrame + Vector3.new(0, 1, 0)
									task.wait(0.15)
									fireproximityprompt(obj)
									picked += 1
									task.wait(0.15)
								end
							end
						end
					end)
				end
				if picked > 0 then
					hrp.CFrame = savedCF
					notify("Picked up " .. picked .. " soul(s)")
				end
			end)
			task.wait(2)
		end
	end)
end)

addSpacer("Demon")
addLabel("Demon", "DEMON INFO")

addButton("Demon", "Show Demon Stats", function()
	pcall(function()
		local slot = nil
		pcall(function()
			local ps = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Service")
			local data = ps.Data:FindFirstChild(player.Name)
			local se = data:FindFirstChild("slotEquipped")
			local slotNum = se and se.Value or 1
			slot = data.slots:FindFirstChild("Slot" .. slotNum)
		end)
		if not slot then notify("Could not read player data"); return end
		local race = "?"; pcall(function() race = slot:FindFirstChild("Race").Value end)
		local dRank = "?"; pcall(function() dRank = slot:FindFirstChild("DemonRank").Value end)
		local rep = "?"; pcall(function() rep = tostring(slot:FindFirstChild("Reputation").Value) end)
		local bda = "None"; pcall(function() local a = slot.Powers.DemonArt.Value; if a ~= "" then bda = a end end)
		notify("Race: " .. race .. " | Demon Rank: " .. dRank)
		notify("Rep: " .. rep .. " | BDA: " .. bda)
		if race ~= "Demon" then notify("You are not a Demon yet (need Rep <= -40 + Muzan)") end
	end)
end)

addSpacer("Demon")
addLabel("Demon", "REPUTATION")

local autoCivFarmEnabled = false

addToggle("Demon", "Auto Farm Civilians (Rep)", false, function(on)
	autoCivFarmEnabled = on
	if not on then return end
	task.spawn(function()
		while autoCivFarmEnabled do
			pcall(function()
				local hrp = getHRP(); if not hrp then return end
				local hum = getHumanoid(); if not hum then return end
				for _, obj in workspace:GetDescendants() do
					if not autoCivFarmEnabled then break end
					pcall(function()
						if (obj.Name == "Civilian" or obj.Name == "*Civilian*") and obj:IsA("Model") then
							local civHum = obj:FindFirstChildOfClass("Humanoid")
							local civHRP = obj:FindFirstChild("HumanoidRootPart")
							if civHum and civHRP and civHum.Health > 0 then
								hrp.CFrame = civHRP.CFrame + Vector3.new(0, 2, 0)
								task.wait(0.2)
								if signalRemote then
									for combo = 1, 4 do
										if not autoCivFarmEnabled then break end
										pcall(function()
											signalRemote:FireServer("Combat_Service", "Combat", combo, false, 0.085, false)
										end)
										task.wait(0.18)
									end
								end
								task.wait(0.3)
							end
						end
					end)
				end
			end)
			task.wait(1)
		end
	end)
end)

addButton("Demon", "TP to Civilians (Mistfall Harbor)", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(137, 874, 733) + Vector3.new(0, 5, 0)
	notify("TP -> Mistfall Harbor (Civilians)")
end)

addButton("Demon", "TP to Civilians (Windy Peak)", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(-448, 1241, -919) + Vector3.new(0, 5, 0)
	notify("TP -> Windy Peak (Civilians)")
end)

addSpacer("Demon")
addLabel("Demon", "MUZAN / TRANSFORMATION")

local muzanEspEnabled = false
local muzanNotifierEnabled = false
local muzanEspHighlight = nil
local muzanEspBillboard = nil

local function findMuzanNPC()
	local muzanModel = nil
	pcall(function()
		for _, obj in workspace:GetDescendants() do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
				local n = obj.Name:lower()
				if n:find("muzan") and not n:find("lair") and not n:find("blood") and not n:find("main") then
					local hrpCheck = obj:FindFirstChild("HumanoidRootPart")
					if hrpCheck then
						muzanModel = obj
						return
					end
				end
			end
		end
	end)
	return muzanModel
end

addButton("Demon", "Find & TP to Muzan", function()
	local hrp = getHRP(); if not hrp then return end
	local muzan = findMuzanNPC()
	if muzan then
		local mHRP = muzan:FindFirstChild("HumanoidRootPart")
		if mHRP then
			hrp.CFrame = mHRP.CFrame + Vector3.new(0, 3, 0)
			notify("TP -> Muzan (found roaming!)")
		end
	else
		notify("Muzan not found in this server — he spawns randomly")
	end
end)

addButton("Demon", "TP to Muzan's Lair", function()
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(2467, 1079, 2333) + Vector3.new(0, 5, 0)
	notify("TP -> Muzan's Lair")
end)

addButton("Demon", "Interact with Muzan", function()
	local hrp = getHRP(); if not hrp then return end
	local muzan = findMuzanNPC()
	if muzan then
		local mHRP = muzan:FindFirstChild("HumanoidRootPart")
		if mHRP then hrp.CFrame = mHRP.CFrame + Vector3.new(0, 3, 0) end
		task.wait(0.5)
	else
		hrp.CFrame = CFrame.new(2467, 1079, 2333) + Vector3.new(0, 5, 0)
		task.wait(1)
	end
	pcall(function()
		for _, obj in workspace:GetDescendants() do
			if obj:IsA("ProximityPrompt") and obj.Name == "Muzan" then
				fireproximityprompt(obj)
				notify("Interacting with Muzan...")
				return
			end
		end
		for _, obj in workspace:GetDescendants() do
			if obj:IsA("ProximityPrompt") then
				local n = (obj.Parent and obj.Parent.Name or ""):lower()
				if n:find("muzan") then
					fireproximityprompt(obj)
					notify("Interacting with Muzan...")
					return
				end
			end
		end
		notify("Muzan prompt not found nearby")
	end)
end)

addSpacer("Demon")

addToggle("Demon", "Muzan Notifier", false, function(on)
	muzanNotifierEnabled = on
	if not on then return end
	task.spawn(function()
		local lastNotified = 0
		while muzanNotifierEnabled do
			pcall(function()
				local muzan = findMuzanNPC()
				if muzan then
					local mHRP = muzan:FindFirstChild("HumanoidRootPart")
					if mHRP and os.clock() - lastNotified > 30 then
						local hrp = getHRP()
						local dist = "?"
						if hrp then dist = tostring(math.round((mHRP.Position - hrp.Position).Magnitude)) end
						notify("MUZAN SPOTTED! Distance: " .. dist .. "m")
						lastNotified = os.clock()
					end
				end
			end)
			task.wait(5)
		end
	end)
end)

addToggle("Demon", "Muzan ESP", false, function(on)
	muzanEspEnabled = on
	if not on then
		pcall(function() if muzanEspHighlight then muzanEspHighlight:Destroy(); muzanEspHighlight = nil end end)
		pcall(function() if muzanEspBillboard then muzanEspBillboard:Destroy(); muzanEspBillboard = nil end end)
		return
	end
	task.spawn(function()
		while muzanEspEnabled do
			pcall(function()
				local muzan = findMuzanNPC()
				if muzan then
					if not muzanEspHighlight or not muzanEspHighlight.Parent then
						pcall(function() if muzanEspHighlight then muzanEspHighlight:Destroy() end end)
						muzanEspHighlight = Instance.new("Highlight")
						muzanEspHighlight.FillColor = Color3.fromRGB(255, 0, 0)
						muzanEspHighlight.FillTransparency = 0.3
						muzanEspHighlight.OutlineColor = Color3.fromRGB(255, 50, 50)
						muzanEspHighlight.OutlineTransparency = 0
						muzanEspHighlight.Adornee = muzan
						muzanEspHighlight.Parent = game:GetService("CoreGui")
					else
						muzanEspHighlight.Adornee = muzan
					end
					local mHRP = muzan:FindFirstChild("HumanoidRootPart") or muzan:FindFirstChild("Head")
					if mHRP then
						if not muzanEspBillboard or not muzanEspBillboard.Parent then
							pcall(function() if muzanEspBillboard then muzanEspBillboard:Destroy() end end)
							muzanEspBillboard = Instance.new("BillboardGui")
							muzanEspBillboard.Size = UDim2.fromOffset(120, 30)
							muzanEspBillboard.StudsOffset = Vector3.new(0, 4, 0)
							muzanEspBillboard.AlwaysOnTop = true
							muzanEspBillboard.Adornee = mHRP
							muzanEspBillboard.Parent = game:GetService("CoreGui")
							local lbl = Instance.new("TextLabel")
							lbl.Size = UDim2.new(1, 0, 1, 0)
							lbl.BackgroundTransparency = 1
							lbl.TextColor3 = Color3.fromRGB(255, 50, 50)
							lbl.Font = Enum.Font.GothamBlack
							lbl.TextSize = 14
							lbl.TextStrokeTransparency = 0
							lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
							lbl.Parent = muzanEspBillboard
						end
						local hrp = getHRP()
						local dist = "?"
						if hrp then dist = tostring(math.round((mHRP.Position - hrp.Position).Magnitude)) end
						local lbl = muzanEspBillboard:FindFirstChildOfClass("TextLabel")
						if lbl then lbl.Text = "MUZAN [" .. dist .. "m]" end
						muzanEspBillboard.Adornee = mHRP
					end
				else
					pcall(function() if muzanEspHighlight then muzanEspHighlight:Destroy(); muzanEspHighlight = nil end end)
					pcall(function() if muzanEspBillboard then muzanEspBillboard:Destroy(); muzanEspBillboard = nil end end)
				end
			end)
			task.wait(1)
		end
		pcall(function() if muzanEspHighlight then muzanEspHighlight:Destroy(); muzanEspHighlight = nil end end)
		pcall(function() if muzanEspBillboard then muzanEspBillboard:Destroy(); muzanEspBillboard = nil end end)
	end)
end)

addSpacer("Demon")
addLabel("Demon", "DEBUG - FIND MUZAN QUEST CODES")

local muzanDebugEnabled = false
local muzanDebugNamecallHooked = false
local muzanDebugSeenNpcFolders = {}
local muzanDebugConn = nil

local function dbgArgToStr(v)
	local ok, s = pcall(function()
		if typeof(v) == "Instance" then return "<" .. v.ClassName .. ":" .. v:GetFullName() .. ">" end
		if typeof(v) == "table" then
			local parts = {}
			for k, val in v do table.insert(parts, tostring(k) .. "=" .. tostring(val)) end
			return "{" .. table.concat(parts, ", ") .. "}"
		end
		return tostring(v)
	end)
	return ok and s or "<unprintable>"
end

local function dbgPrint(tag, ...)
	local parts = {}
	for i = 1, select("#", ...) do
		table.insert(parts, dbgArgToStr((select(i, ...))))
	end
	print(("[F4XI-DBG][%s] %s"):format(tag, table.concat(parts, " | ")))
end

addToggle("Demon", "Debug Remotes (Discovery Mode)", false, function(on)
	muzanDebugEnabled = on
	if not on then
		if muzanDebugConn then muzanDebugConn:Disconnect(); muzanDebugConn = nil end
		notify("Debug mode OFF")
		return
	end

	notify("Debug ON -- open Utility > Console, then go talk to Muzan and accept his quest")

	if signalRemote and not muzanDebugConn then
		muzanDebugConn = signalRemote.OnClientEvent:Connect(function(...)
			if muzanDebugEnabled then dbgPrint("IN", ...) end
		end)
	end

	pcall(function()
		if hookmetamethod and newcclosure and not muzanDebugNamecallHooked then
			muzanDebugNamecallHooked = true
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if muzanDebugEnabled and (method == "FireServer" or method == "InvokeServer") then
					local args = {...}
					pcall(function() dbgPrint("OUT " .. method, self, table.unpack(args)) end)
				end
				return oldNamecall(self, ...)
			end))
		end
	end)

	task.spawn(function()
		while muzanDebugEnabled do
			pcall(function()
				local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
				for _, source in sources do
					if source then
						local regions = source:FindFirstChild("Regions")
						if regions then
							for _, region in regions:GetChildren() do
								local activeNpcs = region:FindFirstChild("ActiveNpcs")
								if activeNpcs then
									for _, npcFolder in activeNpcs:GetChildren() do
										if not muzanDebugSeenNpcFolders[npcFolder] then
											muzanDebugSeenNpcFolders[npcFolder] = true
											dbgPrint("NPC-SPAWN", npcFolder.Name .. " (region: " .. region.Name .. ")")
										end
									end
								end
							end
						end
					end
				end
			end)
			task.wait(1)
		end
	end)
end)

addSpacer("Demon")
addLabel("Demon", "KASUGAI CROW -> MUZAN LOOP")

local CROW_MUZAN_CONFIG = {
	crowNamePattern = "crow",
	questSearchRadius = 220,
}

local function findCrowNPC()
	local crowModel = nil
	pcall(function()
		for _, obj in workspace:GetDescendants() do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
				if obj.Name:lower():find(CROW_MUZAN_CONFIG.crowNamePattern) and obj:FindFirstChild("HumanoidRootPart") then
					crowModel = obj
					return
				end
			end
		end
	end)
	return crowModel
end

local function snapshotQuestNames()
	local names = {}
	local holder = getQuestHolder()
	if holder then
		for _, child in holder:GetChildren() do
			local qs = child:FindFirstChild("QuestString")
			if qs then names[qs.Value] = true end
		end
	end
	return names
end

local function talkToCrowAndAcceptQuest()
	local hrp = getHRP(); if not hrp then return nil, nil end
	local crow = findCrowNPC()
	if not crow then return nil, nil end
	local cHRP = crow:FindFirstChild("HumanoidRootPart")
	if not cHRP then return nil, nil end

	hrp.CFrame = cHRP.CFrame + Vector3.new(0, 3, 0)
	task.wait(0.8)

	local before = snapshotQuestNames()
	pcall(function()
		for _, obj in crow:GetDescendants() do
			if obj:IsA("ProximityPrompt") then fireproximityprompt(obj) end
		end
	end)
	task.wait(0.3)
	pcall(function() signalRemote:FireServer("NpcTalking", "Ended") end)
	task.wait(0.6)

	local newQuest = nil
	local after = snapshotQuestNames()
	for name in pairs(after) do
		if not before[name] then newQuest = name; break end
	end
	return newQuest, cHRP.Position
end

local function findNearestHostile(centerPos, radius)
	local best, bestDist = nil, radius
	pcall(function()
		local sources = {workspace:FindFirstChild("Humanoids"), workspace:FindFirstChild("Debree")}
		for _, source in sources do
			if source then
				local regions = source:FindFirstChild("Regions")
				if regions then
					for _, region in regions:GetChildren() do
						local activeNpcs = region:FindFirstChild("ActiveNpcs")
						if activeNpcs then
							for _, npcFolder in activeNpcs:GetChildren() do
								if not npcFolder.Name:lower():find(CROW_MUZAN_CONFIG.crowNamePattern) then
									for _, child in npcFolder:GetChildren() do
										if child:IsA("Model") then
											local hum = child:FindFirstChildOfClass("Humanoid")
											local root = child:FindFirstChild("HumanoidRootPart")
											if hum and hum.Health > 0 and root then
												local d = (root.Position - centerPos).Magnitude
												if d < bestDist then bestDist = d; best = child end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end)
	return best
end

local function farmHostilesNear(centerPos, radius, isActiveFn)
	local hrp = getHRP(); if not hrp then return end
	hrp.CFrame = CFrame.new(centerPos) + Vector3.new(0, 5, 0)
	task.wait(0.5)
	comboCounter = 0
	local lockedMob = nil
	while isActiveFn() do
		task.wait(0.25)
		pcall(function()
			local myHrp = getHRP()
			local myHum = getHumanoid()
			if not myHrp or not myHum or myHum.Health <= 0 then lockedMob = nil; return end
			if (myHrp.Position - centerPos).Magnitude > radius + 150 then
				myHrp.CFrame = CFrame.new(centerPos) + Vector3.new(0, 5, 0)
				lockedMob = nil
				return
			end
			local mobAlive = false
			if lockedMob then
				pcall(function()
					local h = lockedMob:FindFirstChildOfClass("Humanoid")
					local r = lockedMob:FindFirstChild("HumanoidRootPart")
					if h and h.Health > 0 and r and lockedMob.Parent then mobAlive = true end
				end)
			end
			if not mobAlive then
				lockedMob = findNearestHostile(centerPos, radius)
				if lockedMob then
					comboCounter = 0
					local root = lockedMob:FindFirstChild("HumanoidRootPart")
					if root then
						myHum.PlatformStand = true
						myHrp.CFrame = getAttackCFrame(root.Position, myHrp)
						task.wait()
						startFarmHold(myHrp, getAttackPosition(root.Position, myHrp), root.Position)
					end
				end
			end
			if lockedMob then
				local root = lockedMob:FindFirstChild("HumanoidRootPart")
				if root then
					myHum.PlatformStand = true
					startFarmHold(myHrp, getAttackPosition(root.Position, myHrp), root.Position)
					fireAttack()
				end
			else
				stopFarmHold()
				if (myHrp.Position - centerPos).Magnitude > 80 then
					myHrp.CFrame = CFrame.new(centerPos) + Vector3.new(0, 5, 0)
				end
			end
		end)
	end
	stopFarmHold()
end

local function fightMuzanBoss(isActiveFn)
	notify("Searching for Muzan...")
	local muzan = nil
	while isActiveFn() and not muzan do
		muzan = findMuzanNPC()
		if not muzan then
			local hrp = getHRP()
			if hrp then hrp.CFrame = CFrame.new(2467, 1079, 2333) + Vector3.new(0, 5, 0) end
			task.wait(2)
		end
	end
	if not muzan then return false end

	local mHum = muzan:FindFirstChildOfClass("Humanoid")
	if not mHum then return false end

	pcall(function()
		local myHrp = getHRP()
		local root = muzan:FindFirstChild("HumanoidRootPart")
		if myHrp and root then myHrp.CFrame = getAttackCFrame(root.Position, myHrp) end
	end)
	task.wait()

	notify("Engaging Muzan!")
	comboCounter = 0
	while isActiveFn() and muzan.Parent and mHum.Health > 0 do
		task.wait(0.25)
		pcall(function()
			local myHrp = getHRP()
			local myHum = getHumanoid()
			if not myHrp or not myHum or myHum.Health <= 0 then return end
			local root = muzan:FindFirstChild("HumanoidRootPart")
			if not root then return end
			myHum.PlatformStand = true
			startFarmHold(myHrp, getAttackPosition(root.Position, myHrp), root.Position)
			fireAttack()
		end)
	end
	stopFarmHold()
	return (not muzan.Parent) or mHum.Health <= 0
end

local crowMuzanLoopEnabled = false
local crowMuzanLoopId = 0

addToggle("Demon", "Auto Crow -> Kill Mobs -> Kill Muzan (LOOP)", false, function(on)
	crowMuzanLoopEnabled = on
	if not on then
		notify("Crow/Muzan auto loop stopped")
		return
	end
	crowMuzanLoopId = crowMuzanLoopId + 1
	local myId = crowMuzanLoopId
	local function active() return crowMuzanLoopEnabled and myId == crowMuzanLoopId end

	task.spawn(function()
		equipWeapon(autoFarmWeaponSlot)
		while active() do
			notify("Looking for Kasugai Crow...")
			local questName, crowPos = nil, nil
			for attempt = 1, 30 do
				if not active() then break end
				questName, crowPos = talkToCrowAndAcceptQuest()
				if questName then break end
				task.wait(1)
			end

			if not active() then break end

			if not questName then
				notify("No new quest from Crow -- retrying in 5s")
				task.wait(5)
			else
				notify("Quest accepted: " .. questName .. " -- clearing Muzan's mobs")
				farmHostilesNear(crowPos, CROW_MUZAN_CONFIG.questSearchRadius, function()
					return active() and hasQuest(questName)
				end)

				if active() then
					notify("Mobs cleared -- heading to Muzan")
					local killed = fightMuzanBoss(active)
					if killed then
						notify("Muzan defeated! Looping back to Crow...")
					else
						notify("Lost track of Muzan -- retrying loop")
					end
					task.wait(1)
				end
			end
		end
	end)
end)

addSpacer("Demon")
addLabel("Demon", "SPIDER LILY")

addButton("Demon", "TP to Nearest Spider Lily", function()
	local hrp = getHRP(); if not hrp then return end
	local bestPos, bestDist = nil, math.huge
	pcall(function()
		local debree = workspace:FindFirstChild("Debree")
		if debree then
			for _, obj in debree:GetChildren() do
				if obj.Name == "Spider Lily" and obj:IsA("Model") then
					local part = obj:FindFirstChildWhichIsA("BasePart")
					if part then
						local d = (part.Position - hrp.Position).Magnitude
						if d < bestDist then bestDist = d; bestPos = part.Position end
					end
				end
			end
		end
	end)
	if bestPos then
		hrp.CFrame = CFrame.new(bestPos + Vector3.new(0, 3, 0))
		notify("TP -> Spider Lily (" .. math.round(bestDist) .. "m)")
	else
		notify("No Spider Lily found in Debree")
	end
end)

end -- scope: demon

------------------------------------------------------------
-- UTILITY TAB
------------------------------------------------------------
do -- scope: utility
addLabel("Utility", "ANTI-KICK")

local afkConn
afkToggle = addToggle("Utility", "Anti-AFK", false, function(on)
	if on then
		local ok, VU = pcall(function() return game:GetService("VirtualUser") end)
		if ok then afkConn = player.Idled:Connect(function() VU:CaptureController(); VU:ClickButton2(Vector2.zero) end)
		else notify("VirtualUser unavailable") end
	else if afkConn then afkConn:Disconnect(); afkConn = nil end end
end)

addToggle("Utility", "Auto Rejoin on Kick", false, function(on)
	if on then
		notify("Will rejoin if kicked")
		pcall(function()
			game:GetService("GuiService").ErrorMessageChanged:Connect(function()
				task.wait(1)
				pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
			end)
		end)
	end
end)

addSpacer("Utility")
addLabel("Utility", "STATS")

local fpsLabel
local fpsFrameCount = 0
local fpsLastTime = os.clock()

RunService.Heartbeat:Connect(function() fpsFrameCount += 1 end)

addToggle("Utility", "Show FPS", false, function(on)
	if on then
		fpsLabel = make("TextLabel", {
			Name = "FPS", Size = UDim2.fromOffset(90, 26), Position = UDim2.fromOffset(10, 10),
			BackgroundColor3 = BG, TextColor3 = ACCENT2, Font = Enum.Font.GothamBold, TextSize = 13,
			Text = " FPS: --", TextXAlignment = Enum.TextXAlignment.Left, Parent = gui,
		}, { make("UICorner", { CornerRadius = UDim.new(0, 8) }), make("UIStroke", { Color = ACCENT_DIM, Thickness = 1 }) })
		fpsFrameCount = 0; fpsLastTime = os.clock()
		task.spawn(function()
			while fpsLabel and fpsLabel.Parent do
				task.wait(0.5)
				local now = os.clock()
				local elapsed = now - fpsLastTime
				if elapsed > 0 then
					local fps = math.round(fpsFrameCount / elapsed)
					if fpsLabel and fpsLabel.Parent then fpsLabel.Text = " FPS: " .. fps end
				end
				fpsFrameCount = 0; fpsLastTime = now
			end
		end)
	else if fpsLabel then fpsLabel:Destroy(); fpsLabel = nil end end
end)

addButton("Utility", "Server Info", function()
	local n = #Players:GetPlayers()
	print("=== SERVER ==="); print("Players: " .. n .. "/" .. Players.MaxPlayers)
	print("JobId: " .. game.JobId); print("PlaceId: " .. game.PlaceId)
	notify(n .. "/" .. Players.MaxPlayers .. " players")
end)

addButton("Utility", "Copy Place ID", function()
	local ok = pcall(function() setclipboard(tostring(game.PlaceId)) end)
	if ok then notify("Copied: " .. game.PlaceId) else notify("PlaceId: " .. game.PlaceId) end
end)

addSpacer("Utility")
addLabel("Utility", "SERVER")

local serverJoinTime = os.time()
orders["Utility"] += 1
local uptimeRow = make("Frame", {
	Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = BG_CARD, LayoutOrder = orders["Utility"], Parent = tabPages["Utility"],
}, {
	make("UICorner", { CornerRadius = UDim.new(0, 10) }),
	make("UIStroke", { Color = BORDER, Thickness = 1 }),
})
make("TextLabel", {
	Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(18, 0), BackgroundTransparency = 1,
	Text = "Server Uptime", TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = uptimeRow,
})
local uptimeValue = make("TextLabel", {
	Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(1, -100, 0, 0), BackgroundTransparency = 1,
	Text = "00:00:00", TextColor3 = ACCENT2, Font = Enum.Font.GothamBold, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Right, Parent = uptimeRow,
})
task.spawn(function()
	while uptimeValue and uptimeValue.Parent do
		local elapsed = os.time() - serverJoinTime
		local h = math.floor(elapsed / 3600)
		local m = math.floor((elapsed % 3600) / 60)
		local s = elapsed % 60
		uptimeValue.Text = string.format("%02d:%02d:%02d", h, m, s)
		task.wait(1)
	end
end)

addButton("Utility", "Rejoin Server", function() notify("Rejoining..."); task.wait(0.3); TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
addButton("Utility", "Server Hop", function() notify("Hopping..."); task.wait(0.3); TeleportService:Teleport(game.PlaceId) end)

addSpacer("Utility")
addLabel("Utility", "WORLD")
addSlider("Utility", "Gravity", 0, 400, 196, 1, function(v) workspace.Gravity = v end)
addButton("Utility", "Reset Gravity", function() workspace.Gravity = 196.2; notify("Gravity reset") end)

addSpacer("Utility")
addLabel("Utility", "TOOLS")

local conGui = make("ScreenGui", { Name = "F4xiConsole", ResetOnSpawn = false, Enabled = false, Parent = playerGui })
local conWindow = make("Frame", { Size = UDim2.fromOffset(420, 280), Position = UDim2.fromOffset(460, 420), BackgroundColor3 = BG, Parent = conGui }, { make("UICorner", { CornerRadius = UDim.new(0, 12) }), make("UIStroke", { Color = ACCENT_DIM, Thickness = 1.5 }) })
make("Frame", { Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Parent = conWindow }, { make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2)}) }) })
local conTitle = make("Frame", { Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, 3), BackgroundTransparency = 1, Parent = conWindow })
make("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = "CONSOLE", TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = conTitle })
local conClose = make("TextButton", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -32, 0, 5), BackgroundColor3 = BG_CARD, AutoButtonColor = false, Text = "X", TextColor3 = DIM, Font = Enum.Font.GothamBold, TextSize = 11, Parent = conTitle }, { make("UICorner", { CornerRadius = UDim.new(0, 8) }) })
conClose.MouseButton1Click:Connect(function() conGui.Enabled = false end)
make("Frame", { Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 32), BackgroundColor3 = BORDER, BorderSizePixel = 0, Parent = conWindow })
makeDraggable(conTitle, conWindow)

local conScroll = make("ScrollingFrame", {
	Size = UDim2.new(1, -8, 1, -64), Position = UDim2.fromOffset(4, 36), BackgroundTransparency = 1,
	ScrollBarThickness = 3, ScrollBarImageColor3 = DIM, BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = conWindow,
}, { make("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }) })

local conCopy = make("TextButton", { Size = UDim2.new(0.5, -6, 0, 22), Position = UDim2.new(0, 4, 1, -26), BackgroundColor3 = BG_CARD, AutoButtonColor = false, Text = "Copy", TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 11, Parent = conWindow }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
local conClear = make("TextButton", { Size = UDim2.new(0.5, -6, 0, 22), Position = UDim2.new(0.5, 2, 1, -26), BackgroundColor3 = BG_CARD, AutoButtonColor = false, Text = "Clear", TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 11, Parent = conWindow }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })

local conLogLines = {}

conCopy.MouseButton1Click:Connect(function()
	local ok = pcall(function() setclipboard(table.concat(conLogLines, "\n")) end)
	if ok then notify("Console copied (" .. #conLogLines .. " lines)") else notify("Copy failed -- setclipboard unavailable") end
end)

conClear.MouseButton1Click:Connect(function()
	conScroll:ClearAllChildren()
	make("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = conScroll })
	conLogLines = {}
end)

local conEnabled = false
local conOrder = 0

LogService.MessageOut:Connect(function(msg, msgType)
	if not conEnabled then return end
	conOrder += 1
	local color = WHITE
	local prefix = "INFO"
	if msgType == Enum.MessageType.MessageWarning then color = YELLOW; prefix = "WARN"
	elseif msgType == Enum.MessageType.MessageError then color = RED; prefix = "ERR" end
	table.insert(conLogLines, "[" .. prefix .. "] " .. msg)
	make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = "[" .. prefix .. "] " .. msg,
		TextColor3 = color, Font = Enum.Font.Code, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		LayoutOrder = conOrder, Parent = conScroll,
	}, { make("UIPadding", { PaddingLeft = UDim.new(0, 4) }) })
	task.defer(function() conScroll.CanvasPosition = Vector2.new(0, conScroll.AbsoluteCanvasSize.Y) end)
end)

addToggle("Utility", "Console", false, function(on) conEnabled = on; conGui.Enabled = on end)

addSpacer("Utility")
addLabel("Utility", "SPYBOT")

local spyEnabled = false
local spyNamecallHooked = false
local spyConnections = {}
local spySeenRemotes = {}
local D2C = nil

local function loadD2C()
	if D2C then return D2C end
	pcall(function()
		D2C = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV2/refs/heads/main/Utility/Data2Code%40Amity.lua"))()
	end)
	return D2C
end

local function spySerialize(value)
	local ok, d2c = pcall(loadD2C)
	if ok and d2c then
		local ok2, s = pcall(function() return d2c.Convert(value, true) end)
		if ok2 then return s end
	end
	return tostring(value)
end

local function spyLog(tag, ...)
	local parts = {}
	for i = 1, select("#", ...) do
		table.insert(parts, spySerialize((select(i, ...))))
	end
	print("[SPY][" .. tag .. "] " .. table.concat(parts, " | "))
end

local function connectRemote(inst)
	if spySeenRemotes[inst] then return end
	spySeenRemotes[inst] = true
	pcall(function()
		if inst:IsA("RemoteEvent") then
			table.insert(spyConnections, inst.OnClientEvent:Connect(function(...)
				if spyEnabled then spyLog("IN " .. inst:GetFullName(), ...) end
			end))
		elseif inst:IsA("RemoteFunction") then
			local old = inst.OnClientInvoke
			inst.OnClientInvoke = function(...)
				if spyEnabled then spyLog("INVOKE " .. inst:GetFullName(), ...) end
				if old then return old(...) end
			end
		end
	end)
end

local function scanForRemotes(root)
	pcall(function()
		for _, obj in root:GetDescendants() do
			if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
				connectRemote(obj)
			end
		end
	end)
end

addToggle("Utility", "Spybot (Log Everything)", false, function(on)
	spyEnabled = on
	if not on then
		notify("Spybot OFF")
		return
	end
	notify("Spybot ON -- open Console to see logs")

	scanForRemotes(game:GetService("ReplicatedStorage"))
	scanForRemotes(workspace)

	pcall(function()
		table.insert(spyConnections, game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(obj)
			if spyEnabled and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
				connectRemote(obj)
				spyLog("NEW-REMOTE", obj:GetFullName())
			end
		end))
	end)

	if hookmetamethod and newcclosure and not spyNamecallHooked then
		spyNamecallHooked = true
		local oldNamecall
		oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if spyEnabled and (method == "FireServer" or method == "InvokeServer") then
				local args = {...}
				pcall(function() spyLog("OUT " .. method .. " " .. self:GetFullName(), table.unpack(args)) end)
			end
			return oldNamecall(self, ...)
		end))
	end
end)

addButton("Utility", "Spybot: Save Full Snapshot", function()
	pcall(function()
		local lines = {}
		table.insert(lines, "=== F4XI SPYBOT SNAPSHOT ===")
		table.insert(lines, "Time: " .. os.date())
		table.insert(lines, "")

		table.insert(lines, "-- KNOWN REMOTES (seen so far, toggle Spybot ON first) --")
		for inst in pairs(spySeenRemotes) do
			pcall(function() table.insert(lines, inst.ClassName .. " | " .. inst:GetFullName()) end)
		end

		table.insert(lines, "")
		table.insert(lines, "-- RUNNING SCRIPTS --")
		pcall(function()
			for _, s in getrunningscripts() do
				pcall(function() table.insert(lines, s.ClassName .. " | " .. s:GetFullName()) end)
			end
		end)

		table.insert(lines, "")
		table.insert(lines, "-- MY ACTIVE QUESTS --")
		pcall(function()
			local ps = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Service")
			local pData = ps and ps:FindFirstChild("Data") and ps.Data:FindFirstChild(player.Name)
			if pData then
				local slotNum = 1
				pcall(function() local se = pData:FindFirstChild("slotEquipped"); if se then slotNum = se.Value end end)
				local slots = pData:FindFirstChild("slots")
				local activeSlot = slots and slots:FindFirstChild("Slot" .. slotNum)
				local holder = activeSlot and activeSlot:FindFirstChild("Quests") and activeSlot.Quests:FindFirstChild("Holder")
				if holder then
					for _, child in holder:GetChildren() do
						local qs = child:FindFirstChild("QuestString")
						if qs then table.insert(lines, "Quest: " .. tostring(qs.Value)) end
					end
				end
			end
		end)

		local data = table.concat(lines, "\n")
		local ok = pcall(function() writefile("f4xi_spy_snapshot.txt", data) end)
		if ok then notify("Snapshot saved -> f4xi_spy_snapshot.txt") else notify("writefile unavailable") end
	end)
end)

end -- scope: utility

------------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------------
do -- scope: settings
addLabel("Settings", "KEYBINDS")

local KEYBIND_NAMES = {
	{ key = "speed", label = "Speed Toggle", default = "X" },
	{ key = "fly", label = "Fly Toggle", default = "Y" },
	{ key = "stopQuest", label = "Stop Quest", default = "F8" },
	{ key = "toggleGui", label = "Toggle GUI", default = "RightShift" },
}

local function keyNameToEnum(name)
	local upper = name:upper():gsub("%s", "")
	local ok, result = pcall(function() return Enum.KeyCode[upper] end)
	if ok and result then return result end
	ok, result = pcall(function() return Enum.KeyCode[name] end)
	if ok and result then return result end
	return nil
end

for _, bind in KEYBIND_NAMES do
	orders["Settings"] += 1
	local row = make("Frame", {
		Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = BG_CARD,
		LayoutOrder = orders["Settings"], Parent = tabPages["Settings"],
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		make("UIStroke", { Color = BORDER, Thickness = 1 }),
	})

	make("TextLabel", {
		Size = UDim2.new(0.55, 0, 1, 0), Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1, Text = bind.label, TextColor3 = WHITE,
		Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local keyBox = make("TextBox", {
		Size = UDim2.new(0, 80, 0, 26), Position = UDim2.new(1, -94, 0, 8),
		BackgroundColor3 = Color3.fromRGB(12, 12, 24), Text = bind.default,
		TextColor3 = ACCENT2, Font = Enum.Font.GothamBold, TextSize = 11,
		ClearTextOnFocus = true, Parent = row,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 6) }),
		make("UIStroke", { Color = ACCENT_DIM, Thickness = 1 }),
	})

	keyBox.FocusLost:Connect(function(enter)
		if enter and keyBox.Text ~= "" then
			local newKey = keyNameToEnum(keyBox.Text)
			if newKey then
				keybinds[bind.key] = newKey
				keyBox.Text = keyBox.Text:upper()
				notify(bind.label .. " -> " .. keyBox.Text:upper())
			else
				notify("Invalid key: " .. keyBox.Text)
				keyBox.Text = bind.default
			end
		else
			local current = tostring(keybinds[bind.key]):gsub("Enum.KeyCode.", "")
			keyBox.Text = current
		end
	end)
end

addButton("Settings", "Reset All Keybinds", function()
	keybinds.speed = Enum.KeyCode.X
	keybinds.fly = Enum.KeyCode.Y
	keybinds.stopQuest = Enum.KeyCode.F8
	keybinds.toggleGui = Enum.KeyCode.RightShift
	notify("Keybinds reset to defaults")
end)

addSpacer("Settings")
addLabel("Settings", "CONFIG PROFILES")

local savedConfigs = {}
local configListFrame = nil

local function getConfigKeybindStr(k)
	return tostring(k):gsub("Enum.KeyCode.", "")
end

local function serializeConfig()
	local cfg = {}
	cfg.keybinds = {
		speed = getConfigKeybindStr(keybinds.speed),
		fly = getConfigKeybindStr(keybinds.fly),
		stopQuest = getConfigKeybindStr(keybinds.stopQuest),
		toggleGui = getConfigKeybindStr(keybinds.toggleGui),
	}
	cfg.windowExpanded = windowExpanded
	return cfg
end

local function applyConfig(cfg)
	if not cfg then return end
	if cfg.keybinds then
		for k, v in cfg.keybinds do
			local e = keyNameToEnum(v)
			if e then keybinds[k] = e end
		end
	end
	if cfg.windowExpanded ~= nil then
		windowExpanded = cfg.windowExpanded
		local h = windowExpanded and WINDOW_H_BIG or WINDOW_H_SMALL
		TweenService:Create(window, TWEEN_MED, { Size = UDim2.fromOffset(WINDOW_W, h) }):Play()
	end
end

local function refreshConfigList()
	if configListFrame then configListFrame:Destroy() end
	orders["Settings"] += 1
	configListFrame = make("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = orders["Settings"], Parent = tabPages["Settings"],
	}, { make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	if #savedConfigs == 0 then
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
			Text = "No saved configs", TextColor3 = DIM, Font = Enum.Font.Gotham, TextSize = 11,
			Parent = configListFrame,
		})
		return
	end

	for i, entry in savedConfigs do
		local row = make("Frame", {
			Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = BG_CARD, LayoutOrder = i,
			Parent = configListFrame,
		}, {
			make("UICorner", { CornerRadius = UDim.new(0, 8) }),
			make("UIStroke", { Color = BORDER, Thickness = 1 }),
		})

		make("TextLabel", {
			Size = UDim2.new(1, -110, 1, 0), Position = UDim2.fromOffset(12, 0),
			BackgroundTransparency = 1, Text = entry.name, TextColor3 = WHITE,
			Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})

		local loadBtn = make("TextButton", {
			Size = UDim2.fromOffset(40, 22), Position = UDim2.new(1, -98, 0, 6),
			BackgroundColor3 = ACCENT_DIM, AutoButtonColor = false, Text = "Load",
			TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row,
		}, { make("UICorner", { CornerRadius = UDim.new(0, 5) }) })
		loadBtn.MouseEnter:Connect(function() TweenService:Create(loadBtn, TWEEN_FAST, { BackgroundColor3 = ACCENT }):Play() end)
		loadBtn.MouseLeave:Connect(function() TweenService:Create(loadBtn, TWEEN_FAST, { BackgroundColor3 = ACCENT_DIM }):Play() end)
		loadBtn.MouseButton1Click:Connect(function()
			applyConfig(entry.data)
			notify("Loaded config: " .. entry.name)
		end)

		local delBtn = make("TextButton", {
			Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -50, 0, 6),
			BackgroundColor3 = Color3.fromRGB(60, 20, 30), AutoButtonColor = false, Text = "X",
			TextColor3 = RED, Font = Enum.Font.GothamBold, TextSize = 10, Parent = row,
		}, { make("UICorner", { CornerRadius = UDim.new(0, 5) }) })
		delBtn.MouseEnter:Connect(function() TweenService:Create(delBtn, TWEEN_FAST, { BackgroundColor3 = RED }):Play(); delBtn.TextColor3 = WHITE end)
		delBtn.MouseLeave:Connect(function() TweenService:Create(delBtn, TWEEN_FAST, { BackgroundColor3 = Color3.fromRGB(60, 20, 30) }):Play(); delBtn.TextColor3 = RED end)
		delBtn.MouseButton1Click:Connect(function()
			table.remove(savedConfigs, i)
			refreshConfigList()
			notify("Deleted config: " .. entry.name)
		end)

		row.MouseEnter:Connect(function()
			TweenService:Create(row, TWEEN_FAST, { BackgroundColor3 = BG_HOVER }):Play()
			local s = row:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = ACCENT_DIM }):Play() end
		end)
		row.MouseLeave:Connect(function()
			TweenService:Create(row, TWEEN_FAST, { BackgroundColor3 = BG_CARD }):Play()
			local s = row:FindFirstChildOfClass("UIStroke"); if s then TweenService:Create(s, TWEEN_FAST, { Color = BORDER }):Play() end
		end)
	end
end

addTextInput("Settings", "Config name + Enter to save...", function(name)
	if name == "" then name = "Config " .. (#savedConfigs + 1) end
	for idx, entry in savedConfigs do
		if entry.name == name then
			savedConfigs[idx].data = serializeConfig()
			refreshConfigList()
			notify("Updated config: " .. name)
			return
		end
	end
	table.insert(savedConfigs, { name = name, data = serializeConfig() })
	refreshConfigList()
	notify("Saved config: " .. name)
end)

refreshConfigList()

addSpacer("Settings")
addLabel("Settings", "ITEM TOOLS")

addButton("Settings", "List Inventory Items", function()
	pcall(function()
		local ps = game:GetService("ReplicatedStorage"):FindFirstChild("Player_Service")
		if not ps then notify("Player_Service not found"); return end
		local data = ps:FindFirstChild("Data")
		if not data then notify("Data not found"); return end
		local pData = data:FindFirstChild(player.Name)
		if not pData then notify("Player data not found"); return end
		local slotNum = 1
		pcall(function()
			local se = pData:FindFirstChild("slotEquipped")
			if se then slotNum = se.Value end
		end)
		local slots = pData:FindFirstChild("slots")
		if not slots then notify("No slots"); return end
		local activeSlot = slots:FindFirstChild("Slot" .. slotNum)
		if not activeSlot then notify("No active slot"); return end
		local inventory = activeSlot:FindFirstChild("Inventory")
		if not inventory then notify("No inventory folder"); return end
		local items = {}
		for _, item in inventory:GetChildren() do
			table.insert(items, item.Name)
		end
		if #items == 0 then notify("Inventory empty") else
			notify("Items (" .. #items .. "): " .. table.concat(items, ", "))
		end
	end)
end)

end -- scope: settings

finalizeAccordions()

------------------------------------------------------------
-- STARTUP
------------------------------------------------------------

do -- startup animation
	local ws = window:FindFirstChildOfClass("UIStroke")

	gui.Enabled = false
	window.BackgroundTransparency = 1
	window.Size = UDim2.fromOffset(WINDOW_W, WINDOW_H_SMALL)
	window.Position = UDim2.fromOffset(60, 50)
	if ws then ws.Transparency = 1 end
	if bodyFrame then bodyFrame.Visible = false end
	if titleBar then titleBar.Visible = false end
	if accentTop then accentTop.BackgroundTransparency = 1 end
	if glowBar then glowBar.BackgroundTransparency = 1 end

	local splashGui = make("ScreenGui", { Name = "F4xiSplash", ResetOnSpawn = false, Parent = playerGui })

	local splashBg = make("Frame", {
		Size = UDim2.fromOffset(320, 100), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.45, 0), BackgroundColor3 = BG,
		BackgroundTransparency = 1, Parent = splashGui,
	}, { make("UICorner", { CornerRadius = UDim.new(0, 16) }), make("UIStroke", { Color = ACCENT_DIM, Thickness = 2, Transparency = 1 }) })

	local splashAccent = make("Frame", {
		Size = UDim2.new(0, 0, 0, 3), AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 1),
		BackgroundColor3 = ACCENT, BackgroundTransparency = 0, BorderSizePixel = 0, Parent = splashBg,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 3) }),
		make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 40, 200)), ColorSequenceKeypoint.new(0.3, ACCENT), ColorSequenceKeypoint.new(0.6, ACCENT2), ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 190, 255))}) }),
	})

	local splashBottomLine = make("Frame", {
		Size = UDim2.new(0, 0, 0, 2), AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, -3),
		BackgroundColor3 = ACCENT, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = splashBg,
	}, {
		make("UICorner", { CornerRadius = UDim.new(0, 2) }),
		make("UIGradient", { Color = ColorSequence.new({ColorSequenceKeypoint.new(0, ACCENT2), ColorSequenceKeypoint.new(0.5, ACCENT), ColorSequenceKeypoint.new(1, ACCENT2)}) }),
	})

	local splashTitle = make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 36), Position = UDim2.fromOffset(0, 16),
		BackgroundTransparency = 1, Text = "F4XI HUB", TextColor3 = WHITE,
		TextTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 28, Parent = splashBg,
	})

	local splashVer = make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 56),
		BackgroundTransparency = 1, Text = "v1.0", TextColor3 = ACCENT,
		TextTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 12, Parent = splashBg,
	})

	local splashSub = make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 74),
		BackgroundTransparency = 1, Text = "Slayers 2", TextColor3 = DIM,
		TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 10, Parent = splashBg,
	})

	task.defer(function()
		SFX.intro()
		TweenService:Create(splashBg, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.03,
		}):Play()
		local ss = splashBg:FindFirstChildOfClass("UIStroke")
		if ss then TweenService:Create(ss, TweenInfo.new(0.4), { Transparency = 0.2 }):Play() end

		TweenService:Create(splashAccent, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -6, 0, 3),
		}):Play()
		TweenService:Create(splashBottomLine, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0.6, 0, 0, 2),
		}):Play()

		task.wait(0.25)
		TweenService:Create(splashTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			TextTransparency = 0,
		}):Play()

		task.wait(0.35)
		TweenService:Create(splashVer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
		}):Play()
		task.wait(0.15)
		TweenService:Create(splashSub, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
		}):Play()

		task.wait(0.9)

		TweenService:Create(splashTitle, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		TweenService:Create(splashVer, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		TweenService:Create(splashSub, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		TweenService:Create(splashAccent, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 3),
		}):Play()
		TweenService:Create(splashBottomLine, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 2),
		}):Play()
		if ss then TweenService:Create(ss, TweenInfo.new(0.2), { Transparency = 1 }):Play() end
		TweenService:Create(splashBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
		}):Play()

		task.wait(0.35)
		splashGui:Destroy()

		SFX.swooshOpen()
		gui.Enabled = true
		notifGui.Enabled = true

		local flash = make("Frame", {
			Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = ACCENT,
			BackgroundTransparency = 1, ZIndex = 99, Parent = window,
		}, { make("UICorner", { CornerRadius = UDim.new(0, 14) }) })

		TweenService:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		}):Play()
		if ws then TweenService:Create(ws, TweenInfo.new(0.35), { Transparency = 0 }):Play() end

		task.wait(0.1)
		TweenService:Create(flash, TweenInfo.new(0.1), { BackgroundTransparency = 0.5 }):Play()
		task.wait(0.1)
		TweenService:Create(flash, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()

		if accentTop then TweenService:Create(accentTop, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play() end
		if glowBar then TweenService:Create(glowBar, TweenInfo.new(0.3), { BackgroundTransparency = 0.3 }):Play() end

		task.wait(0.1)
		if titleBar then titleBar.Visible = true end
		task.wait(0.15)

		if bodyFrame then
			bodyFrame.Visible = true
			bodyFrame.GroupTransparency = 1
			TweenService:Create(bodyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
		end

		task.wait(0.35)
		flash:Destroy()

		task.delay(0.1, function() afkToggle.fire() end)

		notify("F4XI HUB v1.0 loaded")
		task.delay(0.4, function() notify("RightShift = toggle | X = speed | Y = fly") end)
		task.delay(0.8, function() notify("F8 = emergency stop quest loop") end)
		task.delay(1.2, function() notify("Anti-AFK auto-enabled") end)
	end)
end
