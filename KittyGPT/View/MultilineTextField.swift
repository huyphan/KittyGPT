import SwiftUI
import AppKit

struct MultilineTextField: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = true
        textView.isRichText = false
        textView.delegate = context.coordinator
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = text
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: MultilineTextField

        init(_ parent: MultilineTextField) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                parent.text = textView.string
            }
        }
    }
}

struct MultilineTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultilineTextField(text: .constant("Some text"))
            .frame(height: 100)
            .padding()
    }
}
