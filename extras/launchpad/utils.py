import os
import subprocess
from typing import List, TypeVar, Sequence

T = TypeVar('T')

def generate_uuid() -> str:
    """Generate a UUID using system's uuidgen command.

    Returns:
        A string containing the generated UUID.

    Raises:
        subprocess.SubprocessError: If uuidgen command fails.
    """
    try:
        return subprocess.check_output("uuidgen").decode("utf-8").strip()
    except subprocess.SubprocessError as e:
        raise RuntimeError(f"Failed to generate UUID: {e}")

def get_launchpad_db_dir() -> str:
    """Determines the user's Launchpad database directory.

    Returns:
        Path to the Launchpad database directory.

    Raises:
        subprocess.SubprocessError: If getconf command fails.
        RuntimeError: If DARWIN_USER_DIR cannot be determined.
    """
    try:
        darwin_user_dir = subprocess.check_output(
            ["getconf", "DARWIN_USER_DIR"]
        ).decode("utf-8").strip()

        return os.path.join(darwin_user_dir, "com.apple.dock.launchpad", "db")
    except subprocess.SubprocessError as e:
        raise RuntimeError(f"Failed to determine Launchpad database directory: {e}")

def batch_items(items: Sequence[T], batch_size: int) -> List[List[T]]:
    """Split a sequence of items into batches of specified size.

    Args:
        items: Sequence of items to batch
        batch_size: Size of each batch

    Returns:
        List of batches, where each batch is a list of items

    Example:
        >>> list(batch_items([1,2,3,4,5], 2))
        [[1, 2], [3, 4], [5]]
    """
    return [
        list(items[i:i + batch_size])
        for i in range(0, len(items), batch_size)
    ]

def validate_config(config: dict) -> bool:
    """Validate the Launchpad configuration format.

    Args:
        config: Dictionary containing the Launchpad configuration

    Returns:
        True if configuration is valid, False otherwise

    Raises:
        ValueError: If required fields are missing or invalid
    """
    if not isinstance(config, dict):
        raise ValueError("Configuration must be a dictionary")

    if "app_layout" not in config:
        raise ValueError("Configuration must contain 'app_layout' key")

    if not isinstance(config["app_layout"], list):
        raise ValueError("app_layout must be a list of pages")

    # Validate each page
    for page_idx, page in enumerate(config["app_layout"]):
        if not isinstance(page, list):
            raise ValueError(f"Page {page_idx} must be a list of items")

        for item_idx, item in enumerate(page):
            if isinstance(item, dict):
                _validate_folder_config(item, f"Page {page_idx}, Item {item_idx}")
            elif not isinstance(item, str):
                raise ValueError(
                    f"Item at Page {page_idx}, position {item_idx} "
                    "must be either a string or folder dictionary"
                )

    # Validate hidden_apps if present
    if "hidden_apps" in config:
        if not isinstance(config["hidden_apps"], list):
            raise ValueError("hidden_apps must be a list of strings")

        if not all(isinstance(app, str) for app in config["hidden_apps"]):
            raise ValueError("All items in hidden_apps must be strings")

    return True

def _validate_folder_config(folder: dict, location: str) -> None:
    """Validate a folder configuration.

    Args:
        folder: Dictionary containing folder configuration
        location: String describing the location of the folder for error messages

    Raises:
        ValueError: If folder configuration is invalid
    """
    required_keys = {"folder_title", "folder_layout"}

    if not isinstance(folder, dict):
        raise ValueError(f"Folder at {location} must be a dictionary")

    missing_keys = required_keys - set(folder.keys())
    if missing_keys:
        raise ValueError(
            f"Folder at {location} missing required keys: {', '.join(missing_keys)}"
        )

    if not isinstance(folder["folder_title"], str):
        raise ValueError(f"folder_title at {location} must be a string")

    if not isinstance(folder["folder_layout"], list):
        raise ValueError(f"folder_layout at {location} must be a list")

    for page_idx, page in enumerate(folder["folder_layout"]):
        if not isinstance(page, list):
            raise ValueError(
                f"Folder page {page_idx} at {location} must be a list"
            )
        if not all(isinstance(item, str) for item in page):
            raise ValueError(
                f"All items in folder page {page_idx} at {location} must be strings"
            )