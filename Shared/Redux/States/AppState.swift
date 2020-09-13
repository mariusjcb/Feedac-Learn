//
//  AppState.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation
import Feedac_CoreRedux

public struct AppState: State, Codable {
    var lessonsState: LessonsState
    var title: String = "NONE"
    
    init(title: String) {
        if let state = Self.archivedState {
            lessonsState = state.1.lessonsState
        } else {
            lessonsState = LessonsState(criteria: "")
        }
        self.title = title
    }
    
    enum CodingKeys: String, CodingKey {
        case lessonsState
    }
}

// MARK: - Archive & iCloud

extension AppState {
    fileprivate static var archivePath: URL = {
        (iCloudArchiveLocation ?? localArchiveLocation).appendingPathComponent("AppState.archive")
    }()
    
    private static var localArchiveLocation: URL {
        try! FileManager.default.url(for: .documentDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: false)
    }
    
    private static var iCloudArchiveLocation: URL? {
        let iCloudLocation = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        if let iCloudLocation = iCloudLocation {
            try? FileManager.default.startDownloadingUbiquitousItem(at: iCloudLocation)
        }
        return iCloudLocation
    }
    
    private static var archivedState: (Data, AppState)? {
        guard let data = try? Data(contentsOf: Self.archivePath),
              let archive = try? JSONDecoder().decode(AppState.self, from: data) else {
            return nil
        }
        return (data, archive)
    }
    
    func archiveState() {
        DispatchQueue.global().async {
            guard let data = try? JSONEncoder().encode(self) else { return }
            do {
                try data.write(to: Self.archivePath)
            } catch let error {
                print("Can't save state archive: \(error)")
            }
        }
    }
    
    func sizeOfArchivedState() -> String {
        do {
            let resources = try Self.archivePath.resourceValues(forKeys:[.fileSizeKey])
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = .useKB
            formatter.countStyle = .file
            return formatter.string(fromByteCount: Int64(resources.fileSize ?? 0))
        } catch {
            return "0"
        }
    }
}

//#if DEBUG
extension AppState {
    init(lessonsState: LessonsState) {
        self.lessonsState = lessonsState
        self.title = "SAMPLE"
    }
}
//#endif
