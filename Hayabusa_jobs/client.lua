local QBCore = exports['qb-core']:GetCoreObject()
local uiOpen = false

CreateThread(function()
    exports['qb-target']:AddBoxZone("hayabusa_jobs-zone", Config.Location.coords, Config.Location.length, Config.Location.width, {
        name = "hayabusa_jobs-zone",
        heading = Config.Location.heading,
        debugPoly = false,
        minZ = Config.Location.minZ,
        maxZ = Config.Location.maxZ,
    }, {
        options = {
            {
                type = "client",
                event = "hayabusa_jobs:client:OpenUI",
                icon = "fas fa-briefcase",
                label = "Employment Center",
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent("hayabusa_jobs:client:OpenUI", function()
    if uiOpen then return end
    uiOpen = true

    local PlayerData = QBCore.Functions.GetPlayerData()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        serverName = "Drip City Whitelist",
        currentJob = PlayerData.job.name
    })

    TriggerServerEvent("hayabusa_jobs:server:GetJobs")
end)

RegisterNetEvent("hayabusa_jobs:client:ForceUIRefresh", function(jobName)
    SendNUIMessage({
        action = "open",
        currentJob = jobName
    })
end)

RegisterNetEvent("hayabusa_jobs:client:ReceiveJobs", function(jobs)
    SendNUIMessage({
        action = "loadJobs",
        jobs = jobs
    })
end)

RegisterNUICallback("apply", function(data, cb)
    if data and data.job then
        TriggerServerEvent("hayabusa_jobs:server:ApplyJob", data.job)
    end
    cb("ok")
end)

RegisterNUICallback("quit", function()
    TriggerServerEvent("jobcenter:quit")
end)

RegisterNUICallback("close", function(_, cb)
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    cb("ok")
end)