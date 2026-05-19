//
//  HostInvitationCell.swift
//  sbud
//
//  Created by ahmed on 03/05/2026.
//

import SwiftUI
import SwiftUI
import Kingfisher


struct HostInvitationCell: View {
    let item: HostInvitationItem
    var vm: ViewModelHostsRequests

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: item.invitedAt)
    }

    var body: some View {
        HStack(spacing: 14) {

            // Event image
            Group {
                if let urlStr = item.imageUrl, let url = URL(string: urlStr) {
                    KFImage(url)
                        .placeholder { RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.15)) }
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(white: 0.15))
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("palelime"))
                                .font(.system(size: 18))
                        )
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(white: 0.2), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("INVITED \(formattedDate.uppercased())")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    Task { await vm.decline(eventId: item.id) }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 38, height: 38)
                        .background(Color(white: 0.12))
                        .clipShape(Circle())
                }
                Button {
                    Task { await vm.accept(eventId: item.id) }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 38, height: 38)
                        .background(Color("palelime"))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
//#Preview {
//    HostInvitationCell()
//}
