//
//  ViewModelCreateStory.swift
//  sbud
//

import Foundation
import PhotosUI
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import AdelsonApiCaller
import AdelsonAuthManager
import OSLog

@MainActor
@Observable
final class ViewModelCreateStory {

    struct EventSummary: Identifiable, Hashable {
        let id: String
        let title: String
        let imageUrl: String
        let activityType: ActivityType
        
        func toUsersEvent() -> UsersEvent{
            UsersEvent(
                id: UUID(),
                activityType: activityType,
                title: title,
                eventImage: imageUrl,
                status: .proposed,
                eventId: ""
            )
        }
    }

    // MARK: - Story content
    var selectedItems: [PhotosPickerItem] = []
    var selectedImages: [UIImage] = []
    var caption = ""
    var selectedEvent: EventSummary?

    // MARK: - State flags
    var isPosting = false
    var isLoadingImages = false
    var isLoadingEvents = false
    var didPost = false
    var showEventPicker = false

    // MARK: - Event picker data
    var availableEvents: [EventSummary] = []

    private let storiesRepo = StoriesRepository()
    private let db = Firestore.firestore()
    private let logger = Logger(subsystem: "sbud", category: "CreateStory")

    var previewIndex = 0

    var canPost: Bool { !selectedImages.isEmpty && selectedEvent != nil && !isPosting }

    // Called from .onChange in the view — avoids didSet/Observable interaction issues
    func onItemsChanged() async {
        logger.info("onItemsChanged — selectedItems=\(self.selectedItems.count)")
        guard !selectedItems.isEmpty else {
            selectedImages = []
            previewIndex = 0
            return
        }
        isLoadingImages = true
        defer { isLoadingImages = false }
        var images: [UIImage] = []
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                images.append(img)
            }
        }
        selectedImages = images
        previewIndex = 0
        logger.info("Images loaded — selectedImages=\(self.selectedImages.count), canPost=\(self.canPost)")
    }

    func loadUserEvents() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoadingEvents = true
        defer { isLoadingEvents = false }

        async let createdTask = fetchCreatedEvents(uid: uid)
        async let hostingTask = fetchHostingEvents()
        async let participatedTask = fetchParticipatedEvents(uid: uid)

        var created: [EventSummary] = []
        var hosting: [EventSummary] = []
        var participated: [EventSummary] = []

        do { created = try await createdTask } catch {
            PopUpGenerator.shared.show(msg: "Couldn't load your events", type: .warning)
        }
        do { hosting = try await hostingTask } catch {}
        do { participated = try await participatedTask } catch {}

        // Deduplicate by id
        var seen = Set<String>()
        var merged: [EventSummary] = []
        for event in created + hosting + participated {
            if seen.insert(event.id).inserted { merged.append(event) }
        }
        availableEvents = merged
    }

    func post() async {
        logger.info("post() called — canPost=\(self.canPost), images=\(self.selectedImages.count), isPosting=\(self.isPosting)")
        guard canPost else {
            logger.warning("post() blocked by canPost guard")
            return
        }
        isPosting = true
        defer { isPosting = false }
        do {
            let imageDataList = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
            logger.info("Compressing \(imageDataList.count) images, eventId=\(self.selectedEvent?.id ?? "nil")")
            let text = caption.trimmingCharacters(in: .whitespaces)
            let response = try await storiesRepo.createStory(
                eventId: selectedEvent?.id,
                text: text.isEmpty ? nil : text,
                imageDataList: imageDataList
            )
            logger.info("Story created successfully — id=\(response.id)")
            PopUpGenerator.shared.show(msg: "Story posted!", type: .notification)
            didPost = true
        } catch {
            logger.error("createStory failed: \(error)")
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }

    // MARK: - Private fetchers

    private func fetchCreatedEvents(uid: String) async throws -> [EventSummary] {
        let snapshot = try await db.collection("Events")
            .whereField("creatorId", isEqualTo: uid)
            .limit(to: 30)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let title = data["title"] as? String else { return nil }
            let activity = ActivityType(rawValue: data["activityType"] as? String ?? "") ?? .running
            return EventSummary(id: doc.documentID, title: title, imageUrl: data["eventImage"] as? String ?? "", activityType: activity)
        }
    }

    private func fetchHostingEvents() async throws -> [EventSummary] {
        let caller = AdelsonFirebaseApiCaller<[HostingEvent]>()
        let events = try await caller.callGet(
            url: "events/hosting",
            queryParams: [:],
            config: AdelsonFirebaseAuthConfig.shared
        )
        return events.map {
            EventSummary(id: $0.eventId, title: $0.title, imageUrl: $0.eventImage, activityType: $0.activityTypeEnum)
        }
    }

    private func fetchParticipatedEvents(uid: String) async throws -> [EventSummary] {
        let snapshot = try await db.collection("joinedEvents")
            .whereField("userId", isEqualTo: uid)
            .limit(to: 30)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let eventId = data["eventId"] as? String,
                  let title = data["title"] as? String else { return nil }
            let activity = ActivityType(rawValue: data["activityType"] as? String ?? "") ?? .running
            return EventSummary(id: eventId, title: title, imageUrl: data["eventImage"] as? String ?? "", activityType: activity)
        }
    }
}
