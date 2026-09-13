import React from 'react';
import { fireEvent, screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { defaultNotificationSettings } from '../../models/serialization';
import { useNotificationSettingsStore } from '../../state/notificationSettingsStore';
import { NotificationsSettingsScreen } from './NotificationsSettingsScreen';

const mockGoBack = jest.fn();
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({ goBack: mockGoBack }),
}));

beforeEach(() => {
  mockGoBack.mockClear();
  useNotificationSettingsStore.setState({ ...defaultNotificationSettings(), hydrated: true });
});

describe('NotificationsSettingsScreen', () => {
  it('toggles the daily digest', () => {
    renderWithProviders(<NotificationsSettingsScreen />);
    expect(useNotificationSettingsStore.getState().dailyDigest).toBe(true);

    fireEvent(screen.getAllByRole('switch')[0], 'valueChange', false);
    expect(useNotificationSettingsStore.getState().dailyDigest).toBe(false);
  });

  it('always shows overdue alerts as on and disabled', () => {
    renderWithProviders(<NotificationsSettingsScreen />);
    const overdueSwitch = screen.getAllByRole('switch')[1];
    expect(overdueSwitch.props.value).toBe(true);
    expect(overdueSwitch.props.disabled).toBe(true);
  });

  it('changes the reminder lead time', () => {
    renderWithProviders(<NotificationsSettingsScreen />);
    fireEvent.press(screen.getByLabelText('1 day before'));
    expect(useNotificationSettingsStore.getState().leadTime).toBe('oneDay');
  });

  it('goes back', () => {
    renderWithProviders(<NotificationsSettingsScreen />);
    fireEvent.press(screen.getByLabelText('Back'));
    expect(mockGoBack).toHaveBeenCalled();
  });
});
