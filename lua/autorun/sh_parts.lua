game.AddParticles("particles/particle_crash.pcf")
PrecacheParticleSystem("test_crash")
if (CLIENT) then
    concommand.Add("br_test_crash", function(ply, cmd, args)
		local part = CreateParticleSystem(ply, "test_crash", PATTACH_ABSORIGIN_FOLLOW, 0, vector_origin);
        
        --This does not crash ->>CreateParticleSystemNoEntity("test_crash", ply:GetPos(), Angle(0, 0, 0));
		timer.Simple(5, function()
			if (IsValid(part)) then
				part:StopEmissionAndDestroyImmediately();
			end
		end)
	end)
end