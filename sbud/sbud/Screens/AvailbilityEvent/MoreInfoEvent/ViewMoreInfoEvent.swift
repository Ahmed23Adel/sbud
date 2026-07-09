//
//  MoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher
import Lottie
import OSLog
import FirebaseAuth
import EventKit

struct ViewMoreInfoEvent: View {
    @State var viewModel: ViewModelMoreInfoEvent
    @EnvironmentObject var coordinator: AvailabilityCoordinator
    @State private var showHostsList = false
    @State private var showCalendarPrompt = false

    let logger = Logger(subsystem: "sbud", category: "ViewMoreInfoEvent")

    init(eventId: String) {
        _viewModel = State(wrappedValue: ViewModelMoreInfoEvent(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()

            VStack {
                if let url = viewModel.fullDetails?.eventImage {
                    FadingEventImage(coverImgURL: url).ignoresSafeArea()
                    Spacer()
                }
            }

            if viewModel.isLoading {
                MidnightLoadingView(text: "Loading event")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .accessibilityIdentifier("moreInfo.loadingView")
            }

            ScrollView {
                VStack {
                    if viewModel.isErrorLoading {
                        VStack {
                            Spacer()
                            Text("Error loading full details of event, pleaes try again")
                                .font(.title)
                                .fontWeight(.bold)
                                .accessibilityIdentifier("moreInfo.errorText")
                            Spacer()
                        }
                    } else if let details = viewModel.fullDetails {

                        ProposalVsDeterminedPhase(
                            isDateConfirmed: details.isDateConfirmed,
                            isLocationConfirmed: details.isLocationConfirmed
                        )
                        .padding(.horizontal)

                        HStack {
                            JoiningProtocolDetailed(joiningProtocol: details.joinCondition)
                            VisibilityDetailed(isPublic: details.isPublic)
                            if let max = details.maxAllowedToJoin {
                                CapacityBadge(max: max)
                            }
                            Spacer()
                        }
                        .padding(.leading, 14)
                        .padding(.horizontal)

                        HStack {
                            Text(details.title)
                                .font(.title).foregroundColor(.white).italic()
                                .padding(.horizontal)
                                .padding(.horizontal)
                                .accessibilityIdentifier("moreInfo.eventTitle")
                            Spacer()
                        }

                        ViewActivityTypeForDetails(activityType: details.activityType)
                            .padding(.horizontal)
                        PerformanceTargetDetailedConditional(activityDetails: details.activityDetails)
                            .padding(.horizontal)

                        GenericMultilineTextView(
                            fieldName: "Description",
                            placeholder: "Ex: Come join us",
                            iconString: "pencil",
                            text: details.notes ?? ""
                        )
                        .padding(.horizontal)

                        if Auth.auth().currentUser?.uid != details.creator.id {
                            CreatorContactDetailed(
                                creatorInfo: details.creator,
                                onTapProfile: {
                                    coordinator.showProfile(userId: details.creator.id)
                                },
                                onTapContact: {
                                    var chatUser = UserProfile(id: details.creator.id)
                                    chatUser.name = details.creator.name
                                    chatUser.surName = details.creator.surName
                                    chatUser.profileImageUrl = details.creator.profileImageUrl
                                    let eTitle = details.title
                                    coordinator.showChat(user: chatUser, eventId: viewModel.eventId, eventTitle: eTitle)
                                }
                            )
                            .padding(.horizontal)
                        }

                        ViewHostsButton {
                            showHostsList = true
                        }

                        LocationMapCard(dateLocations: details.dateLocations).padding()
                            .padding(.horizontal)
                        
                        if details.isDateConfirmed,
                           let finalStart = details.finalStartDateTime,
                           let finalEnd   = details.finalEndDateTime,
                           let firstLoc   = details.dateLocations.first?.locations.first {

                            EventWeatherWidget(
                                finalStart: finalStart,
                                finalEnd:   finalEnd,
                                latitude:   firstLoc.latitude,
                                longitude:  firstLoc.longitude
                            )
                            .padding(.horizontal)
                        }
              
                        if !viewModel.isCurrentUserHost {
                            JoinEventButton(
                                joinCondition: details.joinCondition,
                                joinState: viewModel.joinState,
                                isLoading: viewModel.isJoiningLoading,
                                onJoin: { Task { await viewModel.joinEvent() } },
                                onWithdraw: { Task { await viewModel.withdraw() } },
                                onLeave: { Task { await viewModel.leave() } }
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        
                        if details.isDateConfirmed && details.isLocationConfirmed {
                            Button(action: {
                                showCalendarPrompt = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("Add to Calendar")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.mainColor)
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                            .alert("Aggiungi al Calendario", isPresented: $showCalendarPrompt) {
                                Button("Sì, aggiungi") {
                                    saveToCalendar(details: details)
                                }
                                Button("No, grazie", role: .cancel) { }
                            } message: {
                                Text("Vuoi salvare questo evento nel tuo calendario Apple?")
                            }
                        }

                        participantsSection

                        Spacer()
                    }
                    
                }
                .padding(.top, 200)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard let eventId = viewModel.fullDetails?.id,
                          let url = URL(string: "https://sbud-backend.onrender.com/event/\(eventId)") else { return }
                    let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows.first?.rootViewController?
                        .present(av, animated: true)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .fullScreenCover(isPresented: $showHostsList) {
            ViewHostsList(
                eventId: viewModel.eventId,
                onTapHost: { userId in
                    showHostsList = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        coordinator.showProfile(userId: userId)
                    }
                },
                onDismiss: { showHostsList = false }
            )
        }
    }

    private func saveToCalendar(details: EventFullDetails) {
        Task {
            let db = Firestore.firestore()
            
            do {
                // 1. CERCA NEL DATABASE IL FLATTENED EVENT CONFERMATO
                // Visto che hai eliminato gli scartati, ne rimarrà solo 1 con le date esatte.
                let snapshot = try await db.collection("flattenedEvents")
                    .whereField("eventId", isEqualTo: details.id)
                    .getDocuments()
                
                guard let confirmedDoc = snapshot.documents.first, !snapshot.isEmpty else {
                    await MainActor.run {
                        PopUpGenerator.shared.show(msg: "Evento non ancora finalizzato o dati non trovati.", type: .error)
                    }
                    return
                }
                
                let data = confirmedDoc.data()
                
                // Estrapoliamo le date esatte e aggiornate
                guard let startTimestamp = data["startDateTime"] as? Timestamp,
                      let endTimestamp = data["endDateTime"] as? Timestamp else {
                    await MainActor.run {
                        PopUpGenerator.shared.show(msg: "Date evento non valide.", type: .error)
                    }
                    return
                }
                
                let startDate = startTimestamp.dateValue()
                let endDate = endTimestamp.dateValue()
                
                // Estrapoliamo le coordinate
                var latitude: Double = 0
                var longitude: Double = 0
                if let geoPoint = data["geoPoint"] as? GeoPoint {
                    latitude = geoPoint.latitude
                    longitude = geoPoint.longitude
                } else if let lat = data["latitude"] as? Double, let lon = data["longitude"] as? Double {
                    latitude = lat
                    longitude = lon
                }
                
                // 2. RICHIEDI ACCESSO A EVENTKIT E SALVA
                let store = EKEventStore()
                var granted = false
                if #available(iOS 17.0, *) {
                    granted = try await store.requestWriteOnlyAccessToEvents()
                } else {
                    granted = try await store.requestAccess(to: .event)
                }
                
                guard granted else {
                    await MainActor.run {
                        PopUpGenerator.shared.show(msg: "Calendar permission denied.", type: .warning)
                    }
                    return
                }
                
                let event = EKEvent(eventStore: store)
                event.title = details.title
                event.startDate = startDate  // Usa la data REALE dal database
                event.endDate = endDate      // Usa la data REALE dal database
                event.notes = details.notes
                
                let location = EKStructuredLocation(title: "Event Location")
                location.geoLocation = CLLocation(latitude: latitude, longitude: longitude)
                event.structuredLocation = location
                
                // Fallback Sicurezza Calendario
                if let defaultCalendar = store.defaultCalendarForNewEvents {
                    event.calendar = defaultCalendar
                } else if let fallbackCalendar = store.calendars(for: .event).first(where: { $0.allowsContentModifications }) {
                    event.calendar = fallbackCalendar
                } else {
                    await MainActor.run {
                        PopUpGenerator.shared.show(msg: "No editable calendars found.", type: .error)
                    }
                    return
                }
                
                try store.save(event, span: .thisEvent)
                
                await MainActor.run {
                    PopUpGenerator.shared.show(msg: "Event saved to calendar!", type: .notification)
                }
                
            } catch {
                await MainActor.run {
                    PopUpGenerator.shared.show(msg: "Errore salvataggio: \(error.localizedDescription)", type: .error)
                }
            }
        }
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Participants")
                    .font(.headline)
                    .foregroundColor(.white)
                
                if viewModel.isLoadingParticipants {
                    ProgressView().tint(.white)
                        .scaleEffect(0.8)
                        .padding(.leading, 5)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            if !viewModel.confirmedParticipants.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(viewModel.confirmedParticipants) { user in
                            VStack {
                                
                                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color.gray)
                                }
                                
                                
                                Text(user.name)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 60)
                            }
                            .onTapGesture {
                                coordinator.showProfile(userId: user.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            } else if !viewModel.isLoadingParticipants {
                // Nessun partecipante (o solo l'host)
                Text("No participants yet.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
        }
    }
    
}

