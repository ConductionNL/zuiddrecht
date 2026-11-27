<?php
// SPDX-FileCopyrightText: 2026 Conduction B.V.
// SPDX-License-Identifier: EUPL-1.2
//
// The installation is baked into the image, so the trusted domains come from
// the environment instead of from the install.
$CONFIG = [
	'trusted_domains' => array_values(array_filter(explode(' ', getenv('NEXTCLOUD_TRUSTED_DOMAINS') ?: 'localhost 127.0.0.1'))),
];
