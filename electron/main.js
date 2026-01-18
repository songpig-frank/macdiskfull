const { app, BrowserWindow } = require('electron');
const path = require('path');
const serve = require('electron-serve');

const appServe = app.isPackaged ? serve({ directory: path.join(__dirname, '../out') }) : null;

const createWindow = () => {
    const win = new BrowserWindow({
        width: 1200,
        height: 800,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: false,
            contextIsolation: true,
        },
        titleBarStyle: 'hiddenInset',
        backgroundColor: '#0f0518',
    });

    if (app.isPackaged) {
        appServe(win).then(() => {
            win.loadURL('app://-');
        });
    } else {
        win.loadURL('http://localhost:3000');
        // win.webContents.openDevTools();
    }
};

app.on('ready', () => {
    createWindow();
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});
