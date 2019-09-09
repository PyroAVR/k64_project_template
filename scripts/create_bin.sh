#!/bin/sh
arm-none-eabi-objcopy -O binary ${MESON_BUILD_ROOT}/main ${MESON_BUILD_ROOT}/main.bin
