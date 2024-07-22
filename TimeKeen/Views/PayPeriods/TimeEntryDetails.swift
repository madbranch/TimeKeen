import SwiftUI

struct TimeEntryDetails: View {
  @Bindable var viewModel: TimeEntryViewModel
  @Environment(\.editMode) private var editMode
  @State var isEditingBreak = false
  @State var isAddingBreak = false
  @State var breakStart = Formatting.getRoundedDate()
  @State var breakEnd = Formatting.getRoundedDate()
  @State var breakEntry: BreakEntry?
  
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
          breakStart = viewModel.timeEntry.start
          breakEnd = viewModel.timeEntry.end
          isAddingBreak = true
        }
      }
      EditButton()
    }
    .navigationTitle("\(viewModel.timeEntry.start.formatted(date: .abbreviated, time: .omitted))")
    .sheet(isPresented: $isAddingBreak) {
      VStack {
        DatePicker("From", selection: $breakStart, in: viewModel.timeEntry.start...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        DatePicker("To", selection: $breakEnd, in: viewModel.timeEntry.start...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("Add Break", action: {
          viewModel.timeEntry.breaks.append(BreakEntry(start: breakStart, end: breakEnd))
          isAddingBreak = false
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
      .presentationDetents([.fraction(0.4)])
    }
  }
}
