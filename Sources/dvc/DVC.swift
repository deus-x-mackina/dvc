//
// Created by Danny Mack on 8/9/20.
// Copyright (c) 2020 Danny Mack.
//

import ArgumentParser
import Foundation

struct DVC: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dvc", abstract: "Manage cloned GitHub repos.", version: "0.1.4",
        subcommands: [Clone.self, Remove.self, List.self, Prefix.self]
    )
}
