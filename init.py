"""
Project init file, to set up paths.  This is a workaround for Meson's inability
to use relative-path cross compilation paths.
"""


import os
import subprocess
import sys
import shlex


def find_toolchain(what):
    """
    Find an appropriate install of arm-none-eabi-gcc
    """
    arm_gcc = subprocess.check_output(['which', shlex.quote(what)]).decode('utf-8')
    return arm_gcc[:arm_gcc.rfind('/')]



def find_root():
    """
    Return the current project root
    """
    this_script_location = os.path.abspath(__file__)
    return this_script_location[:this_script_location.rfind('/')]


pyinit_replacements = {
    "PYINIT_CONFIG_TOOLCHAIN_BASE": find_toolchain('arm-none-eabi-gcc'),
    "PYINIT_CONFIG_PROJECT_ROOT": find_root() + '/k64_files'
}

# FIXME change this to a tree walk of template_files
replacement_files = [('template_files/k64_files/k64_cross_properties.cfg', 'k64_files/k64_cross_properties.cfg')]

for template_pair in replacement_files:
    with open(template_pair[0], 'r') as template_file:
        with open(template_pair[1], 'w') as output_file:
            for line in template_file:
                output_file.write(line.format(**pyinit_replacements))
