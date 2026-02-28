local QBCore = exports['qb-core']:GetCoreObject()
local JobCooldown = {}

local function Normalize(job)
    if not job then return nil end
    return string.gsub(job, "^%s*(.-)%s*$", "%1")
end

RegisterNetEvent("hayabusa_jobs:server:GetJobs", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jobsList = {}

    for jobName, jobData in pairs(QBCore.Shared.Jobs) do
        local normalized = Normalize(jobName)

        if normalized and jobData and jobData.grades and jobData.grades["0"] then
            local allowed = true

            if Config.UseWhitelist and not Config.WhitelistedJobs[normalized] then
                allowed = false
            elseif not Config.UseWhitelist and Config.BlacklistedJobs[normalized] then
                allowed = false
            end

            if allowed then
                table.insert(jobsList, {
                    name = normalized,
                    label = jobData.label or normalized,
                    payment = jobData.grades["0"].payment or 0
                })
            end
        end
    end

    table.sort(jobsList, function(a, b)
        return a.label < b.label
    end)

    TriggerClientEvent("hayabusa_jobs:client:ReceiveJobs", src, jobsList)
end)

RegisterNetEvent("hayabusa_jobs:server:ApplyJob", function(jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    jobName = Normalize(jobName)
    if not jobName then return end

    local jobData = QBCore.Shared.Jobs[jobName]
    if not jobData or not jobData.grades or not jobData.grades["0"] then
        return
    end

    if JobCooldown[src] then
        local remaining = 300 - (os.time() - JobCooldown[src])
        if remaining > 0 then
            TriggerClientEvent('QBCore:Notify', src, "Wait "..remaining.." seconds before changing jobs.", "error")
            return
        end
    end

    if Player.PlayerData.job.name == jobName then
        TriggerClientEvent('QBCore:Notify', src, "You already work here.", "error")
        return
    end

    Player.Functions.SetJob(jobName, 0)
    JobCooldown[src] = os.time()

    TriggerClientEvent('QBCore:Notify', src, "You are now employed as "..(jobData.label or jobName), "success")

    -- tell UI to update (optional)
    TriggerClientEvent("hayabusa_jobs:client:ForceUIRefresh", src, jobName)
end)

RegisterNetEvent("jobcenter:quit", function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if not xPlayer then return end

    local oldJob = xPlayer.PlayerData.job.name

    xPlayer.Functions.SetJob("unemployed", 0)

    TriggerClientEvent('QBCore:Notify', src, "You have quit your job.", "success")
end)

AddEventHandler("playerDropped", function()
    JobCooldown[source] = nil
end)