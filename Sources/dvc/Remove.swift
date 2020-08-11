//
// Created by Danny Mack on 8/9/20.
// Copyright (c) 2020 Danny Mack.
//

import Foundation
import ArgumentParser
import Files

struct Remove: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "rm",
        abstract: "Remove a cloned repository.")

    @Argument(
        help: """
              The repository to remove. Should be in the form <account>/<repo>
              """
    ) var repo: String

    @Flag(help: """
                By default, DVC will remove an account directory if it not longer contains anything
                after a repo removal. However, this is blocked if the account directory contains any
                files or subdirectories in it (whether they are git repos or not). On MacOS systems, 
                .DS_Store files in the account directory may also cause this behavior. Add this flag
                to remove the account directory only if it doesn't contain any git repos, ignoring
                other files and subdirectories.
                """)
    var aggressiveClean = false

    func run() throws {
        let (accountFolder, repoFolder) = extract(argument: repo)

        // Only delete a folder that is actually a Git repository!
        guard repoFolder.containsSubfolder(named: ".git") else {
            quit("The folder '\(repoFolder.path)' is not a Git repository. Aborting...")
        }

        try repoFolder.delete()

        if aggressiveClean {
            var abort = false
            for subdir: Folder in accountFolder.subfolders {
                if subdir.containsSubfolder(named: ".git") {
                    abort = true
                    break
                }
            }
            if !abort {
                try accountFolder.delete()
            }
        } else {
            if accountFolder.subfolders.count() == 0, accountFolder.files.count() == 0 {
                try accountFolder.delete()
            }
        }
        print("Deleted cloned repo: \(repoFolder.path)")
    }
}
