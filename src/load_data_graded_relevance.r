# read graded relevance datasets

files_relevance_ratings <- c(
  # no data for artful-accordion here
  "bold-bassoon" = "../data/graded_relevance/bold-bassoon_relevance-ratings.csv",
  "charming-cello" = "../data/graded_relevance/charming-cello_relevance-ratings.csv",
  "dreamy-didgeridoo" = "../data/graded_relevance/dreamy-didgeridoo_relevance-ratings.csv",
  "embracing-euphonium" = "../data/graded_relevance/embracing-euphonium_relevance-ratings.csv"
)

files_gold_standard <- c(
  "bold-bassoon" = "../data/graded_relevance/bold-bassoon_gold-standard.csv",
  "charming-cello" = "../data/graded_relevance/charming-cello_gold-standard.csv",
  "dreamy-didgeridoo" = "../data/graded_relevance/dreamy-didgeridoo_gold-standard.csv",
  "embracing-euphonium" = "../data/graded_relevance/embracing-euphonium_gold-standard.csv"
)

predictions_w_relevance <- files_relevance_ratings |> 
  map(
    read_csv,
    show_col_types = FALSE
  ) 

gold_standards <- files_gold_standard |>
  map(
    read_csv,
    show_col_types = FALSE
  )

gnd <- read_csv(
  "../data/gnd_pref-labels_w-translation.csv",
  show_col_types = FALSE
)

doc_titles <- read_csv(
  "../data/graded_relevance/doc_titles_w-translations.csv",
  show_col_types = FALSE
)
