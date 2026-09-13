import React from 'react';
import { fireEvent, screen, waitFor } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { FixedClock } from '../../core/utils/clock';
import { seedCareData } from '../../data/mockData';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { useSessionStore } from '../../state/sessionStore';
import { useSettingsStore } from '../../state/settingsStore';
import { TodayScreen } from './TodayScreen';

// The Week 3 design instant: Metformin (2:34 PM) is 20 minutes out, making
// it the dominant "next action"; Atorvastatin (1:29 PM) is already overdue
// and so drops out of "Later today" (it is not the next upcoming dose).
const SEED_DAY = new Date(2026, 7, 25, 14, 14);

const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({ navigate: mockNavigate }),
}));

function resetStores() {
  useClockStore.getState().setClock(new FixedClock(SEED_DAY));
  useSettingsStore.setState({ ...useSettingsStore.getState(), demoClock: false, hydrated: true });
  useSessionStore.setState({
    session: { role: 'careRecipient', method: 'passkey', signedInAt: SEED_DAY, email: null },
    hydrated: true,
  });
  useCareDataStore.getState().hydrate(seedCareData(SEED_DAY));
}

beforeEach(() => {
  mockNavigate.mockClear();
  resetStores();
});

describe('TodayScreen', () => {
  it('shows the dominant next-action dose card for the upcoming Metformin dose', () => {
    renderWithProviders(<TodayScreen />);
    expect(screen.getByTestId('today-dose-card')).toBeTruthy();
    expect(screen.getByText('Metformin, 500 mg')).toBeTruthy();
  });

  it('lists the later, still-upcoming dose (Lisinopril) under "Later today"', () => {
    renderWithProviders(<TodayScreen />);
    expect(screen.getByText('Later today')).toBeTruthy();
    expect(screen.getByText('Lisinopril, 10 mg')).toBeTruthy();
  });

  it('marks the next dose taken and offers undo', async () => {
    renderWithProviders(<TodayScreen />);
    fireEvent.press(screen.getByText('Mark as Taken'));

    await waitFor(() => {
      const dose = useCareDataStore
        .getState()
        .data.doseEvents.find((d) => d.medicationId === 'med-metformin' && d.status === 'taken');
      expect(dose).toBeDefined();
    });
    expect(await screen.findByText('Undo')).toBeTruthy();
  });

  it('opens the tapped medication from "Later today"', () => {
    renderWithProviders(<TodayScreen />);
    fireEvent.press(screen.getByText('Lisinopril, 10 mg'));
    expect(mockNavigate).toHaveBeenCalledWith('MedicationsStack', {
      screen: 'MedicationDetail',
      params: { medicationId: 'med-lisinopril' },
    });
  });

  it('shows the all-logged empty state once every dose is accounted for', () => {
    useCareDataStore.setState((state) => ({
      data: {
        ...state.data,
        doseEvents: state.data.doseEvents.map((d) =>
          d.status === 'due' ? { ...d, status: 'taken' as const, recordedAt: SEED_DAY } : d,
        ),
      },
    }));
    renderWithProviders(<TodayScreen />);
    // The same line appears both in the orientation bar's "next" line and
    // in the empty-state message, so assert on the empty state's unique
    // supporting detail instead of the (duplicated) headline text.
    expect(
      screen.getByText('Nothing else is due today. Tomorrow’s first dose will appear here in the morning.'),
    ).toBeTruthy();
  });
});
