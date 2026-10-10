import Domain
import Foundation
import Observation

/// Display-ready weather. All string formatting and icon choice happens here, not in the view.
struct WeatherDisplay: Equatable {
    struct Detail: Equatable {
        let title: String
        let value: String
    }

    struct ForecastDay: Equatable {
        let day: String
        let symbol: String
        let range: String
    }

    let location: String
    let symbol: String
    let temperature: String
    let condition: String
    let details: [Detail]
    let forecast: [ForecastDay]
    /// Set when showing a saved report because the network request failed.
    let offlineBanner: String?
}

enum WeatherViewState: Equatable {
    case loading
    case loaded(WeatherDisplay)
    case failed(message: String, canRetry: Bool)
}

@MainActor @Observable
final class WeatherViewModel {
    private(set) var state: WeatherViewState = .loading

    let title = "Weather"

    private let user: User
    private let getWeather: GetWeatherUseCase

    init(user: User, getWeather: GetWeatherUseCase) {
        self.user = user
        self.getWeather = getWeather
    }

    /// The business rules (fetch, save for favourites, fall back to saved data) live in `GetWeatherUseCase`.
    /// This only turns its outcome into something displayable.
    func load() async {
        state = .loading
        do {
            let result = try await getWeather.execute(for: user)
            state = .loaded(display(for: result))
        } catch WeatherError.noCoordinate {
            state = .failed(message: "This address has no valid coordinates.", canRetry: false)
        } catch WeatherError.unavailable(let message, let userIsFavorite) {
            let hint = userIsFavorite ? "" : "\n\nFavourite this user while online to keep their weather offline."
            state = .failed(message: "Couldn't load the weather.\n\(message)\(hint)", canRetry: true)
        } catch {
            state = .failed(message: "Couldn't load the weather.\n\(error.localizedDescription)", canRetry: true)
        }
    }

    // MARK: Formatting

    private func display(for result: WeatherResult) -> WeatherDisplay {
        let weather = result.weather
        let current = weather.current
        let coordinate = user.address.coordinate.map { "  (\($0.latitude), \($0.longitude))" } ?? ""
        return WeatherDisplay(
            location: "\(user.address.city)\(coordinate)",
            symbol: current.condition.symbolName,
            temperature: "\(Int(current.temperature.rounded()))°C",
            condition: current.condition.title,
            details: [
                .init(title: "Feels like", value: "\(Int(current.apparentTemperature.rounded()))°C"),
                .init(title: "Humidity", value: "\(current.humidity)%"),
                .init(title: "Wind", value: "\(Int(current.windSpeed.rounded())) km/h")
            ],
            forecast: forecast(weather.daily),
            offlineBanner: result.staleSince.map {
                "Offline: showing weather saved \($0.formatted(date: .abbreviated, time: .shortened))"
            }
        )
    }

    private func forecast(_ days: [Weather.DailyForecast]) -> [WeatherDisplay.ForecastDay] {
        let weekday = DateFormatter()
        weekday.dateFormat = "EEE"
        weekday.timeZone = TimeZone(identifier: "UTC") // forecast dates are calendar days at 00:00 UTC

        return days.prefix(5).enumerated().map { index, day in
            WeatherDisplay.ForecastDay(
                day: index == 0 ? "Today" : weekday.string(from: day.date),
                symbol: day.condition.symbolName,
                range: "\(Int(day.minTemperature.rounded()))° / \(Int(day.maxTemperature.rounded()))°"
            )
        }
    }
}
