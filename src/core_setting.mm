// core_setting.cc using N-API
#include <node_api.h>
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

namespace boom {

napi_value AudioHardwareSet(napi_env env, napi_callback_info args) {
  napi_value result;
  napi_status status;

  size_t argc = 1;
  napi_value arg_value;
  status = napi_get_cb_info(env, args, &argc, &arg_value, nullptr, nullptr);
  if(status != napi_ok){
    status = napi_create_string_utf8(env, "Too few arguments", NAPI_AUTO_LENGTH, &result);
    //napi_throw_error(env, "EINVAL", "Too few arguments");
    return result;
  }

  char szDeviceID[256];
  size_t str_len = 256;
  status = napi_get_value_string_utf8(env, arg_value, szDeviceID, 256, &str_len);
  if(status != napi_ok){
    status = napi_create_string_utf8(env, "Expected string", NAPI_AUTO_LENGTH, &result);
    //napi_throw_error(env, "EINVAL", "Expected string");
    return result;
  }
  NSString *strSetDeviceID = [NSString stringWithCString:szDeviceID encoding:NSUTF8StringEncoding];
  if(strSetDeviceID == nil){
     status = napi_create_string_utf8(env, "Device id error", NAPI_AUTO_LENGTH, &result);
    return result;   
  }

  UInt32 uSetDeviceID = [strSetDeviceID intValue];
  BOOL isFindDevice = false;
  BOOL isOutputDevice = false;
  UInt32 propertySize;
  UInt32 tmpPropertySize = 256;
  AudioDeviceID devices[64];
  int devicesCount = 0;
  AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &propertySize, NULL);
  AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &propertySize, devices);
  devicesCount = (propertySize / sizeof(AudioDeviceID));
  for(int i = 0; i < devicesCount; ++i) {
    tmpPropertySize = 256;
    AudioDeviceGetPropertyInfo(devices[i], 0, false, kAudioDevicePropertyStreams, &tmpPropertySize, NULL);
    isOutputDevice = (tmpPropertySize > 0);
    if (isOutputDevice && devices[i] == uSetDeviceID) {
      isFindDevice = true;
    }
  }

  if(isFindDevice){
    propertySize = sizeof(UInt32);
    AudioHardwareSetProperty(kAudioHardwarePropertyDefaultOutputDevice, propertySize, &uSetDeviceID);
    status = napi_create_string_utf8(env, "OK", NAPI_AUTO_LENGTH, &result);
  }else{
    NSString* info = @"Not found devcie id: ";
    info = [info stringByAppendingString:strSetDeviceID];
    const char * pInfo =[info UTF8String];
    status = napi_create_string_utf8(env, pInfo, NAPI_AUTO_LENGTH, &result);
  }
  return result;
}


napi_value AudioHardwareGet(napi_env env, napi_callback_info args) {
  napi_value result;
  napi_status status;

  AudioDeviceID deviceID = kAudioDeviceUnknown;
  UInt32 propertySize = sizeof(deviceID);
  AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &propertySize, &deviceID);
  NSString *strDeviceID = [NSString stringWithFormat:@"%u",deviceID];
  const char * pInfo =[strDeviceID UTF8String];
  status = napi_create_string_utf8(env, pInfo, NAPI_AUTO_LENGTH, &result);
  return result;
}

napi_value AudioHardwareGetList(napi_env env, napi_callback_info args) {
  napi_value result;
  napi_status status;

  UInt32 newDeviceID = 0;
  UInt32 propertySize;
  UInt32 tmpPropertySize = 256;
  AudioDeviceID devices[64];
  int devicesCount = 0;
  AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &propertySize, NULL);
  AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &propertySize, devices);
  devicesCount = (propertySize / sizeof(AudioDeviceID));
  NSString *strDeviceList = @"";
  BOOL isOutputDevice = false;
  for(int i = 0; i < devicesCount; ++i) {
    tmpPropertySize = 256;
    AudioDeviceGetPropertyInfo(devices[i], 0, false, kAudioDevicePropertyStreams, &tmpPropertySize, NULL);
    isOutputDevice = (tmpPropertySize > 0);
    if (isOutputDevice) {
      tmpPropertySize = 256;
      char deviceName[256] = { 0 };
      AudioDeviceGetProperty(devices[i], 0, false, kAudioDevicePropertyDeviceName, &tmpPropertySize, deviceName);
      NSString *curDeviceName = [NSString stringWithCString:deviceName encoding:NSUTF8StringEncoding];
      if([strDeviceList length] > 0){
        strDeviceList = [strDeviceList stringByAppendingString:@","];
      }
      NSString *strDeviceID = [NSString stringWithFormat:@"%u",devices[i]];
      strDeviceList = [strDeviceList stringByAppendingString:strDeviceID];
      strDeviceList = [strDeviceList stringByAppendingString:@"::"];
      if(curDeviceName != nil){
       strDeviceList = [strDeviceList stringByAppendingString:curDeviceName];       
      } 
    }
  }

  const char * pInfo =[strDeviceList UTF8String];
  status = napi_create_string_utf8(env, pInfo, NAPI_AUTO_LENGTH, &result);
  return result;
}

napi_value init(napi_env env, napi_value exports) {
  napi_status status;
  napi_value fn;

  status = napi_create_function(env, nullptr, 0, AudioHardwareSet, nullptr, &fn);
  if (status != napi_ok) return nullptr;

  status = napi_set_named_property(env, exports, "AudioHardwareSet", fn);
  if (status != napi_ok) return nullptr;

  status = napi_create_function(env, nullptr, 0, AudioHardwareGet, nullptr, &fn);
  if (status != napi_ok) return nullptr;

  status = napi_set_named_property(env, exports, "AudioHardwareGet", fn);
  if (status != napi_ok) return nullptr;

  status = napi_create_function(env, nullptr, 0, AudioHardwareGetList, nullptr, &fn);
  if (status != napi_ok) return nullptr;

  status = napi_set_named_property(env, exports, "AudioHardwareGetList", fn);
  if (status != napi_ok) return nullptr;

  return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, init)

}  // namespace boom

