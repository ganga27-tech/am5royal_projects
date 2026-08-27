# Flutter Clean Architecture Walkthrough

This guide provides an overview of the Clean Architecture structure implemented in the `am5vendor` project. The code includes **BLoC** (with **Freezed** annotations), a singleton API Client utilizing **Dio**, modern **Google Fonts (Outfit)** theme configuration, and dependency injection managed globally with **GetIt**.

---

## Directory Structure

The structure separates concerns into distinct layers: **Core** (shared logic, theme, error handling, network) and **Features** (business logic modules).

```
lib/
├── main.dart                      # App entry point (initializes DI & runs MyApp)
├── core/
│   ├── constants/
│   │   └── colors.dart            # Theme color palette and gradients
│   ├── di/
│   │   └── injection_container.dart # GetIt dependency injection registry
│   ├── error/
│   │   ├── exceptions.dart        # Core exceptions (Server, Cache, Network)
│   │   └── failures.dart          # Functional failures for Dartz (Either<Failure, T>)
│   ├── network/
│   │   └── api_client.dart        # Singleton Dio HTTP client with memory-mock CRUD interceptor
│   ├── theme/
│   │   └── app_theme.dart         # Google Fonts (Outfit) Light and Dark theme configurations
│   └── usecase/
│       └── usecase.dart           # Generic UseCase base class
└── features/
    └── products/
        ├── data/
        │   ├── datasources/
        │   │   └── product_remote_data_source.dart # Direct API client calls
        │   ├── models/
        │   │   └── product_model.dart # Freezed product model (JSON serializable)
        │   └── repositories/
        │       └── product_repository_impl.dart # Maps models to entities & catches exceptions
        ├── domain/
        │   ├── entities/
        │   │   └── product.dart    # Pure Dart domain entity
        │   ├── repositories/
        │   │   └── product_repository.dart # Interface definition
        │   └── usecases/
        │       ├── create_product.dart
        │       ├── delete_product.dart
        │       ├── get_product.dart
        │       ├── get_products.dart
        │       └── update_product.dart
        └── presentation/
            ├── bloc/
            │   ├── product_bloc.dart # BLoC state controller mapping events to use cases
            │   ├── product_event.dart # Freezed UI events
            │   └── product_state.dart # Freezed UI states
            ├── pages/
            │   ├── product_detail_page.dart # Details view (uses custom BLoC instance)
            │   └── product_list_page.dart   # Main view displaying the product grid
            └── widgets/
                ├── product_card.dart  # Grid card widget
                └── product_form_dialog.dart # Form dialog for adding/editing items
```

---

## 🛠 Dependency Injection & Accessing CRUD Anywhere

All singletons are registered globally in the GetIt service locator (`sl`) located at [injection_container.dart](file:///Users/vishalkonda/Downloads/am5vendor/lib/core/di/injection_container.dart). 

Because the `ProductBloc` is provided globally at the root of the widget tree in `main.dart`, you can access and trigger CRUD actions from **anywhere in the app** using the context:

```dart
// To Read/Search products list
context.read<ProductBloc>().add(const ProductEvent.loadProducts(search: 'keyboard'));

// To Create a product
context.read<ProductBloc>().add(
  ProductEvent.createProduct(
    name: 'Mechanical Keyboard',
    description: 'Hot-swappable switches',
    price: 129.99,
    stock: 20,
    imageUrl: 'https://...',
    category: 'Electronics',
  ),
);

// To Update a product
context.read<ProductBloc>().add(
  ProductEvent.updateProduct(
    id: '123',
    name: 'Updated Keyboard Name',
    price: 139.99,
  ),
);

// To Delete a product
context.read<ProductBloc>().add(ProductEvent.deleteProduct('123'));
```

---

## 🌐 In-Memory Mock API Server

To enable local run and testing without configuring an external server, the [api_client.dart](file:///Users/vishalkonda/Downloads/am5vendor/lib/core/network/api_client.dart) contains a custom `MockApiInterceptor`. 

This interceptor intercepts all HTTP requests sent to the base URL and resolves them with realistic JSON responses after a simulated **600ms network delay**. Any additions, modifications, or deletions persist in memory during the app session, giving you a true production experience with loading animations and snackbars.

---

## 🎨 Theme & Google Fonts

The system uses **Google Fonts (Outfit)** for sleek typography.
*   **Primary Palette:** Vibrant Indigo (`0xFF6366F1`) & Emerald Green (`0xFF10B981`).
*   **Gradients:** Custom primary and accent gradients applied on buttons and banners.
*   **Sleek Cards:** Fitted with thin borders and glassmorphism styling, adapting automatically to the device's system light and dark modes.
