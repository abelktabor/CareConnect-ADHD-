import { IdGenerator } from './ids';

describe('IdGenerator', () => {
  it('prefixes and increments a counter', () => {
    const ids = new IdGenerator(() => 1000);
    expect(ids.next('dose')).toBe('dose-1000-1');
    expect(ids.next('dose')).toBe('dose-1000-2');
    expect(ids.next('act')).toBe('act-1000-3');
  });

  it('uses the injected clock', () => {
    let t = 5;
    const ids = new IdGenerator(() => t++);
    expect(ids.next('med')).toBe('med-5-1');
    expect(ids.next('med')).toBe('med-6-2');
  });

  it('defaults to Date.now when no clock is supplied', () => {
    const ids = new IdGenerator();
    const id = ids.next('appt');
    expect(id).toMatch(/^appt-\d+-1$/);
  });
});
