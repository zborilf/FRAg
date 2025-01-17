from antlr4.CommonTokenStream import CommonTokenStream

from compiler.agentspeak.mas2j.MAS2JavaLexer import MAS2JavaLexer
from compiler.agentspeak.mas2j.MAS2JavaParser import MAS2JavaParser

from ..base_highlighter import BaseSyntaxHighlighter, create_format

class MAS2JSyntaxHighlighter(BaseSyntaxHighlighter):
    keywords = [
        "agents", "environment", "class", "parameters", "infrastructure",
        "quantity", "mas", "entity", "architecture", "MAS"
    ]

    internal_actions = ["Centralised"]

    def __init__(self, document, error_callback=None):
        super().__init__(document, error_callback)

        self.highlighting_rules += [
            (r"\b\d+\b", create_format("cyan")),
            (r"//.*", create_format("gray")),  # Single-line comments
            (r"/\*[\s\S]*?\*/", create_format("gray")),  # Multi-line comments
            (r"(?<=\bagents:)\s*[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z0-9_]+)?", create_format("green"))  # Entity names
        ]

    def get_parser(self, input_stream):
        lexer = MAS2JavaLexer(input_stream)
        token_stream = CommonTokenStream(lexer)
        parser = MAS2JavaParser(token_stream)
        return parser
