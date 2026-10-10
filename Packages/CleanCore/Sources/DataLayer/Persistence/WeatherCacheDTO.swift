import Domain
import Foundation

/// How a `Weather` is stored on disk (JSON in a Core Data binary attribute). Independent of the API shape,
/// so a change in Open-Meteo's payload never invalidates saved data.
struct WeatherCacheDTO: Codable {
    struct Current: Codable {
        let temperature: Double
        let apparentTemperature: Double
        let humidity: Int
        let windSpeed: Double
        let condition: String
    }

    struct Day: Codable {
        let date: Date
        let condition: String
        let minTemperature: Double
        let maxTemperature: Double
    }

    let current: Current
    let daily: [Day]

    init(_ weather: Weather) {
        current = .init(temperature: weather.current.temperature,
                        apparentTemperature: weather.current.apparentTemperature,
                        humidity: weather.current.humidity,
                        windSpeed: weather.current.windSpeed,
                        condition: weather.current.condition.rawValue)
        daily = weather.daily.map {
            Day(date: $0.date, condition: $0.condition.rawValue,
                minTemperature: $0.minTemperature, maxTemperature: $0.maxTemperature)
        }
    }

    func toDomain() -> Weather {
        Weather(
            current: .init(temperature: current.temperature,
                           apparentTemperature: current.apparentTemperature,
                           humidity: current.humidity,
                           windSpeed: current.windSpeed,
                           condition: WeatherCondition(rawValue: current.condition) ?? .unknown),
            daily: daily.map {
                .init(date: $0.date, condition: WeatherCondition(rawValue: $0.condition) ?? .unknown,
                      minTemperature: $0.minTemperature, maxTemperature: $0.maxTemperature)
            }
        )
    }
}
