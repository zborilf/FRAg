from syntax.base_highlighter import BaseSyntaxHighlighter

class ASLSyntaxHighlighter(BaseSyntaxHighlighter):
    def __init__(self, document):
        super().__init__(document)

        # Keywords
        keywords = ["action", "goal"]
        for keyword in keywords:
            self.add_highlighting_rule(rf"\b{keyword}\b", "blue", bold=True)

        # Comments
        self.add_highlighting_rule(r"//[^\n]*", "green", italic=True)

        # Strings
        self.add_highlighting_rule(r"\".*?\"", "magenta")
