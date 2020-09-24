import ArgumentParser

struct Prefix: ParsableCommand {
    func run() throws {
        print(MANAGED_PATH)
    }
}
