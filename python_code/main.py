import machine
import neopixel
import utime
import time
import uasyncio


# Constants:
fwd_map = {0: 1, 1: 2, 2: 0, 4: 6, 5: 4, 6: 5}
rev_map = {0: 5, 1: 6, 2: 4, 4: 2, 5: 0, 6: 1}
big_rev_map ={0: 5, 1: 6, 2: 4,  4: 2, 5: -7, 6: 1}
small_fwd_map ={0: 1, 1: 0, 5: 6, 6: 5}

CHAR_DICT = {0: 119, 1: 36, 2: 93, 3: 109, 4: 46,
             5: 107, 6: 123, 7: 37, 8: 127, 9: 111,
            ' ': 0, 'A': 63, 'B': 127, 'C': 83}

def get_character_vect(char):
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
            delta_val = target_hsv[2] - current_val

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

        if self.mode=='time':
            self.write_time()

        for segment in self.displays:
            segment.tick(delta_t)
            segment.write_to_strip(self.np)
        self.np.write()
        self.previous_tick = utime.ticks_us()

    def write_time(self, color=(20,80,2)):

        now = utime.mktime(time.localtime()) # Unix timestamp of current time
        now += self.time_zone_offset
        year, month, day, hour, minute, second, milisecond, microsecond = utime.localtime(now)

        color=rgb_to_hsv(200, 100, 0)
        colorB=rgb_to_hsv(50, 20, 5)

        h = '%02d' % hour
        self.displays[0].write_char(int(h[0]), color)
        self.displays[1].write_char(int(h[1]), color)

        m = '%02d' % minute
        self.displays[3].write_char(int(m[0]), color)
        self.displays[4].write_char(int(m[1]), color)

        s = '%02d' % second
        self.displays[6].write_char(int(s[0]), colorB)
        self.displays[7].write_char(int(s[1]), colorB)


    def __getitem__(self,idx):
        return self.displays[idx]

    def write_and_update(self,char=" ",index=0):
        color=rgb_to_hsv(250, 190, 0)
        self.displays[index].write_char(char,color)

        for i in range(20):
            self.tick(mode=None)
            time.sleep_us(200)


np = neopixel.NeoPixel(machine.Pin(4), 7*8)
c = Clock(4, np=np, time_zone_offset=2*3600)

async def tick():
    while  True:
        start = utime.ticks_ms()
        c.tick()
        ticktime = utime.ticks_diff(utime.ticks_ms(), start)
        target_ticktime = 40 # miliseconds
        await uasyncio.sleep_ms( max(0,target_ticktime-ticktime)) #30 fps  1000 ms per

def main():
    loop = uasyncio.get_event_loop()
    loop.create_task(tick())
    loop.run_forever()

main()
