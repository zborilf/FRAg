from antlr4 import InputStream, CommonTokenStream

from compiler.agentspeak.asl.AgentSpeakLexer import AgentSpeakLexer
from compiler.agentspeak.asl.AgentSpeakParser import AgentSpeakParser

def validate_asl_syntax(text):
    """Validates ASL syntax using ANTLR."""
    input_stream = InputStream(text)
    lexer = AgentSpeakLexer(input_stream)
    token_stream = CommonTokenStream(lexer)
    parser = AgentSpeakParser(token_stream)

    try:
        parser.agent()
        return True, None
    except Exception as e:
        return False, str(e)
