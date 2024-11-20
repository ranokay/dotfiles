import logging
import os
import subprocess
from collections import defaultdict
from dataclasses import dataclass
from time import sleep
from typing import Dict, List, Optional, Set, Union

import yaml

from constants import Colors, ItemTypes
from database import LaunchpadDB, AppMapping
from utils import generate_uuid

logger = logging.getLogger(__name__)


@dataclass
class FolderLayout:
    """Represents a folder's layout configuration."""

    folder_title: str
    folder_layout: List[List[str]]


LayoutItem = Union[str, FolderLayout]
PageLayout = List[LayoutItem]
LaunchpadLayout = List[PageLayout]


def _add_missing_items(
    layout: LaunchpadLayout, mapping: Dict[str, AppMapping]
) -> Set[str]:
    """Adds missing items to the layout.

    Args:
        layout: Current layout configuration
        mapping: Mapping of items to their database information

    Returns:
        Set of missing item titles that were added
    """
    items_in_layout = set()

    # Collect all items currently in layout
    for page in layout:
        for item in page:
            if isinstance(item, dict):
                # Handle folder items
                folder_layout = item["folder_layout"]
                for folder_page in folder_layout:
                    items_in_layout.update(folder_page)
            else:
                # Handle regular items
                items_in_layout.add(item)

    # Find missing items
    missing_items = set(mapping.keys()) - items_in_layout

    # Add missing items in batches of 30
    if missing_items:
        batch_size = 30
        missing_list = list(missing_items)
        for i in range(0, len(missing_list), batch_size):
            layout.append(missing_list[i : i + batch_size])

    return missing_items


def _build_layout(
    root: int, parent_mapping: Dict[int, List[tuple]]
) -> List[List[Union[str, dict]]]:
    """Build a layout data structure for a particular root.

    Args:
        root: Root ID of the tree being built
        parent_mapping: Mapping between parent IDs and items

    Returns:
        List of pages containing items and folders
    """
    layout = []

    # Iterate through pages
    for page_id, _, _, _ in parent_mapping[root]:
        page_items = []

        # Iterate through items on the page
        for id_, type_, app_title, group_title in parent_mapping[page_id]:
            if type_ == ItemTypes.APP:
                # Add app to page
                page_items.append(app_title)
            elif type_ == ItemTypes.FOLDER_ROOT:
                # Process folder
                folder = {"folder_title": group_title, "folder_layout": []}

                # Process folder pages
                for folder_page_id, _, _, _ in parent_mapping[id_]:
                    folder_page_items = []

                    # Process items in folder page
                    for _, item_type, folder_item_title, _ in parent_mapping[
                        folder_page_id
                    ]:
                        if item_type == ItemTypes.APP:
                            folder_page_items.append(folder_item_title)

                    folder["folder_layout"].append(folder_page_items)

                page_items.append(folder)

        layout.append(page_items)

    return layout


class LayoutManager:
    """Manages Launchpad layout operations."""

    def __init__(self, db: LaunchpadDB):
        """Initialize the LayoutManager.

        Args:
            db: LaunchpadDB instance for database operations
        """
        self.db = db
        self.missing_items = set()

    def build_layout(
        self,
        app_layout: LaunchpadLayout,
        hidden_apps: Optional[List[str]] = None,
        restart_dock: bool = True,
    ) -> None:
        """Builds the requested layout for Launchpad apps."""
        self.missing_items = set()

        # Reset Launchpad to default settings
        subprocess.run(["defaults", "write", "com.apple.dock", "ResetLaunchPad", "-bool", "true"])
        subprocess.run(["killall", "Dock"])
        # set timer to wait for Dock to restart
        sleep(1)

        # Get all apps after reset
        all_apps, _ = self.db.get_app_mapping()

        if hidden_apps:
            # Only hide apps that are currently present
            apps_to_hide = [app for app in hidden_apps if app in all_apps]
            self.db.hide_apps(apps_to_hide)

        # Get current app mapping and maximum ID
        app_mapping, max_id = self.db.get_app_mapping()
        group_id = max_id  # Groups start after the highest app ID

        # Add missing apps to layout
        missing_apps = _add_missing_items(app_layout, app_mapping)
        if missing_apps:
            logger.warning(
                f"{Colors.BOLD}{Colors.YELLOW}Uncategorized apps found and added to the last page:{Colors.ENDC}"
            )
            for app in missing_apps:
                logger.warning(f"- {app}")

        # Clear existing group items
        self.db.clear_group_items()

        # Disable triggers temporarily
        self.db.set_trigger_status(ignore=True)

        try:
            # Initialize root structure
            self._initialize_root_structure()

            # Set up the app layout
            self._setup_items(
                item_type=ItemTypes.APP,
                layout=app_layout,
                mapping=app_mapping,
                group_id=group_id,
                root_parent_id=1,
            )

            # Display missing items if any
            if self.missing_items:
                logger.warning(
                    f"{Colors.BOLD}{Colors.YELLOW}Unable to find items (skipped):{Colors.ENDC}"
                )
                for item in sorted(self.missing_items):
                    logger.warning(f"- {item}")
        finally:
            # Re-enable triggers
            self.db.set_trigger_status(ignore=False)

        if restart_dock:
            self._restart_dock()

    def _setup_items(
        self,
        item_type: ItemTypes,
        layout: LaunchpadLayout,
        mapping: Dict[str, AppMapping],
        group_id: int,
        root_parent_id: int,
    ) -> int:
        """Sets up items in the database according to the layout.

        Args:
            item_type: Type of items being set up
            layout: Layout configuration
            mapping: Mapping of items to their database information
            group_id: Current group ID to start from
            root_parent_id: Parent ID for the root level

        Returns:
            Updated group ID after processing
        """
        for page_ordering, page in enumerate(layout, start=1):
            # Create new page
            group_id += 1
            page_parent_id = group_id

            self.db.add_item(
                rowid=group_id,
                uuid=generate_uuid(),
                flags=2,
                item_type=ItemTypes.PAGE,
                parent_id=root_parent_id,
                ordering=page_ordering,
            )

            # Process items on the page
            group_id = self._process_page_items(
                page=page,
                page_parent_id=page_parent_id,
                item_type=item_type,
                mapping=mapping,
                group_id=group_id,
            )

        return group_id

    def _process_page_items(
        self,
        page: PageLayout,
        page_parent_id: int,
        item_type: ItemTypes,
        mapping: Dict[str, AppMapping],
        group_id: int,
    ) -> int:
        """Process items on a single page.

        Args:
            page: List of items on the page
            page_parent_id: Parent ID for the page
            item_type: Type of items being processed
            mapping: Mapping of items to their database information
            group_id: Current group ID

        Returns:
            Updated group ID after processing
        """
        for item_ordering, item in enumerate(page):
            if isinstance(item, dict):
                # Process folder
                group_id = self._process_folder(
                    folder_data=item,
                    page_parent_id=page_parent_id,
                    item_ordering=item_ordering,
                    item_type=item_type,
                    mapping=mapping,
                    group_id=group_id,
                )
            else:
                # Process regular item
                self._process_item(
                    title=item,
                    mapping=mapping,
                    item_type=item_type,
                    parent_id=page_parent_id,
                    ordering=item_ordering,
                )

        return group_id

    def _process_folder(
        self,
        folder_data: dict,
        page_parent_id: int,
        item_ordering: int,
        item_type: ItemTypes,
        mapping: Dict[str, AppMapping],
        group_id: int,
    ) -> int:
        """Process a folder and its contents.

        Args:
            folder_data: Folder configuration data
            page_parent_id: Parent ID for the page containing the folder
            item_ordering: Ordering index for the folder
            item_type: Type of items in the folder
            mapping: Mapping of items to their database information
            group_id: Current group ID

        Returns:
            Updated group ID after processing
        """
        folder_title = folder_data["folder_title"]
        folder_layout = folder_data["folder_layout"]

        # Create folder root
        group_id += 1
        folder_root_id = group_id

        self.db.add_item(
            rowid=group_id,
            uuid=generate_uuid(),
            flags=0,
            item_type=ItemTypes.FOLDER_ROOT,
            parent_id=page_parent_id,
            ordering=item_ordering,
            group_title=folder_title,
        )

        # Process folder pages
        for folder_page_ordering, folder_page in enumerate(folder_layout):
            group_id += 1
            folder_page_id = group_id

            self.db.add_item(
                rowid=group_id,
                uuid=generate_uuid(),
                flags=2,
                item_type=ItemTypes.PAGE,
                parent_id=folder_root_id,
                ordering=folder_page_ordering,
            )

            # Process items in folder page
            for folder_item_ordering, title in enumerate(folder_page):
                self._process_item(
                    title=title,
                    mapping=mapping,
                    item_type=item_type,
                    parent_id=folder_page_id,
                    ordering=folder_item_ordering,
                )

        return group_id

    def _process_item(
        self,
        title: str,
        mapping: Dict[str, AppMapping],
        item_type: ItemTypes,
        parent_id: int,
        ordering: int,
    ) -> None:
        """Process a single item.

        Args:
            title: Item title
            mapping: Mapping of items to their database information
            item_type: Type of item
            parent_id: Parent ID for the item
            ordering: Ordering index for the item
        """
        if title not in mapping:
            self.missing_items.add(title)
            return

        app_data = mapping[title]
        self.db.update_item(
            item_id=app_data.item_id,
            uuid=app_data.uuid,
            flags=app_data.flags,
            item_type=item_type,
            parent_id=parent_id,
            ordering=ordering,
        )

    @staticmethod
    def _restart_dock() -> None:
        """Restart the Dock process."""
        try:
            subprocess.run(["killall", "Dock"], check=True)
        except subprocess.CalledProcessError as e:
            logger.error(f"{Colors.BOLD}{Colors.RED}Failed to restart Dock: {e}{Colors.ENDC}")

    def _initialize_root_structure(self) -> None:
        """Initialize the root structure in the database.

        This creates the basic root pages and holding pages required by Launchpad.
        """
        # Add root and holding pages to items and groups
        root_records = [
            # Root for Launchpad apps
            (1, "ROOTPAGE", ItemTypes.ROOT, 0),
            (2, "HOLDINGPAGE", ItemTypes.PAGE, 1),
            # Root for Launchpad version
            (5, "ROOTPAGE_VERS", ItemTypes.ROOT, 0),
            (6, "HOLDINGPAGE_VERS", ItemTypes.PAGE, 5),
        ]

        for rowid, uuid, type_, parent_id in root_records:
            self.db.add_item(
                rowid=rowid,
                uuid=uuid,
                flags=None,
                item_type=type_,
                parent_id=parent_id,
                ordering=0,
            )

    def extract_layout(self, config_path: str = None) -> dict:
        """Extract the current Launchpad layout and combine with hidden apps from config.

        Args:
            config_path: Path to the config.yaml file (defaults to config.yaml in same directory as this file)

        Returns:
            Dictionary containing the current layout configuration and hidden apps from config
        """
        # Get the root elements for Launchpad apps
        launchpad_root = self.db.get_launchpad_root()

        # Build parent mapping
        parent_mapping = self._build_parent_mapping()

        # If no config_path provided, use the one in the same directory as this file
        if config_path is None:
            config_path = os.path.join(os.path.dirname(__file__), "config.yaml")

        # Get hidden apps from config file
        hidden_apps = []
        try:
            with open(config_path, "r") as f:
                config = yaml.safe_load(f)
                if isinstance(config, dict):
                    hidden_apps = config.get("hidden_apps", [])
                else:
                    logger.warning(
                        f"{Colors.BOLD}{Colors.YELLOW}Config file:{Colors.ENDC} {config_path} {Colors.BOLD}{Colors.YELLOW}does not contain a valid dictionary{Colors.ENDC}"
                    )
        except FileNotFoundError:
            logger.warning(
                f"{Colors.BOLD}{Colors.YELLOW}Config file:{Colors.ENDC} {config_path} {Colors.BOLD}{Colors.YELLOW}not found. Using empty hidden_apps list.{Colors.ENDC}"
            )
        except yaml.YAMLError as e:
            logger.warning(
                f"{Colors.BOLD}{Colors.YELLOW}Error reading config file:{Colors.ENDC} {e}. {Colors.BOLD}{Colors.YELLOW}Using empty hidden_apps list.{Colors.ENDC}"
            )

        # Build the current layout
        layout = {
            "app_layout": _build_layout(launchpad_root, parent_mapping),
            "hidden_apps": hidden_apps,
        }

        return layout

    def _build_parent_mapping(self) -> Dict[int, List[tuple]]:
        """Build mapping between parent IDs and their items.

        Returns:
            Dictionary mapping parent IDs to lists of item tuples
        """
        parent_mapping = defaultdict(list)

        # Query all relevant items
        with self.db.get_connection() as conn:
            cursor = conn.execute(
                """
                SELECT items.rowid, items.parent_id, items.type,
                    apps.title AS app_title,
                    groups.title AS group_title
                FROM items
                LEFT JOIN apps ON apps.item_id = items.rowid
                LEFT JOIN groups ON groups.item_id = items.rowid
                WHERE items.uuid NOT IN (
                    'ROOTPAGE', 'HOLDINGPAGE',
                    'ROOTPAGE_DB', 'HOLDINGPAGE_DB',
                    'ROOTPAGE_VERS', 'HOLDINGPAGE_VERS'
                )
                ORDER BY items.parent_id, items.ordering
            """
            )

            for row in cursor.fetchall():
                id_, parent_id, type_, app_title, group_title = row
                parent_mapping[parent_id].append((id_, type_, app_title, group_title))

        return parent_mapping
