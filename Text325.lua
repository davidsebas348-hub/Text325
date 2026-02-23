local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- PACKS DE EJEMPLO (solo nombres)
local PACKS = {
    ["Adidas Sports"] = {},
    ["Adidas Community"] = {},
    ["Adidas Aura"] = {},
    ["Wicked Popular"] = {},
    ["Elder"] = {},
    ["Zombie"] = {},
    ["Mage"] = {},
    ["Catwalk Glam"] = {},
    ["Astronaut"] = {},
    ["Wicked Dancing Through Life"] = {},
    ["Werewolf"] = {},
    ["Superhero"] = {},
    ["Toy"] = {},
    ["No Boundaries"] = {},
    ["NFL"] = {},
    ["Amazon Unboxed"] = {},
    ["Vampire"] = {},
    ["Ninja"] = {},
    ["Robot"] = {},
    ["Levitation"] = {},
    ["Stylish"] = {},
    ["Bubbly"] = {},
    ["Cartoon"] = {},
}

local animTypes = {"Walk","Run","Jump","Fall","Swim","SwimIdle","Climb","Animation1","Animation2"}

-- Obtener los nombres de los packs de animaciones
local packNames = {}
for name in pairs(PACKS) do
    table.insert(packNames, name)
end
table.sort(packNames)

-- Guarda los packs elegidos por cada tipo de animación
local currentIndexes = {}
for _, anim in ipairs(animTypes) do
    currentIndexes[anim] = 1
end

-- Crear ScreenGui y agregar a PlayerGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimationEditorGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Icono flotante
local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0,50,0,50)
icon.Position = UDim2.new(0,10,0,200)
icon.Text = "Anim"
icon.BackgroundColor3 = Color3.fromRGB(50,50,50)
icon.TextColor3 = Color3.fromRGB(255,255,255)
icon.Parent = screenGui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0,10)

-- GUI principal
local gui = Instance.new("Frame")
gui.Size = UDim2.new(0,420,0,50 + #animTypes*40 + 50)
gui.Position = UDim2.new(0.5,-210,0.5,-(#animTypes*20))
gui.BackgroundColor3 = Color3.fromRGB(25,25,25)
gui.Visible = false
gui.Parent = screenGui
Instance.new("UICorner",gui).CornerRadius = UDim.new(0,12)

-- Drag
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
end
makeDraggable(icon)
makeDraggable(gui)

icon.Activated:Connect(function()
    gui.Visible = not gui.Visible
end)

-- Editor con filas
local labels = {}
for i, anim in ipairs(animTypes) do
    local y = 10 + (i-1)*40
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Size = UDim2.new(0,100,0,32)
    typeLabel.Position = UDim2.new(0,10,0,y)
    typeLabel.BackgroundTransparency = 1
    typeLabel.TextColor3 = Color3.fromRGB(255,255,255)
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.TextSize = 14
    typeLabel.Text = anim
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.Parent = gui

    local animLabel = Instance.new("TextLabel")
    animLabel.Size = UDim2.new(0,180,0,32)
    animLabel.Position = UDim2.new(0,120,0,y)
    animLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
    animLabel.TextColor3 = Color3.fromRGB(255,255,255)
    animLabel.Font = Enum.Font.Gotham
    animLabel.TextSize = 14
    animLabel.Text = packNames[currentIndexes[anim]]
    animLabel.Parent = gui
    labels[anim] = animLabel

    local leftBtn = Instance.new("TextButton")
    leftBtn.Size = UDim2.new(0,30,0,32)
    leftBtn.Position = UDim2.new(0,310,0,y)
    leftBtn.Text = "<"
    leftBtn.Font = Enum.Font.GothamBold
    leftBtn.TextSize = 18
    leftBtn.TextColor3 = Color3.fromRGB(255,255,255)
    leftBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    leftBtn.Parent = gui
    Instance.new("UICorner",leftBtn).CornerRadius = UDim.new(0,6)

    local rightBtn = Instance.new("TextButton")
    rightBtn.Size = UDim2.new(0,30,0,32)
    rightBtn.Position = UDim2.new(0,350,0,y)
    rightBtn.Text = ">"
    rightBtn.Font = Enum.Font.GothamBold
    rightBtn.TextSize = 18
    rightBtn.TextColor3 = Color3.fromRGB(255,255,255)
    rightBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    rightBtn.Parent = gui
    Instance.new("UICorner",rightBtn).CornerRadius = UDim.new(0,6)

    leftBtn.Activated:Connect(function()
        currentIndexes[anim] = currentIndexes[anim]-1
        if currentIndexes[anim]<1 then currentIndexes[anim]=#packNames end
        animLabel.Text = packNames[currentIndexes[anim]]
    end)
    rightBtn.Activated:Connect(function()
        currentIndexes[anim] = currentIndexes[anim]+1
        if currentIndexes[anim]>#packNames then currentIndexes[anim]=1 end
        animLabel.Text = packNames[currentIndexes[anim]]
    end)
end

-- Botón generar código
local genBtn = Instance.new("TextButton")
genBtn.Size = UDim2.new(0,100,0,36)
genBtn.Position = UDim2.new(0,150,0,10 + #animTypes*40)
genBtn.Text = "Generar"
genBtn.Font = Enum.Font.GothamBold
genBtn.TextSize = 16
genBtn.TextColor3 = Color3.fromRGB(255,255,255)
genBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
genBtn.Parent = gui
Instance.new("UICorner",genBtn).CornerRadius = UDim.new(0,8)

genBtn.Activated:Connect(function()
    local code = "getgenv().AnimConfig = {\n"
    for _, anim in ipairs(animTypes) do
        local selectedName = packNames[currentIndexes[anim]]
        code = code .. "    " .. anim .. ' = "' .. selectedName .. '",\n'
    end
    code = code .. "}\n\n"
    code = code .. 'loadstring(game:HttpGet("https://raw.githubusercontent.com/SBSHUB1/Mm2/refs/heads/main/Mm2.lua?nocache="..math.random()))()'
    if setclipboard then
        setclipboard(code)
        print("Código completo copiado ✅")
    else
        print(code)
    end
end)
