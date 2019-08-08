{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CombineRouterFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TCombineRegexRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCombineRouterFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    RouterImpl,
    CombineRegexRouteListImpl,
    RegexImpl,
    HashListImpl;

    function TCombineRouterFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TRouter.create(
            TCombineRegexRouteList.create(
                TRegex.create(),
                THashList.create()
            )
        );
    end;

end.