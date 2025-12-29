//
//  EquipmentChecklistView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct EquipmentChecklistView: View {
    @ObservedObject var viewModel: EquipmentViewModel
    @State private var selectedCategory: EquipmentCategory?
    @State private var showingAddEquipment = false
    @State private var editingItem: EquipmentItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Header
                VStack(spacing: 12) {
                    Text("Packing Progress")
                        .font(.headline)
                        .foregroundColor(.hikingTextPrimary)
                    
                    ProgressView(value: viewModel.packingProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .hikingAccent1))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text("\(viewModel.packedCount) / \(viewModel.totalCount) items packed")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                    
                    Text("Total Weight: \(String(format: "%.1f", viewModel.totalWeight)) kg")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                .padding()
                .background(Color.hikingBackground.opacity(0.5))
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterButton(
                            category: nil,
                            isSelected: selectedCategory == nil,
                            title: "All"
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(EquipmentCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                title: category.rawValue
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Equipment List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if filteredEquipment.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "backpack")
                                    .font(.system(size: 50))
                                    .foregroundColor(.hikingAccent1.opacity(0.5))
                                Text("No equipment in this category")
                                    .foregroundColor(.hikingTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                        } else {
                            ForEach(filteredEquipment) { item in
                                EquipmentItemRow(
                                    item: item,
                                    onToggle: {
                                        viewModel.togglePacked(item)
                                    },
                                    onEdit: {
                                        editingItem = item
                                    },
                                    onDelete: {
                                        viewModel.deleteEquipment(item)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.hikingBackground)
            .navigationTitle("Equipment")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEquipment = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.hikingAccent1)
                    }
                }
            }
            .sheet(isPresented: $showingAddEquipment) {
                AddEditEquipmentView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
            .sheet(item: $editingItem) { item in
                AddEditEquipmentView(viewModel: viewModel, editingItem: item)
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    private var filteredEquipment: [EquipmentItem] {
        if let category = selectedCategory {
            return viewModel.equipmentItems.filter { $0.category == category }
        }
        return viewModel.equipmentItems
    }
}

struct CategoryFilterButton: View {
    let category: EquipmentCategory?
    let isSelected: Bool
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.hikingAccent1 : Color.hikingBackground.opacity(0.5))
                .foregroundColor(isSelected ? .white : .hikingTextPrimary)
                .cornerRadius(20)
        }
    }
}

struct EquipmentItemRow: View {
    let item: EquipmentItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPacked ? .hikingAccent1 : .hikingTextSecondary)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(item.isPacked ? .hikingTextSecondary : .hikingTextPrimary)
                    .strikethrough(item.isPacked)
                
                HStack(spacing: 8) {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                    
                    if item.isEssential {
                        Text("Essential")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.hikingAccent2.opacity(0.3))
                            .foregroundColor(.hikingAccent2)
                            .cornerRadius(4)
                    }
                    
                    if let weight = item.weight {
                        Text("\(String(format: "%.2f", weight)) kg")
                            .font(.caption)
                            .foregroundColor(.hikingTextSecondary)
                    }
                }
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if item.quantity > 1 {
                    Text("×\(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.hikingTextSecondary)
                }
                
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.hikingTextSecondary)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
        .alert("Delete Equipment", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Are you sure you want to delete \"\(item.name)\"?")
        }
    }
}

