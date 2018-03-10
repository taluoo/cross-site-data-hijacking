package {

import flash.utils.*;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.ErrorEvent;
import flash.events.UncaughtErrorEvent;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;
import flash.text.TextField;

public class xsftest extends Sprite {

    public var loader: Loader;

    public function xsftest() {
        Security.allowDomain('*');
        Security.allowInsecureDomain('*');
        if (stage) {
            init();
        }
        else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
    }

    private function init(param1: Event = null): void {
        log('swf init');
        removeEventListener(Event.ADDED_TO_STAGE, this.init);

        var textField: TextField = new TextField();
        textField.text = "the quieter you become, the more you are able to hear";
        textField.width = 500;
        addChild(textField);

        loader = new Loader();
        addChild(loader);
        configureListeners(loader.contentLoaderInfo);

        // 可以捕获到 target swf 的报错
        loader.contentLoaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);

        // loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);

        var url: String = LoaderInfo(this.root.loaderInfo).parameters.swfURL;
        if (url) {
            loadSWF(url);
        } else {
            log('请指定 FlashVars swfURL');
        }
    }


    public function loadSWF(url: String): void {
        log('start load target: ' + url);
        var req: URLRequest = new URLRequest(url);
        try {
            log('before load');
            loader.load(req);
            log('after load');

        } catch (e: Error) {
            log('catch a error')
        }

    }

    private function configureListeners(dispatcher: IEventDispatcher): void {
        dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        dispatcher.addEventListener(Event.INIT, initHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        dispatcher.addEventListener(Event.OPEN, openHandler);
        dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
    }

    private function uncaughtErrorHandler(event: UncaughtErrorEvent): void {
        log('uncaughtErrorHandler: ' + event);
        if (event.error is Error) {
            var error: Error = event.error as Error;
            // do something with the error
        }
        else if (event.error is ErrorEvent) {
            var errorEvent: ErrorEvent = event.error as ErrorEvent;
            // do something with the error
        }
        else {
            // a non-Error, non-ErrorEvent type was thrown and uncaught
        }
    }

    private function completeHandler(event: Event): void {
        log("completeHandler: " + event);
        log("setTimeout: 2s");
        setTimeout(function (): void { // 延迟判断，因为有的 SWF allowdomain 授权有延迟，例如：https://qzs.qq.com/music/musicbox_v2_1/img/MusicFlash.swf
            var loader: Loader = event.currentTarget.loader as Loader;
            var canAccessChild: Boolean = loader.contentLoaderInfo.childAllowsParent;
            log('can XSF? ' + canAccessChild);
            log('actionScriptVersion:' + loader.contentLoaderInfo.actionScriptVersion);
            log('swfVersion:' + loader.contentLoaderInfo.swfVersion);
        }, 2000);
    }

    private function httpStatusHandler(event: HTTPStatusEvent): void {
        log("httpStatusHandler: " + event);
    }

    private function initHandler(event: Event): void {
        log("initHandler: " + event);
    }

    private function ioErrorHandler(event: IOErrorEvent): void {
        log("ioErrorHandler: " + event);
    }

    private function openHandler(event: Event): void {
        log("openHandler: " + event);
    }

    private function progressHandler(event: ProgressEvent): void {
        log("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
    }

    private function log(msg: String): void {
        trace(msg);
        ExternalInterface.call('console.log', 'flash log: ' + msg)
    }

}
}
