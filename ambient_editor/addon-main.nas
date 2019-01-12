#==================================================
#	GUI
#==================================================
var load_ambient_editor_gui = func {
	ambient_editor_load_dialogs();
	var data = {
		label   : "Ambient Editor",
		name    : "ambient_editor",
		binding : { command : "dialog-show", "dialog-name" : "ambient_editor" }
	};
	props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);
	fgcommand("gui-redraw");
	print("Ambient Editor GUI loaded");
}

var ambient_editor_load_dialogs = func {
	var dialogs   = ["ambient_editor", "ambient_editor_about", "ambient_editor_import_list"];
	var filenames = ["amb-dialog", "about-dialog", "amb-import-list"];
	forindex (var i; dialogs)
		gui.Dialog.new("/sim/gui/dialogs/" ~ dialogs[i] ~ "/dialog", getprop("/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/path") ~ "/dialogs/" ~ filenames[i] ~ ".xml");
}

var init_ambient_editor_timer = func () {
	ambient_editor_values_handle('init');
	ambient_editor_values_sync();
	var amb_edit_timer = maketimer(.01, ambient_editor_values_refresh);
	amb_edit_timer.simulatedTime = 0;
	var amb_edit_listener = _setlistener("/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/enable", func {
		enabled = props.globals.getNode('/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/enable').getValue();
		if(enabled){
			amb_edit_timer.start();
		}else{
			amb_edit_timer.stop();
			ambient_editor_values_sync();
		}  
	});
	print("Ambient Editor CORE loaded");
}

var ambient_editor_values_refresh = func {
	ambient_editor_values_handle('refresh');
}

var ambient_editor_values_sync = func {
	tmp_timer = maketimer(.5, func() {ambient_editor_values_handle('sync')});
	tmp_timer.singleShot = 1;
	tmp_timer.simulatedTime = 0;
	tmp_timer.start();
}

var ambient_editor_values_handle = func (type) {
	my = ["/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings/scene/diffuse", "/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings/scene/specular", "/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings/scene/ambient", "/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings/dome/sky", "/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings/dome/fog", "/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings/dome/cloud"];
	they = ["rendering/scene/diffuse", "rendering/scene/specular", "rendering/scene/ambient", "rendering/dome/sky", "rendering/dome/fog", "rendering/dome/cloud"];
	colors = ["/red", "/green", "/blue"];
	if (type == 'init'){
		getAmbientEditorPath();
		props.globals.initNode('/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/enable', 0, "BOOL");
		props.globals.initNode('/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/about', "Ambient Editor\nAddon by FlightGearBrasil.com.br", "STRING");
		props.globals.initNode('/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/selected-preset', 'NIL', "STRING");
		forindex(var i; my){
			forindex(var j; colors){
				props.globals.initNode(my[i]~colors[j],'null');
			}
		}
	}
	if(type == 'refresh'){
		forindex(var i; my){
			forindex(var j; colors){
				props.globals.getNode(they[i]~colors[j]).setDoubleValue(props.globals.getNode(my[i]~colors[j]).getValue());
			}
		}
	}
	if(type == 'sync'){
		forindex(var i; my){
			forindex(var j; colors){
				props.globals.getNode(my[i]~colors[j]).setDoubleValue(props.globals.getNode(they[i]~colors[j]).getValue());
			}
		}
	}
}

var ambient_editor_save_file = func {
	var save_xml_sel = nil;
	var save_xml = func(n) {
		result = io.write_properties(n.getValue(), props.globals.getNode("/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings"));
		if(result == nil) print("Ambient Editor: Error trying to save file."); else print("Ambient Editor: Saved file to " ~ result);
	}
	if (save_xml_sel == nil) save_xml_sel = gui.FileSelector.new(save_xml, "Save...", "Save", ["*.xml"], getprop("/sim/fg-home") ~ "/Export/", "*.xml");
	save_xml_sel.open();
	gui.popupTip ("Great! Now move the preset file from " ~ getprop("/sim/fg-home") ~ "/Export/ to the addon presets folder", 6);
}

var ambient_editor_load_preset = func (type) {
	var listN    = cmdarg().getNode("group[1]/list");
	var path     = getprop("/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/path") ~ "/presets/";
	var dir      = directory(path);
	var list     = [];
	if(type == 'sync'){
		foreach(var file; sort(dir, cmp))
			if(size(file) > 4 and substr(file, -4) == ".xml") append(list, split(".", file)[0]);
		listN.removeChildren("value");
		forindex (var i; list)
			listN.addChild("value").setValue(list[i]);
		fgcommand( "dialog-update", props.Node.new({"dialog-name" : "ambient_editor_import_list"}) );
	}
	if (type == 'import'){
		var node      = props.globals.getNode("/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/settings");
		var selection = getprop('/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/selected-preset');
		props.copy(io.read_properties(path ~ "/" ~ selection ~ ".xml"), node);
	}
}

var getAmbientEditorPath = func {
	listN = props.globals.getNode("addons").getChildren("addon");
	forindex (var n; listN) {
		splited = split('/', listN[n].getChild("path").getValue());
		if (splited[size(splited)-1] == "ambient_editor") {
			props.globals.initNode("/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/path", listN[n].getChild("path").getValue());
			props.globals.initNode("/addons/by-id/github.renanmsv.AmbientEditor/addon-devel/namespace", '__addon[org.flightgear.addons.AmbientEditor]__');
		}
	}
}

#--------------------------------------------------
var main = func ( root ) {
	var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
		removelistener(fdm_init_listener);
		init_ambient_editor_timer();
		load_ambient_editor_gui();
	});
};  # main ()
