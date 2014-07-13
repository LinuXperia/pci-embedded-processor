import re
import os

input_filename = './input.asm'
output_filename = './output.txt'

word_length = 12

regexes = {
    'decimal_regex': '^([a-zA-Z]+)(\s(\d+))?$',
    'hexadecimal_regex': '^([a-zA-Z]+)(\s0x([a-fA-F0-9]+))?$',
    'data_decimal': '^([0-9]+)$',
    'data_hexadecimal': '^(0x[a-fA-F0-9]+)$'
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


def fill_with_zeros(param, number):
    fill = '0'
    fill *= number
    result = fill + param
    return result


def translate(filename):
    result = []
    with open(filename) as f:
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

            is_data = numeric_type == 'data_decimal' or numeric_type == 'data_hexadecimal';

            if not is_data:
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
                    if len(instruction) + len(parameter) > word_length:
                        raise ValueError('Word length must be ', word_length, 'bits. On line: ', line)
            else:
                parameter = mat.groups()[0]
                parameter = bin(int(parameter, 0))[2:]
                if len(parameter) > word_length:
                    raise ValueError('Word length must be ', word_length, 'bits. On line: ', line)

            if parameter is None:
                parameter = fill_with_zeros('', word_length - len(instruction))
            else:
                n = (word_length - len(instruction) - len(parameter))
                parameter = fill_with_zeros(parameter, n)

            print key, instruction, parameter
            result.append(instruction + parameter)
    return result

def main():
    trans = translate(input_filename)
    f = open(output_filename, 'w')
    for line in trans:
        f.write(line + '\n')
    f.close()


if __name__ == "__main__":
    main()