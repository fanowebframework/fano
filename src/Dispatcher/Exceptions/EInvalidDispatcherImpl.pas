{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EInvalidDispatcherImpl;

interface

{$MODE OBJFPC}

uses

    sysutils;

type

    (*!------------------------------------------------
     * Exception that is raised when application is
     * given an invalid dispatcher instance.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    EInvalidDispatcher = class(Exception)
    end;

implementation

end.
