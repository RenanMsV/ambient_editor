# https://sourceforge.net/p/flightgear/fgdata/ci/next/tree/Docs/README.add-ons

var getpropaddon = func (v) {
  return "/addons/by-id/github.renanmsv.addons.AmbientEditor" ~ v;
}

var init_ambient_editor_timer = func () {
  ambient_editor_values_handle('init');
  ambient_editor_values_sync();
  var amb_edit_timer = maketimer(.01, ambient_editor_values_refresh);
  amb_edit_timer.simulatedTime = 0;
  var amb_edit_listener = setlistener(getpropaddon("/addon-devel/config/enable"), func {
    enabled = props.globals.getNode(getpropaddon("/addon-devel/config/enable")).getValue();
    if (enabled) {
      amb_edit_timer.start();
    } else {
      amb_edit_timer.stop();
      ambient_editor_values_sync();
    }  
  });
  logprint(LOG_INFO, "[Ambient Editor-Addon] TIMER loaded");
}

var ambient_editor_values_refresh = func {
  ambient_editor_values_handle('refresh');
}

var ambient_editor_values_sync = func {
  tmp_timer = maketimer(.5, func () {ambient_editor_values_handle('sync')});
  tmp_timer.singleShot = 1;
  tmp_timer.simulatedTime = 0;
  tmp_timer.start();
}

var ambient_editor_values_handle = func (type) {
  my = [getpropaddon("/addon-devel/config/settings/scene/diffuse"), getpropaddon("/addon-devel/config/settings/scene/specular"), getpropaddon("/addon-devel/config/settings/scene/ambient"), getpropaddon("/addon-devel/config/settings/dome/sky"), getpropaddon("/addon-devel/config/settings/dome/fog"), getpropaddon("/addon-devel/config/settings/dome/cloud")];
  they = ["rendering/scene/diffuse", "rendering/scene/specular", "rendering/scene/ambient", "rendering/dome/sky", "rendering/dome/fog", "rendering/dome/cloud"];
  colors = ["/red", "/green", "/blue"];
  if (type == 'init') {
    forindex (var i; my) {
      forindex (var j; colors) {
        props.globals.initNode(my[i]~colors[j],'null');
      }
    }
  }
  if (type == 'refresh') {
    forindex (var i; my) {
      forindex (var j; colors) {
        props.globals.getNode(they[i]~colors[j]).setDoubleValue(props.globals.getNode(my[i]~colors[j]).getValue());
      }
    }
  }
  if (type == 'sync') {
    forindex (var i; my) {
      forindex (var j; colors) {
        props.globals.getNode(my[i]~colors[j]).setDoubleValue(props.globals.getNode(they[i]~colors[j]).getValue());
      }
    }
  }
}

var ambient_editor_save_file = func {
  var save_xml_sel = nil;
  var save_xml = func (n) {
    result = io.write_properties(n.getValue(), props.globals.getNode(getpropaddon("/addon-devel/config/settings")));
    if (result == nil) print("Ambient Editor: Error trying to save file."); else print("Ambient Editor: Saved file to " ~ result);
  }
  if (save_xml_sel == nil) save_xml_sel = gui.FileSelector.new(save_xml, "Save...", "Save", ["*.xml"], getprop(getpropaddon("/addon-devel/storage-path")), "*.xml");
  save_xml_sel.open();
  gui.popupTip ("Great! Now move the preset file from " ~ getprop(getpropaddon("/addon-devel/storage-path")) ~ " to the addon presets folder", 15);
}

var ambient_editor_load_preset = func (type) {
  var listN = cmdarg().getNode("group[1]/list");
  var path = getprop(getpropaddon("/path")) ~ "/presets/";
  var dir = directory(path);
  var list = [];
  if (type == 'sync') {
    foreach (var file; sort(dir, cmp))
      if (size(file) > 4 and substr(file, -4) == ".xml") append(list, split(".", file)[0]);
    listN.removeChildren("value");
    forindex (var i; list)
      listN.addChild("value").setValue(list[i]);
    fgcommand( "dialog-update", props.Node.new({"dialog-name" : "ambient_editor_import_list"}) );
  }
  if (type == 'import') {
    var node = props.globals.getNode(getpropaddon("/addon-devel/config/settings"));
    var selection = getprop(getpropaddon("/addon-devel/config/selected-preset"));
    props.copy(io.read_properties(path ~ "/" ~ selection ~ ".xml"), node);
  }
}

#--------------------------------------------------
var main = func ( addon ) {
  setprop(getpropaddon("/addon-devel/storage-path"), addon.createStorageDir());
  init_ambient_editor_timer();
  logprint(LOG_INFO, "[Ambient Editor-Addon] Initialized from path ", addon.basePath);
};  # main ()

var unload = func ( addon ) {
  setprop(getpropaddon("/addon-devel/config/enable"), 0, "BOOL");
}
