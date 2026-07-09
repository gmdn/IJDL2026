ui <- fluidPage(
  titlePanel("annotaterm demo"),
  
  tags$head(
    tags$style(HTML("
    #input_text,
    
    #text_display {
      width: 100%;
      border: 1px solid #ddd;
      padding: 10px;
      min-height: 140px;
      font-family: Arial, Helvetica, sans-serif;
      font-size: 14px;
      line-height: 1.42857143;
      white-space: pre-wrap;
      margin: 0;
      text-indent: 0;
      box-sizing: border-box;
    
      display: flex;
      align-items: flex-start;   /* top */
      justify-content: flex-start; /* left */
    }

    #annotated_text,
    #annotated_text * {
      margin: 0;
      padding: 0;
      text-indent: 0;
      white-space: pre-wrap;
      text-align: left;
      width: 100%;
    }

    #text_display {
      overflow-y: auto;
    }

    .term-span {
      padding: 0 2px;
      border-radius: 3px;
      font-weight: 600;
    }

    .btn-row .btn { margin-right: 6px; }
    .btn-row { display: flex; flex-wrap: wrap; gap: 6px; }

    .small-table table {
      font-size: 12px;
    }

    .small-table th,
    .small-table td {
      padding: 4px 6px !important;
      vertical-align: top;
    }

    .equal-height-row {
      display: flex;
      gap: 20px;
    }

    .equal-height-col {
      display: flex;
      flex-direction: column;
    }

    .equal-height-col .table-wrapper {
      flex: 1 1 auto;
    }
  "))
  ),
  
  
  # JS: capture selection in TEXTAREA
  tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function() {
      var ta = document.getElementById('input_text');
      if (!ta) return;

      function sendSelection() {
        var start = ta.selectionStart;
        var end = ta.selectionEnd;
        if (start === end) return;
        var txt = ta.value.substring(start, end);

        Shiny.setInputValue('current_selection', {
          text: txt,
          start: start + 1,
          end: end
        }, {priority: 'event'});
      }

      ta.addEventListener('select', sendSelection);
      ta.addEventListener('mouseup', sendSelection);
      ta.addEventListener('keyup', function(e) {
        if (e.shiftKey &&
            (e.key === 'ArrowLeft' || e.key === 'ArrowRight' ||
             e.key === 'ArrowUp'   || e.key === 'ArrowDown')) {
          sendSelection();
        }
      });
    });
  ")),
  
  sidebarLayout(
    sidebarPanel(
      h4("Current selection"),
      verbatimTextOutput("selection_text"),
      
      hr(),
      h4("Simple terms"),
      actionButton("add_simple", "Add simple term (from selection)"),
      textInput("simple_label", "Simple term label", value = ""),
      
      hr(),
      h4("Composite terms"),
      div(
        class = "btn-row",
        actionButton("reset_composite", "reset"),
        actionButton("add_fragment", "add fragment"),
        actionButton("save_composite", "save composite")
      ),
      textInput("composite_label", "Composite term label", value = ""),
      br(),
      strong("Current fragments:"),
      verbatimTextOutput("composite_fragments_text"),
      
      hr(),
      h4("Edit annotations"),
      div(
        class = "btn-row",
        actionButton("delete_last", "delete last"),
        actionButton("clear_all", "clear all")
      ),
      br(),
      selectInput("delete_term_id", "Delete by term_id:", choices = character(0)),
      actionButton("delete_term_id_btn", "delete selected"),
      
      hr(),
      h4("Import"),
      fileInput("import_json", "Import annotations (JSON)", accept = ".json"),
      
      hr(),
      h4("Export"),
      div(
        class = "btn-row",
        downloadButton("download_json", "export JSON"),
        downloadButton("download_csv", "export CSV")
      )
    ),
    
    mainPanel(
      h4("Text input (select here)"),
      textAreaInput(
        inputId = "input_text",
        label = NULL,
        value = abstract_text,
        width = "100%",
        rows = 15
      ),
      
      hr(),
      h4("Annotated preview"),
      div(id = "text_display", htmlOutput("annotated_text")),
      
      hr(),
      fluidRow(
        class = "equal-height-row",
        column(
          width = 6,
          class = "equal-height-col",
          h4("Annotations"),
          div(
            class = "table-wrapper small-table",
            tableOutput("annotations_table")
          )
        ),
        column(
          width = 6,
          class = "equal-height-col",
          h4("Annotation objects"),
          div(
            class = "table-wrapper small-table",
            tableOutput("annotation_objects_table")
          )
        )
      )
      
    )
  )
)