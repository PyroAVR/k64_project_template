project('k64', 'c')


local_headers = ['include']
c_sources = ['src/system_MK64F12.c', 'src/uart.c', 'src/main.c']
asm_sources = [
    'src/startup_MK64F12.S',
#    'src/asmlib/uart0_driver.s'
]

# environmental/platform includes
cmsis_includes = ['../CMSIS_5/CMSIS/Core/Include']
k64_includes = ['../cmsis-core-k64f/cmsis-core-k64f']

# project setup

# debug build
if get_option('buildtype') == 'debug'
    # make a debug build target!
    # FIXME this won't work for asm targets...
    add_project_arguments(['-DDEBUG=1', '-ggdb3', '-O0'], language: 'c')
endif

# use default clock?
add_project_arguments(['-DCLOCK_SETUP=1'], language: 'c')


### DON'T EDIT BELOW THIS LINE ###


_includes = local_headers + cmsis_includes + k64_includes
_incl_dirs = include_directories(_includes)

_asm_incl_args = []
foreach incl_path: _includes
    _asm_incl_args += ('-I' + incl_path)
endforeach


arm_gcc = find_program('arm-none-eabi-gcc')

arm_as = generator(arm_gcc, output: '@BASENAME@.o',
    arguments: ['-x', 'assembler-with-cpp'] + _asm_incl_args + ['-c', '@INPUT@', '-o', '@BUILD_DIR@/@BASENAME@.o']
)

asm_objects = arm_as.process(asm_sources)
asm_static_object = static_library('asm_static_object', asm_objects)

meson.add_install_script('create_bin.sh')

main = executable('main',
    c_sources,
    include_directories: _incl_dirs,
    link_with: asm_static_object,
    install: true,
    install_dir: false
)
