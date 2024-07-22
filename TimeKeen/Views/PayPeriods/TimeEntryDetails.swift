import SwiftUI

struct TimeEntryDetails: View {
  @Bindable var viewModel: TimeEntryViewModel
  @Environment(\.editMode) private var editMode
  private let dateFormat: DateFormatter
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)
  private static let startEndFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()
  
  init(viewModel: TimeEntryViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.dateFormat = "HH:mm"
  }
  
  var body: some View {
    List {
      Section("Entry") {
        LabeledContent("Duration") {
          Text(viewModel.timeEntry.duration.formatted(TimeEntryDetails.durationStyle))
        }
        if editMode?.wrappedValue.isEditing == true {
          DatePicker("Start", selection: $viewModel.timeEntry.start, in: ...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
          DatePicker("End", selection: $viewModel.timeEntry.end, in: viewModel.timeEntry.start..., displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
          TextField("Notes", text: $viewModel.timeEntry.notes, axis: .vertical)
        } else {
          LabeledContent("Start") {
            Text(TimeEntryDetails.startEndFormatter.string(from: viewModel.timeEntry.start))
          }
          LabeledContent("End") {
            Text(TimeEntryDetails.startEndFormatter.string(from: viewModel.timeEntry.end))
          }
        }
        if editMode?.wrappedValue.isEditing != true && !viewModel.timeEntry.notes.isEmpty {
          Text(viewModel.timeEntry.notes)
        }
      }
      Section("Breaks") {
        ForEach(viewModel.timeEntry.breaks) { breakEntry in
          HStack {
            Text("\(dateFormat.string(from: breakEntry.start)) - \(dateFormat.string(from: breakEntry.end))")
            Spacer()
            Text(breakEntry.duration.formatted(TimeEntryDetails.durationStyle))
              .foregroundStyle(.secondary)
          }
        }
        .onDelete(perform: viewModel.deleteBreaks)
      }
    }
    .toolbar {
      if editMode?.wrappedValue.isEditing == true {
        Button("Add Break") {
          print("huh")
        }
      }
      EditButton()
    }
    .navigationTitle("\(viewModel.timeEntry.start.formatted(date: .abbreviated, time: .omitted))")
  }
}
