#import <UIKit/UIKit.h>

@interface RSTiltView : UIView {
	CATransform3D _layerTransform;
	float _transformAngle;
	float _transformMultiplierX;
	float _transformMultiplierY;
	BOOL _hasHighlight;
	BOOL _keepsHighlightOnLongPress;
	BOOL _isUntilted;
}

@property (nonatomic,assign) float transformAngle;
@property (nonatomic,assign) float transformMultiplierX;
@property (nonatomic,assign) float transformMultiplierY;
@property (nonatomic,assign) BOOL hasHighlight;
@property (nonatomic,assign) BOOL keepsHighlightOnLongPress;

-(void)setTransformOptions:(NSDictionary*)options;
-(void)setHighlighted:(BOOL)highlighted;

-(void)setTransformMultiplierAngle:(float)angle;
-(void)setTransformMultiplierX:(float)multiplier;
-(void)setTransformMultiplierY:(float)multiplier;

-(void)untilt:(BOOL)animated;

@end