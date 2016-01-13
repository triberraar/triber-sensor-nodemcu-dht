-- file : application.lua
local module = {}  
m = nil

function get_sensor_Data()
    dht=require("dht")
    status,temp,humi,temp_decimial,humi_decimial = dht.read(2)
        if( status == dht.OK ) then
            temperature = temp.."."..(temp_decimial/100)
            humidity = humi.."."..(humi_decimial/100)
            print("Temperature: "..temperature.." deg C")
            print("Humidity: "..humidity.."%")
        elseif( status == dht.ERROR_CHECKSUM ) then          
            print( "DHT Checksum error" )
            temperature=-1 --TEST
        elseif( status == dht.ERROR_TIMEOUT ) then
            print( "DHT Time out" )
            temperature=-2 --TEST
        end
    -- Release module
    dht=nil
    package.loaded["dht"]=nil
end

local function mqtt_start()  
    m = mqtt.Client(config.DEVICE_ID, 120)

    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con) 
        print("Connected to MQTT")
            print("  IP: ".. config.HOST)
            print("  Port: ".. config.PORT)
            print("  Client ID: ".. config.ID)
            
            -- Stop the loop
            tmr.stop(0)
            -- Get sensor data
            get_sensor_Data() 
            m:publish("device/"..config.DEVICE_ID.."/sensor/"..config.TEMPERATURE_SENSOR_ID.."/reading",cjson.encode({value=temperature}), 0, 0, function(conn)
                m:publish("device/"..config.DEVICE_ID.."/sensor/"..config.HUMIDITY_SENSOR_ID.."/reading",cjson.encode({value=humidity}), 0, 0, function(conn)            
                    print("Going to deep sleep for "..(config.DELAY/1000).." seconds")
                    node.dsleep(config.DELAY*1000)
                end)
            end)
    end) 
end

function module.start()  
  mqtt_start()
end

return module 