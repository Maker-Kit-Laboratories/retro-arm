# RETRO-OPI CONSOLE
![Retro Opi Image](./documentation/retro-opi-image-3.png)

### DESCRIPTION:
Custom armbian build script intregrating Retro Pie and open source ROMs.

### PRE-BUILT IMAGE REQUIREMENTS:
- Supported SBC:
    - Zero 3
    - Zero 2w
    - 3 LTS
- 8GB+ Micro SD Card

### PRE-BUILT IMAGE INSTRUCTIONS:
1. Download pre-built image here:
    - Zero 3 -> [retro-opi-0.16-armbian-25.08-orangepizero3.img.xz](https://makerkitlab.xyz/data/kit/retroopi/retro-opi-0.16-armbian-25.08-orangepizero3.img.xz)
    - More coming...
2. Write the image to an SD card using programs such as:
    - [balenaEtcher](https://www.balena.io/etcher/) 
    - [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
    - [rufus](https://rufus.ie/)
3. Insert into SBC and power.

### USAGE:
#### <u>Automated Boot Process:</u>
1. Automatic login to user: `robot`.
2. Ascii splash.
3. Network check.
4. Network setup. `Esc` to cancel.
5. Enable file sharing if network check passes.
    - server: `\\retro-opi.local\roms`
    - user: `robot`
    - password: `retroopi`
6. Retro Pie start.
#### <u>Custom commands:</u>
- `ropi-play` :  Start Retro Pie.
- `ropi-resolution` : Sets a custom video resolution on boot.
- `ropi-connect` : Setup a network connection and file sharing.
#### <u>Credentials:</u>
- user: `robot` / `root`
- password: `retroopi`
#### <u>Hostname:</u>
- `retro-opi`
#### <u>SSH command:</u> 
- `ssh robot@retro-opi.local`

# BUILD (OPTIONAL):

### BUILD REQUIREMENTS:
- Orange Pi SBC
- Linux PC

### BUILD INSTRUCTIONS:
1.  `git clone https://github.com/Maker-Kit-Laboratories/RETRO-OPI.git`
2.  `cd RETRO-OPI`
3.  `./create-retro-opi-image.sh`

### NOTES:
- Version 0.17
- Tested on:
    - Zero 3
    - Zero 2W
    - 3 LTS


# SUPPORT:
- If you'd like to support this project, consider buying a kit @ [Maker Kit Laboratories - Printables](https://www.printables.com/@MakerKitLab_2578894)
- Comfirm supported boards and submit any issues you come across. Thanks!