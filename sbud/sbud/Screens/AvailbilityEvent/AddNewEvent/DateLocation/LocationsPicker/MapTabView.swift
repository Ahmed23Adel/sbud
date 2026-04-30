//
//  MapTabView.swift
//  sbud
//
//  Created by ahmed on 08/03/2026.
// it's made using UIKit to enable clicking on the map to locate the anchor


// Plz notice the following
// when u use UIViewRepresentable, it recieves Context which is the bridge the SwifUI uses
// it has the cordinator, env, transactoins
import SwiftUI
import _MapKit_SwiftUI


//1. User taps the map
//        │
//        ▼
//2. UITapGestureRecognizer detects the tap
//   (you created this in makeUIView)
//        │
//        ▼
//3. It calls handleTap(_ gesture:) on the Coordinator
//   (because you set target: context.coordinator, action: #selector(handleTap))
//        │
//        ▼
//4. handleTap() runs:
//   - gets tap pixel position  → gesture.location(in: map)
//   - converts pixels to GPS   → map.convert(point, toCoordinateFrom: map)
//   - appends to @Binding      → parent.pickedCoordinates.append(coord)
//        │
//        ▼
//5. @Binding changed → SwiftUI notices
//        │
//        ▼
//6. SwiftUI calls updateUIView()
//   - removes all pins         → uiView.removeAnnotations(...)
//   - loops pickedCoordinates  → uiView.addAnnotation() for each one
//        │
//        ▼
//7. addAnnotation() triggers the map to ask the delegate:
//   "what should this pin look like?"
//        │
//        ▼
//8. mapView(_:viewFor:) called on Coordinator
//   - blue dot?  → return nil
//   - red pin?   → return MKMarkerAnnotationView
//        │
//        ▼
//9. Red balloon pin appears on map at the tapped location ✅
                                                            
                                                            
struct MapTabView: UIViewRepresentable {
    @Binding var pickedCoordinates: [CLLocationCoordinate2D]

    // Context: SwiftUI pass it to you automatically
    // it'a a snapshot of swiftui env
    // it contains
    // 1. coordinator: your coordinator instance
    // 2. env: swiftui Env values
    // 3. transactions: animation info
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        // Each UIView has layer of type CALayer that handle visual rendering
        map.layer.cornerRadius = UIConstants.cornerRadius
        map.setRegion(initRegion(), animated: false)
        map.showsUserLocation = true
        // You never call handleTap yourself. UIKit calls it and hands you the gesture object so you can ask it questions:
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        map.addGestureRecognizer(tap)
        map.delegate = context.coordinator

        return map
    }
    // Every time your @Binding var pickedCoordinates changes, SwiftUI automatically calls updateUIView. It's SwiftUI saying:
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove all dropped pins
        uiView.removeAnnotations(uiView.annotations.filter { !($0 is MKUserLocation) })

        // Re-add all pins from the array
        for coord in pickedCoordinates {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = String(format: "%.5f, %.5f", coord.latitude, coord.longitude)
            uiView.addAnnotation(annotation)
        }
    }
    private func initRegion() -> MKCoordinateRegion {
            let userLocation = LocationManager.shared.userLocation
            let mapsHelper = MapsHelper()
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: userLocation?.latitude ?? 0.0,
                    longitude: userLocation?.longitude ?? 0.0
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: mapsHelper.cityZoomLatitudeDelta,
                    longitudeDelta: mapsHelper.cityZoomLongitudeDelta
                )
            )
        }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // NSObjst: root class of all objc clases
    // Delegate: Imagine you hire a **personal assistant**. You give them instructions: *"If anyone calls me, handle it. If someone needs my signature, bring it to me."*
    // "User tapped!"  →  asks delegate → YOUR Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapTabView

        init(_ parent: MapTabView) { self.parent = parent }

        // swiftui and objc C are two diff languaguages
        // let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        // under the hood, it mean `When a tap happens, I'll call the function stored in action`
        // But Objective-C cannot see Swift functions by default. They're invisible to it.
        // @objc Hey Objective-C, this function exists. You're allowed to see and call it.
        // action: #selector(Coordinator.handleTap(_:)): Store the NAME of this function, so it can be called later when a tap happens
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let map = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: map)
            // this is main reasone for using UIKIT here
            let coord = map.convert(point, toCoordinateFrom: map)

            parent.pickedCoordinates.append(coord)
            print("📍 Added: \(coord.latitude), \(coord.longitude) | Total: \(parent.pickedCoordinates.count)")
        }
        // Every time the map needs to draw a pin, it calls this on your Coordinator:
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            //  if it's the blue dot (current location)→ don't touch it, return nil
            guard !(annotation is MKUserLocation) else { return nil }
            //  else → it's one of my red pins → build and return a red balloon
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            // A simple `Bool` property. Enables the popup bubble when user taps the pin:
            view.canShowCallout = true
            return view
        }
    }
}
#Preview {
//    MapTabView()
}
