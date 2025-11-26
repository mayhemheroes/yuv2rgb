#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/yuv2rgb/
#
# Original image: ghcr.io/mayhemheroes/yuv2rgb:master
# Git revision: d290c115973183603d668594377882ae698db854

# ============================================================================
# Environment Variables
# ============================================================================
# No special environment variables needed for this C/C++ project

# ============================================================================
# REQUIRED: Change to Source Directory
# ============================================================================
cd /rlenv/source/yuv2rgb

# ============================================================================
# Clean Previous Build (recommended)
# ============================================================================
# Remove old build artifacts to ensure fresh rebuild
rm -rf build/

# ============================================================================
# Build Commands (NO NETWORK, NO PACKAGE INSTALLATION)
# ============================================================================
# Create build directory and run CMake build
mkdir -p build
cd build
cmake ..
make -j8

# ============================================================================
# Copy Artifacts (use 'cat >' for busybox compatibility)
# ============================================================================
# Copy build artifact to expected location
mkdir -p /repo/build
cat test_yuv_rgb > /repo/build/test_yuv_rgb

# ============================================================================
# Set Permissions
# ============================================================================
chmod 777 /repo/build/test_yuv_rgb 2>/dev/null || true

# 777 allows validation script (running as UID 1000) to overwrite during rebuild
# 2>/dev/null || true prevents errors if chmod not available

# ============================================================================
# REQUIRED: Verify Build Succeeded
# ============================================================================
if [ ! -f /repo/build/test_yuv_rgb ]; then
    echo "Error: Build artifact not found at /repo/build/test_yuv_rgb"
    exit 1
fi

# Verify executable bit
if [ ! -x /repo/build/test_yuv_rgb ]; then
    echo "Warning: Build artifact is not executable"
fi

# Verify file size
SIZE=$(stat -c%s /repo/build/test_yuv_rgb 2>/dev/null || stat -f%z /repo/build/test_yuv_rgb 2>/dev/null || echo 0)
if [ "$SIZE" -lt 1000 ]; then
    echo "Warning: Build artifact is suspiciously small ($SIZE bytes)"
fi

echo "Build completed successfully: /repo/build/test_yuv_rgb"
