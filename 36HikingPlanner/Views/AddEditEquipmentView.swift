//
//  AddEditEquipmentView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct AddEditEquipmentView: View {
    @ObservedObject var viewModel: EquipmentViewModel
    @Environment(\.dismiss) var dismiss
    
    let editingItem: EquipmentItem?
    
    @State private var name: String
    @State private var category: EquipmentCategory
    @State private var isEssential: Bool
    @State private var quantity: Int
    @State private var weight: String
    @State private var notes: String
    
    init(viewModel: EquipmentViewModel, editingItem: EquipmentItem? = nil) {
        self.viewModel = viewModel
        self.editingItem = editingItem
        
        if let item = editingItem {
            _name = State(initialValue: item.name)
            _category = State(initialValue: item.category)
            _isEssential = State(initialValue: item.isEssential)
            _quantity = State(initialValue: item.quantity)
            _weight = State(initialValue: item.weight != nil ? String(format: "%.2f", item.weight!) : "")
            _notes = State(initialValue: item.notes ?? "")
        } else {
            _name = State(initialValue: "")
            _category = State(initialValue: .other)
            _isEssential = State(initialValue: false)
            _quantity = State(initialValue: 1)
            _weight = State(initialValue: "")
            _notes = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Item Name", text: $name)
                        .foregroundColor(.hikingTextPrimary)
                    
                    Picker("Category", selection: $category) {
                        ForEach(EquipmentCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .foregroundColor(.hikingTextPrimary)
                    
                    Toggle("Essential Item", isOn: $isEssential)
                        .tint(.hikingAccent1)
                }
                
                Section(header: Text("Details")) {
                    Stepper(value: $quantity, in: 1...100) {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(quantity)")
                                .foregroundColor(.hikingTextSecondary)
                        }
                    }
                    
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("0.00", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.hikingTextPrimary)
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.hikingTextPrimary)
                }
            }
            .background(Color.hikingBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle(editingItem == nil ? "Add Equipment" : "Edit Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.hikingTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEquipment()
                    }
                    .foregroundColor(.hikingAccent1)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveEquipment() {
        let weightValue = Double(weight.isEmpty ? "0" : weight) ?? nil
        
        let item = EquipmentItem(
            id: editingItem?.id ?? UUID(),
            name: name,
            category: category,
            isEssential: isEssential,
            quantity: quantity,
            weight: weightValue,
            isPacked: editingItem?.isPacked ?? false,
            notes: notes.isEmpty ? nil : notes
        )
        
        if let editingItem = editingItem {
            viewModel.updateEquipment(item)
        } else {
            viewModel.addEquipment(item)
        }
        
        dismiss()
    }
}

