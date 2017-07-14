@interface WeatherWindSpeedFormatter : NSFormatter {
	
	NSLocale* _locale;
	NSDictionary* _directionSubstringAttributes;
	
}

@property (retain) NSLocale * locale;                                        //@synthesize locale=_locale - In the implementation block
@property (retain) NSDictionary * directionSubstringAttributes;              //@synthesize directionSubstringAttributes=_directionSubstringAttributes - In the implementation block
+(id)convenienceFormatter;
-(id)init;
-(void)setLocale:(NSLocale *)arg1 ;
-(NSLocale *)locale;
-(id)stringForObjectValue:(id)arg1 ;
-(id)formattedStringForSpeed:(float)arg1 direction:(float)arg2 ;
-(double)speedByConvertingToUserUnit:(double)arg1 ;
-(id)templateStringForSpeed:(float)arg1 direction:(float)arg2 ;
-(id)stringForWindDirection:(float)arg1 ;
-(NSDictionary *)directionSubstringAttributes;
-(id)stringForWindSpeed:(float)arg1 ;
-(id)fallbackStringForWindSpeed:(float)arg1 ;
-(int)windSpeedUnit;
-(id)fallbackUnitString;
-(id)attributedFormattedStringForSpeed:(float)arg1 direction:(float)arg2 ;
-(id)speedStringByConvertingToUserUnits:(float)arg1 ;
-(void)setDirectionSubstringAttributes:(NSDictionary *)arg1 ;
-(BOOL)getObjectValue:(out id*)arg1 forString:(id)arg2 errorDescription:(out id*)arg3 ;
@end
