# https://sourceforge.net/p/flightgear/fgdata/ci/next/tree/Docs/README.add-ons

var getpropaddon = func (v) {
  return "/addons/by-id/github.renanmsv.addons.AmbientEditor" ~ v;
}

var init_ambient_editor_timer = func () {
  ambient_editor_values_handle('init');
  ambient_editor_values_reset();
  var amb_edit_timer = maketimer(.01, ambient_editor_values_refresh);
  amb_edit_timer.simulatedTime = 0;
  var amb_edit_listener = setlistener(getpropaddon("/addon-devel/config/enable"), func {
    enabled = props.globals.getNode(getpropaddon("/addon-devel/config/enable")).getValue();
    if (enabled) {
      amb_edit_timer.start();
    } else {
      amb_edit_timer.stop();
      ambient_editor_values_reset();
    }  
  });
  logprint(LOG_INFO, "[Ambient Editor-Addon] TIMER loaded");
}

var ambient_editor_values_refresh = func { # this function refreshes the colors
  ambient_editor_values_handle('refresh');
}

var ambient_editor_values_reset = func { # this function creates the timer to reset
  tmp_timer = maketimer(.5, func () {ambient_editor_values_handle('reset')});
  tmp_timer.singleShot = 1;
  tmp_timer.simulatedTime = 0;
  tmp_timer.start();
}

var ambient_editor_values_handle = func (type) {
  my = [getpropaddon("/addon-devel/config/settings/scene/diffuse"), getpropaddon("/addon-devel/config/settings/scene/specular"), getpropaddon("/addon-devel/config/settings/scene/ambient"), getpropaddon("/addon-devel/config/settings/dome/sky"), getpropaddon("/addon-devel/config/settings/dome/fog"), getpropaddon("/addon-devel/config/settings/dome/cloud")];
  they = ["rendering/scene/diffuse", "rendering/scene/specular", "rendering/scene/ambient", "rendering/dome/sky", "rendering/dome/fog", "rendering/dome/cloud"];
  colors = ["/red", "/green", "/blue"];
  if (type == 'init') { # inits all necessary nodes as 'null' for the addon to work
    forindex (var i; my) {
      forindex (var j; colors) {
        props.globals.initNode(my[i]~colors[j], 'null');
      }
    }
  }
  if (type == 'refresh') { # sets simulator color settings to be the same as the addon color settings
    forindex (var i; my) {
      forindex (var j; colors) {
        props.globals.getNode(they[i] ~ colors[j]).setDoubleValue(props.globals.getNode(my[i] ~ colors[j]).getValue());
      }
    }
  }
  if (type == 'reset') { # sets addon color settings to the simulator color settings reseting the addon gui
    forindex (var i; my) {
      forindex (var j; colors) {
        props.globals.getNode(my[i] ~ colors[j]).setDoubleValue(props.globals.getNode(they[i] ~ colors[j]).getValue());
      }
    }
  }
}

var ambient_editor_save_file = func {
  var save_xml_sel = nil;
  var save_xml = func (n) { # callback function that gets return value of gui.FileSelector as first argument
    result = io.write_properties(n.getValue(), props.globals.getNode(getpropaddon("/addon-devel/config/settings")));
    if (result == nil) print("Ambient Editor: Error trying to save file."); else print("Ambient Editor: Saved file to " ~ result);
  }
  if (save_xml_sel == nil) save_xml_sel = gui.FileSelector.new(save_xml, "Save...", "Save", ["*.xml"], getprop(getpropaddon("/addon-devel/storage-path")), "*.xml");
  save_xml_sel.open();
  gui.popupTip ("Great! Now move the preset file from " ~ getprop(getpropaddon("/addon-devel/storage-path")) ~ " to the addon presets folder", 15);
}

var ambient_editor_load_preset = func (type) {
  var listN = cmdarg().getNode("group[1]/list"); # gets the property node of the import dialog list
  var path_addon = getprop(getpropaddon("/path")) ~ "/presets/";
  var path_appdata = getprop(getpropaddon("/addon-devel/storage-path"));
  var dir_addon = directory(path_addon); # gets all files in a directory
  var dir_appdata = directory(path_appdata);
  var list = [];
  if (type == 'sync') {
    foreach (var file; sort(dir_addon, cmp)) # loops addon directory looking for xml files
      if (size(file) > 4 and substr(file, -4) == ".xml") append(list, split(".", file)[0]); # if is xml append to list
    foreach (var file; sort(dir_appdata, cmp)) # loops appdata directory looking for xml files
      if (size(file) > 4 and substr(file, -4) == ".xml") append(list, split(".", file)[0]); # if is xml append to list
    listN.removeChildren("value"); # delete all children inside the import dialog list to clear it
    forindex (var i; list) # for each entry in list
      listN.addChild("value").setValue(list[i]); # add it as a child of the import dialog list
    fgcommand( "dialog-update", props.Node.new({"dialog-name" : "ambient_editor_import_list"}) ); # reloads import dialog
  }
  if (type == 'import') {
    var node = props.globals.getNode(getpropaddon("/addon-devel/config/settings"));
    var selection = getprop(getpropaddon("/addon-devel/config/selected-preset")); # gets selected preset
    var result = io.read_properties(path_appdata ~ "/" ~ selection ~ ".xml"); # check for preset in appdata folder
    if (result == nil) result = io.read_properties(path_addon ~ "/" ~ selection ~ ".xml"); # check for preset in addon folder
    if (result != nil) props.copy(result, node); # if returned correctly copy the preset props to property tree
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
