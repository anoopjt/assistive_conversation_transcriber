# Always prefer setuptools over distutils
from setuptools import setup, find_packages
from os import path

here = path.abspath(path.dirname(__file__))

with open('requirements.txt') as f:
  install_requires = f.read().strip().split('\n')

# Get the long description from the README file
with open(path.join(here, 'README.md'), encoding='utf-8') as f:
  long_description = f.read()
setup(
    name='act_backend',
    version='0.0.1',
    description='Python backend for assistive conversation transcriber',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/faztp12/assistive_conversation_transcriber',
    author='Affluents',
    author_email='faztp12@gmail.com',
    python_requires='>=3.6',
    install_requires=install_requires,
    entry_points={  # Optional
        'console_scripts': [
            'act_backend=act_backend.cli:cli',
        ],
    },
)
