import SwiftUI
import MapKit

// Design: 560:1271 – Add Photo Spot
// Light theme, form with Name/Location/Description/Photos, orange submit button.
struct AddPhotoSpotScreen: View {
    @Environment(AppRouter.self) private var router

    @State private var name        = ""
    @State private var location    = ""
    @State private var description = ""
    @State private var region      = MKCoordinateRegion(
        center:     CLLocationCoordinate2D(latitude: 47.0707, longitude: 15.4395),
        latitudinalMeters:  1000,
        longitudinalMeters: 1000
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.scoonCardLight.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack {
                        Text("Add Photo Spot")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.scoonDarker)
                        Spacer()
                        Button(action: { router.navigateBack() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color.scoonDarker)
                                .frame(width: 36, height: 36)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 56)

                    // Name field
                    FieldLabel(title: "Name")
                    LightTextField(placeholder: "Name des Spots", text: $name)
                        .padding(.horizontal, 20)

                    // Location field
                    FieldLabel(title: "Location")
                    LightTextField(placeholder: "z.B. Graz, Austria", text: $location)
                        .padding(.horizontal, 20)

                    // Map preview
                    Map(coordinateRegion: $region, annotationItems: [MapPin(coord: region.center)]) { pin in
                        MapAnnotation(coordinate: pin.coord) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.yellow)
                        }
                    }
                    .frame(height: 150)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Description field
                    FieldLabel(title: "Beschreibung")
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonBorder, lineWidth: 1))
                        TextEditor(text: $description)
                            .font(.system(size: 15))
                            .foregroundColor(Color.scoonDarker)
                            .padding(10)
                            .frame(height: 100)
                    }
                    .frame(height: 100)
                    .padding(.horizontal, 20)

                    // Photos section
                    FieldLabel(title: "Fotos")

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.scoonBorder, style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .background(Color.white.cornerRadius(12))
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 36))
                                .foregroundColor(Color.scoonTextSecondary)
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Text("Add Photos")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.scoonOrange)
                                        .cornerRadius(8)
                                }
                                Button(action: {}) {
                                    Text("Add Tags")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.scoonOrange)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.scoonOrange, lineWidth: 1))
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    }
                    .frame(height: 130)
                    .padding(.horizontal, 20)

                    // Submit button
                    Button(action: { router.navigateBack() }) {
                        Text("Add Photo Spot")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.scoonOrange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct MapPin: Identifiable {
    let id = UUID()
    let coord: CLLocationCoordinate2D
}

private struct FieldLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color.scoonDarker)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 6)
    }
}

private struct LightTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 15))
            .foregroundColor(Color.scoonDarker)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.scoonBorder, lineWidth: 1))
    }
}
