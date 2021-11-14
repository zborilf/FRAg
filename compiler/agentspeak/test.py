import unittest

from antlr4 import CommonTokenStream, FileStream, ParseTreeWalker

from frag_generator import FragGenerator
from agentspeak.asl.AgentSpeakLexer import AgentSpeakLexer
from agentspeak.asl.AgentSpeakParser import AgentSpeakParser


def _compile(example_name: str) -> str:
    input_stream = FileStream(f'examples/{example_name}.asl')
    lexer = AgentSpeakLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = AgentSpeakParser(stream)
    tree = parser.agent()

    frag_generator = FragGenerator()
    walker = ParseTreeWalker()
    walker.walk(frag_generator, tree)

    return frag_generator.output


def _get_expected_output(example_name: str) -> str:
    with open(f'examples/{example_name}.fap', 'r') as f:
        return f.read()


def _get_example(example_name: str) -> tuple[str, str]:
    output = _compile(example_name)
    expected_output = _get_expected_output(example_name)

    return output, expected_output


_examples = ('factorial', 'do_it')


class TestFragGenerator(unittest.TestCase):
    def test_examples(self):
        for example in _examples:
            output, expected_output = _get_example(example)

            self.assertEqual(output, expected_output)


if __name__ == '__main__':
    unittest.main()
