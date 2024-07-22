import SwiftUI

struct TimeEntryDetails: View {
  @Bindable var viewModel: TimeEntryViewModel
  @Environment(\.editMode) private var editMode
  
  init(viewModel: TimeEntryViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    List {
      Section("Entry") {
        LabeledContent("Duration") {
          Text(viewModel.timeEntry.duration.formatted(Formatting.durationStyle))
        }
        if editMode?.wrappedValue.isEditing == true {
          DatePicker("Start", selection: $viewModel.timeEntry.start, in: ...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
          DatePicker("End", selection: $viewModel.timeEntry.end, in: viewModel.timeEntry.start..., displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
          TextField("Notes", text: $viewModel.timeEntry.notes, axis: .vertical)
        } else {
          LabeledContent("Start") {
            Text(Formatting.startEndWithDateFormatter.string(from: viewModel.timeEntry.start))
          }
          LabeledContent("End") {
            Text(Formatting.startEndWithDateFormatter.string(from: viewModel.timeEntry.end))
          }
        }
        if editMode?.wrappedValue.isEditing != true && !viewModel.timeEntry.notes.isEmpty {
          Text(viewModel.timeEntry.notes)
        }
      }
      Section("Breaks") {
        ForEach(viewModel.timeEntry.breaks) { breakEntry in
          HStack {
            Text("\(Formatting.startEndFormatter.string(from: breakEntry.start)) - \(Formatting.startEndFormatter.string(from: breakEntry.end))")
            Spacer()
            Text(breakEntry.duration.formatted(Formatting.durationStyle))
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
