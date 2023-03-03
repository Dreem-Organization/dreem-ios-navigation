//
//  ConfirmationDialog.swift
//  DreemNavSample
//
//  Created by Mathieu PERROUD on 03/03/2023.
//

import SwiftUI

func ConfirmationDialog(onClickNo: @escaping () -> Void, onClickYes: @escaping () -> Void) -> some View {
    VStack {
        Text("This is the confirmation dialog")
            .foregroundColor(.primaryWhite)
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .padding()
        
        Text("Go back home ?")
            .foregroundColor(.primaryWhite)
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            .padding()
        
        HStack {
            Button("No, Cancel.", action: onClickNo)
                .padding()
                .foregroundColor(.backgroundColor)
                .background(Color.primaryLightBlue)
                .cornerRadius(12)
                .padding()
            Button("Yes, Go back Home!", action: onClickYes)
                .padding()
                .foregroundColor(.backgroundColor)
                .background(Color.primaryLightBlue)
                .cornerRadius(12)
                .padding()
        }
    }
    .background(Color.backgroundColor)
    .cornerRadius(20)
    .padding(20)
}

struct ConfirmationDialog_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationDialog(onClickNo: { }, onClickYes: { })
    }
}
