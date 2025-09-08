#!/usr/bin/env bash
set -euo pipefail

# create-pcl-project.sh
# Create a new folder in the current directory and clone the pcl-init template into it.
#
# Usage:
#   create-pcl-project.sh <project-name> [--https|--ssh] [--branch <name>] [--shallow|--depth N] [--no-submodules] [--fresh]
#
# Flags:
#   --https            Use HTTPS URL instead of SSH (default is SSH)
#   --ssh              Force SSH URL (default)
#   --branch <name>    Branch to clone (default: main)
#   --shallow          Shallow clone (equivalent to --depth 1)
#   --depth N          Shallow clone with depth N
#   --no-submodules    Do not clone submodules
#   --fresh            Remove template git history and re-initialize a fresh git repo
#   -h, --help         Show help
#
# Examples:
#   create-pcl-project.sh my-new-project
#   create-pcl-project.sh my-new-project --https --branch main --shallow
#   create-pcl-project.sh my-new-project --fresh

SCRIPT_NAME=$(basename "$0")
REPO_SSH="git@github.com:czepluch/pcl-init.git"
REPO_HTTPS="https://github.com/czepluch/pcl-init.git"
REPO_URL="$REPO_SSH"
BRANCH="main"
RECURSE=1
FRESH=0
DEPTH_ARGS=()
PROJECT_NAME=""

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <project-name> [options]

Options:
  --https            Use HTTPS URL instead of SSH (default is SSH)
  --ssh              Force SSH URL (default)
  --branch <name>    Branch to clone (default: main)
  --shallow          Shallow clone (equivalent to --depth 1)
  --depth N          Shallow clone with depth N
  --no-submodules    Do not clone submodules
  --fresh            Remove template git history and re-initialize a fresh git repo
  -h, --help         Show this help
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --https)
      REPO_URL="$REPO_HTTPS"
      shift
      ;;
    --ssh)
      REPO_URL="$REPO_SSH"
      shift
      ;;
    --branch)
      [[ $# -ge 2 ]] || { echo "Error: --branch requires a value" >&2; exit 1; }
      BRANCH="$2"
      shift 2
      ;;
    --shallow)
      DEPTH_ARGS=("--depth" "1")
      shift
      ;;
    --depth)
      [[ $# -ge 2 ]] || { echo "Error: --depth requires a value" >&2; exit 1; }
      DEPTH_ARGS=("--depth" "$2")
      shift 2
      ;;
    --no-submodules)
      RECURSE=0
      shift
      ;;
    --fresh|--reinit-git)
      FRESH=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME="$1"
        shift
      else
        echo "Unexpected argument: $1" >&2
        usage
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: <project-name> is required" >&2
  usage
  exit 1
fi

TARGET_DIR="$PWD/$PROJECT_NAME"
if [[ -e "$TARGET_DIR" ]]; then
  echo "Error: Target path already exists: $TARGET_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

CLONE_ARGS=("git" "clone" "--branch" "$BRANCH")
# Append depth args only if set and non-empty (safe under set -u)
if [[ ${DEPTH_ARGS+x} == x && ${#DEPTH_ARGS[@]} -gt 0 ]]; then
  CLONE_ARGS+=("${DEPTH_ARGS[@]}")
fi
if [[ $RECURSE -eq 1 ]]; then
  CLONE_ARGS+=("--recurse-submodules")
fi
CLONE_ARGS+=("$REPO_URL" "$TARGET_DIR")

printf "Cloning %s (branch: %s) into %s\n" "$REPO_URL" "$BRANCH" "$TARGET_DIR"
"${CLONE_ARGS[@]}"

echo "Clone completed."

if [[ $FRESH -eq 1 ]]; then
  echo "Re-initializing repository with fresh git history..."
  # Remove git metadata and template remotes
  rm -rf "$TARGET_DIR/.git" "$TARGET_DIR/.gitmodules" || true
  (cd "$TARGET_DIR" && git init && git add -A && git commit -m "Initialize from pcl-init template")
  echo "Fresh git repository initialized at: $TARGET_DIR"
fi

echo "Done. Next steps:"
echo "  cd $PROJECT_NAME"
echo "  # If you used --fresh, add your own remote:"
echo "  # git remote add origin <your-repo-url> && git push -u origin main"
