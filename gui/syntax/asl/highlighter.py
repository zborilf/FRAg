from antlr4.CommonTokenStream import CommonTokenStream
from PyQt6.QtGui import QTextCharFormat, QColor, QFont

from compiler.agentspeak.asl.AgentSpeakLexer import AgentSpeakLexer
from compiler.agentspeak.asl.AgentSpeakParser import AgentSpeakParser

from ..base_highlighter import BaseSyntaxHighlighter, create_format


class ASLSyntaxHighlighter(BaseSyntaxHighlighter):
    keywords = ["for", "true", "false"]
    internal_actions = [".print", ".println", ".my_name"]
    def __init__(self, document, error_callback=None):
        super().__init__(document, error_callback)

        self.highlighting_rules += [
            (r'\b-?\d+(\.\d+)?\b', create_format("cyan")),  # Numbers (integers and decimals)
            (r'(?<!\.)\b[a-zA-Z_][a-zA-Z0-9_]*\([^)]*\)\.\s*$', create_format("orange")), # Beliefs
            (r'\?[a-zA-Z_][a-zA-Z0-9_]*\([^)]*\)', create_format("blue")),  # Test goals
            (r'\![a-zA-Z_][a-zA-Z0-9_]*', create_format("darkblue")),  # Main goals
            (r'\+![a-zA-Z_][a-zA-Z0-9_]*', create_format("green")),  # Triggered goals
            (r'//.*', create_format("gray")),  # Single-line comments
            (r'/\*[\s\S]*?\*/', create_format("gray")),  # Multi-line comments
        ]

    def get_parser(self, input_stream):
        lexer = AgentSpeakLexer(input_stream)
        token_stream = CommonTokenStream(lexer)
        parser = AgentSpeakParser(token_stream)
        return parser
