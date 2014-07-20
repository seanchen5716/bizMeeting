

#import <UIKit/UIKit.h>

typedef void (^FPTouchedOutsideBlock)();
typedef void (^FPTouchedInsideBlock)();

@interface FPTouchView : UIView
{
    __strong FPTouchedOutsideBlock _outsideBlock;
    __strong FPTouchedInsideBlock  _insideBlock;
}

-(void)setTouchedOutsideBlock:(FPTouchedOutsideBlock)outsideBlock;

-(void)setTouchedInsideBlock:(FPTouchedInsideBlock)insideBlock;

@end
