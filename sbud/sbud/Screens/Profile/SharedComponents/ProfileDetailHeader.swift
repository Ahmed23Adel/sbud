//
//  ProfileDetailHeader.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfileDetailHeader: View {
    let profile: UserProfile
    let showEmail: Bool
    let showPhone: Bool
 
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if showEmail {
                ProfileInfoRow(icon: "envelope", label: "EMAIL", value: profile.email ?? "")
            }
            if showPhone {
                ProfileInfoRow(icon: "phone", label: "PHONE", value: profile.phoneNumber ?? "")
            }
            ProfileInfoRow(icon: "calendar", label: "AGE", value: "\(profile.age ?? 0) YEARS")
            ProfileInfoRow(icon: "person", label: "GENDER", value: profile.gender ?? "")
            ProfileInfoRow(
                icon: "mappin.and.ellipse",
                label: "LOCATION",
                value: "\(profile.city ?? ""), \(profile.country ?? "")"
            )
        }
        .padding(.horizontal, 40)
    }
}
//
//#Preview {
//    ProfileDetailHeader()
//}
