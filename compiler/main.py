import sys
from antlr4 import CommonTokenStream, FileStream
from agentspeak.antlr.AgentSpeakLexer import AgentSpeakLexer
from agentspeak.antlr.AgentSpeakParser import AgentSpeakParser


def main(argv):
    input_stream = FileStream(argv[1] if len(argv) > 1 else 'agentspeak/examples/e1_a1.asl')
    lexer = AgentSpeakLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = AgentSpeakParser(stream)
    tree = parser.agent()


if __name__ == '__main__':
    main(sys.argv)
