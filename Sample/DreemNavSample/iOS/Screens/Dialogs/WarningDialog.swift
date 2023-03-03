//
//  WarningDialog.swift
//  DreemNavSample
//
//  Created by Mathieu PERROUD on 03/03/2023.
//

import SwiftUI

func WarningDialog(onClickOk: @escaping () -> Void) -> some View {
    VStack {
        Text("This is the warning dialog")
            .foregroundColor(.primaryWhite)
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .padding()
        
        Text("WARNING ! LastName will be send empty")
            .foregroundColor(.primaryWhite)
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            .padding()
        
        Button("It's all good!", action: onClickOk)
            .padding()
            .foregroundColor(.backgroundColor)
            .background(Color.primaryLightBlue)
            .cornerRadius(12)
            .padding()
    }
    .background(Color.backgroundColor)
    .cornerRadius(20)
    .padding(20)
}

struct WarningDialog_Previews: PreviewProvider {
    static var previews: some View {
        WarningDialog { }
    }
}
