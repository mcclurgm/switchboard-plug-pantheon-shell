/*
* Copyright 2018–2021 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class PantheonShell.Appearance : Gtk.Grid {
    private const string INTERFACE_SCHEMA = "org.gnome.desktop.interface";
    private const string STYLESHEET_KEY = "gtk-theme";
    private const string STYLESHEET_PREFIX = "io.elementary.stylesheet.";

    private enum AccentColor {
        NO_PREFERENCE,
        RED,
        ORANGE,
        YELLOW,
        GREEN,
        MINT,
        BLUE,
        PURPLE,
        PINK,
        BROWN,
        GRAY;

        public string to_string () {
            switch (this) {
                case RED:
                    return "strawberry";
                case ORANGE:
                    return "orange";
                case YELLOW:
                    return "banana";
                case GREEN:
                    return "lime";
                case MINT:
                    return "mint";
                case BLUE:
                    return "blueberry";
                case PURPLE:
                    return "grape";
                case PINK:
                    return "bubblegum";
                case BROWN:
                    return "cocoa";
                case GRAY:
                    return "slate";
            }

            return "auto";
        }
    }

    construct {
        column_spacing = 12;
        halign = Gtk.Align.CENTER;
        row_spacing = 6;
        margin_start = margin_end = 12;
        margin_bottom = 24;

        var dark_label = new Gtk.Label (_("Style:")) {
            halign = Gtk.Align.END
        };

        var prefer_default_image = new Gtk.Image.from_resource ("/io/elementary/switchboard/plug/pantheon-shell/appearance-default.svg");

        var prefer_default_card = new Gtk.Grid () {
            margin = 6,
            margin_start = 12
        };
        prefer_default_card.add (prefer_default_image);

        unowned Gtk.StyleContext prefer_default_card_context = prefer_default_card.get_style_context ();
        prefer_default_card_context.add_class (Granite.STYLE_CLASS_CARD);
        prefer_default_card_context.add_class (Granite.STYLE_CLASS_ROUNDED);

        var prefer_default_grid = new Gtk.Grid () {
            row_spacing = 6
        };
        prefer_default_grid.attach (prefer_default_card, 0, 0);
        prefer_default_grid.attach (new Gtk.Label (_("Default")), 0, 1);

        var prefer_default_radio = new Gtk.RadioButton (null) {
            halign = Gtk.Align.START
        };
        prefer_default_radio.get_style_context ().add_class ("image-button");
        prefer_default_radio.add (prefer_default_grid);

        var prefer_dark_image = new Gtk.Image.from_resource ("/io/elementary/switchboard/plug/pantheon-shell/appearance-dark.svg");

        var prefer_dark_card = new Gtk.Grid () {
            margin = 6,
            margin_start = 12
        };
        prefer_dark_card.add (prefer_dark_image);

        unowned Gtk.StyleContext prefer_dark_card_context = prefer_dark_card.get_style_context ();
        prefer_dark_card_context.add_class (Granite.STYLE_CLASS_CARD);
        prefer_dark_card_context.add_class (Granite.STYLE_CLASS_ROUNDED);

        var prefer_dark_grid = new Gtk.Grid () {
            row_spacing = 6
        };
        prefer_dark_grid.attach (prefer_dark_card, 0, 0);
        prefer_dark_grid.attach (new Gtk.Label (_("Dark")), 0, 1);

        var prefer_dark_radio = new Gtk.RadioButton.from_widget (prefer_default_radio) {
            halign = Gtk.Align.START,
            hexpand = true
        };
        prefer_dark_radio.get_style_context ().add_class ("image-button");
        prefer_dark_radio.add (prefer_dark_grid);

        var dark_info = new Gtk.Label (_("Preferred visual style for system components. Apps may also choose to follow this preference.")) {
            max_width_chars = 60,
            margin_bottom = 18,
            wrap = true,
            xalign = 0
        };
        dark_info.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var schedule_label = new Gtk.Label (_("Schedule:")) {
            halign = Gtk.Align.END,
            xalign = 1
        };

        var schedule_mode_button = new Granite.Widgets.ModeButton ();
        schedule_mode_button.append_text (_("Disabled"));
        schedule_mode_button.append_text (_("Sunset to Sunrise"));
        schedule_mode_button.append_text (_("Manual"));

        var from_label = new Gtk.Label (_("From:"));

        var from_time = new Granite.Widgets.TimePicker () {
            hexpand = true
        };

        var to_label = new Gtk.Label (_("To:"));

        var to_time = new Granite.Widgets.TimePicker () {
            hexpand = true
        };

        var schedule_grid = new Gtk.Grid () {
            column_spacing = 12,
            margin_bottom = 24
        };

        schedule_grid.add (from_label);
        schedule_grid.add (from_time);
        schedule_grid.add (to_label);
        schedule_grid.add (to_time);

        Pantheon.AccountsService? pantheon_act = null;

        string? user_path = null;
        try {
            FDO.Accounts? accounts_service = GLib.Bus.get_proxy_sync (
                GLib.BusType.SYSTEM,
               "org.freedesktop.Accounts",
               "/org/freedesktop/Accounts"
            );

            user_path = accounts_service.find_user_by_name (GLib.Environment.get_user_name ());
        } catch (Error e) {
            critical (e.message);
        }

        if (user_path != null) {
            try {
                pantheon_act = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                    "org.freedesktop.Accounts",
                    user_path,
                    GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES
                );
            } catch (Error e) {
                warning ("Unable to get AccountsService proxy, color scheme preference may be incorrect");
            }
        }

        if (((GLib.DBusProxy) pantheon_act).get_cached_property ("PrefersColorScheme") != null) {
            attach (dark_label, 0, 0);
            attach (prefer_default_radio, 1, 0);
            attach (prefer_dark_radio, 2, 0);
            attach (dark_info, 1, 1, 2);
            attach (schedule_label, 0, 2, 1, 1);
            attach (schedule_mode_button, 1, 2, 2, 1);
            attach (schedule_grid, 1, 3, 2, 1);

            switch (pantheon_act.prefers_color_scheme) {
                case Granite.Settings.ColorScheme.DARK:
                    prefer_dark_radio.active = true;
                    break;
                default:
                    prefer_default_radio.active = true;
                    break;
            }

            prefer_default_radio.toggled.connect (() => {
                pantheon_act.prefers_color_scheme = Granite.Settings.ColorScheme.NO_PREFERENCE;
            });

            prefer_dark_radio.toggled.connect (() => {
                pantheon_act.prefers_color_scheme = Granite.Settings.ColorScheme.DARK;
            });

            /* Connect to button_release_event so that this is only triggered
             * through user interaction, not if scheduling changes the selection
             */
            prefer_default_radio.button_release_event.connect (() => {
                schedule_mode_button.selected = 0;
                return Gdk.EVENT_PROPAGATE;
            });

            prefer_dark_radio.button_release_event.connect (() => {
                schedule_mode_button.selected = 0;
                return Gdk.EVENT_PROPAGATE;
            });

            ((GLib.DBusProxy) pantheon_act).g_properties_changed.connect ((changed, invalid) => {
                var color_scheme = changed.lookup_value ("PrefersColorScheme", new VariantType ("i"));
                if (color_scheme != null) {
                    switch ((Granite.Settings.ColorScheme) color_scheme.get_int32 ()) {
                        case Granite.Settings.ColorScheme.DARK:
                            prefer_dark_radio.active = true;
                            break;
                        default:
                            prefer_default_radio.active = true;
                            break;
                    }
                }
            });

            var settings = new GLib.Settings ("io.elementary.settings-daemon.prefers-color-scheme");

            from_time.time = double_date_time (settings.get_double ("prefer-dark-schedule-from"));
            from_time.time_changed.connect (() => {
                settings.set_double ("prefer-dark-schedule-from", date_time_double (from_time.time));
            });
            to_time.time = double_date_time (settings.get_double ("prefer-dark-schedule-to"));
            to_time.time_changed.connect (() => {
                settings.set_double ("prefer-dark-schedule-to", date_time_double (to_time.time));
            });

            var schedule = settings.get_string ("prefer-dark-schedule");
            from_label.sensitive = schedule == "manual";
            from_time.sensitive = schedule == "manual";
            to_label.sensitive = schedule == "manual";
            to_time.sensitive = schedule == "manual";

            if (schedule == "sunset-to-sunrise") {
                schedule_mode_button.selected = 1;
            } else if (schedule == "manual") {
                schedule_mode_button.selected = 2;
            } else {
                schedule_mode_button.selected = 0;
            }

            schedule_mode_button.mode_changed.connect (() => {
                if (schedule_mode_button.selected == 1) {
                    schedule = "sunset-to-sunrise";
                } else if (schedule_mode_button.selected == 2) {
                    schedule = "manual";
                } else {
                    schedule = "disabled";
                }

                settings.set_string ("prefer-dark-schedule", schedule);

                from_label.sensitive = schedule == "manual";
                from_time.sensitive = schedule == "manual";
                to_label.sensitive = schedule == "manual";
                to_time.sensitive = schedule == "manual";
            });
        }

        var interface_settings = new GLib.Settings (INTERFACE_SCHEMA);
        var current_stylesheet = interface_settings.get_string (STYLESHEET_KEY);

        debug ("Current stylesheet: %s", current_stylesheet);

        if (current_stylesheet.has_prefix (STYLESHEET_PREFIX)) {
            /// TRANSLATORS: as in "Accent color"
            var accent_label = new Gtk.Label (_("Accent:"));
            accent_label.halign = Gtk.Align.END;

            var blueberry_button = new PrefersAccentColorButton (pantheon_act, AccentColor.BLUE);
            blueberry_button.tooltip_text = _("Blueberry");

            var mint_button = new PrefersAccentColorButton (pantheon_act, AccentColor.MINT, blueberry_button);
            mint_button.tooltip_text = _("Mint");

            var lime_button = new PrefersAccentColorButton (pantheon_act, AccentColor.GREEN, blueberry_button);
            lime_button.tooltip_text = _("Lime");

            var banana_button = new PrefersAccentColorButton (pantheon_act, AccentColor.YELLOW, blueberry_button);
            banana_button.tooltip_text = _("Banana");

            var orange_button = new PrefersAccentColorButton (pantheon_act, AccentColor.ORANGE, blueberry_button);
            orange_button.tooltip_text = _("Orange");

            var strawberry_button = new PrefersAccentColorButton (pantheon_act, AccentColor.RED, blueberry_button);
            strawberry_button.tooltip_text = _("Strawberry");

            var bubblegum_button = new PrefersAccentColorButton (pantheon_act, AccentColor.PINK, blueberry_button);
            bubblegum_button.tooltip_text = _("Bubblegum");

            var grape_button = new PrefersAccentColorButton (pantheon_act, AccentColor.PURPLE, blueberry_button);
            grape_button.tooltip_text = _("Grape");

            var cocoa_button = new PrefersAccentColorButton (pantheon_act, AccentColor.BROWN, blueberry_button);
            cocoa_button.tooltip_text = _("Cocoa");

            var slate_button = new PrefersAccentColorButton (pantheon_act, AccentColor.GRAY, blueberry_button);
            slate_button.tooltip_text = _("Slate");

            var auto_button = new PrefersAccentColorButton (pantheon_act, AccentColor.NO_PREFERENCE, blueberry_button);
            auto_button.tooltip_text = _("Automatic based on wallpaper");

            var accent_grid = new Gtk.Grid ();
            accent_grid.column_spacing = 6;
            accent_grid.add (blueberry_button);
            accent_grid.add (mint_button);
            accent_grid.add (lime_button);
            accent_grid.add (banana_button);
            accent_grid.add (orange_button);
            accent_grid.add (strawberry_button);
            accent_grid.add (bubblegum_button);
            accent_grid.add (grape_button);
            accent_grid.add (cocoa_button);
            accent_grid.add (slate_button);
            accent_grid.add (auto_button);

            var accent_info = new Gtk.Label (_("Used across the system by default. Apps can always use their own accent color.")) {
                margin_bottom = 18,
                xalign = 0,
                wrap = true
            };
            accent_info.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            attach (accent_label, 0, 4);
            attach (accent_grid, 1, 4, 2);
            attach (accent_info, 1, 5, 2);
        }
    }

    private class PrefersAccentColorButton : Gtk.RadioButton {
        public AccentColor color { get; construct; }
        public Pantheon.AccountsService? pantheon_act { get; construct; default = null; }

        private static GLib.Settings interface_settings;

        public PrefersAccentColorButton (Pantheon.AccountsService? pantheon_act, AccentColor color, Gtk.RadioButton? group_member = null) {
            Object (
                pantheon_act: pantheon_act,
                color: color,
                group: group_member
            );
        }

        static construct {
            interface_settings = new GLib.Settings (INTERFACE_SCHEMA);

            var current_stylesheet = interface_settings.get_string (STYLESHEET_KEY);
        }

        construct {
            unowned Gtk.StyleContext context = get_style_context ();
            context.add_class (Granite.STYLE_CLASS_COLOR_BUTTON);
            context.add_class (color.to_string ());

            realize.connect (() => {
                active = color == pantheon_act.prefers_accent_color;

                toggled.connect (() => {
                    if (color != AccentColor.NO_PREFERENCE) {
                        interface_settings.set_string (
                            STYLESHEET_KEY,
                            STYLESHEET_PREFIX + color.to_string ()
                        );
                    }

                    if (((GLib.DBusProxy) pantheon_act).get_cached_property ("PrefersAccentColor") != null) {
                        pantheon_act.prefers_accent_color = color;
                    }
                });
            });
        }
    }

    private static DateTime double_date_time (double dbl) {
        var hours = (int) dbl;
        var minutes = (int) Math.round ((dbl - hours) * 60);

        var date_time = new DateTime.local (1, 1, 1, hours, minutes, 0.0);

        return date_time;
    }

    private static double date_time_double (DateTime date_time) {
        double time_double = 0;
        time_double += date_time.get_hour ();
        time_double += (double) date_time.get_minute () / 60;

        return time_double;
    }
}
