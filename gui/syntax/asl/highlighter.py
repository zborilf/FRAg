from antlr4.CommonTokenStream import CommonTokenStream

from compiler.agentspeak.asl.AgentSpeakLexer import AgentSpeakLexer
from compiler.agentspeak.asl.AgentSpeakParser import AgentSpeakParser

from ..base_highlighter import BaseSyntaxHighlighter

class ASLSyntaxHighlighter(BaseSyntaxHighlighter):
    keywords = ["action", "goal"]
    def __init__(self, document, error_callback=None):
        super().__init__(document, error_callback)

    def get_parser(self, input_stream):
        lexer = AgentSpeakLexer(input_stream)
        token_stream = CommonTokenStream(lexer)
        parser = AgentSpeakParser(token_stream)
        return parser
