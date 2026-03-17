import SwiftUI

struct DWidgetManagerSheet: View {
    @Binding var widgets: [WidgetItem]
    @Environment(\.dismiss) private var dismiss
    @State private var draggingWidgetID: UUID?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(widgets) { widget in
                        DWidgetCard(widget: widget, onToggle: { toggleWidget(widget.id) })
                            .draggable(widget.id.uuidString) {
                                DWidgetCard(widget: widget, onToggle: {})
                                    .frame(width: 160, height: 100)
                                    .opacity(0.8)
                                    .onAppear { draggingWidgetID = widget.id }
                            }
                            .dropDestination(for: String.self) { items, _ in
                                guard let draggedIDStr = items.first,
                                      let draggedID = UUID(uuidString: draggedIDStr),
                                      let fromIdx = widgets.firstIndex(where: { $0.id == draggedID }),
                                      let toIdx = widgets.firstIndex(where: { $0.id == widget.id })
                                else { return false }
                                withAnimation {
                                    widgets.move(fromOffsets: IndexSet(integer: fromIdx),
                                                 toOffset: toIdx > fromIdx ? toIdx + 1 : toIdx)
                                }
                                return true
                            }
                            .opacity(draggingWidgetID == widget.id ? 0.5 : 1.0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Gérer mes widgets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }

    private func toggleWidget(_ id: UUID) {
        guard let idx = widgets.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) { widgets[idx].isActive.toggle() }
    }
}

struct DWidgetCard: View {
    let widget: WidgetItem
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                widgetIcon
                    .frame(width: 28, height: 28)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { onToggle() }
                } label: {
                    Image(systemName: widget.isActive ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundStyle(widget.isActive ? ColorTokens.widgetActive : ColorTokens.widgetBorder)
                }
                .buttonStyle(.plain)
            }

            Text(widget.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(ColorTokens.noir)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(widget.isActive ? ColorTokens.widgetActive.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    widget.isActive ? ColorTokens.widgetActive : ColorTokens.widgetBorder,
                    style: widget.isActive
                        ? StrokeStyle(lineWidth: 1)
                        : StrokeStyle(lineWidth: 1, dash: [5, 3])
                )
        )
    }

    @ViewBuilder
    private var widgetIcon: some View {
        let config = widget.iconConfig
        Image(systemName: config.symbol)
            .font(.system(size: config.fontSize, weight: .medium))
            .foregroundStyle(config.color)
            .frame(width: 28, height: 28)
            .background(config.color.opacity(config.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
