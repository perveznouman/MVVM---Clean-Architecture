import Domain

/// How a domain weather condition is worded and drawn. This is a UI decision, so it lives in Presentation.
extension WeatherCondition {
    var title: String {
        switch self {
        case .clear: return "Clear sky"
        case .partlyCloudy: return "Partly cloudy"
        case .overcast: return "Overcast"
        case .fog: return "Fog"
        case .drizzle: return "Drizzle"
        case .rain: return "Rain"
        case .rainShowers: return "Rain showers"
        case .snow: return "Snow"
        case .snowShowers: return "Snow showers"
        case .thunderstorm: return "Thunderstorm"
        case .unknown: return "Unknown"
        }
    }

    var symbolName: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .overcast: return "cloud.fill"
        case .fog: return "cloud.fog.fill"
        case .drizzle: return "cloud.drizzle.fill"
        case .rain, .rainShowers: return "cloud.rain.fill"
        case .snow, .snowShowers: return "cloud.snow.fill"
        case .thunderstorm: return "cloud.bolt.rain.fill"
        case .unknown: return "questionmark.circle"
        }
    }
}
