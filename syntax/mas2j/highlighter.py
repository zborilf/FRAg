from antlr4.CommonTokenStream import CommonTokenStream

from syntax.base_highlighter import BaseSyntaxHighlighter
from compiler.agentspeak.mas2j.MAS2JavaLexer import MAS2JavaLexer
from compiler.agentspeak.mas2j.MAS2JavaParser import MAS2JavaParser

class MAS2JSyntaxHighlighter(BaseSyntaxHighlighter):
    keywords = ["agents", "environment", "class", "parameters"]
    def __init__(self, document, error_callback=None):
        super().__init__(document, error_callback)

    def get_parser(self, input_stream):
        lexer = MAS2JavaLexer(input_stream)
        token_stream = CommonTokenStream(lexer)
        parser = MAS2JavaParser(token_stream)
        return parser
