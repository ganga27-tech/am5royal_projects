#!/bin/bash

# Check if feature name is provided
if [ -z "$1" ]; then
    echo "Usage: ./create_feature.sh <feature_name>"
    exit 1
fi

FEATURE_NAME=$1
# Convert to snake_case (lowercase with underscores)
FEATURE_NAME_SNAKE=$(echo "$FEATURE_NAME" | sed -r 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]')

BASE_PATH="lib/features/$FEATURE_NAME_SNAKE"

# Create directory structure
echo "Creating feature: $FEATURE_NAME_SNAKE at $BASE_PATH"

mkdir -p "$BASE_PATH/data/datasources"
mkdir -p "$BASE_PATH/data/models"
mkdir -p "$BASE_PATH/data/repositories"
mkdir -p "$BASE_PATH/domain/entities"
mkdir -p "$BASE_PATH/domain/repositories"
mkdir -p "$BASE_PATH/domain/usecases"
mkdir -p "$BASE_PATH/presentation/bloc"
mkdir -p "$BASE_PATH/presentation/pages"
mkdir -p "$BASE_PATH/presentation/widgets"

# Create placeholder files
touch "$BASE_PATH/domain/repositories/${FEATURE_NAME_SNAKE}_repository.dart"
touch "$BASE_PATH/data/repositories/${FEATURE_NAME_SNAKE}_repository_impl.dart"
touch "$BASE_PATH/data/datasources/${FEATURE_NAME_SNAKE}_remote_data_source.dart"
touch "$BASE_PATH/presentation/bloc/${FEATURE_NAME_SNAKE}_bloc.dart"
touch "$BASE_PATH/presentation/pages/${FEATURE_NAME_SNAKE}_page.dart"

echo "✅ Feature '$FEATURE_NAME_SNAKE' created successfully!"
echo "Structure:"
echo "- data/ (datasources, models, repositories)"
echo "- domain/ (entities, repositories, usecases)"
echo "- presentation/ (bloc, pages, widgets)"
