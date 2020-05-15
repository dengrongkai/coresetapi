
require('ffi-napi')
var addon = require('../build/Release/CoreSetApi.node');

//exports.CoreSet = function () {
//    console.log("addon.AudioHardwareSet('BoomAudioDevice') ret=" + addon.AudioHardwareSet('BoomAudioDevice'));
//    return addon.AudioHardwareSet('BoomAudioDevice');
//}


console.log("cur device:" + addon.AudioHardwareGet());
console.log("all devices:" + addon.AudioHardwareGetList());

const setDevice = '116';
console.log("addon.AudioHardwareSet('" + setDevice + "') ret=" + addon.AudioHardwareSet(setDevice));


