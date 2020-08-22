# K64 MCU Project Template

## Requirements
1. You will need the Board Support Package (BSP) from NXP.  The bare minimum
   files are included here for convenience, so this should not be necessary.
   To obtain the latest BSP:
   1. Create an account on [nxp.com](https://nxp.com)
   2. Use the [MCUexpresso SDK Builder](https://mcuxpresso.nxp.com/en/select)
      to select and download your desired components
   3. Place the relevant files and subdirectories in core/include and core/src.
   4. The `startup_MK64F12.S` file may be found here, for unknown reasons
      it is not included in the MCUexpresso SDK:
      [CMSIS CM4 boot code](https://github.com/ARMmbed/mbed-hal-k64f)

   Please note that using any of the MCUexpresso drivers with this project is
   not tested.  The maintainers of this project have no experience with them.

2. Install [Meson](https://mesonbuild.com).

3. Install the following:
    1. For Arch derivatives:
        - `arm-none-eabi-gcc`
        - `arm-none-eabi-binutils`
        - `arm-none-eabi-newlib` (optional, for libc functions)
        - `arm-none-eabi-gdb` (recommended, for debugging)
        - `openocd` (recommended, for flashing)
    2. For Debian derivatives:
        - `gcc-arm-none-eabi`
        - `binutils-arm-none-eabi`
        - `libnewlib-arm-none-eabi`
        - `gdb-multiarch` (includes arm-none-eabi)
        - `openocd`
4. (Optional) In the event that flashing fails, you may need to add some udev rules:
    1. As root, create three files under `/etc/udev/rules.d` with the following names and contents:
        - `45-mbed_debugger.rules`
            ```
            SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", ATTR{idProduct}=="0204", MODE="0660", GROUP="plugdev"
            ```
        - `50-tty_cmsis.rules`
            ```
            KERNEL=="ttyACM[0 ... 9]" SYMLINK+="%k" GROUP="plugdev" MODE="0660"
            ```
        - `99-hidraw-permissions.rules`
            ```
            KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="plugdev" 
            ```
    2. Create the plugdev group, if it does not exist:
        ```
        sudo getent group plugdev || sudo groupadd plugdev
        ```
    3. Add your user to the plugdev group:
        ```
        sudo usermod -aG plugdev $USER
        ```
    4. And finally, reload the udev rules:
        ```
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        ```


## Building Your Project
1. Customize the `meson.build` file to include the files for your project.
    - C source files should be added separately from ASM source files,
      as denoted in the build file.
    - `local_headers` should be set to the root of the include search tree.
      __Do not list every header file.__
    - Add any project options you require with `add_project_arguments`
    - Define the correct CPU for your target. (default: MK64FN1M0VLL12)

2. Run `python init.py`. Only Python 3 is supported.  This script will customize
   files in template\_files with the included replacements.  This may be
   extended for your project if necessary, and acts as a way to configure the
   build before handing over control to meson.

3. Run `meson <build dir> --cross-file k64_files/k64_cross_properties.cfg`.
   This will create a Ninja build description in `<build dir>`.

4. Run `ninja -C <build dir>`.  This will create a binary file which
   can be flashed to the K64 in `<build dir>`.

## Flashing the Target
An OpenOCD flash description usable for k64 should be included by the default
install of OpenOCD.  In the case it is not, it has been included in `k64_files`.
The file `scripts/flash.sh` references this included file.
1. Run `scripts/flash.sh`.  If all goes well, the lights on your K64 board will
   light up and your code will be running immediately.
2. To kill the running OpenOCD session, run `scripts/openocd_server.sh stop`.

## Debugging the Target
OpenOCD provides a GDB server which acts as an arbiter for the actual debug
protocols used on target devices, OpenSDA in this case.
Do the following:
1. From your terminal, run `scripts/gdb.sh build/main.elf`.  You may need to
   change the target file if you edited the inner workings of `meson.build`
2. From another pty, run `telnet localhost 4444`.  This will allow you to
   control OpenOCD when GDB gets out of sync with the target.
3. In the telnet shell, type `reset init` before doing anything in GDB. This
   allows OpenOCD to sync GDB to the current state of the MCU before continuing.

When debugging and flashing, an OpenOCD server is started that runs in the
background.  The scripts here create a PID file in case you need to kill it
manually, which is located at the project root with the name `openocd.pid`.
Normally, this should not be necessary.  Running
`scripts/openocd_server.sh stop` or typing `shutdown` in the telnet console
should be enough to end your OpenOCD session gracefully.

When debugging the target, a new ROM may be flashed to the device, but GDB will
not be aware of the change, nor the reset.  By default, the flash script causes
the target to be running after a flash, meaning that `reset init` must be issued
in the telnet console in order to reset and halt the target.  Note that GDB will
still not be aware of the new debugging symbols, so it needs to be restarted or
the ELF file reloaded for correct source-level debugging.
