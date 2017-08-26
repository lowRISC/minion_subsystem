#!/usr/bin/env/python
#
# Using the file system load
#
# We now assume we have a file in the same dir as this one called
# test_template.html
#

import json
import sys
from jinja2 import Environment, FileSystemLoader

mod = []

def get_configuration(file):
    global mod
    json_file = open(file)
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
    if len(sys.argv) <= 1:
        file = 'conf/minion_config.json'
    else:
        file = sys.argv[1]
    get_configuration(file)
    code_generation()
