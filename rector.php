<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\Set\ValueObject\LevelSetList;
use Rector\ValueObject\PhpVersion;

return static function (RectorConfig $config): void {
    $config->phpVersion(PhpVersion::PHP_84);

    $config->sets([
        LevelSetList::UP_TO_PHP_84,
    ]);
};
