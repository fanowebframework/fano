{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FcgiProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    EnvironmentIntf,
    StreamAdapterIntf,
    FcgiProcessorIntf,
    FcgiRequestManagerIntf,
    FcgiRequestIdAwareIntf,
    FcgiRequestReadyListenerIntf,
    FcgiStdInStreamAwareIntf,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * FastCGI frame processor that parse FastCGI frame
     * and build CGI environment
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiProcessor = class(TInterfacedObject, IFcgiProcessor, IFcgiRequestIdAware, IFcgiStdInStreamAware)
    private
        fcgiParser : IFcgiFrameParser;
        fcgiRequestMgr : IFcgiRequestManager;
        fcgiRequestReadyListener : IFcgiRequestReadyListener;

        //store request id that is ready to be served
        fCompleteRequestId : word;

        procedure processBuffer(const stream : IStreamAdapter; const buffer : pointer; const bufferSize : ptrUint);
    public
        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param parser FastCGI frame parser
         * @param requestMgr, instance of request manager
         *-----------------------------------------------*)
        constructor create(
            const parser : IFcgiFrameParser;
            const requestMgr : IFcgiRequestManager
        );

        destructor destroy(); override;

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------
         * @return true if all data from web server is ready to
         * be handle by application (i.e, environment, STDIN already parsed)
         *-----------------------------------------------*)
        procedure process(const stream : IStreamAdapter);

        (*!------------------------------------------------
         * set listener to be notified weh request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IFcgiRequestReadyListener) : IFcgiProcessor;

        (*!------------------------------------------------
         * get request id
         *-----------------------------------------------
         * @return request id
         *-----------------------------------------------*)
        function getRequestId() : word;

        (*!------------------------------------------------
        * get FastCGI StdIn stream for complete request
        *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;
    end;

implementation

uses

    FcgiEnvironmentImpl,
    FcgiRecordIntf,
    KeyValuePairIntf,
    EnvironmentFactoryIntf,
    EInvalidFcgiRequestIdImpl,
    EInvalidFcgiHeaderLenImpl;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param parser FastCGI frame parser
     * @param requestMgr, instance of request manager
     *-----------------------------------------------*)
    constructor TFcgiProcessor.create(
        const parser : IFcgiFrameParser;
        const requestMgr : IFcgiRequestManager
    );
    begin
        inherited create();
        fcgiParser := parser;
        fcgiRequestMgr := requestMgr;
        fcgiRequestReadyListener := nil;
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFcgiProcessor.destroy();
    begin
        inherited destroy();
        fcgiParser := nil;
        fcgiRequestMgr := nil;
        fcgiRequestReadyListener := nil;
    end;

    (*!-----------------------------------------------
     * parse stream for FCGI records
     *------------------------------------------------
     * @param buffer, buffer where data from socket is stored
     * @param bufferSize, size of buffer where data from socket is stored
     * @return boolean true when FCGI_PARAMS and FCGI_STDIN
     *         stream is complete otherwise false
     *-----------------------------------------------*)
    procedure TFcgiProcessor.processBuffer(const stream : IStreamAdapter; const buffer : pointer; const bufferSize : ptrUint);
    var afcgiRec : IFcgiRecord;
        requestId : word;
        handled : boolean;
    begin
        if (fcgiParser.hasFrame(buffer, bufferSize)) then
        begin
            afcgiRec := fcgiParser.parseFrame(buffer, bufferSize);
            fcgiRequestMgr.add(afcgiRec);
            requestId := afcgiRec.getRequestId();
            if fcgiRequestMgr.complete(requestId) then
            begin
                fCompleteRequestId := requestId;

                if assigned(fcgiRequestReadyListener) then
                begin
                    handled := fcgiRequestReadyListener.ready(
                        stream,
                        fcgiRequestMgr.getEnvironment(requestId),
                        fcgiRequestMgr.getStdInStream(requestId)
                    );
                    if handled then
                    begin
                        fcgiRequestMgr.remove(requestId);
                    end;
                end;
            end;
        end;
    end;

    (*!-----------------------------------------------
     * process stream and parse for FCGI records until stream
     * is exhausted
     *------------------------------------------------
     * @param stream socket stream
     *-----------------------------------------------*)
    procedure TFcgiProcessor.process(const stream : IStreamAdapter);
    var bufPtr : pointer;
        bufSize  : ptrUint;
        streamEmpty : boolean;
    begin
        repeat
            streamEmpty := fcgiParser.readRecord(stream, bufPtr, bufSize);
            if (bufPtr <> nil) and (bufSize > 0) then
            begin
                processBuffer(stream, bufPtr, bufSize);
            end;
        until streamEmpty;
    end;

    (*!------------------------------------------------
     * set listener to be notified weh request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TFcgiProcessor.setReadyListener(const listener : IFcgiRequestReadyListener) : IFcgiProcessor;
    begin
        fcgiRequestReadyListener := listener;
        result := self;
    end;

    (*!------------------------------------------------
     * get request id
     *-----------------------------------------------
     * @return request id
     *-----------------------------------------------*)
    function TFcgiProcessor.getRequestId() : word;
    begin
        result := fCompleteRequestId;
    end;

    (*!------------------------------------------------
     * get FastCGI StdIn stream for complete request
     *-----------------------------------------------*)
    function TFcgiProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fcgiRequestMgr.getStdInStream(fCompleteRequestId);
    end;
end.
