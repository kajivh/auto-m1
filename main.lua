-- ============================================
-- AUTO M1 - SEVEN SINS BTTG
-- Script completo com interface e controle
-- ============================================

-- ============================================
-- 1. CONFIGURAÇÕES
-- ============================================

local CONFIG = {
    -- Intervalos (em segundos)
    INTERVALO_M1 = 0.12,        -- Intervalo padrão entre cliques
    INTERVALO_MINIMO = 0.08,    -- Mínimo para modo aleatório
    INTERVALO_MAXIMO = 0.18,    -- Máximo para modo aleatório
    
    -- Modos
    MODO_ALEATORIO = true,      -- true = variação natural, false = fixo
    AUTO_ATIVAR = false,        -- true = inicia automaticamente
    
    -- Atalhos
    TECLA_ATALHO = "F1",        -- Tecla para ativar/desativar
    
    -- Posição da UI
    POSICAO_X = 0.02,           -- 0.02 = canto esquerdo
    POSICAO_Y = 0.5,            -- 0.5 = centro vertical
}

-- ============================================
-- 2. SERVIÇOS E VARIÁVEIS
-- ============================================

local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

if not player then
    warn("[AUTO M1] ❌ Jogador não encontrado!")
    return
end

-- Estado do script
local estado = {
    ativo = false,          -- Script está rodando?
    executando = false,     -- Ciclo está executando?
    cliques = 0,           -- Total de cliques realizados
    pausado = false,       -- Está pausado?
    tempo_inicio = 0,      -- Tempo de início
}

-- ============================================
-- 3. FUNÇÕES DE AÇÃO
-- ============================================

-- Função para realizar clique
local function realizarClique()
    pcall(function()
        local evento = {
            KeyCode = Enum.KeyCode.Button1,
            UserInputType = Enum.UserInputType.MouseButton1,
        }
        UIS:SetKeyDown(evento)
        task.wait(0.02)
        UIS:SetKeyUp(evento)
        estado.cliques = estado.cliques + 1
    end)
end

-- Função para calcular delay
local function calcularDelay()
    if CONFIG.MODO_ALEATORIO then
        return CONFIG.INTERVALO_MINIMO + math.random() * (CONFIG.INTERVALO_MAXIMO - CONFIG.INTERVALO_MINIMO)
    else
        return CONFIG.INTERVALO_M1
    end
end

-- ============================================
-- 4. CICLO PRINCIPAL
-- ============================================

local function cicloM1()
    print("[AUTO M1] 🔄 Ciclo iniciado!")
    
    while estado.ativo do
        if not estado.pausado then
            realizarClique()
            
            local delay = calcularDelay()
            local start = tick()
            
            while estado.ativo and not estado.pausado and tick() - start < delay do
                task.wait(0.01)
            end
        else
            task.wait(0.1)
        end
    end
    
    estado.executando = false
    print("[AUTO M1] ⏹️ Ciclo finalizado!")
end

-- ============================================
-- 5. FUNÇÕES DE CONTROLE
-- ============================================

local function iniciar()
    if estado.ativo then
        print("[AUTO M1] ⚠️ Já está em execução!")
        return
    end
    
    estado.ativo = true
    estado.executando = true
    estado.cliques = 0
    estado.tempo_inicio = tick()
    estado.pausado = false
    
    print("[AUTO M1] ▶️ Iniciado!")
    print("[AUTO M1] ⚡ Intervalo: " .. CONFIG.INTERVALO_M1 .. "s")
    
    task.spawn(cicloM1)
    atualizarUI()
end

local function parar()
    if not estado.ativo then
        print("[AUTO M1] ⚠️ Não está em execução!")
        return
    end
    
    estado.ativo = false
    estado.executando = false
    
    local tempo_total = tick() - estado.tempo_inicio
    print(string.format("[AUTO M1] ⏹️ Parado! Cliques: %d | Tempo: %.2fs", 
        estado.cliques, tempo_total))
    
    atualizarUI()
end

local function toggle()
    if estado.ativo then
        parar()
    else
        iniciar()
    end
end

local function pausar()
    if not estado.ativo then
        print("[AUTO M1] ⚠️ Não está em execução!")
        return
    end
    
    estado.pausado = not estado.pausado
    
    if estado.pausado then
        print("[AUTO M1] ⏸️ Pausado!")
    else
        print("[AUTO M1] ▶️ Retomado!")
    end
    
    atualizarUI()
end

-- ============================================
-- 6. INTERFACE
-- ============================================

local ui = nil

local function criarInterface()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoM1GUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    -- Frame principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 180)
    frame.Position = UDim2.new(CONFIG.POSICAO_X, 0, CONFIG.POSICAO_Y, -90)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    frame.ClipsDescendants = true
    frame.ZIndex = 10
    
    -- Arredondamento
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Sombra
    local shadow = Instance.new("UIShadow")
    shadow.Parent = frame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 2)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    title.BackgroundTransparency = 0.3
    title.Text = "⚡ AUTO M1"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "StatusLabel"
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0.16, 0)
    status.BackgroundTransparency = 1
    status.Text = "⏹️ PARADO"
    status.TextColor3 = Color3.fromRGB(200, 50, 50)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.TextScaled = true
    status.Parent = frame
    
    -- Contador
    local count = Instance.new("TextLabel")
    count.Name = "CountLabel"
    count.Size = UDim2.new(1, 0, 0, 18)
    count.Position = UDim2.new(0, 0, 0.28, 0)
    count.BackgroundTransparency = 1
    count.Text = "🔄 0"
    count.TextColor3 = Color3.fromRGB(180, 180, 200)
    count.TextSize = 11
    count.Font = Enum.Font.Gotham
    count.TextScaled = true
    count.Parent = frame
    
    -- Botão Toggle (Iniciar/Parar)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0.85, 0, 0, 30)
    toggleBtn.Position = UDim2.new(0.075, 0, 0.42, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    toggleBtn.BackgroundTransparency = 0.2
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "▶ INICIAR"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextScaled = true
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 11
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn
    
    -- Botão Pausar
    local pauseBtn = Instance.new("TextButton")
    pauseBtn.Name = "PauseBtn"
    pauseBtn.Size = UDim2.new(0.4, 0, 0, 25)
    pauseBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
    pauseBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
    pauseBtn.BackgroundTransparency = 0.2
    pauseBtn.BorderSizePixel = 0
    pauseBtn.Text = "⏸ PAUSAR"
    pauseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    pauseBtn.TextSize = 10
    pauseBtn.Font = Enum.Font.GothamBold
    pauseBtn.TextScaled = true
    pauseBtn.AutoButtonColor = false
    pauseBtn.ZIndex = 11
    
    local pauseCorner = Instance.new("UICorner")
    pauseCorner.CornerRadius = UDim.new(0, 6)
    pauseCorner.Parent = pauseBtn
    
    -- Botão Reset
    local resetBtn = Instance.new("TextButton")
    resetBtn.Name = "ResetBtn"
    resetBtn.Size = UDim2.new(0.4, 0, 0, 25)
    resetBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    resetBtn.BackgroundTransparency = 0.2
    resetBtn.BorderSizePixel = 0
    resetBtn.Text = "↺ RESET"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.TextSize = 10
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextScaled = true
    resetBtn.AutoButtonColor = false
    resetBtn.ZIndex = 11
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 6)
    resetCorner.Parent = resetBtn
    
    -- Informações
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 16)
    info.Position = UDim2.new(0, 0, 0.88, 0)
    info.BackgroundTransparency = 1
    info.Text = "⌨️ " .. CONFIG.TECLA_ATALHO .. " | Delay: " .. CONFIG.INTERVALO_M1 .. "s"
    info.TextColor3 = Color3.fromRGB(150, 150, 180)
    info.TextSize = 9
    info.Font = Enum.Font.Gotham
    info.TextScaled = true
    info.Parent = frame
    
    -- Adicionar à GUI
    toggleBtn.Parent = frame
    pauseBtn.Parent = frame
    resetBtn.Parent = frame
    frame.Parent = screenGui
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    return {
        ScreenGui = screenGui,
        Frame = frame,
        ToggleBtn = toggleBtn,
        PauseBtn = pauseBtn,
        ResetBtn = resetBtn,
        StatusLabel = status,
        CountLabel = count,
    }
end

-- ============================================
-- 7. ATUALIZAR UI
-- ============================================

local function atualizarUI()
    if not ui then return end
    
    if estado.ativo then
        if estado.pausado then
            ui.StatusLabel.Text = "⏸️ PAUSADO"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 50)
            ui.ToggleBtn.Text = "⏹ PARAR"
            ui.ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            ui.StatusLabel.Text = "▶️ EXECUTANDO"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 80)
            ui.ToggleBtn.Text = "⏹ PARAR"
            ui.ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    else
        ui.StatusLabel.Text = "⏹️ PARADO"
        ui.StatusLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        ui.ToggleBtn.Text = "▶ INICIAR"
        ui.ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end
    
    ui.CountLabel.Text = "🔄 " .. estado.cliques
end

-- ============================================
-- 8. CONFIGURAR EVENTOS
-- ============================================

local function configurarEventos()
    if not ui then return end
    
    -- Botão Toggle
    ui.ToggleBtn.MouseButton1Click:Connect(function()
        toggle()
        atualizarUI()
    end)
    
    ui.ToggleBtn.TouchTap:Connect(function()
        ui.ToggleBtn.MouseButton1Click:Fire()
    end)
    
    -- Botão Pausar
    ui.PauseBtn.MouseButton1Click:Connect(function()
        pausar()
        atualizarUI()
    end)
    
    ui.PauseBtn.TouchTap:Connect(function()
        ui.PauseBtn.MouseButton1Click:Fire()
    end)
    
    -- Botão Reset
    ui.ResetBtn.MouseButton1Click:Connect(function()
        if estado.ativo then
            parar()
        end
        estado.cliques = 0
        atualizarUI()
        print("[AUTO M1] 🔄 Resetado!")
    end)
    
    ui.ResetBtn.TouchTap:Connect(function()
        ui.ResetBtn.MouseButton1Click:Fire()
    end)
    
    -- Atalho do teclado
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[CONFIG.TECLA_ATALHO] then
            toggle()
            atualizarUI()
        end
    end)
end

-- ============================================
-- 9. ATUALIZAÇÃO PERIÓDICA DA UI
-- ============================================

local function loopAtualizacao()
    while true do
        task.wait(0.5)
        if ui then
            ui.CountLabel.Text = "🔄 " .. estado.cliques
        end
    end
end

-- ============================================
-- 10. INICIALIZAÇÃO
-- ============================================

local function iniciarScript()
    -- Remover GUI antiga
    local oldGui = player.PlayerGui:FindFirstChild("AutoM1GUI")
    if oldGui then oldGui:Destroy() end
    
    -- Criar interface
    ui = criarInterface()
    if not ui then
        warn("[AUTO M1] ❌ Falha ao criar interface!")
        return
    end
    
    -- Configurar eventos
    configurarEventos()
    task.spawn(loopAtualizacao)
    
    -- Exportar funções
    _G.AutoM1 = {
        Iniciar = iniciar,
        Parar = parar,
        Toggle = toggle,
        Pausar = pausar,
        Status = function()
            return {
                ativo = estado.ativo,
                pausado = estado.pausado,
                cliques = estado.cliques,
                executando = estado.executando,
            }
        end,
        Configurar = function(config)
            for k, v in pairs(config) do
                if CONFIG[k] ~= nil then
                    CONFIG[k] = v
                end
            end
            print("[AUTO M1] ✅ Configurações atualizadas!")
        end
    }
    
    print("========================================")
    print("   ⚡ AUTO M1 - SEVEN SINS BTTG       ")
    print("========================================")
    print("   ✅ Interface criada!")
    print("   ⚡ Delay: " .. CONFIG.INTERVALO_M1 .. "s")
    print("   ⌨️ Atalho: " .. CONFIG.TECLA_ATALHO)
    print("   🎲 Modo aleatório: " .. tostring(CONFIG.MODO_ALEATORIO))
    print("========================================")
    
    -- Auto ativar
    if CONFIG.AUTO_ATIVAR then
        task.wait(1)
        iniciar()
        atualizarUI()
    end
end

-- ============================================
-- 11. EXECUTAR
-- ============================================

pcall(iniciarScript)

print("")
print("╔═══════════════════════════════════════╗")
print("║   ⚡ AUTO M1 - SEVEN SINS BTTG      ║")
print("╠═══════════════════════════════════════╣")
print("║   ✅ Script carregado!               ║")
print("║   📌 Interface no canto esquerdo    ║")
print("║   ⌨️ Pressione " .. CONFIG.TECLA_ATALHO .. " para toggle")
print("╚═══════════════════════════════════════╝")
print("")

print("[AUTO M1] 📋 Comandos:")
print("  _G.AutoM1.Iniciar()")
print("  _G.AutoM1.Parar()")
print("  _G.AutoM1.Toggle()")
print("  _G.AutoM1.Pausar()")
print("  _G.AutoM1.Status()")
print("  _G.AutoM1.Configurar({ INTERVALO_M1 = 0.15 })")
print("")
