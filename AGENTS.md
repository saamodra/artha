# Project Instructions

## Tech Stack

- Use Supabase as backend-as-a-service to store data and post data
- Flutter/Dart for frontend
- Supabase Flutter SDK for API communication

## Architecture Pattern: Repository Pattern

### Layer Responsibilities

#### 1. **Models Layer** (`lib/models/`)
- **Purpose**: Define data structures and entities
- **Responsibilities**:
  - Data classes (Wallet, WalletRecord, Debt, etc.)
  - JSON serialization/deserialization (`toJson()`, `fromJson()`)
  - Data validation and type safety
- **Rules**:
  - No business logic
  - No API calls
  - Pure data structures only

#### 2. **Repository Layer** (`lib/repositories/`)
- **Purpose**: Data access abstraction - handles ALL Supabase API calls
- **Responsibilities**:
  - CRUD operations to Supabase (Create, Read, Update, Delete)
  - Query construction and filtering
  - Error handling for network/database errors
  - Data transformation between Supabase and Models
- **Rules**:
  - NO business logic (no calculations, validations)
  - Only pure data operations
  - Return raw data or models
  - Handle Supabase-specific errors
- **Example**:
  ```dart
  class WalletRepository {
    final supabase = Supabase.instance.client;

    Future<List<Wallet>> getWallets() async {
      final data = await supabase.from('wallets').select();
      return data.map((json) => Wallet.fromJson(json)).toList();
    }

    Future<void> createWallet(Wallet wallet) async {
      await supabase.from('wallets').insert(wallet.toJson());
    }
  }
  ```

#### 3. **Service Layer** (`lib/services/`)
- **Purpose**: Business logic and orchestration
- **Responsibilities**:
  - Business rules and calculations (balance, totals, etc.)
  - Data aggregation from multiple repositories
  - Complex operations (e.g., transfer = debit + credit)
  - State management (extends ChangeNotifier)
  - Validation rules
- **Rules**:
  - NO direct Supabase calls (use repositories instead)
  - Contains all business logic
  - Can call multiple repositories
  - Notifies UI of changes
- **Example**:
  ```dart
  class WalletService extends ChangeNotifier {
    final WalletRepository _repository;

    Future<double> getTotalBalance() async {
      final wallets = await _repository.getWallets();
      return wallets.fold(0.0, (sum, w) => sum + w.initialValue);
    }
  }
  ```

#### 4. **UI Layer** (`lib/pages/`, `lib/widgets/`)
- **Purpose**: User interface and user interactions
- **Responsibilities**:
  - Display data from services
  - Handle user input
  - Navigate between screens
  - Show loading/error states
- **Rules**:
  - NO business logic
  - NO direct repository calls
  - Only call services
  - Handle UI state only

### Data Flow

```
User Action (UI)
    ↓
Service (validates & orchestrates)
    ↓
Repository (calls Supabase)
    ↓
Supabase API
    ↓
Repository (returns data)
    ↓
Service (processes & notifies)
    ↓
UI (updates display)
```

## Folder Structure

```
lib/
├── models/              # Data entities & JSON serialization
├── repositories/        # Supabase API calls (NEW - CREATE THIS)
├── services/           # Business logic & calculations
├── pages/              # Full-screen UI pages
├── widgets/            # Reusable UI components
├── auth_service.dart   # Authentication logic
└── main.dart          # App entry point
```

## Key Principles

1. **Separation of Concerns**: Each layer has ONE responsibility
2. **Dependency Direction**: UI → Services → Repositories → Supabase
3. **No Layer Skipping**: UI must NOT call repositories directly
4. **Business Logic Belongs in Services**: All calculations, validations, and rules
5. **Repositories are Dumb**: Just fetch/save data, no logic
6. **Models are Pure**: Just data structures, no behavior

## Migration Path

When refactoring existing services:
1. Create repository classes in `lib/repositories/`
2. Move all Supabase calls from services to repositories
3. Keep business logic in services
4. Update services to use repositories instead of direct Supabase calls
