-- social_profile/src/defaults.lua
-- default fields
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-3.0-or-later


local S = core.get_translator("social_profile")
local social_profile = social_profile
local gui = flow.widgets

social_profile.register_field("bio", {
    title = S("Bio"),
    get_display_value = function(value)
        if value == "" then
            value = S("Nothing here yet~")
        end
        return value
    end,
    get_display_row = function(_, _, value)
        return gui.Textarea {
            h = 1.5,
            default = value,
        }
    end,
    get_edit_row = function(_, _, value)
        return gui.Textarea {
            h = 1.5,
            name = "bio",
            label = S("Bio"),
            default = value
        }
    end,
    show_on_no_value = true,
    priority = -10,
})

social_profile.register_field("real_name", {
    title = S("Real name"),
    priority = -20,
})

social_profile.register_field("pronouns", {
    title = S("Pronouns"),
    get_display_value = function(value)
        return social_profile.render_pronoun(value)
    end,
    get_edit_row = function(_, _, value)
        local pronoun_items = { S("Presets...") }
        for _, k in ipairs(social_profile.listed_pronoun_presets) do
            pronoun_items[#pronoun_items + 1] = social_profile.recognized_pronouns[k]
        end

        return gui.HBox {
            gui.Field {
                w = 6,
                name = "pronouns",
                label = S("Pronouns"),
                default = value,
            },
            gui.Dropdown {
                w = 3,
                name = "pronouns_dropdown",
                items = pronoun_items,
                selected_idx = 1,
                index_event = true,
                on_event = function(_, e_ctx)
                    if e_ctx.form.pronouns_dropdown == 1 then return end
                    e_ctx.form.pronouns =
                        social_profile.listed_pronoun_presets[e_ctx.form.pronouns_dropdown - 1]
                    e_ctx.form.pronouns_dropdown = 1
                    return true
                end,
            },
        }
    end,
    priority = -30,
})

social_profile.register_field("company", {
    title = S("Company"),
    priority = -40,
})

social_profile.register_field("location", {
    title = S("Location"),
    priority = -50,
})

if core.get_modpath("mail") then
    social_profile.register_button(function()
        return gui.Button {
            w = 1,
            label = S("Mail"),
            on_event = function(player, ctx)
                return mail.show_compose(player:get_player_name(), ctx.curr_name)
            end,
        }
    end)
end
