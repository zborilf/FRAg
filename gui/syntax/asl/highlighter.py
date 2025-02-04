from antlr4.CommonTokenStream import CommonTokenStream

from compiler.agentspeak.asl.AgentSpeakLexer import AgentSpeakLexer
from compiler.agentspeak.asl.AgentSpeakParser import AgentSpeakParser

from ..base_highlighter import BaseSyntaxHighlighter, create_format


class ASLSyntaxHighlighter(BaseSyntaxHighlighter):
    logical_operators = ["true", "false"]
    control_structures = ["for"]
    agent_actions = [".print", ".println", ".my_name"]

    def __init__(self, document, error_callback=None):
        super().__init__(document, error_callback)

    def add_language_specific_rules(self):
        # Add ASL-specific rules
        self.add_rule(r'(?<!\.)\b[a-zA-Z_][a-zA-Z0-9_]*\([^)]*\)\.\s*$', create_format("orange"))  # Beliefs
        self.add_rule(r'\?[a-zA-Z_][a-zA-Z0-9_]*\([^)]*\)', create_format("blue"))  # Test goals
        self.add_rule(r'\![a-zA-Z_][a-zA-Z0-9_]*', create_format("darkblue"))  # Main goals
        self.add_rule(r'\+![a-zA-Z_][a-zA-Z0-9_]*', create_format("green"))  # Triggered goals

        logical_operators_format = create_format("blue", bold=True)
        control_structures_format = create_format("blue", bold=True)
        agent_actions_format = create_format("purple", bold=True)

        for op in self.logical_operators:
            self.add_rule(rf"\b{op}\b", logical_operators_format)

        for struct in self.control_structures:
            self.add_rule(rf"\b{struct}\b", control_structures_format)

        for action in self.agent_actions:
            self.add_rule(rf"\b{action}\b", agent_actions_format)

    def get_parser(self, input_stream):
        lexer = AgentSpeakLexer(input_stream)
        token_stream = CommonTokenStream(lexer)
        parser = AgentSpeakParser(token_stream)
        return parser
