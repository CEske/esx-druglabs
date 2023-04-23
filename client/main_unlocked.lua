function farm()
    TaskStartScenarioInPlace(PlayerPedId(-1), 'PROP_HUMAN_BUM_BIN', 0, true)
    Citizen.Wait(ConfigClient.farmtid)
    ClearPedTasksImmediately(PlayerPedId(-1))
end

function pack()
    TaskStartScenarioInPlace(PlayerPedId(-1), 'PROP_HUMAN_BUM_BIN', 0, true)
    Citizen.Wait(ConfigClient.packtid)
    ClearPedTasksImmediately(PlayerPedId(-1))
end

function omdan()
    TaskStartScenarioInPlace(PlayerPedId(-1), 'PROP_HUMAN_BUM_BIN', 0, true)
    Citizen.Wait(ConfigClient.processtid)
    ClearPedTasksImmediately(PlayerPedId(-1))
end