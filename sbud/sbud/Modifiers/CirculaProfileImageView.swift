//
//  CirculaProfileImageView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 30/12/25.
//
/*import SwiftUI
import FirebaseAuth
import Firebase
import Kingfisher

enum ProfileImageSize {
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    
    var dimension: CGFloat {
        switch self {
        case .xxSmall: return 28
        case .xSmall: return 36
        case .small: return 48
        case .medium: return 64
        case .large: return 80
        }
    }
}


struct CircularProfileImageView: View {
    var user: User?
    let size: ProfileImageSize
    
    var body: some View {
        
        if let imageUrl = user?.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .foregroundColor(Color(.systemGray4))
        }
            
    }
}
*/
