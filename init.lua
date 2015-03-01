
-- a simple telnet server
s=net.createServer(net.TCP,180) 
s:listen(2323,function(c) 
    function s_output(str) 
      if(c~=nil) 
        then c:send(str) 
      end 
    end 
    node.output(s_output, 0)   
    -- re-direct output to function s_ouput.
    c:on("receive",function(c,l) 
      node.input(l)           
      --like pcall(loadstring(l)), support multiple separate lines
    end) 
    c:on("disconnection",function(c) 
      node.output(nil)        
      --unregist redirect output function, output goes to serial
    end) 
    print("Welcome to NodeMcu world.")
end)

pin=4
ow.setup(pin)
lastTemp=-999

function bxor(a,b)
	local r = 0
	for i = 0, 31 do
		if ( a % 2 + b % 2 == 1 ) then
			r = r + 2^i
		end
		a = a / 2
		b = b / 2
	end
	return r
end



-- Create the mqtt client
connected = false
mq = mqtt.Client("houseTemp", 5, "", "")
mq:on("connect", function(con) 
	print("connected to server") 
	connected = true 
	pcall(function () mq:publish("/sensors/loxy-house/temperature/status", "online", 0, 1) end)
	end)
mq:on("offline", function(con)
	connected = false
	print("Disconnected from server... reconnecting")
	mq:connect("192.168.0.199", 1883, 0)
	end)
mq:lwt("/sensors/loxy-house/temperature/status", "offline", 0, 1)

tmr.alarm(2, 10000, 1, function()
	if connected == false then
		mq:connect("192.168.0.199", 1883, 0)
	end
end)

mq:connect("192.168.0.199", 1883, 0)

tmr.alarm(1,2000, 1, function()
	pcall(function () mq:publish("/sensors/loxy-house/temperature/celcius", tostring(lastTemp), 0, 0) end)
end)

tempSenseState=0
tmr.alarm(0, 1000, 1, function()
	function ServiceTempSensor()
		if (tempSenseState == 0) then
			ow.reset(pin)
			ow.skip(pin)
			ow.write(pin, 0x44, 1)
			tempSenseState = 1
		else
			ow.reset(pin)
			ow.skip(pin)
			ow.write(pin, 0xBE, 1)
			data = nil
			data = string.char(ow.read(pin))
			data = data .. string.char(ow.read(pin))
			t = (data:byte(1) + data:byte(2) * 256)
			if (t > 32768) then
				t = (bxor(t, 0xffff)) + 1
				t = (-1) * t
			end
			t = t *625
			lastTemp = t
			tempSenseState = 0
		end
	end
	ServiceTempSensor()
end)

	
