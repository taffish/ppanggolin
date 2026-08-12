ppanggolin 2.3.1-r1

Purpose:
  Construct, partition, analyze, export, and visualize prokaryotic pangenomes.
  The primary interface is a headless CLI. Visualization output is standalone
  HTML opened on the host; this app has no browser service or desktop session.

Start here:
  taf-ppanggolin -- --help
  taf-ppanggolin -- --version
  taf-ppanggolin ppanggolin all --help

Run from annotated genomes:
  Create genomes.tsv with one genome per line and two tab-separated fields:
  a unique genome name, then its GFF/GBFF path. Gzip input is supported.
  taf-ppanggolin ppanggolin all \
    --anno genomes.tsv \
    --output ppanggolin-results \
    --cpu 8

Run from genome sequences:
  Create fastas.tsv with a unique genome name and FASTA path per line.
  taf-ppanggolin ppanggolin annotate \
    --fasta fastas.tsv \
    --output annotations \
    --kingdom bacteria \
    --cpu 8

Continue from an HDF5 pangenome:
  taf-ppanggolin ppanggolin info \
    --pangenome ppanggolin-results/pangenome.h5
  taf-ppanggolin ppanggolin rgp \
    --pangenome ppanggolin-results/pangenome.h5
  taf-ppanggolin ppanggolin draw \
    --pangenome ppanggolin-results/pangenome.h5 \
    --output plots --tile_plot --ucurve

Command mode:
  Use taf-ppanggolin ppanggolin <subcommand> ... for PPanGGOLiN subcommands.
  Words such as all, workflow, rgp, and draw are not standalone executables.
  Other packaged executables are available directly; for example:
  taf-ppanggolin mmseqs version
Major upstream interfaces:
  all, workflow, panrgp, panmodule, annotate, cluster, graph, partition,
  rarefaction, metadata, draw, write_pangenome, write_genomes,
  write_metadata, fasta, info, metrics, rgp, spot, module, rgp_cluster,
  msa, align, context, projection, and utils.

Packaged runtime tools:
  MMseqs2 15.6f452       protein-family clustering
  MAFFT 7.525            multiple-sequence alignment
  Aragorn 1.2.41         tRNA/tmRNA annotation
  Infernal 1.1.5         RNA covariance-model searches
  graph-tool 2.98 core   PPanGGOLiN graph objects and .gt export

Inputs and paths:
  Referenced files must be visible in the mounted working directory.
  Prefer paths without spaces. For a spaced path, pass literal single quotes:
    --anno "'data directory/genomes.tsv'" --output "'results directory'"

Outputs:
  pangenome.h5 is reusable PPanGGOLiN state. Depending on the command,
  output directories also contain TSV/CSV tables, GEXF/GT/JSON graphs,
  FASTA sequences, alignments, metadata, metrics, statistics, and logs.
  tile_plot.html, Ushaped_plot.html, and spot_figures/spot_*.html are
  standalone files; open them in a host browser. No web service or port starts.

Scale and scientific boundary:
  CPU and memory use grow with cohort and genome size; use --cpu where offered.
  Five genomes are enough for a tiny execution check, but upstream warns this
  is not robust partitioning. Use at least 15 diverse genomes for normal work.
  Smoke results do not establish biological correctness for a real cohort.

Runtime boundary:
  Native linux/amd64 and linux/arm64 are supported. No external database or
  network access is required. Upstream normally refuses populated output
  directories; use --force only when replacement is intentional.

Troubleshooting:
  For missing genomes, verify two tab-separated columns and visible paths.
  If local-file policy blocks HTML, serve the output directory over local HTTP.
  For command errors/options: taf-ppanggolin ppanggolin <subcommand> --help

Wrapper options:
  taf-ppanggolin --help       Show this TAFFISH help.
  taf-ppanggolin --version    Show the TAFFISH wrapper version.
  taf-ppanggolin --compile    Compile the TAFFISH wrapper.
  taf-ppanggolin -- --help    Pass an option to the default ppanggolin command.

Documentation: https://ppanggolin.readthedocs.io/en/latest/
