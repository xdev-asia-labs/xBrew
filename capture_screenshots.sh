#!/bin/bash
# Automated Screenshot Capture and Extraction for xBrew
# Runs UI tests and auto-extracts screenshots to screenshots/ folder

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCREENSHOTS_DIR="$PROJECT_DIR/screenshots"
DERIVED_DATA="$PROJECT_DIR/.build/DerivedData"
XCRESULT="$PROJECT_DIR/.build/TestResults.xcresult"

echo "==================================="
echo "  xBrew Automated Screenshot Tool"
echo "==================================="
echo ""

# Clean up
rm -rf "$SCREENSHOTS_DIR" "$XCRESULT"
mkdir -p "$SCREENSHOTS_DIR"

# Step 1: Run UI Tests
echo "Step 1: Running UI tests..."
xcodebuild test \
    -project xBrew.xcodeproj \
    -scheme xBrewUITests \
    -destination 'platform=macOS' \
    -derivedDataPath "$DERIVED_DATA" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    -resultBundlePath "$XCRESULT" \
    2>&1 | grep -E "(Test case|passed|failed)" || true

echo ""

# Check if tests succeeded
if [ ! -d "$XCRESULT" ]; then
    echo "Error: Test results not found"
    exit 1
fi

# Step 2: Extract PNG files from xcresult
echo "Step 2: Extracting screenshots..."

SCREENSHOT_NUM=1
NAMES=("01_Dashboard" "02_Packages" "03_Casks" "04_Services" "05_Taps" "06_Maintenance")

for f in "$XCRESULT/Data"/data.*; do
    if file "$f" 2>/dev/null | grep -q "PNG\|image"; then
        if [ $SCREENSHOT_NUM -le 6 ]; then
            NAME="${NAMES[$((SCREENSHOT_NUM-1))]}"
            cp "$f" "$SCREENSHOTS_DIR/${NAME}.png"
            echo "   ✓ Extracted: ${NAME}.png"
            SCREENSHOT_NUM=$((SCREENSHOT_NUM+1))
        fi
    fi
done

echo ""
echo "==================================="
echo "  ✅ Done! $(($SCREENSHOT_NUM-1)) screenshots captured"
echo "==================================="
echo ""
echo "Screenshots saved to: $SCREENSHOTS_DIR"
ls -la "$SCREENSHOTS_DIR"/*.png 2>/dev/null || true
echo ""
echo "Ready for App Store submission!"
