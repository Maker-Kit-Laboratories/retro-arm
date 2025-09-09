# RETRO-OPI CONSOLE
![Retro Opi Image](./documentation/retro-opi-image.png)

### DESCRIPTION:
Custom armbian build script intregrating Retro Pie and open source roms.

### PRE-BUILT IMAGE REQUIREMENTS:
- Orange Pi Zero 3 SBC
- 8GB+ Micro SD Card

### PRE-BUILT IMAGE INSTRUCTIONS:
1. Download premade image here -> [pre-built/retro-opi-armbian-25.08-opizero3.img.xz](./pre-built/retro-opi-armbian-25.08-opizero3.img.xz)
2. Use `rufus` or `balenaEtcher` to write to a an SD.
3. Insert into Orange Pi Zero 3 and power.
4. See Usage.

### BUILD REQUIREMENTS:
- Orange Pi SBC
- PC running your favourite linux
- Sufficient CPU/RAM/DISK to compile armbian

### BUILD INSTRUCTIONS:
1.  `git clone https://github.com/Maker-Kit-Laboratories/RETRO-OPI.git`
2.  `cd RETRO-OPI`
3.  `./create-retro-opi-image.sh`

### USAGE:
- Booting will check your network connection, if none exists it will bring up a connection window. Use a keyboard to configure or hit `Esc` to cancel.
- ROMS directory will be automatically shared under `//RETRO-OPI-DATA`.
- user: `robot` password: `retroopi`
- Retro Pie automatically starts on boot, to exist press `F4`. To restart type `emulationstation` in the console.
- Have fun!

### NOTES:
- Version 0.09
- Tested on:
    - Orange Pi Zero 3
    - Orange Pi Zero 2W



### SUPPORT:
- If you'd like to support this project, consider buying a kit @ [Maker Kit Laboratories - Printables](https://www.printables.com/@MakerKitLab_2578894)
- Comfirm supported boards and submit any issues you come across.