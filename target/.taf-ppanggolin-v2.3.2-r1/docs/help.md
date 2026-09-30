taf-ppanggolin 2.3.2-r1

Build, partition and explore prokaryotic pangenomes with PPanGGOLiN.
Headless CLI with standalone interactive HTML results; no web service.

Quick start:
  taf-ppanggolin -- --help
  taf-ppanggolin -- --version
  taf-ppanggolin ppanggolin all --help

Annotated genomes:
  genomes.tsv: unique genome name and GFF3/GenBank path per tab-separated row.
  Gzip input is supported.
  taf-ppanggolin ppanggolin all --anno genomes.tsv --output results --cpu 8

Genome FASTA:
  fastas.tsv: unique genome name and FASTA path per tab-separated row.
  taf-ppanggolin ppanggolin annotate --fasta fastas.tsv \
    --output annotations --kingdom bacteria --cpu 8
  Use --kingdom archaea for archaeal genomes. Required rRNA models are built
  into the image; no model download or administrator setup is needed.

Reuse results:
  taf-ppanggolin ppanggolin info --pangenome results/pangenome.h5
  taf-ppanggolin ppanggolin draw --pangenome results/pangenome.h5 \
    --output plots --tile_plot --ucurve
  taf-ppanggolin ppanggolin fasta --pangenome results/pangenome.h5 \
    --output sequences --genes all --proteins all

Choose a backend:
  TAFFISH_CONTAINER_BACKEND=docker taf-ppanggolin ppanggolin info --pangenome results/pangenome.h5
  TAFFISH_CONTAINER_BACKEND=podman taf-ppanggolin ppanggolin info --pangenome results/pangenome.h5
  TAFFISH_CONTAINER_BACKEND=apptainer taf-ppanggolin ppanggolin info --pangenome results/pangenome.h5
  Apptainer needs Linux and a matching native architecture; on macOS use
  Docker/Podman or run on a Linux host via SSH.

Shared read-only pangenome:
  Ask your administrator for the prepared cohort directory. Replace /DATA
  below with its absolute path (or your personal prepared directory).
  TAFFISH_CONTAINER_BACKEND=docker TAFFISH_DOCKER_RUN_ARGS='-v /DATA:/reference:ro' taf-ppanggolin ppanggolin info --pangenome /reference/pangenome.h5
  TAFFISH_CONTAINER_BACKEND=podman TAFFISH_PODMAN_RUN_ARGS='-v /DATA:/reference:ro' taf-ppanggolin ppanggolin info --pangenome /reference/pangenome.h5
  TAFFISH_CONTAINER_BACKEND=apptainer TAFFISH_APPTAINER_RUN_ARGS='--bind /DATA:/reference:ro' taf-ppanggolin ppanggolin info --pangenome /reference/pangenome.h5
  Use the same bind for draw/export, writing results in your own directory.
  State-changing steps (cluster, partition, rgp, spot, module, metadata)
  need a private writable copy, not a writable shared reference.
  Combine these per-call options with existing site engine options.

View interactive results:
  Open plots/tile_plot.html, plots/Ushaped_plot.html or
  results/spot_figures/spot_0.html in your host browser, for every backend.
  These are standalone files; no PPanGGOLiN server or container port starts.
  Wide hotspot plots can be scrolled; use Tab to reach the right toolbar.
  Use a full browser for PNG export if an embedded viewer blocks dialogs.
  For remote runs, copy the HTML to your desktop.
  If local-file policy blocks it, serve on the host:
    python3 -m http.server 8765 --bind 127.0.0.1 --directory plots
  Open http://127.0.0.1:8765/tile_plot.html; stop the host server with Ctrl-C.
  For a remote host, forward it with: ssh -L 8765:127.0.0.1:8765 HOST

Paths and command mode:
  Keep input lists and referenced files under mounted paths.
  Use taf-ppanggolin ppanggolin SUBCOMMAND ...; subcommands are not programs.
  A packaged helper can run directly: taf-ppanggolin mmseqs version
  For spaced paths include literal single quotes:
    --anno "'data directory/genomes.tsv'" --output "'results directory'"

Troubleshooting:
  Check tab-separated list columns and visible paths if a genome is missing.
  Use --cpu where offered and provide enough temporary/output storage.
  Existing output directories are normally refused; use --force only when
  replacement is intentional. Use at least 15 diverse genomes for normal
  partitioning; very small cohorts are not statistically robust.

Wrapper options:
  --help: this help; --version: wrapper identity; --compile: compile wrapper.
  -- --help passes the option to upstream PPanGGOLiN.
  taf-ppanggolin ppanggolin SUBCOMMAND --help shows upstream options.

Documentation: https://ppanggolin.readthedocs.io/en/latest/
