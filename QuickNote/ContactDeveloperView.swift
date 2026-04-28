//
//  ContactDeveloperView.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/10/26.
//

import SwiftUI

struct ContactDeveloperView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var feedbackText = ""
    @State private var showingMailFallback = false
    @State private var showingSentConfirmation = false

    private let developerEmail = "michael.fluharty@mac.com"
    private let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }()
    private var deviceInfo: String {
        let device = ProcessInfo.processInfo.hostName
        let os = ProcessInfo.processInfo.operatingSystemVersionString
        return "\(device), \(os)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Got a suggestion, found a bug, or just want to say hi? We'd love to hear from you.")
                        .font(.system(size: 18))
                }

                Section("Your Feedback") {
                    TextEditor(text: $feedbackText)
                        .font(.system(size: 18))
                        .frame(minHeight: 150)
                }

                Section("Device Info") {
                    LabeledContent("App") {
                        Text("Claudes Quick Notes v\(appVersion)")
                            .font(.system(size: 16))
                    }
                    .font(.system(size: 18))
                    LabeledContent("Device") {
                        Text(deviceInfo)
                            .font(.system(size: 16))
                    }
                    .font(.system(size: 18))
                }

                Section {
                    Button(action: sendFeedback) {
                        HStack {
                            Spacer()
                            Label("Send Feedback", systemImage: "paperplane.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Contact Developer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 18))
                }
            }
            .alert("Feedback Sent", isPresented: $showingSentConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("Thank you for your feedback!")
            }
            .alert("Email Not Available", isPresented: $showingMailFallback) {
                Button("Copy Email") {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = developerEmail
                    #endif
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please email your feedback to \(developerEmail)")
            }
        }
    }

    private func sendFeedback() {
        let subject = "Claudes Quick Notes Feedback"
        let body = """
        \(feedbackText)

        --- Device Info ---
        App: Claudes Quick Notes v\(appVersion)
        Device: \(deviceInfo)
        """

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailtoString = "mailto:\(developerEmail)?subject=\(encodedSubject)&body=\(encodedBody)"

        if let url = URL(string: mailtoString) {
            openURL(url)
            showingSentConfirmation = true
        } else {
            showingMailFallback = true
        }
    }
}
