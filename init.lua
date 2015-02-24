print(wifi.sta.getip())
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID HERE","PASSWORD HERE")
print(wifi.sta.getip())
pin = 4
ow.setup(pin)
counter=0
lasttemp=-999
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
function getTemp()
tmr.wdclr()
ow.reset(pin)
ow.skip(pin)
ow.write(pin,0x44,1)
tmr.delay(1000000)
ow.reset(pin)
ow.skip(pin)
ow.write(pin,0xBE,1)
data = nil
data = string.char(ow.read(pin))
data = data .. string.char(ow.read(pin))
t = (data:byte(1) + data:byte(2) * 256)
if (t > 32768) then
t = (bxor(t, 0xffff)) + 1
t = (-1) * t
end
t = t * 625
lasttemp = t
print("Last temp: " .. lasttemp)
end

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    getTemp()
    conn:send(lasttemp)
    end)
  conn:on("sent",function(conn) conn:close() end)
end)
