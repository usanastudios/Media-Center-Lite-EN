package modules.video_player
{
    import flash.display.Graphics;

    import mx.core.IFlexDisplayObject;
    import mx.skins.halo.SliderTrackSkin;

    public class vpSliderTrack extends SliderTrackSkin implements IFlexDisplayObject
    {

        public function vpSliderTrack()
        {
            super();
        }    

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            this.graphics.clear();
            var gr:Graphics = this.graphics;
            gr.beginFill(0x00FF00, 0);
            gr.drawRect(0,0, unscaledWidth, height);
            gr.endFill();
        }
    }
}
