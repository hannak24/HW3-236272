# hello_me

## Answers of dry part:

1. The controller pattern is implemented using the SnappingSheetController class. It
   allows the user to controll the position of the snapping sheet (with or without animation, and stop snapping if it happens).
   
2. In the SnappingSheet class there is a parameter called snappingPositions which controlls the position of the snaped sheet. 
   Its children can be defined with custom duration and curve parameters, which create the snapping animation.
   
3. InkWell has a limited number of gestures to detect but it gives the user more ways to decorate the widget (for example ripple effect tap, which makes the app more      user-friendly, exists only in InkWell).
   gestureDetector can detect more forms of user interactions with the widget (for example pinch, swipe, touch, custom gestures...), but isn't a visual widget.
   

Comments for the HW:

1. After the remark of Ofek that user's suggestions should be saved when he signs out, I implemented it in HW3.

2. The joker picture is the default picture of users that have no profile picture. I found its sudden pop up when the snapping
   sheet is tapped amusing :) .
