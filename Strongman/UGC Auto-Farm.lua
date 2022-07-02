-- Game         : Strongman | 6766156863
-- Last Updated : 2.7.2022 (day.month.year)
-- Author       : IDoN0t (v3rmillion.net)

local client = game:GetService("Players").LocalPlayer
local clientDraggables = workspace.PlayerDraggables[client.UserId]
local holidayCoinLabel = client.PlayerGui.ParticleOverlay.ResourceHolder.TopHolidayContainer.CoinCounter.TextLabel


local function firetouch(toucher, toTouch)
	firetouchinterest(toucher, toTouch, 0)
	firetouchinterest(toucher, toTouch, 1)
end



local function sellAll()
	for i, inst in ipairs(clientDraggables:GetChildren()) do
		firetouch(inst, workspace.Areas.Area1.Exit.Goal)
	end
end


-- Get trophy cause they randomize names
local trophyProxPrompt; do
	for i, inst in ipairs(workspace.Areas.Area1.DraggableItems:GetChildren()) do
		if inst.ClassName == "MeshPart" and inst.MeshId == "rbxassetid://9842961636" then
			trophyProxPrompt = inst.InteractionPoint.ProximityPrompt
		end
	end
end


-- So you can collect the trophy while not moving anywhere
client.Character.HumanoidRootPart.CFrame = trophyProxPrompt.Parent.CFrame + Vector3.new(0, 5, 0)
client.Character.HumanoidRootPart.Anchored = true


shared.loop = true
while shared.loop == true do
	if tonumber(holidayCoinLabel.Text) > 300 then
		if game:GetService("ReplicatedStorage").TGSHoliday_PurchaseItemRemote:InvokeServer(6) == true then-- Incase it goes fucky
			warn("Successfully purchased ugc")
			break
		else
			warn("Failed ugc purchase")
			task.wait(0.1)
		end
	end

	fireproximityprompt(trophyProxPrompt)
	sellAll()
	task.wait(0.05)
end
