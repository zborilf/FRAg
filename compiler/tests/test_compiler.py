import unittest
import tempfile
from pathlib import Path

from examples import get_example_file_path
from compiler.agentspeak.compiler import compile_mas

_example = 'do_it'


class TestMasCompiler(unittest.TestCase):
    def test_example(self):
        mas_file = get_example_file_path(_example, "mas2j")

        expected_mas_file = get_example_file_path(_example, "mas2fp").read_text()
        expected_agent_file = get_example_file_path(_example, "fap").read_text()

        with tempfile.TemporaryDirectory() as dir_name:
            returned_mas_file = compile_mas(mas_file.as_posix(), dir_name)
            expected_mas_file_path = Path(dir_name) / (_example + ".mas2fp")
            assert expected_mas_file_path == returned_mas_file

            compiled_mas_file = expected_mas_file_path.read_text()
            compiled_agent = (Path(dir_name) / (_example + ".fap")).read_text()

            self.assertEqual(compiled_mas_file, expected_mas_file)
            self.assertEqual(compiled_agent, expected_agent_file)


if __name__ == '__main__':
    unittest.main()
