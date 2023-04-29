import pathlib

EXAMPLES_PATH = pathlib.Path(__file__).parent.parent.resolve() / 'examples'


def get_example_file_path(example_name: str, file_extension: str) -> str:
    return (EXAMPLES_PATH / example_name / f'{example_name}.{file_extension}').as_posix()
