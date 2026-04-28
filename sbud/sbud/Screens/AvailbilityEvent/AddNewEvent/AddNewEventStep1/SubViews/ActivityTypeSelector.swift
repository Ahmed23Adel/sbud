//
//  ActivityTypeSelector.swift
//  sbud
//
//  Created by ahmed on 14/04/2026.
//

import SwiftUI


struct ActivityTypeSelector: View {
    @Binding var selectedActivityType: ActivityType
    @Binding var extraArgsHolder: ExtraArgsHolder
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(ActivityType.allCases, id: \.self) { activity in
                    VStack{
                        Image(systemName: activity.icon)
                            .font(.system(size:40))
                            .padding()
                        Text(activity.rawValue)
                            .padding()
                    }
                    .frame(width: 110, height: 150)
                    .background(activity ==  selectedActivityType ?  Color.mainColor : Color.backgroundColor)
                    .animation(.easeIn(duration: 0.25), value: selectedActivityType )
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    .onTapGesture {
                        selectedActivityType = activity
                        extraArgsHolder.selectedActivity = activity
                    }
                }
            }
            
        }
        .padding()
    }
}

#Preview {
    ActivityTypeSelector(
        selectedActivityType: .constant(.running),
        extraArgsHolder: .constant(ExtraArgsHolder()))
}
