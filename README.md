# Large Wall Clock with subscript digits

![Alt text](pictures/clock_overview.jpg?raw=true "Title")

## Functionality
### Hardware:
- Segments are lit using single WS2812 modules
- Temperature and humidity measurements using SHT31 sensor
- Adaptive brightness using BH1750 light sensor
- ESP8266 microcontroller
- 3d printed using PLA fillament without the need of support structures
- 3d models are written in OpenSCAD
- Segments interconnect using dovetail joints


### Software
- Smooth visually pleasing segment updates
- Periodic real time clock synchronisation to internet time
- MicroPython with asynchronous update loop (using uasyncio)

![Alt text](pictures/single_segment.jpg?raw=true "Single segment")

### 3d printed parts overview
![Alt text](pictures/3d_printing_parts_overview.png?raw=true "3d printing parts overview")

![Alt text](pictures/backplane_printing.jpg?raw=true "Title")

### Segment wiring
![Alt text](pictures/backplane_with_leds.jpg?raw=true "Title")

### Subscript digit
![Alt text](pictures/subscript_digit.jpg?raw=true "Title")

