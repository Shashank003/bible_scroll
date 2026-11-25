import SwiftUI

struct SettingsView: View {
    let library: BibleLibrary
    private let sections = ["General", "Contact and support", "Subscription", "Legal"]

    var body: some View {
        List {
            ForEach(sections, id: \.self) { title in
                NavigationLink {
                    if title == "General" {
                        GeneralSettingsView()
                    } else if title == "Subscription" {
                        SubscriptionSettingsView()
                    } else if title == "Legal" {
                        legalSettings
                    } else if title == "Contact and support" {
                        supportSettings
                    } else {
                        AppStyle.canvas
                        .ignoresSafeArea()
                        .navigationTitle(title)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                } label: {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(AppStyle.ink)
                        .padding(.vertical, 10)
                }
                .listRowBackground(AppStyle.surface)
            }

        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppStyle.canvas)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .tint(AppStyle.bronze)
    }

    private var supportSettings: some View {
        List {
            Section {
                Text("Need a hand? Email us at contact@coderustlers.com — we usually respond pretty fast :)")
                    .font(.body).foregroundStyle(AppStyle.ink)
                    .padding(.vertical, 8)
                Link("contact@coderustlers.com", destination: URL(string: "mailto:contact@coderustlers.com?subject=Stillword%20support")!)
            }
            .listRowBackground(AppStyle.surface)
        }
        .scrollContentBackground(.hidden).background(AppStyle.canvas)
        .navigationTitle("Contact and support")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppStyle.bronze)
    }

    private var legalSettings: some View {
        List {
            Link("Privacy policy", destination: URL(string: "https://coderustlers.com/apps/stillword/privacy/")!)
            Link("Terms of service", destination: URL(string: "https://coderustlers.com/apps/stillword/terms/")!)
            NavigationLink("Refund policy") {
                List {
                    Section("App Store purchases") {
                        Text("Apple handles billing and refund requests for Stillword subscriptions purchased through the App Store. Refund eligibility is determined by Apple under its policies and applicable law.")
                        Link("Request a refund from Apple", destination: URL(string: "https://reportaproblem.apple.com/")!)
                    }
                    Section("Canceling a subscription") {
                        Text("Canceling stops future renewals; it does not automatically refund a previous payment. Deleting Stillword does not cancel your subscription. Your rights under applicable consumer law are unaffected.")
                        Link("Manage Apple subscriptions", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    }
                }
                .navigationTitle("Refund policy").navigationBarTitleDisplayMode(.inline)
            }
            NavigationLink("Copyright info") {
                List {
                    Section("Stillword") {
                        Text("Stillword’s original software, branding, artwork, and editorial content belong to Code Rustlers or their respective rights holders. Third-party material remains subject to its own licenses.")
                    }
                    Section("Bible translations") {
                        Text("The World English Bible is public domain. The King James Version is public domain outside the United Kingdom; special publication rights apply in the United Kingdom. Our app copyright does not claim ownership of public-domain Bible text.")
                        Link("WEB source and copyright information", destination: URL(string: "https://ebible.org/engwebp/copyright.htm")!)
                        Link("KJV source and copyright information", destination: URL(string: "https://ebible.org/eng-kjv2006/copr.htm")!)
                    }
                }
                .navigationTitle("Copyright info").navigationBarTitleDisplayMode(.inline)
            }
        }
        .scrollContentBackground(.hidden).background(AppStyle.canvas)
        .navigationTitle("Legal").navigationBarTitleDisplayMode(.inline)
        .tint(AppStyle.bronze)
    }
}
