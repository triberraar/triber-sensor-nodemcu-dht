-- file: setup.lua
local module = {}

local function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
  else
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")
    app.start()
  end
end

local function wifi_start()  
    print("Connecting to " .. config.SSID .. "...")
    wifi.setmode(wifi.STATION);
    wifi.setphymode(wifi.PHYMODE_N)
    wifi.sta.config(config.SSID,config.PASSWORD)
    wifi.sta.connect()
    
    --config.SSID = nil  -- can save memory
    tmr.alarm(1, 2500, 1, wifi_wait_ip)
end

local function stuf()
    print("stuff")
end

function module.start()  
  print("Configuring Wifi ...")
  stuf()
  wifi.setmode(wifi.STATION);
  wifi_start()
end

return module  