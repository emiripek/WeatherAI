WeatherAI (iOS)

A simple, native iOS weather app that shows the current conditions and hourly forecasts for your current location. It uses OpenWeatherMap for data, Core Location for geolocation, and Core Data for lightweight offline caching.

**Overview**
- Current weather with icon, temperature, and description
- Hourly 5-day/3-hour forecast in a collection view
- Offline support via Core Data cache and reachability checks
- Location permission flow with helpful Settings prompt
- Built with UIKit and MVC-style organization

**Requirements**
- Xcode 15+
- iOS 17.2+ (deployment target)
- Swift 5
- OpenWeatherMap API key

**Getting Started**
- Clone the repository and open the Xcode project `WeatherAI.xcodeproj`.
- Add your OpenWeatherMap API key:
  - Replace the placeholder in `WeatherAI/Manager/NetworkManager.swift:16` and `WeatherAI/Manager/NetworkManager.swift:58` with your own key (value for `appid=`).
  - Note: The project currently hard-codes the key; for production, prefer an `.xcconfig`, Info.plist entry, or a build setting.
- Ensure location usage description exists in `WeatherAI/Info.plist:1` and that your device/simulator grants permission.
- Select a signing team and unique bundle identifier if needed (`WeatherAI.xcodeproj/project.pbxproj:393`).
- Build and run on a device or simulator.

**Features**
- Current weather: City name, condition icon, description, and temperature
- Hourly forecast list: Time-sliced forecast cells with icon and temperature
- Offline mode: Falls back to last cached weather and forecast when no network
- Graceful permission handling: Guides user to Settings when location is denied

**Architecture & Data Flow**
- Pattern: Pragmatic MVC with lightweight managers
- Networking: `URLSession` calls to OpenWeatherMap
  - Current weather endpoint: `/data/2.5/weather`
  - Forecast endpoint: `/data/2.5/forecast`
- Caching: Core Data stores latest current weather and a set of forecast entries
- Reachability: Simple reachability check gates network vs. cache reads
- Location: `CLLocationManager` provides coordinates for API requests

**Key Components**
- UI
  - `WeatherAI/Controller/WeatherVC.swift:1`: Main screen controller (labels, icon image, and forecast list)
  - `WeatherAI/View/WeatherCollectionViewCell.swift:1`: Forecast cell UI and image loading
  - `WeatherAI/View/GradientView.swift:1`: Background gradient view
  - Storyboards: `WeatherAI/Base.lproj/Main.storyboard`, `WeatherAI/Base.lproj/LaunchScreen.storyboard`
- Networking & Managers
  - `WeatherAI/Manager/NetworkManager.swift:1`: Fetches current weather and forecast, downloads icons, persists cache
  - `WeatherAI/Manager/LocationManager.swift:1`: Location permission flow and current location retrieval
  - `WeatherAI/Manager/CoreDataManager.swift:1`: Saves and fetches cached models
  - `WeatherAI/Reachability.swift:1`: Network reachability utility
- Models
  - `WeatherAI/Model/Weather.swift:1`: Current weather response types
  - `WeatherAI/Model/WeatherForecast.swift:1`: Forecast response types
- Persistence
  - Core Data model: `WeatherAI/WeatherCoreData.xcdatamodeld/WeatherCoreData.xcdatamodel/contents`
    - Entities: `WeatherEntity`, `ForecastEntity`

**How It Works**
- On launch, `WeatherVC` requests the current location via `LocationManager`.
- With coordinates, `NetworkManager` fetches current and forecast data from OpenWeatherMap.
- Successful responses are saved through `CoreDataManager` (including downloaded icon data).
- When offline (checked via `Reachability`), the app loads the latest cached data instead.

**Configuration Notes**
- API Key: Replace the hard-coded key in `NetworkManager` with your own.
  - Current weather: `WeatherAI/Manager/NetworkManager.swift:16`
  - Forecast: `WeatherAI/Manager/NetworkManager.swift:58`
- Location Permission: The app requests When-In-Use authorization and explains the reason in `Info.plist`.
- Default Coordinates: `WeatherVC` initializes with Istanbul coordinates and updates once location is available.

**Permissions**
- Location When In Use: Requested to provide local weather
  - Description string defined in `WeatherAI/Info.plist:1`

**Offline & Caching**
- Current weather and forecast entries are persisted for offline viewing.
- On no connectivity, the UI displays the last known data and icons from cache.

**Troubleshooting**
- No data shown: Verify location permission, network connectivity, and API key.
- Build issues: Confirm Xcode 15+, iOS 17.2+ target, and valid signing.
- Icons missing: Ensure the app was online at least once to cache icons.

**Roadmap Ideas**
- Search by city name and saved locations
- Unit tests and UI tests
- Error states and loading indicators
- Swift concurrency (`async/await`) networking
- Move API key to secure config (e.g., `.xcconfig`)

**Acknowledgements**
- Weather data by OpenWeatherMap

