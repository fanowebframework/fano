{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

(*! ---------------------------------------------
 * redeclare all class types in unit inside Libs/FileStorage
 * directory
 *
 * @author Zamrony P. Juhara <zamronypj@yahoo.com>
 *-----------------------------------------------*)
TLocalDiskFile = LocalDiskFileImpl.TLocalDiskFile;
TLocalDiskDirectory = LocalDiskDirectoryImpl.TLocalDiskDirectory;
TLocalDiskStorage = LocalDiskStorageImpl.TLocalDiskStorage;

TCompositeFile = CompositeFileImpl.TCompositeFile;
TCompositeDirectory = CompositeDirectoryImpl.TCompositeDirectory;
TCompositeStorage = CompositeStorageImpl.TCompositeStorage;