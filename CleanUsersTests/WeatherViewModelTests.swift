import Domain
import XCTest
@testable import CleanUsers

/// The view model only formats what the use case returns; the fetch / save / fall-back rules are tested in Domain.
@MainActor
final class WeatherViewModelTests: XCTestCase {
    private var getWeather: FakeGetWeather!
    private var viewModel: WeatherViewModel!

    override func setUp() {
        super.setUp()
        getWeather = FakeGetWeather()
        viewModel = WeatherViewModel(user: .fixture(), getWeather: getWeather)
    }

    private func loaded(file: StaticString = #filePath, line: UInt = #line) -> WeatherDisplay? {
        guard case .loaded(let display) = viewModel.state else {
            XCTFail("expected loaded, got \(viewModel.state)", file: file, line: line)
            return nil
        }
        return display
    }

    func test_load_formatsFreshWeather() async {
        await viewModel.load()

        guard let display = loaded() else { return }
        XCTAssertEqual(display.location, "Gwenborough  (-37.3159, 81.1496)")
        XCTAssertEqual(display.temperature, "12°C")
        XCTAssertEqual(display.condition, "Overcast")
        XCTAssertEqual(display.symbol, "cloud.fill")
        XCTAssertEqual(display.details.map(\.value), ["7°C", "70%", "29 km/h"])
        XCTAssertEqual(display.forecast.map(\.day), ["Today", "Thu"])
        XCTAssertEqual(display.forecast.first?.range, "10° / 13°")
        XCTAssertEqual(display.forecast.last?.symbol, "cloud.rain.fill")
        XCTAssertNil(display.offlineBanner)
    }

    func test_staleResult_showsOfflineBanner() async {
        getWeather.result = .success(WeatherResult(weather: .fixture, staleSince: Date()))
        await viewModel.load()
        XCTAssertTrue(loaded()?.offlineBanner?.hasPrefix("Offline") == true)
    }

    func test_noCoordinate_failsWithoutRetry() async {
        getWeather.result = .failure(WeatherError.noCoordinate)
        await viewModel.load()
        XCTAssertEqual(viewModel.state, .failed(message: "This address has no valid coordinates.", canRetry: false))
    }

    func test_unavailable_forNonFavourite_suggestsFavouriting() async {
        getWeather.result = .failure(WeatherError.unavailable(message: "boom", userIsFavorite: false))
        await viewModel.load()

        guard case .failed(let message, let canRetry) = viewModel.state else { return XCTFail("expected failure") }
        XCTAssertTrue(canRetry)
        XCTAssertTrue(message.contains("boom"))
        XCTAssertTrue(message.contains("Favourite this user"))
    }

    func test_unavailable_forFavourite_hasNoHint() async {
        getWeather.result = .failure(WeatherError.unavailable(message: "boom", userIsFavorite: true))
        await viewModel.load()

        guard case .failed(let message, _) = viewModel.state else { return XCTFail("expected failure") }
        XCTAssertFalse(message.contains("Favourite this user"))
    }

    func test_unexpectedError_isRetryable() async {
        getWeather.result = .failure(TestError())
        await viewModel.load()
        XCTAssertEqual(viewModel.state, .failed(message: "Couldn't load the weather.\nboom", canRetry: true))
    }

    func test_conditionsHaveWordingAndIcons() {
        for condition in [WeatherCondition.clear, .partlyCloudy, .overcast, .fog, .drizzle, .rain,
                          .rainShowers, .snow, .snowShowers, .thunderstorm, .unknown] {
            XCTAssertFalse(condition.title.isEmpty)
            XCTAssertFalse(condition.symbolName.isEmpty)
        }
    }
}
