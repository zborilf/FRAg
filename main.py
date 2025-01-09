import os

from PyQt6.QtGui import QFileSystemModel
from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6.QtCore import QDir, Qt

from gui.design import Ui_MainWindow  # Import the generated UI

class MainWindow(QMainWindow, Ui_MainWindow):
    def __init__(self):
        super().__init__()
        self.setupUi(self)

        # Initialize TreeView
        self.file_model = None
        self.initialize_tree_view()

        # Connect signals
        self.runButton.clicked.connect(self.on_start)
        self.treeView.doubleClicked.connect(self.on_file_selected)

        # Setting the run button to inactive on startup
        self.runButton.setEnabled(False)

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

    # Signal handlers
    def on_start(self):
        print("Run button clicked")

    def on_file_selected(self, index):
        file_path = self.file_model.filePath(index)
        print(f"Selected file: {file_path}")

if __name__ == "__main__":
    app = QApplication([])
    window = MainWindow()
    window.show()
    app.exec()
