//
//  SpendMateIntentsExtension.swift
//  SpendMateIntentsExtension
//
//  Created by Berkay Dereci on 5.02.2026.
//

import AppIntents

struct SpendMateIntentsExtension: AppIntent {
    static var title: LocalizedStringResource { "SpendMateIntentsExtension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
