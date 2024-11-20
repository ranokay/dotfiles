import logging
import sqlite3
from contextlib import contextmanager
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple, Generator

from constants import ItemTypes

logger = logging.getLogger(__name__)


@dataclass
class AppMapping:
    """Data class representing an app's mapping information."""

    item_id: int
    uuid: str
    flags: int


class LaunchpadDB:
    """Handles all database operations for the Launchpad Manager."""

    def __init__(self, db_path: str):
        """Initialize the database connection.

        Args:
            db_path: Path to the SQLite database file
        """
        self.db_path = db_path
        self._connection = None

    @contextmanager
    def get_connection(self) -> Generator[sqlite3.Connection, None, None]:
        """Context manager for database connections.

        Yields:
            sqlite3.Connection: Database connection
        """
        conn = None
        try:
            conn = sqlite3.connect(self.db_path)
            yield conn
        finally:
            if conn:
                conn.close()

    def hide_apps(self, apps_to_hide: List[str]) -> List[str]:
        """Hide specified apps from Launchpad.

        Args:
            apps_to_hide: List of app titles to hide

        Returns:
            List of successfully hidden app titles
        """
        if not apps_to_hide:
            return []

        successfully_hidden = []

        with self.get_connection() as conn:
            cursor = conn.cursor()

            for app in apps_to_hide:
                try:
                    # Check if app exists
                    cursor.execute("SELECT COUNT(*) FROM apps WHERE title = ?", (app,))

                    if cursor.fetchone()[0] == 0:
                        logger.warning(f"App {app} not found in Launchpad")
                        continue

                    # Remove from items table first (referential integrity)
                    cursor.execute(
                        """
                        DELETE FROM items
                        WHERE rowid IN (
                            SELECT item_id
                            FROM apps
                            WHERE title = ?
                        )
                    """,
                        (app,),
                    )

                    # Remove from apps table
                    cursor.execute("DELETE FROM apps WHERE title = ?", (app,))

                    successfully_hidden.append(app)
                    conn.commit()

                except sqlite3.Error as e:
                    logger.error(f"Error processing {app}: {e}")
                    conn.rollback()

        return successfully_hidden

    def get_app_mapping(self) -> Tuple[Dict[str, AppMapping], int]:
        """Get mapping between app titles and their database information.

        Returns:
            Tuple containing:
            - Dictionary mapping app titles to their AppMapping
            - Maximum item ID found
        """
        mapping = {}
        max_id = 0

        with self.get_connection() as conn:
            cursor = conn.execute(
                """
                SELECT apps.item_id, apps.title, items.uuid, items.flags
                FROM apps
                JOIN items ON items.rowid = apps.item_id
            """
            )

            for row in cursor.fetchall():
                item_id, title, uuid, flags = row
                mapping[title] = AppMapping(item_id, uuid, flags)
                max_id = max(max_id, item_id)

        return mapping, max_id

    def clear_group_items(self) -> None:
        """Clear all items related to groups for rebuilding."""
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                DELETE FROM items
                WHERE type IN (?, ?, ?)
            """,
                (ItemTypes.ROOT, ItemTypes.FOLDER_ROOT, ItemTypes.PAGE),
            )
            conn.commit()

    def set_trigger_status(self, ignore: bool) -> None:
        """Set the status of update triggers in the database.

        Args:
            ignore: Whether to ignore update triggers
        """
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                UPDATE dbinfo
                SET value = ?
                WHERE key = 'ignore_items_update_triggers'
            """,
                (1 if ignore else 0,),
            )
            conn.commit()

    def add_item(
        self,
        rowid: int,
        uuid: str,
        flags: Optional[int],
        item_type: ItemTypes,
        parent_id: int,
        ordering: int = 0,
        group_title: Optional[str] = None,
    ) -> None:
        """Add a new item to the database.

        Args:
            rowid: Row ID for the item
            uuid: UUID for the item
            flags: Item flags
            item_type: Type of the item
            parent_id: Parent item ID
            ordering: Item ordering
            group_title: Title for group items
        """
        with self.get_connection() as conn:
            cursor = conn.cursor()

            try:
                # Insert into items table
                cursor.execute(
                    """
                    INSERT INTO items
                    (rowid, uuid, flags, type, parent_id, ordering)
                    VALUES (?, ?, ?, ?, ?, ?)
                """,
                    (rowid, uuid, flags, item_type, parent_id, ordering),
                )

                # Insert into groups table
                cursor.execute(
                    """
                    INSERT INTO groups
                    (item_id, category_id, title)
                    VALUES (?, null, ?)
                """,
                    (rowid, group_title),
                )

                conn.commit()
            except sqlite3.Error as e:
                logger.error(f"Error adding item {rowid}: {e}")
                conn.rollback()

    def update_item(
        self,
        item_id: int,
        uuid: str,
        flags: int,
        item_type: ItemTypes,
        parent_id: int,
        ordering: int,
    ) -> None:
        """Update an existing item in the database.

        Args:
            item_id: ID of the item to update
            uuid: New UUID
            flags: New flags
            item_type: New item type
            parent_id: New parent ID
            ordering: New ordering
        """
        with self.get_connection() as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    """
                    UPDATE items
                    SET uuid = ?,
                        flags = ?,
                        type = ?,
                        parent_id = ?,
                        ordering = ?
                    WHERE rowid = ?
                """,
                    (uuid, flags, item_type, parent_id, ordering, item_id),
                )
                conn.commit()
            except sqlite3.Error as e:
                logger.error(f"Error updating item {item_id}: {e}")
                conn.rollback()

    def get_launchpad_root(self) -> int:
        """Get the root item ID for Launchpad apps.

        Returns:
            Root item ID
        """
        with self.get_connection() as conn:
            cursor = conn.execute(
                """
                SELECT value
                FROM dbinfo
                WHERE key = 'launchpad_root'
            """
            )
            return int(cursor.fetchone()[0])
