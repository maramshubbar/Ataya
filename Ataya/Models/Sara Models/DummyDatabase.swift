class DummyDatabase {
    static let shared = DummyDatabase()

    private init() {}

    var collectors: [String: UserProfile] = [
        "collector_1": UserProfile(
            id: "collector_1",
            name: "Zahra Ahmed",
            role: "Collector",
            reviews: []
        )
    ]
}

