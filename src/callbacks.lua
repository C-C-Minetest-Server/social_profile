-- social_profile/src/callbacks.lua
-- callbacks
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-3.0-or-later

local social_profile = social_profile

local S = core.get_translator("social_profile")

core.register_on_joinplayer(function(player)
    if core.settings:get_bool("social_profile.announce.pronouns", true) then
        local name = player:get_player_name()
        local profile = social_profile.get_social_profile(name)
        if not profile then return end

        if profile.pronouns then
            local pronouns = social_profile.render_pronoun(profile.pronouns)
            core.chat_send_all("*** " .. S("The pronouns of @1 is @2.", name, pronouns))
        end
    end
end)
