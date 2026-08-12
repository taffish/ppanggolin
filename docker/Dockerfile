# syntax=docker/dockerfile:1.7

ARG MICROMAMBA_IMAGE=mambaorg/micromamba:1.5.10-bookworm-slim@sha256:e3797091302382ea841498bc93a7b0a50f7c1448333d5e946d2d1608d0c5f43d

FROM ${MICROMAMBA_IMAGE} AS builder

ARG PPANGGOLIN_VERSION=2.3.1
ARG PPANGGOLIN_COMMIT=5492c4c6572e6166b2a821c7941aa6a0068ece37
ARG PPANGGOLIN_SOURCE_SHA256=e23ae74c78b52875d97dd0b894e7080f198f03b8762a30ae5e2e8ec7effcca29
ARG TARGETARCH

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get -o Acquire::Retries=10 update \
 && apt-get -o Acquire::Retries=10 install -y --no-install-recommends \
      ca-certificates \
      curl \
      gcc \
      libc6-dev \
 && mkdir -p /tmp/build /opt/ppanggolin/share/doc/ppanggolin \
      /opt/ppanggolin/share/licenses/ppanggolin \
      /opt/ppanggolin/share/provenance \
 && chown -R mambauser:mambauser /tmp/build /opt/ppanggolin

USER mambauser
WORKDIR /tmp/build

ENV MAMBA_DOWNLOAD_THREADS=1 \
    MAMBA_EXTRACT_THREADS=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN set -eux; \
    curl --retry 10 --retry-delay 3 --retry-all-errors -fsSL \
      "https://codeload.github.com/labgem/PPanGGOLiN/tar.gz/refs/tags/${PPANGGOLIN_VERSION}" \
      -o ppanggolin.tar.gz; \
    echo "${PPANGGOLIN_SOURCE_SHA256}  ppanggolin.tar.gz" | sha256sum -c -; \
    mkdir source; \
    tar -xzf ppanggolin.tar.gz -C source --strip-components=1; \
    test "$(cat source/VERSION)" = "${PPANGGOLIN_VERSION}"; \
    cp source/LICENSE.txt /opt/ppanggolin/share/licenses/ppanggolin/LICENSE.txt; \
    cp source/README.md /opt/ppanggolin/share/doc/ppanggolin/README.upstream.md

RUN set -eux; \
    for attempt in 1 2 3; do \
      if micromamba install -y -n base -c conda-forge -c bioconda \
          "python=3.12" \
          "numpy=1.26.4" \
          "pandas=2.3.3" \
          "tqdm=4.67.1" \
          "pytables=3.10.2" \
          "pyrodigal=3.7.1" \
          "networkx=3.4.2" \
          "scipy=1.16.3" \
          "plotly=5.24.1" \
          "gmpy2=2.2.1" \
          "bokeh=3.8.1" \
          "graph-tool-base=2.98" \
          "mmseqs2=15.6f452" \
          "infernal=1.1.5" \
          "aragorn=1.2.41" \
          "mafft=7.525" \
          "cython=3.2.9" \
          pip \
          setuptools; then \
        break; \
      fi; \
      test "${attempt}" != 3; \
      micromamba clean --all --yes || true; \
      rm -rf /opt/conda/pkgs/*; \
      sleep 10; \
    done

RUN set -eux; \
    /opt/conda/bin/python -m pip install --no-cache-dir --no-deps --no-build-isolation ./source; \
    micromamba list -n base --json > /opt/ppanggolin/share/provenance/conda-packages.json; \
    { \
      printf 'upstream_repo=https://github.com/labgem/PPanGGOLiN\n'; \
      printf 'upstream_tag=%s\n' "${PPANGGOLIN_VERSION}"; \
      printf 'upstream_commit=%s\n' "${PPANGGOLIN_COMMIT}"; \
      printf 'source_sha256=%s\n' "${PPANGGOLIN_SOURCE_SHA256}"; \
      printf 'target_arch=%s\n' "${TARGETARCH}"; \
      printf 'installation=checksum-verified upstream source with pinned Conda runtime dependencies\n'; \
      printf 'runtime_pruning=pip, cython, and setuptools frontends; headers, static archives, Conda metadata, Jupyter extensions, manuals, docs, caches, and bytecode\n'; \
      printf 'graph_tool_scope=top-level Graph API and gt_io required by PPanGGOLiN .gt export; unrelated generic algorithm modules omitted\n'; \
    } > /opt/ppanggolin/share/provenance/source.txt; \
    micromamba clean --all --yes; \
    rm -rf \
      /opt/conda/conda-meta \
      /opt/conda/include \
      /opt/conda/man \
      /opt/conda/pkgs/* \
      /opt/conda/share/doc \
      /opt/conda/share/info \
      /opt/conda/share/jupyter \
      /opt/conda/share/man \
      /tmp/build/*; \
    rm -rf \
      /opt/conda/lib/python3.12/site-packages/Cython \
      /opt/conda/lib/python3.12/site-packages/Cython-*.dist-info \
      /opt/conda/lib/python3.12/site-packages/_distutils_hack \
      /opt/conda/lib/python3.12/site-packages/cython.py \
      /opt/conda/lib/python3.12/site-packages/distutils-precedence.pth \
      /opt/conda/lib/python3.12/site-packages/jupyterlab_plotly \
      /opt/conda/lib/python3.12/site-packages/pip \
      /opt/conda/lib/python3.12/site-packages/pip-*.dist-info \
      /opt/conda/lib/python3.12/site-packages/pkg_resources \
      /opt/conda/lib/python3.12/site-packages/setuptools \
      /opt/conda/lib/python3.12/site-packages/setuptools-*.dist-info \
      /opt/conda/lib/python3.12/ensurepip; \
    rm -rf \
      /opt/conda/lib/python3.12/site-packages/graph_tool/all.py \
      /opt/conda/lib/python3.12/site-packages/graph_tool/centrality \
      /opt/conda/lib/python3.12/site-packages/graph_tool/clustering \
      /opt/conda/lib/python3.12/site-packages/graph_tool/collection \
      /opt/conda/lib/python3.12/site-packages/graph_tool/correlations \
      /opt/conda/lib/python3.12/site-packages/graph_tool/draw \
      /opt/conda/lib/python3.12/site-packages/graph_tool/dynamics \
      /opt/conda/lib/python3.12/site-packages/graph_tool/flow \
      /opt/conda/lib/python3.12/site-packages/graph_tool/generation \
      /opt/conda/lib/python3.12/site-packages/graph_tool/include \
      /opt/conda/lib/python3.12/site-packages/graph_tool/inference \
      /opt/conda/lib/python3.12/site-packages/graph_tool/search \
      /opt/conda/lib/python3.12/site-packages/graph_tool/spectral \
      /opt/conda/lib/python3.12/site-packages/graph_tool/stats \
      /opt/conda/lib/python3.12/site-packages/graph_tool/topology \
      /opt/conda/lib/python3.12/site-packages/graph_tool/util; \
    rm -f /opt/conda/bin/cygdb /opt/conda/bin/cython /opt/conda/bin/cythonize \
      /opt/conda/bin/pip /opt/conda/bin/pip3 /opt/conda/bin/pip3.12; \
    find /opt/conda -type f \( -name '*.a' -o -name '*.pyc' -o -name '*.pyo' \) -delete; \
    find /opt/conda -depth -type d -name __pycache__ -empty -delete

FROM ${MICROMAMBA_IMAGE}

ARG PPANGGOLIN_VERSION=2.3.1

LABEL org.opencontainers.image.title="TAFFISH PPanGGOLiN" \
      org.opencontainers.image.description="PPanGGOLiN pangenome analysis with its complete upstream runtime dependency set" \
      org.opencontainers.image.source="https://github.com/taffish/ppanggolin" \
      org.opencontainers.image.version="${PPANGGOLIN_VERSION}" \
      org.opencontainers.image.licenses="Apache-2.0"

USER root

ENV PATH=/opt/conda/bin:/usr/local/bin:/usr/bin:/bin \
    PYTHONNOUSERSITE=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    BOKEH_RESOURCES=inline \
    TAFFISH_ENV=TAFFISH \
    TAFFISH_NAME=ppanggolin

COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /opt/ppanggolin /opt/ppanggolin
COPY docker/ppanggolin-smoke.sh /opt/ppanggolin/share/testdata/ppanggolin-smoke.sh
COPY docker/ppanggolin-smoke-fixtures.py /opt/ppanggolin/share/testdata/ppanggolin-smoke-fixtures.py

RUN set -eux; \
    chmod 0755 \
      /opt/ppanggolin/share/testdata/ppanggolin-smoke.sh \
      /opt/ppanggolin/share/testdata/ppanggolin-smoke-fixtures.py; \
    ln -s /opt/ppanggolin/share/testdata/ppanggolin-smoke.sh /usr/local/bin/ppanggolin-smoke; \
    ln -s /opt/ppanggolin/share/testdata/ppanggolin-smoke-fixtures.py /usr/local/bin/ppanggolin-smoke-fixtures.py; \
    ppanggolin --version 2>&1 | grep -Fx "ppanggolin ${PPANGGOLIN_VERSION}" >/dev/null; \
    python -c 'from importlib.metadata import version; import graph_tool, nem_stats, ppanggolin; assert version("PPanGGOLiN") == "2.3.1"; assert graph_tool.__version__.split()[0] == "2.98"'; \
    command -v mmseqs >/dev/null; \
    command -v mafft >/dev/null; \
    command -v aragorn >/dev/null; \
    command -v cmscan >/dev/null; \
    test -s /opt/ppanggolin/share/provenance/conda-packages.json

WORKDIR /root
