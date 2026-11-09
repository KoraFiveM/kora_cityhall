fx_version 'cerulean'
game 'gta5'
lua54 'yes'
-- Keep the legacy resource name resolvable for exports['qbcityhall'] callers.
provide 'qbcityhall'
provide 'qb-cityhall'
use_fxv2_oal 'yes'
author 'Kakarot'
description 'Allows players to purchase id cards and licenses or change their job'
version '2.2.0'

dependency 'kora_lib'
dependency 'kora_core'

shared_scripts {
    '@kora_lib/init.lua',
    'shared/**.lua'
}

server_script 'server/**.lua'

client_scripts {
    'client/**.lua'
}
files {
    'locales/*.lua'
}

-- kora_qa: Gherkin test scenarios (converted legacy tests), see [kora]/kora_qa/README.md
qa_feature 'tests/*.feature'
