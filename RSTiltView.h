#import "CommonHeaders.h"

@interface RSTiltView : UIView <UILongPressGestureRecognizerDelegate> {
	CATransform3D _layerTransform;
	float _transformAngle;
	float _transformMultiplierX;
	float _transformMultiplierY;
	BOOL _hasHighlight;
	BOOL hasTransformed;

	SEL actionForTapped;
	id targetForTapped;
	SEL actionForPressed;
	id targetForPressed;
}

@property (assign) float transformAngle;
@property (assign) BOOL hasHighlight;

-(void)setTransformOptions:(NSDictionary*)options;

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;
-(void)tapped:(UITapGestureRecognizer*)sender;
-(void)pressed:(UILongPressGestureRecognizer*)sender;

-(void)setHighlighted:(BOOL)highlighted;

-(void)untilt:(BOOL)animated overridesHighlight:(BOOL)highlightOverride;

-(void)setActionForTapped:(SEL)newActionForTapped forTarget:(id)target;
-(void)setActionForPressed:(SEL)newActionForPressed forTarget:(id)target;
@end