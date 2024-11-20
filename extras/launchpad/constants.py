from enum import IntEnum
from typing import Final

# ANSI Color Codes
class Colors:
    """ANSI color codes for terminal output."""
    BOLD: Final[str] = "\033[1m"
    RED: Final[str] = "\033[38;5;160m"
    GREEN: Final[str] = "\033[38;5;40m"
    YELLOW: Final[str] = "\033[38;5;220m"
    BLUE: Final[str] = "\033[38;5;33m"
    ENDC: Final[str] = "\033[0m"

class ItemTypes(IntEnum):
    """Enumeration of different item types in Launchpad."""
    ROOT = 1
    FOLDER_ROOT = 2
    PAGE = 3
    APP = 4
    DOWNLOADING_APP = 5

# Database Constants
SYSTEM_PAGES: Final[tuple] = (
    "ROOTPAGE",
    "HOLDINGPAGE",
    "ROOTPAGE_DB",
    "HOLDINGPAGE_DB",
    "ROOTPAGE_VERS",
    "HOLDINGPAGE_VERS"
)

# Database initialization records
DB_ROOT_RECORDS: Final[tuple] = (
    # (rowid, uuid, type, parent_id)
    (1, "ROOTPAGE", ItemTypes.ROOT, 0),
    (2, "HOLDINGPAGE", ItemTypes.PAGE, 1),
    (5, "ROOTPAGE_VERS", ItemTypes.ROOT, 0),
    (6, "HOLDINGPAGE_VERS", ItemTypes.PAGE, 5),
)