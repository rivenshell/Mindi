//
//  SupabaseStorageService.swift
//  Mindi
//
//  Service to fetch audio files from Supabase storage
//

import Foundation
import Supabase

class SupabaseStorageService {
    private let bucketName: String

    init(bucketName: String = "Mindful_Audio") {
        self.bucketName = bucketName
    }

    func fetchAudio(fileName: String) async throws -> Data {
        let data = try await supabase.storage
            .from(bucketName)
            .download(path: fileName)

        return data
    }

    func getPublicURL(fileName: String) -> URL? {
        do {
            let url = try supabase.storage
                .from(bucketName)
                .getPublicURL(path: fileName)
            return url
        } catch {
            print("Failed to get public URL: \(error)")
            return nil
        }
    }
}
