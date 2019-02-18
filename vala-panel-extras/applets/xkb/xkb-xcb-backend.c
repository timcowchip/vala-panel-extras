#include <glib.h>
#include <stdbool.h>
#include <xcb/xcb.h>
#include <xcb/xkb.h>
#include <xcb/xproto.h>
#include <xkbcommon/xkbcommon-x11.h>
#include <xkbcommon/xkbcommon.h>

#define GBN_DETAIL_ALL                                                                             \
	XCB_XKB_GBN_DETAIL_TYPES | XCB_XKB_GBN_DETAIL_COMPAT_MAP |                                 \
	    XCB_XKB_GBN_DETAIL_CLIENT_SYMBOLS | XCB_XKB_GBN_DETAIL_SERVER_SYMBOLS |                \
	    XCB_XKB_GBN_DETAIL_INDICATOR_MAPS | XCB_XKB_GBN_DETAIL_KEY_NAMES |                     \
	    XCB_XKB_GBN_DETAIL_GEOMETRY | XCB_XKB_GBN_DETAIL_OTHER_NAMES

G_GNUC_INTERNAL void xkb_backend_xcb_set_keymap_on_window(struct xkb_context *ctx,
                                                          struct xkb_rule_names *rule_names,
                                                          xcb_connection_t *conn,
                                                          xcb_atom_t names_atom, xcb_window_t root)
{
	struct xkb_keymap *new_keymap =
	    xkb_keymap_new_from_names(ctx, rule_names, XKB_KEYMAP_COMPILE_NO_FLAGS);
	if (new_keymap == NULL)
		return;
	uint len = 0;
	len += strlen(rule_names->rules);
	len += strlen(rule_names->model);
	len += strlen(rule_names->layout);
	len += strlen(rule_names->variant);
	len += strlen(rule_names->options);
	if (len < 1)
		return;
	len += 5;
	GArray *rules_char = g_array_sized_new(false, true, 1, len);
	uint8_t zero       = 0;
	g_array_append_vals(rules_char, rule_names->rules, strlen(rule_names->rules));
	g_array_append_val(rules_char, zero);
	g_array_append_vals(rules_char, rule_names->model, strlen(rule_names->model));
	g_array_append_val(rules_char, zero);
	g_array_append_vals(rules_char, rule_names->layout, strlen(rule_names->layout));
	g_array_append_val(rules_char, zero);
	g_array_append_vals(rules_char, rule_names->variant, strlen(rule_names->variant));
	g_array_append_val(rules_char, zero);
	g_array_append_vals(rules_char, rule_names->options, strlen(rule_names->options));
	g_array_append_val(rules_char, zero);
	xcb_xkb_device_spec_t core_keyboard =
	    (xcb_xkb_device_spec_t)xkb_x11_get_core_keyboard_device_id(conn);
	// Not working, IDK why
	xcb_xkb_get_kbd_by_name_cookie_t cook =
	    xcb_xkb_get_kbd_by_name_unchecked(conn,
	                                      core_keyboard,
	                                      GBN_DETAIL_ALL,
	                                      GBN_DETAIL_ALL & (~XCB_XKB_GBN_DETAIL_GEOMETRY),
	                                      true);
	xcb_generic_error_t *e                     = NULL;
	xcb_xkb_get_kbd_by_name_reply_t *xkb_reply = xcb_xkb_get_kbd_by_name_reply(conn, cook, &e);
	//    xcb_discard_reply(conn,cook.sequence);
	xcb_change_property_checked(conn,
	                            XCB_PROP_MODE_REPLACE,
	                            root,
	                            names_atom,
	                            XCB_ATOM_STRING,
	                            8,
	                            rules_char->len,
	                            rules_char->data);
	xkb_keymap_unref(new_keymap);
	g_array_free(rules_char, true);
}
