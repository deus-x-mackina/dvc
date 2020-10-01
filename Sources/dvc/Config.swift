//
// Created by Danny Mack on 8/9/20.
// Copyright (c) 2020 Danny Mack.
//

import Files
import Foundation

/// Default directory name that DVC manages in the user's home directory if one is not specified
/// in the current shell environment.
private let DEFAULT_MANAGED_DIR_NAME = "DVC_Repos"

/// Get git path from the environment or by running a manual search.
let GIT_PATH = ProcessInfo.processInfo.environment["DVC_GIT"] ?? findGit()

/// Get path for directory to manage from environment
/// or use the default $HOME/DEFAULT_MANAGED_DIR_NAME.
let MANAGED_PATH = ProcessInfo.processInfo.environment["DVC_ROOT"] ?? {
    let home = ProcessInfo.processInfo.environment["HOME"] ?? {
        quit("""
        DVC: fatal: Could not configure a path for DVC's root directory. You are seeing this
             because neither the DVC_ROOT not HOME environment variables have been set.
        """)
    }()
    return URL(fileURLWithPath: home)
        .appendingPathComponent(DEFAULT_MANAGED_DIR_NAME)
        .path
}()

func createManagedDirectoryIfNeeded() {
    // Create the managed directory if it doesn't exist yet
    if !FileManager.default.fileExists(atPath: MANAGED_PATH) {
        print("""
        DVC: WARNING: \
        Managed directory does not exist yet. Creating directory at path: \(MANAGED_PATH)
        """)
        do {
            try FileManager.default.createDirectory(
                atPath: MANAGED_PATH, withIntermediateDirectories: true
            )
        } catch {
            quit("""
            DVC: Error encountered creating managed directory at path: \(MANAGED_PATH)
                 Most likely, permission was denied and/or the location is not writeable.
            """)
        }
    }
}

private func findGit() -> String {
    let path = ProcessInfo.processInfo.environment["PATH"] ?? {
        quit("DVC: fatal: Could not access PATH environment variable.")
    }()

    for directory in path.split(separator: ":") {
        let url = URL(fileURLWithPath: String(directory).trimmingCharacters(in: .whitespaces))
            .appendingPathComponent("git")
        if FileManager.default.fileExists(atPath: url.path) {
            return url.path
        }
    }

    quit("""
    DVC: fatal: Could not locate a valid git executable automatically, and an absolute path was
         specified through the DVC_GIT environment variable.
    """)
}

func validateManagedDirectory() {
    guard FileManager.default.fileExists(atPath: MANAGED_PATH) else {
        quit("""
        DVC: fatal: Managed directory '\(MANAGED_PATH)' does not exist.
             Aborting...
        """)
    }
}
