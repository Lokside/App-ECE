import SwiftUI

struct ContentView: View {
    @State private var currentCardPage = 0
    @State private var currentServicePage = 0
    @State private var showWidgetSheet = false
    @State private var showNotifications = false
    @State private var showCalendar = false
    @State private var showAI = false
    @State private var isBarOverDarkBackground = false

    // Data loaded from JSON
    @State private var widgets: [WidgetItem] = []
    @State private var serviceItems: [ServiceItem] = []
    @State private var upcomingEvents: [CalendarEvent] = []
    @State private var calendarEvents: [CalendarEvent] = []
    @State private var notificationSections: [NotificationSection] = []
    @State private var actionCards: [ActionCard] = []
    @State private var actionDetails: [String: [ActionDetailItem]] = [:]
    @State private var consommationValues: [Double] = []
    @State private var dashboardState: DashboardState?

    private var activeWidgets: [WidgetItem] {
        widgets.filter(\.isActive)
    }

    private let repository: HRRepository = LocalHRRepository()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topSection
                    bottomSection
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: BottomSectionTopPreference.self,
                                    value: geo.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(BottomSectionTopPreference.self) { value in
                let screenHeight = UIScreen.main.bounds.height
                let threshold = screenHeight * 0.65
                withAnimation(.easeInOut(duration: 0.25)) {
                    isBarOverDarkBackground = value < threshold
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            DQuestionBar(isOverDarkBackground: isBarOverDarkBackground)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $showWidgetSheet) {
            DWidgetManagerSheet(widgets: $widgets)
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showNotifications) {
            NotificationPage(isPresented: $showNotifications)
        }
        .fullScreenCover(isPresented: $showCalendar) {
            CalendarPage(isPresented: $showCalendar)
        }
        .fullScreenCover(isPresented: $showAI) {
            AIView(isPresented: $showAI)
        }
        .onAppear { loadData() }
    }

    // MARK: - Data Loading

    private func loadData() {
        print("📦 [Data] Chargement des données JSON...")
        do {
            let appData = try repository.fetchAppData()
            print("✅ [Data] appData.json chargé — \(appData.widgets.count) widgets, \(appData.services.count) services, \(appData.upcomingEvents.count) événements à venir, \(appData.calendarEvents.count) événements calendrier")
            print("✅ [Data] appData.json — \(appData.notifications.sections.count) sections notifs, \(appData.actionCards.count) action cards, \(appData.consommationBarChart.count) valeurs consommation")

            let snapshot = try repository.fetchDashboardData()
            print("✅ [Data] datasets HR chargés — \(snapshot.companies.count) entreprises, \(snapshot.contracts.count) contrats, \(snapshot.employees.count) employés, \(snapshot.employeeContracts.count) contrats employés, \(snapshot.events.count) événements lifecycle")

            let state = DashboardAssembler.assemble(snapshot: snapshot, appData: appData)
            print("✅ [Data] DashboardState assemblé — cotisations: \(AppFormatters.currency(state.totalMonthlyContribution)), arrêts: \(state.totalArretDays)j, affiliations santé: \(AppFormatters.percent(state.healthAffiliationRate))")

            widgets = appData.widgets.map { WidgetItem(from: $0) }
            serviceItems = appData.services.map { ServiceItem(from: $0) }
            upcomingEvents = appData.upcomingEvents.map { CalendarEvent(from: $0) }
            calendarEvents = appData.calendarEvents.map { CalendarEvent(from: $0) }
            notificationSections = appData.notifications.sections.map { NotificationSection(from: $0) }
            actionCards = appData.actionCards.map { ActionCard(from: $0) }
            actionDetails = appData.actionDetails.mapValues { records in
                records.map { ActionDetailItem(from: $0) }
            }
            consommationValues = appData.consommationBarChart
            dashboardState = state
            print("🏁 [Data] Toutes les données sont prêtes")
        } catch {
            print("❌ [Data] Erreur chargement: \(error)")
        }
    }

    // MARK: - Sections

    private var topSection: some View {
        VStack(spacing: 24) {
            topBar

            VStack(spacing: 24) {
                TabView(selection: $currentCardPage) {
                    ForEach(Array(activeWidgets.enumerated()), id: \.element.id) { index, widget in
                        widgetContent(for: widget).tag(index)
                    }
                    Color.clear.tag(activeWidgets.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 355)
                .onChange(of: activeWidgets.count) { _, newCount in
                    if currentCardPage >= newCount && newCount > 0 {
                        currentCardPage = newCount - 1
                    }
                }
                .onChange(of: currentCardPage) { _, newPage in
                    if newPage == activeWidgets.count {
                        showWidgetSheet = true
                        withAnimation {
                            currentCardPage = activeWidgets.count - 1
                        }
                    }
                }

                swipeDots
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .background(topBackground)
    }

    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: 40) {
            mhCareCard
            prochainEvenementSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            TopRoundedRectangle(radius: 32)
                .fill(.white)
        )
    }

    // MARK: - Page 0 : Cotisations

    private var cotisationsContent: some View {
        VStack(spacing: 32) {
            Text("Mes cotisations")
                .font(.system(size: 18, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(ColorTokens.noir)
                .frame(height: 25)

            cotisationsCard

            HStack(spacing: 32) {
                DSummaryActionButton(icon: "clock.arrow.circlepath", title: "Régler\nla cotisation")
                DSummaryActionButton(icon: "checklist", title: "Consulter\nl'historique")
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    private var cotisationsCard: some View {
        let totalQuarterly = dashboardState?.totalQuarterlyContribution ?? 0
        let previousQuarterly = dashboardState?.previousQuarterlyContribution ?? 0
        let nextDue = dashboardState?.nextDueDate ?? ""

        let totalFormatted = AppFormatters.currency(totalQuarterly)
        let previousFormatted = AppFormatters.currency(previousQuarterly)

        return ZStack {
            DRemoteAssetImage(urlString: AssetURLs.cotisationWaves)
                .scaledToFill()
                .frame(width: 399, height: 213)
                .offset(y: -8)
                .opacity(0.92)

            VStack(spacing: 8) {
                Text("Échéance à venir")
                    .font(.system(size: 12, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(ColorTokens.noir)
                    .frame(height: 17)

                Text(totalFormatted)
                    .font(.system(size: 36, weight: .regular))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(ColorTokens.corailMHBrand)

                HStack(spacing: 4) {
                    Image(systemName: "bell")
                        .font(.system(size: 12, weight: .regular))
                    Text("Prévue le \(nextDue)")
                        .font(.system(size: 12, weight: .regular))
                        .lineLimit(1)
                }
                .foregroundStyle(ColorTokens.bleuTurquoiseDark)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .frame(height: 21)
                .background(ColorTokens.bleuTurquoiseLight.opacity(0.2))
                .clipShape(Capsule())

                Spacer(minLength: 0)

                Text("Dernier trimestre : \(previousFormatted)")
                    .font(.system(size: 12, weight: .regular))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(ColorTokens.grisDark)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 22)
            .padding(.bottom, 14)
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipped()
    }

    // MARK: - Page 1 : Arrêts de travail

    private var arretsContent: some View {
        let totalDays = dashboardState?.totalArretDays ?? 0
        let trend = dashboardState?.arretTrend ?? 0
        let sinceDate = dashboardState?.arretSinceDate ?? ""
        let segments = dashboardState?.arretSegments

        return VStack(spacing: 32) {
            Text("Mes arrêts de travail")
                .font(.system(size: 18, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(ColorTokens.noir)
                .frame(height: 25)

            ZStack {
                DArretsDonutChart(segments: segments)
                    .frame(width: 180, height: 180)

                VStack(spacing: 8) {
                    Text("Aujourd'hui")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(ColorTokens.noir)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(totalDays)")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundStyle(ColorTokens.noir)
                        if trend > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "arrowtriangle.up.fill")
                                    .font(.system(size: 9))
                                Text("\(trend)")
                                    .font(.system(size: 18, weight: .regular))
                            }
                            .foregroundStyle(ColorTokens.corailMHBrand)
                        }
                    }

                    Text(sinceDate)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(ColorTokens.grisDark)
                }

                Circle()
                    .fill(.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: ColorTokens.noir.opacity(0.3), radius: 1, x: 0, y: 0)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(ColorTokens.bleuTurquoiseDark)
                    }
                    .offset(x: 70, y: -54)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity)

            HStack(spacing: 32) {
                DSummaryActionButton(icon: "arrow.left.arrow.right", title: "Comparer\nles périodes")
                DSummaryActionButton(icon: "doc.text", title: "Consulter\nles IJ")
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Page 2 : Affiliations

    private var affiliationsContent: some View {
        let healthRate = dashboardState?.healthAffiliationRate ?? 0
        let suppRate = dashboardState?.supplementaryAffiliationRate ?? 0
        let disabRate = dashboardState?.disabilityAffiliationRate ?? 0

        return VStack(spacing: 32) {
            Text("Mes affiliations")
                .font(.system(size: 18, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(ColorTokens.noir)
                .frame(height: 25)

            VStack(spacing: 0) {
                DAffiliationRow(
                    icon: "heart.fill",
                    iconForeground: ColorTokens.corailMHBrand,
                    iconBackground: ColorTokens.affiliationSante,
                    label: "Santé obligatoire",
                    percentage: healthRate,
                    percentageText: AppFormatters.percent(healthRate),
                    barColor: ColorTokens.corailMHBrand
                )
                Spacer(minLength: 0)
                DAffiliationRow(
                    icon: "cross.fill",
                    iconForeground: ColorTokens.vertMedium,
                    iconBackground: ColorTokens.vertMedium.opacity(0.2),
                    label: "Surco facultative",
                    percentage: suppRate,
                    percentageText: AppFormatters.percent(suppRate),
                    barColor: ColorTokens.vertMedium
                )
                Spacer(minLength: 0)
                DAffiliationRow(
                    icon: "cross.fill",
                    iconForeground: ColorTokens.bleuTurquoiseMiddle,
                    iconBackground: ColorTokens.bleuTurquoiseLight.opacity(0.2),
                    label: "Prévoyance",
                    percentage: disabRate,
                    percentageText: AppFormatters.percent(disabRate),
                    barColor: ColorTokens.bleuTurquoiseMiddle
                )
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 180)

            DSummaryActionButton(icon: "doc.text", title: "Consulter\nla liste des salariés")
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Top Background

    private var topBackground: some View {
        ZStack {
            Color.white
            AngularGradient(
                stops: [
                    .init(color: ColorTokens.bleuTurquoisePastel, location: 0.0),
                    .init(color: .white, location: 0.55),
                    .init(color: ColorTokens.bleuTurquoisePastel, location: 1.0)
                ],
                center: UnitPoint(x: 0.5, y: 0.16),
                angle: .degrees(90)
            )
            .opacity(0.9)
            .scaleEffect(x: 2.5, y: 1.8)
        }
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder private func widgetContent(for widget: WidgetItem) -> some View {
        switch widget.title {
        case "Cotisations":
            cotisationsContent
        case "Arrêts de travail":
            arretsContent
        case "Affiliations":
            affiliationsContent
        case "Consommation":
            consommationContent
        case "DSN":
            dsnContent
        default:
            EmptyView()
        }
    }

    private var topBar: some View {
        HStack {
            DIconCircleButton(symbol: "square.grid.2x2", iconColor: .white, background: ColorTokens.bleuTurquoiseDark)

            Spacer()

            HStack(spacing: 8) {
                DIconCircleButton(symbol: "bubble.left", iconColor: ColorTokens.noir, background: .white)

                Button { showCalendar = true } label: {
                    DIconCircleButton(symbol: "calendar", iconColor: ColorTokens.noir, background: .white)
                }
                .buttonStyle(.plain)

                Button { showNotifications = true } label: {
                    ZStack(alignment: .topTrailing) {
                        DIconCircleButton(symbol: "bell", iconColor: ColorTokens.noir, background: .white)
                        DNotificationBadge(count: dashboardState?.pendingActionsCount ?? 0)
                            .offset(x: 5, y: -3)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 36)
    }

    private var swipeDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<activeWidgets.count, id: \.self) { i in
                Circle()
                    .fill(i == currentCardPage ? ColorTokens.noir : ColorTokens.noir.opacity(0.2))
                    .frame(
                        width: i == currentCardPage ? 8 : 6,
                        height: i == currentCardPage ? 8 : 6
                    )
            }
        }
        .frame(height: 8)
        .animation(.easeInOut(duration: 0.2), value: currentCardPage)
    }

    // MARK: - Page 3 : Consommation

    private var consommationContent: some View {
        VStack(spacing: 32) {
            Text("Ma consommation")
                .font(.system(size: 18, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(ColorTokens.noir)
                .frame(height: 25)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(consommationValues.enumerated()), id: \.offset) { _, ratio in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(ColorTokens.bleuTurquoiseMiddle)
                        .frame(width: 28, height: 120 * ratio)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)

            DSummaryActionButton(icon: "chart.bar", title: "Voir\nles détails")
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Page 4 : DSN

    private var dsnContent: some View {
        VStack(spacing: 32) {
            Text("Mes DSN")
                .font(.system(size: 18, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(ColorTokens.noir)
                .frame(height: 25)

            VStack(spacing: 12) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(ColorTokens.bleuTurquoiseDark)

                Text("Déclarations Sociales Nominatives")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(ColorTokens.grisDark)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)

            DSummaryActionButton(icon: "doc.text", title: "Consulter\nles DSN")
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    // MARK: - MH Care

    private var mhCareCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .bottom, spacing: 8) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("Services")
                        .font(.system(size: 14, weight: .bold))
                    Text("MHCare")
                        .font(.system(size: 15, weight: .bold))
                        .italic()
                }
                .foregroundStyle(ColorTokens.noir)

                Spacer()

                Text("\(currentServicePage + 1)/\(serviceItems.count)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(ColorTokens.noir)
            }

            GeometryReader { _ in
                HStack(spacing: 16) {
                    ForEach(Array(serviceItems.enumerated()), id: \.offset) { _, item in
                        DMHCareServiceCard(
                            title: item.title,
                            description: item.description,
                            backgroundColor: item.backgroundColor,
                            blobColor: item.blobColor,
                            imageURL: item.imageURL
                        )
                        .frame(width: 272, height: 120)
                    }
                }
                .offset(x: -CGFloat(currentServicePage) * 288)
                .animation(.easeInOut(duration: 0.25), value: currentServicePage)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()

            HStack(spacing: 24) {
                carouselArrow(symbol: "chevron.left", disabled: currentServicePage == 0) {
                    if currentServicePage > 0 { currentServicePage -= 1 }
                }
                carouselArrow(symbol: "chevron.right", disabled: currentServicePage == serviceItems.count - 1) {
                    if currentServicePage < serviceItems.count - 1 { currentServicePage += 1 }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: ColorTokens.corailDark, location: 0.01),
                            .init(color: ColorTokens.corailLight, location: 0.56),
                            .init(color: ColorTokens.corailPastel, location: 0.99)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func carouselArrow(symbol: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { action() }
        } label: {
            Circle()
                .fill(.white)
                .frame(width: 40, height: 40)
                .opacity(disabled ? 0.3 : 1.0)
                .overlay {
                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ColorTokens.bleuTurquoiseDark)
                }
        }
        .disabled(disabled)
        .buttonStyle(.plain)
    }

    // MARK: - Prochains événements

    private var prochainEvenementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prochains événements")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(ColorTokens.noir)

            ForEach(upcomingEvents) { event in
                upcomingEventCard(event)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func upcomingEventCard(_ event: CalendarEvent) -> some View {
        let isReminder = event.name == nil
        return HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 4) {
                Text("\(event.day)")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isReminder ? Color.white : ColorTokens.noir)
                Text(String(event.month.prefix(3)) + ".")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(isReminder ? Color.white.opacity(0.85) : ColorTokens.noir)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isReminder ? ColorTokens.bleuTurquoiseDark : ColorTokens.bleuTurquoiseLight.opacity(0.2))
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if !event.time.isEmpty {
                        Image(systemName: "clock")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(ColorTokens.noir)
                        Text(event.time)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(ColorTokens.noir)
                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(ColorTokens.grisDark)
                }

                if let name = event.name {
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ColorTokens.noir)
                }

                Text(event.subject)
                    .font(.system(size: 14, weight: isReminder ? .bold : .regular))
                    .foregroundStyle(isReminder ? ColorTokens.noir : ColorTokens.grisDark)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ColorTokens.bleuTurquoiseLight.opacity(0.2))
        )
    }
}

// MARK: - Calendar Page

private struct CalendarPage: View {
    @Binding var isPresented: Bool
    @State private var displayedMonth = Date()
    @State private var selectedDate: Date? = nil
    @State private var events: [CalendarEvent] = []

    private let calendar = Calendar.current
    private let dayLabels = ["L", "M", "M", "J", "V", "S", "D"]
    private let repository: HRRepository = LocalHRRepository()

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMMM yyyy"
        let str = formatter.string(from: displayedMonth)
        return str.prefix(1).uppercased() + str.dropFirst()
    }

    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let weekday = calendar.component(.weekday, from: firstDay)
        let offset = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        return days
    }

    private var weeksInMonth: [[Date?]] {
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = []
        for day in daysInMonth {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }
        return weeks
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func isEventDay(_ date: Date) -> Bool {
        let day = calendar.component(.day, from: date)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: displayedMonth)
        return events.contains { $0.day == day && $0.month == monthName }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Button { isPresented = false } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ColorTokens.noir)
                }
                .buttonStyle(.plain)

                Text("Calendrier")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTokens.noir)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 24)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    calendarGrid
                    eventsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation {
                            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                        }
                    } else if value.translation.width > 50 {
                        withAnimation {
                            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                        }
                    }
                }
        )
        .onAppear {
            if let appData = try? repository.fetchAppData() {
                events = appData.calendarEvents.map { CalendarEvent(from: $0) }
            }
        }
    }

    private var calendarGrid: some View {
        VStack(spacing: 16) {
            HStack {
                Text(monthYearString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTokens.noir)

                Spacer()

                Button {
                    withAnimation {
                        displayedMonth = Date()
                    }
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(ColorTokens.noir)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: ColorTokens.noir.opacity(0.3), radius: 0.5, x: 0, y: 0)
                        )
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 8) {
                HStack {
                    ForEach(dayLabels, id: \.self) { label in
                        Text(label)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(ColorTokens.grisDark)
                            .frame(maxWidth: .infinity)
                    }
                }

                ForEach(Array(weeksInMonth.enumerated()), id: \.offset) { _, week in
                    HStack {
                        ForEach(0..<7, id: \.self) { index in
                            dayCell(for: week[index])
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date?) -> some View {
        if let date = date {
            let day = calendar.component(.day, from: date)
            let today = isToday(date)
            let hasEvent = isEventDay(date)
            let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false

            Button {
                selectedDate = date
            } label: {
                Text("\(day)")
                    .font(today ? .system(size: 16, weight: .bold) : .system(size: 16, weight: .regular))
                    .foregroundStyle(today ? Color.white : hasEvent ? ColorTokens.bleuTurquoiseDark : ColorTokens.noir)
                    .frame(width: 38, height: 38)
                    .background(today ? AnyShapeStyle(ColorTokens.corailMHBrand) : AnyShapeStyle(Color.clear), in: Circle())
                    .overlay {
                        if hasEvent && !today && !isSelected {
                            Circle().stroke(ColorTokens.bleuTurquoiseMiddle, lineWidth: 1)
                        }
                    }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        } else {
            Color.clear
                .frame(width: 38, height: 38)
                .frame(maxWidth: .infinity)
        }
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vos événements du mois")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(ColorTokens.noir)

            let currentMonthEvents = events.filter { event in
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "fr_FR")
                formatter.dateFormat = "MMMM"
                let monthName = formatter.string(from: displayedMonth)
                return event.month == monthName
            }

            if currentMonthEvents.isEmpty {
                Text("Aucun événement ce mois-ci")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(ColorTokens.grisDark)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ForEach(currentMonthEvents) { event in
                    calendarEventCard(event)
                }
            }
        }
    }

    private func calendarEventCard(_ event: CalendarEvent) -> some View {
        let isReminder = event.name == nil
        return HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 4) {
                Text("\(event.day)")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isReminder ? Color.white : ColorTokens.noir)
                Text(String(event.month.prefix(3)) + ".")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(isReminder ? Color.white.opacity(0.85) : ColorTokens.noir)
            }
            .frame(width: 60)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isReminder ? ColorTokens.bleuTurquoiseDark : ColorTokens.bleuTurquoiseLight.opacity(0.2))
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if !event.time.isEmpty {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(ColorTokens.noir)
                        Text(event.time)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(ColorTokens.noir)
                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(ColorTokens.grisDark)
                }

                if let name = event.name {
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ColorTokens.noir)
                }

                Text(event.subject)
                    .font(.system(size: 14, weight: isReminder ? .bold : .regular))
                    .foregroundStyle(isReminder ? ColorTokens.noir : ColorTokens.grisDark)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ColorTokens.bleuTurquoiseLight.opacity(0.2))
        )
    }
}

// MARK: - Action Detail Page

private struct ActionDetailPage: View {
    let title: String
    @Binding var isPresented: Bool
    var onRelance: (([String]) -> Void)?
    var onAllRelanced: (() -> Void)?

    @State private var items: [ActionDetailItem] = []
    @State private var relancedItems: Set<UUID> = []

    private let repository: HRRepository = LocalHRRepository()

    private var activeItems: [ActionDetailItem] {
        items.filter { !relancedItems.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Button { isPresented = false } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ColorTokens.noir)
                }
                .buttonStyle(.plain)

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTokens.noir)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            .padding(.bottom, 16)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(activeItems) { item in
                        actionDetailCard(item)
                    }

                    if !activeItems.isEmpty {
                        Button {
                            let names = activeItems.map { $0.companyName }
                            withAnimation {
                                for item in activeItems {
                                    relancedItems.insert(item.id)
                                }
                            }
                            onRelance?(names)
                            onAllRelanced?()
                        } label: {
                            Text("Relancer tous les gestionnaires")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(ColorTokens.corailMHBrand)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Tous les gestionnaires ont été relancés.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(ColorTokens.grisDark)
                            .padding(.top, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .onAppear {
            if items.isEmpty {
                if let appData = try? repository.fetchAppData(),
                   let details = appData.actionDetails[title] {
                    items = details.map { ActionDetailItem(from: $0) }
                }
            }
        }
    }

    private func actionDetailCard(_ item: ActionDetailItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(item.companyName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(ColorTokens.noir)
                Spacer()
                Text("\(item.count)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(ColorTokens.noir)
            }

            HStack(spacing: 8) {
                Image(systemName: "mappin")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(ColorTokens.noir)
                Text(item.city)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ColorTokens.noir)
            }

            Rectangle()
                .fill(ColorTokens.separatorLight)
                .frame(height: 1)

            HStack(spacing: 10) {
                Image(systemName: "clock")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(ColorTokens.noir)
                Text(item.duration)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(ColorTokens.noir)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(ColorTokens.bleuTurquoiseLight.opacity(0.2))
            .clipShape(Capsule())

            Button {
                _ = withAnimation {
                    relancedItems.insert(item.id)
                }
                onRelance?([item.companyName])
                let remainingCount = items.filter { !relancedItems.contains($0.id) }.count
                if remainingCount == 0 {
                    onAllRelanced?()
                }
            } label: {
                Text("Relancer le gestionnaire")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(ColorTokens.corailMHBrand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .overlay(
                        Capsule()
                            .stroke(ColorTokens.corailMHBrand, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: ColorTokens.noir.opacity(0.3), radius: 0.5, x: 0, y: 0)
        )
    }
}

// MARK: - Notification Page (internal)

private struct NotificationPage: View {
    @Binding var isPresented: Bool
    @State private var selectedActionType: String?
    @State private var relancedActionTypes: Set<String> = []
    @State private var relancedCompanyCounts: [String: Int] = [:]
    @State private var sections: [NotificationSection] = []
    @State private var actionCards: [ActionCard] = []

    private let repository: HRRepository = LocalHRRepository()

    private func addRelanceNotifications(companyNames: [String], actionType: String) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH'h'mm"
        let timeString = formatter.string(from: now)

        let newNotifs = companyNames.map { name in
            NotificationItem(
                category: .vieContrat,
                title: "\(actionType) : le gestionnaire de \(name) a été relancé.",
                time: timeString,
                isRecent: true
            )
        }

        if let idx = sections.firstIndex(where: { $0.title == "AUJOURD'HUI" }) {
            let existing = sections[idx]
            sections[idx] = NotificationSection(
                title: existing.title,
                items: newNotifs + existing.items
            )
        } else {
            sections.insert(
                NotificationSection(title: "AUJOURD'HUI", items: newNotifs),
                at: 0
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { isPresented = false } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(ColorTokens.noir)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Notifications")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ColorTokens.noir)

                Spacer()

                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    actionsSection
                    notificationsList
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .onAppear {
            if let appData = try? repository.fetchAppData() {
                sections = appData.notifications.sections.map { NotificationSection(from: $0) }
                actionCards = appData.actionCards.map { ActionCard(from: $0) }
            }
        }
        .fullScreenCover(item: $selectedActionType) { actionType in
            ActionDetailPage(
                title: actionType,
                isPresented: Binding(
                    get: { selectedActionType != nil },
                    set: { if !$0 { selectedActionType = nil } }
                ),
                onRelance: { companyNames in
                    addRelanceNotifications(companyNames: companyNames, actionType: actionType)
                    relancedCompanyCounts[actionType, default: 0] += companyNames.count
                },
                onAllRelanced: {
                    withAnimation {
                        _ = relancedActionTypes.insert(actionType)
                    }
                }
            )
        }
    }

    private var remainingActionCards: [ActionCard] {
        actionCards.filter { !relancedActionTypes.contains($0.title) }
    }

    private var totalRemainingActions: Int {
        remainingActionCards.reduce(0) { total, card in
            total + card.count - relancedCompanyCounts[card.title, default: 0]
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if !remainingActionCards.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Text("Actions à traiter")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ColorTokens.noir)

                    Text("(\(totalRemainingActions))")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(ColorTokens.grisDark)
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    ForEach(remainingActionCards) { card in
                        Button { selectedActionType = card.title } label: {
                            actionCardView(count: "\(card.count)", title: card.title, subtitle: card.subtitle)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                Button {
                    for card in remainingActionCards {
                        addRelanceNotifications(companyNames: ["tous les gestionnaires"], actionType: card.title)
                    }
                    withAnimation {
                        relancedActionTypes = Set(actionCards.map(\.title))
                    }
                } label: {
                    Text("Relancer tous les gestionnaires")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ColorTokens.corailMHBrand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(ColorTokens.corailMHBrand, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
            }
        }
    }

    private func actionCardView(count: String, title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(count)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(ColorTokens.noir)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ColorTokens.noir)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(ColorTokens.grisDark)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ColorTokens.grisDark)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ColorTokens.bleuTurquoiseLight.opacity(0.2))
        )
    }

    private var notificationsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sections) { section in
                Text(section.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(ColorTokens.grisDark)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                ForEach(section.items) { item in
                    notificationRow(item)

                    Rectangle()
                        .fill(ColorTokens.separatorLight)
                        .frame(height: 1)
                        .padding(.leading, 76)
                        .padding(.trailing, 20)
                }
            }
        }
    }

    private func notificationRow(_ item: NotificationItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(iconBackgroundColor(for: item.category))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(iconColor(for: item.category))
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.category.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ColorTokens.grisDark)
                    Spacer()
                    Text(item.time)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(ColorTokens.grisDark)
                }

                Text(item.title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(ColorTokens.noir)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(item.isRecent ? ColorTokens.bleuTurquoiseLight.opacity(0.1) : Color.white)
    }

    private func iconBackgroundColor(for category: NotificationCategory) -> Color {
        switch category {
        case .vieCompte: return ColorTokens.bleuTurquoiseLight.opacity(0.2)
        case .messagerie: return ColorTokens.vertMedium.opacity(0.2)
        case .vieContrat: return ColorTokens.affiliationSante
        }
    }

    private func iconColor(for category: NotificationCategory) -> Color {
        switch category {
        case .vieCompte: return ColorTokens.bleuTurquoiseLight
        case .messagerie: return ColorTokens.vertMedium
        case .vieContrat: return ColorTokens.corailMHBrand
        }
    }
}

// MARK: - Toggle IA / Menu

private struct IATogglePill: View {
    @Binding var showAI: Bool
    let onMenuTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showAI = true }
            } label: {
                ZStack {
                    if showAI {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: ColorTokens.violetIA.opacity(0.19), radius: 6, x: 0, y: 3)
                    }
                    IAIconShape()
                        .fill(showAI ? ColorTokens.violetIA : ColorTokens.violetIA.opacity(0.5))
                        .frame(width: 14, height: 18)
                }
                .frame(width: 32, height: 28)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { showAI = false }
                onMenuTap()
            } label: {
                ZStack {
                    if !showAI {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: ColorTokens.noir.opacity(0.12), radius: 6, x: 0, y: 3)
                    }
                    DoubleSmileShape()
                        .fill(!showAI ? ColorTokens.corailMHBrand : ColorTokens.noir.opacity(0.35))
                        .frame(width: 16, height: 12)
                }
                .frame(width: 32, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(2)
        .background(
            Capsule()
                .fill(ColorTokens.violetPastel.opacity(0.7))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
        )
        .frame(height: 36)
    }
}

// MARK: - Vue IA

struct AIView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            AngularGradient(
                stops: [
                    .init(color: ColorTokens.bleuTurquoisePastel, location: 0.0),
                    .init(color: .white, location: 0.55),
                    .init(color: ColorTokens.bleuTurquoisePastel, location: 1.0)
                ],
                center: UnitPoint(x: 0.5, y: 0.16),
                angle: .degrees(90)
            )
            .opacity(0.9)
            .scaleEffect(x: 2.5, y: 1.8)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    AITogglePillDismiss(onMenuTap: { isPresented = false })
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .frame(height: 36)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        AIBubble(text: "Bonjour Jean-christophe,\nJe suis votre compagnon santé")

                        VStack(alignment: .leading, spacing: 0) {
                            AIBubble(text: "De quoi avez-vous besoin ?", isBold: true)
                            BubbleTail()
                                .fill(ColorTokens.violetPastel)
                                .frame(width: 18, height: 8)
                                .padding(.leading, 24)
                        }

                        AIOrb()
                            .frame(width: 55, height: 50)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 0)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("SUGGESTIONS :")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(ColorTokens.noir)
                            Spacer()
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(ColorTokens.noir)
                        }

                        VStack(spacing: 16) {
                            AISuggestionRow(text: "Transmettre un document", icon: "square.and.arrow.up")
                            AISuggestionRow(text: "Suivre une demande", icon: "clock.arrow.circlepath")
                            AISuggestionRow(text: "Gérer ma couverture", icon: "umbrella")
                            AISuggestionRow(text: "MH Care", icon: "cross.case", textColor: ColorTokens.violetIA)

                            HStack(spacing: 10) {
                                AIMiniTag(icon: "bell", label: "Actu")
                                AIMiniTag(icon: "creditcard", label: "Cartes")
                                AIMiniTag(icon: "person.circle", label: "Profil")
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(ColorTokens.corailLight.opacity(0.3))
                    )

                    HStack(spacing: 4) {
                        Circle()
                            .fill(.white)
                            .frame(width: 40, height: 40)
                            .shadow(color: ColorTokens.noir.opacity(0.1), radius: 4, x: 0, y: 1)
                            .overlay {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(ColorTokens.noir)
                            }

                        HStack {
                            Text("Ma question")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(ColorTokens.grisDark)
                            Spacer()
                            Circle()
                                .fill(ColorTokens.corailMHBrand)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "mic")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                        }
                        .padding(.leading, 16)
                        .padding(.vertical, 4)
                        .padding(.trailing, 4)
                        .background(
                            Capsule()
                                .fill(.white)
                                .overlay(
                                    Capsule()
                                        .stroke(ColorTokens.corailLight, lineWidth: 1)
                                )
                        )
                    }
                    .frame(height: 48)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - AI Components

private struct AITogglePillDismiss: View {
    let onMenuTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 28, height: 28)
                    .shadow(color: ColorTokens.violetIA.opacity(0.19), radius: 6, x: 0, y: 3)
                IAIconShape()
                    .fill(ColorTokens.violetIA)
                    .frame(width: 14, height: 18)
            }
            .frame(width: 32, height: 28)

            Button { onMenuTap() } label: {
                ZStack {
                    DoubleSmileShape()
                        .fill(ColorTokens.noir.opacity(0.35))
                        .frame(width: 16, height: 12)
                }
                .frame(width: 32, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(2)
        .background(
            Capsule()
                .fill(ColorTokens.violetPastel.opacity(0.7))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
        )
        .frame(height: 36)
    }
}

private struct AIBubble: View {
    let text: String
    var isBold: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: isBold ? .bold : .regular))
            .foregroundStyle(ColorTokens.noir)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ColorTokens.violetPastel)
            )
    }
}

private struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.closeSubpath()
        return path
    }
}

private struct AIOrb: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ColorTokens.violetIA.opacity(0.15 - Double(i) * 0.03),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 12 + CGFloat(i) * 5
                        )
                    )
                    .frame(width: 20 + CGFloat(i) * 8, height: 20 + CGFloat(i) * 8)
                    .scaleEffect(pulse ? 1.0 : 0.85)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(Double(i) * 0.15), value: pulse)
            }
            Circle()
                .fill(.white)
                .frame(width: 28, height: 28)
                .overlay(
                    Text("ia")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ColorTokens.violetIA, ColorTokens.pinkIA],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: ColorTokens.violetIA.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .onAppear { pulse = true }
        .frame(width: 55, height: 50)
    }
}

private struct AISuggestionRow: View {
    let text: String
    let icon: String
    var textColor: Color = ColorTokens.noir

    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ColorTokens.corailMHBrand)
                .frame(width: 30, height: 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 0)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: ColorTokens.corailLight.opacity(0.7), radius: 4, x: 0, y: 1)
        )
    }
}

private struct AIMiniTag: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ColorTokens.corailMHBrand)
                .frame(width: 16, height: 16)
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(ColorTokens.noir)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: ColorTokens.corailLight.opacity(0.7), radius: 4, x: 0, y: 1)
        )
    }
}

// MARK: - Shapes

private struct IAIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        let cx = w / 2
        let starR: CGFloat = w * 0.22
        let starCY: CGFloat = h * 0.28
        for i in 0..<4 {
            let angle = CGFloat(i) * .pi / 2
            let outer = CGPoint(x: cx + cos(angle) * starR, y: starCY + sin(angle) * starR)
            let inner1 = CGPoint(x: cx + cos(angle + .pi / 4) * starR * 0.35, y: starCY + sin(angle + .pi / 4) * starR * 0.35)
            let inner2 = CGPoint(x: cx + cos(angle - .pi / 4) * starR * 0.35, y: starCY + sin(angle - .pi / 4) * starR * 0.35)
            if i == 0 { path.move(to: inner1) }
            path.addLine(to: outer)
            path.addLine(to: inner2)
        }
        path.closeSubpath()
        let barW = w * 0.18
        path.addRect(CGRect(x: cx - barW / 2, y: h * 0.52, width: barW, height: h * 0.48))
        return path
    }
}

private struct DoubleSmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let sx = w / 16
        let sy = h / 12

        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0.215144 * sy))
        path.addCurve(to: CGPoint(x: 5.55055 * sx, y: 5.65388 * sy), control1: CGPoint(x: 0.968919 * sx, y: 3.02097 * sy), control2: CGPoint(x: 3.08167 * sx, y: 4.91555 * sy))
        path.addCurve(to: CGPoint(x: 7.76504 * sx, y: 5.99846 * sy), control1: CGPoint(x: 6.26524 * sx, y: 5.86761 * sy), control2: CGPoint(x: 7.00977 * sx, y: 5.98445 * sy))
        path.addCurve(to: CGPoint(x: 16 * sx, y: 0), control1: CGPoint(x: 11.2971 * sx, y: 6.06409 * sy), control2: CGPoint(x: 15.0325 * sx, y: 4.03398 * sy))
        path.addCurve(to: CGPoint(x: 7.63032 * sx, y: 2.91389 * sy), control1: CGPoint(x: 13.6115 * sx, y: 2.02223 * sy), control2: CGPoint(x: 10.7237 * sx, y: 2.97132 * sy))
        path.addCurve(to: CGPoint(x: 0, y: 0.215144 * sy), control1: CGPoint(x: 4.80213 * sx, y: 2.86143 * sy), control2: CGPoint(x: 2.18787 * sx, y: 2.00938 * sy))
        path.closeSubpath()

        let yOff: CGFloat = 6 * sy
        path.move(to: CGPoint(x: 0, y: yOff + 0.215144 * sy))
        path.addCurve(to: CGPoint(x: 5.55055 * sx, y: yOff + 5.65388 * sy), control1: CGPoint(x: 0.968919 * sx, y: yOff + 3.02097 * sy), control2: CGPoint(x: 3.08167 * sx, y: yOff + 4.91555 * sy))
        path.addCurve(to: CGPoint(x: 7.76504 * sx, y: yOff + 5.99846 * sy), control1: CGPoint(x: 6.26524 * sx, y: yOff + 5.86761 * sy), control2: CGPoint(x: 7.00977 * sx, y: yOff + 5.98445 * sy))
        path.addCurve(to: CGPoint(x: 16 * sx, y: yOff), control1: CGPoint(x: 11.2971 * sx, y: yOff + 6.06409 * sy), control2: CGPoint(x: 15.0325 * sx, y: yOff + 4.03398 * sy))
        path.addCurve(to: CGPoint(x: 7.63032 * sx, y: yOff + 2.91389 * sy), control1: CGPoint(x: 13.6115 * sx, y: yOff + 2.02223 * sy), control2: CGPoint(x: 10.7237 * sx, y: yOff + 2.97132 * sy))
        path.addCurve(to: CGPoint(x: 0, y: yOff + 0.215144 * sy), control1: CGPoint(x: 4.80213 * sx, y: yOff + 2.86143 * sy), control2: CGPoint(x: 2.18787 * sx, y: yOff + 2.00938 * sy))
        path.closeSubpath()

        return path
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
