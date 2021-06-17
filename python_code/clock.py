import machine
import neopixel
import utime
import time
import uasyncio
from ntptime import settime
import network

####

# SHT31D default address.
SHT31_I2CADDR = 0x44

# SHT31D Registers

SHT31_MEAS_HIGHREP_STRETCH = 0x2C06
SHT31_MEAS_MEDREP_STRETCH = 0x2C0D
SHT31_MEAS_LOWREP_STRETCH = 0x2C10
SHT31_MEAS_HIGHREP = 0x2400 # 12.5 - 15 ms
SHT31_MEAS_MEDREP = 0x240B  # 4.5 - 6 ms
SHT31_MEAS_LOWREP = 0x2416 # 2.5 - 4 ms

# High sample rate commands:
SHT31_MEAS_HIGHREP_10MPS = 0x2737# 12.5 - 15 ms
SHT31_MEAS_MEDREP_10MPS = 0x2721 # 4.5 - 6 ms
SHT31_MEAS_LOWHREP_10MPS = 0x272A# 2.5 - 4 ms


SHT31_READSTATUS = 0xF32D
SHT31_CLEARSTATUS = 0x3041
SHT31_SOFTRESET = 0x30A2
SHT31_HEATER_ON = 0x306D
SHT31_HEATER_OFF = 0x3066

SHT31_STATUS_DATA_CRC_ERROR = 0x0001
SHT31_STATUS_COMMAND_ERROR = 0x0002
SHT31_STATUS_RESET_DETECTED = 0x0010
SHT31_STATUS_TEMPERATURE_ALERT = 0x0400
SHT31_STATUS_HUMIDITY_ALERT = 0x0800
SHT31_STATUS_HEATER_ACTIVE = 0x2000
SHT31_STATUS_ALERT_PENDING = 0x8000

class SHT31(object):
    def __init__(self, address=SHT31_I2CADDR, i2c=None,
                 **kwargs):
        # Create I2C device.
        # if the SHT31 is taking a measurement
        self.addr=address
        self.bus=i2c
        self.pending_readout = False
        time.sleep(0.05)  # Wait the required time

    def _writeCommand(self, cmd):
        self.bus.writeto(self.addr, bytes([cmd >> 8, cmd & 0xFF]))

    def reset(self):
        self._writeCommand(SHT31_SOFTRESET)
        time.sleep(0.01)  # Wait the required time

    def clear_status(self):
        self._writeCommand(SHT31_CLEARSTATUS);

    def read_status(self):
        self._writeCommand(SHT31_READSTATUS);

        buffer = self.bus.readfrom(self.addr, 3)
        #buffer = self._device.readList(0, 3)
        stat = buffer[0] << 8 | buffer[1]
        if buffer[2] != self._crc8(buffer[0:2]):
            return None
        return stat

    def is_data_crc_error(self):
        return bool(self.read_status() & SHT31_STATUS_DATA_CRC_ERROR)

    def is_command_error(self):
        return bool(self.read_status() & SHT31_STATUS_COMMAND_ERROR)

    def is_reset_detected(self):
        return bool(self.read_status() & SHT31_STATUS_RESET_DETECTED)

    def is_tracking_temperature_alert(self):
        return bool(self.read_status() & SHT31_STATUS_TEMPERATURE_ALERT)

    def is_tracking_humidity_alert(self):
        return bool(self.read_status() & SHT31_STATUS_HUMIDITY_ALERT)

    def is_heater_active(self):
        return bool(self.read_status() & SHT31_STATUS_HEATER_ACTIVE)

    def is_alert_pending(self):
        return bool(self.read_status() & SHT31_STATUS_ALERT_PENDING)

    def set_heater(self, doEnable = True):
        if doEnable:
            self._writeCommand(SHT31_HEATER_ON)
        else:
            self._writeCommand(SHT31_HEATER_OFF)

    def request_readout(self, measurement_cmd = SHT31_MEAS_HIGHREP_10MPS):
        self._writeCommand(measurement_cmd)
        self.pending_readout = True

    def read_temperature_humidity(self):
        if not self.pending_readout:
            self._writeCommand(SHT31_MEAS_HIGHREP)
            time.sleep(0.015)
        self.pending_readout=False
        buffer = self.bus.readfrom(self.addr, 6)
        #buffer = self._device.readList(0, 6)

        if buffer[2] != self._crc8(buffer[0:2]):
            return (float("nan"), float("nan"))

        rawTemperature = buffer[0] << 8 | buffer[1]
        temperature = 175.0 * rawTemperature / 0xFFFF - 45.0

        if buffer[5] != self._crc8(buffer[3:5]):
            return (float("nan"), float("nan"))

        rawHumidity = buffer[3] << 8 | buffer[4]
        humidity = 100.0 * rawHumidity / 0xFFFF
        return (temperature, humidity)

    def read_temperature(self):
        (temperature, humidity) = self.read_temperature_humidity()
        return temperature

    def read_humidity(self):
        (temperature, humidity) = self.read_temperature_humidity()
        return humidity

    def _crc8(self, buffer):
        polynomial = 0x31;
        crc = 0xFF;

        index = 0
        for index in range(0, len(buffer)):
            crc ^= buffer[index]
            for i in range(8, 0, -1):
                if crc & 0x80:
                    crc = (crc << 1) ^ polynomial
                else:
                    crc = (crc << 1)
        return crc & 0xFF

##### FROM https://github.com/PinkInk/upylib/blob/master/bh1750/bh1750/__init__.py
class BH1750():

    PWR_OFF = 0x00
    PWR_ON = 0x01
    RESET = 0x07

    # modes
    CONT_LOWRES = 0x13
    CONT_HIRES_1 = 0x10
    CONT_HIRES_2 = 0x11
    ONCE_HIRES_1 = 0x20
    ONCE_HIRES_2 = 0x21
    ONCE_LOWRES = 0x23

    # default addr=0x23 if addr pin floating or pulled to ground
    # addr=0x5c if addr pin pulled high
    def __init__(self, bus, addr=0x23):
        self.bus = bus
        self.addr = addr
        self.off()
        self.reset()

    def off(self):
        self.set_mode(self.PWR_OFF)

    def on(self):
        self.set_mode(self.PWR_ON)

    def reset(self):
        self.on()
        self.set_mode(self.RESET)

    def set_mode(self, mode):
        self.mode = mode
        self.bus.writeto(self.addr, bytes([self.mode]))

    def luminance(self, mode):
        # continuous modes
        if mode & 0x10 and mode != self.mode:
            self.set_mode(mode)
        # one shot modes
        if mode & 0x20:
            self.set_mode(mode)
        # earlier measurements return previous reading
        uasyncio.sleep_ms(24 if mode in (0x13, 0x23) else 180)
        data = self.bus.readfrom(self.addr, 2)
        factor = 2.0 if mode in (0x11, 0x21) else 1.0
        return (data[0]<<8 | data[1]) / (1.2 * factor)
##########################

# Constants:
fwd_map = {0: 1, 1: 2, 2: 0, 4: 6, 5: 4, 6: 5}
rev_map = {0: 5, 1: 6, 2: 4, 4: 2, 5: 0, 6: 1}
big_rev_map ={0: 5, 1: 6, 2: 4,  4: 2, 5: -7, 6: 1}
small_fwd_map ={0: 1, 1: 0, 5: 6, 6: 5}

CHAR_DICT = {0: 119, 1: 36, 2: 93, 3: 109, 4: 46,
             5: 107, 6: 123, 7: 37, 8: 127, 9: 111,
            ' ': 0, 'A': 63, 'B': 127, 'C': 83,'H':62, 'O':119, '*':15, '.':64}

def get_character_vect(char):
    if not char in CHAR_DICT and int(char) in CHAR_DICT:
        char = int(char)
    return  [ (CHAR_DICT[char]  >> i) & 1 for i in range(7) ] #[::-1]

def clip(n, smallest, largest): return max(smallest, min(n, largest))

# Color conversions taken from colorsys library:
def rgb_to_hsv(r, g, b):
    maxc = max(r, g, b)
    minc = min(r, g, b)
    v = maxc
    if minc == maxc:
        return 0.0, 0.0, v
    s = (maxc-minc) / maxc
    rc = (maxc-r) / (maxc-minc)
    gc = (maxc-g) / (maxc-minc)
    bc = (maxc-b) / (maxc-minc)
    if r == maxc:
        h = bc-gc
    elif g == maxc:
        h = 2.0+rc-bc
    else:
        h = 4.0+gc-rc
    h = (h/6.0) % 1.0
    return h, s, v

def hsv_to_rgb(h, s, v):
    if s == 0.0:
        return v, v, v
    i = int(h*6.0) # XXX assume int() truncates!
    f = (h*6.0) - i
    p = v*(1.0 - s)
    q = v*(1.0 - s*f)
    t = v*(1.0 - s*(1.0-f))
    i = i%6
    if i == 0:
        return v, t, p
    if i == 1:
        return q, v, p
    if i == 2:
        return p, v, t
    if i == 3:
        return p, q, v
    if i == 4:
        return t, p, v
    if i == 5:
        return v, p, q
    # Cannot get here

class SegmentDisplay:

    hue_max_angular_velo_per_sec = 100 # d. per second
    sat_max_velo_per_sec = 100
    val_max_velo_per_sec = 200

    def __init__(self, start_index, n_segments=7, index_remapping=None):
        self.start_index = start_index
        self.n_segments = n_segments
        self.current_color = [(0,0,0)] * n_segments
        self.target_color = [(0,0,0)] * n_segments
        self.index_remapping = index_remapping


    def  test_index(self, idx, np, color=(0,0,250)):
        np.fill((0,0,0))
        absolute_index =  self.start_index+self.index_remapping.get(idx,idx)
        print('Start index:', self.start_index)
        print('Offset index:', self.index_remapping.get(idx,idx))
        print('Absolute index:', absolute_index)
        np[ self.start_index+self.index_remapping.get(idx,idx)] = color
        np.write()

    def set_hsv_target(self, key, value): # SET WITH HSV value!
        assert len(value)==3

        self._set_hsv_target(key,  value)


    def _set_hsv_target(self, key, value):
        self.target_color[key] = tuple(( (self.target_color[key][i] if v is None else v) for i, v in enumerate(value) ))

    def tick(self, deltatime):
        for index, ((current_hue, current_sat, current_val), target_hsv) in enumerate(zip(self.current_color,self.target_color)):

            delta_hue = target_hsv[0] - current_hue
            delta_sat = target_hsv[1] - current_sat

            recall_val =  target_hsv[2] * min(1,ambient_luminance/20)

            if recall_val==0 and target_hsv[2]>0:
                recall_val = 1

            delta_val = recall_val - current_val

            self.current_color[index] = (
                current_hue + clip(delta_hue, -self.hue_max_angular_velo_per_sec*deltatime, self.hue_max_angular_velo_per_sec*deltatime),
                current_sat + clip(delta_sat, -self.sat_max_velo_per_sec*deltatime, self.sat_max_velo_per_sec*deltatime),
                current_val + clip(delta_val, -self.val_max_velo_per_sec*deltatime, self.val_max_velo_per_sec*deltatime)
            )

    def write_to_strip(self,strip):
        for index, (h,s,v) in enumerate(self.current_color):
            try:
                strip[ self.index_remapping.get(index,index)+self.start_index] =  tuple( (int(value) for value in hsv_to_rgb(h,s,v) ))
                #strip[ self.start_index+index ] = tuple( (int(value) for value in hsv_to_rgb(h,s,v) ))
            except IndexError:
                continue

    def write_char(self, char, color_hsv):
        # Write character
        segments_to_enable = get_character_vect(char)
        for i,v in enumerate(segments_to_enable):
            if v:
                self.set_hsv_target(i,color_hsv)
            else:
                self.set_hsv_target(i, (None, None,0))
                #self.set_hsv_target(i, (None, None,0)) #

class Clock:

    def __init__(self, pin, np=None, mode='time', time_zone_offset=0):

        self.time_zone_offset = time_zone_offset
        self.np = np
        self.mode=mode

        try:
            self.previous_tick = utime.ticks_us()
        except:
            pass
        # Initialise the displays
        self.displays = [
                SegmentDisplay(49,index_remapping=rev_map), #0
                SegmentDisplay(42,index_remapping=fwd_map), #1
                SegmentDisplay(35,index_remapping=rev_map),#2
                SegmentDisplay(28,index_remapping=fwd_map),#3
                SegmentDisplay(21, index_remapping=big_rev_map),#4 #big
                SegmentDisplay(7, index_remapping=fwd_map),#5 #big
                SegmentDisplay(15, index_remapping=small_fwd_map),#6 #small
                SegmentDisplay(0, index_remapping={0: 1, 1: 0, 5: 6, 6: 5}),#7 # small
                ]

    def test_index(self, idx, color=(0,0,250)):
        # Clear all values:
        self.np.fill((0,0,0))
        self.np[idx] = color
        self.np.write()

    def tick(self):
        try:
            delta_t = 0.001 * utime.ticks_diff(utime.ticks_us(), self.previous_tick)
        except Exception:

            delta_t=0.01

        # Decide what to show:
        year, month, day, hour, minute, second, milisecond, microsecond = utime.localtime()


        if second>=0 and second<=20:
            self.write_amb('temp')
        elif second>=30 and second<=35:
            self.write_amb('hum')
        else:
            self.write_time()

        for segment in self.displays:
            segment.tick(delta_t)
            segment.write_to_strip(self.np)
        self.np.write()
        self.previous_tick = utime.ticks_us()

    def write_amb(self, mode='temp', color=(20,80,2)):

        global ambient_temperature
        global ambient_humidity

        color = rgb_to_hsv(250, 70, 5)
        colorB = rgb_to_hsv(50, 20, 5)

        # Clear all displays:
        for display in self.displays:
            display.write_char(' ', None)

        if mode=='temp':
            d_str= '%.2f' % ambient_temperature



        if mode=='temp':
            self.displays[-3].write_char('*', colorB)
            self.displays[-1].write_char('C', colorB)

            for i,c in enumerate(d_str):
                self.displays[i].write_char(c, color)

        elif mode=='hum':
            d_str = '%02d' % ambient_humidity
            for i,c in enumerate(d_str):
                self.displays[i+1].write_char(c, color)

            self.displays[4].write_char('H', color)
            self.displays[5].write_char(0, color)
            self.displays[6].write_char(2, color)




    def write_time(self, color=(20,80,2)):

        now = utime.mktime(time.localtime()) # Unix timestamp of current time
        now += self.time_zone_offset
        year, month, day, hour, minute, second, milisecond, microsecond = utime.localtime(now)

        global ambient_luminance

        color = rgb_to_hsv(250, 70, 5)
        colorB = rgb_to_hsv(50, 20, 5)


        # Clear all displays:
        for display in self.displays:
            display.write_char(' ', None)

        h = '%02d' % hour
        self.displays[0].write_char(int(h[0]), color)
        self.displays[1].write_char(int(h[1]), color)

        m = '%02d' % minute
        self.displays[3].write_char(int(m[0]), color)
        self.displays[4].write_char(int(m[1]), color)

        if ambient_luminance>=2: # Disable seconds in darkness
            s = '%02d' % second
            self.displays[6].write_char(int(s[0]), colorB)
            self.displays[7].write_char(int(s[1]), colorB)
        else:
            self.displays[6].write_char(' ', colorB)
            self.displays[7].write_char(' ', colorB)



    def __getitem__(self,idx):
        return self.displays[idx]

    def write_and_update(self,char=" ",index=0):
        color=rgb_to_hsv(250, 190, 0)
        self.displays[index].write_char(char,color)

        for i in range(20):
            self.tick(mode=None)
            time.sleep_us(200)

ambient_luminance = 0
ambient_temperature=20
ambient_humidity = 50

scl = machine.Pin(5) #D1
sda = machine.Pin(4) #D2
i2c = machine.I2C(-1, scl,sda)
np = neopixel.NeoPixel(machine.Pin(14), 7*8) #GPIO14 corresponds to D5, SCLK
sht = SHT31(i2c = i2c)
light_sensor = BH1750(i2c)


# Summer time:
#c = Clock(4, np=np, time_zone_offset=1*3600)
# Winter time:
c = Clock(4, np=np, time_zone_offset=2*3600)

async def aquire_ic2_readings():

    last_sht_aq = None
    while True:

        global ambient_luminance
        global ambient_temperature
        global ambient_humidity

        ambient_luminance_new = light_sensor.luminance(BH1750.CONT_HIRES_2)
        delta = ambient_luminance_new-ambient_luminance
        # Update with slope to remove spikes
        ambient_luminance += clip(delta, -0.1, 0.1)

        # Measure light in intervals of 100 ms
        await uasyncio.sleep_ms(100)

        if last_sht_aq is None or utime.time()-last_sht_aq > 50:
            ambient_temperature, ambient_humidity  = sht.read_temperature_humidity()
            last_sht_aq = utime.time()
            #print(ambient_temperature, ambient_humidity)


async def tick_clock():
    while  True:
        start = utime.ticks_ms()
        c.tick()
        ticktime = utime.ticks_diff(utime.ticks_ms(), start)
        target_ticktime = 40 # miliseconds
        await uasyncio.sleep_ms( max(0,target_ticktime-ticktime))

async def sync_time():
    while True:
        try:
            settime()


        except Exception:
            continue
        await uasyncio.sleep(1500) # The internal clock is terrible.
        # Update the time every this amount of seconds

def main():


    # Set up the event loop:
    loop = uasyncio.get_event_loop()

    # Set up the task which synchronyzes the time to the internet time
    loop.create_task(sync_time())
    # Read the external sensors
    loop.create_task(aquire_ic2_readings())
    # Update the digits:
    loop.create_task(tick_clock())

    loop.run_forever()
