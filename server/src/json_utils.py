import json
from dataclasses import dataclass
from pathlib import Path
from typing import Mapping, Sequence, Iterator, TypeVar, Type

_T = TypeVar("_T")


@dataclass(frozen=True)
class JsonThing:
    _data: object

    def _as_type(self, t: Type[_T]) -> _T:
        assert isinstance(self._data, t), f"Expected {t}, got {type(self._data)}, data={repr(self._data)}"
        return self._data

    def as_int(self) -> int:
        return self._as_type(int)

    def as_str(self) -> str:
        return self._as_type(str)

    def as_bool(self) -> bool:
        return self._as_type(bool)

    def as_map(self) -> "JsonMap":
        assert isinstance(self._data, dict), type(self._data)
        for key in self._data:
            assert isinstance(key, str), type(key)

        return JsonMap(self._data)

    def as_list(self) -> "JsonList":
        assert isinstance(self._data, list)

        return JsonList(self._data)


    def is_none(self) -> bool:
        return self._data is None


    @classmethod
    def from_path(cls, path: Path) -> "JsonThing":
        return cls(json.load(path.open()))


@dataclass(frozen=True)
class JsonMap:
    _data: Mapping[str, object]

    def __len__(self) -> int:
        return len(self._data)

    def __getitem__(self, item: str) -> JsonThing:
        assert isinstance(item, str)
        return JsonThing(self._data[item])


@dataclass(frozen=True)
class JsonList:
    _data: Sequence[object]

    def __len__(self) -> int:
        return len(self._data)

    def __getitem__(self, item: int) -> JsonThing:
        assert isinstance(item, int)
        return JsonThing(self._data[item])

    def __iter__(self) -> Iterator[JsonThing]:
        for i in self._data:
            yield JsonThing(i)
