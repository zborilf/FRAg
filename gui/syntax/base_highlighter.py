import re
from abc import abstractmethod

from PyQt6.QtGui import QSyntaxHighlighter, QTextCharFormat, QColor, QFont
from antlr4.InputStream import InputStream
from antlr4.error.ErrorListener import ErrorListener


class CustomSyntaxError(Exception):
    def __init__(self, msg, line, column):
        super().__init__(msg)
        self.line = line
        self.column = column

class SyntaxErrorListener(ErrorListener):
    """Custom error listener to catch syntax errors during parsing."""
    def __init__(self, text_edit):
        self.text_edit = text_edit

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        error_msg = f"line {line}, column {column}: {msg}"
        raise CustomSyntaxError(error_msg, line, column)


class BaseSyntaxHighlighter(QSyntaxHighlighter):
    keywords = []

    def __init__(self, document, error_callback=None):
        super().__init__(document)
        self.highlighting_rules = []
        self.error_callback = error_callback
        self.errors = []

        # Formats for highlighting
        self.error_format = QTextCharFormat()
        self.error_format.setForeground(QColor("red"))
        self.error_format.setUnderlineStyle(QTextCharFormat.UnderlineStyle.SingleUnderline)

        keyword_format = QTextCharFormat()
        keyword_format.setForeground(QColor("blue"))
        keyword_format.setFontWeight(QFont.Weight.Bold)

        comment_format = QTextCharFormat()
        comment_format.setForeground(QColor("green"))
        comment_format.setFontItalic(True)

        string_format = QTextCharFormat()
        string_format.setForeground(QColor("magenta"))

        # Adding syntax rules for keywords, comments, and strings
        self.highlighting_rules += [(rf"\b{keyword}\b", keyword_format) for keyword in self.keywords]
        self.highlighting_rules.append((r"//[^\n]*", comment_format))
        self.highlighting_rules.append((r"\".*?\"", string_format))

    def highlightBlock(self, text):
        # Highlighting according to the rules
        for pattern, format in self.highlighting_rules:
            matches = re.finditer(pattern, text)
            for match in matches:
                start, end = match.span()
                self.setFormat(start, end - start, format)

        # Validating syntax using ANTLR parser
        self.validate_syntax(text)

    def validate_syntax(self, text):
        if not text:
            return
        try:
            input_stream = InputStream(text)
            parser = self.get_parser(input_stream)

            error_listener = SyntaxErrorListener(text)
            parser.removeErrorListeners()
            parser.addErrorListener(error_listener)

            parser.agent()
        except CustomSyntaxError as e:
            self.errors.append(str(e))
            self.setFormat(0, len(text), self.error_format)
        except Exception as e:
            pass

    @abstractmethod
    def get_parser(self, input_stream):
        ...
