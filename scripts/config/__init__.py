import yaml
import os
import logging

# --- Setup logging for the config loader ---
logger = logging.getLogger(__name__)

# --- Determine the absolute path to the settings.yaml file ---
# This makes the path independent of where you run the script from.
config_dir = os.path.dirname(os.path.abspath(__file__))
config_path = os.path.join(config_dir, 'settings.yaml')

# --- Initialize a global variable to hold the configuration ---
settings = None

# --- Load the YAML configuration ---
try:
    with open(config_path, 'r') as f:
        settings = yaml.safe_load(f)
    if not settings:
        logger.warning(f"Configuration file at {config_path} is empty.")
    else:
        logger.info("Successfully loaded settings from settings.yaml.")
except FileNotFoundError:
    logger.error(f"FATAL: Configuration file not found at {config_path}")
    # You might want to exit or raise an exception if the config is critical
    # raise FileNotFoundError(f"Configuration file not found: {config_path}")
except yaml.YAMLError as e:
    logger.error(f"FATAL: Error parsing YAML file at {config_path}: {e}")
    # raise ValueError(f"Error parsing YAML file: {e}")