# PPanGGOLiN

`ppanggolin` packages PPanGGOLiN 2.3.2 for TAFFISH.

Package identity:

- name: `ppanggolin`
- command: `taf-ppanggolin`
- kind: `tool`
- version: `2.3.2-r1`
- image: `ghcr.io/taffish/ppanggolin:2.3.2-r1`
- TAFFISH packaging license: Apache-2.0
- upstream license: CeCILL-2.1
- upstream: <https://github.com/labgem/PPanGGOLiN>

## What This App Packages

PPanGGOLiN constructs and partitions prokaryotic pangenome graphs. This app
keeps the upstream `ppanggolin` CLI as its default command and packages the
external programs that the Python code invokes at runtime. The image is built
from the checksum-verified upstream 2.3.2 source tag without modifying upstream algorithms.

## Scope

This app supports the complete upstream 2.3.2 command tree, including:

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

- `ppanggolin`: upstream PPanGGOLiN 2.3.2 CLI with 25 analysis commands plus `utils`
- `mmseqs`: MMseqs2 15.6f452 for protein-family clustering
- `mafft`: MAFFT 7.525 for multiple-sequence alignment
- `aragorn`: Aragorn 1.2.41 retained as a standalone compatibility tool
- `cmscan` and `cmpress`: Infernal 1.1.5 tools for RNA annotation
- Python 3.12 with pinned NumPy, pandas, PyTables, Pyrodigal, NetworkX, SciPy,
  Plotly 5.24.1, Bokeh 3.3.4 (upstream requires <3.4), gmpy2, NEM statistics,
  and graph-tool runtime dependencies
- SHA256-pinned native wheels: gb-io 0.4.0, pyaragorn 0.3.0 (now used for
  tRNA/tmRNA annotation), and pyroaring 1.1.0

`graph-tool-base` supplies the top-level `Graph` API and `.gt` serialization
used by PPanGGOLiN. Unrelated generic graph-tool algorithm modules and the GTK
desktop stack are omitted; this is a PPanGGOLiN app, not a general graph-tool
environment. Real `.gt` generation is covered by smoke testing.

## Installation

After this candidate is published and indexed, install the exact release:

```console
taf update
taf install ppanggolin
taf install ppanggolin 2.3.2-r1
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

## Backends and HTML

Use the same analysis command with any backend:

```sh
TAFFISH_CONTAINER_BACKEND=docker taf-ppanggolin ppanggolin all --anno genomes.tsv --output docker-results --cpu 8
TAFFISH_CONTAINER_BACKEND=podman taf-ppanggolin ppanggolin all --anno genomes.tsv --output podman-results --cpu 8
TAFFISH_CONTAINER_BACKEND=apptainer taf-ppanggolin ppanggolin all --anno genomes.tsv --output apptainer-results --cpu 8
```

Apptainer needs Linux and a matching native architecture. On macOS use
Docker/Podman, or run on a Linux host via SSH. Open the generated HTML in a
host browser for every backend. For remote runs, copy HTML to the desktop.
If local-file policy blocks it, optionally serve on the host using
`python3 -m http.server 8765 --bind 127.0.0.1 --directory plots` and open
`http://127.0.0.1:8765/tile_plot.html`. For SSH use
`ssh -L 8765:127.0.0.1:8765 HOST`. Stop that host server with Ctrl-C.
This optional host server is not a containerized PPanGGOLiN service.

Hotspot plots retain upstream's fixed wide layout: scroll horizontally or
use Tab to reach the right-hand Bokeh toolbar. Genome label size/offset
controls can adjust clipped labels. Bokeh Save asks for a filename; embedded
viewers that block JavaScript prompts cannot export it, so open the same
HTML in a full browser. Plotly's PNG export does not use that prompt.
Some absent-cell hover values in upstream tile plots display null/NaN;
this is retained upstream presentation, not an inferred biological value.

Official extras, entry points and visualization documentation were reviewed.
There is no dedicated upstream desktop/server GUI. Proksee JSON is an
interchange format for the separate external web viewer, not a bundled
service. Use of that viewer needs a host browser/network and is outside
the offline image. Generated Plotly/Bokeh HTML is the included GUI surface.

## Resources, Databases, and Platform

The app supports native `linux/amd64` and `linux/arm64`. No external runtime
database or network connection is required. CPU and memory needs scale with
the number and size of genomes; pass `--cpu N` to commands that expose it and
give the container enough temporary and output storage. PPanGGOLiN accepts as
few as five genomes, but upstream warns that this is too small for robust
partitioning and recommends at least 15 diverse genomes for normal analyses.

### Built-in models and cohort sharing

The fixed upstream source includes about 18 MB of bacterial/archaeal Rfam
covariance models and pressed Infernal indexes. They remain at
`/opt/conda/lib/python3.12/site-packages/ppanggolin/annotate/rRNA_DB`.
Source hashes in `/opt/ppanggolin/share/provenance/rrna-models.sha256`
are checked against the installed files. The data are covered by
[Rfam's CC0 terms](https://docs.rfam.org/en/latest/#license).

These small fixed models are already shared read-only through the image/SIF.
No administrator download or runtime network access is needed. A separate
installer, discovery/override/disable switch and external model bind are
N/A: upstream uses the bundled models, selected by `--kingdom`. They are
not a rolling catalog and must not be replaced inside the immutable image.

Project genomes and derived `pangenome.h5` are a different resource type.
No universal cohort database can be selected/downloaded for users.
Suggested personal storage is
`~/.local/share/taffish/db/ppanggolin/COHORT/VERSION/`; administrator storage
is `/srv/taffish/db/ppanggolin/COHORT/VERSION/`. These are conventions, not
auto-discovery locations; always pass `--pangenome`.

An administrator can build and verify a cohort once in a staging directory,
retain genome versions/checksums/config/logs and a manifest, then atomically
rename the complete directory to a versioned destination. Give ordinary
users directory traverse/read and file read access, not shared write access.
Do not alter permissions recursively on unrelated data. Keep incomplete
staging data separate; prepare a new version rather than overwrite a shared
reference. An automated cohort installer is N/A because the inputs and
scientific cohort selection are project-specific.

For a prepared directory at `/srv/taffish/db/ppanggolin/cohort/v1`:

```sh
TAFFISH_CONTAINER_BACKEND=docker TAFFISH_DOCKER_RUN_ARGS='-v /srv/taffish/db/ppanggolin/cohort/v1:/reference:ro' taf-ppanggolin ppanggolin info --pangenome /reference/pangenome.h5
TAFFISH_CONTAINER_BACKEND=podman TAFFISH_PODMAN_RUN_ARGS='-v /srv/taffish/db/ppanggolin/cohort/v1:/reference:ro' taf-ppanggolin ppanggolin info --pangenome /reference/pangenome.h5
TAFFISH_CONTAINER_BACKEND=apptainer TAFFISH_APPTAINER_RUN_ARGS='--bind /srv/taffish/db/ppanggolin/cohort/v1:/reference:ro' taf-ppanggolin ppanggolin info --pangenome /reference/pangenome.h5
```

Use the same bind for `draw` and sequence export, with output in your own
working directory. State-changing commands (`cluster`, `partition`,
`rgp`, `spot`, `module`, `metadata`) require a private writable HDF5
copy. Never make the shared reference writable to run them. Combine per-call
engine environment options with existing site options rather than discard
them.

### Runtime write map

Installation, bundled models and notices are read-only; bytecode writes are
disabled. Intermediate files use fresh private `/tmp`, not mandatory home
or cache writes. Persistent output/logs and mutable HDF5 state belong in
actual user binds. Writable scratch does not make a shared reference writable.

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

The independent smoke entries cover runtime identity and all 26 help
interfaces; FASTA annotation through Pyrodigal, pyaragorn, and Infernal;
GenBank parsing through gb-io; annotated
genome workflow through MMseqs2 and NEM partitioning; graph-tool/GEXF/JSON/TSV
and nucleotide/protein FASTA exports; MAFFT MSA; standalone Plotly HTML; and a
complete `all` path through RGP, spot, and module prediction with a real Bokeh
hotspot HTML artifact and pyroaring-backed RGP clustering. GEXF is parsed
independently. The release evidence records actual platform/backend results;
the existence of smoke entries does not itself prove a run passed.

They verify packaging and a deterministic tiny execution path, not biological
correctness on production cohorts.

Build from the app root, matching the canonical Action:
`docker build -f docker/Dockerfile .`. Build-time tests are only stable
version/import/command checks; workflows and browser rendering are runtime
tests, not strict cross-architecture build assertions.

Original Conda notices are collected and hashed before cache/SDK pruning.
They remain under `/opt/ppanggolin/share/licenses/conda`, alongside upstream
CeCILL and pip distribution notices. Package/source/model inventories are
under `/opt/ppanggolin/share/provenance`. Build-only tools, headers, static
archives, manuals and caches are pruned; required runtime content remains.

## License and Citation

TAFFISH app packaging is Apache-2.0. PPanGGOLiN and its bundled upstream source
retain the CeCILL-2.1 terms included in the image. Runtime dependencies retain
their respective licenses.

For pangenome analyses cite Gautreau G. et al., “PPanGGOLiN: Depicting microbial
diversity via a partitioned pangenome graph,” *PLOS Computational Biology*
16(3):e1007732 (2020), <https://doi.org/10.1371/journal.pcbi.1007732>.

Upstream documentation: <https://ppanggolin.readthedocs.io/en/latest/>
