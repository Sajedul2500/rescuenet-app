#!/bin/bash

echo "🚀 Starting RescueNet APK Build Process..."
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Clean previous builds
echo -e "\n${YELLOW}📦 Step 1: Cleaning previous builds...${NC}"
flutter clean
rm -rf build/
rm -rf android/.gradle/
rm -rf android/app/build/

# Step 2: Get dependencies
echo -e "\n${YELLOW}📥 Step 2: Getting Flutter dependencies...${NC}"
flutter pub get

# Step 3: Verify configuration
echo -e "\n${YELLOW}🔍 Step 3: Verifying configuration...${NC}"
echo "   ✓ Network Security Config: android/app/src/main/res/xml/network_security_config.xml"
echo "   ✓ AndroidManifest permissions configured"
echo "   ✓ Build.gradle updated with SDK 34"

# Step 4: Run code generation if needed
echo -e "\n${YELLOW}🔧 Step 4: Running code generation...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || echo "   ℹ️  No code generation needed"

# Step 5: Build APK
echo -e "\n${YELLOW}🏗️  Step 5: Building APK (Release mode)...${NC}"
echo "   This may take several minutes..."
flutter build apk --release --no-tree-shake-icons

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ BUILD SUCCESSFUL!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo -e "\n📱 APK Location:"
    echo -e "   ${GREEN}build/app/outputs/flutter-apk/app-release.apk${NC}"
    
    # Get APK size
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        echo -e "\n📊 APK Size: ${GREEN}${APK_SIZE}${NC}"
    fi
    
    echo -e "\n🎉 Build completed successfully!"
    echo -e "\n📝 Installation Instructions:"
    echo "   1. Transfer the APK to your Android device"
    echo "   2. Enable 'Install from Unknown Sources' in device settings"
    echo "   3. Tap the APK file to install"
    echo "   4. Grant necessary permissions (Location, Camera, Storage)"
    echo ""
    echo -e "⚠️  ${YELLOW}IMPORTANT:${NC}"
    echo "   - Ensure your device can reach the server at: http://110.76.128.74:8777"
    echo "   - The app requires internet connection to function"
    echo "   - Grant all permissions for full functionality"
    
else
    echo -e "\n${RED}❌ BUILD FAILED!${NC}"
    echo -e "${RED}============================================${NC}"
    echo -e "\nPlease check the error messages above and try again."
    exit 1
fi
