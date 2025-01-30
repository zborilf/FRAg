import unittest

from antlr4 import CommonTokenStream, FileStream, ParseTreeWalker

from compiler.agentspeak.frag_generator import FragGenerator
from compiler.agentspeak.asl.AgentSpeakLexer import AgentSpeakLexer
from compiler.agentspeak.asl.AgentSpeakParser import AgentSpeakParser

from .examples import get_example_file_path


def _compile(example_name: str) -> str:
    input_stream = FileStream(get_example_file_path(example_name, 'asl').as_posix())
    lexer = AgentSpeakLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = AgentSpeakParser(stream)
    tree = parser.agent()

    frag_generator = FragGenerator()
    walker = ParseTreeWalker()
    walker.walk(frag_generator, tree)

    return frag_generator.output


def _get_expected_output(example_name: str) -> str:
    return get_example_file_path(example_name, 'fap').read_text()


def _get_example(example_name: str) -> tuple[str, str]:
    output = _compile(example_name)
    expected_output = _get_expected_output(example_name)

    return output, expected_output


_examples = ('factorial', 'do_it', 'e2_a1')


class TestFragGenerator(unittest.TestCase):
    def test_examples(self):
        for example in _examples:
            output, expected_output = _get_example(example)

            self.assertEqual(output, expected_output)


if __name__ == '__main__':
    unittest.main()
