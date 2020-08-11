//
// Created by Danny Mack on 8/9/20.
// Copyright (c) 2020 Danny Mack.
//

import Foundation
import Files
import ArgumentParser

struct Clone: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Clone a repository."
    )

    @Argument(
        help: """
              The repository to clone. 
              Can be a full URL: https://github.com/<account>/<repo>.git
              or a shorthand: <account>/<repo>
              """
    ) var repo: String

    func run() throws {
        let account: Substring.SubSequence
        let repoName: Substring.SubSequence
        let argumentURL: String

        // Access the managed directory
        guard let folder = try? Folder(
            path: managedPath) else
        {
            quit("Could not access managed directory at: \(managedPath)")
        }

        // Extract account and repo name
        do {
            // Match repositories given in full HTTPS format
            if let range = repo.range(
                of: #"(?<=^https://github.com/)\w+/\w+(?=\.git$)"#,
                options: .regularExpression
            ) {
                let extracted = repo[range].split(separator: "/")
                account = extracted[0]
                repoName = extracted[1]
                argumentURL = repo
            } else if let _ = repo.range(of: #"\w+/\w+"#, options: .regularExpression) {
                // Match a given repo in shorthand format
                let extracted = repo.split(separator: "/")
                guard extracted.count == 2 else {
                    quit("Could not parse input: \(repo)")
                }
                account = extracted[0]
                repoName = extracted[1]
                argumentURL = "https://github.com/\(repo).git"
            } else {
                quit("""
                     Could not parse input: \(repo)
                     Ensure the input is either a full Git url with https:// and .git extension
                     Or of the shorthand notation <account>/<repo>
                     """)
            }
        }

        // Create account sub-folder if it doesn't already exist in the managed directory
        let accountFolder: Folder
        if !FileManager.default.fileExists(atPath: folder.url.appendingPathComponent("\(account)").path) {
            accountFolder = try folder.createSubfolder(at: "\(account)")
        } else {
            accountFolder = try Folder(path: folder.url.appendingPathComponent("\(account)").path)
        }

        // Launch git
        do {
            let process = Process()
            if #available(macOS 10.13, *) {
                process.executableURL = URL(fileURLWithPath: gitPath)
            } else {
                process.launchPath = gitPath
            }
            process.arguments = [
                "clone",
                "\(argumentURL)",
                "\(accountFolder.url.appendingPathComponent("\(repoName)").path)"
            ]
            if #available(macOS 10.13, *) {
                try process.run()
            } else {
                process.launch()
            }
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                // If git failed for some reason, we should try to clean up
                if accountFolder.subfolders.count() == 0, accountFolder.files.count() == 0 {
                    try accountFolder.delete()
                }
                quit("An error occurred while executing 'git clone \(argumentURL)'")
            }
        }
    }
}
