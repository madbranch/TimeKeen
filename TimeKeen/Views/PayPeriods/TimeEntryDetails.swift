import SwiftUI

struct TimeEntryDetails: View {
  @Bindable var viewModel: TimeEntryViewModel
  
  init(viewModel: TimeEntryViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    VStack {
      DatePicker("Clocked In At", selection: $viewModel.timeEntry.start, in: ...viewModel.timeEntry.end, displayedComponents: [.date, .hourAndMinute])
        .datePickerStyle(.compact)
        .padding()
      DatePicker("Clocked Out At", selection: $viewModel.timeEntry.end, in: viewModel.timeEntry.start..., displayedComponents: [.date, .hourAndMinute])
        .datePickerStyle(.compact)
        .padding()
      LabeledContent("Notes") {
        TextField("Optional", text: $viewModel.timeEntry.notes, axis: .vertical)
          .textFieldStyle(.roundedBorder)
      }
      .padding()
      Spacer()
    }
    .navigationTitle("\(viewModel.timeEntry.start.formatted(date: .abbreviated, time: .omitted))")
  }
}
