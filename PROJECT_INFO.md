# Customer Management App

A modern Flutter customer management application with user authentication, paginated customer list, and clean architecture using GetX state management.

## Features

✅ **User Authentication**
- Secure login with username/password
- Session persistence using SharedPreferences
- Auto-navigation based on auth state

✅ **Customer List**
- Paginated customer data (20 items per page)
- Infinite scroll with load more functionality
- Pull-to-refresh support
- Search functionality
- Sort by balance

✅ **Customer Details**
- Display customer images with caching
- Show comprehensive customer information
- Tap to view detailed dialog

✅ **Error Handling**
- User-friendly error messages
- Network error handling
- Retry functionality
- Loading states

✅ **Clean Code Architecture**
- MVVM pattern with GetX
- Separation of concerns
- Reusable widgets
- Type-safe models

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── app/
│   └── theme/
│       └── app_theme.dart             # App theme configuration
├── core/
│   ├── constants/
│   │   └── api_constants.dart         # API endpoints and constants
│   ├── network/
│   │   └── api_client.dart            # Dio HTTP client with error handling
│   └── utils/
│       └── storage_utils.dart         # SharedPreferences wrapper
├── data/
│   ├── models/
│   │   ├── user_model.dart            # User data model
│   │   └── customer_model.dart        # Customer data model
│   └── repositories/
│       ├── auth_repository.dart       # Authentication API calls
│       └── customer_repository.dart   # Customer API calls
├── controllers/
│   ├── auth_controller.dart           # Authentication state management
│   └── customer_controller.dart       # Customer list state management
├── routes/
│   └── app_routes.dart                # Route definitions
└── views/
    ├── login/
    │   └── login_screen.dart          # Login UI
    └── customer_list/
        ├── customer_list_screen.dart  # Customer list UI
        └── widgets/
            └── customer_card.dart     # Customer card widget
```

## Dependencies

- **get**: ^4.6.6 - State management and routing
- **dio**: ^5.4.0 - HTTP client for API calls
- **shared_preferences**: ^2.2.2 - Local data persistence
- **cached_network_image**: ^3.3.1 - Image caching

## API Configuration

**Base URL**: `https://www.pqstec.com/InvoiceApps/Values/`  
**Image Base URL**: `https://www.pqstec.com/InvoiceApps/`

**Endpoints**:
- Login: `LogIn?UserName={username}&Password={password}&ComId={comId}`
- Customer List: `GetCustomerList?searchquery={query}&pageNo={page}&pageSize={size}&SortyBy={sort}`

**Default Credentials**:
- Username: `admin@gmail.com`
- Password: `admin1234`
- ComId: `1`

## Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd customer_management
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Usage

### Login
1. Launch the app
2. Enter your credentials (pre-filled with admin credentials)
3. Tap "Login"
4. On successful login, you'll be redirected to the customer list

### Customer List
1. View paginated customer list
2. Scroll down to load more customers (infinite scroll)
3. Pull down to refresh the list
4. Use search bar to filter customers
5. Tap on a customer card to view detailed information
6. Tap logout icon to sign out

## Key Features Implementation

### State Management (GetX)
- Reactive state management with `.obs` observables
- Dependency injection with `Get.lazyPut`
- Route management with `GetMaterialApp`

### Pagination
- Automatic load more on scroll (80% threshold)
- Page tracking and "has more data" state
- Loading indicators for initial and subsequent loads

### Error Handling
- Dio interceptor for network errors
- User-friendly error messages
- Retry functionality on errors
- Empty state handling

### Image Caching
- `CachedNetworkImage` for efficient image loading
- Placeholder while loading
- Error fallback with default icon

### Clean Architecture
- **Models**: Data structures with JSON serialization
- **Repositories**: API communication layer
- **Controllers**: Business logic and state management
- **Views**: UI components

## Screenshots

### Login Screen
- Clean, modern login interface
- Email and password fields with validation
- Loading state during authentication
- Error messages displayed inline

### Customer List
- Card-based customer display
- Customer image, name, code, contact info
- Balance with color coding (green/red)
- Search bar at the top
- Infinite scroll pagination

### Customer Details Dialog
- Full customer information
- Code, phone, email, address
- Customer type and balance
- Remarks if available

## Code Quality

- ✅ Clean, readable code with proper comments
- ✅ Consistent naming conventions
- ✅ Separation of concerns (MVVM)
- ✅ Reusable widgets
- ✅ Type-safe implementations
- ✅ Error handling at all layers
- ✅ No lint errors

## Future Enhancements

- [ ] Add customer editing functionality
- [ ] Implement offline mode with local database
- [ ] Add customer filtering by type
- [ ] Implement dark mode
- [ ] Add unit and widget tests
- [ ] Add customer creation
- [ ] Export customer list to CSV/PDF

## License

This project is created for demonstration purposes.

## Author

Built with ❤️ using Flutter and GetX
