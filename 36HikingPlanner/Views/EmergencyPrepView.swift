//
//  EmergencyPrepView.swift
//  36HikingPlanner
//
//  Created by Роман Главацкий on 24.12.2025.
//

import SwiftUI

struct EmergencyPrepView: View {
    @ObservedObject var planViewModel: PlanViewModel
    let plan: HikePlan
    
    @State private var emergencyContacts: [EmergencyContact]
    @State private var showingAddContact = false
    
    init(planViewModel: PlanViewModel, plan: HikePlan) {
        self.planViewModel = planViewModel
        self.plan = plan
        _emergencyContacts = State(initialValue: plan.emergencyContacts)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Emergency Contacts
                    emergencyContactsSection
                    
                    // Safety Rules
                    safetyRulesSection
                    
                    // Pre-Hike Checklist
                    preHikeChecklistSection
                }
                .padding()
            }
            .background(Color.hikingBackground)
            .navigationTitle("Emergency Prep")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingAddContact) {
                AddEmergencyContactView(contacts: $emergencyContacts)
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    private var emergencyContactsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Emergency Contacts")
                    .font(.headline)
                    .foregroundColor(.hikingTextPrimary)
                Spacer()
                Button(action: { showingAddContact = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.hikingAccent1)
                }
            }
            
            if emergencyContacts.isEmpty {
                Text("No emergency contacts added")
                    .foregroundColor(.hikingTextSecondary)
                    .padding()
            } else {
                ForEach(emergencyContacts) { contact in
                    EmergencyContactRow(contact: contact)
                }
            }
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private var safetyRulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Safety Rules")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                SafetyRuleRow(text: "Always inform someone about your route and expected return time")
                SafetyRuleRow(text: "Carry a first aid kit and know how to use it")
                SafetyRuleRow(text: "Bring enough water and food for the entire trip")
                SafetyRuleRow(text: "Check weather conditions before departure")
                SafetyRuleRow(text: "Stay on marked trails")
                SafetyRuleRow(text: "Carry a map and compass or GPS device")
                SafetyRuleRow(text: "Dress appropriately for weather conditions")
                SafetyRuleRow(text: "Never hike alone in remote areas")
            }
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private var preHikeChecklistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pre-Hike Checklist")
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                ChecklistItem(text: "Check weather forecast")
                ChecklistItem(text: "Inform emergency contacts")
                ChecklistItem(text: "Pack all essential equipment")
                ChecklistItem(text: "Charge phone and power bank")
                ChecklistItem(text: "Review route map")
                ChecklistItem(text: "Check first aid kit")
                ChecklistItem(text: "Pack enough food and water")
                ChecklistItem(text: "Wear appropriate clothing")
            }
        }
        .padding()
        .background(Color.hikingBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

struct EmergencyContactRow: View {
    let contact: EmergencyContact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(contact.name)
                .font(.headline)
                .foregroundColor(.hikingTextPrimary)
            Text(contact.phone)
                .font(.subheadline)
                .foregroundColor(.hikingAccent1)
            Text(contact.relationship)
                .font(.caption)
                .foregroundColor(.hikingTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.hikingBackground.opacity(0.3))
        .cornerRadius(8)
    }
}

struct SafetyRuleRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.hikingAccent1)
                .font(.caption)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.hikingTextPrimary)
        }
    }
}

struct ChecklistItem: View {
    let text: String
    @State private var isChecked = false
    
    var body: some View {
        HStack {
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .hikingAccent1 : .hikingTextSecondary)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(isChecked ? .hikingTextSecondary : .hikingTextPrimary)
                .strikethrough(isChecked)
        }
    }
}

struct AddEmergencyContactView: View {
    @Binding var contacts: [EmergencyContact]
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var phone = ""
    @State private var relationship = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Relationship", text: $relationship)
            }
            .background(Color.hikingBackground)
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let contact = EmergencyContact(
                            id: UUID(),
                            name: name,
                            phone: phone,
                            relationship: relationship,
                            notes: nil
                        )
                        contacts.append(contact)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
}

