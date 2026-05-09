#!/bin/bash

# =========================================
# MacBook Air 2018 Buyer Inspection Script
# =========================================

clear

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

line() {
    echo "------------------------------------------------------------"
}

title() {
    echo ""
    echo -e "${BLUE}$1${NC}"
    line
}

good() {
    echo -e "${GREEN}✓ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

bad() {
    echo -e "${RED}✗ $1${NC}"
}

# =========================================
# HEADER
# =========================================

echo ""
echo "============================================================"
echo "         MACBOOK BUYER INSPECTION REPORT"
echo "============================================================"
echo ""

# =========================================
# BASIC SYSTEM INFO
# =========================================

title "1. SYSTEM INFORMATION"

MODEL=$(system_profiler SPHardwareDataType | awk -F": " '/Model Name/ {print $2}')
MODEL_ID=$(system_profiler SPHardwareDataType | awk -F": " '/Model Identifier/ {print $2}')
CPU=$(system_profiler SPHardwareDataType | awk -F": " '/Processor Name/ {print $2}')
RAM=$(system_profiler SPHardwareDataType | awk -F": " '/Memory/ {print $2}')
SERIAL=$(system_profiler SPHardwareDataType | awk -F": " '/Serial Number/ {print $2}')
OS=$(sw_vers -productVersion)

echo "Model            : $MODEL"
echo "Model Identifier : $MODEL_ID"
echo "Processor        : $CPU"
echo "Memory           : $RAM"
echo "macOS Version    : $OS"
echo "Serial Number    : $SERIAL"

# =========================================
# STORAGE
# =========================================

title "2. STORAGE HEALTH"

DISK=$(diskutil info / | awk -F": " '/Device Node/ {print $2}')
TOTAL=$(df -h / | awk 'NR==2 {print $2}')
FREE=$(df -h / | awk 'NR==2 {print $4}')

echo "Disk             : $DISK"
echo "Total Storage    : $TOTAL"
echo "Free Storage     : $FREE"

SMART=$(diskutil info disk0 | awk -F": " '/SMART Status/ {print $2}')

if [[ "$SMART" == "Verified" ]]; then
    good "SSD SMART Status Verified"
else
    bad "SSD SMART Status NOT verified"
fi

# =========================================
# BATTERY
# =========================================

title "3. BATTERY HEALTH"

CYCLE=$(system_profiler SPPowerDataType | awk -F": " '/Cycle Count/ {print $2}')
CONDITION=$(system_profiler SPPowerDataType | awk -F": " '/Condition/ {print $2}')
MAXCAP=$(system_profiler SPPowerDataType | awk -F": " '/Maximum Capacity/ {print $2}')

echo "Cycle Count      : $CYCLE"
echo "Condition        : $CONDITION"
echo "Maximum Capacity : $MAXCAP"

if [[ "$CYCLE" -lt 500 ]]; then
    good "Battery cycle count healthy"
elif [[ "$CYCLE" -lt 800 ]]; then
    warn "Battery moderately used"
else
    bad "Battery heavily worn"
fi

if [[ "$CONDITION" == "Normal" ]]; then
    good "Battery condition normal"
else
    bad "Battery may need replacement"
fi

# =========================================
# DISPLAY
# =========================================

title "4. DISPLAY INFORMATION"

DISPLAY=$(system_profiler SPDisplaysDataType | grep Resolution)

echo "$DISPLAY"

good "Check manually for:"
echo "  • Dead pixels"
echo "  • Flickering"
echo "  • Pink edges"
echo "  • Keyboard marks"
echo "  • Flexgate issues"

# =========================================
# KEYBOARD
# =========================================

title "5. KEYBOARD TEST"

warn "Open Notes app and test EVERY key manually."
warn "2018 models are known for butterfly keyboard issues."

# =========================================
# THERMAL CHECK
# =========================================

title "6. THERMAL / CPU STATUS"

CPU_USAGE=$(top -l 1 | awk '/CPU usage/ {print $3}')

echo "Current CPU Usage : $CPU_USAGE"

warn "Play a 4K YouTube video for 5 mins."
warn "Check for overheating, lagging, or loud fan noise."

# =========================================
# WIFI / BLUETOOTH
# =========================================

title "7. CONNECTIVITY"

WIFI=$(networksetup -getairportpower en0 2>/dev/null)

echo "$WIFI"

BT=$(system_profiler SPBluetoothDataType | grep "State")

echo "$BT"

# =========================================
# ICLOUD / MDM CHECK
# =========================================

title "8. ACTIVATION / MDM CHECK"

MDM=$(profiles status -type enrollment 2>/dev/null)

echo "$MDM"

if echo "$MDM" | grep -qi "No"; then
    good "No MDM enrollment detected"
else
    warn "Possible MDM or organization management"
fi

# =========================================
# CAMERA CHECK
# =========================================

title "9. CAMERA CHECK"

CAM=$(system_profiler SPCameraDataType | grep "FaceTime")

if [[ -n "$CAM" ]]; then
    good "Camera detected"
else
    bad "Camera not detected"
fi

# =========================================
# AUDIO CHECK
# =========================================

title "10. AUDIO CHECK"

AUDIO=$(system_profiler SPAudioDataType | grep "Output")

if [[ -n "$AUDIO" ]]; then
    good "Audio output detected"
else
    bad "Audio issue detected"
fi

# =========================================
# FINAL VERDICT
# =========================================

title "11. FINAL BUY RECOMMENDATION"

SCORE=0

if [[ "$SMART" == "Verified" ]]; then
    SCORE=$((SCORE + 1))
fi

if [[ "$CONDITION" == "Normal" ]]; then
    SCORE=$((SCORE + 1))
fi

if [[ "$CYCLE" -lt 700 ]]; then
    SCORE=$((SCORE + 1))
fi

if echo "$MDM" | grep -qi "No"; then
    SCORE=$((SCORE + 1))
fi

echo "Inspection Score : $SCORE / 4"
echo ""

if [[ "$SCORE" -eq 4 ]]; then
    good "SAFE TO BUY at 220 AUD"
elif [[ "$SCORE" -eq 3 ]]; then
    warn "DECENT BUY but negotiate lower price"
else
    bad "AVOID BUYING this MacBook"
fi

echo ""
line
echo "Inspection Complete"
line
echo ""