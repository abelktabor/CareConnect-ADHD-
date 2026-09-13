import React from 'react';
import { fireEvent, screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { FixedClock } from '../../core/utils/clock';
import { seedCareData } from '../../data/mockData';
import { defaultAppSettings } from '../../models/serialization';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { useSettingsStore } from '../../state/settingsStore';
import { CaregiverAccessScreen } from './CaregiverAccessScreen';

const SEED_DAY = new Date(2026, 7, 25, 14, 14);

const mockGoBack = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({ goBack: mockGoBack }),
}));

beforeEach(() => {
  mockGoBack.mockClear();
  useClockStore.getState().setClock(new FixedClock(SEED_DAY));
  useCareDataStore.getState().hydrate(seedCareData(SEED_DAY));
  useSettingsStore.setState({ ...defaultAppSettings(), hydrated: true });
});

describe('CaregiverAccessScreen', () => {
  it('lists what the caregiver can see and reflects sharing being on', () => {
    renderWithProviders(<CaregiverAccessScreen />);
    expect(screen.getByText('Medication names, doses, and status')).toBeTruthy();
    expect(screen.getByText('Sharing is on. Renee sees the list above.')).toBeTruthy();
  });

  it('pauses sharing', () => {
    renderWithProviders(<CaregiverAccessScreen />);
    fireEvent(screen.getByRole('switch'), 'valueChange', false);
    expect(useSettingsStore.getState().shareWithCaregiver).toBe(false);
  });

  it('goes back', () => {
    renderWithProviders(<CaregiverAccessScreen />);
    fireEvent.press(screen.getByLabelText('Back'));
    expect(mockGoBack).toHaveBeenCalled();
  });
});
