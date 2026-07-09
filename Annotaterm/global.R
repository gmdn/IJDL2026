library(shiny)
library(htmltools)
library(jsonlite)

hex_to_rgba <- function(hex, alpha = 0.35) {
  hex <- gsub("#", "", hex)
  r <- strtoi(substr(hex, 1, 2), 16L)
  g <- strtoi(substr(hex, 3, 4), 16L)
  b <- strtoi(substr(hex, 5, 6), 16L)
  sprintf("rgba(%d,%d,%d,%.3f)", r, g, b, alpha)
}

abstract_text <- paste0(
  "Annotaterm is a lightweight web-based annotation tool designed to support the identification of both simple and composite terms in running text.\n",
  "A simple term corresponds to a single contiguous span, such as waste management, machine learning, or digital library.\n",
  "A composite term includes two or more fragments that together form one conceptual unit, even when they are separated in the sentence, as in waste management and disposal, where waste management and waste disposal partially overlap.\n",
  "The tool is also intended to handle cases in which fragments are reused across multiple annotations, for example when the fragment *waste* appears in both *waste management* and *waste disposal*. By adopting a fragment-based representation, Annotaterm allows annotators to mark non-contiguous and partially overlapping expressions without forcing them into purely contiguous-span models. The goal of the usability test is to assess whether this interaction model is intuitive, efficient, and suitable for terminology annotation and named entity annotation in realistic corpus-based workflows."
)
