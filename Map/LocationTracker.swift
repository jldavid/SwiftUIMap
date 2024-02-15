import Foundation
import SwiftUI

class LocationTracker: ObservableObject {
    @Published var latitude: Double = 51.507222
    @Published var longitude: Double = -0.1275
}
