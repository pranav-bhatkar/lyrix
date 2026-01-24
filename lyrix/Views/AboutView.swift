//
//  AboutView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                
                // App Icon
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.accentColor)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "music.note.list")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Lyrix")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tagline
                Text("Beautiful synchronized lyrics\nfor your music")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Support Section
                VStack(spacing: 12) {
                    Link(destination: URL(string: "https://x.com/Pranavbhatkar_")!) {
                        HStack {
                            Image(systemName: "at")
                            Text("Follow on X")
                        }
                        .frame(maxWidth: 200)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Link(destination: URL(string: "https://buymeacoffee.com/pranavbhatkar")!) {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                            Text("Buy Me A Coffee")
                        }
                        .frame(maxWidth: 200)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Link(destination: URL(string: "https://razorpay.me/@pranavbhatkar")!) {
                        HStack {
                            Image(systemName: "indianrupeesign")
                            Text("Support via Razorpay")
                        }
                        .frame(maxWidth: 200)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                }
                .padding(.vertical, 8)
                
                Divider()
                    .padding(.horizontal, 40)
                
                // Features
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "music.note.tv",
                        title: "Floating Lyrics",
                        description: "Overlay lyrics on any app"
                    )
                    
                    FeatureRow(
                        icon: "clock.badge.checkmark",
                        title: "Synced Lyrics",
                        description: "Real-time synchronized display"
                    )
                    
                    FeatureRow(
                        icon: "paintbrush",
                        title: "Customizable",
                        description: "Fonts, colors, and styles"
                    )
                    
                    FeatureRow(
                        icon: "bolt.fill",
                        title: "Instant Cache",
                        description: "Lightning-fast repeat loads"
                    )
                }
                .padding(.horizontal, 40)
                
                // Footer
                VStack(spacing: 8) {
                    Text("Powered by LRCLib.net")
                    Text("Made with ♥ by Pranav Bhatkar")
                    Text("© 2025")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AboutView()
        .frame(width: 450, height: 700)
}
