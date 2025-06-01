# meanalyzeR
An R toolkit for semanticists to extract meaning-related contrasts from interlinear corpora using WRIML.

---

## Quick overview of meanalyseR

**meanalyseR** is an R package designed for field linguists and semanticists working with large corpora of interlinear data. Its main purpose is to help researchers **automatically extract key semantic properties** of morphemes or expressions across a corpus, enabling **faster diagnostics** and **semantic generalizations**.

This tool is especially useful when dealing with understudied languages, where annotated data often come from manually constructed questionnaires and follow-up field interviews.

---

## What Does meanalyseR Do?

meanalyseR takes as input a **corpus of interlinear examples** marked using a simplified custom markup language called **WRIML** (WRIting Markup Language). It currently provides tools for:

- Grouping data by **minimal pairs** based on their gloss lines (function: `sort_by_minimal_pairs()`)
- Grouping data by **contextual variants** based on their context prompts (function: `sort_by_context_variants()`)

These automatic groupings are useful to identify subtle meaning contrasts across examples and track morpheme distribution across contexts.

---

## Input Format: WRIML

Your corpus must be written in plain text (`.txt` or `.wri`) using WRIML, a markup system where each example is wrapped in `^data ... _data` blocks and annotated with the following tags (tags are **always preceded and followed by spaces**):

Example:

```wriml
 ^data 
 ^ct This is the context. _ct 
 ^tx Nko _tx 
 ^mb N ko _mb 
 ^gl 1SG say _gl 
 ^tr "I say" _tr 
 ^rf citem_001 _rf 
 _data 

 ^data 
 ^ct This is the context. _ct 
 ^tx Nko _tx 
 ^mb N ko _mb 
 ^gl 1SG say _gl 
 ^tr "I say" _tr 
 ^rf citem_001 _rf  _data 
```


**Important tag guidelines:**

- Tags must be properly spaced (e.g., `" ^gl "` not `"^gl"`).
- No overlapping tags (nested tags must have space between them).
- Tags currently used: `ct`, `tx`, `mb`, `gl`, `tr`, `rf`, `id`, `aj`.

---

## How to Use meanalyseR in a Project

### 1. Install the package locally

Clone or download the package folder, then install it from the command line or R console:

```r
# Replace with the actual path to your folder
devtools::install_local("path/to/meanalyseR")
``` 

You may need to install devtools first:

```r
install.packages("devtools")
```

## 2. Prepare your corpus
- Create a .txt or .wri file containing your WRIML-annotated data.
- Make sure your tags and indentation follow WRIML format strictly (see above).

## 3. Use the analysis functions
```r
library(meanalyseR)

# Sort by gloss-based minimal pairs
sort_by_minimal_pairs("path/to/your/corpus.txt")

# Sort by contextual variants
sort_by_context_variants("path/to/your/corpus.txt")
```

Each function will generate an output file named after the input file, with suffix -sorted and the same file extension (e.g., corpus-sorted.txt).

## Roadmap
Planned features for upcoming versions:

- Gloss search and filter by morph target (e.g., extract all data where gl contains a particular morpheme)
- Property-to-morpheme mapping (e.g., identify which morphemes are used in definite contexts)
- Visualization tools for semantic distribution
- Export results in spreadsheet format

## Why Use meanalyseR?
Semantic fieldwork is time-consuming and complex. meanalyseR helps you focus your cognitive effort on semantic interpretation, not on repetitive manual sorting or searching. It’s designed to make meaning analysis more scalable, replicable, and structured, especially for work on under-documented languages.

## Contributions & Feedback
You are welcome to open issues, suggest features, or contribute to the code. Let's make semantic diagnostics faster and more reliable for everyone in the linguistic community.

