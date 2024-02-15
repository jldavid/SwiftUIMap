import MapKit
import SwiftUI
import CoreLocation

struct City: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct Coordinate: Codable, Hashable {
    let latitude, longitude: Double
}

struct ContentView: View {
    
    // Add Privacy - Location When In Use Usage Description
    @StateObject var locationManager = LocationManager()
    
    let annotations = [
        City(name: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)),
        City(name: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508)),
        City(name: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5)),
        City(name: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667))
    ]
    
    var body: some View {
        Map(position: $locationManager.position)
        .mapStyle(.hybrid(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea()
        .task {
            try? await locationManager.requestUserAuthorization()
            try? await locationManager.startCurrentLocationUpdates()
        }
        
        /*
        Map() {
            ForEach(annotations) { annotation in
                //Marker(annotation.name, monogram: Text("AAA"), coordinate: annotation.coordinate)
                //Marker(annotation.name, systemImage: "building", coordinate: annotation.coordinate)
                    //.tint(.blue)
                //Marker(annotation.name, coordinate: annotation.coordinate)
                Annotation(annotation.name, coordinate: annotation.coordinate, anchor: .top) {
                    Image("heart")
                        .gesture(TapGesture()
                            .onEnded({ tap in
                                // Add Queried URL Schemes > Item 0 > maps
                                let url = URL(string: "maps://?ll=\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)")
                                if UIApplication.shared.canOpenURL(url!) {
                                    print(annotation.coordinate.latitude)
                                    print(annotation.coordinate.longitude)
                                      UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                                }
                            })
                    )
                }
            }
        }
        .ignoresSafeArea()
        */
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
        
    @Published var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    
    var location: CLLocation? = nil
    
    let locationManager = CLLocationManager()
    
    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() async throws {
        for try await locationUpdate in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdate.location else { return }
            self.location = location
            DispatchQueue.main.async {
                self.position = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    )
                )
            }
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            break
        }
    }
}

#Preview {
    ContentView()
}
