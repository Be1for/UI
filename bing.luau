--[[
	Bing UI Library для Roblox
	Telegram: t.me/pasterlua
	Стиль: тёмно-синее меню, вертикальные вкладки слева, большой логотип "Bing"
	Компоненты: Tab, Section, Label, Button, Toggle, Slider, Dropdown (Multi), Input, Keybind, Notify
]]

local Bing = { Version = "1.0.0", Telegram = "t.me/pasterlua" }

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local Theme = {
	Background  = Color3.fromRGB(9, 14, 36),
	Sidebar     = Color3.fromRGB(11, 18, 48),
	Element     = Color3.fromRGB(16, 30, 84),
	ElementHover= Color3.fromRGB(22, 44, 116),
	BoxOff      = Color3.fromRGB(10, 20, 62),
	Tab         = Color3.fromRGB(20, 62, 168),
	TabActive   = Color3.fromRGB(34, 112, 252),
	Accent      = Color3.fromRGB(40, 130, 255),
	Text        = Color3.fromRGB(222, 234, 255),
	SubText     = Color3.fromRGB(140, 166, 222),
	Title       = Color3.fromRGB(150, 196, 255),
	Stroke      = Color3.fromRGB(40, 72, 168),
}
Bing.Theme = Theme

-- ========= Хелперы =========
local function Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function Corner(r) return Create("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function Stroke(color, t) return Create("UIStroke", { Color = color, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end
local function Pad(l, t, r, b)
	return Create("UIPadding", { PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b) })
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

local function Row(page, height)
	local row = Create("Frame", {
		Size = UDim2.new(1, 0, 0, height or 34),
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Parent = page,
	}, { Corner(8) })
	return row
end

local function RowLabel(row, text, x)
	return Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, x or 12, 0, 0),
		Size = UDim2.new(1, -(x or 12) - 12, 0, 34),
		Text = text or "",
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		Parent = row,
	})
end

local function Hover(row, btn)
	btn.MouseEnter:Connect(function() Tween(row, { BackgroundColor3 = Theme.ElementHover }) end)
	btn.MouseLeave:Connect(function() Tween(row, { BackgroundColor3 = Theme.Element }) end)
end

-- ========= Классы =========
local WindowClass = {}; WindowClass.__index = WindowClass
local TabClass    = {}; TabClass.__index    = TabClass

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

-- ========= Окно =========
function Bing:CreateWindow(opts)
	opts = opts or {}
	local title    = opts.Title or "Bing"
	local size     = opts.Size or UDim2.fromOffset(600, 360)
	local tgText   = opts.Telegram or Bing.Telegram
	local toggleKey= opts.ToggleKey or Enum.KeyCode.RightShift

	local gui = Create("ScreenGui", {
		Name = "BingUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
	})
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	gui.Parent = GetParent()

	local main = Create("Frame", {
		Name = "Main", Size = size, Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Parent = gui,
	}, {
		Corner(12), Stroke(Theme.Stroke, 1),
		Create("UIGradient", {
			Rotation = 55,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 13, 34)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(14, 30, 92)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 40, 130)),
			}),
		}),
	})

	-- Сайдбар
	local sidebar = Create("Frame", {
		Size = UDim2.new(0, 150, 1, 0), BackgroundTransparency = 1, Parent = main,
	})
	local logo = Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 56), Position = UDim2.new(0, 0, 0, 6), BackgroundTransparency = 1,
		Text = "Bing", TextColor3 = Theme.Title, Font = Enum.Font.GothamBold, TextSize = 40, Parent = sidebar,
	})
	Create("Frame", { -- разделитель под логотипом
		Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 0, 68), BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0, Parent = sidebar,
	})
	local tabList = Create("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -86), Position = UDim2.new(0, 10, 0, 78), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

	-- Вертикальная линия между сайдбаром и контентом
	Create("Frame", {
		Size = UDim2.new(0, 1, 1, -24), Position = UDim2.new(0, 150, 0, 12), BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0, Parent = main,
	})

	-- Шапка контента с Telegram
	local header = Create("Frame", {
		Size = UDim2.new(1, -151, 0, 40), Position = UDim2.new(0, 151, 0, 0), BackgroundTransparency = 1, Parent = main,
	})
	local tg = Create("TextButton", {
		Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1,
		Text = "TG: " .. tgText, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.GothamMedium, TextSize = 14, AutoButtonColor = false, Parent = header,
	})
	tg.MouseButton1Click:Connect(function()
		if setclipboard then pcall(setclipboard, "https://" .. tgText) end
	end)

	-- Контейнер страниц
	local pages = Create("Frame", {
		Size = UDim2.new(1, -171, 1, -52), Position = UDim2.new(0, 161, 0, 44), BackgroundTransparency = 1,
		ClipsDescendants = true, Parent = main,
	})

	MakeDraggable(main, main)

	-- Уведомления
	local notifyHolder = Create("Frame", {
		Size = UDim2.new(0, 260, 1, -20), Position = UDim2.new(1, -270, 0, 10), BackgroundTransparency = 1, Parent = gui,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local window = setmetatable({
		Gui = gui, Main = main, TabList = tabList, Pages = pages, NotifyHolder = notifyHolder,
		Tabs = {}, Flags = {}, Options = {}, Current = nil,
	}, WindowClass)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == toggleKey then window:Toggle() end
	end)

	-- Плавающая кнопка (для телефона)
	if opts.ToggleButton ~= false then
		local fb = Create("TextButton", {
			Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 12, 0.4, 0), BackgroundColor3 = Theme.TabActive,
			Text = "B", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 22, AutoButtonColor = true, Parent = gui,
		}, { Corner(20) })
		fb.MouseButton1Click:Connect(function() window:Toggle() end)
	end

	return window
end

function WindowClass:Toggle(state)
	if state == nil then state = not self.Main.Visible end
	self.Main.Visible = state
end

function WindowClass:Destroy() self.Gui:Destroy() end

function WindowClass:SetTelegram(text) end -- зарезервировано

function WindowClass:Notify(o)
	o = o or {}
	local card = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = self.NotifyHolder,
	}, { Corner(10), Stroke(Theme.Accent, 1), Pad(12, 6, 12, 6) })
	Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = o.Title or "Bing", TextColor3 = Theme.Title,
		Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
	})
	Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1, Text = o.Content or "",
		TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = card,
	})
	task.delay(o.Duration or 4, function() if card then card:Destroy() end end)
end

-- ========= Вкладки =========
function WindowClass:Tab(o)
	o = o or {}
	local btn = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Tab, Text = o.Title or "Tab", TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium, TextSize = 14, AutoButtonColor = false, LayoutOrder = #self.Tabs + 1, Parent = self.TabList,
	}, { Corner(8) })

	local page = Create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = self.Pages,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }), Pad(0, 0, 6, 4) })

	local tab = setmetatable({ Window = self, Button = btn, Page = page }, TabClass)
	table.insert(self.Tabs, tab)

	btn.MouseButton1Click:Connect(function() self:Select(tab) end)
	if not self.Current then self:Select(tab) end
	return tab
end

function WindowClass:Select(tab)
	for _, t in ipairs(self.Tabs) do
		local active = (t == tab)
		t.Page.Visible = active
		Tween(t.Button, { BackgroundColor3 = active and Theme.TabActive or Theme.Tab })
	end
	self.Current = tab
end

-- ========= Элементы =========
function TabClass:Section(text)
	return Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = (text or ""):upper(), TextColor3 = Theme.SubText,
		Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Page,
	}, { Pad(4, 0, 0, 0) })
end

function TabClass:Label(text)
	local row = Row(self.Page, 30)
	local lbl = RowLabel(row, text)
	lbl.Size = UDim2.new(1, -24, 1, 0)
	lbl.TextColor3 = Theme.SubText
	return { Set = function(_, t) lbl.Text = t end }
end

function TabClass:Button(o)
	local row = Row(self.Page, 34)
	local btn = Create("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = o.Title or "Button", TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium, TextSize = 14, Parent = row,
	})
	Hover(row, btn)
	btn.MouseButton1Click:Connect(function()
		Tween(row, { BackgroundColor3 = Theme.TabActive }, 0.08)
		task.delay(0.12, function() Tween(row, { BackgroundColor3 = Theme.Element }) end)
		if o.Callback then task.spawn(o.Callback) end
	end)
end

function TabClass:Toggle(o)
	local obj = { Value = o.Default == true }
	local row = Row(self.Page, 34)
	local box = Create("Frame", {
		Size = UDim2.fromOffset(22, 22), Position = UDim2.new(0, 8, 0.5, -11), BackgroundColor3 = Theme.BoxOff, Parent = row,
	}, { Corner(6), Stroke(Theme.Stroke, 1) })
	local check = Create("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "✓", TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold, TextSize = 16, TextTransparency = 1, Parent = box,
	})
	RowLabel(row, o.Title or "Toggle", 40)
	local btn = Create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row })
	Hover(row, btn)

	local function render()
		Tween(box, { BackgroundColor3 = obj.Value and Theme.Accent or Theme.BoxOff })
		Tween(check, { TextTransparency = obj.Value and 0 or 1 })
	end
	local tab = self
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
	local row = Row(self.Page, 50)
	local lbl = RowLabel(row, o.Title or "Slider")
	lbl.Size = UDim2.new(1, -24, 0, 28)
	local val = Create("TextLabel", {
		Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1,
		TextColor3 = Theme.Title, TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.GothamBold, TextSize = 13, Parent = row,
	})
	local bar = Create("Frame", {
		Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = Theme.BoxOff, Parent = row,
	}, { Corner(3) })
	local fill = Create("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Accent, Parent = bar }, { Corner(3) })

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
	local values = o.Values or {}
	local multi = o.Multi == true
	local tab = self
	local obj = { Value = multi and {} or (o.Default or nil), Values = values }
	if multi and type(o.Default) == "table" then
		for _, v in ipairs(o.Default) do obj.Value[v] = true end
	end

	local HEADER = 34
	local holder = Create("Frame", {
		Size = UDim2.new(1, 0, 0, HEADER), BackgroundColor3 = Theme.Element, ClipsDescendants = true, BorderSizePixel = 0, Parent = self.Page,
	}, { Corner(8) })
	local head = Create("TextButton", { Size = UDim2.new(1, 0, 0, HEADER), BackgroundTransparency = 1, Text = "", Parent = holder })
	Hover(holder, head)
	local title = Create("TextLabel", {
		Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Font = Enum.Font.GothamMedium, TextSize = 14, Parent = head,
	})
	local arrow = Create("TextLabel", {
		Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Text = "v",
		TextColor3 = Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 14, Parent = head,
	})
	local list = Create("ScrollingFrame", {
		Size = UDim2.new(1, -12, 0, 0), Position = UDim2.new(0, 6, 0, HEADER + 2), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = holder,
	}, { Create("UIListLayout", { Padding = UDim.new(0, 2) }) })

	local opened = false
	local buttons = {}

	local function selectedList()
		local t = {}
		for _, v in ipairs(values) do if obj.Value[v] then table.insert(t, v) end end
		return t
	end

	local function render()
		local shown
		if multi then
			local s = selectedList()
			shown = #s > 0 and table.concat(s, ", ") or "—"
		else
			shown = obj.Value ~= nil and tostring(obj.Value) or "—"
		end
		title.Text = (o.Title or "Dropdown") .. ": " .. shown
		for v, b in pairs(buttons) do
			local on = multi and obj.Value[v] or (not multi and obj.Value == v)
			Tween(b, { BackgroundColor3 = on and Theme.TabActive or Theme.Tab })
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
		list.Size = UDim2.new(1, -12, 0, h)
		Tween(holder, { Size = UDim2.new(1, 0, 0, opened and (HEADER + h + 8) or HEADER) })
		arrow.Text = opened and "^" or "v"
	end

	local function build()
		for _, b in pairs(buttons) do b:Destroy() end
		buttons = {}
		for _, v in ipairs(values) do
			local b = Create("TextButton", {
				Size = UDim2.new(1, -6, 0, 28), BackgroundColor3 = Theme.Tab, Text = tostring(v), TextColor3 = Theme.Text,
				Font = Enum.Font.Gotham, TextSize = 13, AutoButtonColor = false, Parent = list,
			}, { Corner(6) })
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
	function obj:Get() return multi and selectedList() or obj.Value end

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
	local row = Row(self.Page, 34)
	RowLabel(row, o.Title or "Input")
	local box = Create("TextBox", {
		Size = UDim2.new(0.5, -12, 0, 24), Position = UDim2.new(0.5, 0, 0.5, -12), BackgroundColor3 = Theme.BoxOff,
		Text = obj.Value, PlaceholderText = o.Placeholder or "...", PlaceholderColor3 = Theme.SubText, TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false, Parent = row,
	}, { Corner(6), Stroke(Theme.Stroke, 1) })
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
	local row = Row(self.Page, 34)
	RowLabel(row, o.Title or "Keybind")
	local btn = Create("TextButton", {
		Size = UDim2.new(0, 90, 0, 24), Position = UDim2.new(1, -100, 0.5, -12), BackgroundColor3 = Theme.Tab,
		Text = obj.Value.Name, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 13, Parent = row,
	}, { Corner(6) })
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
