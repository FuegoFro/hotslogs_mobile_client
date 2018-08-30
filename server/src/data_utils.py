from pathlib import Path
from typing import Iterator

_JSON_DIR: Path = Path(__file__).resolve().parent.parent / "data/json"
_RAW_DIR: Path = _JSON_DIR / "raw"
_ROLLUPS_DIR: Path = _JSON_DIR / "rollups"
_TOP_BUILDS_DIR: Path = _JSON_DIR / "top_builds"


def _json_file(root: Path, name: object) -> Path:
    root.mkdir(parents=True, exist_ok=True)
    path = root / f"{name}.json"
    resolved = path.resolve()
    assert path == resolved and root in path.parents
    return path


def json_raw_data_file(file_num: int) -> Path:
    return _json_file(_RAW_DIR, file_num)


def get_last_json_file_num() -> int:
    last_file_num = -1
    for path in _RAW_DIR.iterdir():
        if path.suffix == ".json":
            last_file_num = max(last_file_num, int(path.stem))
    return last_file_num


def json_iter_raw_data() -> Iterator[Path]:
    for path in _RAW_DIR.iterdir():
        if path.suffix == ".json":
            yield path


def json_rollup_file(hero_name: str) -> Path:
    return _json_file(_ROLLUPS_DIR, hero_name)


def get_all_rollup_heroes() -> Iterator[str]:
    for path in _ROLLUPS_DIR.iterdir():
        if path.suffix == ".json":
            yield path.stem


def json_top_builds_file(hero_name: str) -> Path:
    return _json_file(_TOP_BUILDS_DIR, hero_name)
