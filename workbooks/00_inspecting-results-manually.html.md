---
title: "Inspecting Automatic Indexing Results Manually"
format: html
author: "Maximilian Kähler, DNB"
toc: true
keep-md: true
editor: visual
---

In this preparation workbook we will start with looking at the data formats
that CASIMiR expects for computing retrieval metrics. Then, we will create a
manual comparison table that allows us to inspect automatic subject suggestions
in detail. This is very useful to get a first qualitative impression of the 
strengths and weaknesses of different automatic indexing methods.


::: {.cell}

:::


## Looking at Data-Formats

Let's start this tutorial by looking at the basic data formats and data sets.
The subfolder `data` contains the following dataset:

::: {.cell}

```{.bash .cell-code}
tree ../data

```
:::


```bash
../data
├── gnd_entitytypes.csv
├── gnd_pref-labels_w-translation.csv
├── README.md
├── subject-groups-labels.csv
├── test-set_doc-ids-and-titles_w-translation.csv
├── test-set_gold-standard.csv
├── test-set_predictions
│   ├── method-A.csv
│   ├── method-B.csv
│   ├── method-C.csv
│   ├── method-D.csv
│   ├── method-E.csv
│   └── method-F.csv
└── test-set_subject-group-mapping.csv
```

Take a look at the file `data/REAMDE.md` for a description of all datasets
provided. Here we will only introduce the most important ones for getting
started.

### Document Titles

This tutorial is based on a test set of document titles provided by the German
National Library (DNB). The document titles are stored in the file
`data/test-set_doc-ids-and-titles_w-translation.csv`. English translations are
AI-generated and provided for convenience. Please consider these translations
with care.


::: {.cell}

```{.r .cell-code}
doc_titles <- read_csv(
  "../data/test-set_doc-ids-and-titles_w-translation.csv"
)

num_docs <- nrow(doc_titles)

kable(
  head(doc_titles),
  caption = "Document IDs and Titles in the Test Set"
)
```

::: {.cell-output-display}


Table: Document IDs and Titles in the Test Set

|doc_id     |doc_title_ger                                                                                                                |doc_title_eng                                                                                                           |
|:----------|:----------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------|
|1122545479 |Prädiktive Fahrermodelle zur Simulation und Teilautomatisierung eines Hydraulikbaggers                                       |Predictive driver models for simulating and partial automation of a hydraulic excavator                                 |
|1122561075 |Die Landesministerkonferenzen und der Bund kooperativer Föderalismus im Schatten der Politikverflechtung                     |The federal and state ministers' conferences and the cooperative federalism in the shadow of political interdependence. |
|1122562640 |Die Geburt der Philosophie im Garten der Lüste Michel Foucaults Archäologie des platonischen Eros                            |The Birth of Philosophy in the Garden of Pleasure: Michel Foucault's Archeology of Platonic Eros                        |
|1122587236 |Das Geldwäscherisiko verschiedener Glücksspielarten                                                                          |The money laundering risk of various gambling types                                                                     |
|1122592507 |Entwicklung von großvolumigen CdTe- und (Cd,Zn)Te-Detektorsystemen                                                           |Development of high-volume CdTe and (Cd,Zn)Te detector systems                                                          |
|1122593996 |Integrierte bioinformatische Methoden zur reproduzierbaren und transparenten Hochdurchsatz-Analyse von Life Science Big Data |Integrated bioinformatics methods for reproducible and transparent high-throughput analysis of life science big data    |


:::
:::


The dataset contains 8415 document titles, their doc_id and translations.
Each `doc_id` can be resolved to the official public record by prefixing the
base-url `https://d-nb.info/`, e.g. `doc_id = 1122545479` can be resolved to
<https://d-nb.info/1122545479>. Here you can access more metadata about the 
document.

### Gold Standard Data

Each of the document titles was manually annotated by subject experts of the DNB
with subject terms from the Inegrated Authority File (GND). Similar to the 
document identifiers, each GND subject term has a unique identifier, the 
`label_id`, which can be resolved to the official GND record by prefixing the base-url
`https://d-nb.info/`, e.g. `label_id = 041321634` can be resolved to
<https://d-nb.info/041321634>.

For more information on the GND please visit
[the official GND website](https://gnd.network/en/).
In particular, you can find information on each subject term by visiting
the [GND explorer](https://explore.gnd.network/en/), where you can search for
each `label_id`. 


::: {.cell}

```{.r .cell-code}
gold_standard <- read_csv("../data/test-set_gold-standard.csv",
                          col_select = c("doc_id", "label_id"))

# load label_text
gnd_pref_labels <- read_csv("../data/gnd_pref-labels_w-translation.csv")
gold_standard_w_labels <- gold_standard |> 
  left_join(gnd_pref_labels, by = "label_id")

head(gold_standard_w_labels)
```

::: {.cell-output .cell-output-stdout}

```
# A tibble: 6 × 4
  doc_id     label_id  label_text_ger      label_text_eng     
  <chr>      <chr>     <chr>               <chr>              
1 1122545479 041321634 Fahrzeugverhalten   Vehicle behavior   
2 1122545479 041321650 Fahrerverhalten     Driver behavior    
3 1122545479 041608607 Hydraulikbagger     Hydraulic excavator
4 1122545479 042388120 Mechatronik         Mechatronics       
5 1122545479 042718368 Prädiktive Regelung Predictive Control 
6 1122545479 043049168 Systemmodell        System model       
```


:::
:::


For the rest of this tutorial This is our gold standard data that we compare
against.

### Predictions

The subfolder `data/test-set_predictions` contains machine based GND subject suggestions coming from different methods.


::: {.cell}

```{.bash .cell-code}
ls ../data/test-set_predictions
```


::: {.cell-output .cell-output-stdout}

```
method-A.csv
method-B.csv
method-C.csv
method-D.csv
method-E.csv
method-F.csv
```


:::
:::


These datasets all follow the same long table format with columns `doc_id`, 
`label_id` and `score`. Every row expresses a subject assignment of some
document with a label under a confidence score computed by the respective
indexing algorithm. The origin of each prediction file is purposefully not
disclosed here, to avoid any bias when inspecting the results.


::: {.cell}

```{.r .cell-code}
files <- list(
  "method-A" = "../data/test-set_predictions/method-A.csv",
  "method-B" = "../data/test-set_predictions/method-B.csv",
  "method-C" = "../data/test-set_predictions/method-C.csv",
  "method-D" = "../data/test-set_predictions/method-D.csv",
  "method-E" = "../data/test-set_predictions/method-E.csv",
  "method-F" = "../data/test-set_predictions/method-F.csv"
)
predictions <- files |> 
  map(read_csv) 
head(predictions[["method-A"]])
```

::: {.cell-output .cell-output-stdout}

```
# A tibble: 6 × 3
  doc_id     label_id    score
  <chr>      <chr>       <dbl>
1 1122825404 043071929 0.182  
2 1122825404 042124832 0.139  
3 1122825404 970264100 0.0519 
4 1123182132 043090133 0.387  
5 1123118701 041290437 0.00257
6 1123384193 041778928 0.195  
```


:::
:::


Gold standard and predictions are the basic input for computing any retrieval
scores.

## Creating a manual comparison table

Before we talk about metrics, let's look at how we can beautifully join all of
the above tables and get a first informative impression of the various 
subject suggestions originating from different automatic indexing methods.

CASIMiR offers a basic method to construct a comparison table:


::: {.cell}

```{.r .cell-code}
comp <- create_comparison(
  predicted = predictions[["method-A"]],
  gold_standard = gold_standard
)
```

::: {.cell-output .cell-output-stderr}

```
Warning in create_comparison(predicted = predictions[["method-A"]],
gold_standard = gold_standard): gold standard data contains documents that are
not in predicted set
```


:::

```{.r .cell-code}
kable(filter(comp, doc_id == "1122545479"))
```

::: {.cell-output-display}


|doc_id     |label_id  |gold  |     score|suggested | relevance|
|:----------|:---------|:-----|---------:|:---------|---------:|
|1122545479 |041321634 |TRUE  |        NA|FALSE     |         0|
|1122545479 |041321650 |TRUE  |        NA|FALSE     |         0|
|1122545479 |041608607 |TRUE  | 0.3171981|TRUE      |         0|
|1122545479 |042388120 |TRUE  |        NA|FALSE     |         0|
|1122545479 |042718368 |TRUE  |        NA|FALSE     |         0|
|1122545479 |043049168 |TRUE  |        NA|FALSE     |         0|
|1122545479 |040550729 |FALSE | 0.7565188|TRUE      |         0|


:::
:::


Note, CASIMiR informs you that apparently not all documents were indexed by 
"method-A". When working with larger data, that is quite common: There are 
always edge cases with document titles that lead to empty results. Silence, 
not SPAM, may also be a feature for an indexing method...

Provided you don't know DNB's label and document ids by heart, you may need 
more context in form of text descriptions. Below code wraps up a lot of data
wrangling to bring the tables into an instructive format:


::: {.cell}

```{.r .cell-code}
set.seed(42)
sample_docs <- sample_n(doc_titles, size = 5)

# modify `_eng` to `_ger` to see german original texts
qual_table <- create_qualitative_table(
  predicted = predictions,
  gold_standard = gold_standard,
  doc_id_list = select(sample_docs, doc_id),
  gnd = select(gnd_pref_labels, label_id, label_text = label_text_eng),
  title_texts = select(doc_titles, doc_id, title = doc_title_eng),
  limit = 5 # how many suggestions per method to consider?
)

qual_table
```

::: {.cell-output-display}

```{=html}
<div id="zrociydeme" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#zrociydeme table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#zrociydeme thead, #zrociydeme tbody, #zrociydeme tfoot, #zrociydeme tr, #zrociydeme td, #zrociydeme th {
  border-style: none;
}

#zrociydeme p {
  margin: 0;
  padding: 0;
}

#zrociydeme .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#zrociydeme .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#zrociydeme .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#zrociydeme .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#zrociydeme .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#zrociydeme .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zrociydeme .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#zrociydeme .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#zrociydeme .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#zrociydeme .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#zrociydeme .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#zrociydeme .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#zrociydeme .gt_spanner_row {
  border-bottom-style: hidden;
}

#zrociydeme .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#zrociydeme .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#zrociydeme .gt_from_md > :first-child {
  margin-top: 0;
}

#zrociydeme .gt_from_md > :last-child {
  margin-bottom: 0;
}

#zrociydeme .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#zrociydeme .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#zrociydeme .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#zrociydeme .gt_row_group_first td {
  border-top-width: 2px;
}

#zrociydeme .gt_row_group_first th {
  border-top-width: 2px;
}

#zrociydeme .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrociydeme .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#zrociydeme .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#zrociydeme .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zrociydeme .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrociydeme .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#zrociydeme .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#zrociydeme .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#zrociydeme .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#zrociydeme .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#zrociydeme .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrociydeme .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#zrociydeme .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#zrociydeme .gt_left {
  text-align: left;
}

#zrociydeme .gt_center {
  text-align: center;
}

#zrociydeme .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#zrociydeme .gt_font_normal {
  font-weight: normal;
}

#zrociydeme .gt_font_bold {
  font-weight: bold;
}

#zrociydeme .gt_font_italic {
  font-style: italic;
}

#zrociydeme .gt_super {
  font-size: 65%;
}

#zrociydeme .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#zrociydeme .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#zrociydeme .gt_indent_1 {
  text-indent: 5px;
}

#zrociydeme .gt_indent_2 {
  text-indent: 10px;
}

#zrociydeme .gt_indent_3 {
  text-indent: 15px;
}

#zrociydeme .gt_indent_4 {
  text-indent: 20px;
}

#zrociydeme .gt_indent_5 {
  text-indent: 25px;
}

#zrociydeme .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#zrociydeme div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_heading">
      <td colspan="9" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Qualitative Method Comparison</td>
    </tr>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label_id">label_id</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="label_text">label_text</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="gold">gold</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="score_method-A">score_method-A</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="score_method-B">score_method-B</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="score_method-C">score_method-C</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="score_method-D">score_method-D</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="score_method-E">score_method-E</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="score_method-F">score_method-F</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <th colspan="9" class="gt_group_heading" scope="colgroup" id="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban&#10;Design">1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040329038</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Creativity</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">0.07579290</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">0.20905685</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">0.145</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">0.02877</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040621103</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Urbanity</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">TRUE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right" style="background-color: #00FF00;">0.31719807</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right" style="background-color: #00FF00;">0.30762604</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.07800756</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.355</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right" style="background-color: #00FF00;">0.05075</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040057283</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Berlin</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">TRUE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right" style="background-color: #00FF00;">0.36113155</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.07056365</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right" style="background-color: #00FF00;">0.43647248</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.121</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">041143337</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Art</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">0.49477395</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">0.22454967</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">0.05172485</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">0.150</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040778045</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Urban Design</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">TRUE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right" style="background-color: #00FF00;">0.54210848</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right" style="background-color: #00FF00;">0.22112384</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.05332217</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right" style="background-color: #00FF00;">0.40142271</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.219</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right" style="background-color: #00FF00;">0.09810</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040334228</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Arts</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">TRUE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040567338</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Urban Geography</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">TRUE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">04268059X</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Culture economy</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">TRUE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040567540</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Urban Planning</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">0.29041576</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040567303</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Urban development</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">0.04738772</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">0.03008</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">041911253</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Future expectation</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">0.10301682</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">041328779</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Future Planning</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">0.28373721</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">040680975</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Future</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">0.49127367</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_id" class="gt_row gt_left">100152912X</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  label_text" class="gt_row gt_left">Dortmunder U</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  gold" class="gt_row gt_center">FALSE</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban
Design  score_method-F" class="gt_row gt_right">0.03429</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="9" class="gt_group_heading" scope="colgroup" id="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!">1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">041394046</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Goods</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">0.05739328</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040663809</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Reality</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">0.10689719</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040013073</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Daily life</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">TRUE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040118827</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Germany</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">TRUE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right" style="background-color: #00FF00;">0.26746377</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.10488939</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.082</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040118894</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Germany (Federal Republic)</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">0.05507484</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">041900812</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Economic Miracle</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">0.05519071</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040205177</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">History</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">0.06399128</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">948411694</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Post-war period</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">0.35231987</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040288145</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Jewish persecution</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">0.04704222</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040432718</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Austria</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">0.04716158</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">041227824</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Everyday Culture</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">0.04806859</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">0.035</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">042071860</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Groß-Lüder</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">0.04973334</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">0.073</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">041360559</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">American Civil War (1861-1865)</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">0.02764216</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040087840</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Civil war</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">0.03618289</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">043163815</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Past</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">0.12463379</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">043261310</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Good Times - Bad Times</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">0.12642516</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">04061672X</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Commemoration of the past</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">0.30247298</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040468402</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Portrait photography</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">0.029</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">040436659</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Optimism</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">0.031</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">943399718</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Ica</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">0.02581</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">041728335</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Original (Person)
Translation: Original (Person)</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">0.02587</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">041818555</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Care</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">0.03308</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">960318526</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Gelsenkirchen-Resse</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">0.03875</td></tr>
    <tr><td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_id" class="gt_row gt_left">041172353</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  label_text" class="gt_row gt_left">Cake</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  gold" class="gt_row gt_center">FALSE</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1149279583 - Was ist besser? 1945-1965: Wie es wirklich war!  score_method-F" class="gt_row gt_right">0.04195</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="9" class="gt_group_heading" scope="colgroup" id="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful&#10;Implementation">1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">950251194</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Transformation</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">0.05997121</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">041316657</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Claim</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">0.31719807</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">0.18597430</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">04126892X</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">School development</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">TRUE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.11813986</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right" style="background-color: #00FF00;">0.47994795</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.858</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right" style="background-color: #00FF00;">0.32337</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">041351487</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Organizing the Class</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">TRUE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">1000723437</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Inclusive School</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">TRUE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right" style="background-color: #00FF00;">0.29270390</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.04837416</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right" style="background-color: #00FF00;">0.72401166</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.066</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right" style="background-color: #00FF00;">0.02940</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">965002845</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Inclusion (Sociology)</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">TRUE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right" style="background-color: #00FF00;">0.19996907</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.06500251</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.148</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right" style="background-color: #00FF00;">0.03568</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">041276612</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">School development planning</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">0.12761976</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">04053474X</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">School</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">0.13852690</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">100072185X</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Inclusive Pedagogy</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">0.16562288</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">0.04911679</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">0.69988042</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">0.041</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">0.02241</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">041351754</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Educational research</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">0.04595719</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">123322929X</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Inclusive teaching</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">0.30149797</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">040118827</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Germany</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">0.099</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_id" class="gt_row gt_left">041156137</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  label_text" class="gt_row gt_left">Practical relevance</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  gold" class="gt_row gt_center">FALSE</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful
Implementation  score_method-F" class="gt_row gt_right">0.02410</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="9" class="gt_group_heading" scope="colgroup" id="1220297135 - The Enchantment of the World A Cultural History of Christianity">1220297135 - The Enchantment of the World A Cultural History of Christianity</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">96355123X</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Enchantment</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">0.31719807</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">0.05300185</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">04010074X</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Christianity</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">TRUE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right" style="background-color: #00FF00;">0.56590599</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right" style="background-color: #00FF00;">0.60737634</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.05565031</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.255</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right" style="background-color: #00FF00;">0.03819</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">041256980</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Culture</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">TRUE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.05168247</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.054</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right" style="background-color: #00FF00;">0.03080</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040493962</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Religion</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">0.07313728</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040307204</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Church History</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">0.08597670</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040205177</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">History</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">0.08827944</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040349292</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Lifeworld</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">0.04947460</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">0.06769</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040653528</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Worldview</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">0.04968721</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">0.059</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">0.06414</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040277437</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Islam</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">0.05197397</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">0.091</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">04010110X</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Christian Literature</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">0.02210998</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">042261309</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Cultural history writing</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">0.07228480</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040205266</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Historical Consciousness</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">0.11119287</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">041256719</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">History of Culture (Field of Study)</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">0.20801027</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040013286</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Alps</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">0.039</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_id" class="gt_row gt_left">040359646</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  label_text" class="gt_row gt_left">Literature</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  gold" class="gt_row gt_center">FALSE</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1220297135 - The Enchantment of the World A Cultural History of Christianity  score_method-F" class="gt_row gt_right">0.02765</td></tr>
    <tr class="gt_group_heading_row">
      <th colspan="9" class="gt_group_heading" scope="colgroup" id="1255811684 - Media habitus and biographical legendWriterly performance practices in the age&#10;of digitalization">1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization</th>
    </tr>
    <tr class="gt_row_group_first"><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">042030196</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Age</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">0.07579290</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">040227243</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Habitus</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">0.31719807</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">0.05817489</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">0.15841071</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">0.351</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">0.06861</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">041230655</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Digitalization</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">0.31719807</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">0.37469912</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">0.64681196</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">0.322</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">0.06866</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">040350282</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Legend</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">0.31719807</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">0.14183481</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">041223497</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Self-presentation</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">TRUE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">041305450</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Authorship</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">TRUE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right" style="background-color: #00FF00;">0.08664088</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right" style="background-color: #00FF00;">0.05726333</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right" style="background-color: #FF0000;">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right" style="background-color: #00FF00;">0.122</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right" style="background-color: #FF0000;">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">040359646</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Literature</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">0.12004970</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">0.06323440</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">0.109</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">040272230</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Performance</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">0.28547052</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">040533093</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Writer</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">0.30383539</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">041383966</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Self-reference</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">0.05596432</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">0.04118</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">041132920</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">German</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">0.06490613</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">1038714850</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Digital Humanities</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">0.13120206</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">041969103</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">New Media</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">0.29255560</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">0.112</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">NA</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">040740986</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">A student teacher</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">0.04461</td></tr>
    <tr><td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_id" class="gt_row gt_left">964162512</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  label_text" class="gt_row gt_left">Media Competence</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  gold" class="gt_row gt_center">FALSE</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-A" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-B" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-C" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-D" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-E" class="gt_row gt_right">NA</td>
<td headers="1255811684 - Media habitus and biographical legendWriterly performance practices in the age
of digitalization  score_method-F" class="gt_row gt_right">0.06389</td></tr>
  </tbody>
  
</table>
</div>
```

:::
:::


## Your Turn:

Inspect the above table:

-   what subject suggestions do you agree with?

-   are there false positives that would be okay, even if not contained in the gold standard?

-   Which methods do you prefer?
