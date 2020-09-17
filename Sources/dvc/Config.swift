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
            Could not configure a path for DVC's root directory. You are seeing this
            because neither the DVC_ROOT not HOME environment variables have been set.
            """)
    }()
    return URL(fileURLWithPath: home).path
}()

/// Helper function that is executed prior to parsing command line arguments directly.
///
/// It sets up the managed directory path and git executable path and ensures they exist.
func configure() {
    // Dont configure if invoked with help, version, prefix or no args
    if CommandLine.argc == 1 || CommandLine.arguments.contains(where: { s in s.contains("help") })
        || CommandLine.arguments.contains(where: { s in s.contains("prefix") })
        || CommandLine.arguments.contains("-h")
        || CommandLine.arguments.contains(where: { s in s.contains("version") })
    {
        return
    }

    // Make sure the git path we have is legit (whether obtained from the environment or via `which`)
    guard FileManager.default.fileExists(atPath: GIT_PATH),
        FileManager.default.isExecutableFile(atPath: GIT_PATH)
    else { quit("Cannot find a usable git executable; tried: \(GIT_PATH)") }

    // Create the managed directory if it doesn't exist yet
    if !FileManager.default.fileExists(atPath: MANAGED_PATH) {
        print(
            """
            WARNING: \
            Managed directory does not exist yet. Creating directory at path: \(MANAGED_PATH)
            """)
        do {
            try FileManager.default.createDirectory(
                atPath: MANAGED_PATH, withIntermediateDirectories: true
            )
        } catch {
            quit("""
                Error encountered creating managed directory at path: \(MANAGED_PATH)
                Error message: \(error)
                """)
        }
    }
}

private func whichGit() -> String {
    let which = Process()
    let url = URL(fileURLWithPath: "/usr/bin/command")
    // If we can't ge to `which` were are in big trouble!
    guard FileManager.default.fileExists(atPath: url.path) else {
        quit("""
        Error: Could not locate git executable automatically, and an absolute path was specified
        through the DVC_GIT environment variable.
        """)
    }

    if #available(macOS 10.13, *) { which.executableURL = url } else { which.launchPath = url.path }
    which.arguments = ["-v", "git"]
    let pipe = Pipe()
    which.standardOutput = pipe
    if #available(macOS 10.13, *) { try! which.run() } else { which.launch() }
    which.waitUntilExit()
    let data: Data
    if #available(macOS 10.15, *) {
        data = try! pipe.fileHandleForReading.readToEnd()!
    } else {
        data = pipe.fileHandleForReading.readDataToEndOfFile()
    }
    let rawOutput = String(data: data, encoding: .utf8)!
    // Output contains a newline '\n', so we want to strip that
    let output = String(
        rawOutput.prefix(through: rawOutput.index(rawOutput.endIndex, offsetBy: -2)))
    return output
}
