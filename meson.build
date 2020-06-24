project('k64_base', 'c')

# dependencies
dependencies = []

# Project include path.
local_headers = ['include']

# Do not remove the core files if you are not certain of what you are doing.
# List of C sources to compile. Relative to project root.
c_sources = [
    'core/system_MK64F12.c',
    'src/kernel/hardfault.c',
    'src/kernel/kernel_support.c',
    'src/kernel/environment.c',
    'src/kernel/abort.c',
    'src/kernel/sbrk.c',
    'src/nongnu/unistd.c',
    'src/drivers/uart.c',
    'src/programs/dma.c'
]

# List of ASM sources to compile.  Relative to project root.
asm_sources = [
    'core/startup_MK64F12.S',
    'src/asmlib/queue.s',
    'src/asmlib/uart_driver.s'
]

# Environmental/platform include paths.  Edit this to where you have these
# repositories cloned.
EXTERNAL_REPO_ROOT = '/opt/repos/'
# github.com/ARM-software/CMSIS_5
cmsis_includes = [EXTERNAL_REPO_ROOT + 'CMSIS_5/CMSIS/Core/Include']
# github.com/ARMmbed/cmsis-core-k64f
k64_includes = [EXTERNAL_REPO_ROOT + 'cmsis-core-k64f/cmsis-core-k64f']

## project setup

# debug build
if get_option('buildtype') == 'debug'
    # make a debug build target!
    # FIXME this won't work for asm targets...
    add_project_arguments(['-DDEBUG=1', '-ggdb3', '-O0'], language: 'c')
endif

# use default clock?
add_project_arguments(['-DCLOCK_SETUP=1'], language: 'c')


### DON'T EDIT BELOW THIS LINE ###


# meson does not support using include_directories inside a generator...
# generators run in the build dir, which breaks relative includes.
_includes = local_headers + cmsis_includes + k64_includes
_incl_dirs = include_directories(_includes)

_asm_incl_args = []

foreach incl_path: (cmsis_includes + k64_includes)
    _asm_incl_args += ('-I' + incl_path)
endforeach

# patch local includes for asm
foreach incl_path: local_headers
    _asm_incl_args += ('-I' + meson.source_root() + '/' + incl_path)
endforeach

arm_gcc = find_program('arm-none-eabi-gcc')

arm_as = generator(arm_gcc, output: '@BASENAME@.o',
# hardfloat screws up libgcc
#'-mfpu=fpv4-sp-d16', 
    arguments: ['-fworking-directory', meson.source_root(), '-x', 'assembler-with-cpp', '-mcpu=cortex-m4', '-ggdb3'] + _asm_incl_args + ['-c', '@INPUT@', '-o', '@BUILD_DIR@/@BASENAME@.o']
)

asm_objects = arm_as.process(asm_sources)
asm_static_object = static_library('asm_static_object', asm_objects)

#meson.add_install_script('scripts/create_bin.sh')

main = executable(
    'main.elf',
    c_sources,
    include_directories: _incl_dirs,
    link_with: asm_static_object,
    dependencies: dependencies,
    install: true,
    install_dir: false
)
main_binary = custom_target(
    'main.bin',
    command: ['@SOURCE_DIR@/scripts/create_bin.sh', 'main.elf', '@OUTPUT@'],
    depends: main,
    output: 'main.bin',
    build_by_default: true
)
