# IJDL2026 Annotaterm

> **Research use only. Not a medical device.**
> This software was developed in the HEREDITARY project as a research prototype. It has not been assessed or certified under the EU Medical Device Regulation (EU) 2017/745. It must not be used to diagnose, treat, monitor or make any other decision about individual patients.

## 1. Overview

| Field | Value |
|---|---|
| Name | Annotaterm — IJDL2026 release |
| Version | v1.0 |
| Type | R Shiny annotation software and coded usability-survey data; no trained model |
| Owner partner and contact | University of Padua (UNIPD); Giorgio Maria Di Nunzio, giorgiomaria.dinunzio@unipd.it |
| License | Apache-2.0 |
| Repository and DOI | https://github.com/gmdn/IJDL2026 ; article DOI: https://doi.org/10.1007/s00799-026-00447-x |
| Release date | Software release date to confirm; article published 1 August 2026 |
| Related task or deliverable | HEREDITARY; misuse assessment contributes to D9.1. Technical WP3. |
| How to cite | Di Nunzio, G.M., Vezzani, F. (2026). *A fragment-based model and annotation environment for discontinuous and overlapping terms*. International Journal on Digital Libraries 27, 11. https://doi.org/10.1007/s00799-026-00447-x |

The inspected snapshot contains `Annotaterm/global.R`, `ui.R`, `server.R`, project/documentation files and two survey CSVs. No trained weights, linkage key, credentials or deployment configuration were found in the supplied files. This review does not cover repository history or an independently hosted service.

## 2. Intended use

**Primary intended use.** Manual annotation of contiguous, discontinuous, overlapping and nested expressions for terminology research and digital-library curation.

**Intended users.** Researchers, developers, terminology specialists, annotators and students.

**Out-of-scope uses.** This release must not be used for:
- clinical diagnosis, prognosis or treatment of individual patients;
- decisions about individuals, including employment, insurance or access to care;
- re-identification, surveillance, unauthorized processing of personal data, or profiling;
- entering personal, patient or confidential data into an unassessed deployment;
- treating annotations as independently verified facts or validated clinical labels;
- populations, data types or settings beyond those evaluated without separate validation.

These are research-scope and responsible-use statements. They do not amend the applicable license.

## 3. Data provenance

| Dataset | Source partner | Type | Population or corpus | Ethics approval or access conditions |
|---|---|---|---|---|
| Built-in demonstration text (`Annotaterm/global.R`) | UNIPD software authors | Authored illustrative text | Explains annotation using examples such as waste management; no personal information found. Population demographics: N/A. | Distributed with the source; no external source dataset identified in the code |
| Usability questionnaire (`survey/questions.csv`, `survey/answers.csv`) | UNIPD research study | Coded respondent-level evaluation records, described as anonymized by the survey README | 14 rows, student codes `s1`–`s14`; 10 questions including experience, task completion, six ratings and two free-text answers. No age/sex fields. | Article describes participant-consent conditions; the supplied files do not contain consent records or an ethics-approval reference. Owner confirmation remains necessary. |

**Personal information.** No direct names, email addresses or linkage key were found in the survey files. Respondent codes and individual free-text answers are retained. Removing direct identifiers alone does not demonstrate that the small cohort cannot be indirectly identified. Accordingly, this card makes no blanket claim that all released records are fully anonymous or free of identifiers. Check indirect identification and consent coverage before further redistribution; aggregate or redact detail if needed.

**Input handling.** The Shiny host processes the input text, selections, labels and imported JSON. Annotation and composite-builder state are created inside the server function and held in per-session reactive values. JSON import reads an uploaded temporary file; CSV and JSON download handlers write files for download. No application database, telemetry, input logger or explicit third-party API call was found in the supplied source. Hosting logs, temporary-file cleanup, backups, retention and server location remain deployment-dependent; no deletion guarantee is claimed.

## 4. Method

- **Algorithm or architecture.** Manual R Shiny client–server workflow. Fragments, labels and character offsets are grouped under annotation identifiers, shown in tables and a highlighted preview, and exported as CSV or JSON; JSON import is implemented.
- **Training setting.** Not applicable. The fragment-based model is an annotation representation. No learned model, training procedure or model-inference call is included.
- **Privacy techniques.** Survey documentation states that names and emails were not collected. Coded records remain; no formal anonymity test, differential privacy or secure aggregation is provided. Session-specific state limits application-level sharing but does not establish host security or anonymity.

## 5. Performance

- **Evaluation data.** Questionnaire responses from 14 participants in `survey/answers.csv`.
- **Metrics and results.** Means recomputed from the supplied CSV: overall suitability (Q8), 4.36/5; overlapping/nested annotation support (Q6), 4.00/5. These are usability ratings, not annotation accuracy or clinical effectiveness.
- **Results by subgroup.** No demographic subgroup performance is available. No controlled speed, accuracy or inter-annotator-agreement benchmark is included.

## 6. Known limitations and risks

- **Generalizability.** A small, terminology-oriented student sample does not establish suitability across user populations, languages or domains.
- **Known biases and confounders.** Prior annotation experience, task familiarity and device differences may influence feedback. No clinical validity is established.
- **Failure modes.** Source text remains editable after annotations are created; no text-locking or automatic offset-invalidation guard was found. Imported JSON is read without comprehensive schema/offset validation. Incorrect labels, stale offsets or malformed imports can make results unreliable. Use trusted imports, keep source text stable and inspect exports.
- **Privacy risks.** Individual survey responses may be indirectly linkable. Input text and import/export files may contain information entered by users. The source implements no application authentication; any external access controls and infrastructure retention must be verified before hosting.
- **Model privacy tests.** Membership-inference and model-inversion testing are not applicable because no trained model is included. Reassess if learned components are added.
- **Review limits.** Source/data inspection and common credential-pattern checks on 3 November 2026 found no embedded credentials or direct personal identifiers. This was a retrospective snapshot review, not evidence of a pre-release scan or a formal security/anonymity audit.

## 7. Responsible use and reporting

- **Terms of use.** Apache-2.0 license. Preserve applicable notices and verify consent/reuse conditions for the survey records; the article's publication license does not settle software or data terms.
- **Deployment.** Use non-personal research text. Verify the Shiny host's location, access permissions, logs, uploaded/downloaded temporary files, backups and retention/deletion policy. Keep imports and exports in controlled locations. These are recommended deployment checks, not a claim that safeguards have been implemented.
- **Expert review.** Check labels, fragments, offsets and source context before downstream use. Delete/clear controls remove annotation state, not necessarily uploaded temporary files, infrastructure logs or previously downloaded exports.
- **Contact for misuse or vulnerability reports.** giorgiomaria.dinunzio@unipd.it.

## 8. Acknowledgement

Partially funded by the European Union under grant agreement No 101137074 (HEREDITARY). Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Health and Digital Executive Agency (HaDEA). Neither the European Union nor the granting authority can be held responsible for them.
