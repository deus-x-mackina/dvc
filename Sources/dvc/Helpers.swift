//
// Created by Danny Mack on 8/9/20.
// Copyright (c) 2020 Danny Mack.
//

import Files
import Foundation

/// Utility function for printing to standard error and aborting.
func quit(_ message: String) -> Never {
    var message = message
    if message.last != nil, message.last.unsafelyUnwrapped != "\n" { message += "\n" }
    fputs(message, stderr)
    exit(EXIT_FAILURE)
}

/// Extract an account and repo name from an input of format '<account>/<repo>'
/// and returns two `Folder` objects for each.
///
/// Currently this is only used by the `ls` subcommand.
/// I had refactored it here because it was going to be used elsewhere,
/// but ended up not using it there.
///
/// - Parameter argument: The argument from stdin to parse, representing a user and a repo
/// - Returns: A `Folder` object tuple with the account parent folder and the repo child folder.
func extract(argument: String) -> (accountFolder: Folder, repoFolder: Folder) {
    let extracted = argument.split(separator: "/")

    guard extracted.count == 2 else { quit("DVC: fatal: Invalid input: \(argument)") }

    let account = extracted[0]
    let repo = extracted[1]

    guard let accountFolder = try? Folder(path: "\(MANAGED_PATH)/\(account)"),
        let repoFolder = try? accountFolder.subfolder(named: "\(repo)")
    else {
        quit("DVC: The repo \(argument) was not found in the managed directory: \(MANAGED_PATH)")
    }

    return (accountFolder, repoFolder)
}
