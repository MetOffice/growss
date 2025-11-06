Build Sphinx documentation workflow

This reusable workflow enables developers to build and upload Sphinx-generated documentation
from a local repository to GitHub Pages.

## Usage

To use this workflow developers must have a `requirements.txt` file in the top level
of their project repository to outline the sphinx dependencies that will be used by
the `build-sphinx-docs` workflow. An example of a `requirements.txt` file which could
run this workflow would be as follows:

### Example requirements

```text
    sphinx==8.2.3
    pydata-sphinx-theme==0.16.1
    sphinx-design==0.6.1
    sphinx-copybutton==0.5.2
    sphinx-lint==1.0.0
    sphinx-sitemap==2.8.0
    sphinxcontrib-svg2pdfconverter==1.3.0
```

In this example file both the package name and version numbers of these packages have
been specified. This workflow would still run if only the package names were
specified and would by default install the most recent version of each package. Although,
it is advised that version numbers are used in the `requirements.txt` file to ensure consistency
across builds and to avoid automatic updates to packages breaking the workflow due to versions of diffrent
packages being incompatible with each other. 

### Build Sphinx Documentation

```yaml
steps:
  - name: Build Sphinx Documentation
    uses: MetOffice/growss/.github/workflows/build-sphinx-docs.yaml@main
    # Optional
    with:
      docs-directory: Directory containing the documentation source
      requirements: Path to the requirements file to install dependencies from
      sphinx-opts: Additional options to pass to the Sphinx build command
      build-directory: Directory to output the html documentation to
```

### Example deployment workflow
```yaml

name: Deploy Sphinx Docs

on:
  workflow_call:

jobs:

  deploy-sphinx-docs:

     name: deploy sphinx docs to github pages
     # Defines the deployment target as GitHub Pages
     environment:
       name: github-pages

     permissions:
        pages: write
        id-token: write

     runs-on: ubuntu-24.04
     needs: build-sphinx-html
     steps:
        # Configuration and deployment to GitHub Pages
        - name: Configure GitHub Pages
          id: Configure
          uses: actions/configure-pages@v4

        - name: Deploy to GitHub Pages
          id: Deploy
          uses: actions/deploy-pages@v4

```
