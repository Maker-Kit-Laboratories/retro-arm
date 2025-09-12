# RETRO-OPI CONSOLE
![Retro Opi Image](./documentation/retro-opi-image-3.png)

### DESCRIPTION:
- Custom armbian build script intregrating Retro Pie and optional retro-brew ROMs.
- Version 0.18

### PRE-BUILT IMAGE REQUIREMENTS:
- Tested SBCs:
    - Zero 3
    - Zero 2w
    - 3 LTS
- 8GB+ Micro SD Card

### PRE-BUILT IMAGE INSTRUCTIONS:
1. Download pre-built image here:
    - Zero 3 -> Coming...
    - Zero 2w -> Coming...
    - 3 LTS -> Coming...
2. Write the image to an SD card using programs such as:
    - [balenaEtcher](https://www.balena.io/etcher/) 
    - [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
    - [rufus](https://rufus.ie/)
3. Insert into SBC and power.

### USAGE:
#### Automated Boot Process:
1. Automatic login to user: `robot`.
2. Ascii splash.
3. Network check. 
4. `INITIAL BOOT ONLY` - Network setup. `Esc` to cancel.
5. Enable file sharing if network check passes.
    - server: `\\retro-opi.local\roms`
    - user: `robot`
    - password: `retroopi`
6. `INITIAL BOOT ONLY` - Resolution setup: 1280x720 or below depending on your SBC's capabilities.
7. `INITIAL BOOT ONLY` - Reboot.
8. Retro Pie starts.
#### Custom commands:
- `ropi-play` :  Start Retro Pie.
- `ropi-resolution` : Sets a custom video resolution on boot.
- `ropi-connect` : Setup a network connection and file sharing.
#### Credentials:
- user: `robot` / `root`
- password: `retroopi`
#### Hostname: 
- `retro-opi`
#### SSH command: 
- `ssh robot@retro-opi.local`

# BUILD (OPTIONAL):

### BUILD REQUIREMENTS:
- Orange Pi SBC
- Linux PC

### BUILD INSTRUCTIONS:
1.  `git clone https://github.com/Maker-Kit-Laboratories/RETRO-OPI.git`
2.  `cd RETRO-OPI`
3.  `./create-retro-opi-image.sh` Optional arguments: `BOARD=<configname>`


## LICENSE:
- CC BY 4.0
- [Armbian](https://www.armbian.com/), [RetroPie](https://retropie.org.uk/), and all optionally included open source [retrobrews](https://retrobrews.github.io/) are under their respective licenses.


# SUPPORT:
- If you'd like to support this project, consider buying a RETRO-OPI kit @ [Maker Kit Laboratories - Printables](https://www.printables.com/@MakerKitLab_2578894)

- Comfirm supported boards and submit any issues you come across. Thanks!