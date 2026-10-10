import Domain
import Foundation

/// Mirrors the Open-Meteo forecast payload. Never leaves the Data layer.
struct WeatherDTO: Decodable {
    struct Current: Decodable {
        let temperature: Double
        let apparentTemperature: Double
        let humidity: Int
        let windSpeed: Double
        let weatherCode: Int

        enum CodingKeys: String, CodingKey {
            case temperature = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case humidity = "relative_humidity_2m"
            case windSpeed = "wind_speed_10m"
            case weatherCode = "weather_code"
        }
    }

    struct Daily: Decodable {
        let dates: [String]
        let weatherCodes: [Int]
        let maxTemperatures: [Double]
        let minTemperatures: [Double]

        enum CodingKeys: String, CodingKey {
            case dates = "time"
            case weatherCodes = "weather_code"
            case maxTemperatures = "temperature_2m_max"
            case minTemperatures = "temperature_2m_min"
        }
    }

    let current: Current
    let daily: Daily
}

extension WeatherDTO {
    func toDomain() -> Weather {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"

        let count = min(daily.dates.count, daily.weatherCodes.count,
                        daily.maxTemperatures.count, daily.minTemperatures.count)
        let forecast: [Weather.DailyForecast] = (0..<count).compactMap { index in
            guard let date = formatter.date(from: daily.dates[index]) else { return nil }
            return Weather.DailyForecast(
                date: date,
                condition: WeatherCondition(wmoCode: daily.weatherCodes[index]),
                minTemperature: daily.minTemperatures[index],
                maxTemperature: daily.maxTemperatures[index]
            )
        }
        return Weather(
            current: .init(temperature: current.temperature,
                           apparentTemperature: current.apparentTemperature,
                           humidity: current.humidity,
                           windSpeed: current.windSpeed,
                           condition: WeatherCondition(wmoCode: current.weatherCode)),
            daily: forecast
        )
    }
}

extension WeatherCondition {
    /// WMO weather interpretation codes -> domain condition.
    init(wmoCode code: Int) {
        switch code {
        case 0: self = .clear
        case 1, 2: self = .partlyCloudy
        case 3: self = .overcast
        case 45, 48: self = .fog
        case 51...57: self = .drizzle
        case 61...67: self = .rain
        case 71...77: self = .snow
        case 80...82: self = .rainShowers
        case 85, 86: self = .snowShowers
        case 95...99: self = .thunderstorm
        default: self = .unknown
        }
    }
}
