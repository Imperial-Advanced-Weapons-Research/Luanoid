-- Credit: https://devforum.roblox.com/t/2-joint-2-limb-inverse-kinematics/252399

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Class = require(ReplicatedStorage.Class)

local function solve(originCF, targetPos, l1, l2, inverse)
    local angleMultiplier = inverse and -1 or 1

    -- build intial values for solving
    local localized = originCF:pointToObjectSpace(targetPos)
    local localizedUnit = localized.unit
    local l3 = localized.magnitude
    -- build a "rolled" planeCF for a more natural arm look
    local axis = Vector3.new(0, 0, -1):Cross(localizedUnit)
    local angle = math.acos(-localizedUnit.Z)
    local planeCF = originCF * CFrame.fromAxisAngle(axis, angle)
    -- case: point is to close, unreachable
    -- action: push back planeCF so the "hand" still reaches, angles fully compressed
    if l3 < math.max(l2, l1) - math.min(l2, l1) then
        return planeCF * CFrame.new(0, 0,  math.max(l2, l1) - math.min(l2, l1) - l3), -math.pi/2, math.pi
    -- case: point is to far, unreachable
    -- action: for forward planeCF so the "hand" still reaches, angles fully extended
    elseif l3 > l1 + l2 then
        return planeCF, math.pi/2, 0
    -- case: point is reachable
    -- action: planeCF is fine, solve the angles of the triangle
    else
        local a1 = -math.acos((-(l2 * l2) + (l1 * l1) + (l3 * l3)) / (2 * l1 * l3)) * angleMultiplier
        local a2 = math.acos(((l2  * l2) - (l1 * l1) + (l3 * l3)) / (2 * l2 * l3)) * angleMultiplier
        return planeCF, a1 + math.pi/2, a2 - a1
    end
end

local IKSolver = Class() do
    function IKSolver:init(bodyPart, b, c, e)
        self.BodyPart = bodyPart
        self.Base = b
        self.Center = c
        self.End = e
        self.BaseC0 = b.C0
		self.CenterC0 = c.C0
		self.UpperLength = math.abs(b.C1.Y) + math.abs(c.C0.Y)
		self.LowerLength = math.abs(c.C1.Y) + math.abs(e.C0.Y) + math.abs(e.C1.Y)
    end

    function IKSolver:Solve(goal)
        goal = goal or self.Goal
        self.Goal = goal

        if typeof(goal) == "Instance" then
            if goal:IsA("Attachment") then
                goal = goal.WorldPosition
            elseif goal:IsA("BasePart") then
                goal = goal.Position
            end
        end

        local bodyPart = self.BodyPart
        local BaseCF = bodyPart.CFrame * self.BaseC0
        local PlaneCF, BaseAngle, CenterAngle = solve(BaseCF, goal, self.UpperLength, self.LowerLength, self.Inverted)
        self.Base.C0 = bodyPart.CFrame:toObjectSpace(PlaneCF) * CFrame.Angles(BaseAngle, 0, 0)
        self.Center.C0 = self.CenterC0 * CFrame.Angles(CenterAngle, 0, 0)
    end

    function IKSolver:Reset()
        self.Goal = nil
        self.Base.C0 = self.BaseC0
		self.Center.C0 = self.CenterC0
    end
end

return IKSolver