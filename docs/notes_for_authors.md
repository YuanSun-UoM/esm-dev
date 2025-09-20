# Notes for authors

## Setup

```bash
# conda install sphinx-book-theme recommonmark sphinx myst-nb
# pip install sphinx_design
conda activate testingenv
export GITHUB_DIR=/Users/user/Desktop/YuanSun-UoM/
export REPO_NAME=esm-dev
export GITROPO_DIR=${GITHUB_DIR}${REPO_NAME}/
export DOCS_DIR=${GITROPO_DIR}docs/
cd ${GITROPO_DIR}
mkdir docs
cd ${DOCS_DIR}
sphinx-quickstart

> Separate source and build directories (y/n) [n]: y
> Project name: esm-dev
> Author name(s): Yuan Sun
> Project release []:

sphinx-build -b html ${DOCS_DIR}source ${DOCS_DIR}
open ${DOCS_DIR}/index.html

touch docs/.nojekyll
```

## Update

```
conda activate testingenv
export GITHUB_DIR=/Users/user/Desktop/YuanSun-UoM/
export REPO_NAME=esm-dev
export GITROPO_DIR=${GITHUB_DIR}${REPO_NAME}/
export DOCS_DIR=${GITROPO_DIR}docs/
export LOCAL_DOCS=${DOCS_DIR}_build
cd ${DOCS_DIR}
sphinx-build -b html ${DOCS_DIR}source ${LOCAL_DOCS}
open ${LOCAL_DOCS}/index.html
```

- Change the docs style in `conf.py`
- For GitHub, enable **Discussions** and add **issue templates** in **Settings**.
- For GitHub Page, set the source as `Deploy from a branch`, set the Branch as `main/docs/`
  - The HTML files should be directly in the `docs` rather than inner folder
  - `touch docs/.nojekyll` because GitHub Pages uses Jekyll by default, which **ignores _static/** folders unless you disable it.

- Visitor map: https://clustrmaps.com/

  - In `docs/source/index.rst`, add:

    ```
    .. raw:: html
    
        <a href="https://clustrmaps.com/site/1c7o9" title="ClustrMaps">
            <img src="https://www.clustrmaps.com/map_v2.png?d=DU7e_v-cQ_KGxrS5rEOq8I6QI6Um3BnrHeQaFh2q6Do&cl=ffffff">
        </a>
    ```

    