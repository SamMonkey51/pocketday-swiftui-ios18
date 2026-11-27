import SwiftUI

private struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isComplete = false
}

struct ChecklistView: View {
    @AppStorage("checklist.v1") private var storedChecklist = Data()
    @State private var draft = ""
    @FocusState private var isEditing: Bool

    private var items: [ChecklistItem] {
        if storedChecklist.isEmpty {
            return Self.sampleItems
        }
        return (try? JSONDecoder().decode([ChecklistItem].self, from: storedChecklist)) ?? []
    }

    private static let sampleItems = [
        ChecklistItem(title: "读 10 页书", isComplete: true),
        ChecklistItem(title: "出门散步 20 分钟"),
        ChecklistItem(title: "记下一件开心的小事")
    ]

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        let checklist = items
        NavigationStack {
            List {
                Section {
                    progressCard(for: checklist)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("我的清单") {
                    if checklist.isEmpty {
                        ContentUnavailableView("清单是空的", systemImage: "checklist", description: Text("添加一件想做的小事。"))
                    }

                    ForEach(checklist) { item in
                        Button {
                            var updated = items
                            guard let index = updated.firstIndex(where: { $0.id == item.id }) else { return }
                            updated[index].isComplete.toggle()
                            save(updated)
                        } label: {
                            Label {
                                Text(item.title)
                                    .strikethrough(item.isComplete)
                                    .foregroundStyle(item.isComplete ? .secondary : .primary)
                            } icon: {
                                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isComplete ? Color.accentColor : Color.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityValue(item.isComplete ? Text("已完成") : Text("待完成"))
                        .swipeActions {
                            Button("删除", systemImage: "trash", role: .destructive) {
                                save(items.filter { $0.id != item.id })
                            }
                        }
                    }
                }
            }
            .navigationTitle("每日小事")
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack(spacing: 12) {
                    TextField("添加一件小事", text: $draft)
                        .focused($isEditing)
                        .submitLabel(.done)
                        .onSubmit(addItem)
                        .padding(12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

                    Button(action: addItem) {
                        Label("添加", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 12))
                    .disabled(trimmedDraft.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.regularMaterial)
            }
        }
    }

    private func progressCard(for checklist: [ChecklistItem]) -> some View {
        let completed = checklist.filter(\.isComplete).count
        let progress = checklist.isEmpty ? 0 : Double(completed) / Double(checklist.count)

        return VStack(alignment: .leading, spacing: 12) {
            Label("完成进度", systemImage: "sun.max")
                .font(.subheadline.weight(.semibold))

            Text("已完成 \(completed) / \(checklist.count)")
                .font(.title2.weight(.bold))
                .monospacedDigit()

            ProgressView(value: progress)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 22))
    }

    private func addItem() {
        let title = trimmedDraft
        guard !title.isEmpty else { return }
        save(items + [ChecklistItem(title: title)])
        draft = ""
        isEditing = false
    }

    private func save(_ checklist: [ChecklistItem]) {
        if let encoded = try? JSONEncoder().encode(checklist) {
            storedChecklist = encoded
        }
    }
}
