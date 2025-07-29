<?php

return new PhpCsFixer\Config()
    ->setRules([
        '@PSR12' => true,
        'phpdoc_separation' => true,
        'phpdoc_order' => true,
        'strict_param' => true,
        'phpdoc_align' => true,
        'phpdoc_trim' => true,
        'declare_strict_types' => true,
        'array_syntax' => ['syntax' => 'short'],
        'yoda_style' => [
            'equal' => true,
            'identical' => true,
            'less_and_greater' => true,
        ],
        'ordered_imports' => [
            'sort_algorithm' => 'alpha',
            'imports_order' => ['class', 'function', 'const'],
        ],
        'ordered_class_elements' => [
            'order' => [
                'use_trait',
                'constant_public',
                'constant_protected',
                'constant_private',
                'property_public',
                'property_protected',
                'property_private',
                'construct',
                'destruct',
                'magic',
                'method_public_static',
                'method_public',
                'method_protected',
                'method_private',
                'method_protected_static',
                'method_private_static',
            ],
        ],
        'no_unused_imports' => true,
        'blank_line_before_statement' => [
            'statements' => ['return'],
        ],
        'blank_line_after_namespace' => true,
        'blank_line_between_import_groups' => false,
        'no_extra_blank_lines' => [
            'tokens' => [
                'extra',
                'use',
                'return',
                'continue',
                'break',
                'throw',
            ],
        ],
        'native_function_invocation' => [
            'include' => ['@compiler_optimized'],
            'scope' => 'namespaced',
            'strict' => true,
        ],
        'global_namespace_import' => [
            'import_classes' => true,
            'import_constants' => true,
            'import_functions' => true,
        ],
        'class_attributes_separation' => [
            'elements' => [
                'method' => 'one',
                'property' => 'one',
                'const' => 'one',
            ],
        ],
    ]);
