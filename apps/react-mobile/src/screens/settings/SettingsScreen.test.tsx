import React from 'react';
import { fireEvent, screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { FixedClock } from '../../core/utils/clock';
import { seedCareData } from '../../data/mockData';
import { useCareDataStore } from '../../state/careDataStore';
import { useClockStore } from '../../state/clockStore';
import { useSessionStore } from '../../state/sessionStore';
import { SettingsScreen } from './SettingsScreen';

const SEED_DAY = new Date(2026, 7, 25, 14, 14);

const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({ navigate: mockNavigate }),
}));

function resetStores(role: 'careRecipient' | 'caregiver' = 'careRecipient') {
  useClockStore.getState().setClock(new FixedClock(SEED_DAY));
  useCareDataStore.getState().hydrate(seedCareData(SEED_DAY));
  useSessionStore.setState({
    session: { role, method: 'passkey', signedInAt: SEED_DAY, email: null },
    hydrated: true,
  });
}

beforeEach(() => {
  mockNavigate.mockClear();
  resetStores();
});

describe('SettingsScreen', () => {
  it('opens Notifications and App Settings, plus Caregiver Access for a care recipient', () => {
    renderWithProviders(<SettingsScreen />);

    fireEvent.press(screen.getByTestId('settings-notifications'));
    expect(mockNavigate).toHaveBeenCalledWith('Notifications');

    expect(screen.getByTestId('settings-caregiver-access')).toBeTruthy();
    fireEvent.press(screen.getByTestId('settings-caregiver-access'));
    expect(mockNavigate).toHaveBeenCalledWith('CaregiverAccess');

    fireEvent.press(screen.getByTestId('settings-app'));
    expect(mockNavigate).toHaveBeenCalledWith('AppSettings');
  });

  it('hides "My Caregiver Access" for a caregiver', () => {
    resetStores('caregiver');
    renderWithProviders(<SettingsScreen />);
    expect(screen.queryByTestId('settings-caregiver-access')).toBeNull();
  });
});
