local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Class = require(ReplicatedStorage.Class)
local Luanoid = require(script.Parent.RootLuanoid)
local RagdollRigging = require(script.RagdollRigging)
local CharacterState = require(script.Parent.Parent.CharacterState)
local L15StateController = require(script.Parent.Parent.StateControllers.L15StateController)
local IKSolver = require(script.Parent.Parent.IKSolver)
local applyHumanoidDescription = require(script.applyHumanoidDescription)

local L15 = Class():addparent(Luanoid)

function L15:init(params)
    params = params or {}
    params.StateController = params.StateController or L15StateController

    self.__baseclass.__baseclass.init(self, params)

    self.Solvers = {}
end

function L15:SetRig(rig)
    self.__baseclass.__baseclass.SetRig(self, rig)

    local character = self.Character
    RagdollRigging.createRagdollJoints(character, Enum.HumanoidRigType.R15)

    self.Solvers.LeftArm = IKSolver(
        character.UpperTorso,
        character.LeftUpperArm.LeftShoulder,
        character.LeftLowerArm.LeftElbow,
        character.LeftHand.LeftWrist
    )
    self.Solvers.RightArm = IKSolver(
        character.UpperTorso,
        character.RightUpperArm.RightShoulder,
        character.RightLowerArm.RightElbow,
        character.RightHand.RightWrist
    )
    self.Solvers.LeftLeg = IKSolver(
        character.LowerTorso,
        character.LeftUpperLeg.LeftHip,
        character.LeftLowerLeg.LeftKnee,
        character.LeftFoot.LeftAnkle
    )
    self.Solvers.RightLeg = IKSolver(
        character.LowerTorso,
        character.RightUpperLeg.RightHip,
        character.RightLowerLeg.RightKnee,
        character.RightFoot.RightAnkle
    )

    self.Solvers.LeftLeg.Inverted = true
    self.Solvers.RightLeg.Inverted = true
end

function L15:ApplyDescription(humanoidDescription)
    applyHumanoidDescription(self.Character, humanoidDescription)
end

function L15:Ragdoll()
    self:ChangeState(CharacterState.Ragdoll)
end

function L15:ToggleMotors(enable)
    RagdollRigging.toggleMotors(self.Character, enable, Enum.HumanoidRigType.R15)
end

return L15