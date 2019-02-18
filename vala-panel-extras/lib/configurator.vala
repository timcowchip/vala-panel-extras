using GLib;
using Gtk;

public extern enum GenericConfigType
{
    STR,
    INT,
    BOOL,
    FILE,
    FILE_ENTRY,
    DIRECTORY_ENTRY,
    TRIM,
    EXTERNAL
}

namespace Configurator
{
    [CCode (cname= "generic_config_dlg", cheader_filename="generic-config-dialog.h")]
    public extern static Dialog generic_config_dlg(string title, Gtk.Window? parent, GLib.Settings settings, ...);
}
