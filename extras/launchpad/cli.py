import argparse
import json
import logging
import os
import sys
from typing import Dict, Any

import yaml

from constants import Colors
from database import LaunchpadDB
from layout import LayoutManager
from utils import get_launchpad_db_dir, validate_config

logger = logging.getLogger(__name__)


def _create_parser() -> argparse.ArgumentParser:
    """Create and configure the argument parser.

    Returns:
        Configured argument parser
    """
    parser = argparse.ArgumentParser(description="Launchpad layout management tool")
    subparsers = parser.add_subparsers(dest="command")

    # Build command
    build_parser = subparsers.add_parser(
        "build", help="Build the Launchpad layout using provided config"
    )
    build_parser.add_argument("config_path", help="Path to the configuration file")
    build_parser.add_argument(
        "--no-rebuild", action="store_true", help="Skip database rebuild"
    )
    build_parser.add_argument(
        "--no-restart", action="store_true", help="Skip Dock restart"
    )

    # Extract command
    extract_parser = subparsers.add_parser(
        "extract", help="Extract current Launchpad layout to a config file"
    )
    extract_parser.add_argument("config_path", help="Path to save the configuration")
    extract_parser.add_argument(
        "-f",
        "--format",
        choices=["json", "yaml"],
        default="yaml",
        help="Output format (default: yaml)",
    )

    # Compare command
    compare_parser = subparsers.add_parser(
        "compare", help="Compare current layout with config file"
    )
    compare_parser.add_argument(
        "config_path", help="Path to the configuration file to compare"
    )

    return parser


def _load_config(config_path: str) -> Dict[str, Any]:
    """Load configuration from file.

    Args:
        config_path: Path to configuration file

    Returns:
        Loaded configuration dictionary

    Raises:
        ValueError: If file format is not supported or file is invalid
    """
    if not os.path.exists(config_path):
        raise ValueError(f"Configuration file not found: {config_path}")

    _, ext = os.path.splitext(config_path)

    try:
        with open(config_path) as f:
            if ext.lower() == ".json":
                return json.load(f)
            elif ext.lower() in (".yml", ".yaml"):
                return yaml.safe_load(f)
            else:
                raise ValueError(f"Unsupported configuration format: {ext}")
    except (json.JSONDecodeError, yaml.YAMLError) as e:
        raise ValueError(f"Invalid configuration file: {e}")


def _handle_build(args: argparse.Namespace) -> int:
    """Handle the build command.

    Args:
        args: Parsed command line arguments

    Returns:
        Exit code (0 for success, non-zero for failure)
    """
    config = _load_config(args.config_path)
    validate_config(config)

    db_path = os.path.join(get_launchpad_db_dir(), "db")
    db = LaunchpadDB(db_path)
    layout_manager = LayoutManager(db)

    logger.info(f"{Colors.BOLD}{Colors.BLUE}Building Launchpad layout...{Colors.ENDC}")
    layout_manager.build_layout(
        app_layout=config["app_layout"],
        hidden_apps=config.get("hidden_apps", []),
        restart_dock=not args.no_restart,
    )

    logger.info(
        f"{Colors.BOLD}{Colors.GREEN}Successfully built Launchpad layout{Colors.ENDC}"
    )
    return 0


def _handle_compare(args: argparse.Namespace) -> int:
    """Handle the compare command.

    Args:
        args: Parsed command line arguments

    Returns:
        Exit code (0 if layouts match, 1 if they differ)
    """
    config = _load_config(args.config_path)
    validate_config(config)

    db_path = os.path.join(get_launchpad_db_dir(), "db")
    db = LaunchpadDB(db_path)
    layout_manager = LayoutManager(db)

    current_layout = layout_manager.extract_layout()

    if config == current_layout:
        logger.info(f"{Colors.BOLD}{Colors.GREEN}Layouts match{Colors.ENDC}")
        return 0
    else:
        logger.info(f"{Colors.BOLD}{Colors.RED}Layouts differ{Colors.ENDC}")
        return 1


def _save_config(config: Dict[str, Any], config_path: str, file_format: str) -> None:
    """Save configuration to file.

    Args:
        config: Configuration dictionary to save
        config_path: Path to save configuration to
        file_format: Format to save in ('json' or 'yaml')

    Raises:
        ValueError: If format is not supported
    """
    try:
        with open(config_path, "w") as f:
            if file_format == "json":
                json.dump(config, f, indent=2)
            else:  # yaml
                yaml.safe_dump(config, f, default_flow_style=False, explicit_start=True)
    except (IOError, OSError) as e:
        raise ValueError(f"Failed to save configuration: {e}")


def _handle_extract(args: argparse.Namespace) -> int:
    """Handle the extract command.

    Args:
        args: Parsed command line arguments

    Returns:
        Exit code (0 for success, non-zero for failure)
    """
    db_path = os.path.join(get_launchpad_db_dir(), "db")
    db = LaunchpadDB(db_path)
    layout_manager = LayoutManager(db)

    current_layout = layout_manager.extract_layout()

    _save_config(current_layout, args.config_path, args.format)
    logger.info(
        f"{Colors.BOLD}{Colors.GREEN}Successfully extracted layout to:{Colors.ENDC} {args.config_path}"
    )
    return 0


class LaunchpadCLI:
    """Command-line interface for Launchpad management."""

    def __init__(self):
        """Initialize the CLI handler."""
        self.parser = _create_parser()

    def run(self) -> int:
        """Execute the CLI command.

        Returns:
            Exit code (0 for success, non-zero for failure)
        """
        args = self.parser.parse_args()

        if not args.command:
            self.parser.print_help()
            return 1

        try:
            if args.command == "build":
                return _handle_build(args)
            elif args.command == "extract":
                return _handle_extract(args)
            elif args.command == "compare":
                return _handle_compare(args)
        except Exception as e:
            logger.error(f"{Colors.RED}Error: {str(e)}{Colors.ENDC}")
            return 1

        return 0


def main() -> None:
    """Main entry point for the CLI."""
    logging.basicConfig(level=logging.INFO, format="%(message)s")

    cli = LaunchpadCLI()
    sys.exit(cli.run())


if __name__ == "__main__":
    main()
