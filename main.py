import os
import pathlib

from PyQt6.QtGui import QFileSystemModel
from PyQt6.QtWidgets import QApplication, QMainWindow, QTextEdit, QMessageBox
from PyQt6.QtCore import QDir, Qt

from gui.design import Ui_MainWindow  # Import the generated UI

class MainWindow(QMainWindow, Ui_MainWindow):
    def __init__(self):
        super().__init__()
        self.setupUi(self)

        # Dictionary to track open files
        self.open_tabs = {}

        # File model to display the file system
        self.file_model = None

        # Initialize UI components
        self.initialize_tree_view()
        self.initialize_buttons()
        self.initialize_tabs()

    def initialize_tree_view(self):
        self.file_model = QFileSystemModel()
        self.file_model.setRootPath(QDir.rootPath())
        self.treeView.setModel(self.file_model)

        # Open the current working folder
        current_dir = os.getcwd()
        self.treeView.setRootIndex(self.file_model.index(QDir.rootPath()))
        self.treeView.setCurrentIndex(self.file_model.index(current_dir))

        # Set filters
        self.file_model.setNameFilters(["*.asl", "*.mas2j"])
        self.file_model.setNameFilterDisables(False)

        # Horizontal slider setting
        self.treeView.setHorizontalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAsNeeded)
        self.treeView.header().setMinimumSectionSize(self.treeView.geometry().width())
        self.treeView.header().setDefaultSectionSize(self.treeView.geometry().width() * 4)
        self.treeView.header().setStretchLastSection(False)

        # Hide unnecessary columns
        self.treeView.setColumnHidden(1, True)  # Hide the "Size" column
        self.treeView.setColumnHidden(2, True)  # Hide the "Type" column
        self.treeView.setColumnHidden(3, True)  # Hide the "Date Modified" column

    def initialize_buttons(self):
        # Connect signals
        self.runButton.clicked.connect(self.on_start)
        self.treeView.doubleClicked.connect(self.on_file_selected)

        # Setting the run button to inactive on startup
        self.runButton.setEnabled(False)

    def initialize_tabs(self):
        self.codeTab.clear()
        self.codeTab.setTabsClosable(True)
        self.codeTab.tabCloseRequested.connect(self.close_tab)

    # Signal handlers
    def on_start(self):
        print("Run button clicked")

    def on_file_selected(self, index):
        if self.file_model.isDir(index):
            return

        file_path = self.file_model.filePath(index)
        file_name = os.path.basename(file_path)

        if file_path in self.open_tabs:
            self.codeTab.setCurrentIndex(self.open_tabs[file_path])  # Switch to the open tab
            return

        # Open the file in a new tab
        text_edit = QTextEdit()
        try:
            text_edit.setText(pathlib.Path(file_path).read_text(encoding="utf-8"))
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Failed to open file:\n{file_path}\n\nError: {e}")
            return

        self.codeTab.addTab(text_edit, file_name)
        self.codeTab.setCurrentIndex(self.codeTab.count() - 1) # Switch to the new tab

        self.open_tabs[file_path] = self.codeTab.count() - 1

        # Connect to QTextEdit signal to track changes
        text_edit.textChanged.connect(lambda: self.mark_tab_as_dirty(file_path))

    def close_tab(self, index):
        # Remove the file path from open_tabs
        for file_path, tab_index in list(self.open_tabs.items()):
            if tab_index == index:
                del self.open_tabs[file_path]
                break

        # Adjust indices in open_tabs
        for file_path, tab_index in self.open_tabs.items():
            if tab_index > index:
                self.open_tabs[file_path] -= 1

        self.codeTab.removeTab(index)

    def mark_tab_as_dirty(self, file_path):
        """Marks a tab as dirty (modified)."""
        tab_index = self.open_tabs.get(file_path)
        if tab_index is not None:
            tab_text = self.codeTab.tabText(tab_index)
            if not tab_text.endswith("*"):
                self.codeTab.setTabText(tab_index, tab_text + " *")

if __name__ == "__main__":
    app = QApplication([])
    window = MainWindow()
    window.show()
    app.exec()
