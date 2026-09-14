import { contrastRatio, meetsAa, parseHexColor, relativeLuminance } from './contrast';

describe('parseHexColor', () => {
  it('parses 6-digit hex', () => {
    expect(parseHexColor('#FFFFFF')).toEqual({ r: 1, g: 1, b: 1 });
    expect(parseHexColor('#000000')).toEqual({ r: 0, g: 0, b: 0 });
  });

  it('parses 3-digit shorthand hex', () => {
    expect(parseHexColor('#FFF')).toEqual({ r: 1, g: 1, b: 1 });
  });

  it('throws on an invalid string', () => {
    expect(() => parseHexColor('not-a-color')).toThrow();
  });
});

describe('relativeLuminance', () => {
  it('white is 1, black is 0', () => {
    expect(relativeLuminance('#FFFFFF')).toBeCloseTo(1, 5);
    expect(relativeLuminance('#000000')).toBeCloseTo(0, 5);
  });
});

describe('contrastRatio', () => {
  it('black on white is 21:1', () => {
    expect(contrastRatio('#000000', '#FFFFFF')).toBeCloseTo(21, 0);
  });

  it('a colour against itself is 1:1', () => {
    expect(contrastRatio('#1B5E7A', '#1B5E7A')).toBeCloseTo(1, 5);
  });

  it('is symmetric', () => {
    expect(contrastRatio('#1B5E7A', '#FFFFFF')).toBeCloseTo(
      contrastRatio('#FFFFFF', '#1B5E7A'),
      5,
    );
  });
});

describe('meetsAa', () => {
  it('passes normal text at 4.5:1 or above', () => {
    // AppColors.neutral900 on white from the design token table (16.94:1).
    expect(meetsAa('#1A1D1F', '#FFFFFF')).toBe(true);
  });

  it('fails normal text below 4.5:1', () => {
    expect(meetsAa('#CCCCCC', '#FFFFFF')).toBe(false);
  });

  it('accepts large text / UI elements at the lower 3:1 threshold', () => {
    // A ratio between 3:1 and 4.5:1 should pass only when large/UI.
    const fg = '#767C82'; // neutral-500
    const bg = '#FFFFFF';
    const ratio = contrastRatio(fg, bg);
    expect(ratio).toBeGreaterThanOrEqual(3);
    if (ratio < 4.5) {
      expect(meetsAa(fg, bg)).toBe(false);
      expect(meetsAa(fg, bg, { largeTextOrUi: true })).toBe(true);
    }
  });

  it('every AppColors status colour meets AA on white', () => {
    const statusColorsOnWhite = {
      accent: '#C24A34',
      success: '#2E7D4F',
      warning: '#8A5A00',
      error: '#B3261E',
      info: '#2B6CB0',
    };
    for (const [name, hex] of Object.entries(statusColorsOnWhite)) {
      expect(meetsAa(hex, '#FFFFFF', { largeTextOrUi: true })).toBe(true);
      void name;
    }
  });
});
