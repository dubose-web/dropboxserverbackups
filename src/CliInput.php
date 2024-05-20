<?php


declare(strict_types=1);

namespace App;

use Exception;

readonly class CliInput
{
    private array $args;

    public function __construct(array $argsFromArgV)
    {
        $args = [];

        foreach ($argsFromArgV as $arg) {
            $hasDashes = mb_strpos($arg, '--') === 0;

            if (!$hasDashes) {
                continue;
            }

            $argParts = explode('=', $arg);

            $key = explode('-', $argParts[0])[2] ?? null;
            $val = $argParts[1] ?? null;

            if ($key === null || $val === null || $key === '' || $val === '') {
                continue;
            }

            $args[$key] = $val;
        }

        $this->args = $args;
    }

    public function getArg(string $arg, $required = true): string
    {
        $val = $this->args[$arg] ?? null;

        if ($required && $val === null) {
            throw new Exception('--' . $arg .' is required');
        }

        return $val;
    }
}
