# coding: utf-8
import os

from Cython.Build import cythonize
from setuptools import find_packages, setup

EXCLUDE_FILES = []


def get_ext_paths(root_dir: str, exclude_files: list[str]):
    """get filepaths for compilation"""
    paths = []

    for root, dirs, files in os.walk(root_dir):
        for filename in files:
            if os.path.splitext(filename)[1] != ".py":
                continue

            file_path = os.path.join(root, filename)
            if file_path in exclude_files:
                continue

            paths.append(file_path)
    return paths


setup(
    packages=find_packages(),
    ext_modules=cythonize(
        get_ext_paths("src", EXCLUDE_FILES),
        compiler_directives={"language_level": 3},
        build_dir="build",
    ),
)
