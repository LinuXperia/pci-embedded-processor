import re

input_filename = './input.asm'
output_filename = './output.txt'

regexes = {
    'decimal_regex': '^([a-zA-Z]*)(\s(\d*))?$',
    'hexadecimal_regex': '^([a-zA-Z]*)(\s0x([a-fA-F0-9]*))?$'
}

# tuple (address, unary)
encode = {
    'load': ('0000', False),
    'store': ('0001', False),
    'add': ('0010', False),
    'sub': ('0011', False),
    'inc': ('0100', True),
    'dec': ('0101', True),
    'not': ('0110', True),
    'and': ('0111', False),
    'or': ('1000', False),
    'xor': ('1001', False),
    'jump': ('1010', False),
    'be': ('1011', False),
    'bg': ('1100', False),
    'bl': ('1101', False),
    'wait': ('1110', True),
    'nop': ('1111', True)
}

with open(input_filename) as f:
    for line in f:
        line = line.split('--')[0]  # ignore comments
        line = line.strip()  # ignore whitespaces

        numeric_type = ''
        instruction = ''
        parameter = ''

        for key in regexes:
            regex = re.compile(regexes[key])
            mat = regex.match(line)

            if mat is not None:
                numeric_type = key
                break

        if not numeric_type:
            raise ValueError('Syntax error on line: ', line)

        try:
            encoded_value = encode[mat.groups()[0].lower()]
        except KeyError:
            raise ValueError('Unknown instruction on line: ', line)

        parameter = mat.groups()[1]

        if encoded_value[1] is False and not parameter:
            raise ValueError('Expected parameter on line: ', line)

        instruction = encoded_value[0]

        if encoded_value[1] is False:
            parameter = bin(int(parameter, 0))[2:]

        print instruction, parameter