-- WezTerm configuration — mirrors ~/.config/ghostty/config
-- Docs: https://wezterm.org/config/lua/config/index.html
--
-- Ghostty settings with no WezTerm equivalent are noted inline so the two
-- configs can be diffed section by section.

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- ── theme ─────────────────────────────────────────────────────────────────
config.color_scheme = "GitHub Dark"
config.window_background_opacity = 0.99
-- ghostty macos-icon: no equivalent (WezTerm ships a single app icon)

-- ── font ──────────────────────────────────────────────────────────────────
-- Ghostty stacks repeated font-family lines into a fallback chain.
config.font = wezterm.font_with_fallback({
	"MesloLGL Nerd Font Mono",
	"JetBrainsMono Nerd Font Mono",
	"GeistMono Nerd Font",
})
config.font_size = 16
-- ghostty font-feature = -liga
config.harfbuzz_features = { "liga=0", "clig=0", "calt=0" }
-- ghostty font-thicken = true (CoreText-only): approximated with subpixel
-- rendering, which renders glyphs visually heavier.
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- ── cursor ────────────────────────────────────────────────────────────────
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0
-- ghostty shell-integration-features = no-cursor: no equivalent. Programs can
-- still change the cursor shape via DECSCUSR.

-- ── initial size ──────────────────────────────────────────────────────────
config.initial_cols = 130
config.initial_rows = 40

-- ── updates ───────────────────────────────────────────────────────────────
-- ghostty auto-update = download. WezTerm only notifies; it never self-installs.
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400
config.show_update_window = true

-- ── misc ──────────────────────────────────────────────────────────────────
-- ghostty confirm-close-surface = false
config.window_close_confirmation = "NeverPrompt"
config.quit_when_all_windows_are_closed = true
-- ghostty window-save-state = always: no built-in equivalent (needs the
-- third-party resurrect.wezterm plugin).

-- ── macos ─────────────────────────────────────────────────────────────────
-- ghostty macos-option-as-alt = true: stop macOS from composing Option+key
-- into accented characters so Alt reaches the shell.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- ── scrollback ────────────────────────────────────────────────────────────
-- ghostty scrollback-limit counts bytes; WezTerm counts lines.
config.scrollback_lines = 100000
-- ghostty scroll-to-bottom = keystroke,no-output
config.scroll_to_bottom_on_input = true

-- ── copy/paste ────────────────────────────────────────────────────────────
-- ghostty copy-on-select = clipboard: already the WezTerm default — releasing
-- a drag runs CompleteSelection("ClipboardAndPrimarySelection").
-- ghostty selection-clear-on-typing / selection-clear-on-copy: not configurable.

-- ── window padding ────────────────────────────────────────────────────────
config.window_padding = { left = 8, right = 8, top = 4, bottom = 4 }

-- ── window chrome ─────────────────────────────────────────────────────────
-- Drop the macOS titlebar and draw the minimize/maximize/close buttons inside
-- the tab bar instead. RESIZE keeps the resizable border — plain "NONE" would
-- lose it.
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- ── tab bar ───────────────────────────────────────────────────────────────
-- Ghostty uses native macOS tabs; WezTerm draws its own. Requires the fancy
-- tab bar, and it must stay visible even with a single tab: it hosts the window
-- buttons and is the drag handle for moving a titlebar-less window (SUPER+drag
-- also works).
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- ── split styling ─────────────────────────────────────────────────────────
-- ghostty unfocused-split-opacity = 0.8
config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.8 }
-- ghostty split-divider-color
config.colors = { split = "#555555" }

-- ── notify ────────────────────────────────────────────────────────────────
-- ghostty notify-on-command-finish: no built-in equivalent. WezTerm forwards
-- OSC 9 / OSC 777 to macOS notifications, so the shell would have to emit them.

-- ── keybinds ──────────────────────────────────────────────────────────────
config.keys = {
	{ key = "v", mods = "CMD|SHIFT", action = act.PasteFrom("Clipboard") },
	-- Drop screen + scrollback, then redraw the prompt.
	{
		key = "k",
		mods = "CMD",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "l", mods = "CTRL" }),
		}),
	},
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "[", mods = "CMD", action = act.ActivatePaneDirection("Prev") },
	{ key = "]", mods = "CMD", action = act.ActivatePaneDirection("Next") },
	-- ghostty goto_tab:1..3 — CMD+1..8 are already WezTerm defaults.
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = act.ActivateKeyTable({ name = "resize", one_shot = false, prevent_fallback = true }),
	},
}

-- Resize mode: arrows resize the active split, Escape leaves. prevent_fallback
-- swallows everything else, matching ghostty's resize/catch_all=ignore.
config.key_tables = {
	resize = {
		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 10 }) },
		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 10 }) },
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 10 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 10 }) },
		{ key = "Escape", action = act.PopKeyTable },
	},
}

return config
