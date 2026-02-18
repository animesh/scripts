#for %i in ("L:\promec\Animesh\boltz2\*.fasta") do (python boltz2dock.py "%i" DKPD)
#https://build.nvidia.com/mit/boltz2?snippet_tab=Try https://docs.api.nvidia.com/nim/reference/mit-boltz2
#$env:NVIDIA_API_KEY="your-api-key-here"
#python boltz2dock.py <protein_sequence> <peptide1> [peptide2 ...]
import asyncio
import json
import os
import sys
import random
import logging
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
import re

PUBLIC_URL = "https://health.api.nvidia.com/v1/biology/mit/boltz2/predict"
STATUS_URL = "https://api.nvcf.nvidia.com/v2/nvcf/pexec/status/{task_id}"

REQUEST_TIMEOUT = 400
PACING_SECONDS = 3
COOLDOWN_SECONDS = 180          # hard cooldown after quota hit
MAX_RETRIES = 6                 # per peptide
MAX_429_BEFORE_COOLDOWN = 2

# ---------------------------------------- #

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger("boltz2dock")


# ---------------- API CALL ---------------- #

async def call_boltz2(
    client,
    payload: Dict[str, Any],
) -> Optional[Dict[str, Any]]:
    """
    Returns:
        dict  -> successful response
        None  -> rate-limited / quota exhausted
    """

    import httpx

    api_key = os.getenv("NVIDIA_API_KEY")
    if not api_key:
        raise RuntimeError("NVIDIA_API_KEY not set")

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "NVCF-POLL-SECONDS": "300",
    }

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = await client.post(
                PUBLIC_URL,
                json=payload,
                headers=headers,
                timeout=REQUEST_TIMEOUT,
            )

        except Exception as e:
            logger.warning(f"Network error: {e}")
            await asyncio.sleep(2 ** attempt)
            continue

        # -------- SUCCESS -------- #
        if resp.status_code == 200:
            return resp.json()

        # -------- ASYNC JOB -------- #
        if resp.status_code == 202:
            task_id = resp.headers.get("nvcf-reqid")
            while True:
                status = await client.get(
                    STATUS_URL.format(task_id=task_id),
                    headers=headers,
                    timeout=REQUEST_TIMEOUT,
                )
                if status.status_code == 200:
                    return status.json()
                await asyncio.sleep(5)

        # -------- RATE LIMIT -------- #
        if resp.status_code == 429:
            wait = 2 ** attempt + random.random()
            logger.warning(f"429 received, backing off {wait:.1f}s")
            await asyncio.sleep(wait)
            continue

        # -------- OTHER ERROR -------- #
        logger.error(f"HTTP {resp.status_code}: {resp.text}")
        return None

    # retries exhausted → treat as quota exhaustion
    return None


# ---------------- MAIN LOOP ---------------- #

async def main():
    if len(sys.argv) < 3:
        print("Usage: python boltz2dock.py <protein_or_fasta> <peptide1> [peptide2 ...]")
        sys.exit(1)

    protein_arg = sys.argv[1]
    peptides = sys.argv[2:]

    # Optional dry-run mode: don't call the API, just print payload + output names
    dry_run = False
    if "--dry-run" in peptides:
        dry_run = True
        peptides = [p for p in peptides if p != "--dry-run"]

    def read_fasta_first_sequence(path: Path) -> Tuple[str, Optional[str]]:
        """Return (sequence, gene_name).

        If the file contains a FASTA header, extract the first header's
        `GN=` field (if present) and return it as gene_name. If no header
        is present, return the file contents joined as the sequence and
        `None` for gene_name.
        """
        text = path.read_text()
        header = None
        seq_lines = []
        in_seq = False
        for line in text.splitlines():
            line = line.strip()
            if not line:
                continue
            if line.startswith(">"):
                if in_seq:
                    break
                in_seq = True
                if header is None:
                    header = line[1:].strip()
                continue
            # collect sequence lines (either after header, or whole file)
            seq_lines.append(line)

        if not in_seq and header is None:
            # no headers -> assume file contains raw sequence lines
            seq = "".join(l.strip() for l in text.splitlines() if l.strip())
            return seq, None

        seq = "".join(seq_lines)
        gene = None
        if header:
            m = re.search(r"\bGN=([^\s;]+)", header)
            if m:
                gene = m.group(1)

        return seq, gene

    protein = protein_arg
    p = Path(protein_arg)
    prefix = None
    if p.is_file():
        protein, gene = read_fasta_first_sequence(p)
        if gene:
            prefix = gene

    if not prefix:
        prefix = protein[:8]
    consecutive_429 = 0

    if dry_run:
        client = None
        for idx, peptide in enumerate(peptides, 1):
            # dry-run branch — same loop body as below but without API calls
            print("\n" + "=" * 60)
            print(f"Processing {idx}/{len(peptides)}: {peptide}")
            print("=" * 60)

            payload = {
                "polymers": [
                    {
                        "id": "C",
                        "molecule_type": "protein",
                        "sequence": protein,
                        "msa": {
                            "uniref90": {
                                "a3m": {
                                    "alignment": f">seq1\n{protein}",
                                    "format": "a3m",
                                }
                            }
                        },
                    },
                    {
                        "id": "D",
                        "molecule_type": "protein",
                        "sequence": peptide,
                        "msa": {
                            "uniref90": {
                                "a3m": {
                                    "alignment": f">seq2\n{peptide}",
                                    "format": "a3m",
                                }
                            }
                        },
                    },
                ],
                "recycling_steps": 3,
                "sampling_steps": 20,
                "diffusion_samples": 1,   # single model only
                "step_scale": 1.64,
                "without_potentials": True,
            }

            outfile = Path(f"boltz2.{prefix}.{peptide}.json")
            print(f"[dry-run] Would call API with payload for peptide {peptide}")
            print(f"[dry-run] Output → {outfile}")
            await asyncio.sleep(0.01)
            continue
    else:
        import httpx

        async with httpx.AsyncClient() as client:
            for idx, peptide in enumerate(peptides, 1):
                print("\n" + "=" * 60)
                print(f"Processing {idx}/{len(peptides)}: {peptide}")
                print("=" * 60)

                payload = {
                    "polymers": [
                        {
                            "id": "C",
                            "molecule_type": "protein",
                            "sequence": protein,
                            "msa": {
                                "uniref90": {
                                    "a3m": {
                                        "alignment": f">seq1\n{protein}",
                                        "format": "a3m",
                                    }
                                }
                            },
                        },
                        {
                            "id": "D",
                            "molecule_type": "protein",
                            "sequence": peptide,
                            "msa": {
                                "uniref90": {
                                    "a3m": {
                                        "alignment": f">seq2\n{peptide}",
                                        "format": "a3m",
                                    }
                                }
                            },
                        },
                    ],
                    "recycling_steps": 3,
                    "sampling_steps": 20,
                    "diffusion_samples": 1,   # single model only
                    "step_scale": 1.64,
                    "without_potentials": True,
                }

                result = await call_boltz2(client, payload)

                # -------- SUCCESS -------- #
                if result is not None:
                    consecutive_429 = 0
                    outfile = Path(f"boltz2.{prefix}.{peptide}.json")
                    outfile.write_text(json.dumps(result, indent=2))

                    conf = result.get("confidence_scores", [])
                    print(f"Saved → {outfile}")
                    print(f"Confidence → {conf}")

                    await asyncio.sleep(PACING_SECONDS)
                    continue

                # -------- RATE-LIMIT HANDLING -------- #
                consecutive_429 += 1
                logger.warning(f"Quota pressure ({consecutive_429} hits)")

                if consecutive_429 >= MAX_429_BEFORE_COOLDOWN:
                    logger.warning(
                        f"Cooling down for {COOLDOWN_SECONDS}s to reset quota"
                    )
                    await asyncio.sleep(COOLDOWN_SECONDS)
                    consecutive_429 = 0

                # move on, never crash
                continue


if __name__ == "__main__":
    asyncio.run(main())
