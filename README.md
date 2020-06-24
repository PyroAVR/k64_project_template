# K64 MCU Project Template

## Requirements
1. Clone the following repositories to a common location readable by your user.
    - ARMmbed/core-cmsis-k64f
    - ARM-software/CMSIS\_5

2. Install [Meson](https://mesonbuild.com).

3. Install the following:
    - `arm-none-eabi-gcc`
    - `arm-none-eabi-binutils`
    - `arm-none-eabi-newlib` (optional)
    - `arm-none-eabi-gdb` (recommended, for debugging)
    - `openocd` (recommended, for flashing)

## Building Your Project
1. Customize the `meson.build` file to include the files for your project.
    - Set `EXTERNAL_REPO_ROOT` to the location where you cloned the repositories
      in requirements step 1.  Do not omit the trailing slash.
    - C source files should be added separately from ASM source files, as denoted
   in the build file.
    - `local_headers` should be set to the root of the include search tree.
      __Do not list every header file.__
    - Add any project options you require with `add_project_arguments`

2. Run `python init.py`. Only Python 3 is supported.  This script will customize
   files in template_files with the included replacements.  This may be extended
   for your project if necessary, and acts as a way to configure the build
   before handing over control to meson.

3. Run `meson <build dir> --cross-file k64_files/k64_cross_properties.cfg`.
   This will create a Ninja build description in `<build dir>`.

4. Run `ninja install` from `<build dir>`.  This will create a binary file which
   can be flashed to the K64 in `<build dir>`

## Flashing the Target
An OpenOCD flash description usable for k64 should be included by the default
install of OpenOCD.  In the case it is not, it has been included in `k64_files`.
The file `scripts/flash.sh` references this included file.
1. Run `scripts/flash.sh`.  If all goes well, the lights on your K64 board will
   light up and your code will be running immediately.

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
