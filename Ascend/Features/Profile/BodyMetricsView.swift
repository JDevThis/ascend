import SwiftUI
import Charts

struct BodyMetricsView: View {
    let viewModel: ProfileViewModel
    @State private var isPresentingNewEntry = false

    var body: some View {
        List {
            if !viewModel.bodyMetrics.isEmpty {
                Section("Weight Trend") {
                    Chart(viewModel.bodyMetrics.reversed()) { entry in
                        if let weight = entry.weightLb {
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", weight)
                            )
                            .foregroundStyle(AscendColor.accent)
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .frame(height: 160)
                }
            }

            Section("History") {
                if viewModel.bodyMetrics.isEmpty {
                    Text("No entries yet. Tap + to log your weight.")
                        .foregroundStyle(AscendColor.textSecondary)
                } else {
                    ForEach(viewModel.bodyMetrics) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                if let weight = entry.weightLb {
                                    Text("\(String(format: "%.1f", weight)) lb")
                                        .fontWeight(.semibold)
                                }
                            }
                            if entry.bodyFatPercentage != nil || entry.chestIn != nil || entry.waistIn != nil {
                                Text(measurementSummary(entry))
                                    .font(AscendFont.footnote())
                                    .foregroundStyle(AscendColor.textSecondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteMetric(viewModel.bodyMetrics[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("Body Metrics")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingNewEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewEntry) {
            NewMetricSheet(viewModel: viewModel)
        }
    }

    private func measurementSummary(_ entry: BodyMetricEntry) -> String {
        var parts: [String] = []
        if let bf = entry.bodyFatPercentage { parts.append("BF \(String(format: "%.1f", bf))%") }
        if let chest = entry.chestIn { parts.append("Chest \(String(format: "%.1f", chest))in") }
        if let waist = entry.waistIn { parts.append("Waist \(String(format: "%.1f", waist))in") }
        return parts.joined(separator: " · ")
    }
}

private struct NewMetricSheet: View {
    let viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var weight = ""
    @State private var bodyFat = ""
    @State private var chest = ""
    @State private var waist = ""
    @State private var hips = ""
    @State private var arms = ""
    @State private var legs = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Section("Weight & Body Fat") {
                    TextField("Weight (lb)", text: $weight).keyboardType(.decimalPad)
                    TextField("Body Fat %", text: $bodyFat).keyboardType(.decimalPad)
                }
                Section("Measurements (in)") {
                    TextField("Chest", text: $chest).keyboardType(.decimalPad)
                    TextField("Waist", text: $waist).keyboardType(.decimalPad)
                    TextField("Hips", text: $hips).keyboardType(.decimalPad)
                    TextField("Arms", text: $arms).keyboardType(.decimalPad)
                    TextField("Legs", text: $legs).keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Log Metrics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.logMeasurements(
                            date: date,
                            weightLb: Double(weight),
                            bodyFat: Double(bodyFat),
                            chest: Double(chest),
                            waist: Double(waist),
                            hips: Double(hips),
                            arms: Double(arms),
                            legs: Double(legs)
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
