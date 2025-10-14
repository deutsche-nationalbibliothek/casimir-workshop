# Datasets

**DISCLAIMER**: The datasets contain english translations
  to provide accessability for non-german speakers. 
  Translations are machine-based using a `mistralai/Ministral-8B-Instruct-2410` LLM with the script 
  provided in `src/translate_file.py`. These are unofficial
  translations and may be partially incorrect. Please
  use with caution.

## Test-Set

**File name:** test-set_doc-ids-and-titles.csv
**Columns:**
  - `doc_id`: DNB Identifier for documents
  - `doc_title_ger`: German title of the document

**File name:** test-set_doc-ids-and-titles_w-translation.csv
**Columns:**
  - `doc_id`: DNB Identifier for documents
  - `doc_title_ger`: German title of the document
  - `doc_title_eng`: English translation of the document title (machine translated)

**File name:** test-set_subject-group-mapping.csv
**Columns:**
  - `doc_id`: DNB Identifier for documents
  - `sg`: Subject group code
  - `sg_label_ger`: German label for subject group
  - `sg_label_eng`: English label for subject group (machine translated)


**File name:** subject-groups-labels.csv
**Columns:**
  - `sg`: Subject group code
  - `sg_label_ger`: German label for subject group
  - `sg_label_eng`: English label for subject group (machine translated)

**File name:** test-set_gold-standard.csv
**Columns:**
  - `doc_id`: Identifier for documents
  - `label_id`: Identifier for label
  - `label_text`: Preferred label (German)

## Vocab

**File name:** gnd_pref-labels.csv
**Columns:**
  - `label_id`: Identifier for label
  - `label_text_ger`: Preferred label (German)

**File name:** gnd_pref-labels_w-translation.csv
**Columns:**
  - `label_id`: Identifier for label
  - `label_text_ger`: Preferred label (German)
  - `label_text_eng`: Preferred label (English translation, machine translated))

## Test Predictions

