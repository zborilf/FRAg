from syntax.base_highlighter import BaseSyntaxHighlighter

class MAS2JSyntaxHighlighter(BaseSyntaxHighlighter):
    def __init__(self, document):
        super().__init__(document)

        # Keywords
        keywords = ["agents", "environment", "class", "parameters"]
        for keyword in keywords:
            self.add_highlighting_rule(rf"\b{keyword}\b", "blue", bold=True)

        # Comments
        self.add_highlighting_rule(r"#.*", "green", italic=True)

        # Strings
        self.add_highlighting_rule(r"\".*?\"", "magenta")
