ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('q-societycarshop:purchaseVehicle', function(job, model, price, garage, prefix)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  local modelhash = GetHashKey(model)

  local function generateUniquePlate(callback)
    local randomnum
    local plate

    local function checkPlate()
      randomnum = math.random(100, 999)
      plate = prefix .. " " .. randomnum
      MySQL.Async.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
      }, function(result)
        if result then
          checkPlate()
        else
          callback(plate)
        end
      end)
    end

    checkPlate()
  end

  TriggerEvent('esx_addonaccount:getSharedAccount', "society_" .. job, function(account)
    if account.money >= price then
      account.removeMoney(price)

      generateUniquePlate(function(uniquePlate)
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, stored, parking) VALUES (@owner, @plate, @vehicle, @type, @job, @stored, @parking)', {
          ['@owner'] = xPlayer.identifier,
          ['@plate'] = uniquePlate,
          ['@vehicle'] = json.encode({
            color1 = { 255, 255, 255 },
            modTrunk = -1,
            modHydraulics = false,
            modHood = -1,
            modShifterLeavers = -1,
            bodyHealth = 1000,
            model = modelhash,
            modRoof = -1,
            pearlescentColor = 0,
            modCustomTiresF = false,
            modSubwoofer = -1,
            windowTint = -1,
            dirtLevel = 2,
            extras = { ["1"] = 1, ["12"] = 0 },
            wheelSize = 1.0,
            modTank = -1,
            modGrille = -1,
            modBrakes = -1,
            bulletProofTyres = true,
            modPlateHolder = -1,
            modNitrous = -1,
            modRoofLivery = -1,
            tyreSmokeColor = { 255, 255, 255 },
            modDoorR = -1,
            modArchCover = -1,
            modDashboard = -1,
            modFender = -1,
            modSpeakers = -1,
            modSmokeEnabled = false,
            modRightFender = -1,
            driftTyres = false,
            modAPlate = -1,
            doors = {},
            windows = {},
            modTrimB = -1,
            modTrimA = -1,
            paintType2 = 7,
            modLivery = 1,
            tankHealth = 1000,
            modAirFilter = -1,
            modSideSkirt = -1,
            modRearBumper = -1,
            modBackWheels = -1,
            modFrame = -1,
            tyres = {},
            wheels = 0,
            modHorns = -1,
            modSeats = -1,
            modCustomTiresR = false,
            modAerials = -1,
            fuelLevel = 61,
            plateIndex = 4,
            modSpoilers = -1,
            modFrontBumper = -1,
            neonColor = { 255, 0, 255 },
            modArmor = -1,
            modTransmission = -1,
            modXenon = false,
            modDial = -1,
            oilLevel = 5,
            modDoorSpeaker = -1,
            modSteeringWheel = -1,
            modExhaust = -1,
            plate = uniquePlate,
            wheelWidth = 1.0,
            paintType1 = 7,
            neonEnabled = { false, false, false, false },
            modVanityPlate = -1,
            modFrontWheels = -1,
            interiorColor = 0,
            modEngine = -1,
            modLightbar = -1,
            modSuspension = -1,
            modHydrolic = -1,
            engineHealth = 1000,
            dashboardColor = 0,
            color2 = { 0, 0, 0 },
            wheelColor = 156,
            modTurbo = false,
            xenonColor = 255,
            modOrnaments = -1,
            modStruts = -1,
            modEngineBlock = -1,
            modWindows = -1
          }),
          ['@type'] = "automobile",
          ['@job'] = job,
          ['@stored'] = 1,
          ['@parking'] = garage,
        })

        TriggerClientEvent('ox_lib:notify', src, {
          title = 'Vehicle Shop',
          description = 'You have purchased a ' .. model .. 'with plates: ' .. uniquePlate .. ' for $' .. price .. ' from society funds.',
          type = 'success'
        })
      end)
    else
      TriggerClientEvent('ox_lib:notify', src, {
        title = 'Vehicle Shop',
        description = 'Society does not have enough funds.',
        type = 'error'
      })
    end
  end)
end)

ESX.RegisterServerCallback('m4-societycarshop:isuserboss', function(source, cb, job)
  local xPlayer = ESX.GetPlayerFromId(source)

  if xPlayer.job.name == job and xPlayer.job.grade_name == 'boss' then
    cb(true)
  else
    cb(false)
  end
end)
