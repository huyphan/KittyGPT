import SwiftUI
import AppKit
import AlertToast

struct MessageView: View {
    var message: ChatMessage
    
    @State var showToast: Bool = false

    var body: some View {
        HStack {
            if message.sender == "me" {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100)
                Spacer()
            }
            Text(message.content ?? "")
                .foregroundColor(message.sender == "me" ? .white : nil)
                .padding(10.0)
                .background(message.sender == "me" ? .blue : Color(red: 57/256, green: 62/256, blue: 64/256))
                .cornerRadius(10)
                .textSelection(.enabled)
                .font(.custom("Menlo", size: 13))
                .lineSpacing(8)
            if message.sender == "chatGPT" {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(message.content!, forType: .string)
                            showToast.toggle()
                        }) {
                            Image(systemName: "doc.on.clipboard").padding(.vertical, 5.0)
                        }
                        .padding(2)
                        //
                        //                        Button(action: {
                        //
                        //                        }) {
                        //                            Image(systemName: "bin.xmark").padding(.vertical, 5.0)
                        //                        }
                        //                        .padding(2)

                    }
                    .toast(isPresenting: $showToast){
                        AlertToast(displayMode: .banner(.slide), type: .complete(Color.primary), title: "Copied to cliboard")
                    }
                }
                
                Spacer()
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 100)
            }
        }
        .padding(.top, 5)
    }
    
}

//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageView()
//    }
//}

