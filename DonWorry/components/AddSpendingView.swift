import SwiftUI
import UIKit
import Vision

struct AddSpendingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var storeName: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var recurringPayment: Bool = false
    @State private var category: String = ""
    @State private var receiptImage: UIImage? // State for the receipt image
    @State private var isImagePickerPresented: Bool = false // State to present the image picker
    @State private var isCameraPicker: Bool = false // State to determine if camera or photo library is used
    @State private var ocrText: String? // State for OCR text
    
    private let categories = ["Groceries", "Dining Out", "Entertainment", "Utilities", "Other"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Form {
                        Section(header: Text("Spending Details")) {
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                            
                            TextField("Store Name", text: $storeName)
                            
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                            
                            TextField("Notes", text: $notes)
                        }
                        
                        Section(header: Text("Additional Info")) {
                            Toggle(isOn: $recurringPayment) {
                                Text("Recurring Payment")
                            }
                            
                            Picker("Category", selection: $category) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category)
                                }
                            }
                            
                            // Button to pick receipt image from photo library
                            Button(action: {
                                isCameraPicker = false
                                isImagePickerPresented.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Add Receipt Image from Library")
                                }
                            }
                            
                            // Button to take a photo using the camera
                            Button(action: {
                                isCameraPicker = true
                                isImagePickerPresented.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Take a Photo")
                                }
                            }
                            
                            // Display selected image
                            if let image = receiptImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onAppear {
                                        performOCR(on: image) { text in
                                            ocrText = text
                                            let parsedData = parseReceiptText(text ?? "")
                                            amount = parsedData.amount ?? ""
                                            storeName = parsedData.storeName ?? ""
                                            // Convert parsed date to Date object if needed
                                        }
                                    }
                            }
                        }
                    }
                    
                    Button(action: {
                        saveSpendingEntry()
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save")
                                .fontWeight(.bold)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: min(geometry.size.width, 300)) // Adjust width here
                    }
                    .buttonStyle(PlainButtonStyle()) // Ensures button behaves properly with the form
                    .padding(.bottom)
                }
                .padding()
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(image: $receiptImage, isCamera: $isCameraPicker)
                }
            }
            .navigationBarTitle("Add Spending", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveSpendingEntry() {
        // Convert amount to Double
        guard let amountValue = Double(amount) else {
            // Handle invalid amount input
            return
        }
        
        // Convert UIImage to Data if available
        let receiptImageData = receiptImage?.jpegData(compressionQuality: 0.8)
        
        // Create a new SpendingEntry
        let newEntry = SpendingEntry(
            amount: amountValue,
            storeName: storeName,
            date: date,
            notes: notes,
            recurringPayment: recurringPayment,
            category: category,
            receiptPhoto: receiptImageData // Convert UIImage to Data
        )
        
        // Load existing entries
        var entries = FileManagerHelper.shared.loadEntries()
        
        // Append the new entry
        entries.append(newEntry)
        
        // Save the updated entries
        FileManagerHelper.shared.saveEntries(entries)
        
        // Dismiss the view
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func performOCR(on image: UIImage, completion: @escaping (String?) -> Void) {
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }
        
        // Create a VNImageRequestHandler
        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Create a VNRecognizeTextRequest
        let textRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Extract text from request
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        // Perform the request
        do {
            try requestHandler.perform([textRequest])
        } catch {
            print("Error performing OCR request: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    private func parseReceiptText(_ text: String) -> (amount: String?, date: String?, storeName: String?) {
        var amount: String?
        var date: String?
        var storeName: String?
        
        let lines = text.split(separator: "\n")
        
        for line in lines {
            // Example pattern matching for amount, date, and store name
            // Adjust patterns based on your receipt format
            
            // Find amount (e.g., "$12.34" or "12.34")
            if let amountMatch = line.range(of: "\\$\\d+\\.\\d{2}", options: .regularExpression) {
                amount = String(line[amountMatch])
            }
            
            // Find date (e.g., "01/01/2024")
            if let dateMatch = line.range(of: "\\d{2}/\\d{2}/\\d{4}", options: .regularExpression) {
                date = String(line[dateMatch])
            }
            
            // Find store name (assuming it's on a line by itself or with certain keywords)
            if storeName == nil && (line.contains("Store") || line.contains("Location")) {
                storeName =  String(line)
            }
        }
        
        return (amount, date, storeName)
    }
}

// ImagePicker for selecting images or taking a photo
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isCamera: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = isCamera ? .camera : .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct AddSpendingView_Previews: PreviewProvider {
    static var previews: some View {
        AddSpendingView()
    }
}
