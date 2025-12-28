local EFFECT = {}
function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Radius = data:GetRadius() or 0

    local popTime = (data:GetMagnitude() or 0) / 10
    self.LifeTime = math.max(popTime, 0.01)

    self.StartTime = CurTime()
    self.EndTime = self.StartTime + self.LifeTime

    self.PSy = CreateParticleSystemNoEntity("br_castle_fire_spire_telegraph_1", self.Pos, angle_zero)
    if IsValid(self.PSy) then
        self.PSy:SetControlPoint(0, self.Pos)
        self.PSy:SetControlPoint(1, Vector(self.Radius, 0, 0))
        self.PSy:SetControlPoint(2, Vector(self.Radius, 0, 0))
    end
end

function EFFECT:Think()
    if CurTime() >= self.EndTime then
        if IsValid(self.PSy) then
            if self.PSy.StopEmissionAndDestroyImmediately then
                self.PSy:StopEmission()
            elseif self.PSy.StopEmission then
                self.PSy:StopEmission()
            end
        end

        if IsValid(self.snd) then
            self.snd:Stop()
        end

        return false
    end

    if IsValid(self.PSy) then
        local frac = math.Clamp((CurTime() - self.StartTime) / self.LifeTime, 0, 1)
        local x = Lerp(frac, self.Radius, 0)
        self.PSy:SetControlPoint(0, self.Pos)
        self.PSy:SetControlPoint(2, Vector(x, 0, 0))
    end

    return true
end

function EFFECT:Render() end

-- control point 0 pos
-- control point 1 first 2 rings
-- control point 2 outer ring that lerps to 0 based on lifetime.
effects.Register(EFFECT, "br_flamespire_telegraph_1")

local EFFECT_PROC = {}

function EFFECT_PROC:Init(data)
    self.Pos = data:GetOrigin()
    self.Radius = data:GetRadius() or 0

    local life = (data:GetMagnitude() or 0) / 10
    self.LifeTime = math.max(life, 3)
    self.EndTime = CurTime() + self.LifeTime

    self.PSy = CreateParticleSystemNoEntity("br_castle_flamespire_proc_main", self.Pos, angle_zero)
    if IsValid(self.PSy) then
        self.PSy:SetControlPoint(1, Vector(1, self.Radius / 128, 1))
    end
end

function EFFECT_PROC:Think()
    if CurTime() >= self.EndTime then
        if IsValid(self.PSy) then
            if self.PSy.StopEmissionAndDestroyImmediately then
                self.PSy:StopEmission()
            elseif self.PSy.StopEmission then
                self.PSy:StopEmission()
            end
        end
        return false
    end

    return true
end

function EFFECT_PROC:Render() end

effects.Register(EFFECT_PROC, "br_flamespire_proc_1")

local function DoEffect(name, pos, radius, lifeSeconds, noSound)
    local ed = EffectData()
    ed:SetOrigin(pos)
    ed:SetRadius(radius or 256)
    ed:SetMagnitude((lifeSeconds or 3) * 10) -- both effects divide by 10
    ed:SetFlags(noSound and 1 or 0)
    util.Effect(name, ed, true, true)
end

concommand.Add("test_flamespire_effect", function(ply, _, args)
    if not IsValid(LocalPlayer()) then return end

    local which = tostring(args[1] or "both"):lower()
    local radius = tonumber(args[2] or "") or 256
    local lifeSeconds = tonumber(args[3] or "") or 3
    local noSound = tostring(args[4] or ""):lower() == "nosound"

    local tr = LocalPlayer():GetEyeTraceNoCursor()
    local pos = tr.HitPos + Vector(0, 0, 2)

    if which == "telegraph" then
        DoEffect("br_flamespire_telegraph_1", pos, radius, lifeSeconds, noSound)
    elseif which == "proc" then
        DoEffect("br_flamespire_proc_1", pos, radius, lifeSeconds, noSound)
    else
        DoEffect("br_flamespire_telegraph_1", pos, radius, lifeSeconds, noSound)
        timer.Simple(math.max(lifeSeconds, 0.05), function()
            if not IsValid(LocalPlayer()) then return end
            DoEffect("br_flamespire_proc_1", pos, radius, lifeSeconds, noSound)
        end)
    end
end, nil, "Usage: br_test_flamespire_effect [telegraph|proc|both] [radius] [lifeSeconds] [nosound]")