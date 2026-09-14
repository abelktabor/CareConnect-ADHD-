/**
 * Generates locally unique ids for new records.
 *
 * There is no backend this term, so a timestamp plus a per-instance counter
 * is enough to keep ids unique inside one device's AsyncStorage.
 *
 * Port of lib/core/utils/ids.dart.
 */
export class IdGenerator {
  private counter = 0;
  private readonly now: () => number;

  constructor(now: () => number = () => Date.now()) {
    this.now = now;
  }

  next(prefix: string): string {
    this.counter += 1;
    return `${prefix}-${this.now()}-${this.counter}`;
  }
}
