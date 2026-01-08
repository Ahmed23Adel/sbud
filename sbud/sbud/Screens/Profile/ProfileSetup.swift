//
//  ProfileSetup.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//

import SwiftUI

struct ProfileSetupView: View {
    @StateObject private var vm = ProfileSetupVM()
    @EnvironmentObject var coordinator: MainCoordinator
    
    var body: some View {
        NavigationView {
            Form {
                // 1. Identity Section
                Section(header: Text("Personal Identity")) {
                    TextField("Full Name", text: $vm.profile.fullName)
                        .textContentType(.name)
                    
                    Picker("Gender", selection: Binding(
                        get: { vm.profile.gender ?? "" },
                        set: { vm.profile.gender = $0 }
                    )) {
                        Text("Select").tag("")
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    
                    TextField("Bio", text: Binding(
                        get: { vm.profile.bio ?? "" },
                        set: { vm.profile.bio = $0 }
                    ), axis: .vertical)
                    .lineLimit(3...5)
                    
                    Stepper("Age: \(vm.profile.age)", value: $vm.profile.age, in: 18...100)
                }
                
                // 2. Location Section
                Section(header: Text("Location")) {
                    TextField("Country", text: $vm.profile.country)
                    TextField("City", text: $vm.profile.city)
                    TextField("Address", text: Binding(
                        get: { vm.profile.location.fullAddress ?? "" },
                        set: { vm.profile.location.fullAddress = $0 }
                    ))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Latitude").font(.caption2).foregroundColor(.secondary)
                            TextField("0.0", value: $vm.profile.location.latitude, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Longitude").font(.caption2).foregroundColor(.secondary)
                            TextField("0.0", value: $vm.profile.location.longitude, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // 3. Activity & Specific Metrics Section
                Section(header: Text("Preferences & Stats")) {
                    Picker("Activity Type", selection: $vm.profile.preferredActivity) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    
                    if vm.profile.preferredActivity == .running {
                        TextField("Avg Pace (e.g. 5:45)", text: Binding(
                            get: { vm.profile.metrics.averagePace ?? "" },
                            set: { vm.profile.metrics.averagePace = $0 }
                        ))
                    } else if vm.profile.preferredActivity == .cycling {
                        HStack {
                            Text("Avg Speed:")
                            TextField("0.0", value: Binding(
                                get: { vm.profile.metrics.averageSpeed ?? 0.0 },
                                set: { vm.profile.metrics.averageSpeed = $0 }
                            ), format: .number)
                            .keyboardType(.decimalPad)
                            Text("km/h")
                        }
                    } else if vm.profile.preferredActivity == .football {
                        Stepper("Goals per Match: \(vm.profile.metrics.goalsPerMatch ?? 0)", value: Binding(
                            get: { vm.profile.metrics.goalsPerMatch ?? 0 },
                            set: { vm.profile.metrics.goalsPerMatch = $0 }
                        ), in: 0...10)
                    }
                }
                
                Section {
                    if let err = vm.errorMessage {
                        Text(err).font(.caption).foregroundColor(.red)
                    }
                    
                    Button {
                        Task {
                            let success = await vm.save()
                            if success {
                                coordinator.goToHome()
                            }
                        }
                    } label: {
                        if vm.isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Complete Profile").bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isSaving || vm.profile.fullName.isEmpty)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Setup Profile")
        }
    }
}
struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSetupView()
        }
    }
}
