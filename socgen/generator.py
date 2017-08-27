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

def gen_parameters():
    global mod

    parameters = {}

    for per in mod:
        if per['peripheral_type'] == 'CORE':
            if 'core_lockstep' in per:
                parameters['cls'] = per['core_lockstep']
            else:
                parameters['cls'] = False

            if 'fault_injection' in per and parameters['cls']:
                parameters['finj'] = per['fault_injection']
            else:
                parameters['finj'] = False

            if 'vio' in per and parameters['finj']:
                parameters['vio'] = per['vio']
            else:
                parameters['vio'] = False

            if 'btn' in per and parameters['finj']:
                parameters['btn'] = per['btn']
            else:
                parameters['btn'] = False

            if 'pin' in per and parameters['finj']:
                parameters['pin'] = per['pin']
            else:
                parameters['pin'] = False

    return parameters


def code_generation():
    global mod
    # Create the jinja2 environment.
    # Notice the use of trim_blocks, which greatly helps control whitespace.
    env = Environment(loader=FileSystemLoader('templates'))
                        # trim_blocks=True)
    template = env.get_template('minion_soc.template')
    output_from_parsed_template = template.render(module= mod)
    print output_from_parsed_template
    with open("minion_soc.sv", "wb") as f:
        f.write(output_from_parsed_template)

    params = gen_parameters()

    template = env.get_template('soc/coremem.template')
    output_from_parsed_template = template.render(cls = params['cls'])
    print output_from_parsed_template
    with open("coremem.sv", "wb") as f:
        f.write(output_from_parsed_template.encode('utf8'))

    template = env.get_template('soc/top_arty.template')
    output_from_parsed_template = template.render(par = params)
    print output_from_parsed_template
    with open("top_arty.sv", "wb") as f:
        f.write(output_from_parsed_template.encode('utf8'))

    if params['finj']:
        template = env.get_template('soc/minion_cls.template')
        output_from_parsed_template = template.render(finj = params['finj'])
        print output_from_parsed_template
        with open("minion_cls.sv", "wb") as f:
            f.write(output_from_parsed_template.encode('utf8'))

if __name__ == '__main__':
    if len(sys.argv) <= 1:
        file = 'conf/minion_config.json'
    else:
        file = sys.argv[1]
    get_configuration(file)
    code_generation()
