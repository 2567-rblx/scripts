-- Logitech Song Breaker Awards : 9230434873 : 27.6.2022
-- IDoN0t @ v3rmillion.net

local client = game:GetService("Players").LocalPlayer
local network = require(game:GetService("ReplicatedStorage").SharedModules.Global).Network



--// Collect Coins
do
	local startFunc = require(game:GetService("ReplicatedStorage").Modules.World.Interactables.CoinHandler).Start
	local collectFunc = debug.getupvalue(startFunc, 3).Collect
	local coins = debug.getupvalue(startFunc, 4)

	for name, tbl in pairs(coins) do
		if tbl.obj and tbl.obj.Parent then-- Don't remove or your coins can go up infinitly
			collectFunc(tbl)
		end
	end
end



--// Collect People
for i, inst in ipairs(game:GetService("ReplicatedStorage")["Honoree_Hunt"].Hidden:GetChildren()) do-- Makes it so client can collect everyone
	inst.Parent = workspace["Honoree_Hunt"].Hidden
end

for i, npc in ipairs(workspace["Honoree_Hunt"].Hidden:GetChildren()) do-- Collect everyone
	local head = npc:FindFirstChild("Head", true)
	local proxPrompt = head:FindFirstChild("ProximityPrompt", true)

	client.Character.HumanoidRootPart.CFrame = head.CFrame
	task.wait(client:GetNetworkPing() + 0.1)
	fireproximityprompt(proxPrompt)
end



--// Get Selfie
for i, inst in ipairs(workspace.Interactables.SelfieCam:GetChildren()) do-- Remove large players so it's easy to tell once client has taken a selfie
	if inst.Name == "Player" then
		inst:Destroy()
	end
end

client.Character.HumanoidRootPart.CFrame = workspace.Interactables.SelfieCam.Hitbox.CFrame
while true do-- Wait until client has taken a selfie
	if workspace.Interactables.SelfieCam:FindFirstChild("Player") then
		break
	end
	task.wait()
end



--// Enter Rollercoaster
for i, inst in ipairs(workspace.Interactables.CoasterCarts:GetDescendants()) do
	if inst.Name == "Seat" then
		network:FireServer("RollercoasterSit", inst)
	end
end
