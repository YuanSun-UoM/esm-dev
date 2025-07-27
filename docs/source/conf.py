# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'CESM-LCZ'
copyright = '2025, Yuan Sun'
author = 'Yuan Sun'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    #'recommonmark', # for markdown, similar to myst_parser
    'myst_parser',
    #'myst_nb', # for ipynb, check 'myst_nb' or 'myst-nb' as typo
    'sphinx.ext.napoleon',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.mathjax',
    #'sphinx_markdown_tables', # not 'sphinx-markdown-tables',
    'sphinx_design', # for grid layout
    #'nbsphinx', for ipynb
    #'nbconvert' # for ipynb
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'bizstyle'
html_static_path = ['_static']
