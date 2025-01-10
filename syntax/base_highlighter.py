import re

from PyQt6.QtGui import QSyntaxHighlighter, QTextCharFormat, QColor, QFont

class BaseSyntaxHighlighter(QSyntaxHighlighter):
    def __init__(self, document):
        super().__init__(document)
        self.highlighting_rules = []

    def add_highlighting_rule(self, pattern, color, bold=False, italic=False):
        """Adds a highlighting rule with the specified formatting."""
        format = QTextCharFormat()
        format.setForeground(QColor(color))
        if bold:
            format.setFontWeight(QFont.Weight.Bold)
        if italic:
            format.setFontItalic(True)
        self.highlighting_rules.append((re.compile(pattern), format))

    def highlightBlock(self, text):
        """Applies syntax highlighting rules."""
        for pattern, format in self.highlighting_rules:
            for match in re.finditer(pattern, text):
                start, end = match.span()
                self.setFormat(start, end - start, format)
        self.setCurrentBlockState(0)
