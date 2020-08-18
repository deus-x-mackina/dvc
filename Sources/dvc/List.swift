//
// Created by Danny Mack on 8/9/20.
// Copyright (c) 2020 Danny Mack.
//

import ArgumentParser
import Files
import Foundation

struct List: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ls", abstract: "List the currently cloned repos.")

    @Option(help: "Display repos as rows or columns.") var display: DisplayOption = .rows

    func run() throws {
        // Make sure we can get into the managed directory
        guard let baseDir = try? Folder(path: managedPath) else {
            quit("Could not access managed directory at: \(managedPath)")
        }

        // Create a dictionary mapping each account name to a list of all the repo names that are
        // under it.
        let mappings: [String: [String]] = Dictionary(
            uniqueKeysWithValues: baseDir.subfolders.compactMap {
                (folder: Folder) -> (String, [String])? in
                // Ignore top-level git directories (e.g., $DVC_ROOT/someRepo that contains a .git/
                // directory. This is because repos should be under a subdirectory named after the
                // repo's account holder.
                guard !folder.containsSubfolder(named: ".git") else { return nil }

                // Get the account name
                let account = folder.url.lastPathComponent

                // Get names of all the subdirectories of the account directory.
                // Here we **do** ignore directories that aren't git repos.
                let accountSubFolders = folder.subfolders
                let repos = accountSubFolders.compactMap { (sf: Folder) -> String? in
                    guard sf.containsSubfolder(named: ".git") else { return nil }
                    return sf.url.lastPathComponent
                }
                return (account, repos)
            })

        // Now we construct a list of strings from the mappings, each of the format
        // '<account>/<repo>'
        let repos: [String] = mappings.flatMap { account, repos in
            repos.map { repo in "\(account)/\(repo)" }
        }

        // Check the display option and print the results based on that
        if display == .columns {
            // The maximum column width is equal to the length of the longest entry
            // plus 2 extra characters for padding
            let maxWidth = repos.reduce(0) { max($0, $1.count) } + 2

            // Keep track of how much we've printed on the current line
            var printLength = 0

            for repo in repos {
                // Get the padding for this particular entry's length
                let padding: String = " " * (maxWidth - repo.count)

                // We don't want to print beyond eighty characters
                // If the print would overflow, enter this code block
                if printLength + repo.count + padding.count > 80 {
                    // If the print length is still zero, the repo is just really long
                    if printLength == 0 {
                        // So we'll just print it (without padding) and continue.
                        print(repo)
                        continue
                    }
                    // Otherwise, go to a new line and reset the running count
                    print()
                    printLength = 0
                }
                // Print the repo and its padding
                print(repo, terminator: padding)

                // Update the count
                printLength += repo.count + padding.count
            }
            // And drop to a new line at the very end
            print()

        } else {
            // Print each repo on its own line
            for repo in repos { print(repo) }
        }
    }
}

enum DisplayOption: String, ExpressibleByArgument { case columns, rows }

fileprivate func * (lhs: String, rhs: Int) -> String {
    switch rhs {
    case let x where x <= 0: return ""
    case 1: return lhs
    default: return lhs + (lhs * (rhs - 1))
    }
}
