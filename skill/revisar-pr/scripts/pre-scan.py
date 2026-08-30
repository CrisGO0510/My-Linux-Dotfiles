#!/usr/bin/env python3
"""Detección mecánica de convenciones sobre el diff generado por pr-diff.sh.

Uso: pre-scan.py --out <dir>
Salida: una línea por hallazgo con el formato  ruta:línea [ID] fragmento
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ADDED_LINE_RULES = [
    # (id, patrón de ruta, patrón de contenido, rutas excluidas)
    ("NO-MASK", r"\.(vue|ts)$", r"(^|[^\w-])(:?mask\s*[=:]|unmasked-value)", r"(__tests?__|\.(spec|test)\.ts$|shared/components)"),
    ("NO-STYLE", r"\.vue$", r"<style\b", None),
    ("NO-ANY", r"\.(vue|ts)$", r"(:\s*any\b|\bas any\b|<any>|\bany\[\])", None),
    ("NO-TS-COMMENT", r"\.(vue|ts)$", r"@ts-(ignore|expect-error|nocheck)\b", None),
    ("NO-CONSOLE", r"\.(vue|ts)$", r"\bconsole\.\w+\(", r"(__tests?__|\.(spec|test)\.ts$)"),
    ("NO-TODO", r"\.(vue|ts)$", r"(//|/\*|<!--|\*)\s*.*\b(TODO|FIXME)\b", None),
    ("ALIAS-IMPORTS", r"\.(vue|ts)$", r"from\s+['\"]\.\./\.\./", None),
    ("ENDPOINTS-CENTRAL", r"\.(vue|ts)$", r"(['\"`]/api/|https?://)", r"(infrastructure/api/endpoints\.ts$|fake-api/|__tests?__|\.(spec|test)\.ts$|vite\.config|\.stories\.ts$)"),
    ("LAYER-DEPS", r"^src/domain/", r"from\s+['\"](@/?(application|infrastructure|presentation)\b|vue\b|vue-router\b|axios\b|pinia\b|quasar\b)", r"__tests?__"),
    ("LAYER-DEPS", r"^src/application/", r"from\s+['\"]@/?(infrastructure|presentation)\b", r"__tests?__"),
    ("LAYER-DEPS", r"^src/infrastructure/", r"from\s+['\"]@/?presentation\b", r"__tests?__"),
    ("DI-INJECT", r"^src/presentation/.*\.(vue|ts)$", r"\bnew\s+\w+(RepositoryImpl|UseCase)\s*\(", r"__tests?__"),
    ("HTTP-CLIENT", r"\.(vue|ts)$", r"from\s+['\"]axios['\"]", r"(infrastructure/api/|__tests?__|\.(spec|test)\.ts$)"),
    ("SFC-TYPES", r"\.vue$", r"^\s*(export\s+)?(interface\s+[A-Z]\w*\s*[{<]|type\s+[A-Z]\w*\s*(<[^>]*>)?\s*=)", None),
    ("PROPS-TYPED", r"\.vue$", r"\bdefine(Props|Emits)\(\s*\[", None),
    ("DOMAIN-NO-DTO", r"^src/domain/", r"\b(interface|type|class)\s+\w+DTO\b", None),
]

NAMING_RULES = [
    # (patrón de ruta, patrón que debe cumplir el nombre del archivo, descripción)
    (r"^src/domain/.*/repositor(y|ies)/[^/]+\.ts$", r"^I[A-Z]\w*Repository\.ts$", "contrato de repositorio: I<Feature>Repository.ts"),
    (r"^src/application/.*/use-cases?/[^/]+\.ts$", r"^[A-Z]\w*UseCase\.ts$", "caso de uso: <Feature><Accion>UseCase.ts"),
    (r"^src/infrastructure/.*/repositories/[^/]+\.ts$", r"^[A-Z]\w*RepositoryImpl\.ts$", "implementación: <Feature>RepositoryImpl.ts"),
    (r"^src/.*/mappers/[^/]+\.ts$", r"^[A-Z]\w*Mapper\.ts$", "mapper: <Feature>Mapper.ts"),
    (r"^src/.*/composables/[^/]+\.ts$", r"^use[A-Z]\w*\.ts$", "composable: use<Nombre>.ts"),
    (r"^src/.*/stores/[^/]+\.ts$", r"^\w+Store\.ts$", "store: <nombre>Store.ts"),
    (r"^src/presentation/.*/types/[^/]+\.ts$", r"^[a-z0-9]+(-[a-z0-9]+)*\.types\.ts$", "tipos de presentación: kebab-case.types.ts"),
    (r"^src/.*\.vue$", r"^[A-Z][A-Za-z0-9]*\.vue$", "componente/vista: PascalCase.vue"),
    (r"^src/domain/.*\.ts$", r"^(?!.*DTO\.ts$).*$", "en domain no se usa el sufijo DTO"),
]

SLICE_DIRS = [
    "src/domain/feature/{f}",
    "src/application/features/{f}",
    "src/infrastructure/features/{f}",
    "src/core/providers/features/{f}",
    "src/presentation/features/{f}",
]
SLICE_PATTERNS = [
    re.compile(r"^src/domain/feature/([^/]+)/"),
    re.compile(r"^src/(?:application|infrastructure|presentation)/features/([^/]+)/"),
    re.compile(r"^src/core/providers/features/([^/]+)/"),
]

TEST_FILE = re.compile(r"(__tests?__/.*|\.(spec|test))\.ts$")
AAA_MARKERS = ("// Arrange", "// Act", "// Assert")
EMPTY_CATCH = re.compile(r"\bcatch\s*(\([^)]*\))?\s*\{(\s*(//[^\n]*|/\*.*?\*/))*\s*\}", re.S)
TRY_OPEN = re.compile(r"\btry\s*\{")
CATCH_KW = re.compile(r"\}\s*catch\b")
FINALLY_KW = re.compile(r"\}\s*finally\s*\{")


def load_meta(out: Path) -> dict:
    return json.loads((out / "meta.json").read_text())


def read_file(meta: dict, path: str) -> str | None:
    root = Path(meta["repoRoot"])
    if meta["ref"] == "WORKTREE":
        target = root / path
        return target.read_text(errors="replace") if target.is_file() else None
    result = subprocess.run(
        ["git", "-C", str(root), "show", f"{meta['ref']}:{path}"],
        capture_output=True, text=True,
    )
    return result.stdout if result.returncode == 0 else None


def path_exists(meta: dict, path: str, ref: str | None = None) -> bool:
    root = Path(meta["repoRoot"])
    ref = ref or meta["ref"]
    if ref == "WORKTREE":
        return (root / path).exists()
    result = subprocess.run(
        ["git", "-C", str(root), "cat-file", "-e", f"{ref}:{path}"],
        capture_output=True,
    )
    return result.returncode == 0


def parse_added_lines(patch: str):
    """Genera (ruta, número de línea en el archivo nuevo, contenido) por cada línea añadida."""
    current = None
    line_no = 0
    for raw in patch.splitlines():
        if raw.startswith("+++ "):
            target = raw[4:].strip()
            current = None if target == "/dev/null" else re.sub(r"^b/", "", target)
            continue
        if raw.startswith("--- ") or raw.startswith("diff --git") or raw.startswith("index "):
            continue
        hunk = re.match(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@", raw)
        if hunk:
            line_no = int(hunk.group(1))
            continue
        if current is None:
            continue
        if raw.startswith("+"):
            yield current, line_no, raw[1:]
            line_no += 1
        elif raw.startswith("-") or raw.startswith("\\"):
            continue
        else:
            line_no += 1


def parse_files(files_txt: str):
    """Genera (estado, ruta) a partir de `git diff --name-status`."""
    for raw in files_txt.splitlines():
        parts = raw.split("\t")
        if len(parts) < 2:
            continue
        status = parts[0][0]
        path = parts[-1]
        yield status, path


def line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def scan(out: Path) -> list[str]:
    meta = load_meta(out)
    patch = (out / "diff.patch").read_text(errors="replace")
    files = list(parse_files((out / "files.txt").read_text()))
    findings: list[str] = []

    def add(path: str, line: int, rule: str, fragment: str):
        findings.append(f"{path}:{line} [{rule}] {fragment.strip()[:120]}")

    for path, line, content in parse_added_lines(patch):
        for rule, path_re, content_re, exclude_re in ADDED_LINE_RULES:
            if not re.search(path_re, path):
                continue
            if exclude_re and re.search(exclude_re, path):
                continue
            if re.search(content_re, content):
                add(path, line, rule, content)

    changed_paths = [p for status, p in files if status != "D"]
    new_paths = [p for status, p in files if status == "A"]

    for path in new_paths:
        name = path.rsplit("/", 1)[-1]
        if TEST_FILE.search(path):
            continue
        for path_re, name_re, description in NAMING_RULES:
            if re.search(path_re, path) and not re.match(name_re, name):
                add(path, 1, "NAMING", description)

    for path in changed_paths:
        if not TEST_FILE.search(path):
            continue
        content = read_file(meta, path)
        if content is None:
            continue
        missing = [m for m in AAA_MARKERS if m not in content]
        if missing:
            add(path, 1, "TEST-AAA", f"faltan marcadores {', '.join(missing)}")

    for path in changed_paths:
        if not path.endswith(".ts") or TEST_FILE.search(path) or not path.startswith("src/"):
            continue
        content = read_file(meta, path)
        if content is None:
            continue
        for match in EMPTY_CATCH.finditer(content):
            add(path, line_of(content, match.start()), "ERROR-HANDLING", "catch vacío o solo con comentario")
        tries = len(TRY_OPEN.findall(content))
        catches = len(CATCH_KW.findall(content))
        if tries > catches:
            for match in FINALLY_KW.finditer(content):
                add(path, line_of(content, match.start()), "ERROR-HANDLING", "try/finally sin catch")

    features: set[str] = set()
    for path in new_paths:
        for pattern in SLICE_PATTERNS:
            match = pattern.match(path)
            if match:
                features.add(match.group(1))
    for feature in sorted(features):
        expected = [d.format(f=feature) for d in SLICE_DIRS]
        already_existed = any(path_exists(meta, d, meta["baseRef"]) for d in expected)
        if already_existed:
            continue
        missing = [d for d in expected if not path_exists(meta, d)]
        if missing:
            add(f"src/*/features/{feature}", 1, "FEATURE-SLICE", f"feature nuevo; faltan: {', '.join(missing)}")

    return sorted(set(findings), key=lambda f: (f.split(":")[0], int(f.split(":")[1].split(" ")[0])))


def main() -> int:
    args = sys.argv[1:]
    if len(args) != 2 or args[0] != "--out":
        print("uso: pre-scan.py --out <dir>", file=sys.stderr)
        return 2
    out = Path(args[1])
    for required in ("meta.json", "files.txt", "diff.patch"):
        if not (out / required).exists():
            print(f"error: falta {out / required}; ejecuta antes pr-diff.sh", file=sys.stderr)
            return 1
    findings = scan(out)
    for finding in findings:
        print(finding)
    print(f"-- {len(findings)} hallazgos mecánicos", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
