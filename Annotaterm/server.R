server <- function(input, output, session) {
  
  # One row per span (observation)
  annotations_rv <- reactiveVal(
    data.frame(
      fragment_id = character(),  # F1, F2, ...
      term_id     = character(),  # T1, T2... for simple; C1, C2... for composite
      type        = character(),
      term_label  = character(),
      fragment     = character(),
      start       = integer(),
      finish      = integer(),
      color       = character(),  # internal
      stringsAsFactors = FALSE
    )
  )
  
  composite_builder <- reactiveVal(
    data.frame(
      fragment = character(),
      start   = integer(),
      finish  = integer(),
      stringsAsFactors = FALSE
    )
  )
  
  fragment_counter <- reactiveVal(0L)
  simple_counter <- reactiveVal(0L)
  composite_counter <- reactiveVal(0L)
  
  
  # take_next_fragment_id <- function() {
  #   i <- fragment_counter() + 1L
  #   fragment_counter(i)
  #   paste0("F", i)
  # }
  
  get_or_create_fragment_id <- function(df, fragment, start, finish) {
    hit <- df[
      df$fragment == fragment &
        df$start == start &
        df$finish == finish,
      ,
      drop = FALSE
    ]
    
    if (nrow(hit) > 0) {
      return(hit$fragment_id[1])
    }
    
    i <- fragment_counter() + 1L
    fragment_counter(i)
    paste0("F", i)
  }
  
  # Palette cycles per mention
  palette <- c("#FFE066", "#B5E48C", "#A0C4FF", "#FFADAD")
  next_color_index <- reactiveVal(0L)
  
  take_next_color <- function() {
    i <- next_color_index() + 1L
    next_color_index(i)
    palette[(i - 1L) %% length(palette) + 1L]
  }
  
  
  # Duplicate check: exact same span already present (regardless of term_id)
  is_duplicate_span <- function(df, fragment, start, finish) {
    any(df$fragment == fragment & df$start == start & df$finish == finish)
  }
  
  simple_annotation_exists <- function(df, term_label, fragment, start, finish) {
    any(
      df$type == "simple" &
        df$term_label == term_label &
        df$fragment == fragment &
        df$start == start &
        df$finish == finish
    )
  }
  
  composite_annotation_exists <- function(df, seg_df, term_label) {
    comp_ids <- unique(df$term_id[df$type == "composite"])
    
    any(vapply(comp_ids, function(id) {
      sub_df <- df[df$term_id == id, , drop = FALSE]
      
      if (nrow(sub_df) != nrow(seg_df)) {
        return(FALSE)
      }
      
      sub_df <- sub_df[order(sub_df$start, sub_df$finish, sub_df$fragment), ]
      cmp_df <- seg_df[order(seg_df$start, seg_df$finish, seg_df$fragment), ]
      
      same_label <- length(unique(sub_df$term_label)) == 1 &&
        unique(sub_df$term_label) == term_label
      
      same_spans <- all(
        sub_df$fragment == cmp_df$fragment &
          sub_df$start == cmp_df$start &
          sub_df$finish == cmp_df$finish
      )
      
      isTRUE(same_label) && same_spans
    }, logical(1)))
  }
  
  matching_simple_span_exists <- function(df, start, finish) {
    any(
      df$type == "simple" &
        df$start == start &
        df$finish == finish
    )
  }
  
  matching_composite_span_exists <- function(df, fragment, start, finish) {
    comp_ids <- unique(df$term_id[df$type == "composite"])
    
    normalize_text <- function(x) {
      gsub("\\s+", " ", trimws(x))
    }
    
    target_fragment <- normalize_text(fragment)
    
    any(vapply(comp_ids, function(id) {
      sub_df <- df[df$term_id == id, , drop = FALSE]
      sub_df <- sub_df[order(sub_df$start, sub_df$finish), , drop = FALSE]
      
      composite_fragment <- paste(sub_df$fragment, collapse = " ")
      composite_fragment <- normalize_text(composite_fragment)
      
      same_outer_span <-
        min(sub_df$start) == start &&
        max(sub_df$finish) == finish
      
      same_surface <- composite_fragment == target_fragment
      
      same_outer_span && same_surface
    }, logical(1)))
  }
  
  span_exists_in_term <- function(df, term_id, fragment, start, finish) {
    any(
      df$term_id == term_id &
        df$fragment == fragment &
        df$start == start &
        df$finish == finish
    )
  }
  
  span_exists_anywhere <- function(df, fragment, start, finish) {
    any(
      df$fragment == fragment &
        df$start == start &
        df$finish == finish
    )
  }
  
  
  # Keep delete-by-term_id choices in sync
  observe({
    df <- annotations_rv()
    ids <- unique(df$term_id)
    updateSelectInput(session, "delete_term_id", choices = ids)
  })
  
  output$selection_text <- renderText({
    sel <- input$current_selection
    if (is.null(sel) || is.null(sel$text) || !nzchar(sel$text)) {
      return("No selection.")
    }
    sprintf("'%s' [start=%d, finish=%d]", sel$text, sel$start, sel$end)
  })
  
  # ---- Add simple term (T1, T2, ...) ----
  observeEvent(input$add_simple, {
    
    sel <- input$current_selection
    req(sel, sel$text, nzchar(sel$text), sel$start, sel$end)
    
    df <- annotations_rv()
    
    if (matching_composite_span_exists(
      df,
      sel$text,
      as.integer(sel$start),
      as.integer(sel$end)
    )) {
      showNotification(
        "This simple term corresponds to a composite term already stored.",
        type = "warning"
      )
      return()
    }
    
    
    # if (is_duplicate_span(df, sel$text, sel$start, sel$end)) {
    #   showNotification("This exact annotation already exists.", type = "message")
    #   return()
    # }
    
    if (span_exists_anywhere(df, sel$text, sel$start, sel$end)) {
      showNotification(
        "This fragment is already used in another annotation.",
        type = "message"
      )
    }
    
    id_num <- simple_counter() + 1L
    simple_counter(id_num)
    term_id <- paste0("T", id_num)
    
    fragment_id <- get_or_create_fragment_id(
      df,
      sel$text,
      as.integer(sel$start),
      as.integer(sel$end)
    )
    
    label <- trimws(input$simple_label)
    
    if (simple_annotation_exists(df, label, sel$text, as.integer(sel$start), as.integer(sel$end))) {
      showNotification(
        "This simple term is already stored.",
        type = "warning"
      )
      return()
    }
    
    new_row <- data.frame(
      fragment_id = fragment_id,
      term_id = term_id,
      type = "simple",
      term_label = trimws(input$simple_label),
      fragment = sel$text,
      start = as.integer(sel$start),
      finish = as.integer(sel$end),
      color = take_next_color(),
      stringsAsFactors = FALSE
    )
    
    annotations_rv(rbind(df, new_row))
  })
  
  # ---- Composite builder ----
  observeEvent(input$reset_composite, {
    composite_builder(
      data.frame(
        fragment = character(),
        start = integer(),
        finish = integer(),
        stringsAsFactors = FALSE
      )
    )
  })
  
  observeEvent(input$add_fragment, {
    sel <- input$current_selection
    req(sel, sel$text, nzchar(sel$text), sel$start, sel$end)
    
    seg_df <- composite_builder()
    new_row <- data.frame(
      fragment = sel$text,
      start   = as.integer(sel$start),
      finish  = as.integer(sel$end),
      stringsAsFactors = FALSE
    )
    
    # avoid identical duplicate fragment span inside the builder
    is_dup <- seg_df$fragment == new_row$fragment &
      seg_df$start == new_row$start &
      seg_df$finish == new_row$finish
    
    if (!any(is_dup)) {
      composite_builder(rbind(seg_df, new_row))
    }
  })
  
  output$composite_fragments_text <- renderText({
    seg_df <- composite_builder()
    if (nrow(seg_df) == 0) return("No fragments yet.")
    paste(sprintf("%s [%d-%d]", seg_df$fragment, seg_df$start, seg_df$finish), collapse = " + ")
  })
  
  # ---- Save composite (C1, C2, ...) ----
  observeEvent(input$save_composite, {
    
    seg_df <- composite_builder()
    
    if (nrow(seg_df) < 2) {
      showNotification("Composite terms need at least 2 fragments.", type = "warning")
      return()
    }
    
    df <- annotations_rv()
    
    composite_start <- min(seg_df$start)
    composite_finish <- max(seg_df$finish)
    
    if (matching_simple_span_exists(df, composite_start, composite_finish)) {
      showNotification(
        "This composite term corresponds to a simple term already stored.",
        type = "warning"
      )
      return()
    }
    
    
    label <- trimws(input$composite_label)
    
    if (composite_annotation_exists(df, seg_df, label)) {
      showNotification("This composite term is already stored.", type = "warning")
      return()
    }
    
    dups_elsewhere <- mapply(
      function(seg, st, fn) span_exists_anywhere(df, seg, st, fn),
      seg_df$fragment, seg_df$start, seg_df$finish
    )
    
    if (any(dups_elsewhere)) {
      showNotification(
        "Some fragments are already used in other annotations; reusing them.",
        type = "message"
      )
    }
    
    
    id_num <- composite_counter() + 1L
    composite_counter(id_num)
    term_id <- paste0("C", id_num)
    
    color <- take_next_color()
    
    fragment_ids <- vapply(
      seq_len(nrow(seg_df)),
      function(i) {
        get_or_create_fragment_id(
          df,
          seg_df$fragment[i],
          as.integer(seg_df$start[i]),
          as.integer(seg_df$finish[i])
        )
      },
      character(1)
    )
    
    
    new_rows <- data.frame(
      fragment_id = fragment_ids,
      term_id = term_id,
      type = "composite",
      term_label = trimws(input$composite_label),
      fragment = seg_df$fragment,
      start = seg_df$start,
      finish = seg_df$finish,
      color = color,
      stringsAsFactors = FALSE
    )
    
    annotations_rv(rbind(df, new_rows))
    
    # reset builder
    composite_builder(
      data.frame(
        fragment = character(),
        start = integer(),
        finish = integer(),
        stringsAsFactors = FALSE
      )
    )
  })
  
  # ---- Delete / clear ----
  observeEvent(input$delete_last, {
    df <- annotations_rv()
    if (nrow(df) == 0) return()
    
    last_id <- df$term_id[nrow(df)]
    annotations_rv(df[df$term_id != last_id, , drop = FALSE])
  })
  
  observeEvent(input$delete_term_id_btn, {
    df <- annotations_rv()
    id <- input$delete_term_id
    if (is.null(id) || !nzchar(id) || nrow(df) == 0) return()
    annotations_rv(df[df$term_id != id, , drop = FALSE])
  })
  
  observeEvent(input$clear_all, {
    annotations_rv(annotations_rv()[0, ])
    composite_builder(
      data.frame(
        fragment = character(),
        start = integer(),
        finish = integer(),
        stringsAsFactors = FALSE
      )
    )
  })
  
  # ---- Table (hide color, hide label) ----
  output$annotations_table <- renderTable({
    df <- annotations_rv()
    if (nrow(df) == 0) return(NULL)
    df <- df[order(df$term_id, df$fragment_id), ]
    df[, c("fragment_id","term_id", "type", "term_label", "fragment", "start", "finish")]
  })
  
  output$annotation_objects_table <- renderTable({
    df <- annotations_rv()
    if (nrow(df) == 0) {
      return(NULL)
    }
    
    obj_df <- df |>
      dplyr::group_by(term_id, type, term_label) |>
      dplyr::summarise(
        n_fragments = dplyr::n(),
        fragments = paste(sprintf("%s [%d-%d]", fragment, start, finish), collapse = " + "),
        .groups = "drop"
      )
    
    obj_df
  })
  
  
  # ---- Import ----
  observeEvent(input$import_json, {
    req(input$import_json)
    
    json_obj <- jsonlite::read_json(input$import_json$datapath, simplifyVector = TRUE)
    
    rows <- lapply(json_obj, function(obj) {
      spans <- obj$spans
      data.frame(
        fragment_id = spans$fragment_id,
        term_id = obj$term_id,
        type = obj$type,
        term_label = if (!is.null(obj$term_label)) obj$term_label else "",
        fragment = spans$fragment,
        start = as.integer(spans$start),
        finish = as.integer(spans$finish),
        color = take_next_color(),
        stringsAsFactors = FALSE
      )
    })
    
    df <- do.call(rbind, rows)
    annotations_rv(df)
  })
  
  # ---- Export ----
  output$download_csv <- downloadHandler(
    filename = function() sprintf("annotaterm_%s.csv", Sys.Date()),
    content = function(file) {
      df <- annotations_rv()
      out <- df[, c("fragment_id","term_id", "type", "term_label", "fragment", "start", "finish")]
      write.csv(out, file, row.names = FALSE)
    }
  )
  
  output$download_json <- downloadHandler(
    filename = function() sprintf("annotaterm_%s.json", Sys.Date()),
    content = function(file) {
      df <- annotations_rv()
      out <- df[, c("fragment_id","term_id", "type", "term_label", "fragment", "start", "finish")]
      
      grouped <- split(out, out$term_id)
      json_obj <- lapply(grouped, function(d) {
        list(
          term_id = d$term_id[1],
          type = d$type[1],
          term_label = d$term_label[1],
          spans = lapply(seq_len(nrow(d)), function(i) {
            list(
              fragment_id = d$fragment_id[i],
              fragment = d$fragment[i],
              start = d$start[i],
              finish = d$finish[i]
            )
          })
        )
      })
      
      jsonlite::write_json(json_obj, file, auto_unbox = TRUE, pretty = TRUE)
    }
  )
  
  
  
  
  # ---- Overlap-friendly preview with tooltips ----
  output$annotated_text <- renderUI({
    text <- input$input_text
    df <- annotations_rv()
    
    if (!nzchar(text) || nrow(df) == 0) {
      return(HTML(htmlEscape(text)))
    }
    
    df <- df[!is.na(df$start) & !is.na(df$finish), ]
    if (nrow(df) == 0) return(HTML(htmlEscape(text)))
    df <- df[order(df$start, df$finish), ]
    
    text_len <- nchar(text)
    
    cuts <- sort(unique(c(
      1L,
      text_len + 1L,
      pmax(1L, pmin(text_len + 1L, df$start)),
      pmax(1L, pmin(text_len + 1L, df$finish + 1L))
    )))
    cuts <- cuts[cuts >= 1L & cuts <= text_len + 1L]
    
    bg_style <- function(cols_rgba) {
      cols_rgba <- unique(cols_rgba)
      if (length(cols_rgba) == 1) {
        return(sprintf("background:%s;", cols_rgba[1]))
      }
      cols_rgba <- cols_rgba[seq_len(min(length(cols_rgba), 4L))]
      n <- length(cols_rgba)
      stops <- seq(0, 100, length.out = n + 1)
      parts <- character()
      for (i in seq_len(n)) {
        parts <- c(parts, sprintf("%s %.1f%% %.1f%%", cols_rgba[i], stops[i], stops[i + 1]))
      }
      sprintf("background:linear-gradient(90deg,%s);", paste(parts, collapse = ","))
    }
    
    out <- character()
    
    for (i in seq_len(length(cuts) - 1L)) {
      st <- cuts[i]
      en <- cuts[i + 1L] - 1L
      if (st > en) next
      
      chunk <- substr(text, st, en)
      chunk_esc <- htmlEscape(chunk)
      
      active <- df$start <= st & df$finish >= en
      
      if (!any(active)) {
        out <- c(out, chunk_esc)
      } else {
        active_df <- df[active, , drop = FALSE]
        cols <- vapply(active_df$color, hex_to_rgba, character(1), alpha = 0.35)
        style <- bg_style(cols)
        
        # Tooltip: show all covering term_ids/types for this chunk
        tip <- paste(
          #sprintf("%s (%s) [%d-%d]", active_df$term_id, active_df$type, active_df$start, active_df$finish),
          sprintf(
            "%s | %s (%s) [%d-%d]",
            active_df$term_id,
            active_df$term_label,
            active_df$type,
            active_df$start,
            active_df$finish
          ),
          collapse = " | "
        )
        tip <- htmlEscape(tip)
        
        out <- c(out, sprintf(
          "<span class='term-span' title='%s' style='%s'>%s</span>",
          tip, style, chunk_esc
        ))
      }
    }
    
    HTML(paste(out, collapse = ""))
  })
}