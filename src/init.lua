local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Class = require(ReplicatedStorage.Class)
local CharacterState = require(script.CharacterState)

local buildRigFromAttachments = require(script.buildRigFromAttachments)

local LUANOIDS = {
	Default = require(script.Luanoids.RootLuanoid),
	L15 = require(script.Luanoids.L15),
}

local PRIORITY = Enum.AnimationPriority
local DOGU15_RIG = game:GetService("InsertService"):LoadAsset(6324529033).R15Rig
local L15_ANIMATIONS = {
    Run = {
		AnimationId = "rbxassetid://6764590710",
		Priority = PRIORITY.Movement
	},
	Walk = {
		AnimationId = "rbxassetid://6764591871",
		Priority = PRIORITY.Movement
	},
	Aiming = {
		AnimationId = "rbxassetid://6774025850",
		Priority = PRIORITY.Action
	},
	Idling = {
		AnimationId = "http://www.roblox.com/asset/?id=507766388", -- Looking around: 507766666
		Priority = PRIORITY.Idle
	},
	Jumping = {
		AnimationId = "http://www.roblox.com/asset/?id=507765000",
		Priority = PRIORITY.Movement
	},
	Walking = {
		AnimationId = "http://www.roblox.com/asset/?id=913402848",
		Priority = PRIORITY.Movement
	},
}

local function makeLuanoid(luanoid, params)
	luanoid = luanoid()

	if params.Parent then
		luanoid.Character.Parent = params.Parent
	end
	if params.Rig then
		luanoid:SetRig(params.Rig)
		for _,basePart in ipairs(luanoid.Character:GetDescendants()) do
			if basePart:IsA("BasePart") then
				basePart.Anchored = false
			end
		end
	end
	if params.CFrame then
		luanoid.RootPart.CFrame = params.CFrame
	end

	return luanoid
end

local LuanoidService = Class() do
	function LuanoidService:init()
		self.CharacterState = CharacterState
	end

	function LuanoidService:MakeLuanoid(params)
		return makeLuanoid(LUANOIDS.Default, params)
	end

	function LuanoidService:MakeL15(params)
		params.Rig = DOGU15_RIG:Clone()

		local luanoid = makeLuanoid(LUANOIDS.L15, params)
		for animationName, animationData in pairs(L15_ANIMATIONS) do
			luanoid:LoadAnimation(
				animationData.Animation,
				animationName,
				{
					Priority = animationData[2],
				}
			)
		end

		return luanoid
	end

	function LuanoidService:BuildRigFromAttachments(rig)
		return buildRigFromAttachments(rig)
	end
end

for _,animationData in pairs(L15_ANIMATIONS) do
	local animation = Instance.new("Animation")
	animation.AnimationId = animationData.AnimationId
	animationData.Animation = animation
end

return LuanoidService