#!/bin/bash

export GITHUB_DIR=/Users/a16404ys/Desktop/YuanSun-UoM/
export REPO_NAME=esm-dev
export GITROPO_DIR=${GITHUB_DIR}${REPO_NAME}/
export DOCS_DIR=${GITROPO_DIR}docs/
export LATEX_DIR=notebooks/technotes/CLMU/

cd ${DOCS_DIR}source/${LATEX_DIR}/latex_source

# --------------------------------------------------
# 1. Generate Pandoc HTML
# --------------------------------------------------
pandoc main.tex \
  --bibliography=refs_journal.bib \
  --bibliography=refs_dataset.bib \
  --bibliography=refs_report.bib \
  --bibliography=refs_book.bib \
  --citeproc \
  -f latex \
  -t html5 \
  -s \
  --number-sections \
  --mathjax \
  --metadata link-citations=true \
  -o paper_raw.html \
  --csl=apa-numeric-superscript-brackets.csl

# ==================================================
# 2. INSERT CSS after <style>
# ==================================================
awk '
/@media \(max-width: 600px\)/ {
    print "html, body { margin:0; padding:0; height:100%; overflow:hidden; }";
    print "body { max-width:none; }";
    print ".container { display:grid; grid-template-columns:2fr 1fr; height:100vh; overflow:hidden; }";
    print ".paper, .references { overflow-y:auto; padding:20px; }";
    print "";
    print;
    next
}

{print}

' paper_raw.html > step1.html

# ==================================================
# 3. INSERT OPEN CONTAINER after <body>
# ==================================================
awk '
/<body[^>]*>/ {
    print;
    print "<div class=\"container\">";
    print "<div class=\"paper\">";
    next
}
{print}
' step1.html > step2.html

# ==================================================
# 4. INSERT REFERENCES SPLIT before References heading
# ==================================================
sed 's/<h1 class="unnumbered" id="references">/<\/div><div class="references"><h1 id="references">/' \
    step2.html > step3.html

# ==================================================
# 5. CLOSE CONTAINERS before </body>
# ==================================================
sed 's/<\/body>/<\/div><\/div><\/body>/' step3.html > paper.html

# ==================================================
# 6. COPY TO DOCS
# ==================================================
cp paper.html ${DOCS_DIR}${LATEX_DIR}/paper.html

# ==================================================
# 7. BUILD SPHINX
# ==================================================
cd ${DOCS_DIR}
sphinx-build -b html ${DOCS_DIR}source ${DOCS_DIR} > build.log 2>&1

open ${DOCS_DIR}/index.html
          