-- social_profile/src/chatcommand.lua
-- chatcommands
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-3.0-or-later

local S = core.get_translator("social_profile")

core.register_chatcommand("social_profile", {
    description = S("Open social profile of youself or another player"),
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, S("You must be online to run this command.")
        end

        if param == "" then
            param = name
        elseif not core.player_exists(param) then
            return false, S("Player @1 does not exist.", param)
        end

        social_profile.gui:show(player, { curr_name = param })
        return true
    end,
})
