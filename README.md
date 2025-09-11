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
    - Zero 2W -> [retro-opi-0.16-armbian-25.08-orangepizero2w.img.xz](https://makerkitlab.xyz/data/kit/retroopi/retro-opi-0.16-armbian-25.08-orangepizero2w.img.xz)
2. Use `balenaEtcher` or `Raspberry Pi Imager` to write to an SD card.
3. Insert into SBC and power.

### USAGE:
- Automated Boot Process:
    1. Automatic login to user: `robot`.
    2. Boot splash.
    3. Network check.
    4. Network setup. `Esc` to cancel.
    5. Enable file sharing if network check passes.
        - server: `\\retro-opi.local\roms`
        - user: `robot`
        - password: `retroopi`
    6. Run Retro Pie. `F4` to exit. Type `emlulationstation` in the console to restart.
- Helpful custom commands:
    - `ropi-set-resolution` : Sets a custom video resolution on boot.
    - `ropi-connect-network` : Setup a network connection and file sharing.
- Credentials:
    - user: `robot`  
    - password: `retroopi`
- Hostname: `retro-opi`
- SSH command: `ssh robot@retro-opi.local`

# BUILD (OPTIONAL):

### BUILD REQUIREMENTS:
- Orange Pi SBC
- Linux PC

### BUILD INSTRUCTIONS:
1.  `git clone https://github.com/Maker-Kit-Laboratories/RETRO-OPI.git`
2.  `cd RETRO-OPI`
3.  `./create-retro-opi-image.sh`

### NOTES:
- Version 0.16
- Tested on:
    - Zero 3
    - Zero 2W


# SUPPORT:
- If you'd like to support this project, consider buying a kit @ [Maker Kit Laboratories - Printables](https://www.printables.com/@MakerKitLab_2578894)

- Comfirm supported boards and submit any issues you come across. Thanks!

