function PlaySound3D(fileName, x, y, z, radius, volume)
    SetSoundVolume(CreateSound3D(fileName, x, y, z, radius), volume)
end
AddRemoteEvent("YRPF:Graffiti:Sound:PlaySound3D", PlaySound3D)