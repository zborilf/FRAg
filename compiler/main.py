import sys
from agentspeak.compiler import compile_mas


def main(argv):
    compile_mas(argv[1], argv[2])


if __name__ == '__main__':
    main(sys.argv)
