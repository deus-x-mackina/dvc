//
// Created by Danny Mack on 8/9/20.
// Copyright (c) 2020 Danny Mack.
//

import ArgumentParser
import Foundation

struct DVC: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dvc", abstract: "Manage cloned GitHub repos.", version: "0.1.4",
        subcommands: [Clone.self, Remove.self, List.self]
    )

    @Flag(help: "Print the path of the directory that DVC manages.") var prefix = false

    func run() throws {
        // If no subcommand is given, print the prefix is asked, otherwise display the help text
        if prefix {
            print(MANAGED_PATH)
        } else {
            print(Self.helpMessage())
        }
    }
}
