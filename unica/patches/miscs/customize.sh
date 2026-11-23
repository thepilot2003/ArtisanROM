SET_PROP_IF_DIFF "vendor" "ro.oem_unlock_supported" "0"

# Disable FRP
SET_PROP "vendor" "ro.frp.pst" ""
SET_PROP "product" "ro.frp.pst" ""

# Better device/model detection in CoreRune
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/rune/CoreRune.smali" "replace" \
    '<clinit>()V' \
    'ro.product.model' \
    'ro.product.vendor.model'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/rune/CoreRune.smali" "replace" \
    '<clinit>()V' \
    'ro.product.device' \
    'ro.product.vendor.device'

# shellcheck disable=SC2016
# Disable RescueParty
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/RescueParty.smali" "return" \
    '-$$Nest$smisDisabled()Z' \
    'true'

# Better model detection in FreecessController
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/am/FreecessController.smali" "replace" \
    '<clinit>()V' \
    'ro.product.model' \
    'ro.product.vendor.model'
    
LOG_STEP_IN "- Enabling BSOH in deviceinfo"
VALUE=${SOURCE_FIRMWARE:0:8}

DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"

FILES_TO_PATCH="
BatteryRegulatoryPreferenceController.smali
SecBatteryInfoFragment.smali
"

for fname in $FILES_TO_PATCH; do
    target_file="$(find "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" -type f -name "$fname" 2>/dev/null | head -n 1)"
    if [ -n "$target_file" ] && [ -f "$target_file" ]; then
        sed -i "s/SM-A236B/$VALUE/g" "$target_file"
        LOG "  - Patched $fname in $(basename "$(dirname "$target_file")")"
    else
        LOG "  - Warning: $fname not found in SecSettings.apk, skipping"
    fi
done
LOG_STEP_OUT
