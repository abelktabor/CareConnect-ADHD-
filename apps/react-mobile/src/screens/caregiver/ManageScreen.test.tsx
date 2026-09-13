import React from 'react';
import { fireEvent, screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { FixedClock } from '../../core/utils/clock';
import { seedCareData } from '../../data/mockData';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { ManageScreen } from './ManageScreen';

const SEED_DAY = new Date(2026, 7, 25, 14, 14);

const mockNavigate = jest.fn();
const mockRootNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({
    navigate: mockNavigate,
    getParent: () => ({ getParent: () => ({ navigate: mockRootNavigate }) }),
  }),
}));

beforeEach(() => {
  mockNavigate.mockClear();
  mockRootNavigate.mockClear();
  useClockStore.getState().setClock(new FixedClock(SEED_DAY));
  useCareDataStore.getState().hydrate(seedCareData(SEED_DAY));
});

describe('ManageScreen', () => {
  it('lists the active medications with today\'s status and opens one', () => {
    renderWithProviders(<ManageScreen />);
    expect(screen.getByText('Metformin, 500 mg')).toBeTruthy();

    fireEvent.press(screen.getByText('Metformin, 500 mg'));
    expect(mockNavigate).toHaveBeenCalledWith('MedicationDetail', { medicationId: 'med-metformin' });
  });

  it('opens the add-medication form', () => {
    renderWithProviders(<ManageScreen />);
    fireEvent.press(screen.getByTestId('manage-add-medication'));
    expect(mockRootNavigate).toHaveBeenCalledWith('MedicationForm', undefined);
  });

  it('lists upcoming appointments and opens one to edit', () => {
    renderWithProviders(<ManageScreen />);
    fireEvent.press(screen.getByText('Physical therapy'));
    expect(mockRootNavigate).toHaveBeenCalledWith('AppointmentForm', { editingId: 'appt-pt' });
  });

  it('opens the add-appointment form', () => {
    renderWithProviders(<ManageScreen />);
    fireEvent.press(screen.getByTestId('manage-add-appointment'));
    expect(mockRootNavigate).toHaveBeenCalledWith('AppointmentForm', undefined);
  });
});
