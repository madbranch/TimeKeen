import SwiftUI

struct TimeEntryDetails: View {
  @Bindable var viewModel: TimeEntryViewModel
  @Environment(\.editMode) private var editMode
  @AppStorage("MinuteInterval") var minuteInterval = 15
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
          LabeledContent("Start") {
            IntervalDatePicker(selection: $viewModel.timeEntry.start, minuteInterval: minuteInterval, in: ...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
          }
          LabeledContent("End") {
            IntervalDatePicker(selection: $viewModel.timeEntry.end, minuteInterval: minuteInterval, in: viewModel.timeEntry.start..., displayedComponents: [.date, .hourAndMinute])
          }
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
          .contentShape(Rectangle())
          .onTapGesture {
            guard editMode?.wrappedValue.isEditing == true else {
              return
            }
            self.breakEntry = breakEntry
            breakStart = breakEntry.start
            breakEnd = breakEntry.end
            isEditingBreak = true
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
        LabeledContent("From") {
          IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: viewModel.timeEntry.start...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        LabeledContent("To") {
          IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: viewModel.timeEntry.start...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
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
    .sheet(isPresented: $isEditingBreak) {
      VStack {
        LabeledContent("From") {
          IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: viewModel.timeEntry.start...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        LabeledContent("To") {
          IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: viewModel.timeEntry.start...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        Button("Save", action: {
          if let entry = breakEntry {
            entry.start = breakStart
            entry.end = breakEnd
          }
          isEditingBreak = false
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
      .presentationDetents([.fraction(0.4)])
    }
  }
}
