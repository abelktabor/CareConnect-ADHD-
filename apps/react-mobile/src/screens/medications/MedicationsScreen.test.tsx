import React from 'react';
import { fireEvent, screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { FixedClock } from '../../core/utils/clock';
import { seedCareData } from '../../data/mockData';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { MedicationsScreen } from './MedicationsScreen';

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

describe('MedicationsScreen', () => {
  it('lists every active medication with its status for today and opens one', () => {
    renderWithProviders(<MedicationsScreen />);
    expect(screen.getByText('Lisinopril, 10 mg')).toBeTruthy();
    // Vitamin D has instructions and shows them on the card.
    expect(screen.getByText('Take with breakfast.')).toBeTruthy();

    fireEvent.press(screen.getByLabelText('Metformin, 500 mg'));
    expect(mockNavigate).toHaveBeenCalledWith('MedicationDetail', { medicationId: 'med-metformin' });
  });

  it('opens the add-medication form', () => {
    renderWithProviders(<MedicationsScreen />);
    fireEvent.press(screen.getByTestId('add-medication'));
    expect(mockRootNavigate).toHaveBeenCalledWith('MedicationForm');
  });

  it('shows an empty state with no medications', () => {
    useCareDataStore.setState((state) => ({ data: { ...state.data, medications: [] } }));
    renderWithProviders(<MedicationsScreen />);
    expect(screen.getByText('No medications yet.')).toBeTruthy();
  });
});
