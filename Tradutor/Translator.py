import re
import sys, getopt

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


def translate(input_file, word_length):
    result = []
    with open(input_file) as f:
        for line in f:
            line = line.split('--')[0]  # ignore comments
            line = line.strip()  # ignore whitespaces

            if len(line) == 0:
                continue

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

            print instruction + parameter
            result.append(instruction + parameter)
    return result


def usage():
    print 'Usage: Translator.py -n <word length> -i <inputfile> -o <outputfile>'


def main(argv):

    if len(argv) < 6:
        usage()
        sys.exit(2)

    try:
        opts, args = getopt.getopt(argv, "n:i:o:h")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit(2)
        elif opt == '-i':
            input_file = arg
        elif opt == '-o':
            output_file = arg
        elif opt == '-n':
            word_length = int(arg)
        else:
            usage()
            sys.exit(2)

    trans = translate(input_file, word_length)
    f = open(output_file, 'w')
    for line in trans:
        f.write(line + '\n')
    f.close()


if __name__ == "__main__":
    main(sys.argv[1:])