from antlr4 import InputStream, CommonTokenStream

from compiler.agentspeak.mas2j.MAS2JavaLexer import MAS2JavaLexer
from compiler.agentspeak.mas2j.MAS2JavaParser import MAS2JavaParser

def validate_mas2j_syntax(text):
    """Validates MAS2J syntax using ANTLR."""
    input_stream = InputStream(text)
    lexer = MAS2JavaLexer(input_stream)
    token_stream = CommonTokenStream(lexer)
    parser = MAS2JavaParser(token_stream)

    try:
        parser.mas()
        return True, None
    except Exception as e:
        return False, str(e)
