import SwiftUI

struct ListingItemView: View {
    @EnvironmentObject var imageLoader: ImageLoader
    @State var image: UIImage?

    @ObservedObject var viewModel: ListingItemViewModel
    var body: some View {
        HStack {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)
            Text(viewModel.title)
            Spacer()
            priceStack
        }
        .task {
            if let url = viewModel.thumbnailURL {
                do {
                    image = try await imageLoader.image(url)
                } catch {
                    image = UIImage(systemName: "photo.fill")
                }
            } else {
                image = UIImage(systemName: "photo.fill")
            }
        }
    }
    
    private var priceStack: some View {
        return VStack(alignment: .trailing) {
            HStack {
                Text("Price:")
                Text(viewModel.price)
            }
            HStack {
                Text("Min.:")
                switch viewModel.statsState {
                case .loading:
                    Text("...")
                case .paused:
                    Image(systemName: "timer")
                case .finished(lowestPrice: let lowestPrice):
                    Text(lowestPrice.formatted)
                case .failed:
                    Text("Failed").foregroundColor(.red)
                }
            }
        }
        .foregroundColor(viewModel.priceGrading.color)
    }
}

extension ListingItemViewModel.PriceGrading {
    var color: Color {
        switch self {
        case .unknown:
            return .black
        case .high:
            return .red
        case .middle:
            return .orange
        case .low:
            return.green
        }
    }
}

//struct ListingItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ListingItemView(viewModel: .init(listing: .mock()))
//        }
//    }
//}
