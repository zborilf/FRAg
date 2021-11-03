import sys
from antlr4 import CommonTokenStream, FileStream, ParseTreeWalker
from agentspeak.frag_generator import FragGenerator
from agentspeak.parser.AgentSpeakLexer import AgentSpeakLexer
from agentspeak.parser.AgentSpeakParser import AgentSpeakParser


def main(argv):
    input_stream = FileStream(argv[1] if len(argv) > 1 else 'agentspeak/examples/e1_a1.asl')
    lexer = AgentSpeakLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = AgentSpeakParser(stream)
    tree = parser.agent()

    frag_generator = FragGenerator()
    walker = ParseTreeWalker()
    walker.walk(frag_generator, tree)


if __name__ == '__main__':
    main(sys.argv)
