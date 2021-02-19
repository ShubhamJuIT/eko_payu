#import "EkoPayuPlugin.h"
#if __has_include(<eko_payu/eko_payu-Swift.h>)
#import <eko_payu/eko_payu-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "eko_payu-Swift.h"
#endif

@implementation EkoPayuPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEkoPayuPlugin registerWithRegistrar:registrar];
}
@end
