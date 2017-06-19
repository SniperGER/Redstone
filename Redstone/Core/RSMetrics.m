#import "../Redstone.h"

@implementation RSMetrics

int columns;

+ (void)initialize {
	columns = [[[RSPreferences preferences] objectForKey:@"showMoreTiles"] boolValue] ? 3 : 2;
}

+ (CGSize)tileDimensionsForSize:(int)size {
	/*switch ((int)screenWidth) {
		case 414:
			if (size == 1) {
				return CGSizeMake(63.5, 63.5);
			} else if (size == 2) {
				return CGSizeMake(132, 132);
			} else if (size == 3) {
				return CGSizeMake(269, 132);
			} else if (size == 4) {
				return CGSizeMake(269, 269);
			}
			break;
		case 375:
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(57, 57);
				} else if (size == 2) {
					return CGSizeMake(119, 119);
				} else if (size == 3) {
					return CGSizeMake(243, 119);
				} else if (size == 4) {
					return CGSizeMake(243, 243);
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(88, 88);
				} else if (size == 2) {
					return CGSizeMake(181, 181);
				} else if (size == 3) {
					return CGSizeMake(367, 181);
				} else if (size == 4) {
					return CGSizeMake(367, 367);
				}
			}
		case 320:
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(47.83333, 47.83333);
				} else if (size == 2) {
					return CGSizeMake(100.66666, 100.66666);
				} else if (size == 3) {
					return CGSizeMake(206.33333, 100.66666);
				} else if (size == 4) {
					return CGSizeMake(206.33333, 206.33333);
				}
			} else if (columns == 2) {
				if (size == 1) {
					return CGSizeMake(74.25, 74.25);
				} else if (size == 2) {
					return CGSizeMake(153.5, 153.5);
				} else if (size == 3) {
					return CGSizeMake(312, 153.5);
				} else if (size == 4) {
					return CGSizeMake(312, 312);
				}
			}
		default:
			if (columns == 3) {
				CGFloat baseTileWidth = (screenWidth-35)/6;
				if (size == 1) {
					return CGSizeMake(baseTileWidth , baseTileWidth);
				} else if (size == 2) {
					return CGSizeMake(baseTileWidth*2 + 5 , baseTileWidth*2 + 5);
				} else if (size == 3) {
					return CGSizeMake(baseTileWidth*4 + 15 , baseTileWidth*2 + 5);
				} else if (size == 4) {
					return CGSizeMake(baseTileWidth*4 + 15 , baseTileWidth*4 + 15);
				}
			} else if (columns == 2) {
				CGFloat baseTileWidth = (screenWidth-20)/4;
				if (size == 1) {
					return CGSizeMake(baseTileWidth , baseTileWidth);
				} else if (size == 2) {
					return CGSizeMake(baseTileWidth*2 + 5 , baseTileWidth*2 + 5);
				} else if (size == 3) {
					return CGSizeMake(baseTileWidth*4 + 15 , baseTileWidth*4 + 15);
				}
			}
			break;
	}
	
	return CGSizeZero;*/
	
	CGFloat baseTileWidth = 0;
	if (columns == 3) {
		baseTileWidth = (screenWidth - 8 - [self tileBorderSpacing]*5)/6;
	} else if (columns == 2) {
		baseTileWidth = (screenWidth - 8 - ([self tileBorderSpacing]*3))/4;
	}
	
	if (size == 1) {
		return CGSizeMake(baseTileWidth , baseTileWidth);
	} else if (size == 2) {
		return CGSizeMake(baseTileWidth*2 + [self tileBorderSpacing] , baseTileWidth*2 + [self tileBorderSpacing]);
	} else if (size == 3) {
		return CGSizeMake(baseTileWidth*4 + [self tileBorderSpacing]*3 , baseTileWidth*2 + [self tileBorderSpacing]);
	} else if (size == 4) {
		return CGSizeMake(baseTileWidth*4 + [self tileBorderSpacing]*3 , baseTileWidth*4 + [self tileBorderSpacing]*3);
	}
	
	return CGSizeZero;
}

+ (CGSize)tileIconDimensionsForSize:(int)size {
	/*switch ((int)screenWidth) {
		case 414:
			if (size == 1) {
				return CGSizeMake(32, 32);
			} else if (size == 2 || size == 3) {
				return CGSizeMake(44, 44);
			} else if (size == 4) {
				return CGSizeMake(90, 90);
			}
			break;
		case 375:
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(28.5, 28.5);
				} else if (size == 2 || size == 3) {
					return CGSizeMake(40, 40);
				} else if (size == 4) {
					return CGSizeMake(81, 81);
				}
			} else if (columns == 2){
				if (size == 1) {
					return CGSizeMake(44, 44);
				} else if (size == 2 || size == 3) {
					return CGSizeMake(60, 60);
				} else if (size == 4) {
					return CGSizeMake(122, 122);
				}
			}
			break;
		case 320:
			if (columns == 3) {
				if (size == 1) {
					return CGSizeMake(24, 24);
				} else if (size == 2 || size == 3) {
					return CGSizeMake(34, 34);
				} else if (size == 4) {
					return CGSizeMake(70, 70);
				}
			} else if (columns == 2){
				if (size == 1) {
					return CGSizeMake(38, 38);
				} else if (size == 2 || size == 3) {
					return CGSizeMake(50, 50);
				} else if (size == 4) {
					return CGSizeMake(104, 104);
				}
			}
			break;
		default: break;
	}*/
	
	CGSize tileSize = [self tileDimensionsForSize:size];
	
	if (size == 1) {
		return CGSizeMake(tileSize.height * 0.5, tileSize.height * 0.5);
	} else if (size == 2 || size == 3 || size == 4) {
		return CGSizeMake(tileSize.height * 0.33333, tileSize.height * 0.33333);
	}
	
	return CGSizeZero;
}

+ (CGFloat)tileBorderSpacing {
	return 5.0;
}

+ (int)columns {
	return columns;
}

@end
