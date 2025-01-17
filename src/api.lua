-- social_profile/src/api.lua
-- Basic APIs
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-3.0-or-later

local social_profile = social_profile
local S = core.get_translator("social_profile")
local storage = core.get_mod_storage()

function social_profile.get_social_profile(name)
    if not core.player_exists(name) then
        storage:set_string("social_profile:" .. name, "")
        return
    elseif not storage:contains("social_profile:" .. name) then
        return {}
    end

    local raw_data = storage:get_string("social_profile:" .. name)
    local data = core.deserialize(raw_data)

    if not data then
        core.log("[social_profile] Error deserializing data of " .. name .. ": " .. raw_data)
        return {}
    end
    return data
end

function social_profile.set_social_profile(name, data)
    if not core.player_exists(name) then
        storage:set_string("social_profile:" .. name, "")
        return false
    elseif not next(data) then
        storage:set_string("social_profile:" .. name, "")
        return true
    end

    local serialized_data = core.serialize(data)
    storage:set_string("social_profile:" .. name, serialized_data)
    return true
end

function social_profile.can_modify_profile(actor, target)
    if not core.player_exists(target) then
        return false
    elseif actor == target then
        return true
    elseif not core.check_player_privs(actor, { ban = true, }) then
        return false
    else
        return true
    end
end

social_profile.normalized_pronouns = {
    ["he"] = "he/him",
    ["him"] = "he/him",

    ["she"] = "she/her",
    ["her"] = "she/her",

    ["they"] = "they/them",
    ["them"] = "they/them",
}
social_profile.recognized_pronouns = {
    ["he/him"] = S("he/him"),

    ["she/her"] = S("she/her"),

    ["they/them"] = S("they/them"),

    ["he/they"] = S("he/they"),
    ["she/they"] = S("she/they"),
    ["he/she"] = S("he/she"),
    ["he/they/she"] = S("he/they/she"),
}
social_profile.listed_pronoun_presets = {
    "he/him", "she/her", "they/them",
    "he/they", "she/they", "he/she", "he/they/she"
}

function social_profile.render_pronoun(pronoun)
    pronoun = string.trim(pronoun)
    return social_profile.recognized_pronouns[pronoun] or pronoun
end

social_profile.LAST_FIELD_PRIORITY = 0
social_profile.registered_fields = {}
social_profile.registered_fields_order = {}

function social_profile.register_field(field_name, def)
    social_profile.registered_fields[field_name] = def

    def.priority = def.priority or social_profile.LAST_FIELD_PRIORITY - 10
    if def.priority < social_profile.LAST_FIELD_PRIORITY then
        social_profile.LAST_FIELD_PRIORITY = math.floor(def.priority)
    end
    social_profile.registered_fields_order[#social_profile.registered_fields_order + 1] = field_name
    table.sort(social_profile.registered_fields_order, function(a, b)
        local priority_a = social_profile.registered_fields[a].priority
        local priority_b = social_profile.registered_fields[b].priority

        if priority_a == priority_b then
            return a > b
        end

        return priority_a > priority_b
    end)
end

social_profile.registered_buttons = {}

function social_profile.register_button(def)
    social_profile.registered_buttons[#social_profile.registered_buttons+1] = def
end
