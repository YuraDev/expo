#import <ABI38_0_0EXCalendar/ABI38_0_0EXRemindersPermissionRequester.h>
#import <EventKit/EventKit.h>


@implementation ABI38_0_0EXRemindersPermissionRequester

+ (NSString *)permissionType
{
  return @"reminders";
}

- (NSDictionary *)getPermissions
{
  ABI38_0_0UMPermissionStatus status;
  EKAuthorizationStatus permissions;
  
  NSString *remindersUsageDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSRemindersUsageDescription"];
  if (!remindersUsageDescription) {
    ABI38_0_0UMFatal(ABI38_0_0UMErrorWithMessage(@"This app is missing NSRemindersUsageDescription, so reminders methods will fail. Add this key to your bundle's Info.plist."));
    permissions = EKAuthorizationStatusDenied;
  } else {
    permissions = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
  }
  switch (permissions) {
    case EKAuthorizationStatusAuthorized:
      status = ABI38_0_0UMPermissionStatusGranted;
      break;
    case EKAuthorizationStatusRestricted:
    case EKAuthorizationStatusDenied:
      status = ABI38_0_0UMPermissionStatusDenied;
      break;
    case EKAuthorizationStatusNotDetermined:
      status = ABI38_0_0UMPermissionStatusUndetermined;
      break;
  }
  return @{
           @"status": @(status)
          };
}

- (void)requestPermissionsWithResolver:(ABI38_0_0UMPromiseResolveBlock)resolve rejecter:(ABI38_0_0UMPromiseRejectBlock)reject
{
  EKEventStore *eventStore = [[EKEventStore alloc] init];
  ABI38_0_0UM_WEAKIFY(self)
  [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
    ABI38_0_0UM_STRONGIFY(self)
    // Error code 100 is a when the user denies permission; in that case we don't want to reject.
    if (error && error.code != 100) {
      reject(@"E_REMINDERS_ERROR_UNKNOWN", error.localizedDescription, error);
    } else {
      resolve([self getPermissions]);
    }
  }];
}

@end
