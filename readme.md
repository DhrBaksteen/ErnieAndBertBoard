# Ernie & Bert Board
The Ernie & Bert Board is my first try at generating a video signal using a PIC 16F84A microcontroller. It is based on ideas about generating video signals using a PIC by [Rickard Gunee](http://www.rickard.gunee.com/projects/video/pic/howto.php). 

Unlike Rickard's video game system this project displays a single hi-res monochrome image of 512x256 pixels on a PAL TV. Since the PIC is too slow and has too little memory to generate the image by itself the board holds a 16K EPROM chip that contains the bitmap image of Ernie & Bert and additional components to generate the video signal.

![](https://raw.githubusercontent.com/DhrBaksteen/ErnieAndBertBoard/master/IMG_0859.JPG)

### How it works
The PIC is in charge of running the whole operation. It generates the horizontal and vertical sync pulses and controls the rest of the chips on the board. When a video frame is generated the vertical counter is reset and vertical sync pulses are generated. After a number of blank scanlines the image data will be sent. For each scanline the PIC sends the horizontal sync signal, resets the horizontal counter and gives the vertical coutner a clock pulse. Now the video output VENABLE is enabled. This will enable the video clock VCLK as well as the 75165 shift register to send its serial data to the video output. The video clock is a simple AND of the system clock and the video enable signal. The PIC now waits for 52us until the end of the current scanline. Then the video output is disabled and the next scanline will start. After 256 lines the PIC outputs some blank lines to get to a total of 304 scanlines and the process will repeat.

We have 52us of visible video signal on each scanline, which is 520 clock pulses thanks to the 10MHz clock. Hence the choice for a horizontal resolution of 512 pixels. The PIC requires 4 clock cycles per instruction so this leaves just 2 instructions before we need to start the next horizonatal sync. Two instructions is not enough to prepare for te next line of video, so while the video signal is held at sync level the PIC sends a clock pulse to the vertical counter, resets the horizontal counter and keeps track of the number of lines left in the image.

The board has two counters; the vertical line counter and the horizontal pixel counter. When video output is enabled (VENABLE) the horizontal counter is clocked using the video clock VCLK. The horizontal and vertical counters both drive the address bus of the video ROM. Horizontal counter Q3 - Q8 map to A0 - A5 and Vertical counter Q0 - Q6 map to A6 - A12. The lowest 3 bits of the horizontal counter are used to detect the start of a new group of 8 pixels and are what drives the latch pin of the 74165 shift register. When Q0, Q1 and Q2 of the horizontal counter are 0 a new byte is available on the data bus and is latched in the shift register.

The data in the shift register is shifted using the VCLK signal that also drives the horizontal counter. The serial video data that it outputs is run through an AND gate with the VENABLE signal from the PIC and forms the final video signal. I use an AND gate to switch the video signal off at the end of a line so that I don't have to worry about any residual picture data left on the serial output when we need to go to sync level.

An additional debug video signal is generated directly by the PIC. This signal shows an alternating pattern of horizontal lines which was used to test the PIC during development.

Optionally a 32K EPROM chip that contains two images can be inserted. Using a jumper on the board either the first or the second image can be selected.

![](https://raw.githubusercontent.com/DhrBaksteen/ErnieAndBertBoard/master/Schematic.png)

### In this repository
* ernie_bert.bin - Binary of the bitmap image without BMP headers to be loaded on the EPROM
* ernie_bert.bmp - Editable bitmap
* video.asm - Souurce code for the PIC 16F84A
* video.hex - Binary loaded on the PIC

### Possible improvements
* The VCLK clock input to the shift register and horizontal counter should be negated. In the current hardware this is not the case and it causes visible glitches in the image when a new byte is latched into the shift register.
* There are glitches in the form of vertical bars at regular intervals where the image seems to have shifted down a number of lines. This is probably an issue on the address bus due to sloppy soldering :)
* The video signal seems to loose sync briefly every few seconds. Maybe due to an improper reset signal to the PIC?

![](https://raw.githubusercontent.com/DhrBaksteen/ErnieAndBertBoard/master/IMG_0847.JPG)  |  ![](https://raw.githubusercontent.com/DhrBaksteen/ErnieAndBertBoard/master/IMG_0848.JPG)

