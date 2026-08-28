local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-----------------------------------------------------------------------
-- Appearance
-----------------------------------------------------------------------

config.color_scheme = 'Tokyo Night Moon'

config.font_size = 11.5

-- When resizing font, don't also resize the window (causes weirdness with
-- tiled windows)
config.adjust_window_size_when_changing_font_size = false

config.window_background_opacity = 0.96

config.window_padding = {
  left = 10,
  right = 10,
  top = 8,
  bottom = 8,
}

config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Use the simpler terminal-style tab bar rather than the native-looking one.
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 28

-- Tokyo Night-inspired tab bar:
-- dark background, purple inactive tabs, gold active tab, pink hover.
config.colors = {
  tab_bar = {
    background = '#16161e',

    active_tab = {
      bg_color = '#e0af68',
      fg_color = '#16161e',
      intensity = 'Bold',
    },

    inactive_tab = {
      bg_color = '#1f2335',
      fg_color = '#bb9af7',
    },

    inactive_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#f7768e',
    },

    new_tab = {
      bg_color = '#16161e',
      fg_color = '#e0af68',
    },

    new_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#f7768e',
    },
  },
}

-----------------------------------------------------------------------
-- Multiplexer
-----------------------------------------------------------------------

config.unix_domains = {
  {
    name = 'unix',
  },
}

-- Starting "wezterm" behaves like:
--
--     wezterm connect unix
--
-- The mux server is started automatically if necessary.
config.default_gui_startup_args = { 'connect', 'unix' }

-----------------------------------------------------------------------
-- Leader key
-----------------------------------------------------------------------

-- Define leader key binding
config.leader = {
  key = 'q',
  mods = 'ALT',
  timeout_milliseconds = 1000,
}

-- Show when leader key is active
wezterm.on( 'update-right-status', function(window, pane)
   local status_text = ''

   if window:leader_is_active() then
      status_text = ' 🐋 '
   end

   window:set_right_status(status_text)
end)

-- Change cursor color when leader state is held as additional signaling
config.colors.compose_cursor = 'orange'

-----------------------------------------------------------------------
-- Key bindings
-----------------------------------------------------------------------

config.keys = {
  ---------------------------------------------------------------------
  -- Tabs / windows
  ---------------------------------------------------------------------

  {
    key = 't',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },

  {
    key = 'n',
    mods = 'LEADER',
    action = act.SpawnCommandInNewWindow {
      domain = 'CurrentPaneDomain',
    },
  },

--  {
--    key = '[',
--    mods = 'LEADER',
--    action = act.ActivateTabRelative(-1),
--  },
--
--  {
--    key = ']',
--    mods = 'LEADER',
--    action = act.ActivateTabRelative(1),
--  },

  {
    key = '0',
    mods = 'LEADER',
    action = act.ActivateTab(-1),
  },

  {
    key = '1',
    mods = 'LEADER',
    action = act.ActivateTab(0),
  },

  {
    key = '[',
    mods = 'LEADER',
    action = act.MoveTabRelative(-1),
  },

  {
    key = ']',
    mods = 'LEADER',
    action = act.MoveTabRelative(1),
  },

  ---------------------------------------------------------------------
  -- Split panes
  ---------------------------------------------------------------------

  -- Left/right
  {
    key = 's',
    mods = 'LEADER',
    action = act.SplitHorizontal {
      domain = 'CurrentPaneDomain',
    },
  },

  -- Top/bottom
  {
    key = 'v',
    mods = 'LEADER',
    action = act.SplitVertical {
      domain = 'CurrentPaneDomain',
    },
  },

  -- Close current pane
  {
    key = 'w',
    mods = 'LEADER',
    action = act.CloseCurrentPane { confirm = true },
  },

  -- Activates the pane to the left
  {
     key = 'h',
     mods = 'LEADER',
     action = act.ActivatePaneDirection 'Left'
  },

  -- Activates the pane to the right
  {
     key = 'l',
     mods = 'LEADER',
     action = act.ActivatePaneDirection 'Right'
  },

  -- Activates the pane above
  {
     key = 'k',
     mods = 'LEADER',
     action = act.ActivatePaneDirection 'Up'
  },

  -- Activates the pane below
  {
     key = 'j',
     mods = 'LEADER',
     action = act.ActivatePaneDirection 'Down'
  },

  ---------------------------------------------------------------------
  -- Navigate panes using Vim directions
  ---------------------------------------------------------------------

  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },

  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },

  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },

  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },

  ---------------------------------------------------------------------
  -- Resize panes
  ---------------------------------------------------------------------

  {
    key = 'LeftArrow',
    mods = 'LEADER',
    action = act.AdjustPaneSize { 'Left', 3 },
  },

  {
    key = 'DownArrow',
    mods = 'LEADER',
    action = act.AdjustPaneSize { 'Down', 3 },
  },

  {
    key = 'UpArrow',
    mods = 'LEADER',
    action = act.AdjustPaneSize { 'Up', 3 },
  },

  {
    key = 'RightArrow',
    mods = 'LEADER',
    action = act.AdjustPaneSize { 'Right', 3 },
  },

  ---------------------------------------------------------------------
  -- Pane actions
  ---------------------------------------------------------------------

  {
    key = 'z',
    mods = 'LEADER',
    action = act.TogglePaneZoomState,
  },

  {
    key = 'x',
    mods = 'LEADER',
    action = act.CloseCurrentPane {
      confirm = true,
    },
  },

  ---------------------------------------------------------------------
  -- WezTerm UI
  ---------------------------------------------------------------------

  {
    key = 'p',
    mods = 'LEADER',
    action = act.ActivateCommandPalette,
  },

  ---------------------------------------------------------------------
  -- Multiplexer
  ---------------------------------------------------------------------

  -- Disconnect this GUI from the mux without killing its panes.
  {
    key = 'd',
    mods = 'LEADER',
    action = act.DetachDomain 'CurrentPaneDomain',
  },
}

-----------------------------------------------------------------------
-- Mouse bindings
-----------------------------------------------------------------------

config.mouse_bindings = {
  -- Ctrl + scroll up → increase font size
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'CTRL',
    action = act.IncreaseFontSize,
  },

  -- Ctrl + scroll down → decrease font size
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'CTRL',
    action = act.DecreaseFontSize,
  },
}

-----------------------------------------------------------------------
-- Notifications
-----------------------------------------------------------------------

config.notification_handling = "NeverShow"

return config
