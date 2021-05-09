local StateController = require(script.Parent.RootStateController)
local CharacterState = require(script.Parent.Parent.CharacterState)
local RagdollHandler = require(script.Ragdoll)

local DEFAULT_LOGIC_HANDLER = require(script.logic)

local L15StateController = StateController:convert({})

function L15StateController:init(luanoid)
    self.__baseclass.__baseclass.init(self, luanoid)

    self.Logic = DEFAULT_LOGIC_HANDLER

    self.StateHandlers[CharacterState.Ragdoll] = RagdollHandler
end

function L15StateController:step(dt)
    self.__baseclass.__baseclass.step(self, dt)

    local luanoid = self.Luanoid
    local rootPart = self.Luanoid.RootPart
    local solvers = luanoid.Solvers
    local state = luanoid.State

    if solvers.LeftArm.Goal then
        solvers.LeftArm:Solve()
    end
    if solvers.RightArm.Goal then
        solvers.RightArm:Solve()
    end

    if solvers.LeftLeg.Goal then
        solvers.LeftLeg:Solve()
    elseif state == CharacterState.Idling or state == CharacterState.Walking then
        local leftLegResult = self:CastCollideOnly((rootPart.CFrame * CFrame.new(-0.5, 0, 0)).p, Vector3.new(0, -3, 0))
        if leftLegResult then
            solvers.LeftLeg:Solve(leftLegResult.Position)
            solvers.LeftLeg.Goal = nil
        end
    end
    if solvers.RightLeg.Goal then
        solvers.RightLeg:Solve()
    elseif state == CharacterState.Idling or state == CharacterState.Walking then
        local rightLegResult = self:CastCollideOnly((rootPart.CFrame * CFrame.new(0.5, 0, 0)).p, Vector3.new(0, -3, 0))
        if rightLegResult then
            solvers.RightLeg:Solve(rightLegResult.Position)
            solvers.RightLeg.Goal = nil
        end
    end
end

return L15StateController