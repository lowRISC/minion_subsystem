#!/usr/bin/env/python
#
# Using the file system load
#
# We now assume we have a file in the same dir as this one called
# test_template.html
#

import json
from jinja2 import Environment, FileSystemLoader

# mod = [
#     {'peripheral_type' : 'UART',
#      'peripheral_number' : 1 },
#     {'peripheral_type' : 'UART',
#      'peripheral_number' : 2 },
#     {'peripheral_type' : 'LED',
#      'peripheral_number' : 2 } ]

mod = []

def get_configuration():
    global mod
    json_file = open('conf/minion_config.json')
    json_str = json_file.read()
    mod = json.loads(json_str)
    print mod

def check_configuration():
    check_memory_region()


def code_generation():
    global mod
    # Create the jinja2 environment.
    # Notice the use of trim_blocks, which greatly helps control whitespace.
    env = Environment(loader=FileSystemLoader('templates'),
                         trim_blocks=True)
    template = env.get_template('minion_soc.template')
    output_from_parsed_template = template.render(module= mod)
    print output_from_parsed_template
    with open("minion_soc.sv", "wb") as f:
        f.write(output_from_parsed_template)

if __name__ == '__main__':
    get_configuration()
    code_generation()
