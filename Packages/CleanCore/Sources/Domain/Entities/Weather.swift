import Foundation

/// Weather conditions as the business understands them. Raw API codes (WMO) are translated in the Data layer;
/// icons and wording are decided in Presentation.
public enum WeatherCondition: String, Equatable, Sendable {
    case clear, partlyCloudy, overcast, fog, drizzle, rain, rainShowers, snow, snowShowers, thunderstorm, unknown
}

public struct Weather: Equatable, Sendable {
    public struct Current: Equatable, Sendable {
        public let temperature: Double          // °C
        public let apparentTemperature: Double  // °C
        public let humidity: Int                // %
        public let windSpeed: Double            // km/h
        public let condition: WeatherCondition

        public init(temperature: Double, apparentTemperature: Double, humidity: Int,
                    windSpeed: Double, condition: WeatherCondition) {
            self.temperature = temperature
            self.apparentTemperature = apparentTemperature
            self.humidity = humidity
            self.windSpeed = windSpeed
            self.condition = condition
        }
    }

    public struct DailyForecast: Equatable, Sendable {
        /// Calendar day at 00:00 UTC. Format with a UTC time zone to show the forecast's own day.
        public let date: Date
        public let condition: WeatherCondition
        public let minTemperature: Double
        public let maxTemperature: Double

        public init(date: Date, condition: WeatherCondition, minTemperature: Double, maxTemperature: Double) {
            self.date = date
            self.condition = condition
            self.minTemperature = minTemperature
            self.maxTemperature = maxTemperature
        }
    }

    public let current: Current
    public let daily: [DailyForecast]

    public init(current: Current, daily: [DailyForecast]) {
        self.current = current
        self.daily = daily
    }
}

/// A weather report saved for offline use.
public struct CachedWeather: Equatable, Sendable {
    public let weather: Weather
    public let updatedAt: Date

    public init(weather: Weather, updatedAt: Date) {
        self.weather = weather
        self.updatedAt = updatedAt
    }
}

/// What `GetWeatherUseCase` returns: fresh data, or saved data (with the time it was saved) when offline.
public struct WeatherResult: Equatable, Sendable {
    public let weather: Weather
    /// `nil` = fresh from the network. Non-nil = a saved copy from this date.
    public let staleSince: Date?

    public init(weather: Weather, staleSince: Date?) {
        self.weather = weather
        self.staleSince = staleSince
    }
}
