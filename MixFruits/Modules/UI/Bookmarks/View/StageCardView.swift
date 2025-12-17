//
//  StageCardView.swift
//  MixFruits
//
//  Created by GitHub Copilot on 09.12.25.
//

import SwiftUI

struct StageCardView: View {
    @Binding var stage: Stage
    var onSelectImage: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Stage title", text: $stage.title)
                    .font(.headline)
                Spacer()
            }
            
            TextField("Description", text: $stage.description)
            
            HStack(spacing: 12) {
                Group {
                    if let imgName = stage.imageName,
                       let ui = ImageFileStorage.loadImage(named: imgName) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 54, height: 54)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color(UIColor.secondarySystemBackground)))
                .clipped()
                
                Button("Select Image") {
                    onSelectImage?()
                }
                
                Spacer()
            }
            
            HStack {
                Stepper("\(stage.timerMinutes) min", value: $stage.timerMinutes, in: 0...240)
                    .disabled(!stage.timerEnabled)
                    .foregroundColor(stage.timerEnabled ? .black : .gray)
                
                Toggle(isOn: $stage.timerEnabled){
                    EmptyView()
                }
                .padding()
                
            }
        }
    }
}


struct StageCardView_Previews: PreviewProvider {
    struct Container: View {
        @State var stage = Stage(title: "Chop", description: "Chop the apples", imageName: nil, timerEnabled: true, timerMinutes: 5)
        var body: some View { StageCardView(stage: $stage) }
    }
    static var previews: some View {
        Container()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
