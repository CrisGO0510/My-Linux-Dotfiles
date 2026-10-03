export class Z {
  readonly id: string
  name: string
  constructor(public code: string, private readonly ok: string) {}
  get label(): string {
    return this.name
  }
}
