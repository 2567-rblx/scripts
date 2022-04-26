-- 26.4.2022

local network = require(game:GetService("ReplicatedStorage").SharedModules.Global).Network



local function teleport(inst, cframe)
	local tween = game:GetService("TweenService"):Create(inst, TweenInfo.new(0), {CFrame=cframe})
	tween:Play()
end

local function collectCoins()
	local startFunc = require(game:GetService("ReplicatedStorage").Modules.World.Interactables.CoinHandler).Start
	local collectFunc = debug.getupvalue(startFunc, 3).Collect
	local coins = debug.getupvalue(startFunc, 4)

	for name, tbl in pairs(coins) do
		if tbl.obj and tbl.obj.Parent then-- Don't remove or your coins can go up infinitly
			collectFunc(tbl)
		end
	end
end

-- id 1 == driver || id 2 == passenger
local function findSeat(id)
	local startFunc = require(game:GetService("ReplicatedStorage").Modules.World.Interactables.MouseCarController).Start
	local attemptSitFunc = debug.getupvalue(startFunc, 2).AttemptSit
	local cars = debug.getupvalue(startFunc, 4)

	for carInst, tbl in pairs(cars) do-- loop cause the keys are instances
		attemptSitFunc(nil, tbl.Seats[id])
		break
	end
end



-- collect all coins
collectCoins()

-- take a selfie
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Interactables.SelfieCam.Hitbox.CFrame
repeat
	task.wait(0.5)
until workspace.Interactables.SelfieCam:FindFirstChild("Player")

-- collect all people
for i, proxPrompt in pairs(workspace["Honoree_Hunt"].Hidden:GetDescendants()) do
	if proxPrompt.Name == "ProximityPrompt" then
		teleport(game.Players.LocalPlayer.Character.HumanoidRootPart, proxPrompt.Parent.Parent.CFrame)
		task.wait(0.5)
		fireproximityprompt(proxPrompt)
	end
end

-- enter seats
findSeat(1)
network:FireServer("ExitSeat")
findSeat(2)
network:FireServer("ExitSeat")

-- enter rollercoster
network:FireServer("RollercoasterSit", workspace.Interactables.CoasterCarts.CoasterCart.Mesh.Seat)
