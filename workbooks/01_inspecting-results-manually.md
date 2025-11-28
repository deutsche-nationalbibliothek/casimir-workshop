# Workbook 1:Inspecting Automatic Indexing Results Manually
Maximilian Kähler, DNB

- [Looking at Data-Formats](#looking-at-data-formats)
  - [Document Titles](#document-titles)
  - [Gold Standard Data](#gold-standard-data)
  - [Predictions](#predictions)
- [Creating a manual comparison
  table](#creating-a-manual-comparison-table)
- [Your Turn:](#your-turn)

In this preparation workbook we will start with looking at the data
formats that CASIMiR expects for computing retrieval metrics. Then, we
will create a manual comparison table that allows us to inspect
automatic subject suggestions in detail. This is very useful to get a
first qualitative impression of the strengths and weaknesses of
different automatic indexing methods.

## Looking at Data-Formats

Let’s start this tutorial by looking at the basic data formats and data
sets. The subfolder `data` contains the following datasets:

``` bash
tree ../data
```

``` bash
├── gnd_entitytypes.csv
├── gnd_pref-labels_w-translation.csv
├── README.md
├── subject-groups-labels.csv
├── test-set_doc-ids-and-titles_w-translation.csv
├── test-set_gold-standard.csv
├── test-set_predictions
│   ├── artful-accordion.csv
│   ├── bold-bassoon.csv
│   ├── charming-cello.csv
│   ├── dreamy-didgeridoo.csv
│   └── embracing-euphonium.csv
├── test-set_subject-group-mapping.csv
└── training-frequency-distribution.csv
```

Take a look at the file `data/REAMDE.md` for a description of all
datasets provided. Here we will only introduce the most important ones
for getting started.

### Document Titles

This tutorial is based on a test set of document titles provided by the
German National Library (DNB). The document titles are stored in the
file `data/test-set_doc-ids-and-titles_w-translation.csv`. English
translations are AI-generated and provided for convenience. Please
consider these translations with care.

``` r
doc_titles <- read_csv(
  "../data/test-set_doc-ids-and-titles_w-translation.csv"
)

num_docs <- nrow(doc_titles)

kable(
  head(doc_titles),
  caption = "Document IDs and Titles in the Test Set"
)
```

| doc_id | doc_title_ger | doc_title_eng |
|:---|:---|:---|
| 1122545479 | Prädiktive Fahrermodelle zur Simulation und Teilautomatisierung eines Hydraulikbaggers | Predictive driver models for simulating and partial automation of a hydraulic excavator |
| 1122561075 | Die Landesministerkonferenzen und der Bund kooperativer Föderalismus im Schatten der Politikverflechtung | The federal and state ministers’ conferences and the cooperative federalism in the shadow of political interdependence. |
| 1122562640 | Die Geburt der Philosophie im Garten der Lüste Michel Foucaults Archäologie des platonischen Eros | The Birth of Philosophy in the Garden of Pleasure: Michel Foucault’s Archeology of Platonic Eros |
| 1122587236 | Das Geldwäscherisiko verschiedener Glücksspielarten | The money laundering risk of various gambling types |
| 1122592507 | Entwicklung von großvolumigen CdTe- und (Cd,Zn)Te-Detektorsystemen | Development of high-volume CdTe and (Cd,Zn)Te detector systems |
| 1122593996 | Integrierte bioinformatische Methoden zur reproduzierbaren und transparenten Hochdurchsatz-Analyse von Life Science Big Data | Integrated bioinformatics methods for reproducible and transparent high-throughput analysis of life science big data |

Document IDs and Titles in the Test Set

The dataset contains 8415 document titles, their doc_id and
translations. Each `doc_id` can be resolved to the official public
record by prefixing the base-url `https://d-nb.info/`,
e.g. `doc_id = 1122545479` can be resolved to
<https://d-nb.info/1122545479>. Here you can access more metadata about
the document.

### Gold Standard Data

Each of the document titles was manually annotated by subject experts of
the DNB with subject terms from the Inegrated Authority File (GND).
Similar to the document identifiers, each GND subject term has a unique
identifier, the `label_id`, which can be resolved to the official GND
record by prefixing the base-url `https://d-nb.info/`,
e.g. `label_id = 041321634` can be resolved to
<https://d-nb.info/041321634>.

For more information on the GND please visit [the official GND
website](https://gnd.network/Webs/gnd/EN/Home/home_node.html). In
particular, you can find information on each subject term by visiting
the [GND explorer](https://explore.gnd.network/en/), where you can
search for each `label_id`.

``` r
gold_standard <- read_csv("../data/test-set_gold-standard.csv",
                          col_select = c("doc_id", "label_id"))

# load label_text
gnd_pref_labels <- read_csv("../data/gnd_pref-labels_w-translation.csv")
gold_standard_w_labels <- gold_standard |> 
  left_join(gnd_pref_labels, by = "label_id")

head(gold_standard_w_labels)
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

For the rest of this tutorial This is our gold standard data that we
compare against.

### Predictions

The subfolder `data/test-set_predictions` contains machine based GND
subject suggestions coming from different methods.

``` bash
ls ../data/test-set_predictions
```

    artful-accordion.csv
    bold-bassoon.csv
    charming-cello.csv
    dreamy-didgeridoo.csv
    embracing-euphonium.csv

These datasets all follow the same long table format with columns
`doc_id`, `label_id` and `score`. Every row expresses a subject
assignment of some document with a label under a confidence score
computed by the respective indexing algorithm. The origin of each
prediction file is purposefully not disclosed here, to avoid any bias
when inspecting the results.

``` r
files <- list(
  "artful-accordion" = "../data/test-set_predictions/artful-accordion.csv",
  "bold-bassoon" = "../data/test-set_predictions/bold-bassoon.csv",
  "charming-cello" = "../data/test-set_predictions/charming-cello.csv",
  "dreamy-didgeridoo" = "../data/test-set_predictions/dreamy-didgeridoo.csv",
  "embracing-euphonium" = "../data/test-set_predictions/embracing-euphonium.csv"
)

predictions <- files |> 
  map(read_csv) 
head(predictions[["artful-accordion"]])
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

Gold standard and predictions are the basic input for computing any
retrieval scores.

## Creating a manual comparison table

Before we talk about metrics, let’s look at how we can beautifully join
all of the above tables and get a first informative impression of the
various subject suggestions originating from different automatic
indexing methods.

CASIMiR offers a basic method to construct a comparison table:

``` r
comp <- create_comparison(
  predicted = predictions[["artful-accordion"]],
  gold_standard = gold_standard
)
```

    Warning in create_comparison(predicted = predictions[["artful-accordion"]], :
    Gold standard data contains documents that are not in predicted set.

``` r
# display table for a specific document
comp  |>
  filter(doc_id == "1122545479")  |>
  select(-relevance)  |>
  kable()
```

| doc_id     | label_id  | gold  |     score | suggested |
|:-----------|:----------|:------|----------:|:----------|
| 1122545479 | 041321634 | TRUE  |        NA | FALSE     |
| 1122545479 | 041321650 | TRUE  |        NA | FALSE     |
| 1122545479 | 041608607 | TRUE  | 0.3171981 | TRUE      |
| 1122545479 | 042388120 | TRUE  |        NA | FALSE     |
| 1122545479 | 042718368 | TRUE  |        NA | FALSE     |
| 1122545479 | 043049168 | TRUE  |        NA | FALSE     |
| 1122545479 | 040550729 | FALSE | 0.7565188 | TRUE      |

Note, CASIMiR informs you that apparently not all documents were indexed
by “artful-accordion”. When working with larger data, that is quite
common: There are always edge cases with document titles that lead to
empty results. Silence, not SPAM, may also be a feature for an indexing
method…

Provided you don’t know DNB’s label and document ids by heart, you may
need more context in form of text descriptions. Below code wraps up a
lot of data wrangling to bring the tables into an instructive format:

``` r
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

<div id="zrociydeme" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#zrociydeme table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#zrociydeme thead, #zrociydeme tbody, #zrociydeme tfoot, #zrociydeme tr, #zrociydeme td, #zrociydeme th {
  border-style: none;
}
&#10;#zrociydeme p {
  margin: 0;
  padding: 0;
}
&#10;#zrociydeme .gt_table {
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
&#10;#zrociydeme .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#zrociydeme .gt_title {
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
&#10;#zrociydeme .gt_subtitle {
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
&#10;#zrociydeme .gt_heading {
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
&#10;#zrociydeme .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#zrociydeme .gt_col_headings {
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
&#10;#zrociydeme .gt_col_heading {
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
&#10;#zrociydeme .gt_column_spanner_outer {
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
&#10;#zrociydeme .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#zrociydeme .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#zrociydeme .gt_column_spanner {
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
&#10;#zrociydeme .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#zrociydeme .gt_group_heading {
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
&#10;#zrociydeme .gt_empty_group_heading {
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
&#10;#zrociydeme .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#zrociydeme .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#zrociydeme .gt_row {
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
&#10;#zrociydeme .gt_stub {
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
&#10;#zrociydeme .gt_stub_row_group {
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
&#10;#zrociydeme .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#zrociydeme .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#zrociydeme .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#zrociydeme .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#zrociydeme .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#zrociydeme .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#zrociydeme .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#zrociydeme .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#zrociydeme .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#zrociydeme .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#zrociydeme .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#zrociydeme .gt_footnotes {
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
&#10;#zrociydeme .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#zrociydeme .gt_sourcenotes {
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
&#10;#zrociydeme .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#zrociydeme .gt_left {
  text-align: left;
}
&#10;#zrociydeme .gt_center {
  text-align: center;
}
&#10;#zrociydeme .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#zrociydeme .gt_font_normal {
  font-weight: normal;
}
&#10;#zrociydeme .gt_font_bold {
  font-weight: bold;
}
&#10;#zrociydeme .gt_font_italic {
  font-style: italic;
}
&#10;#zrociydeme .gt_super {
  font-size: 65%;
}
&#10;#zrociydeme .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#zrociydeme .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#zrociydeme .gt_indent_1 {
  text-indent: 5px;
}
&#10;#zrociydeme .gt_indent_2 {
  text-indent: 10px;
}
&#10;#zrociydeme .gt_indent_3 {
  text-indent: 15px;
}
&#10;#zrociydeme .gt_indent_4 {
  text-indent: 20px;
}
&#10;#zrociydeme .gt_indent_5 {
  text-indent: 25px;
}
&#10;#zrociydeme .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#zrociydeme div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>

| Qualitative Method Comparison |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|
| label_id | label_text | gold | score_artful-accordion | score_bold-bassoon | score_charming-cello | score_dreamy-didgeridoo | score_embracing-euphonium |
| 1129543579 - Berlin - Visions of a Future Urbanity on Art, Creativity, and Alternative Urban Design |  |  |  |  |  |  |  |
| 040329038 | Creativity | FALSE | 0.07579290 | 0.20905685 | NA | NA | 0.145 |
| 040621103 | Urbanity | TRUE | 0.31719807 | 0.30762604 | 0.07800756 | NA | 0.355 |
| 040057283 | Berlin | TRUE | 0.36113155 | NA | 0.07056365 | 0.43647248 | 0.121 |
| 041143337 | Art | FALSE | 0.49477395 | 0.22454967 | 0.05172485 | NA | 0.150 |
| 040778045 | Urban Design | TRUE | 0.54210848 | 0.22112384 | 0.05332217 | 0.40142271 | 0.219 |
| 040334228 | Arts | TRUE | NA | NA | NA | NA | NA |
| 040567338 | Urban Geography | TRUE | NA | NA | NA | NA | NA |
| 04268059X | Culture economy | TRUE | NA | NA | NA | NA | NA |
| 040567540 | Urban Planning | FALSE | NA | 0.29041576 | NA | NA | NA |
| 040567303 | Urban development | FALSE | NA | NA | 0.04738772 | NA | NA |
| 041911253 | Future expectation | FALSE | NA | NA | NA | 0.10301682 | NA |
| 041328779 | Future Planning | FALSE | NA | NA | NA | 0.28373721 | NA |
| 040680975 | Future | FALSE | NA | NA | NA | 0.49127367 | NA |
| 1149279583 - Was ist besser? 1945-1965: Wie es wirklich war! |  |  |  |  |  |  |  |
| 041394046 | Goods | FALSE | 0.05739328 | NA | NA | NA | NA |
| 040663809 | Reality | FALSE | 0.10689719 | NA | NA | NA | NA |
| 040013073 | Daily life | TRUE | NA | NA | NA | NA | NA |
| 040118827 | Germany | TRUE | NA | 0.26746377 | 0.10488939 | NA | 0.082 |
| 040118894 | Germany (Federal Republic) | FALSE | NA | 0.05507484 | NA | NA | NA |
| 041900812 | Economic Miracle | FALSE | NA | 0.05519071 | NA | NA | NA |
| 040205177 | History | FALSE | NA | 0.06399128 | NA | NA | NA |
| 948411694 | Post-war period | FALSE | NA | 0.35231987 | NA | NA | NA |
| 040288145 | Jewish persecution | FALSE | NA | NA | 0.04704222 | NA | NA |
| 040432718 | Austria | FALSE | NA | NA | 0.04716158 | NA | NA |
| 041227824 | Everyday Culture | FALSE | NA | NA | 0.04806859 | NA | 0.035 |
| 042071860 | Groß-Lüder | FALSE | NA | NA | 0.04973334 | NA | 0.073 |
| 041360559 | American Civil War (1861-1865) | FALSE | NA | NA | NA | 0.02764216 | NA |
| 040087840 | Civil war | FALSE | NA | NA | NA | 0.03618289 | NA |
| 043163815 | Past | FALSE | NA | NA | NA | 0.12463379 | NA |
| 043261310 | Good Times - Bad Times | FALSE | NA | NA | NA | 0.12642516 | NA |
| 04061672X | Commemoration of the past | FALSE | NA | NA | NA | 0.30247298 | NA |
| 040468402 | Portrait photography | FALSE | NA | NA | NA | NA | 0.029 |
| 040436659 | Optimism | FALSE | NA | NA | NA | NA | 0.031 |
| 1166742806 - Inclusive School and Curriculum Development: From Aspiration to Successful Implementation |  |  |  |  |  |  |  |
| 950251194 | Transformation | FALSE | 0.05997121 | NA | NA | NA | NA |
| 041316657 | Claim | FALSE | 0.31719807 | NA | NA | 0.18597430 | NA |
| 04126892X | School development | TRUE | NA | NA | 0.11813986 | 0.47994795 | 0.858 |
| 041351487 | Organizing the Class | TRUE | NA | NA | NA | NA | NA |
| 1000723437 | Inclusive School | TRUE | NA | 0.29270390 | 0.04837416 | 0.72401166 | 0.066 |
| 965002845 | Inclusion (Sociology) | TRUE | NA | 0.19996907 | 0.06500251 | NA | 0.148 |
| 041276612 | School development planning | FALSE | NA | 0.12761976 | NA | NA | NA |
| 04053474X | School | FALSE | NA | 0.13852690 | NA | NA | NA |
| 100072185X | Inclusive Pedagogy | FALSE | NA | 0.16562288 | 0.04911679 | 0.69988042 | 0.041 |
| 041351754 | Educational research | FALSE | NA | NA | 0.04595719 | NA | NA |
| 123322929X | Inclusive teaching | FALSE | NA | NA | NA | 0.30149797 | NA |
| 040118827 | Germany | FALSE | NA | NA | NA | NA | 0.099 |
| 1220297135 - The Enchantment of the World A Cultural History of Christianity |  |  |  |  |  |  |  |
| 96355123X | Enchantment | FALSE | 0.31719807 | NA | NA | 0.05300185 | NA |
| 04010074X | Christianity | TRUE | 0.56590599 | 0.60737634 | 0.05565031 | NA | 0.255 |
| 041256980 | Culture | TRUE | NA | NA | 0.05168247 | NA | 0.054 |
| 040493962 | Religion | FALSE | NA | 0.07313728 | NA | NA | NA |
| 040307204 | Church History | FALSE | NA | 0.08597670 | NA | NA | NA |
| 040205177 | History | FALSE | NA | 0.08827944 | NA | NA | NA |
| 040349292 | Lifeworld | FALSE | NA | NA | 0.04947460 | NA | NA |
| 040653528 | Worldview | FALSE | NA | NA | 0.04968721 | NA | 0.059 |
| 040277437 | Islam | FALSE | NA | NA | 0.05197397 | NA | 0.091 |
| 04010110X | Christian Literature | FALSE | NA | NA | NA | 0.02210998 | NA |
| 042261309 | Cultural history writing | FALSE | NA | NA | NA | 0.07228480 | NA |
| 040205266 | Historical Consciousness | FALSE | NA | NA | NA | 0.11119287 | NA |
| 041256719 | History of Culture (Field of Study) | FALSE | NA | NA | NA | 0.20801027 | NA |
| 040013286 | Alps | FALSE | NA | NA | NA | NA | 0.039 |
| 1255811684 - Media habitus and biographical legendWriterly performance practices in the age of digitalization |  |  |  |  |  |  |  |
| 042030196 | Age | FALSE | 0.07579290 | NA | NA | NA | NA |
| 040227243 | Habitus | FALSE | 0.31719807 | NA | 0.05817489 | 0.15841071 | 0.351 |
| 041230655 | Digitalization | FALSE | 0.31719807 | 0.37469912 | NA | 0.64681196 | 0.322 |
| 040350282 | Legend | FALSE | 0.31719807 | NA | NA | 0.14183481 | NA |
| 041223497 | Self-presentation | TRUE | NA | NA | NA | NA | NA |
| 041305450 | Authorship | TRUE | NA | 0.08664088 | 0.05726333 | NA | 0.122 |
| 040359646 | Literature | FALSE | NA | 0.12004970 | 0.06323440 | NA | 0.109 |
| 040272230 | Performance | FALSE | NA | 0.28547052 | NA | NA | NA |
| 040533093 | Writer | FALSE | NA | 0.30383539 | NA | NA | NA |
| 041383966 | Self-reference | FALSE | NA | NA | 0.05596432 | NA | NA |
| 041132920 | German | FALSE | NA | NA | 0.06490613 | NA | NA |
| 1038714850 | Digital Humanities | FALSE | NA | NA | NA | 0.13120206 | NA |
| 041969103 | New Media | FALSE | NA | NA | NA | 0.29255560 | 0.112 |

</div>

## Your Turn:

Inspect the above table:

- what subject suggestions do you agree with?

- are there false positives that would be okay, even if not contained in
  the gold standard?

- Which methods do you prefer?
