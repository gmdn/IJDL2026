# Annotaterm

**Annotaterm** is a lightweight web-based annotation tool for marking **discontinuous named entities** and **multi-word terms** in text corpora.

The tool is designed for cases where relevant entities or terms are not represented by a single contiguous text span, such as overlapping, coordinated, or fragmented expressions. Instead of forcing annotators to use workarounds, Annotaterm adopts a **fragment-based annotation model**, where each selected textual fragment is stored separately and linked to a shared annotation identifier.

Annotaterm is implemented in **R Shiny** and is intended to support terminology annotation, named entity recognition, corpus curation, and the creation of reusable semantic resources for digital library and NLP workflows.

Main features include:

- annotation of simple and composite terms/entities;
- support for discontinuous and non-adjacent textual fragments;
- fragment-level representation with start and end offsets;
- lightweight deployment through R Shiny;
- export-oriented data model for downstream analysis and interoperability.

Annotaterm was developed as a research prototype to explore annotation models and interfaces for discontinuous terminological and named-entity annotation.
