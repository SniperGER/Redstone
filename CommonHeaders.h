#import <objc/runtime.h>
#import "CAKeyframeAnimation+AHEasing.h"
#import <AudioToolbox/AudioServices.h>

#define ANIM_SCALE_DURATION 0.225
#define ANIM_ALPHA_DURATION 0.2
#define ANIM_DELAY 0.01

extern void AudioServicesPlaySystemSoundWithVibration(int, id, NSDictionary *);

@interface SBIcon

-(NSString *)displayName;
-(id)leafIdentifier;
-(BOOL)isUninstallSupported;

@end

@interface SBIconModel : NSObject

-(id)leafIconForIdentifier:(id)arg1;
-(id)visibleIconIdentifiers;

@end

@interface SBIconController : NSObject

+(id)sharedInstance;
-(id)model;
-(void)_launchIcon:(id)arg1;

@end

@interface SBApplicationInfo : NSObject

@property (nonatomic,copy,readonly) NSString * displayName;

@end