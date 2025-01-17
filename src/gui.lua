-- social_profile/src/gui.lua
-- view and edit gui
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-3.0-or-later

local social_profile = social_profile

local S = core.get_translator("social_profile")
local gui = flow.widgets

local auth

local tab_funcs = {
    nonexist = function(_, ctx)
        return gui.VBox {
            gui.HBox {
                gui.Label {
                    label = S("Internal Error"),
                    expand = true, align_h = "left",
                },
                gui.ButtonExit {
                    w = 0.7, h = 0.7,
                    label = "x",
                },
            },
            gui.Box { w = 0.05, h = 0.05, color = "grey" },
            gui.Label {
                label = S("Invalid tab: @1", ctx.tab),
                expand = true, align_h = "center",
            }
        }
    end,

    view = function(player, ctx)
        ctx.curr_name = ctx.curr_name or player:get_player_name()

        local profile = social_profile.get_social_profile(ctx.curr_name)
        if not profile then
            return gui.VBox {
                gui.HBox {
                    gui.Label {
                        label = S("Player not found: @1", ctx.curr_name),
                        expand = true, align_h = "left",
                    },
                    gui.ButtonExit {
                        w = 0.7, h = 0.7,
                        label = "x",
                    },
                },
                gui.Box { w = 0.05, h = 0.05, color = "grey" },
                gui.Label {
                    label = S("Player not found: @1", ctx.curr_name),
                    expand = true, align_h = "center",
                }
            }
        end

        local skins_display
        if core.global_exists("skins") then
            local skin = skins.get_player_skin({
                get_player_name = function() return ctx.curr_name end,
                get_meta = function() return { get = function() return nil end } end,
            })
            local ver = skin:get_meta("format") or "1.0"
            local v10_texture = "blank.png"
            local v18_texture = "blank.png"

            if ver == "1.8" then
                v18_texture = skin:get_texture()
            else
                v10_texture = skin:get_texture()
            end

            skins_display = gui.Model {
                w = 5, h = 5,
                mesh = "skinsdb_3d_armor_character_5.b3d",
                textures = {
                    v10_texture,
                    v18_texture,
                    "blank.png",
                    "blank.png",
                    "blank.png", -- x_bows
                },
                rotation_x = -30,
                rotation_y = -139,
                mouse_control = true,
            }
        else
            skins_display = gui.Model {
                w = 5, h = 5,
                mesh = "character.b3d",
                textures = {
                    "character.png",
                },
                rotation_x = -30,
                rotation_y = -139,
                mouse_control = true,
            }
        end

        local info_rows = { w = 7 }
        for _, field_name in ipairs(social_profile.registered_fields_order) do
            local def = social_profile.registered_fields[field_name]

            if not def.hide then
                local value
                if def.get_value then
                    value = def.get_value(ctx.curr_name, profile)
                else
                    value = profile[field_name]
                end

                if (value ~= "" and value ~= nil) or def.show_on_value then
                    if value == nil then
                        value = ""
                    end

                    if def.get_display_value then
                        value = def.get_display_value(value)
                        assert(type(value) == "string",
                            "Invalid return type of get_display_value (string expected, got " .. type(value) .. ")")
                    end

                    local row
                    if def.get_display_row then
                        row = def.get_display_row(player, ctx, value)
                    else
                        row = gui.Label {
                            label = S("@1: @2", def.title or field_name, value),
                        }
                    end

                    info_rows[#info_rows + 1] = row
                end
            end
        end

        local button_row = {}
        local button_width = 0
        for _, func in ipairs(social_profile.registered_buttons) do
            local button = func(player, ctx)
            if button then
                if not button.w then
                    button.w = 1
                end
                button_width = button_width + button.w
                button_row[#button_row + 1] = button

                if button_width >= 7 then
                    info_rows[#info_rows + 1] = gui.Hbox(button_row)
                    button_row = {}
                    button_width = 0
                end
            end
        end
        if #button_row > 0 then
            info_rows[#info_rows + 1] = gui.Hbox(button_row)
        end

        local bottom_row = {}
        bottom_row[#bottom_row + 1] = gui.Field {
            w = 5,
            name = "search",
        }
        bottom_row[#bottom_row + 1] = gui.Button {
            w = 2,
            label = S("Search"),
            expand = true, align_h = "left",
            on_event = function(_, e_ctx)
                e_ctx.tab = "search"
                return true
            end,
        }
        if social_profile.can_modify_profile(player:get_player_name(), ctx.curr_name) then
            bottom_row[#bottom_row + 1] = gui.Button {
                label = S("Edit"),
                w = 3, h = 1,
                on_event = function(_, e_ctx)
                    e_ctx.tab = "edit"
                    return true
                end,
            }
        end

        return gui.VBox {
            gui.HBox {
                gui.Label {
                    label = S("Social profile of @1", ctx.curr_name),
                    expand = true, align_h = "left",
                },
                gui.ButtonExit {
                    w = 0.5, h = 0.5,
                    label = "x",
                },
            },
            gui.Box { w = 0.05, h = 0.05, color = "grey" },

            gui.Label {
                label = ctx.curr_name,
                style = {
                    font_size = "*1.5",
                },
            },
            gui.HBox {
                skins_display,
                gui.VBox(info_rows)
            },
            gui.HBox(bottom_row),
        }
    end,
    edit = function(player, ctx, changed)
        ctx.curr_name = ctx.curr_name or player:get_player_name()

        local profile = social_profile.get_social_profile(ctx.curr_name)
        if not profile then
            return gui.VBox {
                gui.HBox {
                    gui.Label {
                        label = S("Player not found: @1", ctx.curr_name),
                        expand = true, align_h = "left",
                    },
                    gui.ButtonExit {
                        w = 0.5, h = 0.5,
                        label = "x",
                    },
                },
                gui.Box { w = 0.05, h = 0.05, color = "grey" },
                gui.Label {
                    label = S("Player not found: @1", ctx.curr_name),
                    expand = true, align_h = "center",
                }
            }
        end

        if not social_profile.can_modify_profile(player:get_player_name(), ctx.curr_name) then
            return gui.VBox {
                gui.HBox {
                    gui.Label {
                        label = S("Insufficant permission to edit profile: @1", ctx.curr_name),
                        expand = true, align_h = "left",
                    },
                    gui.ButtonExit {
                        w = 0.5, h = 0.5,
                        label = "x",
                    },
                },
                gui.Box { w = 0.05, h = 0.05, color = "grey" },
                gui.Label {
                    label = S("Insufficant permission to edit profile: @1", ctx.curr_name),
                    expand = true, align_h = "center",
                }
            }
        end

        local edit_rows = { w = 9 }
        edit_rows[#edit_rows + 1] = gui.HBox {
            gui.Label {
                label = S("Editing social profile: @1", ctx.curr_name),
                expand = true, align_h = "left",
            },
            gui.ButtonExit {
                w = 0.5, h = 0.5,
                label = "x",
            },
        }
        edit_rows[#edit_rows + 1] = gui.Box { w = 0.05, h = 0.05, color = "grey" }

        for _, field_name in ipairs(social_profile.registered_fields_order) do
            local def = social_profile.registered_fields[field_name]
            if not def.disallow_edit then
                if changed then
                    ctx.form[field_name] = nil

                    if def.init_form then
                        def.init_form(player, ctx)
                    end
                end

                local value
                if def.get_value then
                    value = def.get_value(ctx.curr_name, profile)
                else
                    value = profile[field_name]
                end

                local row
                if def.get_edit_row then
                    row = def.get_edit_row(player, ctx, value)
                else
                    row = gui.Field {
                        name = field_name,
                        label = def.title or field_name,
                        default = value
                    }
                end

                edit_rows[#edit_rows + 1] = row
            end
        end

        edit_rows[#edit_rows + 1] = gui.Button {
            label = S("Save"),
            w = 3, h = 1,
            expand = true, align_h = "right",
            on_event = function(e_player, e_ctx)
                if social_profile.can_modify_profile(e_player:get_player_name(), e_ctx.curr_name) then
                    local new_profile = {}
                    for key, def in pairs(social_profile.registered_fields) do
                        if not def.disallow_edit then
                            local value
                            if def.process_form then
                                value = def.process_form(player, ctx)
                            else
                                value = string.trim(e_ctx.form[key])
                            end

                            if value == "" then
                                value = nil
                            end

                            new_profile[key] = value
                        end
                    end
                    social_profile.set_social_profile(e_ctx.curr_name, new_profile)
                    e_ctx.tab = "view"
                end
                return true
            end,
        }

        return gui.VBox(edit_rows)
    end,
    search = function(_, ctx)
        auth = auth or core.get_auth_handler()

        ctx.form.search = string.trim(ctx.form.search)
        ctx.form.search = string.lower(ctx.form.search)
        ctx.search_matches = nil
        local matches = {}
        if ctx.form.search == "" then
            matches[#matches + 1] = S("Type your search terms...")
        else
            for name in auth.iterate() do
                if string.match(string.lower(name), ctx.form.search) then
                    matches[#matches + 1] = name
                end
            end
            if #matches == 0 then
                matches[#matches + 1] = S("No matches.")
            else
                ctx.search_matches = matches
            end
        end

        return gui.VBox {
            gui.HBox {
                gui.Label {
                    label = S("Searching player"),
                    expand = true, align_h = "left",
                },
                gui.ButtonExit {
                    w = 0.5, h = 0.5,
                    label = "x",
                },
            },
            gui.Box { w = 0.05, h = 0.05, color = "grey" },

            gui.Hbox {
                gui.Field {
                    w = 5,
                    name = "search",
                },
                gui.Button {
                    w = 2,
                    label = S("Search"),
                    expand = true, align_h = "left",
                    on_event = function()
                        return true
                    end,
                },
            },

            gui.HBox {
                w = 7,
                gui.Textlist {
                    w = 6, h = 6,
                    name = "search_results",
                    listelems = matches,
                },
                ctx.search_matches and gui.Button {
                    w = 1,
                    label = S("Go"),
                    expand = true, align_v = "bottom",
                    on_event = function(_, e_ctx)
                        if e_ctx.search_matches then
                            e_ctx.curr_name = e_ctx.search_matches[e_ctx.form.search_results]
                            e_ctx.tab = "view"
                            return true
                        end
                    end,
                } or gui.Nil {},
            }
        }
    end,
}

social_profile.gui = flow.make_gui(function(player, ctx)
    local changed = false
    ctx.tab = ctx.tab or "view"
    if ctx.old_tab ~= ctx.tab then
        ctx.old_tab = ctx.tab
        changed = true
    end

    local tab_func = tab_funcs[ctx.tab] or tab_funcs.nonexist
    return tab_func(player, ctx, changed)
end)