import SwiftUI

struct TimeEntrySharingView: View {
  @Bindable var viewModel: TimeEntrySharingViewModel
  @Environment(\.dismiss) private var dismiss
  
  init(viewModel: TimeEntrySharingViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    VStack {
      Text("Export")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .center)
        .overlay(alignment: .trailing) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
        .padding([.bottom])
      Text("Export all time entries from the selected period in time.")
        .font(.subheadline)
      DatePicker("From", selection: $viewModel.from, in: ...viewModel.to, displayedComponents: [.date])
        .datePickerStyle(.compact)
      DatePicker("To", selection: $viewModel.to, in: viewModel.from..., displayedComponents: [.date])
        .datePickerStyle(.compact)
      LabeledContent("Format") {
        Picker("Format", selection: $viewModel.format) {
          Text("CSV").tag(TimeEntryExportFormat.csv)
          Text("JSON").tag(TimeEntryExportFormat.json)
        }
      }
      Spacer()
      switch viewModel.format {
      case .csv:
        ShareLink(item: viewModel.csvExport, preview: SharePreview("CSV Time Entries", image: Image(systemName: "tablecells"))) {
          Label("Export to CSV", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
      case .json:
        ShareLink(item: viewModel.jsonExport, preview: SharePreview("JSON Time Entries", image: Image(systemName: "doc.text"))) {
          Label("Export to JSON", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
      }
    }
    .padding()
    .presentationDetents([.medium])
  }
}
