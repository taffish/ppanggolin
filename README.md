# PPanGGOLiN

`ppanggolin` packages PPanGGOLiN 2.3.1 for TAFFISH.

Package identity:

- name: `ppanggolin`
- command: `taf-ppanggolin`
- kind: `tool`
- version: `2.3.1-r1`
- image: `ghcr.io/taffish/ppanggolin:2.3.1-r1`
- TAFFISH packaging license: Apache-2.0
- upstream license: CeCILL-2.1
- upstream: <https://github.com/labgem/PPanGGOLiN>

## What This App Packages

PPanGGOLiN constructs and partitions prokaryotic pangenome graphs. This app
keeps the upstream `ppanggolin` CLI as its default command and packages the
external programs that the Python code invokes at runtime. The image is built
from the checksum-verified upstream 2.3.1 source tag rather than the older
2.3.0 Bioconda application package.

## Scope

This app supports the complete upstream 2.3.1 command tree, including:

- annotation, clustering, graph construction, partitioning, and the `workflow`
  and `all` pipelines
- RGP, spot, module, panRGP, panModule, context, projection, alignment, and
  rarefaction analyses
- HDF5, TSV/CSV, FASTA, GEXF, graph-tool, JSON, MSA, metadata, metric, and
  standalone interactive HTML outputs

This app does not:

- provide reference genomes or decide which genomes form a scientifically
  representative cohort
- turn the generated HTML files into a server or noVNC session; open those
  files with a browser on the host
- replace production-data validation or interpretation of biological results

## Container Contents

- `ppanggolin`: upstream PPanGGOLiN 2.3.1 CLI with all 25 subcommands
- `mmseqs`: MMseqs2 15.6f452 for protein-family clustering
- `mafft`: MAFFT 7.525 for multiple-sequence alignment
- `aragorn`: Aragorn 1.2.41 for tRNA/tmRNA annotation
- `cmscan` and `cmpress`: Infernal 1.1.5 tools for RNA annotation
- Python 3.12 with pinned NumPy, pandas, PyTables, Pyrodigal, NetworkX, SciPy,
  Plotly, Bokeh, gmpy2, NEM statistics, and graph-tool runtime dependencies

`graph-tool-base` supplies the top-level `Graph` API and `.gt` serialization
used by PPanGGOLiN. Unrelated generic graph-tool algorithm modules and the GTK
desktop stack are omitted; this is a PPanGGOLiN app, not a general graph-tool
environment. Real `.gt` generation is covered by smoke testing.

## Installation

After refreshing the TAFFISH index, install the current release or this exact
immutable package version:

```console
taf update
taf install ppanggolin
taf install ppanggolin 2.3.1-r1
```

## Usage

Read upstream help or identity through the default command:

```sh
taf-ppanggolin -- --help
taf-ppanggolin -- --version
```

Run a complete analysis from existing GFF3 or GenBank annotations:

```sh
taf-ppanggolin ppanggolin all \
  --anno genomes.tsv \
  --output ppanggolin-results \
  --cpu 8
```

Annotate genome FASTA files before later stages:

```sh
taf-ppanggolin ppanggolin annotate \
  --fasta fastas.tsv \
  --output annotations \
  --kingdom bacteria \
  --cpu 8
```

Continue from an existing PPanGGOLiN HDF5 file:

```sh
taf-ppanggolin ppanggolin rgp \
  --pangenome ppanggolin-results/pangenome.h5

taf-ppanggolin ppanggolin draw \
  --pangenome ppanggolin-results/pangenome.h5 \
  --output plots \
  --tile_plot --ucurve
```

## Command Mode

TAFFISH automatic command mode exposes every executable in the image. For
example, `taf-ppanggolin mmseqs version` runs the packaged MMseqs2 executable.

Because words such as `all` and `workflow` are PPanGGOLiN subcommands rather
than standalone executables, use the explicit form
`taf-ppanggolin ppanggolin all ...`. Use `--` for option-leading arguments sent
to the default `ppanggolin` command.

## Inputs

| Input | Meaning | Notes |
| --- | --- | --- |
| `--anno genomes.tsv` | Annotated genomes | Two tab-separated columns per line: unique genome name and GFF/GBFF path; gzip is supported |
| `--fasta fastas.tsv` | Genome sequences | Two tab-separated columns per line: unique genome name and FASTA path; gzip is supported |
| `--pangenome pangenome.h5` | Existing PPanGGOLiN state | Used by downstream analysis, export, drawing, and projection commands |
| YAML config | Command arguments | Pass with the upstream `--config` option where supported |

Input paths are evaluated inside the TAFFISH-mounted working directory. Keep
the list file and referenced genomes under mounted paths. Prefer paths without
spaces. Current TAFFISH automatic command mode reconstructs delegated argv as
a shell command, so ordinary shell quoting alone does not preserve a spaced
argument. When needed, include literal single quotes inside the shell argument:

```sh
taf-ppanggolin ppanggolin all \
  --anno "'data directory/genomes.tsv'" \
  --output "'results directory'" \
  --cpu 8
```

This exact literal-quote form is covered by the generated-wrapper regression;
direct commands inside the container use ordinary shell quoting.

## Output Notes

Most analysis commands create an output directory containing `pangenome.h5`
plus command-specific tables, graphs, alignments, sequences, and logs. The HDF5
file is the reusable state for later PPanGGOLiN subcommands. `draw`, `workflow`,
and `all` may create `tile_plot.html`, `Ushaped_plot.html`, and hotspot files
such as `spot_figures/spot_0.html`; these embed their Plotly or Bokeh runtime
and data and do not require a PPanGGOLiN service or port. If a browser's local
file policy blocks the page, serve the output directory with a local HTTP
server; PPanGGOLiN itself still has no long-running browser backend.

Upstream normally refuses to overwrite a populated output directory. Use its
`--force` option only when replacing those results is intentional.

## Resources, Databases, and Platform

The app supports native `linux/amd64` and `linux/arm64`. No external runtime
database or network connection is required. CPU and memory needs scale with
the number and size of genomes; pass `--cpu N` to commands that expose it and
give the container enough temporary and output storage. PPanGGOLiN accepts as
few as five genomes, but upstream warns that this is too small for robust
partitioning and recommends at least 15 diverse genomes for normal analyses.

## Boundaries and Troubleshooting

- An empty or malformed list file is an input error; verify exactly two
  tab-separated columns and paths visible inside the working directory.
- Five-genome smoke fixtures prove execution, not statistical robustness.
- Generated HTML is a local file artifact. There is no `--host`, `--port`,
  background server, login, SSH, or container-side browser.
- If a subcommand is mistaken for an executable, add the explicit upstream
  command: `taf-ppanggolin ppanggolin <subcommand> ...`.
- For authoritative options and file formats, use
  `taf-ppanggolin ppanggolin <subcommand> --help` and the upstream manual.

## Testing

The independent smoke entries cover runtime identity and all 25 help
interfaces; FASTA annotation through Pyrodigal, Aragorn, and Infernal; annotated
genome workflow through MMseqs2 and NEM partitioning; graph-tool/GEXF/JSON/TSV
and nucleotide/protein FASTA exports; MAFFT MSA; standalone Plotly HTML; and a
complete `all` path through RGP, spot, and module prediction with a real Bokeh
hotspot HTML artifact. Tests run in fresh network-disabled containers on both
declared architectures.

They verify packaging and a deterministic tiny execution path, not biological
correctness on production cohorts.

## License and Citation

TAFFISH app packaging is Apache-2.0. PPanGGOLiN and its bundled upstream source
retain the CeCILL-2.1 terms included in the image. Runtime dependencies retain
their respective licenses.

For pangenome analyses cite Gautreau G. et al., “PPanGGOLiN: Depicting microbial
diversity via a partitioned pangenome graph,” *PLOS Computational Biology*
16(3):e1007732 (2020), <https://doi.org/10.1371/journal.pcbi.1007732>.

Upstream documentation: <https://ppanggolin.readthedocs.io/en/latest/>
