#!/bin/bash

# Script untuk mengaplikasikan modifikasi pada proyek n8n
# Script ini mengubah file-file dari kondisi asli menjadi kondisi yang sudah dimodifikasi

set -e  # Exit on error

echo "🚀 Applying n8n modifications..."

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function untuk print dengan warna
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "packages" ]; then
    print_error "Please run this script from the root of the n8n project"
    exit 1
fi

print_status "Starting modifications..."

# 1. Modify license-state.ts - Bypass license checks
print_status "Modifying license-state.ts to bypass license checks..."
LICENSE_STATE_FILE="packages/@n8n/backend-common/src/license-state.ts"

if [ -f "$LICENSE_STATE_FILE" ]; then
    # Backup original file
    cp "$LICENSE_STATE_FILE" "$LICENSE_STATE_FILE.backup"
    
    # Apply modifications
    sed -i 's/return this\.licenseProvider\.isLicensed(feature);/this.licenseProvider.isLicensed(feature);\n\t\treturn true;/' "$LICENSE_STATE_FILE"
    sed -i 's/this\.assertProvider();$/this.assertProvider();\n\t\t/' "$LICENSE_STATE_FILE"
    
    # Replace quota methods to return unlimited
    sed -i 's/return this\.getValue(.*) ?? UNLIMITED_LICENSE_QUOTA;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_STATE_FILE"
    sed -i 's/return this\.getValue(.*) ?? 7;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_STATE_FILE"
    sed -i 's/return this\.getValue(.*) ?? 180;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_STATE_FILE"
    sed -i 's/return this\.getValue(.*) ?? 24;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_STATE_FILE"
    sed -i 's/return this\.getValue(.*) ?? 0;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_STATE_FILE"
    
    print_success "Modified license-state.ts"
else
    print_warning "license-state.ts not found, skipping..."
fi

# 2. Modify license.ts - Bypass license checks
print_status "Modifying license.ts to bypass license checks..."
LICENSE_FILE="packages/cli/src/license.ts"

if [ -f "$LICENSE_FILE" ]; then
    # Backup original file
    cp "$LICENSE_FILE" "$LICENSE_FILE.backup"
    
    # Apply modifications
    sed -i 's/return this\.manager?.hasFeatureEnabled(feature) ?? false;/this.manager?.hasFeatureEnabled(feature) ?? false;\n\t\treturn true;/' "$LICENSE_FILE"
    
    # Replace quota methods to return unlimited
    sed -i 's/return this\.getValue(.*) ?? UNLIMITED_LICENSE_QUOTA;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_FILE"
    sed -i 's/return this\.getValue(.*) ?? 0;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_FILE"
    sed -i "s/return this\.getValue('planName') ?? 'Community';/return 'Enterprise';/" "$LICENSE_FILE"
    sed -i 's/return this\.getUsersLimit() === UNLIMITED_LICENSE_QUOTA;/return UNLIMITED_LICENSE_QUOTA;/' "$LICENSE_FILE"
    
    print_success "Modified license.ts"
else
    print_warning "license.ts not found, skipping..."
fi

# 3. Modify ProjectNavigation.vue - Add parameter to createProject
print_status "Modifying ProjectNavigation.vue..."
PROJECT_NAV_FILE="packages/frontend/editor-ui/src/components/Projects/ProjectNavigation.vue"

if [ -f "$PROJECT_NAV_FILE" ]; then
    # Backup original file
    cp "$PROJECT_NAV_FILE" "$PROJECT_NAV_FILE.backup"
    
    # Apply modification
    sed -i "s/@click=\"globalEntityCreation\.createProject\"/@click=\"globalEntityCreation.createProject('add_icon')\"/" "$PROJECT_NAV_FILE"
    
    print_success "Modified ProjectNavigation.vue"
else
    print_warning "ProjectNavigation.vue not found, skipping..."
fi

# 4. Modify init.ts - Comment out non-production banner
print_status "Modifying init.ts to disable non-production banner..."
INIT_FILE="packages/frontend/editor-ui/src/init.ts"

if [ -f "$INIT_FILE" ]; then
    # Backup original file
    cp "$INIT_FILE" "$INIT_FILE.backup"
    
    # Apply modification
    sed -i "s/banners\.push('NON_PRODUCTION_LICENSE');/\/\/ banners.push('NON_PRODUCTION_LICENSE');/" "$INIT_FILE"
    
    print_success "Modified init.ts"
else
    print_warning "init.ts not found, skipping..."
fi

# 8. Set executable permissions
chmod +x apply-modifications.sh

# Summary
echo ""
print_success "🎉 Modified files successfully processed!"
echo ""
print_success "📋 Summary of changes:"
echo "   ✅ License bypass applied to license-state.ts (unlimited enterprise features)"
echo "   ✅ License bypass applied to license.ts (unlimited enterprise features)"
echo "   ✅ Project navigation enhanced in ProjectNavigation.vue"
echo "   ✅ Non-production banner disabled in init.ts"
echo ""
print_success "📁 Files modified (M status only):"
echo "   - packages/@n8n/backend-common/src/license-state.ts (modified)"
echo "   - packages/cli/src/license.ts (modified)"
echo "   - packages/frontend/editor-ui/src/components/Projects/ProjectNavigation.vue (modified)"
echo "   - packages/frontend/editor-ui/src/init.ts (modified)"
echo ""
print_status "📝 Note: Files with U (Untracked) status like Dockerfile, docker-compose.yml, n8n.md were skipped"
echo ""
print_success "🚀 Next steps:"
echo "   1. Run 'pnpm install --frozen-lockfile' to install dependencies"
echo "   2. Run 'pnpm dev' for local development"
echo ""
print_success "📚 All n8n enterprise features are now unlocked! 🎊"
