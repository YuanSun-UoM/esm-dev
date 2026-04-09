# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'esm-dev'
copyright = '2026, Yuan Sun'
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
    #'nbconvert' # for ipynb,
    #'sphinx_last_updated_by_git'
]
templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']
html_sidebars = {
    "**": ["localtoc.html", "relations.html", "sourcelink.html", "searchbox.html"]
}
html_sidebars["index"] = [
    "searchbox.html",
    "clustrmaps.html",
    "github_star.html"
]

html_last_updated_fmt = "%d %B %Y"

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'bizstyle'
html_static_path = ['_static']
html_css_files = ['custom.css']
html_js_files = ['back_to_top.js', 'last_updated.js']