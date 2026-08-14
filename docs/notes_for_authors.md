# Notes for authors

## Setup (archived for UoM MacBook)

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



## Update script in new MacBook

- I need to use `sphinx-build` instead of GitHub Actions for building the webpage.

```bash
export GITHUB_DIR=/Users/a16404ys/Desktop/YuanSun-UoM/
export REPO_NAME=esm-dev
cd ${GITHUB_DIR}{REPO_NAME}/
./build.sh
```



```bash
#conda activate testingenv
source /Users/a16404ys/myenv/bin/activate
export GITHUB_DIR=/Users/a16404ys/Desktop/YuanSun-UoM/
export REPO_NAME=esm-dev
export GITROPO_DIR=${GITHUB_DIR}${REPO_NAME}/
export DOCS_DIR=${GITROPO_DIR}docs/
cd ${DOCS_DIR}
cp ${DOCS_DIR}source/${LATEX_DIR}/latex_source/paper.html ${DOCS_DIR}notebooks/technotes/CLMU/
cp -R ${DOCS_DIR}source/${LATEX_DIR}/latex_source/Figure* ${DOCS_DIR}notebooks/technotes/CLMU/
sphinx-build -b html ${DOCS_DIR}source ${DOCS_DIR} > build.log 2>&1
open ${DOCS_DIR}/index.html

# update CLMU html
export LATEX_DIR=notebooks/technotes/CLMU/
# modify graphic path
cd ${DOCS_DIR}source/${LATEX_DIR}/latex_source
pandoc main.tex \
  --bibliography=refs_journal.bib \
  --bibliography=refs_dataset.bib \
  --bibliography=refs_report.bib \
  --bibliography=refs_book.bib \
  --citeproc \
  -f latex \
  -t html5 \
  -s --number-sections --mathjax --metadata link-citations=true \
  -o paper.html --csl=apa-numeric-superscript-brackets.csl    

# pandoc generate html files: paper.html
# modify the generated paper.html to put the reference 
# 修改body并添加container
# 在正文开始的<body>后添加
<div class="paper-container">
<main class="main-text">

# 在参考文献<div id="refs" class="references csl-bib-body" data-entry-spacing="0"前添加
</main>
<aside class="references-panel">

# 结尾应为（添加</aside>后）
</div>
</aside>
</div>
</body>
</html>

# citation style language (csl) is downloaded from: https://github.com/citation-style-language
```

```html
    body {
      margin: 0;
      padding: 0;
      height: 100%;
      overflow: hidden;
    }
    body {
      max-width: none;
    }
    .paper-container {
      display: flex;
      width: 100%;
      height: 100vh;
    }
    .main-text {
      width: 70%;
      height: 100vh;
      overflow-y: auto;
      box-sizing: border-box;
      padding: 50px;
      hyphens: auto;
      overflow-wrap: break-word;
      text-rendering: optimizeLegibility;
      font-kerning: normal;
    }
    .references-panel {
      width: 30%;
      height: 100vh;
      overflow-y: auto;
      box-sizing: border-box;
      padding: 30px;
      border-left: 1px solid #ccc;
      background-color: #f7f7f7;
      font-size: 0.85em;   /* 85% of the main text */
    }
```



- Change the docs' style in `conf.py`

- 如果要重新编译

  ```bash
  make clean
  make html
  ```

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


  - In `docs/source/conf.py`, add:

    ```
    html_sidebars["index"] = [
        "searchbox.html",
        "clustrmaps.html",
        "github_star.html"
    ]
    ```

    



- Vistor map2: 


  - In `docs/source/index.rst`, add:

    ```
    <!-- mapmyvisitors.html -->
    <div style="margin-top:20px; text-align:center;">
    
      <script
          id="mapmyvisitors"
          src="https://statable.com/js/T33127Cb0a/t/mw.js"
          data-id="3251235"
          data-period="90d"
          data-display-mode="cities"
          data-show-stats="false"
          data-ocean-color="#FFFFFF00">
      </script>
    
    </div>
    ```

- `Back to Top` bottom:

  - in `docs/_static/`, 添加`back_to_top.js`和`custom.css`这两个文件

    - `custom.css`可以设置一些对于模板的修改

  - 修改`conf.py`文件，添加：

    ```python
    #html_static_path = ['_static']
    html_css_files = ['custom.css']
    html_js_files = ['back_to_top.js']
    ```

- (Last updated: date)

  - in `docs/_static/`, 添加`last_updated.js`

  - 修改`conf.py`文件，添加：

    ```python
    html_js_files = ['back_to_top.js', 'last_updated.js']
    ```

- Add an HTML file

  - Put the html file into the docs/notebooks/technotes/CLMU/paper.html
  - In the source folder, add an index.rst file

## Manage esm-dev_code repository

- 代码修改在default或者已知的branch上进行，在github中选择一个branch之后，`New Branch`
- The `main` branch only merges the default code from the official CTSM repository