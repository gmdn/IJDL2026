# Annotaterm

**Annotaterm** is a lightweight web-based annotation environment for the annotation of **contiguous**, **discontinuous**, **overlapping**, and **nested** terms through a **fragment-based annotation model**.

The application is implemented in **R Shiny** and was developed as a research prototype for terminology-oriented and digital library workflows.

---

## Motivation

Many existing annotation environments represent discontinuous annotations indirectly by linking multiple spans through relations.

Annotaterm adopts a different approach.

Instead of treating discontinuous expressions as collections of independent annotations, Annotaterm represents an annotation as a conceptual object composed of one or more **fragments**, each explicitly identified and linked through a shared annotation identifier.

This representation naturally supports:

- contiguous terms;
- discontinuous terms;
- overlapping annotations;
- terms within terms (nested annotations).

---

## Features

- Simple (contiguous) term annotation
- Composite (multi-fragment) term annotation
- Overlapping and nested annotations
- Fragment reuse across multiple annotation objects
- Automatic duplicate detection
- Fragment and annotation identifiers
- Live highlighted preview
- Annotation summary tables
- CSV export
- JSON export/import
- Lightweight deployment with R Shiny

---

## Annotation Model

Annotaterm is based on a **fragment-based representation**.

Each annotation object consists of one or more textual fragments.

Each fragment stores:

- fragment identifier
- textual content
- character offsets

Fragments belonging to the same annotation are linked through a shared annotation identifier.

Example:

```
Waste management and disposal
```

can be annotated as

```
Simple term
-------------
Waste management

Composite term
--------------
Waste + disposal

Nested term
-----------
Waste
```

---

## Repository Structure

```
annotaterm/
│
├── app.R
├── global.R
├── ui.R
├── server.R
├── www/
│   ├── annotaterm.js
│   └── style.css
├── data/
└── README.md
```

---

## Installation

Clone the repository

```bash
git clone https://github.com/USERNAME/annotaterm.git
```

Open the project in RStudio.

Install the required packages:

```r
install.packages(c(
  "shiny",
  "shinyjs",
  "jsonlite",
  "dplyr"
))
```

Run the application

```r
shiny::runApp()
```

---

## Usage

1. Paste or load a text.
2. Select a text fragment.
3. Create a **Simple Term** or add the fragment to a **Composite Term**.
4. Inspect annotations in the summary tables.
5. Export annotations as CSV or JSON.

---

## Output

### Annotation table

Each row corresponds to one fragment.

|fragment_id|term_id|type|label|segment|start|finish|
|------------|-------|----|-----|-------|------|------|

### Annotation objects

Fragments belonging to the same annotation are grouped together.

---

## Publications

### Journal article

Di Nunzio, G. M., & Vezzani, F.

**Annotaterm: A Fragment-Based Annotation Environment for Discontinuous and Overlapping Terms in Digital Library Workflows.**

*International Journal on Digital Libraries (IJDL).*

*(to appear)*

---

### Conference paper

Di Nunzio, G. M., & Vezzani, F.

**Annotaterm: A Fragment-Based Approach for Annotating Discontinuous Named Entities and Terms.**

Proceedings of the 22nd Conference on Information and Research Science Connecting to Digital and Library Science (IRCDL 2026).

---

## Citation

If you use Annotaterm in your research, please cite the IJDL paper.

BibTeX will be added once the article is published.

---

## License

MIT License.

---

## Contact

Giorgio Maria Di Nunzio

Department of Information Engineering

University of Padua

https://github.com/gmdn
