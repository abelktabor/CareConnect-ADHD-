import React from 'react';
import { fireEvent, screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { FixedClock } from '../../core/utils/clock';
import { seedCareData } from '../../data/mockData';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { AppointmentsScreen } from './AppointmentsScreen';

const SEED_DAY = new Date(2026, 7, 25, 14, 14);

const mockParentNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({ getParent: () => ({ navigate: mockParentNavigate }) }),
}));

beforeEach(() => {
  mockParentNavigate.mockClear();
  useClockStore.getState().setClock(new FixedClock(SEED_DAY));
  useCareDataStore.getState().hydrate(seedCareData(SEED_DAY));
});

describe('AppointmentsScreen', () => {
  it('lists upcoming appointments and opens one to edit', () => {
    renderWithProviders(<AppointmentsScreen />);
    expect(screen.getByText('Physical therapy')).toBeTruthy();

    fireEvent.press(screen.getByText('Physical therapy'));
    expect(mockParentNavigate).toHaveBeenCalledWith('AppointmentForm', { editingId: 'appt-pt' });
  });

  it('opens the add-appointment form', () => {
    renderWithProviders(<AppointmentsScreen />);
    fireEvent.press(screen.getByTestId('add-appointment'));
    expect(mockParentNavigate).toHaveBeenCalledWith('AppointmentForm', undefined);
  });

  it('shows an empty state with no upcoming appointments', () => {
    useCareDataStore.setState((state) => ({ data: { ...state.data, appointments: [] } }));
    renderWithProviders(<AppointmentsScreen />);
    expect(screen.getByText('No upcoming appointments.')).toBeTruthy();
  });
});
