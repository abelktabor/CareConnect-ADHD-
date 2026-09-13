import { useActivityFilterStore } from './activityFilterStore';

describe('activityFilterStore', () => {
  beforeEach(() => {
    useActivityFilterStore.setState({ filter: 'all' });
  });

  it('defaults to "all"', () => {
    expect(useActivityFilterStore.getState().filter).toBe('all');
  });

  it('updates the filter', () => {
    useActivityFilterStore.getState().setFilter('medications');
    expect(useActivityFilterStore.getState().filter).toBe('medications');

    useActivityFilterStore.getState().setFilter('appointments');
    expect(useActivityFilterStore.getState().filter).toBe('appointments');
  });
});
