const coreSetApi
    = require("../../build/Release/CoreSetApi.node");

/**
 * Set mac system audio output device
 * Returns the set result
 * @param {string} deviceName - The audio output device id.
 * @returns {string} "OK" or error
 * only for Mac OS
 */
module.exports = function(deviceName) {
    if(typeof deviceName !== "string" || deviceName === '') {
        return undefined;
    }
    // if success return "OK" else return "error msg"
    return coreSetApi.AudioHardwareSet(deviceName);
};
