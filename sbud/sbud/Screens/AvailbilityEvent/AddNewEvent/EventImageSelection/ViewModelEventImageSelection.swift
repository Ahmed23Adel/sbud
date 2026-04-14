//
//  ViewModelEventImageSelection.swift.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import Foundation
import _PhotosUI_SwiftUI
import FirebaseAuth
import OSLog

@Observable
class ViewModelEventImageSelection{
    let logger = Logger(subsystem: "sBud", category: "EventImageSelection")
    var eventBuilder: NewEventBuilder
    var selectedImgs: [PhotosPickerItem] = []
    var selectedImg: PhotosPickerItem? {
        if selectedImgs.count == 1 {
            return selectedImgs[0]
        }
        return nil
    }
    var isUploading: Bool = false
    init(eventBuilder: NewEventBuilder) {
        self.eventBuilder = eventBuilder
    }
    
    func uploadSelectedImg() async{
        await startUploadingUI()
        // selectedImg is just a reference to the image selected
        guard let selectedImg = selectedImg else { return }
        // the selectedImg is the real images loaded in format of Data
        // plz remember Data.self is type passed as Value
        // plz also remember Data is just some raw bytes
        if let data = try? await selectedImg.loadTransferable(type: Data.self){
            // plz remember that UIImage is an object that really understands the image
            guard let img = UIImage(data: data) else {
                await finishLoadingUIWithError()
                return
            }
            await uploadedGivenUIImage(img)
            
            
        }
        await finishLoadingUI()
    }
    
    func uploadedGivenUIImage(_ image: UIImage) async {
        do {
            if let compressdData = await compressImage(image){
                if let token = try await BasicAuth.getTokenId(){
                    let url = URL(string: "https://sbud-backend.onrender.com/api/v1/images/upload")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    
                    let boundary = UUID().uuidString
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    
                    var body = Data()
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(compressdData)
                    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                    request.httpBody = body
                    
                    // Send request
                    let (data, _) = try await URLSession.shared.data(for: request)
                    let response = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
                    let imgUrl = response.url
                    await MainActor.run {
                        eventBuilder.coverImgURL = imgUrl
                        logger.info("New img url: \(self.eventBuilder.coverImgURL)")
                        isUploading = false
                        
                    }
                }
            }
        } catch {
            await finishLoadingUI()
        }
        await finishLoadingUI()
        
        
        
    }
    
    private func compressImage(_ image: UIImage) async -> Data?{
        guard let imgData = image.jpegData(compressionQuality: 0.8) else {
            await finishLoadingUIWithError()
            return nil
        }
        return imgData
    }
    
    private func startUploadingUI() async{
        await MainActor.run {
            isUploading = true
        }
    }
    
    private func finishLoadingUIWithError() async {
        PopUpGenerator.shared.show(msg: "Error with image uploading", type: .error)
        await finishLoadingUI()
    }
    private func finishLoadingUI() async{
        await MainActor.run{
            isUploading = false
        }
    }
    
    
}
