import React from 'react';
import { fireEvent, screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { seedCareData } from '../../data/mockData';
import { useActivityFilterStore } from '../../state/activityFilterStore';
import { useCareDataStore } from '../../state/careDataStore';
import { ActivityTimelineScreen } from './ActivityTimelineScreen';

const SEED_DAY = new Date(2026, 7, 25, 14, 14);

beforeEach(() => {
  useCareDataStore.getState().hydrate(seedCareData(SEED_DAY));
  useActivityFilterStore.setState({ filter: 'all' });
});

describe('ActivityTimelineScreen', () => {
  it('lists activity grouped by day, newest first', () => {
    renderWithProviders(<ActivityTimelineScreen />);
    expect(screen.getByText('Muhammad logged Lisinopril taken at 8:04 AM')).toBeTruthy();
    expect(screen.getByText('Renee added a note to Lisinopril')).toBeTruthy();
  });

  it('filters down to appointments only', () => {
    renderWithProviders(<ActivityTimelineScreen />);
    fireEvent.press(screen.getByLabelText('Appointments'));

    expect(useActivityFilterStore.getState().filter).toBe('appointments');
    expect(screen.getByText('Muhammad updated the appointment time to 2:30 PM')).toBeTruthy();
    expect(screen.queryByText('Renee added a note to Lisinopril')).toBeNull();
  });

  it('filters down to medications only', () => {
    renderWithProviders(<ActivityTimelineScreen />);
    fireEvent.press(screen.getByLabelText('Medications'));
    expect(useActivityFilterStore.getState().filter).toBe('medications');
    expect(screen.getByText('Muhammad skipped Vitamin D at 8:15 AM')).toBeTruthy();
  });

  it('shows an empty state when nothing matches the filter', () => {
    useCareDataStore.setState((state) => ({ data: { ...state.data, activity: [] } }));
    renderWithProviders(<ActivityTimelineScreen />);
    expect(screen.getByText('No activity to show.')).toBeTruthy();
  });
});
