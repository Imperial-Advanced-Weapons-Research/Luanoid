local Ragdoll = {}

local function getCurrentTransform(motor6d)
    return (motor6d.Part0.CFrame * motor6d.C0):ToObjectSpace(motor6d.Part1.CFrame * motor6d.C1)
end

function Ragdoll.step(self)
    local luanoid = self.Luanoid
    local rootPart = luanoid.RootPart

    local maxVelocity = -math.huge
    for _,part in ipairs(luanoid.RigParts) do
        maxVelocity = math.max(maxVelocity, rootPart:GetVelocityAtPosition(part.Position).Magnitude)
    end

    -- TODO: Fix so this actually works
    if maxVelocity < 0.01 then
        for _,part in ipairs(luanoid.RigParts) do
            wait(1)
            local motor6d = part:FindFirstChildWhichIsA("Motor6D")
            local ballsocket = part:FindFirstChild("RagdollBallSocket")
            if motor6d and ballsocket and not motor6d.Enabled then
                motor6d.Transform = getCurrentTransform(motor6d)
                motor6d.Enabled = true
                ballsocket.Enabled = false
            end
        end
    else
        for _,part in ipairs(luanoid.RigParts) do
            local motor6d = part:FindFirstChildWhichIsA("Motor6D")
            local ballsocket = part:FindFirstChild("RagdollBallSocket")
            if motor6d and ballsocket and motor6d.Enabled then
                motor6d.Enabled = false
                ballsocket.Enabled = true
            end
        end
    end
end

function Ragdoll.Entering(self)
    local luanoid = self.Luanoid
    luanoid:ToggleRigCollision(true)
    luanoid:StopAnimations()
    luanoid.RootPart.CanCollide = false
    luanoid._mover.Enabled = false
    luanoid._aligner.Enabled = false
end

function Ragdoll.Left(self)
    local luanoid = self.Luanoid
    luanoid:ToggleRigCollision(false)
    luanoid:ToggleMotors(true)
end

return Ragdoll