import os
import json
import shutil
import subprocess
from datetime import datetime
from tzlocal import get_localzone

# Map-specific UTC offsets
MAP_UTC_OFFSETS = {
    "Caucasus": 3,
    "Marianas": 10,
    "Nevada": -7,  # -8 in winter
    "Persian Gulf": 4
}

def calculate_offset(map_name):
    local_tz = get_localzone()
    local_offset = local_tz.utcoffset(datetime.now()).total_seconds() / 3600
    map_offset = MAP_UTC_OFFSETS.get(map_name, 0)
    return int(map_offset - local_offset)

def apply_replacements(text, replacements):
    for placeholder, actual in replacements.items():
        text = text.replace(placeholder, actual)
    return text

def create_template_from_config(bak_path, template_path, replacements):
    with open(bak_path, 'r', encoding='utf-8') as f:
        content = f.read()
    for actual, placeholder  in replacements.items():
        content = content.replace(actual, placeholder)
    with open(template_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Created template at {template_path}")

def generate_config_from_template(template_path, output_path, replacements):
    with open(template_path, 'r', encoding='utf-8') as f:
        template = f.read()
    result = apply_replacements(template, replacements)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(result)
    print(f"✅ Updated config.toml at {output_path}")

def launch_realweather_exe(realweather_dir):
    exe_path = os.path.join(realweather_dir, "realweather.exe")
    if os.path.exists(exe_path):
        print(f"🚀 Launching RealWeather: {exe_path}")
        subprocess.Popen([exe_path], cwd=realweather_dir)
    else:
        print(f"❌ realweather.exe not found at: {exe_path}")

def main():
    with open("input.json", "r") as f:
        input_data = json.load(f)

    rw_dir = os.path.expandvars(input_data["filepaths"]["realweather_dir"])
    missions_dir = os.path.expandvars(input_data["filepaths"]["missons_dir"])
    input_mission_path = os.path.join(missions_dir, input_data["filepaths"]["input_mission_file"])
    output_mission_path = os.path.join(missions_dir, input_data["filepaths"]["output_mission_file"])

    # Escape them
    input_mission_path = input_mission_path.replace("\\", "\\\\")
    output_mission_path = output_mission_path.replace("\\", "\\\\")

    config_path = os.path.join(rw_dir, "config.toml")
    bak_path = os.path.join(rw_dir, "config.toml.bak")
    template_path = os.path.join(rw_dir, "config.toml.template")

    replacements_to_template = {
        "input = \"$input_mission_path\"": "input = \"mission.miz\"",
        "output = \"$output_mission_path\"": "output = \"realweather.miz\"",
        "icao = \"$icao\"": "icao = \"UGKO\"",
        "system-time = true": "system-time = false",
        "offset = \"$offset\"": "offset = \"0\"        # offset system or METAR time by this amount"
    }

    reverse_replacements = {v: k for k, v in replacements_to_template.items()}

    replacements_to_config = {
        "$input_mission_path": input_mission_path,
        "$output_mission_path": output_mission_path,
        "$icao": input_data["icao"],
        "$offset": str(calculate_offset(input_data["map"])) + "h"
    }

    if not os.path.exists(bak_path):
        shutil.copyfile(config_path, bak_path)
        create_template_from_config(bak_path, template_path, reverse_replacements)
    else:
        print(f"ℹ️ Backup already exists at {bak_path}, skipping template generation")

    generate_config_from_template(template_path, config_path, replacements_to_config)

    launch_realweather_exe(rw_dir)

if __name__ == "__main__":
    main()
