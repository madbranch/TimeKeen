import SwiftUI

struct TimeEntryDetails: View {
  @Bindable var timeEntry: TimeEntry
  @Environment(\.editMode) private var editMode
  @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15
  @State var isEditingBreak = false
  @State var isAddingBreak = false
  @State var breakStart = Date()
  @State var breakEnd = Date()
  @State var breakEntry: BreakEntry?
  
  init(timeEntry: TimeEntry) {
    self.timeEntry = timeEntry
  }
  
  var body: some View {
    List {
      Section("Entry") {
        LabeledContent("Duration") {
          Text(Formatting.timeIntervalFormatter.string(from: timeEntry.onTheClock) ?? "")
        }
        if editMode?.wrappedValue.isEditing == true {
          LabeledContent("Start") {
            IntervalDatePicker(selection: $timeEntry.start, minuteInterval: minuteInterval, in: ...timeEntry.end, displayedComponents: [.date, .hourAndMinute])
          }
          LabeledContent("End") {
            IntervalDatePicker(selection: $timeEntry.end, minuteInterval: minuteInterval, in: timeEntry.start..., displayedComponents: [.date, .hourAndMinute])
          }
          TextField("Notes", text: $timeEntry.notes, axis: .vertical)
            .submitLabel(.done)
        } else {
          LabeledContent("Start") {
            Text(Formatting.startEndWithDateFormatter.string(from: timeEntry.start))
          }
          LabeledContent("End") {
            Text(Formatting.startEndWithDateFormatter.string(from: timeEntry.end))
          }
        }
        if editMode?.wrappedValue.isEditing != true && !timeEntry.notes.isEmpty {
          Text(timeEntry.notes)
        }
      }
      Section("Breaks") {
        ForEach(timeEntry.breaks) { breakEntry in
          HStack {
            Text("\(Formatting.startEndFormatter.string(from: breakEntry.start)) - \(Formatting.startEndFormatter.string(from: breakEntry.end))")
            Spacer()
            Text(Formatting.timeIntervalFormatter.string(from: breakEntry.interval) ?? "")
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
        .onDelete { offsets in
          timeEntry.breaks.remove(atOffsets: offsets)
        }
      }
    }
    .toolbar {
      if editMode?.wrappedValue.isEditing == true {
        Button("Add Break") {
          breakStart = timeEntry.start
          breakEnd = timeEntry.end
          isAddingBreak = true
        }
      }
      EditButton()
    }
    .navigationTitle("\(timeEntry.start.formatted(date: .abbreviated, time: .omitted))")
    .sheet(isPresented: $isAddingBreak) {
      VStack {
        Text("Add Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel") {
              isAddingBreak = false
            }
          }
        LabeledContent("From") {
          IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: timeEntry.start...timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
        LabeledContent("To") {
          IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: timeEntry.start...timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
        Button(action: {
          timeEntry.breaks.append(BreakEntry(start: breakStart, end: breakEnd))
          isAddingBreak = false
        }) {
          Text("Add Break")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxHeight: .infinity, alignment: .bottom)
      }
      .padding()
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $isEditingBreak) {
      VStack {
        Text("Edit Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel") {
              isEditingBreak = false
            }
          }
        LabeledContent("From") {
          IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: timeEntry.start...timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
        LabeledContent("To") {
          IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: timeEntry.start...timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        }
        Button(action: {
          if let entry = breakEntry {
            entry.start = breakStart
            entry.end = breakEnd
          }
          isEditingBreak = false
        }) {
          Text("Save")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxHeight: .infinity, alignment: .bottom)
      }
      .padding()
      .presentationDetents([.medium])
    }
  }
}
