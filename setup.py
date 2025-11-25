from setuptools import setup, Extension
from Cython.Build import cythonize
import os
import glob

SRC_DIR = "src"

cpp_sources = glob.glob(os.path.join(SRC_DIR, "*.cc"))
cpp_sources = [f for f in cpp_sources if "qbmain.cc" not in f]

sources = ["pyqb/core.pyx", "pyqb/qb_wrapper.cpp"] + cpp_sources

extensions = [
    Extension(
        "pyqb.core",
        sources=sources,
        include_dirs=[SRC_DIR],
        language="c++",
        extra_compile_args=["-D_FILE_OFFSET_BITS=64", "-D_LARGEFILE_SOURCE", "-fpermissive", "-std=c++11"],
        libraries=["pthread"] if os.name != "nt" else [],
    )
]

setup(
    name="pyqb",
    version="0.1",
    description="Python bindings for qb compression utility",
    packages=["pyqb"],
    ext_modules=cythonize(extensions, compiler_directives={'language_level': "3"}),
    entry_points={
        "console_scripts": [
            "pyqb=pyqb.cli:main",
        ],
    },
)
