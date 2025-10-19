---
title: "Dataset Descriptions"
format: html
author: "Maximilian Kähler, DNB"
toc: true
---

**DISCLAIMER**: The datasets contain english translations
  to provide accessability for non-german speakers. 
  Translations are machine-based using a `mistralai/Ministral-8B-Instruct-2410` 
  LLM with the script provided in `src/translate_file.py`. 
  These are unofficial translations and may be partially incorrect. Please
  use with caution.
  
All `doc_id` and `label_id` values correspond to identifiers from the 
[German National Library (DNB)](https://www.dnb.de). All metadata from the
DNB's catalogue is provided under a 
[Creative Commons Zero](https://creativecommons.org/publicdomain/zero/1.0/deed.de)
LICENSE and may be freely used. 
Each intentifier can be resolved using the DNB's catalogue, by prefixing
`https://d-nb.info/`, e.g. `doc_id = 1122545479` can be resolved to
<https://d-nb.info/1122545479>, to access the full bilbiographic record.

## Test-Set

The test-set used in this tutorial consists of 8415 records from the DNB's
catalogue. Each record is annotated with one or more subject groups from the
DNB's subject group system ("Sachgruppen der deutschen Nationalbibliografie"),
which is essentialy equal to the DDC's highest order classification.
The test-set is chosen to contain an approximately equal number of records
from 18 selected scientific subject groups.

### Document Titles

**File name:** `test-set_doc-ids-and-titles_w-translation.csv`

**Description:** Document titles in German and English for the test-set.

**Columns:**

  - `doc_id`: DNB Identifier for documents
  - `doc_title_ger`: German title of the document
  - `doc_title_eng`: English translation of the document title (machine translated)

### Subject Group Mapping and Group Labels

**File name:** `test-set_subject-group-mapping.csv`

**Description:** Mapping of documents to subject groups in the test-set.

**Columns:**

  - `doc_id`: DNB Identifier for documents
  - `sg`: Subject group code
  - `sg_label_ger`: German label for subject group
  - `sg_label_eng`: English label for subject group (machine translated)


**File name:** `subject-groups-labels.csv`

**Description:** Subject group codes and labels.

**Columns:**

  - `sg`: Subject group code
  - `sg_label_ger`: German label for subject group
  - `sg_label_eng`: English label for subject group (machine translated)

### Gold Standard GND Labels

**File name:** `test-set_gold-standard.csv`

**Description:** Gold standard GND labels for documents in the test-set.

**Columns:**

  - `doc_id`: Identifier for documents
  - `label_id`: Identifier for label
  - `label_text`: Preferred label (German)

## The Integrated Authority File (GND)

Records in the test-set are indexed using the vocabulary of the 
Integrated Authority File [Gemeinsame Normdatei, GND](gnd.network).
The subject terms used in this tutorial are a subset of 314 065 terms from
the GND vocabulary. 

**File name:** `gnd_pref-labels_w-translation.csv`

**Description:** Preferred labels from the GND vocabulary with English 
 AI-generated-translations.

**Columns:**

  - `label_id`: Identifier for label
  - `label_text_ger`: Preferred label (German)
  - `label_text_eng`: Preferred label (English translation, machine translated))


### GND entity types

There are 6 different entity types of GND terms:

  * subject headings (Schlagworte)
  * geographic headings (Geografika)
  * corporate bodies (Körperschaften)
  * conferences (Konferenzen)
  * persons (Personen)
  * works (Werktitel)
  

| label_entitytype_eng         |    n |
|-----------------------------|------|
| conference                  | 16369|
| corporation                 |200025|
| geographic name            |263763|
| person (individualized)     |564305|
| subject term                |198947|
| works                        |142370|

The mapping to the GND entity types is provided in the following file:

**File name:** `gnd_entitytypes.csv`

**Description:** GND entity types for labels in the GND vocabulary.

**Columns:**

  - `label_id`: Identifier for label
  - `label_entitytype_ger`: GND entity type (German)
  - `label_entitytype_eng`: GND entity type (English translation)

### GND frequency distribution

Many of the algorithms tested in this repository are supervised extreme
multi label classification methods, which require training data. Their 
repective performance may often depend on the number of available training
records per GND label. Here, we provide not the full training dataset, but only
the frequency distribution of GND terms in the training data.

**File name:** `gnd_frequency-distribution.csv`

**Description:** Frequency distribution of GND labels in the training data.

**Columns:**

  - `label_id`: Identifier for label
  - `label_freq`: Number of training records annotated with the label


## Test Predictions

Predictions for the test-set are provided from six different indexing algorithms,
which are not disclose purposefully, to allow for unbiased evaluation.
The algorithms are referred to as `method_A` to `method_F`. Each of the
predictions datasets follows the same format:

**File name:** `test-set_predictions_method_*.csv`

**Description:** Predicted GND labels for documents in the test-set using method X.

**Columns:**

  - `doc_id`: Identifier for documents
  - `label_id`: Identifier for the GND label
  - `score`: Confidence score for the prediction (higher is better)