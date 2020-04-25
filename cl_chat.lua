local chatInputActive = false
local chatInputActivating = false
local chatMute = false
local showOoc = true

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')

-- internal events
RegisterNetEvent('__cfx_internal:serverPrint')

RegisterNetEvent('_chat:messageEntered')

--deprecated, use chat:addMessage
AddEventHandler('chatMessage', function(author, color, text)
  if (not showOoc and string.find(author, "[OOC]")) then
    return
  else
    local args = { text }
    
    if author ~= "" then
      table.insert(args, 1, author)
    end
    
    SendNUIMessage({
      type = 'ON_MESSAGE',
      message = {
        color = color,
        multiline = true,
        args = args
      }
    })
  end
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
  print(msg)

  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
      color = { 0, 0, 0 },
      multiline = true,
      args = { msg }
    }
  })
end)

AddEventHandler('chat:addMessage', function(message)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end)

AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:addTemplate', function(id, html)
  SendNUIMessage({
    type = 'ON_TEMPLATE_ADD',
    template = {
      id = id,
      html = html
    }
  })
end)

AddEventHandler('chat:clear', function(name)
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)

  if not data.canceled then
    local id = PlayerId()

    --deprecated
    --local r, g, b = 0, 0x99, 255
    local r, g, b = 170, 170, 170

    if (not chatMute) then
      if data.message:sub(1, 1) == '/' then
        ExecuteCommand(data.message:sub(2))
      else
        --TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message)
        if (showOoc) then
          TriggerServerEvent('_chat:messageEntered', "^7[OOC]", { r, g, b }, data.message)
        else
          exports.pnotify:SendNotification({text = "You have OOC chat disabled.  Type <font color='skyblue'>'/ooc on'</font> to enable it."})
        end
      end
    else
      exports.pnotify:SendNotification({text = "Your chat has been muted by an administrator."})
    end
  end

  cb('ok')
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chat:init');

  cb('ok')
end)

RegisterNetEvent("bms:chat:setChatMute")
AddEventHandler("bms:chat:setChatMute", function(mute)
  chatMute = (mute == 1)
end)

RegisterNetEvent("bms:chat:toggleOoc")
AddEventHandler("bms:chat:toggleOoc", function(toggle)
  showOoc = toggle
end)

Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false)

  while true do
    Wait(0)

    if not chatInputActive then
      if IsControlPressed(0, 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true

        SendNUIMessage({
          type = 'ON_OPEN'
        })
      end
    end

    if chatInputActivating then
      if not IsControlPressed(0, 245) then
        SetNuiFocus(true)

        chatInputActivating = false
      end
    end
  end
end)
