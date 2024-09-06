import SwiftUI
import StoreKit

struct TipStoreView: View {
    var body: some View {
        StoreView(ids: ["com.timekeen.TimeKeen.lovely", "com.timekeen.TimeKeen.sensational", "com.timekeen.TimeKeen.silly"])
            .productViewStyle(.compact)
            .storeButton(.hidden, for: .cancellation)
    }
}
