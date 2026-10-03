export const SaveZUseCaseKey: InjectionKey<SaveZUseCase> = Symbol('x')
app.provide(SaveZUseCaseKey, new SaveZUseCase())
