gold_standard <- read_csv("../data/test-set_gold-standard.csv",
                          col_select = c("doc_id", "label_id"),
                          show_col_types = FALSE)

files <- list(
  "artful-accordion" = "../data/test-set_predictions/artful-accordion.csv",
  "bold-bassoon" = "../data/test-set_predictions/bold-bassoon.csv",
  "charming-cello" = "../data/test-set_predictions/charming-cello.csv",
  "dreamy-didgeridoo" = "../data/test-set_predictions/dreamy-didgeridoo.csv",
  "embracing-euphonium" = "../data/test-set_predictions/embracing-euphonium.csv"
)

predictions <- files |>
  map(read_csv, show_col_types = FALSE)
