#!/bin/bash

# Exit on first error
set -e

# Define helper print function
print_status() {
    echo -e "\033[1;34m==>\033[0m \033[1m$1\033[0m"
}

print_error() {
    echo -e "\033[1;31mError:\033[0m \033[1m$1\033[0m"
}

show_help() {
    echo "Usage: ./build.sh [command]"
    echo ""
    echo "Commands:"
    echo "  get       Run 'flutter pub get' to fetch dependencies"
    echo "  clean     Clean build directories and fetch dependencies"
    echo "  build     Generate code using build_runner (single run)"
    echo "  watch     Watch files and generate code on change"
    echo "  analyze   Run static code analysis"
    echo "  test      Run widget and unit tests"
    echo "  all       Clean, get dependencies, build code, and run tests"
}

case "$1" in
    get)
        print_status "Fetching dependencies..."
        flutter pub get
        ;;
    clean)
        print_status "Cleaning build cache..."
        flutter clean
        print_status "Fetching dependencies..."
        flutter pub get
        ;;
    build)
        print_status "Generating files (build_runner)..."
        dart run build_runner build --delete-conflicting-outputs
        ;;
    watch)
        print_status "Watching files for changes (build_runner)..."
        dart run build_runner watch --delete-conflicting-outputs
        ;;
    analyze)
        print_status "Analyzing code quality..."
        flutter analyze
        ;;
    test)
        print_status "Running tests..."
        flutter test
        ;;
    all)
        print_status "Running clean setup and build..."
        flutter clean
        flutter pub get
        dart run build_runner build --delete-conflicting-outputs
        flutter test
        ;;
    *)
        show_help
        exit 1
        ;;
esac
