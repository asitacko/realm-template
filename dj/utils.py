from typing import List, Tuple


def choices(lst: str) -> List[Tuple[str, str]]:
    return [(c.strip(), c.strip()) for c in lst.split(",")]
