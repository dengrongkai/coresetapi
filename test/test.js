
require('ffi-napi')
var addon = require('../../../build/Release/CoreSetApi.node');

//exports.CoreSet = function () {
//    console.log("addon.AudioHardwareSet('BoomAudioDevice') ret=" + addon.AudioHardwareSet('BoomAudioDevice'));
//    return addon.AudioHardwareSet('BoomAudioDevice');
//}

const setDevice = '外置耳机';
console.log("addon.AudioHardwareSet('" + setDevice + "') ret=" + addon.AudioHardwareSet(setDevice));


