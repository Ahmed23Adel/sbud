//
//  viewMyEventDetails.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI
import Kingfisher
import MapKit
import CoreLocation

struct ViewMyEventDetails: View {
    @State var viewModel: ViewModelMyEventDetails
    @EnvironmentObject private var coordinator: ProfileCoordinator
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    @State var isPulsing = false
    @Environment(\.dismiss) var dismiss

    private let teal = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    /// Her section'ı screenshot'taki gibi kendi kutusuna alan yardımcı.
    @ViewBuilder
    private func boxed<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(white: 0.09))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    init(eventId: String) {
        _viewModel = State(wrappedValue: ViewModelMyEventDetails(eventId: eventId))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(white: 0.05).ignoresSafeArea()

            // Event fotoğrafı arkada sabit kalır
            if let details = viewModel.myEventDertails {
                heroImageBackground(details)
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .ignoresSafeArea(.container, edges: .top)
                    .zIndex(0)
            }

            // ScrollView önde, sadece dikey kayar
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    if let details = viewModel.myEventDertails {
                        VStack(spacing: 0) {

                            // Fotoğraf burada yok; sadece badge, max ve title fotoğrafın önünde görünür
                            heroForegroundContent(details)
                                .frame(width: geo.size.width, height: 320, alignment: .bottomLeading)

                            // ── BODY ───────────────────────────────────
                            VStack(spacing: 14) {
                                boxed { activityTypeSection(details) }

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                    ForEach(statEntries(details), id: \.label) { entry in
                                        boxed { statCard(label: entry.label, value: entry.value, unit: entry.unit) }
                                    }
                                }

                                boxed { descriptionSection(details) }

                                boxed {
                                    VStack(alignment: .leading, spacing: 14) {
                                        dateRangeSection(details)
                                        bareMap(details)
                                    }
                                }

                                boxed { creatorSection(details) }
                                boxed { participantsSection }
                                actionButtons(details)
                                deleteButtonSection
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 80)
                            .background(Color.clear)
                        }
                        .frame(width: geo.size.width)
                        .clipped()
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
                .refreshable { await viewModel.refresh() }
            }
            .zIndex(1)

            // ── Session floating buttons (DOKUNMA) ────────────────────
            if !viewModel.isLoading {
                VStack {
                    Spacer()
                    HStack {
                        BasicFloatingButton(iconName: "chart.dots.scatter") {
                            coordinator.goToSessionSummary(evnet: viewModel.myEventDertails!)
                        }
                        .padding(.leading, 36)

                        Spacer()

                        if viewModel.isSessionCreated {
                            BasicFloatingButton(iconName: "flag.pattern.checkered") {
                                viewModel.navigateToConfirmationForSessionOrNavigateToSessionDetails()
                            }
                            .scaleEffect(isPulsing ? 1.4 : 1.0)
                            .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: isPulsing)
                            .onAppear { isPulsing = true }
                        } else {
                            BasicFloatingButton(iconName: "flag.pattern.checkered") {
                                viewModel.navigateToConfirmationForSessionOrNavigateToSessionDetails()
                            }
                        }
                    }
                }
                .zIndex(2)
            }

            if viewModel.isLoading {
                MidnightLoadingView(text: "Loading event details")
                    .ignoresSafeArea()
                    .zIndex(3)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shareEvent(eventId: viewModel.myEventDertails?.id ?? "")
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { viewModel.showEditEvent = true }
            }
        }
        .sheet(item: $viewModel.activeSheet) { (sheet: MyEventDetailsSheet) in
            switch sheet {
            case .confirmation:
                confirmationSheet
            case .startSessionConfirmation:
                StartSessionConfirmation(eventDetails: viewModel.myEventDertails ?? .empty)
                    .environmentObject(coordinator)
            }
        }
        .onAppear { viewModel.setMainCoordinator(mainCoordinator: mainCoordinator) }
        .fullScreenCover(isPresented: $viewModel.showEditEvent) {
            if let details = viewModel.myEventDertails {
                NavigationStack { ViewMyEventEdit(event: details) }
            }
        }
        .onChange(of: viewModel.showEditEvent) { _, isShowing in
            if !isShowing { Task { await viewModel.refresh() } }
        }
        .fullScreenCover(isPresented: $viewModel.showQueue) { queueCover }
        .alert("Delete Event", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) { Task { await viewModel.deleteEvent() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. Are you sure you want to delete this event?")
        }
        .onChange(of: viewModel.eventDeleted) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - 1. Hero Background

    private func heroImageBackground(_ details: EventFullDetails) -> some View {
        Group {
            if let imgURL = details.eventImage, let url = URL(string: imgURL) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color(white: 0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Color(white: 0.1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
            }
        }
    }

    // MARK: - 1. Hero Foreground

    private func heroForegroundContent(_ details: EventFullDetails) -> some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ProposalVsDeterminedPhase(
                        isDateConfirmed: details.isDateConfirmed,
                        isLocationConfirmed: details.isLocationConfirmed
                    )

                    Spacer()

                    if let max = details.maxAllowedToJoin {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10, weight: .bold))

                            Text("MAX \(max)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)

                Text(details.title.uppercased())
                    .font(.system(size: 32, weight: .black, design: .default))
                    .foregroundColor(.white)
                    .italic()
                    .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: - 2. Activity Type

    private func activityTypeSection(_ details: EventFullDetails) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(teal)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("ACTIVITY TYPE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1.5)

                Text(details.activityType.rawValue.uppercased())
                    .font(.system(size: 28, weight: .black, design: .default))
                    .foregroundColor(.white)
                    .italic()
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - 3. Stats grid

    /// activityDetails aktiviteye göre farklı bir tip döndürüyor (ExtraArgsHolderRunning,
    /// ExtraArgsHolderCycling vb.) — burada ekrandaki 4 kutuya (Distance/Pace/Duration/Type
    /// benzeri) çeviriyoruz. Her case kendi alanlarını okuyor.
    private func statEntries(_ details: EventFullDetails) -> [(label: String, value: String, unit: String)] {
        let holder = details.activityDetails

        switch holder.selectedActivity {
        case .running:
            let t = holder.extraArgs as! ExtraArgsHolderRunning
            return [
                ("DISTANCE", String(format: "%.1f", t.proposedDistance), "Km"),
                ("PACE", String(format: "%.1f", t.proposedPace), "Min/Km"),
                ("DURATION", String(format: "%.1f", t.proposedDurationInMin), "Min"),
                ("TYPE", t.proposedRunningType.rawValue, "Surface")
            ]

        case .cycling:
            let t = holder.extraArgs as! ExtraArgsHolderCycling
            return [
                ("DISTANCE", String(format: "%.1f", t.proposedDistanceInKm), "Km"),
                ("SPEED", String(format: "%.1f", t.proposedSpeedInKmH), "Km/H"),
                ("DURATION", String(format: "%.1f", t.proposedDurationInMin), "Min"),
                ("TYPE", t.proposedCyclingType.rawValue, "Terrain")
            ]

        case .gym:
            let t = holder.extraArgs as! ExtraArgsHolderGym
            return [
                ("DURATION", String(format: "%.1f", t.proposedDurationInMin), "Min"),
                ("DAY TYPE", t.proposedDayType.rawValue, "")
            ]

        case .skiing:
            let t = holder.extraArgs as! ExtraArgsHolderSkiing
            return [
                ("AVG SPEED", String(format: "%.1f", t.proposedAvgSpeedInKmH), "Km/H"),
                ("VERT. DROP", String(format: "%.0f", t.proposedAvgVerticalDropInM), "M"),
                ("RUNS", "\(t.proposedNumberOfRuns)", "Count"),
                ("DURATION", String(format: "%.0f", t.proposedDurationInMin), "Min")
            ]

        case .swimming:
            let t = holder.extraArgs as! ExtraArgsHolderSwimming
            return [
                ("DISTANCE", String(format: "%.0f", t.proposedDistanceInM), "M"),
                ("PACE", String(format: "%.1f", t.proposedPacePer100M), "Min/100M"),
                ("DURATION", String(format: "%.0f", t.proposedDurationInMin), "Min"),
                ("STROKE", t.proposedStroke.rawValue, "")
            ]

        case .hiking:
            let t = holder.extraArgs as! ExtraArgsHolderHiking
            return [
                ("DISTANCE", String(format: "%.1f", t.proposedDistanceInKm), "Km"),
                ("ELEV. GAIN", String(format: "%.0f", t.proposedElevationGainInM), "M"),
                ("MAX ALT.", String(format: "%.0f", t.proposedMaxAltitudeInM), "M"),
                ("DURATION", String(format: "%.0f", t.proposedDurationInMin), "Min")
            ]

        case .yoga:
            let t = holder.extraArgs as! ExtraArgsHolderYoga
            return [
                ("DURATION", String(format: "%.0f", t.proposedDurationInMin), "Min"),
                ("INTENSITY", String(format: "%.0f", t.proposedIntensityLevel), "/10"),
                ("STYLE", t.proposedStyle.rawValue, "")
            ]

        case .tennis:
            let t = holder.extraArgs as! ExtraArgsHolderTennis
            return [
                ("SETS", String(format: "%.0f", t.proposedSets), "Count"),
                ("DURATION", String(format: "%.0f", t.proposedDurationInMin), "Min"),
                ("FORMAT", t.proposedFormat.rawValue, "")
            ]
        }
    }

    private func statCard(label: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(teal)
                .kerning(1.2)

            Text(value)
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 4. Description

    private func descriptionSection(_ details: EventFullDetails) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("DESCRIPTION")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1.5)

                Spacer()

                Button {
                    viewModel.showEditEvent = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(teal)
                }
            }

            if let notes = details.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.85))
            } else {
                Text("No description.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Date Range

    private func dateRangeSection(_ details: EventFullDetails) -> some View {
        Group {
            if let first = details.dateLocations.first {
                HStack(spacing: 6) {
                    Text("FROM")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .kerning(1)

                    Text(first.startDateTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(Color("palelime"))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)

                    Text("TO")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .kerning(1)

                    Text(first.endDateTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(teal)

                    Spacer()

                    // Pin count badge
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                        Text("\(first.locations.count)")
                    }
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(teal)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(teal.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
    }

    /// LocationMapCard'ın header'ı olmayan sade harita versiyonu — sadece harita, tam genişlik
    private func bareMap(_ details: EventFullDetails) -> some View {
        Group {
            if let first = details.dateLocations.first {
                let coordinates = first.locations.map {
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                }

                let cameraPosition: MapCameraPosition = {
                    guard !coordinates.isEmpty else {
                        return .automatic
                    }

                    if coordinates.count == 1 {
                        return .region(
                            MKCoordinateRegion(
                                center: coordinates[0],
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    }

                    let lats = coordinates.map(\.latitude)
                    let lons = coordinates.map(\.longitude)

                    let center = CLLocationCoordinate2D(
                        latitude: (lats.min()! + lats.max()!) / 2,
                        longitude: (lons.min()! + lons.max()!) / 2
                    )

                    let span = MKCoordinateSpan(
                        latitudeDelta: (lats.max()! - lats.min()!) * 1.5 + 0.005,
                        longitudeDelta: (lons.max()! - lons.min()!) * 1.5 + 0.005
                    )

                    return .region(MKCoordinateRegion(center: center, span: span))
                }()

                Map(position: .constant(cameraPosition)) {
                    ForEach(Array(coordinates.enumerated()), id: \.offset) { index, coord in
                        Annotation("", coordinate: coord) {
                            MapPinView(index: index + 1)
                        }
                    }
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)
            }
        }
    }

    // MARK: - 5. Creator

    private func creatorSection(_ details: EventFullDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EVENT CREATOR")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1.5)

            HStack {
                // Avatar
                if let url = URL(string: details.creator.profileImageUrl ?? "") {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(white: 0.2))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                }

                Text(details.creator.name.uppercased())
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    coordinator.showHostsSheet(eventId: viewModel.eventId)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12, weight: .semibold))

                        Text("VIEW HOSTS")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color("palelime"))
                    .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 6. Participants

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PARTICIPANTS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1.5)

                if viewModel.isLoadingParticipants {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.7)
                }

                Spacer()
            }

            if !viewModel.confirmedParticipants.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.confirmedParticipants) { user in
                            VStack(spacing: 6) {
                                if let url = URL(string: user.profileImageUrl ?? "") {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color(white: 0.3), lineWidth: 1))
                                } else {
                                    Circle()
                                        .fill(Color(white: 0.15))
                                        .frame(width: 48, height: 48)
                                        .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                                }

                                Text(user.name)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(width: 56)
                            }
                            .onTapGesture {
                                coordinator.goToOthersProfile(userId: user.id)
                            }
                        }
                    }
                }
            } else if !viewModel.isLoadingParticipants {
                HStack {
                    Spacer()

                    VStack(spacing: 8) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 28))
                            .foregroundColor(Color(white: 0.3))

                        Text("No participants yet.")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.gray)
                            .italic()
                    }

                    Spacer()
                }
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 7. Action Buttons

    private func actionButtons(_ details: EventFullDetails) -> some View {
        VStack(spacing: 12) {
            // CONFIRM FINAL DETAILS
            if !details.isDateConfirmed || !details.isLocationConfirmed {
                Button {
                    viewModel.activeSheet = .confirmation
                } label: {
                    Text("CONFIRM FINAL DETAILS")
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("palelime"))
                        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                }
            }

            // VIEW MESSAGES
            Button {
                coordinator.goToEventConversations(
                    eventId: viewModel.eventId,
                    eventTitle: details.title
                )
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")

                    Text("VIEW MESSAGES")
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("palelime"))
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            }

            // INVITE/EDIT HOSTS
            Button {
                coordinator.showHostsSheet(eventId: viewModel.eventId)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")

                    Text("INVITE/EDIT HOSTS")
                        .font(.system(size: 15, weight: .heavy, design: .monospaced))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("palelime"))
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            }

            // PENDING REQUESTS
            if let queue = viewModel.queueResponse, queue.pendingCount > 0 {
                Button {
                    Task {
                        await viewModel.loadQueue()
                        viewModel.showQueue = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.black)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Text("\(queue.pendingCount)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color("palelime"))
                            )

                        Text("PENDING REQUESTS")
                            .font(.system(size: 15, weight: .heavy, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color("palelime"))
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                }
            } else {
                HStack(spacing: 6) {
                    Text("–")

                    Text("NO PENDING REQUESTS")
                        .font(.system(size: 13, weight: .heavy, design: .monospaced))
                }
                .foregroundColor(Color(white: 0.4))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(white: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            }
        }
        .padding(.top, 12)
    }

    // MARK: - 8. Delete

    @ViewBuilder
    private var deleteButtonSection: some View {
        Button {
            viewModel.showDeleteConfirmation = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")

                Text("DELETE EVENT")
                    .font(.system(size: 15, weight: .heavy, design: .monospaced))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(red: 0.85, green: 0.25, blue: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        }
        .disabled(viewModel.isDeletingEvent)
        .opacity(viewModel.isDeletingEvent ? 0.6 : 1.0)
        .padding(.top, 60)
        .padding(.bottom, 24)
    }

    // MARK: - Sheets (DOKUNMA)

    @ViewBuilder
    private var confirmationSheet: some View {
        if let details = viewModel.myEventDertails {
            ConfirmEventSheet(
                eventTitle: details.title,
                dateLocations: details.dateLocations
            ) { selectedDateEntry, selectedLoc, finalStart, finalEnd in
                viewModel.activeSheet = nil

                Task {
                    await viewModel.confirmEventFinalChoice(
                        selectedDateEntry: selectedDateEntry,
                        selectedLocation: selectedLoc,
                        finalStartDate: finalStart,
                        finalEndDate: finalEnd
                    )
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var queueCover: some View {
        if let q = viewModel.queueResponse {
            QueueView(
                queueResponse: q,
                isLoading: viewModel.isLoadingQueue,
                onRespond: { userId, accept in
                    Task {
                        await viewModel.respondToRequest(requesterId: userId, accept: accept)
                    }
                },
                onDismiss: {
                    viewModel.showQueue = false
                },
                onTapProfile: { userId in
                    viewModel.showQueue = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {}
                }
            )
        }
    }

    private func shareEvent(eventId: String) {
        guard !eventId.isEmpty,
              let url = URL(string: "https://sbud-backend.onrender.com/event/\(eventId)") else {
            return
        }

        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController?
            .present(av, animated: true)
    }
}

#Preview {
    ViewMyEventDetails(eventId: "")
}
