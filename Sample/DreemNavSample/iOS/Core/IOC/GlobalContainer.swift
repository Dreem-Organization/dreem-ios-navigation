import Swinject

private let globalContainer = Assembler(container: Container())

public func register(assembly: Assembly) {
    globalContainer.apply(assembly: assembly)
}

public func register(assemblies: [Assembly]) {
    globalContainer.apply(assemblies: assemblies)
}

public func resolve<T>(name: String? = nil) -> T {
    globalContainer.resolver.resolve(T.self, name: name)!
}
