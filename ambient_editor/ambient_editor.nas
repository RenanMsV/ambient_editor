#==================================================
#	GUI
#==================================================
var load_ambient_editor_gui = func {
	var dialogs   = ["ambient_editor"];
	var filenames = ["amb-dialog"];

	forindex (var i; dialogs)
		gui.Dialog.new("/sim/gui/dialogs/" ~ dialogs[i] ~ "/dialog", "Nasal/ambient_editor/dialogs/" ~ filenames[i] ~ ".xml");

	var data = {
		label   : "Ambient Editor",
		name    : "ambient_editor",
		binding : { command : "dialog-show", "dialog-name" : "ambient_editor" }
	};

	props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);

	fgcommand("gui-redraw");
	print("Ambient Editor GUI loaded");
}

var init_ambient_editor_timer = func {
	ambient_editor_values_handle('init');
	ambient_editor_values_sync();
	var amb_edit_timer = maketimer(.01, ambient_editor_values_refresh);
	amb_edit_timer.simulatedTime = 0;
	var amb_edit_listener = _setlistener("/sim/addons/ambient-editor/enable", func {
		enabled = props.globals.getNode('sim/addons/ambient-editor/enable').getValue();
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
	my = ["sim/addons/ambient-editor/scene/diffuse", "sim/addons/ambient-editor/scene/specular", "sim/addons/ambient-editor/scene/ambient", "sim/addons/ambient-editor/dome/sky", "sim/addons/ambient-editor/dome/fog", "sim/addons/ambient-editor/dome/cloud"];
	they = ["rendering/scene/diffuse", "rendering/scene/specular", "rendering/scene/ambient", "rendering/dome/sky", "rendering/dome/fog", "rendering/dome/cloud"];
	colors = ["/red", "/green", "/blue"];
	if (type == 'init'){
		props.globals.initNode('sim/addons/ambient-editor/enable', 0, "BOOL");
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

#--------------------------------------------------
var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);
	load_ambient_editor_gui();
	init_ambient_editor_timer();
});
