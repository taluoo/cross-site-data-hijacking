package {
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;
import flash.text.TextField;

public class swfloader extends Sprite {
    public function swfloader() {
        Security.allowDomain('*');
        Security.allowInsecureDomain('*');
        ExternalInterface.call('console.log', 'swfloader preparing');
        var textField:TextField = new TextField();
        textField.text = "the quieter you become, the more you are able to hear";
        textField.width = 500;
        addChild(textField);
        var url:String = LoaderInfo(this.root.loaderInfo).parameters.swfURL;
        if (url) {
            loadSWF(url);
        } else {
            ExternalInterface.call('console.log', '请指定 FlashVars swfURL')
        }
    }

    public function loadSWF(url:String):void {
        var loader:Loader = new Loader();
        configureListeners(loader.contentLoaderInfo);
        var req:URLRequest = new URLRequest(url);
        var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
        loader.load(req, loaderContext);
    }

    private function configureListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        dispatcher.addEventListener(Event.INIT, initHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        dispatcher.addEventListener(Event.OPEN, openHandler);
        dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
    }

    private function completeHandler(event:Event):void {
        trace("completeHandler: " + event);
    }

    private function httpStatusHandler(event:HTTPStatusEvent):void {
        trace("httpStatusHandler: " + event);
    }

    private function initHandler(event:Event):void {
        trace("initHandler: " + event);
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        trace("ioErrorHandler: " + event);
    }

    private function openHandler(event:Event):void {
        trace("openHandler: " + event);
    }

    private function progressHandler(event:ProgressEvent):void {
        trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
    }

}
}
