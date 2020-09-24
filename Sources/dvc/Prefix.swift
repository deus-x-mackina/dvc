import ArgumentParser

struct Prefix: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Print the path of the directory that DVC manages."
    )

    func run() throws {
        print(MANAGED_PATH)
    }
}
