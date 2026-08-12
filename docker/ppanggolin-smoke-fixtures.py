#!/usr/bin/env python3
"""Create deterministic, self-contained microbial fixtures for PPanGGOLiN smoke tests."""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path


CODONS = {
    "A": "GCT", "C": "TGT", "D": "GAT", "E": "GAA", "F": "TTT",
    "G": "GGT", "H": "CAT", "I": "ATT", "K": "AAA", "L": "CTG",
    "M": "ATG", "N": "AAT", "P": "CCT", "Q": "CAA", "R": "CGT",
    "S": "TCT", "T": "ACT", "V": "GTT", "W": "TGG", "Y": "TAT",
}
AMINO_ACIDS = "ACDEFGHIKLMNPQRSTVWY"


def coding_sequence(family: str) -> tuple[str, str]:
    digest = hashlib.sha512(family.encode("ascii")).digest()
    residues = []
    for index in range(48):
        residues.append(AMINO_ACIDS[digest[index % len(digest)] % len(AMINO_ACIDS)])
    protein = "M" + "".join(residues)
    dna = "".join(CODONS[residue] for residue in protein) + "TAA"
    return dna, protein


def genome_families(index: int) -> list[str]:
    persistent = [f"persistent_{number:02d}" for number in range(1, 9)]
    variable = []
    if index <= 4:
        variable.append("shell_01")
    if index >= 2:
        variable.append("shell_02")
    if index in {1, 3, 5}:
        variable.append("shell_03")
    variable.extend(f"island_{index:02d}_{number:02d}" for number in range(1, 25))
    variable.extend([f"cloud_{index:02d}_01", f"cloud_{index:02d}_02"])
    return persistent[:4] + variable + persistent[4:]


def write_genome(root: Path, index: int) -> tuple[Path, Path]:
    genome = f"genome_{index:02d}"
    contig = f"{genome}_contig"
    spacer = "ACGT" * 10
    sequence_parts = [spacer]
    features: list[tuple[int, int, str, str]] = []
    cursor = len(spacer) + 1

    for family in genome_families(index):
        dna, protein = coding_sequence(family)
        start = cursor
        end = start + len(dna) - 1
        features.append((start, end, family, protein))
        sequence_parts.extend([dna, spacer])
        cursor = end + len(spacer) + 1

    sequence = "".join(sequence_parts)
    gff_path = root / f"{genome}.gff3"
    fasta_path = root / f"{genome}.fna"

    with gff_path.open("w", encoding="utf-8") as handle:
        handle.write("##gff-version 3\n")
        handle.write(f"##sequence-region {contig} 1 {len(sequence)}\n")
        for number, (start, end, family, _protein) in enumerate(features, 1):
            gene_id = f"{genome}_gene_{number:02d}"
            handle.write(
                f"{contig}\tTAFFISH\tCDS\t{start}\t{end}\t.\t+\t0\t"
                f"ID={gene_id};locus_tag={gene_id};product={family}\n"
            )
        handle.write("##FASTA\n")
        handle.write(f">{contig}\n")
        for offset in range(0, len(sequence), 70):
            handle.write(sequence[offset : offset + 70] + "\n")

    with fasta_path.open("w", encoding="utf-8") as handle:
        handle.write(f">{contig}\n")
        for offset in range(0, len(sequence), 70):
            handle.write(sequence[offset : offset + 70] + "\n")

    return gff_path, fasta_path


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: ppanggolin-smoke-fixtures.py OUTPUT_DIRECTORY")

    root = Path(sys.argv[1]).resolve()
    root.mkdir(parents=True, exist_ok=True)
    annotation_rows = []
    fasta_rows = []

    for index in range(1, 6):
        gff_path, fasta_path = write_genome(root, index)
        genome = f"genome_{index:02d}"
        annotation_rows.append(f"{genome}\t{gff_path}\n")
        fasta_rows.append(f"{genome}\t{fasta_path}\n")

    (root / "annotations.tsv").write_text("".join(annotation_rows), encoding="utf-8")
    (root / "fastas.tsv").write_text("".join(fasta_rows), encoding="utf-8")

    _dna, query_protein = coding_sequence("persistent_01")
    (root / "query.faa").write_text(
        f">persistent_01_query\n{query_protein}\n", encoding="utf-8"
    )


if __name__ == "__main__":
    main()
