//
//  ViewModelCreateStory.swift
//  sbud
//

import Foundation
import PhotosUI
import SwiftUI
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

        func toUsersEvent() -> UsersEvent {
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

    // MARK: - Event picker data
    var availableEvents: [EventSummary] = []

    var previewIndex = 0

    var canPost: Bool { !selectedImages.isEmpty && selectedEvent != nil && !isPosting }

    // MARK: - Dependencies

    private let storiesRepo: any IStoriesRepository
    private let createdEventsProvider: any ICreatedEventsProviding
    private let participatedEventsProvider: any IParticipatedEventsProviding
    private let logger = Logger(subsystem: "sbud", category: "CreateStory")

    init(
        storiesRepo: any IStoriesRepository = StoriesRepository(),
        createdEventsProvider: any ICreatedEventsProviding = UsersEventRepository(),
        participatedEventsProvider: any IParticipatedEventsProviding = JoinedEventsRepository()
    ) {
        self.storiesRepo = storiesRepo
        self.createdEventsProvider = createdEventsProvider
        self.participatedEventsProvider = participatedEventsProvider
    }

    // MARK: - Public

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
        async let participatedTask = fetchParticipatedEvents(uid: uid)

        var created: [EventSummary] = []
        var participated: [EventSummary] = []

        do { created = try await createdTask } catch {
            PopUpGenerator.shared.show(msg: "Couldn't load your events", type: .warning)
        }
        do { participated = try await participatedTask } catch {
            PopUpGenerator.shared.show(msg: "Couldn't load your events", type: .warning)
        }

        var seen = Set<String>()
        var merged: [EventSummary] = []
        for event in created + participated {
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
        let events = try await createdEventsProvider.fetchCreated(for: uid)
        return events.map { EventSummary(id: $0.eventId, title: $0.title, imageUrl: $0.eventImage, activityType: $0.activityType) }
    }

    private func fetchParticipatedEvents(uid: String) async throws -> [EventSummary] {
        let joined = try await participatedEventsProvider.fetchParticipated(for: uid)
        return joined.map { EventSummary(id: $0.eventId, title: $0.title, imageUrl: $0.eventImage, activityType: $0.activityType) }
    }
}
