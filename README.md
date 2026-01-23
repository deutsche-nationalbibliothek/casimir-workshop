# Workshop on Evaluating Automated Subject Indexing Methods

This is the official repository hosting all meterial needed for the 
Workshop **Evaluating Automated Subject Indexing Methods** hosted at 
the Fantastic Futures-Conference 2025 on Dec 3rd at the British National Library in London
and at the German National Library in Frankfurt on Jan 28th, 2026.

## Update:

  * 2026-01-26: Add German slides for 2nd Workshop in Frankfurt
  * 2025-12-16: Post-workshop update: uploaded pdf-slides and fix non-interactive workbooks

# Requirements

## Installing R and RStudio

To work with this tutorial you will need a working R environment and an IDE
to run the provided quarto notebooks in. Here are three options to establish a
working environment:

### Option 1: Install R and RStudio from the official sources

You can install R following instructions under [https://cran.rstudio.com/](https://cran.rstudio.com/).

Afterwards you can install [RStudio Desktop](https://posit.co/download/rstudio-desktop/). 

This should provide instructions for all major OSs. 

Of course you can also choose to work with other IDEs. Positron, VS Code or RStudio Server are other frequently used IDEs to work with R. 
For VS Code you should install the [R extension](https://marketplace.visualstudio.com/items?itemName=REditorSupport.r) and [quarto extension](https://marketplace.visualstudio.com/items?itemName=quarto.quarto).

### Option 2: Run R and RStudio in a Docker Container

If you prefer an encapsulated environment, you can use one of the containers
provided by the [rocker project](https://rocker-project.org/images/).

The following command pulls and starts the container rocker/tidyverse
```
docker run --rm -ti -e DISABLE_AUTH=true -p 8787:8787 rocker/tidyverse
```
after which you can look up `localhost:8787` in your browser to access RStudio 
server.

The tidyverse container comes along with installation of many 
other useful R packages.

### Option 3: Install R and RStudio in Conda Environment

If you are familiar with the package manager [conda](https://docs.conda.io/en/latest/), this provides also an easy method to install a working R environment.
To install conda use the [miniforge installer](https://docs.conda.io/en/latest/#install-svg-version-1-1-width-1-0em-height-1-0em-class-sd-octicon-sd-octicon-download-sd-text-primary-viewbox-0-0-16-16-aria-hidden-true-path-d-m2-75-14a1-75-1-75-0-0-1-1-12-25v-2-5a-75-75-0-0-1-1-5-0v2-5c0-138-112-25-25-25h10-5a-25-25-0-0-0-25-25v-2-5a-75-75-0-0-1-1-5-0v2-5a1-75-1-75-0-0-1-13-25-14z-path-path-d-m7-25-7-689v2a-75-75-0-0-1-1-5-0v5-689l1-97-1-969a-749-749-0-1-1-1-06-1-06l-3-25-3-25a-749-749-0-0-1-1-06-0l4-22-6-78a-749-749-0-1-1-1-06-1-06l1-97-1-969z-path-svg).

To create a conda environment with all necessary tools use:
```bash
conda create --name my_env -c conda-forge r-tidyverse r-gt r-casimir quarto rstudio-desktop
conda activate my_env
```

If you prefer to work with another IDE, or want to have RStudio not installed by
conda, you may ommit `rstudio-desktop` from your environment specs.

## Install CASIMiR

If not already installed, to install the [CASMiR
package](https://github.com/deutsche-nationalbibliothek/casimir) featured in 
this workshop and all other required packages use the following command 
inside your R session:

```R
install.packages(c("tidyverse", "gt", "casimir"))
```

# Workshop plan

The workshop is organised in individual lessons, contained in the `workbooks`
directory. Each workbook will feature another method or point of view on 
looking at subject indexing results. To organize your learning process it is
suggested, that you draw up an empty table at the beginning of the workshop
featuring columns for "pro/ contra" and a row for each method/ algorithm. 
The reoccuring question to bear in mind across these lessons is:

**Which method would I choose, based on what I see in these evaluation results?**

The methods are referred to as `artful accordion`, `bold bassoon`, 
`charming cello`, `dreamy didgeredoo` and `embracing euphonium` in this tutorial 
and are purposefully not disclosed, to allow for unbiased evaluation. 
The true names and algorithms will be presented at the end of the workshop. 