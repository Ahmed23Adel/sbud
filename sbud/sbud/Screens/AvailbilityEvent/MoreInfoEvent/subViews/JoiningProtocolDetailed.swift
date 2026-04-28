//
//  joiningProtocolDetailed.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct JoiningProtocolDetailed: View {
    let joiningProtocol: JoinCondition
    var body: some View {
        HStack{
            if joiningProtocol == .autoJoin{
                Text(joiningProtocol.rawValue)
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color(red: 0, green: 227/255,blue: 253/255))
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                
                    
            } else{
                Text(joiningProtocol.rawValue)
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    
                
            }
        }
    }
}

#Preview {
    JoiningProtocolDetailed(joiningProtocol: .autoJoin)
}
