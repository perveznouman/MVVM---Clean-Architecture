import SwiftUI

/// SCREEN 4. Renders a `WeatherDisplay`; every string it shows was formatted by the view model.
struct WeatherView: View {
    @State private var viewModel: WeatherViewModel

    init(viewModel: WeatherViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .failed(let message, let canRetry):
                ContentUnavailableView {
                    Label("Weather Unavailable", systemImage: "cloud.slash")
                } description: {
                    Text(message)
                } actions: {
                    if canRetry { Button("Try Again") { Task { await viewModel.load() } } }
                }
            case .loaded(let weather):
                content(for: weather)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func content(for weather: WeatherDisplay) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                if let banner = weather.offlineBanner {
                    Text(banner).font(.footnote).foregroundStyle(.orange).multilineTextAlignment(.center)
                }
                currentCard(weather)
                detailsCard(weather.details)
                forecastCard(weather.forecast)
            }
            .padding()
        }
    }

    private func currentCard(_ weather: WeatherDisplay) -> some View {
        VStack(spacing: 8) {
            Text(weather.location).font(.subheadline).foregroundStyle(.secondary)
            Image(systemName: weather.symbol).font(.system(size: 56)).foregroundStyle(.blue)
            Text(weather.temperature).font(.system(size: 52, weight: .bold))
            Text(weather.condition).font(.title3)
        }
        .frame(maxWidth: .infinity)
        .card()
        .accessibilityElement(children: .combine)
    }

    private func detailsCard(_ details: [WeatherDisplay.Detail]) -> some View {
        VStack(spacing: 10) {
            ForEach(details, id: \.title) { detail in
                HStack {
                    Text(detail.title).foregroundStyle(.secondary)
                    Spacer()
                    Text(detail.value)
                }
            }
        }
        .card()
    }

    private func forecastCard(_ forecast: [WeatherDisplay.ForecastDay]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FORECAST").font(.caption).foregroundStyle(.secondary)
            ForEach(forecast, id: \.day) { day in
                HStack(spacing: 12) {
                    Text(day.day).frame(width: 56, alignment: .leading)
                    Image(systemName: day.symbol).foregroundStyle(.blue).frame(width: 28)
                    Spacer()
                    Text(day.range)
                }
            }
        }
        .card()
    }
}

private extension View {
    func card() -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
