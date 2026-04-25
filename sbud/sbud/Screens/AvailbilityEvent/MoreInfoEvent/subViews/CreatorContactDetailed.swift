//
//  CreatorContactDetailed.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI
import Kingfisher
struct CreatorContactDetailed: View {
    var creatorInfo: CreatorInfo
    var body: some View {
        HStack{
            KFImage(URL(string: creatorInfo.profileImageUrl!))
                .placeholder { ProgressView() }
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.mainColor, lineWidth: 2)
                )
            Spacer()
            VStack{
                HStack{
                    Text("Creator")
                        .font(.title3)
                        .foregroundColor(Color.mainColor)
                    Spacer()
                }
                HStack{
                    Text("\(creatorInfo.name) \(creatorInfo.surName) ")
                        .font(.title3)
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            Spacer()
            
            Button("Contact"){
                
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(Color.mainColor)
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            
            
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding(.horizontal)
    }
}

#Preview {
    CreatorContactDetailed(creatorInfo: CreatorInfo(id: "WKSidc5m3ff36toyy8X7z9xjJWz2", name: "Hussein", surName: "Hussein", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/sbud-e5bdd.firebasestorage.app/o/uploads%2FWKSidc5m3ff36toyy8X7z9xjJWz2%2F28e3f3f5-5138-48e3-84f9-8d0d611f87ae.jpg?alt=media&token=c410e75f-6877-4e9f-8d3d-f57fa3e259c5"))
}
