import React from 'react';
import { fireEvent, screen, waitFor } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { FixedClock } from '../../core/utils/clock';
import { seedCareData } from '../../data/mockData';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { CaregiverDashboardScreen } from './CaregiverDashboardScreen';

// At 2:14 PM, Atorvastatin (1:29 PM) is overdue and Metformin (2:34 PM) is
// the next upcoming dose — the same instant used across the other screen
// tests (see TodayScreen.test.tsx).
const SEED_DAY = new Date(2026, 7, 25, 14, 14);

const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({ navigate: mockNavigate }),
}));

beforeEach(() => {
  mockNavigate.mockClear();
  useClockStore.getState().setClock(new FixedClock(SEED_DAY));
  useCareDataStore.getState().hydrate(seedCareData(SEED_DAY));
});

describe('CaregiverDashboardScreen', () => {
  it('surfaces the overdue dose as an alert that opens the medication', () => {
    renderWithProviders(<CaregiverDashboardScreen />);
    const alert = screen.getByText(/Overdue — 1:29 PM Atorvastatin not yet confirmed/);
    fireEvent.press(alert);
    expect(mockNavigate).toHaveBeenCalledWith('ManageStack', {
      screen: 'MedicationDetail',
      params: { medicationId: 'med-atorvastatin' },
    });
  });

  it('logs the next upcoming dose from the dashboard card', async () => {
    renderWithProviders(<CaregiverDashboardScreen />);
    fireEvent.press(screen.getByText('Log now'));

    await waitFor(() => {
      const dose = useCareDataStore
        .getState()
        .data.doseEvents.find((d) => d.medicationId === 'med-metformin' && d.status === 'taken');
      expect(dose).toBeDefined();
    });
  });

  it('opens the full activity history', () => {
    renderWithProviders(<CaregiverDashboardScreen />);
    fireEvent.press(screen.getByTestId('view-full-history'));
    expect(mockNavigate).toHaveBeenCalledWith('Activity');
  });

  it('shows an all-clear empty state once nothing needs attention', () => {
    useCareDataStore.setState((state) => ({
      data: {
        ...state.data,
        doseEvents: state.data.doseEvents.map((d) =>
          d.status === 'due' ? { ...d, status: 'taken' as const, recordedAt: SEED_DAY } : d,
        ),
      },
    }));
    renderWithProviders(<CaregiverDashboardScreen />);
    expect(screen.getByText('Nothing needs attention right now.')).toBeTruthy();
  });
});
