# Cython Obfuscation Example
An example project to use Cython for obfuscation

# How to use?

First install all dependencies.

```bash
pdm install
```

Then run

```bash
pdm run python setup.py build
```

This will compile all `.py` files into `.so` files. The outputs are in `build/lib.linux-x86_64-cpython-311` in case of Python 3.11 in 64bit Linux.

You can include this output directory to your `PYTHONPATH` or simply replace all files in `src` to the compiles ones. Not that root `__init__.py` is required for PDM to correctly recognize a project. You must keep this file.


# Build Docker Image

Please check the `Dockerfile` for how to use multi-stage build with PDM.