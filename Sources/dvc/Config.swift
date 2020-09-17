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
let GIT_PATH = ProcessInfo.processInfo.environment["DVC_GIT"] ?? whichGit()

/// Get path for directory to manage from environment or use the default $HOME/defaultManagedName.
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

private func whichGit() -> String {
    func defaultQuit() -> Never {
        quit("""
        DVC: fatal: Could not locate a valid git executable automatically, and an absolute path was
             specified through the DVC_GIT environment variable.
        """)
    }

    let which = Process()
    let url = URL(fileURLWithPath: "/usr/bin/command")
    // If we can't ge to `which` were are in big trouble!
    guard FileManager.default.fileExists(atPath: url.path),
        FileManager.default.isExecutableFile(atPath: url.path)
    else {
        defaultQuit()
    }

    if #available(macOS 10.13, *) {
        which.executableURL = url
    } else {
        which.launchPath = url.path
    }

    which.arguments = ["-v", "git"]
    let pipe = Pipe()
    which.standardOutput = pipe

    if #available(macOS 10.13, *) {
        do {
            try which.run()
        } catch {
            defaultQuit()
        }
    } else {
        which.launch()
    }
    which.waitUntilExit()
    let data: Data
    if #available(macOS 10.15, *) {
        do {
            guard let d = try pipe.fileHandleForReading.readToEnd() else {
                defaultQuit()
            }
            data = d
        } catch {
            defaultQuit()
        }
    } else {
        data = pipe.fileHandleForReading.readDataToEndOfFile()
    }
    guard let rawOutput = String(data: data, encoding: .utf8) else {
        defaultQuit()
    }
    // Output contains a newline '\n', so we want to strip that
    let output = String(
        rawOutput.prefix(through: rawOutput.index(rawOutput.endIndex, offsetBy: -2))
    )

    // Make sure the git path we have is legit (whether obtained from the environment or via search)
    guard FileManager.default.fileExists(atPath: output),
        FileManager.default.isExecutableFile(atPath: output)
    else {
        defaultQuit()
    }

    return output
}

func validateManagedDirectory() {
    guard FileManager.default.fileExists(atPath: MANAGED_PATH) else {
        quit("""
        DVC: fatal: Managed directory '\(MANAGED_PATH)' does not exist.
             Aborting...
        """)
    }
}
