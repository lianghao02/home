"""將目前專案入口頁複製到使用者明確指定的位置。"""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent
SOURCE_INDEX = PROJECT_ROOT / "index.html"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="複製目前專案的 index.html 到指定輸出檔案。"
    )
    parser.add_argument(
        "destination",
        type=Path,
        help="目標 index.html 的完整或相對路徑。",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="允許覆寫既有目標檔案。",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    destination = args.destination.expanduser().resolve()

    if not SOURCE_INDEX.is_file():
        raise FileNotFoundError(f"找不到入口頁：{SOURCE_INDEX}")
    if destination == SOURCE_INDEX:
        raise ValueError("目標不可與來源 index.html 相同。")
    if destination.exists() and not args.force:
        raise FileExistsError("目標已存在；確認後請加上 --force 覆寫。")

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(SOURCE_INDEX, destination)
    print(f"已複製：{SOURCE_INDEX} -> {destination}")


if __name__ == "__main__":
    main()
