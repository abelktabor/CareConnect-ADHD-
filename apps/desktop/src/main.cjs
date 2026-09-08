/**
 * CareConnect desktop shell.
 *
 * Loads the built web app. Keeping the desktop surface a thin shell over the
 * shared web build means accessibility work done once applies everywhere, and
 * keeps the Windows/macOS dual target cheap (see ADR 0002).
 */
const { app, BrowserWindow, shell } = require('electron');
const path = require('node:path');

const isDev = !app.isPackaged;

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    // Generous minimum: the layout must still reflow without horizontal
    // scrolling, and cramped windows raise cognitive load.
    minWidth: 640,
    minHeight: 600,
    title: 'CareConnect',
    show: false,
    webPreferences: {
      // Security defaults — the renderer gets no Node access.
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
    },
  });

  // Avoid a white flash before first paint; reduced-motion friendly.
  win.once('ready-to-show', () => win.show());

  // External links open in the real browser, never in the app shell.
  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  if (isDev) {
    win.loadURL('http://localhost:5173');
  } else {
    win.loadFile(path.join(__dirname, '../../web/dist/index.html'));
  }
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
