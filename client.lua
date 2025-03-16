ESX = exports["es_extended"]:getSharedObject()

local objectHash = `tr_prop_tr_officedesk_01a`
local spawnedObjects = {}

local function loadModel(model)
  RequestModel(model)
  while not HasModelLoaded(model) do
    Wait(1)
  end
end

local propsloadaed = false

Citizen.CreateThread(function()
  for job, spec in pairs(Config.CarShops) do
    exports.ox_target:addSphereZone({
      coords = vector3(spec.salonCoords.x, spec.salonCoords.y, spec.salonCoords.z),
      name = job .. "_salon",
      radius = 0.7,
      debug = false,
      options = {
        {
          label = 'Open Vehicle Shop',
          icon = 'fa-solid fa-car',
          name = job .. "_shop",
          onSelect = function(entity)
            ESX.TriggerServerCallback("m4-societycarshop:isuserboss", function(isboss)
              if isboss then
                TriggerEvent('q-societycarshop:openVehicleShopMenu', job, spec)
              else
                lib.notify({
                  title = 'VEHICLE UNIT SYS',
                  description = 'Neispravna šifra',
                  type = 'success'
                })
              end
            end, job)
          end
        },
      }
    })
  end

  for job, spec in pairs(Config.CarShops) do
    while true do
      loadModel(objectHash)
      local spawnedObject = CreateObject(objectHash, spec.salonCoords.x, spec.salonCoords.y, spec.salonCoords.z - 1, true, true, false)
      SetEntityHeading(spawnedObject, spec.salonCoords.w)

      FreezeEntityPosition(spawnedObject, true)
      table.insert(spawnedObjects, spawnedObject)
      Wait(10000)
    end
  end
end)

function getVehiclesForJob(jobName)
  local vehiclesForJob = {}

  if Config.CarShops[jobName] then
    for _, vehicle in ipairs(Config.CarShops[jobName].vehicles) do
      table.insert(vehiclesForJob, {
        label = vehicle.label,
        model = vehicle.model,
        price = vehicle.price
      })
    end
  else
    print("Job not found: " .. jobName)
  end

  return vehiclesForJob
end

RegisterNetEvent('q-societycarshop:openVehicleShopMenu', function(job, spec)
  local vehicles = getVehiclesForJob(job)

  local options = {}

  for _, vehicle in ipairs(vehicles) do
    table.insert(options, {
      title = vehicle.label,
      description = 'Price: $' .. vehicle.price,
      icon = 'fa-solid fa-car',
      image = json.encode(vehicle.image),
      onSelect = function()
        TriggerServerEvent('q-societycarshop:purchaseVehicle', job, vehicle.model, vehicle.price, spec.garage, spec.prefix)
      end
    })
  end

  lib.registerContext({
    id = 'vehicle_shop_menu',
    title = 'Vehicle Shop',
    options = options
  })

  lib.showContext("vehicle_shop_menu")
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
  if resourceName == GetCurrentResourceName() then
    for _, obj in ipairs(spawnedObjects) do
      if DoesEntityExist(obj) then
        DeleteObject(obj)
      end
    end
  end
end)
