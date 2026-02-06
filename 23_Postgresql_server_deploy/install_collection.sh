#!/bin/bash
# ============================================================================
# Script: Install community.postgresql Collection
# ============================================================================
#
# Description:
#   This script installs the community.postgresql collection required for the
#   PostgreSQL multiple instances deployment playbook. The collection will be
#   installed in the 'collections/' directory within the same directory
#   as this script, ensuring it is available for the playbook.
#
# Usage:
#   ./install_collection.sh
#
# Author: GCG AAP SSA Team + v3.01 20260217
#
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================================================"
echo "Installing community.postgresql Collection"
echo "============================================================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLLECTIONS_DIR="${SCRIPT_DIR}/collections"

echo "Script directory: ${SCRIPT_DIR}"
echo "Collections directory: ${COLLECTIONS_DIR}"
echo ""

# Check if ansible-galaxy is available
if ! command -v ansible-galaxy &> /dev/null; then
    echo -e "${RED}ERROR: ansible-galaxy command not found.${NC}"
    echo "Please ensure Ansible is installed and ansible-galaxy is in your PATH."
    exit 1
fi

echo -e "${GREEN}✓ ansible-galaxy is available${NC}"
echo ""

# Display current Ansible version
echo "Ansible version:"
ansible --version | head -n 1
echo ""

# Create collections directory if it doesn't exist
if [ ! -d "${COLLECTIONS_DIR}" ]; then
    echo "Creating collections directory: ${COLLECTIONS_DIR}"
    mkdir -p "${COLLECTIONS_DIR}"
    echo -e "${GREEN}✓ Collections directory created${NC}"
    echo ""
fi

# Install the community.postgresql collection to local collections directory
echo "============================================================================"
echo "Installing community.postgresql collection to: ${COLLECTIONS_DIR}"
echo "============================================================================"
echo ""

if ansible-galaxy collection install community.postgresql -p "${COLLECTIONS_DIR}" --force; then
    echo ""
    echo -e "${GREEN}✓ community.postgresql collection installed successfully${NC}"
    echo "  Installation path: ${COLLECTIONS_DIR}"
else
    echo ""
    echo -e "${RED}✗ Failed to install community.postgresql collection${NC}"
    exit 1
fi

echo ""
echo "============================================================================"
echo "Verifying collection installation..."
echo "============================================================================"
echo ""

# List installed collections from the local directory and verify community.postgresql is present
if ansible-galaxy collection list -p "${COLLECTIONS_DIR}" 2>/dev/null | grep -q "community.postgresql"; then
    echo -e "${GREEN}✓ community.postgresql collection is installed in local directory${NC}"
    echo ""
    echo "Collection details:"
    ansible-galaxy collection list -p "${COLLECTIONS_DIR}" | grep "community.postgresql"
    echo ""
else
    echo -e "${YELLOW}⚠ Warning: community.postgresql collection not found using collection list command${NC}"
    echo "Checking directory structure..."
    if [ -d "${COLLECTIONS_DIR}/ansible_collections/community/postgresql" ]; then
        echo -e "${GREEN}✓ Collection directory structure verified:${NC}"
        echo "  ${COLLECTIONS_DIR}/ansible_collections/community/postgresql"
        ls -la "${COLLECTIONS_DIR}/ansible_collections/community/postgresql" | head -n 5
        echo ""
    else
        echo -e "${RED}✗ community.postgresql collection not found in expected location${NC}"
        echo "Expected path: ${COLLECTIONS_DIR}/ansible_collections/community/postgresql"
        exit 1
    fi
fi

# Display full collection list from local directory
echo "============================================================================"
echo "All collections in local directory (${COLLECTIONS_DIR}):"
echo "============================================================================"
if ansible-galaxy collection list -p "${COLLECTIONS_DIR}" 2>/dev/null; then
    echo ""
else
    echo "Listing directory contents:"
    find "${COLLECTIONS_DIR}" -type d -name "postgresql" 2>/dev/null | head -n 5
    echo ""
fi

echo ""
echo "============================================================================"
echo -e "${GREEN}Installation completed successfully!${NC}"
echo "============================================================================"
echo ""
echo "The community.postgresql collection is now installed in:"
echo "  ${COLLECTIONS_DIR}"
echo ""
echo "You can now run the PostgreSQL multiple instances deployment playbook:"
echo "  ansible-playbook postgresql_multiple_instances_deploy_site.yml -i inventory"
echo ""
echo "Note: The playbook will automatically use collections from the"
echo "      'collections/' directory in the same location as the playbook."
echo ""

