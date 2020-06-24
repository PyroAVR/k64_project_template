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
1. Run `openocd -f scripts/frdm-k64f.cfg`.  Ensure that your user is able to
   directly communicate with the device.
2. From another pty, run `telnet localhost 4444`.  This will allow you to
   control OpenOCD when GDB gets out of sync with the target.
3. From another pty, run `scripts/gdb.sh build/main`.  You may need to change
   the target file if you edited the inner workings of the `meson.build` file.
