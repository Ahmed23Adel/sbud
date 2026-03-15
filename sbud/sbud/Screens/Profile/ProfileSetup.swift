//
//  ProfileSetup.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import MapKit

struct ProfileSetupView: View {
    @StateObject private var vm = ProfileSetupVM()
    @EnvironmentObject var coordinator: MainCoordinator
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    
    @State private var showLocationPopup = false
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        switch vm.currentStep {
                        case 0:
                            stepOneView
                        case 1:
                            stepTwoView
                        default:
                            stepTwoView
                        }
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)

                if showLocationPopup {
                    ZStack {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()

                        locationPermissionPopup
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .zIndex(10)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !showLocationPopup {
                VStack(spacing: 10) {
                    if vm.currentStep > 0 {
                        Button {
                            vm.goBack()
                        } label: {
                            Text("Back")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color("textFieldColor"))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                    }

                    Button {
                        Task {
                            switch vm.currentStep {
                            case 0:
                                let success = await vm.saveStep1()
                                if success {
                                    vm.goNext()
                                }

                            case 1:
                                let success = await vm.saveStep2()
                                if success {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                        showLocationPopup = true
                                    }
                                }

                            default:
                                break
                            }
                        }
                    } label: {
                        ZStack {
                            if vm.isSaving || vm.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Continue")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 68)
                        .background(Color.black)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                    }
                    .disabled(isContinueDisabled)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                }
                .background(Color.white)
            }
        }
    }
    
    private var locationPermissionPopup: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showLocationPopup = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 64, height: 64)
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, -12)
                .zIndex(1)

                VStack(spacing: 0) {
                    Text("Allow To Use Your Location")
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.top, 48)

                    Text("We use your location to find people around you")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 28)

                    Map(position: $cameraPosition) {
                        if vm.profile.location.latitude != 0 && vm.profile.location.longitude != 0 {
                            Annotation(
                                "",
                                coordinate: CLLocationCoordinate2D(
                                    latitude: vm.profile.location.latitude,
                                    longitude: vm.profile.location.longitude
                                )
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.25))
                                        .frame(width: 26, height: 26)

                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                    }
                    .mapStyle(.standard)
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .onAppear {
                        vm.requestCurrentLocation()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            vm.fillLocationFromDevice()
                            vm.fillAddressDetails()
                            updateMapToCurrentLocation()
                        }
                    }

                    Button {
                        Task {
                            vm.requestCurrentLocation()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                vm.fillLocationFromDevice()
                                vm.fillAddressDetails()
                                updateMapToCurrentLocation()
                            }

                            let success = await vm.saveStep3()
                            if success {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    showLocationPopup = false
                                }
                                coordinator.goToHome()
                            }
                        }
                    } label: {
                        ZStack {
                            if vm.isSaving || vm.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Allow")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 76)
                        .background(Color.black)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            showLocationPopup = false
                        }
                        coordinator.goToHome()
                    } label: {
                        Text("Don’t Allow")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.horizontal, 14)
                .padding(.bottom, 18)
            }
        }
    }
    
    private var isContinueDisabled: Bool {
        switch vm.currentStep {
        case 0:
            return vm.isSaving || vm.isLoading || vm.profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.profile.surName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return vm.isSaving || vm.isLoading
        default:
            return vm.isSaving || vm.isLoading
        }
    }
    
    private var stepOneView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Tell Us About Yourself")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 10)
            
            Text("Please enter your details to create your profile.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .padding(.top, 8)
            
            HStack {
                Spacer()
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color("textFieldColor"))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.top, 50)
            
            CustomInputField(
                title: "First Name",
                placeholder: "Enter first name",
                text: $vm.profile.name
            )
            .padding(.top, 30)
            
            CustomInputField(
                title: "Last Name",
                placeholder: "Enter last name",
                text: $vm.profile.surName
            )
            .padding(.top, 10)
            
            if let err = vm.errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
    
    private var stepTwoView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Complete Your Details")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 10)
            
            Text("Add a few more details for your profile.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .padding(.top, 8)
            
            CustomMultilineField(
                title: "Bio",
                placeholder: "Tell us about yourself",
                text: Binding(
                    get: { vm.profile.bio ?? "" },
                    set: { vm.profile.bio = $0 }
                )
            )
            .padding(.top, 30)
            
            CustomPickerField(
                title: "Gender",
                selection: Binding(
                    get: { vm.profile.gender ?? "" },
                    set: { vm.profile.gender = $0 }
                ),
                options: ["", "Male", "Female", "Other", "Prefer not to say"]
            )
            .padding(.top, 10)
            
            CustomDateField(
                title: "Birth Date",
                date: $vm.profile.birthDate
            )
            .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Preferred Activity")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Picker("Activity Type", selection: $vm.profile.preferredActivity) {
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(Color("textFieldColor"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.top, 10)
        }
    }
    
    /*private var stepThreeView: some View {
     VStack(alignment: .leading, spacing: 0) {
     Text("Location Details")
     .font(.system(size: 25, weight: .bold))
     .foregroundColor(.black)
     .padding(.top, 10)
     
     Text("Add your location information to complete your profile.")
     .font(.system(size: 16))
     .foregroundColor(.gray)
     .lineSpacing(4)
     .padding(.top, 8)
     
     CustomInputField(
     title: "Country",
     placeholder: "Enter country",
     text: $vm.profile.country
     )
     .padding(.top, 30)
     
     CustomInputField(
     title: "City",
     placeholder: "Enter city",
     text: $vm.profile.city
     )
     .padding(.top, 10)
     
     CustomInputField(
     title: "Address",
     placeholder: "Enter address",
     text: Binding(
     get: { vm.profile.location.fullAddress ?? "" },
     set: { vm.profile.location.fullAddress = $0 }
     )
     )
     .padding(.top, 10)
     }
     }
     }*/
    private var stepThreeView: some View {
        ZStack {
            Color.black.opacity(0.08)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                Button {
                    vm.goBack()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 68, height: 68)
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, -10)
                .zIndex(1)
                
                VStack(spacing: 0) {
                    Text("Allow \"ZEOVA\" To Use\nYour Location?")
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.top, 54)
                    
                    Text("We use your location to find services around you")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 14)
                        .padding(.horizontal, 28)
                    
                    Map(position: $cameraPosition) {
                        if vm.profile.location.latitude != 0 && vm.profile.location.longitude != 0 {
                            Annotation(
                                "",
                                coordinate: CLLocationCoordinate2D(
                                    latitude: vm.profile.location.latitude,
                                    longitude: vm.profile.location.longitude
                                )
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 24, height: 24)
                                    
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                    }
                    .mapStyle(.standard)
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .padding(.horizontal, 22)
                    .padding(.top, 26)
                    .onAppear {
                        vm.requestCurrentLocation()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            vm.fillLocationFromDevice()
                            vm.fillAddressDetails()
                            updateMapToCurrentLocation()
                        }
                    }
                    
                    Button {
                        Task {
                            vm.requestCurrentLocation()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                vm.fillLocationFromDevice()
                                vm.fillAddressDetails()
                                updateMapToCurrentLocation()
                            }
                            
                            let success = await vm.saveStep3()
                            if success {
                                coordinator.goToHome()
                            }
                        }
                    } label: {
                        ZStack {
                            if vm.isSaving || vm.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Allow")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 78)
                        .background(Color.black)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 10)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 34)
                    .disabled(vm.isSaving || vm.isLoading)
                    
                    Button {
                        coordinator.goToHome()
                    } label: {
                        Text("Don’t Allow")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    .padding(.bottom, 26)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.horizontal, 14)
                .padding(.bottom, 18)
            }
        }
    }
    
    private func updateMapToCurrentLocation() {
        let lat = vm.profile.location.latitude
        let lon = vm.profile.location.longitude
        
        guard lat != 0, lon != 0 else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
    
    struct CustomInputField: View {
        let title: String
        let placeholder: String
        @Binding var text: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(placeholder, text: $text)
                    .textContentType(.name)
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                    .background(Color("textFieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    struct CustomMultilineField: View {
        let title: String
        let placeholder: String
        @Binding var text: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(16)
                    .frame(minHeight: 110, alignment: .topLeading)
                    .background(Color("textFieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    struct CustomDateField: View {
        let title: String
        @Binding var date: Date
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(Color("textFieldColor"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    struct CustomPickerField: View {
        let title: String
        @Binding var selection: String
        let options: [String]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Picker(title, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(option.isEmpty ? "Select" : option).tag(option)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(Color("textFieldColor"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    struct CustomNumberField: View {
        let title: String
        @Binding var value: Double
        let placeholder: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(placeholder, value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                    .background(Color("textFieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    struct CustomActivityPicker: View {
        @ObservedObject var vm: ProfileSetupVM
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Preferences & Stats")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Picker("Activity Type", selection: $vm.profile.preferredActivity) {
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                if vm.profile.preferredActivity == .running {
                    CustomInputField(
                        title: "Avg Pace",
                        placeholder: "e.g. 5:45",
                        text: Binding(
                            get: { vm.profile.metrics.averagePace ?? "" },
                            set: { vm.profile.metrics.averagePace = $0 }
                        )
                    )
                }
//                } else if vm.profile.preferredActivity == .cycling {
//                    CustomNumberField(
//                        title: "Avg Speed (km/h)",
//                        value: Binding(
//                            get: { vm.profile.metrics.averageSpeed ?? 0.0 },
//                            set: { vm.profile.metrics.averageSpeed = $0 }
//                        ),
//                        placeholder: "0.0"
//                    )
//                }
            }
        }
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(MainCoordinator())
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView()
            .environmentObject(MainCoordinator())
    }
}

