# Workbook 7 (Bonus): Evaluating Graded Relevance Ratings
Maximilian Kähler, DNB

- [Datasets](#datasets)
  - [Your turn:](#your-turn)
- [Graded Relevance Metrics](#graded-relevance-metrics)
- [Computing Graded Relevance Metrics with
  CASIMiR](#computing-graded-relevance-metrics-with-casimir)
  - [Your turn](#your-turn-1)

In this bonus workbook we will explore how to evaluate graded relevance
ratings using the CASIMiR package. Graded relevance ratings are useful
when you want to capture more nuanced judgments about the relevance of
subject terms beyond a simple binary relevant/ not relevant distinction.
In binary relevance comparison, we often find false postives that are
not entirely wrong. Also manual indexers can have some interrater
disagreement, so that annotations are not always black and white. Graded
relevance ratings allow us to capture these nuances by assigning
different levels of relevance to machine based subject terms. This is
the of evaluation that comes with the highes cost, as it requires
subject experts to manually rate the relevance of each suggested subject
term.

## Datasets

In this workbook we use a different pair of data files for each method.
For each method we have a file of predicted subject terms along with
graded relevance ratings assigned by subject experts and a gold standard
file with binary relevance labels, that also contain false negatives.

The graded relevance ratings are on an ordinal scale from 0 to 3:

- 0: not relevant/ wrong
- 1: slightly helpful
- 2: helpful
- 3: very helpful

Where helpful means that the subject term would be useful for a user to
find the document for retrieval purposes. To calculate metrics from
these ordinal ratings, we map them to metric relevance levels $r$
between 0 and 1 as follows:

| Ordinal Relevance Level | Metric Relevance Level $r$ |
|-------------------------|----------------------------|
| very helpful            | 1                          |
| helpful                 | 2/3                        |
| slightly helpful        | 1/3                        |
| wrong                   | 0                          |

Let’s take a look at how the data looks like for one of the methods,
e.g. “bold-bassoon”.

``` r
method_name <- "bold-bassoon"

preds <- predictions_w_relevance[[method_name]] 
gold <- gold_standards[[method_name]]
set.seed(681)
documents <- predictions_w_relevance[[method_name]] |> 
  distinct(doc_id) |>
  sample_n(3)

example_table <- create_qualitative_table_single_model(
    predicted = predictions_w_relevance[[method_name]],
    gold_standard = gold_standards[[method_name]],
    doc_id_list = documents,
    title_texts = select(doc_titles, doc_id, title = doc_title_eng),
    gnd = select(gnd, label_id, label_text = label_text_eng),
    graded_relevance = TRUE
) |> 
  group_by(doc_id, title_text)  |> 
  arrange(doc_id, gold, relevance) 

apply_styles_single_model_graded_rel(example_table)
```

<div id="croixhbitn" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#croixhbitn table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#croixhbitn thead, #croixhbitn tbody, #croixhbitn tfoot, #croixhbitn tr, #croixhbitn td, #croixhbitn th {
  border-style: none;
}
&#10;#croixhbitn p {
  margin: 0;
  padding: 0;
}
&#10;#croixhbitn .gt_table {
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
&#10;#croixhbitn .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#croixhbitn .gt_title {
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
&#10;#croixhbitn .gt_subtitle {
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
&#10;#croixhbitn .gt_heading {
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
&#10;#croixhbitn .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#croixhbitn .gt_col_headings {
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
&#10;#croixhbitn .gt_col_heading {
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
&#10;#croixhbitn .gt_column_spanner_outer {
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
&#10;#croixhbitn .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#croixhbitn .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#croixhbitn .gt_column_spanner {
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
&#10;#croixhbitn .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#croixhbitn .gt_group_heading {
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
&#10;#croixhbitn .gt_empty_group_heading {
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
&#10;#croixhbitn .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#croixhbitn .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#croixhbitn .gt_row {
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
&#10;#croixhbitn .gt_stub {
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
&#10;#croixhbitn .gt_stub_row_group {
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
&#10;#croixhbitn .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#croixhbitn .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#croixhbitn .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#croixhbitn .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#croixhbitn .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#croixhbitn .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#croixhbitn .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#croixhbitn .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#croixhbitn .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#croixhbitn .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#croixhbitn .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#croixhbitn .gt_footnotes {
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
&#10;#croixhbitn .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#croixhbitn .gt_sourcenotes {
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
&#10;#croixhbitn .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#croixhbitn .gt_left {
  text-align: left;
}
&#10;#croixhbitn .gt_center {
  text-align: center;
}
&#10;#croixhbitn .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#croixhbitn .gt_font_normal {
  font-weight: normal;
}
&#10;#croixhbitn .gt_font_bold {
  font-weight: bold;
}
&#10;#croixhbitn .gt_font_italic {
  font-style: italic;
}
&#10;#croixhbitn .gt_super {
  font-size: 65%;
}
&#10;#croixhbitn .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#croixhbitn .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#croixhbitn .gt_indent_1 {
  text-indent: 5px;
}
&#10;#croixhbitn .gt_indent_2 {
  text-indent: 10px;
}
&#10;#croixhbitn .gt_indent_3 {
  text-indent: 15px;
}
&#10;#croixhbitn .gt_indent_4 {
  text-indent: 20px;
}
&#10;#croixhbitn .gt_indent_5 {
  text-indent: 25px;
}
&#10;#croixhbitn .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#croixhbitn div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>

| label_id | label_text | gold | suggested | score | relevance |
|----|----|----|----|----|----|
| 1131755340 - Advising is not the same as advising |  |  |  |  |  |
| 041142667 | Conflict resolution | FALSE | TRUE | 0.06658245 | 0.3333333 |
| 04055676X | Social work | FALSE | TRUE | 0.08203498 | 0.3333333 |
| 040318834 | Communication | FALSE | TRUE | 0.09478208 | 0.3333333 |
| 041481143 | Coaching | FALSE | TRUE | 0.11768963 | 0.6666667 |
| 040055655 | Counseling | TRUE | TRUE | 0.49701533 | 1.0000000 |
| 040028054 | Work world | TRUE | FALSE | NA | 1.0000000 |
| 040349292 | Lifeworld | TRUE | FALSE | NA | 1.0000000 |
| 040477460 | Psychotherapy | TRUE | FALSE | NA | 1.0000000 |
| 953407497 | Professionalism | TRUE | FALSE | NA | 1.0000000 |
| 1166053415 - Effect of the isovalent defects induced by boron and nitrogen on the conduction band transport in III-V semiconductors |  |  |  |  |  |
| 041347072 | Energy transmission | FALSE | TRUE | 0.21075520 | 0.0000000 |
| 040229939 | Semiconductor | FALSE | TRUE | 0.22035000 | 0.3333333 |
| 041506499 | Three-Five-Semiconductor | FALSE | TRUE | 0.28561482 | 0.6666667 |
| 041256395 | Nitrogen | TRUE | TRUE | 0.39500058 | 1.0000000 |
| 040077098 | Bor | TRUE | TRUE | 0.55118501 | 1.0000000 |
| 944368581 | Gallium Nitride | TRUE | FALSE | NA | 1.0000000 |
| 040191559 | Gallium arsenide | TRUE | FALSE | NA | 1.0000000 |
| 042107334 | Electronic Transport | TRUE | FALSE | NA | 1.0000000 |
| 969784155 | Isoelectric site | TRUE | FALSE | NA | 1.0000000 |
| 1184797021 - Carry Trades - An Empirical Analysis |  |  |  |  |  |
| 041212738 | Finance | FALSE | TRUE | 0.11675494 | 0.0000000 |
| 040172147 | Financial Economy | FALSE | TRUE | 0.27503827 | 0.0000000 |
| 04132613X | Carry over | FALSE | TRUE | 0.42393142 | 0.0000000 |
| 043004008 | Empirical research | FALSE | TRUE | 0.14040960 | 0.3333333 |
| 040737888 | Credit market | FALSE | TRUE | 0.14715549 | 0.3333333 |
| 041947266 | Currency speculation | TRUE | FALSE | NA | 1.0000000 |
| 041909232 | Interest arbitrage | TRUE | FALSE | NA | 1.0000000 |

</div>

### Your turn:

- alter the seed to see more examples
- try it out with other methods by changing the method name in the code
  above

## Graded Relevance Metrics

It is possible to generalise the binary relevance metrics Precision and
Recall to graded relevance ratings (Kekäläinen and Järvelin 2002).

**Generalised Precision**

$$
\mathrm{gPrec} := \frac{tp + \Delta_{rel}}{tp + fp}
$$

**Generalised Recall**  
$$
\mathrm{gRec} := \frac{tp + \Delta_{rel}}{tp + fn + \Delta_{rel}}
$$

with $\Delta_{rel} = \sum_{i \in false\ positives} r_i$ with metric
relevance ratings $0 \leq r_i \leq 1$

## Computing Graded Relevance Metrics with CASIMiR

CASIMiR also provides functions to compute graded relevance metrics.
Actually, you already know the `compute_set_retrieval_scores()` function
from workbook 2. It can also handle graded relevance ratings if you set
the `graded_relevance` argument to `TRUE`. This assumes that `predicted`
contains a `relevance` column with graded relevance ratings.

The following example shows how to compute graded relevance metrics for
the “bold-bassoon” method.

``` r
res <- compute_set_retrieval_scores(
  predicted = predictions_w_relevance[["bold-bassoon"]],
  gold_standard = gold_standards[["bold-bassoon"]],
  graded_relevance = TRUE,
  k = 5,
  rename_metrics = TRUE # adds prefix "g-" to metric names
) 

kable(
  res,
  caption = "Graded relevance metrics for bold-bassoon"
)
```

| metric    | mode    |     value | support |
|:----------|:--------|----------:|--------:|
| g-f1@5    | doc-avg | 0.5666984 |    1132 |
| g-prec@5  | doc-avg | 0.5916863 |    1132 |
| g-rec@5   | doc-avg | 0.5794029 |    1132 |
| g-rprec@5 | doc-avg | 0.6692180 |    1132 |

Graded relevance metrics for bold-bassoon

We can now iterate this over all methods like we did in workbook 2.

``` r
res_all_methods <- map2_dfr(
  predictions_w_relevance,
  gold_standards,
  ~ compute_set_retrieval_scores(
    predicted = .x,
    gold_standard = .y,
    graded_relevance = TRUE,
    k = 5,
    rename_metrics = TRUE
  ),
  .id = "Method"
) |> 
  select(-support) |> 
  pivot_wider(
    names_from = metric,
    values_from = value
  ) 
```

**Note:** Workbook 2 was on a different dataset and here all methods
were tested on their own dataset. So the results are not directly
comparable.

### Your turn

- compare the results with the binary relevance metrics
- can you compute a graded relevance precision recall curve?

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-Kekalainen2002" class="csl-entry">

Kekäläinen, Jaana, and Kalervo Järvelin. 2002. “Using Graded Relevance
Assessments in IR Evaluation.” *Journal of the American Society for
Information Science and Technology* 53 (November): 1120–29.
<https://doi.org/10.1002/asi.10137>.

</div>

</div>
