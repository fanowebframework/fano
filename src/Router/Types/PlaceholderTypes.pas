{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit PlaceholderTypes;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * Data structure for storing route variable placeholder
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TPlaceholder = record
        phName : string;
        phValue : string;
        phFormatRegex : string;
    end;
    TArrayOfPlaceholders = array of TPlaceholder;


implementation

end.