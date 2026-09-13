/**
 * Accessibility-prop coverage for the shared widgets every screen is built
 * from. These assert the WCAG-driving contract directly — an accessible
 * role/label/state on the right element — rather than re-deriving it from a
 * screen, so a regression here fails close to its cause.
 */
import React from 'react';
import { screen } from '@testing-library/react-native';

import { renderWithProviders } from '../../test-utils';
import { AlertCard } from './AlertCard';
import { ChoiceGroup } from './ChoiceGroup';
import { CcListItem } from './CcListItem';
import { StatusChip } from './StatusChip';
import { StepIndicator } from './StepIndicator';

describe('StatusChip', () => {
  it('never relies on colour alone — exposes a spoken label via accessibility, not just the icon colour', () => {
    renderWithProviders(<StatusChip tone="overdue" text="Overdue" spoken="Status: overdue, 45 min late" />);
    expect(screen.getByLabelText('Status: overdue, 45 min late')).toBeTruthy();
  });

  it('falls back to the visible text as the accessible name when no spoken override is given', () => {
    renderWithProviders(<StatusChip tone="taken" text="Taken · 8:04 AM" />);
    expect(screen.getByLabelText('Taken · 8:04 AM')).toBeTruthy();
  });
});

describe('CcListItem', () => {
  it('exposes a button role and a merged title+subtitle accessible name when pressable', () => {
    renderWithProviders(
      <CcListItem title="Metformin, 500 mg" subtitle="Due at 2:34 PM" onPress={() => {}} />,
    );
    const row = screen.getByRole('button');
    expect(row.props.accessibilityLabel).toBe('Metformin, 500 mg. Due at 2:34 PM');
  });

  it('carries the screen-reader hint describing what the tap does', () => {
    renderWithProviders(
      <CcListItem title="Metformin, 500 mg" onPress={() => {}} semanticHint="Opens the medication" />,
    );
    expect(screen.getByRole('button').props.accessibilityHint).toBe('Opens the medication');
  });
});

describe('AlertCard', () => {
  it('prefixes the accessible name with "Alert:" so it reads distinctly from ordinary rows', () => {
    renderWithProviders(<AlertCard text="Overdue — 1:29 PM Atorvastatin not yet confirmed" onPress={() => {}} />);
    expect(
      screen.getByLabelText('Alert: Overdue — 1:29 PM Atorvastatin not yet confirmed'),
    ).toBeTruthy();
  });
});

describe('ChoiceGroup', () => {
  it('exposes a radiogroup of radio items with the selected one checked', () => {
    renderWithProviders(
      <ChoiceGroup
        groupLabel="I am a"
        selected="caregiver"
        onSelect={() => {}}
        options={[
          { value: 'careRecipient', label: 'Care Recipient' },
          { value: 'caregiver', label: 'Caregiver' },
        ]}
      />,
    );
    expect(screen.getByRole('radiogroup')).toBeTruthy();
    const selected = screen.getByLabelText('Caregiver');
    expect(selected.props.accessibilityState).toEqual({ selected: true, checked: true });
    const unselected = screen.getByLabelText('Care Recipient');
    expect(unselected.props.accessibilityState).toEqual({ selected: false, checked: false });
  });
});

describe('StepIndicator', () => {
  it('is a live region announcing the current step without moving focus', () => {
    renderWithProviders(
      <StepIndicator step={2} totalSteps={3} title="Schedule" subtitle="When each dose is due" />,
    );
    const live = screen.getByLabelText('Step 2 of 3, Schedule');
    expect(live.props.accessibilityLiveRegion).toBe('polite');
  });

  it('reports progress through accessibilityValue on a progressbar role', () => {
    renderWithProviders(<StepIndicator step={2} totalSteps={3} title="Schedule" />);
    const bar = screen.getByRole('progressbar');
    expect(bar.props.accessibilityValue).toEqual({ min: 0, max: 3, now: 2 });
  });
});
