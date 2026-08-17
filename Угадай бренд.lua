-- =============================================
-- 🔍 Guess My Brand — Viewer (просмотр выбора противников)
-- Попытка отобразить, что выбрали другие игроки
-- =============================================

local player = game.Players.LocalPlayer

-- Функция для поиска текста в GUI игроков
local function findSelectionText()
    -- Ищем всех игроков
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            -- Проверяем, есть ли у игрока GUI (обычно это PlayerGui)
            local playerGui = plr:FindFirstChild("PlayerGui")
            if playerGui then
                -- Рекурсивно ищем любые TextLabel или TextButton с текстом бренда
                local function searchGUI(obj)
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            local text = child.Text
                            -- Проверяем, похоже ли это на название бренда (можно добавить список известных брендов)
                            if text and #text > 1 and text ~= "" and text ~= " " then
                                print("Игрок " .. plr.Name .. " выбрал: " .. text)
                                -- Можно показать на экране
                                local ScreenGui = player:FindFirstChild("PlayerGui") or Instance.new("ScreenGui")
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(0.3, 0, 0.05, 0)
                                label.Position = UDim2.new(0, 0, 0.2 + (plr.Name:gsub("%W", "") % 10) * 0.05, 0)
                                label.Text = plr.Name .. ": " .. text
                                label.TextColor3 = Color3.fromRGB(255, 255, 0)
                                label.BackgroundTransparency = 1
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 18
                                label.Parent = ScreenGui
                                -- Удаляем через 5 секунд, чтобы не засорять
                                game:GetService("Debris"):AddItem(label, 5)
                            end
                        end
                        -- Рекурсивно обходим глубже
                        searchGUI(child)
                    end
                end
                searchGUI(playerGui)
            end
        end
    end
end

-- Запускаем каждые 2 секунды
while true do
    findSelectionText()
    wait(2)
end
