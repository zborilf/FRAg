import os
import sys
from pathlib import Path

from antlr4 import CommonTokenStream, FileStream, ParseTreeWalker

from .asl.AgentSpeakLexer import AgentSpeakLexer
from .asl.AgentSpeakParser import AgentSpeakParser
from .mas2j.MAS2JavaLexer import MAS2JavaLexer
from .mas2j.MAS2JavaParser import MAS2JavaParser
from .frag_generator import FragGenerator
from .mas2fp_generator import Mas2fpGenerator, Agent

# TODO: more agents
def _compile_mas_file(path: str) -> tuple[str, Agent]:
    input_stream = FileStream(path)
    lexer = MAS2JavaLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = MAS2JavaParser(stream)
    tree = parser.mas()

    mas2f_generator = Mas2fpGenerator()
    walker = ParseTreeWalker()
    walker.walk(mas2f_generator, tree)

    return mas2f_generator.output, mas2f_generator.agent


def _compile_asl_file(path: str) -> str:
    input_stream = FileStream(path)
    lexer = AgentSpeakLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = AgentSpeakParser(stream)
    tree = parser.agent()

    frag_generator = FragGenerator()
    walker = ParseTreeWalker()
    walker.walk(frag_generator, tree)

    return frag_generator.output


def compile_mas(mas_path: str, output_dir_path) -> Path:
    if not os.path.exists(output_dir_path):
        os.makedirs(output_dir_path)

    source_dir = Path(mas_path).parent.resolve()

    mas_compiled, agent_info = _compile_mas_file(mas_path)
    agent_compiled = _compile_asl_file((source_dir / agent_info.filename.replace("fap", "asl")).as_posix())

    output_dir = Path(output_dir_path)

    mas_file_name = Path(mas_path).name.replace("mas2j", "mas2fp")
    mas2fp_file = output_dir / mas_file_name
    with mas2fp_file.open("w") as f:
        f.write(mas_compiled)

    # TODO: handle more directories

    agent_file_name = Path(agent_info.filename).name
    with (output_dir / agent_file_name).open("w") as f:
        f.write(agent_compiled)

    return mas2fp_file


if __name__ == "__main__":
    compile_mas(sys.argv[1], sys.argv[2])
