# Ernie & Bert Board
The Ernie & Bert Board is my first try at generating a video signal using a PIC 16F84A microcontroller. It is based on ideas about generating video signals using a PIC by [Rickard Gunee](http://www.rickard.gunee.com/projects/video/pic/howto.php). 

Unlike Rickard's video game system this project displays a single hi-res monochrome image of 512x256 pixels on a PAL TV. Since the PIC is too slow and has too little memory to generate the image by itself the board holds a 16K EPROM chip that contains the bitmap image of Ernie & Bert and additional components to generate the video signal.

![](https://raw.githubusercontent.com/DhrBaksteen/ErnieAndBertBoard/master/IMG_0859.JPG)

### How it works
The board has two counters; the vertical line counter and the horizontal pixel counter. When video output is enabled the horizontal counter is clocked using the video clock. We have 52us of visible video signal on each scanline, or 520 clock pulses. Hence the choice for a horizontal resolution of 512 pixels. 

The horizontal and vertical counters both drive the address bus of the video ROM. Horizontal counter Q3 - Q8 map to A0 - A5 and Vertical counter Q0 - Q6 map to A6 - A12. The lowest 3 bits of the horizontal counter are used to detect the start of a new group of 8 pixels and are what drives the latch pin of the 74165 shift register. When Q0, Q1 and Q2 of the horizontal counter are 0 a new byte is available on the data bus and is latched in the shift register.

The data in the shift register is shifted using the video clock signal that also drives the horizontal counter. The serial video data that it outputs is run through an AND gate with the video enable signal from the PIC and forms the final video signal.

The PIC is in charge of running the whole operation. It generates the horizontal and vertical sync pulses and controls the rest of the chips. When a new frame is generated the vertical counter is reset and vertical sync pulses are generated. After a number of blank scanlines the actual image is sent. For each scanline the PIC sends the horizontal sync signal, resets the horizontal counter and gives the vertical coutner a clock pulse. Now the video output is enabled. This will enable the video clock as well as the shift register. The PIC now waits for 52us until the end of the current scanline. Then the video output is disabled and the next scanline will start. After 256 lines the PIC outputs some blank lines to get to a total of 304 scanlines and the process will repeat.

An additional debug video signal is generated directly by the PIC. This signal shows an alternating pattern of horizontal lines which was used to test the PIC during development.

Optionally a 32K EPROM chip that contains two images can be inserted. Using a jumper on the board either the first or the second image can be selected.

### In this repository
* ernie_bert.bin - Binary of the bitmap image without BMP headers to be loaded on the EPROM
* ernie_bert.bmp - Editable bitmap
* video.asm - Souurce code for the PIC 16F84A
* video.hex - Binary loaded on the PIC

### Possible improvements
* The clock input to the counters should be negated. In the current hardware this is not the case and it causes visible glitches (the vertical lines) in the image when a new byte is loaded in the shift register.
* The video signal seems to loose sync briefly every few seconds. Maybe due to an improper reset signal to the PIC?

![](https://raw.githubusercontent.com/DhrBaksteen/ErnieAndBertBoard/master/IMG_0847.JPG)
