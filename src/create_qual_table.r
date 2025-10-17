library(gt)

apply_styles <- function(gt_table, column) {
  
  score_column <- paste0("score_", column)
  suggested_column <- paste0("suggested_", column)
  score_column <- rlang::sym(score_column)
  suggested_column <- rlang::sym(suggested_column)
  
  gt_table %>%
    tab_style(
      style = cell_fill(color = "green"),
      locations = cells_body(
        columns = c(score_column),
        rows = gold & !!(suggested_column)
      )
    ) %>%
    tab_style(
      style = cell_fill(color = "red"),
      locations = cells_body(
        columns = c(score_column),
        rows = gold & !(!!(suggested_column))
      )
    ) %>%
    # tab_style(
    #   style = cell_fill(color = "orange"),
    #   locations = cells_body(
    #     columns = c(score_column),
    #     rows = !gold & !!(suggested_column)
    #   )
    # ) |> 
    cols_hide(columns = c(suggested_column))
}

create_qualitative_table <- function(predicted, ...) {
  
  if (is.list(predicted)) {
    qual_table_long <- predicted  |>
      purrr::map_dfr(
        create_qualitative_table_single_model, ...,
        .id = "method")
    
    qual_table_wide <- qual_table_long |>
      dplyr::ungroup() |>
      tidyr::pivot_wider(
        id_cols = c(doc_id, title_text, label_id, label_text, gold),
        names_from = method,
        values_from = c(suggested, score),
        values_fill = list(score = NA_real_, suggested = FALSE)
      ) |>
      dplyr::group_by(doc_id, title_text)    
    
    res <- format_table(qual_table_wide, model_names = names(predictions))
  } else {
    qual_table <- create_qualitative_table_single_model(
      predicted = predicted, ...
    )
    
    res <- format_table(qual_table_wide, model_names = "model")
  
  res
  }

  
}

create_qualitative_table_single_model <- function(
    predicted,
    doc_id_list,
    gold_standard,
    title_texts,
    gnd,
    limit = 5) {
  
  
  if (!is.null(limit)) {
    predicted <- predicted |>
      dplyr::group_by(doc_id) |>
      dplyr::slice_max(order_by = score, n = limit) |>
      dplyr::ungroup()
  }
  
  if (!is.null(gold_standard)) {
    message("Create base comparison with gold standard")
    base_comp <- casimir::create_comparison(
      gold_standard = gold_standard, predicted =  predicted
    )
  } else {
    base_comp <- predicted  |>
      dplyr::mutate(suggested = TRUE, gold = NA)
  }
  
  idn_selecion_w_texts <- doc_id_list  |>
    dplyr::left_join(title_texts, by = "doc_id")  |>
    dplyr::select(doc_id, title_text = title)
  
  qual_table <- idn_selecion_w_texts |>
    dplyr::left_join(base_comp, by = "doc_id")  |>
    dplyr::left_join(gnd, by = c("label_id")) |>
    dplyr::arrange(doc_id) |>
    dplyr::select(doc_id, title_text, label_id,
                  label_text, gold, suggested, score) |>
    dplyr::mutate(title_text = stringr::str_wrap(title_text, 80)) |>
    #dplyr::group_by(doc_id, title_text) |> 
    dplyr::arrange(doc_id, score)
  
  qual_table
}

format_table <- function(df, model_names) {
  nice_table <- df |>
    gt() |>
    tab_header(title = "Qualitative Method Comparison")
  
  out_table <- model_names  |>
    purrr::reduce(
      .init = nice_table,
      .f = ~apply_styles(.x, .y)
    )
  
}