local capabilities = require "st.capabilities"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Basic
local Basic = require "st.zwave.CommandClass.Basic"
--- @type st.zwave.CommandClass.SwitchMultilevel
local SwitchMultilevel = require "st.zwave.CommandClass.SwitchMultilevel"
--- @type st.zwave.Driver
local ZwaveDriver = require "st.zwave.driver"


local is_down_button_active = nil
local is_main_button_down = false

local function send_button_pushed_event(device, is_down)
  if is_down == true then
    device:emit_event(capabilities.button.button.down({ state_change = true }))
  elseif is_down == false then
    device:emit_event(capabilities.button.button.up({ state_change = true }))
  else --use push in all other cases
    device:emit_event(capabilities.button.button.pushed({ state_change = true }))
  end
end

local function report_handler(driver, device, cmd)
  -- it seems we receive value 0 from set command when the button is pushed
  -- and value 1 from a report command when the button is released. But just in case adding both commands
  -- in the check. For my device I never receive a report command with value 0.
  local stButton = device.profile.components["main"]

  if cmd.args.value == 0x00 then
    is_main_button_down = true
    send_button_pushed_event(stButton, true)
  elseif cmd.args.value == 0x01 then
    if is_main_button_down == false then
      send_button_pushed_event(stButton)
    else
      send_button_pushed_event(stButton, false)
    end

    is_main_button_down = false
  end;
end

local function handle_level_change_start(driver, device, cmd)
  -- Since my other switch is not a dimmer for now I need the whole device to behave as a single button. This is why
  -- we send a button pushed event even when the dimmer buttons are pressed. But the logic here can be adapted for
  -- a dimmer here.

  local stButton
  if cmd.args.up_down then
    is_down_button_active = true
    stButton = device.profile.components["down"]
  else
    is_down_button_active = false
    stButton = device.profile.components["up"]
  end

  send_button_pushed_event(stButton, true)
end

local function handle_level_change_stop(driver, device, cmd)
  local stButton
  if is_down_button_active ~= nil then
    if is_down_button_active then
      stButton = device.profile.components["down"]
    else
      stButton = device.profile.components["up"]
    end
    is_down_button_active = nil
    send_button_pushed_event(stButton, false)
  elseif device.preferences.sendPressOnFantomEvents == true then
    stButton = device.profile.components["main"]
    send_button_pushed_event(stButton)
  end
end

local driver_template = {
  zwave_handlers = {
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.START_LEVEL_CHANGE] = handle_level_change_start,
      [SwitchMultilevel.STOP_LEVEL_CHANGE] = handle_level_change_stop
    },
    [cc.BASIC] = {
      [Basic.SET] = report_handler,
      [Basic.REPORT] = report_handler
    },
  }
}

local driver = ZwaveDriver("driver_name", driver_template)

driver:run()