local yrpf = ImportPackage("yrpf")

Graffitis = {}

AddEvent("OnPackageStart", function()
    -- Add translation
    yrpf.AddI18nKey("fr", "Taguer", "Taguer")
    yrpf.AddI18nKey("en", "Taguer", "Tag")
    yrpf.AddI18nKey("fr", "graffiti.tag_error.no_spray", "Vous n'avez pas de bombe de peinture sur vous")
    yrpf.AddI18nKey("en", "graffiti.tag_error.no_spray", "You have no spray paint on you")

    -- Add images
    yrpf.AddImageResource("gamemap", "icon_spray_spot", "yrpf_graffiti/assets/icon_spray_spot.png")

    -- Create items
    yrpf.CreateItemTemplate(100100, "Bombe de peinture", "Pour faire votre plus beau chef-d'oeuvre", 1, "yrpf_graffiti/assets/item_spray.png", 1576, 0.4, 0, 0, -1, -1, -1)
    yrpf.AddI18nKey("fr", "item.name.100100", "Bombe de peinture")
    yrpf.AddI18nKey("fr", "ui.item.desc_100100", "Pour faire votre plus beau chef-d'oeuvre")

    -- Spawn spots
    for k,v in pairs(GraffitiSpots) do
        local wuID = yrpf.CreateWUI(v.x, v.y, v.z, v.rx, v.ry, v.rz, v.width, v.height, "wImageContainer")
        yrpf.SetImageWUI(wuID, GraffitiTags["empty"].image)
        local graf = {
            id = k,
            spot = v,
            wuID = wuID,
            currentTag = "empty"
        }
        Graffitis[k] = graf
        yrpf.AddMapMarker("spray_spot", "icon_spray_spot", v.x, v.y)
    end
end)

function GetNearGraffitiSpot(player)
    local x, y, z = GetPlayerLocation(player)
    for k,v in pairs(GraffitiSpots) do
        if GetDistance3D(x, y, z, v.x, v.y, v.z) < 200 then
            return Graffitis[k]
        end
    end
    return nil
end

AddRemoteEvent("Object:Interact", function(player)
    local spot = GetNearGraffitiSpot(player)
    if(spot == nil) then return end
    local menuId = yrpf.CreateMenu(player)
    yrpf.SetMenuImage(menuId, "yrpf_graffiti/assets/menu_image.png")
    for k,v in pairs(GraffitiTags) do
        yrpf.AddMenuItem(menuId, yrpf.GetI18nForPlayer(player, "Taguer") .. " " .. v.name, "window.CallEvent(\"RemoteCallInterface\", \"YRPF:Graffiti:RequestTag\", \"" .. k .. "\");")
    end
    yrpf.ShowMenu(menuId)
end)

AddRemoteEvent("YRPF:Graffiti:RequestTag", function(player, tag)
    yrpf.CloseMenu(player)
    local spot = GetNearGraffitiSpot(player)
    if(spot == nil) then return end
    if yrpf.GetItemQuantity(player, 100100) <= 0 then
        yrpf.SendToast(player, "error", yrpf.GetI18nForPlayer(player, "graffiti.tag_error.no_spray"))
        return
    end
    yrpf.RemoveItem(player, 100100, 1)

    local grafTag = GraffitiTags[tag]
    local x, y, z = GetPlayerLocation(player)
    CallRemoteEvent(player, "Character:FreezePlayer")
    CallRemoteEvent(player, "YRPF:Graffiti:Sound:PlaySound3D", "assets/sound_spray_can.mp3", x, y, z, 2000, 1)
    SetPlayerAnimation(player, "COMBINE")
    local particle = yrpf.CreateParticle(spot.spot.x, spot.spot.y, spot.spot.z, 0.3, 0.3, 0.3, 3000, "/Game/Vehicle/VFX/PS_VehicleSmoke")
    Delay(5000, function()
        spot.currentTag = tag
        yrpf.SetImageWUI(spot.wuID, grafTag.image)
        yrpf.DestroyParticle(particle)
        CallRemoteEvent(player, "Character:UnFreezePlayer")
    end)
end)