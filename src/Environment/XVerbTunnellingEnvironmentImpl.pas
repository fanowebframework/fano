{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit XVerbTunnellingEnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    EnvironmentIntf,
    EnvironmentEnumeratorIntf,
    RequestIntf,
    VerbTunnellingEnvironmentImpl;


type

    (*!------------------------------------------------
     * class having capability to retrieve
     * CGI environment variable and override HTTP method
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TXVerbTunnellingEnvironment = class(TVerbTunnellingEnvironment)
    private
        fRequest : IRequest;
        fVerbOverrideParam : shortstring;
        function overrideMethod() : string;
    public
        constructor create(
            const aEnv : ICGIEnvironment;
            const request : IRequest;
            const verbOverrideParam : shortstring
        );
        destructor destroy(); override;

        (*!-----------------------------------------
         * Retrieve an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return variable value
         *------------------------------------------*)
        function env(const keyName : string) : string; override;
    end;

implementation

uses

    sysutils,
    EInvalidMethodImpl;

    constructor TXVerbTunnellingEnvironment.create(
        const aEnv : ICGIEnvironment;
        const request : IRequest;
        const verbOverrideParam : shortstring
    );
    begin
        inherited create(aEnv);
        fRequest := request;
        fVerbOverrideParam := verbOverrideParam;
    end;

    destructor TXVerbTunnellingEnvironment.destroy();
    begin
        fRequest := nil;
        inherited destroy();
    end;

    function TXVerbTunnellingEnvironment.overrideMethod() : string;
    var allowed : boolean;
    begin
        result := fRequest.getParsedBodyParam(fVerbOverrideParam);
        if result <> '' then
        begin
            allowed := (result = 'GET') or
                (result = 'POST') or
                (result = 'PUT') or
                (result = 'DELETE') or
                (result = 'OPTIONS') or
                (result = 'PATCH') or
                (result = 'HEAD');

            if not allowed then
            begin
                //important! release reference to avoid memory leak
                //before we raise exception
                fDecoratedEnv := nil;
                fRequest := nil;
                raise EInvalidMethod.createFmt(
                    sErrInvalidMethod,
                    [ result ]
                );
            end;
        end else
        begin
            result := inherited env(keyName);
        end;
    end;

    (*!-----------------------------------------
     * Retrieve an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return variable value
     *------------------------------------------*)
    function TXVerbTunnellingEnvironment.env(const keyName : string) : string;
    begin
        if keyName = 'REQUEST_METHOD' then
        begin
            result := overrideMethod();
        end else
        begin
            result := inherited env(keyName);
        end;
    end;


end.
