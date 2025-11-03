local MODO_CUSTOMIZADO_ID = 1
local FIRMWARE_COPTER = "firmwares/copter.abin"
local FIRMWARE_SUB = "firmwares/sub.abin"
local FIRMWARE_ALVO = "ardupilot.abin"
local TEMPO_ESPERA_MS = 10000

local temporizador_iniciado_ms = 0
local acao_concluida = false
local modo_de_inicio = false

function detectar_tipo_veiculo()
    local modo_atual = vehicle:get_mode()

    if modo_atual == 19 then
        modo_de_inicio = "SUB"
        return "SUB"
    else
        modo_de_inicio = "COPTER"
        return "COPTER"
    end
end

function copiar_arquivo(origem, destino)
    local arquivo_origem = io.open(origem, "rb")
    if not arquivo_origem then
        return false, "Arquivo de origem não encontrado: " .. origem
    end
    
    local conteudo = arquivo_origem:read("*a")
    arquivo_origem:close()
    
    if not conteudo or #conteudo == 0 then
        return false, "Arquivo de origem vazio ou inválido"
    end
    
    local arquivo_destino = io.open(destino, "wb")
    if not arquivo_destino then
        return false, "Não foi possível criar arquivo de destino"
    end
    
    local sucesso_escrita = arquivo_destino:write(conteudo)
    arquivo_destino:close()
    
    if not sucesso_escrita then
        return false, "Falha ao escrever no arquivo de destino"
    end
    
    return true, "Cópia concluída com sucesso"
end

function update()
    if acao_concluida then
        return update, 1000
    end

    local modo_atual = vehicle:get_mode()
    local esta_desarmado = not arming:is_armed()
    local agora_ms = millis()

    if (modo_atual == MODO_CUSTOMIZADO_ID) and esta_desarmado then
        if temporizador_iniciado_ms == 0 then
            temporizador_iniciado_ms = agora_ms
            gcs:send_text(0, "Condições atendidas. Iniciando timer 10s...")
        else
            local tempo_decorrido = agora_ms - temporizador_iniciado_ms
            
            if tempo_decorrido >= TEMPO_ESPERA_MS then
                gcs:send_text(0, "10s completos. Detectando veículo...")
                
                local firmware_origem = nil
                
                if modo_de_inicio == "SUB" then
                    firmware_origem = FIRMWARE_SUB
                    gcs:send_text(0, "Veículo detectado: SUB")
                else
                    firmware_origem = FIRMWARE_COPTER
                    gcs:send_text(0, "Veículo detectado: COPTER")
                end
                
                if not io.open(firmware_origem, "r") then
                    gcs:send_text(0, "ERRO: Arquivo não encontrado: " .. firmware_origem)
                    acao_concluida = true
                    return update, 1000
                end

                gcs:send_text(0, "Copiando: " .. firmware_origem .. " -> " .. FIRMWARE_ALVO)
                local sucesso, erro = copiar_arquivo(firmware_origem, FIRMWARE_ALVO)
                
                if sucesso then
                    gcs:send_text(0, "SUCESSO! Firmware copiado para " .. FIRMWARE_ALVO)
                else
                    gcs:send_text(0, "FALHA: " .. tostring(erro))
                end
                
                acao_concluida = true
            end
        end
    else
        if temporizador_iniciado_ms > 0 then
            gcs:send_text(0, "Condições interrompidas. Timer resetado.")
            temporizador_iniciado_ms = 0
        end
    end

    return update, 100
end

gcs:send_text(0, "LUA SCRIPT LOADED.")

local modo_inicial = vehicle:get_mode()
local tipo_inicial = detectar_tipo_veiculo()
gcs:send_text(0, "Modo inicial: " .. tostring(modo_inicial) .. ", Tipo inicial: " .. tipo_inicial)

return update, 1000