
namespace NeoLayoutViewer {

	public class ConfigManager {

		public Gee.Map<string,string> config;
		private Gee.Map<string,string> description; // allow optional commenting config entrys. 

		public ConfigManager(string path, string conffile) {
			this.config =  new Gee.TreeMap<string, string>();
			this.description =  new Gee.TreeMap<string, string>();

			//add defaults values, if key not set in the config file
			add_defaults();

			//no, it's better to create the conffile in the current dir.
			//var conffile2 = @"$(path)$(conffile)";

			if (!search_config_file(conffile)) {
				create_conf_file(conffile);
			} else {
				load_config_file(conffile);
			}

			//add path
			config.set("path", path);

			add_intern_values();
		}

		public Gee.Map<string, string> getConfig() {
			return config;
		}

		private void addSetting(string name, string val, string? comment) {
			config.set(name, val);

			if (comment != null) {
				description.set(name, comment);
			}
		}

		/*
			 Standardwerte der Einstellungen. Sie werden in eine Konfigurationsdatei geschrieben, falls
			 diese Datei nicht vorhanden ist.
			 Standard values. This vaules will be written in the config file if no config file found.
		*/
		public void add_defaults(){

			addSetting("show_shortcut","<Ctrl><Alt>q", "Toggle the visibility of the window.");
			addSetting("on_top","1", "Show window on top.");
			addSetting("position","3", "Window position on startup (num pad orientation)");
			addSetting("width","1000","Width in Pixel. Min_width and max_width bound sensible values. ");//Skalierung, sofern wert zwischen width(resolution)*max_width und width(resolution)*min_width
			addSetting("min_width","0.25", "Minimal width. 1=full screen width");//Relativ zur Auflösung
			addSetting("max_width","0.5", "Maximal width. 1=full screen width");//Relativ zur Auflösung
			addSetting("move_shortcut","<Ctrl><Alt>N", "Circle the window posisition");
			addSetting("position_cycle","2 3 6 1 3 9 4 7 8", "List of positions (num pad orientation)\n# The n-th number marks the next position of the window.\n# Limit the used position to the corners with\n#position_cycle = 3 3 9 1 3 9 1 7 7");
			addSetting("display_numpad","1", null);
			addSetting("display_function_keys","0", null);
			addSetting("window_selectable","0","To use the keyboard window as virtual keyboard, disable this entry.");
			addSetting("window_decoration","0","Show window decoration/border. Not recommended.");
			addSetting("screen_width","auto", "Set the resolution of your screen manually, if the automatic detection fails.");
			addSetting("screen_height","auto", "Set the resolution of your screen manually, if the automatic detection fails.");
		}

		/*
			 Einstellungen, die der Übersicht halber nicht in der Konfigurationsdatei stehen.
		*/
		private void add_intern_values() {
			config.set("numpad_width","350");
			config.set("function_keys_height","30");
		} 

		private bool search_config_file(string conffile) {
			var file = File.new_for_path(conffile);
			return file.query_exists(null);
		}

		private int create_conf_file(string conffile) {
			var file = File.new_for_path(conffile);

			try {
				//Create a new file with this name
				var file_stream = file.create(FileCreateFlags.NONE);

				// Test for the existence of file
				if (!file.query_exists()) {
					stdout.printf("Can't create config file.\n");
					return -1;
				}

				// Write text data to file 
				var data_stream = new DataOutputStream(file_stream);

				foreach (Gee.Map.Entry<string, string> e in this.config.entries) {

					if (this.description.has_key(e.key)) {
						data_stream.put_string("# " + this.description.get(e.key) + "\n");
					}

					data_stream.put_string(e.key + " = " + e.value + "\n");
				}
			} // Streams 
			catch (GLib.IOError e) { return -1; }
			catch (GLib.Error e) { return -1; }

			return 0;
		}

		private int load_config_file(string conffile) {

			// A reference to our file
			var file = File.new_for_path(conffile);

			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var in_stream = new DataInputStream(file.read(null));
				string line;
				string[] split;
				var comment = new Regex("^#.*$");
				var regex = new Regex("(#[^=]*)*[ ]*=[ ]*");

				// Read lines until end of file (null) is reached
				while ((line = in_stream.read_line(null, null)) != null) {

					if (comment.match(line)) continue;

					split = regex.split(line);

					if (split.length > 1) {
						this.config.set(split[0], split[1]);
					}
				}
			} catch (GLib.IOError e) {
				error ("%s", e.message);
			} catch (RegexError e) {
				error ("%s", e.message);
			} catch (GLib.Error e) {
				error ("%s", e.message);
			}

			return 0;
		}

	} // end ConfigManager
} // end namespace
