{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JwtTokenVerifierImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    TokenVerifierIntf,
    JwtAlgVerifierIntf,
    InjectableObjectImpl;

type

    //supported JWT algorithm
    TAlgArray = array of IJwtAlgVerifier;

    (*!------------------------------------------------
     * class having capability to verify JWT token validity
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TJwtTokenVerifier = class (TInjectableObject, ITokenVerifier)
    private
        fMetadata : IList;
        fAlgorithms : TAlgArray;
        fSecretKey : string;
        function findAlgoByName(const alg : shortstring) : IJwtAlgVerifier;
        procedure cleanUpAlgorithms();
        procedure cleanUpMetadata();
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param metadata lits of additional data for verification
         * @param issuer JWT issuer string
         * @param secretKey secret key used to verify signature
         * @param algos array of supported algorithms
         *-------------------------------------------------*)
        constructor create(
            const metadata : IList;
            const issuer : string;
            const secretKey : string;
            const algos: array of IJwtAlgVerifier
        );

        (*!------------------------------------------------
         * destructor
         *-------------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * verify token
         *-------------------------------------------------
         * @param token token to verify
         * @return boolean true if token is verified and
         *        not expired and issuer match
         *-------------------------------------------------*)
        function verify(const token : string) : boolean;

        (*!------------------------------------------------
         * set additional data for token verification
         *-------------------------------------------------*)
        procedure setData(const key : shortstring; const metaData : string);
        function getData(const key : shortstring) : string;
        property data[const key : shortstring] : string read getData write setData; default;

    end;

implementation

uses

    sysutils,
    dateutils,
    fpjson,
    fpjwt,
    JwtConsts;

type

    TMetadata = record
        strValue : string;
    end;
    PMetadata = ^TMetadata;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param issuer JWT issuer string
     * @param secretKey secret key used to verify signature
     * @param algos array of supported algorithms
     *-------------------------------------------------*)
    constructor TJwtTokenVerifier.create(
        const metadata : IList;
        const issuer : string;
        const secretKey : string;
        const algos: array of IJwtAlgVerifier
    );
    begin
        fMetadata := metadata;
        fSecretKey := secretKey;
        fAlgorithms := algos;
        setData(JWT_ISSUER, issuer);
    end;

    (*!------------------------------------------------
     * destructor
     *-------------------------------------------------*)
    destructor TJwtTokenVerifier.destroy();
    begin
        cleanUpMetadata();
        cleanUpAlgorithms();
        fAlgorithms := nil;
        inherited destroy();
    end;

    procedure TJwtTokenVerifier.cleanUpMetadata();
    var i : integer;
        meta : PMetadata;
    begin
        for i := fMetadata.count-1 downto 0 do
        begin
            meta := fMetadata.get(i);
            meta^.strValue := nil;
            dispose(meta);
            fMetadata.delete(i);
        end;
    end;

    procedure TJwtTokenVerifier.cleanUpAlgorithms();
    var i : integer;
    begin
        for i := length(fAlgorithms)-1 downto 0 do
        begin
            fAlgorithms[i] := nil;
        end;
    end;

    function TJwtTokenVerifier.findAlgoByName(const alg : shortstring) : IJwtAlgVerifier;
    var i, len : integer;
    begin
        //number of algorithms is very small, sequential search is good enough
        result := nil;
        len := length(fAlgorithms);
        for i := 0 to len-1 do
        begin
            if (alg = fAlgorithms[i].name()) then
            begin
                //algorithm found
                result := fAlgorithms[i];
                break;
            end;
        end;
    end;

    (*!------------------------------------------------
     * verify token
     *-------------------------------------------------
     * @param token token to verify
     * @return boolean true if token is verified and
     *         not expired and issuer match
     *-------------------------------------------------*)
    function TJwtTokenVerifier.verify(const token : string) : boolean;
    var jwt : TJwt;
        alg : IJwtAlgVerify;
        aAudience : string;
        aIssuer : string;
    begin
        jwt := TJwt.create();
        try
            try
                //this may raise EJSON when token is not well-formed JWT
                jwt.asEncodedString := token;

                //if we get here, token is well-formed JWT
                alg := findAlgoByName(jwt.JOSE.alg);

                aAudience := fMetadata.find(JWT_AUDIENCE);
                aIssuer := fMetadata.find(JWT_ISSUER);

                //test if signing algorithm is known, if not, then token is
                //definitely not generated by us or token has been tampered.
                result := (alg <> nil) and

                    //if algorithm is known, check signature
                    alg.verify(
                        jwt.JOSE.AsEncodedString + '.' + jwt.Claims.AsEncodedString,
                        jwt.Signature,
                        fSecretKey
                    ) and

                    //if signature valid, check if expired
                    (jwt.Claims.exp > DateTimeToUnix(Now)) and

                    //if not expired, check if audience and issuer match
                    (jwt.Claims.aud = aAudience) and
                    (jwt.Claims.iss = aIssuer);
            except
                on e : EJSON do
                begin
                    //if we get here, token is not valid JWT
                    result := false;
                end;
            end;
        finally
            jwt.free();
        end;
    end;

    procedure TJwtTokenVerifier.setData(const key : shortstring; const metaData : string);
    var meta : PMetadata;
    begin
        meta := fMetadata.find(key);
        if (meta = nil) then
        begin
            new(meta);
            fMetadata.add(key, meta);
        end;
        meta^.strValue := issuer;
    end;

    procedure raiseMetadataNotFound(const key : shortstring);
    begin
        raise EJwt.createFmt('Jwt token meta data %s not found.', [key]);
    end;

    function TJwtTokenVerifier.getData(const key : shortstring) : string;
    var meta : PMetadata;
    begin
        meta := fMetadata.find(key);
        if meta <> nil then
        begin
            result := meta^.strValue;
        end else
        begin
            raiseMetadataNotFound(key);
            result := '';
        end;
    end;
end.