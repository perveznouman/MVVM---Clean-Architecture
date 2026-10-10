import XCTest
import Domain
@testable import DataLayer

final class MappingTests: XCTestCase {
    private let userJSON = """
    [{"id":1,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz",
      "address":{"street":"Kulas Light","suite":"Apt. 556","city":"Gwenborough","zipcode":"92998-3874",
                 "geo":{"lat":"-37.3159","lng":"81.1496"}},
      "phone":"1-770-736-8031 x56442","website":"hildegard.org",
      "company":{"name":"Romaguera-Crona","catchPhrase":"Multi-layered","bs":"harness"}}]
    """

    func test_userDTO_decodesAndMapsToDomain() throws {
        let dtos = try JSONDecoder().decode([UserDTO].self, from: Data(userJSON.utf8))
        let user = dtos[0].toDomain()

        XCTAssertEqual(user.name, "Leanne Graham")
        XCTAssertEqual(user.address.coordinate, Coordinate(latitude: -37.3159, longitude: 81.1496))
        XCTAssertEqual(user.avatarURL?.absoluteString, "https://i.pravatar.cc/300?img=1")
    }

    func test_userDTO_withUnparsableCoordinates_mapsToNilCoordinate() throws {
        let json = userJSON.replacingOccurrences(of: "\"-37.3159\"", with: "\"abc\"")
        let user = try JSONDecoder().decode([UserDTO].self, from: Data(json.utf8))[0].toDomain()
        XCTAssertNil(user.address.coordinate)
    }

    func test_weatherDTO_mapsCodesAndDates() throws {
        let json = """
        {"current":{"temperature_2m":12.4,"apparent_temperature":7.2,"relative_humidity_2m":70,
                    "wind_speed_10m":28.6,"weather_code":3},
         "daily":{"time":["2026-10-07","2026-10-08"],"weather_code":[3,61],
                  "temperature_2m_max":[12.6,13],"temperature_2m_min":[10,11]}}
        """
        let weather = try JSONDecoder().decode(WeatherDTO.self, from: Data(json.utf8)).toDomain()

        XCTAssertEqual(weather.current.condition, .overcast)
        XCTAssertEqual(weather.current.humidity, 70)
        XCTAssertEqual(weather.daily.map(\.condition), [.overcast, .rain])
        XCTAssertEqual(weather.daily[0].date, Date(timeIntervalSince1970: 1791331200)) // 2026-10-07 00:00 UTC
    }

    func test_wmoCodes() {
        XCTAssertEqual(WeatherCondition(wmoCode: 0), .clear)
        XCTAssertEqual(WeatherCondition(wmoCode: 95), .thunderstorm)
        XCTAssertEqual(WeatherCondition(wmoCode: 1234), .unknown)
    }

    func test_weatherCache_roundTripsThroughJSON() throws {
        let weather = Weather(
            current: .init(temperature: 1, apparentTemperature: 2, humidity: 3, windSpeed: 4, condition: .snow),
            daily: [.init(date: Date(timeIntervalSince1970: 10), condition: .fog, minTemperature: 5, maxTemperature: 6)])
        let data = try JSONEncoder().encode(WeatherCacheDTO(weather))
        XCTAssertEqual(try JSONDecoder().decode(WeatherCacheDTO.self, from: data).toDomain(), weather)
    }
}
