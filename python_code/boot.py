# This file is executed on every boot (including wake-boot from deepsleep)
#import esp
#esp.osdebug(None)
import network
import webrepl
from ntptime import settime
import utime
import time

### NETWORK ###
wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.connect('SSID', 'PASS')

for iteration in range(10):
    if wlan.isconnected():
        break
    print('Waiting for wlan ... %s' % iteration,end= '\r')
    time.sleep(1)

### TIME ###
webrepl.start()
settime()
now = utime.mktime(time.localtime()) # Unix timestamp of current time
now += 2*3600 # Add timezone shift
utime.localtime(now)

print('Time:')
print(utime.localtime(now))
