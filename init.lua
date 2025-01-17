-- social_profile/init.lua
-- Database for player social profiles
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-3.0-or-later

local core = core

social_profile = {}

local MP = core.get_modpath("social_profile")

dofile(MP .. "/src/api.lua")
dofile(MP .. "/src/defaults.lua")
dofile(MP .. "/src/gui.lua")
dofile(MP .. "/src/chatcommand.lua")
