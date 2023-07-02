local request = (syn and syn.request) or request or http_request or (http and http.request)
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local setthreadidentityfunc = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity
local getthreadidentityfunc = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local entity, GuiLibrary, funcs = engoware.entity, engoware.GuiLibrary, engoware.funcs
local mouse = lplr:GetMouse()
local remotes, modules = {}, {}
local Hitboxes = {}
local whitelist = {};
local shalib = loadstring(funcs:require("lib/sha.lua"))()
whitelist = game:GetService("HttpService"):JSONDecode((funcs:require("https://github.com/7GrandDadPGN/whitelists/blob/main/whitelist2.json?raw=true", true, true)))

function funcs:getRemote(list) 
    for i,v in next, list do if v == 'Client' then return list[i+1]; end end
end

local Flamework = require(game:GetService("ReplicatedStorage").rbxts_include.node_modules["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local Client, KnitClient = 
require(game:GetService("ReplicatedStorage").TS.remotes).default.Client, 
debug.getupvalue(require(lplr.PlayerScripts.TS.controllers.game["block-break-controller"]).BlockBreakController.onEnable, 1)

local Client_Get, Client_WaitFor = getmetatable(Client).Get, getmetatable(Client).WaitFor

getmetatable(Client).Get = function(self, RemoteName)
    if RemoteName == remotes.SwordRemote then 
        local old = Client_Get(self, RemoteName)
        return {
            SendToServer = function(self, tab) 
                if Hitboxes.Enabled then 
                    pcall(function()
                        local mag = (tab.validate.selfPosition.value - tab.validate.targetPosition.value).magnitude
                        local newres = modules.HashVector(tab.validate.selfPosition.value + (mag > 14.4 and (CFrame.lookAt(tab.validate.selfPosition.value, tab.validate.targetPosition.value).LookVector * 4) or Vector3.new(0, 0, 0)))
                        tab.validate.selfPosition = newres
                    end)
                end
                local suc, plr = pcall(function() return Players:GetPlayerFromCharacter(tab.entityInstance) end)
                if suc and plr then
                    local playerattackable = funcs:isWhitelisted(plr)
                    if not playerattackable then 
                        return nil
                    end
                end
                return old:SendToServer(tab)
            end,
            instance = old.instance,
        }
    end
    return Client_Get(self, RemoteName)
end

engoware.UninjectEvent.Event:Connect(function() 
    getmetatable(Client).Get = Client_Get
    getmetatable(Client).WaitFor = Client_WaitFor
end)

modules = {
    Client = Client,

    BlockEngine = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
    BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
    Maid = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"].maid.Maid),

    QueueService = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"].lobby.out.server.services["queue-service"]).QueueService,
    QueueMeta = require(game:GetService("ReplicatedStorage").TS.game["queue-meta"]).QueueMeta,
    ClientStore = require(lplr.PlayerScripts.TS.ui.store).ClientStore,

    AnimationUtil =  debug.getupvalue(require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["break"]["block-breaker"]).BlockBreaker.hitBlock, 6),
    BlockAnimationId = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.shared.animation["animation-id"]).AnimationId,
    ViewmodelController = KnitClient.Controllers.ViewmodelController,

    BedwarsArmor = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-armor-set"]).BedWarsArmor,
    BedwarsArmorSet = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-armor-set"]).BedwarsArmorSet,

    SwordController = KnitClient.Controllers.SwordController,
    BedwarsSwords = require(game:GetService("ReplicatedStorage").TS.games.bedwars["bedwars-swords"]).BedwarsSwords,
    CombatConstant = require(game:GetService("ReplicatedStorage").TS.combat["combat-constant"]).CombatConstant,

    KnockbackUtil = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
    KnockbackConstant = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1),

    SprintController = require(lplr.PlayerScripts.TS.controllers.global.sprint["sprint-controller"]).SprintController,

    IntentoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil,
    GetInventory = function(plr) 
        if not plr then 
            return {items = {}, armor = {}}
        end

        local suc, ret = pcall(function() 
            return require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil.getInventory(plr)
        end)

        if not suc then 
            return {items = {}, armor = {}}
        end

        if plr.Character and plr.Character:FindFirstChild("InventoryFolder") then 
            local invFolder = plr.Character:FindFirstChild("InventoryFolder").Value
            if not invFolder then return ret end
            for i,v in next, ret do 
                for i2, v2 in next, v do 
                    if typeof(v2) == 'table' and v2.itemType then
                        v2.instance = invFolder:FindFirstChild(v2.itemType)
                    end
                end
                if typeof(v) == 'table' and v.itemType then
                    v.instance = invFolder:FindFirstChild(v.itemType)
                end
            end
        end

        return ret
    end,

    GetItemMeta = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta,
    ItemMeta = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
    ItemDropController = require(lplr.PlayerScripts.TS.controllers.global["item-drop"]["item-drop-controller"]).ItemDropController,

    HashVector = function(vec) 
        return {value = vec}
    end
}
remotes = {
    SwordRemote = funcs:getRemote(debug.getconstants(modules.SwordController.attackEntity)),
    FallRemote = game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.GroundHit,
    DamageBlock = game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"].net.out["_NetManaged"].DamageBlock,
    ItemDropRemote = funcs:getRemote(debug.getconstants(modules.ItemDropController.dropItemInHand)),
    ItemPickupRemote = funcs:getRemote(debug.getconstants(modules.ItemDropController.checkForPickup)),
    PaintRemote = funcs:getRemote(debug.getconstants(KnitClient.Controllers.PaintShotgunController.fire))
}
engoware.modules = modules
engoware.remotes = remotes

function funcs:getSword() 
    local highest, returning = -9e9, nil
    for i,v in next, modules.GetInventory(lplr).items do 
        local power = table.find(modules.BedwarsSwords, v.itemType)
        if not power then continue end
        if power > highest then 
            returning = v
            highest = power
        end
    end
    return returning
end

function funcs:getTool(blockMeta) 
    local highest, returning = -9e9, nil
    for i,v in next, modules.GetInventory(lplr).items do 
        local itemMeta = modules.GetItemMeta(v.itemType)
        local power = itemMeta.breakBlock and itemMeta.breakBlock[blockMeta.block.breakType] or 0
        if not power then continue end
        if power > highest then 
            returning = {item = v, meta = itemMeta}
            highest = power
        end
    end
    return returning.item, returning.meta
end

function funcs:isUncovered(block) 
    local amt = 0
    local normals = Enum.NormalId:GetEnumItems()
    for i,v in next, normals do 
        local pos = block.Position + (Vector3.FromNormalId(v) * 3 )
        if modules.BlockEngine:getStore():getBlockAt(pos) then 
            amt = amt + 1
        end
    end
    return not amt == #normals
end

function funcs:breakBlock(block, normal) 
    if not block or block.Parent == nil then 
        return
    end

    if block:GetAttribute("Team" .. lplr:GetAttribute("Team") .. "NoBreak") then 
        return
    end

    local blockPosition = modules.BlockEngine:getBlockPosition(block.Position)
    local blockTable = {
        target = {
            blockInstance = block,
            blockRef = {
                blockPosition = blockPosition,
            },
            hitPosition = blockPosition,
            hitNormal = Vector3.FromNormalId(normal),
        },
        placementPosition = blockPosition,
    }
    local blockHealth = block:GetAttribute(lplr.Name .. "_Health") or block:GetAttribute("Health")
    local blockMaxHealth = block:GetAttribute("MaxHealth")
    local blockDamage = modules.BlockEngine:calculateBlockDamage(lplr, blockTable.target.blockRef)
    
    local result = remotes.DamageBlock:InvokeServer({
        blockRef = blockTable.target.blockRef,
        hitPosition = blockTable.target.hitPosition * 3,
        hitNormal = blockTable.target.hitNormal,
    })
    if result == 'failed' then 
        blockDamage = 0
    end
    
    block:SetAttribute(lplr.Name .. "_Health", blockHealth - blockDamage)
    modules.BlockBreaker:updateHealthbar(blockTable.target.blockRef, blockHealth - blockDamage, blockMaxHealth, blockDamage)
    modules.AnimationUtil.playAnimation(lplr, modules.BlockEngine:getAnimationController():getAssetId(modules.BlockAnimationId.BREAK_BLOCK), {looped = false, fadeInTime = 0})
    modules.ViewmodelController:playAnimation(15)
    if blockHealth - blockDamage <= 0 then
        modules.BlockBreaker.breakEffect:playBreak(blockTable.target.blockInstance.Name, blockPosition, lplr)
        modules.BlockBreaker.healthbarMaid:DoCleaning()
    else
        modules.BlockBreaker.breakEffect:playHit(blockTable.target.blockInstance.Name, blockPosition, lplr)
    end
end

function funcs:getSurroundingBlocks(blockPosition, override) 
    local blockPosition = modules.BlockEngine:getBlockPosition(blockPosition)
    local surroundingBlocks = {}
    for i,v in next, override or Enum.NormalId:GetEnumItems() do 
        if v == Enum.NormalId.Bottom then continue end
        for i = 1, 15 do 
            local block = modules.BlockEngine:getStore():getBlockAt(blockPosition + (Vector3.FromNormalId(v) * (i)))
            if block then 
                surroundingBlocks[#surroundingBlocks+1] = block
            end
        end
    end
    return surroundingBlocks
end

function funcs:getBestNormal(blockPosition)
    local leastpower, returning = 9e9, Enum.NormalId.Top
    for i,v in next, Enum.NormalId:GetEnumItems() do 
        if v == Enum.NormalId.Bottom then continue end
        local SidePower = 0
        for _, block in next, funcs:getSurroundingBlocks(blockPosition, {v}) do
            local BlockMeta = modules.GetItemMeta(block.Name)
            local _, ToolitemMeta = funcs:getTool(BlockMeta)

            if not block:GetAttribute("Team" .. lplr:GetAttribute("Team") .. "NoBreak") then 
                SidePower = SidePower + (block:GetAttribute(lplr.Name .. "_Health") or block:GetAttribute("Health") or block:GetAttribute("MaxHealth"))
                SidePower = SidePower - (ToolitemMeta.breakBlock and ToolitemMeta.breakBlock[BlockMeta.block.breakType] or 0)
            else
                SidePower = SidePower + 999e999
            end
        end
        if SidePower < leastpower then 
            leastpower = SidePower
            returning = v
        end
    end
    return returning, leastpower
end

function funcs:getBacktrackedBlock(blockPosition, normal)
    local normal = normal or funcs:getBestNormal(blockPosition)
    local blockPosition = modules.BlockEngine:getBlockPosition(blockPosition)
    local returning
    for i = 1, 15 do 
        local offset = Vector3.FromNormalId( normal ) * (i)
        local block = modules.BlockEngine:getStore():getBlockAt(blockPosition + offset)
        if block and block.Parent ~= nil then 
            returning = block
            if funcs:isUncovered(block) then 
                break
            end
        end
    end
    return returning
end

function funcs:getOtherSideBed(bed) 
    local blocks = funcs:getSurroundingBlocks(bed.Position)
    for i,v in next, blocks do 
        if v.Name == "bed" then 
            --print(v:GetFullName())
            return v
        end
    end
    --print("no other side")
end

function funcs:isWhitelisted(plr)
    local plrstr = shalib.sha512(plr.Name..plr.UserId.."SelfReport")
    local playertype, playerattackable = "DEFAULT", true
    local private = funcs:wlfind(whitelist.players, plrstr)
    local owner = funcs:wlfind(whitelist.owners, plrstr)
    if private then
        playertype = "VAPE PRIVATE"
        playerattackable = not (type(private) == "table" and private.invulnerable or true)
    end
    if owner then
        playertype = "VAPE OWNER"
        playerattackable = not (type(owner) == "table" and owner.invulnerable or true)
    end
    return playerattackable, playertype
end


do 
    local NoFall = {}; NoFall = GuiLibrary.Objects.utilitiesWindow.API.CreateOptionsButton({
        Name = "nofall",
        Function = function(callback) 
            if callback then 
                coroutine.wrap(function() 
                    repeat 
                        remotes.FallRemote:FireServer()
                        task.wait(5)
                    until not NoFall.Enabled
                end)()
            end
        end,
    })
end



--[[do 
    local NoRender = {}; NoRender = GuiLibrary.Objects.renderWindow.API.CreateOptionsButton({
        Name = "norender",
        Function = function(callback) 
            if callback then 
                
            end
        end,
    })
end]]
