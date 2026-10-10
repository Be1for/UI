local Bing = { Version = "2.0.0", Telegram = "t.me/pasterlua" }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
	Tab = Color3.fromRGB(22, 66, 176),
	TabHover = Color3.fromRGB(28, 84, 210),
	TabActive = Color3.fromRGB(36, 116, 255),
	Box = Color3.fromRGB(18, 44, 130),
	Accent = Color3.fromRGB(56, 146, 255),
	Text = Color3.fromRGB(225, 236, 255),
	SubText = Color3.fromRGB(150, 175, 230),
	Title = Color3.fromRGB(160, 200, 255),
	Line = Color3.fromRGB(70, 100, 190),
}
Bing.Theme = Theme

local function Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function Corner(r)
	return Create("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function Pad(l, t, r, b)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, l),
		PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r),
		PaddingBottom = UDim.new(0, b),
	})
end

local function Tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function IsPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function MakeDraggable(handle, target)
	local dragging, startPos, startInput
	handle.InputBegan:Connect(function(input)
		if IsPress(input) then
			dragging, startInput, startPos = true, input.Position, target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and IsMove(input) then
			local d = input.Position - startInput
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

local function GetParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	if pcall(function() return CoreGui.Name end) then return CoreGui end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function Hover(btn, target, normal, hover)
	btn.MouseEnter:Connect(function() Tween(target, { BackgroundColor3 = hover }) end)
	btn.MouseLeave:Connect(function() Tween(target, { BackgroundColor3 = normal }) end)
end

local function Row(tab, height)
	tab.Grid = nil
	return Create("Frame", {
		Size = UDim2.new(1, 0, 0, height or 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = tab.Page,
	})
end

local function RowLabel(row, text, x)
	return Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, x or 0, 0, 0),
		Size = UDim2.new(1, -(x or 0), 0, 30),
		Text = text or "",
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		Parent = row,
	})
end

local WindowClass = {}
WindowClass.__index = WindowClass
local TabClass = {}
TabClass.__index = TabClass

local function Register(tab, o, obj)
	if o.Flag then
		tab.Window.Options[o.Flag] = obj
		tab.Window.Flags[o.Flag] = obj.Value
	end
end

local function Fire(tab, o, obj)
	if o.Flag then tab.Window.Flags[o.Flag] = obj.Value end
	if o.Callback then task.spawn(o.Callback, obj.Value) end
end

function Bing:CreateWindow(opts)
	opts = opts or {}
	local size = opts.Size or UDim2.fromOffset(620, 380)
	local tgText = opts.Telegram or Bing.Telegram
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

	local gui = Create("ScreenGui", {
		Name = "BingUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	gui.Parent = GetParent()

	local main = Create("Frame", {
		Name = "Main",
		Size = size,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Parent = gui,
	}, {
		Corner(14),
		Create("UIGradient", {
			Rotation = 60,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 12, 40)),
				ColorSequenceKeypoint.new(0.55, Color3.fromRGB(16, 36, 118)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(78, 56, 160)),
			}),
		}),
	})

	local dragBar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Parent = main,
	})
	MakeDraggable(dragBar, main)

	Create("TextLabel", {
		Size = UDim2.new(0, 150, 0, 52),
		Position = UDim2.new(0, 14, 0, 6),
		BackgroundTransparency = 1,
		Text = "Bing",
		TextColor3 = Theme.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 42,
		Parent = main,
	})

	Create("Frame", {
		Size = UDim2.new(0, 140, 0, 1),
		Position = UDim2.new(0, 14, 0, 66),
		BackgroundColor3 = Theme.Line,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = main,
	})

	local tabList = Create("ScrollingFrame", {
		Size = UDim2.new(0, 140, 1, -88),
		Position = UDim2.new(0, 14, 0, 78),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = main,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local tg = Create("TextButton", {
		Size = UDim2.new(1, -184, 0, 30),
		Position = UDim2.new(0, 170, 0, 8),
		BackgroundTransparency = 1,
		Text = "TG: " .. tgText,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.GothamMedium,
		TextSize = 15,
		AutoButtonColor = false,
		Parent = main,
	})
	tg.MouseButton1Click:Connect(function()
		if setclipboard then pcall(setclipboard, "https://" .. tgText) end
	end)

	local pages = Create("Frame", {
		Size = UDim2.new(1, -184, 1, -62),
		Position = UDim2.new(0, 170, 0, 50),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = main,
	})

	local notifyHolder = Create("Frame", {
		Size = UDim2.new(0, 260, 1, -20),
		Position = UDim2.new(1, -270, 0, 10),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local window = setmetatable({
		Gui = gui,
		Main = main,
		TabList = tabList,
		Pages = pages,
		NotifyHolder = notifyHolder,
		Tabs = {},
		Flags = {},
		Options = {},
		Current = nil,
	}, WindowClass)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == toggleKey then window:Toggle() end
	end)

	if opts.ToggleButton ~= false then
		local fb = Create("TextButton", {
			Size = UDim2.fromOffset(40, 40),
			Position = UDim2.new(0, 12, 0.4, 0),
			BackgroundColor3 = Theme.TabActive,
			Text = "B",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			AutoButtonColor = true,
			Parent = gui,
		}, { Corner(20) })
		fb.MouseButton1Click:Connect(function() window:Toggle() end)
	end

	return window
end

function WindowClass:Toggle(state)
	if state == nil then state = not self.Main.Visible end
	self.Main.Visible = state
end

function WindowClass:Destroy()
	self.Gui:Destroy()
end

function WindowClass:Notify(o)
	o = o or {}
	local card = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundColor3 = Theme.Tab,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = self.NotifyHolder,
	}, { Corner(10), Pad(12, 6, 12, 6) })
	Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = o.Title or "Bing",
		TextColor3 = Theme.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = o.Content or "",
		TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})
	task.delay(o.Duration or 4, function()
		if card then card:Destroy() end
	end)
end

function WindowClass:Tab(o)
	o = o or {}
	local btn = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Tab,
		BackgroundTransparency = 0.08,
		Text = o.Title or "Tab",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		AutoButtonColor = false,
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabList,
	}, { Corner(9) })

	local page = Create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = self.Pages,
	}, {
		Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		Pad(0, 0, 6, 4),
	})

	local tab = setmetatable({ Window = self, TabButton = btn, Page = page, Grid = nil }, TabClass)
	table.insert(self.Tabs, tab)

	btn.MouseButton1Click:Connect(function() self:Select(tab) end)
	btn.MouseEnter:Connect(function()
		if self.Current ~= tab then Tween(btn, { BackgroundColor3 = Theme.TabHover }) end
	end)
	btn.MouseLeave:Connect(function()
		if self.Current ~= tab then Tween(btn, { BackgroundColor3 = Theme.Tab }) end
	end)

	if not self.Current then self:Select(tab) end
	return tab
end

function WindowClass:Select(tab)
	self.Current = tab
	for _, t in ipairs(self.Tabs) do
		local active = (t == tab)
		t.Page.Visible = active
		Tween(t.TabButton, { BackgroundColor3 = active and Theme.TabActive or Theme.Tab })
	end
end

function TabClass:Section(text)
	self.Grid = nil
	return Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = text or "",
		TextColor3 = Theme.SubText,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Page,
	})
end

function TabClass:Label(text)
	local row = Row(self, 24)
	local lbl = RowLabel(row, text)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.TextColor3 = Theme.SubText
	return { Set = function(_, t) lbl.Text = t end }
end

function TabClass:Button(o)
	self.Grid = nil
	local btn = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Tab,
		BackgroundTransparency = 0.08,
		Text = o.Title or "Button",
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		AutoButtonColor = false,
		Parent = self.Page,
	}, { Corner(9) })
	Hover(btn, btn, Theme.Tab, Theme.TabHover)
	btn.MouseButton1Click:Connect(function()
		Tween(btn, { BackgroundColor3 = Theme.TabActive }, 0.08)
		task.delay(0.12, function() Tween(btn, { BackgroundColor3 = Theme.Tab }) end)
		if o.Callback then task.spawn(o.Callback) end
	end)
end

local function GetGrid(tab)
	if tab.Grid and tab.Grid.Parent then return tab.Grid end
	local grid = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = tab.Page,
	}, {
		Create("UIGridLayout", {
			CellSize = UDim2.new(1 / 3, -8, 0, 30),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	tab.Grid = grid
	return grid
end

function TabClass:Toggle(o)
	local obj = { Value = o.Default == true }
	local tab = self
	local cell = Create("Frame", {
		BackgroundTransparency = 1,
		Parent = GetGrid(self),
	})
	local box = Create("Frame", {
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(0, 0, 0.5, -12),
		BackgroundColor3 = Theme.Box,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = cell,
	}, { Corner(6) })
	local check = Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "✓",
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextTransparency = 1,
		Parent = box,
	})
	Create("TextLabel", {
		Size = UDim2.new(1, -32, 1, 0),
		Position = UDim2.new(0, 32, 0, 0),
		BackgroundTransparency = 1,
		Text = o.Title or "Toggle",
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		Parent = cell,
	})
	local btn = Create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Parent = cell,
	})
	btn.MouseEnter:Connect(function() Tween(box, { BackgroundColor3 = Theme.Tab }) end)
	btn.MouseLeave:Connect(function() Tween(box, { BackgroundColor3 = Theme.Box }) end)

	local function render()
		Tween(check, { TextTransparency = obj.Value and 0 or 1 })
	end
	function obj:Set(v, silent)
		obj.Value = v and true or false
		render()
		if not silent then Fire(tab, o, obj) end
	end
	btn.MouseButton1Click:Connect(function() obj:Set(not obj.Value) end)
	render()
	Register(self, o, obj)
	return obj
end

function TabClass:Slider(o)
	local min, max = o.Min or 0, o.Max or 100
	local inc = o.Increment or 1
	local obj = { Value = math.clamp(o.Default or min, min, max) }
	local tab = self
	local row = Row(self, 46)
	local lbl = RowLabel(row, o.Title or "Slider")
	lbl.Size = UDim2.new(1, 0, 0, 26)
	local val = Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Title,
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		Parent = row,
	})
	local bar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0, 32),
		BackgroundColor3 = Theme.Box,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = row,
	}, { Corner(4) })
	local fill = Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.TabActive,
		BorderSizePixel = 0,
		Parent = bar,
	}, { Corner(4) })

	local decimals = 0
	do
		local s = tostring(inc)
		local dot = s:find("%.")
		if dot then decimals = #s - dot end
	end

	local function render()
		local a = (obj.Value - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1)
		val.Text = string.format("%." .. decimals .. "f", obj.Value) .. (o.Suffix or "")
	end
	function obj:Set(v, silent)
		v = math.clamp(math.floor(v / inc + 0.5) * inc, min, max)
		if v == obj.Value and not silent then return end
		obj.Value = v
		render()
		if not silent then Fire(tab, o, obj) end
	end

	local dragging = false
	local function update(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		obj:Set(min + (max - min) * rel)
	end
	row.InputBegan:Connect(function(input)
		if IsPress(input) then
			dragging = true
			tab.Page.ScrollingEnabled = false
			update(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and IsMove(input) then update(input.Position.X) end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if dragging and IsPress(input) then
			dragging = false
			tab.Page.ScrollingEnabled = true
		end
	end)

	render()
	Register(self, o, obj)
	return obj
end

function TabClass:Dropdown(o)
	self.Grid = nil
	local values = o.Values or {}
	local multi = o.Multi == true
	local tab = self
	local obj = { Value = multi and {} or (o.Default or nil), Values = values }
	if multi and type(o.Default) == "table" then
		for _, v in ipairs(o.Default) do obj.Value[v] = true end
	end

	local HEADER = 36
	local holder = Create("Frame", {
		Size = UDim2.new(1, 0, 0, HEADER),
		BackgroundColor3 = Theme.Tab,
		BackgroundTransparency = 0.08,
		ClipsDescendants = true,
		BorderSizePixel = 0,
		Parent = self.Page,
	}, { Corner(9) })
	local head = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, HEADER),
		BackgroundTransparency = 1,
		Text = "",
		Parent = holder,
	})
	Hover(head, holder, Theme.Tab, Theme.TabHover)
	local title = Create("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		Parent = head,
	})
	local arrow = Create("TextLabel", {
		Size = UDim2.new(0, 24, 1, 0),
		Position = UDim2.new(1, -32, 0, 0),
		BackgroundTransparency = 1,
		Text = "v",
		TextColor3 = Theme.SubText,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = head,
	})
	local list = Create("ScrollingFrame", {
		Size = UDim2.new(1, -16, 0, 0),
		Position = UDim2.new(0, 8, 0, HEADER + 2),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = holder,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 2) }) })

	local opened = false
	local buttons = {}

	local function selectedList()
		local t = {}
		for _, v in ipairs(values) do
			if obj.Value[v] then table.insert(t, v) end
		end
		return t
	end

	local function render()
		local shown
		if multi then
			local s = selectedList()
			shown = #s > 0 and table.concat(s, ", ") or "-"
		else
			shown = obj.Value ~= nil and tostring(obj.Value) or "-"
		end
		title.Text = (o.Title or "Dropdown") .. ": " .. shown
		for v, b in pairs(buttons) do
			local on = multi and obj.Value[v] or (not multi and obj.Value == v)
			Tween(b, { BackgroundColor3 = on and Theme.TabActive or Theme.Box })
		end
	end

	local function fire()
		local out = multi and selectedList() or obj.Value
		if o.Flag then tab.Window.Flags[o.Flag] = out end
		if o.Callback then task.spawn(o.Callback, out) end
	end

	local function setOpen(state)
		opened = state
		local h = math.min(#values, 5) * 30
		list.Size = UDim2.new(1, -16, 0, h)
		Tween(holder, { Size = UDim2.new(1, 0, 0, opened and (HEADER + h + 10) or HEADER) })
		arrow.Text = opened and "^" or "v"
	end

	local function build()
		for _, b in pairs(buttons) do b:Destroy() end
		buttons = {}
		for _, v in ipairs(values) do
			local b = Create("TextButton", {
				Size = UDim2.new(1, -6, 0, 28),
				BackgroundColor3 = Theme.Box,
				Text = tostring(v),
				TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				AutoButtonColor = false,
				Parent = list,
			}, { Corner(7) })
			buttons[v] = b
			b.MouseButton1Click:Connect(function()
				if multi then
					obj.Value[v] = not obj.Value[v] or nil
				else
					obj.Value = v
					setOpen(false)
				end
				render()
				fire()
			end)
		end
		render()
	end

	function obj:Set(v, silent)
		if multi then
			obj.Value = {}
			for _, x in ipairs(v or {}) do obj.Value[x] = true end
		else
			obj.Value = v
		end
		render()
		if not silent then fire() end
	end
	function obj:Refresh(newValues)
		values = newValues
		obj.Values = newValues
		if multi then obj.Value = {} else obj.Value = nil end
		build()
		if opened then setOpen(true) end
	end
	function obj:Get()
		return multi and selectedList() or obj.Value
	end

	head.MouseButton1Click:Connect(function() setOpen(not opened) end)
	build()
	if o.Flag then
		tab.Window.Options[o.Flag] = obj
		tab.Window.Flags[o.Flag] = obj:Get()
	end
	return obj
end

function TabClass:Input(o)
	local obj = { Value = o.Default or "" }
	local tab = self
	local row = Row(self, 34)
	RowLabel(row, o.Title or "Input").Size = UDim2.new(0.5, 0, 1, 0)
	local box = Create("TextBox", {
		Size = UDim2.new(0.5, 0, 0, 28),
		Position = UDim2.new(0.5, 0, 0.5, -14),
		BackgroundColor3 = Theme.Tab,
		BackgroundTransparency = 0.15,
		Text = obj.Value,
		PlaceholderText = o.Placeholder or "...",
		PlaceholderColor3 = Theme.SubText,
		TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		ClearTextOnFocus = false,
		Parent = row,
	}, { Corner(8) })
	function obj:Set(v, silent)
		obj.Value = tostring(v)
		box.Text = obj.Value
		if not silent then Fire(tab, o, obj) end
	end
	box.FocusLost:Connect(function() obj:Set(box.Text) end)
	Register(self, o, obj)
	return obj
end

function TabClass:Keybind(o)
	local obj = { Value = o.Default or Enum.KeyCode.E }
	local tab = self
	local row = Row(self, 34)
	RowLabel(row, o.Title or "Keybind").Size = UDim2.new(0.5, 0, 1, 0)
	local btn = Create("TextButton", {
		Size = UDim2.new(0, 100, 0, 28),
		Position = UDim2.new(1, -100, 0.5, -14),
		BackgroundColor3 = Theme.Tab,
		BackgroundTransparency = 0.15,
		Text = obj.Value.Name,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		AutoButtonColor = false,
		Parent = row,
	}, { Corner(8) })
	local listening = false
	btn.MouseButton1Click:Connect(function()
		listening = true
		btn.Text = "..."
	end)
	UserInputService.InputBegan:Connect(function(input, gp)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			obj.Value = input.KeyCode
			btn.Text = input.KeyCode.Name
			if o.Flag then tab.Window.Flags[o.Flag] = obj.Value end
		elseif not gp and not listening and input.KeyCode == obj.Value then
			if o.Callback then task.spawn(o.Callback, obj.Value) end
		end
	end)
	Register(self, o, obj)
	return obj
end

return Bing
