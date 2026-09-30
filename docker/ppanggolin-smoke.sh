#!/bin/sh
set -eu
umask 077

mode="${1:-}"
tmp="$(mktemp -d '/tmp/taf-ppanggolin-smoke.XXXXXX')"
cleanup() {
  result=$?
  trap - EXIT HUP INT TERM
  if [ "$result" -ne 0 ]; then
    echo "FAIL ppanggolin-smoke mode=$mode exit=$result" >&2
    find "$tmp" -type f -name '*.log' -exec tail -n 30 {} \; >&2
  fi
  rm -rf "$tmp"
  exit "$result"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

make_fixture() {
  fixture="$tmp/fixture with spaces"
  ppanggolin-smoke-fixtures.py "$fixture"
}

make_workflow() {
  make_fixture
  workflow_out="$tmp/workflow output"
  ppanggolin workflow \
    --anno "$fixture/annotations.tsv" \
    --output "$workflow_out" \
    --cpu 1 \
    --disable_prog_bar
  test -s "$workflow_out/pangenome.h5"
}

check_html_is_local() {
  python - "$@" <<'PY'
from html.parser import HTMLParser
from pathlib import Path
import sys

class Resources(HTMLParser):
    def __init__(self):
        super().__init__()
        self.remote = []
    def handle_starttag(self, tag, attrs):
        values = dict(attrs)
        for key in ("src", "href"):
            value = values.get(key, "")
            if value.startswith(("http://", "https://", "//")):
                self.remote.append((tag, key, value))

for name in sys.argv[1:]:
    path = Path(name)
    text = path.read_text(encoding="utf-8")
    parser = Resources()
    parser.feed(text)
    if parser.remote:
        raise SystemExit(f"remote runtime resource in {path}: {parser.remote}")
    if len(text) < 10000:
        raise SystemExit(f"unexpectedly small HTML artifact: {path}")
PY
}

case "$mode" in
  identity)
    test "$(ppanggolin --version)" = "ppanggolin 2.3.2"
    python - <<'PY'
from importlib.metadata import version
import bokeh
import gmpy2
import graph_tool
import nem_stats
import networkx
import numpy
import pandas
import plotly
import ppanggolin
import pyrodigal
import pyaragorn
import gb_io
import pyroaring
import scipy
import tables

assert version("PPanGGOLiN") == "2.3.2"
assert version("numpy") == "1.26.4"
assert version("pandas") == "2.3.3"
assert version("plotly") == "5.24.1"
assert version("bokeh") == "3.3.4"
assert version("pyaragorn") == "0.3.0"
assert version("gb-io") == "0.4.0"
assert version("pyroaring") == "1.1.0"
assert graph_tool.__version__.split()[0] == "2.98"
PY
    mmseqs version | grep -Fx '15.6f452' >/dev/null
    mafft --version 2>&1 | grep -F 'v7.525' >/dev/null
    aragorn -h 2>&1 | grep -F 'ARAGORN v1.2.41' >/dev/null
    cmscan -h 2>&1 | grep -F 'INFERNAL 1.1.5' >/dev/null
    test -s /opt/ppanggolin/share/provenance/source.txt
    test -s /opt/ppanggolin/share/provenance/conda-packages.json
    python /opt/ppanggolin/build-support/conda-licenses.py verify
    model_dir="$(python -c 'from pathlib import Path; import ppanggolin; print(Path(ppanggolin.__file__).parent / "annotate/rRNA_DB")')"
    (cd "$model_dir" && sha256sum -c /opt/ppanggolin/share/provenance/rrna-models.sha256)
    ;;
  interfaces)
    ppanggolin --help >"$tmp/main-help.txt"
    grep -F 'Partitioned PanGenome Graph Of Linked Neighbors' "$tmp/main-help.txt" >/dev/null
    for subcommand in \
      all workflow panrgp panmodule annotate cluster graph partition rarefaction \
      metadata draw write_pangenome write_genomes write_metadata fasta info metrics \
      rgp spot module rgp_cluster msa align context projection utils; do
      ppanggolin "$subcommand" --help >"$tmp/$subcommand-help.txt"
      grep -F "usage: ppanggolin $subcommand" "$tmp/$subcommand-help.txt" >/dev/null
    done
    ;;
  annotation)
    make_fixture
    annotation_out="$tmp/annotation output"
    ppanggolin annotate \
      --fasta "$fixture/fastas.tsv" \
      --output "$annotation_out" \
      --kingdom bacteria \
      --cpu 1 \
      --disable_prog_bar
    test -s "$annotation_out/pangenome.h5"
    ppanggolin info --pangenome "$annotation_out/pangenome.h5" >"$tmp/annotation-info.txt"
    grep -F 'Genomes_Annotated: true' "$tmp/annotation-info.txt" >/dev/null
    grep -F 'Genes_with_Sequences: true' "$tmp/annotation-info.txt" >/dev/null
    grep -F 'Genomes: 5' "$tmp/annotation-info.txt" >/dev/null
    ;;
  workflow)
    make_workflow
    ppanggolin info --pangenome "$workflow_out/pangenome.h5" >"$tmp/workflow-info.txt"
    grep -F 'Genes_Clustered: true' "$tmp/workflow-info.txt" >/dev/null
    grep -F 'Pangenome_Partitioned: true' "$tmp/workflow-info.txt" >/dev/null
    grep -F 'Number_of_partitions:' "$tmp/workflow-info.txt" >/dev/null
    ;;
  genbank)
    make_fixture
    ppanggolin annotate --anno "$fixture/genbank.tsv" --output "$tmp/genbank output" --cpu 1 --disable_prog_bar
    ppanggolin info --pangenome "$tmp/genbank output/pangenome.h5" >"$tmp/genbank-info.txt"
    grep -F 'Genomes: 5' "$tmp/genbank-info.txt" >/dev/null
    grep -F 'Genes_with_Sequences: true' "$tmp/genbank-info.txt" >/dev/null
    ;;
  artifacts)
    make_workflow
    artifact_out="$tmp/artifact output"
    ppanggolin write_pangenome \
      --pangenome "$workflow_out/pangenome.h5" \
      --output "$artifact_out" \
      --gexf --light_gexf --gt --json --stats --families_tsv --partitions \
      --disable_prog_bar
    test -s "$artifact_out/pangenomeGraph.gexf"
    test -s "$artifact_out/pangenomeGraph_light.gexf"
    test -s "$artifact_out/pangenomeGraph.gt"
    test -s "$artifact_out/pangenomeGraph.json"
    test -s "$artifact_out/gene_families.tsv"
    python - "$artifact_out" <<'PY'
from pathlib import Path
import networkx as nx
import sys
for name in ("pangenomeGraph.gexf", "pangenomeGraph_light.gexf"):
    graph = nx.read_gexf(Path(sys.argv[1]) / name)
    assert graph.number_of_nodes() > 0 and graph.number_of_edges() > 0
PY
    ppanggolin fasta \
      --pangenome "$workflow_out/pangenome.h5" \
      --output "$tmp/fasta output" \
      --genes all --proteins all \
      --disable_prog_bar
    test -s "$tmp/fasta output/all_genes.fna"
    test -s "$tmp/fasta output/all_protein_genes.faa"
    ppanggolin msa \
      --pangenome "$workflow_out/pangenome.h5" \
      --output "$tmp/msa output" \
      --partition persistent \
      --cpu 1 \
      --disable_prog_bar
    test -s "$(find "$tmp/msa output/msa_persistent_protein" -type f -name '*.aln' -print -quit)"
    ppanggolin draw \
      --pangenome "$workflow_out/pangenome.h5" \
      --output "$tmp/visual output" \
      --tile_plot --ucurve \
      --disable_prog_bar
    test -s "$tmp/visual output/tile_plot.html"
    test -s "$tmp/visual output/Ushaped_plot.html"
    check_html_is_local \
      "$tmp/visual output/tile_plot.html" \
      "$tmp/visual output/Ushaped_plot.html"
    ;;
  all)
    make_fixture
    all_out="$tmp/all output"
    ppanggolin all \
      --anno "$fixture/annotations.tsv" \
      --output "$all_out" \
      --cpu 1 \
      --disable_prog_bar
    test -s "$all_out/pangenome.h5"
    test -s "$all_out/gene_families.tsv"
    test -s "$all_out/Ushaped_plot.html"
    test -s "$all_out/spot_figures/spot_0.html"
    check_html_is_local \
      "$all_out/Ushaped_plot.html" \
      "$all_out/spot_figures/spot_0.html"
    ppanggolin info --pangenome "$all_out/pangenome.h5" >"$tmp/all-info.txt"
    grep -F 'RGP_Predicted: true' "$tmp/all-info.txt" >/dev/null
    grep -F 'Spots_Predicted: true' "$tmp/all-info.txt" >/dev/null
    grep -F 'Modules_Predicted: true' "$tmp/all-info.txt" >/dev/null
    grep -F 'RGP: 5' "$tmp/all-info.txt" >/dev/null
    grep -F 'Spots: 1' "$tmp/all-info.txt" >/dev/null
    ppanggolin rgp_cluster --pangenome "$all_out/pangenome.h5" --output "$tmp/rgp clusters" --disable_prog_bar
    test -s "$tmp/rgp clusters/rgp_cluster.tsv"
    ;;
  *)
    echo "usage: ppanggolin-smoke {identity|interfaces|annotation|genbank|workflow|artifacts|all}" >&2
    exit 2
    ;;
esac
echo "PASS ppanggolin-smoke $mode"
