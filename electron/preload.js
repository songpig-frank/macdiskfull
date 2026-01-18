const { contextBridge } = require('electron');

contextBridge.exposeInMainWorld('electron', {
    // Expose APIs here if needed for the builder functionality later
});
