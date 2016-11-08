#import <UIKit/UIKit.h>

@class RSStartScrollView, RSTile;

@interface RSStartScreenController : NSObject {
	RSTile* selectedTile;
	BOOL _isEditing;
	RSStartScrollView* _startScrollView;
	NSMutableArray* pinnedLeafIds;
}

@property (assign,nonatomic) BOOL isEditing; 
@property (assign,nonatomic) BOOL isPinningTile;

+(id)sharedInstance;
-(void)setIsPinningTile:(BOOL)arg1 ;
-(double)distanceBetweenPointOne:(CGPoint)arg1 pointTwo:(CGPoint)arg2;
-(void)loadTiles;
-(void)saveTiles;
-(void)updateStartContentSize;
-(void)pinTileWithId:(NSString*)leafId;
-(void)unpinTile:(RSTile*)tile;
-(void)returnToHomescreen;
-(void)prepareForAppLaunch:(id)sender;
-(RSStartScrollView*)startScrollView;
-(void)setIsEditing:(BOOL)isEditing;
-(BOOL)isEditing;
-(void)setSelectedTile:(RSTile*)tile;
-(RSTile*)selectedTile;
-(void)updatePreferences;
-(id)affectedTilesForAttemptingSnapForRect:(CGRect)rect;

-(NSArray*)pinnedLeafIdentifiers;
-(void)resetTileVisibility;

@end;