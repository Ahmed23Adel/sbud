//
//  ViewModelEventImageSelection.swift.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import Foundation
import Combine
import _PhotosUI_SwiftUI
import FirebaseAuth

class ViewModelEventImageSelection: ObservableObject{
    @Published var useUserImageAsEventImg: Bool = true
    @Published var selectedImgs: [PhotosPickerItem] = []
    var selectedImg: PhotosPickerItem? {
        if selectedImgs.count == 1 {
            return selectedImgs[0]
        }
        return nil
    }
    @Published var isUploading: Bool = false
    var uploadedImgUrl: String?
    var eventImgUrl: String{
        if useUserImageAsEventImg{
            // TODO: Replace it by user's image
            "https://firebasestorage.googleapis.com/v0/b/sbud-e5bdd.firebasestorage.app/o/uploads%2Fkd5YqKdsHoeRelMwDgssF9xwE7H3%2Frun8.png?alt=media&token=c99a16df-fce1-4f98-81ea-f5e54f7903fb"
        } else{
            uploadedImgUrl!
        }
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
                PopUpGenerator.shared.show(msg: "Error with image uploading", type: .error)
                await finishLoadingUI()
                return
            }
            await uploadedGivenUIImage(img)
            
            
        }
        await finishLoadingUI()
    }
    
    func uploadedGivenUIImage(_ image: UIImage) async {
        do {
            if let compressdData = await compressImage(image){
                if let token = try await getTokenId(){
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
                        uploadedImgUrl = imgUrl
                        useUserImageAsEventImg = false
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
            PopUpGenerator.shared.show(msg: "Error with image uploading", type: .error)
            await finishLoadingUI()
            return nil
        }
        return imgData
    }
    
    private func startUploadingUI() async{
        await MainActor.run{
            isUploading = true
        }
    }
    
    private func finishLoadingUI() async{
        await MainActor.run{
            isUploading = false
        }
    }
    
    private func getTokenId() async throws -> String? {
        guard let currentUser = Auth.auth().currentUser else{
            return nil
        }
        let token = try await currentUser.getIDToken()
        return token
        return nil
    }
}
