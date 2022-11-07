import SwiftUI
import Core

struct ReleaseView: View {
    @State private var stats: Stats?
    let release: Release
    var body: some View {
        Self._printChanges()
        return VStack {
            if let url = URL(string: release.thumbnail) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                    } else if phase.error != nil {
                        Image(systemName: "image")
                    } else {
                        ProgressView()
                    }
                }
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Stats").font(.title)
                Divider()
                HStack {
                    Text("Min price:").font(.title2)
                    Spacer()
                    if let stats {
                        Text(stats.lowestPrice.formatted)
                    } else {
                        ProgressView()
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle(release.releaseDescription)
        .task {
//            if let result = try? await ListingService().getStats(releaseId: release.id) {
//                stats = result
//            }
        }
    }
}

struct ReleaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReleaseView(release: .mock())
        }
    }
}
