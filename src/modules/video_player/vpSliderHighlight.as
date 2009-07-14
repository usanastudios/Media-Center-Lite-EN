package modules.video_player{
    import mx.core.UIComponent;
    import flash.display.Graphics;
    import flash.display.Shape;
import flash.display.GradientType;
import flash.geom.Matrix;

    
    public class vpSliderHighlight extends UIComponent{
        
        /**
         * Line 1926 on Slider puts the highlight 
         * 1 px below the Slider's track
         * */
        override public function get height():Number{
            return 20;
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            this.graphics.clear();
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            var gradientBoxMatrix:Matrix = new Matrix();
            gradientBoxMatrix.createGradientBox(unscaledWidth, 9, Math.PI/2, 0);
            
            //create 2 circle that will act like round corners
            this.graphics.beginGradientFill(GradientType.LINEAR, [0x9dc5e4,0x3879ad,0x1e6aac,0x082947], [1, 1, 1, 1], [0, 28, 50, 255], gradientBoxMatrix, "SpreadMethod.PAD");
            this.graphics.drawCircle(0,0,9);
            this.graphics.drawCircle(unscaledWidth,0,9);
            this.graphics.endFill();
            
            
            
            var gr:Graphics = this.graphics;
            
            gr.beginGradientFill(GradientType.LINEAR, [0x9dc5e4,0x3879ad,0x1e6aac,0x082947], [1, 1, 1, 1], [0, 28, 50, 255], gradientBoxMatrix, "SpreadMethod.PAD");
            gr.drawRect(0,-9, unscaledWidth, 18);
            gr.endFill();
        }
    }
}
