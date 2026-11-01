#!/bin/bash
# 构建一份未签名的 RoamChina.ipa（用于 Sideloadly / AltStore 侧载重签）
# 用法：在 ios/ 目录执行 ./build-ipa.sh
set -euo pipefail

cd "$(dirname "$0")"

BUILD_DIR=".build-device"
DIST="distribution"
APP_NAME="Lucia"          # 工程 target 名，产物仍是 Lucia.app
DISPLAY_NAME="RoamChina"  # 桌面显示名，见 Info.plist 的 CFBundleDisplayName
VERSION="1.1.0"

echo "==> 构建真机 Release（未签名）"
xcodebuild -project "${APP_NAME}.xcodeproj" -scheme "${APP_NAME}" \
  -sdk iphoneos -configuration Release -derivedDataPath "${BUILD_DIR}" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build

rm -rf "${DIST}"
mkdir -p "${DIST}/Payload"
cp -R "${BUILD_DIR}/Build/Products/Release-iphoneos/${APP_NAME}.app" "${DIST}/Payload/"

APP="${DIST}/Payload/${APP_NAME}.app"
ICON="AppIcon.png"

echo "==> 生成并注入应用图标"
for spec in "AppIcon60x60@2x.png:120" "AppIcon60x60@3x.png:180" \
            "AppIcon76x76@2x.png:152" "AppIcon83.5x83.5@2x.png:167"; do
  name="${spec%%:*}"; size="${spec##*:}"
  sips -z "${size}" "${size}" "${ICON}" --out "${APP}/${name}" >/dev/null
done

PLIST="${APP}/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons dict" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons:CFBundlePrimaryIcon dict" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles array" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:0 string AppIcon60x60" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons~ipad dict" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons~ipad:CFBundlePrimaryIcon dict" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons~ipad:CFBundlePrimaryIcon:CFBundleIconFiles array" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons~ipad:CFBundlePrimaryIcon:CFBundleIconFiles:0 string AppIcon76x76" "${PLIST}"
/usr/libexec/PlistBuddy -c "Add :CFBundleIcons~ipad:CFBundlePrimaryIcon:CFBundleIconFiles:1 string AppIcon83.5x83.5" "${PLIST}"

echo "==> 打包 IPA"
cd "${DIST}"
IPA="${DISPLAY_NAME}-${VERSION}-unsigned.ipa"
zip -qry "${IPA}" Payload
shasum -a 256 "${IPA}"
echo "==> 完成：${DIST}/${IPA}"
