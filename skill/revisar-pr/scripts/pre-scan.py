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
    ("NO-ANY", r"\.(vue|ts)$", r"(?:[:<,|&]|=>|\bas)\s*any\b", None),
    ("NO-TS-COMMENT", r"\.(vue|ts)$", r"@ts-(ignore|expect-error|nocheck)\b", None),
    ("NO-CONSOLE", r"\.(vue|ts)$", r"\bconsole\.\w+\(", r"(__tests?__|\.(spec|test)\.ts$)"),
    ("NO-TODO", r"\.(vue|ts)$", r"(//|/\*|<!--|\*)\s*.*\b(TODO|FIXME)\b", None),
    ("ALIAS-IMPORTS", r"\.(vue|ts)$", r"from\s+['\"]\.\./\.\./", None),
    ("ENDPOINTS-CENTRAL", r"\.(vue|ts)$", r"(['\"`]/api/|https?://(?!www\.w3\.org/))", r"(infrastructure/api/endpoints\.ts$|fake-api/|__tests?__|\.(spec|test)\.ts$|vite\.config|\.stories\.ts$)"),
    ("LAYER-DEPS", r"^src/domain/", r"from\s+['\"](@/?(application|infrastructure|presentation)\b|vue\b|vue-router\b|axios\b|pinia\b|quasar\b)", r"__tests?__"),
    ("LAYER-DEPS", r"^src/application/", r"from\s+['\"]@/?(infrastructure|presentation)\b", r"__tests?__"),
    ("LAYER-DEPS", r"^src/infrastructure/", r"from\s+['\"]@/?presentation\b", r"__tests?__"),
    ("DI-INJECT", r"^src/presentation/.*\.(vue|ts)$", r"\bnew\s+\w+(RepositoryImpl|UseCase)\s*\(", r"__tests?__"),
    ("HTTP-CLIENT", r"\.(vue|ts)$", r"from\s+['\"]axios['\"]", r"(infrastructure/api/|__tests?__|\.(spec|test)\.ts$)"),
    ("SFC-TYPES", r"\.vue$", r"^\s*(export\s+)?(interface\s+[A-Z]\w*\b|type\s+[A-Z]\w*\s*(<[^>]*>)?\s*=)", None),
    ("PROPS-TYPED", r"\.vue$", r"\bdefine(Props|Emits)\(\s*[\[{]", None),
    # Candidatos de reglas de criterio: el modelo confirma cada uno.
    ("VALIDATION-RULES", r"^src/presentation/.*\.(vue|ts)$",
     r"(/\^.*/[gimsuy]*\.test\(|\.match\(\s*/\^|=>\s*[^=;]*\|\|\s*['\"`])", r"(__tests?__|\.(spec|test)\.ts$)"),
    ("COMMENTS", r"\.(vue|ts)$",
     r"(?i)^\s*//\s*(components?|props|emits|imports?|logic( view)?|composables?|state|methods|computed|watchers?|lifecycle|variables|functions|types?|interfaces?)\s*$",
     None),
    ("COMMENTS", r"\.(vue|ts)$", r"^\s*//\s*(const|let|var|import|export|return|await|if\s*\(|for\s*\(|this\.)\b", None),
    ("DOMAIN-NO-DTO", r"^src/domain/", r"\b(interface|type|class)\s+\w+DTO\b", None),
    # Declaración a nivel de módulo en un composable: el contenido conserva la indentación
    # original, así que anclar en columna 0 basta para saber que está fuera del `export const useX`.
    ("COMPOSABLE-SCOPE", r"^src/presentation/.*/use[A-Z]\w*\.ts$",
     r"^(?!export\s+(const|(async\s+)?function)\s+use[A-Z])(export\s+)?(const|let|var|(async\s+)?function|enum|class)\s",
     r"(__tests?__|\.(spec|test)\.ts$)"),
]

NAMING_RULES = [
    # (patrón de ruta, patrón que debe cumplir el nombre del archivo, descripción)
    (r"^src/domain/.*/repositor(y|ies)/[^/]+\.ts$", r"^I[A-Z]\w*Repository\.ts$", "contrato de repositorio: I<Feature>Repository.ts"),
    (r"^src/application/.*/use-cases?/[^/]+\.ts$", r"^[A-Z]\w*UseCase\.ts$", "caso de uso: <Feature><Accion>UseCase.ts"),
    (r"^src/infrastructure/.*/repositories/[^/]+\.ts$", r"^[A-Z]\w*RepositoryImpl\.ts$", "implementación: <Feature>RepositoryImpl.ts"),
    (r"^src/.*/mappers/[^/]+\.ts$", r"^[A-Z]\w*Mapper\.ts$", "mapper: <Feature>Mapper.ts"),
    (r"^src/.*/composables/[^/]+\.ts$", r"^use[A-Z]\w*\.ts$", "composable: use<Nombre>.ts"),
    (r"^src/.*/stores/[^/]+\.ts$", r"^\w+Store\.ts$", "store: <nombre>Store.ts"),
    # Ambos repos usan kebab-case.ts a secas (0 de 37 archivos con sufijo .types): no exigirlo.
    (r"^src/presentation/.*/types/[^/]+\.ts$", r"^[a-z0-9]+(-[a-z0-9]+)*\.ts$", "tipos de presentación: kebab-case.ts"),
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

# Lógica dentro del <script> de un SFC (SFC-CLEAN). Destructurar el composable no cuenta.
SFC_LOGIC = re.compile(
    r"\b(computed|watch|watchEffect|ref|reactive|nextTick"
    r"|on(Before)?(Mount|Unmount|Update)(ed)?|onActivated|onDeactivated)\s*(<[^>]*>)?\("
    r"|^\s*(async\s+)?function\s"
    r"|^\s*const\s+\w+\s*=\s*(async\s*)?(\([^)]*\)|\w+)\s*=>"
    r"|\b\w+UseCase\b|\buse\w+Store\s*\("
)
ENTITY_PROP = re.compile(r"^\s{2}(public\s+|private\s+|protected\s+)?(?!readonly\b)\w+[?!]?\s*:(?!.*[({]\s*$)")
ENTITY_CTOR_PARAM = re.compile(r"\b(public|private|protected)\s+(?!readonly\b)\w+[?!]?\s*:")
TEST_FILE = re.compile(r"(__tests?__/.*|\.(spec|test))\.ts$")
AAA_MARKERS = ("// Arrange", "// Act", "// Assert")
# Un bloque de test va desde su `it(`/`test(` hasta el siguiente `it`/`test`/`describe` o el final.
TEST_BLOCK_START = re.compile(r"^\s*(it|test|describe)(\.\w+)*\s*\(")
EMPTY_CATCH = re.compile(r"\bcatch\s*(\([^)]*\))?\s*\{(\s*(//[^\n]*|/\*.*?\*/))*\s*\}", re.S)
TRY_OPEN = re.compile(r"\btry\s*\{")


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


def git(meta: dict, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", "-C", meta["repoRoot"], *args], capture_output=True, text=True)


def tree_paths(meta: dict) -> set[str]:
    """Archivos de src/ tal como quedan en la revisión."""
    if meta["ref"] == "WORKTREE":
        out = git(meta, "ls-files", "--cached", "--others", "--exclude-standard", "--", "src").stdout
    else:
        out = git(meta, "ls-tree", "-r", "--name-only", meta["ref"], "--", "src").stdout
    return set(out.splitlines())


def grep_tree(meta: dict, pattern: str) -> bool:
    """¿Algún archivo de src/ contiene el patrón (ERE)?"""
    if meta["ref"] == "WORKTREE":
        args = ["grep", "-qE", "--untracked", pattern, "--", "src"]
    else:
        args = ["grep", "-qE", pattern, meta["ref"], "--", "src"]
    return git(meta, *args).returncode == 0


def script_lines(content: str) -> set[int]:
    """Números de línea dentro de los bloques <script> de un SFC."""
    inside = False
    result = set()
    for n, line in enumerate(content.splitlines(), 1):
        if re.match(r"^\s*<script\b", line):
            inside = True
            continue
        if re.match(r"^\s*</script>", line):
            inside = False
        if inside:
            result.add(n)
    return result


def parse_added_lines(patch: str):
    """Genera (ruta, número de línea en el archivo nuevo, contenido) por cada línea añadida."""
    current = None
    line_no = 0
    # Las cabeceras `---`/`+++` solo existen antes del primer hunk: una línea añadida
    # cuyo contenido empieza por "++ " no debe confundirse con el archivo destino.
    in_header = False
    for raw in patch.splitlines():
        if raw.startswith("diff --git"):
            in_header = True
            continue
        if in_header:
            if raw.startswith("+++ "):
                target = raw[4:].strip()
                current = None if target == "/dev/null" else re.sub(r"^b/", "", target)
            hunk = re.match(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@", raw)
            if hunk:
                in_header = False
                line_no = int(hunk.group(1))
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


def block_end(text: str, open_idx: int) -> int:
    """Índice de la `}` que cierra la `{` en open_idx, saltando strings y comentarios."""
    depth = 0
    i = open_idx
    while i < len(text):
        c = text[i]
        if text.startswith("//", i):
            i = text.find("\n", i)
            if i == -1:
                return len(text)
        elif text.startswith("/*", i):
            i = text.find("*/", i)
            if i == -1:
                return len(text)
            i += 1
        elif c in "'\"`":
            j = i + 1
            while j < len(text) and text[j] != c:
                j += 2 if text[j] == "\\" else 1
            i = j
        elif c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return len(text)


def tests_without_aaa(content: str, touched: set[int]) -> list[tuple[int, list[str]]]:
    """(línea, marcadores faltantes) de cada `it`/`test` que contiene alguna línea tocada."""
    lines = content.splitlines()
    starts = [n for n, l in enumerate(lines, 1) if TEST_BLOCK_START.match(l)]
    result = []
    for k, start in enumerate(starts):
        if re.match(r"^\s*describe\b", lines[start - 1]):
            continue
        end = starts[k + 1] - 1 if k + 1 < len(starts) else len(lines)
        if not any(start <= n <= end for n in touched):
            continue
        block = "\n".join(lines[start - 1:end])
        missing = [m for m in AAA_MARKERS if m not in block]
        if missing:
            result.append((start, missing))
    return result


def scan(out: Path) -> list[str]:
    meta = load_meta(out)
    patch = (out / "diff.patch").read_text(errors="replace")
    files = list(parse_files((out / "files.txt").read_text()))
    findings: list[str] = []

    def add(path: str, line: int, rule: str, fragment: str):
        findings.append(f"{path}:{line} [{rule}] {fragment.strip()[:120]}")

    added_by_path: dict[str, set[int]] = {}
    added_lines: dict[str, list[tuple[int, str]]] = {}
    for path, line, content in parse_added_lines(patch):
        added_by_path.setdefault(path, set()).add(line)
        added_lines.setdefault(path, []).append((line, content))
        for rule, path_re, content_re, exclude_re in ADDED_LINE_RULES:
            if not re.search(path_re, path):
                continue
            if exclude_re and re.search(exclude_re, path):
                continue
            if re.search(content_re, content):
                add(path, line, rule, content)

    changed_paths = [p for status, p in files if status != "D"]
    # Un renombrado estrena nombre: pasa por NAMING igual que un archivo nuevo.
    new_paths = [p for status, p in files if status in ("A", "R")]

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
        for line, missing in tests_without_aaa(content, added_by_path.get(path, set())):
            add(path, line, "TEST-AAA", f"faltan marcadores {', '.join(missing)}")

    for path in changed_paths:
        if not path.endswith(".ts") or TEST_FILE.search(path) or not path.startswith("src/"):
            continue
        content = read_file(meta, path)
        if content is None:
            continue
        for match in EMPTY_CATCH.finditer(content):
            add(path, line_of(content, match.start()), "ERROR-HANDLING", "catch vacío o solo con comentario")
        for match in TRY_OPEN.finditer(content):
            after = content[block_end(content, match.end() - 1) + 1:]
            if re.match(r"\s*finally\b", after):
                add(path, line_of(content, match.start()), "ERROR-HANDLING", "try/finally sin catch")

    for path, lines in added_lines.items():
        if not path.endswith(".vue") or not path.startswith("src/"):
            continue
        content = read_file(meta, path)
        if content is None:
            continue
        in_script = script_lines(content)
        for line, text in lines:
            if line in in_script and SFC_LOGIC.search(text):
                add(path, line, "SFC-CLEAN", text)
            if "<TableList" in text and "@update-sort" not in content:
                add(path, line, "TABLE-SORT", "TableList sin @update-sort")

    for path, lines in added_lines.items():
        if not re.search(r"^src/domain/.*/entities/.*\.ts$", path) or TEST_FILE.search(path):
            continue
        content = read_file(meta, path)
        if content is None or not re.search(r"\bclass\b", content):
            continue
        for line, text in lines:
            if ENTITY_PROP.search(text) or ENTITY_CTOR_PARAM.search(text):
                add(path, line, "ENTITY-IMMUTABLE", text)

    tree = tree_paths(meta) | set(changed_paths)
    tests = [p for p in tree if TEST_FILE.search(p)]
    for path in (p for status, p in files if status == "A"):
        if TEST_FILE.search(path):
            continue
        name = path.rsplit("/", 1)[-1]
        stem = name[:-3]
        is_use_case = re.search(r"^src/application/.*UseCase\.ts$", path)
        is_composable = re.search(r"^src/presentation/.*/use[A-Z]\w*\.ts$", path)
        if (is_use_case or is_composable) and not any(t.rsplit("/", 1)[-1].startswith(stem + ".") for t in tests):
            add(path, 1, "TESTS-MISSING", f"sin test para {stem}")
        if is_use_case:
            key = f"{stem}Key"
            missing = [
                desc for desc, pattern in (
                    (f"declarar {key}", rf"{key}[[:space:]]*[:=]"),
                    (f"app.provide({key}, ...)", rf"provide\([[:space:]]*{key}\b"),
                    (f"inject({key})", rf"inject\([[:space:]]*{key}\b"),
                ) if not grep_tree(meta, pattern)
            ]
            if missing:
                add(path, 1, "DI-WIRING", f"falta: {', '.join(missing)}")

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

    # El texto completo desempata: sin él, dos IDs en la misma línea salen en el orden del set (aleatorio).
    return sorted(set(findings), key=lambda f: (f.split(":")[0], int(f.split(":")[1].split(" ")[0]), f))


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
